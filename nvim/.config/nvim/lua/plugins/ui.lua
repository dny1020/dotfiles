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

  -- Bottom bar: mode, branch, diff, path relative to the project, diagnostics, LSP, position
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "gruvbox",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " " } } },
        lualine_x = {
          "diagnostics",
          {
            function()
              local names = {}
              for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                table.insert(names, c.name)
              end
              return table.concat(names, " ")
            end,
          },
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "nvim-tree", "fzf", "quickfix", "lazy", "mason" },
    },
  },

  -- Top bar inside each file: path > class > function (VS Code breadcrumbs), clickable
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      {
        "<leader>;",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Breadcrumbs: pick",
      },
    },
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
