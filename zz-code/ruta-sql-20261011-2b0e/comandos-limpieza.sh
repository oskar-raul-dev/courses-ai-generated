#!/usr/bin/env bash
# Removes what this session created in Docker: containers, volumes and network labelled curso=ruta-sql,
# and the discarded images it pulled (none of them was in salidas/inventario-antes.txt).
set -uo pipefail
cd "$(dirname "$0")"
docker compose -f lab/compose.yaml --profile base --profile contraste --profile oracle --profile oracle-oficial \
  --profile mongo --profile api --profile puente --profile sqlserver down -v --remove-orphans
docker ps -aq --filter label=curso=ruta-sql | xargs -r docker rm -f
docker volume ls -q --filter label=curso=ruta-sql | xargs -r docker volume rm
for img in container-registry.oracle.com/database/free:latest mongo:9.0.2 mysql:8.4.11 postgres:18.6 alpine:3.22; do
  grep -q "^${img}	" salidas/inventario-antes.txt && { echo "keep $img (was there before)"; continue; }
  docker image rm "$img"
done
./comandos-inventario.sh despues
diff <(sed -n '/## contenedores/,/## volumenes/p' salidas/inventario-antes.txt | cut -f1 | sort) \
     <(sed -n '/## contenedores/,/## volumenes/p' salidas/inventario-despues.txt | cut -f1 | sort) && echo "contenedores: igual que al inicio"
diff <(sed -n '/## volumenes/,/## redes/p' salidas/inventario-antes.txt | sort) \
     <(sed -n '/## volumenes/,/## redes/p' salidas/inventario-despues.txt | sort) && echo "volúmenes: igual que al inicio"
diff <(sed -n '/## redes/,/## imagenes/p' salidas/inventario-antes.txt | sort) \
     <(sed -n '/## redes/,/## imagenes/p' salidas/inventario-despues.txt | sort) && echo "redes: igual que al inicio"
# Second pass (11/10/2026): anonymous volumes left by `compose rm -sf` (mongo 9.0.2 at 22:57:23, Artemis at 23:07:36).
# docker volume rm 8b7812da2468902a349a5f858ed9574fa1daea0d30381c747e3d192702c2e43b e7cadc41d380a259933d7a517b912a1576bea9c67d8a92b29700e07c0a4ac796
