# rescatado de la sesión 5d4ed58d, 2026-09-10T02:40:23Z · Check style guide decisions record and pending items
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "=== ¿D1–D6 quedaron anotadas en la guía §15? ==="
sed -n '810,835p' prompts/guia-de-estilo-y-convenciones.md
echo
echo "=== ¿existe el script de siembra del incidente 19? ==="
ls scripts/seedHeavyDay.js 2>/dev/null || echo "  NO existe (esperado: el incidente instruye a escribirlo)"
echo
echo "=== ¿el plan está referenciado desde algún .md? ==="
grep -rln "completado_cuaderno_incidentes" --include="*.md" . 
