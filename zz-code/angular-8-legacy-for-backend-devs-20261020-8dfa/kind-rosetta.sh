#!/usr/bin/env bash
# ¿Un pod de kind con una imagen solo-amd64 corre traducido (Rosetta en la VM) o muere con exec format error?
# Cluster a8-rosetta con la imagen de nodo de la Fase 14; kubeconfig propio (no toca ~/.kube/config).
# Uso: ./kind-rosetta.sh [imagen de nodo]
set -uo pipefail
cd "$(dirname "$0")"
NODO=${1:-kindest/node:v1.27.3}; CL=a8-rosetta; KC="$PWD/salidas/kubeconfig"; K="kubectl --kubeconfig $KC"
L="--label curso=angular-8-legacy --label tanda=kind-rosetta"
echo "== runtime"; docker info --format '{{.Name}} / {{.Architecture}} / {{.OperatingSystem}}'
echo "== imágenes de una sola arquitectura"
for A in amd64 arm64; do
  docker build -q --platform linux/$A --provenance=false $L -t a8-kind-$A:1 img >/dev/null
  docker image inspect a8-kind-$A:1 --format "a8-kind-$A:1 ARCH={{.Architecture}}"
  docker run --rm --platform linux/$A a8-kind-$A:1 sh -c 'echo "  docker run: $(uname -m)"'
done
echo "== cluster ($NODO)"
kind delete cluster --name $CL --kubeconfig "$KC" >/dev/null 2>&1
S=$(date +%s); kind create cluster --name $CL --image "$NODO" --kubeconfig "$KC" --wait 120s 2>&1 | tail -4; echo "EXIT_CREATE=${PIPESTATUS[0]} $(( $(date +%s)-S )) s"
$K get nodes -o wide | cut -c1-140
echo "== binfmt dentro del nodo (es el kernel de la VM)"
docker exec $CL-control-plane sh -c 'ls /proc/sys/fs/binfmt_misc/; for f in /proc/sys/fs/binfmt_misc/*; do case $f in */register|*/status) ;; *) echo "-- $f"; head -2 $f;; esac; done'
echo "== kind load"
for A in amd64 arm64; do kind load docker-image a8-kind-$A:1 --name $CL 2>&1 | tail -1; done
docker exec $CL-control-plane crictl images | grep a8-kind
for A in amd64 arm64; do
  $K run x-$A --image=a8-kind-$A:1 --image-pull-policy=Never --restart=Never >/dev/null
done
sleep 20
echo "== pods"; $K get pods -o wide | cut -c1-120
for A in amd64 arm64; do echo "-- logs x-$A"; $K logs x-$A 2>&1 | head -3; $K get pod x-$A -o jsonpath='{.status.containerStatuses[0].state}'; echo; done
echo "== proceso amd64 visto desde el nodo"
docker exec $CL-control-plane sh -c 'ps -eo args | grep -E "rosetta|qemu|sleep 3600" | grep -v grep'
