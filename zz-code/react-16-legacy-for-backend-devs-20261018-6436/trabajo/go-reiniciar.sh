#!/usr/bin/env bash
# Recrea la base (drop + up), siembra desde el db.json del repo y levanta el binario en el 3011 de r16t7-go.
# Uso: trabajo/go-reiniciar.sh [DATABASE_URL]
URL="${1:-postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama}"
docker exec r16t7-go sh -c "kill \$(pidof api) 2>/dev/null; sleep 0.3; gofmt -l .; export DATABASE_URL='$URL'
migrate -path migrations/postgres -database \"\$DATABASE_URL\" drop -f >/dev/null 2>&1
migrate -path migrations/postgres -database \"\$DATABASE_URL\" up 2>&1 | tail -1
go run ./cmd/seed -file ../mock/db.json 2>&1 | tail -1
go build -o /tmp/api ./cmd/api && (PLAY_URL=${PLAY_URL:-http://app:3002} JWT_SECRET=${JWT_SECRET:-laboratorio-esclusa-secreto-de-32-bytes-o-mas} PORT=\${PORT:-3011} /tmp/api > /tmp/api.log 2>&1 &) ; sleep 1; tail -1 /tmp/api.log"
