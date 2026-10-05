-- Autocompletado con IA local (llama.cpp + Qwen2.5-Coder-1.5B) estilo Copilot:
-- ghost text inline mediante FIM (fill-in-middle). Convive con nvim-cmp:
-- el menú lo dan los servidores LSP; la sugerencia gris en línea la da la IA.

-- Same rule as ai.zsh: under WSL the server is reached through the VM IP,
-- elsewhere it only listens on loopback.
local llama_host = os.getenv("LLAMA_HOST")
if not llama_host then
  local ip = os.getenv("WSL_DISTRO_NAME") and vim.fn.system("hostname -I"):match("%S+") or "127.0.0.1"
  llama_host = "http://" .. ip .. ":8082"
end

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
        -- Con 64 max_tokens el modelo cortaba funciones a medias (finish_reason
        -- "length": código roto, ej. un string sin cerrar). Con más presupuesto
        -- la generación tarda más en CPU, así que el timeout sube en consecuencia.
        request_timeout = 20,
        throttle = 1000,
        debounce = 400,
        provider_options = {
          openai_fim_compatible = {
            -- llama-server no usa clave; minuet exige el NOMBRE de una env var no vacía: "TERM" siempre existe
            api_key = "TERM",
            name = "llama.cpp",
            end_point = llama_host .. "/v1/completions",
            model = "qwen2.5-coder-1.5b",
            -- llama-server FIM: si `suffix` está vacío, el modelo puede "chatear" en
            -- vez de hacer completión. Forzamos un suffix mínimo para FIM limpio.
            template = {
              -- El default de minuet antepone "# language: python" + "# indentation:
              -- use N spaces..." antes del código. Con este modelo eso "primea"
              -- al modelo a escribir un comentario por cada línea (a veces sin llegar
              -- nunca al código real, cortándose en max_tokens). El modelo ya infiere
              -- el lenguaje de la sintaxis, así que mandamos el contexto tal cual.
              prompt = function(context_before_cursor, _, _)
                return context_before_cursor
              end,
              suffix = function(_, context_after_cursor, _)
                if context_after_cursor == "" then
                  return "\n"
                end
                return context_after_cursor
              end,
            },
            optional = {
              max_tokens = 96,
              top_p = 0.9,
              temperature = 0.3,
              -- Sin suffix real (fin de archivo), el modelo no sabe dónde parar y
              -- sigue escribiendo la siguiente función/clase. Estas stop sequences
              -- cortan la sugerencia en el límite natural de la función actual.
              stop = { "\ndef ", "\nclass ", "\n\n" },
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
  -- del menú (Explicar, Fix_Code, Review_Code, Ask, Chat...). Habla directo con
  -- el llama-server (:8082, sin auth).
  -- El default de gen.nvim habla la API nativa de Ollama (/api/chat); llama.cpp
  -- solo expone /v1/..., así que se sobreescribe `command` con formato OpenAI.
  -- gen.nvim ya sabe parsear el streaming OpenAI (rama choices[].delta.content).
  {
    "David-Kunz/gen.nvim",
    cmd = "Gen",
    keys = {
      { "<leader>a", ":Gen<CR>", mode = { "n", "v" }, desc = "IA local: menú de acciones (llama.cpp)" },
    },
    opts = {
      model = "qwen2.5-coder-1.5b",
      display_mode = "horizontal-split",
      show_prompt = true,
      show_model = true,
      command = function()
        return "curl --silent --no-buffer -X POST "
          .. llama_host
          .. "/v1/chat/completions "
          .. "-H 'Content-Type: application/json' "
          .. "-d $body"
      end,
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
