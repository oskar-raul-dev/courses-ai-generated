# 🧫 Fase 07 — Muestras y cadena de custodia

> Tutorial Angular 8 — Laboratorio clínico · Fase 7 de 14 · **8 horas**
> Depende de: Fase 5 — Pacientes · Fase 6 — Órdenes
> Habilita: Fase 8 — Resultados y rangos versionados · Fases 10-12
> Apéndices de apoyo: [A01 (Angular Material)](./a01-material.md) · [A06 (NgRx 8)](./a06-ngrx.md) · [A07 (i18n en Angular 8)](./a07-i18n.md) · [Incidentes asociados](./cuaderno-incidentes.md): 11, 21

---

## 🎯 1. Propósito

Hasta acá el `status` de cualquier registro era una cadena que aceptaba lo que le pusieras. Una orden podía saltar de `reported` a `created`, una muestra podía nacer directamente `processed`, y nada protestaba: el `MatSelect` ofrecía los cinco valores y json-server guardaba cualquiera. Esta fase le pone reglas a esa cadena. Una muestra deja de tener un `status` suelto y pasa a tener una **máquina de estados**: un conjunto pequeño de estados, y para cada uno, la lista corta de estados a los que puede ir. Todo lo demás está prohibido, y la prohibición se hace cumplir en el reducer.

Lo que te importa a ti, que vas a *mantener* esto, es que **la mitad de los tickets de un sistema con trazabilidad regulada son transiciones ilegales que ocurrieron igual**. "La muestra aparece como procesada pero nunca se recibió." "El informe salió sobre una muestra que estaba descartada." Cuando llegue ese ticket, la pregunta no es "¿por qué está en ese estado?", sino "¿por qué el sistema la dejó llegar ahí?", y la respuesta casi siempre es que alguien despachó una acción que la guarda tenía que haber rechazado y no rechazó. Aprender dónde vive esa guarda, y cómo se ve una transición ilegal en el log, es el músculo de esta fase.

Hay una segunda razón, y es de continuidad. La muestra es la **primera relación de segundo nivel del sistema**: una muestra pertenece a una orden, que pertenece a un paciente. La Fase 5 dejó el cruce `orden → paciente` resuelto; acá se apoya encima el cruce `muestra → orden`, y esa forma anidada es la que heredan los resultados en la Fase 8 y el rastro completo en la Fase 11.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `npm run seed` incluye ahora muestras con estados del flujo canónico (`scheduled`, `collected`, `received`, `in_process`, `processed`, `discarded`), y `npm run mock` las sirve en `/samples`.
- [ ] Navegas a `/orders/101/samples` y ves las muestras de esa orden y solo esas; cambias a `/orders/102/samples` y la lista cambia, aunque el componente no se destruya entre medio.
- [ ] Sobre una muestra en `collected`, el control de transición ofrece **solo** `received` y `discarded`; los demás estados aparecen deshabilitados, no ausentes.
- [ ] Transicionas una muestra de `received` a `in_process` y en Redux DevTools ves entrar `[Samples] Transition Sample` → `[Samples] Transition Sample Success` → `[Samples] Load Samples`, en ese orden.
- [ ] Intentas forzar una transición ilegal despachando `transitionSample({ sampleId: X, toStatus: 'processed' })` a mano desde DevTools sobre una muestra en `scheduled`, y el estado **no cambia**: el reducer la ignora y lo puedes confirmar mirando que no sale ninguna acción de éxito ni ninguna petición en Network.
- [ ] La línea de custodia de una muestra muestra quién y cuándo la recogió, la recibió y la procesó, leyendo los campos `collectedBy`/`collectedAt`, `receivedBy`/`receivedAt` y `processedBy`/`processedAt` del propio registro.
- [ ] Los textos de los estados salen de i18n (`samples.status.scheduled`, `samples.status.inProcess`, etc.), no hay una sola cadena de estado escrita a mano en la plantilla.

---

## 🚫 3. Qué NO entra todavía

- La **trazabilidad transversal completa** —una colección de eventos de custodia separada, el `auditLog` de quién tocó qué en todo el sistema— → **Fase 11**. Acá el rastro de una muestra vive en campos del propio registro, no en una bitácora aparte.
- La **concurrencia de dos analistas transicionando la misma muestra al mismo tiempo**. Es una regla de negocio real del sistema, pero pertenece a la línea de concurrencia que abrió el incidente 10 en la Fase 5 y que el audit log de la Fase 11 necesita para tener sentido → se difiere; acá una transición es de a una.
- El **CRUD completo de muestras** —alta y baja de una muestra— escrito línea por línea. Es el mismo molde de la Fase 5 con otro sustantivo → queda como ejercicio de espejo (ejercicios 20 a 23). Esta fase se concentra en lo único nuevo: la transición con guarda.
- La **ruta anidada real en el backend**. El `Router` de Angular usa `/orders/:orderId/samples`, pero json-server no sirve rutas anidadas: el servicio llama al filtro plano `/samples?orderId=`. El porqué está en §5.4 y es material forense, no un descuido.
- El efecto de una transición de muestra **sobre el estado de su orden** —que recibir la última muestra empuje la orden a `in_process`— → **Fase 8**, donde las dos máquinas se cruzan.

---

## 🧠 4. Concepto mínimo

### El problema antes que la herramienta

En la Fase 6, el `status` de una orden era un campo de texto con un `MatSelect` que ofrecía los seis valores del flujo. Funcionaba, y por eso mismo era peligroso: **funcionaba también cuando no debía**. Una muestra que el sistema modela como "programada, todavía sin recoger" podía marcarse "procesada" de un clic, sin haber pasado nunca por "recogida" ni por "recibida". En un sistema de laboratorio eso no es un dato inconsistente y ya: es una muestra que el informe va a tratar como válida sin que nadie la haya tocado físicamente.

El problema real no es que el usuario elija mal. Es que **el modelo no tiene forma de decir qué es un cambio de estado legal**. `status` es un `string`, y un `string` acepta cualquier cosa. La regla "de `scheduled` solo se puede ir a `collected`" vive, si acaso, en la cabeza de quien conoce el proceso, y no en ningún lado del código donde el sistema la pueda hacer cumplir.

Una **máquina de estados** mueve esa regla al código. En lugar de un `status` que acepta los seis valores en cualquier momento, hay un mapa que dice, para cada estado, a cuáles se puede ir:

```
scheduled  → collected
collected  → received, discarded
received   → in_process, discarded
in_process → processed, discarded
processed  → (ninguno: es terminal salvo descarte administrativo)
discarded  → (ninguno: es terminal)
```

Una transición que no está en ese mapa no ocurre. No es que se muestre un error y el usuario reintente: es que la acción llega al reducer, el reducer consulta el mapa, ve que la transición no es válida, y **devuelve el estado sin tocar**. La muestra se queda donde estaba. Para el usuario, el botón no hizo nada; para tú, que vas a reconstruir el incidente, en el log hay una acción de intento y ninguna de éxito, y esa asimetría es la firma de una transición rechazada.

**Si vienes de backend**, esto es exactamente una máquina de estados finita de las que dibujas en una pizarra antes de escribir un flujo de aprobación: nodos y flechas, y las flechas que no dibujaste no existen. La analogía es limpia y se rompe en un solo punto: en el backend la pones en el servicio, con transacciones y bloqueos; acá, por fidelidad a LabCore, la invariante vive en el **reducer** de NgRx, que es síncrono, no tiene transacciones, y corre en el navegador donde cualquiera con DevTools abierto puede despachar la acción a mano. La guarda protege del error honesto, no del malicioso.

### Por qué la guarda va en el reducer y no en el effect

Hay dos lugares donde podrías poner el "¿es válida esta transición?": en el effect, antes de mandar el PATCH, o en el reducer, antes de cambiar el estado. Parecen equivalentes y no lo son.

