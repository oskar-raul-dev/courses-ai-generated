# 📊 Fase 10 — Dashboard

> Tutorial Angular 8 — Laboratorio clínico · Fase 10 de 14 · **8 horas**
> Depende de: Fase 5 (pacientes) · Fase 6 (órdenes) · Fase 7 (muestras y custodia) · Fase 8 (resultados y rangos)
> Habilita: Fase 11 (trazabilidad) · Fase 12 (testing y coverage)
> Apéndices de apoyo: [A05 (RxJS de supervivencia)](./a05-rxjs.md) · [A06 (NgRx 8)](./a06-ngrx.md) · [A07 (i18n en Angular 8)](./a07-i18n.md) · [A02 (Bootstrap 4 + Sass)](./a02-bootstrap-sass.md) · [A04 (Webpack oculto)](./a04-webpack-oculto.md) · [Incidentes asociados](./cuaderno-incidentes.md): 16

> 🧭 **Las tres versiones de gráficos, fijadas — y sus fechas cuentan la historia.**
> El dashboard corre sobre **`ng2-charts` 2.4.3** (julio de 2021, la última de la
> línea 2) con **`chart.js` 2.9.4**, y arrastra **`@swimlane/ngx-charts` 12.1.0**
> (noviembre de 2019, la última de su línea 12) por un solo gráfico heredado. Fíjate
> en el hueco de año y medio entre las dos: ng2-charts se actualizó, ngx-charts se
> quedó donde estaba el día que alguien la instaló. Eso no es un dato de trivia, es
> la deuda 💸 de §5.6 escrita en el `package.json`.
>
> Las tres declaran Angular 8 en sus *peers* y la API que usa el código de §5.1 es la
> de esas líneas: `ChartsModule` y la directiva `baseChart`, sin `provideCharts` ni
> standalone. La primera versión de ngx-charts que deja fuera a Angular 8 es la
> **14.0.0**, que pide `~9.1.1`; si ves un ejemplo con esa API, estás cuatro mayores
> por delante.

---

## 🎯 1. Propósito

La Fase 8 te dejó el sistema capaz de *decidir*: un resultado se compara contra el rango vigente y sale dentro, fuera, crítico o sin rango. Pero ese veredicto vivía de a uno, en la pantalla de una muestra. El dashboard es la primera vista que mira **todo a la vez**: cuántas órdenes hay en cada estado, cuántas muestras esperan proceso, cuántos resultados salieron fuera de rango esta semana, cuántas órdenes se vencieron sin entregarse. Es la pantalla que abre el coordinador del laboratorio a primera hora para saber dónde está el atasco.

Y es, sobre todo, **la pantalla que se pone lenta**. A ti, que vas a *mantener* esto, el dashboard te importa por una razón concreta: es donde los problemas de performance del frontend se vuelven visibles y donde vas a recibir el ticket *"el dashboard tarda tres segundos en abrir y el ventilador del portátil se enciende"*. Detrás de ese ticket casi nunca hay un servidor lento: hay un selector que se recomputa de más, un método llamado desde el template que se reevalúa en cada tecla, y suscripciones que nadie cerró y que siguen vivas después de que el usuario se fue a otra pantalla. Esta fase te enseña a reconocer esas tres firmas —recomputación, re-render y suscripción huérfana— antes de tocar una línea de código, porque el dashboard es exactamente el lugar donde conviven las tres.

Hay una segunda razón, de continuidad directa con la Fase 8. Ahí dejamos marcado que `verdictFor`, el método que calcula el veredicto de un resultado, se llama desde el template y se reevalúa en cada ciclo de detección de cambios. Con las pocas filas de una muestra era gratis. En el dashboard, con muchos resultados y gráficos redibujándose, deja de ser gratis. Esta fase es donde ese cheque se cobra, y donde por fin se muestran las salidas que la Fase 8 prometió y no implementó: mover el cálculo a un selector memoizado, usar `OnPush`, o envolver el veredicto en un pipe puro.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Navegas a `/dashboard` (módulo con carga diferida) y ves cuatro KPIs numéricos —órdenes por estado, muestras por estado de custodia, resultados fuera de rango del periodo, órdenes vencidas— y al menos dos gráficos que los representan.
- [ ] Los cuatro KPIs salen de **selectores memoizados que cruzan varios slices** (`orders`, `samples`, `results`) compuestos con `createSelector`, no de recorrer arrays a mano dentro del componente. En Redux DevTools no aparece ninguna acción nueva al abrir el dashboard: es puro lector, no despacha nada propio.
- [ ] El dashboard **no tiene slice de NgRx propio**: `StoreModule.forFeature` no aparece en `dashboard.module.ts`. Si abres el dashboard antes de haber visitado `/orders` o `/samples`, los KPIs de esos slices muestran `0` y no revientan con `undefined` (la guarda heredada de la Fase 5).
- [ ] Con `console.count` dentro de un selector y dentro de un método de template, puedes **medir** cuántas veces se recomputa cada uno al interactuar con la página, y explicar por qué.
- [ ] El `DashboardComponent` gordo se suscribe a sus selectores con `.subscribe()` a pelo y **sin `ngOnDestroy`** (deuda 💸 declarada): al navegar fuera y volver varias veces, las suscripciones se acumulan y lo confirmas en el Performance/Memory panel. Al lado tienes el patrón correcto (`takeUntil(this.destroy$)`) escrito, para contrastar.
- [ ] Los títulos, etiquetas de estado y leyendas del dashboard salen de i18n (`dashboard.title`, `dashboard.ordersByStatus`, `orders.status.*`, `samples.status.*`), sin una sola cadena escrita a mano en la plantilla.

---

## 🚫 3. Qué NO entra todavía

- Las **agregaciones server-side** —que el backend devuelva los conteos ya calculados en `/dashboard/summary` en vez de que el cliente sume sobre el store— → **fuera de alcance del curso**. Acá todo el cálculo es en cliente, sobre lo que ya está en el store, que es como lo hace LabCore. El endpoint de resumen queda como ejercicio 🔥.
- El **BI real** —drill-down, filtros por rango de fechas arbitrario, export a Excel, comparativas UAT vs PROD sobre datos históricos— → **fuera de alcance**. El dashboard de esta fase es operativo y del momento, no analítico.
- El **cruce contra rangos de referencia dentro del dashboard** para recalcular fuera-de-rango de resultados aún `preliminary` → **no acá**. El KPI de fuera-de-rango de esta fase se calcula solo sobre resultados **ya validados**, usando el veredicto congelado en su `rangeVersionApplied` (Fase 8 §5.6). Recalcular veredictos de preliminares en el dashboard reabriría toda la deuda de zona horaria de la Fase 8 en una pantalla que no es su lugar. Ver la nota de continuidad en §5.3.
- La **actualización en tiempo real** (WebSocket, polling que refresca los KPIs solos) → se difiere; encaja con el inyector de caos de la Fase 4 como fuente de eventos, o con la Fase 11. Anotado en pendientes.
- La **resolución definitiva de la deuda de `verdictFor`** en la pantalla de resultados de la Fase 8 → acá se **muestran** las tres salidas (selector memoizado, `OnPush`, pipe puro) aplicadas al dashboard, pero la Fase 8 no se reescribe. El backport queda como pendiente sugerido hacia esa fase.

---

## 🧠 4. Concepto mínimo

### El problema antes que la herramienta

Un dashboard es, en el fondo, una vista de solo lectura sobre datos que ya existen en otro lado. Nadie crea una orden desde el dashboard; el dashboard *cuenta* las órdenes que otras pantallas ya crearon. Esa es la primera decisión de diseño de la fase, y define todo lo demás: **el dashboard no tiene estado propio, lo lee del estado que ya vive en el store**. No hay un slice `dashboard`, no hay acciones de dashboard, no hay effects de dashboard. Hay selectores que leen `orders`, `samples` y `results` y los combinan en números.

