#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
(cd $M/services/storeagent && go get modernc.org/sqlite@v1.59.0 >/dev/null 2>&1)
for m in labs/pool-lab labs/tx-lab services/storeagent services/clearinghouse services/opsreport services/eventrelay; do (cd $M/$m && go mod edit -go=1.25.1 && go get github.com/jackc/pgx/v5@v5.13.0 >/dev/null 2>&1; go mod tidy >/dev/null 2>&1); done
bash /scripts/compila.sh go labs/pool-lab labs/tx-lab services/storeagent services/clearinghouse
echo "-- opsreport/internal/postgres"; (cd $M/services/opsreport && go vet ./internal/postgres/ 2>&1 | head -20)
echo "-- eventrelay/internal/postgres"; (cd $M/services/eventrelay && go vet ./internal/postgres/ 2>&1 | head -20)
