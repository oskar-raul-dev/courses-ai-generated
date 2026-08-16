# 🛠️ Fase 00 — Setup + hola mundo

> Tutorial Angular 8 — Laboratorio clínico · Fase 0 de 14 · **8 horas**
> Depende de: ninguna · Habilita: Fase 1 — Estructura base + NgRx
> Antes de empezar: [`00-historia-del-sistema.md`](./00-historia-del-sistema.md), veinte minutos que explican por qué LabCore está así
> Apéndices de apoyo: [A02 (Bootstrap 4 + Sass)](./a02-bootstrap-sass.md), [A03 (Node y npm)](./a03-node-npm.md), [A12 (dependencias problemáticas en arm64 / M1)](./a12-arm64-m1.md), [A13 (Docker + Colima en Apple Silicon)](./a13-docker-colima.md) · [Incidentes asociados](./cuaderno-incidentes.md): 01, 02

---

## 🎯 1. Propósito

Esta fase deja tu máquina lista para trabajar sobre un Angular 8 de 2019 y te
pone enfrente el primer componente que habla con un endpoint: un formulario de
alta de paciente que hace POST y te dice si salió bien o mal. Nada más. Pero de
paso vas a instalar Bootstrap 4 y Angular Material en el mismo proyecto, verlos
pelearse por el mismo botón, y aprender a mirar en DevTools cuál de los dos ganó
la cascada — que es exactamente el tipo de pregunta que vas a responder durante
el próximo año de mantenimiento.

El objetivo no es que el proyecto quede bonito. Es que quede **reproducible**: que
puedas decir con precisión qué versión de Node, qué versión del CLI y qué
`package-lock.json` produjeron el binario que estás mirando. El día que alguien
del equipo diga "en mi máquina no compila", la mitad del diagnóstico va a ser
comparar su salida de `ng version` con la tuya.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `node --version` responde `v14.21.3` (o `v12.22.12`) y coincide con el `.nvmrc` del repo.
- [ ] `npx ng version` imprime Angular `8.2.14` y Angular CLI `8.3.29`, y su salida está pegada en tu `cuaderno-incidentes.md` como estado inicial.
- [ ] `npx ng serve` levanta la aplicación en `http://localhost:4200` sin errores en consola.
- [ ] `npx json-server --watch db.json` responde en `http://localhost:3000/patients`.
- [ ] El formulario de alta de paciente hace POST y el nuevo registro aparece en `db.json`.
- [ ] Con el mock apagado, el formulario muestra un mensaje de error y tú sabes decir —mirando Network, no la pantalla— si fue conexión rechazada, CORS o 500.
- [ ] Sabes señalar, en DevTools, qué regla de Bootstrap está pisando a un componente de Material y en qué archivo nace.
- [ ] El proyecto está versionado desde el minuto cero —el CLI dejó el commit inicial— y la fase cierra con el tag `fase-00-setup-hola-mundo`.

---

## 🚫 3. Qué NO entra todavía

- Routing y layout con módulos → **Fase 1**.
- NgRx: store, actions, reducers, effects, selectores → **Fase 1**.
- i18n y el árbol de traducciones. En esta fase los textos van literales en
  español, con deuda declarada 💸 → **Fase 2**.
- Servicios inyectables (`patient.service.ts`) y `HttpInterceptor`. Acá el
  `HttpClient` vive dentro del componente, a propósito → **Fases 3 y 4**.
- El middleware de caos: latencia, 500 intermitentes, respuestas malformadas →
  **Fase 4**.
- Tema personalizado de Material. Acá usamos un tema prebuilt → **apéndice A01**.
- `environment.ts` y la configuración por ambiente. Lo vas a *ver* en esta fase,
  pero lo que significa se cobra completo en la **Fase 13**.
- Docker, nginx e imagen de producción → **Fase 13**.

---

## 🧠 4. Concepto mínimo

### El problema del `PATH` compartido

Tienes tres proyectos en la máquina y cada uno nació en un año distinto. Uno
quiere Node 20, este quiere Node 14 y hay un script viejo que solo corre en 12.
Si instalas Node "el normal" y sigues adelante, en algún momento vas a correr
`npm install` en el proyecto equivocado con la versión equivocada y vas a generar
un `package-lock.json` que no le sirve a nadie más del equipo. Peor: va a
funcionar en tu máquina.

La herramienta que resuelve esto es un **gestor de versiones de Node**, y la
convención que lo hace verificable es el archivo `.nvmrc` en la raíz del repo con
la versión adentro. No es magia: es un archivo de texto con un número. Lo que
aporta es que la versión deja de ser algo que recuerdas y pasa a ser algo que se
versiona con el código.

> 📝 **Nota de época.** Angular 8 salió en mayo de 2019, cuando Node 10 y 12 eran
> lo corriente. Node 14 funciona con algunas advertencias y es la que
> recomendamos porque sufre menos con dependencias nativas. De Node 16 en
> adelante el CLI 8 empieza a romperse con errores de OpenSSL que no vale la pena
> pelear. Si ves `ERR_OSSL_EVP_UNSUPPORTED`, estás en la versión equivocada.

