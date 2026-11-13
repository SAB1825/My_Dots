# My Neovim Setup

The leader key is Space. `init.lua` loads `lua/sabari/init.lua`, which loads
editor settings before the plugins.

## Configuration layout

```text
init.lua
lua/sabari/
├── init.lua
├── core/
│   ├── options.lua
│   ├── keymaps.lua
│   ├── commands.lua
│   ├── autocmds.lua
│   └── diagnostics.lua
└── plugins/
    ├── init.lua              -- explicit plugin loading order
    ├── mini.lua              -- all Mini features and their mappings
    ├── fff.lua               -- FFF search, mappings, and native build hook
    └── ...                   -- one file per other plugin
```

Each plugin file declares its package with `vim.pack.add` and contains its
configuration and mappings. `plugins/init.lua` controls loading order.
`plugins/mini.lua` groups icons, notifications, command line, file explorer,
surround, Git signs, completion, and optional snippets. Snippets remain
disabled; enable them with `enable_snippets` in that file.

Use names such as `sabari.plugins.oil` for configuration modules so they do not
shadow plugin modules such as `oil`.

## Common mappings

| Keys | Action |
| --- | --- |
| `Space o` / `Space e` | Open Oil (`q` closes it) |
| `-` / `Space -` | Open MiniFiles |
| `Space ff` | Find files with FFF |
| `Space fl` | Live fuzzy/plain grep with FFF |
| `Space pgf` | Find files in Git root |
| `Space pcf` | Find Neovim configuration files |
| `Space f` | Format the current buffer |
| `Space xx` / `Space xX` | Toggle workspace / current-buffer diagnostics |
| `df` | Show line diagnostics |
| `Space gg` / `Space gd` | Git status / diff |

Formatting also runs on save: StyLua for Lua, gofmt for Go, qmlformat for QML, and LSP fallback for
other file types. Install formatter executables separately; `:ConformInfo` shows
their availability. Errors and warnings appear after pausing on a line for 500 ms
in Normal mode.

QML uses the `qmljs` Treesitter parser and Qt's QML language server for
completion, navigation, and diagnostics. Install Qt's `qmlls` (or `qmlls6`) and
`qmlformat` executables separately. The parser installs automatically on startup.

