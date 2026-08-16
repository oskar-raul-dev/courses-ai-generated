# 🏗️ Fase 01 — Estructura base + NgRx

> Tutorial Angular 8 — Laboratorio clínico · Fase 1 de 14 · **12 horas** · ⭐
> Depende de: Fase 0 — Setup + hola mundo · Habilita: Fases 2-14
> Apéndices de apoyo: [A06 (NgRx 8)](./a06-ngrx.md) · [A05 (RxJS de supervivencia)](./a05-rxjs.md) · [A02 (Bootstrap 4 + Sass)](./a02-bootstrap-sass.md) · [Incidentes asociados](./cuaderno-incidentes.md): 03

---

## 🎯 1. Propósito

Terminaste la Fase 0 con un componente único que tenía el `HttpClient` adentro,
un formulario y un `subscribe()` a pelo. Funcionaba. El problema es que ese
diseño se rompe exactamente cuando aparece el segundo componente que necesita
saber lo mismo: cuántos pacientes hay, cuál está seleccionado, si la última
petición falló.

Esta fase monta el esqueleto que sostiene las trece fases restantes —módulos por
dominio, router con carga diferida, layout— y encima de él instala **NgRx**, que
es donde va a vivir todo el estado del curso. Al terminar vas a poder abrir Redux
DevTools, ver la lista de acciones que despachó la aplicación y reconstruir qué
hizo el usuario sin haberlo visto. Esa capacidad, y no la elegancia del store, es
la razón por la que esta fase es la más densa del curso.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `npx ng serve` compila y la aplicación abre en `/patients` con el layout (toolbar y sidenav de Material) alrededor del `<router-outlet>`.
- [ ] Navegar a `/orders`, `/samples` y `/results` muestra vistas placeholder, y en la pestaña Network ves llegar un `.js` distinto la primera vez que entras a cada una.
- [ ] Redux DevTools está instalado y, al recargar `/patients`, muestra al menos tres acciones en orden: la de carga, la de éxito y el estado resultante.
- [ ] La lista de pacientes se llena desde `json-server` pasando por un effect, no por un `HttpClient` dentro del componente.
- [ ] Apagas el mock, recargas, y en DevTools ves la acción de fallo con el error adentro — y sabes decir en qué archivo se convirtió el error HTTP en esa acción.
- [ ] Sabes señalar en qué archivo vive `apiUrl` y por qué su valor quedó fijo al compilar.

---

## 🚫 3. Qué NO entra todavía

- i18n y el árbol de traducciones. Los textos siguen literales en español, con la deuda 💸 que declaró la Fase 0 → **Fase 2**, donde reemplazarlos es el primer ejercicio.
- Login, guard e interceptor. El router de esta fase no protege nada → **Fase 3**.
- El middleware de caos: latencia, 500 intermitentes, respuestas malformadas. Acá el mock responde bien o no responde → **Fase 4**.
- CRUD de verdad: alta, edición, borrado, formularios reactivos y tablas de Material con filtros → **Fase 5**.
- Máquina de estados de órdenes y muestras. Los módulos existen; adentro no hay nada → **Fases 7 y 8**.
- `@ngrx/entity`, `MetaReducer`, y el `ActionReducerMap` tipado del estado raíz. LabCore no los usa; se nombran y se difieren a **A06**. Las `runtimeChecks` son la excepción: **sí entran acá**, en §5.6, porque son una línea del `app.module.ts` que esta fase escribe y porque cazan el bug de mutación que su propio reducer advierte.
- El `async` pipe. Se nombra en esta fase y se explica por qué el curso no lo usa → **A05**.

---

## 🧠 4. Concepto mínimo

### Mini-repaso: tres cosas de RxJS y una de TypeScript

Antes de entrar al store, cuatro piezas de sintaxis que vas a ver en cada archivo
de esta fase. Si ya las dominas, salta a la sección siguiente.

Un **Observable** es una fuente de valores que empuja en el tiempo. La diferencia
con una `Promise` no es cosmética: la promesa entrega un valor y termina, el
observable puede entregar cero, uno o infinitos, y **no hace nada hasta que
alguien se suscribe**. Un `HttpClient.get()` que nadie suscribe es una petición
que nunca sale. Es el primer bug de RxJS que vas a cometer.

De los operadores, hoy necesitas tres. `map` transforma cada valor que pasa, como
el `map` de cualquier lenguaje. `switchMap` recibe un valor, arranca un observable
nuevo con él, y **cancela el anterior si llega otro valor antes de que termine**
—esa cancelación es la razón por la que se usa en effects de búsqueda—. Y
`catchError` intercepta el error y devuelve otro observable en su lugar, porque
si el error llega hasta el final, el observable muere y el effect deja de
escuchar para siempre.

De TypeScript, el decorador. `@Injectable()`, `@NgModule()`, `@Component()` son
funciones que reciben metadatos y se los cuelgan a la clase para que Angular los
lea en tiempo de arranque. Vienes de backend: es lo mismo que una anotación de
Java o un atributo de C#, y se comporta igual de mágicamente.

> 📚 Los seis operadores que sí aparecen en código real están en el apéndice
> [A05 — RxJS de supervivencia](./a05-rxjs.md). Doc oficial de RxJS 6:
> https://rxjs.dev/guide/operators

### El problema, antes de la herramienta

Imagina la pantalla que vas a construir en la Fase 5: una lista de pacientes a la
izquierda, el detalle a la derecha, un contador en la toolbar y un badge en el
sidenav. Cuatro componentes, tres de ellos en módulos distintos, todos
necesitando saber lo mismo.

Con lo que tienes de la Fase 0 hay dos caminos. Pasar los datos por `@Input` desde
un componente padre común —que en este caso es el `ShellComponent`, o sea el
techo de la aplicación— y encadenar propiedades por cuatro niveles. O poner un
servicio con un array adentro y que cada componente lo lea y lo escriba cuando
quiera.

El primero se llama *prop drilling* y duele rápido. El segundo funciona hasta que
algo cambia el array y no sabes quién fue. Y ese "no sabes quién fue" es
exactamente el ticket que te va a llegar: *"a veces la lista se queda con el
paciente anterior"*. Con un servicio mutable, para responderlo tienes que leer
todos los archivos que lo inyectan.

### La herramienta: flujo unidireccional

NgRx propone que el estado viva en un solo lugar, sea **inmutable**, y solo cambie
como resultado de un evento declarado. Cinco piezas:

Una **action** es un evento con nombre. No es una orden: es la descripción de algo
que pasó. `[Patients] Load Patients` significa "alguien pidió cargar pacientes",
no "carga pacientes". La distinción importa cuando leas el log de acciones para
reconstruir un incidente.

