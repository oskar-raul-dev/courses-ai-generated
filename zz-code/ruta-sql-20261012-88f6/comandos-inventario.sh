#!/usr/bin/env bash
# Inventario de Docker antes y después de las pruebas (regla 9 del plan).
# Uso: ./comandos-inventario.sh antes|despues
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p salidas
fase="${1:?antes|despues}"
{
  echo "## contenedores"; docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Label "curso"}}'
  echo "## volumenes";    docker volume ls --format '{{.Name}}\t{{.Label "curso"}}'
  echo "## redes";        docker network ls --format '{{.Name}}\t{{.Label "curso"}}'
  echo "## imagenes";     docker images --format '{{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}'
} > "salidas/inventario-$fase.txt"
echo "salidas/inventario-$fase.txt"
