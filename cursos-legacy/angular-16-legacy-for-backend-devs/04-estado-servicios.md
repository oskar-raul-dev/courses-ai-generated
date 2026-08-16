# 🧠 Fase 04 — Estado con servicios y BehaviorSubject

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 4 de 14 · **7 horas**
> Depende de: Fase 3 (mock API y caos) · Habilita: Fases 6 a 13
> Apéndices de apoyo: [A06 (RxJS 7 idiomático)](a06-rxjs.md) · [A07 (Estado con servicios)](a07-estado-servicios.md)
> [Incidentes asociados](cuaderno-incidentes.md): 05
> Estilo de esta fase: **nuevo** en los servicios; los dos componentes que se tocan siguen siendo heredados 🧬

---

## 🎯 1. Propósito

Fijar el patrón que sostiene todo lo que queda del curso: **un servicio de estado por feature, con un `BehaviorSubject` privado y un `Observable` público de sólo lectura.** No es un patrón exótico —es la decisión más común del ecosistema Angular— y por eso conviene escribirlo bien una vez y repetirlo sin pensarlo en las features que vienen.

Y con él llega la otra mitad, que es la que de verdad duele en mantenimiento: **el ciclo de vida de las suscripciones.** Quién se suscribe, quién se desuscribe, y por qué un `BehaviorSubject` en un servicio raíz sobrevive a todas las navegaciones aunque el componente que lo escuchaba ya no exista. La mitad de las fugas de este curso nacen aquí, y se cazan aquí.

Además, hoy se paga. Dos deudas 💸 declaradas en las Fases 2 y 3 vencen en esta fase, y las dos se saldan con números delante: el `ShellComponent` que decodifica un JWT en cada ciclo de detección, y el `TemplateListComponent` que se guarda su propia copia de las plantillas.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `TemplateStateService` existe, expone `state$` de sólo lectura, y **no hay forma de llamar a `.next()` desde fuera**: intentarlo no compila.
- [ ] `TemplateListComponent` no tiene `Subscription`, ni `ngOnDestroy`, ni una copia local de las plantillas. Un solo `| async` en la plantilla.
- [ ] `AuthService` expone `currentUser$` y el `console.count` del decodificado marca **1 por sesión**, no uno por ciclo de detección. El número de `deuda.md` baja y lo anotas al lado.
- [ ] Cierras sesión, entras con el otro usuario, y la lista de plantillas **no** trae nada de la sesión anterior — sin que nadie haya llamado a ningún `reset()` a mano.
- [ ] Con `CHAOS=error`, la pantalla muestra el mensaje del error leyéndolo **del estado**, no de un `catch` local.
- [ ] Reprodujiste una fuga de suscripción, la viste en el panel Memory, y la cerraste de las cuatro formas.
- [ ] `git tag` lista `fase-04`.

---

## 🚫 3. Qué NO entra todavía

- **NgRx o cualquier librería de store** → no entra nunca. CertCore no la usa; **A07** explica qué problema resolvería y por qué aquí no está.
- **Signals como estado** → Fase 12 los lee y **A11** los proyecta. En Angular 16 son experimentales.
- **Estado persistido** más allá del token → fuera de alcance. El trabajo en campo con conexión intermitente es una propiedad del CertCore de la ficción, no algo que el curso construya.
- **Cancelar la carga anterior con `switchMap`** → Fase 6 y ejercicio 28. Hoy se **muestra** el problema de las cargas concurrentes y se deja abierto a propósito.
- **`readonly` en el estado expuesto** → Fase 6. Es la 💸 de hoy.
- **`takeUntilDestroyed` en código de producción** → no aparece, y no es un olvido: sirve para suscripciones con efecto, y la primera de verdad llega en la Fase 6. Hoy vive en la sección 6, que es su mejor escenario.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

En la Fase 3 dejaste una pantalla que pide sus plantillas y se las guarda para ella sola. Con una pantalla funciona perfectamente. El problema empieza en la Fase 6, cuando sean cuatro las que necesiten saber qué plantillas hay: el listado, el editor, el formulario de inspección y el panel.

Con el patrón de la Fase 3, esas cuatro pantallas hacen cuatro peticiones. Eso ya es feo, pero no es el bug. El bug es que **cada una se queda con su propia copia**, y en cuanto una de ellas cambie algo —publicar una v3, por ejemplo— las otras tres siguen mostrando lo de antes. Dos pantallas de la misma aplicación afirmando cosas distintas al mismo tiempo, y el usuario decidiendo a cuál creerle.

La solución no es cachear la petición. Es que **haya un solo sitio donde vive la respuesta a "qué plantillas hay"**, y que las cuatro pantallas miren ahí.

### El patrón, en tres reglas

```ts
// 1. El sujeto es privado. Sólo el servicio empuja valores.
private readonly stateSubject = new BehaviorSubject<FeatureState<T>>(createInitialState<T>());

// 2. Lo público es un Observable de sólo lectura. Nadie de fuera puede next().
readonly state$ = this.stateSubject.asObservable();

// 3. Actualizar es REEMPLAZAR el estado, nunca modificarlo en sitio.
private patch(changes: Partial<FeatureState<T>>): void {
  this.stateSubject.next({ ...this.stateSubject.value, ...changes });
}
```

La primera regla es la que más se rompe y la que más cuesta después. Un `BehaviorSubject` público es un campo mutable global con pasos extra: cualquier componente puede empujarle un valor, y cuando el estado quede mal, la lista de sospechosos es "todo el repositorio". Con `asObservable()` la lista de sospechosos son los métodos de un archivo.

La tercera es la que hace posible `OnPush` y la que hoy está a medias, a propósito.

> 🧭 **Regla del proyecto: `*StateService` recuerda, `*ApiService` pide.** Un `*ApiService` traduce HTTP a dominio y no guarda nada; si le pides dos veces lo mismo, hace dos peticiones y le parece bien. Un `*StateService` es el único que tiene memoria, y es quien decide cuándo hace falta pedir. Si un método de un `*ApiService` empieza a acordarse de algo, está en el archivo equivocado.

### Por qué un servicio raíz no se muere nunca

`providedIn: 'root'` significa una instancia por aplicación, creada la primera vez que alguien la pide y viva hasta que se cierre la pestaña. **No se destruye al navegar.** Eso es exactamente lo que quieres —para eso es estado compartido— y trae dos consecuencias que hay que mirar de frente.

La primera es que al volver a una pantalla ves un instante los datos de la visita anterior, antes de que llegue el refresco. No es un bug: es la definición de tener estado. Se puede evitar llamando a `reset()` al entrar, y casi nunca conviene, porque un parpadeo de datos viejos molesta menos que un parpadeo de pantalla vacía.

