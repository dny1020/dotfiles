-- Estetica: Gruvbox dark hard, el mismo #1d2021 que i3bar, rofi y VS Code.
return {
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("gruvbox").setup({ contrast = "hard" })
      vim.o.background = "dark"
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  -- Signos de git en la columna lateral (+ ~ -) y acciones de hunk
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
}
