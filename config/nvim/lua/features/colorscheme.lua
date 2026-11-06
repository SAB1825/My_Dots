-- Moonfly colorscheme
vim.g.moonflyTransparent = true

vim.cmd.colorscheme("moonfly")

local transparent_groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "EndOfBuffer",
    "LineNr",
    "CursorLineNr",
    "WinSeparator",
    "StatusLine",
    "StatusLineNC",
    "TabLine",
    "TabLineFill",
    "TabLineSel",
    "MiniFilesNormal",
    "MiniFilesBorder",
    "MiniPickNormal",
    "MiniPickBorder",
}

for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
end
