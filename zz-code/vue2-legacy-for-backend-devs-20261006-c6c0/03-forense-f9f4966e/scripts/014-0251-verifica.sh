# rescatado de la sesión f9f4966e, 2026-09-10T02:51:17Z · Check event names and enums against contract
echo "=== eventos citados en piezas/cuadernos ==="; grep -rhoE '"(ticket|comment|activity):[a-z]+"' 01-vue2-legacy/forense-*.md 01-vue2-legacy/cuaderno-incidentes.md 02-complement-mongodb-backend/forense-*.md 02-complement-mongodb-backend/cuaderno-incidentes.md | sort | uniq -c
echo "=== status/priority usados ==="; grep -rhoE 'status: "[a-z_]+"|priority: "[a-z]+"' 01-vue2-legacy/forense-*.md 02-complement-mongodb-backend/forense-*.md 0*/cuaderno-incidentes.md | sort | uniq -c
echo "=== enums del contrato ==="; grep -nE 'open/in_progress|"open"|resolved|closed' 02-complement-mongodb-backend/00-audit-contrato.md | head -5
