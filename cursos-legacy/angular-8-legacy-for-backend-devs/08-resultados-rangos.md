# 🧬 Fase 08 — Resultados y rangos versionados

> Tutorial Angular 8 — Laboratorio clínico · Fase 8 de 14 · **10 horas**
> Depende de: Fase 7 — Muestras y cadena de custodia
> Habilita: Fase 9 — Entrega y PDF en cliente · Fases 10-12
> Apéndices de apoyo: [A01 (Angular Material)](./a01-material.md) · [A02 (Bootstrap 4 + Sass)](./a02-bootstrap-sass.md) · [A05 (RxJS de supervivencia)](./a05-rxjs.md) · [A06 (NgRx 8)](./a06-ngrx.md) · [A07 (i18n en Angular 8)](./a07-i18n.md) · [Incidentes asociados](./cuaderno-incidentes.md): 07, 12, 13

---

## 🎯 1. Propósito

Hasta acá el sistema sabía mover cosas de un estado a otro con reglas: una orden nace, una muestra se recoge, se recibe, se procesa. Pero nada de eso *significa* nada todavía. Una muestra procesada es una muestra a la que le pasó el tiempo; no tiene un número adentro, y nadie dijo aún si ese número está bien o mal. Esta fase es donde el sistema por fin **decide**: toma el valor que arrojó una muestra, lo compara contra el rango de referencia que estaba vigente el día que corresponde, y dice si está dentro, fuera, o en zona crítica. Y una vez que un profesional habilitado firma esa decisión, **no se puede deshacer**.

Lo que te importa a ti, que vas a *mantener* esto, es que este es el corazón normativo del sistema y por lo tanto **el lugar donde los bugs cuestan caro y son difíciles de ver**. Un rango mal aplicado no rompe la pantalla: muestra un número en verde que debería estar en rojo, o al revés, y nadie se entera hasta que alguien audita. Un resultado validado sobre la versión equivocada de un rango es un dato que *parece* correcto y que solo se descubre reconstruyendo qué norma regía ese día. Y la irreversibilidad convierte cada validación en un movimiento sin vuelta atrás: si el sistema dejó validar algo que no debía, no hay un botón de deshacer, hay un ticket. Aprender dónde vive la comparación contra el rango, cómo se elige qué versión aplica, y por qué la comparación de fechas es el punto más frágil de todo el sistema, es el músculo de esta fase.

Hay una segunda razón, de continuidad. La Fase 7 te dejó dos máquinas de estado —la de la muestra y, apenas incipiente, la de la orden— sin cruzarse. Acá se cruzan por primera vez: validar el resultado de la última muestra de una orden empuja la orden hacia adelante. Ese empuje, que suena inocente, es el primer punto del sistema donde una acción sobre una entidad cambia el estado de **otra**, y esa forma acoplada es la que el audit log de la Fase 11 tiene que reconstruir entera.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `npm run seed` genera ahora `referenceRanges` con **dos versiones** de al menos un analito (una v1 y una v2 con fechas de vigencia que se solapan con las fechas de las órdenes), y `results` colgando de muestras que están en `in_process` o `processed`. `npm run mock` los sirve en `/referenceRanges` y `/results`.
- [ ] Navegas a la vista de resultados de una muestra procesada y ves, para cada resultado, su `value`, su `unit`, y una marca visual de dentro / fuera de rango / crítico que sale de comparar contra el rango vigente, no de un campo escrito a mano.
- [ ] Cargas un valor sobre un resultado en `preliminary` y en Redux DevTools ves entrar `[Results] Enter Result` → `[Results] Enter Result Success` → `[Results] Load Results`, en ese orden.
- [ ] Validas un resultado `preliminary` con un usuario que tiene rol habilitado y su `status` pasa a `validated`; el control de validación desaparece y no vuelve a ofrecerse. Intentas validarlo otra vez despachando `validateResult` a mano desde DevTools y el estado **no cambia**: el reducer lo ignora, no sale acción de éxito ni petición en Network.
- [ ] Intentas cargar o validar un resultado sobre una muestra que está en `scheduled` o `collected` (no procesada) y el reducer lo rechaza en silencio: la doble guarda cruza el estado del resultado **y** el de la muestra origen.
- [ ] Al validar el resultado, el registro guarda `validatedBy`, `validatedAt` y `rangeVersionApplied` —la versión del rango que se usó para juzgarlo—, de forma que el veredicto queda congelado aunque más tarde nazca una v3.
- [ ] Un resultado cuyo `value` cae fuera de los umbrales `criticalLow`/`criticalHigh` del rango vigente aparece marcado como crítico en la interfaz. (La **alerta activa** —notificar a alguien— no se dispara: eso es el incidente 07 y queda fuera de alcance, ver §3.)
- [ ] Los textos de estado y las marcas salen de i18n (`results.status.preliminary`, `results.status.validated`, `results.outOfRange`, `results.critical`), sin una sola cadena escrita a mano en la plantilla.

---

## 🚫 3. Qué NO entra todavía

- La **firma digital** del resultado —una firma criptográfica real, no un `validatedBy` con el nombre del usuario— → **fuera de alcance del curso**. Acá "firmar" es estampar quién y cuándo; la irreversibilidad la hace cumplir el reducer, no una firma.
- El **workflow de validación multinivel** —que un resultado pase por un analista y después por un supervisor, con estados intermedios— → **fuera de alcance**. Acá la validación es de un solo paso: `preliminary → validated`, y `validated` es terminal absoluto. La invalidación por rol superior queda como ejercicio 🔥 y como material de ese workflow que no construimos.
- La **alerta activa de resultado crítico** —notificar, mandar un canal, encender un banner que interrumpa— → es justamente el **incidente 07**: el sistema marca el crítico pero *no avisa*, y menos el fin de semana. Acá el crítico se **calcula y se marca**; que no avise es la falla que vas a investigar, no una feature que construyas.
- La **concurrencia de dos analistas validando el mismo resultado a la vez** → hermana del incidente 10 de la Fase 5/6, se documenta como **incidente 13** y no se arregla en Track A. Acá una validación es de a una.
- El **analizador externo simulado** que empuja resultados que la aplicación no controla (ALCANCE §5) → se difiere; encaja con el inyector de caos de la Fase 4 o con la Fase 11. Anotado en pendientes.
- El **CRUD completo de resultados** escrito línea por línea → es el mismo molde de la Fase 5 con otro sustantivo. Queda como ejercicio de espejo. Esta fase se concentra en lo nuevo: la comparación contra rango versionado y la validación irreversible.
- La **entrega del informe** que lleva la orden a `delivered` → **Fase 9**. Acá el cruce muestra→orden llega hasta `partial_results`/`complete`, no más allá.

---

## 🧠 4. Concepto mínimo

### El problema antes que la herramienta

Un resultado de laboratorio es un número con una unidad: glucosa 105 mg/dL, TSH 4.2 mUI/L. Por sí solo, ese número no dice nada. Cobra sentido únicamente cuando se lo compara contra un **rango de referencia**: el intervalo de valores que se consideran normales para ese analito. 105 mg/dL de glucosa está bien o está mal según cuál sea el rango, y el rango no es una constante universal: cambia con la norma, con el laboratorio, con el método de medición.

Y acá aparece el problema que define esta fase. Los rangos de referencia **cambian con el tiempo**. Una sociedad médica revisa un umbral, sale una norma nueva, y a partir de cierta fecha el rango "normal" de un analito es otro. Pero los resultados viejos no se recalculan: un resultado que se validó en marzo con el rango de marzo tiene que seguir diciendo lo que decía en marzo, aunque en junio el rango haya cambiado. Si recalcularas, estarías reescribiendo la historia clínica de un paciente cada vez que cambia una norma, y eso en un sistema regulado es exactamente lo que no puede pasar.

La solución no es guardar un solo rango por analito, sino **versionar el rango**. Cada rango tiene una versión y una ventana de vigencia: "esta v1 rige desde enero hasta mayo; esta v2 rige desde junio en adelante". Cuando llega el momento de juzgar un resultado, el sistema no pregunta "¿cuál es el rango de este analito?" sino "¿cuál era el rango vigente **el día que corresponde a este resultado**?". Esa pregunta —qué versión aplica en qué fecha— es el núcleo de la fase, y es también su trampa, porque comparar fechas es el punto donde el sistema miente más fácil.

### La irreversibilidad, y por qué vive en el reducer

Validar un resultado es afirmar, con nombre y apellido, que ese número es correcto y que se juzgó contra el rango correcto. Es un acto que en el mundo real tiene consecuencias médicas y legales, y por eso es **irreversible**: una vez validado, el resultado no vuelve a `preliminary`. No hay "editar", no hay "deshacer".

Esto es, otra vez, una máquina de estados —igual que la de la muestra en la Fase 7—, pero más simple y más estricta:

```
preliminary → validated
validated    → (ninguno: terminal absoluto)
```

Una sola transición legal, y un estado terminal del que no se sale. La Fase 7 te enseñó dónde vive una invariante así: en el **reducer**, no en el effect. Si la guarda de irreversibilidad viviera en el effect o en el componente, dependería de que esa capa se portara bien, y bastaría con despachar `validateResult` a mano desde la consola sobre un resultado ya validado para saltártela. En el reducer, en cambio, la irreversibilidad deja de ser una intención y pasa a ser una propiedad del sistema: **el estado `validated` es terminal por construcción, venga la acción de un botón o de alguien tecleando en DevTools.**

Hay una vuelta de tuerca que la muestra no tenía. Un resultado no vive solo: cuelga de una muestra. Y no tiene sentido juzgar un resultado de una muestra que nunca se procesó. Así que la guarda de esta fase es **doble**: para dejar cargar o validar un resultado, el reducer verifica dos cosas a la vez —que la transición del resultado sea legal *y* que la muestra origen esté en `in_process` o `processed`—. Esa es la decisión de diseño que esta fase fija y que las Fases 9 y 11 heredan: **un resultado nunca es más válido que la muestra de la que cuelga.**

