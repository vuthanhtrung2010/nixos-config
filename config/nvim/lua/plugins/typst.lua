local ok_preview, typst_preview = pcall(require, "typst-preview")
if not ok_preview then
  return
end

typst_preview.setup({
  dependencies_bin = {
    ["tinymist"] = "tinymist",
  },
})

local map = vim.keymap.set
map("n", "<leader>tp", "<cmd>TypstPreviewToggle<CR>", { silent = true, desc = "Toggle Typst Preview" })
map("n", "<leader>tc", "<cmd>TypstPreviewSyncCursor<CR>", { silent = true, desc = "Sync Typst Preview to cursor" })
