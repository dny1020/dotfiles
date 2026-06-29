-- Estética: tema Dracula (con soporte treesitter), statusline y signos de git
return {
  -- Tema Dracula — el mismo morado/cyan de antes, ahora consciente de treesitter/LSP
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000, -- carga antes que el resto para que el colorscheme aplique limpio
    config = function()
      require("dracula").setup({
        italic_comment = true,
        transparent_bg = false,
      })
      vim.cmd.colorscheme("dracula")
    end,
  },

  -- Statusline: modo, archivo, rama git, diagnósticos LSP y posición (reemplaza al `ruler`)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "dracula-nvim",
        icons_enabled = true,
        globalstatus = true,
        section_separators = "",
        component_separators = "|",
      },
    },
  },

  -- Signos de git en la columna lateral (+ ~ -) y acciones de hunk
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
}