La segunda es más seria y es de privacidad: **si cierras sesión y no limpias, el estado del usuario anterior sigue en memoria**, listo para pintarse cuando entre el siguiente. Eso sí hay que resolverlo, y en 5.6 se resuelve de una forma que no obliga a nadie a acordarse.

### Qué es una fuga, exactamente

Aquí hay una confusión que conviene desactivar temprano: **no toda suscripción sin cerrar es una fuga.**

Una fuga es una suscripción que **sobrevive a quien la creó**. Un componente se suscribe a un observable que vive más que él —el de un servicio raíz, por ejemplo—, el usuario navega, Angular destruye el componente… y el observable sigue teniendo una referencia a él. El componente no se puede recolectar, su callback se sigue ejecutando, y cada vez que entras a esa pantalla añades otro. Diez navegaciones, diez componentes zombis reaccionando a cada emisión.

Por eso hay un caso que parece una fuga y no lo es: un servicio `providedIn: 'root'` que se suscribe a otro servicio `providedIn: 'root'`. Nadie sobrevive a nadie; los dos viven lo que vive la aplicación. Vas a escribir una de ésas en 5.6 y a defenderla en el ejercicio 24.

Y hay otro que ni siquiera llega a ser suscripción: **el pipe `async`**. Se suscribe cuando la vista se crea y se desuscribe cuando se destruye, sin que tú tengas que acordarte. Es la razón de que en toda esta fase no haya una sola suscripción manual en código de producción.

> 📝 **Nota de migración: heredar un patrón no es heredar un estilo.** El `BehaviorSubject` en un servicio no es nuevo — es la decisión de **2022** de CertCore, cuando el equipo evaluó NgRx y dijo que no: dos personas, un dominio chico, y una librería que exige ceremonia. Esa decisión sigue vigente y este curso la respeta. Pero el código que escribes hoy es código de hoy: inyecta con `inject()`, no con `constructor`. **El patrón es de 2022, la implementación es de 2024, y las dos cosas conviven sin contradecirse.** Cuando en la Fase 6 abras un servicio de estado antiguo y veas `constructor(private http: HttpClient)`, sabrás que estás mirando la misma idea con la letra de otra época.

### Dónde este patrón se queda corto

Ninguna decisión gana en todo, y ésta pierde en cuatro sitios concretos. Conviene saberlos hoy para no descubrirlos en la Fase 11:

**No hay herramientas.** No hay devtools que te muestre el árbol de estado, ni viaje en el tiempo, ni un registro de qué acción cambió qué. Cuando el estado quede raro, tu herramienta es un `tap(console.log)` bien puesto. Es exactamente lo que NgRx resuelve, y es lo que se paga por no tenerlo.

**No hay trazabilidad de quién cambió qué.** El estado cambió; el porqué no está en ningún sitio. En un sistema cuyo dominio *es* la trazabilidad, la ironía duele.

**Las cargas concurrentes no se ordenan.** Dos `load()` seguidos lanzan dos peticiones, y gana **la que llegue última**, que no tiene por qué ser la última que pediste. Con el mock en local no se nota; con `CHAOS=latency` sí, y el ejercicio 17 te lo hace ver.

**El estado derivado se recalcula por suscriptor** salvo que lo compartas explícitamente, y compartirlo mal es una fuga distinta. Es lo de `shareReplay` de 5.3.

> 📚 El tratamiento completo —incluido qué resolvería NgRx y por qué CertCore no lo usa— está en **A07**. Esta fase construye; A07 discute.

---

## 💻 5. Código mínimo con comentarios

### 5.1 La forma del estado

Un solo tipo para todas las features. Se escribe una vez y no se toca.

```ts
// src/app/core/state/feature-state.model.ts

/**
 * La forma del estado de cualquier feature de CertCore. Genérica en el tipo de
 * la entidad, y sin clase base a propósito: una AbstractStateService<T> ahorra
 * treinta líneas por servicio y mete herencia justo donde peor envejece. Cada
 * *StateService se escribe explícito. El ejercicio 30 te hace probar la otra
 * opción antes de creerte ésta.
 */
export interface FeatureState<T> {
  /**
   * 💸 DEUDA TÉCNICA INTENCIONAL
   * `T[]` y no `readonly T[]`. El array que este estado expone es el mismo que
   * guarda el servicio, y cualquier suscriptor puede hacerle push, splice o
   * sort. Cuando eso pasa, la referencia no cambia, nadie emite, y con OnPush
   * la vista no se entera: la lista se queda como estaba aunque el dato ya no.
   * Lo correcto es `readonly items: readonly T[]` hasta la salida y reemplazar
   * en vez de mutar. Fíjate en que el borde HTTP sí está protegido —los
   * *ApiService de la Fase 3 devuelven `readonly T[]`—; lo que queda abierto es
   * de la puerta para adentro.
   * SE PAGA EN LA FASE 6, con la pantalla que deja de repintar delante.
   */
  items: T[];

  /** La entidad sobre la que está trabajando el usuario, o `null` si ninguna. */
  selected: T | null;

  /** Hay una carga en vuelo. Un booleano, y en el ejercicio 23 verás su límite. */
  loading: boolean;

  /**
   * El mensaje de error, ya traducido por `toApiError`, o `null` si no hay.
   * Vive en el estado y no se propaga como excepción: el dashboard de la Fase
   * 11 necesita pintarlo, y un error que sólo existe en un `catch` local no se
   * puede pintar en otra pantalla.
   */
  error: string | null;
}

/**
 * Ojo con esto: es una FUNCIÓN, no una constante. Si fuera
 * `export const INITIAL_STATE = { items: [], ... }`, todas las features
 * compartirían el mismo objeto y el mismo array, y el primer push de cualquiera
 * aparecería en las demás. El ejercicio 1 te hace comprobarlo.
 */
export function createInitialState<T>(): FeatureState<T> {
  return { items: [], selected: null, loading: false, error: null };
}
```

### 5.2 `TemplateStateService` — el archivo central de la fase

