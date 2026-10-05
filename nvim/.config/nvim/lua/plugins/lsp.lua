-- LSP completo: mason instala los servidores, nvim-lspconfig los configura.
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim", opts = {} },
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp", -- para anunciar las capacidades de completado
    },
    config = function()
      -- Servidores a instalar automáticamente (acordes a tu stack en packages.txt).
      -- Para añadir más: amplía esta lista o ejecuta :Mason.
      local servers = {
        "lua_ls", -- Lua (config de Neovim)
        "bashls", -- Bash/zsh scripts
        "pyright", -- Python: types
        "ruff", -- Python: lint, imports, format (also installs the ruff CLI for conform)
        "gopls", -- Go
        "ts_ls", -- JavaScript/TypeScript
        "html",
        "cssls",
        "jsonls",
        "yamlls",
        "taplo", -- TOML
        "dockerls",
        "terraformls", -- Terraform
        "ansiblels", -- Ansible (filetype yaml.ansible, see options.lua)
        "intelephense", -- PHP
      }

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        -- stylua is installed as a formatter for conform; its LSP mode would format
        -- Lua with default settings (tabs) in projects that have no stylua config
        automatic_enable = { exclude = { "stylua" } },
      })

      -- Non-LSP tools: formatters for conform and the linter bashls calls
      local registry = require("mason-registry")
      registry.refresh(function()
        for _, name in ipairs({ "stylua", "prettier", "shellcheck" }) do
          local pkg = registry.get_package(name)
          if not pkg:is_installed() then
            pkg:install()
          end
        end
      end)

      -- Capacidades extendidas por nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Ajuste para lua_ls: que reconozca el global `vim` y no se queje
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            format = { enable = false }, -- stylua via conform
          },
        },
      })

      vim.lsp.config("ansiblels", {
        settings = {
          ansible = { validation = { lint = { enabled = vim.fn.executable("ansible-lint") == 1 } } },
        },
      })

      -- ruff owns imports and lint; pyright only does types
      vim.lsp.config("pyright", {
        settings = { pyright = { disableOrganizeImports = true } },
      })

      -- Capacidades por defecto para todos los servidores
      vim.lsp.config("*", { capabilities = capabilities })

      -- Diagnósticos: signos en la columna y virtual text discreto
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        severity_sort = true,
        signs = true,
      })

      -- Atajos LSP (solo activos en buffers con un servidor adjunto). Aditivos: no
      -- pisan ninguno de tus mapeos originales.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
        callback = function(ev)
          -- terraform-ls (<=0.38.x) emite semantic tokens corruptos (deltas
          -- negativos desbordados como uint32) en archivos con heredocs <<-EOT,
          -- y Neovim se queda al 100% de CPU decodificándolos (editor congelado).
          -- Se desactivan: el resaltado de .tf lo da el parser terraform de treesitter.
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "terraformls" then
            client.server_capabilities.semanticTokensProvider = nil
          end
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false -- pyright's hover is the useful one
          end

          local function m(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          -- fzf-lua: jumps directly on a single result, otherwise a filterable list
          m("gd", "<cmd>FzfLua lsp_definitions<CR>", "ir a definición")
          m("gD", vim.lsp.buf.declaration, "ir a declaración")
          m("gr", "<cmd>FzfLua lsp_references<CR>", "referencias")
          m("gi", "<cmd>FzfLua lsp_implementations<CR>", "implementación")
          m("gy", "<cmd>FzfLua lsp_typedefs<CR>", "definición de tipo")
          m("K", vim.lsp.buf.hover, "documentación flotante")
          m("<leader>rn", vim.lsp.buf.rename, "renombrar símbolo")
          m("<leader>ca", vim.lsp.buf.code_action, "acción de código")
          m("<leader>d", vim.diagnostic.open_float, "diagnóstico de la línea")
          m("[d", function()
            vim.diagnostic.jump({ count = -1 })
          end, "diagnóstico anterior")
          m("]d", function()
            vim.diagnostic.jump({ count = 1 })
          end, "diagnóstico siguiente")
          m("<leader>f", function()
            require("conform").format({ async = true })
          end, "formatear buffer")
        end,
      })
    end,
  },
}
