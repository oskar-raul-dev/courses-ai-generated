#!/usr/bin/env bash
# be-11 (diff vacío, desde fase-be06): la rueda 1 cierra en 30 minutos y el navegador va una hora adelante (cy.clock).
# Requiere la consola y Go en el 3001 (trabajo/levantar-go-3001.sh). Uso: trabajo/incidentes/be11-cypress.sh
Z="$(cd "$(dirname "$0")/../.." && pwd)"
PSQL="docker exec r16t7-pg psql -U esclusa -d esclusa -Atc"
$PSQL "DELETE FROM grants WHERE case_id = 'C-BE11'; UPDATE wheels SET closes_at = now() + interval '30 minutes' WHERE id = 1 RETURNING 'la rueda 1 cierra a las ' || closes_at"
docker run --rm --label curso=react16 --network container:r16t7-app -v "$Z/trabajo/recorrido":/e2e -w /e2e \
  cypress/included:10.11.0 --spec cypress/e2e/be11-reloj.cy.js 2>&1 | grep -E "passing|failing|AssertionError|✓|[0-9]\)"
cat "$Z/trabajo/recorrido/salida/be11.json"; echo
$PSQL "SELECT 'envío anotado: ' || case_id || ' ' || prize FROM grants WHERE case_id = 'C-BE11'"
$PSQL "UPDATE wheels SET closes_at = '2030-12-31T20:00:00-05:00' WHERE id = 1"