### Si vienes de backend

El versionado de rangos es exactamente una tabla con *validity intervals* —el patrón temporal que usarías para tarifas, tasas de impuesto o precios que cambian por fecha—: no hay un registro por entidad, hay uno por entidad-y-periodo, y toda consulta lleva implícita una fecha. "¿Cuánto costaba esto?" no se responde sin "¿cuándo?". La analogía es limpia y se rompe en un punto: en el backend esa consulta la hace la base de datos con un `WHERE :date BETWEEN valid_from AND valid_to` que sabe de zonas horarias porque el motor las maneja. Acá, por fidelidad a LabCore, la selección del rango vigente la hace un selector de NgRx en el navegador, comparando `Date` de JavaScript, que es donde la zona horaria se pierde en silencio. Esa pérdida es la deuda 💸 de §5.3 y la raíz del incidente 07.

La irreversibilidad, por su lado, es un *append-only ledger* de manual: un asiento contable que se firma no se corrige, se compensa con otro asiento. Que acá no exista siquiera la compensación (no hay invalidación en Track A) es una simplificación deliberada, no un olvido.

### Nota de época

Angular 8 y NgRx 8 no traen nada para modelar validity intervals ni máquinas de estado; se escriben a mano, con un mapa plano y un `switch`, igual que en la Fase 7. Hoy tampoco lo traen de fábrica, pero el ecosistema tiene librerías dedicadas (XState para el estado, date-fns-tz o Luxon para el tiempo con zona) que en 2019, con NgRx ya montado y un equipo que no quería más dependencias, no se adoptaron. El resultado es lo que vas a mantener: comparación de fechas con `Date` pelado y una selección de versión escrita a mano, correcta el 95% de los días y falsa los fines de semana.

---

## 💻 5. Código mínimo con comentarios

Esta fase reusa el molde exacto de las Fases 5 y 6: acciones con `createAction`, reducer de `switch-case`, effect con `mergeMap` + recarga, servicio con `HttpClient` y filtro plano. Lo genuinamente nuevo es **la selección de rango vigente** (§5.3), **la doble guarda del reducer** (§5.4) y **el cruce muestra→orden** (§5.6). El código de abajo muestra lo nuevo o lo distinto y enlaza al molde previo para lo que sería copiar y pegar.

### 5.1 `seed.js` — rangos versionados y resultados

El semillero de la Fase 7 dejó `results` y `referenceRanges` como venían del `db.json` de la Fase 4: prácticamente vacíos. Acá se llenan por primera vez, y su forma es la que heredan todas las fases siguientes. Se agregan dos funciones al `seed.js` que ya existe; los pacientes, órdenes y muestras se generan igual que antes.

```javascript
// seed.js (fragmentos que se agregan al de la Fase 7)

// Un analito de referencia con DOS versiones de rango. La v1 rige la primera
// mitad de 2019; la v2 la segunda mitad, con un umbral más estricto (así el
// mismo value cae distinto según que versión se aplique, que es lo que hace
// visible el bug de versionado). effectiveTo null significa "vigente, sin
// fecha de cierre". Las fechas llevan offset -05:00 explicito porque la zona
// importa: ver la deuda de 5.3.
function buildReferenceRanges() {
  return [
    {
      id: 1,
      analyte: 'glucose',
      version: 1,
      unit: 'mg/dL',
      low: 70,
      high: 110,
      criticalLow: 50,
      criticalHigh: 250,
      effectiveFrom: '2019-01-01T00:00:00-05:00',
      effectiveTo: '2019-05-31T23:59:59-05:00'
    },
    {
      id: 2,
      analyte: 'glucose',
      version: 2,
      unit: 'mg/dL',
      // La v2 baja el techo de normalidad de 110 a 100. Un value de 105 estaba
      // DENTRO con la v1 y queda FUERA con la v2. Esa diferencia es el corazón
      // del ejercicio de versionado.
      low: 70,
      high: 100,
      criticalLow: 50,
      criticalHigh: 250,
      effectiveFrom: '2019-06-01T00:00:00-05:00',
      effectiveTo: null
    },
    {
      id: 3,
      analyte: 'tsh',
      version: 1,
      unit: 'mUI/L',
      low: 0.4,
      high: 4.0,
      criticalLow: 0.1,
      criticalHigh: 20,
      effectiveFrom: '2019-01-01T00:00:00-05:00',
      effectiveTo: null
    }
  ];
}

// Un resultado cuelga de una muestra, no de una orden. La función completa sigue
// el molde de buildSamples de la Fase 7 §5.1 y solo tiene tres decisiones que
// merezcan explicarse; el resto es rellenar campos.
function buildResults(samples) {
  // 1. Solo muestras que llegaron al menos a in_process tienen resultado. Un
  //    resultado sobre una "scheduled" sería justo lo que la doble guarda de 5.4
  //    prohibe, y sembrarlo esconderia el bug en vez de mostrarlo.
  //
  // 2. El value se sortea ALREDEDOR del umbral -para glucosa, entre 90 y 129- de
  //    forma que caiga dentro o fuera según que versión de rango aplique. Es la
  //    única razón por la que estos números no son arbitrarios.
  //
  // 3. outOfRange y critical NO se guardan. Son derivados: se calculan al vuelo
  //    contra el rango vigente cada vez que se muestran (5.7). Lo único que se
  //    congela es rangeVersionApplied, y solo al validar (5.6), porque ahi el
  //    veredicto pasa a ser oficial.
  //
  // Y una inconsistencia a propósito: los resultados sembrados como 'validated'
  // quedan con rangeVersionApplied en null. Un validado tiene que haber aplicado
  // ALGUNA versión; uno que no la tiene es un dato imposible que el sistema
  // aceptó igual. Esa es la semilla del incidente 12.
}
```

Y el objeto que se escribe al `db.json` reemplaza los `results`/`referenceRanges` heredados por los generados:

```javascript
var samples = buildSamples(orders);
var referenceRanges = buildReferenceRanges();
var results = buildResults(samples);

var next = {
  patients: patients,
  orders: orders,
  samples: samples,
  results: results,
  referenceRanges: referenceRanges
};
```

**Detalles con intención**

- `outOfRange` y `critical` **no se guardan**. Son valores derivados: se calculan comparando `value` contra el rango vigente, cada vez que se muestran. Guardarlos sería congelar un veredicto que depende de qué versión de rango aplica, y bastaría un cambio de rango para dejar todos los registros mintiendo. La única cosa que sí se congela es `rangeVersionApplied`, y solo en el momento de validar (§5.6), porque ahí el veredicto pasa a ser oficial.
- Los resultados sembrados como `validated` quedan con `rangeVersionApplied: null`. Es una inconsistencia a propósito: un resultado validado tiene que haber aplicado *alguna* versión de rango, y uno que no la tiene es un dato imposible que el sistema aceptó igual. Esa es la semilla del **incidente 12**.
- Solo hay resultados sobre muestras `in_process`/`processed`. Sembrar un resultado sobre una `scheduled` violaría la invariante que §5.4 hace cumplir, y un dato sembrado que viola la invariante no enseña nada: parece un bug de la guarda cuando en realidad es un bug del semillero.

### 5.2 `result.transitions.ts` — la máquina del resultado

Igual que la muestra tuvo su `sample.transitions.ts`, el resultado tiene el suyo. Es más chico —una sola transición legal— pero la forma es idéntica, a propósito: quien mantiene esto reconoce el patrón de un vistazo.

```typescript
// src/app/results/store/result.transitions.ts

// La máquina de estados de un resultado. Una sola transición legal:
// preliminary -> validated. "validated" es terminal ABSOLUTO: no tiene salida.
// Esa irreversibilidad es la regla que fija esta fase (ver 4).
export var RESULT_TRANSITIONS: any = {
  preliminary: ['validated'],
  validated:   []
};

// Misma firma y misma lógica que canTransition de la Fase 7. Un estado de
// origen desconocido devuelve false: defensa contra datos viejos.
export function canValidate(from: string, to: string): boolean {
  var allowed = RESULT_TRANSITIONS[from];
  if (!allowed) { return false; }
  return allowed.indexOf(to) >= 0;
}
```

**Detalles con intención**

- El mapa es `any`, sin un tipo `ResultStatus` que restrinja las claves. Es el mismo TS-0 de la Fase 7: un typo en un estado devuelve `undefined` y se trata como terminal, sin que nadie avise. Se comenta, no se corrige.
- Que exista una función `canValidate` con la misma forma que `canTransition` y que ninguna de las dos esté factorizada en una utilidad común es la deuda de dispersión que la Fase 7 ya declaró (§5.7 de aquella). Acá se repite en vez de unificarse, por fidelidad a LabCore.

### 5.3 `reference-range.selector.ts` — qué versión aplica, y la deuda 💸 de la zona horaria

Este es el archivo nuevo más importante de la fase. Dado un analito y una fecha, elige qué versión de rango estaba vigente. Es una función pura, sin dependencias de Angular, exactamente como el mapa de transiciones.

