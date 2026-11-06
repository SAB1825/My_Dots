local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")
MiniPick.setup()
MiniExtra.setup()

-- keymaps
vim.keymap.set("n", "<leader>ff", function()
    MiniPick.builtin.files()
end, { desc = "Mini File Picker" })
vim.keymap.set("n", "<leader>fg", function()
    MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") })
end, { desc = "Grep word/Search word" })
vim.keymap.set("n", "<leader>fh", function()
    MiniPick.builtin.help()
end, { desc = "Mini Help" })

vim.keymap.set("n", "<leader>pk", function()
    MiniExtra.pickers.keymaps()
end, { desc = "Search keymaps" })
