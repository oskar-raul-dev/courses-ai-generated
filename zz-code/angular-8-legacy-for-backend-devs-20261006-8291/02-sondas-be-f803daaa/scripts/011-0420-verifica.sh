# rescatado de la sesión f803daaa, 2026-09-09T04:20:51Z · Verify updated document head and section index
cd /Users/oskar/Developer/Learning/courses-ia-generated
sed -n '1,30p' ideas_backend_cursos_angular.md
echo "..."
echo "=== índice completo ==="
grep -nE "^## " ideas_backend_cursos_angular.md | sed 's/^/  /'
