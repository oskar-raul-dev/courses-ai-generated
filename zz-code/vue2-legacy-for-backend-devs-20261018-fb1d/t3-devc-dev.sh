#!/usr/bin/env bash
# T3 (a7 §6): npm run dev (json-server :3000, sockets :4000, Vue CLI :8080) dentro del devcontainer;
# ¿responden los tres desde el Mac? Puertos aleatorios en 127.0.0.1 (regla del curso) en vez de los fijos.
# Uso: t3-devc-dev.sh [comando]   (por defecto: npm run dev)
cmd=${1:-npm run dev}
name=vue2-t3-dev
docker run -d --name $name --label curso=vue2-legacy --label tanda=T3 -e CHOKIDAR_USEPOLLING=true \
  -p 127.0.0.1::8080 -p 127.0.0.1::3000 -p 127.0.0.1::4000 \
  -v "$PWD/devc/tiquetera-legacy:/workspace" -v tiquetera-node-modules:/workspace/node_modules \
  vue2-t0-devc:arm64 sh -c "$cmd" >/dev/null
for i in $(seq 1 90); do docker logs $name 2>&1 | grep -q "App running at" && break; sleep 2; done
sleep 3
for pp in 8080:/ 3000:/tickets 4000:/socket.io/?EIO=3\&transport=polling; do
  p=${pp%%:*}; ruta=${pp#*:}
  hp=$(docker port $name $p | head -1)
  echo "$p$ruta -> $hp desde el Mac: $(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "http://$hp$ruta")"
  echo "$p$ruta desde dentro: $(docker exec $name sh -c "timeout 5 node -e \"require('http').get('http://localhost:$p$ruta',r=>{console.log(r.statusCode);process.exit()}).on('error',e=>{console.log(e.code);process.exit()})\"")"
done
docker exec $name sh -c 'cat /proc/net/tcp /proc/net/tcp6 2>/dev/null | awk "NR>1 && \$4==\"0A\" {print \$2}"' | sort -u
docker logs $name 2>&1 | grep -i "localhost:3000\|listening\|Resources\|Home\|socket" | head -8
docker rm -f -v $name >/dev/null
