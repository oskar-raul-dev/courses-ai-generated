# Paridad de embeddings, lado Python (ingesta): sentence-transformers con los pesos de PyTorch.
# Escribe los vectores en JSON para compararlos con los de transformers.js.
# Uso: python e5_python.py <revision> <salida.json>
import json
import sys

from sentence_transformers import SentenceTransformer

MODEL = "intfloat/multilingual-e5-small"
revision, out_path = sys.argv[1], sys.argv[2]

# reportes de piloto de Cóndor: prosa telegráfica, con jerga y con faltas
texts = [
    "query: ruido metalico al bajar tren, intermitente",
    "passage: golpeteo al extender tren principal, se repite en aterrizaje",
    "passage: vibracion en pedales de freno en carreteo",
    "passage: olor a quemado en cabina durante ascenso",
    "passage: luz de tren no enciende, tren abajo y asegurado segun inspeccion visual",
]

model = SentenceTransformer(MODEL, revision=revision, device="cpu")
vectors = model.encode(texts, normalize_embeddings=True)
json.dump({"texts": texts, "vectors": vectors.tolist()}, open(out_path, "w"))
print(f"{len(texts)} vectores de {vectors.shape[1]} dimensiones")
