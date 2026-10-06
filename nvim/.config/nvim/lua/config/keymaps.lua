-- Atajos — los mismos que tenías en ~/.vimrc (los de LSP están en lua/plugins/lsp.lua).
-- Explorer (<leader>e) lives in plugins/explorer.lua; grep moved to <leader>/ (plugins/picker.lua)
-- so <leader>g can be the git prefix. :grep still works and fills the quickfix list.
local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Guardar" })
map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Quitar resaltado de búsqueda" })
