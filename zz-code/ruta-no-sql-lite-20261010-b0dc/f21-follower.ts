import { crdbExplain } from "/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-no-sql-lite/src/lab/harness/crdb-explain.ts";
import { connect } from "/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-no-sql-lite/src/21-newsql-levantar-y-modelar/db.ts";
const db = await connect("global", "condor_copia", "PE");
for (const aost of ["", " AS OF SYSTEM TIME follower_read_timestamp()"]) {
  const e = await crdbExplain(db, `SELECT work_order_id, type FROM work_order${aost} WHERE aircraft = 'HC-2157'`);
  console.log(`${aost || " (sin cláusula)"} · regiones ${e.regions.join(", ")} · nodos ${e.kvNodes.join(" ")} · filas ${e.kvRows}`);
}
const { rows } = await db.query("SELECT now() - follower_read_timestamp() AS lag");
console.log("follower_read_timestamp() va", rows[0].lag, "atrás");
await db.end();