### Qué es el CLI y qué esconde

Angular CLI no es un generador de plantillas. Es un envoltorio sobre **Webpack**
que decide por ti la configuración de compilación, los *source maps*, la
minificación y el servidor de desarrollo. Viniendo de backend, la analogía más
cercana es una herramienta de *build* que además trae servidor embebido: te da
`ng serve` como te darían un `mvn spring-boot:run`.

Hasta ahí el paralelo funciona. Donde se rompe: el resultado de `ng build` no es
un artefacto que se configure al arrancar, sino **archivos estáticos con la
configuración adentro**. Lo que había en `environment.ts` cuando compilaste quedó
horneado en el JavaScript. Esa frase es el eje de toda la Fase 13 y la causa de
la mitad de los "funciona en UAT y no en PROD" de este curso. Por ahora solo
necesitas saber dónde vive el archivo.

> 📚 Referencia rápida: [Workspace configuration (v8)](https://v8.angular.io/guide/workspace-config)

### Por qué TS-0 no es una decisión nuestra

Vas a ver `strict: false` en `tsconfig.json` y `any` repartido por el código. En
Angular 8 eso **era el default del CLI**: la bandera `--strict` de `ng new` no
existía todavía; llegó con Angular 12. Así que LabCore no eligió ser
laxo, simplemente nació antes de que ser estricto fuera fácil. Lo señalamos
cuando tape un bug, con humor si se puede, y seguimos: en Track A no se corrige.

### Dos frameworks de estilos en el mismo documento

Este es el concepto que de verdad justifica las 8 horas. Angular Material trae
sus propios estilos de componente. Bootstrap trae **Reboot**, una normalización
agresiva que redefine `box-sizing`, `line-height`, márgenes de encabezados y el
aspecto de los controles de formulario nativos — para *todo* el documento, no
solo para lo que tú marcas con clases de Bootstrap.

Cuando los dos conviven, quien gana una regla concreta depende de tres cosas, en
este orden: **especificidad** del selector, **origen** de la hoja, y si empatan,
**orden de aparición** en el CSS final. Ese "orden de aparición" es el que tú
controlas desde `styles.scss` y desde el arreglo `styles` de `angular.json`, y es
la palanca que vas a usar el resto del curso cuando un formulario se vea raro.

No hay una respuesta correcta universal sobre quién debe ir primero. Hay una
respuesta correcta **para este proyecto**, y la vas a descubrir rompiéndola.

---

## 💻 5. Código mínimo con comentarios

### 5.1 Fijar la versión de Node

Crea el archivo en la raíz del repo, antes que nada:

```
# .nvmrc
14.21.3
```

En Windows con [nvm-windows](https://github.com/coreybutler/nvm-windows), el
archivo no se lee solo; lo usas como referencia y ejecutas:

```bash
nvm install 14.21.3
nvm use 14.21.3
node --version   # v14.21.3
npm --version    # 6.14.x
```

En Linux y macOS con `nvm`, `nvm use` sin argumentos lee el `.nvmrc` directo.

**Detalles con intención**

- Fijamos `14.21.3` y no "la 14": una versión parcheada distinta puede traer un
  npm distinto, y npm es quien resuelve el árbol de dependencias.
- npm 6 es el que viene con Node 14. Importa: npm 7 cambió la resolución de
  *peer dependencies* y con Angular 8 vas a necesitar `--legacy-peer-deps` en
  todos lados. Con npm 6 no hace falta.

> ⚠️ **Windows 11 y las dependencias nativas.** Antes de instalar nada, asegúrate
> de tener Python 3 en el `PATH` y las Visual Studio Build Tools 2019 con
> "Desktop development with C++". Sin eso, `node-gyp` falla en el primer paquete
> nativo y el mensaje de error no te va a decir que el problema es ese. Lo que
> hace falta en cada sistema —y cómo se lee cada uno de los tres errores típicos
> de `node-gyp`— está desarrollado en el **Apéndice A12 §4**, que cubre las tres
> plataformas y no solo Apple Silicon.

### 5.2 Crear el proyecto

```bash
# El CLI se instala pinneado y de forma local al proyecto que vamos a crear.
npx @angular/cli@8.3.29 new clinical-lab --routing=false --style=scss --skip-git=false
cd clinical-lab
```

**Detalles con intención**

- `--routing=false`: el router llega en la Fase 1. Un `app-routing.module.ts`
  vacío desde hoy es una promesa que nadie cierra.
- `--style=scss`: obligatorio. Vamos a compilar Bootstrap desde Sass para poder
  tocar sus variables antes de que genere el CSS. Con CSS plano eso no se puede.
- No hay `--strict`. No existe en el CLI 8, y ahí está tu TS-0 sin que nadie lo
  haya elegido.

Verifica y **guarda la salida**:

```bash
npx ng version
```

Pega ese bloque en tu `cuaderno-incidentes.md`. Es tu línea base: dentro de tres
semanas, cuando algo no compile, la primera pregunta va a ser "¿qué cambió desde
acá?".

### 5.3 Los seis archivos que sí vas a tocar

Un proyecto de Angular 8 recién creado tiene bastantes archivos. Estos seis son
los que importan hoy; el resto lo miras cuando te haga falta.

| Archivo | Qué es y por qué te va a importar |
|---|---|
| `angular.json` | Configuración del *build*. Acá vive el arreglo `styles`, que decide el orden de la cascada |
| `package.json` | Dependencias. Su compañero `package-lock.json` es el que de verdad reproduce el árbol |
| `src/main.ts` | El arranque. Tres líneas que arman el `AppModule` |
| `src/app/app.module.ts` | El `NgModule` raíz: acá se declara y se importa todo |
| `src/styles.scss` | Estilos globales. El campo de batalla de esta fase |
| `src/environments/environment.ts` | La configuración por ambiente. Horneada en el build |
| `browserslist` | A qué navegadores apunta el build. Decide si el `dist/` sale doble |

Ese último merece treinta segundos, porque decide algo muy visible que casi nadie
relaciona con él. El CLI 8 estrenó el *differential loading*: si el `target` del
`tsconfig.json` es `es2015` **y** en el `browserslist` queda algún navegador que no
lo entiende —en la práctica, IE 11—, compila la aplicación **dos veces** y emite dos
juegos de bundles, uno moderno y uno viejo. El `ng new` deja el `target` en `es2015`
y la línea de IE **comentada**, así que en este proyecto está apagado y el `dist/`
sale sencillo:

```
# browserslist, tal como lo genera el CLI 8.3.29
> 0.5%
last 2 versions
Firefox ESR
not dead
# IE 9-11 support: descomentar la línea de abajo enciende differential loading
# IE 11
```

Descomentar esa línea duplica el tiempo de build y el número de archivos del
`dist/`. Qué hace ese mecanismo, cómo reconocerlo en un proyecto ajeno en diez
segundos, y la clase entera de bugs que produce —los que solo ocurren en el bundle
viejo y que `ng serve` **no puede reproducir jamás**— está en el **Apéndice A04 §3**.

> 📝 **Nota de época.** Si algún día abres un proyecto Angular con un
> `.angular-cli.json` en lugar de `angular.json`, estás mirando algo que nunca
> migró de Angular 5: el formato cambió en la versión 6 y el archivo viejo ya no se
> lee. LabCore no es ese caso —nació en la 8— pero el ecosistema está lleno de
> proyectos que sí, y reconocer el archivo te fecha el repositorio antes de abrir
> nada más.

Abre `src/environments/environment.ts` un momento. Son cuatro líneas y una de
ellas dice `production: false`. Todavía no hacemos nada con eso. Solo recuerda
dónde está: en la Fase 13 vas a descubrir que esas cuatro líneas explican por qué
la misma imagen se comportó distinto en dos ambientes.

### 5.4 Material primero, y que funcione

```bash
npx ng add @angular/material@8.2.3
```

El asistente pregunta el tema (elige `indigo-pink`, prebuilt), si quieres tipografía
global (sí) y animaciones del navegador (sí). Levanta el servidor y confirma que
compila:

```bash
npx ng serve
```

Ese estado —Material solo, funcionando— es el que vas a querer recuperar dentro
de diez minutos para comparar. Haz un commit ahora.

### 5.5 Bootstrap encima, y algo se rompe

```bash
npm install bootstrap@4.6.2 --save
```

> 🧭 **`4.6.2` es la versión de LabCore**, la última estable de la línea 4, y no hay
> nada que verificar contra nada: el stack del curso está cerrado y vive en el
> README. Lo que sí conviene saber es que entre menores de Bootstrap 4 cambiaron
> nombres de variables de Sass, así que el día que abras un proyecto heredado con
> una `4.3.x` no vas a poder copiar un `styles.scss` de aquí sin leerlo —y el
> procedimiento para comparar su árbol contra este está en **A03 §8**. El
> compilador es `node-sass`, no dart-sass, y eso tiene consecuencias que el
> apéndice **A02 §1.1** desarrolla: entre ellas un error de arranque que no
> menciona ni a Angular ni a tu `.scss`.

Ahora, en `src/styles.scss`:

```scss
// Bootstrap se compila desde Sass, no se consume el CSS ya construido.
// Así podemos redefinir variables ANTES del import y evitar sobreescribir
// reglas después con selectores cada vez más específicos.
$grid-breakpoints: (xs: 0, sm: 576px, md: 768px, lg: 992px, xl: 1200px);

@import "~bootstrap/scss/bootstrap";

// El tema de Material lo inyecta el CLI desde angular.json (arreglo "styles").
// Ese archivo se carga ANTES que este, así que Bootstrap gana los empates.
// Esa decisión no es inocente: es la que vas a revisar cada vez que un
// formulario se vea raro.
html, body { height: 100%; margin: 0; }
```

Recarga. Mira el botón de Material que traía el proyecto: cambió de altura, o de
`line-height`, o el texto ya no está donde estaba. No lo tocaste. Lo tocó Reboot.

Abre DevTools, inspecciona el botón, y en el panel de estilos busca la regla
tachada y la que la reemplazó. Vas a ver el nombre del archivo de origen al lado
de cada una. Ese ejercicio de treinta segundos —qué regla ganó y de dónde
vino— es el que resuelve el 80% de los tickets de "se ve mal en producción".

> 💸 **Deuda técnica intencional: dos design systems sin capa de aislamiento.**
> Lo correcto hoy sería no tener dos sistemas de estilos, y si el negocio obliga
> a tenerlos, aislarlos: cargar Bootstrap solo en las vistas que lo necesitan, o
> restringir Reboot a un contenedor con su propio ámbito. En Track A **no se
> paga**: LabCore los tiene mezclados en el `styles` global desde 2019,
> centenares de plantillas dependen de ese orden exacto, y cambiarlo rompería
> pantallas que nadie está mirando. Tu trabajo no es arreglarlo; es saber
> diagnosticarlo en treinta segundos.

### 5.6 Declarar lo que vamos a usar

```typescript
// src/app/app.module.ts
import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';

import { AppComponent } from './app.component';
import { PatientIntakeComponent } from './patient-intake/patient-intake.component';

@NgModule({
  declarations: [
    AppComponent,
    PatientIntakeComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    // FormsModule habilita ngModel: formularios template-driven.
    // Los reactivos llegan en la Fase 5, cuando el formulario lo justifique.
    FormsModule,
    HttpClientModule,
    // Se importa un módulo por componente de Material que se usa.
    // No hay barril compartido todavía; eso nace en la Fase 1.
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

**Detalles con intención**

- Angular Material no expone un módulo único: si olvidas `MatInputModule`, el
  `<input matInput>` se renderiza como un input pelado y **no falla la
  compilación**. Ese es el error más común de la fase.
- `HttpClientModule` va acá aunque el `HttpClient` se inyecte en el componente.

### 5.7 El componente gordo

```typescript
// src/app/patient-intake/patient-intake.component.ts
import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-patient-intake',
  templateUrl: './patient-intake.component.html',
  styleUrls: ['./patient-intake.component.scss']
})
export class PatientIntakeComponent {

