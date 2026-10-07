# rescatado de la sesión 5d4ed58d, 2026-09-10T02:25:44Z · Verify the systematic broken filename references
echo "=== historia-del-sistema.md (archivo real: 00-historia-del-sistema.md) ==="
grep -rn '`historia-del-sistema\.md`' --include="*.md" . | grep -v completado_ | head -20
echo
echo "=== alcance-del-proyecto.md (archivo real: 00-alcance-del-proyecto.md) ==="
grep -rn '`alcance-del-proyecto\.md`\|`ALCANCE-DEL-PROYECTO\.md`\|`Alcance-del-proyecto\.md`' --include="*.md" . | grep -v completado_ | head -20
echo
echo "=== DECISIONES-CONFIRMADAS ==="
grep -rn 'DECISIONES-CONFIRMADAS' --include="*.md" . | grep -v completado_