```typescript
// src/app/results/store/reference-range.selector.ts

// Elige el rango vigente para un analito en una fecha dada. Recorre las
// versiones y devuelve la que tiene la fecha dentro de su ventana
// [effectiveFrom, effectiveTo]. effectiveTo null significa "sin cierre".
//
// 💸 DEUDA INTENCIONAL: la comparación se hace con new Date(...) sobre strings
// ISO y con .getTime(), que compara instantes absolutos en UTC. Suena bien,
// pero el borde de vigencia se definió en hora LOCAL (-05:00) y el "atDate"
// que llega del componente suele construirse con new Date() del navegador o
// con una fecha sin hora. Cuando la fecha del resultado cae justo en el límite
// de una ventana -medianoche del 31 de mayo, un sábado- el instante UTC puede
// caer del lado equivocado y elegir la versión que NO correspondía.
//
//   Lo correcto hoy: comparar en la zona de la aplicación (America/Bogotá,
//   fijada en environment desde la Fase 2) usando una librería con soporte de
//   zona horaria (Luxon, date-fns-tz), normalizando ambos lados a la misma
//   zona antes de comparar. La comparación de vigencia nunca debería usar la
//   zona del navegador, que el usuario puede cambiar.
//
//   Por que en Track A NO se paga: LabCore compara así, y el bug que
//   produce -un rango de un día mal aplicado en el borde de una norma nueva-
//   es precisamente el incidente 07 que el estudiante tiene que aprender a
//   reproducir y localizar. Arreglarlo acá borraría el ejercicio.
export function selectActiveRange(ranges: any[], analyte: string, atDate: string): any {
  var target = new Date(atDate).getTime();

  for (var i = 0; i < ranges.length; i++) {
    var range = ranges[i];
    if (range.analyte !== analyte) { continue; }

    var from = new Date(range.effectiveFrom).getTime();
    // effectiveTo null: ventana abierta hacia el futuro.
    var to = range.effectiveTo ? new Date(range.effectiveTo).getTime() : Infinity;

    if (target >= from && target <= to) {
      return range;
    }
  }

  // Ningun rango cubre esa fecha. Devolver null y no reventar: un resultado sin
  // rango vigente es un caso real (analito nuevo sin norma todavía) y el
  // componente tiene que saber mostrarlo como "sin rango", no en rojo.
  return null;
}

// Dado un value y un rango, dice si está fuera de rango y si es crítico. Es
// derivado puro: no toca el store ni guarda nada.
export function evaluateResult(value: number, range: any): any {
  if (!range) {
    return { outOfRange: false, critical: false, hasRange: false };
  }
  var outOfRange = value < range.low || value > range.high;
  var critical = value <= range.criticalLow || value >= range.criticalHigh;
  return { outOfRange: outOfRange, critical: critical, hasRange: true };
}
```

**Detalles con intención**

- La comparación con `.getTime()` es correcta como comparación de instantes absolutos; lo que está mal es que **los dos lados no vienen en la misma zona**. `effectiveFrom` trae su offset `-05:00`; el `atDate` que llega del componente muchas veces no (ver §5.7). En el 95% de los días eso da igual porque la fecha cae lejos del borde de una ventana. Los días que no da igual son los bordes, y los peores bordes caen en fin de semana, que es cuando nadie está mirando. Esa es la firma temporal del incidente 07.
- `evaluateResult` distingue tres estados, no dos: dentro, fuera, y **sin rango**. Un resultado sin rango vigente no es "normal", es "no evaluable", y meterlo en el mismo saco que "dentro de rango" sería mostrar en verde algo que el sistema no supo juzgar.
- Ni `selectActiveRange` ni `evaluateResult` viven en el reducer. Son funciones puras que el componente y el effect llaman. El reducer solo custodia el estado válido; el juicio contra el rango es cálculo, no estado.

### 5.4 `results.actions.ts` y el reducer con doble guarda

Las acciones siguen el molde de siempre. Lo nuevo son `enterResult` (cargar el número sobre un resultado preliminary) y `validateResult` (firmarlo).

```typescript
// src/app/results/store/results.actions.ts
import { createAction, props } from '@ngrx/store';

// Lectura: los resultados de UNA muestra. El sampleId viaja porque el effect lo
// necesita para el filtro plano, igual que orderId en muestras.
export const loadResults = createAction(
  '[Results] Load Results',
  props<{ sampleId: number }>()
);

export const loadResultsSuccess = createAction(
  '[Results] Load Results Success',
  props<{ results: any[] }>()
);

export const loadResultsFailure = createAction(
  '[Results] Load Results Failure',
  props<{ error: any }>()
);

// Cargar los rangos de referencia al store. Se disparan una vez al entrar a la
// vista, en paralelo a loadResults. No llevan payload de entrada: se traen
// todos (son pocos) y la selección por vigencia se hace en cliente con
// selectActiveRange. Sin esta acción, referenceRanges queda vacío y ni el
// veredicto ni la validación tienen rangos contra que operar.
export const loadReferenceRanges = createAction(
  '[Results] Load Reference Ranges'
);

export const loadReferenceRangesSuccess = createAction(
  '[Results] Load Reference Ranges Success',
  props<{ ranges: any[] }>()
);

export const loadReferenceRangesFailure = createAction(
  '[Results] Load Reference Ranges Failure',
  props<{ error: any }>()
);

// Cargar/actualizar el value de un resultado preliminary. No lo valida: solo
// pone el número. Un resultado ya validado no acepta esto (irreversibilidad).
export const enterResult = createAction(
  '[Results] Enter Result',
  props<{ resultId: number; value: number }>()
);

export const enterResultSuccess = createAction(
  '[Results] Enter Result Success',
  props<{ result: any }>()
);

export const enterResultFailure = createAction(
  '[Results] Enter Result Failure',
  props<{ error: any }>()
);

// Fija la muestra cuyos resultados se están mirando. La necesita la doble guarda
// del reducer (5.4), que cruza el estado del resultado con el de su muestra: sin
// esto, "la muestra está lista" no se puede responder y todo se rechaza.
export const setCurrentSample = createAction(
  '[Results] Set Current Sample',
  props<{ sample: any }>()
);

// La acción normativa de la fase. Firma un resultado: lo lleva a validated.
// Irreversible. El "por quien" y la versión de rango aplicada los resuelve el
// effect al momento del PATCH (5.6); la acción lleva solo lo mínimo.
export const validateResult = createAction(
  '[Results] Validate Result',
  props<{ resultId: number }>()
);

export const validateResultSuccess = createAction(
  '[Results] Validate Result Success',
  props<{ result: any }>()
);

export const validateResultFailure = createAction(
  '[Results] Validate Result Failure',
  props<{ error: any }>()
);
```

El reducer es donde vive la doble guarda. Necesita conocer el estado de la muestra origen para poder cruzarlo, así que el estado de resultados guarda la muestra actual (igual que muestras guardaba `currentOrderId`).

```typescript
// src/app/results/store/results.reducer.ts
import * as ResultsActions from './results.actions';
import { canValidate } from './result.transitions';

export interface ResultsState {
  items: any[];
  loading: boolean;
  error: any;
  saving: boolean;
  saveError: any;
  // La muestra cuyos resultados están cargados, con su status. Se necesita para
  // la doble guarda: no se puede cargar ni validar un resultado sobre una
  // muestra que no está in_process o processed. Ver enterResult/validateResult.
  currentSample: any;
  // Los rangos de referencia vigentes, cargados una vez al entrar a la vista.
  // Viven en el store -y no se piden cada vez- porque son pocos, cambian poco, y
  // el selector de vigencia (selectActiveRange) y el veredicto del componente
  // (verdictFor) los necesitan a mano. Sin esto, verdictFor no tiene contra que
  // comparar y todo sale "sin rango"; y el effect de validación no puede
  // congelar rangeVersionApplied, dejando todo resultado validado sin norma
  // detrás (justo el incidente 12, pero disparado siempre, no solo en los
  // sembrados). Ver loadReferenceRanges.
  referenceRanges: any[];
}

export const initialState: ResultsState = {
  items: [],
  loading: false,
  error: null,
  saving: false,
  saveError: null,
  currentSample: null,
  // Vacío hasta que loadReferenceRanges los trae. Vacío (no null) para que el
  // selectActiveRange que los recorre no tenga que guardarse de un null: sobre
  // [] simplemente no encuentra rango vigente y devuelve null, que el
  // componente ya sabe mostrar como "sin rango".
  referenceRanges: []
};

// La muestra origen tiene que estar en uno de estos dos estados para que sus
// resultados se puedan tocar. Es la mitad "muestra" de la doble guarda; la
// mitad "resultado" la pone canValidate. Que este arreglo viva acá suelto y no
// en result.transitions.ts es más de la dispersión de 5.6 de la Fase 7.
var SAMPLE_READY_STATES = ['in_process', 'processed'];

function sampleIsReady(sample: any): boolean {
  return !!sample && SAMPLE_READY_STATES.indexOf(sample.status) >= 0;
}

export function resultsReducer(state = initialState, action: any): ResultsState {
  switch (action.type) {

    case ResultsActions.loadResults.type:
      return { ...state, loading: true, error: null };

    case ResultsActions.loadResultsSuccess.type:
      return { ...state, loading: false, items: action.results };

    case ResultsActions.loadResultsFailure.type:
      return { ...state, loading: false, error: action.error };

    // La muestra origen entera, no solo su id: la guarda necesita su "status".
    case ResultsActions.setCurrentSample.type:
      return { ...state, currentSample: action.sample };

    // Cargar un value. Doble guarda: la muestra origen tiene que estar lista, y
    // el resultado NO puede estar ya validated (un validado es intocable).
    case ResultsActions.enterResult.type: {
      var target = state.items.find(function (r) { return r.id === action.resultId; });
      // Sin resultado, o resultado ya validado, o muestra no lista: no se hace
      // nada. El intento queda en el log de DevTools sin efecto en el estado.
      if (!target || target.status === 'validated' || !sampleIsReady(state.currentSample)) {
        return state;
      }
      return { ...state, saving: true, saveError: null };
    }

    case ResultsActions.enterResultSuccess.type:
      return { ...state, saving: false };

    case ResultsActions.enterResultFailure.type:
      return { ...state, saving: false, saveError: action.error };

    // La guarda de irreversibilidad, cruzada con la de la muestra. Se busca el
    // resultado, se consulta canValidate (preliminary -> validated legal;
    // validated -> validated ilegal), y se exige que la muestra este lista. Si
    // algo falla, el estado se devuelve intacto: el resultado no se mueve,
    // "saving" no se enciende, no hay éxito que despachar. Esto es lo que hace
    // IMPOSIBLE por construcción validar dos veces o validar sobre una muestra
    // no procesada, venga la acción de un botón o de la consola.
    case ResultsActions.validateResult.type: {
      var result = state.items.find(function (r) { return r.id === action.resultId; });
      if (!result || !canValidate(result.status, 'validated') || !sampleIsReady(state.currentSample)) {
        return state;
      }
      return { ...state, saving: true, saveError: null };
    }

    case ResultsActions.validateResultSuccess.type:
      return { ...state, saving: false };

    case ResultsActions.validateResultFailure.type:
      return { ...state, saving: false, saveError: action.error };

    // Los rangos llegan y se guardan enteros. No hay bandera de loading propia:
    // los rangos son de apoyo, no la entidad principal de la vista, y su ausencia
    // momentánea se degrada sola a "sin rango" sin romper nada. Si fallan, se
    // deja el error pero no se vacía lo que hubiera: un rango viejo en memoria es
    // mejor que ninguno para juzgar.
    case ResultsActions.loadReferenceRangesSuccess.type:
      return { ...state, referenceRanges: action.ranges };

    case ResultsActions.loadReferenceRangesFailure.type:
      return { ...state, error: action.error };

    default:
      return state;
  }
}
```

