# rescatado de la sesión 8654ffa2, 2026-09-09T02:37:54Z · Check section 6 headers across both courses
echo "=== Curso 01: seccion 6 real ===" && for f in 01-vue2-legacy/0[0-9]*.md 01-vue2-legacy/1[01]*.md 01-vue2-legacy/[qvn][0-9x]*.md; do printf '%-42s ' "$(basename $f)"; grep -o '^## ⚠️.*' "$f" | head -1; done
echo; echo "=== Curso 02: seccion 6 real ===" && for f in 02-complement-mongodb-backend/[0-9]*.md; do printf '%-46s ' "$(basename $f)"; grep -o '^## ⚠️.*' "$f" | head -1; done
echo; echo "=== forense/incidente en curso 02 ===" && grep -rn -i 'forense\|cuaderno de incidentes' 02-complement-mongodb-backend/*.md | head -20
