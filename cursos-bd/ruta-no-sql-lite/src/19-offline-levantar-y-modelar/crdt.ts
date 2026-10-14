// Tres CRDT de estado, escritos a mano para ver qué hacen por dentro: el conjunto con bajas (OR-Set), el
// contador que solo sube (G-Counter) y el registro de varios valores (MV-Register). Los tres cumplen lo
// mismo: merge(a, b) = merge(b, a), merge(a, merge(b, c)) = merge(merge(a, b), c) y merge(a, a) = a. Por
// eso dos réplicas que se fusionan en cualquier orden llegan al mismo estado, sin preguntarle a nadie.

const union = (a: string[], b: string[]) => [...new Set([...a, ...b])].sort();

/** OR-Set: cada alta lleva una etiqueta única; una baja entierra las etiquetas que vio, no el valor. */
export interface ORSet<T> { adds: Record<string, T>; removed: string[] }
export const orSet = <T>(): ORSet<T> => ({ adds: {}, removed: [] });
export const orAdd = <T>(s: ORSet<T>, tag: string, value: T): ORSet<T> => ({ adds: { ...s.adds, [tag]: value }, removed: s.removed });
export const orRemove = <T>(s: ORSet<T>, match: (v: T) => boolean): ORSet<T> => ({
  adds: s.adds,
  removed: union(s.removed, Object.keys(s.adds).filter((t) => match(s.adds[t]))),
});
export const orValues = <T>(s: ORSet<T>): T[] =>
  Object.keys(s.adds).filter((t) => !s.removed.includes(t)).sort().map((t) => s.adds[t]);
export const orMerge = <T>(a: ORSet<T>, b: ORSet<T>): ORSet<T> => ({ adds: { ...a.adds, ...b.adds }, removed: union(a.removed, b.removed) });

/** G-Counter: una cuenta por réplica que solo sube; el valor es la suma, y fusionar es tomar el máximo. */
export type GCounter = Record<string, number>;
export const gInc = (c: GCounter, replica: string, n: number): GCounter => ({ ...c, [replica]: (c[replica] ?? 0) + n });
export const gMerge = (a: GCounter, b: GCounter): GCounter =>
  Object.fromEntries(union(Object.keys(a), Object.keys(b)).map((k) => [k, Math.max(a[k] ?? 0, b[k] ?? 0)]));

/** MV-Register: cada escritura entierra las que vio; si dos no se vieron, sobreviven las dos. */
export interface MVRegister<T> { writes: Record<string, { value: T; supersedes: string[] }> }
export const mvRegister = <T>(): MVRegister<T> => ({ writes: {} });
export const mvSet = <T>(r: MVRegister<T>, tag: string, value: T): MVRegister<T> => ({
  writes: { ...r.writes, [tag]: { value, supersedes: Object.keys(r.writes).sort() } },
});
export const mvValues = <T>(r: MVRegister<T>): T[] => {
  const buried = new Set(Object.values(r.writes).flatMap((w) => w.supersedes));
  return Object.keys(r.writes).filter((t) => !buried.has(t)).sort().map((t) => r.writes[t].value);
};
export const mvMerge = <T>(a: MVRegister<T>, b: MVRegister<T>): MVRegister<T> => ({ writes: { ...a.writes, ...b.writes } });
