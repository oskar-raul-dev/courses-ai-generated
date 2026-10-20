// src/__puente__/rxjs7.test.js — corre igual sobre RxJS 6.6.7 (el repo) y 7.8.1 (una copia descartable).
import * as rxjs from "rxjs";
import { of, combineLatest } from "rxjs";

const major = Number(require("rxjs/package.json").version.split(".")[0]);

test("firstValueFrom: existe en 7 y no en 6", async () => {
  if (major >= 7) expect(await rxjs.firstValueFrom(of(1, 2, 3))).toBe(1);
  else expect(rxjs.firstValueFrom).toBeUndefined();
});

test("toPromise: sigue andando en las dos (en 7, deprecado)", async () => {
  expect(await of(1, 2, 3).toPromise()).toBe(3);
});

test("combineLatest con un arreglo: la forma que sirve en las dos", async () => {
  const values = [];
  combineLatest([of("a"), of("b")]).subscribe((v) => values.push(v));
  expect(values).toEqual([["a", "b"]]);
});