  // El modelo del formulario vive en el componente, sin interfaz que lo tipe.
  // Así es LabCore: TS-0, "any" implícito por todas partes.
  patient: any = {
    documentId: '',
    fullName: '',
    birthDate: ''
  };

  saving = false;
  feedback = '';

  // El HttpClient se inyecta directamente en el componente, sin servicio
  // intermedio. Es deuda: en la Fase 4 esto se muda a PatientService.
  constructor(private http: HttpClient) { }

  // Métodos con "function () {}" no aplica en clases de TypeScript: acá la
  // sintaxis de método es la de la época y la que usa LabCore.
  // Lo que sí evitamos son las propiedades de clase con arrow function.
  submit() {
    // Validación de negocio dentro del componente, otra vez como el sistema
    // real. Lo correcto sería un validador del formulario.
    if (!this.patient.documentId || !this.patient.fullName) {
      this.feedback = 'Documento y nombre son obligatorios.';
      return;
    }

    this.saving = true;
    this.feedback = '';

    // subscribe() a pelo, sin operadores y sin desuscripción.
    // Acá es inofensivo porque HttpClient completa solo; en un componente
    // con router y observables de larga vida, esto es un memory leak.
    this.http.post('http://localhost:3000/patients', this.patient)
      .subscribe(
        (response: any) => {
          this.saving = false;
          // "response" es any: si el mock cambia la forma de la respuesta,
          // nadie te avisa hasta que explota en tiempo de ejecución.
          this.feedback = 'Paciente registrado con id ' + response.id;
          this.resetForm();
        },
        (error: any) => {
          this.saving = false;
          // Mensaje genérico: el detalle real está en la consola y en Network.
          this.feedback = 'No se pudo registrar el paciente.';
          console.error('[PatientIntake] falló el POST', error);
        }
      );
  }

