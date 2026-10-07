# rescatado de la sesión 8654ffa2, 2026-09-09T04:15:04Z · Verify links and package git status
for f in prompts/guia-de-estilo-y-convenciones.md prompts/convencion-de-git-y-tags.md prompts/formato-piezas-forenses.md 02-complement-mongodb-backend/00-audit-contrato.md; do [ -f "$f" ] && echo "OK  $f" || echo "FALTA $f"; done
echo; echo "=== git status del paquete ===" && git status --short . 
echo; echo "=== secciones ===" && grep -c '^## ' prompts/formato-piezas-forenses.md prompts/formato-cuaderno-incidentes.md
