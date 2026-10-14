// Cuánto tarda en verse lo recién escrito: se indexa una referencia nueva y se la busca cada 50 ms hasta
// que aparece, con refresh_interval de 1 s y de 30 s. Al lado, un GET por id, que no espera al refresco.
// Aquí el tiempo es lo que se mide: es la ventana en que la búsqueda no ve lo que ya se escribió.
//
//   node 12-busqueda-romper-y-medir/visibility.ts   (desde src/)
import { Client as OpenSearch } from "@opensearch-project/opensearch";

const os = new OpenSearch({ node: `http://localhost:${process.env.BUSQUEDA_PORT ?? 19200}` });
const index = "part_catalog";
try {
  for (const [interval, trials] of [["1s", 5], ["30s", 2]] as const) {
    await os.indices.putSettings({ index, body: { index: { refresh_interval: interval } } });
    for (let t = 0; t < trials; t++) {
      const id = `99-VIS${interval}-${t}`;
      const written = performance.now();
      await os.index({ index, id, body: { partNumber: id, description: "junta tórica recién llegada", category: "consumable", ataChapter: 20 } });
      const got = (await os.get({ index, id })).body.found;
      let misses = 0;
      for (;;) {
        const { body } = await os.search({ index, body: { query: { term: { partNumber: id } }, size: 1, _source: false } });
        if (body.hits.total.value > 0) break;
        misses++;
        await new Promise((r) => setTimeout(r, 50));
      }
      console.log(`refresh_interval ${interval.padEnd(3)} · GET por id lo encontró: ${got} · búsquedas que no lo vieron: ${String(misses).padStart(3)} · visible a los ${(performance.now() - written).toFixed(0)} ms`);
      await os.delete({ index, id, refresh: true });
    }
  }
} finally {
  await os.indices.putSettings({ index, body: { index: { refresh_interval: "1s" } } });
  await os.close();
}
