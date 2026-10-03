// Escritor NDJSON que calcula el SHA-256 del archivo mientras escribe. El hash es la prueba de
// determinismo: el mismo comando tiene que dar los mismos bytes en cualquier máquina.
import { createHash, type Hash } from "node:crypto";
import { closeSync, openSync, writeSync } from "node:fs";
import { join } from "node:path";

const FLUSH_BYTES = 1 << 20;
const encoder = new TextEncoder();

export interface FileSummary {
  records: number;
  bytes: number;
  sha256: string;
}

export class NdjsonWriter {
  readonly name: string;
  private fd: number;
  private hash: Hash = createHash("sha256");
  private buffer: string[] = [];
  private bufferedBytes = 0;
  private records = 0;
  private bytes = 0;

  constructor(dir: string, name: string) {
    this.name = name;
    this.fd = openSync(join(dir, name), "w");
  }

  write(record: object): void {
    const line = JSON.stringify(record) + "\n";
    this.buffer.push(line);
    this.bufferedBytes += line.length;
    this.records++;
    if (this.bufferedBytes >= FLUSH_BYTES) this.flush();
  }

  private flush(): void {
    if (this.buffer.length === 0) return;
    // TextEncoder da los mismos bytes UTF-8 que Buffer, con tipos que TypeScript 7 acepta
    const chunk = encoder.encode(this.buffer.join(""));
    writeSync(this.fd, chunk);
    this.hash.update(chunk);
    this.bytes += chunk.length;
    this.buffer = [];
    this.bufferedBytes = 0;
  }

  close(): FileSummary {
    this.flush();
    closeSync(this.fd);
    return { records: this.records, bytes: this.bytes, sha256: this.hash.digest("hex") };
  }
}
