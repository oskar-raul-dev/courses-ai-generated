#!/usr/bin/env bash
# Para cada módulo, la última versión estable cuyo go.mod pide go <= 1.25.1 (consulta proxy.golang.org).
mods="github.com/jackc/pgx/v5 github.com/pressly/goose/v3 modernc.org/sqlite github.com/testcontainers/testcontainers-go github.com/testcontainers/testcontainers-go/modules/postgres github.com/stretchr/testify go.mongodb.org/mongo-driver/v2 go.uber.org/mock golang.org/x/perf golang.org/x/vuln golang.org/x/tools golang.org/x/sync github.com/valkey-io/valkey-go github.com/prometheus/client_golang github.com/sqlc-dev/sqlc entgo.io/ent gorm.io/gorm"
for m in $mods; do
  latest=$(curl -s https://proxy.golang.org/$m/@latest | sed 's/.*"Version":"\([^"]*\)".*/\1/')
  best=""; bestgo=""
  for v in $(curl -s https://proxy.golang.org/$m/@v/list | grep -v -- '-' | sort -V -r | head -40); do
    g=$(curl -s https://proxy.golang.org/$m/@v/$v.mod | awk '/^go /{print $2; exit}')
    if [ -z "$g" ] || [ "$(printf '%s\n%s\n' "$g" 1.25.1 | sort -V | head -1)" = "$g" ]; then best=$v; bestgo=$g; break; fi
  done
  lg=$(curl -s https://proxy.golang.org/$m/@v/$latest.mod | awk '/^go /{print $2; exit}')
  printf '%-55s latest=%-10s (go %s)  compatible=%-10s (go %s)\n' "$m" "$latest" "$lg" "$best" "$bestgo"
done
