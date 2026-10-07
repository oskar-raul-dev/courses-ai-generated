# rescatado de la sesión 51943195, 2026-09-10T00:39:01Z · Count symptom rows and read C02 master head
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
echo "=== filas tabla sintomas C01 ==="; awk '/^## 3\./,/^## 4\./' 01-vue2-legacy/forense-master.md | grep -c '^| '
echo "=== fases citadas en la tabla C01 ==="; awk '/^## 3\./,/^## 4\./' 01-vue2-legacy/forense-master.md | grep -o 'Fase [0-9]*' | sort -u -V
echo; cat 02-complement-mongodb-backend/forense-master.md | sed -n '1,60p'
