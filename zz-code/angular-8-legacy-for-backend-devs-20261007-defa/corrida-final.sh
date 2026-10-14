#!/usr/bin/env bash
# T5 final run: every T1-T4 test again, from the markdown as it is now, with fresh containers.
# Outputs go to salidas/final/ and are compared with the ones saved during T1-T4 (noise filtered: Jasmine
# seeds, nginx timestamps, ANSI colours). Usage: CURSO=<course> bash corrida-final.sh
set -uo pipefail
cd "$(dirname "$0")"
: "${CURSO:?set CURSO}"; export CURSO
F=salidas/final; rm -rf $F; mkdir -p $F
N=node:14.21.3
nrun() { docker run --rm --label curso=angular8 "$@"; }
clean() { sed -E 's/\x1b\[[0-9;]*m//g' | grep -v -E '^Randomized|^Started|^Finished|^$|^\.+$|\[notice\]|^\s*$'; }

echo "== extraer"
bash extraer/t1-entradas.sh >/dev/null && bash extraer/t2-entradas.sh >/dev/null && bash extraer/t4-entradas.sh >/dev/null
python3 extraer/bloque.py bea-12-datos-de-prueba-y-volumen.md "var SHAPES = [" > sondas/mongo/generar.js
python3 extraer/bloque.py bea-06-jsonschema-sobre-datos-sucios.md "collMod: 'patients'" > sondas/mongo/bea06-collmod.js
python3 extraer/bloque.py bea-08-tiempo-zonas-y-fechas-en-mongo.md "timezone: 'America/Toronto'" > sondas/mongo/bea08-agg.js
python3 extraer/t3-java-bea08.py > sondas/java8/bea08/Bea08.java
python3 extraer/bloque.py 05-pacientes.md "var SEEDABLE_ORDER_STATUSES" > sondas/seed/seed-despues.js

echo "== T1"
bash comandos-t1.sh datepipe 2>&1 | clean > $F/t1-datepipe-iana.txt
# The date table is built ONCE from the original course (git HEAD, exported to salidas/head-original):
# rebuilding it from the edited markdown would empty it. Here only tabla.js runs again on that inventory.
nrun -e TZ=America/Toronto -v "$PWD/fechas:/w" -w /w $N node tabla.js > $F/t1-fechas-America-Toronto.txt
for tz in America/Toronto Asia/Tokyo; do nrun -e TZ=$tz -v "$PWD/sondas/angular8:/w" -v "$PWD/fechas:/fechas:ro" -w /w $N node t1-verificar.js; done 2>&1 | clean > $F/t1-verificar.txt
nrun -v "$PWD/sondas/angular8:/w" -w /w $N sh t1-json-server.sh > $F/t1-json-server.txt
python3 fechas/cierre-t1.py > $F/t1-cierre.txt
for s in fase05-fechas fase08-selector; do for tz in America/Toronto UTC Asia/Tokyo; do nrun -e TZ=$tz -v "$PWD/sondas/angular8:/w" -w /w $N node $s.js; done > $F/t1-$s.txt; done
for tz in America/Toronto Asia/Tokyo; do nrun -e TZ=$tz -v "$PWD/sondas/angular8:/w" -w /w $N node incidente07.js; done > $F/t1-incidente07.txt
(cd esqueleto/clinical-lab && rm -rf dist) ; bash esqueleto/armar.sh >/dev/null
(cd esqueleto/clinical-lab && docker build --no-cache -q --label curso=angular8 -t lab-frontend:t1 . >/dev/null) && echo "ng build --prod: ok" > $F/t1-build.txt || echo "ng build --prod: FALLA" > $F/t1-build.txt
bash incidente19.sh 2>&1 | clean > $F/t1-incidente19.txt
docker rmi lab-frontend:t1 lab-frontend:inc19 >/dev/null; docker network rm angular8-t1 >/dev/null

echo "== T2"
nrun -v "$PWD/sondas/angular8:/w" -w /w $N sh t2-verificar.sh 2>&1 | clean > $F/t2-verificar.txt
nrun -v "$PWD/sondas/angular8:/w" -w /w $N node t2-moneda.js > $F/t2-moneda.txt
for tz in UTC Asia/Tokyo; do nrun -e TZ=$tz -v "$PWD/sondas/angular8:/w" -w /w $N node fase09-pdf.js; done > $F/t2-fase09-pdf.txt

echo "== T3"
(cd sondas/java8/bea08 && for tz in UTC America/Toronto; do docker run --rm --label curso=angular8 -e TZ=$tz -v "$PWD:/w" -w /w eclipse-temurin:8-jdk sh -c 'javac -d /tmp Bea08.java && java -cp /tmp Bea08'; done) > $F/t3-java-bea08.txt 2>&1
nrun -v "$PWD/sondas:/s" -w /s/mongo $N node generar-pacientes.js > $F/t3-bea12.txt
docker run -d --label curso=angular8 --name angular8-mongo40 -v "$PWD/sondas/mongo:/s:ro" mongo:4.0 >/dev/null; sleep 6
docker exec angular8-mongo40 mongoimport --quiet --db t3gen --collection patients --jsonArray --file /s/patients.json
docker exec angular8-mongo40 mongo --quiet /s/t3-mongo.js > $F/t3-mongo.txt 2>&1
docker rm -f -v angular8-mongo40 >/dev/null

echo "== T4"
for tz in America/Toronto Asia/Tokyo; do nrun -e TZ=$tz -v "$PWD/sondas/angular8:/w" -w /w $N node inc22/verificar.js 2>&1 | clean; done > $F/t4-incidente22.txt
(cd sondas/seed && cp ../angular8/extraidos/fase04-db.json db.json && rm -rf run-* && docker run --rm --label curso=angular8 -e TZ=Asia/Tokyo -v "$PWD:/w" -w /w $N node comparar.js) > $F/t4-seed-invierno.txt
python3 fechas/indice.py > $F/t4-indice.txt

echo "== comparar con lo guardado"
for f in $F/*.txt; do
  b=salidas/$(basename $f)
  [ -f "$b" ] || { echo "nuevo      $(basename $f)"; continue; }
  if diff -q <(clean < "$b") <(clean < "$f") >/dev/null; then echo "igual      $(basename $f)"; else echo "DISTINTO   $(basename $f)"; fi
done