Y acá aparece el primer problema real. Sumar sobre un array es barato una vez. Pero un componente de Angular no lee el store una vez: lo lee cada vez que el store emite. Si tu KPI de "órdenes vencidas" se calcula recorriendo el array de órdenes, y ese cálculo corre cada vez que *cualquier* slice cambia —aunque haya cambiado una muestra que no tiene nada que ver—, estás pagando un recorrido completo por cada latido del sistema. Con veinte órdenes no se nota. Con la carga de un turno completo y cuatro KPIs recalculándose en cascada, sí.

La herramienta que resuelve esto ya la conoces a medias. En la Fase 5 usaste `createSelector` para `selectFilteredPatients`, y en la Fase 7 para `selectSamplesByStatus`. Lo que quizá no viste entonces es *por qué* `createSelector` no es solo azúcar sintáctico: es **memoización**. Un selector construido con `createSelector` recuerda sus últimas entradas y su última salida, y si las entradas no cambiaron, devuelve la salida cacheada sin recalcular. La consecuencia práctica es enorme en un dashboard: si el KPI de órdenes depende solo del slice `orders`, un cambio en `samples` **no** dispara su recálculo. El selector ve que su entrada (`orders`) es la misma referencia de antes y devuelve el número que ya tenía.

Esto solo funciona si respetas la regla que hace posible la memoización: **los reducers devuelven referencias nuevas solo cuando algo cambió de verdad**. Es la misma inmutabilidad que vienes escribiendo desde la Fase 1 con el spread (`{ ...state, items: action.results }`). Si un reducer devolviera el mismo array mutado en lugar de uno nuevo, la memoización de arriba se rompería en silencio, y si devolviera un array nuevo en cada acción aunque el contenido fuera idéntico, recalcularías de más. La memoización de selectores es la recompensa de haber sido disciplinado con la inmutabilidad; también es donde se paga la factura si no lo fuiste.

### La segunda firma: el re-render, y la deuda que viene de la Fase 8

Memoizar el selector arregla el *cálculo*. No arregla el *dibujo*. Un gráfico de Chart.js se redibuja cuando su `@Input` de datos cambia de referencia. Si tu componente arma el objeto de datos del gráfico dentro de un getter o de un método llamado desde el template, ese objeto es nuevo en cada ciclo de detección de cambios —referencia nueva, aunque los números sean idénticos—, y el gráfico se redibuja sin razón, animación incluida. Multiplica eso por dos o tres gráficos y tienes el ventilador encendido.

Esta es exactamente la deuda que la Fase 8 dejó marcada. Ahí, `verdictFor` se llamaba desde el template y se reevaluaba en cada ciclo; era barato porque eran pocas filas. El dashboard es donde el mismo patrón deja de ser barato. Y la lección transferible no es "los métodos en template son malos" —LabCore está lleno de ellos y los vas a mantener—, sino **saber medir cuántas veces corre algo y decidir si eso importa en esta pantalla**. En la de resultados no importaba. En el dashboard sí.

### La tercera firma: la suscripción huérfana

Un componente que hace `this.store.select(...).subscribe(...)` en `ngOnInit` abre un canal que sigue abierto hasta que alguien lo cierra. Si el componente se destruye —el usuario navega a otra pantalla— pero nunca se llamó a `unsubscribe`, ese canal queda vivo: el callback sigue ejecutándose cada vez que el store emite, sobre un componente que ya no está en pantalla. Es un *memory leak*, y en un dashboard al que se entra y se sale muchas veces por turno, se acumula.

Este no es un patrón nuevo del dashboard: es el mismo que el `PatientListComponent` de la Fase 5 ya traía —sus `.subscribe()` sin cerrar y su array plano en vez de `MatTableDataSource` con `disconnect()`— y que aquella fase dejó anotado como pendiente [E] para resolver justo acá. El dashboard es donde ese ciclo de vida deja de ser una nota al margen y se vuelve el tema central, porque es donde el leak se nota.

### Si vienes de backend

La memoización de selectores es primo directo de una vista materializada o de un método cacheado con la última entrada: no recalculas si los argumentos no cambiaron. La analogía es limpia y se rompe en un punto importante: acá la "clave de caché" es la **identidad de referencia** del objeto de entrada, no su valor. Dos arrays con el mismo contenido pero distinta referencia son, para `createSelector`, entradas distintas, y disparan recálculo. En el backend comparas valores; acá comparas punteros. Esa diferencia es la que hace que la inmutabilidad de los reducers no sea una cortesía estética sino la condición para que la memoización funcione.

La suscripción huérfana, por su lado, es el equivalente frontend de un connection leak: abriste algo que consume recursos y no lo cerraste, y el proceso no se muere pero se degrada. La diferencia es que acá no hay un pool que te avise con un timeout; el leak crece callado hasta que el navegador se arrastra.

### Nota de época

Angular 8 y RxJS 6.5 no traen nada que cierre las suscripciones por ti en un componente. El patrón de la época —el que vas a encontrar en LabCore cuando *sí* se acordaron de cerrar— es `takeUntil(this.destroy$)` con un `Subject` que emite en `ngOnDestroy`. Hoy existen alternativas (el operador `takeUntilDestroyed`, la API de `signals`, el `async` pipe que gestiona la suscripción solo), pero ninguna estaba disponible o madura en 2019, y el equipo eligió `.subscribe()` a pelo en muchos componentes porque "funcionaba". Funcionaba hasta que el dashboard empezó a arrastrarse. Ese es el patrón que mantienes.

---

## 💻 5. Código mínimo con comentarios

El dashboard reusa todo el molde de estado que ya existe: no define acciones, ni reducer, ni effects. Lo genuinamente nuevo de esta fase es **el módulo lector sin slice** (§5.1), **los selectores memoizados que cruzan slices** (§5.2), **el componente gordo con su deuda de suscripciones** (§5.3 y §5.4), **el integrado de gráficos** (§5.5 y §5.6) y **las tres salidas de performance** (§5.7), que es donde se cierra el bucle abierto en la Fase 8.

Los feature keys que el dashboard lee ya están fijados: `'orders'` (Fase 6), `'samples'` (Fase 7) y `'results'` (Fase 8). Ningún nombre nuevo de estado se inventa acá.

### 5.1 `dashboard.module.ts` — un módulo lazy que no tiene estado

El dashboard es un módulo con carga diferida, igual que `OrdersModule` o `SamplesModule`, con una diferencia que es la decisión central de la fase: **no registra ningún slice**. No hay `StoreModule.forFeature`, no hay `EffectsModule.forFeature`. Solo importa lo que necesita para leer y para dibujar.

```typescript
// src/app/dashboard/dashboard.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';

// El motor vivo de gráficos: ng2-charts (línea 2.x) sobre Chart.js 2.9.4.
// ChartsModule expone la directiva baseChart que usa la plantilla (5.6).
import { ChartsModule } from 'ng2-charts';

// 💸 DEUDA INTENCIONAL: ngx-charts sigue importado por un solo gráfico heredado
// (5.6). Arrastra d3 al bundle del dashboard. Lo correcto sería unificar en una
// sola librería de gráficos y sacar la otra del package.json y de este import,
// bajando el peso del bundle. Por qué en Track A NO se paga: así está el sistema
// real -dos motores de render conviviendo porque nadie se ánimo a migrar el
// gráfico viejo-, y el peso muerto que produce es justo lo que el estudiante
// tiene que aprender a detectar en el bundle (forense de esta fase, ejercicio 28).
import { NgxChartsModule } from '@swimlane/ngx-charts';

import { DashboardComponent } from './dashboard.component';

// El dashboard es su propia raíz de ruta. Lazy: el slice de gráficos y d3 no
// entran al bundle inicial, solo cuando alguien navega a /dashboard.
const routes: Routes = [
  { path: '', component: DashboardComponent }
];

@NgModule({
  declarations: [
    DashboardComponent
  ],
  imports: [
    CommonModule,
    RouterModule.forChild(routes),
    TranslateModule,
    ChartsModule,
    NgxChartsModule
    // NO va StoreModule.forFeature: el dashboard no tiene slice. Lee los slices
    // que ya registraron OrdersModule, SamplesModule y ResultsModule. Si ninguno
    // se cargó todavía, sus selectores devuelven undefined y la guarda de 5.2 lo
    // convierte en 0. Ver la nota de continuidad con la Fase 5.
  ]
})
export class DashboardModule { }
```

