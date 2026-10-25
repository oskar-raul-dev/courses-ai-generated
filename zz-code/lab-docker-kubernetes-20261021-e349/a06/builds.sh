#!/bin/sh
# a06: los builds sin caché, cronometrados. Cada uno con --no-cache; las imágenes quedan con tag a06-*.
cd "$(dirname "$0")/.."; S=mi-lab/src/lab/services; P="--build-context proto=mi-lab/src/lab/contracts/proto"
t() { name=$1; shift; s=$(date +%s.%N 2>/dev/null || python3 -c 'import time;print(time.time())'); if docker build --no-cache --progress=plain $P "$@" > logs/a06-build-$name.log 2>&1; then r=ok; else r=FALLÓ; fi; e=$(python3 -c "import time;print(round(time.time()-$s,1))"); echo "$name: $e s · $r"; }
s0() { python3 -c 'import time;print(time.time())'; }
t() { name=$1; shift; s=$(s0); if docker build --no-cache --progress=plain $P "$@" > logs/a06-build-$name.log 2>&1; then r=ok; else r=FALLÓ; fi; echo "$name: $(python3 -c "import time;print(round(time.time()-$s,1))") s · $r"; }
t pricing-arm64 --platform linux/arm64 -t lab/pricing:a06-arm64 $S/pricing
t pricing-amd64-emulado --platform linux/amd64 -t lab/pricing:a06-amd64 $S/pricing
t pricing-amd64-cruzado --platform linux/amd64 -f a06/pricing.cross.Dockerfile -t lab/pricing:a06-cross-amd64 $S/pricing
t inventory-arm64 --platform linux/arm64 -t lab/inventory:a06-arm64 $S/inventory
t inventory-amd64-emulado --platform linux/amd64 -t lab/inventory:a06-amd64 $S/inventory
t inventory-amd64-cruzado --platform linux/amd64 -f a06/inventory.cross.Dockerfile -t lab/inventory:a06-cross-amd64 $S/inventory
s=$(s0); docker build --progress=plain $P --platform linux/amd64,linux/arm64 -f a06/pricing.cross.Dockerfile -t lab/pricing:a06-multi --load $S/pricing > logs/a06-build-multi.log 2>&1 && echo "pricing-multi (caché caliente): $(python3 -c "import time;print(round(time.time()-$s,1))") s"
docker image ls --tree 2>/dev/null | grep -A3 'lab/pricing:a06-multi'
