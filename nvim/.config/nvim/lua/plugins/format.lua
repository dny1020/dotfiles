-- Format on save (VS Code formatOnSave + codeActionsOnSave fixAll/organizeImports).
-- Filetypes not listed fall back to the attached LSP server's formatter.
-- Save without formatting: :noautocmd w
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  opts = {
    formatters_by_ft = {
      python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
      lua = { "stylua" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      markdown = { "prettier" },
    },
    -- Only reformat with these when the project opts in with its own config;
    -- their defaults (tabs, 80 cols) would rewrite unrelated code.
    formatters = {
      prettier = { require_cwd = true },
      stylua = { require_cwd = true },
    },
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = { timeout_ms = 2000 },
  },
}
