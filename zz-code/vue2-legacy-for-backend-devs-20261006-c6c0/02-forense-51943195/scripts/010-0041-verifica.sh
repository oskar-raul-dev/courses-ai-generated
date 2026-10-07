# rescatado de la sesión 51943195, 2026-09-10T00:41:36Z · Check F7 errors and 404 symptom
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "== F07 errores =="; sed -n '715,740p' 07-metricas-minimas.md
echo "== 404 comments =="; grep -rn "404" 03-mock-api-minima.md 09-panel-soporte.md | head -6
