# rescatado de la sesión 5d4ed58d, 2026-09-10T02:42:02Z · Verify plan structure and open items
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "=== estructura del plan ==="; grep -n "^## " completado_cuaderno_incidentes.md
echo; echo "=== los 3 ítems abiertos ==="; grep -n "^- \[ \]" completado_cuaderno_incidentes.md
echo; echo "=== suma de líneas por lote, contra lo medido ==="
awk '/^## Incidente/{if(t)print n; n=0} {n++} END{print n}' cuaderno-incidentes.md | tail -20 | paste -sd+ - | bc
