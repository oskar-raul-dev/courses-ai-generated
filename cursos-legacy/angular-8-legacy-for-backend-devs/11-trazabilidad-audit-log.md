# 📜 Fase 11 — Trazabilidad y audit log

> Tutorial Angular 8 — Laboratorio clínico · Fase 11 de 14 · **7 horas**
> Depende de: Fase 5 — Pacientes · Fase 6 — Órdenes · Fase 7 — Muestras y cadena de custodia · Fase 8 — Resultados y rangos versionados · Fase 9 — Entrega y PDF en cliente
> Habilita: Fase 12 — Testing desde cero + coverage
> Apéndices de apoyo: [A06 (NgRx 8)](./a06-ngrx.md) · [A05 (RxJS de supervivencia)](./a05-rxjs.md) · [Incidentes asociados](./cuaderno-incidentes.md): 17

---

## 🎯 1. Propósito

Hasta acá el sistema deja rastro, pero disperso. Sabes cuándo se recibió una muestra porque hay un `receivedAt` en su registro; sabes quién entregó una orden porque hay un `deliveredBy` estampado encima; sabes que un resultado se validó porque cambió su `status`. Cada evento vive pegado a la entidad que tocó, y ninguno sabe del otro. Cuando llega el ticket que dice *"reconstrúyeme todo lo que le pasó a la orden 4021 entre el martes y el jueves"*, no tienes dónde leerlo de corrido: tienes que ir campo por campo, entidad por entidad, armando la película a mano.

Esta fase convierte ese rastro disperso en un `auditLog`: una bitácora consultable, ordenada en el tiempo, donde cada mutación relevante del sistema deja un asiento con quién la hizo, qué tocó, cuándo, y cómo quedó la cosa antes y después. Deja de ser un puñado de timestamps sueltos y pasa a ser una línea de tiempo que puedes filtrar por entidad y recorrer.

Lo que te importa a ti, que vas a *mantener* esto y no a construirlo, es que **el audit log es la primera herramienta que abres cuando el ticket no tiene evidencia**. Un bug reproducible lo depuras con DevTools. Pero la mitad de los tickets de un sistema con trazabilidad no son reproducibles: "esto pasó el sábado, ya no pasa, pero pasó". Ahí no hay consola que mirar en vivo; hay que reconstruir desde el rastro que quedó. Aprender a leer ese rastro —y, más importante, a reconocer cuándo el rastro te miente— es el músculo de esta fase.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `npm run mock` levanta el servidor con una colección `/auditLog` vacía, y al validar un resultado, transicionar una muestra o entregar una orden aparece un asiento nuevo en `db.json` sin que nadie lo escriba a mano.
- [ ] En Redux DevTools ves entrar `[Audit] Log Entry` → `[Audit] Log Entry Success` **después** de cada `*Success` de las otras fases; puedes contar que hay un asiento por cada mutación registrable y ninguno por las que decidimos no registrar.
- [ ] Abres `/audit/orders/4021` y ves la línea de tiempo de esa orden ordenada por `timestamp`, con el identificador de quién hizo cada movimiento.
- [ ] Validas un resultado estando logueado como `analista1` y el asiento registra `analista1` como `actor` —el mismo identificador que las Fases 7, 8 y 9 estampan en los campos de custodia, así que los dos rastros cruzan—; disparas la misma mutación desde el inyector de caos de la Fase 4 y el asiento registra `system`. Esa diferencia es el corazón del incidente 17.
- [ ] Abres un asiento cualquiera y puedes leer su `before` y su `after`; confirmas mirando `db.json` que el `after` del asiento coincide con el estado real de la entidad… o que **no** coincide, si tocaste algo por fuera del store (ejercicio 22).

---

## 🚫 3. Qué NO entra todavía

- **Encriptación de los asientos y retención legal** (cuánto tiempo se guarda un audit log, quién puede borrarlo, cómo se firma para que no se altere) → fuera del alcance del curso. Se nombra en §4 como la razón por la que un audit log de verdad no vive en el frontend, y se cierra ahí.
- **La concurrencia real de dos analistas mutando la misma entidad al mismo tiempo.** Es exactamente lo que le daría sentido pleno a un audit log —el asiento que dice quién ganó la carrera—, pero pertenece a la línea que abrió el incidente 10 en la Fase 5 y que este curso no cierra porque no hay backend con versionado → se difiere; acá cada mutación es de a una.
- **El desacople del cruce `results → orders`** que la Fase 8 (§764 y pendiente [B]) dejó apuntado "para la Fase 11". El audit log **expone** ese acoplamiento —lo vas a ver cuando el mismo evento genere dos asientos de dos entidades distintas—, pero **no lo paga**: refactorizar el `withLatestFrom(this.store)` es trabajo de rediseño, no de hotfix. Se marca como deuda 💸 heredada y se sigue.
- **La vista de comparación visual `before`/`after`** (un diff lado a lado en pantalla) → queda como ejercicio 🔴 24. Acá el asiento guarda ambos estados; mostrarlos enfrentados es trabajo de UI que no cambia el modelo.

---

## 🧠 4. Concepto mínimo

### El problema antes que la herramienta

Piensa en el rastro que ya tienes. La Fase 7 le puso a cada muestra sus campos de custodia: `collectedAt`, `receivedAt`, quién la recibió. La Fase 8 le puso a cada resultado su `validatedAt` y su `rangeVersionApplied`. La Fase 9 le estampó a cada orden su `deliveredBy` y su `deliveredAt`. Todo eso es rastro, y todo eso está **adentro de la entidad**.

Funciona bien para una pregunta: "¿en qué estado está esta muestra ahora?". Y funciona pésimo para la otra: "¿qué le pasó a esta orden, en orden, con nombres y horas?". Porque para responder la segunda tienes que abrir la orden, después sus muestras, después los resultados de cada muestra, leer cinco timestamps repartidos en tres colecciones distintas, y ordenarlos en tu cabeza. Y aun así te falta lo peor: **quién** hizo cada cosa, que en la mayoría de los registros ni siquiera quedó guardado.

El problema de fondo es que el rastro **incrustado en la entidad solo guarda el estado final**. Si una muestra pasó por `received` y después por `discarded`, el registro solo te muestra `discarded`. El paso intermedio existió, se despachó una acción, cambió el estado, y no quedó nada. La entidad recuerda dónde está, no cómo llegó.

### La herramienta: la auditoría como dato de primera clase

Un audit log invierte la relación. En vez de que cada entidad recuerde su propio pasado a medias, hay una colección aparte —`auditLog`— donde cada mutación registrable deja un asiento independiente e inmutable. El asiento no vive dentro de la muestra: vive en su propia colección, apunta a la muestra por id, y nadie lo edita nunca. Se agrega, no se corrige. Si mañana quieres la historia de la muestra 88, filtras el `auditLog` por `entityId: 88` y la lees de corrido.

Eso es lo que significa "dato de primera clase": la auditoría deja de ser un efecto secundario de las otras entidades y pasa a ser una entidad con su propio slice en el store, sus propias acciones, su propio effect y su propia vista. El evento "se validó el resultado 12" ya no es solo un `status` que cambió; es, además, un hecho que se registra por sí mismo.

