# rescatado de la sesión 2924cb25, 2026-09-11T16:22:52Z · Find forensic pieces missing the reciprocal footer
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -L 'Incidentes del cuaderno que usan esta ruta' forense-fase-*.md
echo "=== f12 tail ==="; tail -18 forense-fase-12.md
echo "=== f07 línea 178 contexto ==="; sed -n '174,180p' forense-fase-07.md
