# rescatado de la sesión ba539b99, 2026-09-11T03:40:45Z · Check cross-track references
echo "== quién referencia 00-historia-del-sistema.md =="; grep -ln "00-historia-del-sistema" *.md prompts/*.md
echo; echo "== quién referencia el track BE desde el track base =="; grep -ln "be0[0-8]\|bea-" [0-9]*.md a*.md forense*.md cuaderno-incidentes.md 2>/dev/null
echo; echo "== quién referencia cuaderno-incidentes.md =="; grep -lc "cuaderno-incidentes.md" *.md | head -40
