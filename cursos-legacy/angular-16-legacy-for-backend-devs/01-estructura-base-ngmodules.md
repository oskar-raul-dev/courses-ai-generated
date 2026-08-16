# 🏗️ Fase 01 — Estructura base con NgModules

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 1 de 14 · **8 horas**
> Depende de: Fase 0 (setup + hola mundo standalone) · Habilita: Fases 2 a 13
> Apéndices de apoyo: [A01 (Angular Material 16)](a01-material.md) · [A04 (`inject()](a04-inject-vs-constructor.md)` vs constructor)
> [Incidentes asociados](cuaderno-incidentes.md): 02
> Estilo de esta fase: **heredado** (NgModule + `constructor`)

---

## 🎯 1. Propósito

Aquí llega la herencia. Vas a montar el esqueleto de `NgModule` que CertCore trae de 2021 —`AppModule`, `CoreModule`, `SharedModule`, seis módulos de feature con carga diferida y un layout con `router-outlet`— y, para cada pieza, vas a poder responder a la única pregunta que importa cuando mantienes código ajeno: **¿qué problema resolvía esto antes de que existiera la alternativa moderna?**

Es el 80% del código que vas a tocar durante los próximos tres meses de ficción. La Fase 0 te enseñó el destino; ésta te entrega el edificio.

Y empieza con algo incómodo, así que va primero: **el hola mundo de la Fase 0 se retira hoy** 🪦. No se recicla, no se adapta. Era andamio, cumplió su función —levantar el entorno y enseñarte el estilo de 2024— y sale del proyecto. Borrar código propio sin drama también se aprende, y es más fácil practicarlo con doscientas líneas tuyas que con el módulo de reportes de otro.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `src/main.ts` arranca con `platformBrowserDynamic().bootstrapModule(AppModule)` y **no existe `app.config.ts`** en el proyecto.
- [ ] El layout se ve: toolbar arriba, sidenav con seis enlaces, y el contenido cambiando dentro del `router-outlet`.
- [ ] Las seis rutas (`/dashboard`, `/clients`, `/assets`, `/templates`, `/inspections`, `/certificates`) navegan y muestran su placeholder; `/lo-que-sea` cae en el 404.
- [ ] En la pestaña Network, **cada feature descarga su propio `.js` la primera vez que entras y ninguna vez más**.
- [ ] Importar `CoreModule` desde un segundo módulo revienta con un mensaje escrito por ti, no con un error críptico de Angular.
- [ ] `src/environments/` existe, `ng build` usa el archivo de producción y `ng serve` el de desarrollo — y tú puedes demostrarlo mirando la toolbar.
- [ ] `git tag fase-01` está puesto, y `git tag` lista también `fase-00`.

---

## 🚫 3. Qué NO entra todavía

- **Login, guard e interceptor** → Fase 2. El `AuthModule` es el séptimo módulo de feature y lo crea esa fase, no ésta.
- **`HttpClient` usado de verdad, modelos de dominio y `db.json`** → Fase 3. Hoy `HttpClientModule` se importa y nadie lo llama: es fontanería, no consumo.
- **Servicios de estado con `BehaviorSubject`** → Fase 4.
- **Cualquier `standalone: true`** → Fase 5. Esta fase es de una sola generación, a propósito y sin excepciones.
- **Material de verdad** —tema con `define-palette`, `mat-table`, `MatDialog`, densidad, tipografía— → Fase 6 y **A01**. Hoy entra Material con un tema prefabricado y cuatro componentes de layout, lo justo para que la deuda 💸 de esta fase tenga sustancia.
- **Pruebas** → Fase 12. Se sigue generando todo con `skipTests`.

---

## 🧠 4. Concepto mínimo

### El problema que resolvía un NgModule

Tienes seis pantallas, un layout común, una librería de componentes y un compilador que necesita saber, para cada plantilla, qué etiquetas son componentes tuyos, cuáles son directivas, y de dónde sale cada servicio que alguien inyecta. Hoy la respuesta es que cada componente lo declara por su cuenta. Entre 2016 y 2022 la respuesta era distinta: **lo declaraba una unidad más grande, el `NgModule`**, y el componente no sabía nada de sí mismo.

Si vienes de backend, la analogía que abre la puerta es la de la unidad de compilación con visibilidad propia: un módulo agrupa tipos, decide cuáles son públicos, y trae un contenedor de dependencias asociado. Hasta ahí el paralelo funciona. Donde se rompe —y conviene saberlo desde ya— es que un `NgModule` **no es una unidad de carga**: puedes tener veinte módulos en un solo archivo `.js` descargado, o uno solo partido en tres. Quien decide qué se descarga junto es el router, no el módulo.

Los cuatro arrays, y qué contesta cada uno:

- **`declarations`** — qué componentes, directivas y pipes *nacen* aquí. Un componente se declara en exactamente un módulo, ni cero ni dos, y esa regla es el error número uno de la fase.
- **`imports`** — qué otros módulos necesito para que *mis* plantillas compilen. Si tu plantilla usa `<mat-toolbar>`, alguien tiene que haber importado `MatToolbarModule`.
- **`exports`** — qué de lo mío pueden usar los módulos que me importen. Sin `exports`, tus declaraciones son privadas y el módulo no le sirve a nadie más.
- **`providers`** — qué servicios registro en el inyector de este módulo.

Y hay un quinto que sólo tiene el módulo raíz: **`bootstrap`**, el componente por el que empieza todo.

### El árbol de inyectores, en tres frases

Angular no tiene un contenedor de dependencias: tiene un árbol de ellos. Hay un inyector raíz —el de la aplicación—, y cada módulo cargado de forma diferida crea el suyo por debajo. Cuando alguien pide un servicio, Angular sube por ese árbol hasta encontrar quién lo provee; si nadie lo hace, obtienes el `NullInjectorError` que ya viste en la Fase 0.

De ahí sale la trampa clásica que esta fase te hace tocar con las manos: **un servicio provisto en un módulo diferido tiene una instancia distinta a la del raíz**. Dos pantallas creen compartir un servicio y no lo comparten. `providedIn: 'root'` ganó la partida precisamente porque hace esa pregunta innecesaria en el 95% de los casos.

### Por qué existía `SharedModule`

En 2021 escribir los mismos ocho `imports` en cada uno de los seis módulos de feature era tedioso y se olvidaba. La solución del ecosistema —no de Angular, del ecosistema— fue un módulo que importa todo lo común y lo reexporta: importas uno y tienes los ocho. Funcionó. Y trajo el efecto que vas a medir en la Fase 5: **un módulo que sólo usa un botón arrastra la docena entera al bundle**.

### 🧬 ¿Nuevo o heredado?

El mismo componente, declarado en las dos generaciones:

```ts
// ── HEREDADO (2021, y todo lo que escribes en esta fase) ───────────────────
// El componente no dice nada de sí mismo. Quien lo declara es el módulo.
@Component({
  selector: 'cc-client-list',
  templateUrl: './client-list.component.html',
})
export class ClientListComponent {}

@NgModule({
  declarations: [ClientListComponent],
  imports: [SharedModule, ClientsRoutingModule],
})
export class ClientsModule {}
```

```ts
// ── NUEVO (2024, lo verás en la Fase 5 y lo escribirás desde la Fase 6) ────
// El componente declara lo que usa y se basta solo. No hay módulo.
@Component({
  selector: 'cc-client-list',
  standalone: true,
  imports: [CommonModule, MatTableModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './client-list.component.html',
})
export class ClientListComponent {}
```

**Cuál usarías.** Hoy, y en toda esta fase, el de arriba: estás construyendo el CertCore de 2021 y escribir un standalone aquí sería un anacronismo, no una mejora. El de abajo, desde la Fase 5 en adelante, para todo lo que nazca nuevo.

> 🧭 **Regla del proyecto.** Código nuevo, estilo nuevo. Código heredado, se toca lo mínimo y en su propio estilo. Mezclar los dos dentro de un mismo archivo es peor que cualquiera de los dos estilos puros.

Y una cosa que conviene decir en voz alta: **esta fase no tiene ni un solo punto de contacto 🧬 entre generaciones**, y eso es deliberado. El primero llega en la Fase 2, cuando un guard funcional se enchufe en esta app de módulos. Que aquí no haya ninguno es lo que te permite leer el estilo heredado limpio, sin ruido.

> 📝 **Nota de migración.** `NgModule` es de Angular 2 (2016) y fue la única forma de organizar una aplicación durante seis años. Los componentes standalone llegaron como vista previa en la 14 (2022) y se estabilizaron en la 15, apoyados en Ivy, el compilador que entró en la 9. CertCore nació en 2021 sobre Angular 12: cuando su equipo escribió esta estructura, **la alternativa no existía**. Nada de lo que vas a escribir hoy fue un error entonces, y casi nada de ello es un error ahora — sólo es de otra época.

---

## 💻 5. Código mínimo con comentarios

### 5.1 Primero, el retiro 🪦

Antes de borrar nada, se etiqueta. Si cerraste la Fase 0 como pedía su §9, ya tienes la etiqueta puesta; si no, ahora es el momento y es la última oportunidad.

```bash
# El estado en el que quedó la Fase 0, recuperable para siempre.
git add -A && git commit -m "fase 00: setup y hola mundo standalone"
git tag fase-00

# Y ahora sí, se retira el andamio.
git rm src/app/app.config.ts
git rm src/app/inspection-request-form.component.ts
git rm src/app/inspection-request-form.component.html
git rm src/app/inspection-request.model.ts
```

> 🧭 **La regla de la etiqueta por fase, que fijó la Fase 0, empieza a pagar hoy.** Sin `fase-00`, el formulario que acabas de borrar se habría ido de verdad, y el ejercicio 30 de esta fase —que lo recupera para compararlo— sería imposible. Es la primera vez del curso en que una convención aburrida te salva de perder algo, y no va a ser la última.

Lo que se va y por qué:

- **`app.config.ts`** — su contenido, los `providers` del inyector raíz, vuelve a vivir dentro de `AppModule`. Es literalmente el mismo array en otro sitio.
- **`InspectionRequestFormComponent`** — es standalone, y esta fase no tiene un solo standalone. Su contenido —solicitar una inspección— no se pierde: reaparece con el dominio de verdad en las Fases 7 y 8, donde el formulario se construye desde una plantilla versionada y no desde tres campos inventados.
- **`inspection-request.model.ts`** y el endpoint `/inspection-requests` — el modelo real llega en la Fase 3 con el `db.json` de `alcance-del-proyecto.md` §5.1. El de la Fase 0 era una aproximación deliberada para no adelantar la máquina de estados.

### 5.2 La estructura de directorios, fijada para las trece fases restantes

```
src/app/
├── core/                    ← una sola vez en toda la app: servicios de infraestructura,
│   │                          configuración, y más adelante el guard y el interceptor
│   ├── core.module.ts
│   └── models/              ← modelos de dominio compartidos (llegan en la Fase 3)
├── shared/                  ← lo reutilizable y sin estado: componentes tontos, pipes,
│   │                          y la reexportación de Material 💸
│   ├── shared.module.ts
│   └── not-found/
├── layout/                  ← el marco visual: toolbar, sidenav, router-outlet
│   ├── layout.module.ts
│   └── shell/
├── features/                ← una carpeta por feature, con su módulo y su routing
│   ├── clients/
│   ├── assets/
│   ├── templates/
│   ├── inspections/
│   ├── certificates/
│   └── dashboard/
├── app-routing.module.ts
├── app.module.ts
└── app.component.ts
```

**Detalles con intención**

- **`core` frente a `shared`, que es la duda de todo el mundo.** `core` es lo que existe **una vez** en la aplicación: servicios con estado, configuración, interceptores. `shared` es lo que se **repite** sin recordar nada entre usos: un pipe de formato, un botón, un componente de vacío. La prueba: si tenerlo dos veces sería un bug, va en `core`; si da igual, va en `shared`.
- **`layout` aparte de `shared`.** El shell existe una vez pero no es un servicio, y meterlo en `core` mezcla infraestructura con vistas. Un directorio de tres archivos ahorra esa discusión para siempre.
- **Diez módulos, y ese número importa.** `core`, `shared`, `layout` y siete features —los seis de hoy más `auth`, que crea la Fase 2—. La Fase 5 va a convertir uno a standalone y va a dejar nueve sin convertir, deliberadamente.

### 5.3 Material 16, con lo mínimo

```bash
ng add @angular/material@16.2.14
```

El schematic hace tres preguntas. Responde: **tema prefabricado `Indigo/Pink`**, **sí** a las tipografías globales y **sí** a las animaciones del navegador. Con eso te deja el tema en `angular.json`, `BrowserAnimationsModule` importado en `AppModule` y los estilos base en `styles.scss`.

> 🧭 **El tema prefabricado es provisional y está declarado como tal.** El theming de verdad —paleta con `define-palette`, densidad, tipografía— lo fija la **Fase 6**, que es donde hay tablas y formularios que lo justifiquen. Elegir la paleta hoy, con una toolbar y un sidenav en pantalla, sería elegirla a ciegas.

> ⚠️ El schematic añade dos `<link>` a `fonts.googleapis.com` en `index.html`. Funciona y es lo que hace todo el mundo, pero significa que tu aplicación pide dos recursos a un tercero en cada carga. En un despliegue sin salida a internet —que es más común de lo que parece en sistemas de certificación— hay que servir esas fuentes desde el propio contenedor. Anotado para la Fase 13.

Y antes de generar nada, comprueba que la Fase 0 dejó puesto el `skipTests`:

```jsonc
// angular.json → projects.certcore.schematics
{
  "schematics": {
    // Cero specs hasta la Fase 12. Sin esto, los seis módulos de feature
    // llegan con doce archivos de prueba vacíos que nadie va a mirar.
    "@schematics/angular:component": { "skipTests": true },
    "@schematics/angular:service": { "skipTests": true },
    "@schematics/angular:guard": { "skipTests": true },
    "@schematics/angular:interceptor": { "skipTests": true },
    "@schematics/angular:pipe": { "skipTests": true },
    "@schematics/angular:directive": { "skipTests": true }
  }
}
```

### 5.4 El arranque vuelve a su sitio

```ts
// src/main.ts
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';

import { AppModule } from './app/app.module';

// Así arranca CertCore desde 2021, y así sigue arrancando hoy: la migración a
// la 16 no tocó este archivo, porque no había ningún motivo para tocarlo.
platformBrowserDynamic()
  .bootstrapModule(AppModule)
  .catch((error: unknown) => console.error(error));
```

Es el mismo archivo que viste en la sección 4 de la Fase 0, en la columna de la izquierda. Entonces era una comparación; ahora es tu punto de entrada.

### 5.5 `AppModule`

```ts
// src/app/app.module.ts
import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { CoreModule } from './core/core.module';
import { LayoutModule } from './layout/layout.module';

@NgModule({
  // Lo que nace aquí. El módulo raíz declara poco: sólo el componente que
  // Angular arranca. Todo lo demás vive en su feature.
  declarations: [AppComponent],

  imports: [
    // BrowserModule sólo va en el módulo raíz: incluye CommonModule y la
    // fontanería del navegador. En un módulo de feature se importa CommonModule.
    BrowserModule,
    BrowserAnimationsModule,
    CoreModule,
    LayoutModule,
    // El routing va último a propósito: la ruta comodín ** de AppRoutingModule
    // tiene que quedar después de todas las demás o se come el resto.
    AppRoutingModule,
  ],

  // Vacío, y no por casualidad: los servicios de este curso se registran con
  // providedIn: 'root' o en CoreModule. Ver 5.7.
  providers: [],

  // El quinto array, y sólo lo tiene el módulo raíz: por dónde empieza todo.
  bootstrap: [AppComponent],
})
export class AppModule {}
```

```ts
// src/app/app.component.ts
import { Component } from '@angular/core';

// Componente heredado: declarado en un NgModule, sin `standalone`, sin OnPush.
// La detección de cambios por defecto es la de 2021, y en la Fase 11 vamos a
// hablar de lo que cuesta.
@Component({
  selector: 'cc-root',
  template: '<cc-shell></cc-shell>',
})
export class AppComponent {}
```

**Detalles con intención**

- **El `AppComponent` quedó en tres líneas.** No es minimalismo: es que en una app con layout, el componente raíz no tiene nada que hacer más que dar paso al shell. Un `AppComponent` gordo es una señal de que el layout nunca se separó.
- **`providers: []` vacío y visible.** Lo dejamos escrito en vez de borrar la clave, porque la Fase 2 va a poner cosas ahí y conviene que el hueco se vea.

### 5.6 El routing raíz y la carga diferida

```ts
// src/app/app-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { NotFoundComponent } from './shared/not-found/not-found.component';

const routes: Routes = [
  // pathMatch: 'full' es obligatorio en una redirección desde la ruta vacía.
  // Sin él, '' hace prefijo con TODO y ninguna otra ruta llega a evaluarse.
  { path: '', pathMatch: 'full', redirectTo: 'dashboard' },

  {
    path: 'dashboard',
    // La función import() es lo que le dice al compilador "esto va en otro
    // archivo .js y se descarga cuando alguien navegue aquí".
    loadChildren: () =>
      import('./features/dashboard/dashboard.module').then((m) => m.DashboardModule),
  },
  {
    path: 'clients',
    loadChildren: () =>
      import('./features/clients/clients.module').then((m) => m.ClientsModule),
  },
  {
    path: 'assets',
    loadChildren: () =>
      import('./features/assets/assets.module').then((m) => m.AssetsModule),
  },
  {
    path: 'templates',
    loadChildren: () =>
      import('./features/templates/templates.module').then((m) => m.TemplatesModule),
  },
  {
    path: 'inspections',
    loadChildren: () =>
      import('./features/inspections/inspections.module').then((m) => m.InspectionsModule),
  },
  {
    path: 'certificates',
    loadChildren: () =>
      import('./features/certificates/certificates.module').then((m) => m.CertificatesModule),
  },

  // Siempre la última. El router evalúa en orden y ** hace juego con todo.
  { path: '**', component: NotFoundComponent },
];

@NgModule({
  // forRoot() en el módulo raíz, y sólo ahí: es el que crea el servicio Router.
  // Llamarlo dos veces en la misma aplicación produce dos routers peleándose.
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
```

> ⚠️ La Fase 0 generó el proyecto con `--routing=false`, así que este archivo lo escribes tú. No es que al CLI se le haya olvidado: no había ninguna ruta que declarar el día uno, y un `app-routing.module.ts` vacío durante una fase entera es ruido.

**El patrón a memorizar**

> Las rutas se evalúan **en orden y por prefijo**. Por eso `''` necesita `pathMatch: 'full'` y `**` va al final. El 90% de los "mi ruta no carga" de un proyecto Angular es una de esas dos cosas.

### 5.7 `CoreModule` y el guard de doble importación

```ts
// src/app/core/core.module.ts
import { HttpClientModule } from '@angular/common/http';
import { NgModule, Optional, SkipSelf } from '@angular/core';

@NgModule({
  // HttpClientModule vive aquí porque el cliente HTTP debe existir una sola
  // vez. En la Fase 2 esta línea se sustituye por provideHttpClient(), que es
  // la forma moderna de registrar lo mismo — y ahí llega el primer 🧬.
  imports: [HttpClientModule],
  exports: [HttpClientModule],
})
export class CoreModule {
  /**
   * El guard de doble importación, un clásico de 2021 que sigue siendo útil.
   * @SkipSelf() le dice al inyector "búscalo hacia arriba, no en mí mismo", y
   * @Optional() que devuelva null en vez de explotar si no lo encuentra.
   * Si encuentra algo, es que alguien ya importó CoreModule más arriba.
   */
  constructor(@Optional() @SkipSelf() parentModule?: CoreModule) {
    // ⚠️ Comprobación por verdad, no por `!== undefined`. Aunque el parámetro
    // sea opcional y TypeScript lo tipe como `CoreModule | undefined`,
    // @Optional() inyecta `null` en tiempo de ejecución. Comparar contra
    // undefined haría que esto lanzara SIEMPRE, incluso en el caso bueno.
    if (parentModule) {
      throw new Error(
        'CoreModule ya está cargado. Impórtalo únicamente en AppModule.',
      );
    }
  }
}
```

**Detalles con intención**

- **El mensaje de error va en español.** Es un mensaje para otro desarrollador, no para el usuario: es la continuación natural del comentario, y en este proyecto los comentarios se escriben en español. Los identificadores siguen en inglés. La misma regla aplica a cualquier `console.error` del curso.
- **`providedIn: 'root'` frente a los `providers` de un módulo.** El primero es el estilo por defecto del curso, incluso en el código heredado: el servicio se registra solo y desaparece del bundle si nadie lo usa. Los `providers` de `CoreModule` se reservan para los tokens de configuración, que es lo que verás en el ejercicio 19.

### 5.8 `SharedModule`, y la deuda 💸

```ts
// src/app/shared/shared.module.ts
import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatListModule } from '@angular/material/list';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatTableModule } from '@angular/material/table';
import { MatToolbarModule } from '@angular/material/toolbar';

import { NotFoundComponent } from './not-found/not-found.component';

/**
 * 💸 DEUDA TÉCNICA INTENCIONAL
 * Doce módulos de Material reexportados "por comodidad", para que ningún
 * módulo de feature tenga que pensar qué importa. En 2021 ahorró discusiones.
 * Hoy significa que la pantalla de dashboard, que muestra tres tarjetas,
 * arrastra la tabla, el diálogo y el snackbar al mismo bundle.
 * Lo correcto es que cada módulo importe lo que usa y ni una cosa más.
 * SE PAGA EN PARTE EN LA FASE 5, con el tamaño del bundle medido antes y
 * después: salen los módulos que no usa nadie y el código nuevo deja de pasar
 * por aquí. El resto NO SE PAGA EN ESTE CURSO, porque saldarlo entero exige
 * convertir los módulos heredados que importan este archivo —una migración—, y
 * aquí se enseña a mantener. La Fase 5 lo demuestra con el build delante.
 * Hasta entonces no se toca: quiero que lo sufras con números.
 */
const MATERIAL_MODULES = [
  MatButtonModule,
  MatCardModule,
  MatDialogModule,
  MatFormFieldModule,
  MatIconModule,
  MatInputModule,
  MatListModule,
  MatProgressSpinnerModule,
  MatSidenavModule,
  MatSnackBarModule,
  MatTableModule,
  MatToolbarModule,
];

@NgModule({
  declarations: [NotFoundComponent],
  imports: [CommonModule, ReactiveFormsModule, ...MATERIAL_MODULES],
  // Sin `exports`, todo lo de arriba sería privado y este módulo no le
  // serviría a nadie. Un SharedModule sin exports es el error más silencioso
  // de la fase: compila, se importa, y no aporta nada.
  exports: [CommonModule, ReactiveFormsModule, ...MATERIAL_MODULES, NotFoundComponent],
})
export class SharedModule {}
```

```ts
// src/app/shared/not-found/not-found.component.ts
import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'cc-not-found',
  templateUrl: './not-found.component.html',
})
export class NotFoundComponent {
  // Inyección por constructor: el estilo heredado. La comparación completa con
  // inject() está en el apéndice A04.
  constructor(private readonly router: Router) {}

  goHome(): void {
    // navigate() devuelve una promesa con el resultado de la navegación.
    // Aquí no nos interesa, y `void` lo dice explícitamente en vez de dejar
    // una promesa suelta que nadie mira.
    void this.router.navigate(['/dashboard']);
  }
}
```

```html
<!-- src/app/shared/not-found/not-found.component.html -->
<h2>Esta página no existe</h2>
<p>Revisa la dirección, o vuelve al inicio.</p>
<button mat-raised-button color="primary" (click)="goHome()">Ir al panel</button>
```

### 5.9 El layout

```ts
// src/app/layout/shell/shell.component.ts
import { Component } from '@angular/core';

import { environment } from '../../../environments/environment';

interface NavigationItem {
  readonly path: string;
  readonly label: string;
  readonly icon: string;
}

@Component({
  selector: 'cc-shell',
  templateUrl: './shell.component.html',
  styleUrls: ['./shell.component.scss'],
})
export class ShellComponent {
  // Los enlaces del menú, en el orden en que el negocio piensa el trabajo:
  // primero el panel, luego a quién se le inspecciona, luego con qué, y al
  // final lo que se emite.
  readonly navigationItems: readonly NavigationItem[] = [
    { path: '/dashboard', label: 'Panel', icon: 'dashboard' },
    { path: '/clients', label: 'Clientes', icon: 'business' },
    { path: '/assets', label: 'Activos', icon: 'elevator' },
    { path: '/templates', label: 'Plantillas', icon: 'checklist' },
    { path: '/inspections', label: 'Inspecciones', icon: 'fact_check' },
    { path: '/certificates', label: 'Certificados', icon: 'verified' },
  ];

  // Se lee del archivo de entorno, que el build sustituye. Ver 5.11.
  readonly environmentName = environment.environmentName;
}
```

```html
<!-- src/app/layout/shell/shell.component.html -->
<mat-toolbar color="primary">
  <button mat-icon-button (click)="sidenav.toggle()" aria-label="Abrir el menú">
    <mat-icon>menu</mat-icon>
  </button>
  <span>CertCore</span>
  <span class="shell-spacer"></span>
  <!-- Marcar el ambiente en la barra evita el error más caro del curso:
       creer que estás en UAT cuando estás en producción. -->
  <span class="shell-environment">{{ environmentName }}</span>
</mat-toolbar>

<mat-sidenav-container>
  <mat-sidenav #sidenav mode="side" opened>
    <mat-nav-list>
      <a
        mat-list-item
        *ngFor="let item of navigationItems"
        [routerLink]="item.path"
        routerLinkActive="active-link"
      >
        <mat-icon matListItemIcon>{{ item.icon }}</mat-icon>
        <span matListItemTitle>{{ item.label }}</span>
      </a>
    </mat-nav-list>
  </mat-sidenav>

  <mat-sidenav-content>
    <!-- Aquí es donde el router pinta la feature que toque. -->
    <router-outlet></router-outlet>
  </mat-sidenav-content>
</mat-sidenav-container>
```

```ts
// src/app/layout/layout.module.ts
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';

import { SharedModule } from '../shared/shared.module';
import { ShellComponent } from './shell/shell.component';

@NgModule({
  declarations: [ShellComponent],
  // RouterModule aparte de SharedModule: el shell necesita router-outlet y
  // routerLink, que son directivas del router y no de Material.
  imports: [SharedModule, RouterModule],
  exports: [ShellComponent],
})
export class LayoutModule {}
```

**Detalles con intención**

- **`matListItemIcon` y `matListItemTitle`, no `mat-list-icon` ni `mat-line`.** Los nombres cambiaron al pasar Material a MDC en la 15, y CertCore lo sufrió durante la migración de 2024. Cualquier ejemplo de `mat-nav-list` anterior a 2023 usa los nombres viejos y no compila aquí. Es el aviso permanente de **A01**.
- **`readonly navigationItems: readonly NavigationItem[]`.** El doble `readonly` —la propiedad y el array— dice que esto no cambia nunca. Cuando en la Fase 4 aparezcan listas que sí cambian, la diferencia va a importar.

### 5.10 Un módulo de feature, entero

Éste es el patrón. Los otros cinco son idénticos salvo por los nombres.

```ts
// src/app/features/clients/clients.module.ts
import { NgModule } from '@angular/core';

import { SharedModule } from '../../shared/shared.module';
import { ClientListComponent } from './client-list/client-list.component';
import { ClientsRoutingModule } from './clients-routing.module';

@NgModule({
  declarations: [ClientListComponent],
  // SharedModule trae CommonModule y los doce de Material 💸.
  imports: [SharedModule, ClientsRoutingModule],
})
export class ClientsModule {}
```

```ts
// src/app/features/clients/clients-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { ClientListComponent } from './client-list/client-list.component';

// path: '' porque el prefijo 'clients' ya lo puso la ruta padre. Repetirlo
// aquí produciría /clients/clients, que es el segundo error más común del día.
const routes: Routes = [{ path: '', component: ClientListComponent }];

@NgModule({
  // forChild() en los módulos de feature: se cuelga del router que ya existe
  // en vez de crear uno nuevo.
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ClientsRoutingModule {}
```

```ts
// src/app/features/clients/client-list/client-list.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'cc-client-list',
  templateUrl: './client-list.component.html',
})
export class ClientListComponent {}
```

```html
<!-- src/app/features/clients/client-list/client-list.component.html -->
<h2>Clientes</h2>
<p>El listado de clientes llega en la Fase 6.</p>
```

Los otros cinco se generan igual:

```bash
ng generate module features/assets --routing
ng generate component features/assets/asset-list
# …y lo mismo para templates, inspections, certificates y dashboard
```

| Ruta | Módulo | Componente placeholder | Fase que lo llena |
|---|---|---|---|
| `/dashboard` | `DashboardModule` | `DashboardHomeComponent` | Fase 11 |
| `/clients` | `ClientsModule` | `ClientListComponent` | Fase 6 |
| `/assets` | `AssetsModule` | `AssetListComponent` | Fase 6 |
| `/templates` | `TemplatesModule` | `TemplateListComponent` | Fase 7 ⭐ |
| `/inspections` | `InspectionsModule` | `InspectionListComponent` | Fase 8 ⭐ |
| `/certificates` | `CertificatesModule` | `CertificateListComponent` | Fase 10 |

### 5.11 La configuración por ambiente

```bash
ng generate environments
```

```ts
// src/environments/environment.model.ts
/**
 * El contrato que los dos archivos de entorno tienen que cumplir. Sin esto,
 * un archivo puede quedarse sin un campo y el error aparece en tiempo de
 * ejecución, en el ambiente equivocado y en el peor momento.
 */
export interface AppEnvironment {
  readonly production: boolean;
  readonly apiBaseUrl: string;
  readonly environmentName: 'DEV' | 'UAT' | 'PROD';
}
```

```ts
// src/environments/environment.ts  ← el de PRODUCCIÓN (es el archivo por defecto)
import { AppEnvironment } from './environment.model';

/**
 * 💸 LA DEUDA DE LA FASE 0, MUDADA DE CASA
 * En la Fase 0 la URL del backend estaba escrita dentro de un componente.
 * Ahora está aquí, y se ve mucho más ordenado. Que no te engañe: sigue
 * HORNEADA EN TIEMPO DE COMPILACIÓN. Cambiarla exige recompilar y volver a
 * desplegar, que es exactamente el problema.
 * SE PAGA EN LA FASE 13, leyendo la configuración en tiempo de arranque.
 * Si hiciste el ejercicio 27 de la Fase 0, ya sabes que mover la constante de
 * archivo no cambia absolutamente nada; esto es lo mismo, con mejor letra.
 */
export const environment: AppEnvironment = {
  production: true,
  apiBaseUrl: '/api',
  environmentName: 'PROD',
};
```

```ts
// src/environments/environment.development.ts
import { AppEnvironment } from './environment.model';

export const environment: AppEnvironment = {
  production: false,
  // El stub de json-server de la Fase 0; en la Fase 3 será el mock completo.
  apiBaseUrl: 'http://localhost:3000',
  environmentName: 'DEV',
};
```

```jsonc
// angular.json → …architect.build.configurations.development
{
  "development": {
    // El build de desarrollo sustituye un archivo por otro. En producción no
    // hay sustitución: se usa environment.ts tal cual.
    "fileReplacements": [
      {
        "replace": "src/environments/environment.ts",
        "with": "src/environments/environment.development.ts"
      }
    ]
  }
}
```

**Prueba de fuego**

Corre `ng serve` y mira la esquina derecha de la toolbar: dice `DEV`. Ahora `ng build --configuration production`, sirve el `dist/` y mírala otra vez: dice `PROD`. Son **el mismo archivo de código** dando dos resultados distintos, y el que decide cuál es el compilador. Guarda esa sensación: es la que la Fase 13 va a poner del revés.

### 5.12 Los chunks, que es donde se ve el lazy loading

```bash
ng build
```

```
Initial chunk files   | Names         |  Raw size
main.js               | main          | 412.75 kB
styles.css            | styles        | 76.12 kB
polyfills.js          | polyfills     | 33.06 kB

Lazy chunk files      | Names         |  Raw size
src_app_features_clients_clients_module_ts.js         | clients-module      | 4.21 kB
src_app_features_assets_assets_module_ts.js           | assets-module       | 4.18 kB
src_app_features_templates_templates_module_ts.js     | templates-module    | 4.20 kB
…
```

Los números de tu máquina van a diferir un poco y no importa. Lo que importa es la separación: **seis archivos que no están en el bundle inicial**.

**Prueba de fuego**

Abre la aplicación con la pestaña Network abierta y el filtro en `JS`. Navega a Clientes: aparece una petición nueva. Vuelve al panel y entra otra vez a Clientes: **no aparece nada**, porque ya está en memoria. Ese "no aparece nada" es la confirmación de que el lazy loading funciona; si el chunk no aparece **nunca**, no es que vaya muy rápido: es que ese módulo dejó de ser diferido, y en la sección 6 vas a ver por qué.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** `Type ClientListComponent is part of the declarations of 2 NgModules: ClientsModule and SharedModule.`
**Causa:** el componente está en dos `declarations`. Suele pasar al mover un componente de sitio y olvidar quitarlo del origen.
**Fix mínimo:** borrarlo de una de las dos listas — de la que **no** es su casa.
**Lo que importa:** un componente se declara en exactamente un módulo. Si otro módulo lo necesita, el dueño lo pone en `exports` y el otro importa el módulo. No hay una tercera vía, y buscarla es cómo aparece este error.

**Síntoma:** `NG8001: 'cc-client-list' is not a known element.`
**Causa:** o el componente no está declarado en ningún sitio, o está declarado en un módulo que no lo exporta, o el módulo que lo exporta no está importado donde lo usas. Tres causas, un solo mensaje.
**Fix mínimo:** recorrer las tres en ese orden, que es el de más frecuente a menos.
**Lo que importa:** con `strictTemplates` puesto (Fase 0), este error llega en el build. Sin él, llegaría en el navegador, y el elemento simplemente no se pintaría — sin error visible, que es peor.

**Síntoma:** `Error: CoreModule ya está cargado. Impórtalo únicamente en AppModule.`
**Causa:** alguien importó `CoreModule` desde un módulo de feature buscando `HttpClientModule`.
**Fix mínimo:** quitar el import y traer `SharedModule`, que es lo que un feature necesita.
**Lo que importa:** ese mensaje lo escribiste tú, en 5.7, y por eso se entiende. Sin el guard, el síntoma habría sido un servicio duplicado con estado desincronizado, tres pantallas más allá y sin ninguna pista.

**Síntoma:** el chunk de una feature no aparece en Network **nunca**, y `main.js` engordó.
**Causa:** ese módulo está en los `imports` de `AppModule` **además** de en su `loadChildren`. Al importarlo de forma directa, el bundler lo mete en el bundle inicial y la carga diferida se vuelve decorativa.
**Fix mínimo:** quitarlo de los `imports`.
**Lo que importa:** este bug no rompe nada. La aplicación funciona igual, sólo que arranca más lenta para todo el mundo. Los bugs que no rompen nada son los que sobreviven años, y por eso vale más medirlos que mirarlos.

### Pieza forense de esta fase

Tres preguntas, tres formas de contestarlas sin adivinar.

**¿Este componente existe y quién lo declara?** El error de plantilla te dice el selector, no el archivo. Busca el selector en todo `src/` (`grep -rn "cc-client-list" src/`), encuentra el `@Component`, y desde ahí sube al módulo que lo declara. Es un camino de tres saltos y siempre es el mismo.

**¿Este módulo es diferido de verdad?** No lo preguntes al código: pregúntaselo a Network. Filtro en `JS`, "Disable cache" activado, y navega. Si aparece una petición nueva, es diferido. Si no aparece, mira `main.js`: si su tamaño incluye el componente de esa feature, el módulo se volvió eager y alguien lo importó de más.

**¿Qué chunk es cuál en producción?** En el build de desarrollo los chunks se llaman `src_app_features_clients_clients_module_ts.js` y se leen solos. En producción, con `outputHashing` puesto, se llaman `493.8a1f2c.js` y no dicen nada. Dos formas de resolverlo: `ng build --named-chunks` para una investigación puntual, o `ng build --stats-json` y buscar el módulo dentro de `stats.json`, que es lo que se hace cuando el build es el de un pipeline y no lo puedes cambiar.

> 📄 El recorrido completo, con los mensajes literales de cada error, en `forense-fase-01.md`.

**🧨 Rompe a propósito**

Añade `CertificatesModule` a los `imports` de `AppModule`, **sin quitar** su `loadChildren`. Compila y responde:

1. ¿Cuánto creció `main.js`? Anota los dos números.
2. ¿Sigue apareciendo el chunk de certificados en la lista de "Lazy chunk files"?
3. Navega a `/certificates` con Network abierto. ¿Qué se descarga?
4. ¿Dio Angular algún error, advertencia o pista de cualquier tipo?

La respuesta a la cuarta es no, y ése es el punto entero del ejercicio.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Etiqueta el estado de la Fase 0 (`git tag fase-00`) antes de borrar nada, y comprueba con `git show fase-00 --stat` que el formulario standalone sigue ahí dentro. Criterio: `git tag` lista la etiqueta y el árbol de trabajo ya no tiene `app.config.ts`.
2. Genera los seis módulos de feature con sus placeholders y verifica con `find src -name "*.spec.ts"` que no se creó ni un archivo de pruebas.
3. Cablea los seis `loadChildren` y comprueba que las seis rutas navegan desde el sidenav. Criterio: la URL cambia y el `<h2>` de la pantalla también.
4. **Diagnóstico.** Quita `MatToolbarModule` del array de `SharedModule`. Anota el código de error, el mensaje literal y **en qué archivo** te lo señala Angular. ¿Es el archivo donde está el problema?
5. **Diagnóstico.** Borra el `pathMatch: 'full'` de la redirección de la ruta vacía. Navega a `/clients` y explica qué pasa y por qué.
6. Importa `CoreModule` desde `ClientsModule`, navega a `/clients` y captura el mensaje del guard. Restáuralo y explica en dos frases qué te habría pasado sin ese guard.
7. Corre `ng build` y empareja cada uno de los seis chunks diferidos con su ruta. Criterio: una tabla de seis filas, sin adivinar ninguna.
8. Cambia `environmentName` a `'UAT'` en el archivo de desarrollo y confirma que la toolbar lo refleja tras recargar. Explica por qué no hizo falta tocar `ShellComponent`.

**🟡 Intermedio (9–17)**

9. **Diagnóstico.** Declara `NotFoundComponent` también en `LayoutModule`. Reproduce el error de "2 NgModules", explica cuál de las dos declaraciones sobra y por qué Angular no puede decidirlo por ti.
10. **Diagnóstico.** Haz el 🧨 de la sección 6 con `CertificatesModule` y entrega las cuatro respuestas con los números medidos, no estimados.
11. Cambia la ruta del panel para que sea `path: ''` con `loadChildren` en vez de una redirección a `/dashboard`. Compara las dos soluciones: qué se ve en la barra de direcciones, qué pasa con el botón "atrás", y cuál dejarías en CertCore. Justifica.
12. Implementa `NotFoundComponent` con su botón de vuelta. Criterio: `/inspecciones` (en español, mal escrito) muestra el 404 y el botón te lleva al panel sin recargar la página.
13. **Diagnóstico.** Cambia la comprobación del guard de `CoreModule` a `if (parentModule !== undefined)`. Arranca la aplicación y explica por qué ahora falla siempre, incluso con una sola importación. Relaciónalo con lo que hace `@Optional()`.
14. Cuenta cuántos módulos de Material reexporta `SharedModule` y cuántos usa realmente el `ShellComponent`. Escribe los dos números en un archivo `deuda.md`: la Fase 5 te los va a pedir.
15. Mueve `HttpClientModule` de `CoreModule` a `AppModule`. Comprueba que no se rompe absolutamente nada y después argumenta, en cinco líneas, por qué la convención sigue valiendo la pena aunque el compilador no la exija.
16. **Diagnóstico.** Borra el array `exports` completo de `SharedModule`. Anota **todos** los errores que aparecen, en orden, y explica por qué el primero no menciona a `SharedModule`.
17. Añade una segunda ruta al feature de clientes (`clients/:id`, con un placeholder de detalle) usando `forChild`. Comprueba en Network que **no** se descarga ningún chunk nuevo al entrar y explica por qué.

**🟠 Difícil (18–24)**

18. **Diagnóstico.** Compila en producción y localiza el chunk de `templates` sin usar `--named-chunks`. Documenta el método que usaste en cinco pasos reproducibles.
19. Crea un `InjectionToken<AppEnvironment>` llamado `APP_ENVIRONMENT`, provéelo en `CoreModule` con el objeto de `environment`, e inyéctalo en `ShellComponent` por constructor. Criterio: la toolbar sigue mostrando lo mismo y `ShellComponent` ya no importa `environment` directamente. Explica qué ganaste de cara a la Fase 12.
20. **Diagnóstico.** Provee ese mismo `APP_ENVIRONMENT` otra vez en `ClientsModule` con `environmentName: 'PROD'`. Navega a Clientes y responde: ¿qué instancia recibe un componente de esa feature, cuál recibe el shell, y por qué? Dibuja el árbol de inyectores del caso.
21. Reorganiza los activos como ruta hija de clientes (`clients/:clientId/assets`) manteniendo la carga diferida de ambos. Explica qué pasó con los dos chunks y si la nueva estructura te parece mejor para el dominio.
22. **Diagnóstico.** Escribe mal el nombre de la clase en un `loadChildren` (`then((m) => m.CertificateModule)`, en singular). Responde: ¿falla el build o falla la navegación? ¿Por qué? ¿Y qué habría pasado con el `loadChildren` de cadena de texto que se usaba antes de Angular 8?
23. Escribe un servicio trivial `AppInfoService` de las dos formas —`providedIn: 'root'` y declarado en los `providers` de `CoreModule`—, en dos ramas. Compila con `--stats-json` y responde cuál desaparece del bundle si nadie lo inyecta. Entrega el número.
24. **Diagnóstico.** Cambia un enlace del sidenav de `[routerLink]="item.path"` a `routerLink="item.path"` (sin corchetes). Explica a dónde intenta navegar, por qué el compilador no se queja, y qué regla te llevas sobre cuándo un atributo lleva corchetes.

**🔴 Muy difícil (25–30)**

25. Escribe el post-mortem completo de ocho puntos del incidente **02**: un compañero añadió la pantalla de activos, la ruta navega, pero la pantalla sale en blanco y la consola dice que `cc-asset-list` no es un elemento conocido. Los ocho puntos, con una prueba de regresión que de verdad se pueda automatizar en este repositorio tal como está hoy.
26. **Diagnóstico.** Te dan un `stats.json` de un build donde `main.js` pesa el doble de lo que debería, y **no** tienes el código delante. Describe el procedimiento exacto para averiguar qué feature dejó de ser diferida usando sólo ese archivo. Después provoca el caso, aplica tu procedimiento y comprueba si funciona.
27. Escribe la regla del proyecto sobre dónde vive cada cosa —`core`, `shared`, `layout` o `features/x`— en una página. Resuelve con ella tres casos límite: un pipe que formatea severidades y se usa en dos features; un servicio que recuerda el filtro de la última búsqueda; y un componente de tarjeta de certificado que hoy usa una feature y mañana dos. Justifica cada uno.
28. En una rama aparte, reescribe `SharedModule` sin la deuda: cada módulo de feature importa sólo los módulos de Material que usa. Mide el bundle inicial antes y después y guarda los dos números. **No lo fusiones**: la Fase 5 hace esto oficialmente y quiero que compares tu solución con la suya.
29. **Diagnóstico 🧨.** Añade `RouterModule.forRoot(routes)` dentro de `ClientsModule`. Describe qué se rompe, en qué orden, y por qué el error no menciona la palabra `forRoot` en ningún sitio. Explica qué hace `forRoot` que `forChild` no hace.
30. Recupera la aplicación de la Fase 0 (`git checkout fase-00 -- src/`, en una rama de usar y tirar) y escribe una página comparando: qué habría costado montar estas seis features en standalone puro, qué se habría ganado, y por qué el equipo de CertCore no pudo hacerlo en 2021. Usa la cronología de `00-historia-del-sistema.md` para fundamentarlo.

**🔥 Opcionales**

- 🔥 Sustituye las dos `<link>` de Google Fonts por las fuentes servidas desde `src/assets/`. Mide cuánto pesa eso en el bundle final y decide si compensa. Anticipa la Fase 13.
- 🔥 Añade `preloadingStrategy: PreloadAllModules` a `forRoot` y observa en Network en qué momento se descargan ahora los seis chunks. Explica para qué clase de aplicación es buena idea y para cuál no.
- 🔥 Escribe un `README.md` de dos párrafos para el directorio `src/app/`, dirigido a quien entre al equipo dentro de seis meses. Es el documento que a ti nadie te dejó.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v16.angular.io/guide/ngmodules — la guía completa de NgModules, todavía viva en la documentación de la 16.
- https://v16.angular.io/guide/frequent-ngmodules y https://v16.angular.io/guide/module-types — qué módulo es de qué tipo y cuál importar dónde. Es la respuesta corta a `BrowserModule` frente a `CommonModule`.
- https://v16.angular.io/guide/lazy-loading-ngmodules — `loadChildren`, `forRoot` y `forChild`.
- https://v16.angular.io/guide/hierarchical-dependency-injection — el árbol de inyectores, que es lo que hace falta para el ejercicio 20.
- https://v16.angular.io/guide/router — el router entero; para esta fase, las secciones de rutas comodín y redirecciones.
- https://v16.angular.io/guide/build#configuring-application-environments — `fileReplacements` y los archivos de entorno.
- https://v16.material.angular.io/components/sidenav/overview y https://v16.material.angular.io/components/list/overview — sidenav y nav-list en la versión MDC. ⚠️ `material.angular.io` sin el `v16.` documenta la 17+ y sus ejemplos no compilan aquí.

> ⚠️ La documentación de NgModules sigue publicada pero ya no es lo que Angular recomienda escribir. Cuando leas "la forma recomendada", ten presente la fecha: en 2021 la recomendación era exactamente esto. Y si un buscador te lleva a `angular.dev`, estás leyendo la 17+, donde estos ejemplos ya no aparecen.

**Video y apoyo**

- La charla "Angular Modules and Providers" del equipo de Angular sigue siendo la mejor explicación del árbol de inyectores; búscala por título en el canal oficial de Angular en YouTube. ⚠️ Los identificadores de video cambian y no vamos a inventar uno.

**Orden de lectura sugerido**

Antes de escribir código: la guía de NgModules y la de tipos de módulo, que juntas contestan el 80% de las dudas de la fase. Durante: la de lazy loading, cuando llegues a 5.6, y **A04** si la inyección por constructor te resulta ajena viniendo de la Fase 0. Después: la de inyección jerárquica, que sólo se entiende cuando ya tienes dos inyectores delante — vuelve a ella con el ejercicio 20 abierto.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Tienes el esqueleto de CertCore: once módulos, seis features que se descargan solas, un layout que se ve, un 404 que funciona, configuración por ambiente y una deuda 💸 con fecha de cobro. Y tienes algo menos visible y más importante: sabes leer un `NgModule` y decir en diez segundos qué declara, qué necesita, qué presta y qué provee.

La **Fase 2** trae la autenticación, y con ella **el primer punto de contacto entre las dos generaciones** 🧬. Un `authGuard` funcional —una función, sin clase ni decorador— protegiendo rutas declaradas en estos módulos. Un `authInterceptor` funcional conviviendo con el registro de interceptores de clase. Ahí vas a ver por primera vez las dos épocas de CertCore tocándose en el mismo árbol de archivos, y vas a entender por qué la regla del proyecto existe.

Necesita de esta fase tres cosas exactas: el `CoreModule` donde vive `HttpClientModule` (que la Fase 2 va a reemplazar por `provideHttpClient`), las rutas que hay que proteger, y el `AuthModule` como séptimo feature. Sin este esqueleto, un guard no tendría nada que guardar.

> **La señal de que quedó bien:** cuando alguien te pide una pantalla nueva y sabes, sin abrir un solo archivo, qué cuatro archivos vas a crear y en qué carpeta va cada uno.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-01 -m "F1 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 01: …`) y los de ejercicio su
> número (`fase 01 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f01/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Y comprueba de paso que `git tag` sigue listando `fase-00`: el ejercicio 30 lo
> necesita, y es el único sitio donde el hola mundo que borraste hoy sigue
> existiendo.

---

## 📌 Pendientes sugeridos

- **Las fuentes de Google en `index.html`.** El schematic de Material las añade y funcionan, pero atan cada carga a un tercero. Servirlas desde el propio contenedor es trabajo de la **Fase 13**, que ya toca `index.html` y nginx. Hoy queda como ejercicio 🔥.
- **El theming de Material.** Tema prefabricado hoy, `define-palette` y densidad en la **Fase 6**, con **A01** como referencia. Si alguien toca la paleta antes de la Fase 6, se contradicen dos fases.
- **Mensajes de error en español.** Esta fase fija la regla —un `throw new Error` o un `console.error` va dirigido a otro desarrollador, así que se escribe en español, como los comentarios—. Conviene añadirla explícitamente a `guia-de-estilo-y-convenciones.md` §5, donde hoy sólo se habla de comentarios y de textos de interfaz. → **Decisión de proyecto.**
- 🪦 **El `AuthModule` como séptimo feature, confirmado.** La Fase 2 lo creó como módulo de feature —no dentro de `core`—, así que la cuenta de diez módulos se sostiene y la Fase 5 convirtió uno dejando nueve. Sin acción pendiente.
- **`PreloadAllModules`** aparece como ejercicio 🔥 y merece dos párrafos en algún sitio con más contexto: es la decisión que separa "arranque rápido" de "navegación rápida". → **Fase 11**, que es donde se habla de rendimiento percibido.
- 🔥 **Un diagrama del árbol de inyectores** ayudaría en 5.7 y en el ejercicio 20. Va como pendiente de ilustración, no de contenido.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 02 | "Agregué la pantalla de activos, la ruta funciona pero sale en blanco" | UI | 🟢 |
