#!/usr/bin/env bash
# Node 14.21.3 amd64 en un pod del cluster a8-rosetta (lo crea kind-rosetta.sh). Uso: ./kind-node-x64.sh
set -uo pipefail
cd "$(dirname "$0")"
CL=a8-rosetta; K="kubectl --kubeconfig $PWD/salidas/kubeconfig"
docker build -q --platform linux/amd64 --provenance=false --label curso=angular-8-legacy --label tanda=kind-rosetta -t a8-kind-node-amd64:1 img-node >/dev/null
docker image inspect a8-kind-node-amd64:1 --format 'a8-kind-node-amd64:1 ARCH={{.Architecture}}'
kind load docker-image a8-kind-node-amd64:1 --name $CL 2>&1 | tail -1
$K run node-x64 --image=a8-kind-node-amd64:1 --image-pull-policy=Never --restart=Never >/dev/null
$K wait --for=condition=Ready pod/node-x64 --timeout=60s
$K logs node-x64
docker exec $CL-control-plane sh -c 'ps -eo args | grep "^/run/rosetta/rosetta /usr/local/bin/node"'
