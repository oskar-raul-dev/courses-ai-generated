#!/usr/bin/env bash
# Corre un script dentro del contenedor del curso, con lector/ montado como ~/dev/meridian.
# Uso: scripts/correr.sh scripts/s1-f00.sh corridas/s1-f00.log
set -euo pipefail
AQUI="$(cd "$(dirname "$0")/.." && pwd)"
IMAGEN="${IMAGEN:-golang:1.25.1-bookworm}"
SCRIPT="$1"; LOG="$2"
mkdir -p "$AQUI/lector" "$(dirname "$AQUI/$LOG")"
docker run --rm --label curso=go-for-java-devs ${NET:+--network $NET} -e PGHOST=gfjd-pg -e PGUSER=meridian -e PGPASSWORD=meridian -e PGDATABASE=meridian \
  -v gfjd-gopath:/go \
  -v gfjd-sdk:/root/sdk \
  -v "$AQUI/lector":/root/dev/meridian \
  -v "$AQUI/scripts":/scripts:ro -v "$AQUI/ch-go":/ch -v "$AQUI/../../cursos-algoritmos-lenguajes/go-for-java-devs/src/clearinghouse-spring":/spring \
  -e GOFLAGS= -e HOME=/root -w /root/dev/meridian \
  "$IMAGEN" bash "/scripts/$(basename "$SCRIPT")" 2>&1 | tee "$AQUI/$LOG"