El effect es asíncrono y toca la red. Si la guarda vive ahí, una transición ilegal se detecta *después* de decidir mandarla, mezclada con la lógica de la petición, y el estado del store depende de que el effect se haya portado bien. El reducer es síncrono y es la única función del sistema que tiene permiso para cambiar el estado. Si la guarda vive **ahí**, entonces es imposible —por construcción— que el estado llegue a una transición ilegal, venga la acción de donde venga: de un botón, de otro effect, o de alguien tecleando en la consola. La invariante deja de ser una intención y pasa a ser una propiedad del sistema.

Lo vas a ver escrito así en §5.3, y es la decisión de diseño que esta fase fija y las siguientes heredan: **el estado válido es responsabilidad del reducer; la comunicación con el servidor es responsabilidad del effect, y el effect confía en que si la acción llegó, el reducer ya la dejó pasar.**

### Nota de época

Angular 8 y NgRx 8 no traían nada parecido a una máquina de estados de primera clase; la escribes a mano con un objeto plano y un `switch`, tal como acá. Hoy tampoco NgRx la trae de fábrica —seguirías escribiéndola tú—, pero existen librerías dedicadas (XState y compañía) que la modelan explícitamente, con estados, guardas y efectos como conceptos nombrados. En 2019, en un equipo que ya tenía NgRx montado, meter otra librería de estado para las máquinas era una conversación que nadie quería tener, y por eso LabCore las tiene escritas a mano, dispersas, y a veces duplicadas. Esa dispersión es la deuda de §5.8.

---

## 💻 5. Código mínimo con comentarios

Esta fase no escribe un CRUD nuevo: reusa el molde exacto de la Fase 5 (acciones con `createAction`, reducer de `switch-case`, effect con `mergeMap` + recarga, servicio con `HttpClient`). Lo único genuinamente nuevo es la **transición con guarda**. Por eso el código de abajo muestra lo nuevo o lo distinto, y enlaza a la Fase 5 para todo lo que sería copiar y pegar.

### 5.1 `seed.js` — muestras con el flujo canónico

El semillero de las Fases 5 y 6 generó pacientes y órdenes, y dejó `samples` como estaba en el `db.json` de la Fase 4: dos registros a mano. Con dos muestras no hay máquina de estados que ejercitar. El semillero crece para cubrir los seis estados del flujo, de forma que al abrir cualquier orden haya muestras en momentos distintos de su vida.

Se agrega la función `buildSamples` al `seed.js` que ya existe. Los pacientes y las órdenes se generan igual que en la Fase 5; acá va solo lo nuevo.

```javascript
// seed.js (fragmento que se agrega al de la Fase 5)

// Los seis estados del flujo canónico de una muestra, en orden. Este arreglo
// es el orden de la vida de una muestra; el mapa de transiciones de 5.2 dice
// como se pasa de uno al siguiente. Que sean los mismos valores que fijo el
// ALCANCE y que ya usaba el db.json de la Fase 4 no es casualidad: es el
// contrato del dominio.
var SAMPLE_STATUSES = ['scheduled', 'collected', 'received', 'in_process', 'processed', 'discarded'];

var ANALYSTS = ['analista1', 'analista2', 'supervisor1'];

function buildSamples(orders) {
  var samples = [];
  var sampleId = 501;

  for (var i = 0; i < orders.length; i++) {
    var order = orders[i];
    // Una o dos muestras por orden. Con una sola muestra por orden, la lista
    // anidada de 5.7 nunca muestra más de una fila y el bug de filtrado del
    // ejercicio 9 no se puede ver.
    var count = 1 + Math.floor(random() * 2);

    for (var j = 0; j < count; j++) {
      // El estado se elige de los primeros cinco: nadie nace descartado.
      // "discarded" solo se alcanza transicionando, nunca sembrando, para que
      // el estado terminal signifique algo.
      var statusIndex = Math.floor(random() * 5);
      var status = SAMPLE_STATUSES[statusIndex];

      // Los campos de custodia se rellenan según hasta donde llegó la muestra.
      // Una muestra "scheduled" no tiene collectedBy; una "in_process" tiene
      // collectedBy y receivedBy pero no processedBy. Ese escalonamiento es lo
      // que dibuja la línea de custodia de 5.7, y sembrar campos de custodia
      // que el estado no justifica es exactamente el incidente 11.
      var reached = SAMPLE_STATUSES.indexOf(status);

      samples.push({
        id: sampleId++,
        orderId: order.id,
        status: status,
        // reached >= 1 significa que la muestra al menos se recogió.
        collectedBy: reached >= 1 ? pick(ANALYSTS) : null,
        collectedAt: reached >= 1 ? order.createdAt : null,
        // reached >= 2: al menos se recibió.
        receivedBy: reached >= 2 ? pick(ANALYSTS) : null,
        receivedAt: reached >= 2 ? order.createdAt : null,
        // reached >= 4: al menos se proceso. Ojo con el número: 'in_process' es
        // el índice 3 y 'processed' el 4, así que una muestra EN proceso todavia
        // no tiene processedBy. Escribir 3 acá siembra exactamente el dato
        // imposible del incidente 11 en la mitad de las muestras.
        processedBy: reached >= 4 ? pick(ANALYSTS) : null,
        processedAt: reached >= 4 ? order.createdAt : null
      });
    }
  }

  return samples;
}
```

Y el objeto que se escribe al `db.json` reemplaza el `samples: current.samples` de la Fase 5 por las muestras generadas:

```javascript
var samples = buildSamples(orders);

var next = {
  patients: patients,
  orders: orders,
  samples: samples,
  results: current.results,
  referenceRanges: current.referenceRanges
};
```

**Detalles con intención**

- Nadie nace `discarded`. El descarte es un estado terminal al que solo se llega transicionando, y sembrar una muestra descartada haría que el estado terminal apareciera sin historia. Un estado que no se puede distinguir de "así vino sembrado" no enseña nada.
- Los campos de custodia se rellenan por *escalones*, no todos o ninguno. Una muestra `in_process` tiene `collectedBy` y `receivedBy` pero no `processedBy`, porque todavía no se procesó. Sembrar `processedBy` en una muestra que no está procesada es una inconsistencia entre el estado y su rastro, y es la semilla del incidente 11.
- El `status` de las órdenes **no se toca**, y esta vez no por prudencia sino porque ya está bien: la Fase 5 siembra el flujo canónico (`pending`, `in_process`, `partial_results`, `complete`) y deja fuera los dos terminales, a los que solo se llega actuando. Este semillero solo añade muestras.

### 5.2 `sample.transitions.ts` — el mapa canónico

Antes de la primera acción, el mapa. Un archivo suelto, sin dependencias de Angular ni de NgRx, que dice qué transiciones existen. Es la única pieza que **debería** ser la fuente de verdad única de toda la fase; que no lo sea es la deuda de §5.8.

```typescript
// src/app/samples/store/sample.transitions.ts

// El mapa de transiciones validas. Para cada estado, la lista de estados a los
// que se puede ir. Un estado ausente del lado derecho (o con arreglo vacío) es
// terminal. Esto es la máquina de estados entera: todo lo que no está acá, no
// pasa.
export var SAMPLE_TRANSITIONS: any = {
  scheduled:  ['collected'],
  collected:  ['received', 'discarded'],
  received:   ['in_process', 'discarded'],
  in_process: ['processed', 'discarded'],
  processed:  [],
  discarded:  []
};

// Única función de consulta. La usan el reducer (para hacer cumplir la
// invariante) y el componente (para deshabilitar opciones). Que la usen los
// dos y aún así la lógica este duplicada es la deuda de 5.7: la función es
// compartida, pero cada lado decide por su cuenta que hacer con la respuesta.
export function canTransition(from: string, to: string): boolean {
  var allowed = SAMPLE_TRANSITIONS[from];
  if (!allowed) { return false; }
  return allowed.indexOf(to) >= 0;
}
```

**Detalles con intención**

