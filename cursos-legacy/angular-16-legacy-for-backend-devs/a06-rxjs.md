# 📎 Apéndice A06 — RxJS 7 idiomático

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: [Fase 2](02-autenticacion.md), [Fase 3](03-mock-api-caos.md), [Fase 4](04-estado-servicios.md), [Fase 7](07-plantillas-versionadas.md), [Fase 8](08-formulario-dinamico.md), [Fase 11](11-dashboard-alertas.md), [Fase 12](12-testing-coverage.md) · Versión cubierta: RxJS 7.8.1

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve una pregunta muy concreta: **cuál de los ocho operadores que CertCore usa de verdad toca aquí, y qué antipatrón produce cada uno cuando se elige mal.**

RxJS tiene más de cien operadores y este apéndice cubre ocho. No es una simplificación pedagógica: son los que aparecen en el código del curso, y son los que aparecen en la inmensa mayoría de las aplicaciones Angular de producción. Si algún día necesitas el noveno, lo vas a saber, y para entonces tendrás el modelo mental para leer su documentación.

**Qué queda fuera:** marble testing y `TestScheduler` (la **Fase 12** testea el tiempo de otra forma, más simple y suficiente), los schedulers y todo lo relacionado con `observeOn`/`subscribeOn`, la creación de operadores propios, `WebSocket` y multiplexación, y los operadores de backpressure. Nada de eso está en CertCore.

---

## Índice