El **reducer** es una función pura que recibe el estado actual y una acción, y
devuelve el estado siguiente. Pura significa: mismas entradas, misma salida,
cero efectos de lado, y **nunca muta** lo que recibió. Si el reducer muta, todo lo
demás deja de funcionar por razones que vas a ver en la sección 6.

El **effect** es donde vive lo sucio. Escucha acciones, hace la llamada HTTP, y
despacha otra acción con el resultado. Como no está en el reducer, el reducer
sigue siendo pura aritmética.

El **selector** es una consulta al estado, memoizada: si el pedazo de estado que
lee no cambió, devuelve exactamente la misma referencia que la vez anterior. Esa
memoización es lo que evita que la aplicación redibuje todo cada vez que
cualquier cosa cambia.

Y el **store** es el objeto que junta todo: recibe acciones por `dispatch()` y
entrega estado por `select()`.

Vienes de backend, así que la puerta de entrada es esta: el store es un estado en
memoria compartido con transiciones controladas, y el effect es un handler que
reacciona a un evento y publica otro. Hasta ahí el paralelo funciona. Donde se
rompe: no hay transacción ni rollback, cada estado intermedio **es visible en la
pantalla** mientras ocurre, y todo esto corre en el navegador, o sea que el
usuario puede abrir DevTools y despachar acciones a mano. No es un mecanismo de
integridad; es un mecanismo de trazabilidad.

### ¿Y por qué no un servicio con `BehaviorSubject`?

Es la pregunta correcta y la respuesta honesta es que para una pantalla,
`BehaviorSubject` alcanza y sobra. NgRx pesa: cinco archivos y bastante ceremonia
para leer una lista. Se justifica por dos cosas, y ninguna es la elegancia.

La primera es que el flujo queda **inspeccionable desde fuera**. Con un
`BehaviorSubject` mutado desde ocho servicios, reconstruir qué pasó exige leer
código. Con el store, abres DevTools y ves la secuencia. Para un equipo cuyo
trabajo es diagnosticar bugs de producción, eso no es un detalle: es la
herramienta principal, y por eso la pieza forense de esta fase es justamente esa.

La segunda es que LabCore ya lo tiene montado. No lo estás eligiendo.

> 📝 **Nota de época.** En 2019 la discusión "NgRx o servicios" estaba en su punto
> más caliente y muchos equipos eligieron NgRx por defecto para proyectos que no
> lo necesitaban. Hoy la recomendación de la comunidad es bastante más
> conservadora. No importa: el sistema que vas a mantener tomó la decisión hace
> seis años y no se revierte.

### Dónde vive la configuración por ambiente

En la Fase 0 abriste `src/environments/environment.ts` y te pedí que recordaras
dónde estaba. Ahora le vas a poner algo adentro: `apiUrl`, la dirección del mock.

Angular tiene un mecanismo llamado *file replacement*: al compilar con
`--configuration=production`, el CLI **sustituye el archivo entero** por
`environment.prod.ts` antes de que Webpack empaquete. No es una variable que se
lea al arrancar; es un archivo que se cambia al compilar. Lo que quedó adentro
del bundle es texto fijo.

Guarda esa frase. En la Fase 13 vas a levantar la misma imagen de Docker dos
veces esperando que apunte a dos sitios distintos, y no va a pasar, y la
explicación es esta línea.

> 📝 **Continuidad con la Fase 13.** Ese `apiUrl` horneado no se queda así para
> siempre. La Fase 13 lo mueve fuera del bundle a un `assets/config.json` que la
> aplicación lee **al arrancar** con un `APP_INITIALIZER`, y que un
> `entrypoint.sh` reescribe desde variables de entorno cuando el contenedor
> levanta. La misma imagen, dos valores distintos, sin recompilar. Lo que aquí
> ves horneado es deliberado: es el punto de partida cuya deuda 💸 esa fase paga.

> 📚 Build and serve (v8): https://v8.angular.io/guide/build#configure-target-specific-file-replacements

---

## 💻 5. Código mínimo con comentarios

Doce archivos. Los seis primeros son el esqueleto; los seis siguientes son el
store. Cada bloque introduce una cosa.

### 5.1 Instalar NgRx

```bash
npm install @ngrx/store@8.6.0 @ngrx/effects@8.6.0 @ngrx/store-devtools@8.6.0 --save
```

> 🧭 **`8.6.0` es la versión fijada del curso**, y es la última de la línea 8: la
> que empareja con Angular 8.2.14 y la que LabCore quedó usando cuando el equipo
> actualizó desde NgRx 6. Si algún día heredas un proyecto con una `8.3.x`, no es un
> error suyo ni tuyo —entre menores de NgRx 8 cambiaron detalles de tipado de
> effects— y el procedimiento para comparar su árbol contra este está en el
> **Apéndice A03 §8**.

Y la extensión **Redux DevTools** en el navegador. Sin ella, `@ngrx/store-devtools`
no hace nada visible y la mitad de esta fase se pierde.

### 5.2 `app-routing.module.ts` — el router con carga diferida

```typescript
// src/app/app-routing.module.ts
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

const routes: Routes = [
  // Ruta por defecto: la aplicación entra directo al listado de pacientes.
  { path: '', redirectTo: 'patients', pathMatch: 'full' },

  // Carga diferida con la sintaxis de string, la de la época.
  // El módulo de pacientes viaja en un .js aparte que solo se descarga
  // cuando el usuario navega acá por primera vez.
  { path: 'patients', loadChildren: './patients/patients.module#PatientsModule' },
  { path: 'orders', loadChildren: './orders/orders.module#OrdersModule' },
  { path: 'samples', loadChildren: './samples/samples.module#SamplesModule' },
  { path: 'results', loadChildren: './results/results.module#ResultsModule' },

  // Comodín al final. El orden importa: Angular evalúa de arriba hacia abajo
  // y se queda con la primera coincidencia.
  { path: '**', redirectTo: 'patients' }
];

@NgModule({
  // forRoot solo en el módulo raíz. Los feature modules usan forChild.
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
```

**Detalles con intención**

- La ruta comodín va **última**. Si la subes una línea, se traga todo lo que esté
  debajo y ninguna vista carga. Es el error más silencioso del router.
- `pathMatch: 'full'` en la ruta vacía. Sin eso, `''` coincide con el prefijo de
  *cualquier* URL y entras en un bucle de redirección.

