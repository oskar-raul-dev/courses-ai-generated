#!/usr/bin/env bash
# ng serve dentro del devcontainer, curl desde el Mac por un puerto aleatorio de 127.0.0.1, y recarga
# al tocar un archivo DESDE EL MAC, con y sin --poll. Usa el volumen que dejó t0-devc-run.sh.
# Uso: ./t0-devc-serve.sh <linux/arm64|linux/amd64> <con|sin|sinhost> [proyecto] [tag]
# sinhost: ng serve sin --host (escucha en localhost del contenedor).
set -uo pipefail
cd "$(dirname "$0")"
PLAT=${1:-linux/arm64}; A=${PLAT#linux/}; MODO=${2:-con}; PROY=${3:-devc/clinical-lab}; TAG=${4:-a8-t0-devc:$A}
CN=a8-t0-serve-$A; VOL=a8-t0-lab-node-modules-$A
POLL=""; [ "$MODO" = con ] && POLL="--poll 2000"
HOST="--host 0.0.0.0"; [ "$MODO" = sinhost ] && HOST=""
docker rm -f -v "$CN" >/dev/null 2>&1
docker run -d --name "$CN" --label curso=angular-8-legacy --label tanda=AS --platform "$PLAT" -u node \
  -v "$PWD/$PROY:/workspace" -v "$VOL:/workspace/node_modules" -w /workspace \
  -p 127.0.0.1::4200 "$TAG" sleep infinity >/dev/null
PORT=$(docker port "$CN" 4200/tcp | head -1 | sed 's/.*://')
echo "== ng serve $HOST $POLL  (host 127.0.0.1:$PORT)"
docker exec -d "$CN" bash -c "npx ng serve $HOST $POLL > /tmp/serve.log 2>&1"
for i in $(seq 1 120); do docker exec "$CN" grep -q 'Compiled successfully' /tmp/serve.log 2>/dev/null && break; sleep 2; done
echo "listo tras ~$((i*2)) s"
echo "HTTP desde el Mac: $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:$PORT/)"
N0=$(docker exec "$CN" grep -c 'Compiled successfully' /tmp/serve.log)
F=$PROY/src/app/app.component.html
echo "<!-- t0 $(date +%s) -->" >> "$F"
sleep 15
N1=$(docker exec "$CN" grep -c 'Compiled successfully' /tmp/serve.log)
echo "compilaciones antes=$N0 después de tocar desde el Mac=$N1 -> $([ "$N1" -gt "$N0" ] && echo RECARGA || echo NO-RECARGA)"
sed -i '' '$d' "$F"
docker exec "$CN" bash -c 'grep -E "Compiled|listening|Angular Live" /tmp/serve.log | tail -4'
docker rm -f -v "$CN" >/dev/null
