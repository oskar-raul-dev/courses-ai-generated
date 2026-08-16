# 🛠️ Fase 00 — Setup + hola mundo standalone

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 0 de 14 · **6 horas**
> Depende de: ninguna · Habilita: Fase 1 (estructura base con NgModules)
> Apéndices de apoyo: [A03 (Node y npm)](a03-node-npm.md) · [A04 (`inject()](a04-inject-vs-constructor.md)` vs constructor) · [A12 (Apple Silicon 🔥)](a12-arm64-m1.md)
> [Incidentes asociados](cuaderno-incidentes.md): 01
> Estilo de esta fase: **nuevo** (standalone + `inject()`)

Antes de empezar, si todavía no la leíste: [`00-historia-del-sistema.md`](00-historia-del-sistema.md). Son veinte minutos y explican por qué esta fase, la primera de todas, te enseña el estilo que CertCore **no** tiene en la mayor parte de su código.

---

## 🎯 1. Propósito

Dejar el entorno de CertCore levantado y verificable, y escribir el primer componente standalone que le hable a un endpoint: un formulario que solicita una inspección para un activo. No es un "hola mundo" decorativo — es el andamio sobre el que se apoyan las catorce fases siguientes, y es donde `strict: true` te va a dar el primer golpe, que es exactamente el punto.

El orden es deliberado y va contra el instinto. Vas a aprender el estilo de 2024 —standalone, `inject()`, `OnPush`— antes de tocar una sola línea de la herencia de 2021. Cuando la Fase 1 te entregue el `AppModule` con sus `declarations`, ya vas a tener con qué compararlo, y la pregunta que te hagas va a ser *"¿por qué está así?"* en lugar de *"¿así se hace Angular?"*.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `node -v` responde `v18.18.2` y `npm -v` responde `9.8.1`, con un `.nvmrc` en el repositorio que lo hace reproducible.
- [ ] `npm ls @angular/core` muestra `16.2.12` exacto, sin `^` ni sorpresas.
- [ ] `ng serve` levanta la aplicación en `http://localhost:4200` y **no existe ningún `app.module.ts`** en el proyecto.
- [ ] El stub del mock responde: `curl http://localhost:3000/inspection-requests` devuelve un array JSON.
- [ ] Llenas el formulario, envías, y la pestaña Network muestra un `POST /inspection-requests` con `201 Created` y el `id` asignado apareciendo en pantalla.
- [ ] `ng build --configuration production` genera `.js.map` junto a los bundles, y sabes abrir un stack trace minificado con ellos puestos.
- [ ] `git tag fase-00` está puesto sobre el commit que cierra la fase.

---

## 🚫 3. Qué NO entra todavía

- **Routing y `RouterModule`** → Fase 1. Hoy hay una sola pantalla y no hace falta un router para demostrar nada.
- **`NgModule`, `CoreModule`, `SharedModule`** → Fase 1. Es la herencia, y llega en la fase siguiente.
- **Autenticación, guards e interceptors** → Fase 2.
- **El mock server de verdad**, con su `db.json` completo y el middleware de caos → Fase 3. Lo de hoy es un stub de seis líneas que la Fase 3 tira a la basura sin ceremonia. No es deuda técnica: es andamio, y el andamio se retira cuando el edificio se sostiene solo.
- **Servicios de estado con `BehaviorSubject`** → Fase 4. Hoy el componente habla con `HttpClient` directamente, que es justo lo que la Fase 4 va a dejar de hacer.
- **Angular Material** → Fase 6 y A01. El formulario de hoy es HTML pelado, y se ve como se ve.
- **`environment.ts` y configuración por ambiente** → Fase 13. Hoy la URL del backend está horneada en el componente, a propósito 💸.
- **Pruebas** → Fase 12. El proyecto se genera con `--skip-tests` y no hay ni un `.spec.ts`, igual que CertCore hasta el día en que tú los escribas.

---

## 🧠 4. Concepto mínimo

### Cuatro archivos deciden cómo arranca una aplicación Angular

Vienes de backend, así que el arranque de un proceso no te asusta: hay un punto de entrada, se construye un contenedor de dependencias, se registran servicios y se levanta algo que escucha. Angular hace exactamente eso, y el punto de entrada es `main.ts`.

Lo que cambia entre generaciones es **qué recibe ese punto de entrada**. Durante diez años recibió un `NgModule`: una clase decorada que declaraba qué componentes existían, qué otros módulos importaba y qué proveedores registraba. Desde Angular 14 (experimental) y estable en la 15-16, puede recibir directamente un **componente standalone** más un objeto de configuración.

📝 **Nota de migración.** `bootstrapApplication` llegó en Angular 14 como parte de la API standalone, y se volvió estable en la 15. CertCore nació en 2021 sobre Angular 12, cuando la única forma era `platformBrowserDynamic().bootstrapModule(AppModule)`, y su `main.ts` **sigue siendo así hoy** — lo vas a ver en la Fase 1, sin tocarlo. Que exista una forma nueva no obliga a nadie a reescribir la vieja: obliga a saber leer las dos.

### 🧬 ¿Nuevo o heredado?

El mismo arranque, en las dos generaciones que conviven en el repositorio:

```ts
// ── HEREDADO (así arranca CertCore hoy — lo verás en la Fase 1) ────────────
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';

platformBrowserDynamic()
  .bootstrapModule(AppModule)
  .catch((error: unknown) => console.error(error));
```

```ts
// ── NUEVO (lo que escribes hoy, y todo lo que escribas de aquí en adelante) ─
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

bootstrapApplication(AppComponent, appConfig)
  .catch((error: unknown) => console.error(error));
```

**Cuál usarías.** El de arriba, si estás arreglando algo dentro de un proyecto que ya arranca así — no se toca el arranque de una aplicación en producción para ganar elegancia. El de abajo, en todo proyecto nuevo y en toda aplicación que ya haya migrado, que es el caso de este curso desde la Fase 5 en adelante.

> 🧭 **Regla del proyecto.** Código nuevo, estilo nuevo. Código heredado, se toca lo mínimo y en su propio estilo. Y el corolario, que es lo que de verdad importa: mezclar los dos estilos dentro de un mismo archivo es peor que cualquiera de los dos estilos puros.

### `ApplicationConfig`: el `providers` sin la clase alrededor

Cuando un `NgModule` registraba un servicio, lo hacía en su array `providers`. `ApplicationConfig` es ese array, solo, sin la clase ni el decorador. Ahí viven los `provide*` de Angular: `provideHttpClient()`, `provideRouter()`, `provideAnimations()`. Si vienes de Spring, es el equivalente a pasar de una clase de configuración anotada a una lista explícita de beans: la misma información, menos ceremonia y —esto es lo que de verdad cambia— **más fácil de seguir con la vista cuando algo no se inyecta**.

### `strict: true` y por qué se pone hoy y no después

Aquí hay una tentación fuerte y hay que matarla temprano: el primer `Object is possibly 'null'` aparece en la hora dos de este curso y es incómodo. Se puede apagar `strict` en el `tsconfig.json` y seguir. **No se hace, ni en un ejercicio, ni "sólo para este ejemplo".**

El motivo no es rigor por gusto. Una familia entera de bugs de CertCore —el hallazgo `critical` que no bloqueó la emisión, el certificado sin fecha de vencimiento, el `FormControl` que quedó huérfano al cambiar de plantilla— nace de la diferencia entre `null`, `undefined` y "el campo no vino". Con `strict` puesto, esa diferencia la señala el compilador. Sin él, la señala un cliente por teléfono.

### Mini-repaso: el genérico de `FormGroup`

Desde Angular 14 los formularios reactivos son genéricos. `FormGroup<T>` donde `T` es un objeto cuyos valores son `FormControl<...>`. En la práctica casi nunca escribes el tipo: `FormBuilder` lo infiere del literal que le pasas, y tu trabajo es que **infiera el tipo correcto**, que casi siempre significa decidir la nulabilidad de cada control.

Un `FormControl<string>` declarado con `nonNullable: true` nunca vale `null`: al hacer `reset()` vuelve a su valor inicial en vez de a `null`. Un `FormControl<string | null>` sí puede valer `null`, y entonces `null` tiene que **significar algo** en tu dominio. Los dos son correctos; elegir al azar es lo que no lo es.

> 📚 El detalle completo del tipado de formularios está en **A05**. Hoy alcanza con la distinción de arriba.

---

## 💻 5. Código mínimo con comentarios

### 5.1 El entorno, y cómo se verifica

```bash
# Fija la versión de Node para todo el repositorio.
echo "18.18.2" > .nvmrc

nvm install    # lee .nvmrc e instala esa versión exacta
nvm use        # la activa en esta terminal

node -v        # esperado: v18.18.2
npm -v         # esperado: 9.8.1  (viene dentro de Node, no se instala aparte)
```

> ⚠️ **La versión de Node no es aproximada, y el motivo es npm.** Cada versión de Node empaqueta una versión concreta de npm: la 18.18.2 trae npm 9.8.1, y la 18.19.0 —que parece la misma cosa un parche más adelante— trae npm **10**. El curso está fijado en npm 9.x (`alcance-del-proyecto.md` §9) porque es el que estaba vigente cuando CertCore se migró y porque npm 10 cambió cómo resuelve algunas `peerDependencies`. Si `npm -v` te responde `10.x`, no bajes npm a mano: estás en la versión de Node equivocada. `nvm use` y vuelve a mirar.

> 🧠 Esto es, en pequeño, el problema entero del curso. "Node 18" no es una versión, es una familia, y dos miembros de la misma familia te instalan gestores de paquetes distintos que resuelven el mismo `package.json` de formas distintas. Por eso el `.nvmrc` lleva los tres números y no dos.

> 📚 Qué hace exactamente `npm ci` frente a `npm i`, cómo se lee un lockfile v3, y cómo comparar tu árbol de dependencias contra el del curso: **Apéndice A03**.

Si estás en un Mac con chip M, todo lo anterior funciona nativo y sin trucos. Lo que sí necesita atención en Apple Silicon es la arquitectura de la imagen de la Fase 13, y eso vive en **A12** 🔥 — no lo necesitas hoy.

### 5.2 Generar el proyecto

```bash
# Se usa npx con la versión exacta para no depender de qué CLI tengas instalado
# globalmente, que es la primera fuente de "a mí me funciona".
npx @angular/cli@16.2.12 new certcore \
  --prefix=cc \
  --style=scss \
  --routing=false \
  --skip-tests
```

**Detalles con intención**

- `--prefix=cc` — todos los selectores del proyecto van a ser `<cc-algo>`. Es la convención de CertCore desde 2021 y la vas a ver en cada plantilla del curso. El `app-` por defecto se usa en tutoriales; un sistema con nombre propio usa el suyo, y eso ayuda cuando un día importas un componente de una librería ajena y necesitas saber de un vistazo qué es tuyo.
- `--style=scss` — Angular Material 16 se tematiza con Sass (`define-palette`, tokens), y eso llega en la Fase 6 con A01. Elegir `css` hoy significa migrar después.
- `--routing=false` — el router entra en la Fase 1, junto con los módulos de feature. Hoy no hay dónde navegar.
- `--skip-tests` — **cero specs, a propósito.** CertCore no tiene una sola prueba hasta que la Fase 12 las escribe desde nada. Generar archivos `.spec.ts` vacíos que nadie va a mirar durante once fases es peor que no tenerlos: da la falsa sensación de que hay una red debajo.
- **No hay `--standalone`.** En Angular 16 ese flag existe pero está en `false` por defecto, así que el CLI genera un `AppModule`. Lo vamos a borrar a mano en 5.4, y ese ejercicio de borrarlo vale más que la comodidad del flag: vas a ver exactamente qué archivo hacía qué.

### 5.3 Fijar las versiones y el `tsconfig.json`

El CLI genera rangos con `^`. El curso los fija exactos: es lo que hace que el material siga funcionando dentro de dos años y que tu error sea el mismo error que describe el texto.

```jsonc
// package.json — sólo las líneas que cambian
{
  "engines": {
    "node": "18.18.2",
    "npm": "9.8.1"
  },
  "dependencies": {
    "@angular/common": "16.2.12",
    "@angular/compiler": "16.2.12",
    "@angular/core": "16.2.12",
    "@angular/forms": "16.2.12",
    "@angular/platform-browser": "16.2.12",
    "rxjs": "7.8.1",
    "tslib": "2.6.2",
    "zone.js": "0.13.3"
  },
  "devDependencies": {
    "@angular-devkit/build-angular": "16.2.12",
    "@angular/cli": "16.2.12",
    "@angular/compiler-cli": "16.2.12",
    "typescript": "5.1.6"
  }
}
```

```bash
rm -rf node_modules package-lock.json
npm install
npm ls @angular/core     # debe responder exactamente 16.2.12
```

```jsonc
// tsconfig.json — el bloque que importa
{
  "compilerOptions": {
    // Modo estricto completo. No se apaga: media docena de los bugs de este
    // curso sólo son visibles con esto puesto.
    "strict": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "target": "ES2022",
    "module": "ES2022",
    "lib": ["ES2022", "dom"]
  },
  "angularCompilerOptions": {
    // El compilador de plantillas también verifica tipos. Sin esto, un
    // {{ inspection.assetId }} mal escrito falla en runtime y no en el build.
    "strictTemplates": true,
    "strictInjectionParameters": true,
    "strictInputAccessModifiers": true
  }
}
```

> 🧠 `strictTemplates` es el que más gente apaga y el que más sirve en un sistema como éste. Una plantilla de Angular es código; que el compilador la mire con los mismos ojos que mira el `.ts` es la diferencia entre enterarte en el build y enterarte en producción.

### 5.4 La conversión a standalone, paso a paso

Tres movimientos. El primero es borrar.

```bash
rm src/app/app.module.ts
```

El segundo es crear la configuración de la aplicación:

```ts
// src/app/app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideHttpClient } from '@angular/common/http';

// Esto es el array `providers` que antes vivía dentro del @NgModule, ahora
// suelto. Cada `provide*` registra una pieza de Angular en el inyector raíz.
export const appConfig: ApplicationConfig = {
  providers: [
    // Sin esto, cualquier inject(HttpClient) explota con NullInjectorError.
    // En la Fase 2 esta misma línea crece: provideHttpClient(withInterceptors([...])).
    provideHttpClient(),
  ],
};
```

Y el tercero es reescribir el punto de entrada:

```ts
// src/main.ts
import { bootstrapApplication } from '@angular/platform-browser';

import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

// El componente raíz ya no se "declara" en ningún lado: se arranca directo.
bootstrapApplication(AppComponent, appConfig)
  // `unknown` y no `any`: lo que llega acá puede ser cualquier cosa y hay que
  // tratarlo como tal. Con strict puesto, `any` sería hacer trampa.
  .catch((error: unknown) => console.error(error));
```

**Prueba de fuego**

Corre `ng serve` y confirma que arranca. Después busca en todo el proyecto la cadena `NgModule`:

```bash
grep -rn "NgModule" src/
```

Cero resultados. Si aparece alguno, quedó un archivo generado por el CLI que no borraste, y la Fase 1 te va a confundir el doble cuando ese `NgModule` de más se mezcle con el que sí toca escribir.

### 5.5 El modelo del dominio

Primer archivo de dominio de CertCore. Fíjate en la nulabilidad: no es adorno.

```ts
// src/app/inspection-request.model.ts

/**
 * Solicitud de inspección: lo que un cliente pide antes de que exista la
 * inspección propiamente dicha. Es la antesala del estado `requested` de la
 * máquina de estados (Fase 6 en adelante).
 */
export interface InspectionRequest {
  /** Identificador del activo, tal como lo usa el negocio: "ASC-CENTRAL-03". */
  readonly assetId: string;

  /**
   * Fecha deseada, ISO 8601 CON offset explícito (-05:00), nunca con Z ni
   * suelta. Media docena de tickets de CertCore nacieron de una fecha sin
   * offset; la regla se aplica desde el primer archivo.
   */
  readonly requestedFor: string;

  /**
   * `null` significa "el cliente no dejó nota". Es una ausencia real y
   * declarada, no un campo que nadie se molestó en decidir — por eso es
   * `string | null` y no `note?: string`.
   */
  readonly note: string | null;
}

/** Lo que devuelve el servidor: lo mismo, más el id que él asigna. */
export interface CreatedInspectionRequest extends InspectionRequest {
  readonly id: number;
}
```

**Detalles con intención**

- `note: string | null` frente a `note?: string` — el primero dice "puede no haber nota, y eso es un caso previsto". El segundo dice "puede que la propiedad ni exista", que en un modelo de dominio casi siempre significa que nadie lo pensó. La distinción se sostiene en todo el curso.
- No hay `status` en el modelo. La máquina de estados existe (`requested → scheduled → …`) y la vas a construir, pero **el stub de hoy no la implementa**: json-server guarda lo que le mandes y no asigna nada. Modelar un campo que el mock no llena sería prometer algo que no puedes abrir. La Fase 3 monta el mock de verdad y ahí sí.

### 5.6 El componente raíz

```ts
// src/app/app.component.ts
import { ChangeDetectionStrategy, Component } from '@angular/core';

import { InspectionRequestFormComponent } from './inspection-request-form.component';

@Component({
  selector: 'cc-root',
  // Standalone: el componente declara lo que usa, en vez de esperar que un
  // módulo se lo provea. Es el cambio conceptual más grande de Angular 15-16.
  standalone: true,
  imports: [InspectionRequestFormComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <header>
      <h1>CertCore</h1>
      <p>Inspecciones y certificaciones</p>
    </header>

    <main>
      <cc-inspection-request-form />
    </main>
  `,
})
export class AppComponent {}
```

**Detalles con intención**

- `OnPush` desde el primer componente. Es la estrategia por defecto del código nuevo de CertCore, y ponerla desde hoy hace que el primer tropiezo con ella llegue en la hora cuatro de este curso y no en la Fase 11 con un dashboard encima. Vas a tropezar en 5.7, y está previsto.
- `<cc-inspection-request-form />` con la sintaxis auto-cerrada, que Angular 16 soporta en plantillas. Los textos visibles van literales en español, sin claves de traducción: CertCore es monolingüe y lo es a propósito.

### 5.7 El formulario, el POST y la deuda

Éste es el archivo grande de la fase. Va entero y después lo desarmamos.

```ts
// src/app/inspection-request-form.component.ts
import { HttpClient } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Component,
  inject,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';

