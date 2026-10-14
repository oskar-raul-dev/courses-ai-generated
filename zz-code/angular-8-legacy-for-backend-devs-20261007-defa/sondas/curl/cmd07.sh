# El borde se corrige en el dato; el código no se toca.
curl -s -X PATCH -H "Content-Type: application/json" \
  -d '{"effectiveTo": "2021-12-31T23:59:59-05:00"}' http://localhost:3000/referenceRanges/31
curl -s -X PATCH -H "Content-Type: application/json" \
  -d '{"effectiveFrom": "2022-01-01T00:00:00-05:00"}' http://localhost:3000/referenceRanges/32
