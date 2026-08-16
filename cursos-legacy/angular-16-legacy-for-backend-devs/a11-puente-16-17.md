# 📎 Apéndice A11 — 🔥 Puente Angular 16 → 17+

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **2 horas**
> Usado por: [Fase 12](12-testing-coverage.md) (la pincelada de signals sale de aquí) · Versión cubierta: de 16.2.12 hacia 17 y posteriores
> 🔥 **Opcional — el curso se completa sin abrir este apéndice.**

**Esto no se lee de corrido, y además no es un plan.** Es un mirador. Sirve para una cosa muy concreta y muy frecuente: **buscas cómo hacer algo, encuentras un artículo de 2025, y no se parece en nada a tu código.** Este apéndice te dice en treinta segundos si estás mirando otra versión o si lo estás haciendo mal.

Casi siempre es lo primero. Y saberlo también te permite decir en una reunión, con precisión, qué separa a CertCore de lo que hoy se considera normal — que es una conversación distinta de "deberíamos migrar".

**Qué queda fuera:** el procedimiento de migración paso a paso, y **cualquier recomendación de migrar**. Este curso enseña a mantener, no a modernizar. La decisión de llevar CertCore más allá de la 16 no es técnica y no se toma leyendo un apéndice.

> ⚠️ **En Angular 16 los signals existen y son experimentales.** CertCore no los usa: aquí se leen, no se adoptan. La decisión está cerrada en `alcance-del-proyecto.md` §13 y ninguna fase la contradice.

---

## Índice

