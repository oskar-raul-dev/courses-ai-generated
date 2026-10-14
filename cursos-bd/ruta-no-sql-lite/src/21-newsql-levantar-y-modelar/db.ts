// Las conexiones de las Fases 21 y 22: Postgres de un nodo (la línea base), CockroachDB de un nodo (`newsql`),
// CockroachDB de nueve nodos en tres regiones (`newsql-global`), y el primario en Bogotá y la réplica de lectura en
// Quito de la Fase 22 (`compose.replica.yaml`). Todas hablan el protocolo de Postgres y las abre el mismo driver:
// lo que cambia es el puerto, el usuario y lo que hay detrás.
import pg from "pg";

export type Target = "base" | "newsql" | "global" | "primario" | "replica";

/** El país de cada puerta de `newsql-global`: el sidecar publica un nodo de cada región (a02), y cada región
 *  hace de un país (sección 4): us-east1 = Colombia, us-west1 = Ecuador, europe-west1 = Perú. */
export const GATEWAYS: Record<string, number> = {
  CO: Number(process.env.NEWSQL_GLOBAL_PORT ?? 26259),
  EC: Number(process.env.NEWSQL_GLOBAL_PORT_2 ?? 26260),
  PE: Number(process.env.NEWSQL_GLOBAL_PORT_3 ?? 26261),
};

/** Abre una conexión. En `global`, `country` elige la puerta: el nodo del país desde donde se escribe. */
export async function connect(target: Target, database: string, country: keyof typeof GATEWAYS = "CO"): Promise<pg.Client> {
  const config =
    target === "base" || target === "primario" || target === "replica"
      ? { port: Number(target === "base" ? process.env.BASE_PORT ?? 15432 : target === "primario" ? process.env.REPLICA_PRIMARIO_PORT ?? 15440 : process.env.REPLICA_LECTURA_PORT ?? 15441), user: "postgres", password: "condor" }
      : target === "newsql"
        ? { port: Number(process.env.NEWSQL_PORT ?? 26258), user: "root" }
        : { port: GATEWAYS[country], user: "root" };
  const client = new pg.Client({ host: "localhost", database, ...config });
  await client.connect();
  return client;
}

/** Crea la base si no existe, conectándose a la que siempre está. */
export async function ensureDatabase(target: Target, database: string, options = ""): Promise<void> {
  const isPostgres = target === "base" || target === "primario";
  const admin = await connect(target, isPostgres ? "postgres" : "defaultdb");
  try {
    if (isPostgres) {
      const { rowCount } = await admin.query("SELECT 1 FROM pg_database WHERE datname = $1", [database]);
      if (!rowCount) await admin.query(`CREATE DATABASE ${database}`);
    } else {
      await admin.query(`DROP DATABASE IF EXISTS ${database} CASCADE`);
      await admin.query(`CREATE DATABASE ${database} ${options}`);
    }
  } finally {
    await admin.end();
  }
}
