// Lo que tocó Cassandra para contestar, leído de la traza de la consulta (TRACING ON en cqlsh,
// traceQuery en el driver). Es la medida de la familia columnar (a04): particiones y SSTables
// tocadas, filas vivas leídas contra devueltas, y tombstones.
import cassandra from "cassandra-driver";

export interface TraceResult {
  /** Lecturas de una partición ("Executing single-partition query"). */
  partitions: number;
  /** Recorridos por rango de tokens ("Executing seq scan across"): la consulta no sabía en qué partición estaba. */
  rangeScans: number;
  /** SSTables abiertas, sumadas sobre cada partición o rango. */
  sstables: number;
  /** Filas vivas que leyó el motor ("Read N live rows"), antes de cualquier filtro del coordinador. */
  liveRows: number;
  tombstones: number;
  /** Filas que devolvió la consulta, con todas sus páginas. */
  returned: number;
  /** Páginas pedidas: cada una es una petición, y la que sigue reanuda la partición donde quedó. */
  pages: number;
  /** Duración que el coordinador anota en la traza, en µs: contexto, no argumento. */
  durationUs: number;
}

const num = (re: RegExp, s: string) => Number(re.exec(s)?.[1] ?? 0);

export function summarize(activities: string[], returned: number, durationUs = 0): TraceResult {
  const r: TraceResult = { partitions: 0, rangeScans: 0, sstables: 0, liveRows: 0, tombstones: 0, returned, pages: 1, durationUs };
  for (const a of activities) {
    if (a.startsWith("Executing single-partition query")) r.partitions++;
    if (a.startsWith("Executing seq scan across")) {
      r.rangeScans++;
      r.sstables += num(/across (\d+) sstables/, a);
    }
    if (a.startsWith("Merged data from memtables and")) r.sstables += num(/and (\d+) sstables/, a);
    if (a.startsWith("Read ")) {
      r.liveRows += num(/Read (\d+) live rows/, a);
      r.tombstones += num(/and (\d+) tombstone cells/, a);
    }
  }
  return r;
}

/**
 * Ejecuta la consulta con traza y la recorre entera (todas las páginas). Cada página es una petición
 * con su propia traza: se suman todas, porque leer la segunda página también es leer. Por defecto pide
 * páginas de 50 000 filas, para que una consulta de esta escala salga en una sola y la segunda página no
 * cuente dos veces la partición que reanuda.
 */
export async function traced(client: cassandra.Client, cql: string, params: unknown[] = [], fetchSize = 50_000): Promise<TraceResult & { rows: cassandra.types.Row[] }> {
  const rows: cassandra.types.Row[] = [];
  const activities: string[] = [];
  let durationUs = 0;
  let pageState: string | undefined;
  let pages = 0;
  do {
    pages++;
    const rs = await client.execute(cql, params, { prepare: true, traceQuery: true, fetchSize, pageState });
    rows.push(...rs.rows);
    // la traza se escribe de forma asíncrona en system_traces: getTrace reintenta hasta que está completa
    const trace = await client.metadata.getTrace(rs.info.traceId);
    activities.push(...trace.events.map((e: { activity: string }) => e.activity));
    durationUs += Number(trace.duration ?? 0);
    pageState = rs.pageState ?? undefined;
  } while (pageState);
  return { ...summarize(activities, rows.length, durationUs), pages, rows };
}

export function columnar(): cassandra.Client {
  return new cassandra.Client({
    contactPoints: [`localhost:${process.env.COLUMNAR_PORT ?? 19042}`],
    localDataCenter: "datacenter1",
    keyspace: "condor",
    // las lecturas grandes del laboratorio pasan del timeout por defecto del driver (12 s)
    socketOptions: { readTimeout: 120_000 },
  });
}

/** Escrituras reintentadas en toda la vida del proceso: se reportan, porque cada una es carga de más. */
export const retries = { writeTimeout: 0, other: 0 };

/**
 * Manda las escrituras con `concurrency` en vuelo y reintenta las que fallan por tiempo (E-57 en a09).
 * Reintentar es seguro porque en Cassandra escribir la misma fila dos veces deja una sola (upsert); con
 * el heap de 512 MB del laboratorio, una carga sostenida pierde alguna confirmación cuando las
 * compactaciones se atrasan, y eso es parte del modelo de programación, no un accidente.
 */
export async function writeAll(client: cassandra.Client, items: { query: string; params: unknown[] }[], concurrency = 64): Promise<void> {
  let pending = items;
  for (let attempt = 0; pending.length; attempt++) {
    if (attempt > 0) await new Promise((r) => setTimeout(r, Math.min(1000 * 2 ** attempt, 30_000)));
    if (attempt > 8) throw new Error(`${pending.length} escrituras siguen fallando después de 8 reintentos`);
    const r = await cassandra.concurrent.executeConcurrent(client, pending, { concurrencyLevel: concurrency, raiseOnFirstError: false, collectResults: true });
    const failed: typeof pending = [];
    r.resultItems.forEach((item: unknown, i: number) => {
      if (!(item instanceof Error)) return;
      const code = (item as { code?: number }).code;
      // 4352 = write timeout, 4096 = el nodo se declaró sobrecargado, 4097 = no disponible por arranque
      if (code === 4352) retries.writeTimeout++;
      else if (code === 4096 || code === 4097 || item.name === "OperationTimedOutError") retries.other++;
      else throw item;
      failed.push(pending[i]);
    });
    pending = failed;
  }
}
