-- Estética: tema Monokai + acentos oscuros tipo VS Code minimalista
return {
  -- Tema Monokai
  {
    "tanvirtin/monokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("monokai")
      -- Ajuste fino para acercarlo al esquema custom de VS Code (charcoal, no negro puro)
      vim.api.nvim_set_hl(0, "Normal", { bg = "#262626" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "#262626" })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "#262626" })
      vim.api.nvim_set_hl(0, "LineNr", { fg = "#5a5a5a", bg = "#262626" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#f5f5f5", bg = "#2f2f2f", bold = true })
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2f2f2f" })
      vim.api.nvim_set_hl(0, "Visual", { bg = "#404040" })
      vim.api.nvim_set_hl(0, "Pmenu", { bg = "#313131", fg = "#d0d0d0" })
      vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#3b3b3b", fg = "#f5f5f5" })
      vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#3b3b3b", bg = "#2e2e2e" })
    end,
  },

  -- Signos de git en la columna lateral (+ ~ -) y acciones de hunk
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
}
