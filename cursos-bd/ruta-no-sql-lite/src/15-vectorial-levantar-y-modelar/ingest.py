# La ingesta de vectorial (Fase 15): embebe los reportes de piloto con e5-small, guarda los vectores
# en un archivo junto al dataset —los mismos bytes para Qdrant y para pgvector (Fase 16)— y los
# carga en una colección de Qdrant con su payload.
#
#   uv run python 15-vectorial-levantar-y-modelar/ingest.py [--dataset lab/data/pirep-10k]
#          [--no-prefix] [--collection pirep] [--skip-load] [--force-index]
#                                         (desde src/, con el perfil vectorial arriba)
#
# Si el archivo de vectores ya existe y su hash coincide con su manifiesto, no se vuelve a embeber.
import argparse
import hashlib
import json
import os
import time
from pathlib import Path

import numpy as np
from qdrant_client import QdrantClient, models
from sentence_transformers import SentenceTransformer

E5 = "intfloat/multilingual-e5-small"
E5_REVISION = "614241f622f53c4eeff9890bdc4f31cfecc418b3"
DIMS = 384

parser = argparse.ArgumentParser()
parser.add_argument("--dataset", default="lab/data/pirep-10k")
parser.add_argument("--no-prefix", action="store_true", help="embebe sin 'passage: ' (la apuesta de F16)")
parser.add_argument("--collection", default=None)
parser.add_argument("--skip-load", action="store_true", help="solo embebe, no carga Qdrant")
parser.add_argument("--batch", type=int, default=128)
parser.add_argument("--force-index", action="store_true",
                    help="umbrales de 10 kB: construye el HNSW aunque la colección sea pequeña")
args = parser.parse_args()

dataset = Path(args.dataset)
manifest = json.loads((dataset / "manifest.json").read_text())


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# el mismo control que dataset.ts del arnés: si pirep.ndjson no es el del manifiesto, no se sigue
pireps_path = dataset / "pirep.ndjson"
if sha256(pireps_path) != manifest["files"]["pirep.ndjson"]["sha256"]:
    raise SystemExit(f"{pireps_path}: el hash no coincide con el manifiesto")
pireps = [json.loads(line) for line in pireps_path.open()]
print(f"dataset {manifest['focus']}-{manifest['volume']} ({manifest['datasetSha256'][:12]}…) · {len(pireps)} reportes")

prefix = "" if args.no_prefix else "passage: "
tag = "noprefix" if args.no_prefix else "passage"
vec_path = dataset / f"pirep-e5-{tag}.f32"
meta_path = dataset / f"pirep-e5-{tag}.json"

if vec_path.exists() and meta_path.exists() and sha256(vec_path) == json.loads(meta_path.read_text())["sha256"]:
    vectors = np.fromfile(vec_path, dtype="<f4").reshape(-1, DIMS)
    print(f"vectores: {vec_path.name} ya existe y coincide con su manifiesto, no se vuelve a embeber")
else:
    # CPU a propósito: es lo reproducible; mps es más rápido, pero no se verificó que dé los mismos bytes
    model = SentenceTransformer(E5, revision=E5_REVISION, device="cpu")
    start = time.perf_counter()
    vectors = model.encode([prefix + p["text"] for p in pireps], batch_size=args.batch,
                           normalize_embeddings=True, convert_to_numpy=True).astype("<f4")
    elapsed = time.perf_counter() - start
    vectors.tofile(vec_path)
    meta_path.write_text(json.dumps({
        "model": E5, "revision": E5_REVISION, "prefix": prefix, "normalized": True, "dtype": "float32-le",
        "dims": DIMS, "count": len(pireps), "order": "pirep.ndjson", "datasetSha256": manifest["datasetSha256"],
        "sha256": sha256(vec_path), "device": "cpu", "seconds": round(elapsed, 1),
    }, indent=2) + "\n")
    print(f"vectores: {len(pireps)} embebidos en {elapsed:.1f} s ({len(pireps) / elapsed:.0f} por segundo, CPU) → {vec_path.name}")

print(f"   {vectors.shape[0]} × {vectors.shape[1]} float32 = {vec_path.stat().st_size / 2**20:.1f} MiB en disco")
if args.skip_load:
    raise SystemExit(0)

collection = args.collection or ("pirep" if not args.no_prefix else "pirep_noprefix")
client = QdrantClient(url=f"http://localhost:{os.environ.get('VECTORIAL_HTTP_PORT', 16333)}", timeout=600)
client.delete_collection(collection)
# coseno, HNSW con los valores por defecto de Qdrant escritos a la vista: m = 16, ef_construct = 100
# Por debajo de indexing_threshold (10 000 kB por segmento) Qdrant no construye el HNSW y busca
# recorriendo el segmento; --force-index baja los dos umbrales para ver el índice con pocos puntos.
threshold = 10 if args.force_index else None  # 10 kB: el mínimo que Qdrant acepta
client.create_collection(collection, vectors_config=models.VectorParams(size=DIMS, distance=models.Distance.COSINE),
                         hnsw_config=models.HnswConfigDiff(m=16, ef_construct=100, full_scan_threshold=threshold),
                         optimizers_config=models.OptimizersConfigDiff(indexing_threshold=threshold) if threshold else None)
# índices de payload: sin ellos, filtrar por aeronave o por capítulo ATA recorre los payloads
client.create_payload_index(collection, "aircraft", models.PayloadSchemaType.KEYWORD)
client.create_payload_index(collection, "ataChapter", models.PayloadSchemaType.INTEGER)
start = time.perf_counter()
requests = 0
for i in range(0, len(pireps), 1000):
    chunk = pireps[i:i + 1000]
    client.upsert(collection, wait=True, points=models.Batch(
        ids=list(range(i, i + len(chunk))),
        vectors=vectors[i:i + len(chunk)].tolist(),
        payloads=[{"pirepId": p["pirepId"], "aircraft": p["aircraft"], "ataChapter": p["ataChapter"],
                   "reportedAt": p["reportedAt"], "text": p["text"]} for p in chunk],
    ))
    requests += 1
loaded = time.perf_counter() - start
# el HNSW se construye en segundo plano, después del upsert: se espera a que el optimizador termine
while (info := client.get_collection(collection)).status != models.CollectionStatus.GREEN:
    time.sleep(0.5)
print(f"qdrant: colección {collection} con {info.points_count} puntos en {requests} peticiones de 1000 ({loaded:.1f} s) · "
      f"{info.segments_count} segmentos · vectores en HNSW: {info.indexed_vectors_count} "
      f"(listo a los {time.perf_counter() - start:.1f} s)")
client.close()
