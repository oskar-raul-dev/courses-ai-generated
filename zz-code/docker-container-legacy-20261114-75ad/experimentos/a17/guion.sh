#!/usr/bin/env bash
# Guion de a17 (propuesta §9.5) con dos ajustes medidos: `time` se instala aparte y ccache
# va desde la primera pasada (cold), para que la segunda (warm) mida lo que dice medir.
# Uso: NODE_VERSION=14.21.3 bash guion.sh   — los logs quedan en ~/lab/
set -u
L=~/lab; mkdir -p $L; exec > >(tee -a $L/guion.log) 2>&1
echo "== 0. estado inicial"; date -u; uname -a; command -v /usr/bin/time && echo "time: presente" || echo "time: AUSENTE en la imagen"
echo "== 1. toolchain"
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq build-essential curl ca-certificates git ccache pkg-config python3 time xz-utils >/dev/null && echo "apt ok"
echo "== 2. con qué compilas"
gcc --version | head -1; ldd --version | head -1
python2 --version 2>&1 || true; python3 --version
openssl version; nproc; free -h | head -2; df -h ~ | tail -1
echo "== 3. fuentes v$NODE_VERSION"
cd ~ && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz" | tar -xJ && echo "fuentes ok"
cd "node-v${NODE_VERSION}" || exit 1
du -sh . 
echo "== 4. configure"
./configure --prefix="$HOME/opt/node-${NODE_VERSION}" --with-intl=small-icu > $L/configure.log 2>&1; echo "configure exit=$?"; tail -30 $L/configure.log
export CCACHE_DIR=$HOME/.ccache; ccache -z >/dev/null; ccache -M 20G >/dev/null
echo "== 5. make-1 (ccache en frío)"
/usr/bin/time -v make -j"$(nproc)" CC="ccache gcc" CXX="ccache g++" > $L/make-1.log 2>&1; echo "make-1 exit=$?"
grep -E "Elapsed \(wall|Maximum resident" $L/make-1.log; ccache -s | grep -iE "hit|miss" | head -4
tail -25 $L/make-1.log | grep -iE "error|killed|memory" | head -10
echo "== 6. make-2 (ccache en caliente)"
make clean >/dev/null 2>&1; ccache -z >/dev/null
/usr/bin/time -v make -j"$(nproc)" CC="ccache gcc" CXX="ccache g++" > $L/make-2.log 2>&1; echo "make-2 exit=$?"
grep -E "Elapsed \(wall|Maximum resident" $L/make-2.log; ccache -s | grep -iE "hit|miss" | head -4
echo "== 7. instalar y verificar"
make install > $L/install.log 2>&1; echo "install exit=$?"
"$HOME/opt/node-${NODE_VERSION}/bin/node" --version
file "$HOME/opt/node-${NODE_VERSION}/bin/node"
du -sh "$HOME/opt/node-${NODE_VERSION}/bin/node"
date -u; echo "== fin"
