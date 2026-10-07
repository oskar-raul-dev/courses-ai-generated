# rescatado de la sesión 31a544c8, 2026-09-12T02:18:57Z · Check Dockerfile pin and BE tag naming
echo "=== Fase 13: imagen base del Dockerfile (la 🪦 de la Fase 0 exigía 18.18.2) ==="
grep -n "node:18" 13-build-despliegue.md 14-casi-prod-kind.md a09-docker-kubernetes.md a12-arm64-m1.md 2>/dev/null | cut -c1-110
echo
echo "=== tags BE: el bloque 🏷️ usa be-fase-NN + slug del archivo ==="
for f in be0*.md; do
  slug="be-fase-${f#be}"; slug="be-fase-$(echo "$f" | sed 's/^be\([0-9][0-9]\)-\(.*\)\.md$/\1-\2/')"
  if grep -q "git tag -a $slug" "$f"; then echo "  OK  $f → $slug"; else echo "  ❌ $f: esperado '$slug'"; grep -o "git tag -a [a-z0-9-]*" "$f" | head -1; fi
done
