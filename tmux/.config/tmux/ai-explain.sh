#!/usr/bin/env zsh
# Explica/diagnostica el contenido visible de un panel de tmux con la IA local.
# Lo invoca el bind `prefix + e` de tmux.conf dentro de un display-popup.
# Reutiliza _ai() de ai.zsh (mismo modelo AI_MODEL y mismo endpoint /api/generate),
# así no se duplica la lógica: ai.zsh es la única fuente de verdad.
emulate -L zsh
setopt extendedglob   # necesario para los patrones de recorte de espacios de abajo

source "${HOME}/.config/shell/ai.zsh" 2>/dev/null

pane_file="${1:?uso: ai-explain.sh <archivo-con-el-volcado-del-panel>}"

if ! typeset -f _ai >/dev/null; then
  print -- "IA no disponible: no se pudo cargar _ai() de ai.zsh (¿está Ollama instalado?)."
  print -- "[Enter para cerrar]"; read -r
  exit 1
fi

# Quita líneas en blanco sobrantes (arriba/abajo) para no inflar el prompt.
content="$(<"$pane_file")"
content="${content##[[:space:]]#}"
content="${content%%[[:space:]]#}"

if [[ -z "$content" ]]; then
  print -- "El panel está vacío, nada que analizar."
  print -- "[Enter para cerrar]"; read -r
  exit 0
fi

print -- "Analizando la pantalla con ${AI_MODEL}…\n"

_ai "Eres un asistente de terminal. Abajo está el contenido visible de un panel de tmux (comandos del usuario y su salida). En español, claro y breve: resume qué está ocurriendo y, si hay un error, indica la causa más probable y cómo solucionarlo. Básate SOLO en lo que se ve, no inventes:

$content"

print -- "\n\n[Enter para cerrar]"; read -r
