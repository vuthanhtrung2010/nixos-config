vim.opt.clipboard = "unnamedplus"

require("luasnip.loaders.from_lua").load({
  paths = "~/.config/nvim/lua/snippets"
})

vim.opt.tabstop = 4        -- how many spaces a tab counts for
vim.opt.shiftwidth = 4     -- indentation size
vim.opt.expandtab = true   -- use spaces instead of real tabs
vim.opt.smartindent = true -- auto indent

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float) -- show warnings/errors

-- Disable search highlight when cursor moved
vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    vim.cmd("nohlsearch")
  end,
})
