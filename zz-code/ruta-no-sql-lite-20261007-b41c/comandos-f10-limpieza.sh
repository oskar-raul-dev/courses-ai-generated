# F10: reading_tiny quedó con 7573 chunks y DROP TABLE falla con "out of shared memory".
# Se borra por tandas con drop_chunks (un mes por transacción) y después la tabla. Desde src/.
for y in 2022 2023 2024 2025 2026 2027; do for m in 01 04 07 10; do
  docker compose -f lab/compose.yaml exec -T series psql -U postgres -d condor -Atc "SELECT count(*) FROM drop_chunks('reading_tiny', older_than => TIMESTAMP '$y-$m-01')"
done; done
docker compose -f lab/compose.yaml exec -T series psql -U postgres -d condor -c "DROP TABLE reading_tiny"
docker compose -f lab/compose.yaml exec -T base psql -U postgres -d series_base -c "CREATE TABLE reading_part_2026_10 PARTITION OF reading_part FOR VALUES FROM ('2026-10-01') TO ('2026-11-01')"
