# rescatado de la sesión f803daaa, 2026-09-09T04:12:12Z · Test mongo java driver 3.8 against multiple server versions
cd /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad/labcore
echo "### driver Java 3.8.2 (el de 2019) contra cada version de servidor"
for tag in 4.0 4.2 4.4 5.0 6.0 7.0 8.0; do
  printf "mongo:%-4s " "$tag"
  MONGO_TAG=$tag docker compose down -v >/dev/null 2>&1
  MONGO_TAG=$tag docker compose up -d db >/dev/null 2>&1
  sleep 7
  MONGO_TAG=$tag docker compose run --rm -T api mvn -q exec:java 2>&1 | grep -E "OK |FALLA " | head -2
done
docker compose down -v >/dev/null 2>&1; echo "(limpieza hecha)"
