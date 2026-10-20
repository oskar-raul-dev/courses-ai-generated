#!/usr/bin/env bash
# Baja lo que levantó levantar.sh. Uso: ./bajar.sh            (contenedores y red; conserva node_modules)
#                                       ./bajar.sh --todo     (además, los volúmenes de node_modules)
set -uo pipefail
docker ps -aq --filter label=tanda=navegador --filter label=curso=vue2-legacy | while read -r c; do docker rm -f -v "$c" >/dev/null; done
docker network rm vue2-nav-net >/dev/null 2>&1
if [ "${1:-}" = --todo ]; then
  docker volume ls -q --filter label=tanda=navegador --filter label=curso=vue2-legacy | while read -r v; do docker volume rm "$v" >/dev/null; done
fi
echo "Quedan: $(docker ps -aq --filter label=tanda=navegador | wc -l | tr -d ' ') contenedores, $(docker volume ls -q --filter label=tanda=navegador | wc -l | tr -d ' ') volúmenes"
