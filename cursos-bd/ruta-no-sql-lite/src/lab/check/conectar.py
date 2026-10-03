# Lo que el curso hace en Python: DuckDB embebido (F07–F08), y en vectorial (F15–F16) los
# embeddings con e5-small y la carga en Qdrant. Conecta, pregunta la versión y cierra.
#
#   uv run python lab/check/conectar.py        (desde src/)
import os
import time

import duckdb
import psycopg
from qdrant_client import QdrantClient
from sentence_transformers import SentenceTransformer

E5 = "intfloat/multilingual-e5-small"
E5_REVISION = "614241f622f53c4eeff9890bdc4f31cfecc418b3"  # la verificada en la sesión de laboratorio


def check(family, driver, fn):
    start = time.perf_counter()
    try:
        print(f"✅ {family:<12} {driver:<34} {fn()}  ({round((time.perf_counter() - start) * 1000)} ms)")
    except Exception as e:  # el mensaje literal es lo que va a a09
        print(f"❌ {family:<12} {driver:<34} {type(e).__name__}: {str(e).splitlines()[0]}")


def analitico():
    # embebido: no hay servidor, la base es un archivo (o memoria) dentro de este proceso
    with duckdb.connect() as con:
        return f"DuckDB {con.execute('SELECT version()').fetchone()[0]}"


def base():
    port = int(os.environ.get("BASE_PORT", 15432))
    with psycopg.connect(f"host=localhost port={port} user=postgres password=condor dbname=postgres") as conn:
        return conn.execute("SELECT version()").fetchone()[0].split(" on ")[0]


def vectorial():
    client = QdrantClient(url=f"http://localhost:{os.environ.get('VECTORIAL_HTTP_PORT', 16333)}")
    try:
        return f"Qdrant {client.info().version}"
    finally:
        client.close()


def embeddings():
    model = SentenceTransformer(E5, revision=E5_REVISION, device="cpu")
    vector = model.encode("query: ruido metalico al bajar tren", normalize_embeddings=True)
    return f"{E5}@{E5_REVISION[:8]} · {vector.shape[0]} dimensiones"


check("analitico", f"duckdb {duckdb.__version__}", analitico)
check("base", f"psycopg {psycopg.__version__}", base)
check("vectorial", "qdrant-client", vectorial)
check("embeddings", "sentence-transformers", embeddings)
