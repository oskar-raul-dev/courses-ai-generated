# Sondeo: lo que lee DuckDB de un Parquet, y lo que dice el pie del archivo.
import duckdb, json
P = 'lab/data/analitico/reading.parquet'
c = duckdb.connect()
print(c.sql(f"SELECT count(*) row_groups, sum(num_rows) FROM (SELECT DISTINCT row_group_id, row_group_num_rows num_rows FROM parquet_metadata('{P}'))"))
print(c.sql(f"SELECT path_in_schema, any_value(compression), sum(total_compressed_size) comp, sum(total_uncompressed_size) unc FROM parquet_metadata('{P}') GROUP BY 1 ORDER BY 1"))
for q in [f"SELECT max(aircraft),max(flight_id),max(ts),max(altitude_ft),max(ias_kt),max(egt_c),max(n1_pct),max(oil_press_psi),max(oil_temp_c),max(fuel_flow_pph) FROM '{P}'",
          f"SELECT aircraft, avg(egt_c), avg(fuel_flow_pph) FROM '{P}' GROUP BY aircraft",
          f"SELECT count(*) FROM '{P}' WHERE egt_c = -1",
          f"SELECT avg(egt_c) FROM '{P}' WHERE aircraft = 'HK-4207'",
          f"SELECT aircraft, avg(egt_c), avg(fuel_flow_pph) FROM read_json('lab/data/reading-5m/reading.ndjson') GROUP BY aircraft",
          f"SELECT aircraft, avg(egt_c), avg(fuel_flow_pph) FROM read_csv('lab/data/analitico/reading.csv') GROUP BY aircraft"]:
    c = duckdb.connect()
    j = json.loads(c.sql("EXPLAIN (ANALYZE, FORMAT json) " + q).fetchall()[0][1])
    print(j.get("total_bytes_read"), j.get("cumulative_rows_scanned"), round(j.get("latency"),3), q[:90])
