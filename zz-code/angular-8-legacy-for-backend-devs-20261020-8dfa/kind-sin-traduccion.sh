#!/usr/bin/env bash
# El caso "nadie traduce", simulado con un ejecutable que el kernel no reconoce (ENOEXEC, el mismo error que una
# imagen arm64 en un nodo amd64 sin emulación): docker run y un pod de kind. Usa la kindest/node ya presente (por digest).
# Uso: ./kind-sin-traduccion.sh
set -uo pipefail
cd "$(dirname "$0")"
NODO=kindest/node@sha256:a1ed56cfb0e7b93589bdf97c8cd566405a265939e3620fc4f5de89adff580ae5
CL=a8-sintrad; KC="$PWD/salidas/kubeconfig-sintrad"; K="kubectl --kubeconfig $KC"
docker build -q --provenance=false --label curso=angular-8-legacy --label tanda=kind-rosetta -t a8-kind-enoexec:1 img-loong >/dev/null; echo "EXIT_BUILD=$?"
docker image inspect a8-kind-enoexec:1 --format 'ARCH={{.Architecture}}'
echo "== docker run"; docker run --rm a8-kind-enoexec:1; echo "EXIT_RUN=$?"
kind get clusters | grep -qx $CL || kind create cluster --name $CL --image "$NODO" --kubeconfig "$KC" --wait 120s 2>&1 | tail -1
kind load docker-image a8-kind-enoexec:1 --name $CL 2>&1 | tail -1
$K run x-enoexec --image=a8-kind-enoexec:1 --image-pull-policy=Never --restart=Always >/dev/null
sleep 40
echo "== get pod"; $K get pod x-enoexec
echo "== logs"; $K logs x-enoexec; echo "== logs --previous"; $K logs x-enoexec --previous
echo "== describe (estado y eventos)"; $K describe pod x-enoexec | grep -E -A4 'State:|Last State' | head -14; $K describe pod x-enoexec | sed -n '/Events:/,$p' | cut -c1-200
