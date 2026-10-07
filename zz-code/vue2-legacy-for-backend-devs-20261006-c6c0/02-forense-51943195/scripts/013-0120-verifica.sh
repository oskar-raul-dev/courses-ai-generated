# rescatado de la sesión 51943195, 2026-09-10T01:20:32Z · Final verification of edits
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
echo "== refs viejas =="; grep -rn "La ruta cambia, la URL cambia\|relé tonto del Curso 01\|sesión que sobrevive\|métrica que no cuadra" prompts/ 0*/forense-master.md
echo "== links =="
for f in prompts/*.md 01-vue2-legacy/forense-master.md 02-complement-mongodb-backend/forense-master.md; do d=$(dirname $f); grep -o '](\.\{0,2\}[^)]*\.md[^)]*)' $f | sed 's/](//;s/)$//;s/#.*//' | sort -u | while read p; do [ -e "$d/$p" ] || echo "ROTO: $f -> $p"; done; done
echo "== voseo =="; grep -nE '\b(tenés|podés|querés|hacé|mirá|fijate|vos|sabés|ponés|andá)\b' prompts/*.md 0*/forense-master.md
echo "== columnas tablas §2 =="; awk -F'|' '/^\|/{print NF-2, FILENAME}' 01-vue2-legacy/forense-master.md 02-complement-mongodb-backend/forense-master.md | sort | uniq -c
