# 📎 Apéndice A07 — Estado con servicios y `BehaviorSubject`

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: [Fase 4](04-estado-servicios.md), [Fase 7](07-plantillas-versionadas.md), [Fase 9](09-hallazgos-severidad.md), [Fase 11](11-dashboard-alertas.md) · Versión cubierta: Angular 16.2.12 + RxJS 7.8.1

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve dos cosas: **entender el patrón de estado de CertCore de punta a punta**, y —lo que casi ningún artículo sobre el tema hace— **saber en qué punto exacto se queda corto**.

Ese segundo objetivo no es un adorno de honestidad. Es lo que separa haber elegido un patrón de haberlo heredado sin enterarse. La §8 es obligatoria y es la mitad del valor de este documento.

**Qué queda fuera:** NgRx, NGXS, Akita y cualquier otra librería de store. Se nombra qué problema resuelven (§8) y no se implementan: CertCore no las usa, y la decisión de 2022 que lo estableció sigue vigente. Quien quiera ver NgRx en un sistema heredado de verdad lo tiene en el Track A, donde es una fase entera. Los signals como estado tampoco entran: son experimentales en Angular 16, CertCore no los usa, y el horizonte está en **A11** 🔥.

---

## Índice

- [1. El patrón, en tres reglas](#1-el-patrón-en-tres-reglas)
- [2. Por qué el `Subject` no sale del servicio](#2-por-qué-el-subject-no-sale-del-servicio)
- [3. `providedIn: 'root'` frente a provider de ruta](#3-providedin-root-frente-a-provider-de-ruta)
- [4. Actualizar sin mutar, y por qué `OnPush` te obliga](#4-actualizar-sin-mutar-y-por-qué-onpush-te-obliga)
- [5. Derivar sin duplicar](#5-derivar-sin-duplicar)
- [6. `loading` y `error` dentro del estado](#6-loading-y-error-dentro-del-estado)
- [7. El ciclo de vida de una suscripción, de punta a punta](#7-el-ciclo-de-vida-de-una-suscripción-de-punta-a-punta)
- [8. ⚠️ Dónde este patrón se queda corto](#8-️-dónde-este-patrón-se-queda-corto)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. El patrón, en tres reglas

```ts
// 1. El sujeto es PRIVADO. Sólo el servicio empuja valores.
private readonly stateSubject = new BehaviorSubject<FeatureState<T>>(createInitialState<T>());

// 2. Lo público es un Observable de SÓLO LECTURA.
readonly state$ = this.stateSubject.asObservable();

// 3. Actualizar es REEMPLAZAR el estado, nunca modificarlo en sitio.
private patch(changes: Partial<FeatureState<T>>): void {
  this.stateSubject.next({ ...this.stateSubject.value, ...changes });
}
```

Y una cuarta que no es del patrón sino del proyecto, y que decide en qué archivo va cada método:

> 🧭 **Regla del proyecto: `*StateService` recuerda, `*ApiService` pide.** Un `*ApiService` traduce HTTP a dominio y no guarda nada; si le pides dos veces lo mismo, hace dos peticiones y le parece bien. Un `*StateService` es el único que tiene memoria, y es quien decide cuándo hace falta pedir. Si un método de un `*ApiService` empieza a acordarse de algo, está en el archivo equivocado.

**Por qué `BehaviorSubject` y no `Subject`.** Porque un `BehaviorSubject` **siempre tiene un valor**: quien se suscriba tarde recibe el actual inmediatamente, sin esperar a la siguiente emisión. Eso es lo que permite que un componente que se monta a los diez minutos pinte el estado que ya existía, y es también lo que hace que un `combineLatest` de varios estados emita desde el principio en vez de quedarse callado (**A06** §4).

**Una decisión que se ve poco y se agradece.** El estado de todas las features de CertCore tiene la misma forma (`FeatureState<T>`: `items`, `selected`, `loading`, `error`), pero **no hay una clase base** de la que hereden los servicios. Es deliberado: una `AbstractStateService<T>` ahorra treinta líneas por servicio y mete herencia justo donde peor envejece — el día que una feature necesite un campo más, o que `load()` tenga que hacer dos peticiones, la clase base se llena de ganchos y banderas. Cada `*StateService` se escribe explícito y se lee entero.

> ⚠️ **`createInitialState<T>()` es una función, no una constante.** Con `export const INITIAL_STATE = { items: [], … }` todas las features compartirían el mismo objeto y el mismo array, y el primer `push` de cualquiera aparecería en las demás. Es un bug de veinte segundos de escribir y de dos horas de encontrar.

---

## 2. Por qué el `Subject` no sale del servicio

`asObservable()` no es ceremonia: es lo único que separa un estado con dueño de un campo mutable global.

```ts
// ❌ Con el sujeto público, esto compila y funciona desde cualquier componente:
this.templateState.stateSubject.next({ items: [], selected: null, loading: false, error: null });
```

El día que el estado quede mal, la lista de sospechosos es **el repositorio entero**. Con `asObservable()`, la lista de sospechosos son los métodos públicos de un archivo — y como todos ellos pasan por el único `patch()` privado, hay exactamente un sitio donde poner el breakpoint.

Esa es la razón real de que `patch()` sea privado y sea el único que llama a `next()`. No es encapsulación por gusto: es que un solo `next()` en todo el servicio convierte "el estado quedó raro" en una sesión de depuración de cinco minutos.

**Los tres nombres, y por qué se distinguen por la palabra y no por el signo:**

```ts
private readonly stateSubject = …;   // el sujeto
readonly state$ = …;                 // el observable público
this.stateSubject.value;             // el valor síncrono, sólo dentro del servicio
```

Un `state` privado y un `state$` público difieren en un carácter, y ese carácter se pierde en un `Ctrl+F` a las siete de la tarde.

> ⚠️ **`.value` es legítimo dentro del servicio y sospechoso fuera.** Dentro, es cómo `patch()` compone el estado nuevo a partir del actual. Fuera —en un componente que hace `stateSubject.value` para leer sin suscribirse— es una lectura que no reacciona a nada: funciona la primera vez y se queda vieja para siempre. Si un componente necesita el valor actual una sola vez, el operador es `first()`, no `.value`.

---

## 3. `providedIn: 'root'` frente a provider de ruta

Es la decisión que fija el ciclo de vida, y sólo tiene dos opciones.

**`providedIn: 'root'`** — una instancia por aplicación, creada la primera vez que alguien la pide y viva hasta que se cierre la pestaña. **No se destruye al navegar.** Es lo que quieres para estado compartido entre features, y es lo que usan todos los `*StateService` de CertCore.

**Provider de ruta** (`providers: [X]` en una ruta con `loadComponent` o `loadChildren`) — una instancia por activación de esa ruta, destruida al salir. Es lo que quieres para estado que *pertenece* a una pantalla y no debe sobrevivirla: el borrador de un formulario largo, un asistente de varios pasos.

| | `providedIn: 'root'` | provider de ruta |
|---|---|---|
| Instancias | una, para toda la aplicación | una por activación de la ruta |
| Al navegar fuera | sobrevive | se destruye |
| Lo ven otras features | sí | no |
| Riesgo típico | datos del usuario anterior en memoria | perder estado que sí querías conservar |

De la primera opción salen dos consecuencias que hay que mirar de frente:

**Al volver a una pantalla ves un instante los datos de la visita anterior**, antes de que llegue el refresco. No es un bug: es la definición de tener estado. Se puede evitar llamando a `reset()` al entrar, y casi nunca conviene — un parpadeo de datos viejos molesta menos que un parpadeo de pantalla vacía.

**Si cierras sesión y no limpias, el estado del usuario anterior sigue en memoria**, listo para pintarse cuando entre el siguiente. Eso sí hay que resolverlo, y la forma que no obliga a nadie a acordarse es que el propio servicio escuche el cierre de sesión:

```ts
constructor() {
  // Cuando la sesión se cierra —por el botón o por un 401 que cazó el
  // interceptor— el estado del usuario anterior desaparece. Esto no es
  // rendimiento: es privacidad. Y al hacerlo aquí, ningún sitio que llame a
  // logout() tiene que acordarse de limpiar nada.
  this.authService.currentUser$
    .pipe(filter((user) => user === null))
    .subscribe(() => this.reset());
}
```

Nadie se desuscribe de esa suscripción y **es correcto**: los dos servicios son `providedIn: 'root'` y viven lo mismo que la aplicación, así que la suscripción no sobrevive a nadie (§7).

---

## 4. Actualizar sin mutar, y por qué `OnPush` te obliga

Con `ChangeDetectionStrategy.OnPush`, Angular sólo revisa un componente cuando pasa una de cuatro cosas: cambia la **referencia** de un `@Input`, se dispara un evento dentro de su propia plantilla, emite un observable conectado con `async` pipe, o alguien llama a `markForCheck()`.

Ninguna de las cuatro incluye *"alguien mutó un array que el componente ya tenía"*.

```ts
// ❌ La referencia no cambia. Nadie emite. La vista se queda mintiendo.
this.stateSubject.value.items.push(newTemplate);

// ✅ Objeto nuevo, array nuevo. La referencia cambia, el async pipe emite,
//    OnPush se despierta.
this.patch({ items: [...this.stateSubject.value.items, newTemplate] });
```

La variante cruel de este bug, y la razón de que la **Fase 6** lo use como pago de deuda: **una pantalla con `OnPush` se queda congelada y la pantalla heredada de al lado, que no tiene `OnPush`, se refresca igual.** El mismo bug se ve en un sitio y no en el otro, y quien lo reporte va a jurar que es cosa de la pantalla nueva.

**Las tres actualizaciones que hacen falta, escritas una vez:**

```ts
// Añadir
this.patch({ items: [...items, created] });

// Reemplazar uno
this.patch({ items: items.map((item) => (item.id === updated.id ? updated : item)) });

// Quitar
this.patch({ items: items.filter((item) => item.id !== removedId) });
```

> 💸 **La deuda que la Fase 4 declara y la Fase 6 paga.** `FeatureState<T>` nace con `items: T[]` y no `readonly items: readonly T[]`: el array que sale por `state$` es el mismo que guarda el servicio, y cualquier suscriptor puede hacerle `push` o `sort`. El borde HTTP sí está protegido —los `*ApiService` de la Fase 3 devuelven `readonly T[]`—; lo que queda abierto es de la puerta para adentro. Se paga en la **Fase 6**, con la pantalla que deja de repintar delante, y la factura se lee con `git diff fase-04 fase-06 -- src/app/core/state/`.

> 🧭 **La regla que sale de todo esto, y que aplica cuatro veces en el curso: un derivado sólo es seguro si sus entradas son inmutables.** Aparece con la severidad de los hallazgos (Fase 9), con el `status` del certificado (Fase 10) y con las agregaciones del dashboard (Fase 11). Si el dato del que derivas se puede mutar por debajo, tu cálculo es correcto y su resultado es basura, y nada en el código señala al culpable.

---

## 5. Derivar sin duplicar

Lo que se puede calcular no se guarda. Guardarlo son dos fuentes de verdad que se van a desincronizar, y la que se desincronice será la que esté pintada.

```ts
// Derivados simples: una vista del estado, con su distinctUntilChanged.
readonly templates$ = this.state$.pipe(map((state) => state.items), distinctUntilChanged());
readonly loading$   = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());

// Derivado con cálculo: se comparte, porque cuatro pantallas lo miran.
readonly latestVersions$ = this.templates$.pipe(
  map((templates) => /* agrupa por familia y se queda con la versión más alta */),
  shareReplay({ bufferSize: 1, refCount: true }),
);
```

Dos detalles que deciden si esto escala o no:

**El `distinctUntilChanged` de los derivados simples** evita que un cambio en `loading` despierte a quien sólo mira `items`. Sin él, cada emisión del estado despierta a todos los suscriptores de todos los derivados.

**El `refCount: true` del `shareReplay`** es la mitad que importa. `shareReplay(1)` —la forma corta— deja la suscripción interna viva para siempre aunque no quede nadie escuchando, y sobre una fuente que no completa —un `BehaviorSubject`, justo— eso es una fuga. El detalle completo está en **A06** §7.

**Cuando el derivado cruza dos servicios**, la herramienta es `combineLatest`, y sigue sin guardarse nada:

```ts
// Fase 11: certificados por vencer, agrupados por cliente. El cruce no existe
// en ningún estado; se calcula cuando alguien lo mira.
readonly expiringByClient$ = combineLatest([
  this.certificateState.certificates$,
  this.clientState.clients$,
]).pipe(
  map(([certificates, clients]) => groupExpiringByClient(certificates, clients)),
  shareReplay({ bufferSize: 1, refCount: true }),
);
```

> 💡 **Dónde va la función que calcula.** Fuera del servicio, en `core/domain/`, como función pura. El servicio la llama; no la contiene. Así la **Fase 12** puede testear la regla de negocio sin `TestBed`, sin `HttpClient` y sin montar nada — y el 80% del coverage del proyecto sale de ahí.

---

## 6. `loading` y `error` dentro del estado

Los dos viven **dentro** del objeto de estado, no como campos sueltos del componente ni como excepciones que se propagan.

```ts
load(): void {
  this.patch({ loading: true, error: null });   // limpiar el error anterior importa

  this.templateApi.getAll().subscribe({
    next: (templates) => this.patch({ items: [...templates], loading: false }),
    error: (error: unknown) => this.patch({
      loading: false,
      error: error instanceof ApiError ? error.message : 'No se pudieron cargar las plantillas.',
    }),
  });
}
```

**Por qué el error vive en el estado y no se lanza.** Porque un error que sólo existe en un `catch` local no se puede pintar en otra pantalla, y el dashboard de la **Fase 11** necesita exactamente eso: mostrar que la carga de certificados falló mientras el resto del panel sigue funcionando. Un error en el estado es un dato como cualquier otro; una excepción es un evento que ya pasó.

**Por qué se limpia el error al empezar la carga.** Sin ese `error: null`, un reintento que funciona deja el mensaje de error anterior en pantalla junto a los datos nuevos. Es de los bugs más tontos y más frecuentes del patrón.

**El límite del booleano.** `loading: boolean` responde a "¿hay algo en vuelo?", no a "¿qué hay en vuelo?". En cuanto una feature tenga dos cargas concurrentes —el listado y el detalle— un solo booleano miente: la primera en volver lo pone en `false` mientras la otra sigue viajando. La respuesta cuando llega ese día es un campo por operación, o un contador; en CertCore no llega, y por eso el booleano se queda.

---

## 7. El ciclo de vida de una suscripción, de punta a punta

La pregunta no es "¿me desuscribo?" sino **"¿esta suscripción puede sobrevivir a quien la creó?"**. Con eso, los cuatro casos del proyecto se resuelven solos:

| Quién se suscribe | A qué | ¿Hace falta cortar? | Por qué |
|---|---|---|---|
| Un `*StateService` | a un `*ApiService` (HTTP) | **No** | el observable completa al llegar la respuesta; no queda nada abierto |
| Un `*StateService` raíz | a otro servicio raíz | **No** | los dos viven lo que la aplicación; nadie sobrevive a nadie |
| Una plantilla | a `state$` con `async` pipe | **No** | el pipe se suscribe al crear la vista y se desuscribe al destruirla |
| Un componente, con `.subscribe()` | a `state$` para provocar un efecto | **Sí** | `state$` no completa nunca y el componente se destruye antes |

Sólo el último caso necesita gestión, y la forma nueva es `takeUntilDestroyed(this.destroyRef)`. Las dos formas heredadas —`Subscription` manual y `takeUntil` con un `Subject` de destrucción— están vivas en CertCore y se explican en **A06** §8.

> 🧭 **La regla de oro, que se repite en todo el curso: `async` pipe para pintar, `.subscribe()` para efectos.** Si la suscripción es sólo para que un valor aparezca en pantalla, no escribas una suscripción: escribe un `async`. En toda la Fase 4 no hay una sola suscripción manual en código de producción, y no es una casualidad de la fase.

**Cómo se caza una fuga cuando ya existe**, que es lo que de verdad vas a tener que hacer:

1. Abre la pantalla sospechosa, navega fuera y vuelve. Diez veces.
2. Pon un `tap((v) => console.log('emitió', v))` en el observable compartido y provoca **una** emisión.
3. Cuenta las líneas en consola. Si son diez, tienes diez componentes zombis vivos y acabas de localizar la fuga sin abrir el perfilador.

---

## 8. ⚠️ Dónde este patrón se queda corto

Ninguna decisión gana en todo, y ésta pierde en cuatro sitios concretos. Esta sección no es un descargo de responsabilidad: es lo que te permite defender la decisión —o cambiarla— con argumentos en vez de con preferencias.

**No hay herramientas.** No existe un devtools que te muestre el árbol de estado, ni viaje en el tiempo, ni un registro de qué acción cambió qué. Cuando el estado quede raro, tu herramienta es un `tap(console.log)` bien puesto y el breakpoint en `patch()`. Con quince servicios de estado eso sigue funcionando; con setenta, no.

**No hay trazabilidad de quién cambió qué.** El estado cambió; el porqué no está en ningún sitio. En un sistema cuyo dominio **es** la trazabilidad, la ironía duele. Es la diferencia central con un store basado en acciones: allí cada cambio tiene un nombre, y el registro de nombres *es* la historia de la sesión.

**Las cargas concurrentes no se ordenan.** Dos `load()` seguidos lanzan dos peticiones y gana **la que llegue última**, que no tiene por qué ser la última que pediste. Con el mock respondiendo en dos milisegundos no se nota; con `CHAOS=latency` sí. El arreglo dentro del patrón existe —`switchMap` sobre un sujeto de disparo en vez de un `subscribe` suelto en `load()`— y cuesta que `load()` deje de ser tres líneas legibles.

**El estado derivado se recalcula por suscriptor** salvo que lo compartas explícitamente, y compartirlo mal es la fuga del `refCount` (§5). Es una responsabilidad que el patrón te deja a ti y que un store resuelve con selectores memorizados de fábrica.

### Qué resolvería NgRx, y por qué CertCore no lo usa

Un store de acciones y reducers resuelve, punto por punto, los cuatro: trae devtools con viaje en el tiempo, cada cambio pasa por una acción con nombre, los efectos se escriben con operadores de RxJS donde la cancelación es explícita, y los selectores memorizan por defecto.

Y cobra por ello: cinco archivos por feature en vez de uno, un vocabulario que hay que aprender antes de tocar nada, y una curva que un equipo de dos personas paga entera sin repartirla.

> 📝 **La decisión, fechada.** En **2022** el equipo de CertCore evaluó NgRx y dijo que no: dos personas, un dominio chico, y una librería que exige ceremonia. Esa decisión sigue vigente y este curso la respeta — no porque sea la correcta en abstracto, sino porque es la que el sistema tiene y mantener significa trabajar con lo que hay. El Track A tomó la decisión contraria en 2019 y hoy arrastra NgRx 8 con el estilo de aquella época; ninguna de las dos empresas se equivocó.

**Cuándo tendrías que replantearlo**, con criterios y no con sensaciones: cuando más de tres features necesiten leer y escribir el mismo estado; cuando "¿quién cambió esto?" se convierta en una pregunta recurrente en los tickets; cuando las cargas concurrentes empiecen a producir bugs intermitentes de verdad; o cuando el equipo pase de dos a ocho personas y el patrón informal deje de ser el mismo patrón en la cabeza de todos.

---

## 🧭 Cuándo usar qué

| Situación | Decisión | Por qué |
|---|---|---|
| Estado que varias features leen | `*StateService` con `providedIn: 'root'` | una instancia, una verdad |
| Estado que pertenece a una pantalla | provider de ruta | se destruye al salir, que es lo que quieres |
| Pedir datos sin recordarlos | `*ApiService` | si empieza a acordarse de algo, está en el archivo equivocado |
| Un valor que se puede calcular | derivado con `map`, nunca un campo del estado | dos fuentes de verdad se desincronizan |
| Un derivado que miran varias vistas | `shareReplay({ bufferSize: 1, refCount: true })` | uno de los dos `refCount` es una fuga |
| Cruzar dos estados | `combineLatest` + función pura en `core/domain/` | testeable sin `TestBed` |
| Mostrar un fallo de carga | `error` dentro del estado | una excepción no se puede pintar en otra pantalla |
| Leer el valor actual una sola vez | `first()` | `.value` desde fuera es una lectura que no reacciona |
| Pintar | `async` pipe | no hay suscripción que gestionar |
| Provocar un efecto | `.subscribe()` + `takeUntilDestroyed` | es el único caso donde hace falta cortar |

---

## 📚 Referencias

- https://rxjs.dev/api/index/class/BehaviorSubject — la clase, y la diferencia con `Subject` en su primera frase.
- https://rxjs.dev/api/operators/shareReplay — con la explicación de `refCount` que la mayoría de los tutoriales omite.
- https://v16.angular.io/guide/dependency-injection-providers — `providedIn` y los ámbitos de la §3.
- https://v16.angular.io/guide/change-detection-skipping-subtrees — `OnPush` y las condiciones exactas que lo despiertan; es la referencia de la §4.
- https://v16.angular.io/api/core/rxjs-interop/takeUntilDestroyed — la forma nueva de cortar.
- https://ngrx.io/guide/store — para entender qué se está dejando sobre la mesa. Léelo como comparación, no como plan: este curso no lo instala.
- https://blog.angular.io/angular-v16-is-here-4d7a28ec680d — el anuncio de Angular 16, con la sección de signals que explica por qué en esta versión se leen y no se usan.

> ⚠️ Los artículos sobre "state management sin NgRx" que encuentres son casi todos posteriores a 2023 y resuelven el problema con signals. Eso es Angular 17 en adelante y no aplica aquí: en la 16 los signals son experimentales. El horizonte está en **A11** 🔥.

**Orden de lectura sugerido:** §1, §2 y §3 antes de escribir tu primer `*StateService`, que es la Fase 4. La §4 justo antes de la Fase 6, que es donde se paga la deuda de la inmutabilidad. La §7 el día que una lista se actualice dos veces. Y la §8 al terminar la Fase 11, no antes: hasta que no hayas escrito cinco servicios de estado, sus cuatro límites se leen como advertencias abstractas en vez de como cosas que ya te pasaron.

---

## 🧪 Ejercicios (8)

1. 🟢 Cambia `createInitialState<T>()` por una constante exportada `INITIAL_STATE`. Carga dos features distintas, muta el array de una, y comprueba qué le pasa a la otra. Revierte y explica en una frase por qué era una función.

2. 🟢 Haz público el `stateSubject` de `TemplateStateService` y llámale `next()` desde un componente con un estado inventado. Comprueba que compila, que funciona, y que no hay forma de saber desde el servicio quién lo hizo. Revierte.

3. 🟡 Convierte `TemplateStateService` de `providedIn: 'root'` a provider de la ruta de plantillas. Navega fuera y vuelve, y anota qué cambia en lo que ves. Después decide cuál de las dos configuraciones querría CertCore y defiéndelo en tres líneas.

4. 🟡 Reproduce el bug de `OnPush` de la §4: muta `state.items` con un `push` desde un componente y comprueba que la pantalla con `OnPush` no se entera mientras la heredada sí. Arréglalo con el reemplazo y verifica las dos pantallas.

5. 🟡 Añade un derivado `criticalTemplates$` que filtre las plantillas con al menos un ítem `photoRequired`. Suscríbete desde tres sitios con `async` y cuenta cuántas veces corre el filtro con y sin `shareReplay`. Anota las dos cifras.

6. 🟠 Levanta el mock con `CHAOS=latency` y llama a `load()` dos veces seguidas con un cambio de filtro en medio. Comprueba que gana la respuesta que llega última y no la que pediste al final. Después arréglalo dentro del patrón —con un sujeto de disparo y `switchMap`— y argumenta si el arreglo compensa la legibilidad que cuesta.

7. 🟠 Caza una fuga con el método de la §7: añade un `.subscribe()` sin cortar a `state$` en un componente, navega diez veces, provoca una emisión y cuenta las líneas de consola. Después arréglalo con `takeUntilDestroyed` y verifica que vuelve a ser una.

8. 🔴 Escribe el documento de decisión que CertCore no tiene: una página que responda a *"¿deberíamos migrar el estado a NgRx?"* con los cuatro límites de la §8 medidos sobre el proyecto real —cuántos servicios de estado hay, cuántas features comparten cuál, cuántos tickets del cuaderno son de estado— y una recomendación con su porqué. El criterio de éxito es que alguien que no conozca el sistema pueda estar en desacuerdo contigo señalando un dato concreto, no una opinión.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y los servicios de estado que explica los escriben las Fases 4, 6, 7, 9 y 11, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 04: …`, `fase 06: …`). Las mediciones de los ejercicios 5 y 7 van en el mensaje de un tag anotado (`ej/a07/5`). Y si haces el 8, es de las pocas cosas de un apéndice que merecen quedar en el repositorio: `docs/decision-estado.md`, commiteado con el prefijo de la fase desde la que llegaste. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
