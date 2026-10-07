# rescatado de la sesión 51943195, 2026-09-10T01:17:10Z · Look for sourced symptoms in F1 and F2
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "== F01 conceptos/router =="; grep -n "router-view\|router-link\|:key\|params\|watch" 01-estructura-base-legacy.md | head -20
echo "== F02 guard/localStorage/pestaña =="; grep -n "guard\|pestaña\|storage\|expira\|token" 02-autenticacion-minima.md | sed -n '1,25p'