**Si vienes de backend**, un audit log es primo directo de una tabla de auditoría con triggers: cada `INSERT`/`UPDATE`/`DELETE` sobre las tablas de negocio dispara un asiento en una tabla `audit` aparte. La analogía abre bien la puerta y **se rompe en un punto que es toda la lección de esta fase**: en una base de datos el trigger corre *dentro de la misma transacción* que la mutación, del lado del servidor, y no hay forma de que la mutación ocurra sin su asiento. Acá, en Track A, **el asiento lo escribe el frontend desde un effect, después de que la mutación ya ocurrió, en una petición separada**. Esa diferencia no es cosmética: es la fuente de todos los bugs que vas a auditar.

### 💸 La deuda central de esta fase: el audit log lo escribe el front

Vamos a construir un `AuditEffect` que observa las acciones `*Success` de las otras fases —`transitionSampleSuccess`, `validateResultSuccess`, `markDeliveredSuccess`, y las de pacientes— y, por cada una, arma un asiento y hace `POST /auditLog`.

> 💸 **Deuda técnica intencional.**
> **Qué sería lo correcto hoy:** el asiento de auditoría lo emite el backend, en la misma transacción que la mutación, del lado del servidor donde el cliente no puede intervenir. Así el asiento y el cambio son atómicos: o pasan los dos o no pasa ninguno, y el `actor`, el `timestamp` y el `before`/`after` los determina el servidor, que es la única parte del sistema en la que se puede confiar.
> **Por qué en Track A no se paga:** el backend real no está bajo nuestro control en este curso, y montar la escritura del asiento del lado del servidor exige tocarlo. Un hotfix de mantenimiento no reescribe el modelo de persistencia. LabCore lo resolvió así en su momento —el front registra la auditoría— y con eso convive. Nuestro trabajo es entender las consecuencias, no arreglarlas.

Las consecuencias, para que las tengas presentes desde ya, son tres. **Primera:** si la mutación tiene éxito y el `POST /auditLog` falla, la cosa cambió y no quedó registrada — hay un hueco en la bitácora. **Segunda:** el `actor` sale del token del navegador, así que el audit log solo sabe quién *dice* el cliente que hizo la cosa. **Tercera:** el `timestamp` lo pone el reloj del cliente, con la deuda de zona horaria que arrastramos desde la Fase 8 — un asiento con la hora del navegador puede caer en otro día que el evento real. Las tres son material del incidente 17.

> 📝 **Nota de época.** Registrar auditoría desde el frontend fue —y sigue siendo— más común de lo que debería en sistemas que crecieron rápido: es el camino de menor resistencia cuando el backend es de otro equipo y tú solo controlas el cliente. En 2019, con el backend congelado y presión de entrega, "que el front escriba el log" era una decisión defendible. Hoy sabes que un audit log que el cliente puede evitar o falsear no es un audit log confiable, y ese conocimiento es justo lo que te vuelve útil manteniéndolo.

### Cómo se resolvía esto en la época

NgRx 8 no tiene `createActionGroup` ni `createFeature`; el slice de auditoría se arma a mano, con sus acciones sueltas, su reducer de `switch`-`case` y su registro por `StoreModule.forFeature('audit', ...)`, igual que todos los slices desde la Fase 1. El `AuditEffect` que escucha acciones de *otros* slices no es un truco raro: un effect puede hacer `ofType` de cualquier acción del sistema, vengan del feature que vengan. Esa es justamente la propiedad que lo hace el lugar natural para la auditoría transversal.

---

## 💻 5. Código mínimo con comentarios

El grueso de la fase. El orden va de adentro hacia afuera: primero el dato en el mock, después el modelo, después el circuito de store (acciones → servicio → reducer → **el effect**, que es el corazón → selectores), y al final la vista y el módulo que lo cablea todo.

### 5.1 La colección en el mock — `db.json`

```json
{
  "patients": [ "... sembrado desde la Fase 5 ..." ],
  "orders": [ "... sembrado desde la Fase 6 ..." ],
  "samples": [ "... sembrado desde la Fase 7 ..." ],
  "results": [ "... sembrado desde la Fase 8 ..." ],
  "referenceRanges": [ "... sembrado desde la Fase 8 ..." ],
  "auditLog": []
}
```

El `auditLog` arranca vacío: no se siembra. A diferencia de las otras colecciones, la de auditoría se llena sola a medida que usas el sistema. Sembrarla con datos falsos arruinaría el ejercicio: el punto es ver nacer los asientos.

### 5.2 El modelo del asiento — `audit.model.ts`

```typescript
// El asiento de auditoría. Es inmutable por contrato: una vez escrito,
// nadie lo edita. Se agrega, no se corrige — igual que el cuaderno de
// incidentes del curso.
export interface AuditEntry {
  id: string;
  // Momento del registro. OJO: lo pone el reloj del CLIENTE, no el servidor.
  // Arrastra la deuda de zona horaria de la Fase 8: si el navegador está en
  // otra TZ, el asiento puede caer en otro día que el evento real.
  timestamp: string;
  // Quien lo hizo, resuelto desde el token en el navegador. Es "quien dice
  // el cliente que fue", no una verdad del servidor. Ver incidente 17.
  actor: string;
  // El "type" de la acción NgRx que originó el asiento, tal cual.
  // Ej: "[Results] Validate Result Success". En inglés porque es el nombre
  // real de la acción, no texto de interfaz.
  action: string;
  // A que tipo de entidad apunta: 'patient' | 'order' | 'sample' | 'result'.
  entityType: string;
  entityId: string;
  // Estado antes y después de la mutación. any tolerado a propósito: cada
  // entidad tiene su forma y el audit log es deliberadamente agnostico a
  // ella. 💸 Guardar el objeto entero (y no un diff) es cómodo y gordo;
  // lo correcto sería un diff, pero en Track A no se paga: para mantener
  // este sistema, el objeto entero es más fácil de leer en un ticket.
  before: any;
  after: any;
}
```

**Detalles con intención.**
- `action` guarda el `type` de la acción, no una etiqueta traducida. El audit log es evidencia técnica: quieres el nombre exacto que buscarías en el código, no un texto amigable.
- `before`/`after` son `any` a propósito y comentado. No es descuido: el audit log tiene que registrar entidades de forma distinta (paciente, muestra, resultado) sin acoplarse a ninguna. El precio es que pierdes el chequeo de tipos justo donde más datos hay.

### 5.3 Las acciones — `audit.actions.ts`

```typescript
import { createAction, props } from '@ngrx/store';
import { AuditEntry } from './audit.model';

// Se despacha desde el AuditEffect cuando detecta una mutación registrable.
// Lleva el asiento ya armado.
export const logAuditEntry = createAction(
  '[Audit] Log Entry',
  props<{ entry: AuditEntry }>()
);

export const logAuditEntrySuccess = createAction(
  '[Audit] Log Entry Success',
  props<{ entry: AuditEntry }>()
);

// 💸 Si esto falla, la mutación ya ocurrió y quedó SIN registrar. El hueco
// en la bitácora nace acá. Lo correcto sería una escritura atómica en el
// backend; en Track A no se paga.
export const logAuditEntryFailure = createAction(
  '[Audit] Log Entry Failure',
  props<{ error: any }>()
);

// Para la vista: cargar la bitácora completa o filtrada por entidad.
export const loadAuditLog = createAction(
  '[Audit] Load Audit Log'
);

export const loadAuditLogSuccess = createAction(
  '[Audit] Load Audit Log Success',
  props<{ entries: AuditEntry[] }>()
);

export const loadAuditLogFailure = createAction(
  '[Audit] Load Audit Log Failure',
  props<{ error: any }>()
);
```

