# rescatado de la sesión 8654ffa2, 2026-09-09T04:24:12Z · Final verification of P2
echo "=== voseo en los 5 archivos ===" && grep -nE '\b(tenés|querés|podés|hacés|sabés|debés|mirá|fijate|andá|poné|agregá|vos)\b' prompts/guia-de-estilo-y-convenciones.md prompts/plantilla-de-fase.md prompts/convencion-de-git-y-tags.md prompts/formato-*.md | head
echo "=== archivos citados en lo nuevo de la guía ==="
for f in prompts/formato-piezas-forenses.md prompts/formato-cuaderno-incidentes.md prompts/convencion-de-git-y-tags.md; do [ -f "$f" ] && echo "OK  $f"; done
echo "=== §16 y §9.2 presentes ===" && grep -n '9.2 La pieza forense\|## 16. El track forense' prompts/guia-de-estilo-y-convenciones.md
echo "=== checklist §15: items nuevos ===" && sed -n '/Lleva el bloque 🏷️ del tag/,/ninguno se reasignó/p' prompts/guia-de-estilo-y-convenciones.md
echo "=== diff resumido ===" && git diff --stat .
