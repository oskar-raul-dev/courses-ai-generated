#!/usr/bin/env bash
# Lista los tags más recientes de un repositorio de Docker Hub (para fijar versiones según D12).
# Uso: ./tags.sh library/postgres [filtro-regex]
set -euo pipefail
repo="$1"; filtro="${2:-.}"
curl -fsS "https://hub.docker.com/v2/repositories/$repo/tags?page_size=100&ordering=last_updated" \
  | python3 -c 'import json,sys,re; f=sys.argv[1]; [print(t["name"], t["last_updated"][:10]) for t in json.load(sys.stdin)["results"] if re.search(f,t["name"])]' "$filtro"