> 📝 **Nota de época.** La sintaxis `'./ruta/modulo#NombreDelModulo'` está
> deprecada desde Angular 8 y el compilador te lo dice al construir. La reemplazó
> el import dinámico (`() => import('./patients/patients.module').then(...)`), que
> es lo que vas a ver en cualquier tutorial de internet. LabCore usa la
> vieja porque nació antes, y funciona. La deprecación se vuelve error real en
> Angular 11, que es una de las razones por las que nadie migró.

### 5.3 `core.module.ts` — el módulo de los singletons

```typescript
// src/app/core/core.module.ts
import { NgModule, Optional, SkipSelf } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';

import { ShellComponent } from './shell/shell.component';

@NgModule({
  declarations: [ShellComponent],
  imports: [
    CommonModule,
    // RouterModule sin forRoot ni forChild: solo se necesita la directiva
    // router-outlet y routerLink dentro de la plantilla del shell.
    RouterModule,
    MatToolbarModule,
    MatSidenavModule,
    MatListModule,
    MatIconModule
  ],
  exports: [ShellComponent]
})
export class CoreModule {
  // Guarda contra la doble importación. Si alguien importa CoreModule desde un
  // feature module, Angular crea una segunda instancia de todo lo que este
  // módulo provee, y terminas con dos servicios "singleton" distintos.
  // El bug resultante es de los peores: dos partes de la app leyendo estados
  // que no se hablan entre si.
  constructor(@Optional() @SkipSelf() parentModule: CoreModule) {
    if (parentModule) {
      throw new Error('CoreModule ya esta cargado. Importalo solo en AppModule.');
    }
  }
}
```

> **El patrón a memorizar:** `@Optional() @SkipSelf()` significa "búscame esta
> dependencia saltándote mi propio inyector, y si no existe no te quejes". Si la
> encuentra, es que alguien ya cargó el módulo más arriba. Es el idioma estándar
> de 2019 para hacer que un `NgModule` sea de una sola instancia, y lo vas a
> encontrar tal cual en LabCore.

### 5.4 `shell.component` — el layout

```typescript
// src/app/core/shell/shell.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-shell',
  templateUrl: './shell.component.html',
  styleUrls: ['./shell.component.scss']
})
export class ShellComponent {

  // El estado del sidenav vive en el componente, sin store. No todo estado
  // pertenece al store: esto no lo consulta nadie más y no sale en el log de
  // acciones. Meterlo al store sería ceremonia sin retorno.
  sidenavOpen = true;

  toggleSidenav() {
    this.sidenavOpen = !this.sidenavOpen;
  }
}
```

```html
<!-- src/app/core/shell/shell.component.html -->
<mat-toolbar color="primary">
  <button mat-icon-button (click)="toggleSidenav()">
    <mat-icon>menu</mat-icon>
  </button>
  <span>Laboratorio clínico</span>
</mat-toolbar>

<mat-sidenav-container class="shell-container">
  <mat-sidenav mode="side" [opened]="sidenavOpen">
    <mat-nav-list>
      <!-- routerLinkActive marca visualmente la ruta actual.
           Los textos van literales en español: la deuda de i18n sigue abierta. -->
      <a mat-list-item routerLink="/patients" routerLinkActive="active">Pacientes</a>
      <a mat-list-item routerLink="/orders" routerLinkActive="active">Órdenes</a>
      <a mat-list-item routerLink="/samples" routerLinkActive="active">Muestras</a>
      <a mat-list-item routerLink="/results" routerLinkActive="active">Resultados</a>
    </mat-nav-list>
  </mat-sidenav>

  <mat-sidenav-content>
    <!-- Todo lo que cargue el router aparece acá dentro. -->
    <div class="container-fluid p-3">
      <router-outlet></router-outlet>
    </div>
  </mat-sidenav-content>
</mat-sidenav-container>
```

> 💸 **Deuda técnica intencional: el grid de Bootstrap envolviendo el contenido
> de Material.** Lo correcto sería elegir un sistema de layout y quedarse con él,
> o usar el `Layout` del CDK de Material. En Track A **no se paga**: el sistema
> real mezcla `container-fluid` y `row` de Bootstrap con contenedores de Material
> en centenares de plantillas desde 2019, y homogeneizarlo sería tocar todas las
> pantallas a la vez. Lo que sí haces es reconocer, cuando algo se vea corrido,
> que el padding puede venir de cualquiera de los dos.

### 5.5 `shared.module.ts`

```typescript
// src/app/shared/shared.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

// Este módulo NO declara servicios. Solo reexporta lo que todos los feature
// modules necesitan importar igual. Un servicio provisto acá se duplicaría
// en cada módulo con carga diferida que lo importe: los servicios van en Core.
@NgModule({
  imports: [CommonModule, FormsModule, MatButtonModule, MatCardModule, MatProgressSpinnerModule],
  exports: [CommonModule, FormsModule, MatButtonModule, MatCardModule, MatProgressSpinnerModule]
})
export class SharedModule { }
```

**Detalles con intención**

- La regla de oro de 2019: **Core provee, Shared declara y reexporta**. Si la
  rompes, aparecen instancias duplicadas de servicios en los módulos diferidos.
- `SharedModule` se importa en cada feature module; `CoreModule` solo en
  `AppModule`.

### 5.6 `app.module.ts` — el raíz, ahora con store