Sin `createActionGroup`: no existe en NgRx 8. Acciones sueltas, como en todas las fases.

### 5.4 El servicio — `audit.service.ts`

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { environment } from '../../../environments/environment';
import { AuditEntry } from './audit.model';

@Injectable({ providedIn: 'root' })
export class AuditService {

  constructor(private http: HttpClient) { }

  // Escribe un asiento. json-server responde el objeto creado tal cual.
  postEntry(entry: AuditEntry): Observable<AuditEntry> {
    return this.http.post<AuditEntry>(environment.apiUrl + '/auditLog', entry);
  }

  // Trae la bitácora entera. El filtrado por entidad lo hace el selector en
  // el cliente: 💸 traer todo y filtrar en memoria no escala, pero para el
  // volumen del curso alcanza y evita depender de los query params de
  // json-server. En Track A no se paga; en producción lo filtraría el server.
  getLog(): Observable<AuditEntry[]> {
    return this.http.get<AuditEntry[]>(environment.apiUrl + '/auditLog');
  }
}
```

### 5.5 El reducer — `audit.reducer.ts`

```typescript
import { Action } from '@ngrx/store';

import { AuditEntry } from './audit.model';
import * as AuditActions from './audit.actions';

export interface AuditState {
  entries: AuditEntry[];
  loading: boolean;
  error: any;
}

export const initialState: AuditState = {
  entries: [],
  loading: false,
  error: null
};

// switch-case a mano, como en toda fase. Sin createReducer con on().
export function auditReducer(state: AuditState = initialState, action: Action): AuditState {
  switch (action.type) {

    case AuditActions.loadAuditLog.type:
      return { ...state, loading: true, error: null };

    case AuditActions.loadAuditLogSuccess.type: {
      const a = action as ReturnType<typeof AuditActions.loadAuditLogSuccess>;
      return { ...state, loading: false, entries: a.entries };
    }

    case AuditActions.loadAuditLogFailure.type: {
      const a = action as ReturnType<typeof AuditActions.loadAuditLogFailure>;
      return { ...state, loading: false, error: a.error };
    }

    // Cuando un asiento se escribe bien, lo agregamos al estado local para
    // que la timeline lo vea sin recargar toda la bitácora del servidor.
    case AuditActions.logAuditEntrySuccess.type: {
      const a = action as ReturnType<typeof AuditActions.logAuditEntrySuccess>;
      // Se AGREGA. El audit log nunca reemplaza ni edita asientos previos.
      return { ...state, entries: [...state.entries, a.entry] };
    }

    default:
      return state;
  }
}
```

### 5.6 El effect — `audit.effects.ts` ⭐

Este es el corazón de la fase. Todo lo demás es andamiaje alrededor de este archivo.

```typescript
import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { map, mergeMap, catchError } from 'rxjs/operators';

import { environment } from '../../../environments/environment';
import { AuditService } from './audit.service';
import { AuthService } from '../../core/auth/auth.service';
import { AuditEntry } from './audit.model';
import * as AuditActions from './audit.actions';

// Importamos las acciones de las OTRAS fases: el AuditEffect escucha lo que
// pasa en el resto del sistema. Un effect puede ofType cualquier acción,
// venga del feature que venga — esa es la propiedad que lo hace el lugar
// natural para la auditoría transversal.
import * as SamplesActions from '../../samples/store/samples.actions';
import * as ResultsActions from '../../results/store/results.actions';
import * as OrdersActions from '../../orders/store/orders.actions';

@Injectable()
export class AuditEffects {

  constructor(
    private actions$: Actions,
    private auditService: AuditService,
    private authService: AuthService
  ) { }

  // ⭐ El effect central: escucha las mutaciones exitosas del sistema y por
  // cada una escribe un asiento. Acá vive la deuda 💸 de la fase: el asiento
  // lo arma y lo escribe el FRONT, después de que la mutación ya pasó.
  writeAudit$ = createEffect(function (this: AuditEffects) {
    return this.actions$.pipe(
      // Se registran las mutaciones que importan para reconstruir un
      // incidente. Las lecturas (loadX) NO se registran: un audit log de
      // quien leyó que es otro problema (y otra escala) — fuera de alcance.
      ofType(
        SamplesActions.transitionSampleSuccess,
        ResultsActions.enterResultSuccess,
        ResultsActions.validateResultSuccess,
        OrdersActions.transitionOrderSuccess,
        OrdersActions.markDeliveredSuccess
      ),
      map(function (this: AuditEffects, action: any) {
        // buildEntry traduce cada tipo de acción a un asiento. Ver 5.6.1.
        const entry = this.buildEntry(action);
        return AuditActions.logAuditEntry({ entry: entry });
      }.bind(this))
    );
  }.bind(this));

  // Segundo effect: toma el logAuditEntry y hace el POST. Se separa del
  // primero a propósito, para que el asiento pase por el store (y se vea en
  // DevTools) antes de viajar al servidor.
  persistAudit$ = createEffect(function (this: AuditEffects) {
    return this.actions$.pipe(
      ofType(AuditActions.logAuditEntry),
      mergeMap(function (this: AuditEffects, action) {
        return this.auditService.postEntry(action.entry).pipe(
          map(function (saved: AuditEntry) {
            return AuditActions.logAuditEntrySuccess({ entry: saved });
          }),
          catchError(function (error) {
            // 💸 Si esto falla, la mutación ya ocurrió y no quedó registrada.
            // No reintentamos ni revertimos: el hueco queda. Lo correcto
            // sería escritura atómica en el backend; en Track A no se paga.
            return of(AuditActions.logAuditEntryFailure({ error: error }));
          })
        );
      }.bind(this))
    );
  }.bind(this));

  loadAuditLog$ = createEffect(function (this: AuditEffects) {
    return this.actions$.pipe(
      ofType(AuditActions.loadAuditLog),
      mergeMap(function (this: AuditEffects) {
        return this.auditService.getLog().pipe(
          map(function (entries: AuditEntry[]) {
            return AuditActions.loadAuditLogSuccess({ entries: entries });
          }),
          catchError(function (error) {
            return of(AuditActions.loadAuditLogFailure({ error: error }));
          })
        );
      }.bind(this))
    );
  }.bind(this));

