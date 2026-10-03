// Los viajes de ida y vuelta no los reporta ningún motor: se cuentan en el cliente. Es la métrica
// más importante del curso y la única que se instrumenta a mano (a04).

export interface RoundTripCounter {
  count: number;
  reset(): void;
}

/**
 * Envuelve un método del cliente —`query` en pg, por ejemplo— para que cada llamada cuente como
 * un viaje. Devuelve el contador; el cliente se sigue usando igual.
 */
export function countRoundTrips<T extends object>(client: T, method: keyof T): RoundTripCounter {
  const counter: RoundTripCounter = { count: 0, reset: () => { counter.count = 0; } };
  const original = client[method] as unknown as (...args: unknown[]) => unknown;
  (client as Record<keyof T, unknown>)[method] = (...args: unknown[]) => {
    counter.count++;
    return original.apply(client, args);
  };
  return counter;
}

/** Comandos que el driver manda por su cuenta y que no son consultas de tu programa. */
const DRIVER_CHATTER = new Set(["hello", "isMaster", "ismaster", "saslStart", "saslContinue", "endSessions", "ping", "buildInfo"]);

/**
 * En MongoDB los viajes se cuentan con los eventos de comando del driver: cada `commandStarted` es
 * un comando que salió hacia el servidor. El cliente tiene que crearse con `monitorCommands: true`.
 * No cuenta la conversación propia del driver (handshake, autenticación, cierre de sesiones).
 */
export function countMongoRoundTrips(client: { on(event: "commandStarted", fn: (e: { commandName: string }) => void): unknown }): RoundTripCounter & { byCommand: Record<string, number> } {
  const counter = { count: 0, byCommand: {} as Record<string, number>, reset: () => { counter.count = 0; counter.byCommand = {}; } };
  client.on("commandStarted", (e) => {
    if (DRIVER_CHATTER.has(e.commandName)) return;
    counter.count++;
    counter.byCommand[e.commandName] = (counter.byCommand[e.commandName] ?? 0) + 1;
  });
  return counter;
}

/**
 * En Valkey (iovalkey) un viaje es una escritura al socket: 100 comandos con `await` uno a uno son
 * 100 escrituras; los mismos 100 en un pipeline, una. Se llama después de `connect()`, porque el
 * socket se crea al conectar (y se vuelve a crear si el cliente reconecta).
 */
export function countSocketWrites(client: { stream: { write: (...args: never[]) => boolean } }): RoundTripCounter {
  const counter: RoundTripCounter = { count: 0, reset: () => { counter.count = 0; } };
  const stream = client.stream as unknown as { write: (...args: unknown[]) => boolean };
  const original = stream.write.bind(stream);
  stream.write = (...args: unknown[]) => {
    counter.count++;
    return original(...args);
  };
  return counter;
}
