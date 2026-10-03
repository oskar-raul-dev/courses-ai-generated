# La línea base de la Fase 16: carga en pgvector los mismos vectores que Qdrant, desde el archivo
# que escribió ingest.py (Fase 15), y construye el HNSW con los mismos parámetros (m 16,
# ef_construction 100). No vuelve a embeber: si el hash del archivo no coincide, no carga nada.
#
#   uv run python 16-vectorial-romper-y-medir/load_pgvector.py [--dataset lab/data/pirep-1m]
#          [--vectors passage] [--table pirep_embedding] [--maintenance-work-mem 2GB] [--halfvec]
#                                                      (desde src/, con el perfil base arriba)
import argparse
import hashlib
import json
import os
import time
from pathlib import Path

import numpy as np
import psycopg

parser = argparse.ArgumentParser()
parser.add_argument("--dataset", default="lab/data/pirep-1m")
parser.add_argument("--vectors", default="passage", help="passage o noprefix")
parser.add_argument("--table", default="pirep_embedding")
parser.add_argument("--maintenance-work-mem", default="2GB")
parser.add_argument("--halfvec", action="store_true", help="índice sobre halfvec: la mitad de bytes por dimensión")
parser.add_argument("--skip-load", action="store_true", help="solo reconstruye el índice")
args = parser.parse_args()

dataset = Path(args.dataset)
meta = json.loads((dataset / f"pirep-e5-{args.vectors}.json").read_text())
vec_path = dataset / f"pirep-e5-{args.vectors}.f32"
h = hashlib.sha256()
with vec_path.open("rb") as f:
    for chunk in iter(lambda: f.read(1 << 20), b""):
        h.update(chunk)
if h.hexdigest() != meta["sha256"]:
    raise SystemExit(f"{vec_path}: el hash no coincide con su manifiesto")
vectors = np.fromfile(vec_path, dtype="<f4").reshape(-1, meta["dims"])
pireps = [json.loads(line) for line in (dataset / "pirep.ndjson").open()]
assert len(pireps) == len(vectors)
print(f"{vec_path.name}: {len(vectors)} × {meta['dims']} ({meta['sha256'][:12]}…), prefijo {meta['prefix']!r}")

dsn = f"host=localhost port={os.environ.get('BASE_PORT', 15432)} user=postgres password=condor dbname=postgres"
with psycopg.connect(dsn, autocommit=True) as conn:
    conn.execute("CREATE EXTENSION IF NOT EXISTS vector")
    if not args.skip_load:
        conn.execute(f"DROP TABLE IF EXISTS {args.table}")
        # la aeronave y el capítulo van en la misma fila: el filtro es un WHERE en la misma consulta
        conn.execute(f"""CREATE TABLE {args.table} (id int PRIMARY KEY, pirep_id text NOT NULL, aircraft text NOT NULL,
                         ata_chapter int NOT NULL, embedding vector({meta['dims']}) NOT NULL)""")
        start = time.perf_counter()
        with conn.cursor() as cur, cur.copy(f"COPY {args.table} FROM STDIN") as copy:
            for i, (p, v) in enumerate(zip(pireps, vectors)):
                # 9 cifras significativas: el float32 vuelve exacto al parsearlo (los mismos bytes)
                copy.write_row((i, p["pirepId"], p["aircraft"], p["ataChapter"], "[" + ",".join(f"{x:.9g}" for x in v) + "]"))
        conn.execute(f"CREATE INDEX ON {args.table} (aircraft)")
        conn.execute(f"VACUUM ANALYZE {args.table}")
        print(f"cargados {len(pireps)} en {time.perf_counter() - start:.0f} s con COPY · tabla {conn.execute(f'SELECT pg_size_pretty(pg_table_size(%s))', (args.table,)).fetchone()[0]}")
    expr, ops, name = ((f"(embedding::halfvec({meta['dims']}))", "halfvec_cosine_ops", "hnsw_half") if args.halfvec
                       else ("(embedding)", "vector_cosine_ops", "hnsw_passage"))
    # solo se reconstruye el índice pedido: el de float32 y el de halfvec conviven
    conn.execute(f"DROP INDEX IF EXISTS {args.table}_{name}")
    conn.execute(f"SET maintenance_work_mem = '{args.maintenance_work_mem}'")
    notices: list[str] = []
    conn.add_notice_handler(lambda d: notices.append(d.message_primary))
    start = time.perf_counter()
    conn.execute(f"CREATE INDEX {args.table}_{name} ON {args.table} USING hnsw ({expr} {ops}) WITH (m = 16, ef_construction = 100)")
    size = conn.execute("SELECT pg_size_pretty(pg_relation_size(%s))", (f"{args.table}_{name}",)).fetchone()[0]
    print(f"HNSW {name} (maintenance_work_mem {args.maintenance_work_mem}): {time.perf_counter() - start:.0f} s · {size}")
    for n in notices:
        print(f"   NOTICE: {n}")
