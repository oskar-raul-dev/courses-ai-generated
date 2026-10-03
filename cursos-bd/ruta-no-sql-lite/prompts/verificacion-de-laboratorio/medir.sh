#!/usr/bin/env bash
# Sesión de verificación de laboratorio (T10): levanta cada familia sola, fija su digest,
# mide cuánto tarda en estar healthy y cuánta RAM ocupa en reposo, y guarda las
# advertencias y errores literales del arranque.
#
# Uso:  ./medir.sh [familia ...]       (sin argumentos, todas)
# Salida: resultados-<plataforma>.tsv y logs-<plataforma>/<familia>.log
set -uo pipefail
cd "$(dirname "$0")"

platform="${PLATFORM:-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)}"
families=("$@")
[ ${#families[@]} -eq 0 ] && families=(base documental clave-valor series busqueda grafos vectorial columnar offline newsql)
out="resultados-${platform}.tsv"
logs="logs-${platform}"
mkdir -p "$logs"
[ -f "$out" ] || printf "fecha\tplataforma\tfamilia\timagen\tdigest\tsegundos_a_healthy\tram_reposo\n" > "$out"

dc() { docker compose --profile "$1" "${@:2}"; }

for f in "${families[@]}"; do
  echo "== $f"
  dc "$f" down -v >/dev/null 2>&1
  dc "$f" pull -q "$f" 2>&1 | tee "$logs/$f.pull.log"
  cid_image=$(dc "$f" config --images "$f")
  digest=$(docker image inspect "$cid_image" --format '{{index .RepoDigests 0}}' 2>/dev/null)

  start=$(date +%s)
  dc "$f" up -d "$f" > "$logs/$f.up.log" 2>&1
  status="starting"
  for _ in $(seq 1 120); do
    status=$(docker inspect --format '{{.State.Health.Status}}' "rnl-t10-$f-1" 2>/dev/null || echo "missing")
    [ "$status" = "healthy" ] && break
    [ "$status" = "missing" ] && break
    sleep 2
  done
  ready=$(( $(date +%s) - start ))
  [ "$status" = "healthy" ] || ready="NO-HEALTHY($status,${ready}s)"

  # un minuto de reposo antes de medir, igual en todas las familias
  [ "$status" = "healthy" ] && sleep 60
  ram=$(docker stats --no-stream --format '{{.MemUsage}}' "rnl-t10-$f-1" 2>/dev/null | cut -d/ -f1 | tr -d ' ')

  docker logs "rnl-t10-$f-1" > "$logs/$f.log" 2>&1
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$(date -u +%FT%TZ)" "$platform" "$f" "$cid_image" "$digest" "$ready" "${ram:-?}" >> "$out"
  echo "   $cid_image  healthy en: $ready  RAM: ${ram:-?}"
  dc "$f" down -v >/dev/null 2>&1
done
