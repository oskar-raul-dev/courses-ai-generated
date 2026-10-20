#!/usr/bin/env bash
# A13 §4 y ejercicio 3: un contenedor amd64 pedido con --platform, y una imagen solo-amd64 corrida SIN
# --platform en una VM arm64 con Rosetta (Docker Desktop). Uso: ./t1-plataforma.sh
set -uo pipefail
L="--label curso=angular-8-legacy --label tanda=AS"
echo "== docker info"; docker info --format '{{.Name}} / {{.Architecture}} / {{.OperatingSystem}}'
echo "== --platform linux/amd64"; docker run --rm $L --platform linux/amd64 node:14.21.3-bullseye-slim node -p 'process.arch + " " + require("os").arch()'
echo "== la imagen solo-amd64 del devcontainer, sin --platform"
docker image inspect a8-t0-devc:amd64 --format 'ARCH={{.Architecture}}'
docker run --rm $L a8-t0-devc:amd64 node -p process.arch; echo "EXIT=$?"
