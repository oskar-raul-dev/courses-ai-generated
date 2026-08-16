# 📎 Apéndice A06 — NgRx 8

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **4h**
> Usado por: Fases 1, 5, 6, 7, 8, 9, 10, 11 y 12 · Versión cubierta: NgRx **8.6.0**
> (`@ngrx/store`, `@ngrx/effects`, `@ngrx/store-devtools`)
> Estado: Base ⭐

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve una sola pregunta, la que aparece cada vez que abres un slice ajeno: **dónde va este código y por qué ese archivo y no otro.**

Este proyecto usa NgRx en una mezcla de dos épocas, y conviene saberlo antes de leer una línea: las **acciones y los effects** están escritos con la API moderna que llegó justo en la 8 (`createAction`, `props`, `createEffect`), y los **reducers** están en `switch`-`case`, que es lo anterior. No es incoherencia: es lo que le pasa a un equipo que actualiza de NgRx 6 a 8, adopta lo nuevo donde no duele y no reescribe lo que ya funcionaba. Mantener eso es el trabajo.

**Qué queda fuera:** `createFeature`, `createActionGroup`, los *functional effects*, `provideStore` y los Signals. **Ninguno existe en NgRx 8** — llegaron entre la 12 y la 16 — así que si los ves en un tutorial, no es que tú lo estés haciendo mal: es otra versión. El **Apéndice A11 §6** muestra este mismo slice escrito con esa API, lado a lado con el tuyo, y su §8 trae la tabla para traducir un ejemplo moderno a lo que tienes. Tampoco entra el porqué de usar un store en vez de un `BehaviorSubject` compartido (**Fase 1 §4**), ni cómo funcionan los operadores de RxJS que aparecen en los effects (**Apéndice A05**, que es su dueño: acá se dice *qué* hace el effect, no cómo funciona `mergeMap`), ni el testing del store (**Fase 12**, incluido que en Angular 8 se inyecta con `TestBed.get()` y no con `TestBed.inject()`).

---

## Índice

