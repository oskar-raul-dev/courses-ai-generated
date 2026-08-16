# 🧩 Fase 05 — Standalone conviviendo con NgModules

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 5 de 14 · **6 horas**
> Depende de: Fase 4 (estado con servicios y `BehaviorSubject`) · Habilita: Fases 6 a 13
> Apéndices de apoyo: [A01 (Angular Material 16)](a01-material.md) · [A04 (`inject()](a04-inject-vs-constructor.md)` vs constructor)
> [Incidentes asociados](cuaderno-incidentes.md): 06, 07
> Estilo de esta fase: **mixto 🧬 y deliberado** — la convivencia *es* el tema

---

## 🎯 1. Propósito

Hasta aquí escribiste una aplicación de `NgModule` con piezas modernas enchufadas: un guard funcional, un interceptor funcional, un servicio de estado con `inject()`. Todas esas piezas entraron por la puerta de un módulo heredado y ninguna cambió la forma del edificio.

Hoy cambia. Vas a convertir **un** módulo de feature a standalone —`ClientsModule`, el que la Fase 6 necesita—, vas a dejar los otros nueve exactamente como están, y vas a escribir la regla que decide, para cada archivo que toques durante el resto del curso, en cuál de las dos generaciones se escribe el fix.

Y hoy se paga la deuda más vieja que arrastras: la del `SharedModule` de la Fase 1, esa que reexporta doce módulos de Material "por comodidad". Se paga con `ng build` delante y dos cifras anotadas, y el pago va a darte una sorpresa que vale más que la propia deuda.

Nada de esto es una migración. Una migración tiene fecha de fin y un módulo que queda vacío. Esto es lo otro: **aprender a mantener un repositorio que no va a terminar de migrarse nunca**, que es lo que te vas a encontrar el lunes.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `ClientListComponent` es standalone, declara sus propios `imports`, usa `OnPush`, y **`clients.module.ts` y `clients-routing.module.ts` ya no existen** en el repositorio.
- [ ] `/clients` sigue navegando igual que ayer y su chunk sigue siendo diferido: aparece en Network la primera vez que entras y ninguna vez más.
- [ ] `AssetsModule` —que sigue siendo un `NgModule` de 2021— renderiza un componente standalone dentro de su plantilla, sin declararlo.
- [ ] `SharedModule` reexporta **nueve** módulos de Material y no doce, y tienes las dos cifras de `main.js` escritas en `deuda.md`, con la fecha.
- [ ] Provocaste el `NullInjectorError` de un standalone y el de un `NgModule`, y puedes decir, mirando sólo la consola, cuál de los dos estás viendo.
- [ ] Rompiste el botón de "Nuevo cliente" quitando un `import`, y el build siguió pasando en verde.
- [ ] `git tag` lista `fase-05`.

---

## 🚫 3. Qué NO entra todavía

- **Convertir los otros nueve módulos** → no entra nunca en el cuerpo del curso. Queda como ejercicio 🔥 (el 25 y el 26) y como decisión de proyecto, y la sección 5.8 explica por qué.
- **`ClientStateService` y el CRUD de clientes** → Fase 6. Hoy la pantalla de clientes es un cascarón con la tabla montada y sin filas: lo que se convierte es la *estructura*, no el contenido.
- **`provideRouter` y `bootstrapApplication`** → no llegan a CertCore. `main.ts` sigue arrancando con `bootstrapModule(AppModule)` hasta la última fase, y en 5.4 vas a ver por qué eso no impide nada.
- **El control flow nuevo (`@if`, `@for`)** → Fase 12 lo nombra y **A11** lo proyecta. En Angular 16 no existe: aquí se escribe `*ngIf`.
- **El tema de Material** (paleta, densidad, tipografía) → Fase 6, con **A01** al lado. Hoy seguimos con el tema prefabricado de la Fase 1.
- **Signals** → siguen sin aparecer, y seguirán hasta la Fase 12.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

La Fase 6 va a construir la pantalla de clientes: una tabla, un formulario, un diálogo de confirmación. Antes de escribir la primera línea hay que contestar una pregunta que no es de estilo, aunque lo parezca: **¿esa pantalla se escribe como las cinco que ya tienes, o se escribe como el guard y el interceptor de la Fase 2?**

Contestar "como las que ya tienes" tiene un argumento fuerte: coherencia. Y tiene una consecuencia: dentro de ocho fases, cuando alguien mire el repositorio, va a encontrar código de 2025 escrito con las convenciones de 2021, sin ninguna nota que explique por qué, y va a asumir que el proyecto entero es viejo.

Contestar "como el guard" tiene el problema contrario: si cada quien moderniza lo que toca, en tres meses tienes archivos donde `constructor(private http: HttpClient)` convive con `inject(Router)` en la misma clase, y eso —lo dice la guía §6.1 y lo vas a comprobar hoy— **es peor que cualquiera de los dos estilos puros**.

La salida no es elegir un estilo: es elegir una **regla** y escribirla donde no se pueda ignorar.

> 🧭 **Regla del proyecto, la que ordena el resto del curso: código nuevo, estilo nuevo. Código heredado, se toca lo mínimo y en su propio estilo.** Un archivo nace en una generación y se queda ahí hasta que alguien decida convertirlo entero, en un commit que no hace ninguna otra cosa.

### Qué es realmente un componente standalone

La respuesta corta —y suficiente para hoy— es que **`standalone: true` mueve la declaración de dependencias del módulo al componente**. Donde antes un `NgModule` decía "estos tres componentes existen y para compilar sus plantillas hace falta Material y el router", ahora cada componente lo dice de sí mismo, en su propio decorador.

No hay magia nueva debajo. El compilador sigue necesitando exactamente lo mismo que necesitaba en 2021: saber, para cada etiqueta y cada atributo de una plantilla, si es un componente tuyo, una directiva, un pipe o HTML del navegador. Lo único que cambió es **quién se lo cuenta**.

Si vienes de backend, el paralelo que abre la puerta es el de bajar la unidad de compilación de tamaño: antes declarabas dependencias por paquete, ahora las declaras por clase. Donde el paralelo se rompe —y conviene saberlo antes de la sección 5— es que un `NgModule` nunca fue una unidad de carga: **quien decide qué se descarga junto es el router**, y eso no ha cambiado ni un milímetro hoy.

Hay dos consecuencias prácticas que vas a tocar con las manos:

**Nada viene gratis.** Un componente standalone no hereda `CommonModule`. Si su plantilla usa `*ngIf`, alguien tiene que importarlo — la directiva `NgIf` suelta, o el `CommonModule` entero. En un módulo de feature eso lo resolvía `SharedModule` para todos a la vez, y por eso nadie pensaba en ello.

**Lo que importas, lo pagas tú.** Y ésa es la mitad interesante de la fase: cuando el que importa es el componente, el bundler sabe exactamente quién usa qué, y la respuesta deja de ser "todos usan todo".

### ¿Nuevo o heredado? 🧬

El mismo componente, en las dos formas que vas a leer durante el resto del curso.

**Heredado — así está `ClientListComponent` hoy, y así se queda `AssetListComponent`**

```ts
// El componente no sabe nada de sí mismo: quién lo declara y qué necesita
// para compilar vive en clients.module.ts, en otro archivo.
@Component({
  selector: 'cc-client-list',
  templateUrl: './client-list.component.html',
})
export class ClientListComponent {
  constructor(private readonly router: Router) {}
}
```

*(El `Router` está sólo para que se vea la inyección; el archivo real de 5.2 no lo necesita todavía.)*

**Nuevo — así queda al terminar la sección 5.2**

```ts
@Component({
  selector: 'cc-client-list',
  standalone: true,
  // Todo lo que la plantilla necesita, en el propio archivo y a la vista.
  imports: [NgIf, MatButtonModule, MatIconModule, MatTableModule],
  templateUrl: './client-list.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ClientListComponent {
  private readonly router = inject(Router);
}
```

Cuál usar no se decide por gusto: se decide por **de quién es el archivo**. Si el archivo ya existía, es del estilo en el que nació y ahí se queda. Si el archivo lo estás creando tú hoy, es nuevo y se escribe nuevo. Y si el archivo existía pero decides convertirlo —hoy conviertes uno—, la conversión es un commit propio que no arregla ningún bug de paso. La comparación completa de `inject()` frente al constructor, incluido dónde `inject()` explota, está en **A04**.

> 📝 **Nota de migración.** Los componentes standalone llegaron en vista previa con Angular **14** (junio de 2022) y se estabilizaron en la **15**. CertCore nació en 2021 sobre Angular 12: cuando se escribió su estructura, esto no existía. Y cuando el equipo migró a 16 durante 2024, **no convirtió nada** — deliberadamente. Migrar de versión y migrar de estilo son dos proyectos distintos, con dos riesgos distintos y dos presupuestos distintos, y sólo hubo dinero para uno. Que el repositorio siga siendo de `NgModule` en 2025 no es negligencia: es la consecuencia normal de haber priorizado bien.

### Cómo se resuelve un provider, ahora que hay dos mundos

Aquí es donde la convivencia deja de ser cosmética y empieza a producir errores de verdad. Tres sitios, tres tiempos de vida.

**`providedIn: 'root'`** es el que ya usas para todo desde la Fase 4: una instancia por aplicación, viva hasta que se cierre la pestaña. Funciona igual en los dos mundos, y por eso `TemplateStateService` no se entera de nada de lo que pasa hoy. Cuando dudes, éste es el sitio.

**Los `providers` de una ruta** son nuevos para ti. Una ruta puede traer su propio inyector, y lo que registra ahí vive **mientras esa ruta esté activa** y desaparece cuando navegas fuera. Es la herramienta correcta para la configuración de una pantalla —cuántas filas por página, qué endpoint usa este listado— y la equivocada para el estado, porque un estado que se borra al navegar deja de ser estado compartido.

**Los `providers` de un componente** viven lo que vive cada instancia del componente. Dos instancias en pantalla, dos objetos distintos. Casi nunca es lo que quieres y de vez en cuando es exactamente lo que necesitas; el ejercicio 10 te hace verlo.

Y falta el puente. Un `NgModule` heredado puede llevar providers dentro —`CoreModule` lleva los suyos— y una ruta standalone no puede importar módulos, sólo registrar providers. Para eso existe **`importProvidersFrom(ModuloHeredado)`**: extrae los providers de un `NgModule` y los deja en el inyector de esa ruta. Es la costura oficial entre las dos generaciones, y como toda costura, tiene un mal uso obvio que vas a ver en 5.7.

⚠️ Y un detalle que sorprende a todo el mundo la primera vez: cuando un componente standalone importa un `NgModule` en su decorador, **no sólo trae sus directivas: también trae sus providers**, acotados a ese componente y a sus hijos. Por eso importar un módulo grande "para tener las directivas a mano" no es sólo caro en peso; también mueve de sitio cosas que creías registradas en el inyector raíz.

---

## 💻 5. Código mínimo con comentarios

### 5.1 Qué se convierte, y la foto de antes

Se convierte **`ClientsModule`**, y la razón cabe en una frase: es el módulo que la Fase 6 va a llenar, y convertir un módulo vacío cuesta una hora mientras que convertir uno lleno cuesta una semana. Los otros nueve —`core`, `shared`, `layout`, `dashboard`, `assets`, `templates`, `inspections`, `certificates` y `auth`— se quedan como están.

Antes de tocar nada, la foto. Los dos números que vas a comparar dentro de una hora salen de aquí:

```bash
# --named-chunks para que los chunks se lean; --stats-json para poder buscar
# dentro. Los dos flags los introdujo la pieza forense de la Fase 1.
ng build --named-chunks --stats-json
```

```
Initial chunk files   | Names         |  Raw size
main.js               | main          | 448.31 kB
styles.css            | styles        |  76.12 kB
polyfills.js          | polyfills     |  33.06 kB
                      | Initial total | 557.49 kB

Lazy chunk files      | Names             |  Raw size
clients-module.js     | clients-module    |   4.24 kB
assets-module.js      | assets-module     |   4.21 kB
templates-module.js   | templates-module  |  12.86 kB
…
```

Anota `main.js = 448.31 kB` en `deuda.md`, con la fecha. Tus números van a diferir de éstos —dependen de tu versión exacta de las dependencias y de qué escribiste en los ejercicios de las fases anteriores— y no importa en absoluto: **lo que se compara es tu antes contra tu después**, no tu máquina contra este documento.

💡 La columna que el CLI llama *Raw size* es el tamaño sin comprimir. El usuario descarga menos, porque el servidor comprime; la Fase 13 mira esa otra columna. Aquí comparamos la cruda porque es determinista y no depende de cómo esté configurado nginx.

### 5.2 `ClientListComponent`, ahora standalone

Éste es el archivo de la fase. Nace en la generación nueva, así que lleva las cuatro marcas del estilo nuevo a la vez: `standalone`, `imports` propios, `OnPush` e `inject()`.

```ts
// src/app/features/clients/client-list/client-list.component.ts
import { NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';

import { Client } from '../../../core/models/client.model';
import { EmptyStateComponent } from '../../../shared/empty-state/empty-state.component';
import { CLIENT_LIST_PAGE_SIZE } from '../client-list-page-size.token';

@Component({
  selector: 'cc-client-list',
  standalone: true,
  /**
   * Cinco entradas, y ni una más. Compara esta lista con lo que este mismo
   * componente recibía ayer a través de SharedModule: doce módulos de Material,
   * CommonModule entero y ReactiveFormsModule, de los cuales usaba tres.
   *
   * NgIf va suelto y no CommonModule: importar la directiva concreta es más
   * barato y, sobre todo, es documentación. Quien lea este decorador sabe que
   * la plantilla tiene un condicional y no tiene bucles ni pipes de formato.
   */
  imports: [NgIf, MatButtonModule, MatIconModule, MatTableModule, EmptyStateComponent],
  templateUrl: './client-list.component.html',
  // OnPush por defecto en todo lo nuevo. Con el estado de la Fase 4 —que
  // reemplaza el objeto en vez de retocarlo— es gratis y correcto.
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ClientListComponent {
  /**
   * Cuántas filas por página. NO viene de `providedIn: 'root'`: lo provee la
   * ruta de clientes, en 5.3. Si este componente se monta fuera de esa ruta,
   * revienta — y ese error es la pieza forense de hoy.
   */
  readonly pageSize = inject(CLIENT_LIST_PAGE_SIZE);

  /** Las columnas de la tabla, en el orden en que se leen. */
  readonly displayedColumns: readonly string[] = ['legalName', 'taxId'];

  /**
   * Vacío a propósito y sin pedir nada a nadie. El listado real llega en la
   * Fase 6 con ClientStateService y su `clients$ | async`; hoy lo que se
   * convierte es la estructura del módulo, no el contenido de la pantalla.
   */
  readonly clients: readonly Client[] = [];
}
```

```html
<!-- src/app/features/clients/client-list/client-list.component.html -->
<h2>Clientes</h2>

<!-- El botón está deshabilitado porque el alta es de la Fase 6. Deshabilitado
     y visible se lee mejor que ausente: la pantalla ya cuenta lo que va a
     hacer. -->
<button mat-raised-button color="primary" [disabled]="true">
  <mat-icon>add</mat-icon>
  Nuevo cliente
</button>

<table mat-table [dataSource]="clients" *ngIf="clients.length > 0">
  <ng-container matColumnDef="legalName">
    <th mat-header-cell *matHeaderCellDef>Razón social</th>
    <td mat-cell *matCellDef="let client">{{ client.legalName }}</td>
  </ng-container>

  <ng-container matColumnDef="taxId">
    <th mat-header-cell *matHeaderCellDef>NIT</th>
    <td mat-cell *matCellDef="let client">{{ client.taxId }}</td>
  </ng-container>

  <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
  <tr mat-row *matRowDef="let row; columns: displayedColumns"></tr>
</table>

<!-- Un componente standalone consumido por otro componente standalone: se
     importó arriba y se usa aquí. Sin módulo de por medio. -->
<cc-empty-state
  *ngIf="clients.length === 0"
  icon="business"
  message="Todavía no hay clientes cargados."
></cc-empty-state>

<p class="client-list-hint">Se mostrarán {{ pageSize }} clientes por página.</p>
```

```ts
// src/app/features/clients/client-list-page-size.token.ts
import { InjectionToken } from '@angular/core';

/**
 * Cuántos clientes muestra el listado por página. Es configuración de UNA
 * pantalla, así que vive en el inyector de esa ruta y no en el raíz. Cinco es
 * un número bajo a propósito: la semilla trae tres clientes y con veinticinco
 * por página el paginador de la Fase 6 no paginaría nunca.
 *
 * Fíjate en lo que NO lleva: no lleva `factory`. Con
 * `new InjectionToken<number>('…', { providedIn: 'root', factory: () => 25 })`
 * el token nunca fallaría… y tampoco te avisaría nunca de que estás montando
 * la pantalla fuera de su ruta. Aquí preferimos el error: un NullInjectorError
 * en desarrollo cuesta cinco minutos; una paginación silenciosamente distinta
 * en producción cuesta un ticket.
 */
export const CLIENT_LIST_PAGE_SIZE = new InjectionToken<number>('CLIENT_LIST_PAGE_SIZE');
```

**Detalles con intención**

- **`NgIf` y no `CommonModule`.** Las dos formas compilan. La primera dice qué usa la plantilla; la segunda dice "algo de `@angular/common`, vaya usted a saber". En un archivo que otro va a leer dentro de un año, esa diferencia es todo el valor.
- **`readonly` en `displayedColumns` y en `clients`.** Con `OnPush`, lo que dispara un repintado es que la referencia cambie. Declarar los arrays inmutables desde el primer día evita el reflejo de hacerles `push` — que es exactamente la 💸 que la Fase 4 dejó viva en `FeatureState<T>` y que la Fase 6 paga.
- **El componente no inyecta ningún servicio de estado.** No es un olvido ni una simplificación: `ClientStateService` lo escribe la Fase 6 y este archivo lo va a recibir entonces, en su propio commit.

**El patrón a memorizar**

> En un standalone, el decorador es la lista de la compra. Si algo se usa en la plantilla y no está en `imports`, no existe — y a veces Angular te lo dice y a veces no, que es lo que vas a ver en la sección 6.

### 5.3 Las rutas de clientes, sin módulo

`clients-routing.module.ts` desaparece y su contenido se convierte en lo que siempre fue por dentro: un array.

```ts
// src/app/features/clients/clients.routes.ts
import { Routes } from '@angular/router';

import { CLIENT_LIST_PAGE_SIZE } from './client-list-page-size.token';

/**
 * El equivalente de ClientsRoutingModule, sin la ceremonia. No hay NgModule, no
 * hay forChild(): un array exportado, que es lo que RouterModule.forChild()
 * recibía y envolvía.
 */
export const CLIENTS_ROUTES: Routes = [
  {
    path: '',
    /**
     * Providers de ruta: viven mientras /clients esté activa y se van con
     * ella. Es el sitio correcto para la configuración de una pantalla.
     * Compáralo con TemplateStateService, que es `providedIn: 'root'` porque
     * su trabajo es justamente sobrevivir a la navegación.
     */
    providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }],
    // loadComponent en vez de loadChildren: el destino es un componente, no un
    // módulo. Sigue siendo un import() dinámico, así que sigue siendo un chunk
    // aparte y sigue siendo carga diferida.
    loadComponent: () =>
      import('./client-list/client-list.component').then((m) => m.ClientListComponent),
  },
];
```

Y se van dos archivos:

```bash
git rm src/app/features/clients/clients.module.ts
git rm src/app/features/clients/clients-routing.module.ts
```

🪦 **Retiro.** Los dos módulos cumplieron su función durante cuatro fases y salen del proyecto. No se comentan "por si acaso" ni se dejan sin usar: el tag `fase-04` los conserva enteros, y recuperarlos es un `git show`. Un archivo muerto en el árbol es peor que un archivo borrado, porque el siguiente que lo lea no va a saber si está muerto.

### 5.4 🧬 El punto de contacto: un router heredado apuntando a código nuevo

`AppRoutingModule` es de 2021 y no se moderniza. Se le cambia una ruta, en su propio estilo.

```ts
// src/app/app-routing.module.ts — sólo la ruta de clientes
  {
    path: 'clients',
    canActivate: [authGuard],
    // 🧬 PUNTO DE CONTACTO ENTRE GENERACIONES
    // RouterModule.forRoot() de 2021 cargando un array de rutas standalone de
    // 2025. loadChildren acepta las dos cosas: un NgModule con rutas dentro
    // (las otras seis features) o un array de rutas a secas (ésta). No hay que
    // convertir el router para empezar a convertir features, y eso es
    // exactamente lo que hace posible migrar de a poco.
    loadChildren: () => import('./features/clients/clients.routes').then((m) => m.CLIENTS_ROUTES),
  },
```

**Detalles con intención**

- **`main.ts` no se toca.** CertCore sigue arrancando con `platformBrowserDynamic().bootstrapModule(AppModule)`, y va a seguir así hasta la Fase 13. `bootstrapApplication` es otra conversión, mucho más cara, y no hace falta ninguna para tener componentes standalone: la aplicación no necesita ser standalone para alojarlos.
- **El guard no cambia.** `authGuard` ya era funcional desde la Fase 2, y le da exactamente igual si detrás hay un módulo o un componente. Las piezas funcionales de la Fase 2 fueron, sin que se dijera entonces, el ensayo de esta fase.
- **La ruta sigue siendo diferida.** Es lo primero que hay que comprobar y lo primero que se olvida.

**Prueba de fuego**

Abre Network con el filtro en `JS` y "Disable cache" activado. Navega a Clientes: aparece **una** petición nueva, y ahora se llama `clients-routes.js` en vez de `clients-module.js`. Vuelve al panel y entra otra vez: no aparece nada. Si el chunk **no aparece nunca**, no es que vaya muy rápido — es que alguien importó `ClientListComponent` desde `AppModule` o desde otro componente eager, y la carga diferida se volvió decorativa. Es el mismo bug de la Fase 1 con otra ropa, y es el ejercicio 20.

### 5.5 🧬 El otro sentido: un standalone dentro de un `NgModule` vivo

La convivencia tiene dos direcciones y la segunda es la que más se usa en la vida real, porque es la que no obliga a convertir nada. `AssetsModule` sigue siendo un módulo de 2021 y va a consumir un componente escrito hoy.

```ts
// src/app/shared/empty-state/empty-state.component.ts
import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';

/**
 * El bloque de "aquí no hay nada todavía", que ya aparece en dos pantallas y va
 * a aparecer en seis. Es standalone y vive en shared/ sin estar declarado en
 * SharedModule: desde hoy, la CARPETA shared y el MÓDULO SharedModule dejan de
 * ser la misma cosa. La carpeta significa "lo usa más de uno"; el módulo
 * significa "lo declara un NgModule", y eso último ya no hace falta.
 */
@Component({
  selector: 'cc-empty-state',
  standalone: true,
  imports: [MatIconModule],
  template: `
    <div class="empty-state">
      <mat-icon class="empty-state-icon">{{ icon }}</mat-icon>
      <p>{{ message }}</p>
    </div>
  `,
  styleUrls: ['./empty-state.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class EmptyStateComponent {
  /**
   * `required: true` es de Angular 16: el compilador exige el atributo en la
   * plantilla y el error llega en el build. Lleva inicializador porque
   * `strictPropertyInitialization` no sabe del `required` del decorador, y
   * porque en CertCore el aserto de no-nulo (`!`) no se usa — regla de la
   * Fase 0.
   */
  @Input({ required: true }) message = '';

  /** Nombre del icono de Material. Opcional, con un valor neutro por defecto. */
  @Input() icon = 'inbox';
}
```

```ts
// src/app/features/assets/assets.module.ts
import { NgModule } from '@angular/core';

import { EmptyStateComponent } from '../../shared/empty-state/empty-state.component';
import { SharedModule } from '../../shared/shared.module';
import { AssetListComponent } from './asset-list/asset-list.component';
import { AssetsRoutingModule } from './assets-routing.module';

@NgModule({
  declarations: [AssetListComponent],
  imports: [
    SharedModule,
    AssetsRoutingModule,
    // 🧬 PUNTO DE CONTACTO ENTRE GENERACIONES
    // Un componente standalone va en `imports`, JAMÁS en `declarations`. La
    // razón es que ya está declarado: se declaró a sí mismo. Ponerlo abajo da
    // un error explícito que vas a provocar en el ejercicio 6.
    EmptyStateComponent,
  ],
})
export class AssetsModule {}
```

```html
<!-- src/app/features/assets/asset-list/asset-list.component.html -->
<h2>Activos</h2>
<cc-empty-state icon="elevator" message="El inventario de activos llega en la Fase 6."></cc-empty-state>
```

**Detalles con intención**

- **`AssetListComponent` no se convirtió.** Sigue siendo heredado, sigue declarado, sigue sin `OnPush`, y consumir un componente moderno no lo contamina: la regla habla de cómo se escribe cada archivo, no de con quién se junta.
- **`EmptyStateComponent` no se exporta desde `SharedModule`.** Es la costumbre que hay que perder: un standalone lo importa quien lo usa, directamente. Meterlo en `SharedModule` para "que esté disponible" es reconstruir la deuda que estamos pagando en la sección siguiente.
- **Plantilla inline y no `templateUrl`.** Cuatro líneas de HTML no justifican un archivo. La regla del curso es la de siempre: si la plantilla cabe en la pantalla junto al código, mejor junta.

### 5.6 💸 La deuda del `SharedModule`, con factura

La Fase 1 dejó doce módulos de Material reexportados por comodidad y una promesa: *"se paga en la Fase 5, con el tamaño del bundle medido antes y después"*. Vamos a pagarla, y por el camino vas a descubrir que la promesa estaba mal formulada — que es la parte que de verdad importa.

**Primero, quién usa qué.** Recorre las cinco plantillas que existen hoy y anota los módulos de Material que aparecen de verdad:

- `shell.component.html` → toolbar, sidenav, list, icon, button
- `login.component.html` → card, form-field, input, button
- `not-found.component.html` → button
- `template-list.component.html` → progress-spinner, list
- `asset-list.component.html` y las otras cuatro pantallas placeholder → nada

Tres módulos de los doce **no los usa nadie**: `MatTableModule`, `MatDialogModule` y `MatSnackBarModule`. Están ahí porque en 2021 alguien pensó que harían falta. Y hacen falta — en la Fase 6 —, pero hoy son peso muerto que viaja en cada carga de la aplicación.

```ts
// src/app/shared/shared.module.ts — sólo la lista de Material
/**
 * 💸 DEUDA DE LA FASE 1, PAGADA A MEDIAS Y RECLASIFICADA
 *
 * Salen los tres que nadie usa. Vuelven en la Fase 6, pero importados por el
 * componente standalone que los use, así que viajarán en su chunk y no en el
 * inicial.
 *
 * Lo que NO se paga: los nueve que quedan siguen viajando enteros a los siete
 * módulos heredados que importan este archivo, y ninguno de los siete usa más
 * de cinco. Saldarlo exige tocar esos siete módulos, y eso
 * es una migración — precisamente lo que este curso decidió no hacer (5.8). La
 * deuda queda declarada, medida y viva, que es distinto de olvidada.
 */
const MATERIAL_MODULES = [
  MatButtonModule,
  MatCardModule,
  MatFormFieldModule,
  MatIconModule,
  MatInputModule,
  MatListModule,
  MatProgressSpinnerModule,
  MatSidenavModule,
  MatToolbarModule,
];
```

**La foto de después:**

```bash
ng build --named-chunks --stats-json
```

```
Initial chunk files   | Names         |  Raw size
main.js               | main          | 402.88 kB      ← eran 448.31 kB
styles.css            | styles        |  76.12 kB
polyfills.js          | polyfills     |  33.06 kB
                      | Initial total | 512.06 kB      ← eran 557.49 kB

Lazy chunk files      | Names             |  Raw size
clients-routes.js     | clients-routes    |  32.87 kB      ← eran 4.24 kB
assets-module.js      | assets-module     |   4.31 kB
…
```

**45.43 kB menos en el arranque, y el chunk de clientes casi ocho veces más grande.** Las dos cosas son la misma cosa: `MatTableModule` ya no viaja con todo el mundo, viaja con quien lo usa. Y `MatDialogModule` y `MatSnackBarModule` no viajan con nadie, porque hoy no los usa nadie.

Anota las dos cifras en `deuda.md` junto a las de la Fase 4. Ése es el recibo.

**Y ahora la sorpresa, que es la lección de verdad.**

Convierte mentalmente una segunda feature. Y una tercera. `main.js` **no va a bajar ni un kilobyte más**, y el motivo no está en las features: está en `LayoutModule`.

`AppModule` importa `LayoutModule`, así que `LayoutModule` es *eager*: viaja en el bundle inicial siempre. Y `LayoutModule` importa `SharedModule`. Por lo tanto, **todo lo que `SharedModule` reexporta está en `main.js` desde el primer día**, se use en una feature diferida o en veinte. Los chunks de las features se veían pequeños (4.24 kB) precisamente por eso: no contenían Material, porque Material ya estaba arriba.

> 🧠 **El modelo mental que te llevas:** un módulo compartido no cuesta caro por cuántas veces se importa, sino por **quién lo importa primero**. Un solo importador eager sube todo su contenido al bundle inicial, y a partir de ahí ninguna optimización río abajo se nota. Cuando te pidan "adelgazar el bundle", la primera pregunta no es qué es grande: es qué es *eager*.

Por eso la deuda se reclasifica en vez de cerrarse. Pagarla entera significaría que `LayoutModule` importe sus cinco módulos de Material directamente y que `SharedModule` deje de existir — y eso son siete módulos heredados tocados en una fase cuyo tema es no tocarlos. Queda como el ejercicio 28, que es donde tiene que estar.

**Prueba de fuego**

No te creas la tabla del build: pregúntale al `stats.json`. Busca dónde quedó cada módulo de Material antes y después.

```bash
# ¿En qué chunk vive la tabla de Material?
grep -o '"name":"[^"]*material_table[^"]*"' stats.json | sort -u
```

Antes de tocar `SharedModule`, la respuesta menciona `main`. Después, menciona `clients-routes`. Esa línea de salida es la deuda pagada, y es más difícil de discutir en una revisión que cualquier párrafo.

### 5.7 `importProvidersFrom`, y la trampa que trae puesta

Falta la costura que no has usado todavía: qué haces cuando una ruta standalone necesita los providers de un `NgModule` heredado.

```ts
// src/app/features/clients/clients.routes.ts — la variante, NO la versión final
import { importProvidersFrom } from '@angular/core';

export const CLIENTS_ROUTES: Routes = [
  {
    path: '',
    providers: [
      { provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 },

      // ✅ El uso legítimo: un NgModule cuyo valor son sus PROVIDERS, y que no
      // tiene equivalente en función. Se acota a esta ruta y muere con ella.
      // importProvidersFrom(SomeLegacyConfigModule),

      // ⚠️ EL USO QUE PARECE CÓMODO Y NO LO ES
      // importProvidersFrom(SharedModule)
      // No compila el error que esperarías: compila y funciona. Y no sirve
      // para lo que la gente lo usa — no aporta ni una directiva a la
      // plantilla, porque los providers no son directivas —, así que el
      // botón sigue sin estilo Y además acabas de arrastrar los providers de
      // nueve módulos de Material al inyector de esta ruta. Pagas el peso sin
      // recibir nada. Ejercicio 16, con el chunk medido.
    ],
    loadComponent: () =>
      import('./client-list/client-list.component').then((m) => m.ClientListComponent),
  },
];
```

**Detalles con intención**

- **`importProvidersFrom` trae providers, no declaraciones.** Es la confusión número uno de la convivencia. Las directivas y componentes de un `NgModule` se traen importando el módulo en el `imports` del *componente*; los providers se traen con esta función en el `providers` de la *ruta*. Son dos canales distintos y arreglan dos síntomas distintos.
- **La versión final de `clients.routes.ts` es la de 5.3**, sin `importProvidersFrom`. Este bloque está aquí para que reconozcas la función cuando la veas en un pull request, no para que la uses hoy: CertCore no tiene todavía ningún `NgModule` que valga sólo por sus providers.

### 5.8 La regla escrita, y los nueve que no se convierten

Quedan nueve módulos sin convertir: `core`, `shared`, `layout`, `dashboard`, `assets`, `templates`, `inspections`, `certificates` y `auth`. **No se convierten, ni hoy ni en el resto del curso.**

No es pereza ni falta de presupuesto de páginas. Es que el trabajo que este curso entrena es *mantener*, y en un sistema en mantenimiento la conversión de estilo compite —y pierde— contra cualquier cambio normativo, cualquier hotfix y cualquier reporte que el negocio necesita el jueves. Un plan de migración que nadie ejecuta es peor que no tener plan, porque genera un repositorio a medio convertir con dos convenciones y ninguna regla.

Lo que sí hace falta es la regla, y va escrita en el repositorio, no en la cabeza de nadie:

```md
<!-- deuda.md — sección nueva -->
## Convivencia standalone / NgModule

- Archivo nuevo → standalone, `inject()`, `OnPush`, `imports` propios.
- Archivo heredado → se toca lo mínimo y **en su propio estilo**. Modernizar
  mientras arreglas es cómo se rompen otras tres cosas.
- Convertir un archivo es una decisión explícita, en un commit que **no hace
  ninguna otra cosa**, y sólo cuando ese archivo ya se iba a reescribir entero.
- Un componente standalone se consume desde un NgModule por `imports`, nunca
  por `declarations`.
- Módulos convertidos: `clients` (Fase 5). Pendientes: los otros nueve, sin
  fecha y a propósito.
```

> 🧭 **La pregunta que decide, y que vas a usar en la Fase 6 diez veces:** no es "¿cuál de los dos estilos es mejor?", sino **"¿de quién es este archivo?"**. El archivo tiene dueño, el dueño tiene época, y la época decide la sintaxis. Tú sólo la respetas.

**El patrón a memorizar**

> La convivencia no se administra archivo por archivo con criterio propio: se administra con una regla de tres líneas que cualquiera del equipo puede citar y que un revisor puede aplicar sin discutir contigo.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** `NG8001: 'cc-empty-state' is not a known element.` en `client-list.component.html`.
**Causa:** el componente no está en el `imports` del decorador. En el mundo de los `NgModule` este mensaje tenía tres causas posibles (no declarado, no exportado, módulo no importado); en un standalone tiene **una**.
**Fix mínimo:** añadirlo a `imports`.
**Lo que importa:** el mensaje es idéntico y el diagnóstico es la mitad de largo. Es la primera ventaja práctica de la conversión, y no aparece en ninguna presentación sobre standalone.

**Síntoma:** `Component EmptyStateComponent is standalone, and cannot be declared in an NgModule. Did you mean to import it instead?`
**Causa:** el reflejo de 2021 — lo pusiste en `declarations` de `AssetsModule`.
**Fix mínimo:** moverlo a `imports`, una línea más abajo.
**Lo que importa:** un standalone ya está declarado, por sí mismo. Ésta es la clase de error que arregla el propio mensaje, y por eso conviene provocarlo una vez a propósito (ejercicio 6): así lo reconoces en un minuto cuando aparezca dentro de un log de CI de cuatrocientas líneas.

**Síntoma:** el botón "Nuevo cliente" se ve como un botón gris del navegador, sin sombra ni color. **El build pasa en verde y no hay nada en consola.**
**Causa:** falta `MatButtonModule` en los `imports` del standalone.
**Fix mínimo:** añadirlo.
**Lo que importa:** esto es lo peor que trae la convivencia y merece un párrafo aparte. `mat-raised-button` es un **atributo estático**, no un binding: para el compilador de plantillas es HTML válido que nadie reclama, así que no hay error, no hay warning, y los tests que no miran estilos pasan. La consecuencia es que **el bug llega a producción con todo en verde**, y llega como un ticket de diseño que nadie relaciona con un `import`. Es el incidente **06**.

**Síntoma:** `NullInjectorError: No provider for InjectionToken CLIENT_LIST_PAGE_SIZE!` al abrir una pantalla que monta `cc-client-list`.
**Causa:** el componente se montó fuera de la ruta `/clients`, que es quien provee el token.
**Fix mínimo:** o lo montas dentro de su ruta, o el token deja de ser de ruta y pasa a `root` con un `factory` por defecto — y las dos opciones son decisiones distintas, no la misma con otra letra.
**Lo que importa:** es el incidente **07**, y es la puerta de la pieza forense.

### Pieza forense de esta fase

Los dos `NullInjectorError` no se parecen, y saber cuál estás mirando te dice **dónde buscar** antes de abrir un solo archivo.

**El de un `NgModule`.** Provócalo quitando el `provideHttpClient(...)` de los `providers` de `CoreModule` —donde lo dejó la Fase 2— y pidiendo `HttpClient` desde un servicio:

```
ERROR NullInjectorError: R3InjectorError(AppModule)[HttpClient -> HttpClient]:
  NullInjectorError: No provider for HttpClient!
```

Entre paréntesis está **el módulo** desde el que Angular empezó a buscar: `AppModule`. Eso te dice que el inyector implicado es el del árbol de módulos, y que la respuesta está en algún `providers` o en algún `imports` de un `.module.ts`. Es una búsqueda de diez archivos.

**El de un standalone.** Provócalo montando `cc-client-list` desde la pantalla del dashboard:

```
ERROR NullInjectorError: R3InjectorError(Standalone[ClientListComponent])[InjectionToken CLIENT_LIST_PAGE_SIZE -> InjectionToken CLIENT_LIST_PAGE_SIZE]:
  NullInjectorError: No provider for InjectionToken CLIENT_LIST_PAGE_SIZE!
```

Entre paréntesis está **el componente**, con la palabra `Standalone` delante. Eso te dice otra cosa completamente distinta: que ningún módulo va a tener la respuesta, y que la pregunta correcta es *"¿por qué ruta llegó este componente a la pantalla?"*. La búsqueda no es en los `.module.ts`: es en los `providers` de las rutas y en el `imports` del propio decorador. Son dos archivos.

> 🩺 **Diagnóstico por síntoma.** Si el paréntesis dice `AppModule` o cualquier otro `…Module`, mira módulos. Si dice `Standalone[…]`, mira la ruta que montó el componente. Si dice `EnvironmentInjector`, estás en el inyector raíz y el token no lo provee nadie en ninguna parte. Tres paréntesis, tres sitios donde buscar, y ninguno de los tres requiere leer el stack trace entero.

> 📄 El recorrido completo, con los mensajes literales de los dos errores en dev y en un build de producción minificado, en `forense-fase-05.md`.

**🧨 Rompe a propósito**

Dos roturas seguidas en `client-list.component.ts`, y la comparación entre ambas es toda la lección de hoy.

1. **Quita `NgIf` de los `imports`** y compila. Angular 16 te da un error explícito y con nombre propio: `NG8103: The *ngIf directive was used in the template, but neither the NgIf directive nor the CommonModule was imported.` Te dice el problema, el archivo y la solución.
2. **Vuelve a ponerlo, quita ahora `MatButtonModule`** y compila. **No pasa nada.** Build verde, consola limpia, aplicación funcionando. Y el botón, gris.

La diferencia no es un capricho: `*ngIf` es una directiva **estructural** —el compilador tiene que resolverla para generar la vista, así que su ausencia es un error de compilación— mientras que `mat-raised-button` es un **selector de atributo** sobre un `<button>` que ya es HTML válido. Cuando no hay nadie que lo reclame, no hay nada roto que reportar.

> ⚠️ **Lo que te llevas de aquí:** en un componente standalone, olvidar un `import` de Material no falla; se ve feo. Y "se ve feo" no aparece en ningún pipeline. Es el motivo por el que la Fase 12 va a incluir un test que monta cada pantalla y busca la clase `mat-mdc-raised-button` en el DOM — y el motivo por el que ese test parece absurdo hasta que has vivido esto una vez.

---

## 🧪 7. Ejercicios (28)

**🟢 Fácil (1–8)**

1. Convierte `ClientListComponent` a standalone siguiendo 5.2 y borra `clients.module.ts` y `clients-routing.module.ts` con `git rm`. El build tiene que pasar y `/clients` seguir navegando. Commit: `fase 05: clients a standalone`.
2. Corre `ng build --named-chunks` antes y después de tocar `SharedModule`. Anota las dos cifras de `main.js` en `deuda.md` con la fecha, debajo de las de la Fase 4.
3. **Diagnóstico.** Con los dos `stats.json` (antes y después), localiza en cuál de los dos casos `material_table` vive en `main` y en cuál vive en `clients-routes`. Entrega las dos líneas de salida.
4. **Diagnóstico.** Quita `NgIf` de los `imports` del decorador. Copia el error literal, el código `NG…` y el número de línea que reporta. Vuelve a ponerlo.
5. **Diagnóstico.** Quita `MatButtonModule` de los `imports`. Describe en tres frases qué **no** ocurre: qué no dice el build, qué no dice la consola, y qué sí ve el usuario. Guárdalo: es la mitad del incidente 06.
6. **Diagnóstico.** Pon `EmptyStateComponent` en las `declarations` de `AssetsModule` en vez de en `imports`. Copia el error literal y explica en una frase por qué Angular puede decirte exactamente qué hacer.
7. Añade `cc-empty-state` a la pantalla de activos siguiendo 5.5, sin convertir `AssetListComponent`. Comprueba que `asset-list.component.ts` no cambió ni una línea.
8. **Diagnóstico.** Con Network abierto y "Disable cache" activado, confirma que el chunk de clientes cambió de nombre (`clients-module.js` → `clients-routes.js`) y que sigue descargándose una sola vez. Anota el tamaño transferido.

**🟡 Intermedio (9–16)**

9. Cambia el `useValue` de `CLIENT_LIST_PAGE_SIZE` a 10 en la ruta y comprueba que el texto de la pantalla lo refleja sin tocar el componente. Explica en dos frases qué acabas de demostrar sobre dónde vive la configuración de una pantalla.
10. Mueve el provider del token desde la ruta al `providers` del propio `@Component`. Comprueba que sigue funcionando y responde: si mañana hubiera dos `cc-client-list` en la misma pantalla, ¿cuántas instancias del valor habría en cada una de las dos versiones?
11. 🧬 **Estilo.** Llega el ticket: *"en la pantalla de Activos el título dice 'Activos' y el negocio lo quiere como 'Activos inspeccionables'"*. `AssetListComponent` es heredado. Escribe el fix, y justifica en tres líneas por qué no aprovechaste para convertirlo a standalone "ya que estabas".
12. 🧬 **Estilo.** Llega el ticket contrario: *"en Clientes hay que mostrar un icono junto al botón deshabilitado"*. `ClientListComponent` es nuevo. Escribe el fix y di qué habría estado mal si lo hubieras resuelto importando `SharedModule`.
13. **Diagnóstico.** Monta `<cc-client-list>` dentro de la plantilla del dashboard (heredado; tendrás que importarlo en `DashboardModule`). Captura el `NullInjectorError` completo y señala la parte del mensaje que te dice que el problema es de ruta y no de módulo.
14. **Diagnóstico.** Provoca el `NullInjectorError` de la variante `NgModule` (quita el `provideHttpClient(...)` de los `providers` de `CoreModule` y pide `HttpClient` desde un servicio). Pon los dos mensajes uno encima del otro y subraya las tres diferencias.
15. Convierte `NotFoundComponent` a standalone y quítalo de las `declarations` y los `exports` de `SharedModule`. Cuenta cuántos archivos tuviste que tocar y anótalo: es el costo real de convertir un componente compartido, y lo vas a necesitar en el ejercicio 26.
16. Añade `importProvidersFrom(SharedModule)` a los `providers` de la ruta de clientes. Comprueba dos cosas: que el botón **sigue** sin estilo si le quitaste `MatButtonModule`, y qué le pasa al tamaño del chunk `clients-routes`. Explica por qué la función no arregla lo que la gente cree que arregla.

**🟠 Difícil (17–23)**

17. `AssetsModule` va a necesitar `mat-table` en la Fase 6 y `SharedModule` ya no lo reexporta. Impórtalo donde toca, en el estilo que toca, y mide con `stats.json` en qué chunk cae ahora `material_table`. Justifica si el resultado te parece mejor o peor que antes.
18. **Diagnóstico.** Alguien deja un pull request donde `client-list.component.ts` importa `SharedModule` "porque así no hay que ir añadiendo cosas". El build pasa. Localiza el costo sin mirar el diff: sólo con `ng build --named-chunks` y `stats.json`. Entrega el número y la frase con la que rechazarías el pull request.
19. Escribe el post-mortem completo de ocho puntos del incidente **06** siguiendo `formato-cuaderno-incidentes.md` §7, con su par de tags `inc/06/<slug>-roto` / `-fix`. El punto 7 (prevención) es el difícil: ¿qué te habría avisado, y por qué ningún test de los que sabes escribir hoy lo habría hecho?
20. **Diagnóstico.** Importa `ClientListComponent` en el `imports` de `AppModule` —cosa que ahora es legal, porque un standalone puede importarse desde un módulo— y observa Network. El chunk `clients-routes.js` desaparece. Explica qué pasó, por qué la aplicación funciona exactamente igual, y cómo lo detectarías en una revisión de código.
21. 🧬 **Estilo.** El ticket dice: *"al cerrar sesión, la toolbar se queda un instante con el nombre del usuario anterior"*. El archivo es `shell.component.ts`, de 2021, con `constructor` y sin `OnPush`. Decide el estilo del fix, escríbelo, y contesta: ¿en qué caso concreto sí convertirías este archivo entero, y qué tendría que estar pasando para justificarlo?
22. **Diagnóstico.** Demuestra que el inyector de la ruta de clientes muere al navegar fuera. Pista: cambia el provider del token a `useFactory` con un `console.log` dentro, entra a Clientes, sal a Plantillas, vuelve. Entrega el número de veces que se imprimió y explica qué implicaría eso si en vez de un número el token proveyera un servicio con estado.
23. Reconstruye sin mirar la tabla de decisión de "¿dónde declaro esto?": componente nuevo, componente heredado, servicio compartido, configuración de una pantalla, directiva de Material. Cinco filas: qué es, dónde va, y qué error ves si te equivocas. Después compárala con las secciones 4 y 5.

**🔴 Muy difícil (24–28)**

24. Escribe el post-mortem completo de ocho puntos del incidente **07** siguiendo `formato-cuaderno-incidentes.md` §7, con su par de tags `inc/07/<slug>-roto` / `-fix`. Incluye en el punto 4 la línea exacta del mensaje de consola que te llevó a la causa, y explica por qué el mismo síntoma en un `NgModule` te habría hecho perder media hora más.
25. En una rama `spike/standalone-templates`, convierte `TemplatesModule` entero —que sí tiene contenido: `TemplateListComponent` con su estado, su spinner y su lista—. Mide `main.js` y el chunk antes y después. Después decide si mezclarías esa rama, y escribe el argumento en cinco líneas. No hay respuesta correcta; hay respuesta justificada.
26. Escribe el plan de migración de los nueve módulos restantes que este curso **no** va a ejecutar: en qué orden, con qué criterio, cuánto costaría cada uno usando el número que mediste en el ejercicio 15, y —lo más importante— cuál es el criterio de parada, es decir, qué tendría que ocurrir para decidir que el resto se queda como está para siempre.
27. **Diagnóstico.** El botón sin estilo del incidente 06 llegó a producción. Diseña la defensa: escribe el test de Jasmine que lo habría detectado (monta el componente, busca la clase que Material aplica), y explica por qué ese test es distinto de "probar que Material funciona". Guárdalo para la Fase 12.
28. **Diagnóstico.** Convierte mentalmente tres features más y explica, con `stats.json` en la mano, por qué `main.js` no baja ni un kilobyte. Después escribe el cambio que sí lo bajaría —qué archivo, qué línea— y calcula cuántos archivos habría que tocar para hacerlo sin romper nada. Ése es el número que justifica por qué la deuda quedó reclasificada en 5.6.

**🔥 Opcionales**

- 🔥 Corre el schematic oficial de migración sobre una copia del proyecto: `ng generate @angular/core:standalone`, en una rama `spike/schematic`. Compara su resultado con tu conversión a mano de `clients`: qué hizo igual, qué hizo distinto, y qué habría convertido que tú no querías convertir. Es la mejor forma de entender por qué esta fase convierte uno solo.
- 🔥 Escribe una regla de ESLint que falle cuando un componente standalone importe `SharedModule`. Es diez líneas de `no-restricted-imports` bien puestas y es la única forma de que la regla de 5.8 sobreviva a la tercera persona que se incorpore al equipo.
- 🔥 Convierte `LayoutModule` y `SharedModule` a la vez (el ejercicio 28 hecho de verdad) y mide `main.js`. Si el número te sorprende, escríbelo en `deuda.md`: es la clase de dato que gana discusiones.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v16.angular.io/guide/standalone-components — la guía de referencia de la fase. Cubre `imports` en el decorador, el consumo desde `NgModule` y las rutas con `loadComponent`.
- https://v16.angular.io/guide/standalone-migration — el schematic de migración y sus tres modos. Léela antes del ejercicio 🔥, no después.
- https://v16.angular.io/guide/hierarchical-dependency-injection — el árbol de inyectores completo. Es densa; para hoy basta con la sección de `EnvironmentInjector`.
- https://v16.angular.io/api/router/Route#providers — los providers de ruta, que es lo que hace funcionar 5.3.
- https://v16.angular.io/api/core/importProvidersFrom — corta y suficiente.
- https://v16.angular.io/cli/build — los flags `--stats-json` y `--named-chunks` de 5.1 y 5.6.
- https://v16.material.angular.io/components/table/overview — `mat-table` con Material 16 (MDC). ⚠️ Cualquier ejemplo de `mat-table` anterior a 2023 describe otro componente con el mismo nombre; el aviso permanente está en **A01**.

> ⚠️ **Cuidado con `angular.dev`.** Documenta Angular 17 en adelante y sus ejemplos de standalone usan `@if`, `@for` y `bootstrapApplication` como norma. Todo eso compila distinto —o no compila— en el stack de este curso. Si una búsqueda te lleva ahí, cambia el dominio por `v16.angular.io` a mano antes de leer.

**Video / apoyo**

- El anuncio original de los componentes standalone es del blog oficial de Angular, con la versión 14 (mediados de 2022). Búscalo por "standalone components developer preview" en el blog de Angular: sigue siendo la mejor explicación de *por qué* se hicieron, que es lo que ninguna guía de API cuenta.

> ⚠️ Los títulos y las URLs de artículos, charlas y videos cambian o desaparecen; verifícalos antes de citarlos en un documento de tu equipo. La documentación oficial versionada es la única referencia de este curso que se puede dar por estable.

**Orden de lectura sugerido:** la guía de standalone components antes de escribir la sección 5.2 — sólo sus tres primeras secciones. Durante el trabajo, la página de `Route#providers`, cuando llegues a 5.3. Y después de haber visto los dos `NullInjectorError` con tus ojos, la de inyección jerárquica: hasta ese momento es teoría, y a partir de ese momento explica algo que ya te pasó.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore tiene hoy las dos generaciones conviviendo a la vista y una regla escrita que decide en cuál se escribe cada fix. Un módulo convertido, nueve intactos, un componente standalone consumido desde un `NgModule` de 2021, un router heredado cargando un array de rutas moderno, y una deuda de cuatro fases pagada a medias con dos números en `deuda.md` que nadie puede discutir.

Y te llevas algo que no estaba en el guion: la diferencia entre un error que el compilador te cuenta y uno que sólo cuenta el usuario. `*ngIf` sin importar es un build roto; `mat-raised-button` sin importar es un botón feo en producción con todo el pipeline en verde. A partir de hoy, cuando conviertas un componente, la lista de `imports` no se revisa leyendo el `.ts`: se revisa mirando la pantalla.

La **Fase 6** es la que llena el cascarón. Va a escribir `ClientStateService` con el molde de la Fase 4, va a poner filas de verdad en esa `mat-table`, va a montar el alta y la edición con `FormGroup<T>` tipado, y va a devolver `MatDialogModule` y `MatSnackBarModule` al proyecto — pero importados por el componente que los usa, que es la mitad del pago de hoy convertida en costumbre. También va a saldar la 💸 de mutabilidad que la Fase 4 dejó viva, y lo va a hacer con `OnPush` puesto en las pantallas que hoy estrenamos: sin `OnPush`, esa deuda no se ve.

> **La señal de que quedó bien:** cuando abres un archivo del proyecto y, antes de leer una sola línea de lógica, ya sabes de qué año es y cómo se escribe el fix — y no sientes ninguna necesidad de arreglar el año.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-05 -m "F5 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 05: …`) y los de ejercicio su
> número (`fase 05 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f05/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Esta fase **retira código** y **paga una deuda**, y el tag es lo que sostiene
> las dos cosas. `clients.module.ts` y `clients-routing.module.ts` ya no están
> en el árbol: el único sitio donde existen enteros es `fase-04`, y
> `git show fase-04:src/app/features/clients/clients.module.ts` los devuelve
> cuando el ejercicio 25 o una discusión de equipo los necesiten. La factura del
> `SharedModule` se lee en `git diff fase-01 fase-05 -- src/app/shared/shared.module.ts`,
> y las dos cifras de `main.js` van en el mensaje del tag: dentro de ocho fases
> van a ser la única prueba de que aquello pesaba.

---

## 📌 Pendientes sugeridos

- 🪦 **La deuda 💸 del `SharedModule`, cerrada a medias y declarada.** La Fase 1 la anunció como "se paga en la Fase 5" a secas, y el build demuestra que eso era imposible tal como está montado el árbol: `LayoutModule` es eager e importa `SharedModule`, así que el contenido compartido vive en `main.js` pase lo que pase río abajo. Se pagó la parte medible (tres módulos fuera, 45.43 kB) y el resto quedó **reclasificado con su porqué** en 5.6. → Conviene ajustar la redacción del 💸 de la **Fase 1 §5.8** para que prometa lo que esta fase puede cumplir.
- 🪦 **Los dos "nueve" del curso, resueltos.** La Fase 4 hablaba de "las nueve features" y de "nueve servicios de estado" cuando el árbol cerrado tiene **siete** features (`auth` más las seis de la Fase 1), y el nueve de esta fase es otro —los NgModules sin convertir, 10 − 1—. Se corrigió la Fase 4 quitando los números de esas frases en vez de ajustarlos: cuántos servicios de estado acabe teniendo el curso depende de las Fases 9 y 11, y un número escrito hoy volvería a envejecer mal. → **Cerrado**, sin acción pendiente.
- **El incidente 07 lo nombran los prompts de la Fase 5 y de la Fase 6, y no hay que renumerar nada.** Lo **reserva** esta fase —junto con el 06, porque los dos son de convivencia y la propuesta §6 pide al menos dos de esa categoría— y la Fase 6 lo tiene **asociado**, que es distinto: trabaja sobre la misma pantalla y su enunciado le sirve. Los IDs 08 y 09 son de la Fase 7 y no se tocan. → **Aviso para el chat de la Fase 6**: no reserves un ID nuevo para el 07; hereda éste.
- **El test que detecta el botón sin estilo** (ejercicio 27) es material real de la **Fase 12**. Merece entrar en su temario como caso concreto y no como ejemplo genérico de test de componente: es el único test del curso que existe por una propiedad del compilador de plantillas y no por una regla de negocio. → **Aviso para el chat de la Fase 12.**
- **La regla de ESLint del ejercicio 🔥** (prohibir `SharedModule` dentro de un standalone) es la única forma de que la regla de 5.8 sobreviva a un equipo que rota. Encaja en el pipeline de calidad que monta la Fase 12, o en **A03** si se prefiere tratarlo como herramienta. → **Decisión de proyecto.**
- **`EmptyStateComponent` es el primer componente standalone compartido del curso**, y a partir de la Fase 9 va a haber más (chips de severidad, badges de vigencia). Conviene decidir ya si viven todos en `shared/` sin módulo o si nace una carpeta `ui/`. Cambiarlo cuando haya seis cuesta seis veces más. → **Decisión de proyecto**, barata hoy.
- 🔥 **Un diagrama del árbol de inyectores con las tres capas** —raíz, ruta, componente— cerraría de una vez el pendiente que dejaron abierto la Fase 1 (ejercicio 20) y la Fase 2. Es el mismo dibujo para las tres. Pendiente de ilustración, no de contenido.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 06 | "El botón de Nuevo cliente se ve gris y plano desde el martes, pero todo compila" | Convivencia de estilos 🧬 | 🟡 |
| 07 | "Metí el listado de clientes en el panel y la pantalla se queda en blanco" | Convivencia de estilos 🧬 | 🟡 |
