# 🎲 Apéndice A14 — Estadística mínima para auditar una rueda
## Tutorial React 16 — La Esclusa, la consola de Jewel Locks

> **Material de consulta rápida** · **~3 horas** · Lo usan la Fase 8 (conciliación), la Fase 9 (la banda en el
> dashboard), la Fase 10 (probar algo aleatorio) y, en el track BE, `be07` · Prioridad: 🔴 Alta

Esto no se lee de corrido. Es la página que abres cuando `oddsAudit` pinta una fila en rojo y alguien pregunta si la rueda está arreglada, o cuando tienes que decidir cuántos giros hacen falta antes de contestar.

No es un curso de estadística. Es la estadística **justa** para contestar una pregunta con números: *¿la rueda gira con los pesos que publica?* Todo lo que hace falta es una distribución (la binomial), dos herramientas (la banda de ±3σ y el chi-cuadrado), una idea incómoda (una rueda honesta da falsas alarmas) y un límite (lo que esta auditoría no puede probar). El valor crítico del chi-cuadrado se da hecho: no vas a calcular una tabla.

Todos los números de esta página salen de una corrida: el `oddsAudit` y el generador sembrado de bitácoras de la Fase 8, y una simulación de 100.000 bitácoras que está en §5.

---

## 🧭 Índice de salto rápido

