local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofmt" },
    },
    format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",
    },
})

local function format_buffer()
    conform.format({
        bufnr = vim.api.nvim_get_current_buf(),
        timeout_ms = 3000,
        lsp_format = "fallback",
    })
end

vim.keymap.set("n", "<leader>f", format_buffer, { desc = "Format current buffer" })
