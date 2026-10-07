# rescatado de la sesión 70a2da9f, 2026-09-10T22:06:44Z · Verify no cross-course references remain
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs
echo "=== 1. refs a cursos hermanos (excluye 'volumen' y a11) ==="
grep -rniE "angular.?16|angular-16|certcore|lumen|react.?16|react-16|vue.?2|curso hermano|curso de contenedores" . --include='*.md' | grep -v "_deprecado" | grep -viE "volumen|volúmen" | grep -v "^./a11-migracion-9-16.md"
echo "--- (a11, solo versión de Angular:)"
grep -rn "Angular 16" a11-migracion-9-16.md | wc -l
echo
echo "=== 2. rutas a otros directorios de curso ==="
grep -rnE "\.\./(react|angular|vue)-" . --include='*.md' | grep -v "_deprecado"
echo "(vacío = ok)"
