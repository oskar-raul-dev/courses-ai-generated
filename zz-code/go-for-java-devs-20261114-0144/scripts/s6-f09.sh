#!/usr/bin/env bash
set -uo pipefail
. /scripts/prep.sh
export GOWORK=off
(cd $M/services/storeagent && go mod edit -go=1.25.1 && go get modernc.org/sqlite@v1.59.0 >/dev/null 2>&1 && go mod tidy >/dev/null 2>&1)
(cd $M/labs/pool-lab && go mod edit -go=1.25.1 && go get github.com/jackc/pgx/v5@v5.13.0 >/dev/null 2>&1 && go mod tidy >/dev/null 2>&1)
command -v psql >/dev/null || { apt-get -qq install -y postgresql-client >/dev/null 2>&1; }
p "goose@v3.27.0"; go install github.com/pressly/goose/v3/cmd/goose@v3.27.0 2>&1 | tail -2; goose -version
export GOOSE_DRIVER=postgres GOOSE_DBSTRING="postgres://meridian:meridian@gfjd-pg:5432/meridian?sslmode=disable"
psql -qc "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" 
p "goose up opsreport"; GOOSE_MIGRATION_DIR=$M/services/opsreport/migrations goose up 2>&1 | tail -3
p "goose status"; GOOSE_MIGRATION_DIR=$M/services/opsreport/migrations goose status 2>&1 | tail -3
p "goose up eventrelay en la MISMA base"; GOOSE_MIGRATION_DIR=$M/services/eventrelay/migrations goose up 2>&1 | tail -4
p "goose redo opsreport (prueba el Down)"; GOOSE_MIGRATION_DIR=$M/services/opsreport/migrations goose redo 2>&1 | tail -3
p "con una tabla de versiones por servicio (-table)"
psql -qc "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
goose -dir $M/services/opsreport/migrations -table opsreport_goose_db_version up 2>&1 | tail -1
goose -dir $M/services/eventrelay/migrations -table eventrelay_goose_db_version up 2>&1 | tail -1
goose -dir $M/services/opsreport/migrations -table opsreport_goose_db_version redo 2>&1 | tail -2
GOOSE_TABLE=opsreport_goose_db_version GOOSE_MIGRATION_DIR=$M/services/opsreport/migrations goose status 2>&1 | tail -1
p "\\d deliveries"; psql -c '\d deliveries' | head -25
p "SKIP LOCKED: dos reclamaciones concurrentes"
psql -qc "INSERT INTO endpoints VALUES ('EP-1','Socio','https://socio.test','s3cr3t','{order.*}',true,now())"
psql -qc "INSERT INTO events SELECT 'E-'||g, 'order.created', '{}', NULL, now() FROM generate_series(1,10) g"
psql -qc "INSERT INTO deliveries (id, event_id, endpoint_id, status, attempts, max_attempts, next_attempt, created_at)
  SELECT 'D-'||g, 'E-'||g, 'EP-1', 'pending', 0, 5, now() - interval '1 minute', now() FROM generate_series(1,10) g" 2>&1 | head -3
SQL=$(grep -v '^--' $M/services/eventrelay/internal/postgres/queries.sql | sed "s/\$1/now()/g; s/\$2/4/g")
(psql -At -c "BEGIN; $SQL; SELECT pg_sleep(1); COMMIT;" | grep '^D-' | cut -d'|' -f1 | sort | tr '\n' ' '; echo " ← sesión A") &
sleep 0.2; psql -At -c "BEGIN; $SQL; COMMIT;" | grep '^D-' | cut -d'|' -f1 | sort | tr '\n' ' '; echo " ← sesión B"; wait
p "F09:L400 pool-lab (plazo de 3 s)"
cd $M/labs/pool-lab && go run . 2>&1 | sed 's/^[0-9\/]* [0-9:]* //' | head -8
p "storeagent: WAL y restricciones"
cd $M/services/storeagent && go build -o /tmp/sa ./cmd/storeagent && rm -f /tmp/storeagent.db* && /tmp/sa record -kind SALE -amount 145900 -currency COP && /tmp/sa status
/tmp/sa record -kind GIFT -amount 1 -currency COP; /tmp/sa record -kind SALE -amount 1 -currency cop
ls /tmp/storeagent.db*