**Detalles con intención**

- El dashboard **no declara estado** porque no lo tiene. Todo lo que muestra ya vive en otros slices. Registrar un slice `dashboard` sería duplicar datos y crear un segundo lugar donde desincronizarse. La regla que fija esta fase y heredan las siguientes: **una pantalla de solo lectura compone selectores, no crea estado.**
- Las dos librerías de gráficos se importan juntas a propósito, para que el peso muerto de la que casi no se usa (`NgxChartsModule` + d3) sea **visible en el bundle** y sirva de material forense. No es un descuido del ejemplo: es LabCore.
- Al ser lazy, el costo de los dos motores de gráficos y de d3 no se paga en el arranque de la app, solo al entrar al dashboard. Eso es correcto y es también lo que hace que el ticket sea "el *dashboard* tarda", no "la app tarda en arrancar".

### 5.2 `dashboard.selectors.ts` — los selectores memoizados que cruzan slices

Este es el archivo nuevo más importante de la fase. Cada KPI es un `createSelector` que arranca de los `createFeatureSelector` que ya definieron las fases anteriores y los combina en un número. La memoización es la que hace que un cambio en un slice no dispare el recálculo de un KPI que no depende de él.

```typescript
// src/app/dashboard/dashboard.selectors.ts
import { createFeatureSelector, createSelector } from '@ngrx/store';

// Se leen los slices YA registrados por las otras fases. El dashboard no crea
// ninguno: solo apunta a los feature keys existentes. Si el slice no se cargó
// todavía (módulo lazy no visitado), el feature selector devuelve undefined.
const selectOrdersState = createFeatureSelector<any>('orders');
const selectSamplesState = createFeatureSelector<any>('samples');
const selectResultsState = createFeatureSelector<any>('results');

// Extractores de la lista de cada slice, con guarda de undefined. La guarda es
// la misma lección de la Fase 5: un slice lazy no visitado NO es un array vacío,
// es undefined, y sumar sobre undefined revienta. Devolver [] en ese caso hace
// que el KPI muestre 0 en vez de romper la pantalla entera.
const selectOrdersList = createSelector(
  selectOrdersState,
  function (state: any) { return state && state.items ? state.items : []; }
);

const selectSamplesList = createSelector(
  selectSamplesState,
  function (state: any) { return state && state.items ? state.items : []; }
);

const selectResultsList = createSelector(
  selectResultsState,
  function (state: any) { return state && state.items ? state.items : []; }
);

// KPI 1: órdenes por estado. Depende SOLO de orders. Un cambio en samples o
// results no lo recomputa: la memoización ve que selectOrdersList devolvió la
// misma referencia y no vuelve a contar. Esa es la ganancia central del
// dashboard, y la razón por la que estos conteos no van en el componente.
export const selectOrdersByStatusCount = createSelector(
  selectOrdersList,
  function (orders: any[]) {
    // Se cuenta por estado con un acumulador plano. Los estados son los de la
    // Fase 5: pending, in_process, partial_results, complete, delivered, expired.
    var counts: any = {};
    for (var i = 0; i < orders.length; i++) {
      var status = orders[i].status;
      counts[status] = (counts[status] || 0) + 1;
    }
    return counts;
  }
);

// KPI 2: muestras por estado de custodia. Depende SOLO de samples. Estados de la
// Fase 7: scheduled, collected, received, in_process, processed, discarded.
export const selectSamplesByStatusCount = createSelector(
  selectSamplesList,
  function (samples: any[]) {
    var counts: any = {};
    for (var i = 0; i < samples.length; i++) {
      var status = samples[i].status;
      counts[status] = (counts[status] || 0) + 1;
    }
    return counts;
  }
);

// KPI 3: resultados fuera de rango del periodo. Depende SOLO de results, y SOLO
// mira los ya validados: su veredicto quedó congelado al validar (Fase 8 §5.6)
// vía rangeVersionApplied, así que el dashboard NO recalcula nada temporal acá.
// Recalcular veredictos de preliminares reabriría toda la deuda de zona horaria
// de la Fase 8 en la pantalla equivocada. Ver la nota de continuidad de abajo.
//
// El campo outOfRange existe porque la validación de la Fase 8 (§5.6) lo estampa
// en el mismo patch que rangeVersionApplied. Ese es el contrato del que vive este
// KPI: mientras un resultado es preliminary su veredicto es derivado y no se
// guarda; en el instante de validar se congela. Por eso acá se lee un booleano en
// vez de recalcular contra los rangos, y por eso el dashboard no necesita tocar
// referenceRanges. Si alguien "limpiara" ese campo del patch por parecerle
// redundante, este número se iria a cero en silencio y nadie lo notaria hasta una
// auditoria: es el ejercicio 29.
export const selectOutOfRangeCount = createSelector(
  selectResultsList,
  function (results: any[]) {
    var count = 0;
    for (var i = 0; i < results.length; i++) {
      var r = results[i];
      if (r.status === 'validated' && r.outOfRange === true) {
        count++;
      }
    }
    return count;
  }
);

// KPI 4: órdenes vencidas. Depende SOLO de orders. Una orden vencida es la que
// está en estado expired (la máquina de estados de la Fase 5 ya lo modela); no
// se recalcula vencimiento por fecha acá, se cuenta el estado. Contar por fecha
// sería meter comparación temporal en el dashboard: no es su trabajo.
export const selectExpiredOrdersCount = createSelector(
  selectOrdersList,
  function (orders: any[]) {
    var count = 0;
    for (var i = 0; i < orders.length; i++) {
      if (orders[i].status === 'expired') { count++; }
    }
    return count;
  }
);
```

**Detalles con intención**

- Cada KPI depende de **un solo slice**. Eso es deliberado: mantiene la memoización efectiva (un cambio en `samples` no toca los KPIs de `orders`) y mantiene cada selector legible. Un KPI que de verdad necesite cruzar dos slices —"muestras procesadas cuya orden sigue pendiente"— existe y es el ejercicio 24; se escribe combinando dos listas en un `createSelector` de dos entradas, y ahí se ve el costo real del cruce.
- La guarda `state && state.items ? state.items : []` **no es paranoia**: es la consecuencia directa de que `orders` y `samples` son módulos lazy. Si abres el dashboard como primera pantalla de la sesión, esos slices no existen todavía. Sin la guarda, el KPI revienta con *"cannot read property length of undefined"* y se lleva la pantalla entera por delante. Con la guarda, muestra `0`, que es la verdad: no hay datos cargados.
- Los conteos viven en **selectores, no en el componente**. Si el componente hiciera el `for` adentro de un método llamado desde el template, ese conteo correría en cada ciclo de detección de cambios en vez de solo cuando el slice cambia. Mover el conteo al selector es la mitad de la solución de performance; la otra mitad es el re-render de los gráficos (§5.7).

