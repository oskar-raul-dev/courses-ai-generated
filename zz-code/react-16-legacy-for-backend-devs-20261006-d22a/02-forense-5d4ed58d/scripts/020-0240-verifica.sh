# rescatado de la sesión 5d4ed58d, 2026-09-10T02:40:07Z · Verify actual state of the notebook and plan file
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "== incidentes redactados =="; grep -c "^## Incidente " cuaderno-incidentes.md
echo "== placeholders {{Título / {{... =="; grep -n "^## Incidente .*{{" cuaderno-incidentes.md || echo "  ninguno"
echo "== líneas del cuaderno =="; wc -l < cuaderno-incidentes.md
echo "== índice 🩺 =="; grep -c "🩺 Entrar por el síntoma" cuaderno-incidentes.md cuaderno-incidentes-be.md
echo "== README: ¿sigue el callout del hueco? =="; grep -c "todavía no están" README.md || echo "  0"
echo "== guía §15 =="; grep -n "cuaderno de incidentes está vacío" prompts/guia-de-estilo-y-convenciones.md
echo "== plantilla =="; wc -l < prompts/plantilla-de-incidente.md
echo "== git: ¿alguien más tocó el plan? =="; git log --oneline -3 -- completado_cuaderno_incidentes.md 2>/dev/null || echo "  sin historial (untracked)"
echo "== mtime de los archivos clave =="; ls -lT completado_cuaderno_incidentes.md cuaderno-incidentes.md 2>/dev/null | awk '{print $6,$7,$8,$9,$10}'