  resetForm() {
    this.patient = { documentId: '', fullName: '', birthDate: '' };
  }
}
```

> **El patrón a memorizar:** cuando el `subscribe()` tiene dos funciones, la
> segunda es el único lugar donde vas a ver el error. Si alguien la olvidó, el
> fallo se convierte en una promesa rechazada silenciosa y la pantalla se queda
> esperando para siempre. "Se queda cargando" es casi siempre eso.

### 5.8 La plantilla, con los dos frameworks mezclados

```html
<!-- src/app/patient-intake/patient-intake.component.html -->
<!-- Grid de Bootstrap por fuera, componentes de Material por dentro.
     Es exactamente lo que hace LabCore, y donde nacen los choques. -->
<div class="container mt-4">
  <div class="row">
    <div class="col-md-6">

      <h2>Registro de paciente</h2>

      <mat-form-field class="w-100">
        <input matInput
               name="documentId"
               placeholder="Documento"
               [(ngModel)]="patient.documentId">
      </mat-form-field>

      <mat-form-field class="w-100">
        <input matInput
               name="fullName"
               placeholder="Nombre completo"
               [(ngModel)]="patient.fullName">
      </mat-form-field>

      <mat-form-field class="w-100">
        <input matInput
               type="date"
               name="birthDate"
               [(ngModel)]="patient.birthDate">
      </mat-form-field>

      <button mat-raised-button
              color="primary"
              [disabled]="saving"
              (click)="submit()">
        {{ saving ? 'Guardando...' : 'Registrar' }}
      </button>

      <p class="mt-3" *ngIf="feedback">{{ feedback }}</p>

    </div>
  </div>
