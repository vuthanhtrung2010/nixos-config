-- Leader keys (must be set before plugins/mappings load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core Editor Options
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250

-- Diagnostic float shortcut
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- Auto-stop search highlighting when cursor moves to somewhere else
local hl_ns = vim.api.nvim_create_namespace("auto_hlsearch")
vim.on_key(function(char)
  if vim.api.nvim_get_mode().mode == "n" then
    local key = vim.fn.keytrans(char)
    local search_keys = { "<CR>", "n", "N", "*", "#", "?", "/" }
    if vim.tbl_contains(search_keys, key) then
      vim.opt.hlsearch = true
    else
      vim.opt.hlsearch = false
    end
  end
end, hl_ns)

-- Load custom LuaSnip snippets
local ok_ls, ls_loaders = pcall(require, "luasnip.loaders.from_lua")
if ok_ls then
  ls_loaders.load({
    paths = {
      vim.fn.stdpath("config") .. "/lua/snippets",
      vim.fn.expand("~/.config/nvim/lua/snippets"),
    },
  })
end

-- Load Modular Plugins Configuration
require("plugins.ui")
require("plugins.tree")
require("plugins.treesitter")
require("plugins.telescope")
require("plugins.completion")
require("plugins.autopairs")
require("plugins.typst")
require("plugins.context")
