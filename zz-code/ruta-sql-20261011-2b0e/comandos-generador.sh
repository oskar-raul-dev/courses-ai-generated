#!/usr/bin/env bash
# Corre el prototipo del generador dentro de un contenedor. Uso: ./comandos-generador.sh s|m [salida]
# La caja queda en salidas/caja/<perfil>/ (no se versiona).
set -euo pipefail
cd "$(dirname "$0")"
IMG=ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim
perfil="$1"; out="${2:-salidas/caja}"
docker run --rm --label curso=ruta-sql -v "$PWD":/w -w /w "$IMG" \
  python generador/generar.py --profile "$perfil" --out "$out"
