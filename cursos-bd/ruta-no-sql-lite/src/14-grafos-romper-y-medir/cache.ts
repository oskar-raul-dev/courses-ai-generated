// El grafo que no cabe en memoria: la misma travesía de 8 saltos desde la pieza de a07, dos veces seguidas
// (en frío, recién arrancado el motor, y en caliente). Neo4j Community no informa los aciertos de su caché
// de páginas, así que se mide lo que el contenedor leyó de disco: los bytes de io.stat y los fallos de
// página mayores de memory.stat de su cgroup, antes y después (el método de la Fase 16).
// Se corre una vez con la caché del compose (256 MB) y otra con 64 MB.
//
// "En frío" exige vaciar antes la caché de archivos de la máquina virtual de Docker; si no, la lectura sale
// de la memoria del sistema y no del disco. Desde src/, para cada tamaño:
//
//   docker compose -f lab/compose.yaml up -d --wait --force-recreate grafos
//       (para 64 MB: -f lab/compose.yaml -f 14-grafos-romper-y-medir/compose.pagecache-64m.yaml)
//   docker run --rm --privileged pgvector/pgvector@sha256:2ba9ca5f2e7daa0f0e7723cba1ee9167bab54efd3640516a44ac1a928dd67e7a \
//       sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'      (la imagen de base, ya descargada; no borra datos)
//   node 14-grafos-romper-y-medir/cache.ts
//
// y al terminar, otra vez el primer comando, para volver a 256 MB.
import { execFileSync } from "node:child_process";
import neo4j from "neo4j-driver";

const CONTAINER = process.env.GRAFOS_CONTAINER ?? "condor-lab-grafos-1";
const cgroup = () => {
  const out = execFileSync("docker", ["exec", CONTAINER, "sh", "-c", "grep -E '^pgmajfault ' /sys/fs/cgroup/memory.stat; cat /sys/fs/cgroup/io.stat"], { encoding: "utf8" });
  const faults = Number(/pgmajfault (\d+)/.exec(out)![1]);
  const read = [...out.matchAll(/rbytes=(\d+)/g)].reduce((s, m) => s + Number(m[1]), 0);
  return { faults, read };
};
const driver = neo4j.driver(`bolt://localhost:${process.env.GRAFOS_BOLT_PORT ?? 17687}`, neo4j.auth.basic("neo4j", "condor-mro"));
const session = driver.session();
try {
  const size = (await session.run("SHOW SETTINGS YIELD name, value WHERE name = 'server.memory.pagecache.size' RETURN value")).records[0].get("value");
  for (const run of ["en frío", "en caliente"]) {
    const before = cgroup();
    const t = performance.now();
    const r = await session.run("MATCH (p:Part {serialNumber: 'SN-0391969'})-[:INSTALLED*1..8]-(x) RETURN count(DISTINCT x) AS n");
    const seconds = (performance.now() - t) / 1000;
    const after = cgroup();
    console.log(`caché ${size} · ${run} · ${r.records[0].get("n").toNumber()} nodos · leídos de disco ${((after.read - before.read) / 2 ** 20).toFixed(1)} MiB · fallos de página mayores ${after.faults - before.faults} · ${seconds.toFixed(1)} s`);
  }
} finally {
  await session.close();
  await driver.close();
}