  // Traduce una acción de otro slice a un asiento de auditoría. Es el punto
  // más frágil de la fase: cada acción tiene su propia forma de payload, y
  // este método tiene que conocerlas todas. Cuando una fase futura agregue
  // una acción registrable, este switch hay que tocarlo — y si no se toca,
  // la mutación pasa sin dejar rastro (bug silencioso, ejercicio 20).
  buildEntry(action: any): AuditEntry {
    // 💸 El actor sale del token en el NAVEGADOR. Es "quien dice el cliente
    // que fue". getCurrentUser() viene de la Fase 3 y devuelve el "sub" del
    // JWT -el username- o null si no hay sesión.
    //
    // Se guarda el sub y NO el fullName, por la misma razón que lo guardan los
    // campos de custodia de las Fases 7, 8 y 9: es la referencia estable, y es
    // lo que hace que los dos rastros se puedan cruzar. Un asiento que dijera
    // "Marcela Ríos" y un collectedBy que dijera "analista1" describen a la
    // misma persona y no hay forma automática de saberlo.
    const user = this.authService.getCurrentUser();
    // Si no hay usuario logueado, la mutación la disparó algo que no es una
    // persona: el inyector de caos de la Fase 4, o el analizador externo
    // simulado. Se marca 'system'. Esa palabra en la timeline es el nucleo
    // del incidente 17: "el log dice que yo lo hice y yo no estaba".
    const actor = user ? user : 'system';

    // 💸 timestamp del reloj del cliente. Arrastra la deuda de zona horaria
    // de la Fase 8: en otra TZ, el asiento puede caer en otro día. Lo
    // correcto: que el servidor selle el tiempo. En Track A no se paga.
    const timestamp = new Date().toISOString();

    const base = {
      id: this.generateId(),
      timestamp: timestamp,
      actor: actor,
      action: action.type
    };

    // any tolerado: cada rama conoce la forma del payload de su acción.
    switch (action.type) {

      case SamplesActions.transitionSampleSuccess.type:
        return {
          ...base,
          entityType: 'sample',
          entityId: String(action.sample.id),
          // No tenemos el estado ANTES en el payload del Success: la acción
          // solo trae el resultado. 💸 Registramos before: null. Reconstruir
          // el "antes" real exigiría capturarlo en la acción original, cosa
          // que ninguna fase previa hizo. En Track A no se paga; es material
          // del ejercicio 23.
          before: null,
          after: action.sample
        };

      case ResultsActions.enterResultSuccess.type:
      case ResultsActions.validateResultSuccess.type:
        return {
          ...base,
          entityType: 'result',
          entityId: String(action.result.id),
          before: null,
          after: action.result
        };

      // Las dos mutaciones de orden comparten forma: las dos traen la orden
      // entera en action.order. Se separan igual porque el "action" del asiento
      // guarda el type, y distinguir "la orden avanzo sola" de "alguien la
      // entrego" es justo lo que §5.11 necesita para explicarse.
      case OrdersActions.transitionOrderSuccess.type:
      case OrdersActions.markDeliveredSuccess.type:
        return {
          ...base,
          entityType: 'order',
          entityId: String(action.order.id),
          before: null,
          after: action.order
        };

      default:
        // No debería llegar acá: el ofType ya filtro. Pero si una acción
        // nueva llega sin case, dejamos un asiento genérico en vez de
        // tirar. Un audit log que se cae por una acción que no conoce es
        // peor que uno que registra de más.
        return {
          ...base,
          entityType: 'unknown',
          entityId: 'unknown',
          before: null,
          after: action
        };
    }
  }

  // Id de asiento. 💸 Math.random no garantiza unicidad; para el volumen del
  // curso alcanza. En producción sería un uuid del servidor. No se paga.
  generateId(): string {
    return 'audit_' + Date.now() + '_' + Math.floor(Math.random() * 100000);
  }
}
```

**El patrón a memorizar.** Un effect que hace `ofType` de acciones de *otros* features es el lugar natural para cualquier lógica transversal: auditoría, métricas, telemetría. No necesita pertenecer al slice que observa; solo necesita escuchar sus acciones.

**Detalles con intención.**
- **`writeAudit$` y `persistAudit$` están separados a propósito.** El primero traduce la mutación a un `logAuditEntry` y lo mete al store; el segundo lo persiste. Así el asiento aparece en DevTools *antes* de viajar, y si el `POST` falla lo ves fallar contra un asiento que ya existía en el store. Fusionarlos escondería ese paso.
- **`buildEntry` es el punto frágil declarado.** Conoce la forma del payload de cada acción. Cuando una fase futura agregue una mutación registrable, hay que venir acá a agregar su `case`. Si no se hace, la mutación pasa sin rastro y nadie se entera hasta que un auditor pregunta. Eso es el ejercicio 20.
- **`before: null` en todos los asientos.** El payload de las acciones `*Success` de las fases previas solo trae el resultado, no el estado anterior. Registrar el "antes" real exigiría haberlo capturado en la acción original, y ninguna fase lo hizo. Es deuda 💸 heredada, no un olvido de esta fase.

### 5.7 Los selectores — `audit.selectors.ts`

```typescript
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { AuditState } from './audit.reducer';
import { AuditEntry } from './audit.model';

export const selectAuditState = createFeatureSelector<AuditState>('audit');

export const selectAllAuditEntries = createSelector(
  selectAuditState,
  function (state: AuditState) {
    // Ordenados por timestamp ascendente: la timeline se lee de arriba
    // hacia abajo como pasó el tiempo. slice() para no mutar el array del
    // store al ordenar (sort muta in-place).
    return state.entries.slice().sort(function (a: AuditEntry, b: AuditEntry) {
      return a.timestamp.localeCompare(b.timestamp);
    });
  }
);

// Selector con factory: filtra la bitácora por una entidad concreta.
// 💸 El filtrado es en cliente sobre toda la bitácora traida en memoria.
// No escala; para el curso alcanza. En Track A no se paga.
export const selectAuditLogForEntity = function (entityType: string, entityId: string) {
  return createSelector(
    selectAllAuditEntries,
    function (entries: AuditEntry[]) {
      return entries.filter(function (e: AuditEntry) {
        return e.entityType === entityType && e.entityId === entityId;
      });
    }
  );
};
```

### 5.8 La vista — `audit-timeline.component.ts`

Componente gordo, con la lógica de lectura adentro y `.subscribe()` a pelo, como todo el sistema. Reutiliza el patrón de tabla de la Fase 5 (no lo reimplementamos: mismo `MatTable`, misma forma).

```typescript
import { Component, OnInit } from '@angular/core';
import { Store } from '@ngrx/store';
import { ActivatedRoute } from '@angular/router';

import * as AuditActions from '../store/audit.actions';
import { selectAuditLogForEntity, selectAllAuditEntries } from '../store/audit.selectors';
import { AuditEntry } from '../store/audit.model';

@Component({
  selector: 'app-audit-timeline',
  templateUrl: './audit-timeline.component.html'
})
export class AuditTimelineComponent implements OnInit {

  entries: AuditEntry[] = [];
  // Columnas de la tabla Material, reusando el patrón de la Fase 5.
  displayedColumns: string[] = ['timestamp', 'actor', 'action', 'entityId'];

  // any tolerado: leer el store entero por comodidad, como en la Fase 8.
  constructor(private store: Store<any>, private route: ActivatedRoute) { }

