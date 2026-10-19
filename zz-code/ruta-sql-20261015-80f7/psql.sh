#!/bin/sh
# psql del laboratorio: lee SQL de un archivo o de stdin
docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda -X -q -v ON_ERROR_STOP=1 "$@"
