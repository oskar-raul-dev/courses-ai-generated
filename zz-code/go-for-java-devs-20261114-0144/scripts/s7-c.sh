#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
for m in labs/bson-lab labs/aggregation-lab labs/cache-aside-lab labs/stampede-lab; do (cd $M/$m && go mod edit -go=1.25.1 && go get go.mongodb.org/mongo-driver/v2@v2.10.0 github.com/valkey-io/valkey-go@v1.0.79 golang.org/x/sync@v0.22.0 >/dev/null 2>&1; go mod tidy >/dev/null 2>&1); done
bash /scripts/compila.sh go labs/bson-lab labs/aggregation-lab labs/cache-aside-lab labs/stampede-lab
