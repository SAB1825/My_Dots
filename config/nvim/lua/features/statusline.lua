local theme = vim.deepcopy(require("lualine.themes.moonfly"))
for _, sections in pairs(theme) do
    -- Keep the mode badge solid without giving the right-hand section its background.
    sections.z = vim.deepcopy(sections.a)
    for section, highlight in pairs(sections) do
        if section ~= "a" then
            highlight.bg = "NONE"
        end
    end
end

require("lualine").setup({
    options = {
        theme = theme,
        globalstatus = true,
        icons_enabled = false,
        component_separators = "|",
        section_separators = "",
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = {
            "branch",
            {
                "diff",
                source = function()
                    local summary = vim.b.minidiff_summary
                    if not summary then
                        return nil
                    end
                    return {
                        added = summary.add,
                        modified = summary.change,
                        removed = summary.delete,
                    }
                end,
            },
        },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = {
            { "diagnostics", sources = { "nvim_diagnostic" } },
            "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
})
