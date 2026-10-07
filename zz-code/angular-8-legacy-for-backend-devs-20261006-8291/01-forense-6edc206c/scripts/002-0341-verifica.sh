# rescatado de la sesión 6edc206c, 2026-09-08T03:41:18Z · Correct link integrity and bidirectional check
echo "=== enlaces rotos (bien contados) ==="
grep -oh "](\.\{0,2\}/\?[A-Za-z0-9_][^)#]*\.md)" *.md prompts/*.md | sed 's/^](//; s/)$//' | sort -u | while read f; do [ -f "$f" ] || echo "ROTO: $f"; done
echo "(sin ROTO = todo resuelve)"
echo; echo "=== fase ↔ pieza (mapeo correcto) ==="
for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do
  fase=$(ls ${n}-*.md | grep -v convencion | grep -v historia | head -1)
  a=$(grep -c "forense-fase-${n}\.md)" "$fase"); b=$(grep -c "${fase})" forense-fase-${n}.md)
  printf "%-32s pieza←fase:%s  fase←pieza:%s\n" "$fase" "$a" "$b"; done