  ngOnInit(): void {
    // Primero, aseguramos que la bitácora este cargada.
    this.store.dispatch(AuditActions.loadAuditLog());

    // La ruta puede venir con entityType/entityId (timeline de una entidad)
    // o sin ellos (bitácora global). Se resuelve leyendo los params.
    const entityType = this.route.snapshot.paramMap.get('entityType');
    const entityId = this.route.snapshot.paramMap.get('entityId');

    const selector = (entityType && entityId)
      ? selectAuditLogForEntity(entityType, entityId)
      : selectAllAuditEntries;

    // .subscribe() a pelo, sin ngOnDestroy. 💸 Es el mismo leak que la Fase 10
    // convirtió en el incidente 16; acá se muestra el patrón real, no el
    // correcto. El fix con takeUntil vive en la Fase 10. En Track A no se paga.
    this.store.select(selector).subscribe(function (this: AuditTimelineComponent, entries: AuditEntry[]) {
      this.entries = entries;
    }.bind(this));
  }
}
```

```html
<!-- audit-timeline.component.html -->
<!-- Texto de interfaz por clave i18n, nunca literal. -->
<h2>{{ 'audit.timeline.title' | translate }}</h2>

<table mat-table [dataSource]="entries" class="audit-table">

  <ng-container matColumnDef="timestamp">
    <th mat-header-cell *matHeaderCellDef>{{ 'audit.column.timestamp' | translate }}</th>
    <td mat-cell *matCellDef="let entry">{{ entry.timestamp }}</td>
  </ng-container>

  <ng-container matColumnDef="actor">
    <th mat-header-cell *matHeaderCellDef>{{ 'audit.column.actor' | translate }}</th>
    <!-- El identificador crudo, no el nombre. Resolverlo a "Marcela Rios" seria
         mas amable de leer y exigiria una tabla de usuarios que este sistema no
         tiene; ademas, un rastro de auditoria que muestra el nombre de HOY sobre
         un evento de hace dos años miente sin darse cuenta. Cuando actor es
         'system', esta celda es la que delata el incidente 17. -->
    <td mat-cell *matCellDef="let entry">{{ entry.actor }}</td>
  </ng-container>

  <ng-container matColumnDef="action">
    <th mat-header-cell *matHeaderCellDef>{{ 'audit.column.action' | translate }}</th>
    <!-- action es el type crudo de la acción: evidencia técnica, no se traduce. -->
    <td mat-cell *matCellDef="let entry">{{ entry.action }}</td>
  </ng-container>

  <ng-container matColumnDef="entityId">
    <th mat-header-cell *matHeaderCellDef>{{ 'audit.column.entityId' | translate }}</th>
    <td mat-cell *matCellDef="let entry">{{ entry.entityType }} #{{ entry.entityId }}</td>
  </ng-container>

  <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
  <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
</table>
```

### 5.9 El módulo — `audit.module.ts`

```typescript
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { StoreModule } from '@ngrx/store';
import { EffectsModule } from '@ngrx/effects';
import { MatTableModule } from '@angular/material/table';
import { TranslateModule } from '@ngx-translate/core';

import { AuditTimelineComponent } from './audit-timeline/audit-timeline.component';
import { auditReducer } from './store/audit.reducer';
import { AuditEffects } from './store/audit.effects';

