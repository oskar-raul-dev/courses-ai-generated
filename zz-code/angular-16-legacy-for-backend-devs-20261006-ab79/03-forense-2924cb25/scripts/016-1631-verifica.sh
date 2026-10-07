# rescatado de la sesión 2924cb25, 2026-09-11T16:31:25Z · Final sanity check of edits
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -c 'Ruta forense' cuaderno-incidentes.md
grep -n '^#\{1,3\} ' prompts/formato-cuaderno-incidentes.md
echo "=== diffstat del curso ==="; cd .. && git diff --stat -- angular-16-legacy-for-backend-devs | tail -8; git status --porcelain -- angular-16-legacy-for-backend-devs | grep '??'