</div>
```

> 💸 **Textos literales en español, en plantilla.** La regla del curso es que
> todo texto de interfaz sale de una clave de traducción. Acá no se puede: i18n
> se monta en la Fase 2 y todavía está pendiente decidir si va por *runtime* o
> por *compile-time*. Se deja literal, marcado, y **la Fase 2 lo reemplaza como
> primer ejercicio**. Este bucle sí se cierra.

Y en `app.component.html`, borra el andamio del CLI y deja:

```html
<app-patient-intake></app-patient-intake>
```

### 5.9 El mock

Todo el curso trabaja contra mocks. No hay backend real y no lo va a haber: el
foco es 100% frontend, y cuando haga falta lógica de servidor se escribe un
Express mínimo — que es lo que ocurre en la Fase 4 con el inyector de caos. Por
ahora, tres líneas:

```json
{
  "patients": []
}
```

```bash
npx json-server@0.16.3 --watch db.json --port 3000
```

Con eso, `POST /patients` responde `201` y agrega el registro al archivo, con un
`id` autoincremental. Abre `db.json` después de enviar el formulario: ahí está tu
paciente.

> **Prueba de fuego.** Apaga el mock (`Ctrl+C`) y envía el formulario otra vez.
> La pantalla te dice "No se pudo registrar el paciente." — que es verdad y a la
> vez es inútil. Abre la pestaña Network y mira la petición fallida: ahí ves si
> fue conexión rechazada, si nunca salió, o si salió y volvió con un código. Ese
> salto —de lo que dice la pantalla a lo que dice Network— es lo que hace esta
> fase.

### 5.10 El repo, que ya estaba ahí

No hay `git init` que hacer: la bandera `--skip-git=false` de §5.2 es la que
hace que el CLI inicialice el repositorio y deje el commit inicial con todo el
andamiaje. Compruébalo, que son tres segundos:

```bash
git log --oneline     # un commit, el que dejó el CLI
git status            # limpio, salvo lo que agregaste en esta fase
```

Vale la pena detenerse un momento acá, porque en este curso el repositorio no es
burocracia. Vas a **romper cosas a propósito** —el inyector de caos de la Fase 4
existe para eso, un tercio de los ejercicios de cada fase te entrega algo roto, y
el cuaderno de incidentes vive de reproducir bugs— y poder volver a un estado
sano sin pensarlo es lo que te va a dar permiso para experimentar.

De acá en adelante los commits llevan el prefijo de la fase —`f00:`, `f01:`,
`f05:`— y los de ejercicio además su número:

```bash
git add .
git commit -m "f00: formulario de alta de paciente contra el mock"
git commit -m "f00 ej17: lock regenerado y diff anotado"
```

Con eso, `git log --oneline --grep '^f00'` te devuelve todo lo que hiciste en
esta fase. Antes de commitear, dos comprobaciones: el `.gitignore` que dejó el
CLI ya excluye `/dist`, `/node_modules` y `/coverage`, y **`package-lock.json`
sí entra al repositorio** — es la foto exacta del árbol que produjo el binario
que estás mirando, y sin ella el `npm ci` de tu compañero no reproduce nada
(§1 y **Apéndice A03 §9**).

Y al terminar la fase —con el checklist de la sección 2 en verde, no antes—
marcas el hito con un tag anotado:

```bash
git tag -a fase-00-setup-hola-mundo -m "F0 cerrada: Node 14.21.3 con .nvmrc,
Angular 8.2.14 y CLI 8.3.29 arrancando, Material y Bootstrap conviviendo,
formulario de alta contra json-server, y el salto de la pantalla a Network
hecho a mano."
```

A partir de acá cada fase cierra igual: commit, tag `fase-NN-…`, y a la
siguiente. Trece fases más adelante vas a poder correr `git tag -l 'fase-*'` y
ver el curso entero en una pantalla. La convención completa —cómo etiquetar
ejercicios, cómo dejar un incidente resuelto con su par de tags, de dónde salen
las ramas `incidente/NN` del cuaderno y cómo restaurar el `db.json` que
ensuciaste probando— está en
[`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

> 💡 **¿Nunca usaste git más allá de `pull` y `commit`?** No hace falta más que
> eso. Un tag es un puntero a un commit: no ocupa espacio, no cambia nada y se
> borra con `git tag -d`. La convención se lee en diez minutos y te ahorra la
> tarde en que un ejercicio de la Fase 8 te deje el `db.json` irreconocible.


---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**El `<input matInput>` se ve como un input de HTML pelado.**
Síntoma: el campo no tiene la línea inferior ni la animación del *placeholder*.
Causa: falta `MatInputModule` en los `imports` del `AppModule`; el atributo
`matInput` no coincide con ninguna directiva y Angular lo ignora en silencio.
Fix mínimo: agregar el import. No hay refactorización pendiente acá; es un
olvido, no una decisión.

