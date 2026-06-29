-- Treesitter: resaltado de sintaxis preciso (gran salto visual respecto a `syntax on`)
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- rama estable con API clásica (la default `main` aún se estabiliza)
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  main = "nvim-treesitter.configs",
  opts = {
    ensure_installed = {
      "lua", "vim", "vimdoc", "bash", "python", "javascript", "typescript",
      "json", "yaml", "toml", "php", "html", "css", "markdown", "markdown_inline",
      "dockerfile", "hcl", "sql", "gitcommit", "diff",
    },
    auto_install = true, -- instala el parser que falte al abrir un tipo de archivo nuevo
    highlight = { enable = true },
    indent = { enable = true },
  },
}
