# rescatado de la sesión 31a544c8, 2026-09-11T18:46:12Z · Verify exercise numbering matches declared counts
for f in be0*.md bea-*.md; do
  d=$(grep -o "Ejercicios ([0-9]*)" "$f" | head -1 | grep -o '[0-9]*')
  last=$(awk '/^## 🧪/{s=1} s&&/^[0-9]+\./{n=$1} /^## 📚/{s=0} END{print n}' "$f" | tr -d '.')
  st=$([ "$d" = "$last" ] && echo OK || echo "⚠ declarado=$d último=$last")
  printf "%-52s %s\n" "$f" "$st"
done
