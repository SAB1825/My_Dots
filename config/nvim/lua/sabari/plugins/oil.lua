vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({
    float = {
        max_width = 0.6,
        max_height = 0.6,
        border = "rounded",
    },
    win_options = {
        signcolumn = "yes:2",
    },
    view_options = {
        show_hidden = true,
    },
    watch_for_changes = true,
    use_default_keymaps = false,
    keymaps = {
        ["<CR>"] = "actions.select",
        ["q"] = { "actions.close", mode = "n" },
    },
})
vim.keymap.set("n", "<leader>o", "<cmd>Oil --float<cr>", { silent = true, desc = "Open Oil floating explorer" })
vim.keymap.set("n", "<leader>e", "<cmd>Oil --float<cr>", { silent = true, desc = "Open Oil floating explorer" })