**Detalles con intención**

- Cada `case` con lógica lleva sus llaves (`{ ... }`) para darle ámbito propio a las `var`. Es la misma lección de la Fase 7: sin las llaves, `var target` y `var result` se hoistarían al `switch` entero y chocarían. Ejercicio 16.
- La doble guarda es **una sola condición con dos partes** unidas por `||` de rechazo: `!canValidate(...) || !sampleIsReady(...)`. Que fallen juntas o por separado da el mismo resultado —estado intacto— y esa uniformidad es deliberada: el reducer no distingue *por qué* rechazó, solo rechaza. El *por qué* es material del incidente 13 y del ejercicio 27, donde se discute si el rechazo debería ser distinguible.
- `currentSample` guarda la muestra **entera**, no solo su id, porque la guarda necesita su `status`. Eso acopla el estado de resultados a la forma de la muestra, y es una decisión que la Fase 11 va a tener que desenredar cuando el audit log necesite el estado de la muestra desde otro lado. Anotado como deuda.
- El reducer **no calcula `outOfRange` ni `critical`**. Eso es cálculo derivado, vive en el componente (§5.7). El reducer solo custodia estado. Que ahora también custodie `referenceRanges` no rompe esa regla: guardar el rango es custodiar un dato; juzgar el `value` contra él sigue siendo cálculo del componente.
- **Nota de continuidad (primera).** `currentSample` —el campo del que cuelga la
  mitad "muestra" de la doble guarda— se declaraba en la interfaz y en el
  `initialState`, y **nada lo escribía nunca**: no había acción que lo fijara, ni
  `case` en el reducer, ni nadie que lo resolviera en el componente, que se
  limitaba a declarar `sample: any = null` con un comentario diciendo que "llega
  resuelta de la navegación". El efecto era que `sampleIsReady(null)` devolvía
  siempre `false` y **la fase entera no funcionaba**: `enterResult` y
  `validateResult` se rechazaban en todos los casos, la Prueba de fuego de §5.7 no
  se podía completar, y `verdictFor` caía siempre al `new Date()` del navegador,
  con lo que la deuda de zona horaria de §5.3 dejaba de ser un caso borde y pasaba
  a ser el caso único. Se corrige con el circuito completo —la acción
  `setCurrentSample`, su `case`, el effect `loadCurrentSample$` y la suscripción
  del componente—, más el `getById` que se añadió retroactivamente a
  **Fase 7 §5.4**. Es el mismo tipo de hueco que tenía `referenceRanges` y se
  arregla igual.

- **Nota de continuidad (segunda).** El `patch` de validación de §5.6 estampa
  además `outOfRange` y `critical`, que en la primera versión de esta fase no
  guardaba. El hueco se detectó al revisar el curso: el KPI de resultados fuera de
  rango del **dashboard (Fase 10 §5.2)** cuenta `r.outOfRange === true` sobre
  resultados validados, y ese campo no existía en ningún registro, así que ese KPI
  daba `0` siempre. Corregirlo en el dashboard —recalculando el veredicto allá—
  habría esparcido la deuda de zona horaria de §5.3 a una pantalla más; corregirlo
  acá es coherente con lo que la fase ya hacía con `rangeVersionApplied`: **en el
  instante de validar, el juicio deja de ser derivado y pasa a ser historia.** El
  seed (§5.1) sigue sin guardarlos, y sigue estando bien: un resultado
  `preliminary` no tiene veredicto oficial que congelar.

- **Nota de continuidad.** El circuito de `referenceRanges` en el store —el campo en la interfaz e `initialState`, las acciones `loadReferenceRanges*`, este `case` del reducer, el effect `loadReferenceRanges$` y el `dispatch` del componente— se agregó como corrección retroactiva. En la primera versión de esta fase, el componente y el effect leían `state.results.referenceRanges` pero nada lo llenaba: la interfaz no lo declaraba y ninguna acción lo cargaba. El efecto era que `verdictFor` no tenía rangos contra qué comparar (todo salía "sin rango") y la validación no podía congelar `rangeVersionApplied` (todo resultado validado quedaba sin norma detrás, disparando el incidente 12 en *todos* los casos, no solo en los sembrados a propósito). El hueco se detectó al escribir la **Fase 10 (dashboard)**, que necesita leer resultados con veredicto consistente; se corrige acá para que el incidente 12 vuelva a ser lo que debe ser —una inconsistencia sembrada en unos pocos registros—, no un bug universal por un store vacío.

### 5.5 `results.service.ts` — la ruta que el mock no tiene, otra vez

Mismo patrón exacto que la Fase 7: el `Router` navega bonito, json-server filtra plano. Un resultado se lee por su muestra con `/results?sampleId=`, y los rangos se leen enteros y se filtran en cliente (son pocos y cambian poco).

```typescript
// src/app/results/results.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class ResultsService {

  constructor(private http: HttpClient) { }

  // Filtro plano por muestra, igual que /samples?orderId= de la Fase 7.
  getResultsBySample(sampleId: number): Observable<any> {
    return this.http.get(environment.apiUrl + '/results?sampleId=' + sampleId);
  }

  // Los rangos se traen todos y se filtran/seleccionan en cliente con
  // selectActiveRange. Son pocas filas y la selección por vigencia es lógica de
  // negocio, no una query: json-server no sabe comparar ventanas de fecha.
  getReferenceRanges(): Observable<any> {
    return this.http.get(environment.apiUrl + '/referenceRanges');
  }

  // Cargar el value: PATCH de un solo campo, igual que la baja lógica de la
  // Fase 5 y la transición de la Fase 7.
  enterValue(resultId: number, value: number): Observable<any> {
    return this.http.patch(environment.apiUrl + '/results/' + resultId, { value: value });
  }

  // Validar: PATCH que lleva el status a validated Y estampa quien, cuando, y
  // qué versión de rango se aplicó. Ese estampado a mano es el mismo que en
  // muestras hacia el cliente; misma deuda de custodia (el timestamp debería
  // ponerlo el servidor). Quien arma el patch es el effect, en 5.6.
  validate(resultId: number, patch: any): Observable<any> {
    return this.http.patch(environment.apiUrl + '/results/' + resultId, patch);
  }
}
```

**Detalles con intención**

- Los rangos se traen enteros. Es la misma decisión de "no optimizar lo que no duele" de toda la serie: con tres filas de rango, filtrar en cliente es gratis y mantiene la selección por vigencia donde se puede leer y testear, en lugar de esconderla en un query string.
- `validate` recibe un `patch` genérico y no un `status` suelto, porque el PATCH lleva el estado **y** la evidencia de la validación (`validatedBy`, `validatedAt`, `rangeVersionApplied`). Quién arma ese patch es el effect, y ahí está la parte que hay que entender bien.

### 5.6 `results.effects.ts` — validar, estampar la versión, y empujar la orden

El effect sigue el patrón de la Fase 7 sin novedad estructural: `mergeMap`, `timeout`, `catchError`, recarga completa después de escribir. Tiene dos complicaciones nuevas: al validar, hay que **congelar qué versión de rango se aplicó**, y después hay que **empujar la orden** si esta era la última muestra pendiente. Esto último es el primer cruce entre dos máquinas de estado del sistema.

