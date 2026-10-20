#!/usr/bin/env bash
# T3 (a7 §7): los comandos publicados sobre la imagen de la API del Curso 02 (A01), más las etiquetas de la tanda.
L="--label curso=vue2-legacy --label tanda=T3"
cd backend/tiquetera-backend
echo "## build nativo"; ( time docker build $L -t tiquetera-api . >/dev/null ) 2>&1 | grep real
docker image inspect tiquetera-api --format '{{.Architecture}}'
echo "## build amd64"; ( time docker build $L --platform linux/amd64 -t tiquetera-api . >/dev/null ) 2>&1 | grep real
docker image inspect tiquetera-api --format '{{.Architecture}}'
echo "## run amd64"; docker run --rm $L --platform linux/amd64 tiquetera-api node -p process.arch
echo "## run sin --platform (la imagen ya es amd64)"; docker run --rm $L tiquetera-api node -p process.arch 2>&1 | tail -2
echo "## docker info"; docker info --format '{{.Name}} / {{.Architecture}} / {{.OperatingSystem}}'
docker context ls
