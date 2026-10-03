// La ficha de medición con sus cinco datos obligatorios (guía de estilo §6), lista para pegar en
// un documento y en la bitácora: qué se midió, volumen, motor y digest, máquina, y cómo reproducir.
import { cpus, totalmem } from "node:os";

export interface Ficha {
  id: string; // M-NN
  title: string; // qué se midió, en forma estructural
  volume: string; // 10k, 1m o el volumen de rotura
  datasetSha256: string;
  engine: string; // motor y digest
  baseline?: string; // la línea base, si es otra
  columns: string[];
  rows: (string | number)[][];
  reproduce: string; // el comando exacto
  verifiedOn: string; // DD/MM/AAAA
  withTimes?: boolean; // si aparece algún tiempo, la máquina es obligatoria
}

export const machine = () => `${cpus()[0].model}, ${cpus().length} núcleos, ${Math.round(totalmem() / 2 ** 30)} GB`;

export function formatFicha(f: Ficha): string {
  const lines = [
    `> 📐 **${f.id} — ${f.title}** · ${f.volume} (\`${f.datasetSha256.slice(0, 12)}…\`) · ${f.engine}` +
      `${f.baseline ? ` · línea base ${f.baseline}` : ""} · verificado el ${f.verifiedOn}`,
    ">",
    `> | ${f.columns.join(" | ")} |`,
    `> |${f.columns.map(() => "---").join("|")}|`,
    ...f.rows.map((r) => `> | ${r.join(" | ")} |`),
    ">",
  ];
  if (f.withTimes) lines.push(`> Máquina: ${machine()}. Los tiempos son contexto, no argumento.`, ">");
  lines.push(`> Reproducir: \`${f.reproduce}\``);
  return lines.join("\n");
}