1. [La ley de grandes números](#1-la-ley-de-grandes-números)
2. [Un segmento es una binomial](#2-un-segmento-es-una-binomial)
3. [La banda de ±3σ](#3-la-banda-de-3σ)
4. [El chi-cuadrado, sin tabla](#4-el-chi-cuadrado-sin-tabla)
5. [Falsas alarmas, y cuánta muestra hace falta](#5-falsas-alarmas-y-cuánta-muestra-hace-falta)
6. [Lo que esta auditoría no prueba](#6-lo-que-esta-auditoría-no-prueba)
7. [🧩 Cuándo usar qué](#-cuándo-usar-qué)
8. [🧪 Ejercicios](#-ejercicios-8)

---

## 1. La ley de grandes números

La Esclusa de Oro pesa 50 puntos básicos: 0,5 % de los giros. Eso no significa que de cada 200 giros salga una. Significa que, **a medida que crecen los giros, la frecuencia observada se acerca a 0,5 %**. Es la ley de grandes números, y la bitácora sembrada de la Fase 8 la muestra con la Rueda de fin de mes, que es honesta:

```javascript
test("§1: la frecuencia de la Esclusa de Oro se acerca a 0,5 % a medida que crecen los giros", () => {
  const goldOf = (spins) => honest(42, spins)[7];
  expect([100, 1000, 10000, 100000].map(goldOf)).toEqual([1, 6, 57, 484]);
  // 1 % · 0,6 % · 0,57 % · 0,484 %: el desvío relativo baja; el absoluto, no
});
```

| Giros | Esclusas de Oro | Frecuencia | Desvío contra el esperado |
|---|---|---|---|
| 100 | 1 | 1 % | +0,5 (esperado 0,5) |
| 1.000 | 6 | 0,6 % | +1 (esperado 5) |
| 10.000 | 57 | 0,57 % | +7 (esperado 50) |
| 100.000 | 484 | 0,484 % | −16 (esperado 500) |

Mira las dos últimas columnas a la vez, porque ahí está todo el apéndice. La **frecuencia** se acerca a 0,5 %: el desvío **relativo** baja. Pero el desvío **absoluto** crece: con 100.000 giros faltan 16 Esclusas de Oro, más que las 7 que sobraban con 10.000. Eso no es un problema de la rueda. Es como funciona el azar, y por eso la pregunta "¿cuánto se puede alejar?" necesita una respuesta que dependa de cuántos giros hay. Esa respuesta es σ.

> 🧠 **El error de intuición más común.** *"Si la rueda es honesta, con muchos giros va a dar casi exacto."* La frecuencia, sí. El conteo, no: se aleja cada vez más del esperado, solo que más despacio de lo que crecen los giros. Por eso no se auditan conteos contra el esperado a ojo.

---

## 2. Un segmento es una binomial

Cada giro es un ensayo independiente con dos resultados para un segmento dado: cae en él, con probabilidad `p` (su peso dividido por 10.000), o no. El número de veces que un segmento sale en `n` giros es una variable **binomial**, con dos números que la describen:

- **El esperado:** `n · p`. Con 10.000 giros, 50 para la Esclusa de Oro.
- **La desviación estándar:** `σ = √(n · p · (1 − p))`. Con 10.000 giros, 7,05 para la Esclusa de Oro.

σ es la escala natural del azar para ese segmento con esa cantidad de giros. Los pesos de la rueda de la historia (§8), con 10.000 giros:

| Segmento | Peso | Esperado | σ | Banda de ±3σ | Banda relativa |
|---|---|---|---|---|---|
| sin-premio | 3.000 | 3.000 | 45,83 | 2.862,5 – 3.137,5 | ±4,6 % |
| vidas-2 | 2.000 | 2.000 | 40,00 | 1.880,0 – 2.120,0 | ±6,0 % |
| avatar-comun | 1.500 | 1.500 | 35,71 | 1.392,9 – 1.607,1 | ±7,1 % |
| set-gemas-basico | 1.500 | 1.500 | 35,71 | 1.392,9 – 1.607,1 | ±7,1 % |
| vidas-5 | 1.000 | 1.000 | 30,00 | 910,0 – 1.090,0 | ±9,0 % |
| set-gemas-plata | 800 | 800 | 27,13 | 718,6 – 881,4 | ±10,2 % |
| avatar-raro | 150 | 150 | 12,16 | 113,5 – 186,5 | ±24,3 % |
| esclusa-de-oro | 50 | 50 | 7,05 | 28,8 – 71,2 | ±42,3 % |

La última columna es la que conviene memorizar. Para el segmento grande, 10.000 giros alcanzan para ver un desvío de 5 %. Para la Esclusa de Oro, la banda va de 29 a 71: **cualquier cosa entre 0,29 % y 0,71 % es compatible con una rueda honesta**. Un segmento raro necesita muchos más giros para decir algo (§5).

> 📝 **Una aproximación honesta.** La binomial supone giros independientes con la misma probabilidad. Con la regla nueva (protección con sustituto) es exactamente así: la rueda no cambia sus pesos. Con la regla vieja, la que se acomoda, cada jugador giraba con pesos distintos, y por eso la auditoría la detecta.

---

## 3. La banda de ±3σ

Una binomial con muchos ensayos se parece a una normal, y en una normal **el 99,73 % de los valores cae a menos de 3σ del esperado**. La banda de ±3σ usa eso: si un segmento sale fuera de su banda, la probabilidad de que el azar lo explique es 0,27 %. No es cero, y es lo bastante chica como para pedir una explicación.

`oddsAudit` no calcula la raíz. La condición `|c − e| > 3σ`, con `e = n·w / 10.000`, multiplicada por 10.000 y elevada al cuadrado, queda entera:

```text
(c · 10.000 − n · w)²  >  9 · n · w · (10.000 − w)
```

Y en el borde se comporta como la tabla de §2, que dice 71,2:

```javascript
test("§3: con 10.000 giros, 71 Esclusas de Oro está en la banda y 72 no", () => {
  // Los giros de más de la Esclusa de Oro salen de sin-premio: n sigue siendo 10.000.
  const with71 = [2979, 2000, 1500, 1500, 1000, 800, 150, 71];
  const with72 = [2978, 2000, 1500, 1500, 1000, 800, 150, 72];
  expect(with71.reduce((a, b) => a + b, 0)).toBe(10000);
  expect(oddsAudit(with71, weights).bandAlarms).toEqual([]);
  expect(oddsAudit(with72, weights).bandAlarms).toEqual([7]);
});
```

> ⚠️ **La banda es por segmento, y hay ocho.** Cada uno tiene un 0,27 % de falsa alarma. Ocho bandas juntas dan, en la simulación de §5, un **1,99 %** de bitácoras honestas con alguna banda en rojo. Mirar más segmentos es mirar más veces, y cada mirada es una oportunidad de ver una alarma que no existe.

---

## 4. El chi-cuadrado, sin tabla

La banda mira los segmentos de a uno. El **chi-cuadrado** los junta en un solo número:

```text
χ² = Σ (observado − esperado)² / esperado
```

Cada término es el desvío de un segmento al cuadrado, medido contra su esperado. Si la rueda es honesta, χ² tiende a ser chico; si gira con otros pesos, crece con los giros. La pregunta es cuánto es "grande", y la respuesta depende de dos cosas:

- **Los grados de libertad:** segmentos menos uno. Con ocho segmentos, 7. (Si sabes siete conteos y el total, el octavo no es libre.)
- **El nivel de significancia, α:** cuánta falsa alarma estás dispuesto a aceptar. El curso usa α = 0,05.

Con 7 grados y α = 0,05, el **valor crítico es 14,067**. Es un número de tabla, y `oddsAudit` lo trae como constante con nombre (`CHI2_CRITICAL_DF7_05`). Si χ² lo supera, hay alarma.

```javascript
test("§4: la bitácora sembrada de la Fase 8 da χ² = 4,49, lejos del crítico", () => {
  const r = oddsAudit(honest(42, 10000), weights);
  expect(r.chi2).toBeCloseTo(4.4877, 4);
  expect(r.chi2).toBeLessThan(CHI2_CRITICAL_DF7_05);
});
```

Las tres bitácoras de la Fase 8, puestas en esta escala: la honesta da 4,49; la misma bitácora contada por premio entregado, 1.335; la regla vieja, 808. Las dos últimas no están "un poco" por encima del crítico: están cien veces por encima.

> ⚠️ **El chi-cuadrado pide esperados de al menos 5.** La aproximación que da el valor crítico deja de valer cuando algún segmento espera menos de 5. Para la Esclusa de Oro, eso son **1.000 giros**. Con menos, el número existe pero la tabla no le aplica.

---

## 5. Falsas alarmas, y cuánta muestra hace falta

**α = 0,05 significa que una rueda honesta da alarma en el 5 % de las conciliaciones.** No es un defecto de la herramienta: es su definición. Si no quisieras ninguna falsa alarma, tendrías que no dar ninguna alarma.

La simulación lo confirma con 100.000 bitácoras honestas de 10.000 giros cada una, auditadas con la misma regla que `oddsAudit`:

```javascript
// scripts/false-alarms.js — las cifras de A14: σ y banda por segmento, la muestra para el
// segmento raro, y la tasa de falsas alarmas de una rueda honesta, simulada.
//   node scripts/false-alarms.js 100000   (100.000 simulaciones de 10.000 giros; unos 30 s)
const W = [3000, 2000, 1500, 1500, 1000, 800, 150, 50];
const NAMES = ["sin-premio", "vidas-2", "avatar-comun", "set-gemas-basico", "vidas-5", "set-gemas-plata", "avatar-raro", "esclusa-de-oro"];
const N = 10000, SIMS = Number(process.argv[2] || 100000), CRIT = 14.067;
console.log("n =", N);
W.forEach((w, i) => {
  const p = w / 10000, e = N * p, s = Math.sqrt(N * p * (1 - p));
  console.log(NAMES[i].padEnd(17), "p", p, "esperado", e, "σ", s.toFixed(2), "banda", (e - 3 * s).toFixed(1), "–", (e + 3 * s).toFixed(1), "relativa ±", (300 * s / e).toFixed(1) + " %");
});
// Muestra mínima: (a) para que el esperado del raro llegue a 5 (regla del chi-cuadrado);
// (b) para que pasar de 0,5 % a 1 % y a 2 % quede a más de 3σ del esperado.
const p0 = 0.005;
console.log("esperado ≥ 5 en el raro: n ≥", Math.ceil(5 / p0));
for (const p1 of [0.01, 0.02]) {
  const n = Math.ceil((9 * p0 * (1 - p0)) / ((p1 - p0) ** 2));
  console.log(`de 0,5 % a ${p1 * 100} % a 3σ: n ≥`, n);
}
function mulberry32(a) { return function () { a = (a + 0x6d2b79f5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; }; }
const cum = []; W.reduce((acc, w) => { cum.push(acc + w); return acc + w; }, 0);
const rnd = mulberry32(20261016);
let band = 0, chi = 0, either = 0; const perSeg = W.map(() => 0);
const t0 = Date.now();
for (let s = 0; s < SIMS; s++) {
  const c = [0, 0, 0, 0, 0, 0, 0, 0];
  for (let i = 0; i < N; i++) { const r = Math.floor(rnd() * 10000); let k = 0; while (r >= cum[k]) k++; c[k]++; }
  let b = false, x2 = 0;
  W.forEach((w, i) => { const d = c[i] * 10000 - N * w; if (d * d > 9 * N * w * (10000 - w)) { b = true; perSeg[i]++; } x2 += (d * d) / (10000 * N * w); });
  if (b) band++; if (x2 > CRIT) chi++; if (b || x2 > CRIT) either++;
}
const pct = (k) => (100 * k / SIMS).toFixed(2) + " %";
console.log(`${SIMS} simulaciones de ${N} giros (rueda honesta, semilla 20261016), ${((Date.now() - t0) / 1000).toFixed(0)} s`);
console.log("alarma de banda:", band, pct(band), "· chi-cuadrado:", chi, pct(chi), "· cualquiera:", either, pct(either));
console.log("banda por segmento:", NAMES.map((n, i) => `${n} ${pct(perSeg[i])}`).join(" · "));
```

```text
100000 simulaciones de 10000 giros (rueda honesta, semilla 20261016), 32 s
alarma de banda: 1993 1.99 % · chi-cuadrado: 5037 5.04 % · cualquiera: 5545 5.54 %
banda por segmento: sin-premio 0.25 % · vidas-2 0.25 % · avatar-comun 0.24 % · set-gemas-basico 0.23 % · vidas-5 0.26 % · set-gemas-plata 0.27 % · avatar-raro 0.28 % · esclusa-de-oro 0.24 %
```

Las tres cifras, en una línea cada una:

- **Chi-cuadrado: 5,04 %.** Lo que α promete.
- **Banda: 1,99 %.** Ocho segmentos de 0,27 % cada uno, que no son del todo independientes (si uno sale de más, otro sale de menos).
- **Cualquiera de las dos: 5,54 %.** Más o menos **una de cada dieciocho** conciliaciones de una rueda honesta va a tener algo en rojo.

Por eso una alarma es una pregunta, no una condena. Lo que se hace con ella es **juntar más evidencia**: la conciliación de la rueda siguiente, más giros, la bitácora por jugador. Una rueda honesta da una alarma de vez en cuando; una arreglada la da siempre.

### Cuánta muestra para un segmento raro

Depende de qué quieras poder ver:

| Pregunta | Giros necesarios |
|---|---|
| Que el chi-cuadrado valga (esperado ≥ 5 en la Esclusa de Oro) | 1.000 |
| Que la Esclusa de Oro al 1 % (el doble) quede a 3σ de su 0,5 % | 1.791 |
| Que la Esclusa de Oro al 2 % (el cuádruple) quede a 3σ de su 0,5 % | 199 |

La cuenta es `n ≥ 9 · p₀ · (1 − p₀) / (p₁ − p₀)²`: la distancia que quieres ver tiene que ser al menos 3σ. Pero quedar "a 3σ" es el borde: con esa muestra, la mitad de las veces el azar te la acerca y no la ves. Lo que importa en la práctica es la **potencia**: en cuántas bitácoras de una rueda arreglada la auditoría da alarma. Con la regla vieja de la casa, 300 bitácoras por tamaño:

```javascript
test("§5: la rueda que se acomoda se detecta casi siempre desde 1.000 giros", () => {
  const detected = (spins) => {
    let alarms = 0;
    for (let s = 1; s <= 300; s++) {
      const log = generateSpinLog({ seed: 1000 + s, spins, wheelId: 4, segments, rule: "accommodating" });
```

| Giros por bitácora | Bitácoras con alarma |
|---|---|
| 200 | 69 de 300 (23 %) |
| 500 | 211 de 300 (70 %) |
| 1.000 | 299 de 300 |
| 2.000 | 300 de 300 |

Un día normal de la Esclusa tiene unos 60.000 giros entre todas sus ruedas (historia §8), y una rueda que dura semanas, como la de la Fase 8, junta decenas de miles: sobra. Una rueda de un evento chico, de un par de horas, puede no llegar, y una conciliación con 200 giros que no da alarma **no dice que la rueda sea honesta**: dice que no hubo giros para saberlo.

---

## 6. Lo que esta auditoría no prueba

Que las frecuencias cuadren dice que la rueda gira **con los pesos publicados**. No dice que nadie pueda **adivinar el próximo giro**. Son dos propiedades distintas, y la auditoría solo ve la primera:

```javascript
test("§6: un generador sembrado pasa la auditoría y es completamente predecible", () => {
  const a = generateSpinLog({ seed: 42, spins: 10000, wheelId: 4, segments });
```

El generador de la Fase 8 pasa la auditoría sin una alarma, y es **completamente predecible**: con la semilla, se conocen los 10.000 giros antes de que ocurran. Para simular está perfecto, que es su trabajo. Para una rueda donde los jugadores pagan, sería un desastre que ninguna conciliación de frecuencias detectaría.

Eso no es teoría: es el incidente `be-17` del track BE. En Go 1.19, `math/rand` sin semilla arranca **siempre con la misma secuencia**, y una rueda que gira con él da las mismas frecuencias —honestas— en el mismo orden cada vez que el servidor reinicia. La herramienta para esa pregunta es otra: un generador criptográfico (`crypto/rand` en Go, `crypto.getRandomValues` en el navegador) y, si hace falta probarlo, baterías de pruebas de aleatoriedad que no son de este curso.

> 🧭 **La frase para la reunión.** *"La conciliación dice que la rueda cumple sus pesos. Que nadie pueda predecirla depende de con qué gira, y eso se revisa en el código del servidor, no en la bitácora."*

---

## 🧩 Cuándo usar qué

- **¿La rueda, en conjunto, gira con sus pesos?** → chi-cuadrado (§4), con al menos 5 de esperado en cada segmento.
- **¿Qué segmento se alejó?** → la banda de ±3σ (§3), segmento por segmento.
- **Una sola alarma** → más evidencia antes de concluir: otra rueda, más giros, otro período (§5).
- **¿Cuántos giros necesito?** → la tabla de §5, o la cuenta `9 · p₀ · (1 − p₀) / (p₁ − p₀)²` para el desvío que te importa.
- **¿El aleatorio es impredecible?** → no lo contesta ninguna de estas herramientas (§6).
- **Probar código que usa azar sin que la prueba sea intermitente** → generador sembrado y una tolerancia calculada con esta misma estadística (Fase 10).

---

## 🧪 Ejercicios (8)

1. **🟢** Calcula a mano el esperado y σ de vidas-5 con 10.000 giros y compáralos con la tabla de §2. **Criterio:** 1.000 y 30,00.
2. **🟢** Con la tabla de §2, di si 1.130 veces vidas-5 en 10.000 giros está dentro de la banda. **Criterio:** no (la banda llega a 1.090), y lo confirmas con `oddsAudit`.
3. **🟡** Repite la tabla de §1 con la semilla 7. **Criterio:** los cuatro conteos de la Esclusa de Oro, y una frase sobre si el desvío absoluto vuelve a crecer.
4. **🟡** Cambia α a 0,01: el valor crítico con 7 grados es 18,475. Corre la simulación de §5 con ese valor (cambia `CRIT`). **Criterio:** la tasa del chi-cuadrado baja a cerca de 1 %; explica qué perdiste a cambio (pista: la potencia de la tabla de §5).
5. **🟡** Calcula con la fórmula de §5 cuántos giros hacen falta para que el avatar raro al 3 % (el doble de su 1,5 %) quede a 3σ. **Criterio:** el número, y por qué es mucho menor que el de la Esclusa de Oro al doble.
6. **🟠** Corre la simulación de §5 con 200 giros por bitácora en vez de 10.000 (cambia `N`): la Esclusa de Oro espera 1. **Criterio:** la banda da alarma en cerca del doble de bitácoras honestas (alrededor de 4 % contra 2 %) y el chi-cuadrado se aleja del 5 % prometido; explícalo con la advertencia del final de §4.
7. **🟠** Escribe una prueba que demuestre que `oddsAudit` y la simulación de §5 dan la misma alarma para los mismos conteos. **Criterio:** 1.000 bitácoras sembradas, cero diferencias.
8. **🔴** Diseña la auditoría para la rueda de un evento de dos horas con 3.000 giros: ¿qué segmentos pueden auditarse con la banda y cuáles no? ¿Qué harías con los demás? **Criterio:** una tabla por segmento con su esperado y su banda relativa, y una propuesta escrita para los que no alcanzan (juntar eventos, auditar por grupo de premios).

**🔥 Opcionales**

- 🔥 Mide la falsa alarma de la banda sola con 8 segmentos y con 4, y explica por qué no es exactamente 8 · 0,27 %.
- 🔥 Implementa la prueba exacta de la binomial para la Esclusa de Oro (sin aproximar por la normal) y compárala con la banda en una bitácora de 1.000 giros.

---

## 📚 Referencias

- NIST/SEMATECH *e-Handbook of Statistical Methods* — la prueba de bondad de ajuste de chi-cuadrado, con su tabla de valores críticos: https://www.itl.nist.gov/div898/handbook/eda/section3/eda35f.htm
- La distribución binomial, en el mismo manual: https://www.itl.nist.gov/div898/handbook/eda/section3/eda366i.htm
- La política de Google Play sobre artículos aleatorios —las probabilidades se publican antes de la compra—: https://support.google.com/googleplay/android-developer/answer/9858738
- `crypto.getRandomValues` — https://developer.mozilla.org/es/docs/Web/API/Crypto/getRandomValues — el aleatorio criptográfico del navegador, para §6.

> ⚠️ Las URL pueden haber cambiado desde la redacción; verifícalas. Los valores críticos de la tabla (14,067 con 7 grados y α = 0,05; 18,475 con α = 0,01) son estándar y puedes contrastarlos con cualquier tabla de chi-cuadrado.

**Orden de lectura sugerido:** §1 y §2 (el porqué de σ) → §3 y §4 (las dos herramientas) → la Fase 8, §5.4 → §5 y §6 cuando tengas que defender una conclusión.

---

## 🚀 Y ahora, de vuelta al código

Si viniste desde la Fase 8, vuelve a `oddsAudit.js`: ahora sabes por qué la banda se compara al cuadrado y por qué el 14,067 viene hecho. Si viniste porque una fila se pintó de rojo, §5 es la respuesta para la reunión: una alarma es una pregunta.

> **La señal de que quedó bien:** cuando alguien te muestre una alarma y tu primera pregunta sea *"¿con cuántos giros, y cuántas conciliaciones honestas dan alarma con esa muestra?"*.

---

> 🏷️ **Este apéndice no lleva tag propio.** Si de él sale código —la simulación de §5 en `scripts/`, un ejercicio—, commitéalo con el prefijo de la fase desde la que llegaste (`f08: …`), y si el ejercicio produjo una medición, el número va en el mensaje del tag (`ej/a14/4`). Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