```ts
// src/app/core/state/template-state.service.ts
import { Injectable, inject } from '@angular/core';
import { BehaviorSubject, Observable, distinctUntilChanged, filter, map, shareReplay } from 'rxjs';

import { TemplateApiService } from '../api/template-api.service';
import { ApiError } from '../api/api-error';
import { AuthService } from '../auth.service';
import { ChecklistTemplate } from '../models/checklist-template.model';
import { FeatureState, createInitialState } from './feature-state.model';

@Injectable({ providedIn: 'root' })
export class TemplateStateService {
  private readonly templateApi = inject(TemplateApiService);
  private readonly authService = inject(AuthService);

  /**
   * El sujeto es privado y se llama `stateSubject`; lo público es `state$`.
   * Regla del proyecto: los dos nombres se distinguen por la palabra, no por el
   * signo. Un `state` privado y un `state$` público difieren en un carácter, y
   * ese carácter se pierde en un `Ctrl+F` a las siete de la tarde.
   */
  private readonly stateSubject = new BehaviorSubject<FeatureState<ChecklistTemplate>>(
    createInitialState<ChecklistTemplate>(),
  );

  /** Sólo lectura. Sin asObservable(), cualquiera podría hacerle next(). */
  readonly state$: Observable<FeatureState<ChecklistTemplate>> = this.stateSubject.asObservable();

  // Derivados. distinctUntilChanged evita que un cambio en `loading` haga
  // reevaluar a quien sólo mira `items`.
  readonly templates$ = this.state$.pipe(map((state) => state.items), distinctUntilChanged());
  readonly selected$ = this.state$.pipe(map((state) => state.selected), distinctUntilChanged());
  readonly loading$ = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());
  readonly error$ = this.state$.pipe(map((state) => state.error), distinctUntilChanged());

  constructor() {
    // Cuando la sesión se cierra —por el botón de la toolbar o por un 401 que
    // cazó el interceptor— el estado del usuario anterior desaparece. Esto no
    // es rendimiento: es privacidad. Y al hacerlo aquí, ningún sitio que llame
    // a logout() tiene que acordarse de limpiar nada.
    //
    // Nadie se desuscribe de esta suscripción, y es CORRECTO: los dos servicios
    // son providedIn: 'root' y viven lo mismo que la aplicación, así que la
    // suscripción no sobrevive a nadie. Una fuga es una suscripción que
    // sobrevive a su dueño; ésta no tiene a quién sobrevivir. Ejercicio 24.
    this.authService.currentUser$
      .pipe(filter((user) => user === null))
      .subscribe(() => this.reset());
  }

  load(): void {
    this.patch({ loading: true, error: null });

    // Suscripción a pelo, y aquí también está bien: un observable de HttpClient
    // completa por su cuenta en cuanto llega la respuesta, así que no queda
    // nada abierto. Compáralo con la suscripción del componente de la sección
    // 6, que nunca completa — ésa sí es una fuga.
    this.templateApi.getAll().subscribe({
      next: (templates) => {
        // [...templates] porque lo que llega es readonly y lo que guardamos no.
        // Esa copia parece responsable y sólo protege la mitad del camino: el
        // array que sale por state$ sigue siendo mutable 💸.
        this.patch({ items: [...templates], loading: false });
      },
      error: (error: unknown) => {
        this.patch({
          loading: false,
          error: error instanceof ApiError
            ? error.message
            : 'No se pudieron cargar las plantillas.',
        });
      },
    });
  }

  select(rowId: string): void {
    const selected = this.stateSubject.value.items.find((template) => template.id === rowId) ?? null;
    this.patch({ selected });
  }

  reset(): void {
    this.stateSubject.next(createInitialState<ChecklistTemplate>());
  }

  /**
   * El único punto del servicio que llama a next(). Reemplaza el objeto de
   * estado entero: la referencia cambia siempre, que es lo que hace posible
   * OnPush y distinctUntilChanged.
   */
  private patch(changes: Partial<FeatureState<ChecklistTemplate>>): void {
    this.stateSubject.next({ ...this.stateSubject.value, ...changes });
  }
}
```

**Detalles con intención**

- **`inject()` y no `constructor`.** El patrón lo fijó 2022; este archivo es de 2024. En `core/` conviven `AuthService` con su `constructor` y este servicio con su `inject()`, y los dos están bien — lo que no estaría bien es mezclar las dos formas dentro de un archivo.
- **`patch()` privado y único.** Un solo `next()` en todo el servicio significa que, cuando el estado quede raro, hay exactamente un sitio donde poner el breakpoint.
- **El `?? null` de `select()`.** Con `strict`, `find()` devuelve `ChecklistTemplate | undefined`, y el estado dice `| null`. Elegir uno de los dos y traducir en la frontera evita que medio proyecto tenga que comprobar los dos.

**El patrón a memorizar**

> El estado se **reemplaza**, no se retoca. Si después de una actualización `oldState === newState` sigue siendo cierto, no ha pasado nada para nadie que estuviera mirando.

### 5.3 Un derivado, y la trampa de `shareReplay`

Cuatro pantallas van a querer la última versión de cada familia de plantillas. Eso es estado derivado: no se guarda, se calcula.

```ts
// dentro de TemplateStateService

/**
 * La versión más alta de cada familia. Es un cálculo, no un dato: guardarlo
 * sería tener dos fuentes de verdad que se pueden desincronizar.
 *
 * Ojo: esto NO resuelve "qué versión aplica a esta fecha", que es otra cosa y
 * es la Fase 7 entera ⭐. Aquí sólo es "la más nueva de cada una".
 */
readonly latestVersions$: Observable<ChecklistTemplate[]> = this.templates$.pipe(
  map((templates) => {
    const latestByFamily = new Map<string, ChecklistTemplate>();

    for (const template of templates) {
      const current = latestByFamily.get(template.templateId);

      if (current === undefined || template.version > current.version) {
        latestByFamily.set(template.templateId, template);
      }
    }

    return [...latestByFamily.values()];
  }),
  // Sin esto, el Map se recorre una vez POR CADA suscriptor. Con cuatro
  // pantallas mirando, cuatro cálculos idénticos en cada emisión.
  //
  // ⚠️ `refCount: true` es la mitad que importa: hace que la suscripción a la
  // fuente se cierre cuando se va el último suscriptor. Con `refCount: false`
  // —que es el valor por defecto del atajo `shareReplay(1)`— la suscripción
  // interna queda viva para siempre aunque no quede nadie escuchando, y eso es
  // una fuga con nombre y apellido. Ejercicio 15.
  shareReplay({ bufferSize: 1, refCount: true }),
);
```

### 5.4 El pago de la 💸 de la Fase 3

Así quedó `TemplateListComponent` en la Fase 3:

```ts
// ANTES — Fase 3
export class TemplateListComponent implements OnInit, OnDestroy {
  templates: readonly ChecklistTemplate[] = [];
  loading = false;
  errorMessage: string | null = null;
  private subscription: Subscription | null = null;
  // …ngOnInit con subscribe, ngOnDestroy con unsubscribe…
}
```

