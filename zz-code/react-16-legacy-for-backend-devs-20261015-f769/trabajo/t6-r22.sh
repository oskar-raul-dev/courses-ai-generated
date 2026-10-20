#!/bin/sh
# R22 (T6): el cierre de la rueda 1 pasa de 2026-10-31 a 2030-12-31 en toda la historia del repo de prueba.
# Reescribe ramas y etiquetas (menos previo-*); el historial anterior queda en refs/original.
set -e
cd "$1"
REFS=$(git for-each-ref --format='%(refname)' refs/heads refs/tags | grep -v previo)
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f \
  --tree-filter 'grep -rl --exclude-dir=node_modules "2026-10-31T20:00:00-05:00" . 2>/dev/null | while read f; do sed -i "" "s/2026-10-31T20:00:00-05:00/2030-12-31T20:00:00-05:00/g" "$f"; done; true' \
  --tag-name-filter cat -- $REFS
