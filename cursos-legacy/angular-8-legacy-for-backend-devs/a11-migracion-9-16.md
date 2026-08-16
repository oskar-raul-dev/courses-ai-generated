# 📎 Apéndice A11 — 🔥 Migración 9 → 16

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **2h**
> Usado por: Fases 4 y 13, siempre como referencia · Versión cubierta: el camino de **Angular 9 a la línea 16**
> Estado: 🔥 **Opcional.** El curso se completa sin abrir este apéndice

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Y a diferencia del resto del curso, la mayoría de quien lo abra **no va a migrar nada**: lo abre porque tiene delante un ejemplo de internet que no se parece en nada a su código y necesita saber si está mirando otra versión o si lo está haciendo mal.

Casi siempre es lo primero. Este apéndice sirve para confirmarlo rápido y para poder decir en una reunión, con precisión, **qué separa a tu aplicación de lo que hoy se considera normal**.

> 🧭 **La 16 es un mirador, no la meta.** Se eligió porque es donde el modelo mental cambia del todo —standalone ya estable, `inject()` asentado, signals asomando—, no porque sea la última. Angular 16 es de 2023 y el ecosistema siguió corriendo: cuando leas esto habrá más versiones por delante, y el control flow (`@if`, `@for`) que mucha gente asocia a "Angular moderno" es de la **17**, una después de tu destino. Trátalo como una foto fechada, no como el final del camino.

**Qué queda fuera:** la migración real, que no se propone ni se planifica acá; **todo el método de migrar** —`ng update` una mayor por vez, leer el diff de las schematics, `ngcc`, la ficha por dependencia, el ensayo en rama desechable y las tres categorías de estimación—, que es el **Apéndice A10** y no se repite: acá solo se dice qué cambia cuando el salto es de siete majors en vez de uno; el tramo 8 → 9 completo (**A10** otra vez); y `node-sass` → `sass`, que es del **Apéndice A12**.

---

## Índice

