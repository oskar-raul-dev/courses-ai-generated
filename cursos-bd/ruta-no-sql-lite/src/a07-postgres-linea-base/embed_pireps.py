# pgvector en la línea base (a07): embebe los primeros N reportes de piloto con e5-small y los
# guarda en Postgres, para comparar HNSW con IVFFlat contra la búsqueda exacta.
#
#   uv run python a07-postgres-linea-base/embed_pireps.py [N]      (desde src/, con base cargada)
import os
import sys

import psycopg
from sentence_transformers import SentenceTransformer

E5 = "intfloat/multilingual-e5-small"
E5_REVISION = "614241f622f53c4eeff9890bdc4f31cfecc418b3"
n = int(sys.argv[1]) if len(sys.argv) > 1 else 2000

model = SentenceTransformer(E5, revision=E5_REVISION, device="cpu")
dsn = f"host=localhost port={os.environ.get('BASE_PORT', 15432)} user=postgres password=condor dbname=postgres"
with psycopg.connect(dsn) as conn:
    conn.execute("CREATE EXTENSION IF NOT EXISTS vector")
    conn.execute("DROP TABLE IF EXISTS pirep_embedding")
    conn.execute("CREATE TABLE pirep_embedding (pirep_id text PRIMARY KEY REFERENCES pirep, embedding vector(384) NOT NULL)")
    rows = conn.execute("SELECT pirep_id, text FROM pirep ORDER BY pirep_id LIMIT %s", (n,)).fetchall()
    # e5 exige el prefijo: "passage:" para lo que se guarda, "query:" para lo que se busca
    vectors = model.encode([f"passage: {t}" for _, t in rows], normalize_embeddings=True, batch_size=64)
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO pirep_embedding VALUES (%s, %s::vector)",
            [(pid, "[" + ",".join(f"{x:.6f}" for x in v) + "]") for (pid, _), v in zip(rows, vectors)],
        )
    q = model.encode("query: ruido metalico al bajar tren", normalize_embeddings=True)
    with open(os.path.join(os.path.dirname(__file__), "query-vector.txt"), "w") as f:
        f.write("[" + ",".join(f"{x:.6f}" for x in q) + "]")
    print(f"{len(rows)} reportes embebidos · 384 dimensiones")
