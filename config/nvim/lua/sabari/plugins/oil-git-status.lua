vim.pack.add({ "https://github.com/refractalize/oil-git-status.nvim" })

require("oil-git-status").setup({
    show_ignored = false,
})
