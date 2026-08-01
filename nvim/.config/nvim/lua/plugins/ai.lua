-- Autocompletado con IA local (llama.cpp + Qwen2.5-Coder-1.5B) estilo Copilot:
-- ghost text inline mediante FIM (fill-in-middle). Convive con nvim-cmp:
-- el menú lo dan los servidores LSP; la sugerencia gris en línea la da la IA.
return {
  {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  -- IMPORTANTE: cargar en BufReadPre/BufNewFile (no en InsertEnter). minuet activa
  -- el ghost text con un autocmd FileType; si se carga en InsertEnter ese autocmd
  -- se registra demasiado tarde y el auto-trigger nunca se habilita en el buffer.
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("minuet").setup({
      provider = "openai_fim_compatible",
      n_completions = 1, -- una sola sugerencia: el modelo local va más fluido
      context_window = 1024, -- contexto enviado (tokens); bajo = más rápido en CPU
      -- Con el endpoint de qwen2.5-coder-1.5b el FIM responde notablemente más
      -- rápido en CPU; timeout más corto evita sugerencias "viejas".
      request_timeout = 6,
      throttle = 1000,
      debounce = 400,
      provider_options = {
        openai_fim_compatible = {
          -- llama-server no usa clave; minuet exige el NOMBRE de una env var no vacía: "TERM" siempre existe
          api_key = "TERM",
          name = "llama.cpp",
          end_point = "http://127.0.0.1:8082/v1/completions",
          model = "qwen2.5-coder-1.5b",
          -- llama-server FIM: si `suffix` está vacío, el modelo puede "chatear" en
          -- vez de hacer completión. Forzamos un suffix mínimo para FIM limpio.
          template = {
            suffix = function(_, context_after_cursor, _)
              if context_after_cursor == "" then
                return "\n"
              end
              return context_after_cursor
            end,
          },
          optional = {
            max_tokens = 64,
            top_p = 0.9,
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = { "*" }, -- ghost text automático en todos los lenguajes
        keymap = {
          accept = "<A-y>", -- aceptar toda la sugerencia
          accept_line = "<A-l>", -- aceptar solo la primera línea
          prev = "<A-[>", -- sugerencia anterior
          next = "<A-]>", -- sugerencia siguiente
          dismiss = "<A-e>", -- descartar
        },
      },
    })
  end,
  },

  -- Acciones IA sobre selección/buffer: selecciona código, <espacio>a y eliges
  -- del menú (Explicar, Fix_Code, Review_Code, Ask, Chat...). Usa el MISMO
  -- backend local llama.cpp. Sale del split con `q`.
  {
    "David-Kunz/gen.nvim",
    cmd = "Gen",
    keys = {
      { "<leader>a", ":Gen<CR>", mode = { "n", "v" }, desc = "IA local: menú de acciones (llama.cpp)" },
    },
    opts = {
      model = "qwen3-4b",
      display_mode = "split",
      show_prompt = true,
      show_model = true,
      host = "127.0.0.1",
      port = 8080,
    },
    config = function(_, opts)
      local gen = require("gen")
      gen.setup(opts)
      -- prompt propio: los de fábrica responden en inglés
      gen.prompts["Explicar"] = {
        prompt = "Explica en español, claro y breve, qué hace este código:\n```$filetype\n$text\n```",
      }
    end,
  },
}
