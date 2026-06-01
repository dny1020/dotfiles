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
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
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
  { "WhoIsSethDaniel/mason-tool-installer.nvim", lazy = false },
  { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },
  { "hrsh7th/nvim-cmp", event = "InsertEnter" },
  { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
  { "L3MON4D3/LuaSnip", event = "InsertEnter" },
  { "saadparwaiz1/cmp_luasnip", event = "InsertEnter" },
  { "windwp/nvim-autopairs", event = "InsertEnter" },
  { "stevearc/conform.nvim", event = { "BufWritePre" }, cmd = { "ConformInfo" } },
  { "mfussenegger/nvim-lint", event = { "BufReadPost", "BufNewFile" } },
  { "christoomey/vim-tmux-navigator", lazy = false },
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

local mason_tools = safe_require("mason-tool-installer")
if mason_tools then
  mason_tools.setup({
    ensure_installed = {
      "stylua",
      "shfmt",
      "shellcheck",
      "ruff",
      "black",
      "isort",
      "prettierd",
      "prettier",
      "eslint_d",
    },
    run_on_start = true,
    auto_update = false,
    start_delay = 3000,
    debounce_hours = 24,
  })
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

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  update_in_insert = false,
  float = { border = "rounded", source = "if_many" },
})

local lsp_group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
    vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Implementation" }))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Line diagnostics" }))
    vim.keymap.set("n", "<leader>lf", function()
      vim.lsp.buf.format({ async = true })
    end, vim.tbl_extend("force", opts, { desc = "LSP format" }))
  end,
})

local autopairs = safe_require("nvim-autopairs")
if autopairs then
  autopairs.setup()
end

local conform = safe_require("conform")
if conform then
  conform.setup({
    notify_on_error = false,
    notify_no_formatters = false,
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },
      sh = { "shfmt" },
      zsh = { "shfmt" },
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 1200, lsp_format = "fallback" }
    end,
  })
end

local lint = safe_require("lint")
if lint then
  local lint_linters = {}

  if vim.fn.executable("ruff") == 1 then
    lint_linters.python = { "ruff" }
  end
  if vim.fn.executable("eslint_d") == 1 then
    lint_linters.javascript = { "eslint_d" }
    lint_linters.javascriptreact = { "eslint_d" }
    lint_linters.typescript = { "eslint_d" }
    lint_linters.typescriptreact = { "eslint_d" }
  end
  if vim.fn.executable("shellcheck") == 1 then
    lint_linters.sh = { "shellcheck" }
    lint_linters.bash = { "shellcheck" }
    lint_linters.zsh = { "shellcheck" }
  end

  lint.linters_by_ft = lint_linters

  if next(lint_linters) ~= nil then
    local lint_group = vim.api.nvim_create_augroup("UserLint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_group,
      callback = function()
        lint.try_lint()
      end,
    })
  end
end

-- Keymaps
local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>", { silent = true, desc = "Save buffer" })
map("n", "<leader>q", ":q<CR>", { silent = true, desc = "Quit" })
map("n", "<leader>Q", ":q!<CR>", { silent = true, desc = "Force quit" })
map("n", "<C-s>", ":w<CR>", { silent = true, desc = "Save buffer" })
map("i", "<C-s>", "<Esc>:w<CR>a", { silent = true, desc = "Save buffer" })
map("n", "<leader>h", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
map("v", "<", "<gv", { silent = true })
map("v", ">", ">gv", { silent = true })

map("n", "[d", vim.diagnostic.goto_prev, { silent = true, desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { silent = true, desc = "Next diagnostic" })

map("n", "<C-p>", ":Telescope find_files<CR>", { silent = true, desc = "Find files" })
map("n", "<leader>ff", ":Telescope find_files<CR>", { silent = true, desc = "Find files" })
map("n", "<leader>fb", ":Telescope buffers<CR>", { silent = true, desc = "Find buffers" })
map("n", "<leader>fr", ":Telescope live_grep<CR>", { silent = true, desc = "Live grep" })
map("n", "<leader>fd", ":Telescope diagnostics<CR>", { silent = true, desc = "Diagnostics" })

map("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle tree" })
map("n", "<leader>E", ":NvimTreeFindFileToggle<CR>", { silent = true, desc = "Tree find file" })

map({ "n", "v" }, "<leader>f", function()
  if conform then
    conform.format({ async = true, lsp_format = "fallback" })
  else
    vim.lsp.buf.format({ async = true })
  end
end, { silent = true, desc = "Format buffer" })

if lint then
  map("n", "<leader>ll", function()
    lint.try_lint()
  end, { silent = true, desc = "Run linter" })
end