Y así queda hoy:

```ts
// src/app/features/templates/template-list/template-list.component.ts
import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs';

import { FeatureState } from '../../../core/state/feature-state.model';
import { TemplateStateService } from '../../../core/state/template-state.service';
import { ChecklistTemplate } from '../../../core/models/checklist-template.model';

@Component({
  selector: 'cc-template-list',
  templateUrl: './template-list.component.html',
})
export class TemplateListComponent implements OnInit {
  readonly state$: Observable<FeatureState<ChecklistTemplate>>;

  // Sigue siendo un componente de 2021: inyección por constructor, sin OnPush,
  // declarado en TemplatesModule. Pagar una deuda NO es modernizar el archivo.
  // Y el pipe async, que es lo que resuelve esto, existe desde Angular 2: no
  // hay nada anacrónico en usarlo aquí.
  constructor(private readonly templateState: TemplateStateService) {
    // Se asigna en el constructor y no en el campo: un inicializador de campo
    // correría antes de que `templateState` exista. Misma razón que en el
    // formulario de login de la Fase 2.
    this.state$ = templateState.state$;
  }

  ngOnInit(): void {
    this.templateState.load();
  }
}
```

```html
<!-- src/app/features/templates/template-list/template-list.component.html -->
<h2>Plantillas de checklist</h2>

<!-- UN solo async pipe para las tres cosas que la vista necesita. Con
     `loading$ | async`, `error$ | async` y `templates$ | async` por separado
     tendrías tres suscripciones a la misma fuente. No es incorrecto —un
     BehaviorSubject es multicast y las tres emiten en el mismo tick— pero son
     tres tuberías donde basta una, y la plantilla se lee peor. -->
<ng-container *ngIf="state$ | async as state">
  <mat-progress-spinner
    *ngIf="state.loading"
    mode="indeterminate"
    diameter="32"
  ></mat-progress-spinner>

  <p class="template-error" *ngIf="state.error !== null">{{ state.error }}</p>

  <mat-nav-list *ngIf="!state.loading && state.error === null">
    <a mat-list-item *ngFor="let template of state.items">
      <span matListItemTitle>{{ template.templateId }} · v{{ template.version }}</span>
      <span matListItemLine>
        Vigente desde {{ template.validFrom }}
        <ng-container *ngIf="template.validUntil !== null">
          hasta {{ template.validUntil }}
        </ng-container>
        <ng-container *ngIf="template.validUntil === null">· sin fecha de fin</ng-container>
        · {{ template.items.length }} ítems
      </span>
    </a>
  </mat-nav-list>
</ng-container>
```

**Detalles con intención**

- **Desaparecieron cuatro cosas: el campo `templates`, el campo `loading`, el campo `errorMessage` y el `ngOnDestroy` entero.** No se sustituyeron por nada más corto: se sustituyeron por *nada*. El componente ya no recuerda; sólo pinta.
- **`implements OnDestroy` se fue con ellos.** Si un componente no tiene nada que limpiar, declarar el gancho vacío es ruido que la próxima persona va a leer buscando qué limpia.

**Prueba de fuego**

Entra a Plantillas, sal a Clientes y vuelve. La segunda vez la lista **aparece inmediatamente**, antes de que la nueva petición vuelva: son los datos que el servicio conservó. Eso es tener estado, y es lo que la Fase 3 no podía hacer.

### 5.5 El pago de la 💸 de la Fase 2

`AuthService` sigue siendo un archivo de 2021, así que el cambio va con `constructor` y sin `inject()`. Un `BehaviorSubject` en 2021 es perfectamente de época: RxJS los tiene desde siempre.

```ts
// src/app/core/auth.service.ts — sólo lo que cambia
import { BehaviorSubject, Observable, tap } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly currentUserSubject = new BehaviorSubject<AccessTokenPayload | null>(null);

  readonly currentUser$: Observable<AccessTokenPayload | null> =
    this.currentUserSubject.asObservable();

  constructor(private readonly http: HttpClient) {
    // La sesión puede existir antes de que la aplicación arranque: el token
    // sobrevive a la recarga. Se decodifica UNA vez, aquí.
    this.currentUserSubject.next(this.readUserFromStorage());
  }

  login(credentials: AuthCredentials): Observable<LoginResponse> {
    return this.http
      .post<LoginResponse>(`${environment.apiBaseUrl}/auth/login`, credentials)
      .pipe(
        tap((response) => {
          localStorage.setItem(TOKEN_STORAGE_KEY, response.accessToken);
          this.currentUserSubject.next(this.readUserFromStorage());
        }),
      );
  }

  logout(): void {
    localStorage.removeItem(TOKEN_STORAGE_KEY);
    // Emitir null es lo que dispara el reset() de todos los servicios de estado
    // que estén escuchando. Nadie tiene que acordarse de limpiar nada.
    this.currentUserSubject.next(null);
  }

  /** Sigue siendo síncrono porque el guard lo necesita síncrono. */
  isAuthenticated(): boolean {
    const user = this.currentUserSubject.value;

    return user !== null && user.exp * 1000 > Date.now();
  }

  getCurrentUser(): AccessTokenPayload | null {
    // Ya no decodifica: lee el valor que el sujeto tiene guardado. Éste es el
    // cambio que paga la deuda, y se mide con el console.count del ejercicio 8.
    return this.currentUserSubject.value;
  }

  /** El decodificado de verdad, ahora en un solo sitio y llamado dos veces por sesión. */
  private readUserFromStorage(): AccessTokenPayload | null {
    // …el cuerpo que tenía getCurrentUser() en la Fase 2, sin cambios…
  }
}
```

Y el shell deja de llamar a métodos desde la plantilla:

```ts
// src/app/layout/shell/shell.component.ts — sólo lo que cambia
export class ShellComponent {
  readonly currentUser$: Observable<AccessTokenPayload | null>;

  // authService pasa de `public` a `private`: la plantilla ya no lo necesita, y
  // eso es la mitad del pago. Un servicio público en un componente casi siempre
  // significa que la plantilla está llamando a métodos.
  constructor(
    private readonly authService: AuthService,
    private readonly router: Router,
  ) {
    this.currentUser$ = authService.currentUser$;
  }

  logout(): void {
    this.authService.logout();
    void this.router.navigate(['/login']);
  }
}
```

