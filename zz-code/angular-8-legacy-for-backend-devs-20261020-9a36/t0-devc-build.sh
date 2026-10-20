#!/usr/bin/env bash
# Construye la imagen del devcontainer candidato (devc/clinical-lab/.devcontainer) para una plataforma.
# Uso: ./t0-devc-build.sh <linux/arm64|linux/amd64> [carpeta .devcontainer] [tag]
set -uo pipefail
cd "$(dirname "$0")"
PLAT=${1:-linux/arm64}; CTX=${2:-devc/clinical-lab/.devcontainer}; TAG=${3:-a8-t0-devc:${PLAT#linux/}}
S=$(date +%s)
docker build --platform "$PLAT" --progress=plain --label curso=angular-8-legacy --label tanda=AS -t "$TAG" "$CTX" 2>&1 | tail -15
echo "EXIT_BUILD=${PIPESTATUS[0]} SEGUNDOS=$(( $(date +%s) - S ))"
docker image inspect "$TAG" --format 'ARCH={{.Architecture}} SIZE={{.Size}}'
docker run --rm --platform "$PLAT" "$TAG" bash -c 'python2 --version; python3 --version; chromium --version; git config --global --get-all url.https://github.com/.insteadof; ls -ld /workspace/node_modules; id'
