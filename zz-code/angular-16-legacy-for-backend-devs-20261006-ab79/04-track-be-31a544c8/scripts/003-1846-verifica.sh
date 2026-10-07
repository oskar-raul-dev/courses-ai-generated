# rescatado de la sesión 31a544c8, 2026-09-11T18:46:22Z · Verify template compliance and incident IDs
echo "=== IDs reservados ==="; grep -h "^| \*\*be-[0-9]" be0*.md | sed 's/|.*\*\*\(be-[0-9]*\)\*\*.*/\1/' | sort | tr '\n' ' '; echo
echo "=== secciones por fase ==="; for f in be0*.md; do printf "%-6s %s\n" "$(echo $f|cut -c1-4)" "$(grep -c '^## ' $f)"; done
echo "=== faltantes de plantilla ==="; for f in be0*.md; do for s in "1. Propósito" "2. Qué queda listo" "3. Qué NO entra" "4. Concepto mínimo" "5. " "6. Errores comunes" "7. Ejercicios" "8. Referencias" "9. Cierre" "📌 Pendientes"; do grep -q "^## .*$s" "$f" || echo "$f falta: $s"; done; done