```html
<!-- shell.component.html — sólo el bloque de la toolbar -->
<ng-container *ngIf="currentUser$ | async as currentUser">
  <span class="shell-user">{{ currentUser.name }} · {{ currentUser.role }}</span>
  <button mat-icon-button (click)="logout()" aria-label="Cerrar sesión">
    <mat-icon>logout</mat-icon>
  </button>
</ng-container>
```

**Prueba de fuego**

Pon `console.count('decode')` dentro de `readUserFromStorage()`. Entra, navega entre cuatro pantallas, abre y cierra el sidenav diez veces. **El contador dice 2**: una al arrancar la aplicación y otra al hacer login. Ahora abre `deuda.md` y compáralo con el número que anotaste en el ejercicio 12 de la Fase 2. Ésa es la factura pagada, con recibo.

### 5.6 El reseteo que nadie tiene que recordar

Ya está escrito: son las cinco líneas del constructor de `TemplateStateService` en 5.2. Merece un párrafo aparte porque la decisión de dónde ponerlo es lo interesante.

La forma obvia sería que `logout()` limpiara todos los estados. Y es la peor de las tres, por dos razones: obliga a `AuthService` —un archivo de infraestructura— a conocer todos los servicios de feature, y obliga a que alguien se acuerde de añadir el siguiente. La segunda opción, un `AppStateService` con un `resetAll()`, arregla lo de acordarse y deja la misma dependencia al revés.

La tercera, que es la que usamos, invierte quién sabe de quién: **cada servicio de estado escucha el cierre de sesión y se limpia solo.** `AuthService` no sabe que existen los servicios de estado; los servicios de estado sí saben que existe la sesión, que es la dirección natural de la dependencia. Añadir el siguiente servicio es añadir cinco líneas en su propio archivo, y olvidarlas es un bug de ese archivo y no de otro.

Tiene un costo, y hay que decirlo: **un servicio que nunca se instanció no se resetea**, porque no existe. Da igual —si nunca se instanció, no tiene estado que filtrar— pero es la clase de razonamiento que conviene tener escrito antes de que alguien lo descubra a las once de la noche.

### 5.7 El molde para las features que faltan

`ClientStateService` lo escribe la Fase 6. Ésta es su firma, y es idéntica a la de hoy salvo por el tipo:

```ts
// src/app/core/state/client-state.service.ts — la Fase 6 lo implementa
@Injectable({ providedIn: 'root' })
export class ClientStateService {
  readonly state$: Observable<FeatureState<Client>>;
  readonly clients$: Observable<Client[]>;
  readonly selected$: Observable<Client | null>;
  readonly loading$: Observable<boolean>;
  readonly error$: Observable<string | null>;

  load(): void;
  select(id: number): void;
  reset(): void;
}
```

**Detalles con intención**

- **`selected: Client | null` y no `selectedId: number | null`.** Guardar el id obliga a cada suscriptor a buscar el objeto, y a decidir qué hace si no lo encuentra. Guardar el objeto responde esa pregunta una sola vez, en el servicio. El ejercicio 16 te hace defender la otra opción, que también tiene argumentos.
- **Un servicio casi idéntico por feature, y ninguna clase base.** Es repetición deliberada: el día que uno de ellos necesite algo distinto —y en la Fase 7 uno lo va a necesitar— no habrá que romper una jerarquía para conseguirlo.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** la pantalla de Plantillas dice que no hay ninguna, y en el mock están las tres.
**Causa:** nadie llamó a `load()`. Con el patrón de la Fase 3, la petición salía del `ngOnInit` y era imposible olvidarla; ahora el componente sólo pinta, y pedir es una decisión explícita.
**Fix mínimo:** el `load()` en `ngOnInit`.
**Lo que importa:** el estado inicial de un `BehaviorSubject` **es un estado válido y se pinta**. Una lista vacía no dice "no he pedido nada": dice "no hay nada". Distinguir las dos cosas es lo que el campo `loading` está intentando hacer, y por eso importa que empiece en `false` y no en `true`. Es el incidente **05**.

**Síntoma:** `Property 'next' does not exist on type 'Observable<FeatureState<ChecklistTemplate>>'`.
**Causa:** alguien intentó empujar un valor al estado desde fuera del servicio.
**Fix mínimo:** ninguno — el compilador tiene razón. Lo que falta es un método en el servicio que haga ese cambio con nombre.
**Lo que importa:** este error es el patrón funcionando. La tentación de "abrirlo un momentito" es exactamente cómo un estado con un dueño se convierte en un estado con veinte.

**Síntoma:** cambias de usuario y ves las plantillas del anterior durante un segundo.
**Causa:** el `reset()` llega, pero el `load()` de la pantalla nueva todavía no. Entre los dos hay un instante con el estado inicial.
**Fix mínimo:** ninguno, porque no es un fallo: es cómo se ve el estado compartido. Lo que se ajusta, si molesta, es qué pinta la vista mientras `loading` es `true`.
**Lo que importa:** distinguir un bug de una consecuencia. El ejercicio 26 te da el ticket con esa frase exacta y te pide decidir cuál de las dos cosas es.

**Síntoma:** al entrar y salir de una pantalla varias veces, cada acción se ejecuta más veces que la anterior.
**Causa:** una suscripción manual sin cerrar. Es la fuga, y tiene su propia sección.

### Pieza forense de esta fase

Esto no se lee: se hace. Construye el componente con fuga, provócala, y ciérrala de las cuatro formas.

```ts
// src/app/features/templates/template-counter/template-counter.component.ts
// Este componente está roto A PROPÓSITO. No lo copies a producción.
@Component({
  selector: 'cc-template-counter',
  template: '<p>Plantillas cargadas: {{ count }}</p>',
})
export class TemplateCounterComponent implements OnInit {
  count = 0;

  constructor(private readonly templateState: TemplateStateService) {}

  ngOnInit(): void {
    // templates$ viene de un BehaviorSubject de un servicio raíz: NUNCA
    // completa. Este componente sí se destruye. La suscripción sobrevive a su
    // dueño, y eso es la definición de fuga.
    this.templateState.templates$.subscribe((templates) => {
      console.count('TemplateCounter recibió');
      this.count = templates.length;
    });
  }
}
```

**La fuga en el comportamiento.** Móntalo en la pantalla de Plantillas, entra y sal cinco veces, y en la sexta pulsa lo que dispare un `load()`. La consola no dice `1`: dice `6`. Hay seis componentes recibiendo, y cinco de ellos ya no están en pantalla. Con un `console.count` bastó; no hizo falta abrir ninguna herramienta.