```typescript
// src/app/results/store/results.effects.ts
import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { Store } from '@ngrx/store';
import { of } from 'rxjs';
import { map, mergeMap, switchMap, catchError, timeout, withLatestFrom } from 'rxjs/operators';

import { ResultsService } from '../results.service';
import { SamplesService } from '../../samples/samples.service';
import { AuthService } from '../../core/auth/auth.service';
import { selectActiveRange, evaluateResult } from './reference-range.selector';
import * as ResultsActions from './results.actions';

// Heredada de la Fase 4, igual que en pacientes y muestras.
var REQUEST_TIMEOUT_MS = 10000;

@Injectable()
export class ResultsEffects {

  constructor(
    private actions$: Actions,
    private resultsService: ResultsService,
    private samplesService: SamplesService,
    private authService: AuthService,
    private store: Store<any>
  ) { }

  loadResults$ = createEffect(function (this: ResultsEffects) {
    return this.actions$.pipe(
      ofType(ResultsActions.loadResults),
      switchMap((action: any) => {
        return this.resultsService.getResultsBySample(action.sampleId).pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (results: any) {
            return ResultsActions.loadResultsSuccess({ results: results });
          }),
          catchError(function (error: any) {
            return of(ResultsActions.loadResultsFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));

  // Trae los rangos al store. El servicio (getReferenceRanges) ya existía en
  // 5.5; lo que faltaba era este effect que lo conecta a la acción y vuelca el
  // resultado en referenceRanges. switchMap porque una segunda carga de rangos
  // deja sin sentido a la anterior: siempre gana la última.
  loadReferenceRanges$ = createEffect(function (this: ResultsEffects) {
    return this.actions$.pipe(
      ofType(ResultsActions.loadReferenceRanges),
      switchMap(() => {
        return this.resultsService.getReferenceRanges().pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (ranges: any) {
            return ResultsActions.loadReferenceRangesSuccess({ ranges: ranges });
          }),
          catchError(function (error: any) {
            return of(ResultsActions.loadReferenceRangesFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));

  // Trae la muestra origen al store. Se dispara con la misma acción que carga los
  // resultados, porque las dos cosas hacen falta a la vez y pedirlas por separado
  // desde el componente abriría una ventana en la que la guarda ya puede rechazar
  // y la muestra todavía no llegó. switchMap: si el usuario navega a otra muestra,
  // la anterior deja de importar.
  loadCurrentSample$ = createEffect(function (this: ResultsEffects) {
    return this.actions$.pipe(
      ofType(ResultsActions.loadResults),
      switchMap((action: any) => {
        return this.samplesService.getById(action.sampleId).pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (sample: any) {
            return ResultsActions.setCurrentSample({ sample: sample });
          }),
          catchError(function () {
            // Si la muestra no llega, se deja el estado en null y la doble guarda
            // rechaza todo. Es lo correcto: sin saber en qué estado está la
            // muestra, validar un resultado suyo es adivinar.
            return of(ResultsActions.setCurrentSample({ sample: null }));
          })
        );
      })
    );
  }.bind(this));

  enterResult$ = createEffect(function (this: ResultsEffects) {
    return this.actions$.pipe(
      ofType(ResultsActions.enterResult),
      // mergeMap, no switchMap: cancelar una carga de value a medias por otra
      // sería perder un dato en silencio. Misma lección que la Fase 5/6.
      mergeMap((action: any) => {
        return this.resultsService.enterValue(action.resultId, action.value).pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (updated: any) {
            return ResultsActions.enterResultSuccess({ result: updated });
          }),
          catchError(function (error: any) {
            return of(ResultsActions.enterResultFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));

  validateResult$ = createEffect(function (this: ResultsEffects) {
    return this.actions$.pipe(
      ofType(ResultsActions.validateResult),
      // Se necesita el resultado (para su analyte y su fecha) y los rangos
      // vigentes, para congelar la versión aplicada. Se leen del store.
      withLatestFrom(this.store),
      mergeMap((pair: any) => {
        var action = pair[0];
        var state = pair[1];

        var result = state.results.items.find(function (r: any) {
          return r.id === action.resultId;
        });
        var ranges = state.results.referenceRanges || [];

        // La fecha contra la que se selecciona el rango. 💸 DEUDA: se usa la
        // fecha de creación de la muestra actual, y si no hay, la de HOY del
        // navegador (new Date()). Ese "hoy sin zona" es el otro extremo del
        // problema de 5.3: entra en selectActiveRange sin offset y en el borde
        // de una ventana de vigencia elige mal. Lo correcto sería usar la fecha
        // del EVENTO (cuando se tomó la muestra) normalizada a America/Bogotá.
        var sample = state.results.currentSample;
        var atDate = sample && sample.collectedAt
          ? sample.collectedAt
          : new Date().toISOString();

        // Se congela QUÉ versión de rango aplicó. A partir de acá, aunque nazca
        // una v3, este resultado sigue diciendo lo que dijo: el histórico queda
        // intacto. Un resultado validado sin esta versión es el incidente 12.
        var activeRange = result
          ? selectActiveRange(ranges, result.analyte, atDate)
          : null;

        // El veredicto, congelado en el mismo instante que la versión. Hasta acá
        // outOfRange y critical eran derivados y no se guardaban (5.1), y eso es
        // correcto MIENTRAS el resultado se pueda mover. Al validar deja de
        // poder: el juicio se vuelve oficial, y un dato oficial se guarda. Sin
        // esta línea, cualquier consumidor posterior tendria que recalcular el
        // veredicto contra los rangos, o sea reabrir la deuda de zona horaria de
        // 5.3 en pantallas que no son su sitio. El dashboard de la Fase 10 es el
        // primero que lo agradece.
        var verdict = evaluateResult(result ? result.value : null, activeRange);

        var patch: any = {
          status: 'validated',
          validatedBy: this.authService.getCurrentUser(),
          // 💸 Timestamp de cliente, misma deuda de custodia de la Fase 7: en un
          // sistema serio lo pone el servidor, no el navegador.
          validatedAt: new Date().toISOString(),
          rangeVersionApplied: activeRange ? activeRange.version : null,
          outOfRange: verdict.outOfRange,
          critical: verdict.critical
        };

        return this.resultsService.validate(action.resultId, patch).pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (updated: any) {
            return ResultsActions.validateResultSuccess({ result: updated });
          }),
          catchError(function (error: any) {
            return of(ResultsActions.validateResultFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));

  // Después de cargar o validar, recargar los resultados de la muestra actual.
  // Misma "cobardía deliberada" de la Fase 5/6: dos viajes donde alcanzaba uno,
  // a cambio de nunca desincronizarse. El sampleId sale del store.
  reloadAfterWrite$ = createEffect(function (this: ResultsEffects) {
    return this.actions$.pipe(
      ofType(ResultsActions.enterResultSuccess, ResultsActions.validateResultSuccess),
      withLatestFrom(this.store),
      map(function (pair: any) {
        var state = pair[1];
        var sample = state.results.currentSample;
        return ResultsActions.loadResults({ sampleId: sample ? sample.id : null });
      })
    );
  }.bind(this));

  // EL CRUCE. Cuando se valida un resultado, quizá haya que empujar la orden.
  // Este effect es el primer punto del sistema donde una acción sobre una
  // entidad cambia el estado de OTRA. Se despacha una acción de órdenes (la de
  // la Fase 6) para llevar la orden a partial_results o complete. La regla de
  // cuando exactamente -si es la última muestra, si todos sus resultados están
  // validados- se lee del store y se decide acá.
  //
  // 🔥 NOTA: este cruce está escrito de forma mínima a propósito. La lógica
  // completa (contar muestras de la orden, ver si TODAS están procesadas y con
  // resultados validados) acopla tres slices -results, samples, orders- y es el
  // germen del enredo que la Fase 11 tiene que auditar. Acá se muestra el
  // esqueleto; el conteo fino queda como ejercicio 25.
  pushOrderAfterValidate$ = createEffect(function (this: ResultsEffects) {
    return this.actions$.pipe(
      ofType(ResultsActions.validateResultSuccess),
      withLatestFrom(this.store),
      mergeMap((pair: any) => {
        var state = pair[1];
        var sample = state.results.currentSample;
        if (!sample) { return of({ type: '[Results] No Order Push' }); }

        // La acción destino es OrdersActions.transitionOrder, del slice que
        // construyo el ejercicio 1 de la Fase 6. El nombre esta fijado
        // aunque el conteo no: la Fase 11 §5.11 construye argumento sobre el
        // asiento que produce su exito -'[Orders] Transition Order Success'- y no
        // puede depender de que alguien haya hecho un ejercicio opcional.
        //
        // A QUE estado va (partial_results si quedan resultados por validar,
        // complete si no queda ninguno) es lo que exige contar muestras y
        // resultados, y eso es el ejercicio 25. Hasta entonces, el gancho:
        // return of(OrdersActions.transitionOrder({
        //   orderId: sample.orderId, toStatus: <lo que decida el conteo>
        // }));
        return of({ type: '[Results] No Order Push' });
      })
    );
  }.bind(this));
}
```

**Detalles con intención**

- `rangeVersionApplied` se congela **en el effect, en el momento de validar**, no antes y no después. Antes de validar, un resultado preliminary no tiene versión aplicada porque todavía no se juzgó. Después de validar, la versión es historia y no se recalcula. Ese instante exacto —la validación— es el único momento en que el veredicto temporal se vuelve permanente, y por eso es el único lugar donde se guarda.
- El cruce (`pushOrderAfterValidate$`) se muestra como **esqueleto deliberado**. Escribir el conteo completo acá —cuántas muestras tiene la orden, cuántas están procesadas, cuántos resultados validados— acoplaría tres slices del store y metería en esta fase el enredo que la Fase 11 existe para desenredar. Se deja el gancho y el conteo va al ejercicio 25, donde el estudiante lo escribe entendiendo qué acopla.
- `withLatestFrom(this.store)` lee el store entero. Es cómodo y es una pequeña bomba: acopla el effect a la forma de tres slices. Es el precio de tener la lógica de cruce en el cliente. El operador y su trampa —que no emite nada si el otro slice no ha cargado— están en el **Apéndice A05 §8.2**; qué hacer con el acoplamiento, en la **Fase 11 §5.11**, donde el audit log lo hace visible.

### 5.7 El componente gordo — calcular el veredicto y estampar `currentSample`

El componente sigue el molde de la Fase 7: carga los resultados de la muestra, guarda la muestra actual para que la doble guarda funcione, y —esto es lo nuevo— calcula al vuelo el veredicto de cada resultado contra el rango vigente. Toda la lógica adentro del componente, como manda el estilo de LabCore.

