local ok_plenary, _ = pcall(require, "plenary")
if not ok_plenary then
  return
end

local ok_tele, telescope = pcall(require, "telescope")
if not ok_tele then
  return
end

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      },
    },
  },
})

local ok_builtin, builtin = pcall(require, "telescope.builtin")
if ok_builtin then
  local map = vim.keymap.set
  map("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
  map("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
  map("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
  map("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
end