**La fuga en la memoria.** El comportamiento sólo delata las fugas que *hacen* algo visible. Para las otras: DevTools → Memory → *Heap snapshot* antes, las diez navegaciones, snapshot después, y en el filtro escribe `TemplateCounter`. Vas a encontrar diez instancias vivas, y si sigues el enlace de retención llegas al `Subscriber` que las sostiene. Ésa es la investigación que sirve cuando el síntoma es "la pestaña va poniéndose lenta con las horas" y no hay ningún contador que mirar.

**Las cuatro formas de cerrarla**, en orden cronológico:

```ts
// ── 2021 A · Subscription + ngOnDestroy ────────────────────────────────────
private subscription: Subscription | null = null;
ngOnInit(): void { this.subscription = source$.subscribe(/* … */); }
ngOnDestroy(): void { this.subscription?.unsubscribe(); }
// Funciona. Con tres suscripciones son tres campos y tres líneas que olvidar.

// ── 2021 B · takeUntil + Subject de destrucción ────────────────────────────
private readonly destroy$ = new Subject<void>();
ngOnInit(): void { source$.pipe(takeUntil(this.destroy$)).subscribe(/* … */); }
ngOnDestroy(): void { this.destroy$.next(); this.destroy$.complete(); }
// Escala mejor y tiene dos trampas célebres: olvidar el next() antes del
// complete() —y entonces no cierra nada— y poner takeUntil en medio del pipe.
// Debe ir SIEMPRE el último: lo que venga después de él se suscribe aparte y
// sigue vivo. Ejercicio 11.

// ── 2024 · takeUntilDestroyed ──────────────────────────────────────────────
source$.pipe(takeUntilDestroyed()).subscribe(/* … */);
// Sin campos, sin gancho, sin nada que olvidar. Exige contexto de inyección:
// en un inicializador de campo o en el constructor funciona; en ngOnInit hay
// que pasarle el DestroyRef, `takeUntilDestroyed(this.destroyRef)`.
// Y sigue teniendo que ir el último. Ejercicio 12.

// ── La que de verdad usa esta fase · no suscribirse ────────────────────────
readonly count$ = this.templateState.templates$.pipe(map((t) => t.length));
// Y en la plantilla: {{ count$ | async }}
// Cero suscripciones que cerrar, porque no hay ninguna que abrir.
```

> 🧭 **La regla que se lleva el estudiante:** si la suscripción es para **pintar**, va `async` pipe y no hay nada que cerrar. Si es para provocar un **efecto** —guardar, navegar, abrir un diálogo—, va `.subscribe()`, y entonces alguien tiene que desuscribirse. En esta fase no hay ni un solo efecto, y por eso no hay ni una sola suscripción manual en producción.

> 📄 El recorrido completo, con la lectura del panel Memory paso a paso y cómo seguir la cadena de retención, en `forense-fase-04.md`.

**🧨 Rompe a propósito**

Cambia el `shareReplay({ bufferSize: 1, refCount: true })` de `latestVersions$` por el atajo `shareReplay(1)`. Después:

1. Suscríbete desde la consola, guarda la suscripción, y desuscríbete.
2. Dispara un `load()`. ¿Se sigue ejecutando el `map` del `latestVersions$`? Compruébalo con un `tap(() => console.count('recalculado'))`.
3. Repite con `refCount: true`. ¿Qué cambia?
4. ¿Por qué crees que el atajo de una línea tiene el valor por defecto peligroso?

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Escribe `FeatureState<T>` y `createInitialState<T>()`. Después comprueba con `===` que dos llamadas devuelven objetos distintos, y explica en tres frases qué pasaría en las demás features si fuera una constante exportada.
2. Implementa `load()` y comprueba en Network que entrar tres veces a Plantillas dispara tres peticiones. Anota el número: el ejercicio 19 lo cuestiona.
3. **Diagnóstico.** Cambia `state$` para que exponga el `BehaviorSubject` directamente en vez de `asObservable()`. Haz un `.next()` desde `TemplateListComponent`, comprueba que compila y funciona, y escribe en cinco líneas qué garantía acabas de perder y cómo se manifestaría dentro de tres meses.
4. Sustituye el `state$ | async as state` de la plantilla por tres pipes separados (`loading$`, `error$`, `templates$`). Añade un `tap(() => console.count('suscripción'))` a `state$` y compara el conteo de las dos versiones.
5. **Diagnóstico.** Con `CHAOS=error CHAOS_RATE=1`, entra a Plantillas. Responde: ¿qué valen `items`, `loading` y `error` en el estado? ¿Se borraron las plantillas que ya había? ¿Debería?
6. Añade `reset()` y llámalo desde la consola del navegador con la pantalla abierta. Describe qué ves y en qué orden.
7. Entra como `inspector@certcore.co`, ve a Plantillas, cierra sesión, entra como `supervisor@certcore.co` y vuelve a Plantillas. Comprueba que no hay rastro de la sesión anterior y explica **qué línea de qué archivo** lo consiguió.
8. Pon `console.count('decode')` en `readUserFromStorage()`. Navega cuatro pantallas y abre el sidenav diez veces. Anota el número junto al del ejercicio 12 de la Fase 2 en `deuda.md`, con la fecha. Es el recibo.

**🟡 Intermedio (9–17)**

9. **Diagnóstico.** Monta `TemplateCounterComponent` tal como está en la sección 6, navega cinco veces entrando y saliendo de Plantillas, y dispara un `load()`. Entrega la salida de la consola y explica qué son cada uno de esos mensajes.
10. Cierra la fuga con `Subscription` + `ngOnDestroy` y verifica que el contador vuelve a 1. Después añade una segunda suscripción al mismo componente y cuenta cuántas líneas nuevas hicieron falta.
11. Ciérrala con `takeUntil` + `Subject`. Después provoca las dos trampas: primero olvida el `destroy$.next()` dejando sólo el `complete()`, y después mueve el `takeUntil` a la mitad del pipe con un `map` detrás. Describe qué pasa en cada caso y por qué el segundo es más difícil de ver.
12. Ciérrala con `takeUntilDestroyed()`. Explica por qué falla si lo llamas dentro de `ngOnInit` sin argumentos, y qué hay que pasarle para que funcione ahí.
13. **Diagnóstico.** Compara las cuatro soluciones de la sección 6 en una tabla de tres columnas: líneas de código, qué se te puede olvidar, y en qué generación de CertCore la escribirías. Añade una quinta fila con la que usarías si la suscripción tuviera un efecto y no sólo pintara.
14. Implementa `latestVersions$` con `shareReplay({ bufferSize: 1, refCount: true })`. Añade un `tap` antes del `shareReplay` y demuestra con dos suscriptores que el `map` se ejecuta **una** vez por emisión y no dos.
15. **Diagnóstico.** Haz el 🧨 de la sección 6 y entrega las cuatro respuestas.
16. Escribe la firma completa de `ClientStateService` sin implementarla. Después defiende **la opción contraria** a la del curso: por qué `selected` podría ser `number | null` en vez de `Client | null`, y en qué caso concreto de CertCore eso sería mejor.
17. **Diagnóstico.** Con `CHAOS=latency CHAOS_DELAY_MS=4000`, llama a `load()` dos veces seguidas cambiando el `db.json` entre medias. Determina cuál de las dos respuestas acaba en el estado. ¿Es la última que pediste? Explica el mecanismo.