```typescript
// src/app/app.module.ts
import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

import { StoreModule } from '@ngrx/store';
import { EffectsModule } from '@ngrx/effects';
import { StoreDevtoolsModule } from '@ngrx/store-devtools';

import { environment } from '../environments/environment';
import { AppRoutingModule } from './app-routing.module';
import { CoreModule } from './core/core.module';
import { AppComponent } from './app.component';

@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    AppRoutingModule,
    CoreModule,

    // El estado raíz está vacío a propósito: no hay estado global todavía.
    // Cada feature module registra el suyo con StoreModule.forFeature.
    StoreModule.forRoot({}),
    EffectsModule.forRoot([]),

    // Las DevTools solo se conectan fuera de producción. En el build de prod
    // esta línea sigue estando, pero el módulo se desactiva solo.
    // Ojo: "desactivado" no es "ausente"; el código viaja igual en el bundle.
    StoreDevtoolsModule.instrument({ maxAge: 25, logOnly: environment.production })
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

Y `app.component.html` queda en una línea, igual que en la Fase 0:

```html
<app-shell></app-shell>
```

**El segundo argumento de `forRoot` que dejamos vacío: `runtimeChecks`**

`StoreModule.forRoot()` acepta un segundo argumento de configuración, y arriba no se le pasa ninguno. Ahí dentro viven las **comprobaciones en tiempo de ejecución** que NgRx 8 estrenó, y una de ellas apunta directo a la advertencia que acabas de leer en el comentario del reducer: mutar `state` en vez de devolver un objeto nuevo.

```typescript
// Las cuatro comprobaciones que trae NgRx 8, encendidas explicitamente.
StoreModule.forRoot({}, {
  runtimeChecks: {
    strictStateImmutability: true,      // caza el reducer que muta el estado
    strictActionImmutability: true,     // caza quien modifica el objeto de la accion
    strictStateSerializability: true,   // caza un Date o una función dentro del estado
    strictActionSerializability: true   // lo mismo, dentro del payload de una accion
  }
})
```

Con `strictStateImmutability` encendida, el bug intermitente de "a veces la pantalla no se actualiza" deja de ser intermitente: se convierte en una excepción con nombre y línea, en el instante en que alguien muta. Es la diferencia entre un fallo que se diagnostica en diez segundos y uno que se persigue durante una tarde.

> ⚠️ **No supongas cuáles vienen activadas de fábrica.** El reparto de valores por defecto cambió entre versiones de NgRx, y este curso no da ninguno por bueno de memoria. El experimento que lo resuelve dura dos minutos y es el ejercicio 🔥 de esta fase: muta el estado a propósito en un `case` del reducer y mira si la aplicación lanza una excepción o si el bug pasa en silencio. Lo que veas es la respuesta para tu versión.

💸 **Deuda técnica intencional: `forRoot` sin `runtimeChecks`.** Lo correcto sería encender al menos las dos de inmutabilidad, que no cuestan nada y cazan una clase entera de bugs. **En Track A no se paga**, y la razón es honesta y poco heroica: encenderlas hoy, sobre siete slices escritos por gente distinta a lo largo de tres años, probablemente haga fallar el arranque en algún sitio que nadie ha tocado en meses. Eso es un ticket de investigación con fecha, no una línea de configuración — y lo que un mantenedor hace con eso es abrirlo, no colarlo en un hotfix del viernes. Lo que sí haces es **saber que el interruptor existe**: el día que persigas un bug de "la pantalla no se actualiza", encenderlo en tu rama es la primera prueba que corres. El catálogo de las cuatro está en el **Apéndice A06 §9.4**.

### 5.7 `environment.ts` — la promesa de la Fase 0, a medias

```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  // La dirección del mock. Este valor queda horneado en el bundle al compilar:
  // no se lee al arrancar la aplicación. La Fase 13 lo saca de acá y lo mueve a
  // assets/config.json, leido con APP_INITIALIZER, para poder cambiarlo sin
  // recompilar. Por ahora vive horneado a propósito: es la deuda que esa fase paga.
  apiUrl: 'http://localhost:3000'
};
```

```typescript
// src/environments/environment.prod.ts
export const environment = {
  production: true,
  // Mismo mock por ahora. El día que esto apunte a otra parte y nadie lo
  // recompile, tienes el clásico "funciona en UAT y no en PROD". La Fase 13
  // resuelve exactamente ese problema inyectando la config en el arranque.
  apiUrl: 'http://localhost:3000'
};
```

### 5.8 `patients.actions.ts` — los eventos

```typescript
// src/app/patients/store/patients.actions.ts
import { createAction, props } from '@ngrx/store';

// El nombre lleva el origen entre corchetes y el evento en lenguaje natural.
// Esa cadena es literalmente lo que vas a leer en Redux DevTools cuando
// reconstruyas un incidente, así que se escribe para ser leida por humanos.
export const loadPatients = createAction('[Patients] Load Patients');

export const loadPatientsSuccess = createAction(
  '[Patients] Load Patients Success',
  props<{ patients: any[] }>()   // any: TS-0. El día que el mock cambie de forma, nadie avisa.
);

export const loadPatientsFailure = createAction(
  '[Patients] Load Patients Failure',
  props<{ error: any }>()
);

export const selectPatient = createAction(
  '[Patients] Select Patient',
  props<{ patientId: number }>()
);
```

**Detalles con intención**

- El trío `Load / Load Success / Load Failure` es el patrón que repiten las Fases
  5 a 10 para cada entidad. Si lo cambias acá, cambian nueve fases.
- `createAction` y `props` **sí existen** en NgRx 8: llegaron con esta versión. Lo
  digo porque el reducer de abajo va en `switch` y podrías pensar que es porque
  no había otra cosa.

### 5.9 `patients.reducer.ts` — la función pura, al estilo del equipo

```typescript
// src/app/patients/store/patients.reducer.ts
import * as PatientsActions from './patients.actions';

export interface PatientsState {
  items: any[];          // any otra vez: no hay interfaz Patient todavia.
  loading: boolean;
  error: any;
  selectedId: number;
}

export const initialState: PatientsState = {
  items: [],
  loading: false,
  error: null,
  selectedId: null
};

// Reducer con switch sobre action.type. Es el estilo de LabCore.
export function patientsReducer(state = initialState, action: any): PatientsState {
  switch (action.type) {

    case PatientsActions.loadPatients.type:
      // Se devuelve un objeto NUEVO. El spread copia lo anterior y pisa lo que
      // cambia. Mutar "state" acá rompería la detección de cambios y la
      // memoización de los selectores, y el bug sería intermitente.
      return { ...state, loading: true, error: null };

    case PatientsActions.loadPatientsSuccess.type:
      return { ...state, loading: false, items: action.patients };

    case PatientsActions.loadPatientsFailure.type:
      return { ...state, loading: false, error: action.error };

    case PatientsActions.selectPatient.type:
      return { ...state, selectedId: action.patientId };

    // Cualquier acción que no reconozca devuelve el estado intacto. No es
    // opcional: el reducer recibe TODAS las acciones de la aplicación.
    default:
      return state;
  }
}
```

> 💸 **Deuda técnica intencional: reducer en `switch` y `action: any`.**
> Lo correcto hoy —y también en NgRx 8, que ya lo permitía— sería `createReducer`
> con `on(...)`, que da tipado por acción y evita el `default` a mano. Y lo
> correcto en cualquier versión sería una interfaz `Patient` en lugar de `any[]`.
> En Track A **no se paga**: el equipo venía de NgRx 6, donde `switch` era lo
> único, y al actualizar no reescribió los reducers existentes. Convivir con eso
> es exactamente el trabajo. Lo que sí ganas es entender que `action: any` es lo
> que permite escribir `action.patients` sin que el compilador te frene — y
> también lo que permite escribir `action.pacientes` y no enterarte hasta que la
> pantalla salga vacía.

> **El patrón a memorizar:** si un reducer muta el estado que recibe, la
> aplicación **sigue funcionando a veces**. Ese "a veces" es el síntoma más caro
> de diagnosticar de todo NgRx, y lo desarmas en la sección 6.

### 5.10 `patients.selectors.ts` — las consultas memoizadas

```typescript
// src/app/patients/store/patients.selectors.ts
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { PatientsState } from './patients.reducer';

