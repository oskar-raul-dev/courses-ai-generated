# 📎 Apéndice A05 — RxJS de supervivencia

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **3h**
> Usado por: Fases 1, 2, 3, 4, 8, 9, 10, 11 y 12 · Versión cubierta: RxJS **6.5.5** (con `rxjs-compat` instalado)
> Estado: Base ⭐

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve una sola pregunta, la que aparece cuando abres un effect ajeno un martes por la tarde: **qué hace esta cadena de operadores y cuál de ellos puedo tocar sin romper nada.**

RxJS tiene más de cien operadores. Este proyecto usa **ocho**, y con seis se explica el 90% del código. Este apéndice cubre esos, en el orden en que te los vas a encontrar, y no cubre los demás a propósito: aprender operadores que tu repositorio no usa no te hace más rápido arreglando tu repositorio.

**Qué queda fuera:** los operadores que el proyecto no usa —`combineLatest`, `forkJoin`, `shareReplay`, `concatMap`, `exhaustMap`, `debounceTime`, `distinctUntilChanged` y los otros noventa—, que puedes buscar en la doc oficial el día que aparezcan. Tampoco entra el testing de observables con `TestScheduler` y marbles, que es un tema con curva propia (pendiente anotado al final), ni `ofType`, que es de NgRx y no de RxJS (**Apéndice A06**), ni la medición del memory leak en el Memory panel, que es el objeto de estudio de la **Fase 10 §5.7** y del incidente 16. Acá está el **mecanismo** de cerrar una suscripción; allá está el **caso clínico** de no haberla cerrado.

---

## Índice

