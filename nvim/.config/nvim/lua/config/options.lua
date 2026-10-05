-- Opciones — equivalente 1:1 a los `set` del antiguo ~/.vimrc

-- Leader (debe ir ANTES de cargar lazy y los mapeos)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Apariencia
opt.termguicolors = true -- color verdadero (necesario para Dracula en Alacritty)
opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.signcolumn = "yes" -- columna fija para diagnósticos/git (no salta el texto)
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.showmode = false
opt.laststatus = 3 -- a single statusline across all splits (lualine)
opt.showtabline = 0 -- sin barra de tabs
opt.cmdheight = 0
opt.colorcolumn = ""
opt.fillchars:append({ eob = " " }) -- oculta ~ del final del buffer
opt.foldenable = false

-- Edición (encoding, backspace, hidden, autoread ya son por defecto en Neovim)
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.splitright = true
opt.splitbelow = true
opt.updatetime = 250 -- faster CursorHold: gitsigns blame and LSP highlights

-- Portapapeles del sistema (xclip en X11): `y` copia y `p` pega contra el
-- clipboard, así que pegar de la web es `p` en modo normal y no pasa por el
-- teclado del terminal — no hay autoindent que lo escalone.
opt.clipboard = "unnamedplus"

-- Búsqueda
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true -- (incsearch ya es por defecto)

-- Archivos
opt.autoread = true
opt.undofile = true -- undo persistente (Neovim usa ~/.local/state/nvim/undo y lo crea solo)

-- Completado (lo gestiona nvim-cmp)
opt.completeopt = { "menu", "menuone", "noselect" }

-- Ripgrep para :grep
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

-- Limpieza al guardar (equivalente a trimTrailingWhitespace de VS Code)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("trim_trailing_whitespace", { clear = true }),
  callback = function(args)
    local view = vim.fn.winsaveview()
    vim.api.nvim_buf_call(args.buf, function()
      vim.cmd([[%s/\s\+$//e]])
    end)
    vim.fn.winrestview(view)
  end,
})

-- Abre la lista quickfix automáticamente tras :grep (tu <leader>g)
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = vim.api.nvim_create_augroup("auto_quickfix", { clear = true }),
  pattern = { "grep", "grepadd" },
  command = "cwindow",
})

-- autoread only applies when nvim checks the file; agents in another herdr
-- pane write behind its back, so check on focus, buffer switch and idle.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("reload_external_changes", { clear = true }),
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = vim.api.nvim_create_augroup("notify_external_changes", { clear = true }),
  callback = function(args)
    vim.notify("Reloaded (changed on disk): " .. vim.fn.fnamemodify(args.file, ":."), vim.log.levels.WARN)
  end,
})

-- Ansible lives in plain .yml files; these paths are what ansiblels attaches to
vim.filetype.add({
  pattern = {
    [".*/roles/.*/tasks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.ya?ml"] = "yaml.ansible",
    [".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
  },
})
vim.treesitter.language.register("yaml", "yaml.ansible")

-- Volver al último cursor al reabrir un archivo
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("last_cursor", { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 1 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
