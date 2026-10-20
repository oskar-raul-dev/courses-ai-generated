#!/usr/bin/env bash
# Reproduce las fallas del devcontainer de A13 §6 tal como está publicado (antes de T2).
# Uso: ./t0-a13-actual.sh <linux/arm64|linux/amd64>
set -uo pipefail
cd "$(dirname "$0")"
PLAT=${1:-linux/arm64}; TAG=a8-t0-a13-actual:${PLAT#linux/}
echo "== build del Dockerfile publicado ($PLAT)"
docker build --platform "$PLAT" --no-cache --progress=plain --label curso=angular-8-legacy --label tanda=AS \
  -t "$TAG" a13-actual/.devcontainer 2>&1 | tail -60
echo "EXIT_BUILD=${PIPESTATUS[0]}"
