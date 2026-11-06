require("mason").setup()

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("mini.completion").get_lsp_capabilities())

vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("lua_ls", {
    root_dir = function(bufnr, on_dir)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local config_dir = vim.fn.stdpath("config")
        if vim.fs.relpath(config_dir, filename) then
            on_dir(config_dir)
            return
        end

        local root = vim.fs.root(bufnr, {
            ".luarc.json",
            ".luarc.jsonc",
            ".emmyrc.json",
            ".stylua.toml",
            "stylua.toml",
            ".git",
        })
        if not root or root == vim.env.HOME then
            root = vim.fs.dirname(filename)
        end
        if root and root ~= vim.env.HOME then
            on_dir(root)
        end
    end,
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            runtime = { version = "LuaJIT" },
            workspace = {
                checkThirdParty = false,
                library = { vim.env.VIMRUNTIME },
            },
            format = { enable = true },
        },
    },
})

vim.lsp.enable({
    "lua_ls",
    "marksman",
    "gopls",
    "rust_analyzer",
})
