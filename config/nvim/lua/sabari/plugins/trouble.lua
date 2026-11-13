vim.pack.add({ "https://github.com/folke/trouble.nvim" })

require("trouble").setup({
    focus = true,
    win = { position = "bottom", size = 0.3 },
    keys = { q = "close" },
})

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", {
    desc = "Toggle diagnostics (Trouble)",
})
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", {
    desc = "Toggle buffer diagnostics (Trouble)",
})