@NgModule({
  declarations: [AuditTimelineComponent],
  imports: [
    CommonModule,
    MatTableModule,
    TranslateModule,
    RouterModule.forChild([
      // Bitácora global.
      { path: '', component: AuditTimelineComponent },
      // Timeline de una entidad: /audit/orders/4021 y similares.
      { path: ':entityType/:entityId', component: AuditTimelineComponent }
    ]),
    // Slice nuevo con feature key 'audit', como todos los slices desde la Fase 1.
    StoreModule.forFeature('audit', auditReducer),
    EffectsModule.forFeature([AuditEffects])
  ]
})
export class AuditModule { }
```

### 5.10 Capturar el antes: por qué el payload de un `Success` no alcanza

Todos los asientos que escribe §5.6 llevan `before: null`, y §5.6 lo declara como deuda heredada. Esta sección explica **por qué** no se puede arreglar donde uno esperaría, porque el primer intento que hace todo el mundo no funciona, y no funciona por una razón del motor de NgRx que conviene saberse.

El intento evidente es leer el store desde el propio `AuditEffect`: si el effect ya tiene el `withLatestFrom(this.store)`, que lea el estado y ahí está el "antes". No lo está:

```typescript
// NO FUNCIONA, y falla en silencio: el estado que llega aquí ya es el DESPUÉS.
this.actions$.pipe(
  ofType(ResultsActions.validateResultSuccess),
  withLatestFrom(this.store),
  map(function (pair: any) {
    var state = pair[1];
    // Esperabas el resultado sin validar. Recibes el resultado ya validado.
    ...
  })
)
```

> 🧠 **En NgRx, el reducer corre antes que el effect.** Cuando una acción se despacha, el store actualiza el estado primero y solo después los effects ven pasar esa acción. Así que para cuando el `AuditEffect` observa `validateResultSuccess`, el reducer de resultados ya escribió el `status: 'validated'`. El estado que lee el effect es el posterior, siempre, y no hay orden de operadores que lo cambie.

Eso deja tres caminos, y ninguno es una línea:

| Opción | Cómo | Qué cuesta |
|---|---|---|
| **A. El `before` viaja en la acción original** | Quien despacha `validateResult` lee el estado actual y lo mete en el payload; el `Success` lo arrastra hasta el asiento | Tocar las acciones, los effects y los reducers de las **Fases 7, 8 y 9**. Y el "antes" lo determina el cliente, que es la parte del sistema en la que menos se puede confiar |
| **B. Auditar la acción de intención, no la de éxito** | El `AuditEffect` escucha `validateResult` (no `...Success`), y ahí sí el store todavía tiene el antes | Hay que correlacionar dos acciones para un solo asiento. Y si la escritura falla, queda un "antes" sin "después": un asiento de algo que no pasó |
| **C. El asiento lo emite el backend** | En la misma transacción que la mutación, del lado donde el `before` es un hecho y no una lectura | Es el "qué sería lo correcto hoy" de §4, y es un proyecto de servidor, no de front |

**Por qué el proyecto se queda en `before: null`:** la opción A es la que pide el ejercicio 17, y hacerla bien significa un refactor transversal de tres fases para obtener un dato que, al venir del cliente, un auditor serio no aceptaría igualmente. La B introduce una correlación frágil justo en el componente cuyo trabajo es ser confiable. Y la C es la buena, y no está en tu tejado. **Registrar `null` y que se note es más honesto que registrar un "antes" que el navegador se inventó.**

⚠️ Y el corolario incómodo, que es la lección de la fase: un audit log sin `before` responde *qué quedó*, no *qué cambió*. Sirve para reconstruir el estado final; no sirve para demostrar que alguien modificó algo que antes decía otra cosa. Si alguien te pide lo segundo apoyándose en esta bitácora, la respuesta correcta es que esta bitácora no lo prueba.

---

### 5.11 El cruce `results → orders`: un gesto, dos asientos

La **Fase 8** dejó anotado un acoplamiento y esta fase es donde se vuelve visible. Al validar el último resultado pendiente de una muestra, un effect empuja la orden hacia adelante: `pushOrderAfterValidate$`. Un solo clic del usuario, dos entidades mutadas.

En el audit log eso se ve así, y la primera vez desconcierta:

```
14:32:07  analista1   [Results] Validate Result Success   result 8871
14:32:07  analista1   [Orders] Transition Order Success    order 4021
```

> ⚠️ Ese segundo asiento **solo aparece si completaste el ejercicio 25 de la Fase
> 7**, que es el que escribe el conteo. Con el esqueleto tal como lo deja la fase,
> `pushOrderAfterValidate$` no despacha nada y la orden no se mueve. Lo que sigue
> describe el sistema con el cruce terminado, que es como está en LabCore.

Dos asientos, mismo actor, mismo segundo, y **el segundo no tiene ninguna causa visible en la interfaz**: nadie tocó la orden 4021. Quien audite dentro de seis meses va a preguntar quién movió esa orden, y la respuesta —"la movió el sistema porque `analista1` validó un resultado de una muestra que pertenecía a esa orden"— no está escrita en ninguna parte del asiento.

**Por qué el acoplamiento duele, en términos de store.** El effect vive en el slice de resultados, pero lee el de muestras (para saber si era el último pendiente) y escribe en el de órdenes. Eso significa que la forma de tres slices está atada a un archivo que solo uno de ellos considera suyo: cambiar `OrdersState` puede romper un effect de `results`, y el compilador no va a avisar porque el store es `Store<any>` (**Apéndice A06 §9.3**). Y si alguien entra por enlace directo a la pantalla de resultados sin pasar por órdenes, el slice `orders` no está registrado y el `withLatestFrom` **no emite nunca**: el empuje no ocurre y no hay ningún error (**A06 §6**).

Las tres salidas, con su precio:

- **Dejarlo (Track A).** Es lo que hace LabCore. El cruce funciona, y el coste se paga en legibilidad y en auditorías confusas.
- **Mover el cruce al servidor.** El endpoint que valida un resultado decide si la orden avanza, en la misma transacción. Desaparece el effect, desaparece el acoplamiento y desaparecen los dos asientos descoordinados: el backend emite uno solo, coherente. Es la misma respuesta que la §5.10 y la misma que el §4 de esta fase.
- **Un `correlationId`.** No desacopla nada, pero hace legible lo que ya pasa: la acción original genera un identificador y ambos asientos lo llevan, de modo que la bitácora puede decir "estos dos cambios son el mismo gesto". Es barato, cabe en el modelo de §5.2, y es el ejercicio 26.

> 🧭 **La distinción que hay que tener clara antes de discutir esto con alguien:** el cruce no es un bug. Es una regla de negocio real, implementada en el lugar equivocado. Moverla al servidor es un rediseño que este curso declara no abordar; hacerla **auditable** donde está sí cabe en un sprint, y es la diferencia entre una bitácora que confunde y una que explica.

---

**Prueba de fuego.** Levanta el mock, loguéate como `analista1`, valida un resultado y abre `db.json`: tiene que haber un asiento nuevo en `auditLog` con `actor: "analista1"` — y el mismo `analista1` en el `validatedBy` del resultado, que es lo que hace cruzables los dos rastros. Ahora abre `/audit/results/<ese id>` y confírmalo en la timeline. Después, con `CHAOS` apagado en la petición de auditoría pero disparando la validación desde el inyector de caos (sin sesión de usuario), repite: el asiento nuevo dice `actor: "system"`. Esa palabra es la fase entera.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** validas un resultado y no aparece ningún asiento; en DevTools ves el `Validate Result Success` pero ningún `[Audit] Log Entry` detrás.
**Causa:** el `AuditModule` no está importado en el arranque de la aplicación, o su `EffectsModule.forFeature([AuditEffects])` no llegó a registrarse porque el módulo es lazy y nunca se cargó. Un effect que no está registrado no escucha nada, aunque el archivo compile perfecto.
**Fix mínimo:** el `AuditModule` no puede ser lazy si tiene que auditar desde el arranque. Regístralo en el módulo raíz (o en el `CoreModule`) para que su effect esté vivo apenas arranca la app. **Fix correcto:** separar el effect de auditoría de su vista — el effect en el core, siempre vivo; la vista en un módulo lazy que se carga cuando abres la timeline.

**Síntoma:** el asiento aparece, pero `actor` dice `undefined` en vez de un identificador o de `system`.
**Causa:** alguien reemplazó `getCurrentUser()` por `getDecodedUser()` y accedió a una propiedad del payload sin chequear que el objeto no fuera `null`. El nulo se cuela un nivel más abajo del que se está mirando y el ternario, en vez de caer en `'system'`, devuelve `undefined`.
**Fix mínimo:** confirma que la rama chequee **el objeto**, no una propiedad suya. Y para registrar, `getCurrentUser()`: `getDecodedUser()` es para mostrar (Fase 3 §5.4).

**Síntoma:** el `POST /auditLog` responde 201, el asiento existe en `db.json`, pero la timeline no lo muestra hasta que recargas la página.
**Causa:** el reducer no agregó el asiento al estado local en `logAuditEntrySuccess`, o la vista se suscribió a `selectAllAuditEntries` pero el asiento nuevo no cumple el filtro de `selectAuditLogForEntity` porque el `entityId` se guardó como número y se filtra como string (o al revés).
**Fix mínimo:** revisa que `String(action.sample.id)` y el `entityId` de la ruta se comparen como el mismo tipo. Es la clase de bug que un `===` sobre `any` esconde perfecto.

**Síntoma:** cada mutación genera **dos** asientos.
**Causa:** el `AuditModule` se importó dos veces (una en el core y otra en un módulo lazy), así que su effect está registrado dos veces y cada acción lo dispara doble.
**Fix mínimo:** un solo registro del `EffectsModule.forFeature([AuditEffects])` en toda la aplicación. Es el mismo problema clásico de módulos compartidos importados de más.

### Pieza forense de esta fase

La pieza forense de esta fase es **reconstruir un incidente leyendo el action log**, y se desarrolla entera en [`forense-fase-11.md`](./forense-fase-11.md). El esqueleto: te dan una queja sin evidencia en vivo ("el sábado la orden 4021 salió entregada sin que se validara el último resultado"), y tienes que abrir el `auditLog`, filtrar por esa orden, ordenar por `timestamp`, y encontrar el asiento que no debería existir o el que debería existir y falta. La bitacora es la caja negra; aprender a leerla es lo que la fase entrena.

**Rompe a propósito y observa.** En `buildEntry`, cambia el `after: action.result` por `after: action` (el objeto entero de la acción, no su payload). Valida un resultado y abre el asiento en `db.json`. Vas a ver que el `after` ya no es el resultado sino la acción con su `type` adentro. Ahora abre la timeline: se ve **casi igual**, porque la tabla solo muestra `timestamp`, `actor`, `action` y `entityId`, y ninguno de esos cambió. La mentira que te cuenta la pantalla es que todo está bien; el asiento corrupto solo se ve si abres el `before`/`after`, que la timeline no muestra. Ese es el punto: **un audit log puede estar podrido por dentro y verse impecable por fuera**. Si confías en la vista en vez de en el dato, no lo detectas nunca.

---

## 🧪 7. Ejercicios (27)

**🟢 Fácil (1–7)**

1. Levanta el mock, loguéate como `supervisor1`, transiciona una muestra a `received` y confirma en `db.json` dos cosas: que el asiento registra `supervisor1` como `actor`, y que el `receivedBy` de la muestra dice exactamente lo mismo. Después busca en `mock-server/auth.js` a quién corresponde ese identificador y explica en una línea por qué el asiento no guarda ese nombre.
2. Abre `/audit` (sin entidad) y confirma que la bitacora global muestra todos los asientos ordenados por `timestamp` ascendente. Cambia el `localeCompare` por su inverso y observa cómo se invierte la timeline.
3. Agrega la clave `audit.column.actor` a los tres árboles de traducción (es, en, fr) y confirma que la cabecera cambia al cambiar de idioma.
4. Cuenta, en DevTools, cuántas acciones median entre `Validate Result Success` y `[Audit] Log Entry Success`. Explica por qué `writeAudit$` y `persistAudit$` producen dos acciones separadas y no una.
5. Cambia `entityType: 'sample'` por `entityType: 'muestra'` en un `case` de `buildEntry`. Explica por qué eso rompe el filtro de `selectAuditLogForEntity` para las rutas que usan `sample`, y por qué el idioma del código no es negociable ni acá.
6. Agrega una columna `entityType` visible a la tabla de la timeline reutilizando el patrón de columnas de `MatTable` de la Fase 5.
7. Loguéate, valida un resultado, haz logout, y valida otro resultado desde el inyector de caos. Abre la timeline y ubica el asiento con `actor: 'system'`. Descríbelo con tus palabras.

**🟡 Intermedio (8–15)**

8. La acción `enterResultSuccess` y `validateResultSuccess` caen en el mismo `case` de `buildEntry`. Sepáralas para que el asiento distinga "resultado ingresado" de "resultado validado", y explica por qué eso importa al reconstruir un incidente.
9. Escribe un selector `selectAuditLogByActor(actor: string)` con factory, siguiendo el patrón de `selectAuditLogForEntity`. Úsalo para responder "¿qué hizo `Marcela Ríos` hoy?".
10. Agrega el registro de las mutaciones de pacientes: importa las acciones `*Success` de la Fase 5 en el `AuditEffect`, agrégalas al `ofType`, y agrega sus `case` en `buildEntry`. Confirma que dar de baja un paciente deja asiento.
11. La `loadAuditLog$` se dispara en cada `ngOnInit` de la timeline. Mide en Network cuántas veces se pide `/auditLog` si navegas tres veces a la timeline. Propón (sin implementar) cómo evitar recargarla si ya está en el store.
12. **Diagnóstico.** Te dan un `db.json` donde una orden tiene `deliveredAt` pero no hay ningún asiento de `markDeliveredSuccess` en el `auditLog`. Reproduce la situación y explica las dos causas posibles: el asiento falló al escribirse, o la entrega ocurrió por fuera del store.
13. **Diagnóstico.** La timeline de la orden 4021 muestra un asiento de `Validate Result Success` con `timestamp` del sábado, pero el resultado tiene `validatedAt` del viernes. Explica cómo la deuda de zona horaria de la Fase 8 puede producir esa discrepancia de un día.
14. Cambia el `mergeMap` de `persistAudit$` por `switchMap`. Dispara dos mutaciones muy seguidas y observa en `db.json` qué pasa. Explica por qué `switchMap` es la elección equivocada para escribir asientos.
15. Agrega un asiento manualmente a `db.json` con un `entityId` que no existe en ninguna colección. Abre su timeline y explica por qué el sistema no se cae, y qué implica que el audit log pueda apuntar a entidades fantasma.

**🟠 Difícil (16–21)**

16. **Diagnóstico.** Cada mutación genera dos asientos idénticos salvo el `id`. Reproduce el bug importando `AuditModule` dos veces y localiza la causa con DevTools observando cuántas veces se dispara el effect por acción.
17. El `before` de todos los asientos es `null`. Modifica la acción `transitionSample` de la Fase 7 para que su payload lleve el estado anterior de la muestra, y propaga ese `before` hasta el asiento. Documenta qué fases hay que tocar y por qué esto es refactor y no hotfix.
18. **Diagnóstico.** Un asiento de auditoría tiene `actor: 'Marcela Ríos'`, pero `Marcela` jura que ese día estaba de vacaciones. Sin acusar a nadie, enumera las tres formas en que el audit log de esta fase puede registrar un `actor` que no corresponde a quien realmente hizo la mutación.
19. `generateId()` usa `Date.now()` + `Math.random()`. Construye el escenario (aunque sea forzándolo) en el que dos asientos reciben el mismo `id`, y explica qué se rompe en la timeline cuando eso pasa.
20. **Diagnóstico.** Se agregó una nueva mutación registrable en una fase posterior (un `cancelOrderSuccess` imaginario), pero no aparece en el audit log aunque la acción se despacha. Localiza el punto exacto de `AuditEffects` donde hay que registrarla y explica por qué el bug es silencioso.
21. Escribe una `Prueba de fuego` reproducible que confirme que un `POST /auditLog` fallido deja la mutación aplicada pero sin asiento. Usa el inyector de caos de la Fase 4 para forzar el fallo solo en la petición de auditoría.

**🔴 Muy difícil (22–27)**

22. **Diagnóstico.** Edita a mano el `value` de un resultado directamente en `db.json`, sin pasar por el store. Abre la timeline de ese resultado: el `after` del último asiento ya no coincide con el estado real de la entidad. Explica cómo un auditor detectaría esa alteración comparando el audit log contra el estado actual, y por qué el audit log de esta fase no puede evitarla.
23. El `before: null` significa que la timeline muestra el "después" de cada evento pero nunca el "antes". Diseña (en prosa, sin implementar entero) cómo reconstruir el `before` de un asiento a partir del `after` del asiento *anterior* de la misma entidad, y explica en qué caso esa reconstrucción miente.
24. 🔴 Construye la vista de comparación `before`/`after` lado a lado para un asiento: dado un asiento con ambos estados, muestra un diff campo por campo resaltando lo que cambió. Reutiliza la timeline como punto de entrada.
25. **Diagnóstico.** Te dan la bitacora completa de una orden que "salió entregada sin validar el último resultado". Reconstruye la secuencia real de asientos, identifica cuál falta o cuál sobra, y determina si el problema fue una transición ilegal (que la Fase 7 debía impedir), un asiento que no se escribió, o una mutación por fuera del store. Este es el ejercicio que ensaya la pieza forense de [`forense-fase-11.md`](./forense-fase-11.md).

26. Implementa el `correlationId` de §5.11: la acción `validateResult` genera un identificador, la acción de orden que dispara el cruce lo hereda, y los dos asientos lo guardan. Después consulta la bitácora filtrando por ese id y confirma que devuelve exactamente los dos cambios del mismo gesto.
27. **Diagnóstico.** Escucha `validateResult` (la intención, no el `Success`) en un effect de prueba con `withLatestFrom(this.store)` y registra el `status` del resultado. Después haz lo mismo escuchando `validateResultSuccess`. Anota los dos valores y explica cuál de los dos es el "antes" y por qué el orden reducer-effect de §5.10 lo determina.

**🔥 Opcionales**

- 🔥 Migra el filtrado de la bitacora al servidor usando los query params de json-server (`/auditLog?entityType=order&entityId=4021`) en vez de traer todo y filtrar en memoria. Documenta qué gana y qué se acopla a json-server.
- 🔥 Agrega un segundo effect que, además del asiento, emita una métrica (un `console.count` por `entityType`) sin tocar `writeAudit$`. Demuestra que un tercer consumidor transversal de las mismas acciones no requiere modificar el existente.
- 🔥 Propón (sin implementar) cómo se vería este audit log si lo escribiera el backend: qué desaparece del frontend, qué deuda 💸 se paga, y qué del incidente 17 dejaría de ser posible.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v8.angular.io/guide/observables — el modelo de observables sobre el que corre el `store.select` de la timeline. ⚠️ Enlace no verificado al cierre; si `v8.angular.io` no responde, `https://angular.io/guide/observables` cubre una versión posterior con diferencias menores en este tema.
- https://ngrx.io/guide/effects — effects. ⚠️ Cubre versiones posteriores; el `createEffect` de esta página es compatible con NgRx 8, pero `createActionGroup` y `createFeature` que aparecen en guías vecinas **no existen** en la versión del curso. El patrón de un effect que hace `ofType` de acciones de otro feature es válido en todas las versiones.
- https://ngrx.io/api/store/createSelector — selectores con factory, tal como los usa `selectAuditLogForEntity`. Misma advertencia de versión.
- https://github.com/typicode/json-server/tree/v0.16.3 — `POST` a una colección y filtros por campo, en la versión que fijó la Fase 4.
- https://developer.mozilla.org/en-US/docs/Web/API/WindowBase64/Base64_encoding_and_decoding — `atob`, que `getDecodedUser()` de la Fase 3 usa para leer el payload del JWT del que sale el `actor`.

