# rescatado de la sesión 51943195, 2026-09-10T00:40:23Z · Spot-check symptom sourcing in course 01
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "--F0 EADDRINUSE/version mismatch--"; grep -n "EADDRINUSE\|version mismatch\|Volar\|Vetur" 00-setup-hola-mundo.md | head
echo "--F5 error/invalid--"; grep -n '\$error\|\$invalid\|\$touch' 05-crud-tickets.md | head -5
echo "--F7 canvas--"; grep -n "Canvas is already in use\|destroy()" 07-metricas-minimas.md | head -4
echo "--F10 strict prod--"; grep -n "strict" 10-vuex-a-fondo.md | head -8
echo "--strict en rutas Q--"; grep -rn "strict" q*.md | head -5
echo "--X-Total-Count--"; grep -rln "X-Total-Count" *.md