> **📝 Nota de continuidad con la Fase 8.** El KPI de fuera-de-rango de §5.2 cuenta solo resultados **validados** y se apoya en su veredicto ya congelado, **no** vuelve a seleccionar el rango vigente ni compara fechas. Esto es a propósito: la selección de rango por vigencia (`selectActiveRange`) arrastra la deuda de zona horaria de la Fase 8 (§5.3 de esa fase), y meterla en el dashboard la esparciría a una pantalla más. Escribir esta fase, además, destapó un hueco en la Fase 8: su componente leía `state.results.referenceRanges`, un campo que el `ResultsState` no declaraba y que ninguna acción cargaba. Se corrigió allá con una edición retroactiva —el circuito completo de `loadReferenceRanges*`, documentado en la *Nota de continuidad* de la Fase 8 §5.4—, así que hoy la Fase 8 es consistente. El dashboard igual **esquiva el tema** al no tocar `referenceRanges` en absoluto, y esa decisión no cambia.

### 5.3 `dashboard.component.ts` — el componente gordo y la deuda 💸 de las suscripciones

El componente sigue el molde gordo de siempre: se suscribe a los selectores, guarda los resultados en propiedades, arma los datos de los gráficos. Toda la lógica adentro, como LabCore. Y acá vive la deuda central de la fase: **`.subscribe()` a pelo sin `ngOnDestroy`**.

```typescript
// src/app/dashboard/dashboard.component.ts
import { Component, OnInit } from '@angular/core';
import { Store } from '@ngrx/store';

import {
  selectOrdersByStatusCount,
  selectSamplesByStatusCount,
  selectOutOfRangeCount,
  selectExpiredOrdersCount
} from './dashboard.selectors';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html'
  // 💸 Sin changeDetection: OnPush a propósito. El componente corre con la
  // detección por defecto (Default), que reevalúa el template en cada ciclo de
  // toda la app. Es el modo de LabCore, y es una de las tres firmas de
  // lentitud de la fase. El fix (OnPush) se muestra en 5.7, no se aplica acá.
})
export class DashboardComponent implements OnInit {

  ordersByStatus: any = {};
  samplesByStatus: any = {};
  outOfRangeCount = 0;
  expiredOrdersCount = 0;

  constructor(private store: Store<any>) { }

  ngOnInit() {
    // 💸 DEUDA INTENCIONAL: cuatro .subscribe() a pelo, ninguno se cierra. No hay
    // ngOnDestroy, no hay takeUntil, no hay async pipe. Cada vez que el usuario
    // entra al dashboard se abren cuatro canales nuevos; cada vez que se va, esos
    // canales siguen vivos porque nadie los cierra. Entrar y salir del dashboard
    // diez veces en un turno deja cuarenta suscripciones ejecutando callbacks
    // sobre componentes que ya no están en pantalla. Es un memory leak.
    //
    //   Lo correcto hoy: gestionar el ciclo de vida. Tres formas, en orden de
    //   preferencia para este stack (RxJS 6.5, Angular 8): el async pipe en el
    //   template (que suscribe y desuscribe solo), o takeUntil(this.destroy$)
    //   con un Subject que emite en ngOnDestroy (5.7), o guardar cada
    //   Subscription y desuscribir una por una en ngOnDestroy.
    //
    //   Por qué en Track A NO se paga: LabCore está lleno de este patrón
    //   -.subscribe() a pelo sin cerrar- y el leak que produce es precisamente lo
    //   que el estudiante tiene que aprender a ver en el Performance/Memory panel
    //   (forense de esta fase, incidente 16). Arreglarlo acá borraría el
    //   ejercicio. El patrón correcto se muestra al lado en 5.7 para contrastar.
    this.store.select(selectOrdersByStatusCount)
      .subscribe(function (this: DashboardComponent, counts: any) {
        this.ordersByStatus = counts;
      }.bind(this));

    this.store.select(selectSamplesByStatusCount)
      .subscribe(function (this: DashboardComponent, counts: any) {
        this.samplesByStatus = counts;
      }.bind(this));

    this.store.select(selectOutOfRangeCount)
      .subscribe(function (this: DashboardComponent, count: number) {
        this.outOfRangeCount = count;
      }.bind(this));

    this.store.select(selectExpiredOrdersCount)
      .subscribe(function (this: DashboardComponent, count: number) {
        this.expiredOrdersCount = count;
      }.bind(this));
  }

  // Arma los datos del gráfico de órdenes por estado. 💸 OJO: este método NO se
  // llama desde el template todavía. Se deja como método para 5.7, donde se
  // muestra la diferencia entre llamarlo desde el template (referencia nueva en
  // cada ciclo, gráfico redibujado) y precalcularlo. El orden de los estados es
  // el de la Fase 5.
  buildOrdersChartData(): number[] {
    var order = ['pending', 'in_process', 'partial_results', 'complete', 'delivered', 'expired'];
    var data: number[] = [];
    for (var i = 0; i < order.length; i++) {
      data.push(this.ordersByStatus[order[i]] || 0);
    }
    return data;
  }
}
```

**Detalles con intención**

- Las cuatro suscripciones sin cerrar son **la deuda declarada de la fase**. No es un olvido: es el patrón de LabCore, y el leak que produce es el objeto de estudio del forense y del incidente 16. Se declara qué sería lo correcto (async pipe, `takeUntil`, o `Subscription` guardada) y por qué no se paga en Track A.
- `changeDetection` se deja en `Default` a propósito, comentado. Es la segunda firma de lentitud. `OnPush` aparece en §5.7 como una de las salidas, no acá.
- `buildOrdersChartData` se deja como método pero **no** se llama desde el template en §5.4. Esa es una decisión de andamio: primero se muestra la forma correcta (datos precalculados en una propiedad), y en §5.7 se contrasta contra la forma que causa re-render (método en template), para que la diferencia sea visible y medible, no dada por sentada.

### 5.4 `dashboard.component.html` — KPIs y gráficos, todo vía i18n

La plantilla muestra los cuatro KPIs numéricos y engancha los gráficos. Cero cadenas a mano: títulos y etiquetas de estado salen de i18n, reusando las claves que ya definieron las Fases 5, 7 y 8.

```html
<!-- src/app/dashboard/dashboard.component.html -->
<h1>{{ 'dashboard.title' | translate }}</h1>

<section class="kpi-grid">
  <!-- KPI numérico: órdenes vencidas. El número sale de la propiedad, ya
       calculada por el selector memoizado. La etiqueta, de i18n. -->
  <div class="kpi-card kpi-danger">
    <span class="kpi-number">{{ expiredOrdersCount }}</span>
    <span class="kpi-label">{{ 'dashboard.expiredOrders' | translate }}</span>
  </div>

  <div class="kpi-card">
    <span class="kpi-number">{{ outOfRangeCount }}</span>
    <span class="kpi-label">{{ 'dashboard.outOfRangeResults' | translate }}</span>
  </div>
</section>

<!-- Gráfico de órdenes por estado con ng2-charts. La directiva baseChart de la
     línea 2.x recibe [datasets] o [data], [labels], [chartType]. Los datos salen
     de propiedades precalculadas (ordersChartData/ordersChartLabels, armadas en
     5.7), NO de un método llamado acá: un método devolvería una referencia nueva
     en cada ciclo y el gráfico se redibujaría sin razón. Ver 5.7. -->
<div class="chart-panel">
  <h2>{{ 'dashboard.ordersByStatus' | translate }}</h2>
  <canvas baseChart
          [data]="ordersChartData"
          [labels]="ordersChartLabels"
          [chartType]="'bar'">
  </canvas>
</div>
```

**Detalles con intención**

