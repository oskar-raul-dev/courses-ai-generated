# rescatado de la sesión 8654ffa2, 2026-09-09T13:31:00Z · Verify master links and status
echo "=== enlaces markdown en los dos masters ==="
grep -ohE '\]\([^)]+\)' forense-master.md ../01-vue2-legacy/forense-master.md | tr -d '])(' | sort -u | while read l; do
  d=$(dirname "$l"); b=$(basename "$l")
  if [ -f "$l" ] || [ -f "../01-vue2-legacy/$l" ]; then echo "OK   $l"; else echo "REVISAR $l"; fi
done
echo; echo "=== comprobación explícita ==="
ls ../prompts/convencion-de-git-y-tags.md 00-audit-contrato.md
echo; echo "=== git status paquete ==="; git status --short ..
