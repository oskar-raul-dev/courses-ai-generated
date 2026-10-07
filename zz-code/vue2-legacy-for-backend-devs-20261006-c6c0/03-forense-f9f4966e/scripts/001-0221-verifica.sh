# rescatado de la sesión f9f4966e, 2026-09-10T02:21:23Z · Count phases, pieces and incidents
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
echo "tronco C01:"; ls 01-vue2-legacy/[0-9][0-9]-*.md | wc -l
echo "ruta C01:"; ls 01-vue2-legacy/{q,vu,nx}[0-9]-*.md | wc -l
echo "fases C02:"; ls 02-complement-mongodb-backend/[0-9][0-9]-*.md | grep -v audit | wc -l
echo "piezas totales:"; ls 0*/forense-*.md | wc -l
grep -c "^## Incidente" 01-vue2-legacy/cuaderno-incidentes.md 02-complement-mongodb-backend/cuaderno-incidentes.md
