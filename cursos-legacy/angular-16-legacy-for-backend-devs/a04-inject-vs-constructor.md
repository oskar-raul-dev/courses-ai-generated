# 📎 Apéndice A04 — `inject()` frente a `constructor`

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **2 horas**
> Usado por: [Fase 0](00-setup-hola-mundo.md), [Fase 1](01-estructura-base-ngmodules.md), [Fase 2](02-autenticacion.md), [Fase 5](05-standalone-convivencia.md) — y de consulta en todas · Versión cubierta: Angular 16.2.12

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve la pregunta que te vas a hacer cada vez que abras un archivo de CertCore: **cuál de las dos formas de inyectar toca aquí, y qué se rompe si eliges mal.**

Este apéndice es 🧬 de principio a fin. Casi todas sus secciones muestran el mismo caso escrito de las dos maneras, porque las dos están vivas en el repositorio y las dos son correctas — cada una en su archivo.

**Qué queda fuera:** el sistema de inyección de dependencias completo. La jerarquía de inyectores de elemento, los `multi` providers avanzados, las factories con `deps`, los inyectores de plataforma. Nada de eso hace falta para mantener CertCore, y está documentado mejor de lo que cabría aquí: https://v16.angular.io/guide/dependency-injection. Lo que sí está es todo lo que aparece en el código del curso.

---

## Índice