- Los gráficos se alimentan de **propiedades precalculadas**, no de métodos. Un `[data]="buildOrdersChartData()"` en el template devolvería un array nuevo en cada detección de cambios —referencia nueva, aunque los números sean idénticos— y Chart.js lo interpretaría como "los datos cambiaron", redibujando con animación cada vez. Esa es la trampa de re-render de la fase, y es la misma naturaleza del `verdictFor` de la Fase 8. La forma correcta —propiedad precalculada— se construye en §5.7.
- Las etiquetas de estado que un gráfico más detallado necesitaría (`orders.status.pending`, etc.) salen del mismo diccionario i18n que la Fase 6 ya definió. El dashboard **no inventa claves de estado nuevas**; reusa las que existen. La doble grafía `in_process` (dato) vs `inProcess` (clave) sigue siendo la deuda de i18n de la Fase 2, anotada en pendientes.

### 5.5 El seed y el mock: nada nuevo

El dashboard no necesita datos nuevos: cuenta lo que las Fases 5, 7 y 8 ya siembran. `npm run seed` genera pacientes, órdenes, muestras, resultados y rangos como hasta ahora; `npm run mock` los sirve. La única condición para que los KPIs muestren números interesantes es haber navegado antes a `/orders` y `/samples` al menos una vez en la sesión, para que esos slices lazy estén cargados. Si no, el dashboard muestra `0` honestamente (§5.2). Esa dependencia de orden de navegación es, ella misma, material de diagnóstico: el ejercicio 15 la explota.

### 5.6 Los dos motores de gráficos conviviendo — la deuda 💸 de ngx-charts

En §5.1 se importaron dos librerías. ng2-charts dibuja los gráficos vivos del dashboard con la directiva `baseChart` sobre un `<canvas>`. ngx-charts sigue ahí por un solo gráfico heredado —pongamos, un `advanced-pie-chart` que alguien puso en 2019 y que nadie migró— que se dibuja como componente Angular sobre SVG, con su propia sintaxis:

```html
<!-- Fragmento heredado que sigue vivo por inercia. 💸 Es el único consumidor de
     NgxChartsModule y de d3 en toda la app. Dos motores de render para lo mismo:
     ng2-charts sobre canvas, ngx-charts sobre SVG. -->
<ngx-charts-advanced-pie-chart
  [results]="samplesPieData"
  [scheme]="colorScheme">
</ngx-charts-advanced-pie-chart>
```

**Detalles con intención**

- Que convivan dos librerías de gráficos **no es un buen diseño y no se presenta como tal**. Es fidelidad a LabCore: en un legacy de años es normal encontrar dos formas de hacer lo mismo, una nueva y una que quedó. La deuda 💸 se declara en §5.1: lo correcto sería unificar en una y sacar la otra del bundle. En Track A no se paga; se aprende a **verla en el bundle** (§6, ejercicio 28).
- ngx-charts arrastra **d3** como dependencia. Ese d3 pesa y viaja en el chunk lazy del dashboard aunque solo un gráfico lo use. Medir cuánto pesa ese peso muerto es parte del forense de la fase.
- Los dos motores tienen **modelos de datos distintos** (`[data]`/`[labels]` en ng2-charts, `[results]` con objetos `{name, value}` en ngx-charts) y **modos de render distintos** (canvas vs SVG). Mantener las dos formas en la cabeza a la vez es exactamente el costo cognitivo que la deuda impone a quien mantiene esto.

### 5.7 Las tres salidas de performance — cerrando el bucle de la Fase 8

Acá se muestran, aplicadas al dashboard, las tres salidas que la Fase 8 prometió y no implementó (su ejercicio 22 y su pendiente [E]). **No se reescribe la Fase 8**; se demuestra en el dashboard cómo se resuelve cada firma, y se deja el backport a la Fase 8 como pendiente sugerido.

**Salida 1 — Precalcular los datos del gráfico en una propiedad (mata el re-render).** En vez de `[data]="buildOrdersChartData()"` en el template, se calcula una vez cuando el KPI cambia y se guarda en una propiedad. El gráfico solo ve una referencia nueva cuando los datos cambiaron de verdad.

```typescript
// Dentro de DashboardComponent. En vez de un método en template, se recalcula la
// propiedad SOLO cuando llega un valor nuevo del selector. La referencia de
// ordersChartData cambia únicamente cuando cambio el conteo: el gráfico se
// redibuja cuando corresponde, no en cada ciclo.
ordersChartData: number[] = [];
ordersChartLabels: string[] = ['pending', 'in_process', 'partial_results', 'complete', 'delivered', 'expired'];

// En el subscribe de ordersByStatus (5.3), tras asignar el conteo:
//   this.ordersByStatus = counts;
//   this.ordersChartData = this.buildOrdersChartData(); // referencia nueva solo acá
```

**Salida 2 — `OnPush` (recorta los ciclos de detección).** Con `changeDetection: ChangeDetectionStrategy.OnPush`, el componente solo revisa su template cuando cambia un `@Input`, cuando emite un observable enganchado con `async`, o cuando se dispara un evento propio. Deja de reevaluarse en cada latido de la app. En un dashboard que solo lee, encaja bien, **a condición de** alimentar la vista con el `async` pipe en lugar de asignar en un `.subscribe()` manual.

**Salida 3 — Pipe puro para el veredicto (el fix directo del `verdictFor` de la Fase 8).** Un pipe puro se recalcula solo cuando su entrada cambia de referencia; llamado desde el template, memoiza por argumento. Es la salida más limpia para el `verdictFor` de la Fase 8: convertirlo en un `VerdictPipe` puro que reciba `result` y `ranges` y devuelva el veredicto. El template pasa de `verdictFor(result)` a `result | verdict:ranges:sample.collectedAt`, y deja de recalcularse en cada ciclo.

```typescript
// src/app/results/verdict.pipe.ts  (la forma del fix que la Fase 8 recibiría)
import { Pipe, PipeTransform } from '@angular/core';
import { selectActiveRange, evaluateResult } from './store/reference-range.selector';

// Pipe PURO (pure: true es el default): Angular lo reevalúa solo cuando cambia la
// REFERENCIA de sus argumentos. Con result y ranges estables entre ciclos, el
// veredicto se calcula una vez y se cachea, en vez de en cada detección de
// cambios como hacía verdictFor llamado desde el template en la Fase 8.
@Pipe({ name: 'verdict' })
export class VerdictPipe implements PipeTransform {
  // Tres argumentos, y el tercero es el que la versión ingenua olvida: la fecha
  // contra la que se elige el rango vigente sale de la MUESTRA (su collectedAt),
  // no del resultado, que no tiene fecha propia hasta que se valida. Pedirsela al
  // llamante en vez de adivinarla es lo que mantiene el pipe puro: si dependiera
  // de "hoy", su salida cambiaria sin que cambien sus argumentos, y eso rompe la
  // premisa entera de un pipe puro.
  transform(result: any, ranges: any[], atDate: string): any {
    // 💸 Nota: esto mueve el cálculo, NO arregla la deuda de zona horaria de la
    // Fase 8. selectActiveRange sigue comparando fechas sin normalizar zona; el
    // pipe solo evita recalcularlo de más. La deuda temporal se paga en otro lado
    // (incidente 07), no acomodando el veredicto en un pipe.
    var range = selectActiveRange(ranges, result.analyte, atDate);
    return evaluateResult(result.value, range);
  }
}
```

**Salida contrastante — el patrón correcto de suscripción (la deuda de §5.3, mostrada, no pagada).** Así se cerraría el leak sin borrar la deuda del componente gordo: se muestra al lado para que la diferencia sea concreta.

