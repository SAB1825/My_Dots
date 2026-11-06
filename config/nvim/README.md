# My Neovim Setup

`init.lua` lists the modules in their loading order. Plugins are installed before
their feature configurations, and the leader key is Space.

## Configuration layout

| Location | Purpose |
| --- | --- |
| `lua/config/options.lua` | Editor options and cursor shapes |
| `lua/config/keymaps.lua` | General editing and navigation mappings |
| `lua/config/autocmds.lua` | General editor events |
| `lua/config/commands.lua` | Plugin management commands |
| `lua/config/plugins.lua` | All plugin declarations |
| `lua/features/` | One module per feature, including its keymaps |

Feature modules include Oil, MiniFiles, search, Git, completion, snippets,
formatting, LSP, diagnostics, Trouble, Treesitter, Markdown, statusline, colors,
icons, notifications, surround, and command-line UI.

Use `features.oil` and other names under `features` for configuration modules.
This prevents local files from shadowing plugin modules such as `oil`.

## Common mappings

| Keys | Action |
| --- | --- |
| `Space o` / `Space e` | Open Oil (`q` closes it) |
| `-` / `Space -` | Open MiniFiles |
| `Space ff` | Find files |
| `Space fg` | Grep the word under the cursor |
| `Space fh` | Find help |
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

