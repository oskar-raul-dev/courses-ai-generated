// El reindexado completo del millón sin cortar la búsqueda: la pantalla de Sandra consulta un alias
// (catalog) que apunta al índice viejo mientras el nuevo se carga desde la fuente, y el alias cambia de
// índice en una sola operación. En paralelo, la misma búsqueda contra el índice nuevo, por su nombre,
// muestra lo que vería la pantalla sin alias.
//
//   node 12-busqueda-romper-y-medir/reindex-alias.ts   (desde src/, con part_catalog de 1 M)
import { spawn } from "node:child_process";
import { Client as OpenSearch } from "@opensearch-project/opensearch";

const os = new OpenSearch({ node: `http://localhost:${process.env.BUSQUEDA_PORT ?? 19200}` });
const QUERY = { match: { description: { query: "juntas toricas tren", operator: "and" } } };
const count = async (index: string): Promise<number | string> => {
  try {
    return (await os.count({ index, body: { query: QUERY } })).body.count;
  } catch (e) {
    return `error: ${(e as Error).message.split("\n")[0].slice(0, 60)}`;
  }
};

try {
  await os.indices.updateAliases({ body: { actions: [{ remove: { index: "*", alias: "catalog", must_exist: false } }, { add: { index: "part_catalog", alias: "catalog" } }] } });
  const seenAlias = new Map<string, number>();
  const seenDirect = new Map<string, number>();
  let polls = 0;
  const started = performance.now();
  const loader = spawn("node", ["11-busqueda-levantar-y-modelar/load.ts", "--dataset", "lab/data/partCatalog-1m", "--index", "part_catalog_v2", "--skip-postgres"], { stdio: "ignore" });
  let loading = true;
  loader.on("exit", () => { loading = false; });
  while (loading) {
    const a = String(await count("catalog"));
    const d = String(await count("part_catalog_v2"));
    seenAlias.set(a, (seenAlias.get(a) ?? 0) + 1);
    seenDirect.set(d, (seenDirect.get(d) ?? 0) + 1);
    polls++;
    await new Promise((r) => setTimeout(r, 200));
  }
  const rebuild = (performance.now() - started) / 1000;
  // el cambio: quitar el viejo y poner el nuevo en la misma petición
  await os.indices.updateAliases({ body: { actions: [{ remove: { index: "part_catalog", alias: "catalog" } }, { add: { index: "part_catalog_v2", alias: "catalog" } }] } });
  const after = await count("catalog");
  console.log(`reconstrucción desde la fuente: ${rebuild.toFixed(1)} s · ${polls} búsquedas durante la carga`);
  console.log(`  por el alias:            ${[...seenAlias].map(([k, n]) => `${k} (${n} veces)`).join(" · ")}`);
  console.log(`  contra el índice nuevo:  ${seenDirect.size} respuestas distintas, de ${[...seenDirect.keys()][0]} a ${[...seenDirect.keys()].at(-1)}`);
  console.log(`  por el alias, después del cambio: ${after}`);
  // el laboratorio vuelve a como estaba: el alias al índice del curso y el nuevo fuera
  await os.indices.updateAliases({ body: { actions: [{ remove: { index: "part_catalog_v2", alias: "catalog" } }, { add: { index: "part_catalog", alias: "catalog" } }] } });
  await os.indices.delete({ index: "part_catalog_v2" });
} finally {
  await os.close();
}
