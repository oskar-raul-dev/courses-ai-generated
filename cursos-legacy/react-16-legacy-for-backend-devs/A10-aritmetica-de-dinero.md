# 💰 Apéndice A10 — Aritmética de dinero en JavaScript
## Tutorial React 16 — La Esclusa, la consola de Jewel Locks

> **Material de consulta rápida** · **~2 horas** · Lo usan la Fase 8 (conciliación) y la Fase 9 (dashboard) ·
> Prioridad: 🔴 Alta. No es lectura secuencial: salta al bloque que necesites.

Esto no se lee de corrido. Es la página que abres cuando tienes que tocar cualquier línea que sume, multiplique, divida o muestre plata, y quieres estar seguro de no perder un centavo por el camino.

Es también el único apéndice que funciona como **prerrequisito**: la Fase 8 asume que `money.js` existe y que sabes por qué está escrito así. Si vas entrando a la Fase 8, lee §1 a §4 de acá primero —media hora— y vuelve.

Todos los números de esta página salen de una corrida: el código es el de la consola al cerrar la Fase 8 (`src/features/reconciliation/`), y cada cifra está en una prueba que pasa. Las pruebas van en los bloques, para que puedas correrlas tú.

---

## 🧭 Índice de salto rápido

1. [Por qué el dinero no se representa con floats](#1-por-qué-el-dinero-no-se-representa-con-floats)
2. [El redondeo, que es donde de verdad se pierde plata](#2-el-redondeo-que-es-donde-de-verdad-se-pierde-plata)
3. [`money.js`: la frontera de entrada y salida](#3-moneyjs-la-frontera-de-entrada-y-de-salida)
4. [Repartir sin perder ni inventar centavos](#4-repartir-sin-perder-ni-inventar-centavos)
5. [Migrar un sistema que guardaba dólares en float](#5-migrar-un-sistema-que-guardaba-dólares-en-float)
6. [Cómo se ve el bug, y cómo se caza](#6-cómo-se-ve-el-bug-y-cómo-se-caza)
7. [Por qué no usamos una librería](#7-por-qué-no-usamos-una-librería)
8. [🧩 Cuándo usar qué](#-cuándo-usar-qué)
9. [🧪 Ejercicios](#-ejercicios-9)

---

## 1. Por qué el dinero no se representa con floats

JavaScript tiene un solo tipo numérico, `number`, que es un flotante de doble precisión (IEEE 754). Ese formato **no puede representar exactamente** muchos decimales que a ti te parecen triviales. El caso canónico, y los dos que importan en esta consola:

```javascript
test("§1: los floats de siempre", () => {
  expect(0.1 + 0.2).toBe(0.30000000000000004);
  expect(1.005 * 100).toBe(100.49999999999999);
  expect(20.99 / 500).toBe(0.041979999999999996);
});
```

No es un bug de JavaScript: es cómo funciona la aritmética binaria de punto flotante en casi todos los lenguajes. `0.1` en binario es un decimal periódico infinito, igual que `1/3` lo es en decimal, y al truncarlo a 64 bits arrastras un error minúsculo. El precio por giro de un paquete de 500 por US$20,99 —4,198 centavos— tampoco existe en binario. Sumas muchos de esos errores minúsculos y terminas con **centavos que aparecen o desaparecen de la nada**. En dinero, un centavo que no cuadra no es un error de redondeo simpático: es una conciliación que no se puede firmar.

**La solución que usa toda la industria** (Stripe, bancos, sistemas contables) es no guardar nunca "dólares con decimales" como float, sino **guardar la unidad mínima indivisible como entero**. Para el dólar, esa unidad es el centavo: US$20,99 se guarda como `2099`. Todos los cálculos se hacen sobre enteros —que JavaScript **sí** representa exactamente hasta `Number.MAX_SAFE_INTEGER`, 2⁵³ − 1, unos 90 billones de dólares en centavos— y solo al **mostrar** se convierte a la representación con coma decimal.

> 📝 **Nota de la casa.** La Esclusa guarda el dinero así desde 2021: la primera conciliación de las compras contra el reporte de la tienda dio catorce centavos de diferencia, y Renzo pasó todo a centavos enteros, sin librería (`00-historia-del-sistema.md` §3, era 2). La consola, que hasta la Fase 8 no hacía cuentas de dinero, adopta la misma regla.

### La unidad mínima no siempre es el centavo

Quien te informa el dinero decide su unidad, y no siempre es el centavo. Google Play da el precio de un producto en **micros** —un millonésimo de la moneda: US$20,99 es `20990000`—, y AdMob informa los ingresos por anuncios en micros también: US$6,50 llega como `6500000`. Un renglón de anuncios puede valer fracciones de centavo, así que pasar a centavos es una decisión de redondeo, y se toma **una vez, al final**:

```javascript
// (patrón de consulta: esta función no está en la consola)
function microsToCents(micros) {
  if (!Number.isInteger(micros)) throw new Error(`microsToCents espera un entero, recibió: ${micros}`);
  return Math.floor((micros + 5000) / 10000); // al centavo más cercano, la mitad hacia arriba
}
test("§1: micros a centavos, y por qué se suma en micros", () => {
  expect(microsToCents(20990000)).toBe(2099); // el precio del paquete: exacto
  expect(microsToCents(6500000)).toBe(650);
  const day = [1234400, 2344400, 3454400]; // tres renglones de un reporte de anuncios
  const roundedEach = day.map(microsToCents).reduce((a, b) => a + b, 0);
  const roundedOnce = microsToCents(day.reduce((a, b) => a + b, 0));
  expect(roundedEach).toBe(702); // 123 + 234 + 345
  expect(roundedOnce).toBe(703); // 7.033.200 micros = 703,32 centavos
});
```

Redondear cada renglón da 702 centavos; sumar en micros y redondear una vez da 703. Con tres renglones es un centavo; con los miles de renglones de un mes de anuncios —el 70 % de los ingresos del estudio (historia §8)— es la diferencia que Marisol encuentra. La regla: **se calcula en la unidad de la fuente y se convierte al final**.

---

## 2. El redondeo, que es donde de verdad se pierde plata

Sumar y restar enteros nunca pierde precisión. El problema aparece con la **división**, y la conciliación divide: prorratear el precio de un paquete entre sus giros, calcular una comisión. Cuando divides enteros, el resto no siempre es cero, y ahí tienes que decidir qué hacer con la fracción sobrante. Tres cosas importan.

**Primero, divide lo último posible y sobre enteros.** No conviertas a decimal para dividir "cómodo" y después redondees: cada conversión a float reintroduce el error que estás tratando de evitar. El prorrateo del paquete en float lo muestra:

```javascript
test("§2: 500 giros de 20,99/500 en float no suman 20,99", () => {
  let total = 0;
  for (let i = 0; i < 500; i++) total += 20.99 / 500;
  expect(total).toBe(20.98999999999994);
  expect(Math.floor(total * 100)).toBe(2098); // un centavo menos
  expect(Math.round(total * 100)).toBe(2099); // Math.round lo "salva", por esta vez
});
```

`Math.floor` sobre la suma pierde un centavo. `Math.round` "lo salva", y ese es el peligro: funciona con estos números, y la próxima vez, con otros, no.

**Segundo, elige una regla de redondeo y hazla explícita.** `Math.round` redondea `.5` siempre hacia arriba (`Math.round(2.5) === 3`, y `Math.round(-2.5) === -2` —ojo con los negativos—), lo que introduce un sesgo sistemático si redondeas muchos valores. Para dinero, la regla que usa la consola es **división entera y el resto asignado de forma determinista** (§4), de modo que la suma de las partes sea **exactamente** el total. Cuando de verdad hay que redondear al centavo más cercano —la comisión de la tienda—, se hace con enteros: `Math.floor((c · 1.500 + 5.000) / 10.000)` es el 15 % redondeado, sin un float de por medio.

**Tercero, el redondeo silencioso es el enemigo.** Un `Math.round` metido a mitad de un cálculo, sin comentario, "para que quede lindo", es como se pierden centavos sin que nadie se dé cuenta hasta que la contadora reclama. Toda operación de redondeo del proyecto es explícita, comentada y tiene su prueba. Un `Math.round` sin comentario al lado es, en este sistema, un hallazgo de revisión de código.

---

## 3. `money.js`: la frontera de entrada y de salida

Todo el dinero de la consola cruza por **un solo archivo**, en las dos direcciones. Nada entra sin pasar por `toCents` y nada se muestra sin pasar por `formatCents`. Esa disciplina es lo que convierte "en algún lado se pierde un centavo" en "se pierde acá, y acá están las pruebas".

```javascript
// Punto único de conversión entre lo que ve el operador (dólares con coma decimal)
// y lo que guarda el sistema (centavos de dólar, enteros). Todo el dinero cruza por acá.

/**
 * Convierte una entrada en DÓLARES ("20.99", "20,99" o "21") a un entero de CENTAVOS.
 * Rechaza lo que no puede representar exacto: más de dos decimales es un error del
 * llamador, no algo que se redondee en silencio. Nunca multiplica por 100 en float.
 * @param {string | number} input
 * @returns {number}
 */
export function toCents(input) {
  const raw = String(input).trim().replace(",", ".");
  if (!/^-?\d+(\.\d{1,2})?$/.test(raw)) {
    throw new Error(`Monto inválido para convertir a centavos: "${input}"`);
  }
  const [dollarsPart, centsPart = ""] = raw.split(".");
  const sign = dollarsPart.startsWith("-") ? -1 : 1;
  const dollars = Math.abs(parseInt(dollarsPart, 10));
  const cents = parseInt(centsPart.padEnd(2, "0"), 10); // "9" → 90, "" → 0
  return sign * (dollars * 100 + cents);
}

/**
 * Convierte un entero de centavos a texto para mostrar: 2099 → "US$20,99".
 * Si le llega un float, explota: alguien más arriba calculó con decimales.
 * @param {number} cents
 * @returns {string}
 */
export function formatCents(cents) {
  if (!Number.isInteger(cents)) {
    throw new Error(`formatCents espera un entero de centavos, recibió: ${cents}`);
  }
  const sign = cents < 0 ? "-" : "";
  const abs = Math.abs(cents);
  const dollars = String(Math.floor(abs / 100)).replace(/\B(?=(\d{3})+(?!\d))/g, ".");
  const rest = String(abs % 100).padStart(2, "0");
  return `${sign}US$${dollars},${rest}`;
}
```

Y sus pruebas, que son también su especificación:

```javascript
test("§3: toCents y formatCents", () => {
  expect(toCents("20.99")).toBe(2099);
  expect(toCents("20,99")).toBe(2099);
  expect(parseFloat("5000.10") * 100).toBe(500010.00000000006);
  expect(toCents("5000.10")).toBe(500010);
  expect(() => toCents("20.999")).toThrow();
  expect(formatCents(2099)).toBe("US$20,99");
  expect(formatCents(1596000)).toBe("US$15.960,00");
  expect(() => formatCents(4.198)).toThrow();
});
```

> **Detalle con intención.** `toCents` **nunca multiplica por 100 en float**. La tentación obvia es `Math.round(parseFloat(raw) * 100)`, y funciona… casi siempre: `parseFloat("5000.10") * 100` da `500010.00000000006`, y ahí `Math.round` te salva por poco. Apoyarte en que `Math.round` "te salve" es precisamente el redondeo silencioso que buscamos erradicar. Partir el texto y trabajar los centavos como enteros elimina el float de raíz.

---

## 4. Repartir sin perder ni inventar centavos

Todo sistema con dinero divide tarde o temprano: prorratear el precio de un paquete entre sus giros, repartir una comisión, partir un total en cuotas. La propiedad que hay que preservar tiene nombre y es innegociable: **las partes deben sumar exactamente el todo**. No "aproximadamente". Exactamente. Un prorrateo donde las partes suman 20,98 de un paquete de 20,99 no está "casi bien": está mal, y Marisol lo va a encontrar antes que tú.

El patrón es siempre el mismo y cabe en tres líneas: **división entera para la parte, resto explícito, y el resto repartido de a un centavo entre las primeras**.

```javascript
/**
 * Reparte un total en `parts` partes iguales SIN perder ni inventar un centavo.
 * División entera para todas, y el resto (siempre < parts) de a un centavo
 * para las primeras. 2.099 entre 500: 99 partes de 5 y 401 de 4.
 * @param {number} totalCents
 * @param {number} parts
 * @returns {number[]} su suma es exactamente totalCents
 */
export function prizeShare(totalCents, parts) {
  if (!Number.isInteger(totalCents) || !Number.isInteger(parts) || parts <= 0) {
    throw new Error("prizeShare requiere enteros y al menos una parte");
  }
  const base = Math.floor(totalCents / parts);
  const remainder = totalCents - base * parts;
  return Array.from({ length: parts }, (_, i) => base + (i < remainder ? 1 : 0));
}

/**
 * Cuánto del precio de un paquete corresponde a los giros que cayeron en cada
 * segmento. Prorratea por giro con prizeShare y suma por segmento, en el orden de
 * `counts`: las filas suman exactamente el precio del paquete.
 * @param {number} packagePriceCents
 * @param {number[]} counts - giros del paquete por segmento
 * @returns {number[]} centavos por segmento
 */
export function prorateSpinPrice(packagePriceCents, counts) {
  const spins = counts.reduce((sum, c) => sum + c, 0);
  const shares = prizeShare(packagePriceCents, spins);
  let next = 0;
  return counts.map((count) => {
    let cents = 0;
    for (let i = 0; i < count; i++) cents += shares[next++];
    return cents;
  });
}
```

El caso de la casa: un paquete de 500 giros por US$20,99 vale 4,198 centavos por giro, y ningún giro puede valer eso. `prizeShare(2099, 500)` da 99 giros de 5 centavos y 401 de 4: 2.099 exactos. `prorateSpinPrice` reparte esas partes entre los segmentos en que cayeron los giros del paquete:

```javascript
test("§4: el paquete de 500 giros", () => {
  const shares = prizeShare(2099, 500);
  expect(shares.filter((c) => c === 5)).toHaveLength(99);
  expect(shares.reduce((a, b) => a + b, 0)).toBe(2099);
  expect(prizeShare(100, 3)).toEqual([34, 33, 33]);
  // los giros del paquete tok-ago-05, por segmento (bitácora sembrada de la F08)
  const counts = [148, 95, 71, 74, 57, 38, 13, 4];
  expect(prorateSpinPrice(2099, counts)).toEqual([691, 380, 284, 296, 228, 152, 52, 16]);
  // la versión que calcula cada fila en dólares y redondea
  const rows = counts.map((c) => Math.round(c * (20.99 / 500) * 100));
  expect(rows.reduce((a, b) => a + b, 0)).toBe(2100);
});
```

La última línea es la versión que parece razonable —calcular cada fila en dólares y redondear— y da 2.100. Un centavo de más, que nadie ve en ninguna fila, porque cada fila está bien redondeada. Es el incidente 18 del cuaderno.

> **El patrón a memorizar.** *"División entera para la parte, resto explícito repartido de a uno, y una aserción de que las partes suman el todo."* Si te llevas una sola cosa de este apéndice, que sea esta.

> ⚠️ **La trampa del reparto "justo".** Repartir el resto siempre entre los primeros parece injusto, y lo es un poquito: en un reparto de 100 centavos entre 3, el primero se lleva 34 y los otros 33. La alternativa —repartirlo al azar, o rotar— suena más justa y es **peor**: pierdes el determinismo, y un cálculo de dinero que no da el mismo resultado dos veces no se puede auditar ni probar. Si el dominio exige justicia en el reparto, se resuelve con una regla explícita y documentada (por orden de compra, por antigüedad), nunca con aleatoriedad.

---

## 5. Migrar un sistema que guardaba dólares en float

Es el caso más común en mantenimiento, y es el que vivió este sistema en 2021: el dinero se guardaba en dólares con decimales porque nadie había decidido la unidad, y en cuanto alguien concilió, hubo que migrar. La regla general sirve en cualquier otro sistema.

**Uno: migra por el texto, no por la multiplicación.** `Math.round(monto * 100)` convierte casi todo bien, y por eso es peligroso: también convierte, sin decir nada, los montos que ya estaban corruptos. Pasar cada monto por `toCents(String(monto))` hace lo contrario: un monto que no tiene dos decimales exactos **no se migra**, se aparta para revisar.

```javascript
test("§5: migrar por el texto encuentra las filas que ya venían corruptas", () => {
  const stored = [20.99, 0.99, 20.98999999999994];
  const migrated = stored.map((amount) => {
    try {
      return toCents(String(amount));
    } catch (error) {
      return null; // a revisar a mano: no se adivina
    }
  });
```

La tercera fila es lo que deja una suma de 500 giros en float (§2). `Math.round` la convierte en 2.099 y la esconde para siempre; la migración por el texto la encuentra.

**Dos: no migres sin bandera de idempotencia.** Una migración de montos que se corre dos veces no falla ruidosamente: multiplica por cien en silencio, sobre datos que nadie va a mirar hasta la conciliación del mes. Toda migración de dinero graba una marca y verifica esa marca antes de tocar nada.

**Tres: migrar es también cambiar el contrato de la interfaz.** Después de migrar, cada pantalla que mostraba el número crudo muestra cien veces más. Esas pantallas se arreglan en el mismo cambio o se marcan como deuda 💸 explícita, nunca se dejan rotas "porque nadie las mira".

**Cuatro: la unidad se declara por escrito.** Un comentario en el esquema, un campo en el propio dato, un sufijo en el nombre —`packagePriceCents`—: donde sea, pero escrito. Un sistema donde hay que preguntar "¿esto está en dólares o en centavos?" ya tiene el bug; solo falta que alguien sume.

---

## 6. Cómo se ve el bug, y cómo se caza

El bug de dinero tiene una firma reconocible: **es pequeño, parece intermitente, y aparece lejos de donde se originó.** Nadie reporta "el float perdió precisión"; reportan "la conciliación da un centavo de diferencia". Y lo de "intermitente" es literal: con los mismos 2.099 centavos, el prorrateo por fila redondeada da 2.100 con unos giros, 2.099 con otros y 2.098 con otros más (Fase 8, ejercicio 18).

La secuencia de diagnóstico, de barato a caro:

**Primero, la función pura.** Antes de abrir DevTools, corre el cálculo en una consola de Node con los datos exactos del reporte. Si ahí ya falla, no hace falta mirar nada más: el bug está en la aritmética, no en React, ni en Redux, ni en la red. Es el diagnóstico más rápido del curso y el que más gente se salta.

**Segundo, `Number.isInteger`.** Recorre el store y verifica que todo campo de dinero sea entero. Un solo `false` te dice dónde entró el float. `formatCents` ya hace esa verificación y **lanza** en vez de mostrar algo raro: fallar ruidosamente donde el error ocurre vale más que pintar "US$20,990000000001" tres pantallas más allá.

**Tercero, el cuerpo de la petición.** En Network, mira lo que se persiste. Un decimal ahí prueba que el float llegó hasta la base, y eso cambia el fix: ya no basta con corregir el cálculo, hay que corregir los datos guardados (§5).

**Cuarto, la prueba de regresión, antes del fix.** La que falla con el bug y pasa con el arreglo. La de §4 es el modelo: su aserción más importante no verifica un valor, verifica una **invariante** —que las partes sumen el todo—. Sigue siendo cierta si cambia el precio, si cambian los giros y si mañana alguien reescribe el reparto entero.

---

## 7. Por qué no usamos una librería

Existen `dinero.js`, `big.js` y `decimal.js`, y todas resuelven bien este problema. El proyecto **no adopta ninguna**, y la decisión está cerrada en `00-decisiones-y-versiones.md`.

El motivo no es que las librerías sean malas. Es que el dominio no las necesita: todos los montos de la consola caben holgadamente dentro del entero seguro, las operaciones son sumar, multiplicar por un entero y dividir con resto, y la moneda es una sola, el dólar. Agregar una dependencia a un sistema legacy congelado tiene un costo real —una versión más que auditar, una dependencia más que puede romper el lock— y acá no compra nada.

**Cuándo sí la comprarías**, para que reconozcas el momento: cuando aparezcan varias monedas con subdivisiones distintas (el dinar kuwaití tiene tres decimales, el yen ninguno), cuando haya conversión de divisas, o cuando los montos puedan desbordar el entero seguro. Si el estudio vendiera los giros de Colombia y de México en la moneda de cada país, con sus precios locales, la primera aparecería. Hoy, ninguna.

> 🧠 **El criterio general, que vale más que el caso concreto.** "Hay una librería que hace esto" no es razón para adoptarla. La razón es "el problema que resuelve la librería es un problema que yo tengo". Ochenta líneas de aritmética entera bien probada son más baratas de mantener que una dependencia que hace veinte veces más de lo que necesitas.

---

## 🧩 Cuándo usar qué

- **Entra un monto desde un formulario** → `toCents(input)`. Siempre, aunque "sea obvio" que ya viene entero.
- **Sale un monto a la pantalla** → `formatCents(cents)`. Siempre, aunque solo sea un `console.log` de depuración: si lo miras mal una vez, lo vas a razonar mal después.
- **Multiplicas un monto por una cantidad** → directo sobre enteros (`packagePriceCents * purchases`). Es exacto; no hace falta nada más.
- **Divides un monto** → §4, siempre con resto explícito. Nunca `/` a secas.
- **Redondeas una comisión o un impuesto** → con enteros y la regla escrita (§2), y renglón por renglón si así lo hace quien cobra.
- **Comparas dos montos** → `===` sobre enteros, que es exacto. Comparar floats con `===` es la otra mitad del bug.
- **Te llega un monto en micros** → se suma en micros y se pasa a centavos una vez, al final (§1).
- **Te llega un monto de una API que no controlas** → `Number.isInteger` en el borde y error explícito si falla. No lo redondees en silencio.

---

## 🧪 Ejercicios (9)

1. **🟢** En una consola de Node, corre `0.1 + 0.2`, `1.005 * 100` y `20.99 / 500`. Anota los tres resultados y explica en una línea qué tienen en común. **Criterio:** coinciden con la prueba de §1.
2. **🟢** Implementa `toCents` y `formatCents` desde cero, sin mirar §3. Después corre la prueba de §3 contra tu versión y anota cada diferencia: sobre todo, dónde tu versión usó un float.
3. **🟢** Verifica el ida y vuelta: para cien valores de centavos, confirma que formatear y volver a convertir con `toCents` devuelve el mismo entero. **Criterio:** si alguno falla, encontraste un caso borde del formateo; si ninguno, explica por qué `toCents` acepta la coma.
4. **🟡** `formatCents` **lanza** si recibe un float. Escribe la prueba que lo verifica y explica en dos líneas por qué fallar ruidosamente es mejor que pintar `"US$20,990000000001"`.
5. **🟡** Implementa `prizeShare` con `Math.round(total / parts)` para todas las partes. **Criterio:** encuentras un caso donde las partes no suman el todo —`(2099, 500)` sirve— y lo dejas como prueba de regresión.
6. **🟠 Diagnóstico.** Te reportan una conciliación que da un centavo de más de forma aparentemente intermitente. Aplica la secuencia de §6: qué corres primero, qué evidencia recoges en cada paso, y en qué punto sabrías que el problema está en el dato persistido y no en el cálculo.
7. **🟠** Escribe la migración de §5 para un `db.json` que guarda `packagePrice: 20.99` en dólares, con su bandera de idempotencia. **Criterio:** correrla dos veces deja lo mismo, y una fila con `20.98999999999994` queda apartada con su id en un reporte, no migrada.
8. **🔴** Implementa `toCents` para una moneda de **tres** decimales sin romper la de dos. Decide si lo resuelves con un parámetro, una factory o una configuración por moneda, y **defiende la elección** en cinco líneas. Después argumenta si, con ese requisito sobre la mesa, seguirías sin librería (§7).
9. **🔴 Auditoría completa.** Recorre el código de la consola buscando cada punto donde un monto entra, sale, se calcula o se persiste. Haz la lista y marca cuáles pasan por `money.js` y cuáles no. Cada "no" es un hallazgo: documéntalo con su riesgo. Es lo que haría alguien auditando un sistema financiero, y suele encontrar más de lo que uno espera.

**🔥 Opcionales**

- 🔥 Reescribe `money.js` con `BigInt` en vez de `Number`. ¿Qué ganas? ¿Qué pierdes al serializar a JSON y en el store de Redux? Es el ejercicio que enseña por qué `BigInt` no es la respuesta obvia que parece.
- 🔥 Integra `dinero.js` en una rama aparte y reescribe `reconciliationMath.js` con ella. Compara líneas de código, tamaño del bundle y legibilidad, y decide si cambiarías la decisión de §7.

---

## 📚 Referencias

**Documentación oficial**

- `Number.MAX_SAFE_INTEGER` — https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Number/MAX_SAFE_INTEGER — el límite hasta el que los enteros son exactos.
- `Number.isInteger` — https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Number/isInteger — la guarda de una línea que caza la mayoría de estos bugs.
- `Intl.NumberFormat` — https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat — útil para formatear, **peligroso** si lo alimentas con un float. Si lo usas, divide por 100 en el último paso y sobre un entero.
- IEEE 754 — https://en.wikipedia.org/wiki/IEEE_754 — el fundamento, si quieres el porqué y no solo la regla.
- AdMob API, informe de red — https://developers.google.com/admob/api/reference/rest/v1/accounts.networkReport/generate — los ingresos estimados llegan en micros (`microsValue`).

**Libros y artículos**

- *"What Every Computer Scientist Should Know About Floating-Point Arithmetic"*, de David Goldberg. El texto canónico sobre el tema; con la primera sección alcanza para lo que necesitas acá.
- *Patterns of Enterprise Application Architecture*, de Martin Fowler, incluye el patrón **Money**, que es en esencia lo que hace `money.js`.

> ⚠️ Verifica título, autor y edición de las dos referencias bibliográficas antes de recomendarlas al equipo. Las URL de MDN son estables, pero su contenido se actualiza.

**Orden de lectura sugerido:** §1 y §2 (los fundamentos) → §3 (el código que vas a usar) → §4 → vuelve a la Fase 8 → §5 y §6 cuando toques una migración o persigas un descuadre.

---

## 🚀 Y ahora, de vuelta al código

Si viniste desde la Fase 8, ya tienes `money.js` y el porqué: vuelve a su §5.3 y sigue con `oddsAudit` y `reconciliationMath.js`. Si viniste persiguiendo un descuadre, el incidente **18** del `cuaderno-incidentes.md` es exactamente este problema con un ticket delante.

> **La señal de que quedó bien:** cuando veas un `Math.round` a mitad de un cálculo de dinero y tu primera reacción sea preguntar *"¿y qué pasa con el resto?"* — antes de mirar si el resultado se ve bien en pantalla.

---

> 🏷️ **Este apéndice deja código: márcalo.** Cuando termines lo que viniste a hacer acá, con `git status` limpio:
>
> ```bash
> git tag -a apendice-a10-aritmetica-de-dinero -m "A10: money.js con toCents y formatCents, y el reparto que cuadra con prizeShare."
> ```
>
> Los commits llevan su prefijo (`a10: …`) y los de ejercicio su número (`a10 ej3: …`). La convención completa —tags de fase, de ejercicio y de incidente— está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
