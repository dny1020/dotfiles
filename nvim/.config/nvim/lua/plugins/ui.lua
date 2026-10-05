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
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function m(mode, keys, fn, desc)
          vim.keymap.set(mode, keys, fn, { buffer = buf, desc = "Git: " .. desc })
        end
        m("n", "]h", function()
          gs.nav_hunk("next")
        end, "next hunk")
        m("n", "[h", function()
          gs.nav_hunk("prev")
        end, "previous hunk")
        m("n", "<leader>gp", gs.preview_hunk, "preview hunk")
        m("n", "<leader>gS", gs.stage_hunk, "stage hunk")
        m("n", "<leader>gR", gs.reset_hunk, "reset hunk")
        m("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "blame line")
        m("n", "<leader>gt", gs.toggle_current_line_blame, "toggle inline blame")
        m("n", "<leader>gd", gs.diffthis, "diff against index")
      end,
    },
  },

  -- Popup listing the next keys after <leader>, g, ], etc.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { mappings = false },
      spec = {
        { "<leader>s", group = "search" },
        { "<leader>g", group = "git" },
      },
    },
  },
}
