# rescatado de la sesión 2924cb25, 2026-09-11T16:20:10Z · Check reciprocal linking between forensic pieces and incidents
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== A16 formato-piezas-forenses: secciones ==="; grep -n '^#\{1,3\} ' angular-16-legacy-for-backend-devs/prompts/formato-piezas-forenses.md
echo; echo "=== A16 piezas que enlazan incidentes ==="; grep -l 'cuaderno-incidentes' angular-16-legacy-for-backend-devs/forense-*.md
echo; echo "=== A8 piezas que enlazan incidentes ==="; grep -l 'cuaderno-incidentes' angular-8-legacy-for-backend-devs/forense-*.md
