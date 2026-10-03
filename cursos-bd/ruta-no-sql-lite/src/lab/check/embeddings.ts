// El lado TypeScript de vectorial: la consulta se embebe con transformers.js y el mismo ONNX
// del repositorio de intfloat, en la revisión fijada (paridad verificada contra Python, a06).
//
//   node lab/check/embeddings.ts        (desde src/)
import { pipeline } from "@huggingface/transformers";

const E5 = "intfloat/multilingual-e5-small";
const E5_REVISION = "614241f622f53c4eeff9890bdc4f31cfecc418b3";

const start = performance.now();
const extractor = await pipeline("feature-extraction", E5, { revision: E5_REVISION, dtype: "fp32" });
const [vector] = (await extractor(["query: ruido metalico al bajar tren"], { pooling: "mean", normalize: true })).tolist();
console.log(`✅ embeddings   @huggingface/transformers   ${E5}@${E5_REVISION.slice(0, 8)} · ${vector.length} dimensiones  (${Math.round(performance.now() - start)} ms)`);
