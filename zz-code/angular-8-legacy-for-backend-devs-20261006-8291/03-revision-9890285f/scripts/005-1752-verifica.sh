# rescatado de la sesión 9890285f, 2026-09-10T17:52:40Z · Check placeholders and exercise counts in appendices
echo "=== placeholders/TODO ==="; grep -rn "{{[^}]*}}\|TODO\|TBD\|XXX\|FIXME\|Lorem" --include="*.md" . | grep -v "^./cuaderno-incidentes.md\|^./prompts/" | grep -v "{{ *'" | head -15
echo; echo "=== ejercicios: título vs conteo real ==="
for f in a0*.md a1*.md; do
  t=$(grep -o "Ejercicios (\([0-9]*\))" "$f" | head -1 | grep -o "[0-9]*")
  r=$(awk '/^## .*Ejercicios/{p=1;next} p&&/^## /{exit} p&&/^[0-9]+\. /{c++} END{print c+0}' "$f")
  [ "$t" != "$r" ] && echo "  ✗ $f: título dice $t, hay $r" || echo "  ok $f ($t)"
done
