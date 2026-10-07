# rescatado de la sesión 70a2da9f, 2026-09-10T22:07:05Z · Check whether the broken links pre-date the edits
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs
echo "=== ¿los 3 enlaces sin ../ son previos? ==="
for f in prompts/plantillas-de-capitulo.md prompts/guia-de-estilo-y-convenciones.md; do
  echo -n "$f en HEAD: "; git show HEAD:angular-8-legacy-for-backend-devs/$f | grep -c "](00-convencion-de-git-y-tags.md"
done
echo
echo "=== diff resumido ==="
cd .. && git diff --stat -- angular-8-legacy-for-backend-devs
