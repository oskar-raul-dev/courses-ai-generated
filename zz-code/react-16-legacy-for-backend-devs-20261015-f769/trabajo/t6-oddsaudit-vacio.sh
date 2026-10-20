#!/bin/sh
# T6: oddsAudit con cero giros devolvía χ² = NaN (0/0). La guarda entra desde la F08 en toda la historia.
set -e
cd "$1"
REFS=$(git for-each-ref --format='%(refname)' refs/heads refs/tags | grep -v previo-t1 | grep -v 'previo-revision')
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f \
  --tree-filter 'f=src/features/reconciliation/oddsAudit.js; if [ -f "$f" ] && ! grep -q "Sin giros no hay nada" "$f"; then perl -0pi -e "s/(  const n = counts\.reduce\(\(sum, c\) => sum \+ c, 0\);\n)/\$1  \/\/ Sin giros no hay nada que auditar: ni alarma, ni un χ² de 0\/0.\n  if (n === 0) return { bandAlarms: [], chi2: 0, chi2Alarm: false };\n/" "$f"; fi; true' \
  --tag-name-filter cat -- $REFS