```typescript
// src/app/results/result-list/result-list.component.ts (fragmentos)
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { Store } from '@ngrx/store';

import { selectActiveRange, evaluateResult } from '../store/reference-range.selector';
import * as ResultsActions from '../store/results.actions';

@Component({
  selector: 'app-result-list',
  templateUrl: './result-list.component.html'
})
export class ResultListComponent implements OnInit {

  results: any[] = [];
  ranges: any[] = [];
  // La muestra actual, leída del store. Se necesita para dos cosas: la doble
  // guarda del reducer la consulta para saber si está lista, y verdictFor usa su
  // collectedAt para elegir la versión de rango vigente.
  sample: any = null;

  constructor(
    private route: ActivatedRoute,
    private store: Store<any>
  ) { }

  ngOnInit() {
    // paramMap como observable, no snapshot: el componente se reusa al navegar
    // entre muestras sin destruirse. Misma lección que la ruta anidada de la
    // Fase 7; el bug de usar snapshot acá es el ejercicio 11.
    this.route.paramMap.subscribe(function (this: ResultListComponent, params: any) {
      var sampleId = Number(params.get('sampleId'));
      this.store.dispatch(ResultsActions.loadResults({ sampleId: sampleId }));
    }.bind(this));

    // Los rangos se cargan una vez, en paralelo a los resultados. No dependen del
    // sampleId -son globales- así que se piden fuera del subscribe de paramMap,
    // que se reejecuta al navegar entre muestras. Sin este dispatch,
    // referenceRanges queda vacío y verdictFor no tiene contra que comparar.
    this.store.dispatch(ResultsActions.loadReferenceRanges());

    this.store.select(function (state: any) { return state.results.items; })
      .subscribe(function (this: ResultListComponent, items: any) {
        this.results = items;
      }.bind(this));

    this.store.select(function (state: any) { return state.results.referenceRanges; })
      .subscribe(function (this: ResultListComponent, ranges: any) {
        this.ranges = ranges || [];
      }.bind(this));

    // La muestra origen. La trae el effect al despachar loadResults, y el
    // componente la lee del store en vez de resolverla por su cuenta: así hay
    // una sola verdad sobre en qué estado está, y es la misma que consulta la
    // doble guarda del reducer.
    this.store.select(function (state: any) { return state.results.currentSample; })
      .subscribe(function (this: ResultListComponent, sample: any) {
        this.sample = sample;
      }.bind(this));
  }

  // El veredicto de un resultado: se calcula al vuelo, no se guarda. Elige el
  // rango vigente para la fecha de la muestra y evalúa el value contra el.
  //
  // 💸 DEUDA: la fecha que entra a selectActiveRange sale de la muestra, pero si
  // la muestra no tiene collectedAt se cae a new Date() del navegador. Ese "hoy
  // local sin zona" es el mismo agujero de 5.3 y 5.6: en el borde de una
  // ventana de vigencia, elige la versión equivocada. El fix correcto vive en
  // A06/incidente 07; acá se muestra el bug, no se tapa.
  verdictFor(result: any): any {
    var atDate = this.sample && this.sample.collectedAt
      ? this.sample.collectedAt
      : new Date().toISOString();
    var range = selectActiveRange(this.ranges, result.analyte, atDate);
    return evaluateResult(result.value, range);
  }

  // Firmar. La doble guarda del reducer decide si ocurre; el componente solo
  // pide. El botón de validar se oculta cuando el resultado ya está validated.
  onValidate(result: any) {
    this.store.dispatch(ResultsActions.validateResult({ resultId: result.id }));
  }

  onEnterValue(result: any, value: number) {
    this.store.dispatch(ResultsActions.enterResult({ resultId: result.id, value: value }));
  }
}
```

Y en la plantilla, el veredicto y los estados salen de i18n, sin una sola cadena a mano:

```html
<!-- src/app/results/result-list/result-list.component.html (fragmento) -->
<div class="result-row" *ngFor="let result of results">
  <span class="result-value">{{ result.value }} {{ result.unit }}</span>

  <!-- El veredicto se pide al método, que lo calcula al vuelo. Llamar un método
       en el template se reevalúa en cada ciclo de detección de cambios: acá es
       barato (pocas filas), pero es exactamente el patrón que en el dashboard
       de la Fase 10 se vuelve un problema de performance. Ejercicio 22. -->
  <ng-container *ngIf="verdictFor(result) as v">
    <span class="badge badge-critical" *ngIf="v.critical">
      {{ 'results.critical' | translate }}
    </span>
    <span class="badge badge-out" *ngIf="v.outOfRange && !v.critical">
      {{ 'results.outOfRange' | translate }}
    </span>
    <span class="badge badge-norange" *ngIf="!v.hasRange">
      {{ 'results.noRange' | translate }}
    </span>
  </ng-container>

  <!-- El estado sale de i18n. Ojo con la grafía: el dato es "preliminary" y la
       clave es results.status.preliminary; si algún día hubiera un in_process
       acá, la clave sería inProcess, y esa doble grafía es la deuda de i18n de
       la Fase 2. El mapa explícito estado -> clave está en el apéndice A07 §4. -->
  <span class="result-status">
    {{ ('results.status.' + result.status) | translate }}
  </span>

  <!-- El control de validar solo aparece si NO está validado. La irreversibilidad
       también se refleja en la UI: un validado no ofrece botón. Pero la guarda
       REAL vive en el reducer (5.4); esto es cortesía visual, no seguridad. -->
  <button mat-button *ngIf="result.status === 'preliminary'"
          (click)="onValidate(result)">
    {{ 'results.validate' | translate }}
  </button>
</div>
```

> 📚 Las tres clases `badge-critical`, `badge-out` y `badge-norange` no vienen de
> Bootstrap: se generan añadiendo tres claves al mapa `$theme-colors` antes del
> `@import`, y el porqué de hacerlo así —y el costo, que son dos docenas de clases
> que nadie va a usar— está en **A02 §5.2**. Los colores tampoco son arbitrarios:
> el crítico reusa el rojo del tema de Material y el "sin rango" es un gris, porque
> la ausencia de información no es un veredicto y no puede parecerlo.

**Detalles con intención**

- `verdictFor` se llama desde el template y se reevalúa en cada ciclo de detección de cambios. Con pocas filas es gratis, y se hace así por fidelidad a LabCore, que está lleno de métodos en templates. Es también una bomba de relojería que en el dashboard de la Fase 10 —con gráficos y muchas filas— se convierte en el problema de performance central. Ejercicio 22 lo mide.
- El botón de validar oculto sobre un resultado ya validado es **cortesía visual, no seguridad**. La irreversibilidad de verdad vive en el reducer; esto solo evita que el usuario vea un botón que no haría nada. Confundir "no muestro el botón" con "protejo la invariante" es un error clásico, y el ejercicio 26 lo explota despachando la acción sin pasar por el botón.
- `sample` llega de la navegación (resuelto arriba en la cadena de rutas, igual que la orden llegaba a la muestra en la Fase 7). Que pueda venir `null` y el `verdictFor` se caiga a `new Date()` es el punto exacto donde la deuda de zona horaria se filtra al componente.

> **Prueba de fuego.** Corre `npm run seed`, `npm run mock`, `npx ng serve`. Entra a los resultados de una muestra procesada. Deberías ver valores con su unidad y badges de dentro/fuera/crítico. Toma un resultado de glucosa con `value` 105 y una muestra recogida el **15 de junio de 2019**: debería aplicar la v2 (techo 100) y salir fuera de rango. Ahora cambia a mano en `db.json` el `collectedAt` de esa muestra al **15 de mayo**: debería aplicar la v1 (techo 110) y salir dentro de rango. El mismo número, dos veredictos, según la fecha. Por último valida el resultado, mira `db.json`: `status: 'validated'`, `rangeVersionApplied` con el número de versión que aplicó, y `validatedBy` con tu usuario. Intenta validarlo otra vez desde DevTools despachando `validateResult` con su id: en el log entra la acción, no sale ningún éxito, y `db.json` no cambia.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** un resultado sale en verde (dentro de rango) cuando debería salir en rojo, o al revés, y solo en ciertas fechas.
**Causa:** `selectActiveRange` eligió la versión equivocada porque comparó la fecha del resultado contra las ventanas de vigencia sin normalizar la zona horaria (§5.3). En el borde de una ventana, el instante UTC cae del lado equivocado.
**Fix mínimo:** para el hotfix, forzar que el `atDate` que entra al selector lleve el offset explícito de la aplicación antes de comparar. **Fix correcto:** normalizar ambos lados a `America/Bogota` con una librería de zona horaria. No los confundas: el mínimo tapa el caso reportado; el correcto arregla la clase entera de bugs.

**Síntoma:** un resultado figura `validated` pero su `rangeVersionApplied` es `null`.
**Causa:** o se sembró así (los validados del `seed.js` nacen sin versión, §5.1), o se validó cuando `selectActiveRange` devolvió `null` porque ninguna ventana cubría la fecha. Un validado sin versión es un veredicto sin norma detrás.
**Fix mínimo:** rechazar la validación en el reducer si `selectActiveRange` no encuentra rango (agregar esa tercera condición a la doble guarda). **Fix correcto:** eso, más una migración que marque los validados-sin-versión existentes para revisión. Es el **incidente 12**.

**Síntoma:** validas un resultado y la orden no se mueve, aunque era la última muestra.
**Causa:** el cruce `pushOrderAfterValidate$` está como esqueleto (§5.6): el gancho existe pero el conteo no. Es deuda declarada, no bug.
**Fix mínimo:** ninguno; es el ejercicio 25. **Fix correcto:** escribir el conteo de muestras/resultados de la orden entendiendo que acopla tres slices.

**Síntoma:** el botón de validar no aparece, pero el resultado igual se puede validar.
**Causa:** confundir la cortesía visual (`*ngIf` que oculta el botón) con la guarda real (el reducer). Ocultar el botón no impide despachar la acción. Es lo correcto: la guarda vive en el reducer justamente para no depender de la UI.
**Fix:** ninguno, es el diseño. Entenderlo es el ejercicio 26.

### Pieza forense de esta fase

Lo que se depura acá son los **source maps en producción**: cómo activarlos, y por qué a veces te mienten sobre qué línea de tu código está fallando. Es la herramienta que necesitas para rastrear un bug de versionado de rango —que ocurre en `selectActiveRange`— cuando el que se rompe es un bundle minificado de PROD y el stack trace apunta a `main.a3f9.js:1:48213`. La pieza completa vive en [`forense-fase-08.md`](./forense-fase-08.md); acá basta con saber que la vas a necesitar y por qué.