- El mapa es un objeto plano tipado como `any`. TS-0: no hay un tipo `SampleStatus` que restrinja las claves, así que escribir `SAMPLE_TRANSITIONS['prcessed']` con un typo devuelve `undefined` sin que nadie avise, y `canTransition` lo trata como terminal. Ese `undefined` silencioso es el mismo patrón de la cadena mágica de la Fase 5: en el Angular de la época, todo identificador que es un `string` es una bomba sin validación.
- `canTransition` devuelve `false` para un estado de origen desconocido. Es defensa contra datos viejos: una muestra que llegue del mock con un `status` que ya no existe en el flujo no puede transicionar a ningún lado, en vez de reventar.

### 5.3 `samples.actions.ts` y el reducer con guarda

Las acciones siguen el molde de la Fase 5 al pie de la letra. Prefijo `[Samples]`, `createAction`, `props`. Lo nuevo es `transitionSample`.

```typescript
// src/app/samples/store/samples.actions.ts
import { createAction, props } from '@ngrx/store';

// Lectura: se cargan las muestras de UNA orden, no todas. El orderId viaja en
// la acción porque el effect lo necesita para armar el filtro.
export const loadSamples = createAction(
  '[Samples] Load Samples',
  props<{ orderId: number }>()
);

export const loadSamplesSuccess = createAction(
  '[Samples] Load Samples Success',
  props<{ samples: any[] }>()
);

export const loadSamplesFailure = createAction(
  '[Samples] Load Samples Failure',
  props<{ error: any }>()
);

// La acción de esta fase. Pide llevar una muestra a un estado. No garantiza
// que ocurra: el reducer decide si la transición es legal. El payload lleva
// solo lo mínimo, el "por quien" lo resuelve el effect al momento del PATCH.
export const transitionSample = createAction(
  '[Samples] Transition Sample',
  props<{ sampleId: number; toStatus: string }>()
);

export const transitionSampleSuccess = createAction(
  '[Samples] Transition Sample Success',
  props<{ sample: any }>()
);

export const transitionSampleFailure = createAction(
  '[Samples] Transition Sample Failure',
  props<{ error: any }>()
);
```

El reducer es donde vive la invariante. Es un `switch-case` idéntico en forma al de la Fase 5, con un solo `case` que hace algo que ningún reducer anterior hizo: **mira el estado actual antes de decidir si cambia**.

```typescript
// src/app/samples/store/samples.reducer.ts
import * as SamplesActions from './samples.actions';
import { canTransition } from './sample.transitions';

export interface SamplesState {
  items: any[];
  loading: boolean;
  error: any;
  saving: boolean;
  saveError: any;
  // La orden cuyas muestras están cargadas. Sirve para saber si lo que hay en
  // "items" corresponde a la orden que se está mirando o quedó de la anterior.
  // Ver el incidente 10 y el ejercicio 9.
  currentOrderId: number;
}

export const initialState: SamplesState = {
  items: [],
  loading: false,
  error: null,
  saving: false,
  saveError: null,
  currentOrderId: null
};

export function samplesReducer(state = initialState, action: any): SamplesState {
  switch (action.type) {

    case SamplesActions.loadSamples.type:
      return { ...state, loading: true, error: null, currentOrderId: action.orderId };

    case SamplesActions.loadSamplesSuccess.type:
      return { ...state, loading: false, items: action.samples };

    case SamplesActions.loadSamplesFailure.type:
      return { ...state, loading: false, error: action.error };

    // La guarda. Antes de poner "saving", se busca la muestra y se consulta el
    // mapa de transiciones. Si la transición NO es valida, el reducer devuelve
    // el estado intacto: la muestra no se mueve, "saving" no se enciende, y no
    // hay ninguna acción de éxito que despachar. Esto es lo que hace imposible
    // -por construcción- que el store llegue a una transición ilegal, venga la
    // acción de un botón o de la consola.
    case SamplesActions.transitionSample.type: {
      var sample = state.items.find(function (s) { return s.id === action.sampleId; });
      // Muestra inexistente o transición ilegal: no se hace nada. El intento
      // queda en el log de DevTools (la acción se despacho) pero sin efecto en
      // el estado, y esa asimetría es la firma forense de la fase.
      if (!sample || !canTransition(sample.status, action.toStatus)) {
        return state;
      }
      return { ...state, saving: true, saveError: null };
    }

    case SamplesActions.transitionSampleSuccess.type:
      return { ...state, saving: false };

    case SamplesActions.transitionSampleFailure.type:
      return { ...state, saving: false, saveError: action.error };

    default:
      return state;
  }
}
```

**Detalles con intención**

- El `case` de `transitionSample` lleva llaves (`{ ... }`) alrededor. No es decorativo: en un `switch`, declarar `var sample` sin un bloque propio lo *hoista* al `switch` entero, y si otro `case` declarara otra `var sample`, chocarían. Las llaves le dan al `case` su propio ámbito. Ejercicio 15.
- Que el reducer devuelva `state` sin tocarlo ante una transición ilegal es deliberado y silencioso. **No lanza un error, no despacha un fallo, no marca `saveError`.** Para el usuario, el control simplemente no reaccionó. Esa elección tiene un costo —el usuario no sabe *por qué* no pasó nada— y es material del incidente 10 y del ejercicio 27, donde se discute si el rechazo debería ser visible.
- `find` recorre el arreglo en cada transición. Con dos muestras por orden es gratis; es la misma decisión de "no optimizar lo que no duele" de toda la serie.

### 5.4 `samples.service.ts` — la ruta anidada que el mock no tiene

Acá está el punto que decidimos al abrir la fase. El `Router` de Angular navega a `/orders/:orderId/samples`, pero **json-server no sirve rutas anidadas**: no existe el recurso `/orders/101/samples`. Lo que json-server sí sabe hacer es filtrar un recurso plano por un campo, exactamente como la Fase 5 filtró pacientes por `documentId`. Así que la ruta anidada vive en Angular, y el servicio traduce a un filtro plano.

```typescript
// src/app/samples/samples.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class SamplesService {

  constructor(private http: HttpClient) { }

  // La URL de Angular es /orders/:orderId/samples, pero json-server no tiene
  // rutas anidadas: acá se traduce a /samples?orderId=. La ruta bonita es una
  // convención de NAVEGACIÓN; el backend solo entiende el filtro plano. Esta
  // distancia entre lo que dice la URL del navegador y lo que viaja en Network
  // es real en el sistema y es material del ejercicio 10.
  getSamplesByOrder(orderId: number): Observable<any> {
    return this.http.get(environment.apiUrl + '/samples?orderId=' + orderId);
  }

  // Una muestra suelta, por id. No la usa esta fase: la usa la Fase 8, que
  // necesita conocer el estado de la muestra origen para su doble guarda.
  // Añadido por edición retroactiva; ver la nota de continuidad de abajo.
  getById(sampleId: number): Observable<any> {
    return this.http.get(environment.apiUrl + '/samples/' + sampleId);
  }

  // La transición es un PATCH de un solo campo, igual que la baja lógica de la
  // Fase 5. Además del status, se estampa el "por quien y cuando" del evento
  // de custodia que corresponde a ESE estado destino. Ese estampado a mano es
  // lo que en un sistema serio haría el backend; acá lo hace el cliente, y esa
  // es la deuda de custodia de esta fase (ver la nota de 5.5).
  transition(sampleId: number, patch: any): Observable<any> {
    return this.http.patch(environment.apiUrl + '/samples/' + sampleId, patch);
  }
}
```

> **Nota de continuidad (editada desde la Fase 8).** El método `getById` no lo
> necesita esta fase: lo necesita la **Fase 8 §5.4**, cuya doble guarda cruza el
> estado del resultado con el de su muestra origen y por lo tanto tiene que
> conocerla. En la primera versión del curso ese circuito no existía y la guarda
> rechazaba siempre —el detalle está en la nota de continuidad de aquella fase—.
> Se añade aquí, que es donde vive el servicio de muestras, con el mismo
> precedente que el `server.js` de la Fase 3: una brecha detectada tarde se
> corrige con una edición localizada del entregable anterior.

