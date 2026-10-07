# rescatado de la sesión 6edc206c, 2026-09-08T03:41:05Z · Full course link integrity check
echo "=== 1. Enlaces rotos en TODO el curso ==="
grep -oh "](\.\{0,2\}/\?[A-Za-z0-9_][^)#]*\.md)" *.md prompts/*.md | tr -d ')]' | sed 's|^\./||' | sort -u | while read f; do
  case "$f" in ../*) [ -f "${f#../}" ] || [ -f "$f" ] || echo "ROTO: $f";; *) [ -f "$f" ] || echo "ROTO: $f";; esac; done
echo "(sin ROTO = todo resuelve)"
echo; echo "=== 2. Cada fase enlaza su pieza y cada pieza su fase ==="
for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do
  fase=$(ls ${n}-*.md 2>/dev/null | head -1)
  a=$(grep -c "](\./forense-fase-${n}\.md)" "$fase"); b=$(grep -c "](\./${fase})" forense-fase-${n}.md)
  printf "fase %s → pieza:%s   pieza → fase:%s\n" "$n" "$a" "$b"; done
echo; echo "=== 3. Enlaces por archivo nuevo ==="
for f in forense-*.md prompts/formato-piezas-forenses.md; do printf "%-38s %s enlaces\n" "$f" "$(grep -o "](\.\{0,2\}/\?[A-Za-z0-9][^)]*\.md" $f | wc -l | tr -d ' ')"; done
