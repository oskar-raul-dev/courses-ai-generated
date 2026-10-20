#!/usr/bin/env bash
# El Dockerfile publicado de A13 §6 con SOLO el parche de apt (archive.debian.org), para ver lo que
# viene detrás: el postCreateCommand con sudo, y npm ci como 'node' con python3 y sin ca-certificates.
# Uso: ./t0-a13-parche.sh <linux/arm64|linux/amd64>
set -uo pipefail
cd "$(dirname "$0")"
PLAT=${1:-linux/arm64}; A=${PLAT#linux/}; TAG=a8-t0-a13-parche:$A; VOL=a8-t0-nm-parche-$A; CN=a8-t0-parche-$A
L="--label curso=angular-8-legacy --label tanda=AS"
docker build --platform "$PLAT" -q $L -t "$TAG" a13-parche-apt; echo "EXIT_BUILD=$?"
docker volume create $L "$VOL" >/dev/null
docker rm -f -v "$CN" >/dev/null 2>&1
# Lo mismo que hace VS Code: bind del proyecto en /workspaces/clinical-lab (containerWorkspaceFolder)
# y el volumen encima de node_modules; después, el postCreateCommand publicado.
docker run -d --name "$CN" $L --platform "$PLAT" -u node \
  -v "$PWD/devc/clinical-lab-parche:/workspaces/clinical-lab" -v "$VOL:/workspaces/clinical-lab/node_modules" \
  -w /workspaces/clinical-lab "$TAG" sleep infinity >/dev/null
echo "== dueño del volumen recién montado"
docker exec "$CN" ls -ld node_modules
echo "== postCreateCommand publicado"
docker exec "$CN" bash -c 'sudo chown -R node:node node_modules && npm ci'; echo "EXIT_POSTCREATE=$?"
echo "== npm ci como node, con el volumen ya de node (chown hecho como root, a mano)"
docker exec -u root "$CN" chown node:node node_modules
docker exec "$CN" bash -c 'time npm ci 2>&1 | tail -40'; echo "EXIT_NPM_CI=$?"
docker rm -f -v "$CN" >/dev/null; docker volume rm "$VOL" >/dev/null
