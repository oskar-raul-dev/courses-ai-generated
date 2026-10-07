# rescatado de la sesión 70a2da9f, 2026-09-10T22:09:46Z · Check whether both plans were executed
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== angular-8 forense:"; ls angular-8-legacy-for-backend-devs/forense-*.md | wc -l; ls angular-8-legacy-for-backend-devs/prompts/formato-piezas-forenses.md
echo "=== react-16:"; ls react-16-legacy-for-backend-devs/ | grep -i "forense" ; echo "--- prompts:"; ls react-16-legacy-for-backend-devs/prompts/ 2>/dev/null | grep -i forense
echo "=== react-16 alcance §6/§7 sobre track forense:"; grep -n -i "forense" react-16-legacy-for-backend-devs/00-alcance-del-proyecto.md | head -20
