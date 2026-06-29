-- ~/.config/nvim/init.lua — punto de entrada
-- Migrado desde ~/.vimrc: mismos atajos, Dracula potenciado y LSP completo.

require("config.options") -- sets (porta el .vimrc) + leader
require("config.keymaps") -- atajos de teclado originales
require("config.lazy") -- gestor de plugins + carga de lua/plugins/*
