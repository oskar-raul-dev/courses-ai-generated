# rescatado de la sesión 2924cb25, 2026-09-11T16:21:21Z · Read distribution spec and count actual difficulties
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '62,112p' prompts/formato-cuaderno-incidentes.md
echo "=== conteo real dificultades en cuaderno ==="
grep -oE '\| (🟢|🟡|🟠|🔴) \| ⬜' cuaderno-incidentes.md | sort | uniq -c
