local ok_ts, treesitter = pcall(require, "nvim-treesitter")
if ok_ts then
  pcall(treesitter.setup, {})
end

-- Enable treesitter highlighting for all filetypes with a parser available
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Code folding based on treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