// La cadena 'patients' tiene que coincidir EXACTAMENTE con la clave que use
// StoreModule.forFeature en patients.module.ts. Si no coincide, el selector
// devuelve undefined y el error aparece lejos de la causa.
export const selectPatientsState = createFeatureSelector<PatientsState>('patients');

export const selectAllPatients = createSelector(
  selectPatientsState,
  function (state) { return state.items; }
);

export const selectPatientsLoading = createSelector(
  selectPatientsState,
  function (state) { return state.loading; }
);

// Selector derivado: se construye sobre otros dos. Si ninguno de los dos
// cambio de referencia, createSelector ni siquiera ejecuta esta función y
// devuelve el resultado anterior. Eso es la memoización.
export const selectSelectedPatient = createSelector(
  selectAllPatients,
  selectPatientsState,
  function (patients, state) {
    return patients.find(function (p) { return p.id === state.selectedId; }) || null;
  }
);
```

**Detalles con intención**

- La memoización compara **por referencia**, no por contenido. Por eso el reducer
  tiene que devolver objetos nuevos solo cuando algo cambió de verdad: si
  devuelve uno nuevo siempre, el selector recalcula siempre y la memoización
  deja de servir. Ese es el bug de performance de la Fase 10.
- Un selector que construye un array o un objeto nuevo en cada llamada
  (`.map(...)`, `.filter(...)` sin memoizar) tiene el mismo efecto. Acá
  `selectAllPatients` devuelve la referencia tal cual, a propósito.

### 5.11 `patients.service.ts` — lo primero que sale del componente

```typescript
// src/app/patients/patients.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class PatientsService {

  constructor(private http: HttpClient) { }

  // El servicio no guarda estado ni se suscribe: devuelve el observable y se
  // aparta. Quien decide que hacer con el resultado es el effect.
  getPatients(): Observable<any> {
    return this.http.get(environment.apiUrl + '/patients');
  }
}
```

En la Fase 0 el `HttpClient` vivía dentro del componente. Acá sale, y no es por
pulcritud: sale porque el effect necesita un observable que pueda componer, y un
componente no se lo puede dar. La URL, que estaba escrita a mano en el
componente, ahora se arma desde `environment`. Ese bucle de la Fase 0 queda
cerrado.

### 5.12 `patients.effects.ts` — donde vive lo sucio

```typescript
// src/app/patients/store/patients.effects.ts
import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { map, switchMap, catchError } from 'rxjs/operators';

import { PatientsService } from '../patients.service';
import * as PatientsActions from './patients.actions';

@Injectable()
export class PatientsEffects {

  constructor(
    private actions$: Actions,
    private patientsService: PatientsService
  ) { }

