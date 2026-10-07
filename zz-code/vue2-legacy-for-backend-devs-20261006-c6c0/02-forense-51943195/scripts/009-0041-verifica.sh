# rescatado de la sesión 51943195, 2026-09-10T00:41:07Z · Link, voseo and section 9 checks
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
echo "=== links rotos ==="
for f in prompts/convencion-de-git-y-tags.md prompts/guia-de-estilo-y-convenciones.md prompts/plantilla-de-fase.md prompts/formato-piezas-forenses.md prompts/formato-cuaderno-incidentes.md 01-vue2-legacy/forense-master.md 02-complement-mongodb-backend/forense-master.md; do
  d=$(dirname $f)
  grep -o '](\.\{0,2\}[^)]*\.md[^)]*)' $f | sed 's/](//;s/)$//;s/#.*//' | sort -u | while read p; do
    [ -e "$d/$p" ] || echo "ROTO: $f -> $p"
  done
done
echo "=== voseo ==="
grep -nE '\b(tenés|podés|querés|hacé|mirá|fijate|vos|sabés|ponés|andá)\b' prompts/formato-*.md */forense-master.md prompts/convencion-de-git-y-tags.md | head
echo "=== guia §9 encabezado ==="
sed -n '600,632p' prompts/guia-de-estilo-y-convenciones.md
