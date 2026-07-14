#!/usr/bin/env bash
# Genera un proyecto nuevo a partir de uno de los templates de templates/.
# Uso: ./new.sh <template> <destino> [opciones extra de copier]
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" -lt 2 ]; then
    echo "Uso: $0 <template> <destino> [opciones extra de copier]"
    echo
    echo "Templates disponibles:"
    ls "$script_dir/templates"
    exit 1
fi

template="$1"
destino="$2"
shift 2

template_dir="$script_dir/templates/$template"

if [ ! -d "$template_dir" ]; then
    echo "Error: el template '$template' no existe en $script_dir/templates/"
    echo "Templates disponibles:"
    ls "$script_dir/templates"
    exit 1
fi

uvx copier copy --trust "$template_dir" "$destino" "$@"
