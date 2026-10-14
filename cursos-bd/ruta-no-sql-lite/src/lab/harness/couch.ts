// CouchDB y PouchDB en el arnés (a04). La base remota es una URL; la "tableta" es una base local de
// PouchDB en lab/data/tablets/, y "sin señal" quiere decir que no se replica. Lo que viaja se cuenta en el
// cliente, como los viajes de las demás familias: peticiones HTTP y bytes en cada sentido.
import { execFileSync } from "node:child_process";
import { mkdirSync, rmSync } from "node:fs";
import PouchDB from "pouchdb";

const port = Number(process.env.OFFLINE_PORT ?? 15984);
const origin = `http://localhost:${port}`;
const authHeader = "Basic " + Buffer.from("condor:condor").toString("base64");

export type Db = PouchDB.Database<Record<string, any>>;

/** Lo que pasó por el cable: peticiones y bytes de cuerpo enviados (up) y recibidos (down). */
export interface Wire { requests: number; up: number; down: number }
export const newWire = (): Wire => ({ requests: 0, up: 0, down: 0 });

const bodyBytes = (body: unknown): number =>
  typeof body === "string" ? Buffer.byteLength(body) : body instanceof Uint8Array ? body.byteLength : 0;

/** Una base de CouchDB vista desde PouchDB. Con `wire`, cada petición suma al contador. */
export function remote(name: string, wire?: Wire): Db {
  const counted = async (url: string | Request, opts?: RequestInit) => {
    const res: Response = await (PouchDB as any).fetch(url, opts);
    if (!wire) return res;
    // se lee el cuerpo una vez y se le devuelve a PouchDB una respuesta nueva con esos bytes: con
    // res.clone(), la copia a veces quedaba esperando para siempre y el proceso terminaba sin terminar
    // (Fase 20). Y primero se lee, después se suma: `wire.down += await …` leería el total antes de
    // esperar, y dos peticiones en vuelo se pisarían la suma
    const body = await res.arrayBuffer();
    wire.requests++;
    wire.up += bodyBytes(opts?.body);
    wire.down += body.byteLength;
    const empty = [101, 204, 205, 304].includes(res.status);
    return new Response(empty ? null : body, { status: res.status, statusText: res.statusText, headers: res.headers });
  };
  return new PouchDB(`${origin}/${name}`, { auth: { username: "condor", password: "condor" }, fetch: counted } as any);
}

/** La API HTTP de CouchDB a secas, para lo que PouchDB no expone: crear, borrar, _revs_limit, tamaños. */
export async function couch<T = any>(path: string, init: RequestInit = {}): Promise<T> {
  const res = await fetch(`${origin}/${path}`, {
    ...init, headers: { authorization: authHeader, "content-type": "application/json", ...init.headers },
  });
  return (await res.json()) as T;
}

/** Borra y crea una base remota vacía. */
export async function freshRemote(name: string): Promise<void> {
  await couch(name, { method: "DELETE" });
  await couch(name, { method: "PUT" });
}

const TABLETS = "lab/data/tablets";

/** Una tableta nueva: borra la carpeta y abre una base local vacía (LevelDB en Node). */
export function freshTablet(name: string): Db {
  rmSync(`${TABLETS}/${name}`, { recursive: true, force: true });
  return openTablet(name);
}

/** Una tableta que ya existe, como la dejó el último proceso que la cerró. */
export function openTablet(name: string): Db {
  mkdirSync(TABLETS, { recursive: true });
  return new PouchDB(`${TABLETS}/${name}`) as Db;
}

/** Lo que ocupa la carpeta de una tableta en disco (cerrada, para que LevelDB haya escrito todo). */
export function tabletBytes(name: string): number {
  return Number(execFileSync("du", ["-sk", `${TABLETS}/${name}`], { encoding: "utf8" }).split("\t")[0]) * 1024;
}

/** Ids de los documentos con conflictos, y cuántas revisiones perdedoras suman. */
export async function conflicts(db: Db): Promise<{ docs: string[]; losers: number }> {
  const all = await db.allDocs({ include_docs: true, conflicts: true });
  const docs = all.rows.filter((r) => r.doc?._conflicts?.length).map((r) => r.id);
  const losers = all.rows.reduce((n, r) => n + (r.doc?._conflicts?.length ?? 0), 0);
  return { docs, losers };
}

/** Todas las hojas de un documento: la ganadora y las que perdieron, con su cuerpo. */
export async function leaves(db: Db, id: string): Promise<any[]> {
  const got = await db.get(id, { open_revs: "all" } as any) as unknown as { ok?: any }[];
  return got.filter((g) => g.ok && !g.ok._deleted).map((g) => g.ok);
}
