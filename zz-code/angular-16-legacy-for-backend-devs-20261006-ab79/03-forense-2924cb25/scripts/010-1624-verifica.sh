# rescatado de la sesión 2924cb25, 2026-09-11T16:24:47Z · Read BE proposal section on the incident logbook
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '/^## .*9\./,/^## /p' prompts/propuesta-fases-backend.md | grep -n 'cuaderno\|incidente\|prepar\|plantilla-de-incidente\|\.env' | head -30
echo "=== busca la sección del cuaderno BE ==="
grep -n 'cuaderno-incidentes-be\|plantilla-de-incidente-be' prompts/propuesta-fases-backend.md | head