```typescript
// Como se cerraria el leak de 5.3. NO se aplica al DashboardComponent gordo
// (esa es la deuda de Track A); se muestra para contrastar. El Subject destroy$
// emite una vez en ngOnDestroy y takeUntil corta todas las suscripciones a la vez.
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

// private destroy$ = new Subject<void>();
//
// this.store.select(selectOrdersByStatusCount)
//   .pipe(takeUntil(this.destroy$))
//   .subscribe(function (this: DashboardComponent, counts: any) {
//     this.ordersByStatus = counts;
//   }.bind(this));
//
// ngOnDestroy() {
//   this.destroy$.next();     // avisa a todos los takeUntil que cierren
//   this.destroy$.complete(); // cierra el propio Subject
// }
```

**El patrón a memorizar.** Las tres firmas de un dashboard lento tienen tres fixes distintos y no intercambiables: **recomputación** se ataca con selectores memoizados, **re-render** con datos precalculados / `OnPush` / pipes puros, y **suscripción huérfana** con gestión de ciclo de vida (`async` pipe o `takeUntil`). Confundirlas —meter `OnPush` para arreglar un leak, o cerrar suscripciones para arreglar un re-render— es el error de diagnóstico que esta fase entrena a no cometer.

> **Prueba de fuego.** Corre `npm run seed`, `npm run mock`, `npx ng serve`. Navega primero a `/orders` y `/samples` (para cargar los slices lazy), luego a `/dashboard`. Verifica los cuatro KPIs. Ahora abre la consola y mete un `console.count('ordersKPI')` dentro del cuerpo del selector `selectOrdersByStatusCount` y otro `console.count('render')` en `buildOrdersChartData`. Interactúa con otra parte de la app que cambie el slice `samples` (marca una muestra) y observa: el contador del KPI de órdenes **no** sube (memoización: `orders` no cambió), pero el de render sí subiría si `buildOrdersChartData` estuviera en el template. Por último, entra y sal del dashboard cinco veces y abre el Memory panel: sin `ngOnDestroy`, las suscripciones se acumulan. Ese crecimiento es el incidente 16.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** el dashboard revienta con *"cannot read property 'length' of undefined"* al abrirlo como primera pantalla de la sesión, pero funciona perfecto si antes pasaste por Órdenes.
**Causa:** `orders` y `samples` son módulos lazy. Sus slices no existen hasta que se visita la ruta por primera vez; hasta entonces el feature selector devuelve `undefined`, no `[]`. Es el mismo patrón que la Fase 5 (línea del `createFeatureSelector('orders')` que devuelve `undefined` desde la pantalla de pacientes).
**Fix mínimo:** la guarda `state && state.items ? state.items : []` en el selector (§5.2), que convierte el `undefined` en `0`. **Fix correcto:** además, un guard de ruta que asegure la carga de los slices necesarios antes de entrar al dashboard, o mover los reducers críticos a `forRoot`. No los confundas: el mínimo evita el crash; el correcto arregla que el dashboard dependa del orden de navegación.

**Síntoma:** los gráficos parpadean y se reanima toda la barra en cada tecla que escribes en un input de otra parte de la pantalla.
**Causa:** el `@Input` de datos del gráfico se alimenta de un método llamado desde el template, que devuelve una referencia nueva en cada ciclo de detección de cambios. Chart.js lo lee como "los datos cambiaron" y redibuja. Es la misma naturaleza del `verdictFor` de la Fase 8, ahora con costo visible.
**Fix mínimo:** precalcular los datos en una propiedad y bindear la propiedad (§5.7, salida 1). **Fix correcto:** `OnPush` + `async` pipe, para que el componente ni siquiera entre en detección de cambios por eventos ajenos.

**Síntoma:** después de un turno completo, el navegador del coordinador se arrastra; cerrar y reabrir la pestaña lo cura por un rato.
**Causa:** suscripciones huérfanas. El `DashboardComponent` abre cuatro `.subscribe()` en `ngOnInit` y no los cierra; cada entrada al dashboard suma cuatro canales vivos que nunca mueren. "Cerrar y reabrir la pestaña lo cura" es la firma clásica de un memory leak de front.
**Fix mínimo:** un `ngOnDestroy` que desuscriba (§5.7, salida contrastante). **Fix correcto:** migrar la vista al `async` pipe, que no puede olvidarse de cerrar porque lo gestiona Angular.

### Pieza forense de esta fase

Lo que se debuggea acá es el **Performance/Memory panel** del navegador: suscripciones huérfanas que se acumulan y redibujos de gráfico que no deberían ocurrir. La pieza completa vive en [`forense-fase-10.md`](./forense-fase-10.md) —cómo tomar un heap snapshot antes y después de entrar/salir del dashboard, cómo leer el crecimiento de listeners, y cómo distinguir en el Performance panel un recálculo de selector de un re-render de gráfico—. No se desarrolla entera acá.

El incidente asociado es el **16** (ver §Pendientes para el título propuesto en el índice del cuaderno).

**Rompe a propósito y observa.** Quita la guarda `state && state.items ? ... : []` de `selectOrdersByStatusCount` (§5.2), dejando `return state.items;`. Abre el dashboard como **primera** pantalla de la sesión, sin pasar por Órdenes. La pantalla se cae entera y la consola grita `undefined`. La mentira que te cuenta la pantalla: parece un problema del dashboard, cuando la causa está en que un slice lazy que el dashboard *lee* todavía no se cargó. El lugar correcto donde mirar no es el `DashboardComponent`, es el estado del store en Redux DevTools: verás que la clave `orders` sencillamente no está.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Crea la clave i18n `dashboard.title` en los tres idiomas (es/en/fr) y confirma que el título del dashboard cambia al cambiar de idioma, sin tocar la plantilla.
2. Añade un quinto KPI numérico —"muestras descartadas"— como selector memoizado sobre `samples`, contando el estado `discarded`. Sigue el molde de `selectExpiredOrdersCount`.
3. Navega a `/dashboard` sin pasar antes por `/orders`. Anota qué muestran los KPIs de órdenes y explica en una frase por qué muestran `0` y no revientan.
4. Con Redux DevTools abierto, entra al dashboard y confirma que **no** se despacha ninguna acción nueva. Explica por qué un componente de solo lectura no despacha nada.
5. Mete un `console.count('ordersKPI')` dentro de `selectOrdersByStatusCount` y cuenta cuántas veces corre al abrir el dashboard una sola vez.
6. Localiza en `dashboard.module.ts` el `import` de `NgxChartsModule` y explica en una frase por qué está marcado como deuda 💸.
7. Cambia el `chartType` del gráfico de órdenes de `'bar'` a `'doughnut'` y observa. Anota qué propiedad de datos (`[data]` vs `[datasets]`) necesita cada tipo.
8. Agrega la etiqueta i18n de un estado de orden (`orders.status.expired`) a la tarjeta de órdenes vencidas, reusando la clave que ya definió la Fase 6. No inventes una clave nueva.

**🟡 Intermedio (9–17)**

