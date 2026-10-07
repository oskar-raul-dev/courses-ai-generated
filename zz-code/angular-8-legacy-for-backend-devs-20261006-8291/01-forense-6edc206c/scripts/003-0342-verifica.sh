# rescatado de la sesión 6edc206c, 2026-09-08T03:42:40Z · Final integrity check and change summary
echo "=== enlaces rotos, curso completo ==="
grep -oh "](\.\{0,2\}/\?[A-Za-z0-9_][^)#]*\.md)" *.md prompts/*.md | sed 's/^](//; s/)$//' | sort -u > /tmp/l.txt
while read f; do case "$f" in ../*) [ -f "$f" ] || [ -f "${f#../}" ] || echo "ROTO $f";; *) [ -f "$f" ] || echo "ROTO $f";; esac; done < /tmp/l.txt
echo "(sin ROTO = ok · $(wc -l < /tmp/l.txt) destinos distintos)"
echo; echo "=== resumen de cambios ==="; git status --short | sed 's|^|  |'
