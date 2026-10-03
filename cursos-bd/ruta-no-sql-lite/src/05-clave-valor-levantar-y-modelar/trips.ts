// Cuántas escrituras al socket cuestan 100 lecturas de sesión en Valkey según cómo se manden: una a
// una con await, en pipeline, en paralelo con Promise.all y con autopipelining (Fase 05, a04).
//
//   node 05-clave-valor-levantar-y-modelar/trips.ts     (desde src/, con clave-valor arriba y las
//                                                        sesiones de model.ts cargadas)
import { Valkey } from "iovalkey";
import { countSocketWrites } from "../lab/harness/roundtrips.ts";

const port = Number(process.env.CLAVE_VALOR_PORT ?? 16379);
const ids = Array.from({ length: 100 }, (_, i) => `session:${String(i).padStart(7, "0")}`);

const plain = new Valkey({ host: "localhost", port, lazyConnect: true });
await plain.connect();
const auto = new Valkey({ host: "localhost", port, lazyConnect: true, enableAutoPipelining: true });
await auto.connect();
try {
  const t = countSocketWrites(plain);
  for (const id of ids) await plain.hgetall(id);
  const sequential = t.count;
  t.reset();
  const p = plain.pipeline();
  for (const id of ids) p.hgetall(id);
  const res = await p.exec();
  const pipelined = t.count;
  t.reset();
  await Promise.all(ids.map((id) => plain.hgetall(id)));
  const parallel = t.count;
  const ta = countSocketWrites(auto);
  await Promise.all(ids.map((id) => auto.hgetall(id)));
  const found = res!.filter(([, h]) => Object.keys(h as object).length > 0).length;
  console.log(`100 lecturas de sesión (${found} existen) · escrituras al socket:`);
  console.log(`   una a una con await: ${sequential} · pipeline: ${pipelined} · Promise.all: ${parallel} · Promise.all con autopipelining: ${ta.count}`);
} finally {
  await plain.quit();
  await auto.quit();
}
