#!/usr/bin/env bash
# Banco sistemático del cortafuegos de Q3. Variantes: A = sin el CSS de Bootstrap (referencia), B = con Bootstrap,
# C = con Bootstrap y el cortafuegos (salidas/qcss/cortafuegos.scss). Construye qcss/, sirve /css-prueba, vuelca las
# medidas (estilos computados de cada elemento) con Chromium headless y saca una captura. Uso: ./t-qbanco.sh A|B|C
set -uo pipefail
cd "$(dirname "$0")"
V=$1; L="--label curso=vue2-legacy --label tanda=qcss"; NET=vue2-qcss-net; OUT="$PWD/salidas/qbanco"
cp salidas/qcss/app-antes.scss qcss/src/css/app.scss
[ "$V" = C ] && cat salidas/qcss/cortafuegos.scss >> qcss/src/css/app.scss
python3 -I - "$V" <<'PY'
import sys
p = "qcss/quasar.conf.js"; t = open(p).read()
con, sin = "      'bootstrap',\n", "      // 'bootstrap', (variante A del banco)\n"
t = t.replace(sin, con)
if sys.argv[1] == "A":
    t = t.replace(con, sin)
open(p, "w").write(t)
PY
docker network create $L $NET >/dev/null 2>&1; docker volume create $L vue2-qcss-nm >/dev/null
docker run --rm $L -v "$PWD/qcss":/app -v vue2-qcss-nm:/app/node_modules -w /app node:14.21.3 \
  bash -c '[ -d node_modules/quasar ] || npm ci --silent >/dev/null 2>&1; npx quasar build > /tmp/b.log 2>&1; echo "EXIT_BUILD=$?"'
docker rm -f vue2-qcss-web >/dev/null 2>&1
docker run -d --name vue2-qcss-web $L --network $NET -v "$PWD/qcss/dist/spa":/srv -w /srv node:14.21.3 \
  npx -p http-server@14.1.1 http-server -p 8080 -s --proxy "http://localhost:8080?" >/dev/null
sleep 12
CH="docker run --rm $L --network $NET -v $OUT:/out zenika/alpine-chrome:124 --no-sandbox --hide-scrollbars --virtual-time-budget=6000 --window-size=1000,1600"
$CH --dump-dom "http://vue2-qcss-web:8080/css-prueba" 2>/dev/null > "$OUT/$V.html"
$CH --screenshot=/out/$V.png "http://vue2-qcss-web:8080/css-prueba" >/dev/null 2>&1
docker rm -f vue2-qcss-web >/dev/null
python3 -I -c "
import re, html, sys
t = open('$OUT/$V.html', encoding='utf-8').read()
m = re.search(r'<pre id=\"medidas\">(.*?)</pre>', t, re.S)
open('$OUT/$V.json', 'w').write(html.unescape(m.group(1)) if m else '')
print('$V: medidas', 'OK' if m and m.group(1) else 'VACÍAS')"