- [1. El `pipe` y los dos árboles de import](#1-el-pipe-y-los-dos-árboles-de-import)
- [2. ⚰️ `rxjs-compat`: dos sintaxis en el mismo repositorio](#2-️-rxjs-compat-dos-sintaxis-en-el-mismo-repositorio)
- [3. `map` — transformar lo que pasa](#3-map--transformar-lo-que-pasa)
- [4. `tap` — mirar sin tocar](#4-tap--mirar-sin-tocar)
- [5. `catchError` — el error que no debe matar el stream](#5-catcherror--el-error-que-no-debe-matar-el-stream)
- [6. `switchMap` vs `mergeMap` — la decisión que pierde datos](#6-switchmap-vs-mergemap--la-decisión-que-pierde-datos)
- [7. `take` — solo el primer valor](#7-take--solo-el-primer-valor)
- [8. Los dos que no estaban en la lista: `timeout` y `withLatestFrom`](#8-los-dos-que-no-estaban-en-la-lista-timeout-y-withlatestfrom)
- [9. La suscripción: quién la cierra](#9-la-suscripción-quién-la-cierra)
- [10. ⚰️ Sobreusar RxJS es el antipatrón](#10-️-sobreusar-rxjs-es-el-antipatrón)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. El `pipe` y los dos árboles de import

Un operador de RxJS 6 es una **función que recibe un observable y devuelve otro**. No es un método del observable. Por eso se encadenan dentro de `.pipe(...)`, separados por comas, y por eso el orden importa: el valor entra por arriba y va bajando.

```typescript
// La forma canonica de RxJS 6. Cada operador recibe lo que emitio el anterior.
source$.pipe(
  timeout(REQUEST_TIMEOUT_MS),   // 1. corta si tarda demasiado
  map(function (x) { ... }),     // 2. transforma lo que llego
  catchError(function (e) { ... })  // 3. atrapa lo que exploto arriba
)
```

Y de ahí sale la única regla de imports que necesitas, que es la que más tiempo hace perder porque el editor no ayuda:

| Qué importas | De dónde | Ejemplos del proyecto |
|---|---|---|
| **Operadores** (van dentro de `pipe`) | `rxjs/operators` | `map`, `tap`, `catchError`, `switchMap`, `mergeMap`, `take`, `takeUntil`, `timeout`, `withLatestFrom` |
| **Tipos y creadores** (crean observables o los describen) | `rxjs` | `Observable`, `of`, `throwError`, `Subject`, `BehaviorSubject`, `ReplaySubject`, `EMPTY` |

```typescript
// Así arranca cualquier effect del proyecto. Dos líneas, dos arboles.
import { of } from 'rxjs';
import { map, mergeMap, catchError, timeout } from 'rxjs/operators';
```

> ⚠️ **Tu autocompletado te va a ofrecer el import equivocado.** Con `rxjs-compat` instalado (§2) existen tres rutas válidas para `map` —`rxjs/operators`, `rxjs/add/operator/map` y `rxjs/operator/map`— y el editor las lista todas sin decirte cuál es la de esta década. Si aceptas la sugerencia sin mirar, el código compila y funciona, y acabas de meter sintaxis de 2017 en un archivo de 2019. **La regla: si va dentro de un `pipe`, sale de `rxjs/operators`. Punto.**

---

## 2. ⚰️ `rxjs-compat`: dos sintaxis en el mismo repositorio

Este proyecto tiene `rxjs-compat` en su `package.json`. Es la pieza de contexto más importante del apéndice y explica una rareza que si no vas a atribuir a un error tuyo: **vas a encontrar dos formas distintas de escribir lo mismo, y las dos compilan.**

```typescript
// Sintaxis vieja (RxJS 5). Solo funciona porque rxjs-compat esta instalado.
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';

this.http.get(url).map(function (r) { return r.data; });
```

```typescript
// Sintaxis de RxJS 6, la única que este curso escribe.
import { map } from 'rxjs/operators';

this.http.get(url).pipe(map(function (r) { return r.data; }));
```

**Qué es y por qué está ahí.** RxJS 6 (2018) rompió la API: los operadores dejaron de ser métodos del prototipo de `Observable` y pasaron a funciones sueltas dentro de `pipe`. Para que miles de proyectos pudieran subir de versión sin reescribir todos sus archivos el mismo día, el equipo publicó `rxjs-compat`: un paquete que vuelve a parchar el prototipo y restaura las rutas de import viejas. Era un **andamio de migración**, pensado para quitarse. Casi nadie lo quitó.

### 2.1 Por qué esto es una trampa y no una comodidad

El parcheo del prototipo es un **efecto global**. Cuando un archivo cualquiera del proyecto hace `import 'rxjs/add/operator/map'`, el método `.map()` queda disponible **en toda la aplicación**, también en archivos que nunca importaron nada. Consecuencia directa, y es la que arruina la tarde:

> **Puedes borrar un `import 'rxjs/add/operator/map'` que parece no usarse y romper un archivo que está en otra carpeta y que no menciona ese import por ninguna parte.** El error llega en tiempo de ejecución, dice `x.map is not a function`, y apunta a un archivo que tú no tocaste.

Por eso limpiar `rxjs-compat` no es una tarea de limpieza: es una migración pequeña, con su rama y su prueba de humo completa.

### 2.2 Cómo saber si de verdad se está usando

Dos `grep` contestan la pregunta entera:

```bash
# ¿Alguien importa por las rutas viejas? Si esto no devuelve nada,
# rxjs-compat esta instalado pero nadie depende de el.
grep -rn "rxjs/add/\|from 'rxjs/Observable'\|from 'rxjs/Subject'" src/

# ¿Alguien encadena operadores sin pipe? La firma de la sintaxis vieja.
grep -rn "\.map(\|\.filter(\|\.switchMap(\|\.catchError(" src/ | grep -v "\.pipe("
```

Si el primero sale vacío, el paquete es peso muerto y puede quitarse en un `npm uninstall` con una prueba de humo — pero eso es una decisión de proyecto, no un hotfix, y lo escribes en un ticket. Si devuelve resultados, esos archivos son de la era anterior y hay que migrarlos antes de tocar nada.

💸 **Deuda intencional del curso.** El proyecto arrastra `rxjs-compat` sin necesitarlo: **todo el código que escribes en este tutorial usa `.pipe()`**. Lo correcto sería quitarlo y cerrar la puerta a que alguien escriba sintaxis de 2017 sin querer. **En Track A no se paga** porque el riesgo (§2.1) no está en tu código sino en el que no has leído, y porque quitarlo bloquea absolutamente nada de lo que tienes que hacer esta semana. Lo que sí haces es **reconocerlo**: cuando veas un `.map(` sin `pipe`, ya sabes que no es un error de otro, es otra época conviviendo con la tuya.

> ⚠️ **`rxjs-compat` no existe para RxJS 7.** Su última línea es la 6.x, así que hay que quitarlo **antes** de subir RxJS, no después. Ahora bien, conviene tener clara la fecha de vencimiento: **no bloquea el salto a Angular 9**, que sigue sobre RxJS 6.x —eso está precisado en el **Apéndice A10 §7**—; bloquea el salto a **RxJS 7**, que llega bastante más adelante en el camino y es territorio del **Apéndice A11**. Sigue siendo un bloqueante real; simplemente no es el de mañana.

---

## 3. `map` — transformar lo que pasa

El más fácil y el más usado (59 apariciones en el curso). Recibe cada valor que emite el observable, devuelve otro, y el resto de la cadena ve el nuevo.

```typescript
// En un effect: la respuesta HTTP entra, sale una acción de NgRx.
this.patientsService.getPatients().pipe(
  map(function (patients: any[]) {
    return PatientsActions.loadPatientsSuccess({ patients: patients });
  })
)
```

El único matiz que confunde, y confunde mucho al llegar de backend: **no es `Array.map`, aunque se llame igual.** `Array.map` recorre los elementos de una colección que ya tienes; `map` de RxJS transforma **una emisión**, y esa emisión puede ser un arreglo entero. Cuando lo que quieres es transformar los elementos de dentro, necesitas los dos, uno dentro del otro:

```typescript
// map de RxJS: se ejecuta UNA vez, con el arreglo completo.
// map de Array: se ejecuta una vez por paciente, adentro.
this.patientsService.getPatients().pipe(
  map(function (patients: any[]) {
    return patients.map(function (p) { return { ...p, fullName: p.name + ' ' + p.surname }; });
  })
)
```

Si alguna vez ves `map(function (p) { return p.name; })` sobre un observable de arreglos y el resultado es `undefined`, es esto: le pediste la propiedad `name` a un arreglo.

---

## 4. `tap` — mirar sin tocar

`tap` recibe cada valor, hace algo con él, y **deja pasar el valor intacto**. Es el operador de los efectos secundarios: no transforma, no filtra, no atrapa. Si lo quitas de un `pipe`, la cadena sigue produciendo exactamente lo mismo.

Tiene un solo uso real en todo el curso, en `auth.service.ts` de la **Fase 3**, y es el uso canónico: guardar algo de paso.

```typescript
// El login devuelve el token al componente Y de paso lo guarda.
// tap no toca la respuesta: el subscribe de arriba recibe lo mismo.
login(username: string, password: string): Observable<{ token: string; expiresIn: number }> {
  return this.http.post<{ token: string; expiresIn: number }>(
    environment.apiUrl + '/login',
    { username: username, password: password }
  ).pipe(
    tap(function (this: AuthService, response) {
      localStorage.setItem(TOKEN_KEY, response.token);
    }.bind(this))
  );
}
```

### 4.1 Su segundo oficio: depurar un `pipe` sin romperlo

Este es el motivo por el que conviene tener `tap` en la cabeza aunque el proyecto casi no lo use. Cuando una cadena de cuatro operadores devuelve algo raro y no sabes cuál es el culpable, **metes `tap` entre medio y miras**:

```typescript
source$.pipe(
  timeout(REQUEST_TIMEOUT_MS),
  tap(function (v) { console.log('1. después del timeout:', v); }),
  map(function (x) { return transform(x); }),
  tap(function (v) { console.log('2. después del map:', v); }),
  catchError(function (e) { return of(fallback); })
)
```

Si el log 1 aparece y el 2 no, el problema está en el `map`. Si no aparece ninguno, el observable no está emitiendo y el problema está más arriba —o nadie se suscribió (§10). Es diagnóstico por bisección, cuesta treinta segundos, y no cambia el comportamiento del código mientras depuras.

> 💡 Los `tap` de depuración se borran antes del commit. Un `console.log` dentro de un `tap` en producción es un log por cada emisión, y en un dashboard eso son miles.

---

## 5. `catchError` — el error que no debe matar el stream

Un observable que emite un error **termina**. No emite más, y quien estaba suscrito deja de recibir para siempre. En un effect de NgRx eso significa que el effect muere y la aplicación se congela en silencio: nadie vuelve a escuchar esa acción hasta que recargues la página.

`catchError` intercepta ese error y **devuelve otro observable en su lugar**, con lo que el stream sobrevive. De ahí sale el `of(...)` que aparece cuarenta y cinco veces en el curso y que confunde la primera vez:

```typescript
catchError(function (error: any) {
  // of(x) crea un observable que emite x y termina. catchError EXIGE
  // devolver un observable, no un valor: por eso el of.
  return of(PatientsActions.loadPatientsFailure({ error: error }));
})
```

Las tres cosas que puedes devolver, y qué significa cada una:

| Devuelves | Qué pasa | Cuándo |
|---|---|---|
| `of(algunaAccion)` | El stream sigue vivo y emite esa acción | **Siempre, en effects.** El error se convierte en estado |
| `EMPTY` | El stream termina sin emitir nada, sin error | Cuando el fallo no le importa a nadie. Raro y peligroso: nadie se entera |
| `throwError(error)` | Vuelves a lanzar. El stream muere igual | Solo en interceptores, para que el siguiente eslabón decida (**Fase 3 §5.3**) |

> 🧭 **Dónde lo pones importa más que ponerlo.** `catchError` va **dentro** del `pipe` interno —el de la llamada HTTP—, nunca en el `pipe` externo del effect. Si va fuera, atrapa el error igual y la pantalla hasta parece funcionar, pero el stream de acciones ya murió y el botón de reintentar no vuelve a hacer nada nunca. Ese síntoma exacto, con su reproducción paso a paso, es la **Fase 1 §6** y su ejercicio 24. Es el error de RxJS más caro del curso y el que más veces se comete.

---

## 6. `switchMap` vs `mergeMap` — la decisión que pierde datos

> 🕵️ **El bug que produce esta decisión, perseguido de punta a punta**, está en [`forense-fase-05.md`](forense-fase-05.md) —desde el lado de la aplicación— y en [`forense-fase-12.md`](forense-fase-12.md) —desde el lado del test que no lo caza—.

**La sección central de este apéndice.** Los dos hacen lo mismo: reciben un valor y arrancan con él un observable nuevo (típicamente una petición HTTP). La diferencia está en qué hacen cuando llega un **segundo** valor antes de que el primero termine.

- **`switchMap` cancela el anterior.** Se desuscribe del observable en curso —lo que en HTTP significa abortar la petición— y se queda solo con el último. *Switch* = cambiar de canal.
- **`mergeMap` no cancela nada.** Deja los dos corriendo en paralelo y emite lo que vaya llegando, en el orden en que llegue. *Merge* = fusionar.

```typescript
// LECTURA: switchMap. Si el usuario pide la lista dos veces seguidas,
// la primera respuesta ya no le interesa a nadie. Cancelarla es correcto.
loadPatients$ = createEffect(function (this: PatientsEffects) {
  return this.actions$.pipe(
    ofType(PatientsActions.loadPatients),
    switchMap(function (this: PatientsEffects) {
      return this.patientsService.getPatients().pipe(
        timeout(REQUEST_TIMEOUT_MS),
        map(function (patients: any[]) {
          return PatientsActions.loadPatientsSuccess({ patients: patients });
        }),
        catchError(function (error: any) {
          return of(PatientsActions.loadPatientsFailure({ error: error }));
        })
      );
    }.bind(this))
  );
}.bind(this));
```

```typescript
// ESCRITURA: mergeMap. Si el usuario guarda dos pacientes seguidos,
// los dos tienen que guardarse. Cancelar el primero PIERDE DATOS.
createPatient$ = createEffect(function (this: PatientsEffects) {
  return this.actions$.pipe(
    ofType(PatientsActions.createPatient),
    mergeMap(function (this: PatientsEffects, action: any) {
      return this.patientsService.createPatient(action.patient).pipe(
        timeout(REQUEST_TIMEOUT_MS),
        map(function (created: any) {
          return PatientsActions.createPatientSuccess({ patient: created });
        }),
        catchError(function (error: any) {
          return of(PatientsActions.createPatientFailure({ error: error }));
        })
      );
    }.bind(this))
  );
}.bind(this));
```

### 6.1 La regla, en una línea

> 🧠 **Lectura: `switchMap`. Escritura: `mergeMap`.** Si el resultado de la operación anterior deja de importar cuando llega una nueva, cancela. Si cada operación tiene que completarse pase lo que pase, no canceles.

### 6.2 Por qué el bug es peor de lo que parece

El ticket de la **Fase 12** dice: *"si guardo un paciente y sin esperar guardo otro, a veces se pierde el primero"*. La causa es un `switchMap` donde debía haber un `mergeMap`. Pero el mecanismo tiene un detalle sucio que conviene entender antes de prometerle a alguien que lo arreglaste:

**`switchMap` cancela la suscripción del lado del navegador, no la operación del lado del servidor.** Cuando aborta el XHR pueden pasar dos cosas, y las dos son malas de forma distinta:

- La petición no llegó a salir o el servidor no la procesó → el paciente **no se guardó**. Pérdida limpia. El usuario ve que falta y lo vuelve a escribir, refunfuñando.
- La petición sí llegó y el servidor la procesó → el paciente **sí se guardó**, pero el navegador ignoró la respuesta, así que la acción `createPatientSuccess` nunca se despachó y el store no se enteró. **La pantalla dice que no está y la base de datos dice que sí.** Y el "a veces" del ticket sale de acá: depende de la latencia, o sea de la red, o sea de la hora del día.

Esa segunda variante es la que convierte un bug de operador en un problema de datos, y la razón por la que este apéndice le dedica su sección más larga a dos palabras que se diferencian en cuatro letras.

### 6.3 Por qué el test no lo caza

Un test con **una sola** acción pasa en verde con los dos operadores, porque sin concurrencia se comportan idénticos. Hay que emitir dos acciones solapadas para que la diferencia exista. Eso no es material de este apéndice —es el "rompe a propósito" de la **Fase 12 §6** y su ejercicio 30—, pero sí es la moraleja que se lleva quien elige el operador: **este bug es invisible para cualquier prueba que no simule concurrencia**, incluida la manual de "lo probé y funciona".

> 📝 **Nota de época.** Hoy dirías `concatMap` para una escritura, que además **serializa** las peticiones y garantiza el orden. Existía en RxJS 6.5.5 y habría sido mejor opción. LabCore usa `mergeMap`, así que eso es lo que el curso escribe y lo que vas a mantener: con `mergeMap` los dos guardados llegan, pero el orden en que el servidor los procese no está garantizado. Para pacientes independientes da igual; si algún día alguien guarda dos veces el *mismo* registro, esa diferencia deja de dar igual.

---

## 7. `take` — solo el primer valor

`take(n)` deja pasar las primeras `n` emisiones y después **completa el observable**, lo que se lleva un regalo importante: al completar, **la suscripción se cierra sola**. Es la única forma de suscribirse sin tener que acordarse de desuscribir (§9).

En este proyecto `take` no aparece en el código de producción: aparece como **el fix** de la **Fase 9**, donde el componente de entrega congela una foto del resultado al abrir la vista y genera el PDF con datos viejos.

```typescript
// Leer el estado ACTUAL del store una sola vez, en el instante de generar.
// take(1) toma el primer valor que emita el selector y cierra. El componente y
// el servicio son los de la Fase 9 §5.2: ReportComponent y ReportService.
onGenerate() {
  this.store.select(function (state: any) { return state.results.items; })
    .pipe(take(1))
    .subscribe(function (this: ReportComponent, results: any[]) {
      this.reportService.generate(this.buildSnapshot(results));
    }.bind(this));
}
```

Que esto sea legítimo y no un parche merece decirse, porque el instinto de quien viene de aprender RxJS moderno es que suscribirse a mano siempre está mal: **hay operaciones que no son un flujo, son una lectura puntual.** "Dame el estado que hay ahora mismo para meterlo en este PDF" es una de ellas. El `async` pipe no sirve acá porque no hay nada que pintar, y una suscripción viva tampoco, porque el PDF es una foto por definición.

> 💡 `first()` hace casi lo mismo, con una diferencia que muerde: si el observable completa sin emitir nada, `take(1)` termina en silencio y `first()` **lanza un error**. Este curso usa `take(1)` siempre. Si ves un `first()` en código ajeno, comprueba que alguien esté atrapando ese error.

---

## 8. Los dos que no estaban en la lista: `timeout` y `withLatestFrom`

No son de los "seis", pero aparecen 49 y 8 veces respectivamente, así que te los vas a encontrar antes que a `take`.

### 8.1 `timeout` — poner un límite a la espera

`HttpClient` no trae timeout propio: si el servidor recibe la petición y no responde nunca, la petición se queda en *pending* indefinidamente y la pantalla se queda cargando para siempre. `timeout(ms)` corta esa espera y **emite un error**, que el `catchError` de abajo convierte en una acción de fallo.

```typescript
return this.patientsService.getPatients().pipe(
  timeout(REQUEST_TIMEOUT_MS),   // 10000. Va PRIMERO: mide la petición, no el map
  map(function (patients: any[]) { ... }),
  catchError(function (error: any) { ... })   // aquí aterriza el TimeoutError
);
```

Dos cosas que hay que tener claras y que la **Fase 4 §5.4** desarrolla con su modo de caos `CHAOS=timeout`: va **dentro** del pipe interno, por la misma razón que `catchError`; y el error que produce es un `TimeoutError`, indistinguible de un fallo de red si tu `catchError` no lo mira. De ahí sale el síntoma de "se cayó a los diez segundos exactos": cuando el número es redondo y siempre el mismo, no busques un servidor, busca una constante.

### 8.2 `withLatestFrom` — leer otro stream sin dispararte

Combina el valor que acaba de emitir tu stream con **el último valor** de otro, sin que el segundo pueda disparar la cadena. En la **Fase 8** se usa para leer el store en el momento en que llega una acción:

```typescript
// El stream lo gobierna la acción. El store solo aporta su último valor.
this.actions$.pipe(
  ofType(ResultsActions.validateResultSuccess),
  withLatestFrom(this.store),
  map(function (pair: any) {
    var action = pair[0];   // lo que emitio el stream principal
    var state = pair[1];    // la foto del store en ese instante
    ...
  })
)
```

Emite un arreglo `[valorPropio, ultimoValorDelOtro]`, y esa desestructuración por índice es la mitad de su fealdad.

> ⚠️ **`withLatestFrom` no emite nada hasta que el segundo observable haya emitido al menos una vez.** Si el store todavía no tiene el slice cargado —porque el usuario entró directo por URL a una pantalla profunda, sin pasar por la que carga los datos—, el effect **se queda callado para siempre y no da ningún error**. Ni excepción, ni acción de fallo, ni log: simplemente no pasa nada. Es una de las formas más limpias que tiene RxJS de no funcionar sin decírtelo, y si algún día un effect "no se ejecuta" y el `ofType` es correcto, mira acá antes que a ninguna otra parte.

---

## 9. La suscripción: quién la cierra

> 🕵️ **Cómo se ve un connection leak desde el navegador** —contar antes de medir, y el heap snapshot sólo al final— está en [`forense-fase-10.md`](forense-fase-10.md).

Un observable no hace **nada** hasta que alguien se suscribe. `subscribe()` es lo que abre el canal, y devuelve una `Subscription`, que es el objeto con el que se cierra. Mientras nadie lo cierre, el callback se sigue ejecutando cada vez que la fuente emita — aunque el componente que lo abrió ya no esté en pantalla.

Si vienes de backend, la analogía es exacta: **es un connection leak**. Abriste algo que consume recursos y no lo cerraste. La diferencia es que acá no hay un pool que te avise con un timeout; crece callado.

### 9.1 Las tres formas de cerrarla

**1. Guardar la `Subscription` y cerrarla a mano.** Explícita y verbosa. Se vuelve incómoda a partir de la tercera suscripción, que es exactamente donde está la mayoría de los componentes de este proyecto.

```typescript
private sub = new Subscription();

ngOnInit() {
  // add() acumula. Un solo unsubscribe las cierra todas.
  this.sub.add(this.store.select(selectAllPatients).subscribe(...));
  this.sub.add(this.store.select(selectPatientsLoading).subscribe(...));
}

ngOnDestroy() {
  this.sub.unsubscribe();
}
```

**2. `takeUntil(this.destroy$)` — el patrón de la época.** Un `Subject` que emite una vez cuando el componente muere; `takeUntil` corta todas las suscripciones a la vez. Es lo que vas a encontrar en LabCore cuando *sí* se acordaron de cerrar.

```typescript
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

private destroy$ = new Subject<void>();

ngOnInit() {
  this.store.select(selectAllPatients)
    .pipe(takeUntil(this.destroy$))
    .subscribe(...);
}

ngOnDestroy() {
  this.destroy$.next();       // avisa a todos los takeUntil que corten
  this.destroy$.complete();   // y cierra el propio Subject
}
```

> ⚠️ **`takeUntil` tiene que ir el último del `pipe`.** Si pones operadores después, esos siguen enganchados a la fuente y el corte no es completo. Es la trampa clásica del patrón y no produce ningún error visible: solo un leak más pequeño que sigue ahí después de "haberlo arreglado".

**3. El `async` pipe — que no puede olvidarse.** Angular suscribe al entrar la vista y desuscribe al salir. No hay `ngOnDestroy` que escribir ni nada que recordar.

```html
<!-- El observable se declara en el componente y la plantilla lo consume. -->
<div *ngIf="patients$ | async as patients">
  <app-patient-row *ngFor="let p of patients" [patient]="p"></app-patient-row>
</div>
```

### 9.2 Por qué este curso no usa el `async` pipe

Es la pregunta que la **Fase 1** dejó abierta, y la respuesta honesta tiene dos mitades.

**La mitad de fidelidad:** LabCore no lo usa. Sus componentes son gordos, se suscriben en `ngOnInit` y copian el estado a campos propios (`this.patients = patients`). Migrar a `async` no es cambiar una línea: es reescribir cada plantilla que consuma esos campos, porque el tipo cambia de `Patient[]` a `Observable<Patient[]>`. Es un refactor de pantalla completa, no un hotfix, y este curso enseña a mantener lo que hay.

**La mitad pedagógica, que importa más:** el leak es el **objeto de estudio** de la Fase 10. Si el curso usara `async` desde el principio, el incidente 16 no podría existir, y con él se iría el ejercicio de abrir el Memory panel y ver crecer las suscripciones al entrar y salir del dashboard cinco veces. Se aprende más arreglando un leak que no teniéndolo nunca.

Y una advertencia para cuando sí lo uses, porque es la trampa que nadie cuenta: **cada `| async` es una suscripción independiente.** Dos `| async` sobre el mismo observable son dos suscripciones; si el observable es *cold* —un `http.get()` directo, por ejemplo— son **dos peticiones HTTP**. Con selectores de NgRx no pasa, porque el store es *hot* y comparte. Con un servicio que devuelve `HttpClient` directo, sí pasa, y se ve en Network duplicado.

| Forma | Cuándo | Costo |
|---|---|---|
| `async` pipe | Cuando el valor solo se pinta | Ninguno. Es lo correcto por defecto |
| `takeUntil(destroy$)` | Cuando el componente necesita el valor en TypeScript | Un `Subject`, un `ngOnDestroy`, y acordarse de ponerlo el último |
| `Subscription.add()` | Una o dos suscripciones y ganas de ser explícito | Verboso a partir de tres |
| `take(1)` | Lectura puntual, no un flujo (§7) | Ninguno: se cierra solo al completar |
| `.subscribe()` a pelo | **Nunca, salvo que la deuda esté declarada** | Un leak. En este proyecto, el incidente 16 |

> 🧭 El caso completo —medirlo, reproducirlo, capturar el heap snapshot y escribir la regresión— es la **Fase 10 §5.7**. Acá está el mecanismo; allá está la autopsia.

---

## 10. ⚰️ Sobreusar RxJS es el antipatrón

Todo lo anterior explica cómo usar RxJS. Esta sección explica cuándo **no**, y es la que más veces salva un code review.

**El `if` que no necesitaba ser un `filter`.** Si el dato ya está en una variable, es una variable. Envolverlo en `of(x).pipe(filter(...))` para "ser reactivo" no aporta nada y añade una capa que hay que desmontar mentalmente para leer el archivo. Este proyecto no usa `filter` de RxJS ni una sola vez, y no le hace falta.

**La cadena de seis operadores.** Un `pipe` con seis operadores es ilegible para el que llega, y para el que lo escribió tres meses después. Si tienes que depurarlo con `tap` intercalados (§4.1) para entender qué hace, ya es demasiado largo. Partir la cadena en dos observables con nombre —o sacar la lógica a una función pura y llamarla desde un `map`— casi siempre gana.

**El `subscribe` dentro de otro `subscribe`.** Es el antipatrón más frecuente y el más fácil de detectar:

```typescript
// MAL. Dos suscripciones anidadas: nadie cierra la de dentro, no hay forma
// de cancelar la petición en curso, y los errores de la interna no llegan
// al catchError de la externa.
this.route.params.subscribe(function (params) {
  this.patientsService.getById(params.id).subscribe(function (patient) {
    this.patient = patient;
  }.bind(this));
}.bind(this));
```

```typescript
// BIEN. switchMap encadena y además cancela la petición anterior si el
// usuario navega rápido de un paciente a otro. Una sola suscripción.
this.route.params.pipe(
  switchMap(function (this: PatientDetailComponent, params: any) {
    return this.patientsService.getById(params.id);
  }.bind(this)),
  takeUntil(this.destroy$)
).subscribe(function (this: PatientDetailComponent, patient: any) {
  this.patient = patient;
}.bind(this));
```

**El `Subject` que es un store de estado.** Un `BehaviorSubject` compartido entre varios servicios y mutado desde todos ellos es un store sin reglas: no hay historial, no hay DevTools, y reconstruir qué pasó exige leer todos los sitios que lo tocan. Este proyecto ya tiene un store con reglas, y la conversación sobre cuándo NgRx pesa demasiado está en la **Fase 1 §4**.

**Y el clásico de todos: el observable que nadie suscribió.** Un `this.http.get(url)` cuyo resultado no se suscribe **no lanza ninguna petición**. No hay error, no hay warning, y en Network no aparece nada — que es lo que hace que la gente busque el problema en el backend. Si tu petición "no sale", cuenta los `subscribe` antes de nada.

---

## 🧭 Cuándo usar qué

Entrada por intención. Cada fila es "necesito hacer esto".

| Necesito | Operador | Trampa que trae |
|---|---|---|
| Transformar cada valor que pasa | `map` | No es `Array.map`: recibe la emisión entera (§3) |
| Guardar o loguear de paso, sin tocar el valor | `tap` | Ninguna. Bórralo del commit si era para depurar |
| Que un error no mate el stream | `catchError` | Va **dentro** del pipe interno, o el effect muere (§5) |
| Devolver un valor desde `catchError` | `of(...)` | Tiene que ser un observable, no un valor suelto |
| Lanzar una petición por cada acción, **de lectura** | `switchMap` | Cancela la anterior. Perfecto acá, fatal en escritura |
| Lanzar una petición por cada acción, **de escritura** | `mergeMap` | No cancela. Tampoco garantiza el orden (§6) |
| Leer el estado una sola vez, ahora | `take(1)` | Ninguna. Además cierra la suscripción sola |
| Que la espera no sea infinita | `timeout(ms)` | Va primero en el pipe interno; produce `TimeoutError` |
| Combinar mi acción con el store | `withLatestFrom` | Silencio total si el otro no ha emitido nunca (§8.2) |
| Cerrar suscripciones al destruir el componente | `takeUntil(destroy$)` | Tiene que ir el **último** del pipe |
| Solo pintar el valor en la plantilla | `async` pipe | Cada `async` de la plantilla es una suscripción propia (§9.2) |
| Filtrar un dato que ya tengo en una variable | **Ninguno.** Un `if` | Envolverlo en RxJS no lo hace mejor (§10) |
| Encadenar dos peticiones | `switchMap`, no `subscribe` anidado | El anidado no se cancela ni propaga errores (§10) |
| Compartir estado entre servicios | **Ninguno.** El store | Un `BehaviorSubject` global es un store sin reglas |

---

## ⚠️ Advertencias

**`rxjs.dev` documenta RxJS 7 y no te lo dice.** Es la advertencia central de este apéndice porque afecta a cada búsqueda que hagas. El sitio oficial sirve por defecto la versión actual, y entre tu 6.5.5 y esa hay cambios que compilan distinto: en RxJS 7.2+ los operadores se exportan también desde la raíz `rxjs` (en la tuya, **solo** desde `rxjs/operators`), `toPromise()` está deprecado en favor de `firstValueFrom`/`lastValueFrom` (que en la tuya **no existen**), y varias firmas cambiaron. Si copias un ejemplo de la doc y el import no compila, no estás loco: estás leyendo sobre otra versión. Todos los enlaces de este apéndice se abren asumiendo eso.

**`rxjs-compat` hace que sintaxis de 2017 compile sin avisar, y quitarlo rompe archivos que no lo mencionan.** El parcheo del prototipo es global: un `import 'rxjs/add/operator/map'` en un archivo habilita `.map()` en todos los demás. Borrarlo produce un `x.map is not a function` en tiempo de ejecución, en otro archivo, que nadie va a relacionar con tu commit. Antes de tocarlo, los dos `grep` de §2.2. Y nunca en un hotfix.

**Un observable que nadie suscribe no hace absolutamente nada.** Ni petición, ni error, ni rastro en Network. Es el primer bug de RxJS que comete todo el mundo y el que más tiempo hace perder porque se busca en el sitio equivocado — normalmente en el servidor.

**`switchMap` en una escritura pierde datos, y a veces los pierde de la peor manera.** No solo puede cancelar el guardado: puede dejar que el servidor lo procese mientras el navegador ignora la respuesta, con lo que la pantalla y la base de datos quedan diciendo cosas distintas. Ningún test de una sola acción lo detecta. Ninguna prueba manual de "lo intenté y funcionó" lo detecta.

**Un `catchError` mal colocado no se nota hasta el segundo error.** Fuera del `pipe` interno, el primer fallo se maneja y todo parece bien; lo que murió es el stream, y eso solo se descubre cuando alguien pulsa reintentar y no pasa nada. Es la razón por la que la Fase 1 le dedica un ejercicio de diagnóstico completo.

**No metas RxJS donde no hay asincronía.** El coste de una cadena de operadores no es de rendimiento, es de lectura: cada operador es una cosa más que el próximo tiene que desmontar en la cabeza para entender qué hace el archivo. En un sistema que se mantiene, eso se paga todos los días.

---

## 📚 Referencias

- https://rxjs.dev/guide/operators — la guía de operadores, incluido el diagrama de qué operador elegir. ⚠️ Documenta RxJS 7: los ejemplos de import de la raíz `rxjs` **no** funcionan en tu 6.5.5.
- https://rxjs.dev/api/operators/switchMap y https://rxjs.dev/api/operators/mergeMap — abre los dos en pestañas contiguas y compara sus diagramas de canicas: la diferencia de §6 se ve mejor dibujada que explicada.
- https://rxjs.dev/api/operators/takeUntil — el patrón de §9.1. ⚠️ Mismo aviso de versión que arriba; en 6.5.5 se importa de `rxjs/operators`, como en la **Fase 10 §5.7**.
- https://rxjs.dev/api/operators/timeout — el operador de §8.1, con la forma del `TimeoutError` que produce.
- https://github.com/ReactiveX/rxjs/blob/6.x/docs_app/content/guide/v6/migration.md — la guía oficial de migración de RxJS 5 a 6 **en la rama 6.x**, que es la que explica qué hace `rxjs-compat` y cómo quitarlo. Es la fuente de la §2 y la única página de esta lista que habla de tu versión sin advertencias.
- https://www.npmjs.com/package/rxjs-compat — la ficha del paquete. Vale por una línea: su última versión publicada es de la línea 6, y eso es lo que lo convierte en un bloqueante de migración.
- https://github.com/ReactiveX/rxjs-tslint — la herramienta automática que convierte sintaxis encadenada en `pipe`. ⚠️ Sirve para hacerse una idea del tamaño del trabajo; el resultado se revisa a mano, archivo por archivo, y nunca se commitea a ciegas.
- https://rxmarbles.com — diagramas de canicas interactivos. Para `switchMap` y `mergeMap` es la forma más rápida de entender la diferencia: arrastras las emisiones y ves qué sale.
- https://v8.angular.io/guide/observables — cómo usa Angular 8 los observables, en la doc de tu versión. Es donde vive la explicación oficial del `async` pipe de §9.
- https://blog.angular.io/rxjs-6-what-changed-so-far-2b6f7e9e2b6e — resumen de qué rompió RxJS 6. ⚠️ Es una entrada de blog de 2018 y las URLs de `blog.angular.io` se han movido; si no resuelve, la búsqueda es "rxjs 6 breaking changes pipeable operators".

> ⚠️ Los enlaces y sus contenidos pueden haber cambiado o desaparecido; verifícalos. Acá el riesgo tiene una forma concreta y conviene repetirlo: **`rxjs.dev` no tiene selector de versión visible**, así que todo lo que leas ahí es RxJS 7 salvo que la URL diga otra cosa. La única documentación que habla de tu 6.5.5 sin ambigüedad es la de la rama `6.x` del repositorio.

---

## 🧪 Ejercicios (8)

Cortos y de consulta. Sobre el proyecto del laboratorio, con el mock levantado (`npm run mock`).

1. Abre `patients.effects.ts` y lista, en tu cuaderno, cada operador del `pipe` y de qué árbol se importa (`rxjs` o `rxjs/operators`). Después corre `grep -rn "from 'rxjs" src/` y confirma que **ningún** archivo del proyecto importa de las rutas viejas de §2.
2. Corre los dos `grep` de §2.2. Escribe en dos líneas si `rxjs-compat` se puede quitar de este proyecto, cuál sería el comando, y **por qué no lo vas a hacer hoy**. La tercera respuesta es la más importante.
3. En un effect de lectura, mete tres `tap` de depuración entre los operadores existentes (§4.1). Levanta el mock con `CHAOS=timeout`, dispara la acción, y anota **cuál es el último `tap` que imprime**. Explica qué te dice eso sobre dónde se cortó la cadena. Borra los `tap` al terminar.
4. **Rompe a propósito.** Mueve el `catchError` de `loadPatients$` fuera del `switchMap`, al `pipe` externo. Apaga el mock, recarga, pulsa reintentar, vuelve a levantar el mock y pulsa reintentar otra vez. Documenta la secuencia de acciones en Redux DevTools y explica por qué la última no aparece. Revierte. (Es el ejercicio 24 de la **Fase 1** visto desde el operador.)
5. Cambia el `mergeMap` de `createPatient$` por `switchMap`. Guarda un paciente y, **sin esperar la respuesta**, guarda otro — usa el retardo de la pestaña Network para tener tiempo. Anota qué pasó en la pantalla, qué pasó en Redux DevTools, y **qué dice `db.json` del mock**. Si los tres no coinciden, acabas de reproducir §6.2. Revierte.
6. En `withLatestFrom` de la **Fase 8**: entra por URL directa a una pantalla de resultados sin pasar antes por la que carga los rangos. Anota qué hace el effect, qué aparece en la consola y qué aparece en DevTools. Explica en una línea por qué el silencio total es peor que un error.
7. Convierte una de las suscripciones del `PatientListComponent` al `async` pipe: declara `patients$` en el componente, usa `patients$ | async` en la plantilla, y borra el campo `patients`. Anota **cuántas líneas de plantilla tuviste que tocar** — ese número es la respuesta a §9.2. Hazlo en una rama aparte.
8. **Diagnóstico.** Un compañero te pasa este componente y te dice que "el detalle del paciente a veces muestra el anterior":

   ```typescript
   ngOnInit() {
     this.route.params.subscribe(function (params) {
       this.patientsService.getById(params.id).subscribe(function (patient) {
         this.patient = patient;
       }.bind(this));
     }.bind(this));
   }
   ```

   Sin ejecutarlo, escribe: cuántas suscripciones hay abiertas después de navegar entre cinco pacientes, por qué "a veces" muestra el anterior, qué operador lo arregla, y qué segunda cosa sigue mal aunque cambies el operador. Las cuatro respuestas están en §10 y §9.


> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida: el código que
> explica lo escriben las fases, y un tag que no apunta a un cambio no marca
> nada. Lo que salga de leerlo se commitea con el prefijo de la fase desde la
> que llegaste (`f01: …`), para que su `git log --oneline --grep '^f01'`
> siga completo. Y si un ejercicio produjo una medición, el número va en el
> mensaje de un tag anotado (`ej/a05/3`), que es donde no se pierde. La
> convención completa —tags de fase, de ejercicio y de incidente— está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **Marbles y `TestScheduler`** — la **Fase 12** (nota [A] de su cierre) sugería traerlos a este apéndice. Los dejo fuera a propósito: es un tema con curva de aprendizaje propia, se estudia un domingo y no se consulta con el jefe al lado, que es justo lo contrario de lo que un apéndice tiene que ser. Destino: **apéndice propio** o ampliación de la Fase 12.
- **`concatMap` no se usa y en escritura sería mejor que `mergeMap`** (§6, nota de época). Serializa las peticiones y garantiza el orden. Cambiarlo es una decisión de proyecto con efecto sobre todos los effects de escritura. Destino: decisión de proyecto; si se toma, tocar Fases 5, 7 y 8 a la vez.
- **Quitar `rxjs-compat`** es un bloqueante real de la migración de **RxJS**, no una tarea de limpieza — y no del salto a Angular 9, que convive con la 6.x sin problema. Quedó ubicado en el **Apéndice A10 §7** ("lo que no bloquea hoy y sí bloquea después") y desarrollado en el **Apéndice A11 §2** como la **primera de las cuatro puertas** del camino largo — la única, además, que se puede abrir hoy sin migrar nada, y por eso A11 la deja anotada como ticket propio.
- **El `withLatestFrom` que se queda mudo para siempre** (§8.2) es un incidente 🟠 esperando a ser escrito: "la validación no hace nada, pero solo si entras por el enlace que te pasaron por chat". No hay error, no hay log, y la reproducción depende de por dónde entres a la aplicación. Destino: **cuaderno de incidentes**.
- 🪦 **Corregido al escribir este apéndice.** La **Fase 10 §8** afirmaba que el ciclo de vida de suscripciones "no está entre los operadores de A05". Sí está: A05 §9 enseña el mecanismo (`Subscription`, `takeUntil`, `async` pipe) y la Fase 10 conserva el caso clínico (medición, heap snapshot, incidente 16). La línea de la Fase 10 quedó ajustada para reflejar el reparto, que es además el que ya anunciaba la **Fase 1** en su cierre.
