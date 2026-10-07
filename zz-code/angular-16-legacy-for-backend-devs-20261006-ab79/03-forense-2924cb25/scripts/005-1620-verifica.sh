# rescatado de la sesión 2924cb25, 2026-09-11T16:20:17Z · Check incident mentions in forensic pieces and format docs
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== A8 piezas: menciones a incidentes ==="; grep -c 'ncidente' angular-8-legacy-for-backend-devs/forense-fase-*.md | grep -v ':0'
echo; echo "=== A16 piezas: menciones a incidentes ==="; grep -c 'ncidente' angular-16-legacy-for-backend-devs/forense-fase-*.md | grep -v ':0'
echo; echo "=== A8 formato-piezas §8 (checklist) sobre incidentes ==="; grep -n -i 'incidente' angular-8-legacy-for-backend-devs/prompts/formato-piezas-forenses.md
echo; echo "=== A16 formato-piezas: menciones incidente ==="; grep -n -i 'incidente' angular-16-legacy-for-backend-devs/prompts/formato-piezas-forenses.md
