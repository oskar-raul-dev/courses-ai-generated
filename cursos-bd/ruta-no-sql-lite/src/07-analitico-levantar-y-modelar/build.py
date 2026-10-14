# Construye la base analítica de Cóndor en DuckDB a partir del dataset canónico de a05, y deja el
# CSV de las lecturas que carga Postgres: los mismos bytes en los dos motores.
#
#   uv run python 07-analitico-levantar-y-modelar/build.py [--dataset lab/data/reading-5m] [--copies 10]
#                                                          (desde src/)
#
# Escribe en lab/data/analitico/ (ignorado por git; se regenera con este mismo comando):
#   condor.duckdb      la base: aircraft, work_order, reading y reading_x10 (la ampliación)
#   reading.csv        las lecturas tal como las carga Postgres, con su SHA-256 en reading.csv.sha256
#   reading.parquet    las mismas lecturas en Parquet, para consultarlas sin cargarlas
import argparse
import hashlib
import json
import time
from pathlib import Path

import duckdb

parser = argparse.ArgumentParser()
parser.add_argument("--dataset", default="lab/data/reading-5m")
parser.add_argument("--copies", type=int, default=10)
args = parser.parse_args()

dataset = Path(args.dataset)
out = Path("lab/data/analitico")
out.mkdir(parents=True, exist_ok=True)


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# antes de cargar nada, el dataset tiene que ser el del curso (a05)
manifest = json.loads((dataset / "manifest.json").read_text())
for name in ("aircraft.ndjson", "workOrder.ndjson", "reading.ndjson"):
    if sha256(dataset / name) != manifest["files"][name]["sha256"]:
        raise SystemExit(f"{name}: el hash no coincide con el manifiesto; regenera el dataset (a05)")
print(f"dataset {dataset} · datasetSha256 {manifest['datasetSha256'][:12]}… verificado")

db = out / "condor.duckdb"
db.unlink(missing_ok=True)
con = duckdb.connect(str(db))
# todos los instantes del dataset están en UTC; la base también
con.execute("SET TimeZone = 'UTC'")

started = time.time()
con.execute(f"""
    CREATE TABLE aircraft AS
    SELECT registration, model, kind, operatorId AS operator_id, country,
           hasFlightRecorder AS has_flight_recorder, continuousWingContract AS continuous_wing_contract
    FROM read_json('{dataset}/aircraft.ndjson')
""")
# las órdenes, sin sus arrays: aquí solo interesan sus costos
con.execute(f"""
    CREATE TABLE work_order AS
    SELECT workOrderId AS work_order_id, aircraft, hangarId AS hangar_id, type,
           openedAt AS opened_at, closedAt AS closed_at, laborHours::INTEGER AS labor_hours,
           laborCostUsd::DECIMAL(12, 2) AS labor_cost_usd, partsCostUsd::DECIMAL(12, 2) AS parts_cost_usd
    FROM read_json('{dataset}/workOrder.ndjson')
""")
# una lectura por minuto de vuelo; los tipos, declarados, para que sean los mismos que en Postgres
con.execute(f"""
    CREATE TABLE reading AS
    SELECT aircraft, flightId AS flight_id, ts, altitudeFt AS altitude_ft, iasKt AS ias_kt, egtC AS egt_c,
           n1Pct AS n1_pct, oilPressPsi AS oil_press_psi, oilTempC AS oil_temp_c, fuelFlowPph AS fuel_flow_pph
    FROM read_json('{dataset}/reading.ndjson', columns = {{
        aircraft: 'VARCHAR', flightId: 'VARCHAR', ts: 'TIMESTAMP', altitudeFt: 'INTEGER', iasKt: 'INTEGER',
        egtC: 'INTEGER', n1Pct: 'INTEGER', oilPressPsi: 'INTEGER', oilTempC: 'INTEGER', fuelFlowPph: 'INTEGER'}})
""")
print(f"cargado en DuckDB: {time.time() - started:.1f} s")

# la ampliación sintética, sin azar: cada copia k > 0 es otra aeronave (matrícula con ~k) que voló
# exactamente lo mismo. Postgres hace la misma operación con generate_series, y se comprueba que
# los dos resultados coinciden (fingerprint.sql).
started = time.time()
con.execute(f"""
    CREATE TABLE reading_x10 AS
    SELECT CASE WHEN k = 0 THEN aircraft ELSE aircraft || '~' || k END AS aircraft,
           CASE WHEN k = 0 THEN flight_id ELSE flight_id || '~' || k END AS flight_id,
           ts, altitude_ft, ias_kt, egt_c, n1_pct, oil_press_psi, oil_temp_c, fuel_flow_pph
    FROM range(0, {args.copies}) AS copies(k), reading
    ORDER BY k, aircraft, ts
""")
print(f"ampliado ×{args.copies}: {con.sql('SELECT count(*) FROM reading_x10').fetchone()[0]} lecturas, {time.time() - started:.1f} s")

csv = out / "reading.csv"
con.execute(f"COPY (SELECT * FROM reading ORDER BY aircraft, ts) TO '{csv}' (HEADER false)")
(out / "reading.csv.sha256").write_text(f"{sha256(csv)}  reading.csv\n")
con.execute(f"COPY (SELECT * FROM reading ORDER BY aircraft, ts) TO '{out}/reading.parquet' (FORMAT parquet)")
con.execute("CHECKPOINT")
con.close()
for name in ("condor.duckdb", "reading.csv", "reading.parquet"):
    print(f"  {name:16} {(out / name).stat().st_size / 2**20:8.1f} MiB")
print(f"  reading.csv sha256 {(out / 'reading.csv.sha256').read_text().split()[0]}")
