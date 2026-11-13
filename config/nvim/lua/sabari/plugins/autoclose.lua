vim.pack.add({ "https://github.com/m4xshen/autoclose.nvim" })

require("autoclose").setup({
	keys = {
		["$"] = { escape = true, close = true, pair = "$$", disabled_filetypes = {} },
	},
})