El punto forense central: un source map puede estar **desactualizado** respecto al bundle que sirve producción (se rebuildeo el JS pero se subió el map viejo), y entonces te lleva a una línea de tu fuente que *parece* la culpable y no lo es. La firma de eso es un breakpoint que nunca se dispara sobre código que claramente se ejecuta. [`forense-fase-08.md`](./forense-fase-08.md) te enseña a detectar el desfase comparando el hash del bundle con el que el map dice cubrir.

**Rompe a propósito y observa.** Toma la deuda de zona horaria de §5.3 y hazla gritar. Cambia el `collectedAt` de una muestra a exactamente `'2019-05-31T20:00:00-05:00'` (las 8 de la noche del último día de la v1, hora local). Un resultado de glucosa 105 sobre esa muestra **debería** aplicar la v1 y salir dentro de rango. Mira qué versión elige `selectActiveRange` en realidad: pon un `console.log(activeRange.version)` en el effect antes del patch. Lo que vas a ver es que las 8pm del 31 en `-05:00` son la 1am del 1 de junio en UTC, así que `.getTime()` las cuenta como dentro de la ventana de la v2, y el sistema aplica el techo estricto de 100: el resultado sale **fuera de rango**, un día antes de que la norma nueva empezara a regir. Esa es la mentira: la pantalla te muestra un veredicto con total seguridad, calculado sobre la versión equivocada, y nada en la interfaz delata que la comparación de fechas se resbaló. Solo lo ves si sabes que la comparación es en UTC y que el borde cae de noche.

---

## 🧪 7. Ejercicios (35)

**🟢 Fácil (1–9)**

1. Corre `npm run seed` y abre `db.json`. Encuentra las dos versiones del rango de glucosa y anota qué fechas cubre cada una y en qué cambia el `high`. Sin correr nada más, predice qué versión aplica a una muestra del 3 de marzo y a una del 3 de julio.
2. Entra a los resultados de una muestra procesada y toma nota de un resultado de glucosa `preliminary`. Sin validarlo, di si está dentro, fuera o crítico según la fecha de su muestra.
3. Cambia en `db.json` el `value` de un resultado de glucosa a 260 y recarga. Confirma que aparece el badge de crítico y no solo el de fuera de rango. Explica por qué crítico gana sobre fuera de rango.
4. Cambia el `value` a 60 (por debajo de `low` 70 pero por encima de `criticalLow` 50). Confirma que sale fuera de rango pero **no** crítico.
5. Valida un resultado `preliminary` con tu usuario. Mira `db.json`: anota los tres campos que se estamparon (`validatedBy`, `validatedAt`, `rangeVersionApplied`) y de dónde salió cada uno.
6. En Redux DevTools, valida un resultado y anota la secuencia exacta de acciones que ves entrar, en orden. Compárala con la de transición de muestra de la Fase 7.
7. Agrega la clave i18n `results.noRange` en los tres idiomas (es, en, fr). Provoca su aparición cambiando el `analyte` de un resultado a uno sin rango sembrado (ej. `'sodium'`) y confirma que sale el badge "sin rango".
8. Localiza en `result.transitions.ts` la línea que hace que `validated` sea terminal. Bórrala (deja `validated: ['preliminary']`) y observa qué se rompe. Vuelve a ponerla.
9. En `reference-range.selector.ts`, identifica qué devuelve `selectActiveRange` cuando ninguna ventana cubre la fecha, y qué hace `evaluateResult` con esa respuesta.

**🟡 Intermedio (10–19)**

10. Toma un resultado de glucosa 105 sobre una muestra del 15 de mayo (v1, `high` 110). Confirma que sale dentro de rango. Cambia el `collectedAt` de la muestra al 15 de junio (v2, `high` 100) y confirma que ahora sale fuera. Explica en una frase por qué el mismo número cambió de veredicto.
11. **Diagnóstico.** El `ResultListComponent` usa `route.paramMap` como observable. Cámbialo a `route.snapshot.paramMap` y navega entre dos muestras distintas sin recargar. Reproduce el bug (la lista no cambia), explícalo relacionándolo con el reuso del componente, y revierte.
12. Siembra un resultado sobre una muestra en `collected` (edita `db.json` a mano). Intenta cargarle un value con `enterResult` desde la UI. Explica por qué el reducer lo rechaza y qué mitad de la doble guarda actuó.
13. **Diagnóstico.** Un resultado `validated` tiene `rangeVersionApplied: null`. Localiza las dos formas en que pudo llegar a ese estado (sembrado, o validado sin rango vigente) y di cómo distinguirías cuál fue mirando solo `db.json`.
14. Agrega al reducer una tercera condición a la guarda de `validateResult` que rechace la validación si no hay rango vigente para la fecha. Escribe una prueba mental de qué resultados dejarían de poder validarse.
15. Cambia `evaluateResult` para que un `value` exactamente igual a `range.high` cuente como fuera de rango (hoy `>` lo deja dentro). Discute si el borde debe ser inclusivo o exclusivo en un rango de referencia clínico y documenta tu decisión en el comentario.
16. Quita las llaves del `case validateResult` en el reducer (deja el `var result` sin bloque). Agrega otro `case` con otra `var result`. Observa el error de compilación y explica qué hace el hoisting de `var` en un `switch`.
17. En el effect `validateResult$`, la fecha para seleccionar el rango sale de `sample.collectedAt`. Cámbiala para que salga de `new Date().toISOString()` siempre. Explica qué escenario de negocio rompe esto (validar hoy un resultado de una muestra de hace tres meses aplicando el rango de hoy).
18. Escribe la clave i18n y el badge para distinguir "fuera de rango alto" de "fuera de rango bajo" (hoy `outOfRange` no distingue). Modifica `evaluateResult` para devolver la dirección.
19. **Diagnóstico.** Dos resultados de la misma muestra, uno de glucosa y uno de TSH. Validas el de glucosa y observas que la lista entera recarga (los dos parpadean). Explícalo relacionándolo con `reloadAfterWrite$` recargando por `sampleId`, y decide si es bug o la deuda de recarga heredada.

**🟠 Difícil (20–28)**

20. **Espejo de CRUD.** Escribe el alta de un resultado nuevo sobre una muestra procesada (acción, reducer case, effect, servicio), copiando el molde de la Fase 5. Marca con 💸 cualquier atajo que tomes.
21. Implementa `rangeVersionApplied` como parte del veredicto **mostrado** en preliminary (hoy solo se congela al validar). Muestra "se aplicaría v2" antes de validar. Discute por qué el valor mostrado en preliminary y el congelado al validar podrían diferir si pasa el tiempo entre ambos.
22. **Performance.** `verdictFor` se llama desde el template en cada detección de cambios. Con `console.count('verdict')` dentro del método, cuenta cuántas veces se ejecuta al escribir en un input de la página. Propón cómo lo resolverías en la Fase 10 (memoización, `OnPush`, pipe puro) sin implementarlo aún.
23. **Diagnóstico.** Un resultado de glucosa sobre una muestra del 31 de mayo a las 20:00 `-05:00` sale fuera de rango cuando debería salir dentro. Reproduce el bug de zona horaria de §5.3, localiza la línea exacta de `selectActiveRange` donde se pierde la zona, y explica por qué falla de noche y no de día.
24. Escribe una prueba de regresión (Jasmine) que verifique que `resultsReducer` deja el estado intacto ante `validateResult` sobre un resultado ya `validated`, y que lo cambia (a `saving: true`) ante uno `preliminary` con muestra lista. Es la prueba que la Fase 12 espera encontrar.
25. **El cruce.** Completa `pushOrderAfterValidate$`: cuenta las muestras de la orden y sus resultados validados, y despacha la acción de ordenes que lleve la orden a `partial_results` (algunas listas) o `complete` (todas). Documenta qué tres slices del store acopla y por qué eso es material de la Fase 11.
26. **Diagnóstico.** El botón de validar está oculto sobre un resultado `validated` (`*ngIf`). Despacha `validateResult` con su id desde DevTools de todas formas. Confirma que el estado no cambia y explica por qué la guarda real no era el `*ngIf`.
27. **Discusión con código.** El reducer rechaza una validación ilegal en silencio. Argumenta la posición contraria —el rechazo debería ser visible, con un `validateResultRejected` que diga *por qué* (irreversible vs muestra no lista)— y escribe esa versión. Decide cuál dejarías en un sistema regulado y justifica el comentario.
28. Siembra un rango de glucosa v3 con `effectiveFrom` en el futuro (2020). Valida hoy un resultado y confirma que **no** aplica la v3. Ahora cambia el reloj mental: ¿qué pasaría con los resultados ya validados con v2 cuando llegue 2020? Explica por qué `rangeVersionApplied` los protege.

**🔴 Muy difícil (29–35)**