import {
  CreatedInspectionRequest,
  InspectionRequest,
} from './inspection-request.model';

/**
 * 💸 DEUDA TÉCNICA INTENCIONAL
 * La URL del backend está horneada en el código fuente. Lo correcto es leer la
 * configuración en tiempo de ARRANQUE, no de compilación, para que la misma
 * imagen sirva en UAT y en PROD sin recompilar.
 * SE PAGA EN LA FASE 13, que es la tesis del curso. Hasta entonces convives
 * con ella a propósito: cuando llegue el momento de pagarla vas a tener trece
 * fases de código apuntando a esta constante, que es exactamente el tamaño
 * real del problema en un sistema de verdad.
 */
const API_BASE_URL = 'http://localhost:3000';

/** Estado de la única operación de esta pantalla. */
type SubmissionStatus = 'idle' | 'sending' | 'sent' | 'failed';

@Component({
  selector: 'cc-inspection-request-form',
  standalone: true,
  // Sin ReactiveFormsModule acá, [formGroup] no existe para esta plantilla.
  // Un componente standalone importa lo que usa, y nada más.
  imports: [ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './inspection-request-form.component.html',
})
export class InspectionRequestFormComponent {
  // inject() en vez de constructor: el estilo del código nuevo. La comparación
  // completa con la inyección por constructor está en el apéndice A04.
  private readonly formBuilder = inject(FormBuilder);
  private readonly http = inject(HttpClient);
  private readonly changeDetectorRef = inject(ChangeDetectorRef);

  protected status: SubmissionStatus = 'idle';
  protected createdId: number | null = null;

  /**
   * El tipo del FormGroup se infiere del literal. Los dos primeros controles
   * son nonNullable porque un activo sin identificar o una solicitud sin fecha
   * no significan nada; el tercero sí admite null, porque "sin nota" es un
   * caso legítimo del negocio.
   */
  protected readonly form = this.formBuilder.group({
    assetId: this.formBuilder.control('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    requestedFor: this.formBuilder.control('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    note: this.formBuilder.control<string | null>(null),
  });

  protected submit(): void {
    if (this.form.invalid) {
      // Sin esto, los mensajes de error no aparecen: el usuario que le da a
      // "Enviar" sin tocar nada no ha "tocado" ningún campo todavía.
      this.form.markAllAsTouched();
      return;
    }

    // getRawValue() devuelve el objeto tipado y completo. Con controles
    // deshabilitados, value los omitiría y getRawValue no: por eso es el que
    // usamos siempre que armamos un payload.
    const payload: InspectionRequest = this.form.getRawValue();

    this.status = 'sending';

    this.http
      .post<CreatedInspectionRequest>(`${API_BASE_URL}/inspection-requests`, payload)
      .subscribe({
        next: (created) => {
          this.createdId = created.id;
          this.status = 'sent';
          this.form.reset();
          // OnPush no se entera de que estas propiedades cambiaron: el cambio
          // vino de un callback asíncrono, no de un evento de la plantilla.
          // Desde la Fase 4 esto se resuelve con el pipe async; hoy, a mano.
          this.changeDetectorRef.markForCheck();
        },
        error: (error: unknown) => {
          // unknown, no any: acá puede llegar un HttpErrorResponse, un error de
          // red o cualquier cosa. Se estrecha antes de asumir su forma.
          this.status = 'failed';
          this.changeDetectorRef.markForCheck();
          console.error('Falló la solicitud de inspección', error);
        },
      });
  }
}
```

```html
<!-- src/app/inspection-request-form.component.html -->
<!-- Textos literales en español: CertCore es monolingüe (guía §5.1). -->
<h2>Solicitar una inspección</h2>

<form [formGroup]="form" (ngSubmit)="submit()">
  <label for="assetId">Activo</label>
  <input id="assetId" formControlName="assetId" placeholder="ASC-CENTRAL-03" />
  <!-- Acceso tipado al control. Nada de form.get('assetId'), que devolvería
       AbstractControl | null y obligaría a lidiar con un null que no existe. -->
  <p *ngIf="form.controls.assetId.touched && form.controls.assetId.invalid">
    Indica el activo que se va a inspeccionar.
  </p>

  <label for="requestedFor">Fecha deseada</label>
  <input id="requestedFor" type="date" formControlName="requestedFor" />

  <label for="note">Nota (opcional)</label>
  <textarea id="note" formControlName="note"></textarea>

  <button type="submit" [disabled]="status === 'sending'">
    {{ status === 'sending' ? 'Enviando…' : 'Solicitar inspección' }}
  </button>
</form>

<p *ngIf="status === 'sent' && createdId !== null">
  Solicitud registrada con el número {{ createdId }}.
</p>

<p *ngIf="status === 'failed'">
  No se pudo registrar la solicitud. Revisa la consola y la pestaña Network.
</p>
```

> ⚠️ La plantilla usa `*ngIf`, no `@if`. El control flow con `@if/@for` llegó en Angular **17** y aquí no existe: si lo escribes, el compilador de la 16 lo trata como texto y no vas a entender por qué tu condición se renderiza literalmente en pantalla. Es de los errores más frecuentes al copiar ejemplos de `angular.dev`. Para usar `*ngIf` en un componente standalone hay que importar `NgIf` (o `CommonModule`) — añádelo a `imports`; el ejercicio 5 te hace tropezar con eso a propósito.

**Detalles con intención**

- **`ChangeDetectorRef.markForCheck()` y no cambiar a `Default`.** Es la primera lección de `OnPush` y conviene sufrirla ahora: con `OnPush`, Angular sólo revisa el componente cuando cambia un `@Input`, se dispara un evento de su plantilla, o alguien lo marca a mano. Un `subscribe` no es ninguna de las tres. Cambiar la estrategia a `Default` "arregla" el síntoma y te compra un dashboard lento en la Fase 11.
- **`status` como unión de literales y no como tres booleanos.** `isSending`, `isSent` e `isFailed` admiten el estado imposible de estar los tres en `true`. La unión no. Es el mismo reflejo que aplicas en backend con las máquinas de estados del dominio.
- **`protected` en vez de `public` para lo que usa la plantilla.** Angular puede leer miembros `protected` desde la plantilla desde la v14, y así queda explícito que ese miembro no es API del componente para nadie más.

**El patrón a memorizar**

> Con `OnPush`, todo lo que cambie fuera de un evento de la plantilla necesita que alguien avise. Hoy avisas tú con `markForCheck()`; desde la Fase 4 avisa el pipe `async`, que hace lo mismo sin que te acuerdes de hacerlo — y por eso es el que gana.

### 5.8 El stub del mock

Seis líneas. **No es el mock del curso**: es un andamio para que el POST de hoy tenga contra qué hablar. La Fase 3 escribe el `db.json` completo, el servidor de Express y el middleware de caos, y esto desaparece.

```json
{
  "inspection-requests": [
    {
      "id": 1,
      "assetId": "ASC-CENTRAL-03",
      "requestedFor": "2024-03-20T09:00:00-05:00",
      "note": null
    }
  ]
}
```

```bash
# Guárdalo como mock/db.json y levántalo en otra terminal:
npx json-server@0.17.4 --watch mock/db.json --port 3000
```

**Prueba de fuego**

Con las dos terminales corriendo (`ng serve` y json-server), llena el formulario con `ASC-CENTRAL-03`, envía, y **mira las dos cosas a la vez**: la pantalla debería decir "Solicitud registrada con el número 2", y `mock/db.json` en tu disco debería tener ahora dos entradas. Si la pantalla dice que sí y el archivo no cambió, no estás hablando con el servidor que crees.

Y ahora la parte incómoda: abre el `db.json` y mira el `requestedFor` que guardó. El `<input type="date">` entrega `"2024-03-20"` a secas, sin hora y sin offset. Lo que dice el modelo —ISO con `-05:00` explícito— **no es lo que estás mandando**. Es un bug real, y está puesto a propósito: el ejercicio 16 te hace arreglarlo, y la Fase 10 te cobra la factura completa cuando un certificado venza "ayer" para el servidor y "hoy" para el usuario.

### 5.9 El primer `Object is possibly 'null'`

Escribe esto dentro de `submit()` y compila:

```ts
// ❌ No compila: form.get() devuelve AbstractControl<unknown> | null
const assetId = this.form.get('assetId').value;
//              ~~~~~~~~~~~~~~~~~~~~~~~~ error TS18047: 'this.form.get(...)'
//                                        is possibly 'null'.
```

TypeScript tiene razón: `get('assetId')` busca por una cadena, y una cadena puede estar mal escrita, así que el tipo de retorno contempla el `null`. Hay tres respuestas y sólo una es la del curso.

```ts
// Respuesta 1 — el aserto de no-nulo. ❌ En este curso, no.
const assetId = this.form.get('assetId')!.value;
// Le dices al compilador "confía en mí". Si mañana alguien renombra el control,
// esto compila igual y falla en runtime. Cambiaste un error de build por un
// ticket. El `!` no se usa en el código de CertCore.

// Respuesta 2 — el encadenamiento opcional. Correcto, pero contagia el null.
const assetId = this.form.get('assetId')?.value;
// Ahora assetId es `unknown`, y todo lo que venga después tiene que estrecharlo.
// Sirve cuando el null es un caso real; acá no lo es.

// Respuesta 3 — acceso tipado. ✅ La del curso.
const assetId = this.form.controls.assetId.value;
// `controls` está tipado por el genérico del FormGroup: la propiedad existe o
// no compila, y el tipo es `string` porque el control es nonNullable. No hay
// null que manejar porque no hay null.
```

**El patrón a memorizar**

> Cuando `strict` te obliga a manejar un `null`, la primera pregunta no es *"¿cómo lo callo?"* sino *"¿este `null` puede ocurrir de verdad?"*. Si no puede, el problema es la API que elegiste — no el compilador.

Vas a ver el mismo error en otro disfraz cuando toques el DOM: `document.querySelector('#assetId').focus()` falla exactamente igual, y ahí el `null` **sí** es real, porque el elemento puede no estar montado.

### 5.10 Source maps y el build de producción

```jsonc
// angular.json → projects.certcore.architect.build.configurations.production
{
  "production": {
    "budgets": [ /* ...lo que generó el CLI... */ ],
    "outputHashing": "all",
    // Por defecto en producción esto es false y el stack trace queda ilegible.
    // Los .map se generan como archivos aparte: el bundle que sirve nginx no
    // crece, y tú puedes depurar lo que ya está desplegado.
    "sourceMap": {
      "scripts": true,
      "styles": false,
      "vendor": false,
      "hidden": false
    }
  }
}
```

```bash
ng build --configuration production
ls -la dist/certcore/*.map     # deben existir
```

**Prueba de fuego**

Sirve el build (`npx http-server dist/certcore -p 8080`), abre la aplicación, apaga json-server y envía el formulario. En la consola te va a aparecer el error. Con `sourceMap` en `false`, el stack trace apunta a `main.a1b2c3.js:1:48210` y no te dice nada. Con los mapas puestos, apunta a `inspection-request-form.component.ts:74`, que es la línea del `subscribe`. La diferencia entre esas dos tardes de trabajo es este bloque de JSON.

> 💡 En un despliegue real la pregunta no es *si* generar los mapas, sino *a quién se los sirves*. `"hidden": true` los genera pero no los referencia desde el bundle: tú los tienes para depurar, un curioso con DevTools no. La Fase 13 vuelve sobre esto con nginx delante.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** `ng serve` muere con `The Angular CLI requires a minimum Node.js version of v16.14`, o con un `SyntaxError` incomprensible dentro de `node_modules`.
**Causa:** la terminal está usando otra versión de Node. Pasa siempre al abrir una pestaña nueva.
**Fix mínimo:** `nvm use` en esa terminal y reintentar.
**La corrección correcta:** que el `.nvmrc` esté en el repositorio (ya lo está) y que tu shell lo aplique al entrar al directorio. Es el incidente **01** del cuaderno.

**Síntoma:** al enviar el formulario, la consola escupe `NullInjectorError: No provider for _HttpClient!`.
**Causa:** falta `provideHttpClient()` en `app.config.ts`. En el mundo de los `NgModule` el equivalente era olvidar `HttpClientModule` en los `imports`.
**Fix mínimo:** añadir el provider. Diez segundos.
**Lo que importa:** que reconozcas la forma del error. `NullInjectorError` siempre significa lo mismo —alguien pidió algo que nadie registró— y en la Fase 5 vas a ver que ese mismo error se ve **distinto** según venga de un standalone o de un `NgModule` 🧬. Saber distinguirlos ahorra media tarde.

**Síntoma:** el POST devuelve `201` en Network, el `db.json` tiene la fila nueva, y la pantalla no cambia ni un píxel.
**Causa:** `OnPush` sin `markForCheck()`.
**Fix mínimo:** llamar a `markForCheck()` en el `next`, que es lo que hace el código de 5.7.
**La refactorización correcta:** exponer el resultado como observable y pintarlo con el pipe `async`, que marca el componente solo. Llega en la Fase 4, cuando haya un servicio de estado que exponga algo. Hoy sería inventar un servicio para no escribir una línea.

**Síntoma:** `NG8002: Can't bind to 'formGroup' since it isn't a known property of 'form'`.
**Causa:** falta `ReactiveFormsModule` en el `imports` del componente standalone.
**Fix mínimo:** añadirlo al array `imports` del decorador.
**Lo que importa:** en un componente standalone, `imports` es la lista **completa** de lo que la plantilla puede usar. Nada se hereda del padre. Eso es una virtud —lo que ves es lo que hay— y también la razón por la que un standalone que olvidó importar algo falla de una forma que no se parece en nada al fallo equivalente en un `NgModule`.

### Pieza forense de esta fase

Tres fuentes de verdad, y las tres mienten en algún momento. Aprender **en qué** miente cada una es el oficio entero.

**La consola.** Miente por omisión. Un `subscribe` sin callback de `error` traga el fallo entero: la petición falló, el usuario vio la pantalla congelada, y la consola está limpia. Por eso el código de 5.7 tiene el `error` puesto desde el primer día. Y miente por ilegibilidad: en producción, sin source maps, el stack apunta a un bundle minificado y da igual leerlo.

**La pestaña Network.** Miente por status. Un `201` significa que el servidor contestó, no que hizo lo que crees. Mira siempre tres cosas y en este orden: la **Request URL** completa (¿el puerto es 3000 o te olvidaste y quedó 4200?), el **payload** enviado (¿el `requestedFor` lleva offset o va pelado, como en 5.8?), y el **body** de la respuesta. Y hay un caso donde Network no miente pero se malinterpreta: un fallo de CORS aparece como `(failed)` sin código de estado, y se confunde con "el servidor está caído" — son cosas distintas y en la Fase 3 vas a provocar las dos a propósito.

**Los source maps.** Mienten cuando están desactualizados: un `.map` de un build anterior te lleva a la línea equivocada del archivo correcto, que es la peor clase de pista falsa. Ante una línea que "no tiene sentido", reconstruye el build antes de dudar de tu código.

> 📄 El recorrido completo, con la salida literal de cada herramienta y la ruta de decisión, en `forense-fase-00.md`.

**🧨 Rompe a propósito**

Cambia el puerto de la URL en `API_BASE_URL` de `3000` a `3001`, con json-server corriendo en el 3000. Envía el formulario y responde por escrito, antes de arreglarlo:

1. ¿Qué muestra la consola, exactamente?
2. ¿Qué status muestra Network, y por qué ese y no un `404`?
3. Si en vez del puerto hubieras equivocado la ruta (`/inspection-request`, en singular), ¿qué habría cambiado en las dos pestañas? Pruébalo.

Los tres síntomas se parecen desde la silla del usuario —"no se guardó"— y no tienen nada que ver entre sí. Distinguirlos en veinte segundos es literalmente el trabajo.

---

## 🧪 7. Ejercicios (28)

**🟢 Fácil (1–8)**

1. Crea el `.nvmrc`, activa la versión y deja constancia: pega en un archivo `setup.md` la salida exacta de `node -v`, `npm -v` y `npx ng version`. Criterio: las tres coinciden con el stack fijado, npm incluido.
2. Genera el proyecto con los cuatro flags de 5.2 y lista los archivos que **no** existen comparado con un `ng new certcore` a secas. Explica en una línea por qué falta cada uno.
3. Fija las versiones exactas, reinstala, y demuestra con `npm ls @angular/core @angular/forms rxjs typescript` que no queda ni un `^`.
4. Haz la conversión a standalone completa y verifica con `grep -rn "NgModule" src/` que devuelve cero resultados, con `ng serve` levantado.
5. **Diagnóstico.** Borra `ReactiveFormsModule` del array `imports` del formulario y anota el código de error y el mensaje literal. Después bórrale también el `NgIf`/`CommonModule` y anota el segundo. Restaura ambos y explica por qué el segundo error es más silencioso que el primero.
6. **Diagnóstico.** Cambia el selector del formulario de `cc-inspection-request-form` a `app-inspection-request-form` sin tocar la plantilla de `AppComponent`. ¿Qué error da, en qué momento aparece, y qué habría pasado con `strictTemplates: false`?
7. Levanta el stub y pide `http://localhost:3000/inspection-requests` desde el navegador. Copia el `requestedFor` de la fila sembrada y explica qué significa el `-05:00` y qué habría cambiado con una `Z`.
8. Envía una solicitud **con** nota y otra **sin** nota. Abre `mock/db.json` y explica la diferencia entre las dos filas en el campo `note`, y por qué el modelo dice `string | null` y no `note?: string`.

**🟡 Intermedio (9–17)**

9. **Diagnóstico.** Reproduce el `Object is possibly 'null'` de 5.9. Resuélvelo de las tres formas, deja las tres en el archivo comentadas, y escribe dos frases justificando por qué la tercera es la del proyecto y en qué caso concreto elegirías la segunda.
10. Quita `nonNullable: true` del control `assetId`. **Sin ejecutar nada**, escribe cuál es el tipo nuevo de `this.form.getRawValue()` y por qué la asignación a `InspectionRequest` deja de compilar. Después compila y comprueba si acertaste.
11. Añade un validador que rechace fechas en el pasado. Criterio: pedir una inspección para ayer marca el formulario inválido y muestra un mensaje; para hoy, no. Ojo con la zona horaria al comparar.
12. **Diagnóstico.** Comenta las dos llamadas a `markForCheck()`. Envía el formulario, confirma en Network que el `201` llegó y en el `db.json` que la fila se creó, y explica en tres frases por qué la pantalla no se enteró.
13. Con el bug de 12 puesto, cambia `ChangeDetectionStrategy.OnPush` a `Default` y comprueba que la pantalla se actualiza. Después revierte y explica por qué ese **no** es el fix del curso, aunque funcione.
14. **Diagnóstico.** Apaga json-server y envía. Describe qué aparece en consola, qué aparece en Network, y cómo distinguirías esto de un servidor que sí respondió pero con un `500`.
15. Cambia el tipo genérico del `post<...>` a `CreatedInspectionRequest` (si aún no lo está) e intenta leer `created.status` en el `next`. Explica el error de compilación y qué te está protegiendo exactamente.
16. Arregla el bug de 5.8: haz que `requestedFor` se envíe como ISO con offset `-05:00` explícito a partir de lo que entrega el `<input type="date">`. Criterio: la fila nueva del `db.json` tiene el mismo formato que la sembrada.
17. Crea un segundo componente standalone `cc-app-version` que muestre la versión de la aplicación, e impórtalo desde `AppComponent`. Criterio: aparece en pantalla y sigues sin tener un solo `NgModule` en `src/`.

**🟠 Difícil (18–23)**

18. **Diagnóstico.** Compila en producción **sin** `sourceMap`, provoca el error de 5.10 y guarda el stack trace. Actívalo, recompila, provoca el mismo error y guarda el segundo. Entrega los dos y una frase sobre cuánto habrías tardado con cada uno.
19. **Diagnóstico 🧨.** Pon `strict: false` en el `tsconfig.json` y vuelve a escribir el `this.form.get('assetId').value` del 5.9. Documenta: qué error desapareció, en qué momento exacto habría fallado en runtime, y qué habría visto el usuario. Restaura `strict: true` — y déjalo así para siempre.
20. Escribe a mano el tipo completo del `FormGroup` del formulario (`FormGroup<{ ... }>`) y anótalo explícitamente en la propiedad. Criterio: compila sin cambiar una línea del `FormBuilder`. Después explica por qué el curso prefiere la inferencia.
21. **Diagnóstico.** Edita `mock/db.json` a mano y cambia el `id` de la fila sembrada de `1` a `"1"`. Envía una solicitud, lee el `created.id` y explica por qué TypeScript no te avisó de nada. ¿Dónde está el límite del tipado, y qué se hace en un sistema real en ese borde?
22. **Diagnóstico.** Mueve `const http = inject(HttpClient)` desde el campo de clase a la primera línea de `submit()`. Reproduce el error, cítalo literal y explica con tus palabras qué es el "contexto de inyección" y por qué existe. Enlaza tu explicación con **A04**.
23. Mide el tamaño del bundle inicial con `ng build --configuration production` en tres variantes: como está, sin `ReactiveFormsModule` (formulario de plantilla), y con `CommonModule` importado entero en vez de `NgIf`. Entrega los tres números y una conclusión sobre qué diferencia importa de verdad y cuál es ruido.

**🔴 Muy difícil (24–28)**

24. **Diagnóstico.** Te llega este ticket, literal: *"solicité una inspección para el ascensor de la torre A y no se guardó nada"*. Escribe un árbol de diagnóstico de una página que llegue a la causa en el menor número de pasos, cubriendo al menos cinco causas posibles (URL, puerto, ruta, servidor caído, validación del cliente, `OnPush`). Después provoca tres de ellas y comprueba que tu árbol las separa.
25. Crea dos ramas: una con el arranque por `bootstrapApplication` y otra con `platformBrowserDynamic().bootstrapModule(AppModule)`, ambas mostrando la misma pantalla. Compara el tamaño del bundle inicial y el orden en que aparecen los errores cuando borras `provideHttpClient()` / `HttpClientModule`. Entrega la comparación y **no mezcles los dos estilos en ningún archivo**.
26. Decide dónde va la validación de `assetId`: sólo en el cliente, sólo en el mock, o en ambos. Impleméntala donde decidas, provoca el caso que tu decisión **no** cubre, y justifica la elección como lo haría alguien de mantenimiento: qué cuesta cada opción y qué ticket evita.
27. **Anticipa la Fase 13.** Extrae `API_BASE_URL` a su propio archivo `src/app/api-config.ts` y compila en producción. Ahora busca la cadena `localhost:3000` dentro de `dist/` con `grep -r`. Explica por qué sigue ahí, por qué mover la constante de archivo no cambió absolutamente nada, y qué haría falta para que la URL se pudiera cambiar **sin recompilar**.
28. Escribe el post-mortem completo de ocho puntos (formato del cuaderno, `formato-cuaderno-incidentes.md` §7) del incidente 01: un compañero clonó el repositorio, corrió `npm install` con Node 20 y `ng serve` falló. Los ocho puntos, con la prueba de regresión del punto 6 siendo algo que de verdad se pueda automatizar en este repositorio.

**🔥 Opcionales**

- 🔥 Configura tu shell para que aplique el `.nvmrc` automáticamente al entrar al directorio, y documenta cómo lo hiciste para tu shell y sistema operativo. Es la prevención real del incidente 01.
- 🔥 Sirve el build de producción detrás de un `npx http-server` en un puerto distinto del de json-server y provoca un fallo de CORS de verdad. Anota cómo se ve en Network y guárdalo: en la Fase 3 vas a construir el middleware que lo provoca a voluntad.
- 🔥 En Apple Silicon: comprueba con `node -p "process.arch"` si tu Node es `arm64` o `x64` bajo Rosetta, y anota el resultado. No cambia nada hoy; en la Fase 13 y en **A12** sí.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v16.angular.io/guide/standalone-components — componentes standalone y `bootstrapApplication`, en la versión que usa el curso.
- https://v16.angular.io/api/core/ApplicationConfig — la referencia de `ApplicationConfig` y los `provide*`.
- https://v16.angular.io/guide/typed-forms — formularios tipados, `nonNullable` y el genérico de `FormGroup`. Complementa A05.
- https://v16.angular.io/guide/change-detection-skipping-subtrees — qué hace exactamente `OnPush` y cuándo Angular revisa un componente.
- https://v16.angular.io/cli/new — todos los flags de `ng new` en el CLI 16.
- https://v16.angular.io/guide/workspace-config#source-map-configuration — la configuración de `sourceMap` en `angular.json`.
- https://www.typescriptlang.org/tsconfig#strict — qué activa exactamente `strict`. ⚠️ Documenta versiones posteriores a la 5.1.6 del curso; los flags de esta tabla no cambiaron, pero los ejemplos pueden usar sintaxis más nueva.
- https://github.com/typicode/json-server/tree/v0.17.4 — el stub de hoy y el mock de la Fase 3.
- https://github.com/nvm-sh/nvm — nvm en Linux y macOS. Para Windows, nvm-windows: https://github.com/coreybutler/nvm-windows

> ⚠️ **Angular tiene dos sitios de documentación y esto te va a morder.** `https://angular.dev` documenta la 17 en adelante: sus ejemplos usan `@if`/`@for`, signals como estilo de estado y `standalone: true` implícito. Nada de eso existe en la 16. La referencia por defecto de este curso es **`https://v16.angular.io`**, siempre. Si un buscador te lleva a `angular.dev`, mira la URL antes de copiar.

**Video y apoyo**

- Angular Standalone Components — charla oficial del equipo de Angular en ng-conf 2022/2023, disponible en el canal de Angular en YouTube. ⚠️ Busca la charla por título; los identificadores de video cambian y no vamos a inventar uno.
- MDN sobre `<input type="date">`: https://developer.mozilla.org/es/docs/Web/HTML/Element/input/date — útil para el ejercicio 16, porque explica exactamente qué formato entrega el control.

**Orden de lectura sugerido**

Antes de escribir código: la guía de standalone components y la de `ApplicationConfig`, en ese orden, sin detenerte en los `provide*` que no vas a usar hoy. Durante: la de formularios tipados, cuando llegues a 5.7, y **A04** si `inject()` te resulta ajeno. Después: la configuración de source maps de `angular.json`, que sólo se entiende cuando ya tienes un stack trace ilegible delante — vuelve a ella con el ejercicio 18 abierto.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Tienes CertCore arrancando: entorno reproducible con versiones exactas, un proyecto sin una sola línea de `NgModule`, un componente standalone con `inject()` y `OnPush`, un formulario tipado que respeta la nulabilidad del dominio, un POST que llega a un servidor de verdad, y `strict: true` puesto desde el primer archivo y hasta el último. También tienes una deuda 💸 que ya sabes dónde se paga, y un primer error de fecha que ya sabes que existe.

Y ahora viene el giro. La **Fase 1 te entrega la herencia**: `AppModule`, `CoreModule`, `SharedModule`, módulos de feature con `RouterModule.forChild`, componentes en `declarations`, inyección por `constructor`. Todo eso que hoy no escribiste. No es un retroceso pedagógico — es que ese código es el 80% de CertCore, es lo que vas a mantener, y ahora tienes con qué compararlo. Cuando veas el `SharedModule` reexportando media librería de Material vas a poder decir por qué está mal **y** por qué en 2021 tenía sentido, que son dos frases distintas y las dos hacen falta.

La Fase 1 necesita de ésta exactamente tres cosas: el entorno verificado, `strict` puesto (porque los `NgModule` de la Fase 1 también lo respetan), y que tengas fresco el estilo nuevo. Sin eso, la herencia se lee como "así es Angular" en vez de como "así era Angular en 2021".

> 🧭 **Regla del proyecto: una etiqueta por fase.** Antes de pasar a la Fase 1, cierra el trabajo y etiquétalo: `git add -A && git commit -m "fase 00: setup y hola mundo standalone"` seguido de `git tag fase-00`. Vas a repetirlo catorce veces y cuesta dos segundos, pero te compra tres cosas: volver a cualquier punto del curso sin deshacer trabajo (`git checkout fase-04`), comparar dos fases con `git diff fase-03 fase-04 --stat` —que es la mejor forma de repasar qué hizo realmente una fase—, y tener un "antes" cuando un ejercicio te pida volver atrás. Si además trabajas cada fase en su propia rama, mejor todavía — pero ponle prefijo (`git switch -c wip/fase-01`): una rama y un tag que se llaman igual vuelven ambiguo cualquier `git checkout fase-01`. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

> ⚠️ **Y etiqueta ésta en particular, porque la Fase 1 retira lo que escribiste hoy.** El componente standalone del formulario, su modelo y `app.config.ts` salen del proyecto mañana: eran andamio para levantar el entorno y enseñarte el estilo de 2024, y CertCore es una aplicación de NgModules. No se pierde nada —el tag lo conserva, y el ejercicio 30 de la Fase 1 lo recupera para compararlo—, pero conviene que no te tome por sorpresa.

> **La señal de que quedó bien:** cuando cierras la terminal, la vuelves a abrir mañana, corres tres comandos y todo levanta igual que ayer — y cuando algo no levanta, sabes en cuál de las tres pestañas mirar antes de abrir el código.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-00 -m "F0 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 00: …`) y los de ejercicio su
> número (`fase 00 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f00/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> La regla ya la leíste arriba, en el 🧭 de esta sección. Lo que falta —cómo
> etiquetar un ejercicio, de dónde salen las ramas `incidente/NN`, y por qué la
> rama en la que trabajas **no** debe llamarse igual que el tag— está en ese
> documento, y se lee en diez minutos.

---

## 📌 Pendientes sugeridos

- 🪦 **La incoherencia npm 9 / Node 18.19, cerrada.** Node 18.19.0 empaqueta npm 10.2.x y `alcance-del-proyecto.md` §9 fijaba npm 9.x, que eran dos cosas incompatibles. Se resolvió bajando el pin a **Node 18.18.2**, que trae npm **9.8.1** de fábrica: la tabla de §9 ya dice eso, y esta fase pide los tres números exactos en el `.nvmrc`. Queda una consecuencia para la **Fase 13**: la imagen base del Dockerfile debería ser `node:18.18.2-alpine` y no `node:18-alpine`, o el contenedor construirá con un npm distinto al de tu máquina.
- **Formato de `requestedFor` desde `<input type="date">`.** El ejercicio 16 lo arregla en el cliente, pero la decisión de fondo —¿el navegador arma el offset, o lo arma el servidor?— es de dominio y le pertenece a la **Fase 10**, donde la vigencia del certificado la vuelve crítica. Anotado ahí.
- **`hidden: true` en los source maps de producción.** Hoy se menciona en un 💡. El tratamiento completo —qué se sirve, qué se guarda, qué ve alguien con DevTools abierto— pertenece a la **Fase 13**, con nginx delante.
- **El error del `!` como política de proyecto.** El 5.9 dice que el aserto de no-nulo no se usa en CertCore. Merece una línea en la regla de lint del proyecto → **Apéndice A03** o la Fase 12, cuando se configure el pipeline de calidad.
- **Comparación de `NullInjectorError` entre standalone y `NgModule`.** Se nombra en la sección 6 y se resuelve en la **Fase 5** 🧬, que es su sitio. Aquí sólo queda sembrado.
- 🔥 **Un ejercicio de arranque doble más ambicioso** (el 25) podría convertirse en material del **Apéndice A10** para lectores del Track A, que llegan con `bootstrapModule` en los dedos.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 01 | "Cloné el repo, hice npm install y `ng serve` no arranca" | Despliegue | 🟢 |
