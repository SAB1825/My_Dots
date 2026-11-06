-- Editor settings and plugin installation.
require("config.options")
require("config.keymaps")
require("config.commands")
require("config.autocmds")
require("config.plugins")

-- Appearance and interface.
require("features.colorscheme")
require("features.icons")
require("features.notifications")
require("features.cmdline")
require("features.statusline")

-- Navigation and editing.
require("features.files")
require("features.oil")
require("features.search")
require("features.surround")
require("features.git")

-- Language tools.
require("features.treesitter")
require("features.markdown")
require("features.completion")
require("features.snippets")
require("features.formatting")
require("features.lsp")
require("features.diagnostics")
require("features.trouble")
