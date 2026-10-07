# rescatado de la sesión 31a544c8, 2026-09-12T01:45:32Z · Cross-check incidents and links
echo "=== incidentes declarados por fase vs cuaderno ==="
for f in be0*.md; do printf "%-6s " "$(echo $f|cut -c1-4)"; sed -n '5p' "$f" | grep -o 'be-[0-9][0-9]' | tr '\n' ' '; echo; done
echo "cuaderno:"; grep -o '^## Incidente be-[0-9][0-9]' cuaderno-incidentes-be.md | grep -o 'be-[0-9][0-9]' | tr '\n' ' '; echo
echo; echo "=== enlaces a archivos inexistentes ==="
grep -oh '](\([a-z0-9][^):#]*\.md\)' be0*.md bea-*.md cuaderno-incidentes-be.md README.md | sed 's/](//' | sort -u | while read f; do [ -f "$f" ] || echo "❌ $f"; done
echo "(sin salida = todos existen)"
