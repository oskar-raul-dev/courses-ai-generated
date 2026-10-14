// La situación 3 de la familia: el buscador usado como fuente de verdad. La pantalla de Sandra corrige
// 500 precios escribiendo solo en OpenSearch. Después, un cambio de mapping obliga a reconstruir el
// índice, y hay dos formas de hacerlo:
//   _reindex     copiar el índice viejo al nuevo: las correcciones sobreviven, pero ya no coinciden
//                con la fuente (Postgres)
//   desde fuente cargar el índice nuevo desde el catálogo: coincide con la fuente, y las 500 se pierden
//
//   node 11-busqueda-levantar-y-modelar/source-of-truth.ts   (desde src/, con part_catalog de 1 M)
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { Client as OpenSearch } from "@opensearch-project/opensearch";
import pg from "pg";

// _reindex de un millón tarda más que los 30 s de espera por defecto del cliente, y el cliente reintenta
// por su cuenta: sin estas dos opciones, el reindexado se lanzó cuatro veces (Fase 11, sección 9)
const os = new OpenSearch({ node: `http://localhost:${process.env.BUSQUEDA_PORT ?? 19200}`, requestTimeout: 600_000, maxRetries: 0 });
const db = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "busqueda_base" });
await db.connect();
const mapping = JSON.parse(readFileSync(join(import.meta.dirname, "catalog-index.json"), "utf8"));

try {
  // 1. las correcciones de Sandra, solo en el buscador: un 7 % más caro, 500 referencias
  const { rows } = await db.query("SELECT part_number, unit_cost_usd FROM part_catalog ORDER BY md5(part_number) LIMIT 500");
  const body = rows.flatMap((r) => [{ update: { _index: "part_catalog", _id: r.part_number } }, { doc: { unitCostUsd: Math.round(Number(r.unit_cost_usd) * 107) / 100 } }]);
  const { body: bulk } = await os.bulk({ body, refresh: true });
  console.log(`correcciones escritas solo en OpenSearch: ${bulk.items.length} · errores ${bulk.errors}`);

  const priceMismatches = async (index: string): Promise<number> => {
    const { body: r } = await os.mget({ index, body: { ids: rows.map((x) => x.part_number) }, _source_includes: ["unitCostUsd"] });
    return r.docs.filter((d: { _source: { unitCostUsd: number } }, i: number) => Math.abs(d._source.unitCostUsd - Number(rows[i].unit_cost_usd)) > 0.005).length;
  };
  console.log(`índice part_catalog: precios distintos de la fuente ${await priceMismatches("part_catalog")} de 500`);

  // 2. reconstruir con _reindex: el índice nuevo copia al viejo, correcciones incluidas
  await os.indices.delete({ index: "part_catalog_v2", ignore_unavailable: true });
  await os.indices.create({ index: "part_catalog_v2", body: mapping });
  let t = performance.now();
  // como tarea y no esperando la respuesta: la respuesta síncrona trae una cabecera TASK_RESOURCE_USAGE
  // por cada lote del recorrido, y con un millón de documentos Node la rechaza (Header overflow)
  const { body: started } = await os.reindex({ body: { source: { index: "part_catalog" }, dest: { index: "part_catalog_v2" } }, wait_for_completion: false });
  let task;
  do {
    await new Promise((r) => setTimeout(r, 1000));
    task = (await os.tasks.get({ task_id: started.task })).body;
  } while (!task.completed);
  await os.indices.refresh({ index: "part_catalog_v2" });
  const re = task.response;
  console.log(`_reindex: ${re.total} documentos en ${((performance.now() - t) / 1000).toFixed(1)} s · precios distintos de la fuente ${await priceMismatches("part_catalog_v2")} de 500`);
  await os.indices.delete({ index: "part_catalog_v2" });

  // 3. reconstruir desde la fuente: se vuelve a cargar el catálogo, y las correcciones no estaban ahí
  t = performance.now();
  const { execFileSync } = await import("node:child_process");
  execFileSync("node", ["11-busqueda-levantar-y-modelar/load.ts", "--dataset", "lab/data/partCatalog-1m", "--index", "part_catalog_v2", "--skip-postgres"], { stdio: "ignore" });
  console.log(`desde la fuente: ${((performance.now() - t) / 1000).toFixed(1)} s · precios distintos de la fuente ${await priceMismatches("part_catalog_v2")} de 500 · correcciones perdidas ${500 - (await priceMismatches("part_catalog_v2"))}`);
  await os.indices.delete({ index: "part_catalog_v2" });

  // el índice del curso vuelve a coincidir con la fuente
  const undo = rows.flatMap((r) => [{ update: { _index: "part_catalog", _id: r.part_number } }, { doc: { unitCostUsd: Number(r.unit_cost_usd) } }]);
  await os.bulk({ body: undo, refresh: true });
} finally {
  await os.close();
  await db.end();
}
