require("oil").setup({
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
require("oil-git-status").setup({
    show_ignored = false,
})

vim.keymap.set("n", "<leader>o", "<cmd>Oil<cr>", { silent = true, desc = "Open Oil file explorer" })
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { silent = true, desc = "Open Oil file explorer" })
