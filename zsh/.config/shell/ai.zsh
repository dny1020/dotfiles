# ~/.config/shell/ai.zsh
# Copiloto local con llama.cpp (Qwen2.5-Coder-1.5B). Son funciones (coste de arranque ~0).
# Modelo por defecto: qwen2.5-coder-1.5b (puerto 8082, ~19 tokens/s en CPU).
# Cambia con export AI_MODEL=otro-modelo o export LLAMA_HOST=otro-puerto.
# (Versionado en el repo dotfiles; sourceado desde ~/.zshrc.)

: ${AI_MODEL:=qwen2.5-coder-1.5b}
: ${LLAMA_HOST:=http://127.0.0.1:8082}

if [[ -x "$HOME/llama.cpp/build/bin/llama-server" ]] || curl -s "$LLAMA_HOST/v1/models" >/dev/null 2>&1; then

  # --- helper interno: manda un prompt al modelo y devuelve solo la respuesta -
  #     Usa la API OpenAI-compatible de llama.cpp (chat/completions para instruct models).
  #     jq extrae choices[0].message.content.
  #     2º arg opcional = temperatura (baja = más determinista, para comandos).
  #     3º arg opcional = max_tokens (default 64 para shell rápido en CPU).
  #     Nota: usa chat/completions porque qwen2.5-coder es un modelo instruct.
  _ai() {
    local temp=${2:-0.4}
    local tokens=${3:-64}
    curl -s "$LLAMA_HOST/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d "$(jq -n --arg m "$AI_MODEL" --arg p "$1" --argjson t "$temp" --argjson mx "$tokens" \
            '{model:$m, messages:[{role:"user",content:$p}], stream:false, temperature:$t, max_tokens:$mx}')" \
      | jq -r '.choices[0].message.content // empty'
  }

  # limpia la respuesta del modelo a UNA línea de comando (quita fences/backticks)
  _ai_oneline() { sed '/^[[:space:]]*```/d; s/`//g; /^[[:space:]]*$/d' | head -1; }

  # --- registro ligero para `why` (una asignación por comando) ----------------
  autoload -Uz add-zsh-hook
  __ai_prev() { __AI_PREV_CMD=$__AI_THIS_CMD; __AI_THIS_CMD=$1 }
  # captura $? y lo RE-PROPAGA con return, para no romper a quien lo lea después (Starship)
  __ai_status() { __AI_LAST_STATUS=$?; return $__AI_LAST_STATUS }
  add-zsh-hook preexec __ai_prev
  precmd_functions=(__ai_status $precmd_functions)  # debe correr ANTES que vcs_info/starship

  # --- ai: pregunta general en la terminal ------------------------------------
  ai() { [[ -n "$*" ]] && _ai "$*" || echo "uso: ai <pregunta>"; }

  # --- explain: explica qué hace un comando (no lo ejecuta) -------------------
  explain() {
    [[ -z "$*" ]] && { echo "uso: explain '<comando>'"; return 1; }
    _ai "En 1-2 oraciones, explica qué hace este comando: $*" 0.3 64
  }

  # genera UNA línea de comando a partir de una descripción en lenguaje natural
  _ai_cmdgen() {
    _ai "Comando Linux para: $*. Solo el comando, sin explicación." 0.1 32 | _ai_oneline
  }

  # --- cmd: genera un comando y lo DEJA en el prompt para que tú lo revises ----
  #     (nunca se auto-ejecuta: aparece editable, pulsa Enter si te convence)
  cmd() {
    [[ -z "$*" ]] && { echo "uso: cmd '<lo que quieres hacer>'"; return 1; }
    local out
    out=$(_ai_cmdgen "$*")
    [[ -n "$out" ]] && print -z "$out"
  }

  # --- Ctrl+X Ctrl+A: escribe en el prompt lo que quieres en lenguaje natural,
  #     pulsa el atajo y el texto se REEMPLAZA por el comando generado.
  #     Editable y nunca se auto-ejecuta: Enter solo si te convence.
  _ai_prompt_to_cmd() {
    [[ -z "$BUFFER" ]] && return
    zle -M "ai: generando comando…"
    local out
    out=$(_ai_cmdgen "$BUFFER")
    zle -M ""
    [[ -n "$out" ]] && { BUFFER=$out; CURSOR=${#BUFFER}; }
    zle redisplay
  }
  zle -N _ai_prompt_to_cmd
  bindkey '^X^A' _ai_prompt_to_cmd
  # Variante para DENTRO de tmux: su prefijo es Ctrl+A y se traga el segundo
  # golpe de ^X^A. Ctrl+X y luego la letra `a` (sin Ctrl) pasa limpio siempre.
  bindkey '^Xa' _ai_prompt_to_cmd

  # --- why: analiza por qué falló el último comando ---------------------------
  why() {
    local code=${__AI_LAST_STATUS:-$?}
    [[ -z "$__AI_PREV_CMD" ]] && { echo "No hay comando previo que analizar."; return 1; }
    _ai "Comando falló (exit $code): $__AI_PREV_CMD. Causa y solución en 1-2 líneas:" 0.3 64
  }

  # --- gitai: mensaje de commit (Conventional Commits) desde el diff ----------
  #     lo deja en el prompt como `git commit -m "..."` para revisar y confirmar
  gitai() {
    local diff msg
    # Prioriza lo 'staged'; recorta el diff (un modelo pequeño se satura con diffs enormes).
    diff=$(git diff --cached --stat 2>/dev/null; git diff --cached 2>/dev/null | head -c 6000)
    [[ -z "${diff//[[:space:]]/}" ]] && diff=$(git diff --stat 2>/dev/null; git diff 2>/dev/null | head -c 6000)
    [[ -z "${diff//[[:space:]]/}" ]] && { echo "No hay cambios para describir (git diff vacío). ¿Hiciste 'git add'?"; return 1; }
    msg=$(_ai "Commit message en español (Conventional Commits, 1 línea): $diff" 0.1 32 | _ai_oneline)
    [[ -n "$msg" ]] && print -z "git commit -m \"${msg//\"/\\\"}\""
  }

fi
