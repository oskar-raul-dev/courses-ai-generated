# rescatado de la sesión 51943195, 2026-09-10T01:48:39Z · Verify checklist state in react course
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "== incidentes en cuaderno base =="; grep -c "^## Incidente" cuaderno-incidentes.md
echo "== incidentes BE =="; grep -c "^## Incidente" cuaderno-incidentes-be.md 2>/dev/null
echo "== indice sintomas =="; grep -rn "🩺" cuaderno-incidentes.md cuaderno-incidentes-be.md | head
echo "== plantilla =="; ls prompts/ ; echo "== referencias al doc =="; grep -rln "completado_cuaderno_incidentes" --include="*.md" .
echo "== hueco en README/guia =="; grep -n "no están redactados\|hueco\|⚠️.*redact" README.md prompts/guia-de-estilo-y-convenciones.md | head