9. Escribe `selectResultsByStatusCount` memoizado, contando resultados por `status` (`preliminary`, `validated`). Úsalo en un KPI nuevo.
10. Convierte el gráfico de muestras de ng2-charts a datos precalculados en una propiedad (`samplesChartData`), armada en el `subscribe`, y confirma con `console.count` que deja de recalcularse en cada ciclo.
11. Añade `ngOnDestroy` con un `Subject destroy$` y `takeUntil` a las cuatro suscripciones del `DashboardComponent`. Confirma en el Memory panel que el leak desaparece. (Esto **paga** la deuda; hazlo en una rama aparte para conservar el ejemplo con leak.)
12. Reemplaza uno de los `.subscribe()` manuales por el `async` pipe en el template (`ordersByStatus$ | async`). Explica qué línea de `ngOnDestroy` deja de ser necesaria para esa suscripción.
13. Mide el peso del chunk lazy del dashboard con `npx ng build --stats-json` antes y después de quitar `NgxChartsModule` del módulo. Anota cuántos KB pesa d3.
14. Añade `changeDetection: OnPush` al `DashboardComponent` y observa qué KPIs dejan de actualizarse. Explica por qué, y qué necesitas cambiar (el `async` pipe) para que vuelvan a funcionar bajo `OnPush`.
15. Reproduce el bug del orden de navegación: documenta la secuencia exacta de rutas que hace que el KPI de muestras muestre `0` incorrectamente, y la que lo hace mostrar el número real.
16. El KPI de fuera-de-rango (§5.2) cuenta `r.outOfRange === true` sobre resultados validados. Abre `db.json` y comprueba dos cosas: que los resultados **sembrados** no tienen ese campo, y que los que tú validaste desde la interfaz sí. Explica en dos líneas por qué esa asimetría es correcta y no un bug del semillero.
17. Escribe el `VerdictPipe` puro de §5.7 y úsalo en la plantilla de resultados de la Fase 8 en una rama de prueba. Con `console.count`, compara cuántas veces se ejecuta contra el `verdictFor` original. Después quita el tercer argumento y haz que el pipe resuelva la fecha por su cuenta con `new Date()`: sigue compilando, sigue dando el veredicto correcto hoy, y acabas de romper la pureza. Explica en dos líneas por qué.

**🟠 Difícil (18–24)**

18. Con el Performance panel grabando, entra y sal del dashboard diez veces. Identifica en el flame chart el crecimiento de detached listeners y correlaciónalo con las cuatro suscripciones sin cerrar.
19. Toma un heap snapshot antes de entrar al dashboard y otro después de entrar/salir cinco veces. Compara el conteo de instancias de `DashboardComponent` retenidas y explica por qué no es 1.
20. Demuestra la memoización: mete `console.count` en `selectOrdersByStatusCount` y en `selectSamplesByStatusCount`, cambia **solo** una muestra (marca una como `collected`) y confirma que el contador de órdenes **no** sube pero el de muestras sí. Explica la relación con la inmutabilidad de los reducers.
21. Rompe la memoización a propósito: haz que el reducer de `orders` devuelva `{ ...state, items: [...state.items] }` en una acción que no cambia nada (un array nuevo con el mismo contenido). Observa que el KPI de órdenes ahora sí se recomputa en esa acción y explica por qué.
22. El gráfico de ngx-charts (`advanced-pie-chart`) usa el formato `{name, value}[]`; el de ng2-charts usa `number[]` + `labels`. Escribe una función pura que transforme el conteo por estado a ambos formatos y explica por qué mantener dos formatos es el costo de la deuda de §5.6.
23. Añade un guard de ruta (`CanActivate`) que despache la carga de `orders` y `samples` antes de permitir entrar al dashboard, eliminando la dependencia del orden de navegación. Explica por qué esto es el "fix correcto" del ejercicio 3 y el mínimo no.
24. Escribe `selectProcessedSamplesWithPendingOrder`: un selector de **dos entradas** que cruza `samples` (procesadas) y `orders` (aún `pending`). Mide con `console.count` cuántas veces se recomputa al cambiar cada slice y explica por qué un selector cruzado es más caro de mantener que uno de un solo slice.

**🔴 Muy difícil (25–30)**

25. Te dan un dashboard que tarda 4 segundos en cargar. Sin ver el código primero, usa solo el Performance panel para decidir cuál de las tres firmas (recomputación, re-render, leak) domina. Documenta cómo lo dedujiste antes de abrir un solo archivo.
26. Un usuario reporta que "los números del dashboard están viejos, no reflejan la orden que acabo de crear". Reproduce: crea una orden desde `/orders` con el dashboard abierto en otra pestaña. Localiza si el problema es de suscripción, de memoización rota, o de que el slice no emitió. (Pista: revisa si el dashboard estaba montado cuando se creó la orden.)
27. Combina las tres salidas de §5.7 en el `DashboardComponent`: selectores memoizados (ya están), `OnPush` + `async` pipe (mata leak y recorta ciclos), y datos de gráfico precalculados vía `async`. Mide el antes/después en el Performance panel y reporta la mejora en ms.
28. **Forense de bundle.** Con `webpack-bundle-analyzer` sobre el build, localiza el chunk lazy del dashboard, identifica qué porción es d3 (traída por ngx-charts) y qué porción es Chart.js (traída por ng2-charts). Argumenta cuál de las dos librerías sacarías y qué gráfico habría que reescribir para lograrlo (la deuda de §5.6).
29. El KPI de fuera-de-rango depende de que el veredicto se haya congelado al validar (Fase 8). Reconstruye la cadena completa: desde `validateResult` en la Fase 8 hasta el número que muestra el dashboard, e identifica el punto exacto donde, si la validación no persistiera el veredicto, el KPI mentiría en silencio. Conéctalo con el hueco de `referenceRanges` en el `ResultsState` de la Fase 8.
30. Reproduce el incidente 16 de punta a punta: parte de un dashboard con las cuatro suscripciones sin cerrar, provoca el leak entrando/saliendo, captúralo en un heap snapshot, aplica el fix con `takeUntil`, y escribe la prueba de regresión que falla antes y pasa después (un test que monte y destruya el componente N veces y verifique que no quedan suscripciones activas).

**🔥 Opcionales**

- 🔥 Reemplaza los cuatro KPIs calculados en cliente por una sola llamada a un endpoint `/dashboard/summary` que el Express de la Fase 4 calcule server-side. Documenta qué desaparece de `dashboard.selectors.ts` y qué se gana y se pierde (menos trabajo en cliente, pero un cálculo que ya no ves en Redux DevTools).
- 🔥 Añade actualización en tiempo real: un polling cada 30s o un canal del inyector de caos de la Fase 4 que empuje cambios. Documenta cómo interactúa con la memoización (¿el selector se recomputa si el dato llegó pero es idéntico?) y con el leak (¿el polling sin cerrar es un leak peor?).
- 🔥 Migra el gráfico heredado de ngx-charts a ng2-charts, saca `NgxChartsModule` y d3 del `package.json`, y mide la reducción del bundle. Esto **paga** la deuda de §5.6: hazlo en una rama aparte y documenta qué se rompió al migrar (los formatos de datos no son intercambiables).

---

## 📚 8. Referencias

**Documentación oficial**

- https://v8.angular.io/api/core/ChangeDetectionStrategy — `OnPush` y el ciclo de detección de cambios, en la versión del curso. ⚠️ Enlace no verificado al cierre; si `v8.angular.io` no responde, la alternativa es `https://angular.io/api/core/ChangeDetectionStrategy` advirtiendo que cubre una versión posterior. Arrastra el pendiente abierto en la Fase 3.
- https://v8.angular.io/guide/pipes — pipes puros e impuros y cuándo Angular los reevalúa. La base de la salida 3 de §5.7. ⚠️ Mismo pendiente de `v8.angular.io`.
- https://ngrx.io/guide/store/selectors — `createSelector` y la memoización. ⚠️ Cubre versiones posteriores; el `createSelector` de la página es compatible en firma con NgRx 8, pero ignora las secciones de `createFeature`/`createSelectorFactory` modernos, que **no** existen en tu `package.json`.
- https://rxjs.dev/api/operators/takeUntil — `takeUntil` para cerrar suscripciones en `ngOnDestroy`. ⚠️ Documenta RxJS 7+; en RxJS 6.5.5 el operador se importa de `rxjs/operators`, como en §5.7, no del árbol nuevo. Ojo con esa diferencia de import.
- https://github.com/valor-software/ng2-charts/tree/2.x — ng2-charts línea 2.x, la directiva `baseChart` y `ChartsModule`. ⚠️ La rama `master` y npm ya documentan la v4+ con `provideCharts` y componentes standalone, que **no** son los de tu stack: tu versión usa `ChartsModule` con `@NgModule`, como en §5.1.
- https://www.chartjs.org/docs/2.9.4/ — Chart.js 2.9.4, el motor que ng2-charts envuelve. ⚠️ La doc actual de Chart.js cubre la v4, con API de registro de componentes distinta; fíjate que estás leyendo la 2.9.
- https://github.com/swimlane/ngx-charts/releases — releases de ngx-charts, el motor del gráfico heredado de §5.6. ⚠️ Abre el tag que corresponda a la versión de tu `package.json` y no la rama por defecto: las líneas altas exigen Angular 12+ y su API no es la que compila contra tu Angular 8.