29. **Diagnóstico intermitente.** Un resultado aplica bien la versión de rango los lunes a viernes y mal los sábados. Sin ver el código, formula la hipótesis (borde de vigencia + zona horaria + qué días caen los primeros/últimos de mes en 2019) y diseña el experimento mínimo que la confirma. Es el **incidente 07**.
30. **Concurrencia.** Dos pestañas abiertas sobre el mismo resultado `preliminary`. Ambas despachan `validateResult` casi a la vez. Describe qué pasa con json-server (que no tiene locks), qué queda en `validatedBy`, y por qué el reducer no protege de esto (la guarda es por instancia de store, no global). Es el **incidente 13**.
31. Refactoriza la doble guarda para que el reducer distinga tres rechazos —resultado ya validado, muestra no lista, sin rango vigente— sin dejar de ser un `switch-case` de NgRx 8 (sin `createReducer` con `on()`). Mide qué se gana en depurabilidad y qué se pierde en simplicidad.
32. **Forense de source maps.** Buildea con `ng build --prod --source-map`, sirve el `dist`, provoca un error en `selectActiveRange` (pásale un `ranges` no-array). Abre el stack trace en DevTools, confirma que el source map te lleva a la línea correcta, y después sube a mano un source map viejo (rebuildeando el código pero conservando el map anterior) y observa cómo te miente. Documenta la firma del desfase.
33. Diseña (sin implementar del todo) cómo se movería `selectActiveRange` al servidor Express de la Fase 4 para que la selección de versión no dependa de la zona del navegador. Documenta qué implica reabrir ese entregable y por qué la deuda de §5.3 existe para no hacerlo en Track A.
34. **Diagnóstico de dato imposible.** Te dan un `db.json` donde un resultado tiene `status: 'validated'`, `rangeVersionApplied: 2`, pero su muestra origen está en `collected` (nunca se procesó). Explica cómo pudo entrar ese dato pese a la doble guarda (pista: se editó el `db.json` a mano, o la muestra retrocedió después de validar), y qué invariante del sistema viola.
35. **Post-mortem.** Reconstruye, solo con Redux DevTools y Network, la historia de un resultado que terminó validado con la versión de rango equivocada. Ordena las acciones, identifica el momento donde se congeló la versión mala, y escribe el post-mortem de una página como lo pide el cuaderno de incidentes.

**🔥 Opcionales**

- 🔥 Implementa la **invalidación por rol superior**: un `supervisor1` puede llevar un `validated` de vuelta a `preliminary`. Documenta por qué esto rompe la irreversibilidad absoluta de Track A, qué estado intermedio haría falta, y por qué LabCore prefirió no tenerlo.
- 🔥 Reemplaza `selectActiveRange` por una consulta a un endpoint del Express de la Fase 4 que resuelva la versión vigente en el servidor, con zona horaria correcta. Documenta qué desaparece de §5.3 y qué se rompe si esto se adopta a medias (la mitad cliente, la mitad servidor).
- 🔥 Modela la máquina del resultado con XState en vez del mapa + `switch`. Documenta qué de la doble guarda se expresa naturalmente como guarda de XState y qué queda igual de disperso.
- 🔥 Implementa la **alerta activa de resultado crítico** (un `MatSnackBar` o un canal) que el incidente 07 dice que falta. Documenta por qué construirla no cierra el incidente 07 (que es sobre por qué no avisa *el fin de semana*, un problema de tiempo, no de feature).

---

## 📚 8. Referencias

**Documentación oficial**

- https://v8.angular.io/api/router/ActivatedRoute — `paramMap` como observable para el componente reusado entre muestras. ⚠️ Enlace no verificado al cierre; si `v8.angular.io` no responde, la alternativa es `https://angular.io/api/router/ActivatedRoute` advirtiendo que cubre una versión posterior. Arrastra el pendiente abierto en la Fase 3.
- https://ngrx.io/guide/store/reducers — reducers y por qué la doble guarda vive ahí. ⚠️ Cubre versiones posteriores; el `createReducer` con `on()` de la página **no** es el del curso: NgRx 8 usa el `switch-case` de esta fase.
- https://ngrx.io/api/store/withLatestFrom — el operador que el effect usa para leer el store al validar. ⚠️ Verifica que la firma de la versión que ves coincida con RxJS 6.5.5.
- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Date — el comportamiento de `Date` con strings ISO y `getTime()` en UTC, que es el origen de la deuda de §5.3. Léelo sabiendo que `Date` no guarda zona: guarda un instante y lo muestra en la del navegador.
- https://github.com/typicode/json-server/tree/v0.16.3 — el filtro plano `?sampleId=` que reemplaza la ruta anidada inexistente, en la versión que fijó la Fase 4.

**Libros / artículos de referencia**

- Martin Fowler, *Patterns for things that change with time* — https://martinfowler.com/eaaDev/timeNarrative.html — la teoría de los validity intervals que el versionado de rangos implementa a mano. Es la referencia de fondo para entender qué modela `selectActiveRange`.
- Sobre el manejo de fechas y zonas en JavaScript de la época (2019), cualquier material que explique por qué `Date` sin librería es una trampa para comparaciones con vigencia. ⚠️ Todo lo posterior a 2023 va a mencionar `Temporal`, que no existe en tu stack.

**Video / apoyo**

- Charlas de la época sobre manejo de tiempo en aplicaciones (2018-2020) — https://www.youtube.com/results?search_query=javascript+dates+timezones+2019 — útiles para ver el problema que la deuda de §5.3 encarna. ⚠️ Verifica la fecha: las soluciones cambiaron con `Temporal` y con la madurez de date-fns-tz.

**Orden de lectura sugerido:** antes de escribir código, el artículo de Fowler sobre validity intervals, para tener el modelo mental del versionado. Durante, el `selectActiveRange` de §5.3 y el reducer de §5.4, que son el corazón. Después, y solo si vas al forense, la doc de source maps enlazada en [`forense-fase-08.md`](./forense-fase-08.md).

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido desde que se escribió esto. Los enlaces a `v8.angular.io` están marcados como **no verificados** y arrastran el pendiente de la Fase 3. Toda la documentación de NgRx en su sitio oficial cubre una versión posterior: el `createReducer` con `on()` que vas a ver ahí no existe en tu `package.json`, donde el reducer es un `switch`.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Quedó construido el corazón normativo del sistema: un rango de referencia que se versiona por ventana de vigencia, un selector que elige qué versión aplica según la fecha, un veredicto (dentro / fuera / crítico / sin rango) que se calcula al vuelo y nunca se congela salvo en el instante de validar, y una validación irreversible que vive en el reducer con doble guarda —estado del resultado y estado de la muestra origen—. Quedaron declaradas tres deudas 💸 —la comparación de vigencia sin zona horaria explícita, el timestamp de validación estampado en cliente, y el cruce muestra→orden dejado como esqueleto—, y quedó instalado el reflejo central de la fase: **en un sistema con reglas versionadas por tiempo, un bug no rompe la pantalla; muestra un veredicto perfectamente seguro calculado sobre la versión equivocada, y solo lo ves si sabes que la comparación de fechas se resbala en los bordes.**

La **Fase 9 — Entrega y PDF en cliente** es el paso natural porque un informe es la foto congelada de un resultado validado: toma el `value`, su veredicto, la versión de rango que aplicó (`rangeVersionApplied`), quién lo firmó y cuándo, y lo imprime en un documento que sale del sistema. Sin la validación irreversible de esta fase, un PDF sería una foto de algo que todavía puede cambiar; con ella, el informe imprime un dato que ya no se mueve. Y la deuda de datos stale que la Fase 9 investiga —un PDF que salió con una copia vieja del estado— tiene su raíz justo acá, en la diferencia entre lo que está en el store y lo que se congeló al validar.

> **La señal de que quedó bien:** cuando alguien te muestre un resultado "mal clasificado" y tu primer movimiento no sea abrir el código, sino preguntar de qué fecha es la muestra y qué versión de rango regía ese día —y sospechar del borde antes que del cálculo.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-08-resultados-rangos -m "F8 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f08: …`) y los de ejercicio su
> número (`f08 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f08/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

Cosas que aparecieron escribiendo esta fase y que no caben acá:

- **[A]** El **analizador externo simulado** que empuja resultados que la aplicación no controla (`alcance-del-proyecto.md` §5). Es la única regla de negocio del dominio que ninguna fase construye, y conviene decidirla en vez de arrastrarla: o se retira del alcance, o se convierte en un **modo del inyector de caos** (`CHAOS=analyzer`, un `setInterval` en el Express que escribe en `/results` sin pasar por el store) y entonces es un ejercicio 🔥 de la **Fase 4** y material del audit log de la **Fase 11**, que tendría que registrar un evento que la aplicación no originó. La segunda opción es barata y cierra dos huecos; queda como decisión de proyecto.
- **[B]** El cruce completo `muestra → orden` (`pushOrderAfterValidate$` con su conteo real) acopla tres slices del store → queda como **ejercicio 25** acá y como material central del **apéndice A06 (NgRx 8)** y de la **Fase 11**, donde el desacople se vuelve necesario.
- **[C]** 🪦 **Resuelto.** La doble grafía `in_process` (dato) vs `inProcess` (clave i18n) reaparece en `results.status.*` en cuanto haya un estado compuesto. El patrón para escribirla —mapa explícito en vez de concatenación— quedó en el **Apéndice A07 §4**; la deuda en sí sigue declarada y sin pagar.
- 🪦 **[D] Ya estaba pagado acá.** El fix correcto de la zona horaria —normalizar ambos lados a `America/Bogota` con una librería de zonas— está en **§5.3** con la deuda 💸, en **§6** con la distinción entre fix mínimo y fix correcto, y en los ejercicios 23, 29 y el 🔥 de resolver la vigencia en el servidor. No es material de A06: no tiene nada de NgRx. Sigue siendo el **incidente 07** y en Track A no se paga.
- **[E]** La performance de `verdictFor` llamado desde el template en cada detección de cambios → es de la **Fase 10 (dashboard)**; queda anotado como ejercicio 22 acá y central allá.

### Reservas para el cuaderno de incidentes

Esta fase toma los incidentes **07, 12 y 13**. El **07** ya estaba reservado en el índice del cuaderno con el título *"Los resultados críticos no avisan el fin de semana"* (categoría tiempo, 🟠) y es la pieza de tiempo/zona horaria de esta fase; su raíz es la deuda de §5.3. El **12** y el **13** son nuevos. Los dos están en el índice del cuaderno y con su enunciado escrito:

- **07** · Fase 8 · *"Los resultados críticos no avisan el fin de semana"* · Categoría: tiempo · Dificultad 🟠 *(ya en el índice)*
- **12** · Fase 8 · *"El resultado quedó validado pero sin norma detrás"* · Categoría: normativo · Dificultad 🟡
- **13** · Fase 8 · *"Dos analistas firmaron el mismo resultado"* · Categoría: concurrencia · Dificultad 🟠
