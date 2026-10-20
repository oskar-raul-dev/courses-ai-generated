#!/bin/sh
# T6: el chequeo de serialización también mira el payload de cada acción; la que trae la bitácora se excluye.
set -e
cd "$1"
REFS=$(git for-each-ref --format='%(refname)' refs/heads refs/tags | grep -v previo-t1 | grep -v 'previo-revision')
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f \
  --tree-filter 'f=src/app/store.js; if [ -f "$f" ] && grep -q "serializableCheck: { ignoredPaths: \[\"dashboard.spinLog\"\] }," "$f"; then perl -0pi -e "s/      serializableCheck: \{ ignoredPaths: \[\"dashboard\.spinLog\"\] \},\n/      serializableCheck: {\n        ignoredPaths: [\"dashboard.spinLog\"],\n        \/\/ y la acción que la trae: este chequeo también mira el payload de cada acción.\n        ignoredActionPaths: [\"meta.arg\", \"meta.baseQueryMeta\", \"payload.spinLog\"],\n      },\n/" "$f"; fi; true' \
  --tag-name-filter cat -- $REFS
