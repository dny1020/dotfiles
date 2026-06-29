# ~/.config/shell/ai.zsh
# Copiloto local con Ollama. Son funciones (coste de arranque ~0, sin daemon extra).
# Modelo por defecto: qwen2.5-coder:3b. Más rápido: export AI_MODEL=qwen2.5-coder:1.5b
# (Versionado en el repo dotfiles; sourceado desde ~/.zshrc.)

: ${AI_MODEL:=qwen2.5-coder:3b}

if command -v ollama >/dev/null; then

  # --- helper interno: manda un prompt al modelo y devuelve solo la respuesta -
  #     Usa la API HTTP (stream:false) para una salida limpia, sin spinner ni
  #     códigos de terminal. jq arma el JSON respetando saltos de línea/comillas.
  #     2º arg opcional = temperatura (baja = más determinista, para comandos).
  _ai() {
    local temp=${2:-0.4}
    curl -s "${OLLAMA_HOST:-http://localhost:11434}/api/generate" \
      -d "$(jq -n --arg m "$AI_MODEL" --arg p "$1" --argjson t "$temp" \
            '{model:$m, prompt:$p, stream:false, options:{temperature:$t}}')" \
      | jq -r '.response // empty'
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
    _ai "Explica en español, claro y breve, qué hace este comando de shell. Solo explícalo, no lo ejecutes:
$*"
  }

  # --- cmd: genera un comando y lo DEJA en el prompt para que tú lo revises ----
  #     (nunca se auto-ejecuta: aparece editable, pulsa Enter si te convence)
  cmd() {
    [[ -z "$*" ]] && { echo "uso: cmd '<lo que quieres hacer>'"; return 1; }
    local out
    out=$(_ai "Devuelve ÚNICAMENTE un comando de shell para Linux que logre esto, sin explicación ni markdown ni comillas de adorno:
$*" 0.1 | _ai_oneline)
    [[ -n "$out" ]] && print -z "$out"
  }

  # --- why: analiza por qué falló el último comando ---------------------------
  why() {
    local code=${__AI_LAST_STATUS:-$?}
    [[ -z "$__AI_PREV_CMD" ]] && { echo "No hay comando previo que analizar."; return 1; }
    _ai "Este comando de shell falló con código de salida $code:
  $__AI_PREV_CMD
En español y en 2-3 líneas: causa más probable y cómo solucionarlo."
  }

  # --- gitai: mensaje de commit (Conventional Commits) desde el diff ----------
  #     lo deja en el prompt como `git commit -m "..."` para revisar y confirmar
  gitai() {
    local diff msg
    # Prioriza lo 'staged'; recorta el diff (un modelo pequeño se satura con diffs enormes).
    diff=$(git diff --cached --stat 2>/dev/null; git diff --cached 2>/dev/null | head -c 6000)
    [[ -z "${diff//[[:space:]]/}" ]] && diff=$(git diff --stat 2>/dev/null; git diff 2>/dev/null | head -c 6000)
    [[ -z "${diff//[[:space:]]/}" ]] && { echo "No hay cambios para describir (git diff vacío). ¿Hiciste 'git add'?"; return 1; }
    msg=$(_ai "Eres un generador de mensajes de commit. Devuelve EXCLUSIVAMENTE una línea en español en formato Conventional Commits (ej: 'feat(nvim): añade LSP con mason'). Sin explicación, sin comillas, sin markdown. Cambios:
$diff" 0.1 | _ai_oneline)
    [[ -n "$msg" ]] && print -z "git commit -m \"${msg//\"/\\\"}\""
  }

fi
