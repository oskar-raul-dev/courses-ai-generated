# sonda de CPU justa: el MISMO binario (node 14.21.3 oficial, glibc 2.17) en las dos VM
set -u; cd /tmp; [ -x node-v14.21.3-linux-arm64/bin/node ] || curl -fsSL https://nodejs.org/dist/v14.21.3/node-v14.21.3-linux-arm64.tar.xz | tar -xJ
N=/tmp/node-v14.21.3-linux-arm64/bin/node; sha256sum $N
J='let s=0;const t=Date.now();for(let i=0;i<2e9;i++){s+=i%7}console.log(Date.now()-t)'
echo "== 1 hilo (ms)"; for i in 1 2 3; do $N -e "$J"; done
echo "== 8 en paralelo (ms cada uno)"; for i in 1 2 3 4 5 6 7 8; do $N -e "$J" & done; wait
echo "== fin"
