# rescatado de la sesión 5d4ed58d, 2026-09-10T02:44:08Z · Check whether per-phase hours exist and conflict
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "=== ¿alguna fase declara sus propias horas? ==="
grep -rnoE "\*\*[0-9]{1,2} ?(h|horas)\*\*|\b[0-9]{1,2} horas\b" --include="*.md" 0*.md 1*.md be0*.md | grep -v "96\|84\|veinte minutos" | head -20
echo
echo "=== ¿existe un reparto por fase en algún documento? ==="
grep -rn "reparto\|horas por fase\|presupuesto" --include="*.md" 00-alcance-del-proyecto.md prompts/instrucciones-del-proyecto.md prompts/propuesta-fases-backend.md | head -10
