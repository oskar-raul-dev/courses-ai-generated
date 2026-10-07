# rescatado de la sesión 2924cb25, 2026-09-11T17:12:48Z · Calibrate size against angular-8 BE track
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== tamaños del track BE de angular-8 (referencia) ==="
wc -w angular-8-legacy-for-backend-devs/be0*.md angular-8-legacy-for-backend-devs/bea-0[1-3]*.md angular-8-legacy-for-backend-devs/cuaderno-incidentes-be.md | tail -15
echo; echo "=== plantilla de fase (9 secciones) en angular-16 ==="
cd angular-16-legacy-for-backend-devs
grep -n '^## \|^### ' prompts/plantillas-de-capitulo.md | head -30
