local ok_tree, tree = pcall(require, "nvim-tree")
if not ok_tree then
  return
end

-- Disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local has_devicons, _ = pcall(require, "nvim-web-devicons")

tree.setup({
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    icons = {
      show = {
        file = has_devicons,
        folder = has_devicons,
        folder_arrow = has_devicons,
        git = has_devicons,
      },
    },
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
  },
})

vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { silent = true, desc = "Toggle file tree" })
