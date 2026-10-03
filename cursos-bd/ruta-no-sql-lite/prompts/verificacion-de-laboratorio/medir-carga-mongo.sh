#!/usr/bin/env bash
# Prueba de carga de hallazgos.md §H1: levanta documental, lanza mongo_carga.mjs desde un
# contenedor de Node en la red del laboratorio y vigila si mongod muere (código 139 = SIGSEGV)
# o se reinicia. Uso: NODE_MODULES_DIR=<dir con mongodb instalado> ./medir-carga-mongo.sh [minutos] [trabajadores]
set -uo pipefail
cd "$(dirname "$0")"
minutes="${1:-10}"; workers="${2:-32}"
platform="${PLATFORM:-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)}"
log="logs-${platform}/carga-mongo.log"
mkdir -p "logs-${platform}"

echo "kernel de la VM/host: $(docker info --format '{{.KernelVersion}}')" | tee "$log"
docker compose --profile documental up -d --wait documental >>"$log" 2>&1
echo "imagen: $(docker inspect rnl-t10-documental-1 --format '{{.Config.Image}}')" | tee -a "$log"

docker run --rm --network rnl-t10_default -v "$NODE_MODULES_DIR":/app -v "$PWD/comprobaciones":/app/c -w /app \
  node:24-slim node c/mongo_carga.mjs "mongodb://documental:27017/?directConnection=true" "$minutes" "$workers" \
  >>"$log" 2>&1
client_exit=$?

state=$(docker inspect rnl-t10-documental-1 --format 'status={{.State.Status}} exit={{.State.ExitCode}} oom={{.State.OOMKilled}} restarts={{.RestartCount}}')
echo "cliente terminó con $client_exit · mongod: $state" | tee -a "$log"
docker logs rnl-t10-documental-1 2>&1 | grep -E '"s":"(F|E)"|SIGSEGV|Invalid access|tcmalloc' | cut -c1-400 >>"$log"
docker compose --profile documental down -v >/dev/null 2>&1
