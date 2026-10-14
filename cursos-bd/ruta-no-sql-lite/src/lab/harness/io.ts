// Bytes que un contenedor del laboratorio escribió de verdad al disco, leídos del io.stat de su cgroup.
// Es la medida de amplificación de escritura que vale para cualquier motor (a04): no pregunta al motor
// qué cree que escribió, cuenta lo que llegó al dispositivo, incluido el WAL, el commitlog, los flushes y
// las compactaciones. El kernel atribuye al cgroup la escritura diferida de las páginas que ensució.
import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";

const compose = (service: string, ...cmd: string[]) =>
  execFileSync("docker", ["compose", "-f", "lab/compose.yaml", "exec", "-T", service, ...cmd], { encoding: "utf8" });

/** Bytes escritos por el contenedor desde que arrancó, sumados sobre todos sus dispositivos. */
export function containerWrites(service: string): number {
  // `sync` vacía las páginas sucias: sin él, lo escrito hace un momento todavía no cuenta
  compose(service, "sync");
  return compose(service, "cat", "/sys/fs/cgroup/io.stat")
    .split("\n")
    .reduce((sum, line) => sum + Number(/wbytes=(\d+)/.exec(line)?.[1] ?? 0), 0);
}

export const MiB = (bytes: number) => bytes / 1024 / 1024;

// lo que miden las cargas de la Fase 18 queda aquí para que scorecard.ts lo lea; lab/data/ no se versiona
const LEDGER = "lab/data/f18-writes.json";

export function recordWrites(key: string, value: Record<string, number>): void {
  let all: Record<string, Record<string, number>> = {};
  try {
    all = JSON.parse(readFileSync(LEDGER, "utf8"));
  } catch {
    // primera medida
  }
  all[key] = value;
  writeFileSync(LEDGER, JSON.stringify(all, null, 2));
}

export function readWrites(): Record<string, Record<string, number>> {
  return JSON.parse(readFileSync(LEDGER, "utf8"));
}