**Detalles con intención**

- El `orderId` no se codifica con `encodeURIComponent` porque es un número. Si algún día llegara como cadena con caracteres raros —no en este mock, pero sí en sistemas reales donde los ids son UUID o códigos— haría falta. Ejercicio 11.
- `transition` recibe un `patch` genérico y no un `status` suelto, porque el PATCH lleva el estado **y** los campos de custodia del evento. Quién arma ese `patch` es el effect, en §5.5, y ahí está la parte fea.

### 5.5 `samples.effects.ts` — transicionar y volver a leer

El effect sigue el patrón de la Fase 5 sin novedad estructural: `mergeMap`, `timeout`, `catchError`, y un `reloadAfterWrite$` que recarga la lista completa después de una transición exitosa. La única complicación nueva es armar el `patch` de custodia: según a qué estado va la muestra, se estampa un campo de custodia distinto.

```typescript
// src/app/samples/store/samples.effects.ts
import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { map, mergeMap, switchMap, catchError, timeout } from 'rxjs/operators';

import { SamplesService } from '../samples.service';
import { AuthService } from '../../core/auth/auth.service';
import * as SamplesActions from './samples.actions';

// Heredada de la Fase 4, igual que en pacientes.
var REQUEST_TIMEOUT_MS = 10000;

// Que campo de custodia estampa cada estado destino. Entrar a "received"
// estampa receivedBy/receivedAt; entrar a "processed" estampa processedBy, y
// así. Esta tabla es prima del mapa de transiciones y podría vivir en el mismo
// archivo; que estén separadas es parte de la dispersión que se paga en 5.6.
var CUSTODY_FIELD: any = {
  collected:  'collected',
  received:   'received',
  in_process: 'inProcess',
  processed:  'processed'
  // discarded no estampa un "por quien": el descarte se rastrea aparte en la
  // Fase 11. Acá solo cambia el status.
};

@Injectable()
export class SamplesEffects {

  constructor(
    private actions$: Actions,
    private samplesService: SamplesService,
    private authService: AuthService
  ) { }

  loadSamples$ = createEffect(function (this: SamplesEffects) {
    return this.actions$.pipe(
      ofType(SamplesActions.loadSamples),
      switchMap((action: any) => {
        return this.samplesService.getSamplesByOrder(action.orderId).pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (samples: any) {
            return SamplesActions.loadSamplesSuccess({ samples: samples });
          }),
          catchError(function (error: any) {
            return of(SamplesActions.loadSamplesFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));

  transitionSample$ = createEffect(function (this: SamplesEffects) {
    return this.actions$.pipe(
      ofType(SamplesActions.transitionSample),
      // mergeMap, no switchMap: cancelar una transición en curso porque llegó
      // otra sería perder un cambio de custodia en silencio. Misma lección que
      // la escritura de pacientes en la Fase 5.
      mergeMap((action: any) => {
        // El patch base: el nuevo status. A eso se le agrega el campo de
        // custodia que corresponda al estado destino.
        var patch: any = { status: action.toStatus };
        var field = CUSTODY_FIELD[action.toStatus];
        if (field) {
          // El "por quien" sale del usuario autenticado de la Fase 3; el
          // "cuando" es ahora. Que el cliente estampe la hora es la deuda: en
          // un sistema serio el timestamp de custodia lo pone el servidor, no
          // el navegador, cuya hora el usuario puede cambiar. Ver la nota 💸.
          patch[field + 'By'] = this.authService.getCurrentUser();
          patch[field + 'At'] = new Date().toISOString();
        }

        return this.samplesService.transition(action.sampleId, patch).pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (updated: any) {
            return SamplesActions.transitionSampleSuccess({ sample: updated });
          }),
          catchError(function (error: any) {
            return of(SamplesActions.transitionSampleFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));

  // Después de una transición exitosa, recargar las muestras de la orden
  // actual. Mismo patrón de "cobardía deliberada" de la Fase 5: dos viajes
  // donde alcanzaba uno, a cambio de nunca desincronizarse del servidor.
  // Necesita el orderId, que no viaja en la acción de éxito: se lee del store.
  reloadAfterTransition$ = createEffect(function (this: SamplesEffects) {
    return this.actions$.pipe(
      ofType(SamplesActions.transitionSampleSuccess),
      map(function (this: SamplesEffects) {
        // Se lee el orderId actual del componente, que lo mantiene. Ver 5.7.
        // Alternativa: inyectar el Store y leer currentOrderId del estado.
        return SamplesActions.loadSamples({ orderId: this.currentOrderId });
      }.bind(this))
    );
  }.bind(this));

  // El orderId de la orden que se está mirando, guardado para el reload. Lo
  // setea el componente al cargar (ver 5.8). Es un caso feo -estado mutable en
  // el effect- y está acá para no inyectar el Store solo por un número; se
  // discute la alternativa correcta en el ejercicio 26.
  currentOrderId: number = null;
}
```

> 💸 **Deuda técnica intencional: el cliente estampa el timestamp de custodia.** El `receivedAt`, el `processedAt` y el nombre del analista los pone el navegador, con `new Date()` y el usuario autenticado del lado del cliente. La hora sale del reloj de la máquina del operador, que el operador puede cambiar, y el "por quién" sale de un token que vive en `localStorage`.
>
> **Lo correcto hoy** sería que el servidor estampara el evento de custodia: el cliente manda solo "pasa esta muestra a `received`", y el backend, que es la autoridad, escribe quién (del token que él validó) y cuándo (de su propio reloj). La cadena de custodia de un laboratorio es justamente el tipo de dato que no puede depender del reloj del cliente.
>
> **En Track A no se paga.** El mock es json-server: no ejecuta lógica, solo guarda lo que le mandan. Estampar en el servidor obligaría a mover esa lógica al Express de la Fase 4 y a reabrir un entregable cerrado. En LabCore la custodia sí se sella en el servidor, y por eso este código es una simplificación del mock, no del diseño. Lo que te llevas es el reflejo: **cuando un timestamp de custodia no cuadre, la primera pregunta es de qué reloj salió.**

### 5.6 `samples.selectors.ts` — cuatro consultas y ninguna sorpresa

Es el archivo más mecánico de la fase y por eso casi se queda sin escribir. Sigue
el molde de la Fase 5 §5.6 al pie de la letra; lo único que conviene mirar es la
última línea.

```typescript
// src/app/samples/store/samples.selectors.ts
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { SamplesState } from './samples.reducer';

// La cadena 'samples' tiene que coincidir con la del StoreModule.forFeature de
// samples.module.ts. Son dos strings sueltas en dos archivos y nadie las valida:
// es el primero de los tres errores silenciosos de A06 §10.
export const selectSamplesState = createFeatureSelector<SamplesState>('samples');

export const selectAllSamples = createSelector(
  selectSamplesState,
  function (state) { return state.items; }
);

export const selectSamplesLoading = createSelector(
  selectSamplesState,
  function (state) { return state.loading; }
);

// La orden cuyas muestras están cargadas. Lo consulta el effect de recarga
// (5.5) para saber qué volver a pedir después de una transición, y es lo que
// permite responder "¿lo que veo en pantalla corresponde a la orden de la URL?",
// que es la pregunta del incidente 21.
export const selectCurrentOrderId = createSelector(
  selectSamplesState,
  function (state) { return state.currentOrderId; }
);
```

**Detalle con intención.** No hay un `selectSamplesByStatus`, y no es un olvido: un
selector con parámetro se escribe con una *factory* —una función que devuelve un
`createSelector`, como el `selectAuditLogForEntity` de la Fase 11 §5.7— y tiene una
trampa que conviene descubrir escribiéndolo. Es el ejercicio 12.

### 5.7 La duplicación de la guarda — deuda declarada

La invariante de transición vive en el reducer (§5.3): es ahí donde se hace cumplir. Pero el componente (§5.8) **también** necesita saber qué transiciones son válidas, por una razón de interfaz: para no ofrecerle al usuario opciones que el reducer va a rechazar. Un `MatSelect` que muestra los seis estados y después no hace nada cuando eliges uno inválido es una interfaz que miente.

