-- Register before installation to build the native library on first install too.
vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("FffNativeBuild", { clear = true }),
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "fff" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("fff")
			end
			require("fff.download").download_or_build_binary()
		end
	end,
})


vim.pack.add({ "https://github.com/dmtrKovalenko/fff" })

local fff = require("fff")
fff.setup({
    title = "Find Files",
    max_results = 100,
    max_threads = 4,
    lazy_sync = true,
    prompt = "🛸 ",
    layout = {
        width = 0.75,
        height = 0.85,
        prompt_position = "bottom",
        preview_position = "right",
        preview_size = 0.5,
        flex = false,
    },
    preview = {
        enabled = true,
        max_lines = 100,
        max_size = 10 * 1024 * 1024, -- 10 MB
        chunk_size = 8192,
        binary_file_threshold = 1024,
        line_numbers = false,
        wrap_lines = false,
        show_file_info = true,
    },
    keymaps = {
        close = { "<C-c>", "<Esc>" },
        select = "<CR>",
        select_split = "<C-s>",
        select_vsplit = "<C-v>",
        select_tab = "<C-t>",
        move_up = { "<Up>", "<C-p>", "<C-k>" },
        move_down = { "<Down>", "<C-n>", "<C-j>" },
        preview_scroll_up = "<C-u>",
        preview_scroll_down = "<C-d>",
    },
    git = { status_text_color = true },
    hl = {
        border = "FloatBorder",
        normal = "Normal",
        cursor = "CursorLine",
        matched = "IncSearch",
        title = "Title",
        prompt = "Question",
        active_file = "Visual",
        frecency = "Number",
        debug = "Comment",
        git_staged = "FFFGitStaged",
        git_modified = "FFFGitModified",
        git_deleted = "FFFGitDeleted",
        git_renamed = "FFFGitRenamed",
        git_untracked = "FFFGitUntracked",
        git_ignored = "FFFGitIgnored",
    },
    frecency = {
        enabled = true,
        db_path = vim.fn.stdpath("cache") .. "/fff_nvim",
    },
    history = {
        enabled = true,
        db_path = vim.fn.stdpath("data") .. "/fff_queries",
        min_combo_count = 3,
        combo_boost_score_multiplier = 100,
    },
    debug = { show_scores = false },
})

vim.keymap.set("n", "<leader>ff", function()
    fff.find_files()
end, { desc = "Open file picker" })
vim.keymap.set("n", "<leader>fl", function()
    fff.live_grep({ grep = { modes = { "fuzzy", "plain" } } })
end, { desc = "Live fuzzy grep" })
vim.keymap.set("n", "<leader>pgf", function()
    fff.find_in_git_root()
end, { desc = "Find files in Git root" })
vim.keymap.set("n", "<leader>pcf", function()
    fff.find_files_in_dir(vim.fn.stdpath("config"))
end, { desc = "Find Neovim configuration files" })
