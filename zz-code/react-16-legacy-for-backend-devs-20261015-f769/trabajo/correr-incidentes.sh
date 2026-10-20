#!/bin/sh
# Uso: correr-incidentes.sh <directorio-del-proyecto>
# Para cada incidente con prueba de regresión: la corre en su rama (debe fallar) y en la etiqueta
# de la fase que lo corrige (debe pasar). Columnas: número, prueba, etiqueta, caos, zona horaria. Usa correr-pruebas.sh (mock al lado, db.json restaurado).
set -u
P="$1"
T="$(cd "$(dirname "$0")" && pwd)"
while read -r n file tag chaos tz; do
  for ref in "incidente/$n" "$tag"; do
    (cd "$P" && git checkout -q "$ref")
    result=$(CHAOS_LEVEL="${chaos:-off}" CHAOS_SEED=7 TZ_PRUEBA="${tz:-UTC}" sh "$T/correr-pruebas.sh" "$P" "$file" 2>&1 | grep -E "Tests:" | sed 's/  */ /g')
    echo "inc$n · $ref · $result"
  done
done <<LIST
03 inc03.test.jsx fase-01-estructura-base-router-5
04 inc04.test.jsx fase-01-estructura-base-router-5
05 inc05.test.js fase-02-autenticacion-minima
06 inc06.test.jsx fase-02-autenticacion-minima
07 inc07.test.js fase-03-mock-api-express-caos high
09 inc09.test.jsx fase-04-ruedas-crud
10 inc10.test.js fase-04-ruedas-crud
11 inc11.test.js fase-05-envios-manuales
12 inc12.test.js fase-05-envios-manuales
13 inc13.test.js fase-06-redux-observable-a-fondo
14 inc14.test.js fase-07-cierre-polling-compras
15 inc15.test.js fase-06-redux-observable-a-fondo
16 inc16.test.js fase-07-cierre-polling-compras off America/Panama
17 inc17.test.js fase-07-cierre-polling-compras
18 inc18.test.js fase-08-conciliacion
20 inc20.test.jsx fase-10-testing-minimo off UTC
LIST
(cd "$P" && git checkout -q --detach)