**Libros / artículos de referencia**

- El apéndice **A05 (RxJS de supervivencia)** cubre los operadores del curso y, en su §9, el **mecanismo** de cerrar una suscripción: `Subscription`, `takeUntil(destroy$)` con sus trampas, el `async` pipe y por qué el curso no lo usa. Esta fase conserva el **caso clínico**: medir el leak en el Memory panel, reproducirlo, capturarlo en un heap snapshot y escribir la regresión (§5.7, §6 e incidente 16). Si buscas la sintaxis, A05; si buscas la autopsia, acá.
- El apéndice **A06 (NgRx 8)** es la referencia de fondo para la memoización de selectores y para el acoplamiento de un selector que cruza varios slices (§5.2, ejercicio 24).

**Video / apoyo**

- Charlas de la época (2018-2020) sobre performance de change detection en Angular y sobre memory leaks por suscripciones sin cerrar — https://www.youtube.com/results?search_query=angular+change+detection+performance+2019 — útiles para ver las tres firmas en acción. ⚠️ Verifica la fecha: todo lo posterior a 2023 va a hablar de `signals` y `takeUntilDestroyed`, que no existen en tu stack.

**Orden de lectura sugerido:** antes de escribir código, la doc de `createSelector` de NgRx para tener claro qué es la memoización y por qué depende de la inmutabilidad. Durante, los selectores de §5.2 y el componente de §5.3, que son el corazón. Después, y solo si vas al forense, la doc de `ChangeDetectionStrategy` y el heap snapshot enlazados en [`forense-fase-10.md`](./forense-fase-10.md).

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido desde que se escribió esto. Los enlaces a `v8.angular.io` están marcados como **no verificados** y arrastran el pendiente de la Fase 3. Toda la documentación de NgRx, RxJS, ng2-charts y Chart.js en sus sitios oficiales cubre versiones posteriores a las tuyas: el `createSelector` moderno, el `provideCharts` de ng2-charts v4 y la API de registro de Chart.js 4 **no** existen en tu `package.json`.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Quedó construida la primera vista de solo lectura del sistema: un dashboard con carga diferida que no tiene estado propio, sino que compone selectores memoizados sobre los slices `orders`, `samples` y `results` que ya existían. Quedaron demostradas las tres firmas de un dashboard lento —recomputación de selectores, re-render de gráficos y suscripciones huérfanas— con sus tres fixes no intercambiables, y quedó declarada la deuda 💸 central de la fase: cuatro `.subscribe()` sin cerrar en el componente gordo, el memory leak que alimenta el incidente 16. Se cerró además el bucle que la Fase 8 dejó abierto: el `verdictFor` llamado desde el template encontró acá sus tres salidas —selector memoizado, `OnPush`, pipe puro—, mostradas sobre el dashboard sin reescribir la Fase 8. Y quedó marcada, como segunda deuda 💸, la convivencia de dos motores de gráficos (ng2-charts vivo, ngx-charts heredado con su d3 a cuestas), peso muerto que se aprende a ver en el bundle.

La **Fase 12 — Testing desde cero + coverage** es el paso natural porque el dashboard es la primera pantalla donde un test tiene algo *medible* que afirmar más allá de "renderiza": que un selector memoizado no se recomputa cuando no debe, que el componente no deja suscripciones vivas tras destruirse (el ejercicio 30 ya escribe esa prueba de regresión), que un KPI muestra `0` y no revienta cuando un slice lazy no se cargó. Sin la disciplina de esta fase —lógica en selectores puros y testeables en vez de enredada en el componente—, esas afirmaciones no se podrían escribir. Con ella, el dashboard es material de test de primera.

> **La señal de que quedó bien:** cuando te llegue el ticket "el dashboard va lento" y tu primer movimiento no sea abrir el código, sino grabar el Performance panel y preguntarte cuál de las tres firmas domina —recomputación, re-render o leak—, y sepas que cada una tiene su propio fix y que aplicar el equivocado no arregla nada.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-10-dashboard -m "F10 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f10: …`) y los de ejercicio su
> número (`f10 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f10/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

Cosas que aparecieron escribiendo esta fase y que no caben acá:

- **[A]** El **hueco de `referenceRanges` en el `ResultsState` de la Fase 8**: el componente de esa fase leía `state.results.referenceRanges`, un campo que la interfaz `ResultsState` (§5.4 de la Fase 8) no declaraba ni ninguna acción cargaba. → **resuelto por edit retroactivo a la Fase 8** (precedente del edit retroactivo de la Fase 3): se agregó el campo a la interfaz y al `initialState`, las acciones `loadReferenceRanges*`, su `case` en el reducer, el effect `loadReferenceRanges$` (sobre el `getReferenceRanges()` que ya existía) y el `dispatch` en el componente. El dashboard esquiva el tema al no tocar rangos, pero la Fase 8 quedó consistente: `verdictFor` ya tiene rangos contra qué comparar y la validación puede congelar `rangeVersionApplied`.
- **[B]** El **backport de las tres salidas de performance a la Fase 8**: convertir `verdictFor` en el `VerdictPipe` puro de §5.7 dentro de la pantalla de resultados → sugerido como **edit retroactivo a la Fase 8** o como material del **apéndice A05/A06**. Acá se muestra el pipe pero no se aplica a la Fase 8.
- **[C]** El **endpoint `/dashboard/summary` server-side** que precalcula los KPIs → sugerido para el **inyector de caos / Express de la Fase 4** (como ruta calculada) o como ejercicio 🔥 ya incluido. Cambia dónde vive el cálculo y qué se ve en Redux DevTools.
- **[D]** La **actualización en tiempo real** (polling o canal de eventos) → sugerido para la **Fase 4** (fuente de eventos) o la **Fase 11** (audit log que captura cambios). Interactúa con la memoización y con el leak de formas que valen su propio análisis.
- **[E]** 🪦 **Resuelto.** La **doble grafía `in_process` (dato) vs `inProcess` (clave i18n)** reaparece en las etiquetas de estado del dashboard; el mapa explícito que la neutraliza está en el **Apéndice A07 §4**. La deuda sigue declarada, pero ya no está huérfana.
- **[F]** La **unificación de las dos librerías de gráficos** (migrar el gráfico heredado y sacar ngx-charts + d3) → deuda 💸 de §5.6; queda como **ejercicio 🔥** acá y como decisión de arquitectura para un apéndice de bundle/build o la **Fase 13 (build y despliegue)**, donde el peso del bundle se vuelve tema central.

### Reservas para el cuaderno de incidentes

Esta fase toma el incidente **16**. Está en el índice del cuaderno y con su enunciado escrito allí, que es donde vive:

- **16** · Fase 10 · *"El dashboard se arrastra al final del turno"* · Categoría: performance · Dificultad 🟠

Su raíz es la deuda de §5.3 (las cuatro suscripciones sin cerrar) y su reproducción es el ejercicio 30. Es la pieza de performance/leak del curso.
