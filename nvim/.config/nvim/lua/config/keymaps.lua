-- Atajos — los mismos que tenías en ~/.vimrc (los de LSP están en lua/plugins/lsp.lua)
local map = vim.keymap.set

map("n", "<leader>e", "<cmd>Explore<CR>", { desc = "Explorador de archivos (netrw)" })
map("n", "<leader>g", ":grep ", { desc = "Buscar con ripgrep (:grep)" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Guardar" })
map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Quitar resaltado de búsqueda" })
