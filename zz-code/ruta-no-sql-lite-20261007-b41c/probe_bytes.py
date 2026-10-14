# Sondeo: total_bytes_read del perfilador, en frío (conexión nueva) y en caliente (misma conexión).
import duckdb, json
QS = ["SELECT avg(egt_c) FROM reading_x10",
      "SELECT aircraft, avg(egt_c), avg(fuel_flow_pph) FROM reading_x10 GROUP BY aircraft",
      "SELECT aircraft, flight_id, ts, altitude_ft, ias_kt, egt_c, n1_pct, oil_press_psi, oil_temp_c, fuel_flow_pph FROM reading_x10 WHERE egt_c = -1",
      "SELECT avg(egt_c) FROM reading_x10 WHERE aircraft = 'HK-4207'"]
for q in QS:
    c = duckdb.connect('lab/data/analitico/condor.duckdb', read_only=True)
    out = []
    for i in range(2):
        j = json.loads(c.sql("EXPLAIN (ANALYZE, FORMAT json) " + q).fetchall()[0][1])
        out.append((j.get("total_bytes_read"), j.get("cumulative_rows_scanned")))
    print(out, q[:70])
    c.close()
