#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off GOOSE_DRIVER=postgres GOOSE_DBSTRING="postgres://meridian:meridian@gfjd-pg:5432/meridian?sslmode=disable"
command -v psql >/dev/null || apt-get -qq install -y postgresql-client >/dev/null 2>&1
go install github.com/pressly/goose/v3/cmd/goose@v3.27.0 >/dev/null 2>&1
psql -qc "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" 2>/dev/null
p "goose up de la migración de batches (F13)"
goose -dir $M/services/clearinghouse/migrations -table ch_goose up 2>&1 | tail -3
psql -c '\dt'
p "goose down"
goose -dir $M/services/clearinghouse/migrations -table ch_goose down 2>&1 | tail -2
p "chunked-stream"
cd $M/labs/chunked-stream && go mod edit -go=1.25.1 && go mod tidy >/dev/null 2>&1 && go vet . 2>&1 | head -5 && go test -count=1 . 2>&1 | tail -3