Así que el mapa de `sample.transitions.ts` se consulta en **dos lugares**: el reducer lo usa para proteger el estado, y el componente lo usa para deshabilitar opciones. Los dos llaman a la misma función `canTransition`, con lo cual la *fuente de datos* es única; pero la *lógica de qué hacer con la respuesta* está escrita dos veces, y peor: el effect de §5.5 tiene además su propia tabla `CUSTODY_FIELD`, que es prima hermana del mapa de transiciones y vive aparte.

> 💸 **Deuda técnica intencional: la regla de transición decidida en dos capas.** El reducer valida la transición y el componente la valida otra vez para pintar la interfaz. Si mañana cambia una regla —digamos que de `processed` se pueda volver a `in_process` para reprocesar—, hay que tocar el mapa y *acordarse* de que el componente ya lee del mapa (bien) pero que la tabla `CUSTODY_FIELD` del effect no (mal): un estado nuevo en el mapa no aparece automáticamente con su campo de custodia.
>
> **Lo correcto hoy** sería una sola descripción de la máquina —estados, transiciones y qué campo de custodia estampa cada uno— en un único lugar, y que las tres capas (reducer, componente, effect) la consultaran sin reimplementar nada. Es lo que hace una librería de máquinas de estado, y es lo que en 2019 el equipo no quiso adoptar.
>
> **En Track A no se paga.** Unificar las tres capas es un rediseño de cómo el sistema modela sus máquinas de estado, no un hotfix, y hay varias de estas máquinas dispersas por el código. Lo que sí te llevas: **cuando agregues un estado, busca todos los lugares que conocen la máquina, no solo el reducer.** El ejercicio 24 te hace agregar un estado y descubrir, a los golpes, cuántos lugares eran.

### 5.8 `sample-timeline.component.ts` — la línea de custodia y el control de transición

El componente gordo de la fase. Carga las muestras de la orden que viene en la URL, dibuja para cada una su línea de custodia, y ofrece las transiciones válidas. Reproduce el mapa (a través de `canTransition`) para deshabilitar lo inválido.

```typescript
// src/app/samples/sample-timeline/sample-timeline.component.ts
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { Store } from '@ngrx/store';

import * as SamplesActions from '../store/samples.actions';
import * as SamplesSelectors from '../store/samples.selectors';
import { SAMPLE_TRANSITIONS, canTransition } from '../store/sample.transitions';

@Component({
  selector: 'app-sample-timeline',
  templateUrl: './sample-timeline.component.html',
  styleUrls: ['./sample-timeline.component.scss']
})
export class SampleTimelineComponent implements OnInit {

  orderId: number = null;
  samples: any[] = [];
  loading = false;

  // Los seis estados en orden, para dibujar la línea de custodia completa y
  // marcar por donde va la muestra. Se lee del mapa para no escribir la lista
  // dos veces... aunque el orden del objeto no está garantizado por el
  // lenguaje. Ver el ejercicio 16.
  allStatuses: string[] = Object.keys(SAMPLE_TRANSITIONS);

  constructor(
    private route: ActivatedRoute,
    private store: Store<any>
  ) { }

  ngOnInit() {
    // El orderId viene de la ruta anidada /orders/:orderId/samples. Si esta
    // pantalla se reusa navegando de una orden a otra sin destruir el
    // componente, hay que reaccionar al cambio del parámetro, no leerlo una
    // sola vez. Leerlo una vez es el bug del ejercicio 9.
    this.route.paramMap.subscribe(function (this: SampleTimelineComponent, params) {
      this.orderId = Number(params.get('orderId'));
      this.store.dispatch(SamplesActions.loadSamples({ orderId: this.orderId }));
    }.bind(this));

    this.store.select(SamplesSelectors.selectAllSamples).subscribe(function (this: SampleTimelineComponent, samples) {
      this.samples = samples;
    }.bind(this));

    this.store.select(SamplesSelectors.selectSamplesLoading).subscribe(function (this: SampleTimelineComponent, loading) {
      this.loading = loading;
    }.bind(this));
  }

  // Los estados a los que ESTA muestra puede ir. La plantilla lo usa para
  // pintar los botones habilitados. Misma info que ya tiene el reducer: esta
  // es la mitad de la duplicación de 5.6.
  allowedTargets(sample: any): string[] {
    return SAMPLE_TRANSITIONS[sample.status] || [];
  }

  // La plantilla pregunta por cada estado del flujo si esta muestra puede ir
  // ahí, para deshabilitar en vez de ocultar. Deshabilitar y no ocultar es una
  // decisión de producto: el usuario ve que el estado existe pero no está
  // disponible desde donde está, y aprende la máquina mirándola.
  canGoTo(sample: any, toStatus: string): boolean {
    return canTransition(sample.status, toStatus);
  }

  transition(sample: any, toStatus: string) {
    // El componente NO revalida antes de despachar: confia en el reducer. Si
    // canGoTo devolvió true, despacha; si el estado cambio entre el render y
    // el clic, el reducer lo atrapa. Esta es la línea que separa "el
    // componente decide" de "el componente pide y el store decide".
    this.store.dispatch(SamplesActions.transitionSample({
      sampleId: sample.id,
      toStatus: toStatus
    }));
  }

  // Devuelve los eventos de custodia ya ocurridos de una muestra, para la
  // línea de tiempo: cada evento con su estado, su responsable y su fecha.
  // Toda la lógica de presentación vive acá, en el componente gordo.
  custodyEvents(sample: any): any[] {
    var events = [];
    if (sample.collectedBy) {
      events.push({ status: 'collected', by: sample.collectedBy, at: sample.collectedAt });
    }
    if (sample.receivedBy) {
      events.push({ status: 'received', by: sample.receivedBy, at: sample.receivedAt });
    }
    if (sample.processedBy) {
      events.push({ status: 'processed', by: sample.processedBy, at: sample.processedAt });
    }
    return events;
  }
}
```

**Detalles con intención**

- `this.route.paramMap.subscribe(...)` y no `this.route.snapshot.paramMap.get(...)`. El `snapshot` se lee una vez, al construir el componente. Si el router reusa el componente al navegar de `/orders/101/samples` a `/orders/102/samples` —que es lo normal cuando solo cambia un parámetro—, el `snapshot` sigue diciendo `101` y la lista nunca se actualiza. Es el bug del ejercicio 9, y es de los más comunes de la época.
- `custodyEvents` reconstruye la línea de tiempo a partir de los campos del registro. Si una muestra tiene `processedBy` pero no `receivedBy` —una inconsistencia que el seed no genera pero que un dato viejo sí podría tener—, la línea muestra "procesada" sin "recibida", y el hueco es exactamente lo que hace visible el incidente 11.
- `custodyEvents` está en el componente, no en un selector ni en un servicio. Es lógica de presentación viviendo dentro del componente gordo: así es LabCore, y así se comenta, no se corrige.

### 5.9 La plantilla del timeline

```html
<!-- src/app/samples/sample-timeline/sample-timeline.component.html -->
<h2>{{ 'samples.title' | translate }}</h2>

<div *ngIf="loading">{{ 'common.loading' | translate }}</div>

<mat-card *ngFor="let sample of samples" class="sample-card">

  <!-- Estado actual, traducido. Nunca el valor crudo: samples.status.inProcess
       resuelve a "En proceso", "In process" o "En cours" según el idioma. -->
  <div class="sample-status">
    {{ ('samples.status.' + sample.status) | translate }}
  </div>

  <!-- La línea de custodia: los eventos ya ocurridos, con quién y cuándo. -->
  <ul class="custody-timeline">
    <li *ngFor="let event of custodyEvents(sample)">
      {{ ('samples.status.' + event.status) | translate }}
      — {{ event.by }} — {{ event.at | date:'short' }}
    </li>
  </ul>

  <!-- Los botones de transición. Se pintan TODOS los estados del flujo, pero
       cada uno deshabilitado si la muestra no puede ir ahí desde donde está.
       Deshabilitar y no ocultar: el usuario ve la máquina completa. -->
  <div class="transition-actions">
    <button mat-stroked-button
            *ngFor="let target of allStatuses"
            [disabled]="!canGoTo(sample, target)"
            (click)="transition(sample, target)">
      {{ ('samples.status.' + target) | translate }}
    </button>
  </div>

</mat-card>
```

