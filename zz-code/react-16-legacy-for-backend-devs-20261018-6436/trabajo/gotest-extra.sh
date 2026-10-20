#!/usr/bin/env bash
# Corre go test sobre una COPIA de server/ con archivos de prueba extra, sin tocar el repo.
# Uso: trabajo/gotest-extra.sh <ruta-destino-en-server> <archivo-extra> [-- args de go test]
# Ej.: trabajo/gotest-extra.sh internal/wheel trabajo/be02/divergencias_test.go -run Divergencia -v
Z="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$1"; EXTRA="$2"; shift 2
docker run --rm --label curso=react16 --network r16t7-net -v "$Z/esclusa-app/server":/src:ro \
  -v "$(cd "$(dirname "$EXTRA")" && pwd)":/extra:ro -v r16t7-gomod:/go/pkg/mod \
  -e PG_URL="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable" golang:1.19.13 \
  sh -c "cp -r /src /work && cp /extra/$(basename "$EXTRA") /work/$DEST/ && cd /work && go test -count=1 $* ./$DEST/ 2>&1"
