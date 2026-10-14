// El reintento como parte del modelo de programación (sección 4.4). Una transacción que recibe un 40001 no falló:
// el motor no pudo ordenarla con las demás, y lo que leyó ya no vale. Se repite entera, desde el BEGIN, con una
// espera que crece y un poco de azar para que los que chocaron no vuelvan a chocar al mismo tiempo. Lo que se repite
// tiene que poder repetirse: nada fuera de la base (un correo, una llamada) puede ir dentro.
import type pg from "pg";

export interface RetryStats { attempts: number; reasons: Record<string, number>; samples?: Record<string, string> }

/** Por qué se reinició: la palabra que CockroachDB pone en el mensaje, o el texto de Postgres. */
export function retryReason(e: any): string {
  const m = /(RETRY_[A-Z_]+|ReadWithinUncertaintyIntervalError|WriteTooOldError|TransactionAbortedError\([A-Z_]+\))/.exec(e.message ?? "");
  return m ? m[1] : (e.message ?? "").split("\n")[0].slice(0, 60);
}

export async function withRetry<T>(db: pg.Client, work: (db: pg.Client) => Promise<T>, stats: RetryStats, maxAttempts = 20): Promise<T | undefined> {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    stats.attempts++;
    try {
      await db.query("BEGIN");
      const out = await work(db);
      await db.query("COMMIT");
      return out;
    } catch (e: any) {
      await db.query("ROLLBACK").catch(() => {});
      if (e.code !== "40001") throw e;
      const why = retryReason(e);
      stats.reasons[why] = (stats.reasons[why] ?? 0) + 1;
      if (stats.samples && !stats.samples[why]) stats.samples[why] = e.message;   // el mensaje literal, una vez por motivo
      await new Promise((ok) => setTimeout(ok, Math.random() * Math.min(1000, 5 * 2 ** attempt)));
    }
  }
  return undefined;   // se rindió: el llamador decide qué le dice al técnico
}
