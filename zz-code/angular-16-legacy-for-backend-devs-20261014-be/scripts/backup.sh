#!/usr/bin/env bash
# scripts/backup.sh — respaldo nocturno. Escrito en 2016, no tocado desde entonces.
# NOTA DE AUTORÍA: la ausencia de `set -euo pipefail` es EL bug, no un descuido
# de quien escribe esta preparación. Sin ella los psql fallan y el tar corre igual.

DEST="${DEST:-/tmp/certcore-backups}"
PGDATA="${PGDATA:-/var/lib/postgresql/data}"
mkdir -p "$DEST"

psql -U postgres -c "SELECT pg_start_backup('nightly')"
tar czf "$DEST/certcore-$(date +%F).tar.gz" "$PGDATA" 2>/dev/null
psql -U postgres -c "SELECT pg_stop_backup()"
psql -U postgres -c "SELECT pg_switch_xlog()"

echo "respaldo completado: $DEST/certcore-$(date +%F).tar.gz"
