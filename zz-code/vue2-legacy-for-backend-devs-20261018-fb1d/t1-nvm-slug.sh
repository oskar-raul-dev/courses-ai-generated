#!/usr/bin/env bash
# T1: con el nvm 0.39.7 de F0, qué binario pide cada combinación de sistema/arquitectura/versión.
# nvm_get_os y nvm_get_arch se reemplazan para simular un Mac; el resto es el código de nvm.
docker run --rm --label curso=vue2-legacy --label tanda=T1 node:14.21.3 bash -c '
curl -s -o /tmp/nvm.sh https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/nvm.sh
export NVM_DIR=/tmp/nvmdir; mkdir -p $NVM_DIR; source /tmp/nvm.sh --no-use
echo "nvm $(nvm --version)"
for os_arch in "darwin arm64" "darwin x64"; do
  set -- $os_arch
  eval "nvm_get_os() { echo $1; }; nvm_get_arch() { echo $2; }"
  for v in v14.16.1 v14.21.3 v16.20.2; do echo "$1/$2 $v -> $(nvm_get_download_slug node binary $v)"; done
done
echo "process.arch en este contenedor: $(node -p process.arch)"'
docker run --rm --platform linux/amd64 --label curso=vue2-legacy --label tanda=T1 node:14.21.3 node -p '"process.arch amd64: " + process.arch'
