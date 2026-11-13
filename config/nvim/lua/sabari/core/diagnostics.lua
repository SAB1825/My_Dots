vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
    underline = true,
    update_in_insert = false,
    float = {
        border = "rounded",
        source = "if_many",
        header = "Diagnostics",
        scope = "line",
        severity = { min = vim.diagnostic.severity.WARN },
        close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertEnter", "WinLeave" },
    },
})

vim.keymap.set("n", "df", function()
    vim.diagnostic.open_float({ scope = "line" })
end, { desc = "Show line diagnostics" })

-- Show errors and warnings after pausing on a line in Normal mode.
vim.opt.updatetime = 500
vim.api.nvim_create_autocmd("CursorHold", {
    group = vim.api.nvim_create_augroup("LineDiagnosticFloat", { clear = true }),
    callback = function(args)
        if vim.bo[args.buf].buftype ~= "" or vim.api.nvim_get_mode().mode ~= "n" then
            return
        end
        -- Only avoid covering interactive popups; UI/message floats can stay open.
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= "" and config.focusable then
                return
            end
        end
        vim.diagnostic.open_float(args.buf, { scope = "line", focus = false })
    end,
})