- [1. El modelo mental mínimo](#1-el-modelo-mental-mínimo)
- [2. `map`, y por qué casi todo empieza ahí](#2-map-y-por-qué-casi-todo-empieza-ahí)
- [3. `switchMap`, `mergeMap` y `concatMap`](#3-switchmap-mergemap-y-concatmap)
- [4. `combineLatest` y la trampa del primer valor](#4-combinelatest-y-la-trampa-del-primer-valor)
- [5. `debounceTime` + `distinctUntilChanged`](#5-debouncetime--distinctuntilchanged)
- [6. `catchError`: qué devolver, y dónde ponerlo](#6-catcherror-qué-devolver-y-dónde-ponerlo)
- [7. `shareReplay`, con y sin `refCount`](#7-sharereplay-con-y-sin-refcount)
- [8. 🧬 Las tres formas de desuscribirse](#8--las-tres-formas-de-desuscribirse)
- [9. `async` pipe frente a `.subscribe()`](#9-async-pipe-frente-a-subscribe)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-9)

---

## 1. El modelo mental mínimo

Tres preguntas responden por casi cualquier observable que te encuentres en CertCore. Vale la pena hacérselas explícitamente las primeras veces, hasta que salgan solas.

**¿Quién dispara el trabajo?** Un observable **frío** hace su trabajo *por cada suscripción*. El de `HttpClient` es el ejemplo canónico: tres suscripciones son tres peticiones HTTP. Un observable **caliente** ya está corriendo y los suscriptores se enganchan a lo que hay: un `BehaviorSubject` es caliente y además guarda el último valor, que es por lo que sirve como estado.

```ts
const templates$ = this.http.get<ChecklistTemplate[]>('/templates');   // FRÍO
templates$.subscribe();   // petición 1
templates$.subscribe();   // petición 2. No es un bug de nadie: es la definición.

readonly state$ = this.stateSubject.asObservable();   // CALIENTE
```

**¿Completa?** Un observable de `HttpClient` emite una vez y completa: no queda nada abierto, y por eso la **Fase 4** se suscribe a él sin desuscribirse y está bien. Un `BehaviorSubject` **no completa nunca**: quien se suscriba se queda suscrito hasta que alguien lo corte. Ahí es donde viven todas las fugas del curso.

**¿Quién cancela?** Si alguien puede pedir dos veces lo mismo antes de que llegue la primera respuesta, alguien tiene que decidir qué pasa con la primera. Ésa es toda la §3.

> 🧠 **Qué es una fuga, exactamente** (Fase 4). No es "una suscripción sin cerrar": es **una suscripción que sobrevive a quien la creó**. Un componente que se suscribe a un servicio raíz y se destruye sin cortar deja un zombi reaccionando a cada emisión, y diez navegaciones dejan diez. Un servicio raíz suscrito a otro servicio raíz no es una fuga: nadie sobrevive a nadie.

> 📝 **Nota de migración: RxJS 6 → 7.** Tres diferencias que hacen que un ejemplo de internet no compile aquí. **Los imports:** en RxJS 7 todos los operadores salen de `'rxjs'`; el `'rxjs/operators'` de la 6 sigue funcionando pero está en desuso, y verlo es la señal más rápida de que un artículo es viejo. **`toPromise()` está deprecado** y se sustituye por `firstValueFrom()` o `lastValueFrom()`, que además obligan a decidir cuál de los dos querías —`toPromise()` devolvía el último valor y `undefined` si no había ninguno, que es de las peores decisiones de diseño que ha tenido esta librería—. Y **`combineLatest` con argumentos sueltos** (`combineLatest(a$, b$)`) desapareció: ahora es siempre un array. CertCore nació en 2021 con RxJS 6; la migración de 2024 los actualizó todos, así que en el repositorio no queda ninguno — pero en el tuyo sí.

---

## 2. `map`, y por qué casi todo empieza ahí

`map` transforma cada valor sin tocar nada más. Es el operador que menos explicación necesita y el que más trabajo hace, y en CertCore aparece sobre todo en un sitio: **derivar estado sin duplicarlo**.

```ts
// TemplateStateService, Fase 4. Un solo BehaviorSubject, cinco vistas de él.
readonly templates$ = this.state$.pipe(map((state) => state.items), distinctUntilChanged());
readonly loading$   = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());
```

El `distinctUntilChanged` que va detrás no es adorno: sin él, un cambio en `loading` hace emitir a `templates$` con el mismo array de siempre, y quien esté pintando con `OnPush` se despierta para nada. Con él, cada derivado sólo emite cuando su parte cambió.

> 🧭 **Regla del proyecto (Fases 4, 9, 10 y 11): lo que se puede calcular no se guarda.** Un dato guardado que también se puede derivar son dos fuentes de verdad que se van a desincronizar — y en un sistema cuyo dominio es la trazabilidad, eso no es un detalle. El `map` es la herramienta con la que se cumple esa regla.

**El antipatrón:** un `map` con efectos dentro. Si tu `map` navega, guarda, abre un diálogo o hace `console.log` de algo que importa, no es un `map`: es un `tap` mal puesto, o es lógica que debería estar en el `subscribe`. Un `map` que no es puro convierte cada suscripción extra en un efecto extra, y con un `async` pipe de más te encuentras guardando dos veces.

---

## 3. `switchMap`, `mergeMap` y `concatMap`

Los tres hacen lo mismo —por cada valor que entra, lanzan un observable nuevo y aplanan el resultado— y se diferencian **sólo** en qué hacen con el anterior cuando todavía está en vuelo. Elegir mal no da error: da un bug intermitente que sólo aparece con latencia, que es exactamente por lo que la **Fase 3** construye el inyector de caos.

| Operador | Con el anterior en vuelo… | El caso que lo pide |
|---|---|---|
| `switchMap` | lo **cancela** y se queda con el nuevo | buscar mientras se escribe, reaccionar a un cambio de ruta |
| `mergeMap` | lo **deja correr**, en paralelo | operaciones independientes donde el orden da igual |
| `concatMap` | lo **encola**, uno detrás de otro | escrituras que tienen que llegar en orden |

```ts
// switchMap — el parámetro de ruta cambia: la petición anterior ya no interesa.
readonly inspection$ = this.route.paramMap.pipe(
  map((params) => params.get('inspectionId') ?? ''),
  switchMap((inspectionId) => this.inspectionApi.getById(inspectionId)),
);
```

Si el inspector navega rápido entre dos inspecciones, `switchMap` **aborta** la petición HTTP anterior —de verdad: aparece como `canceled` en la pestaña Network— y sólo llega la buena. Con `mergeMap`, las dos peticiones vuelven, y pinta **la que llegue última**, que no tiene por qué ser la que pediste al final. Es el bug de "se me quedó la inspección de antes" y es imposible de reproducir en local con el mock respondiendo en dos milisegundos.

```ts
// concatMap — el orden ES el dato. Dos PATCH de la misma inspección no pueden
// cruzarse: el segundo tiene que salir cuando el primero haya vuelto.
this.saveRequests$.pipe(
  concatMap((answers) => this.inspectionApi.saveAnswers(inspectionId, answers)),
).subscribe();
```

> 💡 **El cuarto, que CertCore no usa y conviene conocer.** `exhaustMap` **ignora** lo nuevo mientras hay algo en vuelo: es la respuesta natural al doble clic en "Guardar". CertCore lo resuelve con una bandera `submitting` en el componente (Fase 6), que es más explícita para quien lee la pantalla y no requiere entender un cuarto operador. Las dos soluciones son correctas; si te encuentras `exhaustMap` en un proyecto ajeno, es esto.

**Los tres antipatrones:**

- **`subscribe` dentro de `subscribe`.** Es la forma manual de `mergeMap`, sin cancelación, sin manejo de errores y sin nada que se pueda desuscribir de golpe. Si ves uno, la traducción es directa: el interior se convierte en `switchMap` o en `concatMap` según lo que quieras que pase con el anterior.
- **`mergeMap` por defecto** porque es el que sale primero al buscar "flatten observable". Es el único de los tres que no da ninguna garantía, y por eso es el peor valor por defecto.
- **`switchMap` sobre una escritura.** Cancelar un `GET` es gratis; cancelar un `PATCH` que ya salió no cancela nada en el servidor, sólo te deja sin saber si llegó. Para escrituras, `concatMap`.

---

## 4. `combineLatest` y la trampa del primer valor

`combineLatest` toma varios observables y emite un array con el último valor de cada uno, cada vez que cualquiera emite. Es la herramienta con la que se cruzan dos partes del estado sin guardarlas juntas.

```ts
// Fase 11: el dashboard cruza certificados con clientes sin guardar el cruce.
readonly expiringByClient$ = combineLatest([
  this.certificateState.certificates$,
  this.clientState.clients$,
]).pipe(
  map(([certificates, clients]) => groupExpiringByClient(certificates, clients)),
);
```

**La trampa:** `combineLatest` **no emite absolutamente nada hasta que cada una de sus fuentes haya emitido al menos una vez**. Si una de las cinco todavía no ha emitido, la pantalla se queda en blanco, sin error, sin nada en consola, y sin ninguna pista de cuál de las cinco es la que falta.

Con `BehaviorSubject` no pasa, porque siempre tiene un valor desde el momento en que se crea — y ésa es una de las razones de peso por las que el patrón de estado de CertCore usa `BehaviorSubject` y no `Subject`. Pasa cuando metes en el `combineLatest` un `Subject` normal, un `EventEmitter`, o un observable de `HttpClient` que todavía no ha vuelto.

**Cómo se depura en un minuto:** un `tap` con etiqueta en cada fuente, antes del `combineLatest`. La que no imprima nada es la culpable.

```ts
combineLatest([
  this.a$.pipe(tap((v) => console.log('a', v))),
  this.b$.pipe(tap((v) => console.log('b', v))),   // si esto no imprime, aquí está
])
```

**El antipatrón:** `combineLatest` sobre fuentes que cambian a la vez. Si `a$` y `b$` se actualizan los dos como consecuencia de la misma acción, `combineLatest` emite **dos veces**: una con `a` nuevo y `b` viejo, y otra con los dos nuevos. Esa emisión intermedia es un estado que nunca existió, y si tiene efectos —guardar, navegar— los tiene sobre datos inconsistentes. La solución en CertCore es la de la Fase 4: **un solo objeto de estado** del que salen los derivados, en vez de varios sujetos que hay que recombinar.

---

## 5. `debounceTime` + `distinctUntilChanged`

Van juntos y en ese orden. `debounceTime(ms)` espera a que pare de llegar; `distinctUntilChanged` descarta lo que es igual a lo anterior.

```ts
// Fase 8: el autosave de una inspección en curso.
this.form.valueChanges.pipe(
  debounceTime(1500),
  map(() => toAnswers(this.form)),
  distinctUntilChanged((a, b) => serializeAnswers(a) === serializeAnswers(b)),
  concatMap((answers) => this.inspectionApi.saveAnswers(this.inspectionId, answers)),
  takeUntilDestroyed(this.destroyRef),
).subscribe();
```

**Por qué ese orden.** Con `distinctUntilChanged` delante, filtras teclas que igualmente iban a colapsarse en el debounce: gastas comparaciones para nada. Con el debounce delante, comparas una vez por pausa. Además, sin el `distinct` detrás, un `valueChanges` que emite por un `markAsTouched` o por un `disable()` te dispara un guardado con un valor idéntico al anterior.

**El comparador importa.** `distinctUntilChanged` sin argumento compara con `===`, y dos objetos con el mismo contenido nunca son `===`. Sobre un array de respuestas hace falta un comparador explícito, y en CertCore es una serialización a JSON: es O(n) sobre decenas de elementos, corre como mucho una vez cada segundo y medio, y es bastante más difícil de romper que una comparación profunda escrita a mano.

**Los antipatrones:**

- **Debounce sin `distinct`** — guardas lo mismo dos veces y no lo notas hasta que el log del servidor tiene el doble de líneas.
- **`distinct` sin comparador sobre objetos** — no filtra nada y parece que sí, que es el peor de los dos mundos.
- **Debounce en un validador asíncrono puesto con `subscribe` en vez de con `timer`** — ver **A05** §6: el validador tiene que devolver un observable que complete, y un `debounceTime` sobre un observable de un solo valor no espera nada.

---

## 6. `catchError`: qué devolver, y dónde ponerlo

`catchError` recibe el error y **tiene que devolver un observable nuevo**. Lo que devuelvas decide qué pasa con el flujo, y ésa es la parte que todo el mundo contesta mal la primera vez.

```ts
// Opción A — devolver un valor por defecto: el flujo CONTINÚA y COMPLETA.
catchError(() => of([]))

// Opción B — relanzar: el flujo muere y el error llega a quien se suscribió.
catchError((error: unknown) => throwError(() => error))

// Opción C — tragárselo en silencio: el flujo COMPLETA sin decir nada.
catchError(() => EMPTY)
```

La regla del proyecto es de la **Fase 3** y es corta: **quien traduce el error es el borde HTTP; quien decide qué hacer con él es quien llamó.** Un `*ApiService` convierte un `HttpErrorResponse` en un `ApiError` del dominio y lo relanza; el `*StateService` lo captura y lo mete en `state.error`; el componente lo pinta. Nadie se lo traga por el camino.

> ⚠️ **El error de colocación que cuesta horas.** `catchError` en el `pipe` **externo** de un flujo de larga vida lo mata para siempre. Un `valueChanges` que pasa por un `switchMap` y termina en un `catchError` externo: falla una petición, el `catchError` la maneja, y **el `valueChanges` deja de emitir**. La pantalla no da ningún error; simplemente el autosave no vuelve a funcionar hasta que recargues.
>
> ```ts
> // ❌ Un solo fallo mata el flujo entero para siempre.
> this.form.valueChanges.pipe(
>   switchMap((v) => this.api.save(v)),
>   catchError(() => of(null)),
> ).subscribe();
>
> // ✅ El catchError va DENTRO, protegiendo sólo la petición.
> this.form.valueChanges.pipe(
>   switchMap((v) => this.api.save(v).pipe(catchError(() => of(null)))),
> ).subscribe();
> ```
>
> La regla que lo resume: **el `catchError` va tan cerca de lo que puede fallar como se pueda.**

**Los antipatrones:** el `catchError(() => EMPTY)` que hace desaparecer el fallo (el componente sigue esperando una respuesta que no va a llegar, y el bug aparece tres pantallas más allá sin nada en consola); el `catchError` que devuelve un valor de dominio inventado —un array vacío que la pantalla pinta como "no hay plantillas" cuando lo que hubo fue un 500—; y el interceptor que se traga el error en vez de relanzarlo, que es el que la **Fase 2** nombra por su nombre.

---

## 7. `shareReplay`, con y sin `refCount`

Un observable derivado con `map` se recalcula **una vez por suscriptor**. Con cuatro pantallas mirando el mismo derivado, cuatro cálculos idénticos en cada emisión. `shareReplay` comparte una sola ejecución y reparte el resultado.

```ts
readonly latestVersions$ = this.templates$.pipe(
  map((templates) => /* recorre y agrupa por familia */),
  shareReplay({ bufferSize: 1, refCount: true }),
);
```

**`refCount: true` es la mitad que importa, y es la que el atajo omite.** `shareReplay(1)` —la forma corta que aparece en todos los ejemplos— equivale a `refCount: false`: la suscripción interna a la fuente **queda viva para siempre**, aunque no quede nadie escuchando. Sobre una fuente que no completa —un `BehaviorSubject`, por ejemplo— eso es una fuga con nombre y apellido, y no se ve en ningún sitio hasta que el perfilador de memoria la enseña.

Con `refCount: true`, cuando se va el último suscriptor la suscripción a la fuente se cierra; cuando llega uno nuevo, se vuelve a abrir.

| Forma | Qué hace | Cuándo |
|---|---|---|
| `shareReplay({ bufferSize: 1, refCount: true })` | comparte y se cierra al quedarse sin suscriptores | **el valor por defecto del proyecto** |
| `shareReplay(1)` | comparte y no se cierra nunca | sólo sobre fuentes que completan (una petición HTTP que se quiere cachear de por vida) |
| sin `shareReplay` | cada suscriptor recalcula | derivados baratos con un solo consumidor |

**Los antipatrones:** `shareReplay(1)` sobre un `BehaviorSubject` (la fuga de arriba); `shareReplay` sobre algo que ya es caliente y barato, que añade una capa que no comparte nada; y `shareReplay` usado como caché de una petición HTTP sin pensar en la invalidación — funciona, y el día que alguien publique una v3 la pantalla seguirá enseñando la v2 hasta que se recargue.

---

## 8. 🧬 Las tres formas de desuscribirse

Las tres están vivas en CertCore, y ésa es la lección: al abrir un archivo, la forma en que se desuscribe te dice de qué año es.

```ts
// ── HEREDADO (2021) — Subscription manual ─────────────────────────────────
export class TemplateListComponent implements OnInit, OnDestroy {
  private subscription: Subscription | null = null;

  constructor(private readonly templateApi: TemplateApiService) {}

  ngOnInit(): void {
    this.subscription = this.templateApi.getAll().subscribe(/* … */);
  }

  ngOnDestroy(): void {
    this.subscription?.unsubscribe();
  }
}
```

```ts
// ── HEREDADO (2021) — takeUntil con Subject de destrucción ────────────────
export class AssetListComponent implements OnInit, OnDestroy {
  private readonly destroy$ = new Subject<void>();

  ngOnInit(): void {
    this.assetState.assets$.pipe(takeUntil(this.destroy$)).subscribe(/* … */);
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();   // el complete() que la mitad del mundo olvida
  }
}
```

```ts
// ── NUEVO (2024) — takeUntilDestroyed ──────────────────────────────────────
export class ClientFormComponent {
  private readonly destroyRef = inject(DestroyRef);

  ngOnInit(): void {
    this.clientApi.getById(id)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(/* … */);
  }
}
```

**Cuál usarías.** El tercero, en todo lo que escribas de aquí en adelante: no hay campo que declarar, no hay `ngOnDestroy` que recordar, y no hay forma de olvidarse la mitad. Los dos primeros, si estás arreglando un archivo que ya los tiene — arreglar no es reescribir (guía §6.1).

> ⚠️ **`takeUntilDestroyed()` sin argumento sólo se puede llamar en el contexto de inyección**, típicamente en un inicializador de campo. Llamarlo dentro de `ngOnInit` da `NG0203`, y el mensaje de error no menciona a `takeUntilDestroyed` por ningún lado. Fuera del contexto, se inyecta `DestroyRef` arriba y se le pasa. Está en **A04** §7, caso 3.

> 🧭 **Y antes de nada: ¿hace falta desuscribirse?** Si el observable completa —cualquiera de `HttpClient`—, no. Si la suscripción es sólo para pintar, no: va `async` pipe y no hay suscripción manual que gestionar. Sólo hace falta en el caso restante: una suscripción manual a un observable que no completa, hecha desde algo que se destruye.

---

## 9. `async` pipe frente a `.subscribe()`

> 🧭 **La regla de oro del curso: `async` pipe para pintar, `.subscribe()` para efectos — y entonces alguien se desuscribe.**

Si lo único que quieres es que un valor aparezca en pantalla, `async` pipe. Se suscribe al crear la vista, se desuscribe al destruirla, y además marca el componente para revisión, que es lo que hace que `OnPush` funcione sin que tengas que llamar a `markForCheck()` a mano.

```html
<!-- Un solo async, un solo objeto de estado. -->
<ng-container *ngIf="state$ | async as state">
  <mat-spinner *ngIf="state.loading"></mat-spinner>
  <cc-error-box *ngIf="state.error as error" [message]="error"></cc-error-box>
  <cc-template-table *ngIf="!state.loading" [templates]="state.items"></cc-template-table>
</ng-container>
```

**El antipatrón que más se ve:** varios `async` sobre el mismo observable frío.

```html
<!-- ❌ Tres async sobre un observable de HttpClient son TRES peticiones. -->
<span>{{ (templates$ | async)?.length }}</span>
<div *ngFor="let t of templates$ | async">…</div>
<p *ngIf="(templates$ | async)?.length === 0">No hay plantillas</p>
```

Con un `BehaviorSubject` detrás no pasa —es caliente— y por eso en CertCore casi no se nota. Con un observable de `HttpClient` directo, son tres peticiones y la pestaña Network lo enseña. Las dos soluciones son conocidas: un solo `async` con `as` (arriba), o `shareReplay` sobre el derivado (§7).

`.subscribe()` se reserva para cuando la suscripción **provoca algo**: guardar, navegar, abrir un diálogo, mostrar un snackbar. Y en ese caso vuelve la §8: alguien tiene que desuscribirse.

---

## 🧭 Cuándo usar qué

| Necesitas… | Operador | Antipatrón que evita |
|---|---|---|
| transformar un valor | `map` | guardar lo que se puede calcular |
| reaccionar a lo último y descartar lo anterior | `switchMap` | pintar la respuesta que llegó tarde |
| lanzar cosas independientes en paralelo | `mergeMap` | encolar sin motivo lo que no depende de nada |
| garantizar el orden de varias escrituras | `concatMap` | dos `PATCH` cruzados de la misma entidad |
| cruzar dos partes del estado | `combineLatest` | duplicar el cruce en un tercer sujeto |
| esperar a que el usuario pare de escribir | `debounceTime` | una petición por tecla |
| no repetir lo idéntico | `distinctUntilChanged` **con comparador** | guardar dos veces lo mismo |
| traducir o manejar un fallo | `catchError` **lo más cerca posible** | matar un flujo de larga vida |
| compartir un cálculo entre varias vistas | `shareReplay({ bufferSize: 1, refCount: true })` | recalcular por suscriptor, o la fuga del `refCount: false` |
| cortar al destruir el componente | `takeUntilDestroyed(destroyRef)` | el zombi que revive en cada navegación |
| sólo pintar | `async` pipe | la suscripción manual que nadie cierra |
| provocar un efecto | `.subscribe()` + desuscripción | el efecto duplicado por dos `async` |

---

## ⚠️ Advertencias

- **Mucho de lo que encuentres en internet es RxJS 6.** Se reconoce por los imports desde `'rxjs/operators'`, por `toPromise()`, y por `combineLatest(a$, b$)` con argumentos sueltos. Traducirlo es mecánico; el problema es no darte cuenta de que estás traduciendo.
- **Un `subscribe` anidado dentro de otro `subscribe` no es un estilo: es un operador que falta.** La guía lo nombra como antipatrón por su nombre (§6.5) y en el curso no aparece ni una vez, salvo cuando un ejercicio te pide arreglarlo.
- **Exponer un `Subject` público es un campo mutable global con pasos extra.** Cualquiera puede hacerle `next()`, y cuando el estado quede mal la lista de sospechosos es el repositorio entero. Con `asObservable()`, la lista son los métodos de un archivo (**Fase 4**, **A07**).
- **La latencia cero del mock esconde la mitad de estos bugs.** `switchMap` frente a `mergeMap` no se distingue con respuestas de dos milisegundos. Levanta el mock con `CHAOS=latency` de la **Fase 3** antes de dar por buena una elección de operador.

---

## 📚 Referencias

- https://rxjs.dev/guide/overview — la guía oficial de RxJS 7, que es la versión de este curso.
- https://rxjs.dev/api/operators/switchMap · https://rxjs.dev/api/operators/mergeMap · https://rxjs.dev/api/operators/concatMap — los tres, con sus diagramas de canicas. Verlos uno tras otro es la forma más rápida de fijar la diferencia.
- https://rxjs.dev/api/operators/shareReplay — incluida la explicación de `refCount`, que es lo que la mayoría de los tutoriales omite.
- https://rxjs.dev/api/operators/combineLatest — con la frase sobre no emitir hasta que todas las fuentes hayan emitido.
- https://rxjs.dev/deprecations — la lista oficial de lo que salió entre la 6 y la 7, `toPromise()` incluido.
- https://v16.angular.io/api/core/rxjs-interop/takeUntilDestroyed — el operador de Angular 16, con su nota sobre el contexto de inyección.
- https://v16.angular.io/api/common/AsyncPipe — el `async` pipe, y su relación con `markForCheck()`.
- https://www.learnrxjs.io — colección de recetas por caso de uso. ⚠️ Mezcla ejemplos de RxJS 6 y 7; útil para encontrar el operador, no para copiar el código.

**Orden de lectura sugerido:** la §1 antes de la Fase 4, y de verdad antes: sin las tres preguntas, el resto son recetas. La §3 y la §7 cuando llegues a la Fase 4, que es donde aparecen las dos. La §6 cuando la Fase 3 te ponga el caos delante. La §5 y la §9 con la Fase 8. La §8 se lee de un tirón el día que abras un componente heredado y no reconozcas cómo se desuscribe.

---

## 🧪 Ejercicios (9)

1. 🟢 Suscríbete dos veces al mismo `this.http.get(...)` y cuenta las peticiones en la pestaña Network. Después haz lo mismo con `state$` de `TemplateStateService`. Explica la diferencia en una frase usando las palabras "frío" y "caliente".

2. 🟢 Quita el `distinctUntilChanged` de `templates$` en `TemplateStateService`, añade un `tap(() => console.log('recalculo'))` y provoca un cambio que sólo toque `loading`. Anota cuántas veces imprime con y sin el operador.

3. 🟡 Levanta el mock con `CHAOS=latency`, navega rápido entre dos inspecciones y observa qué se pinta. Cambia el `switchMap` de la ruta por `mergeMap` y repite. Anota qué ves en Network en cada caso y cuál de las dos peticiones aparece como `canceled`.

4. 🟡 Escribe un `combineLatest` de tres fuentes donde una sea un `Subject` normal al que nadie ha hecho `next()`. Comprueba que no emite nada, y localiza la fuente culpable con la técnica del `tap` etiquetado de la §4.

5. 🟡 En el autosave de la Fase 8, invierte el orden de `debounceTime` y `distinctUntilChanged`. Escribe rápido en un campo y cuenta las peticiones en los dos órdenes. Explica el resultado.

6. 🟠 Reproduce el error de colocación de `catchError` de la §6: ponlo en el `pipe` externo del autosave, provoca un fallo con `CHAOS=error`, y comprueba que el autosave no vuelve a funcionar aunque el siguiente guardado sí funcionaría. Después muévelo dentro del `switchMap` y verifica que el flujo sobrevive.

7. 🟠 Cambia `shareReplay({ bufferSize: 1, refCount: true })` por `shareReplay(1)` en `latestVersions$`. Navega diez veces entre dos pantallas y busca en el perfilador de memoria de DevTools la diferencia. Si no consigues verla, explica por escrito por qué el bug existe igual aunque tu medición no lo capture — que es lo interesante de este ejercicio.

8. 🔴 🧬 Te dan un componente heredado con `subscribe` anidado dentro de `subscribe` y desuscripción por `Subscription` manual. El ticket es "el segundo `subscribe` a veces pinta datos de la petición anterior". Escribe el **parche mínimo** —sin cambiar el estilo del archivo— y después la **refactorización correcta** en estilo nuevo. Argumenta cuál de los dos entregarías un viernes a las seis y por qué.

9. 🔴 Escribe un flujo que combine cinco de los ocho operadores de este apéndice para resolver esto: cuando el supervisor escribe en un buscador de clientes, la pantalla busca tras 300 ms de pausa, no repite la misma búsqueda, cancela la anterior si sigue escribiendo, sobrevive a un 500 sin dejar de funcionar, comparte el resultado entre dos vistas y se corta al destruir el componente. Debe funcionar con `CHAOS=latency,error` puesto, y ése es el criterio de éxito.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y los flujos que explica los escriben las Fases 2, 3, 4, 8 y 11, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 04: …`, `fase 08: …`). Las mediciones de los ejercicios 3, 5 y 7 van en el mensaje de un tag anotado (`ej/a06/7`), que es donde un número queda fechado. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
