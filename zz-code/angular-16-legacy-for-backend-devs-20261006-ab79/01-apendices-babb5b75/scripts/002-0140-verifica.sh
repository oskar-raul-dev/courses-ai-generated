# rescatado de la sesión babb5b75, 2026-09-07T01:40:57Z · Final course inventory and checks
echo "=== INVENTARIO DEL CURSO ==="; printf "%-34s %6s\n" "GRUPO" "LINEAS"
printf "%-34s %6s\n" "README + previos (3)" "$(cat README.md 00-historia-del-sistema.md 00-convencion-de-git-y-tags.md | wc -l)"
printf "%-34s %6s\n" "Fases 00-14 (15)" "$(cat 0[0-9]-[a-z]*.md 1[0-4]-*.md 2>/dev/null | grep -v x | wc -l)"
printf "%-34s %6s\n" "Apendices a01-a13 (13)" "$(cat a[01][0-9]-*.md | wc -l)"
printf "%-34s %6s\n" "Track forense (16)" "$(cat forense*.md | wc -l)"
printf "%-34s %6s\n" "Cuaderno de incidentes (1)" "$(wc -l < cuaderno-incidentes.md)"
printf "%-34s %6s\n" "Prompts y especificaciones (8)" "$(cat prompts/*.md | wc -l)"
echo; echo "TOTAL archivos .md del curso: $(ls *.md | wc -l) + $(ls prompts/*.md | wc -l) en prompts/"
echo "TOTAL lineas (sin prompts): $(cat *.md | wc -l)"
echo; echo "--- comprobaciones finales ---"
echo -n "enlaces .md rotos en todo el curso: "; grep -rhoE '\]\([a-z0-9][^)#]*\.md\)' *.md | sed 's/^](//;s/)$//' | sort -u | while read x; do [ -f "$x" ] || echo "$x"; done | wc -l
echo -n "incidentes con solucion de referencia: "; grep -c 'Solución de referencia' cuaderno-incidentes.md
echo -n "incidentes con test de regresion: "; grep -c '\*\*Prueba de regresión\*\*' cuaderno-incidentes.md
echo -n "incidentes con post-mortem: "; grep -c '\*\*Por qué llegó a producción\*\*' cuaderno-incidentes.md
echo -n "incidentes con diagnostico alternativo: "; grep -c '\*\*Si tu causa fue distinta a esta\*\*' cuaderno-incidentes.md
