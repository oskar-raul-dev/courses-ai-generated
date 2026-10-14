#!/usr/bin/env bash
# Descarga las imágenes candidatas y registra su digest y arquitectura. Salida: salidas/pull.tsv
cd "$(dirname "$0")"; mkdir -p salidas
: > salidas/pull.tsv
while read -r img; do
  [ -z "$img" ] && continue
  inicio=$(date +%s)
  if docker pull -q "$img" >> salidas/pull.log 2>&1; then
    dig=$(docker image inspect --format '{{index .RepoDigests 0}}' "$img")
    arch=$(docker image inspect --format '{{.Architecture}}' "$img")
    size=$(docker image inspect --format '{{.Size}}' "$img")
    printf '%s\t%s\t%s\t%s\t%ss\n' "$img" "$arch" "$size" "$dig" "$(( $(date +%s)-inicio ))" >> salidas/pull.tsv
  else
    printf '%s\tFALLO\n' "$img" >> salidas/pull.tsv
  fi
done < imagenes.txt
