// El boss del Bloque V, "Las dos verdades": deja los dos sistemas como llegan al comité. SIGMA es la base `expediente`
// de Postgres (workOrder-10k, cargada por la Fase 19); el sistema de componentes de Camilo es la colección
// `component` de la base `camilo` en MongoDB, cargada aquí desde `lab/data/camilo-10k/component.ndjson` después de
// comprobar su hash. No resuelve nada, y no lee el answers.json de camilo-10k: ese archivo es la solución.
//
//   node 25-poliglota-la-factura/boss/setup.ts   (desde src/, con los perfiles base y documental arriba)
//
// Si falta el dataset:   (cd lab/generator && node src/diverge.ts)
import { MongoClient } from "mongodb";
import pg from "pg";
import { readNdjson, verifyDataset } from "../../lab/harness/dataset.ts";

const DATASET = "lab/data/camilo-10k";
const manifest = await verifyDataset(DATASET);
console.log(`camilo-10k · datasetSha256 ${manifest.datasetSha256.slice(0, 12)}… verificado`);

const sigma = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "expediente" });
await sigma.connect();
const { rows: [s] } = await sigma.query(`SELECT (SELECT count(*) FROM part)::int AS parts, (SELECT count(*) FROM work_order)::int AS orders`);
await sigma.end();
console.log(`SIGMA (Postgres, base expediente): ${s.parts} piezas, ${s.orders} órdenes`);

const mongo = new MongoClient(`mongodb://localhost:${process.env.DOCUMENTAL_PORT ?? 27018}/?directConnection=true`);
await mongo.connect();
const component = mongo.db("camilo").collection("component");
await component.drop().catch(() => {});
let batch: any[] = [], loaded = 0;
for await (const doc of readNdjson<any>(`${DATASET}/component.ndjson`)) {
  batch.push(doc);
  if (batch.length === 1000) { await component.insertMany(batch); loaded += batch.length; batch = []; }
}
if (batch.length) { await component.insertMany(batch); loaded += batch.length; }
await mongo.close();
console.log(`sistema de Camilo (MongoDB, camilo.component): ${loaded} componentes`);
console.log(s.parts === loaded ? "los dos sistemas tienen las mismas piezas; ahora, encuentra en qué no coinciden" : "⚠️ distinto número de piezas: revisa que expediente tenga workOrder-10k");
