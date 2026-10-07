# rescatado de la sesión 8654ffa2, 2026-09-09T02:38:08Z · Check incident conventions and chaos support
echo "=== §14 git convention incidentes ===" && sed -n '172,210p' prompts/convencion-de-git-y-tags.md
echo; echo "=== plantilla-de-fase seccion 6 ===" && sed -n '99,118p' prompts/plantilla-de-fase.md
echo; echo "=== 03-mock-api-minima: caos? ===" && grep -n -i 'caos\|chaos\|latenc\|fallo simulado\|malformed\|timeout' 01-vue2-legacy/03-mock-api-minima.md | head -20
echo; echo "=== angular-16 prompts ===" && ls ../angular-16-legacy-for-backend-devs/prompts/