- [1. El mapa en una página](#1-el-mapa-en-una-página)
- [2. Acciones: `createAction` y `props`](#2-acciones-createaction-y-props)
- [3. El reducer en `switch`, y el `createReducer` que no usamos](#3-el-reducer-en-switch-y-el-createreducer-que-no-usamos)
- [4. Selectores: `createFeatureSelector` y `createSelector`](#4-selectores-createfeatureselector-y-createselector)
- [5. Effects: `createEffect` y `ofType`](#5-effects-createeffect-y-oftype)
- [6. Registrar un slice: `forRoot` vacío y `forFeature`](#6-registrar-un-slice-forroot-vacío-y-forfeature)
- [7. DevTools: leer el store como un log](#7-devtools-leer-el-store-como-un-log)
- [8. Anatomía del feature state](#8-anatomía-del-feature-state)
- [9. 🩻 Lo que existía en NgRx 8 y no usamos](#9--lo-que-existía-en-ngrx-8-y-no-usamos)
- [10. ⚰️ Los tres errores que no dan error](#10-️-los-tres-errores-que-no-dan-error)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-10)

---

## 1. El mapa en una página

Un slice son **cinco archivos** y siempre los mismos. Esta es la primera consulta del apéndice y la que más veces vas a hacer: *"tengo que tocar X, ¿en qué archivo vive?"*.

```
src/app/patients/
├── store/
│   ├── patients.actions.ts     ← QUE puede pasar. Solo nombres y payloads
│   ├── patients.reducer.ts     ← COMO cambia el estado. Funcion pura, sincrona
│   ├── patients.effects.ts     ← QUE PASA AFUERA. HTTP, navegacion, storage
│   └── patients.selectors.ts   ← COMO se lee el estado. Consultas memoizadas
├── patients.service.ts         ← habla con la red. Devuelve observables y se aparta
├── patients.module.ts          ← REGISTRA el slice: forFeature(...)
└── patient-list/               ← el componente, que despacha y se suscribe
```

Y el árbol entero, porque la mitad de los errores de import de este curso salen de
contar mal los `../`. **Fíjate en el nivel del servicio: vive junto al módulo, no
dentro de `store/`.** Es una decisión de LabCore y tiene su lógica —el servicio no
es parte del store, es a quien el store llama— pero significa que desde un effect
el servicio está a `../` y el `environment` a `../../`:

```
src/
├── environments/
│   ├── environment.ts
│   └── environment.prod.ts
└── app/
    ├── app.module.ts
    ├── app-routing.module.ts
    ├── app.component.html          ← un <router-outlet> pelado (Fase 3 §5.8)
    ├── core/                       ← singletons. Se importa SOLO en AppModule
    │   ├── core.module.ts
    │   ├── shell/                  ← toolbar + sidenav (Fase 1 §5.4)
    │   ├── auth/                   ← service, guard, interceptor, login (Fase 3)
    │   ├── i18n/                   ← module, language.service, selector (Fase 2)
    │   └── config/                 ← app-config.service.ts (Fase 13 §5.3)
    ├── shared/
    │   └── shared.module.ts        ← reexporta. NO provee servicios
    ├── patients/  orders/  samples/  results/  audit/  reports/  dashboard/
    └── ...
```

Las tres rutas que se escriben mal más veces, resueltas de una vez:

| Desde | Hacia | Se escribe |
|---|---|---|
| `<feature>/store/*.effects.ts` | el servicio de su propio feature | `../<feature>.service` |
| `<feature>/store/*.ts` | `AuthService` | `../../core/auth/auth.service` |
| `<feature>/*.service.ts` | `environment` | `../../environments/environment` |

> ⚠️ Una ruta mal contada no siempre falla al compilar: si existe **otro** archivo en
> el destino equivocado, TypeScript lo resuelve tan contento. Cuando un import
> "funcione" y el objeto que llega no tenga los métodos que esperabas, cuenta los
> `../` antes de sospechar de nada más.

Y el recorrido de una carga de pacientes, de punta a punta:

```
componente                store                     effect                 servicio
    │                       │                          │                      │
    ├─ dispatch(loadPatients) ─────────────────────────>│                     │
    │                       │  (el reducer ve la accion │                     │
    │                       │   y pone loading: true)   │                     │
    │                       │                          ├─ getPatients() ──────────>│
    │                       │                          │                      │
    │                       │                          │<──── Patient[] ──────┤
    │                       │<─ dispatch(loadPatientsSuccess) ─┤              │
    │                       │  (el reducer guarda items │                     │
    │                       │   y pone loading: false)  │                     │
    │<── el selector emite ─┤                          │                      │
```

> 🧠 **La regla que ordena todo el reparto:** el **reducer** no puede hacer nada asíncrono ni tocar el mundo exterior, y el **effect** no puede tocar el estado. Si tienes que llamar al servidor, es un effect. Si tienes que decidir cómo queda el estado, es el reducer. Cuando dudes de dónde va un `if`, pregúntate si necesita esperar algo: si no espera, va al reducer.

Y la regla que la acompaña: **los effects devuelven acciones**, no resultados. Un effect que hace un `PATCH` no "actualiza el estado": despacha `updateSuccess` y es el reducer quien decide qué hacer con eso. Esa indirección es la que hace que todo el sistema sea auditable desde DevTools, y es la razón de que exista el **audit log de la Fase 11**.

---

## 2. Acciones: `createAction` y `props`

Una acción es **un hecho que ya pasó o una intención**, con nombre y payload. No es un método ni una orden: nadie "ejecuta" una acción, se despacha y quien esté escuchando reacciona.

```typescript
// src/app/patients/store/patients.actions.ts
import { createAction, props } from '@ngrx/store';

export const loadPatients = createAction(
  '[Patients] Load Patients'          // sin payload: no lleva props
);

export const loadPatientsSuccess = createAction(
  '[Patients] Load Patients Success',
  props<{ patients: any[] }>()        // el payload, tipado en la firma
);

export const loadPatientsFailure = createAction(
  '[Patients] Load Patients Failure',
  props<{ error: any }>()
);
```

**`createAction` y `props` sí existen en NgRx 8**: llegaron con esta versión, y por eso conviven con reducers en `switch`. Antes de la 8 esto se escribía con clases (`export class LoadPatients implements Action`), y si encuentras esa forma en un ejemplo de internet estás leyendo NgRx 7 o anterior.

Tres cosas que hay que saber y ninguna es obvia:

**El nombre no es decorativo, es el mensaje.** La convención `'[Feature] Verbo Sustantivo'` no es un capricho de estilo: es exactamente lo que vas a leer en DevTools (§7) y en el audit log a las tres de la mañana. `'[Patients] Load Patients Failure'` te dice el slice, la operación y el desenlace de un vistazo; `'loadFail'` no te dice nada cuando hay nueve slices.

**El `.type` es esa misma string, y el reducer la usa.** `loadPatients.type` devuelve `'[Patients] Load Patients'`. Ese es el puente entre las acciones modernas y el reducer viejo: el `switch` compara contra `PatientsActions.loadPatients.type`, no contra un literal escrito a mano (§3).

**El trío `Load / Success / Failure` es un contrato de nueve fases.** Se repite para cada entidad desde la Fase 5 hasta la 11. Cambiar la forma del trío en un slice significa que ese slice deja de parecerse a los otros seis, y quien llegue después va a perder media hora averiguando por qué.

> ⚠️ **Dos acciones distintas pueden tener el mismo `type` sin que nadie se queje.** Si copias un archivo de acciones para crear un slice nuevo y olvidas cambiar el prefijo `[Patients]`, tienes dos acciones con el mismo nombre: los reducers de los dos slices reaccionan a las dos, y el bug parece cosa de brujas. NgRx no lo detecta en la 8 —la comprobación `strictActionTypeUniqueness` llegó mucho después—, así que la única defensa es mirar el prefijo cada vez que copias un archivo.

---

## 3. El reducer en `switch`, y el `createReducer` que no usamos

El reducer es una **función pura**: recibe el estado actual y una acción, devuelve el estado nuevo. No llama a nadie, no espera nada, no muta.

```typescript
// src/app/patients/store/patients.reducer.ts
import * as PatientsActions from './patients.actions';

export function patientsReducer(state = initialState, action: any): PatientsState {
  switch (action.type) {

    case PatientsActions.loadPatients.type:
      // Objeto NUEVO. El spread copia lo anterior y pisa lo que cambia.
      return { ...state, loading: true, error: null };

    case PatientsActions.loadPatientsSuccess.type:
      return { ...state, loading: false, items: action.patients };

    // Cualquier acción que no reconozca devuelve el estado intacto. No es
    // opcional: el reducer recibe TODAS las acciones de la aplicación.
    default:
      return state;
  }
}
```

Tres reglas que no se negocian:

**Devuelve un objeto nuevo, siempre.** Mutar `state.items.push(...)` compila, funciona a veces, y produce el peor bug del store: los selectores memoizados comparan por referencia (§4), así que si la referencia no cambió, **la pantalla no se entera de que el dato cambió**. El síntoma es intermitente y no hay error en consola. La §9 tiene el interruptor que convierte eso en una excepción ruidosa.

**El `default` es obligatorio.** El reducer de pacientes recibe también las acciones de órdenes, de muestras y de i18n. Sin `default: return state`, cualquier acción ajena devolvería `undefined` y el slice desaparecería del store.

**El `case` compara contra `.type`, no contra un literal.** Escribir `case '[Patients] Load Patients':` a mano funciona hasta que alguien corrige una tilde en el archivo de acciones. Con `PatientsActions.loadPatients.type` el compilador te avisa si la acción deja de existir; con el literal, no.

### 3.1 Lo mismo con `createReducer`, que también existía

NgRx 8 traía `createReducer` con `on(...)`. Este proyecto no lo usa —deuda 💸 declarada y justificada en la **Fase 1 §5.9**, y con su ejercicio 🔥 de reescritura—, pero la doc oficial no documenta ninguna otra cosa, así que necesitas leer las dos formas.

```typescript
// La misma lógica, con createReducer. NgRx 8 lo soportaba.
import { createReducer, on } from '@ngrx/store';

export const patientsReducer = createReducer(
  initialState,
  on(PatientsActions.loadPatients, function (state) {
    return { ...state, loading: true, error: null };
  }),
  // El segundo argumento del handler es la acción, YA TIPADA por la props<>
  // de createAction. Aquí action.patients es any[]; action.pacientes no compila.
  on(PatientsActions.loadPatientsSuccess, function (state, action) {
    return { ...state, loading: false, items: action.patients };
  })
);
```

| | `switch` (lo que usas) | `createReducer` + `on` |
|---|---|---|
| Tipado de la acción | Ninguno: `action: any` | Inferido de `props<>`. Un typo en el payload **no compila** |
| `default` | Lo escribes tú, y si lo olvidas rompes el slice | Implícito. No se puede olvidar |
| Acción no manejada | Cae en el `default` | Devuelve el estado sin tocar |
| Leer un diff | Un `case` más, tres líneas | Un `on(...)` más, tres líneas |
| Depurar con breakpoint | Un `switch`: pones el punto y ves todo pasar | Cada `on` es una función suelta; el flujo es menos evidente |
| Lo que encuentras en internet | Casi nada desde 2019 | Absolutamente todo |

> 🧭 **Lo que se gana con `on` es real y es tipado**, y es exactamente el error que el ejercicio 29 de la Fase 1 te hace cometer a propósito (`action.pacientes` en vez de `action.patients`, que con `action: any` pasa el compilador y falla en pantalla). Lo que se pierde al migrar no es técnico: es que siete slices dejan de parecerse entre sí mientras dure la migración a medias. Por eso la Fase 1 declara la deuda y no la paga.

---

## 4. Selectores: `createFeatureSelector` y `createSelector`

Un selector es una **consulta al store**. Se escriben en dos niveles y el orden importa.

```typescript
// src/app/patients/store/patients.selectors.ts
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { PatientsState } from './patients.reducer';

// Nivel 1: apunta al slice entero. La cadena tiene que coincidir EXACTAMENTE
// con la clave del StoreModule.forFeature de patients.module.ts (sección 6).
export const selectPatientsState = createFeatureSelector<PatientsState>('patients');

// Nivel 2: consultas concretas sobre ese slice.
export const selectAllPatients = createSelector(
  selectPatientsState,
  function (state) { return state.items; }
);

// Derivado: se construye sobre otros selectores, no sobre el estado crudo.
export const selectFilteredPatients = createSelector(
  selectAllPatients,
  selectPatientsFilter,
  function (patients, filter) {
    if (!filter) { return patients; }
    var needle = filter.toLowerCase();
    return patients.filter(function (p) {
      return (p.fullName || '').toLowerCase().indexOf(needle) >= 0;
    });
  }
);
```

### 4.1 Memoización: qué es y cuándo se rompe

`createSelector` **cachea el último resultado**. Si sus entradas no cambiaron de referencia, no vuelve a ejecutar la función: devuelve lo de antes. Por eso puedes tener un selector que filtra tres mil pacientes consultado desde una plantilla sin que la aplicación se arrastre.

La memoización compara **por referencia**, no por contenido. De ahí salen las dos formas de romperla, y las dos duelen en direcciones opuestas:

- **Mutar el estado en el reducer** → la referencia no cambia → el selector devuelve lo viejo → **la pantalla no se actualiza** aunque el dato sí cambió (§3).
- **Devolver un objeto nuevo en cada llamada** (`return { ...state.items }`, o un `.map()` dentro del selector sin que las entradas hayan cambiado) → la referencia cambia siempre → **todo se recalcula y se repinta** aunque no haya pasado nada. Es una de las tres firmas del dashboard lento de la **Fase 10 §5.2**.

> 💡 Para comprobar si un selector está memoizando de verdad, mete un `console.count('selectorX')` dentro de su función e interactúa con **otra** parte de la aplicación. Si el contador sube cuando tocas un slice que ese selector no consulta, la memoización no está funcionando. La prueba completa está en la **Fase 10 §5.7**.

### 4.2 La string suelta

`createFeatureSelector<PatientsState>('patients')` y `StoreModule.forFeature('patients', patientsReducer)` son **dos strings escritas a mano en dos archivos distintos que nadie valida**. Si no coinciden, el selector devuelve `undefined` —no un error— y la pantalla se rompe lejos de la causa, normalmente con un `Cannot read property 'items' of undefined`. Es el primero de los tres errores silenciosos de la §10.

---

## 5. Effects: `createEffect` y `ofType`

Un effect **escucha el flujo de acciones**, hace algo con el mundo exterior, y despacha otra acción con el resultado. Es el único sitio del store donde vive lo asíncrono.

```typescript
// src/app/patients/store/patients.effects.ts
import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { map, switchMap, catchError, timeout } from 'rxjs/operators';

@Injectable()
export class PatientsEffects {

  loadPatients$ = createEffect(function (this: PatientsEffects) {
    return this.actions$.pipe(
      // ofType filtra: de todas las acciones del sistema, solo esta.
      ofType(PatientsActions.loadPatients),
      switchMap(function (this: PatientsEffects) {
        return this.patientsService.getPatients().pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (patients: any[]) {
            return PatientsActions.loadPatientsSuccess({ patients: patients });
          }),
          // catchError DENTRO del pipe interno. Si va fuera, el effect muere.
          catchError(function (error: any) {
            return of(PatientsActions.loadPatientsFailure({ error: error }));
          })
        );
      }.bind(this))
    );
  }.bind(this));

  constructor(private actions$: Actions, private patientsService: PatientsService) { }
}
```

Lo que hay que retener, en cuatro puntos:

**`createEffect` es de NgRx 8.** Antes se marcaba con el decorador `@Effect()` sobre una propiedad. Las dos formas hacen lo mismo; esta es la que el proyecto usa, y no hay un solo `@Effect` en el curso.

**`ofType` viene de `@ngrx/effects`, no de RxJS.** Es un operador más dentro del `pipe`, pero su import está en otro paquete. Acepta varias acciones (`ofType(a, b, c)`), que es como el audit log de la Fase 11 escucha acciones de cinco slices a la vez.

**Un effect siempre devuelve una acción.** Si el suyo no tiene nada que despachar —loguear algo, navegar—, hay que decirlo explícitamente o NgRx intentará despachar `undefined` y romperá el store:

```typescript
// Sin dispatch: false, NgRx intenta despachar lo que devuelva el pipe.
logSelection$ = createEffect(function (this: PatientsEffects) {
  return this.actions$.pipe(
    ofType(PatientsActions.selectPatient),
    tap(function (action: any) { console.log('seleccionado:', action.patientId); })
  );
}.bind(this), { dispatch: false });
```

**Un effect que deja morir su stream deja de escuchar para siempre.** Es el error más caro del curso y el motivo de que `catchError` vaya dentro del pipe interno. Cómo funciona y cómo se reproduce está en el **Apéndice A05 §5** y en la **Fase 1 §6** con su ejercicio de diagnóstico; acá solo queda la regla.

---

## 6. Registrar un slice: `forRoot` vacío y `forFeature`

Esta sección explica una sola cosa, y esa cosa es la causa de tres síntomas distintos repartidos por el curso que parecen no tener nada que ver entre sí.

El estado raíz de este proyecto está **vacío a propósito**:

```typescript
// src/app/app.module.ts
imports: [
  // No hay estado global. Cada feature module registra el suyo.
  StoreModule.forRoot({}),
  EffectsModule.forRoot([]),
  StoreDevtoolsModule.instrument({ maxAge: 25, logOnly: environment.production })
]
```

Y cada feature registra el suyo, en su módulo, que además es **lazy**:

```typescript
// src/app/patients/patients.module.ts
imports: [
  StoreModule.forFeature('patients', patientsReducer),
  EffectsModule.forFeature([PatientsEffects])
]
```

> 🧠 **La consecuencia que hay que tener escrita en la frente: un slice no existe hasta que alguien navega a su ruta por primera vez.** No está vacío: **no está**. Y su effect no escucha nada, porque tampoco se registró.

De ahí salen los tres síntomas, que ahora se leen como uno solo:

| Síntoma | Dónde aparece en el curso | Por qué |
|---|---|---|
| Un selector devuelve `undefined` en vez de `[]` | **Fase 6 §6** — consultar órdenes sin haber entrado a `/orders` | El slice `orders` no está registrado todavía |
| El slice aparece en DevTools a mitad de sesión | **Fase 7**, ejercicio 20 | Se registró al navegar a `/orders/:id/samples` |
| Un effect no reacciona aunque el archivo compile | **Fase 11 §6** — el `AuditEffect` mudo | Su módulo lazy nunca se cargó |

Y un cuarto que hereda el **Apéndice A05 §8.2**: un `withLatestFrom(this.store)` sobre un slice que no está cargado **no emite nunca y no da ningún error**. El effect se queda mudo para siempre. Si entras a una pantalla profunda por un enlace directo, sin pasar por la ruta que carga el slice, ese es el primer sitio donde mirar.

**El fallo espejo: registrar dos veces.** Poner `EffectsModule.forRoot([PatientsEffects])` en `AppModule` *además* del `forFeature` registra el effect dos veces, y a partir de ahí **cada acción dispara dos peticiones**. No hay error, y con un mock rápido en local la duplicación pasa desapercibida porque las dos respuestas llegan bien. Se ve en la pestaña Network y en el contador de DevTools, y es el ejercicio 25 de la **Fase 1** y el 16 de la **Fase 11**.

---

## 7. DevTools: leer el store como un log

> 🕵️ **El recorrido completo con las tres pestañas** —Actions, Diff y el deslizador, y lo que el time-travel **no** deshace— está en [`forense-fase-01.md`](forense-fase-01.md).

La extensión Redux DevTools es la herramienta de diagnóstico más rentable de todo el stack y la que menos gente abre. Con ella, cada acción de la aplicación es una línea de log con su payload, su diff de estado y su hora.

```typescript
StoreDevtoolsModule.instrument({
  maxAge: 25,                          // solo las ultimas 25 acciones
  logOnly: environment.production      // en prod, solo lectura
})
```

Qué significa cada opción y qué te va a morder:

- **`maxAge: 25`** — el historial se corta en 25 acciones. En un flujo largo (abrir orden → cargar muestras → validar resultado → recargar) te vas a quedar sin historial justo antes de lo que buscas. Súbelo temporalmente cuando estés persiguiendo algo: es una línea y se revierte.
- **`logOnly: true`** — desactiva el *time travel* y el despacho manual: puedes mirar, no tocar. Es lo que se activa en producción.
- **En producción el módulo se desactiva, pero no desaparece.** El código viaja igual dentro del bundle. Es peso muerto medible, y sale en el analizador del **Apéndice A04 §5**.

Las tres cosas que de verdad se usan:

**El diff.** Selecciona una acción y mira la pestaña *Diff*: te dice exactamente qué claves del estado cambiaron. Es la respuesta más rápida a "¿esta acción hizo lo que yo creía?".

**El time travel.** Retrocede a una acción anterior y la aplicación se repinta con ese estado. Sirve para reproducir un bug sin volver a hacer los doce clics — y también revela cuál es el estado real frente a lo que muestra la pantalla, que no siempre coinciden.

**El despacho a mano.** Puedes despachar una acción escribiéndola en DevTools, sin pasar por la interfaz. Es la forma más rápida de probar una guarda del reducer… y es también la razón por la que **una guarda en el reducer protege del error honesto, no del malicioso**: cualquiera con la extensión abierta puede despachar `transitionSample` con lo que le dé la gana. La **Fase 7 §4** lo dice con todas las letras.

> ⚠️ **Si un slice no aparece en DevTools, no está roto: no está registrado.** Antes de buscar el bug en el reducer, navega a la ruta que carga ese feature y mira si aparece. La mitad de los "el store no funciona" son la §6.

---

## 8. Anatomía del feature state

Los siete slices del proyecto tienen la misma forma, y esa repetición es intencional:

```typescript
export interface PatientsState {
  items: any[];          // la colección. any: no hay interfaz Patient (deuda)
  loading: boolean;      // hay una petición en vuelo
  error: any;            // el último fallo, o null
  selectedId: number;    // que elemento esta seleccionado, por id
}
```

Por qué esas cuatro claves y no otras:

- **`items` es un arreglo plano, no un diccionario por id.** Buscar por id es un `.find()` lineal. Con los volúmenes del curso da igual; la alternativa es `@ngrx/entity` (§9).
- **`loading` es un booleano, no un contador.** Dos peticiones simultáneas sobre el mismo slice y la primera que termine apaga el spinner de las dos. Es aceptable acá porque las escrituras son de a una; en un slice con escrituras concurrentes haría falta un contador.
- **`error` guarda el último fallo y lo pisa.** Un segundo error borra el primero. La alternativa —una lista de errores— nadie la pide hasta que hay que auditar.
- **`selectedId` guarda el id, no el objeto.** Guardar el objeto sería duplicar el dato: uno en `items` y otro en `selectedId`, y en cuanto uno se actualice y el otro no, tienes dos verdades. **Guarda el id y deriva el objeto con un selector.** Es la regla más útil de esta sección.

> 🧭 **Lo que va al store y lo que no.** Al store va lo que tiene que sobrevivir a la navegación o lo que consulta más de un componente. **No** va el estado de una interfaz que muere con su pantalla —un acordeón abierto, el texto a medio escribir de un formulario, qué columna está ordenada—, porque eso ensucia el historial de DevTools y no lo lee nadie. Cuando dudes: si el usuario navega a otra pantalla y vuelve, ¿te importa que ese dato siga ahí? Si no, no es del store.

---

## 9. 🩻 Lo que existía en NgRx 8 y no usamos

Catálogo, no ensayo. Las cuatro piezas que tu versión traía y este proyecto no adoptó, con qué hacen y qué costaría meterlas hoy.

### 9.1 `@ngrx/entity`

**No está instalado.** Es un paquete aparte que resuelve exactamente el `items: any[]` de la §8: guarda las colecciones como `{ ids: [], entities: {} }` y te regala `addOne`, `updateOne`, `removeOne`, `upsertMany` y los selectores `selectAll` y `selectEntities` ya escritos.

Lo que resolvería en este proyecto es concreto: la **Fase 5 §5.6** recarga la lista entera después de cada escritura —dos viajes donde alcanzaba uno, con su parpadeo— porque actualizar el arreglo a mano en el reducer es tedioso y fácil de equivocar. Con `entity` eso es una línea.

Lo que cuesta: **la forma del estado cambia en todos los slices que lo adopten**, y con ella todos sus selectores, sus reducers y los tests de la Fase 12. Migrar un slice sí y otro no es peor que no migrar ninguno, porque entonces hay dos formas de estado conviviendo. Está como ejercicio 🔥 de la Fase 5, y ahí se pide justamente documentar qué se rompe en las Fases 7 a 11.

### 9.2 `MetaReducer`

Un meta-reducer envuelve a **todos** los reducers y ve pasar cada acción con el estado de antes y el de después. Es el punto de extensión global del store.

```typescript
// El MetaReducer de logging: DevTools casero, en diez líneas.
export function loggerMetaReducer(reducer: any): any {
  return function (state: any, action: any) {
    var next = reducer(state, action);
    console.groupCollapsed(action.type);
    console.log('before:', state);
    console.log('action:', action);
    console.log('after:', next);
    console.groupEnd();
    return next;
  };
}

// Se registra en el forRoot:
StoreModule.forRoot({}, { metaReducers: [loggerMetaReducer] })
```

**Para qué sirve de verdad:** el día que tengas que depurar en una máquina donde no puedes instalar la extensión de DevTools —un equipo bloqueado por política, el navegador de un usuario— esto es lo único que te queda. Es el ejercicio 🔥 de la Fase 1.

### 9.3 El `ActionReducerMap` tipado, y el `Store<any>`

El proyecto inyecta `Store<any>` en diez componentes. Con `any`, `this.store.select(cualquierCosa)` compila siempre y `select` sobre un slice que no existe devuelve `undefined` sin que nadie avise.

La alternativa que NgRx 8 ya ofrecía es declarar la forma del estado raíz y tipar el store con ella:

```typescript
export interface AppState {
  patients: PatientsState;
  orders: OrdersState;
}

export const reducers: ActionReducerMap<AppState> = {
  patients: patientsReducer,
  orders: ordersReducer
};

// Y en el componente: constructor(private store: Store<AppState>) { }
```

**Por qué este proyecto no puede hacerlo tal cual, y es una razón buena:** su estado raíz está **vacío** y todos los slices son lazy (§6). Un `AppState` que declare `patients` y `orders` estaría mintiendo, porque durante buena parte de la sesión esas claves no existen. Tipar bien un store de slices lazy exige que todas las claves sean opcionales (`patients?: PatientsState`), y entonces el compilador te obliga a comprobar `undefined` en cada selector — que es exactamente la comprobación que hoy no se hace y por eso el bug de la §10 existe. **El tipado no es cosmético acá: es el que te obligaría a manejar el caso del slice ausente.**

### 9.4 `runtimeChecks`

NgRx 8 introdujo cuatro comprobaciones que se activan en `forRoot` y convierten en excepción ruidosa lo que hoy es un bug intermitente:

| Comprobación | Qué caza |
|---|---|
| `strictStateImmutability` | Un reducer que muta el estado en vez de devolver uno nuevo (§3) |
| `strictActionImmutability` | Un effect o un reducer que modifica el objeto de la acción |
| `strictStateSerializability` | Un `Date`, un `Map` o una función guardados dentro del estado |
| `strictActionSerializability` | Lo mismo, dentro del payload de una acción |

```typescript
StoreModule.forRoot({}, {
  runtimeChecks: {
    strictStateImmutability: true,
    strictActionImmutability: true,
    strictStateSerializability: true,
    strictActionSerializability: true
  }
})
```

> ⚠️ **No des por buenos los valores por defecto: compruébalos.** Cuáles de las cuatro vienen activadas de fábrica cambió entre versiones de NgRx, y este apéndice no va a afirmar de memoria cuál es el reparto en tu 8.6.0. El experimento que lo resuelve dura dos minutos y es el ejercicio 9: muta el estado a propósito en un reducer y mira si la aplicación lanza una excepción o si el bug pasa en silencio. Lo que veas es la respuesta para tu versión, y vale más que cualquier tabla.

La decisión de este proyecto —y lo que costaría cambiarla— está en la **Fase 1 §5.6**. Las dos de serializabilidad son las que más ruido harían aquí: el estado del curso guarda fechas como string ISO precisamente por esto, pero el `validatedAt: new Date().toISOString()` de la Fase 8 pasa por el payload de una acción, y ahí hay que mirar con calma antes de encender nada.

---

## 10. ⚰️ Los tres errores que no dan error

Los tres fallan en silencio, los tres se diagnostican en menos de un minuto **si sabes que existen**, y los tres han costado una tarde a alguien.

**1. Las dos strings que no coinciden.** `createFeatureSelector('patients')` contra `forFeature('patient', ...)`. El selector devuelve `undefined`, la pantalla revienta con `Cannot read property 'items' of undefined` en un componente que no tiene nada que ver, y no hay ni un warning. **Diagnóstico:** abre DevTools y mira cómo se llama el slice de verdad. Son diez segundos.

**2. El effect registrado dos veces.** `forRoot([PatientsEffects])` y `forFeature([PatientsEffects])` a la vez. Cada acción dispara dos peticiones. Con un mock local ni se nota, porque las dos responden bien y rápido; en producción es el doble de carga y, si la acción escribe, **dos escrituras**. **Diagnóstico:** cuenta las peticiones en Network por cada clic.

**3. El slice que no está registrado todavía.** Un selector que devuelve `undefined` en vez de `[]`, o un `withLatestFrom` que no emite nunca (§6). **Diagnóstico:** navega primero a la ruta de ese feature y repite. Si entonces funciona, ya lo tienes.

> 🧠 **El patrón común de los tres:** NgRx no valida nada de esto en tiempo de compilación, porque las tres cosas son strings y registros dinámicos que solo existen al arrancar. **El compilador no te va a salvar; DevTools sí.** Por eso la §7 es la sección que más se consulta de este apéndice.

---

## 🧭 Cuándo usar qué

Entrada por intención: "quiero hacer X en el store".

| Quiero | Va en | Trampa |
|---|---|---|
| Decir que algo pasó o que el usuario pidió algo | Una acción (§2) | El prefijo `[Feature]`: copiar un archivo y no cambiarlo duplica types |
| Cambiar cómo queda el estado | El reducer (§3) | Objeto nuevo, siempre. Y no olvides el `default` |
| Llamar al servidor, navegar, tocar `localStorage` | Un effect (§5) | `catchError` dentro del pipe interno, o el effect muere |
| Un effect que no despacha nada | Un effect con `{ dispatch: false }` (§5) | Sin esa opción, NgRx despacha `undefined` |
| Leer el estado desde un componente | Un selector (§4) | La string del `createFeatureSelector` tiene que coincidir |
| Derivar un dato de otros dos | `createSelector` sobre selectores, no sobre el estado (§4) | Devolver un objeto nuevo cada vez rompe la memoización |
| Guardar cuál está seleccionado | El id en el estado, el objeto por selector (§8) | Guardar el objeto crea dos verdades que se desincronizan |
| Guardar si un acordeón está abierto | **Nada.** Una propiedad del componente (§8) | El store no es para estado que muere con la pantalla |
| Saber qué pasó en la aplicación hace treinta segundos | DevTools, pestaña Diff (§7) | `maxAge: 25` te corta el historial antes de lo que buscas |
| Que un reducer que muta falle ruidoso | `runtimeChecks` (§9.4) | Comprueba los defaults de tu versión, no los supongas |
| Registrar un slice nuevo | `forFeature` en su módulo (§6) | No existe hasta que alguien navegue ahí |
| Escuchar acciones de varios slices | `ofType(a, b, c)` en un effect (§5) | El módulo del effect tiene que estar cargado |
| Colecciones con `addOne`/`updateOne` ya escritos | `@ngrx/entity` (§9.1) | No está instalado, y cambia la forma del estado en cascada |
| Loguear cada acción sin la extensión | Un `MetaReducer` (§9.2) | En producción es un `console.log` por acción |

---

## ⚠️ Advertencias

**`ngrx.io` solo documenta versiones modernas, y la diferencia no es cosmética.** Es la advertencia central de este apéndice porque afecta a cada búsqueda. El sitio oficial sirve la versión actual: el `createReducer` con `on()` que verás en la página de reducers **no** es lo que tienes en tus siete slices, y `createFeature`, `createActionGroup`, los functional effects y `provideStore` **no existen en NgRx 8**. Si copias un ejemplo y no compila, no estás loco: estás leyendo sobre una versión cuatro mayores por encima. La documentación de tu versión existe, pero hay que ir a buscarla al repositorio (ver Referencias).

**Nada de lo que sostiene el store lo valida el compilador.** Las claves de los features son strings sueltas en dos archivos, los registros de módulos son dinámicos, y `action: any` desactiva el tipado justo donde más datos hay. Las tres cosas fallan en tiempo de ejecución y en silencio (§10). **DevTools abierto es tu compilador para esta capa**, y no es una figura retórica.

**Un slice lazy no existe hasta que alguien navega a su ruta.** No está vacío: no está. Su selector devuelve `undefined`, su effect no escucha, y `withLatestFrom` sobre él no emite jamás. Es la causa única de cuatro síntomas que parecen no tener relación (§6).

**Mutar el estado en un reducer produce el peor bug del store.** No lanza excepción, no aparece en consola, y el síntoma es "a veces la pantalla no se actualiza". La memoización compara referencias, así que si mutas, el selector devuelve lo viejo con total convicción. El interruptor que lo convierte en un error ruidoso existe desde NgRx 8 y está en la §9.4.

**Una guarda en el reducer protege del error honesto, no del malicioso.** Cualquiera con DevTools abierto puede despachar la acción que quiera con el payload que quiera y saltarse la máquina de estados de la Fase 7 entera. La validación real vive en el servidor; lo del navegador es ergonomía, no seguridad. Conviene tenerlo claro antes de decirle a alguien que "el sistema no permite esa transición".

---

## 📚 Referencias

- https://github.com/ngrx/platform/tree/8.6.0/projects/ngrx.io/content/guide/store — **la documentación de tu versión exacta**, dentro del repositorio en el tag `8.6.0`. Es la única fuente de esta lista que no te va a mentir sobre la API. Menos cómoda de navegar que el sitio, y vale la pena.
- https://ngrx.io/guide/store — la guía de store en el sitio oficial. ⚠️ Documenta una versión muy posterior: su `createReducer` con `on()` sí existe en la 8, pero `createFeature` y `createActionGroup` no.
- https://ngrx.io/guide/effects — effects. ⚠️ Mismo aviso. Los *functional effects* que muestra no existen en tu versión; `createEffect` con clase e `@Injectable`, sí.
- https://ngrx.io/guide/store/selectors — selectores y memoización. Es la parte de la doc que menos ha cambiado desde la 8, así que es de las más seguras de leer.
- https://ngrx.io/guide/store/configuration/runtime-checks — las comprobaciones de la §9.4, con qué caza cada una. ⚠️ Lista también las que llegaron después de la 8 (`strictActionWithinNgZone`, `strictActionTypeUniqueness`): si intentas activar una que tu versión no tiene, el objeto de configuración simplemente la ignora.
- https://ngrx.io/guide/entity — `@ngrx/entity`, para la §9.1. Léelo sabiendo que **no lo tienes instalado**.
- https://github.com/reduxjs/redux-devtools/tree/main/extension — la extensión de DevTools, con las instrucciones de instalación para Chrome y Firefox. Es la herramienta de la §7.
- https://github.com/ngrx/platform/blob/master/CHANGELOG.md — el changelog completo. Sirve para una cosa muy concreta: cuando dudes de si una API existe en la 8, búscala ahí y mira en qué versión aparece.
- https://redux.js.org/understanding/thinking-in-redux/three-principles — los tres principios de Redux, que son los que NgRx implementa. Es de 2015, no ha cambiado, y explica el *porqué* del reparto de la §1 mejor que cualquier página de NgRx.
- https://v8.angular.io/guide/lazy-loading-ngmodules — carga diferida de módulos en Angular 8, que es el mecanismo detrás de la §6.

> ⚠️ Los enlaces y sus contenidos pueden haber cambiado o desaparecido; verifícalos. Con NgRx el riesgo tiene una forma concreta: **`ngrx.io` no tiene selector de versión**, así que todo lo que leas ahí es la versión actual salvo que la URL apunte al repositorio. Entre tu 8.6.0 y esa hay más de una decena de mayores.

---

## 🧪 Ejercicios (10)

Cortos y de consulta. Sobre el proyecto del laboratorio, con el mock levantado y la extensión de Redux DevTools instalada.

1. Abre DevTools y navega a `/patients`. Anota **en qué momento exacto aparece el slice `patients`** en el árbol de estado, y qué había antes ahí. Después ve a `/orders` y repite. Explica en una línea por qué el estado raíz está vacío.
2. Con DevTools abierto, dispara una carga de pacientes y copia la lista de acciones que pasan, en orden. Marca cuál la despachó el componente y cuál la despachó un effect. Deberían ser dos y dos.
3. Selecciona `[Patients] Load Patients Success` en DevTools y abre la pestaña **Diff**. Anota qué tres claves del estado cambiaron. Compara con el `case` correspondiente del reducer y confirma que coinciden.
4. **Rompe a propósito.** En `patients.selectors.ts`, cambia `createFeatureSelector<PatientsState>('patients')` por `('patient')`. Recarga y anota el error exacto, **en qué archivo aparece**, y cuánto se parece ese archivo al que tocaste. Revierte.
5. Añade un `console.count('selectFilteredPatients')` dentro del selector filtrado. Interactúa con **otro** slice (marca una muestra, por ejemplo) y anota si el contador sube. Explica qué demuestra el resultado sobre la memoización.
6. **Rompe a propósito.** En el reducer de pacientes, cambia el `case` de `loadPatientsSuccess` por `state.items = action.patients; return state;`. Recarga, carga la lista, y anota qué muestra la pantalla y qué muestra DevTools. Si los dos no dicen lo mismo, acabas de reproducir el bug de la §3. Revierte.
7. Registra un effect que escuche `[Patients] Select Patient` y solo haga `console.log`. **Primero sin `{ dispatch: false }`**: anota qué pasa y qué dice la consola. Después añade la opción y anota la diferencia.
8. **Diagnóstico.** Añade `EffectsModule.forRoot([PatientsEffects])` al `AppModule`, dejando también el `forFeature`. Carga la lista y cuenta las peticiones en Network. Explica por qué esto pasaría desapercibido en local y qué haría en producción si la acción fuera de escritura. Revierte.
9. Enciende las cuatro `runtimeChecks` de §9.4 en el `forRoot` y vuelve a hacer el ejercicio 6. Anota si ahora falla ruidosamente y con qué mensaje. Después **apaga las cuatro** y comprueba cuáles de ellas estaban activas de fábrica en tu versión: esa es la tabla que este apéndice no te da hecha. Revierte.
10. **Diagnóstico.** Un compañero reporta: *"la vista de auditoría no registra nada cuando valido un resultado, pero el archivo del effect está bien y compila"*. Sin ver su pantalla, escribe las tres preguntas que le harías, en el orden en que se las harías, y qué le pedirías que mire en DevTools para cada una. Las tres respuestas están en §6 y §10.


> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida: el código que
> explica lo escriben las fases, y un tag que no apunta a un cambio no marca
> nada. Lo que salga de leerlo se commitea con el prefijo de la fase desde la
> que llegaste (`f01: …`), para que su `git log --oneline --grep '^f01'`
> siga completo. Y si un ejercicio produjo una medición, el número va en el
> mensaje de un tag anotado (`ej/a06/3`), que es donde no se pierde. La
> convención completa —tags de fase, de ejercicio y de incidente— está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **El cruce entre slices `results → orders`** —un effect que, al validar un resultado, empuja el estado de la orden— es el acoplamiento que las Fases 8 y 11 dejaron anotado. No es material de consulta rápida: es diseño. Quedó desarrollado en la **Fase 11 §5.11**, que es donde el audit log lo hace visible (un evento genera asientos de dos entidades distintas).
- **`@ngrx/entity` no está instalado** y la Fase 5 tiene el ejercicio 🔥 de migrar su slice. Si algún día se adopta, hay que tocar las Fases 5 a 11 y toda la suite de la 12 a la vez: es un proyecto, no un ticket. Destino: decisión de proyecto.
- **El `Store<any>` de diez componentes** (§9.3) no se puede tipar bien sin decidir antes cómo se representa un slice lazy ausente. Esa decisión —claves opcionales y comprobación de `undefined` en cada selector— es la que haría desaparecer el primero de los tres errores silenciosos de la §10. Destino: decisión de proyecto, con nota en la **Fase 1**.
- 🪦 **Cerrados al escribir este apéndice.** Cuatro fases delegaban material a A06 que ya estaba escrito en la propia fase: las máquinas de estado a mano vs librería dedicada (**Fase 7 §4**), el fix de zona horaria (**Fase 8 §5.3 y §6**), la decisión sobre las tres copias de los mapas de transición (**Fase 9 §5.4** y su ejercicio 26) y el operador `withLatestFrom` (**Apéndice A05 §8.2**). Las cuatro notas quedaron corregidas en sus fases.
