-- File tree pinned to the left, like the VS Code explorer. Opens at startup,
-- follows the current file and closes with the last editor window.
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false, -- must take over directory buffers before VimEnter
  keys = {
    { "<leader>e", "<cmd>NvimTreeFocus<CR>", desc = "Explorer: focus" },
    { "<leader>E", "<cmd>NvimTreeToggle<CR>", desc = "Explorer: toggle" },
  },
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  config = function()
    require("nvim-tree").setup({
      hijack_directories = { enable = false }, -- `nvim .` is handled below so the tree stays a sidebar
      view = { side = "left", width = 34, preserve_window_proportions = true },
      renderer = {
        group_empty = true,
        highlight_git = "name",
        root_folder_label = ":~:s?$?/?", -- top line of the tree: project path
      },
      update_focused_file = { enable = true },
      diagnostics = { enable = true, show_on_dirs = true },
      filters = {
        custom = { "^\\.git$", "__pycache__", "\\.pytest_cache", "\\.mypy_cache", "\\.ruff_cache" },
      },
      filesystem_watchers = {
        ignore_dirs = { "node_modules", ".venv", "venv", "build", "dist", "target", ".terraform" },
      },
      actions = { open_file = { resize_window = false } },
    })

    local api = require("nvim-tree.api")

    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("nvim_tree_startup", { clear = true }),
      callback = function(data)
        local ft = vim.bo[data.buf].filetype
        if vim.o.diff or ft == "gitcommit" or ft == "gitrebase" or vim.bo[data.buf].buftype ~= "" then
          return
        end
        -- nvim as $EDITOR: Claude Code / Codex prompt drafts (Ctrl+G) live in the
        -- temp dir, `git add -e` and friends under .git/
        local tmp = vim.env.TMPDIR or "/tmp"
        if
          vim.startswith(data.file, tmp)
          or vim.startswith(data.file, "/tmp/")
          or data.file:find("/.git/", 1, true)
        then
          return
        end
        local is_dir = vim.fn.isdirectory(data.file) == 1
        if is_dir then
          vim.cmd.enew()
          vim.cmd.bwipeout(data.buf)
          vim.cmd.cd(data.file)
        end
        api.tree.open()
        if not is_dir and data.file ~= "" then
          vim.cmd.wincmd("p") -- started on a file: keep the cursor there
        end
      end,
    })

    -- Quitting the last editor window would otherwise leave the tree alone on screen.
    vim.api.nvim_create_autocmd("QuitPre", {
      group = vim.api.nvim_create_augroup("nvim_tree_autoclose", { clear = true }),
      callback = function()
        local editors = 0
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.api.nvim_win_get_config(win).relative == "" and vim.bo[buf].filetype ~= "NvimTree" then
            editors = editors + 1
          end
        end
        if editors == 1 then
          api.tree.close()
        end
      end,
    })
  end,
}
