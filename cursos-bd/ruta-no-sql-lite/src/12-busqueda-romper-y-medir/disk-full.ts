// El punto de rotura de la Fase 12: el disco lleno. No se llena el disco de verdad: se bajan los umbrales
// de disco (watermarks) por debajo de lo que ya está usado, que para OpenSearch es lo mismo, y se observa
// qué hace con el índice, qué deja escribir y qué deja leer. Al final, los umbrales vuelven a su valor.
//
//   node 12-busqueda-romper-y-medir/disk-full.ts   (desde src/)
import { Client as OpenSearch } from "@opensearch-project/opensearch";

const os = new OpenSearch({ node: `http://localhost:${process.env.BUSQUEDA_PORT ?? 19200}` });
const index = "part_catalog";
const blocked = async () => (await os.indices.getSettings({ index, name: "index.blocks.read_only_allow_delete" })).body[index]?.settings?.index?.blocks?.read_only_allow_delete ?? "false";
const write = async (id: string) => {
  try {
    await os.index({ index, id, body: { partNumber: id, description: "junta tórica de prueba", category: "consumable", ataChapter: 20 } });
    await os.delete({ index, id });
    return "escribe";
  } catch (e) {
    const err = e as { meta?: { body?: { error?: { type: string; reason: string } }; statusCode?: number } };
    return `${err.meta?.statusCode} ${err.meta?.body?.error?.type}: ${err.meta?.body?.error?.reason}`;
  }
};
const WATERMARKS = ["low", "high", "flood_stage"].map((w) => `cluster.routing.allocation.disk.watermark.${w}`);

try {
  const { body: fs } = await os.nodes.stats({ metric: "fs" });
  const total = Object.values(fs.nodes as Record<string, { fs: { total: { total_in_bytes: number; available_in_bytes: number } } }>)[0].fs.total;
  console.log(`disco del nodo: ${((1 - total.available_in_bytes / total.total_in_bytes) * 100).toFixed(1)} % usado`);
  // por debajo de lo usado: para OpenSearch, el disco ya pasó los tres umbrales
  await os.cluster.putSettings({ body: { persistent: {
    [WATERMARKS[0]]: "1%", [WATERMARKS[1]]: "2%", [WATERMARKS[2]]: "3%", "cluster.info.update.interval": "10s" } } });
  let t = performance.now();
  while ((await blocked()) !== "true") await new Promise((r) => setTimeout(r, 500));
  console.log(`índice bloqueado a los ${((performance.now() - t) / 1000).toFixed(1)} s · read_only_allow_delete = ${await blocked()}`);
  console.log(`  escribir: ${await write("99-DISCO-1")}`);
  const { body } = await os.count({ index, body: { query: { match: { description: "junta" } } } });
  console.log(`  leer: ${body.count} juntas`);
  // los umbrales a su valor por defecto; el bloqueo se levanta solo cuando el disco baja del umbral alto
  await os.cluster.putSettings({ body: { persistent: { [WATERMARKS[0]]: null, [WATERMARKS[1]]: null, [WATERMARKS[2]]: null, "cluster.info.update.interval": null } } });
  t = performance.now();
  while ((await blocked()) === "true") await new Promise((r) => setTimeout(r, 500));
  console.log(`bloqueo levantado solo a los ${((performance.now() - t) / 1000).toFixed(1)} s · escribir: ${await write("99-DISCO-2")}`);
} finally {
  await os.close();
}