- [1. Para qué sirve mirar esto](#1-para-qué-sirve-mirar-esto)
- [2. Las cuatro puertas del camino](#2-las-cuatro-puertas-del-camino)
- [3. Standalone: el `NgModule` deja de ser obligatorio](#3-standalone-el-ngmodule-deja-de-ser-obligatorio)
- [4. `inject()`: la inyección se sale del constructor](#4-inject-la-inyección-se-sale-del-constructor)
- [5. `strict`: el proyecto que no es una migración](#5-strict-el-proyecto-que-no-es-una-migración)
- [6. NgRx, siete versiones después](#6-ngrx-siete-versiones-después)
- [7. Signals, y el horizonte que ya no es la 16](#7-signals-y-el-horizonte-que-ya-no-es-la-16)
- [8. ⚖️ Qué de esto te sirve hoy, sin migrar nada](#8-️-qué-de-esto-te-sirve-hoy-sin-migrar-nada)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios (6)](#-ejercicios-6)

---

## 1. Para qué sirve mirar esto

Tres usos, y solo uno tiene que ver con migrar.

**El de todos los días: traducir.** Buscas cómo hacer algo, encuentras un ejemplo de 2024, y no tiene `NgModule`, ni constructor con dependencias, ni `*ngIf`. Necesitas saber en treinta segundos qué parte de eso es una idea que puedes usar y qué parte es sintaxis que tu versión no entiende. Para eso está la tabla de la **§8**, que es la sección más consultada de este apéndice.

**El de la reunión: dimensionar.** Alguien dice "saltemos a la última". La respuesta útil no es sí ni no: es **dónde están las puertas** (§2) y cuál de ellas decide. En un salto de siete majors, el trabajo no se reparte parejo: se concentra en dos o tres sitios muy concretos.

**El de la carrera, y no es menor.** El código que mantienes te enseña un modelo mental que ya no es el que se usa fuera. Saber en qué se diferencia —y por qué cambiaron— es lo que te deja moverte a otro proyecto sin sentir que empiezas de cero.

Lo que **no** es este apéndice: una guía para modernizar el proyecto del curso. El código principal se queda en Angular 8, con NgModules y `any` a discreción, y nada de lo que hay aquí se lleva allá.

---

## 2. Las cuatro puertas del camino

Siete majors suenan a siete problemas y no lo son. El trabajo se concentra en cuatro puertas; entre ellas, `ng update` hace casi todo solo, con el método de **A10 §3**.

### Puerta 1 — RxJS 7, y el `rxjs-compat` que tiene que salir antes

RxJS 7 entra en escena en la línea **12**, y a partir de ahí la 6.x va quedando atrás. Para ti eso es una fecha de vencimiento concreta: **`rxjs-compat` no tiene versión 7**, así que hay que quitarlo **antes** de subir RxJS, no después. **A05 §2** ya describe el trabajo exacto —buscar la sintaxis anterior a `.pipe()` en el código que no has leído y migrarla—, y **A10 §7** lo ubicó aquí precisamente porque en el tramo 8 → 9 no molesta.

> 🧭 Esta es la única puerta que puedes abrir **hoy**, sin migrar nada y sin permiso de nadie: quitar `rxjs-compat` es un ticket propio, medible, con una prueba de humo, y adelanta trabajo del salto largo. Si alguna vez te preguntan "¿qué podemos ir haciendo?", esta es la respuesta.

### Puerta 2 — El retiro de ViewEngine, y las librerías que se quedaron

Ivy convivió con ViewEngine unas cuantas versiones gracias a `ngcc`, el compilador de compatibilidad que **A10 §4** describe. Ese puente se retira: ViewEngine desaparece del framework y, más adelante en el camino, **`ngcc` también**. La consecuencia es dura y clara: **una librería que nunca se recompiló para Ivy deja de poder usarse.** No hay bandera ni truco.

Traducido a tu inventario: cualquier dependencia abandonada por su autor entre 2020 y hoy no es un problema de versiones, es una **decisión** —esperar, sustituir o quitar—, exactamente como plantea la ficha de **A10 §6**. Y es la puerta que más migraciones largas detiene, porque el bloqueo no depende de ti.

### Puerta 3 — Node y TypeScript, que suben a la fuerza

El curso corre sobre **Node 12** (y 14 en Apple Silicon) y **TypeScript 3.5.3**. Un Angular de la línea 16 pide un Node y un TypeScript muy posteriores, y eso arrastra cosas que no parecen de Angular: `node-sass`, que se compila contra una versión concreta de Node y termina siendo `sass` (**A12**); las herramientas del pipeline; y la imagen base del `Dockerfile` de la **Fase 13 §5.6**.

⚠️ **Las versiones exactas de Node y TypeScript que exige cada línea de Angular no las vas a encontrar acá**, por la misma razón que en **A10 §6**: son datos que envejecen. Se comprueban en un comando, y ese comando es el mismo:

```bash
# Qué Node, qué TypeScript y qué RxJS exige una versión concreta de Angular.
# Es la verdad; los blogs son rumores.
npm view @angular/core@16 peerDependencies
npm view @angular/core@16 engines
```

### Puerta 4 — Las mayores de las ocho librerías

Angular sube con `ng update`. Las librerías de alrededor suben **cada una por su cuenta, con su propio changelog y sus propios cambios que rompen**, y en siete majors de Angular caben varias mayores de cada una. La ficha por dependencia de **A10 §6** sigue siendo la herramienta; lo que cambia en un salto largo son tres preguntas más:

- **¿Cuántas mayores de esta librería caben en el tramo?** No es lo mismo saltar una que cuatro.
- **¿Hay alguna que reescriba el DOM o el CSS que genera?** Es el caso de **Angular Material**, que en la línea 15 rehace sus componentes sobre otra base: el HTML y las clases que produce cambian, y con ellos **todo lo que tú escribiste encima**. Para este proyecto eso toca de lleno la convivencia con Bootstrap y las peleas de especificidad que documenta **A02** entero. Es, con diferencia, el mayor trabajo visual de todo el camino.
- **¿La librería sigue viva?** Ver puerta 2.

> ⚠️ **Y una advertencia de método que en el salto largo importa más que en el corto:** la tentación de "aprovechar que estamos" y modernizar el código a la vez —meter standalone, encender `strict`, reescribir un slice— es enorme, y es la forma más segura de que la migración no termine. **A10 §⚖️** ya lo dice para un salto; con siete, se multiplica. Primero se llega a la versión con el código lo más parecido posible a como estaba. Modernizar es otro proyecto, después, y opcional.

---

## 3. Standalone: el `NgModule` deja de ser obligatorio

Es el cambio que más se nota al leer código ajeno, y el más fácil de traducir mentalmente.

**Tu Angular 8** — el componente se declara en un módulo, y el módulo importa lo que las plantillas de sus componentes necesitan:

```typescript
// src/app/patients/patients.module.ts (lo que tienes)
@NgModule({
  declarations: [PatientListComponent],
  imports: [
    CommonModule,
    MatCardModule,
    TranslateModule.forChild({ isolate: false }),   // la trampa de la Fase 2
    StoreModule.forFeature('patients', patientsReducer),
    EffectsModule.forFeature([PatientsEffects])
  ]
})
export class PatientsModule { }
```

**Angular 16** — el componente **se declara a sí mismo** y trae su propia lista de dependencias. El módulo puede no existir:

```typescript
// El mismo componente, escrito hoy. El array imports vive en el componente y
// contiene exactamente lo que SU plantilla usa: ni más ni menos.
@Component({
  standalone: true,
  selector: 'app-patient-list',
  imports: [CommonModule, MatCardModule, TranslateModule],
  templateUrl: './patient-list.component.html'
})
export class PatientListComponent { }
```

Y lo que en tu proyecto es `AppModule` + `platformBrowserDynamic().bootstrapModule(...)` pasa a ser un arranque con una lista de *providers* —`bootstrapApplication(AppComponent, { providers: [...] })`—, donde lo que antes eran `HttpClientModule`, `StoreModule.forRoot(...)` o `RouterModule.forRoot(...)` se declaran como funciones `provideXxx()`.

**Qué se gana.** Se acaba la pregunta *"¿por qué esta plantilla no encuentra el pipe?"*, que en tu stack es un clásico —el `TranslateModule.forChild` que falta y su `isolate: false` (**Fase 2 §6**)—, porque cada componente lleva escrito lo que usa. Y la carga diferida se vuelve por componente (`loadComponent`) y no solo por módulo.

**Qué se pierde.** El módulo era también un lugar donde mirar: una lista corta de qué compone una funcionalidad. Sin él, esa información queda repartida en veinte archivos. En proyectos grandes eso se nota, y no todo el mundo lo cuenta.

> 📝 **Nota de época, al revés.** Durante años, "saber Angular" incluía entender los `NgModule` y sus `forRoot`/`forChild`. Ese conocimiento —que este curso te hace practicar tres veces, con el router, con NgRx y con i18n— dejó de ser central. No fue tiempo perdido: los módulos siguen soportados, los proyectos que los usan son la mayoría del código que existe, y entender el problema que resolvían es lo que hace que el modelo nuevo se entienda en cinco minutos.

---

## 4. `inject()`: la inyección se sale del constructor

**Tu Angular 8** —el constructor declara lo que necesita, y así lo hace cada servicio, guard e interceptor del curso:

```typescript
// src/app/patients/patients.service.ts (lo que tienes)
@Injectable({ providedIn: 'root' })
export class PatientsService {
  constructor(private http: HttpClient, private config: AppConfigService) { }
}
```

**Angular 16** —la dependencia se pide con una función, en la inicialización de la propiedad:

```typescript
// Lo mismo, sin constructor. inject() solo funciona en un "contexto de
// inyección": inicializando una propiedad, dentro del constructor, o dentro de
// una factoria. Llamarlo dentro de ngOnInit o de un método cualquiera falla.
@Injectable({ providedIn: 'root' })
export class PatientsService {
  private http = inject(HttpClient);
  private config = inject(AppConfigService);
}
```

Donde de verdad cambia el aspecto del código es en los guards, que dejan de ser clases. Tu `auth.guard.ts` de la **Fase 3** —una clase con `CanActivate`— se escribe hoy como una función:

```typescript
// Un guard funcional. Ya no hay clase, ni @Injectable, ni implements: es una
// función que se pone directamente en la ruta. La misma lógica de la Fase 3.
export const authGuard: CanActivateFn = function () {
  const auth = inject(AuthService);
  const router = inject(Router);
  return auth.isLoggedIn() ? true : router.createUrlTree(['/login']);
};
```

**Por qué existe.** Sobre todo por la herencia y la composición: una clase base que necesita dependencias obligaba a repetir el constructor entero en cada hija. Con `inject()`, cada quien pide lo suyo. Y permite escribir funciones reutilizables que usan servicios sin ser clases.

**Dónde muerde.** En el contexto: `inject()` fuera de un contexto de inyección lanza un error en tiempo de ejecución que desconcierta la primera vez. Y en los tests, donde la forma de proveer dependencias cambia —tu `TestBed.get()` de la **Fase 12** pasó primero a `TestBed.inject()` (**A10 §3**) y convive hoy con este modelo.

---

## 5. `strict`: el proyecto que no es una migración

Desde la línea 12, un proyecto nuevo nace con `strict: true`. El tuyo nació con `strict: false` y `any` tolerado —**TS-0 declarado**, que es estilo del curso y de LabCore, no un descuido.

**Qué enciende exactamente.** `strict` es un paraguas: activa `noImplicitAny` (un parámetro sin tipo deja de ser `any` silencioso), `strictNullChecks` (`null` y `undefined` dejan de pertenecer a todos los tipos) y varios más. Aparte, y **a nivel de Angular**, está `strictTemplates`, que lleva la misma severidad dentro de los HTML: `@Input` con el tipo equivocado, `async` sobre algo que puede ser `null`.

**Qué pasa el primer día.** Cientos de errores. No decenas: cientos, y la mayoría en código que funciona perfectamente en producción desde hace años. `strictNullChecks` es el caro: cada `patient.lastOrderDate` que puede no venir, cada `state.error` que a veces es `null`, cada `find()` que puede no encontrar nada — y este curso está lleno de los tres.

**La única forma sensata de hacerlo:**

- **Nunca en la misma tanda que un cambio de versión.** Es la regla de **A10 §5** y aquí vale doble: si enciendes `strict` mientras migras, ningún error te dice ya qué lo causó.
- **Una bandera por vez, no el paraguas.** Empieza por `noImplicitAny`, que suele ser el más barato, estabiliza, y solo después `strictNullChecks`, que es el que de verdad cuesta.
- **Con la suite en verde antes y después.** La cobertura de la **Fase 12** es lo que distingue "arreglé el tipo" de "cambié el comportamiento sin querer". Un `!` puesto para callar al compilador es exactamente el bug que `strictNullChecks` venía a evitar, y es la tentación permanente de este trabajo.
- **Como un ticket propio, visible y estimado.** No es limpieza de fin de semana: es un proyecto con nombre.

> 🧭 **Y el matiz honesto:** encender `strict` en un sistema legacy grande **no siempre vale la pena**. Lo que hace es prevenir bugs de código que se va a escribir; en un sistema en mantenimiento donde apenas se escribe código nuevo, ese beneficio es pequeño y el costo es real. Donde sí vale es en el código nuevo: la mayoría de los equipos acaban con la configuración laxa heredada y una regla de disciplina para lo que nace después. No es elegante y es lo que funciona.

---

## 6. NgRx, siete versiones después

Es donde más se nota el cambio de época, y **A06** ya te dejó el aviso: `createFeature`, `createActionGroup`, los functional effects y `provideStore` **no existen en NgRx 8**, llegaron por el camino. Este es el mismo slice de pacientes, en las dos épocas.

**Tu NgRx 8** — cuatro archivos, con acciones modernas para su época y un reducer en `switch` (**A06 §3**), más el registro por módulo:

```typescript
// patients.reducer.ts (lo que tienes)
export function patientsReducer(state = initialState, action: any): PatientsState {
  switch (action.type) {
    case PatientsActions.loadPatients.type:
      return { ...state, loading: true, error: null };
    case PatientsActions.loadPatientsSuccess.type:
      return { ...state, loading: false, items: action.patients };
    default:
      return state;
  }
}
// y en patients.module.ts: StoreModule.forFeature('patients', patientsReducer)
```

**NgRx 16** — el reducer se escribe con `on()`, y `createFeature` empaqueta el nombre del feature, el reducer y **los selectores generados solos**:

```typescript
// El mismo slice, hoy. createFeature devuelve el reducer Y los selectores:
// selectPatientsState, selectItems, selectLoading... uno por cada clave del
// estado, sin escribir ninguno a mano.
export const patientsFeature = createFeature({
  name: 'patients',
  reducer: createReducer(
    initialState,
    on(PatientsActions.loadPatients, function (state) {
      return { ...state, loading: true, error: null };
    }),
    on(PatientsActions.loadPatientsSuccess, function (state, action) {
      return { ...state, loading: false, items: action.patients };
    })
  )
});
```

Y el effect deja de necesitar una clase:

```typescript
// Effect funcional: una constante, no un método de una clase con @Injectable.
// El { functional: true } es lo que le dice a NgRx que puede inyectar por su
// cuenta lo que las funciones de dentro pidan con inject().
export const loadPatients$ = createEffect(
  function () {
    const actions$ = inject(Actions);
    const service = inject(PatientsService);
    return actions$.pipe(
      ofType(PatientsActions.loadPatients),
      mergeMap(function () {
        return service.getPatients().pipe(
          map(function (patients) { return PatientsActions.loadPatientsSuccess({ patients: patients }); }),
          catchError(function (error) { return of(PatientsActions.loadPatientsFailure({ error: error })); })
        );
      })
    );
  },
  { functional: true }
);
```

**Lo que no cambió, y es la mitad del valor de haber aprendido esto:** las acciones se siguen llamando `'[Patients] Load Patients'`, el reducer sigue siendo una función pura que devuelve estado nuevo, los effects siguen devolviendo acciones, los selectores siguen memoizando, y Redux DevTools se sigue leyendo igual. **El modelo mental de A06 §1 es idéntico**; lo que cambió es cuánto código hay que escribir para expresarlo. Por eso un ejemplo moderno de NgRx te resulta legible aunque la sintaxis no compile en tu versión.

---

## 7. Signals, y el horizonte que ya no es la 16

La 16 estrena **signals** como vista previa, y son el cambio que más lejos llega — más que standalone, aunque se hable menos de ellos.

```typescript
// Un valor que sabe quien lo esta leyendo.
const patients = signal<any[]>([]);
const pendingCount = computed(function () {
  return patients().filter(function (p) { return p.pendingOrders > 0; }).length;
});

patients.set(newList);   // pendingCount se recalcula, y solo lo que dependia
                         // de el se vuelve a pintar
```

**Por qué importa más de lo que parece.** Tu aplicación repinta guiada por `zone.js`, que parchea temporizadores y eventos para saber que "algo pudo cambiar" y revisa el árbol. Es lo que hace que en la **Fase 10** el dashboard se ponga lento sin que nadie sepa muy bien por qué. Con signals, el framework sabe **exactamente** qué depende de qué, y ese camino termina en aplicaciones sin `zone.js`. Es un cambio de motor, no de sintaxis.

Y en el terreno práctico hay un detalle que le habla directo a este curso: llega `takeUntilDestroyed`, que resuelve en una línea la suscripción que nadie limpia — la deuda que la **Fase 9** deja anotada y la **Fase 10** convierte en tema central.

**El horizonte, dicho con fecha.** El **control flow** en plantillas —`@if`, `@for`, `@switch` en vez de `*ngIf` y `*ngFor`— **es de la línea 17**, una después de tu destino. Si lo ves en un ejemplo, no estás mirando la 16: estás mirando algo más nuevo todavía. Y detrás vienen las vistas diferibles y el sistema de build sobre esbuild. Lo único sensato que se puede decir de todo eso desde acá es que existe y que sigue moviéndose.

---

## 8. ⚖️ Qué de esto te sirve hoy, sin migrar nada

La habilidad que de verdad te llevas: **leer un ejemplo moderno y traducirlo a tu stack sin estrellarte**. Esta es la tabla, y es lo que más se consulta de este apéndice.

| Si el ejemplo dice… | En tu Angular 8 es… | ¿Se puede usar la idea? |
|---|---|---|
| `standalone: true` con `imports` en el componente | Declarar el componente en un `NgModule` e importar ahí (§3) | Sí: mira **qué** importa y llévalo a tu módulo |
| `bootstrapApplication(App, { providers })` | `AppModule` + `platformBrowserDynamic().bootstrapModule()` | Sí, los providers son los mismos |
| `provideHttpClient()`, `provideStore()`, `provideRouter()` | `HttpClientModule`, `StoreModule.forRoot()`, `RouterModule.forRoot()` | Sí: es el mismo registro con otra forma |
| `inject(HttpClient)` | `constructor(private http: HttpClient)` (§4) | Sí, siempre |
| `CanActivateFn` como función en la ruta | Una clase con `implements CanActivate` (**Fase 3**) | Sí: la lógica se copia tal cual |
| `@if` / `@for` | `*ngIf` / `*ngFor` | Sí, y **ojo**: es de la 17, ni siquiera de la 16 (§7) |
| `loadComponent: () => import(...)` | `loadChildren` con un módulo (**Fase 3**) | Parcial: tú cargas módulos, no componentes |
| `TestBed.inject(Service)` | `TestBed.get(Service)` (**Fase 12**) | Sí, cambia solo el nombre |
| `createFeature({ name, reducer })` | `StoreModule.forFeature('x', reducer)` + selectores a mano (§6) | Sí: los selectores los escribes tú |
| `createReducer(initial, on(...))` | El `switch` sobre `action.type` (**A06 §3**) | Sí, es lo mismo |
| `createEffect(..., { functional: true })` | `createEffect` dentro de una clase con `@Injectable` (**A06 §5**) | Sí, el `pipe` de dentro es idéntico |
| `signal()` / `computed()` | Una propiedad y un `subscribe`, o un selector (§7) | **No**: no hay equivalente. Lee la idea, no el código |
| `takeUntilDestroyed()` | `takeUntil` con un `Subject` en `ngOnDestroy` (**A05**) | Sí, con más líneas |
| `toSignal(obs$)` | `obs$ \| async` en la plantilla, o un `subscribe` | Parcial |
| `provideTranslateService()` (**A07**) | `TranslateModule.forRoot({...})` | Sí, misma configuración |
| Formularios tipados (`FormGroup<T>`) | `FormGroup` con `any` dentro (**Fase 5**) | Parcial: el tipado no existe en tu versión |
| `@angular/localize` para i18n | `@ngx-translate` en runtime (**Fase 2 §4**) | **No**, y es deliberado: no cambia idioma en caliente |

> 🧭 **La regla para usar la tabla:** cuando un ejemplo no compile en tu versión, la pregunta no es *"¿cómo lo hago funcionar?"* sino **"¿cuál es la idea y cómo se expresaba en mi época?"**. Casi siempre la idea es vieja y lo nuevo es la forma de escribirla. Las dos filas donde eso no aplica —signals e i18n nativo— están marcadas, y son las únicas donde conviene cerrar la pestaña.

---

## 🧭 Cuándo usar qué

| Situación | Qué haces | Por qué |
|---|---|---|
| Un ejemplo de internet no compila | La tabla de §8 | Casi siempre es versión, no error tuyo |
| "Saltemos a la última versión" en una reunión | Las cuatro puertas de §2 | El trabajo se concentra, no se reparte |
| Te preguntan qué se puede ir adelantando | Quitar `rxjs-compat` (§2, puerta 1) | Es la única puerta que se abre sin migrar nada |
| Quieres saber si una migración larga es viable | La ficha de **A10 §6**, con las tres preguntas extra de §2 | Una librería muerta decide sola |
| Alguien propone encender `strict` | §5, y **nunca** junto a un cambio de versión | Mezclarlos hace imposible saber qué rompió qué |
| Alguien propone "aprovechar y modernizar" | §2, última ⚠️, y **A10 §⚖️** | Es la razón número uno de migraciones abandonadas |
| Ves `@if` en un ejemplo | Es de la 17, ni siquiera de tu destino (§7) | Sirve para fechar el ejemplo que estás leyendo |
| Vas a escribir código nuevo en el proyecto | Sigue el estilo del proyecto, no el moderno | La coherencia del código vale más que la novedad |

---

## ⚠️ Advertencias

**Esto es comparación, y nada más.** No hay aquí un plan de migración, ni una propuesta, ni código que se lleve al proyecto. El curso se queda en Angular 8: NgModules, constructor con dependencias, `*ngIf`, `strict: false`. Escribir un componente standalone "para ir practicando" dentro del proyecto no es modernizar, es dejar dos estilos conviviendo en un código que otro va a mantener.

**Las versiones exactas de cada cosa no están aquí, y es a propósito.** Qué Node, qué TypeScript, qué RxJS y qué mayor de cada librería pide cada línea de Angular se comprueba en un comando (§2, puerta 3) con el método de **A10 §6**. Cualquier tabla de compatibilidades escrita hoy miente dentro de un año.

**No mezcles versión con modernización.** Ni con `strict`, ni con standalone, ni con un rediseño visual. Primero se llega a la versión con el código lo más parecido posible a como estaba; lo demás es otro proyecto, después, y opcional.

**La 16 no es la última línea.** Es de 2023 y se eligió como mirador. El control flow es de la 17, y desde entonces hay más. Si este apéndice y la realidad no coinciden, gana la realidad.

**Y la que más ahorra en el día a día: que un ejemplo no compile casi nunca significa que lo estés haciendo mal.** Significa que quien lo escribió tenía otra versión. Antes de dudar de ti, fecha el ejemplo — y la tabla de §8 fecha bastante rápido.

---

## 📚 Referencias

- https://update.angular.io — el generador de pasos de **A10**, que también sirve para tramos largos: eliges 9 → 16 y te muestra el camino completo. ⚠️ Recuerda que se hace **una mayor por vez** (**A10 §3**); la herramienta te da la lista, no un atajo.
- https://angular.dev/reference/releases — el calendario de versiones y qué línea sigue con soporte. Es donde se confirma que la 16 ya no lo tiene.
- https://blog.angular.io — el anuncio de cada mayor. Es la forma más rápida de ver qué trajo cada una del tramo; busca la entrada de cada versión, de la 10 a la 16.
- https://angular.dev/guide/components/importing — componentes standalone, con `imports` y `bootstrapApplication` (§3). ⚠️ Documenta la versión actual, posterior a la 16.
- https://angular.dev/guide/di/dependency-injection — `inject()` y qué es un contexto de inyección (§4).
- https://angular.dev/guide/signals — signals, `computed` y `effect` (§7). ⚠️ En la 16 eran vista previa; lo que ves documentado hoy es una versión más madura.
- https://angular.dev/guide/templates/control-flow — el control flow `@if`/`@for`, para confirmar que es de la 17 y no de la 16 (§7).
- https://www.typescriptlang.org/tsconfig/#strict — qué banderas enciende exactamente `strict` (§5). Es la lista que hay que leer antes de encenderlo.
- https://ngrx.io/guide/store/feature-creators — `createFeature` y los selectores generados (§6).
- https://ngrx.io/guide/effects#functional-effects — effects funcionales (§6).
- https://rxjs.dev/6-to-7-change-summary — el resumen de cambios de RxJS 6 a 7, que es la puerta 1 de §2 vista de cerca.
- https://github.com/ngx-translate/core — la librería de i18n en su versión actual (**A07**), útil para ver cómo se configura hoy lo que tú registras con `forRoot`.

> ⚠️ Casi todos estos enlaces documentan versiones **posteriores** a la 16 y muy posteriores a tu 8: aquí eso es la gracia, porque el objetivo es justamente ver a dónde fue el ecosistema. Lo que no debes hacer es copiar nada de ahí al proyecto. Y verifica antes de confiar: Angular cambió de dominio de documentación por el camino (`angular.io` → `angular.dev`), así que enlaces antiguos pueden redirigir o morir.

**Orden de lectura sugerido:** si viniste con un ejemplo que no compila, §8 y nada más. Si viniste de una reunión, §2 y el cierre de §5. Si viniste por curiosidad de a dónde fue esto, §3, §4, §6 y §7 en ese orden, que es cronológico.

---

## 🧪 Ejercicios (6)

Cortos y de consulta. Ninguno toca el proyecto del curso: **todo lo que se cree acá se borra al terminar.**

1. En una carpeta temporal, fuera del repositorio, crea una aplicación vacía con la CLI de la línea 16 (`npx @angular/cli@16 new modern-lab --routing --style=scss`). Lista los archivos de `src/app` y anota **qué archivo del tuyo no está**. Abre el `tsconfig.json` y anota el valor de `strict`. Después borra la carpeta.
2. En esa misma aplicación —antes de borrarla— abre `main.ts` y `app.component.ts` y encuentra dónde se registra el router y dónde se declara qué usa el componente. Escribe en dos líneas el equivalente exacto en tu proyecto, nombrando los archivos reales del curso.
3. Corre `npm view @angular/core@16 peerDependencies` y `npm view @angular/core@16 engines`. Anota qué versión de RxJS, de TypeScript y de Node exige. Compara las tres con las de tu `package.json` y marca cuál de los tres saltos te parece más caro y por qué (§2, puerta 3).
4. Busca cuál es la primera versión de `@angular/core` cuyas `peerDependencies` **ya no aceptan** RxJS 6. Usa `npm view` sobre varias versiones, no un blog. Esa versión es tu fecha límite real para quitar `rxjs-compat` (§2, puerta 1).
5. **Traducción.** Toma cualquier ejemplo de la documentación actual de NgRx que use `createFeature` y functional effects, y reescríbelo mentalmente —o en un archivo de borrador— con la forma de **A06**: `forFeature`, reducer en `switch`, effect en clase, selectores a mano. Anota cuántas líneas ocupa cada versión y qué información contiene una que la otra no.
6. **Diagnóstico de lectura.** Te pasan tres fragmentos de código de tres proyectos distintos: uno con `entryComponents`, otro con `inject()` y `standalone: true`, y otro con `@for`. Sin ejecutarlos, di de qué época es cada uno y con qué precisión puedes fecharlos. Después explica qué le dirías a alguien que copió el tercero en un proyecto como el tuyo y no le compila.


> 🏷️ **Este apéndice no lleva tag ni deja nada que commitear.** Sus ejercicios
> lo dicen sin rodeos: *"ninguno toca el proyecto del curso"*, y la aplicación
> de la línea 16 que crea el primero vive en una carpeta temporal fuera del
> repositorio y se borra al terminar. Lo único que puede salir de acá y merecer
> un commit es un ticket anotado —quitar `rxjs-compat`, por ejemplo—, y ese va
> con el prefijo de la fase donde se pague. La convención completa está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **Quitar `rxjs-compat` como ticket real.** Es la única puerta del §2 que se puede abrir hoy, sin migrar nada, y adelanta trabajo del salto largo. El procedimiento está en **A05 §2**; lo que falta es que alguien lo estime y lo meta en un sprint → decisión de proyecto.
- **La política de código nuevo.** El §5 termina en un punto que este curso no ha decidido: si el código que nace a partir de ahora sigue el TS-0 del sistema o se le exige más. Es una regla de equipo, no una configuración, y hoy no está escrita en ninguna parte → decisión de proyecto, con nota en la **Fase 12**.
- **El costo visual del salto de Material.** El §2, puerta 4, señala que la línea 15 de Material rehace el DOM y el CSS de sus componentes, y que eso choca de lleno con todo lo que **A02** documenta sobre la convivencia con Bootstrap. Cuantificarlo —cuántas pantallas, cuántos `::ng-deep`— es un inventario que nadie ha hecho y que sería el primer dato serio de una migración larga → material de un ensayo como el de **A10 §8**.
- **Este apéndice tiene fecha de caducidad.** Está escrito mirando a la 16 y el ecosistema sigue. La §8 —la tabla de traducción— es la parte que envejece mejor y la que conviene mantener; el resto habrá que revisarlo cuando el destino razonable ya no sea esta línea.
