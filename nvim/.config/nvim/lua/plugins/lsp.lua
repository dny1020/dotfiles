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
        "pyright", -- Python
        "ts_ls", -- JavaScript/TypeScript
        "html",
        "cssls",
        "jsonls",
        "yamlls",
        "taplo", -- TOML
        "dockerls",
        "terraformls", -- Terraform
        "intelephense", -- PHP
      }

      require("mason-lspconfig").setup({ ensure_installed = servers })

      -- Capacidades extendidas por nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Ajuste para lua_ls: que reconozca el global `vim` y no se queje
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
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
          local function m(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          m("gd", vim.lsp.buf.definition, "ir a definición")
          m("gD", vim.lsp.buf.declaration, "ir a declaración")
          m("gr", vim.lsp.buf.references, "referencias")
          m("gi", vim.lsp.buf.implementation, "implementación")
          m("K", vim.lsp.buf.hover, "documentación flotante")
          m("<leader>rn", vim.lsp.buf.rename, "renombrar símbolo")
          m("<leader>ca", vim.lsp.buf.code_action, "acción de código")
          m("<leader>d", vim.diagnostic.open_float, "diagnóstico de la línea")
          m("[d", function() vim.diagnostic.jump({ count = -1 }) end, "diagnóstico anterior")
          m("]d", function() vim.diagnostic.jump({ count = 1 }) end, "diagnóstico siguiente")
          m("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "formatear buffer")
        end,
      })
    end,
  },
}
