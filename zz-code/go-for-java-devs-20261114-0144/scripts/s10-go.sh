#!/usr/bin/env bash
# S10: ClearingHouse Go de referencia + suite de contrato, contra gfjd-pg (base chdb).
. /scripts/prep.sh
export GOWORK=off
command -v psql >/dev/null || apt-get -qq install -y postgresql-client >/dev/null 2>&1
SP=/spring
psql -qc "DROP DATABASE IF EXISTS chdb" && psql -qc "CREATE DATABASE chdb"
for f in $SP/src/main/resources/db/migration/V1__clearinghouse.sql $SP/src/main/resources/db/migration/V2__stores.sql; do psql -q -d chdb -v ON_ERROR_STOP=1 -f $f; done
cd /ch && go get github.com/jackc/pgx/v5@v5.13.0 >/dev/null 2>&1; go mod tidy >/dev/null 2>&1; go vet ./... && CGO_ENABLED=0 go build -o /tmp/ch . || exit 1
export DATABASE_URL="postgres://meridian:meridian@gfjd-pg:5432/chdb?sslmode=disable"
/tmp/ch serve > /tmp/ch.log 2>&1 & sleep 1
cd $SP/contract && CLEARINGHOUSE_URL=http://localhost:8080 go test -count=1 -v . 2>&1 | grep -E "^(---|ok|FAIL|PASS)|    contract" | head -40
kill %1
