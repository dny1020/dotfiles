vim.g.mapleader = " "

-- Core options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.updatetime = 300
vim.opt.timeoutlen = 400
vim.opt.ttimeoutlen = 10
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.errorbells = false
vim.opt.history = 1000
vim.opt.autoread = true
vim.opt.confirm = true
vim.opt.foldenable = false

-- Persistent state (avoid /tmp so plugins are not reinstalled frequently)
local function ensure_dir(path)
  if vim.fn.isdirectory(path) == 1 then
    return true
  end
  return vim.fn.mkdir(path, "p") == 1
end

local undodir = vim.fn.stdpath("state") .. "/undo"
local shadadir = vim.fn.stdpath("state") .. "/shada"
if ensure_dir(undodir) then
  vim.opt.undodir = undodir
else
  vim.opt.undofile = false
end
if ensure_dir(shadadir) then
  vim.opt.shadafile = shadadir .. "/main.shada"
end

-- Bootstrap lazy.nvim in persistent stdpath("data")
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.fn.empty(vim.fn.glob(lazypath)) > 0 then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local ok_lazy, lazy = pcall(require, "lazy")
if not ok_lazy then
  vim.notify("lazy.nvim not found; plugins disabled", vim.log.levels.WARN)
  return
end

lazy.setup({
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  { "nvim-lualine/lualine.nvim", event = "VeryLazy" },
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle", "NvimTreeOpen" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
  },
  { "lewis6991/gitsigns.nvim", event = "BufReadPre" },
  { "williamboman/mason.nvim", cmd = { "Mason", "MasonInstall", "MasonUpdate" } },
  { "williamboman/mason-lspconfig.nvim", event = "VeryLazy" },
  { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },
  { "hrsh7th/nvim-cmp", event = "InsertEnter" },
  { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
  { "L3MON4D3/LuaSnip", event = "InsertEnter" },
  { "saadparwaiz1/cmp_luasnip", event = "InsertEnter" },
  { "windwp/nvim-autopairs", event = "InsertEnter" },
}, {
  checker = { enabled = false },
  change_detection = { notify = false },
  install = { missing = true, colorscheme = { "tokyonight", "habamax" } },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

local function safe_require(name)
  local ok, mod = pcall(require, name)
  if not ok then
    return nil
  end
  return mod
end

pcall(vim.cmd.colorscheme, "tokyonight")

local lualine = safe_require("lualine")
if lualine then
  lualine.setup({})
end

local gitsigns = safe_require("gitsigns")
if gitsigns then
  gitsigns.setup()
end

local telescope = safe_require("telescope")
if telescope then
  telescope.setup({
    defaults = {
      layout_strategy = "horizontal",
      sorting_strategy = "ascending",
    },
  })
end

local nvim_tree = safe_require("nvim-tree")
if nvim_tree then
  nvim_tree.setup({
    hijack_cursor = true,
    sync_root_with_cwd = true,
    view = {
      width = 34,
      side = "left",
    },
    renderer = {
      group_empty = true,
      highlight_git = true,
    },
    actions = {
      open_file = {
        quit_on_open = true,
      },
    },
    filters = {
      dotfiles = false,
    },
  })

  local tree_group = vim.api.nvim_create_augroup("UserNvimTree", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = tree_group,
    callback = function()
      if vim.fn.argc() == 0 then
        vim.cmd("NvimTreeOpen")
      end
    end,
  })
end

local ts = safe_require("nvim-treesitter.configs")
if ts then
  ts.setup({
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = { "bash", "lua", "vim", "vimdoc", "python", "javascript", "typescript", "json" },
  })
end

local mason = safe_require("mason")
if mason then
  mason.setup()
end

local cmp = safe_require("cmp")
local luasnip = safe_require("luasnip")
if cmp and luasnip then
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping.select_next_item(),
      ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    }),
    sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
    },
  })
end

local cmp_nvim_lsp = safe_require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities() or nil
local mason_lsp = safe_require("mason-lspconfig")

local servers = {
  pyright = {},
  ts_ls = {},
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
      },
    },
  },
}

if mason_lsp then
  mason_lsp.setup({ ensure_installed = vim.tbl_keys(servers) })
end

-- Neovim 0.11+ native LSP API (fast path, avoids lspconfig deprecation warnings)
if vim.lsp and vim.lsp.config and vim.lsp.enable then
  for server, cfg in pairs(servers) do
    cfg.capabilities = capabilities
    vim.lsp.config(server, cfg)
    vim.lsp.enable(server)
  end
else
  local lspconfig = safe_require("lspconfig")
  if lspconfig then
    for server, cfg in pairs(servers) do
      cfg.capabilities = capabilities
      if lspconfig[server] then
        lspconfig[server].setup(cfg)
      end
    end
  end
end

local autopairs = safe_require("nvim-autopairs")
if autopairs then
  autopairs.setup()
end

-- Keymaps
local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>", { silent = true })
map("n", "<leader>q", ":q<CR>", { silent = true })
map("n", "<leader>Q", ":q!<CR>", { silent = true })
map("n", "<C-s>", ":w<CR>", { silent = true })
map("i", "<C-s>", "<Esc>:w<CR>a", { silent = true })
map("n", "<leader>h", ":nohlsearch<CR>", { silent = true })
map("v", "<", "<gv", { silent = true })
map("v", ">", ">gv", { silent = true })
map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-j>", "<C-w>j", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })

map("n", "<C-p>", ":Telescope find_files<CR>", { silent = true })
map("n", "<leader>ff", ":Telescope find_files<CR>", { silent = true })
map("n", "<leader>fb", ":Telescope buffers<CR>", { silent = true })
map("n", "<leader>fr", ":Telescope live_grep<CR>", { silent = true })
map("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
map("n", "<leader>E", ":NvimTreeFindFileToggle<CR>", { silent = true })
