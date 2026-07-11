-- Autocompletado con IA local (Ollama + qwen2.5-coder) estilo Copilot:
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
      -- En CPU el FIM tarda 5-9s (más en arranque en frío al cargar el modelo).
      -- Con timeout=4 minuet generaba la sugerencia pero la DESCARTABA -> nunca
      -- aparecía el ghost text. Damos margen suficiente para que llegue.
      request_timeout = 10, -- segundos antes de descartar (modelo local en CPU)
      throttle = 1000,
      debounce = 400,
      provider_options = {
        openai_fim_compatible = {
          -- Ollama no usa clave; minuet exige el NOMBRE de una env var no vacía: "TERM" siempre existe
          api_key = "TERM",
          name = "Ollama",
          end_point = "http://localhost:11434/v1/completions",
          model = "qwen2.5-coder:3b",
          -- Ollama solo activa el modo FIM (fill-in-middle) cuando el `suffix` NO
          -- está vacío. Al final de un archivo el texto tras el cursor es "" y el
          -- modelo instruct se pone a "chatear" (devuelve markdown/prosa). Forzamos
          -- un suffix mínimo (un salto de línea) para que SIEMPRE haga FIM limpio.
          -- Solo sobreescribimos `suffix`; `prompt` queda con el default de minuet.
          template = {
            suffix = function(_, context_after_cursor, _)
              if context_after_cursor == "" then
                return "\n"
              end
              return context_after_cursor
            end,
          },
          optional = {
            -- 64 basta para una sugerencia en línea y acelera ~4x la generación
            -- frente a 256 (clave para que entre dentro del timeout en CPU).
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
  -- modelo que minuet ya tiene residente en RAM -> no añade carga ni espera
  -- de carga en frío. Sale del split con `q`.
  {
    "David-Kunz/gen.nvim",
    cmd = "Gen",
    keys = {
      { "<leader>a", ":Gen<CR>", mode = { "n", "v" }, desc = "IA local: menú de acciones (Ollama)" },
    },
    opts = {
      model = "qwen2.5-coder:3b",
      display_mode = "split",
      show_prompt = true,
      show_model = true,
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
