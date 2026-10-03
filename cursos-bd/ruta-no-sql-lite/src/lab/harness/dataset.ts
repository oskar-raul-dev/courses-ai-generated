// Antes de cargar o medir, se comprueba que el dataset es el que dice su manifiesto: si un solo
// byte cambió, la medición deja de ser comparable con la del curso (a05).
import { createHash } from "node:crypto";
import { createReadStream, readFileSync } from "node:fs";
import { pipeline } from "node:stream/promises";
import { createInterface } from "node:readline";
import { join } from "node:path";

export interface Manifest {
  generatorVersion: string;
  seed: string;
  focus: string;
  volume: string;
  files: Record<string, { records: number; bytes: number; sha256: string }>;
  datasetSha256: string;
}

async function sha256File(path: string): Promise<string> {
  const hash = createHash("sha256");
  await pipeline(createReadStream(path), hash);
  return hash.digest("hex");
}

/** Recalcula el hash de cada archivo y devuelve el manifiesto si todo coincide. */
export async function verifyDataset(dir: string): Promise<Manifest> {
  const manifest = JSON.parse(readFileSync(join(dir, "manifest.json"), "utf8")) as Manifest;
  for (const [name, expected] of Object.entries(manifest.files)) {
    const actual = await sha256File(join(dir, name));
    if (actual !== expected.sha256) {
      throw new Error(`${name}: el hash no coincide con el manifiesto (${actual.slice(0, 12)} ≠ ${expected.sha256.slice(0, 12)})`);
    }
  }
  return manifest;
}

/** Recorre un NDJSON registro a registro, sin cargarlo entero en memoria. */
export async function* readNdjson<T = Record<string, unknown>>(path: string): AsyncGenerator<T> {
  const lines = createInterface({ input: createReadStream(path), crlfDelay: Infinity });
  for await (const line of lines) if (line) yield JSON.parse(line) as T;
}
