// Conecta con cada familia del laboratorio desde tu máquina, pregunta la versión del servidor
// y CIERRA la conexión. Si el proceso no termina solo al final, alguna conexión quedó abierta:
// es el error más común con estos drivers (a06).
//
//   node lab/check/conectar.ts            (desde src/, con los perfiles que quieras arriba)
import { readFileSync } from "node:fs";
import pg from "pg";
import { MongoClient } from "mongodb";
import { Valkey } from "iovalkey";
import { Client as OpenSearch } from "@opensearch-project/opensearch";
import neo4j from "neo4j-driver";
import { QdrantClient } from "@qdrant/js-client-rest";
import cassandra from "cassandra-driver";
import PouchDB from "pouchdb";

// la versión se lee del archivo: algunos paquetes no exportan su package.json
const driverVersion = (name: string): string =>
  JSON.parse(readFileSync(new URL(`../../node_modules/${name}/package.json`, import.meta.url), "utf8")).version;
const port = (name: string, fallback: number) => Number(process.env[name] ?? fallback);

type Check = { family: string; driver: string; run: () => Promise<string> };

const postgres = (database: string, envPort: string, fallback: number, user = "postgres", password: string | undefined = "condor") =>
  async () => {
    const client = new pg.Client({ host: "localhost", port: port(envPort, fallback), user, password, database });
    await client.connect();
    try {
      const { rows } = await client.query("SELECT version() AS v");
      return rows[0].v.split(" on ")[0];
    } finally {
      await client.end(); // sin esto, el proceso no termina
    }
  };

const checks: Check[] = [
  { family: "base", driver: "pg", run: postgres("postgres", "BASE_PORT", 15432) },
  {
    family: "documental", driver: "mongodb", run: async () => {
      // directConnection: el replica set se anuncia como localhost:27017, que desde tu máquina no existe
      const client = new MongoClient(`mongodb://localhost:${port("DOCUMENTAL_PORT", 27018)}/?directConnection=true`);
      try {
        const info = await client.db("admin").command({ buildInfo: 1 });
        return `MongoDB ${info.version}`;
      } finally {
        await client.close();
      }
    },
  },
  {
    family: "clave-valor", driver: "iovalkey", run: async () => {
      const client = new Valkey({ host: "localhost", port: port("CLAVE_VALOR_PORT", 16379), lazyConnect: true });
      await client.connect();
      try {
        return `Valkey ${(await client.info("server")).match(/valkey_version:(\S+)/)?.[1]}`;
      } finally {
        await client.quit();
      }
    },
  },
  {
    family: "series", driver: "pg", run: async () => {
      const client = new pg.Client({ host: "localhost", port: port("SERIES_PORT", 15433), user: "postgres", password: "condor", database: "postgres" });
      await client.connect();
      try {
        const { rows } = await client.query("SELECT default_version FROM pg_available_extensions WHERE name = 'timescaledb'");
        return `TimescaleDB ${rows[0]?.default_version} (disponible)`;
      } finally {
        await client.end();
      }
    },
  },
  {
    family: "busqueda", driver: "@opensearch-project/opensearch", run: async () => {
      const client = new OpenSearch({ node: `http://localhost:${port("BUSQUEDA_PORT", 19200)}` });
      try {
        const { body } = await client.info();
        return `OpenSearch ${body.version.number}`;
      } finally {
        await client.close();
      }
    },
  },
  {
    family: "grafos", driver: "neo4j-driver", run: async () => {
      const driver = neo4j.driver(`bolt://localhost:${port("GRAFOS_BOLT_PORT", 17687)}`, neo4j.auth.basic("neo4j", "condor-mro"));
      try {
        const info = await driver.getServerInfo();
        return `${info.agent}`;
      } finally {
        await driver.close();
      }
    },
  },
  {
    family: "vectorial", driver: "@qdrant/js-client-rest", run: async () => {
      // HTTP sin estado: no hay conexión que cerrar
      const client = new QdrantClient({ url: `http://localhost:${port("VECTORIAL_HTTP_PORT", 16333)}` });
      const info = await client.versionInfo();
      return `Qdrant ${info.version}`;
    },
  },
  {
    family: "columnar", driver: "cassandra-driver", run: async () => {
      const client = new cassandra.Client({
        contactPoints: [`localhost:${port("COLUMNAR_PORT", 19042)}`],
        localDataCenter: "datacenter1",
      });
      try {
        await client.connect();
        const rs = await client.execute("SELECT release_version FROM system.local");
        return `Cassandra ${rs.first().release_version}`;
      } finally {
        await client.shutdown();
      }
    },
  },
  {
    family: "offline", driver: "pouchdb", run: async () => {
      // PouchDB habla con CouchDB por HTTP: la base remota es solo una URL
      const remote = new PouchDB(`http://condor:condor@localhost:${port("OFFLINE_PORT", 15984)}/_users`, { skip_setup: true });
      try {
        const info = await remote.info();
        const server = await (await fetch(`http://localhost:${port("OFFLINE_PORT", 15984)}/`)).json();
        return `CouchDB ${server.version} (${info.db_name})`;
      } finally {
        await remote.close();
      }
    },
  },
  { family: "newsql", driver: "pg", run: postgres("defaultdb", "NEWSQL_PORT", 26258, "root", undefined) },
];

const only = process.argv.slice(2);
for (const c of checks.filter((c) => only.length === 0 || only.includes(c.family))) {
  const start = performance.now();
  try {
    const server = await c.run();
    console.log(`✅ ${c.family.padEnd(12)} ${`${c.driver} ${driverVersion(c.driver)}`.padEnd(42)} ${server}  (${Math.round(performance.now() - start)} ms)`);
  } catch (e) {
    const err = e as Error;
    console.log(`❌ ${c.family.padEnd(12)} ${`${c.driver} ${driverVersion(c.driver)}`.padEnd(42)} ${err.name}: ${err.message.split("\n")[0]}`);
  }
}
