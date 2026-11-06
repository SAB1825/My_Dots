require("mini.completion").setup({
    lsp_completion = {
        auto_setup = true,
    },
})

-- Clear menu backgrounds while keeping the selected row opaque.
local function completion_highlights()
    for _, group in ipairs({ "Pmenu", "PmenuKind", "PmenuExtra", "PmenuMatch", "PmenuSbar" }) do
        local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
        highlight.bg = nil
        highlight.ctermbg = nil
        vim.api.nvim_set_hl(0, group, highlight)
    end

    local selected = vim.api.nvim_get_hl(0, { name = "PmenuSel", link = false })
    selected.bg = selected.bg or "#303030"
    selected.fg = selected.fg or "#c6c6c6"
    vim.api.nvim_set_hl(0, "PmenuSel", selected)
    for _, group in ipairs({ "PmenuKindSel", "PmenuExtraSel", "PmenuMatchSel" }) do
        local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
        highlight.bg = selected.bg
        highlight.ctermbg = nil
        vim.api.nvim_set_hl(0, group, highlight)
    end
end

vim.opt.pumblend = 0
completion_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("CompletionAppearance", { clear = true }),
    callback = completion_highlights,
})

local function map_key(key, action, description)
    vim.keymap.set("i", key, action, { expr = true, desc = description })
end

map_key("<Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, "Next completion or Tab")

map_key("<S-Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, "Previous completion or Shift-Tab")

map_key("<CR>", function()
    if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1 then
        return "<C-y>"
    end
    return "<CR>"
end, "Accept selected completion or newline")

for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
    map_key(key, function()
        return vim.fn.pumvisible() == 1 and "<Ignore>" or key
    end, "Disable arrow navigation during completion")
end
