#!/usr/bin/env bash
# T3 (a7 §🧰): la receta "a mano" publicada, desde la raíz de una copia limpia de F11 con .devcontainer/.
# Diferencias con lo publicado: etiquetas de la tanda, nombres con prefijo vue2-t3 y puertos aleatorios
# en 127.0.0.1 en vez de los fijos; sin -it (se reemplaza 'bash' por docker exec).
set -u
L="--label curso=vue2-legacy --label tanda=T3"
cd devc/manual
docker build $L -t vue2-t3-tiquetera-dev .devcontainer >/dev/null && echo "build OK"
docker volume create $L vue2-t3-node-modules >/dev/null
docker run -d --rm --name vue2-t3-manual $L \
  -v "$PWD":/workspace \
  -v vue2-t3-node-modules:/workspace/node_modules \
  -e CHOKIDAR_USEPOLLING=true \
  -p 127.0.0.1::8080 -p 127.0.0.1::3000 -p 127.0.0.1::4000 -p 127.0.0.1::8888 \
  vue2-t3-tiquetera-dev sleep infinity >/dev/null
docker exec vue2-t3-manual sh -c 'ls -ld node_modules; npm ci --silent >/dev/null 2>&1; echo "npm ci EXIT=$?"'
docker exec -d vue2-t3-manual sh -c 'npm run mock -- --host 0.0.0.0 > /tmp/mock.log 2>&1'
docker exec -d vue2-t3-manual sh -c 'npm run sockets > /tmp/sockets.log 2>&1'
docker exec -d vue2-t3-manual sh -c 'npm run serve > /tmp/serve.log 2>&1'
for i in $(seq 1 90); do docker exec vue2-t3-manual grep -q "App running at" /tmp/serve.log 2>/dev/null && break; sleep 2; done
for pp in 8080:/ 3000:/tickets "4000:/socket.io/?EIO=3&transport=polling"; do
  p=${pp%%:*}; ruta=${pp#*:}; hp=$(docker port vue2-t3-manual $p | head -1)
  echo "$p$ruta desde el Mac: $(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "http://$hp$ruta")"
done
docker exec vue2-t3-manual sh -c 'head -3 /tmp/mock.log; grep -m1 "escuchando" /tmp/sockets.log'
docker rm -f -v vue2-t3-manual >/dev/null; docker volume rm vue2-t3-node-modules >/dev/null