**Libros / artículos de referencia**

- Martin Fowler, *Patterns of Enterprise Application Architecture* — el patrón **Audit Log** está descrito acá tal como lo aplicamos: una bitacora de cambios separada de las entidades que audita. Es la referencia de fondo de §4. ⚠️ Título y edición pueden variar; verifica.
- Discusión sobre auditoría en el cliente vs el servidor: cualquier fuente sobre *tamper-evident logging* sirve para entender por qué un audit log que el cliente puede evitar no es confiable. La deuda 💸 de esta fase es exactamente ese problema.

**Video / apoyo**

- *NgRx Effects* — búsqueda sugerida: https://www.youtube.com/results?search_query=ngrx+effects+angular+8 — material de la época. ⚠️ Verifica la fecha: cualquier video posterior a 2021 muestra `createActionGroup`, que no existe en tu `package.json`.

**Orden de lectura sugerido:** antes de escribir código, la sección de effects de NgRx para tener claro que un effect escucha acciones, no las suyas nada más. Durante, la API de `createSelector` cuando escribas el selector con factory. Después, el patrón Audit Log de Fowler, ya con el código escrito, para ver cuánto de lo que construiste es el patrón clásico y cuánto es la deuda 💸 de haberlo puesto en el frontend.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido desde que se escribió esto. Los enlaces a `v8.angular.io` están marcados como **no verificados** y arrastran el pendiente abierto en la Fase 3. Cualquier documentación de NgRx en su sitio oficial cubre una versión posterior a la del curso: léela sabiendo que parte de lo que ofrece no existe en tu stack.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Quedó construido el audit log: un slice nuevo con feature key `'audit'`, un `AuditEffect` que escucha las mutaciones exitosas de las Fases 5 a 9 y deja un asiento por cada una, una timeline consultable por entidad, y el reflejo de que **cuando el ticket no tiene evidencia en vivo, la bitacora es la primera caja que abres**. Quedaron declaradas las deudas 💸 que no se pagan: el asiento lo escribe el front y no el backend, el `actor` sale del token del navegador, el `timestamp` es del reloj del cliente, el `before` va en `null`, y el filtrado es en memoria. Ninguna se corrige; todas se entienden, porque cada una es un bug que vas a auditar algún día.

