#!/usr/bin/env bash
# ¿Qué combinaciones de perfiles caben a la vez en la VM? Levanta cada combinación con --wait,
# espera un minuto y anota: cuántos servicios quedaron healthy, si alguno murió por OOM, la RAM
# sumada del laboratorio y la de cualquier otro contenedor que esté corriendo en la máquina.
# Uso: ./combinaciones.sh
set -uo pipefail
LAB="$(cd "$(dirname "$0")/../../src/lab" && pwd)"
cd "$(dirname "$0")"
platform="${PLATFORM:-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)}"
out="combinaciones-${platform}.txt"
vm=$(docker info --format '{{.MemTotal}}')
echo "fecha: $(date -u +%FT%TZ) · memoria de la VM/host: $((vm/1048576)) MiB" | tee "$out"

to_mib() { python3 -c "
import re,sys
t=0
for v in sys.stdin.read().split():
    m=re.match(r'([\d.]+)([KMG]i?B|B)',v)
    if m: t+=float(m[1])*{'B':1/1048576,'KiB':1/1024,'KB':1/1024,'MiB':1,'MB':1,'GiB':1024,'GB':1024}[m[2]]
print(round(t))"; }

combo() { # nombre perfiles...
  name=$1; shift
  args=(); for p in "$@"; do args+=(--profile "$p"); done
  docker compose --project-directory "$LAB" -f "$LAB/compose.yaml" --profile "*" down -v >/dev/null 2>&1
  start=$(date +%s)
  timeout 600 docker compose --project-directory "$LAB" -f "$LAB/compose.yaml" "${args[@]}" up -d --wait >/dev/null 2>&1
  rc=$?
  sleep 60
  total=$(docker ps --filter label=com.docker.compose.project=condor-lab -q | wc -l | tr -d ' ')
  healthy=$(docker ps --filter label=com.docker.compose.project=condor-lab --filter health=healthy -q | wc -l | tr -d ' ')
  oom=$(docker ps -a --filter label=com.docker.compose.project=condor-lab -q | xargs docker inspect --format '{{.Name}} {{.State.OOMKilled}} {{.State.Status}}' | awk '$2=="true" || $3!="running"' | tr '\n' ';')
  lab=$(docker stats --no-stream --format '{{.Name}} {{.MemUsage}}' | grep condor-lab | awk '{print $2}' | to_mib)
  others=$(docker stats --no-stream --format '{{.Name}} {{.MemUsage}}' | grep -v condor-lab | awk '{print $2}' | to_mib)
  echo "$name [$*] · up rc=$rc en $(( $(date +%s) - start - 60 )) s · healthy $healthy/$total · laboratorio ${lab} MiB · otros contenedores ${others} MiB · caídos/OOM: ${oom:-ninguno}" | tee -a "$out"
}

combo "A · base + una JVM" base busqueda
combo "B · base + las tres JVM" base busqueda grafos columnar
combo "C · todo menos newsql-global" base documental clave-valor series busqueda grafos vectorial columnar offline newsql
combo "D · todo" base documental clave-valor series busqueda grafos vectorial columnar offline newsql newsql-global
docker compose --project-directory "$LAB" -f "$LAB/compose.yaml" --profile "*" down -v >/dev/null 2>&1
