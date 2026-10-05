-- Fuzzy finder over fzf + ripgrep: stays fast on large repos.
-- Inside any picker, <A-q> sends the results to the quickfix list.
local function pick(name, opts)
  return function()
    require("fzf-lua")[name](opts)
  end
end

return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  keys = {
    { "<leader><space>", pick("files"), desc = "Find files" },
    { "<leader>/", pick("live_grep"), desc = "Grep in project" },
    { "<leader>sf", pick("files"), desc = "Search: files" },
    { "<leader>sg", pick("live_grep"), desc = "Search: grep" },
    { "<leader>sw", pick("grep_cword"), desc = "Search: word under cursor" },
    { "<leader>sw", pick("grep_visual"), mode = "v", desc = "Search: selection" },
    { "<leader>sb", pick("buffers"), desc = "Search: buffers" },
    { "<leader>sr", pick("oldfiles", { cwd_only = true }), desc = "Search: recent files" },
    { "<leader>ss", pick("lsp_document_symbols"), desc = "Search: symbols in file" },
    { "<leader>sS", pick("lsp_live_workspace_symbols"), desc = "Search: symbols in project" },
    { "<leader>sd", pick("diagnostics_document"), desc = "Search: diagnostics in file" },
    { "<leader>sD", pick("diagnostics_workspace"), desc = "Search: diagnostics in project" },
    { "<leader>sp", pick("zoxide"), desc = "Search: projects (zoxide)" },
    { "<leader>sh", pick("helptags"), desc = "Search: help" },
    { "<leader>sk", pick("keymaps"), desc = "Search: keymaps" },
    { "<leader>s.", pick("resume"), desc = "Search: resume last" },
    { "<leader>gs", pick("git_status"), desc = "Git: status" },
    { "<leader>gc", pick("git_bcommits"), desc = "Git: file history" },
    { "<leader>gC", pick("git_commits"), desc = "Git: repo history" },
    { "<leader>gB", pick("git_branches"), desc = "Git: branches" },
  },
  opts = {
    defaults = { file_icons = false, git_icons = false },
    files = { cwd_prompt = false },
  },
}
