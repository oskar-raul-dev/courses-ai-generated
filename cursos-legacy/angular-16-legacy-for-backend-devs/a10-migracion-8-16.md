# 📎 Apéndice A10 — Puente Angular 8/9 → 16

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: lectores que vienen del Track A (LabCore) · De consulta en todas las fases
> Versión cubierta: de Angular 8.2.14 / 9 hasta 16.2.12

**Esto no se lee de corrido, y además no es una guía de migración.** Es un **puente conceptual**: sirve para que alguien con los reflejos de Angular 8 puestos pueda leer el código de CertCore sin traducir mentalmente cada línea. No propone migrar nada, no explica `ng update`, y no hay ningún proyecto que llevar de una versión a la otra.

**Y es el único documento del cuerpo del curso donde nombrar LabCore es correcto** —el otro sitio es la sección *«Su curso hermano»* del `README.md`, que se lee antes de empezar; la regla completa está en §12.1 de la guía de estilo—, porque su lector es exactamente quien vino del Track A y trae ocho fases de laboratorio clínico en los dedos. Si llegaste directo al Track B y no sabes qué es LabCore, **este apéndice es opcional y puedes saltártelo entero**: nada del curso depende de él.

**Qué queda fuera:** el procedimiento real de migrar —`ng update` una mayor por vez, leer el diff de las schematics, `ngcc`, la ficha por dependencia, el ensayo en rama desechable—. Eso está desarrollado en el propio Track A, en sus apéndices A10 y A11, y no se repite aquí porque este documento va en la otra dirección: no cómo llegar, sino **cómo leer lo que hay al otro lado**.

---

## Índice

