local ok_theme, _ = pcall(vim.cmd.colorscheme, "tokyonight")
if not ok_theme then
  pcall(vim.cmd.colorscheme, "default")
end

-- Statusline
local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
  local has_devicons, _ = pcall(require, "nvim-web-devicons")
  lualine.setup({
    options = {
      theme = "tokyonight",
      icons_enabled = has_devicons,
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
    },
  })
end

-- Buffer tabs
local ok_bufferline, bufferline = pcall(require, "bufferline")
if ok_bufferline then
  local has_devicons, _ = pcall(require, "nvim-web-devicons")
  bufferline.setup({
    options = {
      mode = "buffers",
      show_buffer_icons = has_devicons,
      separator_style = "thin",
      always_show_bufferline = true,
    },
  })
end

-- Buffer navigation keymaps
local map = vim.keymap.set
map("n", "<Tab>", "<cmd>bnext<CR>", { silent = true, desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { silent = true, desc = "Previous buffer" })
map("n", "<leader>x", "<cmd>bdelete<CR>", { silent = true, desc = "Close buffer" })
