# 💰 Apéndice A10 — Aritmética de dinero en JavaScript

> Tutorial React 16 — Rifas y chances · Apéndice de **consulta rápida** · **~2 horas**
> Lo usan: Fase 8 (liquidación) y Fase 9 (dashboard) · Prioridad: 🔴 Alta
> No es lectura secuencial: salta al bloque que necesites.

Esto no se lee de corrido. Es la página que abres cuando tienes que tocar
cualquier línea que sume, multiplique, divida o muestre plata, y quieres estar
seguro de no perder un centavo por el camino.

Es también el único apéndice que funciona como **prerrequisito**: la Fase 8
asume que `money.js` ya existe y que sabes por qué está escrito así. Si vas
entrando a la Fase 8, lee §1 y §2 de acá primero —veinte minutos— y vuelve.

> 📝 **De dónde sale este apéndice.** Vivía dentro de la Fase 8, que era el
> archivo más largo del curso y mezclaba dos temas distintos: la aritmética
> entera —universal, aplica a cualquier sistema con dinero, se consulta muchas
> veces— y la liquidación de una rifa —dominio puro, se lee una vez—. Se
> separaron por eso.

---

## 🧭 Índice de salto rápido

1. [Por qué el dinero no se representa con floats](#1-por-qué-el-dinero-no-se-representa-con-floats)
2. [El redondeo, que es donde de verdad se pierde plata](#2-el-redondeo-que-es-donde-de-verdad-se-pierde-plata)
3. [`money.js`: la frontera de entrada y salida](#3-moneyjs-la-frontera-de-entrada-y-de-salida)
4. [Repartir sin perder ni inventar centavos](#4-repartir-sin-perder-ni-inventar-centavos)
5. [Migrar un sistema que ya guarda pesos](#5-migrar-un-sistema-que-ya-guarda-pesos)
6. [Cómo se ve el bug, y cómo se caza](#6-cómo-se-ve-el-bug-y-cómo-se-caza)
7. [Por qué no usamos una librería](#7-por-qué-no-usamos-una-librería)
8. [🧩 Cuándo usar qué](#-cuándo-usar-qué)
9. [🧪 Ejercicios](#-ejercicios-9)

---

## 1. Por qué el dinero no se representa con floats

JavaScript tiene un solo tipo numérico, `number`, que es un flotante de
doble precisión (IEEE 754). Ese formato **no puede representar exactamente**
muchos decimales que a ti te parecen triviales. El caso canónico:

```javascript
0.1 + 0.2            // 0.30000000000000004
0.1 + 0.2 === 0.3    // false
```

No es un bug de JavaScript: es cómo funciona la aritmética binaria de punto
flotante en casi todos los lenguajes. El problema es que `0.1` en binario es
un decimal periódico infinito, igual que `1/3` lo es en decimal. Al
truncarlo a 64 bits, arrastras un error minúsculo. Sumas muchos de esos
errores minúsculos a lo largo de una liquidación con cientos de números
vendidos, y terminas con **centavos que aparecen o desaparecen de la nada**.
En dinero, un centavo que no cuadra no es un error de redondeo simpático: es
una liquidación que no se puede auditar.

**La solución que usa toda la industria** (Stripe, bancos, sistemas
contables) es no guardar nunca "pesos con decimales" como float, sino
**guardar la unidad mínima indivisible como entero**. Para pesos con
céntimos, esa unidad es el centavo. `$5.000,00` se guarda como `500000`
(centavos), no como `5000.0`. Todos los cálculos se hacen sobre enteros —que
JavaScript **sí** representa exactamente hasta `Number.MAX_SAFE_INTEGER`,
2⁵³−1, más que suficiente para cualquier rifa— y solo al **mostrar** se
convierte a la representación con separador decimal.

> 📝 **Nota de dominio (COP y por qué igual usamos centavos).** La rifa vive
> en Colombia y la moneda es el peso colombiano (COP), que en la práctica
> cotidiana **no** usa centavos: nadie paga $5.000,50 por un número. Podría
> tentarte trabajar en pesos enteros directamente y olvidarte del problema.
> **No lo hacemos, a propósito.** El sistema maneja dinero con precisión de
> céntimos por herencia de las integraciones que el contratista de 2019 dejó
> cableadas, y el punto pedagógico es más profundo que "COP no tiene
> decimales": **los floats no son confiables para dinero, tenga o no tenga
> centavos la moneda en la calle.** Trabajar en centavos te entrena en la
> disciplina correcta —la unidad atómica entera— que aplica a cualquier
> moneda. Un `basePrize` de $5.000,00 COP se representa como `500000`
> centavos; lo que en la calle es "cinco mil pesos" en el store es "quinientos
> mil centavos", entero, exacto.

---

## 2. El redondeo, que es donde de verdad se pierde plata

Sumar y restar enteros nunca pierde precisión. El problema aparece con la
**división**, y la liquidación divide: repartir un premio, calcular una
fracción, prorratear. Cuando divides enteros, el resto no siempre es cero, y
ahí tienes que decidir qué hacer con la fracción sobrante. Tres cosas
importan:

**Primero, divide lo último posible y sobre enteros.** No conviertas a
decimal para dividir "cómodo" y después redondees: cada conversión a float
reintroduce el error que estás tratando de evitar. Mantén enteros y usa
división entera (`Math.floor(a / b)`) más el resto (`a % b`) explícito.

**Segundo, elige una regla de redondeo y hazla explícita.** `Math.round`
redondea `.5` siempre hacia arriba (`Math.round(2.5) === 3`,
`Math.round(-2.5) === -2` —ojo con negativos), lo que introduce un sesgo
sistemático si redondeas muchos valores. Para dinero, la regla más común es
**truncar hacia abajo con `Math.floor` y asignar el resto de forma
determinista** (por ejemplo, el último centavo va a una parte fija), de
modo que la suma de las partes sea **exactamente** igual al total. Esa
propiedad —que las partes sumen el todo, sin centavos colgando— es la que
hace una liquidación auditable.

**Tercero, el redondeo silencioso es el enemigo.** Un `Math.round` metido a
mitad de un cálculo, sin comentario, "para que quede lindo", es como se
pierden centavos sin que nadie se dé cuenta hasta que contabilidad reclama.
Toda operación de redondeo del proyecto es explícita, comentada, y tiene su
prueba. Sin excepciones: un `Math.round` sin comentario al lado es, en este
sistema, un hallazgo de revisión de código.

---

## 3. `money.js`: la frontera de entrada y de salida

Todo el dinero del sistema cruza por **un solo archivo**, en las dos
direcciones. Nada entra sin pasar por `toCents` y nada se muestra sin pasar por
`formatCents`. Esa disciplina es lo que convierte "en algún lado se pierde un
centavo" en "se pierde acá, y acá están los tests".

```javascript
// src/features/settlements/money.js
// Punto único de conversión entre la representación que ve el usuario
// (pesos con separador) y la representación interna (centavos, entero).
// TODO el dinero cruza por acá. Si un centavo se pierde, se pierde acá,
// y por eso acá es donde ponemos los tests más finos.

/**
 * Convierte una entrada de usuario (string o number en PESOS) a un entero
 * en CENTAVOS. Es la única puerta de entrada del dinero al sistema.
 *
 * Rechaza entradas que no pueda representar de forma exacta: si alguien
 * escribe más decimales que los que un centavo admite, es un error del
 * llamador, no algo que redondeemos en silencio.
 *
 * @param {string | number} input - monto en pesos, p. ej. "5000" o 5000.50
 * @returns {number} entero de centavos, p. ej. 500000 o 500050
 */
export function toCents(input) {
  // Normalizamos a string para no depender de cómo JS imprime el number.
  const raw = String(input).trim();

  // Aceptamos separador decimal con punto; el separador de miles se asume
  // ya removido por la capa de formulario (no adivinamos formatos locales
  // acá: eso es responsabilidad del input, no del conversor de dinero).
  if (!/^-?\d+(\.\d{1,2})?$/.test(raw)) {
    throw new Error(`Monto inválido para convertir a centavos: "${raw}"`);
  }

  const [pesosPart, centsPart = ''] = raw.split('.');
  const sign = pesosPart.startsWith('-') ? -1 : 1;
  const pesos = Math.abs(parseInt(pesosPart, 10));

  // Rellenamos a dos dígitos SIN usar floats: "5" -> "50" centavos,
  // "" -> "00". Nada de multiplicar por 100 en punto flotante.
  const cents = parseInt(centsPart.padEnd(2, '0'), 10);

  return sign * (pesos * 100 + cents);
}

/**
 * Convierte un entero de centavos a un string en PESOS para mostrar.
 * Es la única puerta de SALIDA del dinero hacia la interfaz.
 *
 * No usa toLocaleString con decimales sobre un float: parte el entero en
 * pesos y centavos con aritmética entera y arma el string a mano.
 *
 * @param {number} cents - entero de centavos, p. ej. 500050
 * @returns {string} representación en pesos, p. ej. "5.000,50"
 */
export function formatCents(cents) {
  if (!Number.isInteger(cents)) {
    // Si esto explota, alguien metió un float donde debía haber un entero:
    // es exactamente el bug que esta fase persigue. Fallamos ruidosamente.
    throw new Error(`formatCents espera un entero de centavos, recibió: ${cents}`);
  }

  const sign = cents < 0 ? '-' : '';
  const abs = Math.abs(cents);
  const pesos = Math.floor(abs / 100);   // división entera: sin float
  const remainder = abs % 100;           // resto exacto: 0..99

  // Separador de miles a mano para no depender de toLocaleString con floats.
  const pesosStr = String(pesos).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  const centsStr = String(remainder).padStart(2, '0');

  return `${sign}${pesosStr},${centsStr}`;
}
```

> **Detalle con intención.** Fíjate que `toCents` **nunca multiplica por
> 100 en float**. La tentación obvia es `Math.round(parseFloat(raw) * 100)`,
> y funciona… casi siempre. `parseFloat("5000.10") * 100` da
> `500009.9999999999`, y ahí `Math.round` te salva por poco. Pero apoyarte
> en que `Math.round` "te salve" es precisamente la clase de redondeo
> silencioso que buscamos erradicar. Partir el string y trabajar los
> centavos como enteros elimina el float de raíz.

---

## 4. Repartir sin perder ni inventar centavos

Sumar y restar enteros nunca pierde precisión. El problema aparece con la
**división**, y todo sistema con dinero divide tarde o temprano: repartir un
premio entre varios ganadores, prorratear una comisión, partir un total en
cuotas.

La propiedad que hay que preservar tiene nombre y es innegociable: **las partes
deben sumar exactamente el todo**. No "aproximadamente". Exactamente. Una
liquidación donde las partes suman 99,99 de un total de 100,00 no está "casi
bien": está mal, y alguien de contabilidad lo va a encontrar antes que tú.

El patrón es siempre el mismo y cabe en tres líneas: **división entera para la
parte, resto explícito, y el resto repartido de a un centavo entre los primeros.**

```javascript
// src/features/settlements/settlementMath.js (extracto)
/**
 * Reparte un premio entre N ganadores SIN perder ni inventar un centavo.
 * No es código base (el mock tiene un ganador único), pero es el patrón
 * canónico de "las partes suman exactamente el todo" y el corazón del
 * redondeo determinista. Se usa en un ejercicio 🔴.
 *
 * Estrategia: división entera para la parte base de cada uno, y el resto
 * (siempre < N) se reparte de a un centavo entre los primeros ganadores.
 * Así la suma de las partes es EXACTAMENTE prizeAmount, sin floats.
 *
 * @param {number} prizeAmount - premio total en centavos (entero)
 * @param {number} winners     - cantidad de ganadores (entero > 0)
 * @returns {number[]} arreglo de centavos por ganador; su suma === prizeAmount
 */
export function prizeShare(prizeAmount, winners) {
  if (!Number.isInteger(prizeAmount) || !Number.isInteger(winners) || winners <= 0) {
    throw new Error('prizeShare requiere enteros y al menos un ganador');
  }
  const base = Math.floor(prizeAmount / winners); // parte entera para todos
  let remainder = prizeAmount % winners;          // centavos sobrantes: 0..winners-1

  return Array.from({ length: winners }, (_, i) => {
    // Los primeros `remainder` ganadores reciben un centavo extra.
    // Determinista: mismo input, mismo reparto, siempre.
    return base + (i < remainder ? 1 : 0);
  });
}
```

> **El patrón a memorizar.** *"División entera para la parte, resto
> explícito repartido de a uno, y una aserción de que las partes suman el
> todo."* Si te llevas una sola cosa de este apéndice, que sea esta. Es el
> antídoto contra el redondeo que pierde centavos.


> ⚠️ **La trampa del reparto "justo".** Repartir el resto siempre entre los
> primeros parece injusto, y lo es un poquito: en un reparto de 100 centavos
> entre 3, el primero se lleva 34 y los otros 33. La alternativa —repartirlo al
> azar, o rotar— suena más justa y es **peor**: pierdes el determinismo, y un
> cálculo de dinero que no da el mismo resultado dos veces no se puede auditar
> ni testear. Si el dominio exige justicia en el reparto, se resuelve con una
> regla explícita y documentada (por antigüedad, por orden de compra), nunca
> con aleatoriedad.

---

## 5. Migrar un sistema que ya guarda pesos

Es el caso más común en mantenimiento, y le pasó a este sistema: el dinero se
guardó en pesos porque nadie decidió la unidad, y en cuanto alguien empezó a
sumarlo hubo que migrar. La Fase 8 §5.0 tiene la migración concreta de este
proyecto; acá va la regla general, que sirve en cualquier otro.

**Uno: no migres sin bandera de idempotencia.** Una migración de montos que se
corre dos veces no falla ruidosamente: multiplica en silencio, sobre datos que
nadie va a mirar hasta la conciliación del mes. Toda migración de dinero graba
una marca y verifica esa marca antes de tocar nada.

**Dos: migra con aritmética entera.** `pesos * 100` sobre enteros es exacto;
`parseFloat(x) * 100` no lo es. Una migración es exactamente el peor lugar para
introducir el error que estás migrando para eliminar.

**Tres: migrar es también cambiar el contrato de la UI.** Después de migrar,
cada pantalla que mostraba el número crudo muestra cien veces más. Esas
pantallas se arreglan en el mismo cambio o se marcan como deuda 💸 explícita —
nunca se dejan rotas "porque nadie las mira".

**Cuatro: la unidad se declara por escrito.** Un comentario en el schema, un
campo en el propio dato, una línea en el README: donde sea, pero escrito. Un
sistema donde hay que preguntar "¿esto está en pesos o en centavos?" ya tiene el
bug; solo falta que alguien sume.

---

## 6. Cómo se ve el bug, y cómo se caza

El bug de dinero tiene una firma reconocible: **es pequeño, parece
intermitente, y aparece lejos de donde se originó.** Nadie reporta "el float
perdió precisión"; reportan "la liquidación da un centavo de diferencia".

La secuencia de diagnóstico, de barato a caro:

**Primero, la función pura.** Antes de abrir DevTools, corre el cálculo en la
consola de Node con los datos exactos del reporte. Si ahí ya falla, no hace
falta mirar nada más: el bug está en la aritmética, no en React, ni en Redux, ni
en la red. Es el diagnóstico más rápido del curso y el que más gente se salta.

**Segundo, `Number.isInteger`.** Recorre el store y verifica que todo campo de
dinero sea entero. Un solo `false` te dice dónde entró el float. `formatCents`
ya hace esa verificación y **lanza** en vez de mostrar algo raro: fallar
ruidosamente donde el error ocurre vale más que pintar "$5.000,004" tres
pantallas más allá.

**Tercero, el cuerpo de la petición.** En la pestaña Network, mira el `POST` que
persiste. Un decimal ahí prueba que el float llegó hasta la base de datos, y eso
cambia el fix: ya no basta con corregir el cálculo, hay que corregir los datos
guardados.

**Cuarto, la prueba de regresión, antes del fix.** El test que falla con el bug
presente y pasa con el arreglo:

```javascript
// settlementMath.test.js
import { calculateTotalCollected, prizeShare } from './settlementMath';

test('el recaudo total es entero exacto, sin residuo de float', () => {
  // 3 números a 10 centavos: DEBE ser exactamente 30, no 30.000000004.
  const total = calculateTotalCollected({ soldCount: 3, numberPrice: 10 });
  expect(total).toBe(30);
  expect(Number.isInteger(total)).toBe(true);
});

test('prizeShare reparte sin perder ni inventar centavos', () => {
  const shares = prizeShare(100, 3); // 100 centavos entre 3
  expect(shares).toEqual([34, 33, 33]);
  expect(shares.reduce((a, b) => a + b, 0)).toBe(100); // las partes suman el todo
});
```

Ese segundo `expect` —que las partes sumen el todo— es el assert más importante
que vas a escribir sobre dinero. No verifica un valor concreto: verifica una
**invariante**. Sigue siendo cierto si cambia el premio, si cambia el número de
ganadores, y si mañana alguien reescribe el reparto entero.

---

## 7. Por qué no usamos una librería

Existen `dinero.js`, `big.js` y `decimal.js`, y todas resuelven bien este
problema. El proyecto **no adopta ninguna**, y la decisión está cerrada en
`prompts/decisiones-y-versiones.md`.

El motivo no es que las librerías sean malas. Es que el dominio no las necesita:
todos los montos de una rifa caben holgadamente dentro del entero seguro, las
operaciones son sumar, multiplicar por un entero y dividir con resto, y la
moneda es una sola. Agregar una dependencia a un sistema legacy congelado tiene
un costo real —una versión más que auditar, un peer dependency más que puede
romper el lock— y acá no compra nada.

**Cuándo sí la comprarías**, para que reconozcas el momento: cuando aparezcan
varias monedas con subdivisiones distintas (el dinar kuwaití tiene tres
decimales, el yen cero), cuando haya conversión de divisas, o cuando los montos
puedan desbordar el entero seguro. Ninguna de las tres ocurre acá.

> 🧠 **El criterio general, que vale más que el caso concreto.** "Hay una
> librería que hace esto" no es razón para adoptarla. La razón es "el problema
> que resuelve la librería es un problema que yo tengo". Ochenta líneas de
> aritmética entera bien testeada son más baratas de mantener que una
> dependencia que hace veinte veces más de lo que necesitas.

---

## 🧩 Cuándo usar qué

- **Entra un monto desde un formulario** → `toCents(input)`. Siempre, aunque
  "sea obvio" que ya viene entero.
- **Sale un monto a la pantalla** → `formatCents(cents)`. Siempre, aunque solo
  sea un `console.log` de depuración: si lo miras mal una vez, lo vas a razonar
  mal después.
- **Multiplicas un monto por una cantidad** → directo sobre enteros
  (`numberPrice * soldCount`). Es exacto; no hace falta nada más.
- **Divides un monto** → §4, siempre con resto explícito. Nunca `/` a secas.
- **Comparas dos montos** → `===` sobre enteros, que es exacto. Comparar floats
  con `===` es la otra mitad del bug.
- **Persistes un monto** → entero, con la unidad declarada por escrito.
- **Te llega un monto de una API que no controlas** → `Number.isInteger` en el
  borde y error explícito si falla. No lo redondees en silencio.

---

## 🧪 Ejercicios (9)

1. **🟢** En la consola, corre `0.1 + 0.2`, `0.1 * 3` y `1.005 * 100`. Anota los
   tres resultados y explica en una línea qué tienen en común.
2. **🟢** Implementa `toCents` y `formatCents` desde cero, sin mirar §3. Después
   compara con la versión del apéndice y anota cada diferencia: sobre todo, dónde
   tu versión usó un float y la de acá no.
3. **🟢** Verifica el ida y vuelta: para cien valores aleatorios de centavos,
   confirma que formatear y volver a convertir devuelve el mismo entero. Si
   alguno falla, encontraste un caso borde del formateo.
4. **🟡** `formatCents` **lanza** si recibe un float, en vez de mostrar algo raro.
   Escribe el test que lo verifica y explica en dos líneas por qué fallar
   ruidosamente es mejor que pintar `"$5.000,004"`.
5. **🟡** Implementa `prizeShare` con `Math.round` en vez de `Math.floor` más
   resto. Encuentra un input donde las partes **no** sumen el todo y documéntalo.
   Ese input es tu caso de regresión.
6. **🟠 Diagnóstico.** Te reportan un cálculo que da un centavo de más de forma
   aparentemente intermitente. Aplica la secuencia de §6: qué corres primero, qué
   evidencia recoges en cada paso, y en qué punto exacto sabrías que el problema
   está en el dato persistido y no en el cálculo.
7. **🟠** Escribe la migración de §5 para un `db.json` que además tiene una
   colección `settlements` con montos ya calculados en pesos. Cuida el orden: si
   migras las rifas y no las liquidaciones, ¿qué queda inconsistente, y cómo lo
   detectarías sin revisar los datos a mano?
8. **🔴** Implementa `toCents` para una moneda de **tres** decimales sin romper la
   de dos. Decide si lo resuelves con un parámetro, una factory o un objeto de
   configuración por moneda, y **defiende la elección** en cinco líneas. Después
   argumenta si, con ese requisito sobre la mesa, seguirías sin librería (§7).
9. **🔴 Auditoría completa.** Recorre todo el código del proyecto buscando cada
   punto donde un monto entra, sale, se calcula o se persiste. Haz la lista y
   marca cuáles pasan por `money.js` y cuáles no. Cada "no" es un hallazgo:
   documéntalo con su riesgo asociado. Es literalmente lo que haría alguien
   auditando un sistema financiero, y suele encontrar más de lo que uno espera.

**🔥 Opcionales**

- 🔥 Reescribe `money.js` con `BigInt` en vez de `Number`. ¿Qué ganas? ¿Qué
  pierdes en serialización a JSON y en el store de Redux? Es el ejercicio que
  enseña por qué `BigInt` no es la respuesta obvia que parece.
- 🔥 Integra `dinero.js` en una rama aparte y reescribe `settlementMath.js` con
  ella. Compara líneas de código, tamaño de bundle y legibilidad, y después
  decide si cambiarías la decisión de §7.

---

## 📚 Referencias

**Documentación oficial**

- `Number.MAX_SAFE_INTEGER` —
  https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Number/MAX_SAFE_INTEGER
  — el límite hasta el que los enteros son exactos.
- `Number.isInteger` —
  https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Number/isInteger
  — la guarda de una línea que caza la mayoría de estos bugs.
- `Intl.NumberFormat` —
  https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat
  — útil para formatear, **peligroso** si lo alimentas con un float. Si lo usas,
  divide por 100 en el último paso y sobre un entero.
- IEEE 754 — https://en.wikipedia.org/wiki/IEEE_754 — el fundamento, si quieres
  el porqué y no solo la regla.

**Libros y artículos**

- *"What Every Computer Scientist Should Know About Floating-Point Arithmetic"*,
  de David Goldberg. Es el texto canónico sobre el tema y sigue vigente. Denso;
  con la primera sección alcanza para lo que necesitas acá.
- *Patterns of Enterprise Application Architecture*, de Martin Fowler, incluye un
  patrón **Money** que es, en esencia, lo que hace `money.js`.

> ⚠️ Las dos referencias bibliográficas se citan de memoria: verifica título,
> autor y edición antes de recomendarlas al equipo. Las URLs de MDN son estables
> pero su contenido se actualiza.

**Orden de lectura sugerido:** §1 y §2 (los fundamentos, veinte minutos) → §3
(el código que vas a usar) → vuelve a la Fase 8 → §4 y §6 cuando toques un
reparto o persigas un descuadre.

---

## 🚀 Y ahora, de vuelta al código

Si viniste desde la Fase 8, ya tienes `money.js` y el porqué: vuelve a §5.0 y
sigue con la migración y `settlementMath.js`. Si viniste persiguiendo un
descuadre, el incidente **18** del `cuaderno-incidentes.md` es exactamente este
problema con un ticket delante.

> **La señal de que quedó bien:** cuando veas un `Math.round` a mitad de un
> cálculo de dinero y tu primera reacción sea preguntar *"¿y qué pasa con el
> resto?"* — antes de mirar si el resultado se ve bien en pantalla.

---

> 🏷️ **Este apéndice deja código: márcalo.** Cuando termines lo que viniste a
> hacer acá, con `git status` limpio:
>
> ```bash
> git tag -a apendice-a10-aritmetica-de-dinero -m "A10: money.js con toCents, fromCents y el reparto que cuadra;
> settlementMath.js migrado a enteros."
> ```
>
> Los commits llevan su prefijo (`a10: …`) y los de ejercicio su número
> (`a10 ej3: …`). La convención completa —tags de fase, de ejercicio y de
> incidente— está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
