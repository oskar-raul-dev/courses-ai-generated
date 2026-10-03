// Generador de números pseudoaleatorios propio y sin dependencias: sfc32, sembrado con cyrb128.
// Propio a propósito: una librería podría cambiar su algoritmo en una versión menor y romper el
// determinismo sin avisar. Solo usa aritmética entera de 32 bits, que es idéntica en toda
// plataforma donde corra V8.

export interface Rng {
  /** Entero uniforme en [0, 2^32). */
  u32(): number;
  /** Real uniforme en [0, 1). */
  next(): number;
  /** Entero uniforme en [min, max], ambos incluidos. */
  int(min: number, max: number): number;
  chance(p: number): boolean;
  pick<T>(items: readonly T[]): T;
  /** Elige con pesos: pares [valor, peso]. */
  weighted<T>(items: readonly (readonly [T, number])[]): T;
  /**
   * Flujo independiente para un propósito concreto. Cada entidad usa el suyo, así que añadir
   * una entidad nueva no desplaza los valores de las demás.
   */
  fork(label: string): Rng;
}

function cyrb128(text: string): [number, number, number, number] {
  let h1 = 1779033703, h2 = 3144134277, h3 = 1013904242, h4 = 2773480762;
  for (let i = 0; i < text.length; i++) {
    const k = text.charCodeAt(i);
    h1 = h2 ^ Math.imul(h1 ^ k, 597399067);
    h2 = h3 ^ Math.imul(h2 ^ k, 2869860233);
    h3 = h4 ^ Math.imul(h3 ^ k, 951274213);
    h4 = h1 ^ Math.imul(h4 ^ k, 2716044179);
  }
  h1 = Math.imul(h3 ^ (h1 >>> 18), 597399067);
  h2 = Math.imul(h4 ^ (h2 >>> 22), 2869860233);
  h3 = Math.imul(h1 ^ (h3 >>> 17), 951274213);
  h4 = Math.imul(h2 ^ (h4 >>> 19), 2716044179);
  h1 ^= h2 ^ h3 ^ h4;
  h2 ^= h1;
  h3 ^= h1;
  h4 ^= h1;
  return [h1 >>> 0, h2 >>> 0, h3 >>> 0, h4 >>> 0];
}

export function createRng(seed: string): Rng {
  let [a, b, c, d] = cyrb128(seed);

  const u32 = (): number => {
    a >>>= 0; b >>>= 0; c >>>= 0; d >>>= 0;
    const t = (a + b) | 0;
    a = b ^ (b >>> 9);
    b = (c + (c << 3)) | 0;
    c = (c << 21) | (c >>> 11);
    d = (d + 1) | 0;
    const r = (t + d) | 0;
    c = (c + r) | 0;
    return r >>> 0;
  };

  // se descartan los primeros valores: sfc32 necesita unas vueltas para mezclar el estado
  for (let i = 0; i < 15; i++) u32();

  const rng: Rng = {
    u32,
    next: () => u32() / 4294967296,
    int: (min, max) => min + Math.floor((u32() / 4294967296) * (max - min + 1)),
    chance: (p) => u32() / 4294967296 < p,
    pick: (items) => items[Math.floor((u32() / 4294967296) * items.length)],
    weighted: (items) => {
      let total = 0;
      for (const [, w] of items) total += w;
      let r = (u32() / 4294967296) * total;
      for (const [value, w] of items) {
        if ((r -= w) < 0) return value;
      }
      return items[items.length - 1][0];
    },
    fork: (label) => createRng(`${seed}/${label}`),
  };
  return rng;
}
