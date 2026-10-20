#!/usr/bin/env bash
# T0.5: npm run serve en el devcontainer; responde desde el host y recompila al tocar un archivo desde el host.
# Uso: t0-devc-serve.sh <con|sin>   (con/sin CHOKIDAR_USEPOLLING)
modo=$1; name=vue2-t0-serve-$modo
envs=(); [ "$modo" = con ] && envs=(-e CHOKIDAR_USEPOLLING=true)
docker run -d --name $name --label curso=vue2-legacy --label tanda=T0 "${envs[@]}" -p 127.0.0.1::8080 \
  -v "$PWD/devc/tiquetera-legacy:/workspace" -v tiquetera-node-modules:/workspace/node_modules \
  vue2-t0-devc:arm64 npm run serve >/dev/null
for i in $(seq 1 90); do docker logs $name 2>&1 | grep -q "App running at" && break; sleep 2; done
port=$(docker port $name 8080 | head -1); echo "puerto: $port"
docker logs $name 2>&1 | grep -A3 "App running at"
echo "curl: $(curl -s -o /dev/null -w '%{http_code}' http://$port/)"
antes=$(docker logs $name 2>&1 | grep -c "Compiled\|Compiling\|DONE")
echo "// toque $(date +%s)" >> devc/tiquetera-legacy/src/main.js
sleep 12
despues=$(docker logs $name 2>&1 | grep -c "Compiled\|Compiling\|DONE")
echo "recompilaciones: antes=$antes despues=$despues"
docker logs $name 2>&1 | tail -4
sed -i '' '$d' devc/tiquetera-legacy/src/main.js
docker rm -f -v $name >/dev/null
