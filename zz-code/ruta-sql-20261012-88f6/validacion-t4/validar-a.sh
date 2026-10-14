#!/usr/bin/env bash
# Validación del cierre de T0–T4: los números de a05, F01, F03 y F04 sobre la carga actual.
cd "$(dirname "$0")/.."
P=(docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda)
echo "== a05/F01"
"${P[@]}" -At -c "SELECT profile, left(sha256,12), (SELECT count(*) FROM legacy.\"Pacientes\"), (SELECT count(*) FROM legacy.\"Protocolos\"), (SELECT count(*) FROM legacy.\"ResultadoItem\") FROM lab.loaded ORDER BY loaded_at DESC LIMIT 1"
"${P[@]}" -At -c "SELECT count(*) FROM legacy.\"Pacientes\" WHERE \"Nombre\" LIKE '%DNI%'"
"${P[@]}" -c "EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM legacy.\"Protocolos\" WHERE \"NroProtocolo\" = 'C-0048213'" | grep -m1 Buffers
echo "== F03"
for f in ../../cursos-bd/ruta-sql/src/03-*/*.sql; do echo "-- $(basename "$f")"; "${P[@]}" < "$f" 2>&1 | tail -6; done
echo "== F04"
"${P[@]}" -At -c "SELECT count(*) FROM (SELECT \"DNI\" FROM legacy.\"Pacientes\" WHERE \"DNI\" IS NOT NULL GROUP BY 1 HAVING count(DISTINCT \"Nombre\") > 1) d"
"${P[@]}" -At -c "SELECT count(*) FILTER (WHERE staging.extract_dni_2016(p.\"Nombre\") = c.expected_dni) FROM truth.parser_case c JOIN legacy.\"Pacientes\" p ON p.\"IdPaciente\"=c.legacy_patient_id"
"${P[@]}" -c "SELECT * FROM staging.rejection_report"