- [1. Para quién es esto, y para quién no](#1-para-quién-es-esto-y-para-quién-no)
- [2. Las cuatro puertas](#2-las-cuatro-puertas)
- [3. Qué desapareció y qué sólo cambió de nombre](#3-qué-desapareció-y-qué-sólo-cambió-de-nombre)
- [4. RxJS 6 → 7](#4-rxjs-6--7)
- [5. Formularios sin tipar → tipados](#5-formularios-sin-tipar--tipados)
- [6. Guards e interceptors de clase → funcionales](#6-guards-e-interceptors-de-clase--funcionales)
- [7. NgRx de 2019 → estado en servicios](#7-ngrx-de-2019--estado-en-servicios)
- [8. ⭐ Tabla de traducción LabCore → CertCore](#8--tabla-de-traducción-labcore--certcore)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-7)

---

## 1. Para quién es esto, y para quién no

**Es para ti si** acabas de terminar el Track A —o lo estás haciendo— y abres el primer archivo de CertCore con la sensación de que está escrito en otro idioma. No lo está: son las mismas ideas con siete versiones encima. Este apéndice te dice cuáles de tus reflejos siguen sirviendo, cuáles cambiaron de nombre, y cuáles hay que desaprender.

**No es para ti si** llegaste directo al Track B. Aquí no hay nada que las fases no expliquen por su cuenta, y leer sobre las carencias de Angular 8 antes de haber escrito una línea de la 16 no aclara nada.

> 🧠 **La buena noticia primero, porque es la más grande.** Lo que aprendiste en el Track A no era Angular 8: era **cómo se lee, se depura y se arregla un sistema heredado sin romperlo**. Eso no caduca con las versiones. La máquina de estados, el versionado por fecha, el ticket vago, el diff de ambientes, el post-mortem sin culpabilización — todo eso vale igual aquí. Lo que cambia es la sintaxis, y la sintaxis se traduce en una tarde.

---

## 2. Las cuatro puertas

Ocho versiones mayores suenan a ocho problemas y no lo son. Todo lo que te va a desconcertar de CertCore cabe en cuatro cambios, y los cuatro tienen fecha.

**Puerta 1 — Ivy (Angular 9).** LabCore compila con ViewEngine; CertCore con Ivy. Para ti, como lector de código, cambia poco: la sintaxis de las plantillas es la misma. Cambia mucho para lo que ves cuando algo falla — los mensajes de error de Ivy son otros, llevan código (`NG0100`, `NG0203`) y apuntan mejor— y para lo que sale del build, porque Ivy es lo que hizo posible que un componente exista sin `NgModule`, que es la puerta 3.

**Puerta 2 — `strict` (Angular 10 lo ofrece, la decisión es del proyecto).** LabCore vive con `strict: false` y `any` tolerado; CertCore tiene `strict: true` desde el primer archivo y `any` prohibido. **Ésta es la puerta que más trabajo te va a dar y la que más te va a devolver.** Una familia entera de bugs del Track A —el campo que llegó `undefined`, la cadena mágica de `patientForm.get('documentID')` con la D mayúscula— aquí sencillamente no compila.

**Puerta 3 — Standalone (estable en Angular 15).** Un componente puede declarar sus propias dependencias y no pertenecer a ningún `NgModule`. En LabCore, todo componente vive en un `declarations`; en CertCore conviven las dos formas a propósito, y decidir en cuál escribes es el músculo central del track.

**Puerta 4 — `inject()` (Angular 14).** La inyección se sale del constructor. Es la que menos cambia el comportamiento y la que más cambia el aspecto del código: un servicio de CertCore normalmente **no tiene constructor**, y la primera vez eso desconcierta.

> 📝 **Y una que no es puerta pero sí es una diferencia de proyecto.** LabCore usa NgRx montado al estilo de 2019; CertCore usa servicios con `BehaviorSubject`. Eso no es una consecuencia de la versión: es una decisión distinta que tomaron dos equipos distintos (§7). Ninguna de las dos empresas se equivocó.

---

## 3. Qué desapareció y qué sólo cambió de nombre

| En LabCore (Angular 8) | En CertCore (Angular 16) | ¿Qué pasó? |
|---|---|---|
| `platformBrowserDynamic().bootstrapModule(AppModule)` | `bootstrapApplication(AppComponent, appConfig)` | forma nueva; la vieja sigue existiendo |
| `@NgModule` obligatorio para todo | `standalone: true` en código nuevo | el `NgModule` **no desapareció**: dejó de ser obligatorio |
| `constructor(private http: HttpClient)` | `private readonly http = inject(HttpClient)` | las dos formas conviven, incluso en CertCore |
| `HttpClientModule` en `imports` | `provideHttpClient(...)` en `providers` | forma nueva; la vieja sigue funcionando |
| `RouterModule.forRoot(routes)` | `provideRouter(routes)` o `RouterModule` | conviven; CertCore usa la heredada en el raíz |
| `loadChildren: () => import(...).then(m => m.Module)` | `loadComponent` o `loadChildren` a un array de rutas | se amplió: ahora una ruta puede cargar un componente suelto |
| `ngOnDestroy` + `Subscription.unsubscribe()` | `takeUntilDestroyed(destroyRef)` | añadido en la 16; las formas viejas siguen vivas |
| `.bind(this)` / `var self = this` | arrow functions | **esto sí desaparece**: en CertCore sería un anacronismo |
| `patientForm.get('documentId').value` → `any` | `form.controls.taxId.value` → `string` | los formularios se hicieron genéricos en la 14 |
| `entryComponents` | — | **desapareció de verdad** con Ivy: ya no hace falta |
| `ViewChild(..., { static: true })` | el `static` sigue existiendo y se usa poco | Ivy cambió el valor por defecto y dejó de ser el campo minado que era |

> 🧭 **La regla que resume la tabla: casi nada desapareció; casi todo se volvió opcional.** Angular ha sido notablemente cuidadoso con la compatibilidad hacia atrás, y por eso un sistema como CertCore puede tener módulos de 2021 conviviendo con componentes de 2024 sin que nada esté roto. Tu instinto de "esto es viejo, hay que cambiarlo" es exactamente el que este curso te va a pedir que reprimas.

---

## 4. RxJS 6 → 7

LabCore usa RxJS 6.5.5; CertCore usa 7.8.1. Tres diferencias visibles y ninguna conceptual:

```ts
// LabCore (RxJS 6)
import { map, switchMap } from 'rxjs/operators';
import { of, combineLatest } from 'rxjs';
const both$ = combineLatest(a$, b$);          // argumentos sueltos
const value = await someObservable.toPromise();

// CertCore (RxJS 7)
import { map, switchMap, of, combineLatest } from 'rxjs';   // todo desde 'rxjs'
const both$ = combineLatest([a$, b$]);        // siempre un array
const value = await firstValueFrom(someObservable);
```

- **Los imports.** En la 7 todos los operadores salen de `'rxjs'`. El `'rxjs/operators'` de la 6 sigue funcionando, en desuso, y verlo es la señal más rápida de que un ejemplo es viejo.
- **`combineLatest` con argumentos sueltos desapareció.** Ahora es siempre un array.
- **`toPromise()` está deprecado** y se sustituye por `firstValueFrom()` o `lastValueFrom()`, que además te obligan a decidir cuál querías — `toPromise()` devolvía el último valor y `undefined` si no había ninguno, que es de las peores decisiones de diseño de esta librería.

**Lo que no cambió es el 95%:** `map`, `switchMap`, `combineLatest`, `catchError`, `debounceTime`, `shareReplay` se comportan igual. Si en el Track A entendiste la diferencia entre `switchMap` y `mergeMap`, aquí no tienes nada nuevo que aprender.

**Lo que sí es nuevo y te va a gustar:** `takeUntilDestroyed()`, que no es de RxJS sino de Angular 16, y que hace en una línea lo que en LabCore era un campo `destroy$`, un `ngOnDestroy` y dos líneas dentro. El tratamiento completo de los ocho operadores del curso está en **A06**.

---

## 5. Formularios sin tipar → tipados

Aquí está el cambio con mejor relación entre esfuerzo y alivio de todo el puente.

```ts
// ── LabCore (Angular 8) ────────────────────────────────────────────────────
patientForm: FormGroup;

constructor(private fb: FormBuilder) {
  this.patientForm = this.fb.group({
    documentId: ['', Validators.required],
  });
}

// `get()` recibe una cadena mágica y devuelve AbstractControl | null.
// `documentID` con la D mayúscula devuelve null y nadie te avisa.
const value = this.patientForm.get('documentId').value;   // any
```

```ts
// ── CertCore (Angular 16) ──────────────────────────────────────────────────
interface ClientForm {
  legalName: FormControl<string>;
  taxId: FormControl<string>;
}

readonly form = new FormGroup<ClientForm>({
  legalName: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
  taxId: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
});

// Acceso por propiedad, tipado. `form.controls.taxID` no compila.
const value = this.form.controls.taxId.value;   // string
```

**Los tres reflejos que hay que cambiar:**

- **`form.get('campo')` pasa a ser `form.controls.campo`.** La cadena mágica —fuente de bugs número uno de los formularios de la época— desaparece.
- **Aparece un `| null` que en LabCore no existía.** `new FormControl('')` es `FormControl<string | null>` porque `reset()` deja el control en `null`. La respuesta es `nonNullable: true`, y toda la mecánica está en **A05** §1 y §2.
- **`value` deja de ser `any` y empieza a exigirte decisiones.** Es exactamente el trabajo de la puerta 2, concentrado en el sitio donde más se nota.

> 💡 **Y una que vas a agradecer sin darte cuenta.** En LabCore, `getRawValue()` y `value` daban lo mismo desde el punto de vista del compilador, porque los dos eran `any`. En CertCore el tipo de `value` es `Partial<…>` y el de `getRawValue()` no, y esa diferencia de tipo es lo que te va a hacer descubrir el bug de los controles deshabilitados **antes** de escribirlo en vez de después (**A05** §7).

---

## 6. Guards e interceptors de clase → funcionales

```ts
// ── LabCore (Angular 8) ────────────────────────────────────────────────────
@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
    if (this.authService.isAuthenticated()) {
      return true;
    }
    this.router.navigate(['/login']);
    return false;
  }
}
// …y en la ruta: { path: 'patients', canActivate: [AuthGuard] }
```

```ts
// ── CertCore (Angular 16) ──────────────────────────────────────────────────
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }
  // Un UrlTree en vez de navigate(): el router cancela esta navegación y
  // ejecuta la otra en un solo paso, sin dos navegaciones compitiendo.
  return router.createUrlTree(['/login'], { queryParams: { returnUrl: state.url } });
};
// …y en la ruta: { path: 'clients', canActivate: [authGuard] }
```

**Lo que hay que saber para leer CertCore:**

- **La función recibe los mismos dos parámetros** que el método de la clase. No hay nada nuevo que aprender sobre guards.
- **Las dependencias entran con `inject()`, y sólo se puede llamar arriba del todo.** Dentro de un `catchError` o de un `subscribe` da `NG0203`. Ése es el error nuevo que te vas a encontrar, y está traducido en **A04** §7.
- **Las dos formas conviven en CertCore a propósito.** El `authInterceptor` es funcional y el `CorrelationIdInterceptor` es de clase, escrito en 2021 y sin tocar desde entonces. El archivo donde se registran los dos —`core.module.ts`— va marcado 🧬 y es el archivo más característico del track.

> 🧭 **Y aquí está la diferencia grande entre los dos cursos.** En LabCore, todo lo que se escribe es de una sola generación. En CertCore, **elegir en cuál de las dos generaciones escribes el fix es la habilidad que el curso entrena**. La regla es corta: código nuevo, estilo nuevo; código heredado, se toca lo mínimo y en su propio estilo, y nunca los dos en el mismo archivo.

---

## 7. NgRx de 2019 → estado en servicios

Ésta no es una diferencia de versión: es una decisión distinta de dos equipos distintos, y merece leerse así.

| | LabCore (2019) | CertCore (2022) |
|---|---|---|
| Qué se declara | acciones, reducer, selectores, effects | un servicio con un `BehaviorSubject` privado |
| Archivos por feature | cinco | uno |
| Cómo se lee | `store.select(selectPatients)` | `templateState.templates$` |
| Cómo se escribe | `store.dispatch(loadPatients())` | `templateState.load()` |
| Lo asíncrono | un `Effect` con `switchMap` | un método que llama al `*ApiService` |
| Herramientas | Redux DevTools, viaje en el tiempo | un `tap(console.log)` y un breakpoint |
| Trazabilidad | cada cambio tiene nombre | ninguna |

**La traducción mental, en tres frases:**

- **Un selector de NgRx es un derivado con `map`.** `selectPatients` se convierte en `readonly templates$ = this.state$.pipe(map(s => s.items), distinctUntilChanged())`. Lo que NgRx memoriza de fábrica, aquí lo compartes tú con `shareReplay({ bufferSize: 1, refCount: true })`.
- **Un effect es un método del servicio.** Todo lo que en LabCore era `ofType(loadPatients)` + `switchMap` + `map(loadPatientsSuccess)` aquí es un `load()` de doce líneas que llama al API, mete el resultado en el estado y guarda el error dentro del propio estado.
- **Un reducer es el `patch()` privado.** Un solo sitio que llama a `next()`, un solo breakpoint cuando algo quede raro.

**Lo que ganas:** un archivo por feature en vez de cinco, y nada que aprender antes de tocar nada.

**Lo que pierdes, y conviene decirlo porque tú **sí** conociste lo otro:** las devtools, el viaje en el tiempo, y sobre todo el registro de qué acción cambió qué. En un sistema cuyo dominio es la trazabilidad, esa ironía es la mejor sección de **A07**, que es donde esta conversación se cierra con criterios en vez de con preferencias.

---

## 8. ⭐ Tabla de traducción LabCore → CertCore

La sección que vas a consultar de verdad. A la izquierda, lo que tienes en los dedos; a la derecha, cómo se llama lo mismo aquí.

**Del stack**

| LabCore | CertCore |
|---|---|
| Angular 8.2.14 · CLI 8.3.29 | Angular 16.2.12 · CLI 16.2.12 |
| TypeScript 3.5.3, `strict: false` | TypeScript 5.1.6, `strict: true`, cero `any` |
| RxJS 6.5.5 | RxJS 7.8.1 |
| NgRx 8.6 | servicios con `BehaviorSubject`, sin librería |
| Bootstrap 4 + Material peleándose | Material 16 (MDC); Bootstrap sólo en **A02** 🔥 |
| Prefijo de selector `app-` | prefijo `cc-` |
| Tres idiomas con i18n en runtime | monolingüe, literales en plantilla (**A13** 🔥) |
| Deuda 💸 que **no** se paga | deuda 💸 que **se paga** cuando corresponde |

**Del código**

| LabCore | CertCore |
|---|---|
| `patients.actions.ts` + `.reducer.ts` + `.selectors.ts` + `.effects.ts` | `template-state.service.ts` |
| `patients.service.ts` (habla con HTTP) | `template-api.service.ts` (mismo papel, mismo nombre en espíritu) |
| `PatientListComponent` (componente gordo) | `TemplateListComponent` (componente honesto, más flaco) |
| `AuthGuard implements CanActivate` | `authGuard: CanActivateFn` |
| `AuthInterceptor implements HttpInterceptor` | `authInterceptor: HttpInterceptorFn` — y el `CorrelationIdInterceptor` **sigue siendo de clase** |
| `core.module.ts` con los singletons | `core.module.ts`, y sigue siendo el archivo donde todo se registra 🧬 |
| `.bind(this)` y `var self = this` | arrow functions, siempre |
| `patientForm.get('documentId')` | `form.controls.taxId` |
| `destroy$` + `takeUntil` + `ngOnDestroy` | `takeUntilDestroyed(this.destroyRef)` |

**Del dominio — y ésta es la fila que más vale**

| LabCore | CertCore |
|---|---|
| Paciente | Cliente (`Client`) |
| Orden médica | Inspección (`Inspection`) |
| Muestra con cadena de custodia | Activo (`Asset`) y su trazabilidad |
| Analito y resultado | Ítem de checklist (`ChecklistItem`) y respuesta (`InspectionAnswer`) |
| **Rango de referencia versionado** | **Plantilla de checklist versionada** (`ChecklistTemplate`) |
| "¿qué rango regía el día del resultado?" | "¿qué versión aplica a esta fecha?" |
| Entrega de resultados en PDF | Certificado en PDF |
| Bitácora de auditoría | trazabilidad de quién marcó qué y cuándo |

> 🧠 **La fila en negrita es la lección que se repite y por eso importa.** Los dos sistemas versionan algo por fecha, y los dos tienen su bug estrella en la misma pregunta: *"¿por qué esto se está viendo con la versión equivocada?"*. Lo que cambia es **dónde vive la respuesta**: en LabCore la resuelve un selector de NgRx comparando `Date` en el navegador —con la zona horaria perdiéndose en silencio, que es su 💸—; en CertCore la resuelve `resolveTemplateVersion`, una función pura con la zona horaria explícita, testeada sin `TestBed` en la Fase 12.
>
> Si te llevas una sola cosa de este apéndice, que sea ésta: **el problema es el mismo, la versión de Angular no lo resolvió, y lo que cambia el resultado es dónde decidiste poner la regla.**

---

## 🧭 Cuándo usar qué

| Vienes buscando… | Ve a |
|---|---|
| "¿por qué este servicio no tiene constructor?" | §2 puerta 4, y **A04** |
| "¿dónde están las acciones y el reducer?" | §7 |
| "`form.get('x')` no me compila" | §5, y **A05** |
| "este guard es una función, ¿dónde está la clase?" | §6, y **A04** §4 |
| "el import de `rxjs/operators` no existe" | §4, y **A06** |
| "¿por qué me obliga a decidir sobre `null`?" | §2 puerta 2 |
| "¿cómo se llama aquí lo que en LabCore era X?" | §8, la tabla |
| "¿y qué viene después de la 16?" | **A11** 🔥 |
| "quiero migrar de verdad un proyecto" | los apéndices A10 y A11 **del Track A** |

---

## 📚 Referencias

- https://v16.angular.io/guide/update-to-version-16 — la guía oficial de actualización a la 16. Útil como catálogo de cambios de ruptura, aunque aquí no migres nada.
- https://update.angular.io — el asistente oficial: eliges versión de origen y de destino y te lista lo que cambia. Poner 8 y 16 es la forma más rápida de ver el tamaño real del salto.
- https://blog.angular.io/version-9-of-angular-now-available-project-ivy-has-arrived-23c97b63cfa3 — el anuncio de Ivy, la puerta 1.
- https://v16.angular.io/guide/standalone-components — standalone, la puerta 3.
- https://v16.angular.io/guide/typed-forms — el cambio de la §5, explicado por quienes lo hicieron.
- https://rxjs.dev/deprecations — lo que salió entre RxJS 6 y 7, `toPromise()` incluido.
- https://ngrx.io/guide/migration — para dimensionar la distancia entre NgRx 8 y el actual, si tu curiosidad va por ahí.

> ⚠️ Casi toda la documentación oficial que encuentres hoy describe Angular 17 o posterior. Para leer CertCore, la referencia es `v16.angular.io`; para leer LabCore, la del Track A. Un ejemplo que use `@if` o `signal()` no pertenece a ninguno de los dos.

**Orden de lectura sugerido:** la §1 y la §2 el primer día, antes de abrir un solo archivo de CertCore. La §8 déjala abierta en una pestaña durante las primeras tres fases: es la que de verdad se consulta. Las §4 a la §7, cada una cuando el curso te ponga delante ese cambio concreto — la §5 con la Fase 6, la §6 con la Fase 2, la §7 con la Fase 4. La §3 sirve de repaso el día que quieras explicarle a alguien qué separa las dos versiones.

---

## 🧪 Ejercicios (7)

1. 🟢 Abre `core/auth.service.ts` de CertCore y el `patients.service.ts` de LabCore uno al lado del otro. Escribe en cinco líneas qué hace cada uno, y cuál de las diferencias entre los dos es de versión y cuál es de decisión de equipo.

2. 🟢 Traduce este fragmento de LabCore al estilo de CertCore, explicando cada cambio: `this.subscription = this.store.select(selectPatients).subscribe(function(patients) { this.patients = patients; }.bind(this));`

3. 🟡 Toma la definición del formulario de pacientes de LabCore (Fase 5 del Track A) y reescríbela como `FormGroup<T>` tipado con `nonNullable`. Anota cuántos accesos con cadena mágica desaparecieron y cuántos `| null` tuviste que decidir.

4. 🟡 Convierte el `AuthGuard` de LabCore a `CanActivateFn`, incluyendo el cambio de `router.navigate()` a `createUrlTree()`. Explica en dos líneas por qué el segundo es mejor y qué problema del historial de navegación evita.

5. 🟠 Toma el flujo completo de "cargar pacientes" de LabCore —acción, effect, reducer, selector— y escríbelo como un `*StateService` de CertCore. Cuenta las líneas de los dos y las responsabilidades de cada uno. Después escribe el párrafo honesto: qué perdiste en el cambio, no sólo qué ganaste.

6. 🟠 Compara `resolveTemplateVersion` de la Fase 7 de CertCore con el selector de rango vigente de la Fase 8 de LabCore. Identifica dónde vive la zona horaria en cada uno, y explica por qué uno de los dos se puede testear sin navegador y el otro no.

7. 🔴 Escribe la guía de una página que le darías a un compañero que acaba de terminar el Track A y empieza el B mañana: qué reflejos conserva, cuáles tiene que desaprender, y cuál es el único error de fondo que le va a costar tiempo. El criterio de éxito es que no sea una lista de sintaxis: la sintaxis está en la §8, y una guía que sólo repita eso no aporta nada.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y no produce código del proyecto: lo que salga de leerlo —una traducción de un fragmento, un ejercicio resuelto— se commitea con el prefijo de la fase desde la que llegaste (`fase 02: …`, `fase 06: …`), y si merece conservarse va con la forma `ej/a10/5`. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