La **Fase 12** es el paso natural porque necesita justo lo que acá quedó instalado: una bitacora que registra *qué* pasó y *cuándo*, sobre la cual se puede construir la siguiente capa de control. El audit log es la base de evidencia; sin él, cualquier cosa que la Fase 12 quiera verificar tendría que reconstruirse de nuevo desde los timestamps dispersos que esta fase justamente vino a reemplazar.

> **La señal de que quedó bien:** cuando alguien te diga *"esto pasó el sábado y no sé por qué"*, tu primer movimiento no sea abrir el código ni pedir que lo reproduzcan, sino filtrar el `auditLog` por la entidad y leer la timeline de corrido — y que tu segundo pensamiento, apenas la leas, sea *"¿y esto quién lo escribió de verdad?"*.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-11-trazabilidad-audit-log -m "F11 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f11: …`) y los de ejercicio su
> número (`f11 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f11/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

Cosas que aparecieron escribiendo esta fase y que no caben acá:

- 🪦 **[A] Resuelto acá.** El porqué del `before: null` —que el reducer corre antes que el effect, así que el store ya tiene el *después* cuando el `AuditEffect` mira— quedó desarrollado en **§5.10**, con las tres opciones de diseño y su precio. Implementarlo sigue siendo el ejercicio 17: refactor transversal de las Fases 7, 8 y 9, no hotfix.
- 🪦 **[B] Resuelto acá.** El cruce `results → orders` que la Fase 8 dejó para esta fase quedó desarrollado en **§5.11**: por qué acopla tres slices, cómo se ve en la bitácora (dos asientos, un solo gesto, y el segundo sin causa visible) y las tres salidas con su precio. El **desacople** en sí sigue siendo el rediseño que Track A declara no abordar; lo que sí cabe es hacerlo auditable con el `correlationId` del ejercicio 26.
- **[C]** El **audit log de lecturas** (quién consultó qué, no solo quién mutó qué). Es otra escala de problema —volumen mucho mayor, otras implicaciones— → sugerido para las **pendientes de proyecto**; no es de una fase.
- **[D]** La **actualización en tiempo real** de la timeline (que un asiento escrito en otra pestaña aparezca sin recargar) → hereda el pendiente [D] de la Fase 10; sugerido para la **Fase 4** como fuente de eventos.

### Reservas para el cuaderno de incidentes

Esta fase toma el incidente **17**. Está en el índice del cuaderno y con su enunciado escrito allí, que es donde vive:

- **17** · Fase 11 · *"El log dice que yo validé ese resultado y yo no estaba ese día"* · Categoría: trazabilidad · Dificultad 🟠 — ancla las tres deudas 💸 del asiento (actor de cliente, timestamp de cliente, escritura desde el front), y usa el `actor: 'system'` y la discrepancia de un día por zona horaria como las dos pistas escalonadas.
