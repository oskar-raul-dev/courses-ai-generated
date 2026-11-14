#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
cd $M/services/opsreport && go mod edit -go=1.25.1 && go get github.com/jackc/pgx/v5@v5.13.0 github.com/testcontainers/testcontainers-go@v0.44.0 github.com/testcontainers/testcontainers-go/modules/postgres@v0.44.0 github.com/pressly/goose/v3@v3.27.0 2>&1 | tail -2; go mod tidy >/dev/null 2>&1
go vet -tags=integration ./internal/postgres/ 2>&1 | head -10; echo "exit $?"
grep "go 1\|toolchain" go.mod
