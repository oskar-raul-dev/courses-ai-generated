#!/usr/bin/env bash
# Proves the skip scan with EXPLAIN ANALYZE (Index Searches) and checks pg_hint_plan in the PGDG apt repo.
set -uo pipefail
cd "$(dirname "$0")/.."
C="docker compose -f lab/compose.yaml --profile base"
$C exec -T postgres psql -U postgres -d alameda <<'SQL'
CREATE INDEX p8_protocol_site_date_idx ON legacy."Protocolos" ("Sede", "Fecha");
ANALYZE legacy."Protocolos";
EXPLAIN (ANALYZE, COSTS OFF, TIMING OFF, SUMMARY OFF) SELECT count(*) FROM legacy."Protocolos" WHERE "Fecha" = DATE '2015-03-02';
DROP INDEX legacy.p8_protocol_site_date_idx;
SQL
docker run --rm --label curso=ruta-sql pgvector/pgvector:0.8.7-pg18 sh -c \
  'apt-get update -qq >/dev/null 2>&1; apt-cache policy postgresql-18-pg-hint-plan | head -4'