- [1. Signals de verdad](#1-signals-de-verdad)
- [2. En qué se parece un signal a un `BehaviorSubject`, y en qué no](#2-en-qué-se-parece-un-signal-a-un-behaviorsubject-y-en-qué-no)
- [3. El control flow `@if` / `@for` / `@switch`](#3-el-control-flow-if--for--switch)
- [4. Deferrable views](#4-deferrable-views)
- [5. El builder de esbuild](#5-el-builder-de-esbuild)
- [6. `provideRouter` y el bootstrap sin `NgModule`](#6-providerouter-y-el-bootstrap-sin-ngmodule)
- [7. Lo que caduca del testing de la Fase 12](#7-lo-que-caduca-del-testing-de-la-fase-12)
- [8. ⚖️ Qué costaría llevar CertCore hasta aquí](#8-️-qué-costaría-llevar-certcore-hasta-aquí)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-5)

---

## 1. Signals de verdad

Un signal es un valor que sabe quién lo está mirando. Se lee llamándolo como función, se escribe con métodos, y todo lo que dependa de él se entera solo.

```ts
// Angular 17+. NO compila en este proyecto y no hay que escribirlo.
const templates = signal<ChecklistTemplate[]>([]);

templates();                                  // leer
templates.set(nextTemplates);                 // reemplazar
templates.update((current) => [...current, created]);   // derivar del actual

// Un derivado. Se recalcula solo, y sólo cuando alguna de sus entradas cambió.
const criticalCount = computed(() => templates().filter((t) => t.hasCritical).length);

// Un efecto. Corre cuando cambia algo de lo que leyó dentro.
effect(() => console.log('plantillas:', templates().length));
```

Y en un componente, con las entradas y salidas reescritas:

```ts
@Component({ /* … */ })
export class KpiCardComponent {
  readonly value = input.required<number>();          // en vez de @Input()
  readonly selected = output<string>();               // en vez de @Output()
  readonly label = computed(() => `${this.value()} vigentes`);
}
```

Lo que esto cambia de fondo no es la sintaxis: es que **el framework sabe exactamente qué parte de la pantalla depende de qué dato**. Con `zone.js` —lo que usa CertCore— Angular no lo sabe, así que ante cualquier evento revisa todo y confía en `OnPush` para podar. Con signals, la actualización va dirigida.

---

## 2. En qué se parece un signal a un `BehaviorSubject`, y en qué no

Es la comparación que de verdad le sirve a alguien que viene de la Fase 4, y hay que hacerla con cuidado porque el parecido superficial esconde dos diferencias grandes.

**En qué se parecen:** los dos siempre tienen un valor, los dos avisan a quien los mira, y los dos sirven de base para derivados (`computed` frente a `map` + `shareReplay`).

| | `BehaviorSubject` (CertCore) | `signal` (17+) |
|---|---|---|
| Leer el valor actual | `.value`, y desde fuera es sospechoso | `templates()`, y es la forma normal |
| Suscribirse | explícito, y hay que desuscribirse | no existe: lees y ya estás enganchado |
| Derivar | `map` + `distinctUntilChanged` + `shareReplay` | `computed`, memorizado de fábrica |
| Fugas | la mitad de los bugs del curso | no aplica: no hay suscripción que quede colgando |
| Asincronía | es su especialidad: `switchMap`, `debounceTime`, cancelación | **no la maneja**: un signal es un valor, no un flujo |
| Tiempo | puedes expresar "espera 300 ms y cancela lo anterior" | necesitas RxJS igual |

**Las dos diferencias que importan de verdad:**

**Un signal no es un observable.** No hay `switchMap`, no hay `debounceTime`, no hay cancelación de una petición en vuelo. Todo lo que la Fase 8 hace con el autosave —esperar, no repetir, encolar— sigue necesitando RxJS. Angular 17+ trae puentes en las dos direcciones (`toSignal`, `toObservable`) precisamente porque las dos cosas resuelven problemas distintos y hay que combinarlas.

**Los signals eliminan una familia de bugs y no todas.** Se acaban las fugas de suscripción y los `async` duplicados; **no** se acaban las cargas concurrentes que llegan en el orden equivocado, ni la falta de trazabilidad de quién cambió qué, que son dos de los cuatro límites que **A07** §8 le pone al patrón de CertCore. Cambiar a signals no es cambiar de arquitectura de estado: es cambiar el mecanismo de notificación.

---

## 3. El control flow `@if` / `@for` / `@switch`

```html
<!-- CertCore, Angular 16 -->
<ng-container *ngIf="state$ | async as state; else loading">
  <div *ngFor="let template of state.items; trackBy: trackByTemplateId">…</div>
</ng-container>
<ng-template #loading><mat-spinner></mat-spinner></ng-template>
```

```html
<!-- Angular 17+. No compila aquí. -->
@if (state(); as state) {
  @for (template of state.items; track template.id) {
    <div>…</div>
  } @empty {
    <p>No hay plantillas</p>
  }
} @else {
  <mat-spinner />
}
```

**Qué gana, más allá de que se lea mejor:**

- **`track` es obligatorio en `@for`.** No es azúcar: es que el error de rendimiento más común de las listas —no poner `trackBy`— deja de poderse cometer.
- **`@empty` existe.** El caso de la lista vacía deja de ser un `*ngIf` paralelo que alguien olvida actualizar.
- **No hace falta importar nada.** `NgIf` y `NgFor` desaparecen de los `imports` de los componentes standalone, lo cual quita ruido de cada archivo.
- **Las directivas estructurales siguen funcionando.** No desaparecieron; el control flow es lo recomendado y hay una migración automática que las convierte.

---

## 4. Deferrable views

```html
<!-- Angular 17+. Carga diferida declarada en la plantilla. -->
@defer (on interaction) {
  <cc-certificate-pdf-button [certificate]="certificate" />
} @placeholder {
  <button>Descargar PDF</button>
} @loading (minimum 200ms) {
  <mat-spinner diameter="20" />
}
```

Es la respuesta declarativa a lo que la **Fase 10** resuelve a mano con `await import('jspdf')`: los 300 KB del generador de PDF no viajan hasta que alguien interactúa con ese botón.

**Lo que aporta frente a lo que ya haces:** el disparador se declara donde se usa (`on interaction`, `on viewport`, `on idle`, `on timer`), y el estado de carga tiene su hueco en la plantilla en vez de resolverse con una bandera. **Lo que no cambia:** la decisión sigue siendo tuya y sigue siendo la misma —qué es lo bastante pesado y lo bastante infrecuente como para diferirlo—, y esa decisión es lo difícil. `@defer` hace más cómodo lo fácil.

---

## 5. El builder de esbuild

Angular 16 construye CertCore con Webpack. A partir de la 17, el builder por defecto para proyectos nuevos usa **esbuild** con Vite en desarrollo, y en las versiones siguientes se consolidó como el camino principal.

**Qué cambia en la práctica:** los tiempos de build y sobre todo los de recompilación en desarrollo bajan mucho — es la diferencia más tangible de todo este apéndice para el día a día. **Qué se rompe:** cualquier cosa que dependiera de la configuración interna de Webpack. Un `custom-webpack` builder, un plugin propio, un `polyfills` peculiar, o el `stats.json` que la **Fase 10** usa para localizar en qué chunk quedó `jspdf` — la información sigue estando, con otro formato.

> 💡 **La conclusión útil, que no es la que parece.** Si algún día alguien plantea saltar de la 16 en adelante, el riesgo no está en los signals ni en el control flow: está aquí. Signals y `@if` son **aditivos** —tu código sigue compilando sin tocarlos—; el cambio de builder es el único que puede romper el pipeline entero de golpe. Es donde hay que mirar primero al estimar.

---

## 6. `provideRouter` y el bootstrap sin `NgModule`

```ts
// CertCore, Angular 16: el AppModule de 2021 sigue siendo el raíz.
platformBrowserDynamic().bootstrapModule(AppModule);

// Angular 17+, y ya posible en la 16: sin ningún NgModule.
bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(routes, withComponentInputBinding()),
    provideHttpClient(withInterceptors([authInterceptor])),
    provideAnimations(),
  ],
});
```

Esto **ya existe en Angular 16** —de hecho la Fase 0 arranca así, antes de que la Fase 1 traiga la herencia— y por eso es la parte del futuro que menos te va a sorprender. Lo que cambia después de la 17 es que deja de ser una alternativa y pasa a ser lo que el CLI genera por defecto y lo que la documentación asume.

`withComponentInputBinding()` merece una mención: hace que los parámetros de la ruta lleguen directamente como `@Input` del componente, y elimina la mitad del código que la **Fase 8** escribe para derivar el formulario de la ruta. Es de los añadidos que más gustan y menos se conocen.

---

## 7. Lo que caduca del testing de la Fase 12

La Fase 12 escribe su suite con tres piezas que en Angular 17 en adelante están en desuso o dejaron de tener sentido. Ninguna está mal hoy: en la 16 son lo que hay.

| Lo que usa la Fase 12 | Qué pasó después | Qué se usa en su lugar |
|---|---|---|
| `RouterTestingModule` | deprecado en Angular 17 | `provideRouter(routes)` en los `providers` del `TestBed` |
| `HttpClientTestingModule` | deprecado en versiones posteriores | `provideHttpClient()` + `provideHttpClientTesting()` |
| `TestBed` sin signals, con `detectChanges()` para leer el estado | sigue funcionando y deja de hacer falta tanto | `componentRef.setInput()` y leer el signal directamente |

**El cambio de fondo, que es el que la Fase 12 §5.9 anuncia:** con signals, **el estado deja de necesitar un ciclo de detección de cambios para ser observable**. La mitad de los `fixture.detectChanges()` de esa fase existen sólo para que el valor llegue a la plantilla; con signals el valor está antes de pintar nada.

> 🧭 **Y lo que no caduca, que es la mitad de tu suite: las funciones puras se seguirán testeando exactamente igual.** `resolveTemplateVersion`, `buildAnswerForm`, las reglas de severidad, las agregaciones del dashboard — nada de eso toca `TestBed`, así que nada de eso se ve afectado por ninguna versión de Angular. Es un argumento a favor de escribir dominio puro que ninguna presentación de signals te va a dar, y es la razón por la que el coverage de CertCore está donde está.

---

## 8. ⚖️ Qué costaría llevar CertCore hasta aquí

Una estimación honesta, con las categorías separadas, para que la conversación se pueda tener con números en vez de con entusiasmo.

**Lo que es casi automático:** subir de mayor en mayor con `ng update`, una por vez. Angular es notablemente cuidadoso con esto y las schematics hacen buena parte del trabajo. De la 16 a la 20 son cuatro saltos, y ninguno de ellos rompe conceptualmente nada de lo que CertCore tiene.

**Lo que es trabajo real y acotado:** el cambio de builder (§5), la actualización de Material —que entre la 16 y la 18 volvió a mover cosas de tema y tokens—, y la revisión de las dependencias que no son de Angular: `ng2-charts`, `jspdf` y el `zone.js` que, si algún día se quita, cambia el modelo de detección de cambios entero.

**Lo que es opcional y por eso peligroso de estimar:** convertir a signals, adoptar el control flow, quitar los `NgModule` que quedan. Nada de esto es necesario para estar en una versión nueva — el código de la 16 sigue compilando —, y por eso es donde una migración se convierte en una refactorización sin límite claro si nadie la acota antes de empezar.

> ⚖️ **El veredicto honesto, y es el que cierra el apéndice.** Migrar un sistema **en mantenimiento**, sin features nuevas previstas y con un equipo pequeño, rara vez se paga solo. Los argumentos que sí sostienen la decisión son concretos y no son técnicos: **soporte** (una versión sin actualizaciones de seguridad es un riesgo con fecha), **contratación** (cuesta más encontrar a alguien dispuesto a mantener una versión que nadie usa), y **dependencias** (el día que necesites una librería que ya sólo publica para versiones nuevas, la decisión la toma ella por ti).
>
> "Es más moderno" no está en esa lista, y **"el equipo se aburre" tampoco lo está — aunque sea un problema real que merece resolverse de otra manera**. Si alguien plantea la migración en una reunión, las tres preguntas útiles son: ¿cuánto soporte le queda a la versión actual?, ¿qué dependencia nos va a obligar primero?, y ¿quién mantiene esto dentro de dos años?

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer hoy, en la 16 |
|---|---|
| Un ejemplo usa `@if` / `@for` | traducirlo a `*ngIf` / `*ngFor`; la idea sirve, la sintaxis no |
| Un ejemplo usa `signal()` o `input()` | traducirlo a `BehaviorSubject` y `@Input`; ver §2 |
| Un ejemplo usa `@defer` | es un `await import()` en un método; **Fase 10** y **A08** §6 |
| Un artículo dice que `HttpClientTestingModule` está deprecado | tiene razón, y en la 16 sigue siendo lo correcto |
| Necesitas argumentar una migración | §8, con las tres preguntas del final |
| Necesitas argumentar **no** migrar | §8 otra vez, con las mismas tres |
| Quieres prepararte para migrar sin migrar | escribe dominio puro (§7): sobrevive a todas las versiones |

---

## 📚 Referencias

- https://angular.dev — la documentación de la 17 en adelante. Aquí sí es la referencia correcta, y es el único apéndice de este curso donde lo es.
- https://angular.dev/guide/signals — signals, `computed` y `effect`.
- https://angular.dev/guide/templates/control-flow — `@if`, `@for` con su `track` obligatorio, y `@switch`.
- https://angular.dev/guide/templates/defer — deferrable views y sus disparadores.
- https://angular.dev/tools/cli/build-system-migration — la migración al builder de esbuild, que es el punto de riesgo de la §5.
- https://update.angular.io — el asistente oficial: pon 16 como origen y la versión que quieras como destino para ver el catálogo real de cambios.
- https://angular.dev/reference/releases — el calendario de soporte. Es el dato que convierte la conversación de la §8 en una decisión con fecha.

> ⚠️ Al revés que en el resto del curso: **aquí `v16.angular.io` es la referencia equivocada.** Este apéndice habla de lo que viene después, y lo que viene después sólo está documentado en `angular.dev`. Cuando vuelvas a las fases, vuelve también a la otra URL.

**Orden de lectura sugerido:** la §2 si vienes de la Fase 4 y te preguntas si el patrón de estado de CertCore tiene los días contados (la respuesta corta es que no, y la larga está ahí). La §7 al terminar la Fase 12. La §8 sólo el día que alguien plantee la pregunta en una reunión — leerla antes convierte una curiosidad en una inquietud, y no hay nada que hacer con ella.

---

## 🧪 Ejercicios (5)

1. 🟢 Toma la plantilla del listado de plantillas de la Fase 7 y reescríbela con `@if` y `@for` **en un archivo aparte que no compile**. Anota qué tres cosas desaparecieron del componente al hacerlo.

2. 🟢 Busca en internet cómo hacer algo que ya sabes hacer en CertCore —cargar datos en un componente, por ejemplo— y clasifica el primer resultado: ¿es de la 16 o posterior? Anota las tres señales que te lo dijeron.

3. 🟡 Reescribe `TemplateStateService` con signals, en un archivo que no compila y que no se commitea al `src/`. Después responde: ¿cuáles de los cuatro límites de **A07** §8 resolvió el cambio, y cuáles siguen exactamente igual?

4. 🟠 Toma tres tests de la Fase 12 —uno de función pura, uno de servicio con `HttpClientTestingModule` y uno de componente con `detectChanges()`— y di, para cada uno, qué habría que cambiar en Angular 17+ y qué no. Ordénalos por cuánto trabajo cuesta.

5. 🔴 Escribe el documento de una página que le llevarías a tu líder si mañana te preguntara *"¿migramos CertCore?"*. Tiene que responder a las tres preguntas del cierre de la §8 con datos —cuánto soporte le queda a la 16, qué dependencia obliga primero, quién mantiene esto en dos años— y terminar con una recomendación. El criterio de éxito es que la recomendación sea defendible en las dos direcciones: si tu documento sólo puede terminar en "sí", no es un análisis.

---

> 🏷️ **Este apéndice no lleva tag propio**, y aquí la regla es más estricta que en el resto: **nada de lo que escribas leyéndolo debe acabar en `src/`.** Los ejercicios 1 y 3 producen código que no compila en este proyecto a propósito; si quieres conservarlo, va en `docs/futuro/` y se commitea con el prefijo de la fase desde la que llegaste (`fase 12: …`). Un `signal()` colado en el código del curso rompe la coherencia de las catorce fases anteriores. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