**El formulario se envía pero `db.json` no cambia.**
Síntoma: la pantalla dice "Paciente registrado con id undefined".
Causa: json-server está corriendo, pero contra otro archivo o en otro puerto, y
lo que respondió fue otra cosa. También pasa cuando el `POST` va a `/patient` en
singular y json-server crea una colección nueva sin avisar.
Fix mínimo: verificar la URL en Network contra las rutas que json-server imprime
al arrancar. La refactorización correcta —centralizar la URL base en
`environment.ts` en vez de tenerla escrita en el componente— llega en la Fase 4.

**El botón de Material cambió de tamaño después de instalar Bootstrap.**
Síntoma: los controles se ven apretados, o el texto del botón está descentrado.
Causa: Reboot redefinió `box-sizing` y `line-height` globalmente.
Fix mínimo: ninguno. Es el comportamiento esperado del proyecto y así vive
LabCore. Lo que sí haces es **saber decirlo**: abrir DevTools y señalar la
regla y su archivo de origen en menos de un minuto.

**`ERR_OSSL_EVP_UNSUPPORTED` al correr `ng serve`.**
Síntoma: falla el arranque con un error de OpenSSL que no menciona Angular.
Causa: estás en Node 17 o superior. El Webpack que trae el CLI 8 usa un algoritmo
de hash que las versiones nuevas de Node deshabilitaron.
Fix mínimo: `nvm use 14.21.3`. Que exista una variable de entorno para forzar el
proveedor legado no significa que sea buena idea: te aleja del entorno del equipo.

### Pieza forense de esta fase

La pieza de la Fase 0 es **la consola y la pestaña Network como fuente de
verdad**, y se desarrolla completa en [`forense-fase-00.md`](./forense-fase-00.md).
La idea que se instala acá es una sola: la pantalla te cuenta lo que el
programador decidió contarte, y esa decisión casi siempre se tomó un día en que
nadie pensaba en depurar. El estado real de la petición está en Network, y el
error original está en la consola, en el `console.error` que dejamos a propósito
en el componente.

**Rompe a propósito y observa.** Cambia la URL del POST a
`http://localhost:3001/patients` —un puerto donde no hay nadie— y envía el
formulario. Vas a ver: en la pantalla, el mismo mensaje genérico de siempre; en
Network, una petición en rojo con estado `(failed)` y sin código de respuesta; en
la consola, un `HttpErrorResponse` con `status: 0`. Ese `status: 0` es la firma de
"la petición nunca llegó a un servidor" y lo vas a reconocer el resto del curso:
significa conexión rechazada, DNS, o CORS bloqueando antes de salir. La mentira
que te cuenta la pantalla es que "no se pudo registrar el paciente", como si el
servidor hubiera dicho que no. El servidor nunca habló.

Este ejercicio es también la puerta de entrada a los **incidentes 01 y 02** del
cuaderno, que son de configuración y CORS. Cuando los abras, ya tienes el reflejo.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Crea el `.nvmrc` con `14.21.3` y confirma con `node --version` que estás en esa versión exacta.
2. Corre `npx ng version` y pega la salida completa en tu `cuaderno-incidentes.md`. Anota la fecha.
3. Instala Node 12.22.12 en paralelo, cambia a él, corre `npx ng serve` y anota si algo cambia en la salida del compilador.
4. Localiza en `angular.json` el arreglo `styles` y escribe en qué orden se cargan las hojas globales.
5. Abre `src/environments/environment.ts` y `environment.prod.ts`. Escribe en dos líneas qué diferencia hay y cuándo se usa cada uno.
6. Agrega un campo `email` al modelo `patient` y a la plantilla. Confirma que llega al `db.json`.
7. Arranca json-server con `--port 3001` y ajusta el componente. Confirma que vuelve a funcionar.
8. Cambia el tema prebuilt de Material a `deeppurple-amber` en `angular.json` y recarga sin reiniciar el servidor. Anota si hizo falta reiniciar.

**🟡 Intermedio (9–17)**

9. Comenta el import de `MatInputModule` en `app.module.ts`, recarga, y escribe exactamente qué se ve y qué dice la consola. Restáuralo.
10. Invierte el orden: haz que el tema de Material se cargue **después** de Bootstrap. Anota tres diferencias visuales concretas.
11. Redefine `$primary` de Bootstrap antes del `@import` en `styles.scss` y confirma que un `.btn-primary` cambia de color pero un `mat-raised-button color="primary"` no. Explica por qué.
12. Envuelve el `<div class="container">` en un elemento con la clase `.d-none.d-md-block`. Explica qué acaba de pasar y a qué archivo de Bootstrap pertenece esa regla.
13. Agrega validación de que `birthDate` no sea futura, dentro del componente. Deja el `any` como está.
14. Haz que el botón quede deshabilitado también cuando `documentId` esté vacío, sin tocar el método `submit()`.
15. Agrega un segundo `console.log` en el callback de éxito que imprima la respuesta completa. Envía un paciente y describe la forma exacta del objeto que devuelve json-server.
16. Corre `npm ci` en una carpeta limpia del repo y compara el tiempo contra `npm install`. Explica de dónde sale la diferencia (apóyate en el apéndice A03).
17. Borra `package-lock.json`, corre `npm install` y usa `git diff` sobre el lock regenerado. Anota cuántas líneas cambiaron y revierte.