Y las claves nuevas que esta fase agrega al árbol de referencia `es.json` (los otros dos idiomas quedan incompletos a propósito, como fijó la Fase 2, y se completan cuando toque):

```json
{
  "samples": {
    "title": "Muestras",
    "status": {
      "scheduled": "Programada",
      "collected": "Recogida",
      "received": "Recibida",
      "inProcess": "En proceso",
      "processed": "Procesada",
      "discarded": "Descartada"
    }
  }
}
```

**Detalle con intención.** La clave i18n del estado `in_process` es `samples.status.inProcess`, en camelCase, aunque el valor del dato sea `in_process` con guion bajo. Es la misma convención que fijó la Fase 2 con `orders.status.inProcess`: el valor viaja en snake_case porque así lo guarda el mock, y la clave se escribe en camelCase porque así son las claves del proyecto. Concatenar `'samples.status.' + sample.status` produce `samples.status.in_process`, que **no existe** en el árbol. Por eso la plantilla no puede concatenar el valor crudo para el estado `in_process` sin más: o el dato se normaliza, o la clave se mapea. Este desajuste es real y es el ejercicio 13.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**La transición no hace nada y no hay ningún error.**
Síntoma: haces clic en un estado, el botón estaba habilitado, y la muestra no cambia. Ni error en consola, ni petición en Network, ni acción de éxito en DevTools.
Causa: casi siempre, el estado de la muestra en el store no es el que muestra la pantalla, y la transición que la interfaz creía válida el reducer la ve inválida contra el estado *real*. Menos común pero posible: el `sampleId` del payload no coincide con ningún `id` de `items`, y el `find` del reducer devuelve `undefined`.
Fix mínimo: mirar en DevTools el estado de esa muestra en `items` justo antes del clic, y compararlo con lo que pinta la pantalla. Si difieren, la pantalla está desactualizada (típicamente el bug de `snapshot` del ejercicio 9). La refactorización correcta —hacer visible el rechazo con un mensaje— es decisión de producto, no hotfix.

**`samples.status.in_process` aparece crudo en pantalla.**
Síntoma: cinco estados se traducen bien y el sexto muestra la clave literal `samples.status.in_process`.
Causa: la plantilla concatena `'samples.status.' + sample.status`, y para ese estado el valor es `in_process` (snake_case) mientras la clave del árbol es `inProcess` (camelCase). Los otros cinco estados coinciden en ambas grafías por casualidad, y por eso el bug se esconde en uno solo.
Fix mínimo: normalizar el valor a camelCase antes de concatenar, o agregar un alias `samples.status.in_process` en el árbol. La refactorización correcta es tener una sola grafía en todo el sistema, que es la deuda de i18n de la Fase 2.

**Las muestras de la orden anterior siguen en pantalla al cambiar de orden.**
Síntoma: entras a `/orders/101/samples`, ves sus muestras, navegas a `/orders/102/samples`, y sigues viendo las de la 101.
Causa: el componente leyó el `orderId` con `route.snapshot` una sola vez, en `ngOnInit`. Al navegar entre dos rutas que solo difieren en un parámetro, el router **reusa** el componente sin volver a construirlo, así que `ngOnInit` no corre de nuevo y el `snapshot` sigue apuntando a la orden vieja.
Fix mínimo: suscribirse a `route.paramMap` en vez de leer el `snapshot`, como hace §5.8. La refactorización correcta no existe: es directamente el patrón correcto para un componente que se reusa. Este es el **incidente 21**.

**`Cannot read property 'indexOf' of undefined` al transicionar.**
Síntoma: una muestra revienta al ofrecer sus transiciones, con ese error apuntando a `canTransition`.
Causa: la muestra tiene un `status` que no es ninguna clave de `SAMPLE_TRANSITIONS` —un valor viejo, un typo sembrado, un estado que existía en una versión anterior del flujo—. `SAMPLE_TRANSITIONS[sample.status]` da `undefined`, y `allowedTargets` lo devuelve tal cual a la plantilla sin el `|| []` de guarda.
Fix mínimo: el `|| []` ya está en `allowedTargets` de §5.8; si el error aparece es porque algún consumidor consultó el mapa directo sin esa red. La lección es la misma de siempre: **todo acceso a un mapa por clave-string necesita su valor por defecto**, porque el compilador de la época no te avisa de la clave que no existe.

### Pieza forense de esta fase

La pieza es **rastrear una transición ilegal en los logs**, y se desarrolla completa en [`forense-fase-07.md`](./forense-fase-07.md). Acá va el gancho.

El ticket dice: *"hay una muestra que figura como procesada pero el analista jura que nunca la recibió"*. En pantalla, la muestra está en `processed` y su línea de custodia tiene un hueco: aparece "Recogida" y "Procesada", pero no "Recibida". Físicamente imposible según el flujo —a `processed` solo se llega desde `in_process`, y a `in_process` solo desde `received`—, y sin embargo ahí está.

El trabajo forense son tres movimientos. Primero, **decidir si la transición ilegal ocurrió en este sistema o llegó ya rota del dato**. Si alguien transicionó ilegalmente *acá*, en el log de acciones tiene que haber un `[Samples] Transition Sample` con `toStatus: 'processed'` sobre una muestra que estaba en `received` o antes —y el reducer lo tendría que haber rechazado, así que **no habría** un `Transition Sample Success` detrás—. Si no hay ni siquiera el intento en el log, la muestra llegó rota del `db.json` o de una migración, y es otra investigación. Esa bifurcación se decide leyendo el log, y ahorra medio día de buscar en el lugar equivocado.

Segundo, **si el intento está y el éxito también, la guarda falló**, y eso es grave: significa que el reducer dejó pasar una transición que `canTransition` debería haber negado. Las causas posibles son acotadas y todas educativas: el mapa tiene la transición que no debería (alguien editó `SAMPLE_TRANSITIONS`), o el `status` contra el que se validó no era el real (la muestra se transicionó dos veces rápido y la segunda validó contra un estado intermedio que el store todavía no reflejaba), o la validación se saltó porque el `find` no encontró la muestra y —en una versión bugueada del reducer— el `undefined` se trató como "sigue adelante".

Tercero, **decidir el fix mínimo**. Corregir el dato de esa muestra es una línea de PATCH. Endurecer el reducer para que un `find` fallido nunca deje pasar es otra línea. Hacer el rechazo visible al usuario es un cambio de interfaz. Cuál corresponde depende de cuál de las tres causas fue, y por eso el diagnóstico va antes que el parche.

**Rompe a propósito y observa.** Edita `SAMPLE_TRANSITIONS` en `sample.transitions.ts` y agrega `'processed'` a la lista de `scheduled`:

```typescript
scheduled: ['collected', 'processed'],   // transición ilegal metida a mano
```

Ahora abre una orden con una muestra en `scheduled`, y transiciónala directo a `processed`.

Lo que vas a ver en pantalla: la muestra salta a "Procesada" sin problema. Lo que vas a ver en su línea de custodia: "Programada" y después "Procesada", con el hueco donde deberían estar "Recogida" y "Recibida" —porque esos eventos nunca se estamparon—. Lo que vas a ver en Redux DevTools: `Transition Sample` → `Transition Sample Success` → `Load Samples`, todo normal, como si fuera una transición legítima. Lo que vas a ver en Network: un PATCH exitoso.

