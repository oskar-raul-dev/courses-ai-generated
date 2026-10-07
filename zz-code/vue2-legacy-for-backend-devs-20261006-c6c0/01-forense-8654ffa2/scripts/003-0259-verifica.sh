# rescatado de la sesión 8654ffa2, 2026-09-09T02:59:19Z · Check tag blocks in all phases
echo "=== ¿Las fases llevan el bloque 🏷️? (guía §9.1) ==="
for f in 01-vue2-legacy/0[0-9]*.md 01-vue2-legacy/1[01]*.md 01-vue2-legacy/[qvn][0-9x]*.md 02-complement-mongodb-backend/[0-9]*.md; do
  n=$(grep -c '🏷️' "$f"); t=$(grep -o 'git tag -a [a-z0-9-]*' "$f" | head -1)
  printf '%-46s 🏷️:%-3s %s\n' "$(basename $f)" "$n" "$t"
done