**🟠 Difícil (18–24)**

18. **Diagnóstico.** Te entregan el proyecto con `MatFormFieldModule` importado pero `MatInputModule` no, y el reporte dice "los campos se ven feos en la pantalla de registro". Reproduce, localiza la causa y escribe el post-mortem de tres líneas.
19. **Diagnóstico.** El formulario "no guarda nada" y json-server está corriendo. La URL del componente apunta a `/patient` en singular. Reproduce, y explica por qué json-server devuelve `201` igual y por qué eso hace el bug más difícil de ver.
20. **Diagnóstico.** Un compañero reporta `ERR_OSSL_EVP_UNSUPPORTED`. Sin verle la máquina, escribe las tres preguntas que le harías, en orden de probabilidad.
21. **Diagnóstico.** Arranca json-server en `--port 3000` pero configura el componente contra `http://127.0.0.1:3000`. Anota si funciona, y si tu navegador trata `localhost` y `127.0.0.1` como el mismo origen.
22. Provoca un error de CORS de verdad: levanta un Express de diez líneas que responda al POST sin cabeceras de CORS y apunta el componente ahí. Documenta qué ves en Network, qué en consola, y por qué el `status` es `0` cuando el servidor sí respondió.
23. Usa el panel Sources de DevTools para poner un *breakpoint* dentro del callback de error y examina el objeto `HttpErrorResponse`. Lista sus cinco propiedades más útiles para un diagnóstico.
24. **Diagnóstico.** Modifica `db.json` a mano para que `patients` sea un objeto en vez de un arreglo. Arranca json-server, intenta el POST y explica el error a partir de lo que devuelve el servidor, no de lo que muestra la pantalla.

**🔴 Muy difícil (25–30)**

25. **Diagnóstico.** Sin tocar el código, haz que el formulario reporte éxito pero el paciente no quede guardado. Hay al menos dos formas; encuentra una y documenta la cadena completa de por qué la pantalla miente.
26. Compila con `npx ng build --prod`, sirve el resultado con cualquier servidor estático y confirma que el POST **sigue apuntando a localhost:3000** aunque estés en otro puerto. Explica qué acaba de demostrar esto sobre `environment.ts`. Anota tu respuesta: es la tesis de la Fase 13.
27. Sobre ese mismo *build* de producción, abre el bundle minificado y localiza el texto `No se pudo registrar el paciente`. Anota cuánto tardaste y qué te habría ahorrado tiempo.
28. Activa los *source maps* en el *build* de producción (`--source-map`), repite el ejercicio 27 y compara la experiencia. Anota en qué punto el mapa deja de ayudarte.
29. **Diagnóstico.** Genera un estado en el que el botón queda deshabilitado para siempre después de un fallo. Localiza la línea responsable, escribe el parche mínimo que aplicarías un viernes, y aparte, en una línea, la refactorización correcta.
30. **Diagnóstico.** Instala una versión distinta de Bootstrap (4.3.1) sobre el mismo proyecto sin borrar `node_modules`. Documenta qué se rompió, si algo, y cómo verificarías desde cero que el estado del proyecto es el que crees que es.

**🔥 Opcionales**

- 🔥 Monta el ambiente completo dentro de un contenedor **Debian slim** armado a mano —Node, Python, build tools— en vez de usar una imagen de Node ya hecha. Documenta qué te faltó instalar y en qué orden lo descubriste. Es la vía natural si trabajas en macOS con Apple Silicon; hay bastante material en internet sobre el tema y buscarlo es parte del ejercicio. Los apéndices A12 y A13 cubren la ruta corta — y el **A13 §6** trae el `devcontainer.json` y el `Dockerfile` de desarrollo ya escritos, que es exactamente lo que este ejercicio te pide construir a mano. **Y si quieres la lección completa, inténtalo primero sobre Alpine:** usa `musl` en vez de `glibc` y el tooling nativo de esta época se rompe ahí. Anota el error exacto antes de mudarte a Debian — es el mismo motivo por el que el Dockerfile de la **Fase 13** compila sobre Debian y no sobre Alpine (**Apéndice A03 §⚠️**).
- 🔥 Escribe un script de npm que verifique la versión de Node antes de `ng serve` y falle con un mensaje claro si no coincide con el `.nvmrc`.
- 🔥 Reemplaza el `.subscribe()` de dos callbacks por uno con `catchError`. Anota por qué en Track A **no** vamos a hacer este cambio en el código del curso.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v8.angular.io/guide/setup-local — instalación y primer proyecto, en la versión que usamos.
- https://v8.angular.io/guide/workspace-config — el `angular.json`, incluido el arreglo `styles`.
- https://v8.angular.io/guide/build — configuración por ambiente y el reemplazo de archivos en el *build*. Léelo hoy en diagonal; se cobra en la Fase 13.
- https://v8.angular.io/guide/forms — formularios template-driven con `ngModel`.
- https://v8.material.angular.io/components/form-field/overview — `mat-form-field` y por qué necesita `matInput`.
- https://getbootstrap.com/docs/4.6/content/reboot/ — qué redefine Reboot exactamente. Es la lista de lo que te va a morder.
- https://github.com/typicode/json-server — el mock. Ojo: el README del repositorio ya documenta la versión 1.x, que cambió opciones de línea de comandos; nosotros usamos la línea 0.16.
- https://github.com/coreybutler/nvm-windows — gestor de versiones de Node en Windows.
- https://developer.mozilla.org/es/docs/Web/CSS/Specificity — especificidad de la cascada, para el ejercicio 10.

