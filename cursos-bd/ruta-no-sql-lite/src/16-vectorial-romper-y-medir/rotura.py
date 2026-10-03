# El punto de rotura de la Fase 16 en Qdrant: el millón de vectores con la memoria del contenedor
# cada vez más limitada, en tres configuraciones —todo en RAM (la de fábrica), vectores e índice en
# disco, y cuantización int8—, con el recall y los fallos de página mayores (lecturas de
# disco) de cada una. Usa un contenedor desechable, condor-lab-rotura en el puerto 16391: la
# colección del laboratorio no se toca.
#
#   uv run python 16-vectorial-romper-y-medir/rotura.py [--dataset lab/data/pirep-1m] [--limits 1g,512m,256m]
#                                                      (desde src/; tarda cerca de una hora)
import argparse
import json
import subprocess
import time
from pathlib import Path

import numpy as np
from qdrant_client import QdrantClient, models
from sentence_transformers import SentenceTransformer

parser = argparse.ArgumentParser()
parser.add_argument("--dataset", default="lab/data/pirep-1m")
parser.add_argument("--limits", default="1g,512m,256m")
# binary también existe, pero en la verificación su carga agotó la espera del cliente (Fase 16, §5.1)
parser.add_argument("--variants", default="ram,disk,int8")
parser.add_argument("--queries", type=int, default=100)
args = parser.parse_args()
IMAGE = "qdrant/qdrant@sha256:12364fe851b9f17356fc88189fc06d1b521262e04659ec7345975b00c9246a10"
NAME, PORT = "condor-lab-rotura", 16391
url = f"http://localhost:{PORT}"

dataset = Path(args.dataset)
vectors = np.fromfile(dataset / "pirep-e5-passage.f32", dtype="<f4").reshape(-1, 384)
pireps = [json.loads(line) for line in (dataset / "pirep.ndjson").open()]
picks = [i * len(pireps) // args.queries + 7 for i in range(args.queries)]
model = SentenceTransformer("intfloat/multilingual-e5-small", revision="614241f622f53c4eeff9890bdc4f31cfecc418b3", device="cpu")
queries = model.encode([f"query: {pireps[i]['text']}" for i in picks], normalize_embeddings=True)
# la referencia, sin motor: el producto de todos los vectores por cada consulta (están normalizados)
floors = [np.sort(vectors @ q)[-10] - 1e-5 for q in queries]


def sh(*cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout.strip()


def state():
    return sh("docker", "inspect", "-f", "{{.State.Status}} OOMKilled={{.State.OOMKilled}} exit={{.State.ExitCode}}", NAME)


def cgroup():
    stat = dict(line.split() for line in sh("docker", "exec", NAME, "cat", "/sys/fs/cgroup/memory.stat").splitlines())
    current = int(sh("docker", "exec", NAME, "cat", "/sys/fs/cgroup/memory.current"))
    return current, int(stat["anon"]), int(stat["file"]), int(stat["pgmajfault"])


def mib(b):
    return f"{b / 2**20:.0f} MiB"


def wait_green(collection, timeout=3600):
    start = time.time()
    while time.time() - start < timeout:
        if state().startswith("exited"):
            return False
        try:
            info = QdrantClient(url=url, timeout=5).get_collection(collection)
            if info.status == models.CollectionStatus.GREEN:
                return True
            # grey: optimizaciones pendientes que Qdrant no arranca solo (pasa tras un reinicio). Si
            # todos los vectores ya están en el HNSW, la colección sirve igual
            if info.status == models.CollectionStatus.GREY and (info.indexed_vectors_count or 0) >= (info.points_count or 0) > 0:
                return True
        except Exception:
            pass
        time.sleep(2)
    return False


def recall(client, collection, params):
    total = 0
    for q, floor in zip(queries, floors):
        got = client.query_points(collection, query=q.tolist(), limit=10, search_params=params).points
        # el parecido se recalcula con los vectores completos: la cuantizada puntúa con los suyos
        total += sum(1 for p in got if float(vectors[int(p.id)] @ q) >= floor)
    return total / (10 * len(queries))


def measured(collection, params):
    """Recall de las consultas, y cuántas lecturas de disco (fallos de página mayores) costaron."""
    before = cgroup()[3]
    r = recall(QdrantClient(url=url, timeout=600), collection, params)
    return r, (cgroup()[3] - before) / len(queries)


VARIANTS = {
    "ram": (False, None),
    "disk": (True, None),
    "int8": (True, models.ScalarQuantization(scalar=models.ScalarQuantizationConfig(type=models.ScalarType.INT8, always_ram=True))),
    "binary": (True, models.BinaryQuantization(binary=models.BinaryQuantizationConfig(always_ram=True))),
}
params = models.SearchParams(hnsw_ef=128)

try:
    for key in args.variants.split(","):
        on_disk, quant = VARIANTS[key]
        sh("docker", "rm", "-f", NAME)
        sh("docker", "run", "-d", "--name", NAME, "-p", f"{PORT}:6333", "--memory", "6g", "--memory-swap", "6g", IMAGE)
        time.sleep(3)
        client = QdrantClient(url=url, timeout=600)
        client.create_collection(key, vectors_config=models.VectorParams(size=384, distance=models.Distance.COSINE, on_disk=on_disk),
                                 hnsw_config=models.HnswConfigDiff(m=16, ef_construct=100, on_disk=on_disk), quantization_config=quant)
        start = time.perf_counter()
        # lotes de 1000: con 5000, el cuerpo JSON pasa de 32 MiB y Qdrant lo rechaza (a09)
        for i in range(0, len(vectors), 1000):
            client.upsert(key, wait=True, points=models.Batch(ids=list(range(i, min(i + 1000, len(vectors)))), vectors=vectors[i:i + 1000].tolist()))
        # sin esto, la colección puede quedar en grey con las optimizaciones sin arrancar
        client.update_collection(key, optimizers_config=models.OptimizersConfigDiff())
        wait_green(key)
        built = time.perf_counter() - start
        # un reinicio, para que la memoria se mida como la vería un arranque y no la carga
        sh("docker", "restart", NAME)
        wait_green(key)
        r, faults = measured(key, params)
        cur, anon, file, _ = cgroup()
        line = f"{key}: listo en {built:.0f} s · sin límite: {mib(cur)} (anónima {mib(anon)}, archivos {mib(file)}) · recall@10 {r:.3f} · {faults:.0f} fallos mayores por consulta"
        if quant is not None:
            line += f" · sin reordenar: {recall(QdrantClient(url=url, timeout=600), key, models.SearchParams(hnsw_ef=128, quantization=models.QuantizationSearchParams(rescore=False))):.3f}"
        print(line, flush=True)
        for limit in args.limits.split(","):
            sh("docker", "update", "--memory", limit, "--memory-swap", limit, NAME)
            sh("docker", "restart", NAME)
            if wait_green(key, timeout=300):
                r, faults = measured(key, params)
                cur, anon, file, _ = cgroup()
                print(f"   --memory {limit}: sirve · {mib(cur)} (anónima {mib(anon)}, archivos {mib(file)}) · recall@10 {r:.3f} · {faults:.0f} fallos mayores por consulta", flush=True)
            else:
                logs = sh("docker", "logs", "--tail", "2", NAME).splitlines()
                print(f"   --memory {limit}: NO sirve · {state()}" + "".join(f"\n      {x[:200]}" for x in logs[-2:]), flush=True)
                break
finally:
    sh("docker", "rm", "-f", NAME)
