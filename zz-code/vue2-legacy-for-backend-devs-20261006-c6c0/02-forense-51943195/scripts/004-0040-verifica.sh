# rescatado de la sesión 51943195, 2026-09-10T00:40:04Z · Extract common errors of phases 1,2,4,7
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "### F01"; sed -n '405,470p' 01-estructura-base-legacy.md | grep -E '^\*\*|^\| |^[0-9]+\.' | head -20
echo "### F02"; sed -n '511,580p' 02-autenticacion-minima.md | grep -E '^\*\*|^\| |^[0-9]+\.' | head -20
echo "### F04"; sed -n '710,780p' 04-dashboard-tickets.md | grep -E '^\*\*|^\| |^[0-9]+\.' | head -20
echo "### F07"; sed -n '715,790p' 07-metricas-minimas.md | grep -E '^\*\*|^\| |^[0-9]+\.' | head -20
