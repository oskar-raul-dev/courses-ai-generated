# rescatado de la sesión 2924cb25, 2026-09-11T16:21:28Z · Count difficulty distribution and read A8 distribution spec
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep '^| \[' cuaderno-incidentes.md | awk -F'|' '{print $6}' | sort | uniq -c
echo "=== A8 formato §3 reparto ==="; sed -n '113,160p' ../angular-8-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md
