-- Treesitter: resaltado de sintaxis preciso (gran salto visual respecto a `syntax on`)
-- Rama `main`: la unica compatible con nvim 0.12+. La vieja `master` esta congelada
-- y con 0.12 rompe en las inyecciones (HTML->JS/CSS) con
-- "attempt to call method 'range' (a nil value)".
local langs = {
  "lua", "vim", "vimdoc", "bash", "python", "javascript", "typescript",
  "json", "yaml", "toml", "php", "html", "css", "markdown", "markdown_inline",
  "dockerfile", "hcl", "sql", "gitcommit", "diff",
}

-- Por encima de este tamano no se activa treesitter: en archivos enormes
-- el re-parse incremental se arrastra y el resaltado no compensa.
local max_filesize = 512 * 1024 -- 512 KB

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false, -- la rama main no soporta lazy-loading
  config = function()
    require("nvim-treesitter").install(langs)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
      callback = function(ev)
        local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(ev.buf))
        if stat and stat.size > max_filesize then
          return
        end
        -- pcall: si no hay parser para este filetype, se queda sin resaltado y ya
        if pcall(vim.treesitter.start, ev.buf) then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
