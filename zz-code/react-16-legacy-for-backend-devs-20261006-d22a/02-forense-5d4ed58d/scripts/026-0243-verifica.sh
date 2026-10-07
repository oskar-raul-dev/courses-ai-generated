# rescatado de la sesión 5d4ed58d, 2026-09-10T02:43:58Z · Check hour budget consistency across documents
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "=== ¿las cifras de horas coinciden entre documentos? ==="
grep -rn "96 h\|96 horas\|84 h\|84 horas" --include="*.md" . | grep -v completado_ | sed 's/:.*\(9[0-9] h\|9[0-9] horas\|84 h\|84 horas\)/ → \1/' | head -20
echo
echo "=== reparto por fase: ¿dónde vive? ==="
grep -rn "^| *0[0-9] *|.*h *|" --include="*.md" 00-alcance-del-proyecto.md prompts/*.md 2>/dev/null | head -8
grep -n "horas" 00-alcance-del-proyecto.md | head -8
