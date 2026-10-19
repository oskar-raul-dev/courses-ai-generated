#!/bin/sh
# Reconstruye las tablas f20_* de staging antes de cada corrida del arnés (el arnés escribe en staging).
set -e
cd "$(dirname "$0")/../../../cursos-bd/ruta-sql/src/20-la-propuesta-de-florencia"
docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda -q -v ON_ERROR_STOP=1 < 01_muestra.sql > /dev/null
docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda -q -v ON_ERROR_STOP=1 < 03_jsonb.sql > /dev/null
echo "estado f20 reiniciado"
