// Paridad de embeddings, lado TypeScript (consulta): transformers.js con el ONNX del mismo repositorio.
// Compara contra los vectores que escribió e5_python.py y mide qué pasa sin prefijos.
// Uso: node e5_node.mjs <revision> <vectores-python.json>
import { readFileSync } from "node:fs";
import { pipeline } from "@huggingface/transformers";

const [revision, pyPath] = process.argv.slice(2);
const py = JSON.parse(readFileSync(pyPath, "utf8"));

const extractor = await pipeline("feature-extraction", "intfloat/multilingual-e5-small", {
  revision,
  dtype: "fp32", // sin cuantizar: la paridad se mide contra los pesos completos
});

const embed = async (texts) =>
  (await extractor(texts, { pooling: "mean", normalize: true })).tolist();

const dot = (a, b) => a.reduce((s, x, i) => s + x * b[i], 0);

// 1. paridad: mismo texto, mismo vector
const node = await embed(py.texts);
node.forEach((v, i) => {
  const cos = dot(v, py.vectors[i]);
  const maxDiff = Math.max(...v.map((x, j) => Math.abs(x - py.vectors[i][j])));
  console.log(`paridad [${i}] coseno=${cos.toFixed(6)} max|dif|=${maxDiff.toExponential(2)}`);
});

// 2. el anti-patrón: la misma búsqueda con y sin prefijos
const rank = (q, docs) =>
  docs.map((d, i) => ({ i, s: dot(q, d) })).sort((a, b) => b.s - a.s);
const docsWith = py.texts.slice(1);
const docsWithout = docsWith.map((t) => t.replace(/^passage: /, ""));
const [qWith] = await embed([py.texts[0]]);
const [qWithout] = await embed([py.texts[0].replace(/^query: /, "")]);
const show = (r, docs) => r.map(({ i, s }) => `${s.toFixed(3)} ${docs[i]}`).join("\n   ");
console.log("con prefijos:\n   " + show(rank(qWith, await embed(docsWith)), docsWith));
console.log("sin prefijos:\n   " + show(rank(qWithout, await embed(docsWithout)), docsWithout));