**🟠 Difícil (18–24)**

18. Quita el `distinctUntilChanged()` de los derivados, pon `console.count` en un `tap` de `templates$`, y cuenta cuántas veces reacciona al cambiar sólo `loading`. Vuelve a ponerlo y compara. Entrega los dos números.
19. Añade a `load()` un corto circuito: si `items.length > 0`, no vuelve a pedir. Comprueba que ahorra peticiones. Después argumenta en diez líneas por qué esa optimización es un bug esperando a la Fase 6, y qué le pasa a un usuario que acaba de crear un cliente en otra pestaña.
20. **Diagnóstico.** Panel Memory. Snapshot con la aplicación recién cargada, diez navegaciones entrando y saliendo de Plantillas con el componente con fuga montado, snapshot después. Filtra por `TemplateCounter`, entrega los dos números de instancias, y sigue la cadena de retención hasta el objeto que las sostiene. Di cómo se llama.
21. Provee `TemplateStateService` en la ruta de `templates` en vez de en `root`. Responde con evidencia: ¿cuántas instancias hay ahora? ¿Qué pasa con la lista al salir y volver? ¿Y con el `reset()` del cierre de sesión? Después describe un caso de CertCore donde el provider de ruta **sería** la decisión correcta.
22. **Diagnóstico.** Desde `TemplateListComponent`, haz `state.items.push(fakeTemplate)` sobre lo que te dio el `async`. Comprueba que TypeScript te deja y que la pantalla, con detección por defecto, hasta se actualiza. Ahora explica qué pasaría exactamente si ese componente tuviera `OnPush` — que es lo que va a tener en la Fase 6 — y por qué el bug sería peor que "no se actualiza".
23. El campo `loading` es un booleano. Dispara dos cargas concurrentes (`load()` dos veces con `CHAOS=latency`), y demuestra que el booleano se queda mal: la primera en volver lo pone en `false` mientras la segunda sigue en vuelo. Propón la forma **mínima** que lo arregla sin cambiar la firma pública.
24. **Diagnóstico.** El constructor de `TemplateStateService` se suscribe a `currentUser$` y nunca se desuscribe. Argumenta con precisión por qué eso **no** es una fuga, y después construye el caso que sí lo sería: cambia una de las dos piezas para convertirla en una, y demuéstralo.

**🔴 Muy difícil (25–30)**

25. Escribe el post-mortem completo de ocho puntos del incidente **05** siguiendo `formato-cuaderno-incidentes.md` §7, con su par de tags `inc/05/<slug>-roto` / `-fix`. Indica cuál de las tres formas de preparación de §4 usarías y por qué.
26. **Diagnóstico.** Ticket: *"a veces al entrar a Plantillas veo la lista de hace un rato y un segundo después cambia"*. Explica el mecanismo exacto con los tiempos, decide si es un bug o la consecuencia de una decisión, y propón tres tratamientos —`reset()` al entrar, esqueleto de carga, no hacer nada— con lo que gana y lo que pierde cada uno. Recomienda uno y defiéndelo.
27. Escribe para tu equipo la sección "dónde este patrón se queda corto", con **cuatro** límites y un caso concreto de CertCore para cada uno: uno de las plantillas versionadas, uno de los certificados, uno del panel y uno de la trazabilidad. Que cada caso diga qué síntoma tendría el usuario, no sólo qué le falta al patrón.
28. Implementa la cancelación con `switchMap` para que gane siempre la última carga pedida. Verifica con el ejercicio 17. Después responde lo difícil: si aplicaras el mismo patrón a un `POST` que crea una inspección, ¿qué pasaría exactamente, y por qué `switchMap` es la respuesta correcta para leer y la equivocada para escribir?
29. **Diagnóstico.** Dos pestañas con la misma sesión. Cierra sesión en una. ¿Se reseteó el estado de la otra? ¿Se enteró siquiera? Conecta la respuesta con el ejercicio 25 de la Fase 2 y di si la solución que propusiste allí arreglaría también esto, o sólo la mitad.
30. Escribe `AbstractStateService<T>` como clase base genérica y reimplementa `TemplateStateService` heredando de ella. Entrega las dos versiones y las dos cuentas de líneas. Después argumenta, con el caso de la Fase 7 en la cabeza —donde un servicio de estado va a necesitar algo que los otros no—, por qué el curso eligió la repetición. Si al terminar sigues prefiriendo la clase base, escribe por qué: es una discusión legítima y no tiene una respuesta única.

**🔥 Opcionales**

- 🔥 Añade un `tap` de registro en `patch()` que imprima el cambio y el estado resultante. Acabas de escribir el 5% de unas devtools de estado. Mide cuánto te ayuda durante los siguientes tres ejercicios y decide si lo dejas.
- 🔥 Haz que `TemplateStateService` guarde también **cuándo** se cargó por última vez, y que `load()` no pida si han pasado menos de treinta segundos. Después busca el caso donde eso te muerde.
- 🔥 Escribe un `StateInspectorComponent` que muestre el estado completo de las features cargadas en una esquina de la pantalla, activable por un atajo de teclado. Es la herramienta que el patrón no trae.

---

## 📚 8. Referencias

**Documentación oficial**

- https://rxjs.dev/api/index/class/BehaviorSubject — qué lo distingue de un `Subject` y por qué el valor inicial cambia todo.
- https://rxjs.dev/api/index/function/shareReplay — el operador y sus opciones. Lee dos veces la parte de `refCount`.
- https://rxjs.dev/api/operators/distinctUntilChanged — y la advertencia de que compara por referencia salvo que le pases un comparador.
- https://v16.angular.io/api/common/AsyncPipe — el pipe que hace innecesaria la mitad de esta fase.
- https://v16.angular.io/api/core/rxjs-interop/takeUntilDestroyed — llegó en la 16 y exige contexto de inyección. La página lo dice en dos líneas que conviene no saltarse.
- https://v16.angular.io/guide/dependency-injection-providers y https://v16.angular.io/guide/hierarchical-dependency-injection — `providedIn: 'root'` frente al provider de ruta, para el ejercicio 21.
- https://developer.chrome.com/docs/devtools/memory-problems/ — cómo tomar un snapshot y leer la cadena de retención. Es la herramienta del ejercicio 20. ⚠️ Chrome reorganiza su documentación con frecuencia: si la URL falla, busca "heap snapshot" en el sitio de DevTools.