La mentira que te va a contar la pantalla es que todo está bien: la muestra se procesó, el flujo se cumplió. Nada grita. La única evidencia de que algo está mal es el **hueco en la línea de custodia**, y solo lo notas si sabes que el flujo no permite ese salto. Ese es el punto de la fase: en un sistema con máquina de estados, el bug no siempre se ve como un error rojo; a veces se ve como un dato que es imposible según las reglas, y hay que conocer las reglas para verlo. Ahora quita la transición que metiste y confirma que la muestra en `scheduled` ya no ofrece `processed`.

Los **incidentes 11 y 21** del cuaderno viven de esta fase. El 11 es la muestra con la custodia inconsistente, la del hueco; el 21 es la lista que no cambia al navegar entre órdenes, el `snapshot` que no reacciona.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Corre `npm run seed` y cuenta cuántas muestras quedaron en cada estado. Explica por qué ninguna quedó en `discarded` y por qué ese número es estable entre corridas.
2. Abre `/orders/101/samples` y `/orders/102/samples` y anota cuántas muestras tiene cada una. Confirma en la pestaña Network que cada navegación dispara un `GET /samples?orderId=` distinto.
3. Sobre una muestra en `collected`, lista qué botones de transición aparecen habilitados y cuáles deshabilitados. Contrástalo con el mapa de `SAMPLE_TRANSITIONS` y confirma que coinciden.
4. Agrega la clave `samples.status.discarded` al `en.json`, cambia el idioma a inglés, y confirma que una muestra descartada ahora se traduce en vez de mostrar la clave cruda.
5. Transiciona una muestra de `received` a `in_process` y anota, en orden, las tres acciones que aparecen en Redux DevTools.
6. En `sample.transitions.ts`, ¿qué devuelve `canTransition('processed', 'in_process')` y por qué? ¿Y `canTransition('discarded', 'collected')`?
7. Mira la línea de custodia de una muestra en `in_process`. ¿Cuántos eventos muestra? Explica por qué `processedBy` está en `null` para esa muestra.
8. Agrega el texto `common.loading` al `es.json` si no existe, y confirma que el mensaje de carga de §5.8 se resuelve.

**🟡 Intermedio (9–17)**

9. **Diagnóstico.** Cambia el `route.paramMap.subscribe` de §5.8 por `route.snapshot.paramMap.get('orderId')`. Navega de `/orders/101/samples` a `/orders/102/samples` sin recargar. Anota qué muestra la pantalla, qué dice la URL, y qué `orderId` viajó en el último `GET` de Network. Es el incidente 21.
10. Con las herramientas de red abiertas, transiciona una muestra y anota la URL exacta del PATCH. Explica por qué la URL de la barra del navegador dice `/orders/101/samples` pero la petición va a `/samples/501`.
11. Cambia el `orderId` de la ruta por un valor que no existe (`/orders/9999/samples`). ¿Qué devuelve el `GET`? ¿Qué muestra la pantalla? ¿Es un error o una lista vacía, y por qué importa la diferencia?
12. Escribe el selector `selectSamplesByStatus(status)` que devuelva solo las muestras en un estado dado, memoizado sobre `selectAllSamples`, siguiendo el patrón de `selectFilteredPatients` de la Fase 5.
13. **Diagnóstico.** Siembra una muestra con `status: 'in_process'` y mira cómo se pinta su estado actual en pantalla. Localiza por qué aparece la clave cruda `samples.status.in_process` y aplica el fix mínimo de §6.
14. Agrega al reducer un `case` para una acción nueva `resetSamples` que vuelva al `initialState`. Justifica si va antes o después del `default`.
15. **Diagnóstico.** Quita las llaves del `case transitionSample` del reducer (§5.3) y agrega otro `case` más abajo que también declare `var sample`. Anota el error de compilación y explica qué tiene que ver con el ámbito de `var` en un `switch`.
16. `allStatuses = Object.keys(SAMPLE_TRANSITIONS)` asume que el orden del objeto es el del flujo. Investiga si ese orden está garantizado por el lenguaje para claves de tipo string, y propón una forma que no dependa de esa suposición.
17. Transiciona una muestra a `discarded` y confirma en `db.json` que el PATCH **no** estampó un campo `discardedBy`. Explica, leyendo `CUSTODY_FIELD`, por qué el descarte es el único estado que no estampa custodia.

**🟠 Difícil (18–24)**

18. **Diagnóstico.** Levanta el mock con `CHAOS=latency=3000`, transiciona una muestra y, sin esperar la respuesta, transiciónala de nuevo a otro estado válido. Anota qué llega a DevTools, qué queda en `db.json`, y contra qué estado validó la segunda transición. Relaciónalo con la elección de `mergeMap`.
19. **Diagnóstico.** Te dan este log: `[Samples] Transition Sample` (toStatus: `processed`) y **nada más** detrás. Reconstruye qué muestra recibió el intento, en qué estado estaba, y por qué no hay acción de éxito. ¿Qué ve el usuario en pantalla?
20. Construye el `SamplesModule` completo: `samples.module.ts` con `StoreModule.forFeature('samples', samplesReducer)`, `EffectsModule.forFeature([SamplesEffects])`, y el routing `forChild` con la ruta anidada `/orders/:orderId/samples`. Confirma que el slice `samples` no existe en el store hasta navegar ahí por primera vez.
21. Escribe el CRUD de alta de muestra por espejo del de pacientes de la Fase 5: acción `createSample`, effect con `mergeMap`, recarga después del éxito. Anota qué campos de custodia lleva una muestra recién creada.
22. Agrega la baja de muestra como baja lógica (`active: false`), reusando el patrón de `deactivatePatient`. Discute si una muestra descartada y una muestra dada de baja son lo mismo o no.
23. Escribe el selector `selectSampleById(id)` y úsalo para mostrar el detalle de una muestra en un diálogo, reusando el molde de `MatDialog` de la Fase 5.
24. **Diagnóstico.** Agrega un estado nuevo `revalidation` al flujo, alcanzable desde `processed`. Recorre el sistema y anota **todos** los lugares que hubo que tocar para que funcione de punta a punta: el mapa, el reducer, la tabla de custodia del effect, la interfaz, i18n. Cuenta cuántos eran y relaciónalo con la deuda de §5.7.

**🔴 Muy difícil (25–30)**

25. **Diagnóstico.** Reproduce el escenario de la pieza forense: mete a mano la transición ilegal `scheduled → processed` en el mapa, transiciona una muestra, y quita la transición. Después, sin el mapa alterado, encuentra esa muestra rota y decide: ¿corriges el dato, o hay algo más que arreglar? Escribe el diagnóstico completo.
26. El effect guarda `currentOrderId` como propiedad mutable para el reload (§5.5). Reescríbelo inyectando el `Store` y leyendo `currentOrderId` del estado con un selector, sin esa propiedad. Explica qué gana y qué pierde cada versión.
27. **Discusión con código.** El reducer rechaza una transición ilegal en silencio (§5.3). Argumenta la posición contraria —el rechazo debería ser visible— y escribe la versión que despacha un `transitionSampleRejected` con un mensaje para el usuario. Después decide cuál dejarías en un sistema de laboratorio y justifica el comentario en el código.
28. **Diagnóstico.** Siembra una muestra con `processedBy` lleno pero `receivedBy` en `null` (la inconsistencia del incidente 11). Anota cómo se ve su línea de custodia, por qué el sistema la aceptó, y por qué este bug es invisible salvo que conozcas el flujo.
29. Escribe una prueba de regresión (Jasmine) que verifique que `samplesReducer` deja el estado intacto ante `transitionSample` con una transición ilegal, y que lo cambia ante una legal. Es la prueba que la Fase 12 espera encontrar ya escrita.
30. **Diagnóstico.** Dos muestras de la misma orden, una en `received` y otra en `collected`. Transicionas la primera a `in_process` y observas que **ambas** parpadean/recargan. Explica por qué —relaciónalo con `reloadAfterTransition$` recargando la orden entera— y decide si es un bug o el comportamiento esperado de la deuda de recarga.

**🔥 Opcionales**

