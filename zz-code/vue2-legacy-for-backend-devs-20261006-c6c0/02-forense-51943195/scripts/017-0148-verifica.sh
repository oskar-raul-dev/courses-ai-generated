# rescatado de la sesión 51943195, 2026-09-10T01:48:44Z · Inspect base incident notebook
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
wc -l cuaderno-incidentes.md cuaderno-incidentes-be.md prompts/plantilla-de-incidente.md
echo "== headings base =="; grep -n '^## \|^### ' cuaderno-incidentes.md | head -30
echo "== indice base (filas) =="; grep -c '^| ' cuaderno-incidentes.md
