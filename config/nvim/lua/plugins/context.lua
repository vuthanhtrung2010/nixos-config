-- Zed-style top bar breadcrumbs (showing file > enclosing function/class)
local ok_dropbar, dropbar = pcall(require, "dropbar")
if ok_dropbar then
  dropbar.setup({
    bar = {
      enable = true,
      attach_opts = {
        -- Don't attach to prompt or file tree windows
        filetypes = {
          buftype = {
            ["nofile"] = false,
            ["prompt"] = false,
            ["help"] = false,
          },
        },
      },
    },
  })
end

-- Zed-style sticky scroll (pins the function/class header at the top when scrolling)
local ok_tsc, tsc = pcall(require, "treesitter-context")
if ok_tsc then
  tsc.setup({
    enable = true,
    max_lines = 3,            -- Maximum lines for the sticky header
    min_window_height = 0,
    line_numbers = true,
    multiline_threshold = 20, -- Maximum lines to show for a single context
    trim_scope = "outer",     -- Discard outer context if max_lines is exceeded
    mode = "cursor",          -- Follow cursor context
  })
end