- 🔥 Reemplaza el mapa y el `switch` de guarda por una librería de máquinas de estado (XState u otra). Documenta qué de §5.7 desaparece y qué se rompe en las Fases 8 y 11 si esto se adopta.
- 🔥 Implementa el efecto cruzado que la Fase 8 va a necesitar: cuando la última muestra de una orden pasa a `processed`, despacha una acción que lleve la orden a `partial_results`. Anota por qué esto empieza a acoplar dos máquinas de estado y por qué conviene pensarlo antes de escribirlo.
- 🔥 Estampa el timestamp de custodia en el servidor en vez del cliente, moviendo la lógica al Express de la Fase 4. Documenta qué implica reabrir ese entregable y por qué la deuda de §5.5 existe justamente para no hacerlo.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v8.angular.io/api/router/ActivatedRoute — `paramMap` como observable, la diferencia con `snapshot`, y por qué un componente reusado necesita el observable. ⚠️ Enlace no verificado al cierre; si `v8.angular.io` no responde, la alternativa es `https://angular.io/api/router/ActivatedRoute` advirtiendo que cubre una versión posterior. Arrastra el pendiente abierto en la Fase 3.
- https://v8.angular.io/guide/router#activated-route — cómo la ruta anidada `/orders/:orderId/samples` entrega el parámetro, y el ciclo de reuso del componente.
- https://ngrx.io/guide/store/reducers — reducers y por qué la guarda de estado vive ahí. ⚠️ Cubre versiones posteriores; el `createReducer` de la página **no** es el del curso: NgRx 8 usa el `switch-case` de esta fase, no `createReducer` con `on()`. Leela sabiendo esa diferencia.
- https://github.com/typicode/json-server/tree/v0.16.3 — el filtro plano por campo (`?orderId=`) que reemplaza la ruta anidada inexistente, en la versión que fijó la Fase 4.

**Libros / artículos de referencia**

- David Khourshid, *Welcome to the World of Statecharts* — https://statecharts.dev — la teoría de máquinas de estado y statecharts, agnóstica de framework. Es la referencia de fondo para entender qué modela a mano el `switch` de §5.3 y qué haría una librería dedicada.
- Martin Fowler, sobre máquinas de estado en dominios con transiciones estrictas — el patrón **State** de *Patterns of Enterprise Application Architecture* es la formulación clásica de lo que acá se escribe con un mapa y un `switch`.

**Video / apoyo**

- Charlas introductorias a XState de la época (2019-2020) — https://www.youtube.com/results?search_query=xstate+state+machine+2019 — útiles para ver la alternativa que el equipo no adoptó. ⚠️ Verifica la fecha: XState cambió bastante de API entre versiones.

**Orden de lectura sugerido:** antes de escribir código, la sección de `ActivatedRoute` de v8, para tener clara la diferencia entre `paramMap` y `snapshot` —es la mitad de los bugs de la fase—. Durante, el mapa de §5.2 y el reducer de §5.3, que son el corazón. Después, y solo si te interesa el 🔥, la referencia de statecharts para ver qué estás escribiendo a mano.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido desde que se escribió esto. Los enlaces a `v8.angular.io` están marcados como **no verificados** y arrastran el pendiente de la Fase 3. Toda la documentación de NgRx en su sitio oficial cubre una versión posterior: el `createReducer` con `on()` que vas a ver ahí no existe en tu `package.json`, donde el reducer es un `switch`.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Quedó construida la primera máquina de estados del sistema: un mapa de transiciones, una guarda que vive en el reducer y hace imposible por construcción que el estado llegue a una transición ilegal, y una línea de custodia que reconstruye el rastro de una muestra a partir de sus propios campos. Quedaron declaradas dos deudas 💸 —el timestamp de custodia estampado en el cliente, y la regla de transición decidida en dos capas—, y quedó instalado el reflejo central de la fase: **en un sistema con máquina de estados, un bug no siempre grita en rojo; a veces es un dato que las reglas prohíben, y solo lo ves si conoces las reglas.**

La **Fase 8 — Resultados y rangos versionados** es el paso natural porque los resultados cuelgan de las muestras que acá cobraron reglas. Un resultado se valida sobre una muestra que tiene que estar en `in_process` o `processed`: sin la máquina de estados de esta fase, "validar un resultado sobre una muestra que nunca se recibió" sería un dato posible en vez de una transición prohibida. Además, la Fase 8 cruza las dos máquinas —la de la muestra y la de la orden—, y ese cruce necesita que al menos una de las dos ya esté escrita y funcionando. La relación anidada `muestra → orden` que acá se resolvió con `/orders/:orderId/samples` es la misma forma que van a tener los resultados sobre las muestras.

> **La señal de que quedó bien:** cuando alguien te muestre una muestra "imposible" y tu primer movimiento no sea abrir el código, sino mirar su línea de custodia buscando el hueco, y después el log de acciones buscando el intento sin éxito.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-07-muestras-custodia -m "F7 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f07: …`) y los de ejercicio su
> número (`f07 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f07/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

Cosas que aparecieron escribiendo esta fase y que no caben acá:

- 🪦 **[A] Resuelto.** Este pendiente denunciaba que el `seed.js` de la Fase 5 usaba valores de estado (`created`, `processing`, `reported`) fuera del flujo canónico, y que la Fase 8 iba a chocar de frente con eso al cruzar las dos máquinas. Se corrigió por edición retroactiva en dos sitios: el `seed.js` de la **Fase 5 §5.1**, que hoy sortea sobre `SEEDABLE_ORDER_STATUSES`, y el `db.json` de la **Fase 4 §5.1**, que es donde el dato nace y donde el desajuste había sobrevivido más tiempo.
- **[B]** 🪦 **Resuelto.** La grafía doble de `in_process` (dato) vs `inProcess` (clave i18n) obliga a normalizar o mapear en cada concatenación de clave. Quedó desarrollada en el **Apéndice A07 §4**, con el mapa explícito `estado → clave` como patrón recomendado y su fallback a `unknown`. La deuda sigue sin pagarse —LabCore mantiene los dos vocabularios—, pero ya tiene dueño y una forma de escribirla.
- **[C]** El efecto cruzado muestra→orden (la última muestra procesada empuja la orden) → es de la **Fase 8**; queda como 🔥 acá y como material central allá.
- **[D]** La concurrencia de dos analistas transicionando la misma muestra → sugerido para el **cuaderno de incidentes** como caso de concurrencia, hermano del incidente 10, sin fix en Track A.
- 🪦 **[E] Ya estaba pagado acá.** La comparación entre escribir la máquina de estados a mano y usar una librería dedicada vive en **§4** (por qué en 2019, con NgRx ya montado, meter XState era una conversación que nadie quería tener), y la dispersión del mapa, `CUSTODY_FIELD` y la validación del componente está declarada en **§5.7**. No necesita apéndice: la decisión de unificar las tres copias que el curso acumula es el ejercicio 26 de la **Fase 9**.

### Reservas para el cuaderno de incidentes

Esta fase toma los incidentes **11 y 21**, los dos nuevos.

Un apunte sobre el 21, porque nació de una corrección: durante un tiempo este
síntoma —la lista que no cambia al navegar de una orden a otra— viajó pegado al
incidente 10 de la Fase 5, con el argumento de que compartían la raíz, «estado que
no reacciona a lo que debería». No la comparten. El 10 es un `switchMap` que
cancela una escritura en vuelo; este es un `route.snapshot` leído una sola vez en
un componente que el router reusa. Lo que comparten es la **sensación** del
usuario, que es justamente lo que un ticket transmite y lo que un diagnóstico
tiene que separar. Meterlos en un mismo post-mortem de ocho puntos obligaría a
escribir dos causas raíz en la casilla de una.

- **11** · Fase 7 · *"La muestra figura procesada pero nunca se recibió"* · Categoría: máquina de estados · Dificultad 🟠
- **21** · Fase 7 · *"La lista no cambia al cambiar de orden"* · Categoría: estado (store) · Dificultad 🟠