  // El sufijo $ marca que la propiedad es un observable. Convención, no sintaxis.
  loadPatients$ = createEffect(function (this: PatientsEffects) {
    return this.actions$.pipe(
      // Deja pasar solo la acción de carga. Todas las demás se descartan acá.
      ofType(PatientsActions.loadPatients),

      // switchMap: por cada acción que pasa, arranca la llamada HTTP. Si llega
      // otra acción de carga antes de que termine, cancela la anterior.
      switchMap(() => {
        return this.patientsService.getPatients().pipe(

          // La respuesta se convierte en una acción nueva. El effect nunca
          // toca el estado: solo despacha.
          map(function (patients: any) {
            return PatientsActions.loadPatientsSuccess({ patients: patients });
          }),

          // catchError DENTRO del switchMap, no afuera. Si estuviera afuera,
          // el error mataría el observable de acciones y el effect dejaria de
          // escuchar para siempre: la primera falla rompe la pantalla hasta
          // recargar. Es el bug de NgRx que más veces vas a ver.
          catchError(function (error: any) {
            return of(PatientsActions.loadPatientsFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));
}
```

**Detalles con intención**

- `createEffect` devuelve un observable de acciones y NgRx se suscribe por ti.
  Lo que emitas se despacha automáticamente; por eso el effect no llama a
  `store.dispatch()`.
- El error no se muestra acá. Se convierte en acción, va al reducer, queda en el
  estado, y el componente lo lee. Así el fallo aparece en Redux DevTools con
  nombre y fecha, que es la mitad del trabajo forense.

### 5.13 `patients.module.ts` — el feature module completo

```typescript
// src/app/patients/patients.module.ts
import { NgModule } from '@angular/core';
import { StoreModule } from '@ngrx/store';
import { EffectsModule } from '@ngrx/effects';

import { SharedModule } from '../shared/shared.module';
import { PatientsRoutingModule } from './patients-routing.module';
import { PatientListComponent } from './patient-list/patient-list.component';
import { patientsReducer } from './store/patients.reducer';
import { PatientsEffects } from './store/patients.effects';

@NgModule({
  declarations: [PatientListComponent],
  imports: [
    SharedModule,
    PatientsRoutingModule,
    // 'patients' es la clave del estado. Tiene que coincidir con la que usa
    // createFeatureSelector. Al ser un módulo diferido, este pedazo del estado
    // NO existe hasta que el usuario navega acá por primera vez.
    StoreModule.forFeature('patients', patientsReducer),
    EffectsModule.forFeature([PatientsEffects])
  ]
})
export class PatientsModule { }
```

```typescript
// src/app/patients/patients-routing.module.ts
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { PatientListComponent } from './patient-list/patient-list.component';

const routes: Routes = [
  // Ruta vacía: relativa al 'patients' que declaró el router raíz.
  { path: '', component: PatientListComponent }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],   // forChild, no forRoot.
  exports: [RouterModule]
})
export class PatientsRoutingModule { }
```

Los módulos de `orders`, `samples` y `results` son idénticos pero sin store: un
componente placeholder, un routing module con `forChild`, y nada más. Se generan
con `npx ng generate module orders --routing` y se les agrega la vista.

### 5.14 `patient-list.component.ts` — el componente gordo que consume el store

```typescript
// src/app/patients/patient-list/patient-list.component.ts
import { Component, OnInit } from '@angular/core';
import { Store } from '@ngrx/store';

import * as PatientsActions from '../store/patients.actions';
import * as PatientsSelectors from '../store/patients.selectors';

@Component({
  selector: 'app-patient-list',
  templateUrl: './patient-list.component.html',
  styleUrls: ['./patient-list.component.scss']
})
export class PatientListComponent implements OnInit {

  // El componente copia el estado a campos propios. No es lo idiomático:
  // lo idiomático sería dejar los observables y usar el async pipe en la
  // plantilla. Así lo hace LabCore, y así lo hacemos acá.
  patients: any[] = [];
  loading = false;
  error: any = null;

  constructor(private store: Store<any>) { }

  ngOnInit() {
    // Tres suscripciones a pelo, sin desuscripción. Como el componente vive
    // mientras dure la ruta, el leak es pequeño; en una pantalla que se abre
    // y cierra cien veces al día deja de serlo. La Fase 10 lo mide.
    this.store.select(PatientsSelectors.selectAllPatients).subscribe(function (this: PatientListComponent, patients) {
      this.patients = patients;
    }.bind(this));

    this.store.select(PatientsSelectors.selectPatientsLoading).subscribe(function (this: PatientListComponent, loading) {
      this.loading = loading;
    }.bind(this));

    this.store.select(PatientsSelectors.selectPatientsState).subscribe(function (this: PatientListComponent, state) {
      this.error = state.error;
    }.bind(this));

    // Despachar la carga es lo último. El componente pide; no sabe quien
    // responde ni desde donde. Eso es el flujo unidireccional.
    this.store.dispatch(PatientsActions.loadPatients());
  }

  onSelect(patientId: number) {
    this.store.dispatch(PatientsActions.selectPatient({ patientId: patientId }));
  }

  retry() {
    this.store.dispatch(PatientsActions.loadPatients());
  }
}
```

```html
<!-- src/app/patients/patient-list/patient-list.component.html -->
<h2>Pacientes</h2>

<mat-spinner *ngIf="loading" diameter="40"></mat-spinner>

<div *ngIf="error" class="alert alert-danger">
  No se pudo cargar la lista de pacientes.
  <button mat-button (click)="retry()">Reintentar</button>
</div>

<div class="row" *ngIf="!loading && !error">
  <div class="col-md-4 mb-3" *ngFor="let patient of patients">
    <mat-card (click)="onSelect(patient.id)">
      <mat-card-title>{{ patient.fullName }}</mat-card-title>
      <mat-card-subtitle>{{ patient.documentId }}</mat-card-subtitle>
    </mat-card>
  </div>
</div>
```

> **Prueba de fuego.** Levanta el mock (`npx json-server@0.16.3 --watch db.json
> --port 3000`), abre `/patients` y confirma que ves las tarjetas. Ahora abre
> Redux DevTools y mira la secuencia: `[Patients] Load Patients` con `loading:
> true`, y después `[Patients] Load Patients Success` con el array adentro.
> Apaga el mock, recarga, y confirma que aparece `[Patients] Load Patients
> Failure` y que la pantalla muestra el botón de reintentar. Vuelve a levantarlo
> y pulsa reintentar sin recargar la página: si el effect está bien escrito,
> funciona. Si `catchError` estuviera fuera del `switchMap`, no pasaría nada al
> pulsar — y esa diferencia es el ejercicio 27.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**El selector devuelve `undefined` y la pantalla queda vacía sin error.**
Síntoma: `Cannot read property 'items' of undefined`, o directamente nada.
Causa: la cadena de `createFeatureSelector('patients')` no coincide con la de
`StoreModule.forFeature('patients', ...)`. Son dos strings sueltas en dos
archivos distintos y nada las valida.
Fix mínimo: igualar las cadenas. La refactorización correcta —exportar una
constante `PATIENTS_FEATURE_KEY` desde el reducer e importarla en los dos
lados— es de dos líneas, pero implica tocar el patrón que copian nueve fases;
se decide a nivel de proyecto, no de hotfix.

**La primera falla del backend rompe la pantalla hasta recargar.**
Síntoma: el primer error se muestra bien; después de eso, el botón de reintentar
no hace nada y ninguna acción nueva aparece en DevTools.
Causa: `catchError` colocado fuera del `switchMap`. El error sube hasta el
observable de acciones, lo completa, y el effect deja de escuchar.
Fix mínimo: mover el `catchError` dentro del `pipe` interno. Es un cambio de dos
llaves y arregla una clase entera de bugs.

**Los cambios ocurren pero la pantalla no se entera.**
Síntoma: en DevTools ves el estado nuevo; en pantalla sigue lo viejo.
Causa: el reducer mutó el estado (`state.items.push(...)` en lugar de devolver un
array nuevo). Como la referencia no cambió, el selector memoizado no emite.
Fix mínimo: devolver objetos nuevos con spread. Acá **no hay refactorización
alternativa**: mutar es un bug, no un estilo, y esta es la única regla de NgRx
que el curso trata como no negociable.

**La aplicación compila pero la ruta diferida tira `Cannot find module`.**
Síntoma: al navegar a `/orders` la consola muestra un error de carga de chunk.
Causa: la cadena de `loadChildren` no coincide con la ruta real del archivo o con
el nombre exportado de la clase después del `#`. Es una cadena, no un import: el
compilador no la verifica en modo desarrollo.
Fix mínimo: corregir la cadena. Ojo con mayúsculas y con la extensión: va sin
`.ts`.

### Pieza forense de esta fase

La pieza de la Fase 1 es **Redux DevTools como máquina del tiempo**, y se
desarrolla completa en [`forense-fase-01.md`](./forense-fase-01.md). La idea que
se instala acá es que el log de acciones no es una herramienta de desarrollo: es
la reconstrucción de lo que hizo el usuario. Cuando el ticket diga *"le di a
guardar dos veces porque no pasaba nada"*, en el log vas a ver literalmente las
dos acciones seguidas, con el estado entre medio.

Dedica veinte minutos a las tres pestañas que importan. **Actions** muestra la
secuencia y el payload de cada una. **Diff** muestra qué cambió del estado entre
una acción y la siguiente, que suele ser más rápido de leer que el estado
completo. Y el control deslizante de abajo te deja **retroceder** el estado a
cualquier punto anterior: la aplicación se redibuja como estaba. De ahí lo de
máquina del tiempo.

**Rompe a propósito y observa.** En `patients.reducer.ts`, cambia el caso de
éxito por una mutación:

```typescript
case PatientsActions.loadPatientsSuccess.type:
  state.items = action.patients;   // mutación deliberada
  return state;                    // misma referencia de siempre
```

Recarga `/patients`. Vas a ver: en DevTools, la acción `Load Patients Success`
llegó, y el panel **Diff** muestra los pacientes ahí, dentro del estado. En la
pantalla, nada. El componente sigue vacío. La mentira que te cuenta DevTools es
que "el estado está bien" — y lo está, en el sentido de que los datos son
correctos. Lo que no ocurrió es la **notificación**: el selector comparó la
referencia del estado con la anterior, encontró la misma, y no emitió. Nadie se
enteró.

Ese es el patrón que hace tan cara la mutación en el reducer: no produce un error,
produce un silencio. Y el silencio no aparece en ningún log.

Este ejercicio es la puerta de entrada al **incidente 03** del cuaderno, de la
categoría *estado (store)*. Cuando lo abras, ya tienes el reflejo.

> **Cómo se registra esto en tu cuaderno.** El `cuaderno-incidentes.md` es tuyo:
> lo que escribes ahí son tus reproducciones, tus hipótesis descartadas y tus
> fixes, con la convención de commits que define ese archivo. La secuencia que
> acabas de provocar es material de primera para practicar el formato antes de
> que llegue un incidente de verdad.

---

## 🧪 7. Ejercicios (35)

**🟢 Fácil (1–10)**

1. Instala la extensión Redux DevTools, abre `/patients` y anota cuántas acciones aparecen entre la carga de la página y la lista renderizada.
2. Usa el control deslizante de DevTools para retroceder al estado anterior a `Load Patients Success` y describe qué muestra la pantalla en ese punto.
3. Agrega un cuarto pacientes de prueba a `db.json` y confirma que aparece sin tocar código.
4. Navega a `/orders` con la pestaña Network abierta y anota el nombre exacto del `.js` que se descarga. Vuelve a `/patients` y luego otra vez a `/orders`: anota si se descarga de nuevo.
5. Cambia `apiUrl` en `environment.ts` a un puerto donde no haya nadie y describe qué acción aparece en DevTools.
6. Localiza en `patients.module.ts` la cadena `'patients'` y en `patients.selectors.ts` su pareja. Escribe en una línea qué las conecta.
7. Despacha `[Patients] Select Patient` a mano desde el panel Dispatcher de DevTools con un `patientId` que exista, y confirma en el estado que `selectedId` cambió.
8. Agrega un campo `email` a los pacientes del `db.json` y muéstralo en la tarjeta. No toques el reducer.
9. Escribe un selector `selectPatientsCount` sobre `selectAllPatients` y úsalo para mostrar el total en el `<h2>`.
10. Cambia el nombre de la acción a `'[Pacientes] Cargar pacientes'`, comprueba que todo sigue funcionando, y explica en dos líneas por qué el curso la deja en inglés igual.

**🟡 Intermedio (11–21)**

11. Agrega la acción `[Patients] Clear Selection` con su caso en el reducer y un botón que la despache. Verifica el efecto en DevTools.
12. Haz que la ruta comodín `**` suba a la primera posición del arreglo `routes`. Describe qué pasa y por qué.
13. Elimina `pathMatch: 'full'` de la ruta vacía y documenta el error exacto que aparece en consola.
14. Registra un segundo effect que escuche `[Patients] Select Patient` y solo haga `console.log` del id. Márcalo con `{ dispatch: false }` y explica qué pasaría sin esa opción.
15. Importa `CoreModule` desde `PatientsModule` y anota el mensaje de error exacto. Restáuralo.
16. Mueve `MatCardModule` de `SharedModule` a `PatientsModule` y confirma que la aplicación sigue funcionando. Explica cuándo sí importaría la diferencia.
17. Añade un `console.log` en la línea `default` del reducer y anota cuántas acciones distintas pasan por ahí en una carga de página. Explica el número.
18. Reemplaza la sintaxis de `loadChildren` de `orders` por el import dinámico moderno. Confirma que compila y anota si el warning de deprecación desaparece.
19. Haz que el spinner solo aparezca si la carga tarda más de 300 ms, sin tocar el reducer ni el effect.
20. Convierte `selectAllPatients` en un selector que devuelva la lista ordenada por `fullName`. Anota cuántas veces se ejecuta la función de ordenamiento durante una carga.
21. Agrega el campo `lastLoadedAt` al estado, poblado en el caso de éxito con la fecha en zona horaria explícita. Explica por qué `new Date()` a secas sería un problema en la Fase 8.

**🟠 Difícil (22–29)**

22. **Diagnóstico.** Te entregan el proyecto con `createFeatureSelector('patient')` en singular. El reporte dice "la pantalla de pacientes está en blanco, sin errores". Reproduce, localiza y escribe el post-mortem de tres líneas.
23. **Diagnóstico.** El reducer muta `state.items` en el caso de éxito. Reproduce el silencio descrito en la sección 6, y explica por qué el panel Diff de DevTools te da información correcta y engañosa a la vez.
24. **Diagnóstico.** Mueve `catchError` fuera del `switchMap`. Apaga el mock, recarga, vuelve a levantarlo y pulsa reintentar. Documenta la secuencia completa de acciones en DevTools y explica por qué la última no aparece.
25. **Diagnóstico.** Alguien puso `EffectsModule.forRoot([PatientsEffects])` en `AppModule` **además** del `forFeature`. Reproduce y anota cuántas peticiones salen en la pestaña Network por cada carga, y por qué eso pasaría desapercibido con un mock rápido.
26. **Diagnóstico.** El componente despacha `loadPatients()` en el constructor en lugar de en `ngOnInit`. Anota si algo cambia visiblemente, y explica en qué situación sí cambiaría.
27. **Diagnóstico.** Sin tocar el effect, provoca un estado en el que `loading` se queda en `true` para siempre. Documenta la cadena completa y el parche mínimo que aplicarías un viernes.
28. Haz que el estado de `patients` **no** se registre hasta navegar a la ruta. Confírmalo mirando el árbol de estado en DevTools antes y después de navegar, y explica qué implica eso para un selector usado desde el `ShellComponent`.
29. **Diagnóstico.** Cambia el `map` del effect para que devuelva `loadPatientsSuccess({ pacientes: response })`. Confirma que compila, reproduce el síntoma y explica exactamente qué línea del código permitió que esto llegara a producción.

**🔴 Muy difícil (30–35)**

30. **Diagnóstico.** Consigue que la lista muestre los pacientes de una carga anterior después de un fallo. Documenta la cadena y distingue el parche mínimo de la refactorización correcta.
31. **Diagnóstico.** Provoca una condición de carrera despachando dos `loadPatients()` con latencia distinta —usa el retardo de la pestaña Network— y explica qué hizo `switchMap` con la primera. Después cámbialo por `mergeMap` y documenta la diferencia observable en DevTools.
32. Compila con `npx ng build --prod`, sirve el resultado y confirma en el bundle que las cadenas de las acciones (`[Patients] Load Patients`) siguen siendo legibles. Explica qué significa eso para depurar en producción.
33. Sobre ese mismo build, verifica si Redux DevTools sigue conectándose. Explica qué hace `logOnly` y por qué la extensión no es una puerta trasera pero tampoco es invisible.
34. **Diagnóstico.** Te entregan la aplicación con dos instancias del `PatientsService` en memoria. Localiza cómo se pudo llegar a eso a partir del código de esta fase, y qué evidencia lo confirmaría desde DevTools.
35. **Diagnóstico.** Sin tocar el reducer ni el effect, haz que un componente vea una lista de pacientes distinta a la que ve otro al mismo tiempo. Documenta la cadena completa y explica qué garantía de NgRx acabas de romper.

**🔥 Opcionales**

- 🔥 Reescribe `patients.reducer.ts` con `createReducer` y `on(...)`. Compara ambas versiones y anota qué error del ejercicio 29 habría atrapado el compilador. Después revierte, y explica en una línea por qué en Track A no se paga esta deuda.
- 🔥 Reemplaza las tres suscripciones del componente por `async` pipe en la plantilla. Anota cuántas líneas desaparecen y qué problema de desuscripción deja de existir.
- 🔥 Enciende las cuatro `runtimeChecks` de §5.6 y provoca el fallo: en el `case` de `loadPatientsSuccess`, cambia el `return { ...state, ... }` por `state.items = action.patients; return state;`. Anota el mensaje exacto de la excepción. Después **apágalas todas** y repite el experimento: lo que veas ahí te dice cuáles estaban activas de fábrica en tu versión de NgRx, que es un dato que no conviene creerle a ninguna tabla. Revierte las dos cosas.
- 🔥 Escribe un `MetaReducer` que registre en consola cada acción con su estado anterior y posterior. Es la versión casera de DevTools y sirve para el día que tengas que depurar en un navegador donde no puedas instalar extensiones.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v8.angular.io/guide/architecture-modules — `NgModule`, qué declara, qué importa y qué provee.
- https://v8.angular.io/guide/lazy-loading-ngmodules — carga diferida con la sintaxis de la época.
- https://v8.angular.io/guide/router — el router completo. Léelo en diagonal; solo necesitas rutas y `router-outlet`.
- https://v8.angular.io/guide/build#configure-target-specific-file-replacements — el reemplazo de `environment.ts` al compilar. Es la tesis de la Fase 13.
- https://ngrx.io/guide/store — guía del store. ⚠️ El sitio documenta versiones muy posteriores a la 8: los conceptos son los mismos, pero los ejemplos usan `createFeature` y sintaxis que acá no vas a escribir.
- https://ngrx.io/guide/effects — effects. Misma advertencia de versión.
- https://rxjs.dev/guide/operators — RxJS 6. Cuidado: hay diferencias de imports con RxJS 7, que es lo que el sitio asume por defecto.
- https://v8.material.angular.io/components/sidenav/overview — el `mat-sidenav` del layout.
- https://github.com/reduxjs/redux-devtools — la extensión.

**Video / apoyo**

- Cualquier introducción a Redux sirve para el modelo mental de acción/reducer/estado: NgRx es Redux con inyección de dependencias encima. Verifica la versión antes de copiar código de NgRx de cualquier fuente en video; casi todo el material posterior a 2021 usa APIs que acá no existen o que el curso no usa.

**Orden de lectura sugerido:** empieza por la guía de módulos de v8 para tener el mapa de `NgModule`; ten abierta la de effects de NgRx mientras escribes la sección 5.12, que es donde vas a necesitarla; y vuelve a la guía de *build* al terminar el ejercicio 32, cuando ya sepas por qué las cadenas de acciones sobreviven a la minificación.

> ⚠️ URLs, títulos y contenidos cambian o desaparecen; verifícalos. El apéndice
> [A06 — NgRx 8](./a06-ngrx.md) cubre el store al estilo de la época sin
> las advertencias de versión que hay que repetir en cada enlace de `ngrx.io`.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Terminas con el esqueleto completo: cuatro módulos por dominio, un router que
carga cada uno cuando hace falta, un layout, y el store funcionando de punta a
punta para pacientes. Más importante: terminas sabiendo leer el log de acciones,
que es la herramienta que vas a usar en las once fases restantes cada vez que
algo no cuadre.

Lo que quedó pendiente es que **la aplicación todavía habla un solo idioma, y con
los textos escritos a mano en las plantillas**. Esa deuda la declaró la Fase 0 y
sigue viva en cada `<a mat-list-item>` del `ShellComponent`. La Fase 2 la paga:
monta el árbol de traducciones con tres idiomas y su primer ejercicio es
reemplazar exactamente los literales que acabas de escribir. Necesita de esta
fase el layout donde vive el selector de idioma y el módulo donde registrarlo.

> **La señal de que quedó bien:** "si alguien me describe lo que hizo en la
> pantalla, yo puedo decirle qué acciones despachó — y si me muestra el log de
> acciones, yo puedo decirle qué hizo."


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-01-estructura-base-ngrx -m "F1 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f01: …`) y los de ejercicio su
> número (`f01 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f01/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- 🪦 **Versión de NgRx: cerrada.** `8.6.0`, la última de la línea 8, fijada en el
  README y en `propuesta-fases-y-alcance.md` §8. Ya no hay nada que verificar.
- **`@ngrx/entity` en LabCore.** Si allá se usa, la forma del estado de
  las Fases 5-11 cambia entera (`{ ids, entities }` en vez de arrays). Verificar
  antes de escribir la Fase 5 → **Fase 5** y apéndice **A06**.
- **Constante compartida para la feature key.** El bug del ejercicio 22 se evita
  exportando `PATIENTS_FEATURE_KEY`. Es refactor de patrón, no de hotfix →
  decisión de proyecto, apéndice **A06**.
- **`MetaReducer` de logging.** Queda como ejercicio 🔥 acá; si el equipo depura
  en entornos sin extensiones del navegador, merece desarrollo propio →
  apéndice **A06** o [`forense-fase-01.md`](./forense-fase-01.md).
- **`async` pipe y desuscripción.** Se nombra y se difiere. El memory leak de
  suscripciones se mide en la **Fase 10** y se enseña a prevenir en **A05**.

### Reservas para el cuaderno de incidentes

Esta fase toma el incidente **03**, ya reservado en el índice de
[`cuaderno-incidentes.md`](./cuaderno-incidentes.md). El enunciado completo —ticket, preparación,
pistas plegadas y solución de referencia— **ya está escrito allí**:

- **03** · Fase 1 · *"Cambié el paciente y la lista no se entera"* · Categoría: estado (store) · Dificultad 🟡 — la mutación dentro del reducer: el estado es correcto en DevTools y la pantalla muestra lo viejo porque el selector nunca emitió. El ejercicio que lo prepara es el que rompe la inmutabilidad a propósito.