> ⚠️ Casi todo lo que encuentres escrito sobre estado en Angular desde 2023 habla de **signals**, y de librerías construidas sobre ellas. En Angular 16 los signals son experimentales y CertCore no los usa: aquí se leen en la Fase 12 y se proyectan en **A11**. Cuando un artículo empiece con `signal(0)`, estás leyendo la 17 o posterior.

**Video y apoyo**

- Las charlas sobre "state management without NgRx" de la comunidad Angular de 2021-2022 describen exactamente este patrón, y suelen ser más honestas sobre sus límites que la documentación de las librerías. ⚠️ Busca por tema; los identificadores de video cambian y no vamos a inventar uno.

**Orden de lectura sugerido**

Antes de escribir código: **A07** entero, que es corto y es el marco de esta fase; la página de `BehaviorSubject` si vienes sin RxJS. Durante: `AsyncPipe` cuando llegues a 5.4, y `takeUntilDestroyed` cuando llegues a la sección 6. Después: `shareReplay` y **A06**, releídos con el 🧨 hecho — el operador no se entiende hasta que has visto su fuga.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore tiene un sitio donde vive el estado, y una regla clara sobre quién puede cambiarlo. Tienes un `BehaviorSubject` privado que nadie de fuera puede tocar, derivados que se calculan solos, errores que viven en el estado en vez de morir en un `catch`, un cierre de sesión que limpia sin que nadie se acuerde, y cero suscripciones manuales en producción.

Y tienes dos facturas pagadas con recibo: el `console.count` del decodificado bajó de decenas por minuto a dos por sesión, y `TemplateListComponent` perdió cuatro campos y un gancho de ciclo de vida sin ganar nada a cambio, que es la mejor clase de refactorización que existe.

Lo que de verdad te llevas es la distinción entre una suscripción y una fuga. Ya no vas a mirar un `.subscribe()` con desconfianza automática: vas a preguntarte quién vive más, si el que emite o el que escucha. Cuando el que escucha se muere primero y nadie cerró la puerta, ahí está tu fuga — y ya sabes buscarla con un `console.count` cuando hace ruido y con un heap snapshot cuando no.

La **Fase 5** es la bisagra del curso. Hasta aquí has escrito una aplicación de NgModules con piezas modernas enchufadas; a partir de ahí vas a aprender a **vivir con las dos generaciones a la vez**: se convierte un módulo de feature a standalone —el que la Fase 6 va a necesitar—, se deja el resto intacto, y se cobra la deuda 💸 más antigua que arrastras, la del `SharedModule` de la Fase 1, con el bundle medido antes y después — que se paga en parte, y descubrir por qué el resto no se puede pagar vale más que el propio pago. También es donde vas a ver que un `NullInjectorError` de un standalone y el del mismo error en un `NgModule` no se parecen en nada.

> **La señal de que quedó bien:** cuando ves un `.subscribe()` en un pull request y tu primera pregunta ya no es "¿se desuscribe?", sino "¿quién de los dos se muere antes?".

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-04 -m "F4 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 04: …`) y los de ejercicio su
> número (`fase 04 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f04/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Ésta es la primera fase que **paga** deudas declaradas antes, y el tag es lo
> que convierte el pago en algo que se puede leer. `git diff fase-01 fase-04 --
> src/app/layout/shell/` te enseña la factura del `ShellComponent` de punta a
> punta, y `git diff fase-03 fase-04 -- src/app/features/templates/` la del
> listado. Guarda los dos números de `deuda.md` en el mensaje del tag: dentro de
> seis fases van a ser la única prueba de que aquello costaba algo.

---

## 📌 Pendientes sugeridos

- **Las dos 💸 de las Fases 2 y 3 quedan saldadas**, y conviene que se note fuera de este documento: el 📌 de la Fase 2 pedía confirmar que la Fase 4 tocaría `AuthService`, y lo hizo. → **Cerrado**, sin acción pendiente.
- **La 💸 de mutabilidad que nace hoy tiene una sola pagadora: la Fase 6.** Su prompt ya la describe con precisión. Si esa fase decide no pagarla, hay que reclasificarla explicando por qué, porque es la que justifica que `OnPush` importe. → **Aviso ya escrito en el prompt de la Fase 6.**
- **El `loading` booleano se rompe con cargas concurrentes** (ejercicio 23) y el patrón no ordena las respuestas (ejercicio 17). Las dos cosas se arreglan de verdad con `switchMap` en la **Fase 6**, que es donde hay una búsqueda que las provoca de forma natural. Hoy se muestran y se dejan abiertas a propósito. → **Aviso para el chat de la Fase 6.**
- 🪦 **El servicio de estado que no encaja en el molde, confirmado.** La Fase 7 reescribió `TemplateStateService` con un `TemplateState` propio —`versions` en vez de `items`, `selectedFamilyId` en vez de `selected`— y mantuvo el resto del patrón intacto. Es exactamente el caso que justificó no hacer una clase base, y de paso renombró `select(rowId)` a `selectFamily(templateId)`, cambio documentado allí. → **Cerrado**, sin acción pendiente.
- **La zona horaria sigue sin dueño.** Esta fase la esquivó a propósito: `latestVersions$` compara números de versión y no fechas, precisamente para no adelantar la decisión que le toca a la **Fase 10** (fijar la zona horaria de referencia en un solo sitio). Cuando esa fase la fije, la resolución por fecha de la Fase 7 tiene que usarla. → **Dependencia Fase 7 ← Fase 10** que conviene no perder de vista.
- **`StateInspectorComponent`** (ejercicio 🔥) es el 5% de unas devtools y da para un apéndice pequeño. Si alguna vez el curso quiere ese material, no es una fase. → **Ejercicio 🔥, y no más.**
- 🔥 **Un diagrama del flujo de una carga** —componente pide, servicio marca `loading`, `ApiService` va, vuelve, `patch`, emite, `async` pinta— cerraría el trío de ilustraciones pendientes con las de las Fases 2 y 3.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 05 | "Entro a Plantillas y dice que no hay ninguna, pero en el mock están las tres" | Estado (servicios) | 🟢 |