**Video / apoyo**

- Cualquier recorrido introductorio del Angular CLI sirve para el vocabulario, pero verifica la versión antes de seguir los comandos: casi todo el material en video de Angular asume versiones 14 o posteriores, donde `ng new` tiene banderas que acá no existen.

**Orden de lectura sugerido:** empieza por la guía de setup local de v8 para tener el mapa; ten abierta la página de Reboot mientras haces la sección 5.5, que es donde vas a necesitarla; y vuelve a la guía de *build* al terminar el ejercicio 26, cuando ya sepas por qué importa.

> ⚠️ URLs, títulos y contenidos cambian o desaparecen; verifícalos. Cuidado
> especial con caer en `angular.io` o `angular.dev`: documentan versiones muy
> posteriores y sus ejemplos no compilan acá. La referencia por defecto de este
> curso es siempre `v8.angular.io`.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Terminas esta fase con un proyecto que compila, un componente que habla con un
mock, dos sistemas de estilos conviviendo con la fricción declarada, y —lo más
importante— con la salida de `ng version` guardada como línea base.

Lo que **no** tienes es estructura. Un solo componente con el `HttpClient`
adentro funciona hasta que aparece el segundo, y ahí empiezan las preguntas que
la Fase 1 responde: dónde vive el estado compartido, cómo se navega entre
vistas, y por qué LabCore montó NgRx en 2019 con reducers en `switch`.
La Fase 1 es la más densa del curso y necesita de esta lo único que no puede
darse a sí misma: un entorno que arranca sin sorpresas.

> **La señal de que quedó bien:** "si mañana un compañero clona el repo, corre
> dos comandos y ve la misma pantalla que yo, entonces lo que armé no es mi
> máquina: es el proyecto."


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-00-setup-hola-mundo -m "F0 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f00: …`) y los de ejercicio su
> número (`f00 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f00/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Es el primero de quince, y el único que no estrena repositorio: el CLI ya lo
> abrió en §5.2 y §5.10 te lo deja listo. De acá en adelante, cada fase cierra
> igual.

---

## 📌 Pendientes sugeridos

- 🪦 **Versión de Bootstrap: cerrada.** `4.6.2` compilado desde Sass con
  `node-sass` 4.14.1, fijada en el README y desarrollada en el apéndice **A02**.
  Ya no queda nada que verificar.
- 🪦 **Orden de la cascada: resuelto.** Material primero por el arreglo `styles`
  de `angular.json`, Bootstrap después dentro de `styles.scss` — el que ya
  escribe §5.5. Queda fijado como contrato del proyecto en **A02 §4.1**, y el
  ejercicio 10 sigue siendo el que lo invierte para ver qué se rompe.
- **Textos literales en español en plantilla.** Deuda declarada acá, se paga en
  la **Fase 2** como primer ejercicio, y depende del pendiente bloqueante de
  i18n *runtime* vs *compile-time*.
- **Centralizar la URL base del API en `environment.ts`.** Hoy está escrita en el
  componente → **Fase 4**, y se cobra en la **Fase 13**.
- **Ambiente dockerizado con Debian slim armado a mano.** Queda como ejercicio 🔥
  en esta fase; si el equipo trae varias MacBook, merece desarrollo propio →
  apéndice **A13**. La razón de que sea Debian y no Alpine —`musl` contra
  `glibc`— está en el **Apéndice A03**.

### Reservas para el cuaderno de incidentes

Esta fase toma los incidentes **01 y 02**, ambos ya reservados en el índice de
[`cuaderno-incidentes.md`](./cuaderno-incidentes.md) —que es el único archivo de
incidentes del curso—. El enunciado completo —ticket, preparación, pistas plegadas y solución de referencia— **ya está escrito allí**:

- **01** · Fase 0 · *"Guardé el paciente y la pantalla dice que no se pudo"* · Categoría: despliegue · Dificultad 🟢 — entra por el `status: 0` del §6: el servidor nunca habló, y la pantalla lo cuenta como si hubiera dicho que no.
- **02** · Fase 0 · *"En la máquina de al lado funciona y en la mía no"* · Categoría: integración · Dificultad 🟢 — la diferencia de entorno: versión de Node, puerto ocupado o el mock que no está levantado. Es el primer diff entre máquinas del curso.