- [1. Qué es el contexto de inyección, y dónde termina](#1-qué-es-el-contexto-de-inyección-y-dónde-termina)
- [2. 🧬 El mismo servicio, escrito de las dos formas](#2--el-mismo-servicio-escrito-de-las-dos-formas)
- [3. Herencia: el `super()` que deja de doler](#3-herencia-el-super-que-deja-de-doler)
- [4. Guards, interceptors y resolvers funcionales](#4-guards-interceptors-y-resolvers-funcionales)
- [5. `runInInjectionContext`: cuándo es legítimo](#5-runininjectioncontext-cuándo-es-legítimo)
- [6. Las opciones de `inject()`](#6-las-opciones-de-inject)
- [7. `NG0203` traducido: los cuatro sitios donde sale](#7-ng0203-traducido-los-cuatro-sitios-donde-sale)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Qué es el contexto de inyección, y dónde termina

`inject()` no lee un registro global. Lee **el inyector que Angular tiene activo en este preciso instante**, y Angular sólo tiene un inyector activo mientras está construyendo algo. Fuera de esa ventana, `inject()` no tiene a quién preguntar y lanza `NG0203`.

La ventana está abierta exactamente en cuatro sitios:

- **En el inicializador de un campo de clase.** `private readonly http = inject(HttpClient);` — los campos se inicializan durante la construcción de la instancia, así que estás dentro.
- **En el cuerpo del constructor.** Menos común, igual de válido.
- **Dentro de una función factory.** El `useFactory` de un provider, la factory de un `APP_INITIALIZER` —la de la **Fase 13**—, y la factory implícita de un `@Injectable({ providedIn: 'root' })`.
- **Dentro de un guard, interceptor o resolver funcional.** Porque son, literalmente, factories que Angular ejecuta con el inyector puesto (§4).

Y se cierra en cuanto Angular termina. Esto **no** es contexto de inyección, aunque esté en la misma clase:

```ts
export class TemplateListComponent implements OnInit {
  private readonly templateApi = inject(TemplateApiService);   // ✅ dentro

  ngOnInit(): void {
    const router = inject(Router);   // ❌ NG0203: ya se construyó, la ventana se cerró
  }
}
```

> 🧭 **El hábito que resuelve el 90% de los casos: se inyecta arriba del todo y se usa después.** Las referencias quedan capturadas en el campo o en el closure y funcionan donde quieras — dentro de un `subscribe`, de un `catchError`, de un `setTimeout`. Lo que no funciona es *llamar a `inject()`* ahí.

> 🧠 **La analogía con backend, y dónde se rompe.** `inject()` es resolución del contenedor de DI, como el `getBean()` de Spring o el `GetService<T>()` de .NET. La diferencia que importa: aquellos leen un contenedor que existe todo el tiempo, y éste lee un contenedor que sólo existe durante la construcción. Por eso allí puedes resolver una dependencia en mitad de un método y aquí no. Hasta ahí el paralelo; a partir de ahí, la regla de arriba.

---

## 2. 🧬 El mismo servicio, escrito de las dos formas

Las dos formas están en `core/` de CertCore, y las dos están bien. La diferencia es la fecha del archivo.

```ts
// ── HEREDADO (2021) ────────────────────────────────────────────────────────
// Así está escrito AuthService, y así se queda. Las dependencias son
// parámetros del constructor, marcados `private readonly` para que TypeScript
// los convierta en campos.
@Injectable({ providedIn: 'root' })
export class AuthService {
  constructor(
    private readonly http: HttpClient,
    private readonly router: Router,
  ) {}
}
```

```ts
// ── NUEVO (2024) ───────────────────────────────────────────────────────────
// Así está escrito TemplateStateService. Sin constructor. Cada dependencia es
// un campo que se resuelve sola.
@Injectable({ providedIn: 'root' })
export class TemplateStateService {
  private readonly templateApi = inject(TemplateApiService);
  private readonly authService = inject(AuthService);
}
```

**Qué cambia de verdad, más allá de la estética:**

- **El tipo no viaja por metadatos.** El constructor con parámetros depende de `emitDecoratorMetadata` y de que el tipo sea una clase: por eso un token de inyección necesita `@Inject(TOKEN)` delante. Con `inject(TOKEN)` el token es un argumento normal y la ceremonia desaparece.
- **Se puede usar fuera de una clase.** Un guard funcional no tiene constructor. Ésa es la razón por la que `inject()` existe, y no la brevedad.
- **La herencia deja de doler** (§3).
- **El orden de los campos importa.** Los inicializadores de campo corren de arriba abajo: si un campo usa a otro, el otro tiene que estar declarado antes. Con constructor, el cuerpo corre después de que todos los parámetros existan.

Lo que **no** cambia: el `@Injectable()` sigue haciendo falta para que la clase se pueda proveer, `providedIn: 'root'` sigue significando lo mismo, y el árbol de inyectores es exactamente el mismo. `inject()` es otra sintaxis para preguntarle a quien ya estaba ahí.

> 📝 **Nota de migración.** `inject()` es público desde Angular **14**, y su motivo original fue habilitar los guards e interceptors funcionales, no ahorrar líneas en los servicios. CertCore nació en 2021 sobre Angular 12, donde ni existía; durante la migración de 2024 el equipo escribió lo nuevo con `inject()` y no tocó lo viejo. Por eso `core/` tiene hoy servicios de las dos épocas, uno al lado del otro, y ninguno de los dos está mal.

> 🧭 **Regla del proyecto (guía §6.1).** Código nuevo, estilo nuevo. Código heredado, se toca lo mínimo y en su propio estilo. **Y nunca los dos dentro del mismo archivo.** Una clase con dos dependencias en el constructor y una tercera con `inject()` es peor que cualquiera de las dos formas puras: obliga a leer el archivo entero para saber de qué depende.

---

## 3. Herencia: el `super()` que deja de doler

Éste es el sitio donde la diferencia deja de ser estilo y pasa a ser mantenimiento.

```ts
// ── HEREDADO ───────────────────────────────────────────────────────────────
@Injectable()
export abstract class BaseApiService {
  constructor(protected readonly http: HttpClient) {}
}

@Injectable({ providedIn: 'root' })
export class ClientApiService extends BaseApiService {
  // Hay que volver a declarar la dependencia del padre SÓLO para pasársela.
  constructor(http: HttpClient, private readonly logger: LoggerService) {
    super(http);
  }
}
```

El problema no es la verbosidad: es que **añadir una dependencia a la clase base obliga a tocar todas las hijas**. Cinco servicios que heredan de `BaseApiService` significan cinco constructores que cambian, cinco commits en archivos que no tenían nada que ver con el cambio, y cinco oportunidades de equivocarse en el orden de los argumentos — que además compila, porque dos `string` son intercambiables para el compilador y no para ti.

```ts
// ── NUEVO ──────────────────────────────────────────────────────────────────
@Injectable()
export abstract class BaseApiService {
  // El padre se resuelve solo. Nadie tiene que saber de qué depende.
  protected readonly http = inject(HttpClient);
}

@Injectable({ providedIn: 'root' })
export class ClientApiService extends BaseApiService {
  private readonly logger = inject(LoggerService);
  // Sin constructor. Sin super(). Sin nada.
}
```

Ahora la clase base puede añadir dependencias sin que ninguna hija se entere. Ése es el argumento entero.

> ⚠️ **El orden de inicialización sigue siendo el de JavaScript, y muerde.** Los campos de la clase base se inicializan **antes** que los de la hija. Si un campo de la base llama a un método sobrescrito que usa un campo de la hija, ese campo todavía es `undefined` — y con `strict` el compilador no te avisa, porque el tipo dice que existe. No es un problema de `inject()`: es el mismo de siempre, sólo que ahora hay más código en los inicializadores donde antes había un constructor.

---

## 4. Guards, interceptors y resolvers funcionales

Aquí `inject()` no es una alternativa: es la única forma. Un guard funcional no tiene clase, así que no tiene constructor donde pedir nada.

```ts
// Guard — CanActivateFn, Angular 14
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);   // ✅ estamos dentro de la factory
  const router = inject(Router);
  return authService.isAuthenticated() || router.createUrlTree(['/login']);
};

// Interceptor — HttpInterceptorFn, Angular 15
export const authInterceptor: HttpInterceptorFn = (request, next) => {
  const authService = inject(AuthService);   // ✅ arriba del todo, siempre
  return next(request).pipe(
    catchError((error: unknown) => {
      // ❌ Aquí ya NO. `inject(Router)` en este punto es NG0203.
      // authService funciona porque es una referencia capturada, no una llamada.
      return throwError(() => error);
    }),
  );
};

// Resolver — ResolveFn<T>, Angular 15
export const templateResolver: ResolveFn<ChecklistTemplate> = (route) => {
  const templateApi = inject(TemplateApiService);
  const templateId = route.paramMap.get('templateId') ?? '';
  return templateApi.getById(templateId);
};
```

**La equivalencia con la forma heredada**, para cuando te encuentres una:

| Nuevo | Heredado | Cómo se registra el heredado |
|---|---|---|
| `CanActivateFn` | clase con `implements CanActivate` | `canActivate: [AuthGuard]` con la clase |
| `HttpInterceptorFn` | clase con `implements HttpInterceptor` | `{ provide: HTTP_INTERCEPTORS, useClass: …, multi: true }` |
| `ResolveFn<T>` | clase con `implements Resolve<T>` | `resolve: { data: DataResolver }` con la clase |

> 🧬 **El archivo donde las dos generaciones se tocan** es `core/core.module.ts` de la **Fase 2**: un `NgModule` de 2021 registrando a la vez `provideHttpClient(withInterceptorsFromDi(), withInterceptors([authInterceptor]))`. Eso no viola la regla del §2: no hay dos estilos *escritos* en el archivo, hay un módulo heredado registrando código de las dos épocas, que es su trabajo. Por eso lleva 🧬 y no 💸.

---

## 5. `runInInjectionContext`: cuándo es legítimo

Cuando de verdad necesitas resolver algo fuera de la ventana, Angular 16 te deja abrirla a mano — siempre que tengas un inyector.

```ts
export class ReportExportService {
  private readonly injector = inject(EnvironmentInjector);   // capturado al construir

  // El caso legítimo: código que se ejecuta más tarde y cuyas dependencias no
  // se conocen al construir. Aquí, el generador del PDF se carga con import()
  // dinámico y sólo entonces sabemos qué necesita.
  async export(): Promise<void> {
    const { buildCertificatePdf } = await import('./certificate-pdf');

    runInInjectionContext(this.injector, () => {
      buildCertificatePdf();   // dentro puede llamar a inject() sin romperse
    });
  }
}
```

**Cuándo es legítimo, en una lista corta:** carga diferida con `import()` de código que inyecta; librerías o utilidades que reciben una función y la ejecutan fuera del ciclo de Angular; y tests, donde a veces es lo más limpio (**Fase 12**).

**Cuándo es un parche:** cuando lo estás usando para llamar a `inject()` dentro de un `ngOnInit`, de un `subscribe` o de un manejador de evento. Ahí la solución no es abrir la ventana otra vez: es inyectar arriba y usar la referencia. Si te encuentras un `runInInjectionContext` en una clase de CertCore, léelo como una señal de que alguien resolvió con maquinaria lo que se resolvía moviendo una línea.

> 📝 **Nota de migración.** Hasta Angular 15 esto se escribía `injector.runInContext(fn)`, un método del `EnvironmentInjector`. Angular **16** introdujo la función suelta `runInInjectionContext(injector, fn)` y dejó el método anterior en desuso. Las dos hacen lo mismo; si encuentras la forma vieja en un artículo, no está mal, está fechada.

---

## 6. Las opciones de `inject()`

El segundo argumento cambia qué pasa cuando la dependencia no aparece o dónde se busca.

```ts
// El caso normal: si no está, NG0201 (NullInjectorError) y el arranque se cae.
private readonly http = inject(HttpClient);

// optional: devuelve null en vez de reventar. El tipo lo refleja: HttpClient | null
private readonly analytics = inject(AnalyticsService, { optional: true });

// skipSelf: empieza a buscar en el inyector PADRE, saltándose el propio.
// Es lo que hace el guard de doble importación de CoreModule, en su forma de clase.
private readonly parent = inject(CoreModule, { optional: true, skipSelf: true });

// self: busca SÓLO en el inyector propio; si no está ahí, no sube.
private readonly localConfig = inject(FEATURE_CONFIG, { self: true });

// host: se detiene en el componente anfitrión. Sólo tiene sentido en directivas.
private readonly control = inject(NgControl, { optional: true, host: true });
```

| Opción | Qué hace | Dónde aparece en CertCore |
|---|---|---|
| `optional: true` | `null` en vez de error; el tipo se vuelve `T \| null` | dependencias que pueden no estar configuradas |
| `skipSelf: true` | empieza a buscar en el padre | el guard de doble importación de `CoreModule` (Fase 1, en su forma heredada con `@SkipSelf()`) |
| `self: true` | no sube al padre | providers de ruta que no deben caer al de raíz |
| `host: true` | se detiene en el componente anfitrión | directivas que hablan con el control del formulario |

La traducción a la forma heredada es uno a uno: `{ optional: true }` es `@Optional()`, `{ skipSelf: true }` es `@SkipSelf()`, `{ self: true }` es `@Self()`, `{ host: true }` es `@Host()`. Si estás arreglando un archivo de 2021, usa los decoradores; el archivo es de esa época.

> ⚠️ **`optional: true` cambia el tipo, y con `strict` eso se nota.** `inject(X, { optional: true })` devuelve `X | null`, y a partir de ahí el compilador te va a exigir decidir qué pasa cuando es `null`. Eso es exactamente lo que quieres: la mitad de los bugs de configuración del curso son "esto podía no estar y nadie lo pensó".

---

## 7. `NG0203` traducido: los cuatro sitios donde sale

El mensaje completo es `NG0203: inject() must be called from an injection context such as a constructor, a factory function, a field initializer, or a function used with runInInjectionContext`. Es de los errores más honestos que da Angular: dice el problema y la solución en la misma línea. Aun así, hay cuatro sitios donde aparece una y otra vez.

**1. Dentro de un hook del ciclo de vida.**

```ts
ngOnInit(): void {
  const router = inject(Router);   // ❌
}
```
El componente ya está construido. Sube la línea al cuerpo de la clase.

**2. Dentro de un callback de RxJS.**

```ts
return next(request).pipe(
  catchError(() => {
    const router = inject(Router);   // ❌ el callback corre mucho después
    return EMPTY;
  }),
);
```
Es el ejercicio 10 de la **Fase 2** y es el caso más común en interceptors. Inyecta arriba, usa la referencia dentro.

**3. En `takeUntilDestroyed()` sin argumento.**

```ts
ngOnInit(): void {
  this.templateState.templates$
    .pipe(takeUntilDestroyed())   // ❌ NG0203, y el mensaje no menciona takeUntilDestroyed
    .subscribe(/* … */);
}
```
Éste engaña porque el error no nombra al culpable. `takeUntilDestroyed()` sin argumento llama a `inject(DestroyRef)` por dentro, así que **sólo puede escribirse en el contexto de inyección** — típicamente en un inicializador de campo. Si lo necesitas más tarde, inyecta el `DestroyRef` arriba y pásaselo: `takeUntilDestroyed(this.destroyRef)`, que es exactamente lo que hace `ClientFormComponent` en la **Fase 6**.

**4. Dentro de una función suelta llamada desde un método.**

```ts
function buildHeaders(): HttpHeaders {
  const auth = inject(AuthService);   // ❌ si quien la llama ya no está en contexto
  return new HttpHeaders();
}
```
Una función auxiliar hereda el contexto de quien la llama: si la llamas desde un inicializador de campo, funciona; si la llamas desde un método, no. Que el mismo código funcione o falle según desde dónde se invoque es lo que hace este caso desagradable. La solución es pasar la dependencia como parámetro y dejar la función pura — que además la vuelve testeable sin `TestBed`, como las funciones de dominio de las Fases 7 a 9.

> 💡 **Cómo se depura en treinta segundos.** El stack trace de `NG0203` apunta al `inject()` que falló, no a la causa. Pon el breakpoint ahí, mira la pila hacia arriba, y busca el primer marco que **no** sea de Angular: ése es el sitio desde donde se llamó fuera de contexto. Nueve de cada diez veces es un `subscribe` o un hook.

---

## 🧭 Cuándo usar qué

| Situación | Forma | Por qué |
|---|---|---|
| Componente, servicio o directiva **nuevos** | `inject()` en campos | es el estilo del proyecto desde la Fase 5 |
| Fix de tres líneas en un archivo de 2021 | `constructor` | el parche se escribe en el estilo del archivo (guía §6.7) |
| Guard, interceptor o resolver funcional | `inject()` | no hay alternativa: no hay constructor |
| Clase base de la que heredan varios servicios | `inject()` | añadir una dependencia deja de tocar a las hijas |
| Necesitas un token con `@Inject(TOKEN)` | `inject(TOKEN)` | el token es un argumento normal, sin decorador |
| Código que corre después del arranque y necesita DI | `runInInjectionContext` con un inyector capturado | y sólo si de verdad no puedes inyectar arriba |
| Un archivo heredado al que hay que añadir **una** dependencia | `constructor`, junto a las que ya están | mezclar las dos formas en una clase es peor que cualquiera de ellas |

---

## ⚠️ Advertencias

- **Mezclar las dos formas en el mismo archivo es el único error de estilo que este apéndice llama error.** Las dos formas puras se leen bien; la mezcla obliga a recorrer la clase entera para saber de qué depende.
- **`inject()` en el inicializador de un campo que usa otro campo depende del orden de declaración.** Con constructor, el cuerpo corre cuando todos los parámetros existen; con campos, no. Si tienes que ordenar campos para que algo funcione, probablemente ese cálculo no debería estar en un inicializador.
- **Modernizar un archivo heredado "ya que estoy" es cómo se rompen otras tres cosas.** Convertir `AuthService` a `inject()` no arregla ningún bug, cambia el diff de un hotfix de tres líneas a treinta, y le quita a quien revise la posibilidad de ver qué cambió de verdad.

---

## 📚 Referencias

- https://v16.angular.io/api/core/inject — la firma de `inject()` y sus opciones, en la versión de este curso.
- https://v16.angular.io/guide/dependency-injection — la guía completa de DI, para lo que este apéndice deja fuera.
- https://v16.angular.io/errors/NG0203 — la página oficial del error, con la lista de contextos válidos.
- https://v16.angular.io/api/core/runInInjectionContext — la función de Angular 16 que sustituyó a `EnvironmentInjector.runInContext()`.
- https://v16.angular.io/api/router/CanActivateFn · https://v16.angular.io/api/common/http/HttpInterceptorFn · https://v16.angular.io/api/router/ResolveFn — las tres firmas funcionales.
- https://v16.angular.io/api/core/rxjs-interop/takeUntilDestroyed — incluida la nota sobre el `DestroyRef` explícito, que es el caso 3 de la §7.

> ⚠️ Cuidado con caer en https://angular.dev buscando `inject()`: documenta la 17 en adelante, y sus ejemplos combinan `inject()` con signals y control flow que en la 16 no existen o son experimentales. Para este curso, la referencia es siempre `v16.angular.io`.

**Orden de lectura sugerido:** la §1 y la §7 antes que nada — con esas dos ya no vuelves a pelearte con `NG0203`. La §2 cuando abras el primer archivo heredado y dudes de si tocarlo. La §3 sólo si te encuentras herencia, que en CertCore es poco frecuente y en un proyecto de verdad lo es mucho. La §5 la última, y ojalá no la necesites.

---

## 🧪 Ejercicios (8)

1. 🟢 Abre `core/auth.service.ts` y `core/state/template-state.service.ts`. Escribe en dos líneas cómo sabrías, sin mirar el historial de git, cuál de los dos se escribió en 2021 y cuál en 2024.

2. 🟢 En `authInterceptor`, mueve la línea `const router = inject(Router);` dentro del `catchError`. Provoca un 401 con el mock, anota el código de error exacto que sale en consola y el archivo y línea a los que apunta. Devuelve la línea a su sitio.

3. 🟡 Escribe un guard funcional `supervisorGuard` que sólo deje pasar si `AuthService` dice que el rol es `supervisor`, y devuelva un `UrlTree` a `/` si no. Después escribe el mismo guard en su forma heredada (clase con `implements CanActivate`) y registra los dos en rutas distintas. Compara los dos archivos y di cuál usarías hoy y por qué.

4. 🟡 Toma un componente cualquiera de la Fase 6 y añade `takeUntilDestroyed()` **sin argumento** dentro de `ngOnInit`. Anota el error. Después arréglalo de las dos formas posibles —mover el pipe a un inicializador de campo, o inyectar `DestroyRef` arriba y pasarlo— y explica en qué situación conviene cada una.

5. 🟠 Crea una clase base `BaseApiService` con `inject(HttpClient)` en un campo `protected`, haz que `ClientApiService` y `TemplateApiService` hereden de ella, y comprueba que ninguna de las dos necesita constructor. Después añade una segunda dependencia a la base y cuenta cuántos archivos tuviste que tocar. Repite el ejercicio mentalmente con la forma heredada y anota la diferencia.

6. 🟠 Inyecta un token inexistente con `inject(SOME_TOKEN)` y luego con `inject(SOME_TOKEN, { optional: true })`. Anota los dos comportamientos, el código de error del primero, y qué te obliga a escribir el segundo por culpa de `strict`.

7. 🔴 Provoca el caso 4 de la §7: escribe una función suelta que llame a `inject()`, llámala primero desde un inicializador de campo y después desde un método. Explica por qué el mismo código funciona en un sitio y no en el otro, y reescríbela como función pura que reciba la dependencia por parámetro. Argumenta en tres líneas por qué la versión pura es además la única que se puede testear sin `TestBed`.

8. 🔴 🧬 Te asignan un ticket: `CorrelationIdInterceptor` —clase, 2021— tiene que dejar de estampar la cabecera en las peticiones a `/auth/login`. Escribe el fix y justifica en un párrafo por qué **no** lo conviertes a `HttpInterceptorFn` mientras estás dentro, citando la regla del proyecto. Después escribe el párrafo contrario: qué tendría que pasar para que convertirlo sí fuera lo correcto.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y el código que explica lo escriben las fases, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 02: …`, `fase 05: …`). Si un ejercicio te deja código que quieres conservar —el `supervisorGuard` del 3, por ejemplo—, va con la forma `ej/a04/3`. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
