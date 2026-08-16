# ✅ Fase 12 — Testing desde cero + coverage

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 12 de 14 · **8 horas**
> Depende de: Fase 11 (dashboard y alertas) · Habilita: Fase 13
> Apéndices de apoyo: [A05 (Formularios tipados)](a05-formularios-tipados.md) · [A06 (RxJS 7)](a06-rxjs.md) · [A11 (Puente 16 → 17+)](a11-puente-16-17.md)
> [Incidentes asociados](cuaderno-incidentes.md): 17, 20
> Estilo de esta fase: **mixto 🧬** — hay que testear las dos generaciones, y no se testean igual

---

## 🎯 1. Propósito

CertCore lleva tres años en producción y **no tiene un solo test**. No es una exageración pedagógica: el proyecto se generó con `--skip-tests` en la Fase 0, precisamente para que hoy la carpeta estuviera vacía como está la de la mitad de los sistemas que un equipo de mantenimiento hereda.

Hoy escribes los primeros. Y la pregunta que ordena la fase no es *"¿cómo se usa Jasmine?"* —eso se aprende en veinte minutos— sino la única que importa en un sistema que ya sólo recibe hotfixes: **¿qué merece un test?** Testear once fases de código retroactivamente no lo hace ningún equipo del mundo, y quien lo propone en una reunión está proponiendo un trimestre. Lo que sí se hace, y lo que esta fase enseña, es cubrir tres cosas: **lo que se toca en un hotfix, lo que ya se rompió una vez, y las reglas que si fallan no dan ningún error**.

Vas a descubrir además que la mitad del trabajo ya está hecho. Las Fases 7 a 11 llevan cinco capítulos escribiendo el dominio sin inyecciones, sin `Observable` y sin saber en qué pantalla corre — `resolveTemplateVersion`, `computeProgress`, `deriveSeverity`, `certificateStatus`, `bucketCertificates`—. Cada una de esas funciones se testea en tres líneas y sin navegador, y ése era el plan desde la Fase 7 aunque no lo dijéramos así.

Y hay una lección que sólo se puede dar aquí, porque necesita once fases de código detrás: **la testabilidad es lo que delata el diseño**. Cuando una función necesita trucos para probarse, casi nunca es culpa del test.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `npm test` levanta Karma, corre la suite y pasa. `npm run test:ci` la corre en Chrome headless, sin ventana y sin quedarse esperando.
- [ ] Jasmine y Karma están fijados a versión exacta en `package.json`, como todo lo demás del curso desde la Fase 0. `npm ls jasmine-core karma` responde una sola versión de cada uno.
- [ ] La tabla de ocho casos borde de `resolveTemplateVersion` (Fase 7 §5.3) es una suite de ocho `it`, y cuando uno falla el nombre te dice cuál sin abrir el código.
- [ ] Existe el **test de regresión del invariante**: una inspección de agosto de 2023 se lee con la v1 aunque la v2 esté vigente. Rompes esa línea en el código de producción y el test se pone rojo.
- [ ] `authGuard` y `authInterceptor` —funcionales— tienen test, y `CorrelationIdInterceptor` —de clase, de 2021— también. Son tres técnicas distintas y sabes por qué.
- [ ] `KpiCardComponent` (standalone) e `InspectionListComponent` (declarado) tienen su spec, con **dos configuraciones de `TestBed` distintas**. Intercambiarlas no compila, y sabes leer el error.
- [ ] `npm run test:ci` imprime el coverage y **falla** si baja del umbral. Las exclusiones están escritas en `angular.json` con su justificación al lado.
- [ ] Sabes decir, con el informe delante, por qué un 82 % global no significa que el sistema esté probado.
- [ ] `git tag` lista `fase-12`.

---

## 🚫 3. Qué NO entra todavía

- **E2E con Playwright o Cypress** → fuera de alcance del curso, y no es un recorte de tiempo. Un e2e prueba el sistema entero contra un backend, y el backend de CertCore es un mock con un inyector de caos: un e2e sobre eso prueba el caos, no la aplicación. La decisión está en `alcance-del-proyecto.md` §8 y aquí sólo se confirma.
- **Mutation testing** → fuera de alcance. Es la respuesta correcta a la pregunta *"¿mis tests sirven para algo?"* y es una herramienta más que instalar, configurar y esperar. Se nombra en el ejercicio 29, que hace la misma pregunta a mano.
- **CI real** → fuera de alcance. Lo que sí entra es el comando que un pipeline necesitaría (`test:ci`), porque sin él no se puede ni medir coverage en local.
- **`TestScheduler` y la sintaxis de marbles con guiones** → se nombra y se descarta. Los observables de este curso se testean coleccionando emisiones en un array y con `fakeAsync`; aprender un segundo lenguaje para escribir `'--a--b|'` no aporta nada aquí. **A06** lo comenta.
- **Tests del PDF** (`certificate-pdf.ts`) → es una de las exclusiones justificadas de 5.1. Genera un binario; comprobar que jsPDF dibuja es testear jsPDF.
- **Tocar el código de producción de las fases anteriores** → esta fase escribe specs, no refactoriza. La única excepción está en el ejercicio 26, y es a propósito.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

Un equipo de mantenimiento con cero tests tiene delante dos caminos y uno de los dos no lleva a ninguna parte.

El primero es *"vamos a testear el sistema"*. Once fases de código, cientos de ramas, un objetivo de cobertura y un trimestre. Nadie lo termina nunca, porque a mitad entra un hotfix urgente y la iniciativa muere con la reunión en que se propuso.

El segundo es más humilde y funciona: **se testea lo que se toca**. Cada hotfix trae su test de regresión, cada bug del cuaderno deja el suyo, y la cobertura sube sola en las zonas donde el sistema se mueve — que son, por definición, las zonas donde puede romperse. Las que llevan tres años quietas siguen sin test, y está bien: un código que nadie modifica no puede regresionar.

> 🧭 **Regla del proyecto: en un sistema heredado, el coverage no se persigue, se acumula.** Sube como efecto de arreglar cosas, no como objetivo de un trimestre.

Eso deja tres categorías que sí merecen test desde el primer día:

**Lo que se toca en un hotfix.** El invariante de plantillas, el cálculo de vigencia, la derivación de severidad. Son las tres reglas que un ticket va a hacer tocar, y las tres son funciones puras.

**Lo que ya se rompió una vez.** Los dieciséis incidentes del cuaderno. Un bug que ocurrió puede volver a ocurrir, y su test es la única garantía de que el fix sobrevive a la siguiente refactorización.

**Lo que si falla no da ningún error.** Ésta es la categoría más importante de este sistema y la más fácil de olvidar. Una inspección renderizada con la plantilla equivocada no lanza una excepción: pinta una pantalla perfectamente creíble. Un hallazgo `critical` que no bloquea no da un 500: emite el certificado. Ninguno de los dos aparece en un log. **Sólo un test los ve.**

### El test de regresión, y por qué va antes que el fix

Éste es el orden que separa un arreglo de un parche con suerte, y es la pieza forense de la fase:

1. Llega el ticket. Reproduces el bug **a mano** hasta verlo.
2. Escribes un test que lo reproduce. **El test falla.** Ése es el momento importante: un test de regresión que no has visto fallar no prueba nada, porque no sabes si falla por el bug o si no prueba nada en absoluto.
3. Arreglas el código.
4. El test pasa. Y ahora sabes dos cosas: que arreglaste **eso**, y que sigue arreglado dentro de dos años cuando alguien refactorice.

El paso 2 es el que la gente se salta, y saltárselo tiene un nombre: **el test que nunca fue rojo**. Escrito después del fix, sobre el código ya arreglado, pasa a la primera y nadie comprueba si pasaría también con el bug puesto. La mitad de esos tests no prueban nada — hacen `expect(algo).toBeTruthy()` sobre un objeto que siempre existe— y nadie se entera, porque están verdes.

El curso tiene una traducción exacta de esto a git y conviene usarla: el par `inc/<ID>/<slug>-roto` e `inc/<ID>/<slug>-fix`. En el primero, el test **existe y falla**; en el segundo, pasa. El `git diff` entre los dos es el punto 5 de un post-mortem, aislado del ruido.

### Cómo se testea cada cosa de este proyecto

Hay cuatro maneras y elegir mal es la causa de la mitad de los tests lentos y frágiles del mundo. Ordenadas de más barata a más cara:

**Una función pura: llamándola.** Sin `TestBed`, sin navegador, sin nada. Le pasas datos, compruebas lo que devuelve. Corre en milisegundos y no puede ser intermitente. **Aquí entra la mitad del código del proyecto**, y no por casualidad: las Fases 7 a 11 escribieron el dominio así a propósito.

**Un servicio con dependencias: con `TestBed` y dobles.** `TestBed.configureTestingModule({ providers: [...] })` monta un inyector de mentira donde tú decides qué recibe cada cosa. Para los servicios de API, `HttpClientTestingModule` sustituye el backend por uno que te deja inspeccionar y responder a mano.

**Un guard o interceptor funcional: llamándolo, pero dentro de un contexto de inyección.** Son funciones, así que se llaman; lo que pasa es que por dentro hacen `inject()`, y `inject()` fuera de un contexto de inyección da `NG0203`. `TestBed.runInInjectionContext(() => authGuard(route, state))` resuelve exactamente eso, y es la pieza que hace testeable todo el estilo nuevo del proyecto.

**Un componente: con `TestBed` y un `ComponentFixture`.** Es lo más caro —monta un árbol de verdad, con detección de cambios y DOM— y es donde el proyecto tiene su 🧬: un componente standalone y uno declarado en un NgModule se configuran distinto, y confundirlos da un error que no dice lo que pasa.

### 🧬 ¿Nuevo o heredado? Las dos configuraciones de `TestBed`

Ésta es la micro-sección que da nombre al estilo de la fase, porque es la primera vez en el curso que **el mismo trabajo se escribe de dos formas según la generación del archivo**, y no hay forma de elegir una para todo.

**Un componente standalone se declara a sí mismo.** Sabe lo que importa —está en su propio decorador— así que el `TestBed` sólo tiene que conocerlo:

```ts
TestBed.configureTestingModule({
  // Va en `imports`, como cualquier otra cosa standalone.
  imports: [KpiCardComponent],
});
```

**Un componente declarado no sabe nada.** Sus dependencias las tiene el módulo que lo declara, así que el `TestBed` tiene que reproducir ese entorno a mano:

```ts
TestBed.configureTestingModule({
  // Va en `declarations`, y hay que darle además lo que su módulo le daba.
  declarations: [InspectionListComponent],
  imports: [SharedModule, RouterTestingModule],
  providers: [{ provide: InspectionStateService, useValue: inspectionStateStub }],
});
```

Intercambiarlas produce dos errores distintos y los dos merecen verse una vez. Un standalone en `declarations` da un error explícito —*"Component X is standalone, and cannot be declared in an NgModule"*— que se lee y se entiende. Un componente declarado puesto en `imports` da otro que **no** dice lo que pasa: se queja de que el tipo no es un módulo, un componente standalone ni una directiva, y a mitad de un spec de cuarenta líneas cuesta relacionarlo con la causa.

> 🧭 **La regla de siempre, aplicada al test: el spec se escribe en el estilo del archivo que prueba.** Un componente de 2021 se testea como se testeaba en 2021, con `declarations` y su módulo alrededor, aunque el spec lo escribas hoy. Convertirlo a standalone "para que el test quede más limpio" es modernizar mientras arreglas, que es como se rompen otras tres cosas.

> 📝 **Nota de migración.** El `TestBed` es de Angular 2 y su forma no ha cambiado; lo que cambió es lo que le metes. Hasta la 14, todo iba en `declarations` porque todo era declarado. La 14 trajo standalone y con él `imports`; la 15 trajo `provideHttpClient()`; la 16 trajo `TestBed.runInInjectionContext()` —en la 16.1, y este curso está en la 16.2.12, así que lo tienes—. Antes de eso, testear un guard funcional exigía `TestBed.inject(EnvironmentInjector).runInContext(...)`, que hacía lo mismo con peor nombre. Y hay una pieza que **todavía no existe** en tu versión: `provideHttpClientTesting()`, que llega en la 17. Aquí el cliente HTTP de prueba se monta con `HttpClientTestingModule`, un NgModule — así que en la 16 configuras la aplicación con la forma nueva y la testeas con la vieja. Es la fricción más honesta de esta versión y no tiene arreglo: tiene fecha.

---

## 💻 5. Código mínimo con comentarios

### 5.1 Lo primero es mirar qué te dejó el CLI

No empieces escribiendo un spec. Empieza averiguando qué hay, que es el reflejo que este curso entero entrena.

```bash
# 1. ¿Existe el objetivo `test` en angular.json?
npx ng config projects.certcore.architect.test

# 2. ¿Están los archivos que Karma necesita?
ls -la karma.conf.js tsconfig.spec.json

# 3. ¿Qué versiones hay instaladas, y con qué rango?
npm ls jasmine-core karma karma-jasmine
```

Lo esperable, con el `--skip-tests` que puso la Fase 0: el objetivo `test` **está**, las devDependencies de Jasmine y Karma **están** —`--skip-tests` omite los `.spec.ts`, no el andamiaje—, `tsconfig.spec.json` **está**, y `karma.conf.js` **no**, porque desde Angular CLI 12 el builder usa una configuración por defecto y sólo genera el archivo si se lo pides.

Si te falta el `karma.conf.js` —que es el caso normal—:

```bash
# Genera el archivo con los valores por defecto, para poder editarlo.
npx ng generate config karma
```

Y si te falta el objetivo `test` entero, alguien generó el proyecto con `--minimal` en vez de `--skip-tests`. No es tu caso, pero conviene saber distinguirlos: los dos dejan la carpeta sin specs y sólo uno deja el andamiaje.

**Las versiones, que nunca se fijaron.** El `alcance-del-proyecto.md` §9 manda **Jasmine 4.6.x y Karma 6.4.x**, y la Fase 0 fijó exacto todo lo que usaba — pero no usaba éstos, así que se quedaron con el `^` que puso el CLI. Hoy se cierra, porque la regla del proyecto es que ninguna dependencia vive con rango:

```jsonc
// package.json — comprueba primero con `npm ls` qué patch tienes instalado y
// fija ése. Estos son los que trae el CLI 16.2.12, y lo que importa no es el
// número exacto sino que deje de haber un `^` delante.
{
  "devDependencies": {
    "@types/jasmine": "4.6.4",
    "jasmine-core": "4.6.1",
    "karma": "6.4.4",
    "karma-chrome-launcher": "3.2.0",
    "karma-coverage": "2.2.1",
    "karma-jasmine": "5.1.0",
    "karma-jasmine-html-reporter": "2.1.0"
  },
  "scripts": {
    "test": "ng test",
    // Sin ventana, sin quedarse esperando, y con coverage. Es lo que un
    // pipeline necesitaría — el CI real está fuera de alcance, pero sin este
    // comando no se puede ni medir en tu propia máquina.
    "test:ci": "ng test --watch=false --browsers=ChromeHeadlessCI --code-coverage"
  }
}
```

```js
// karma.conf.js
// Generado con `ng generate config karma` y editado. Comentarios en español,
// como todo el código del proyecto — esto también es código.
module.exports = function (config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine', '@angular-devkit/build-angular'],
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-launcher'),
      require('karma-jasmine-html-reporter'),
      require('karma-coverage'),
      require('@angular-devkit/build-angular/plugins/karma'),
    ],
    client: {
      jasmine: {
        // El orden aleatorio es el DEFECTO de Jasmine desde la 3, y se deja
        // puesto a propósito. Es lo único que delata que dos tests dependen
        // uno del otro por culpa de un servicio `providedIn: 'root'` que
        // sobrevive entre specs. Apagarlo esconde el incidente 17 en vez de
        // arreglarlo.
        random: true,
      },
      // La consola del navegador NO se limpia entre ejecuciones: cuando un
      // test falla por un error que nadie capturó, el mensaje sigue ahí.
      clearContext: false,
    },
    reporters: ['progress', 'kjhtml'],
    browsers: ['Chrome'],
    customLaunchers: {
      // Chrome sin ventana. `--no-sandbox` hace falta dentro de un contenedor
      // —donde no hay usuario ni namespaces— y es inofensivo fuera. La Fase 13
      // te va a agradecer que ya esté escrito.
      ChromeHeadlessCI: {
        base: 'ChromeHeadless',
        flags: ['--no-sandbox', '--disable-gpu'],
      },
    },
    coverageReporter: {
      dir: require('path').join(__dirname, './coverage/certcore'),
      subdir: '.',
      reporters: [{ type: 'html' }, { type: 'text-summary' }, { type: 'lcovonly' }],
      /**
       * ⭐ Los dos umbrales, y el segundo es el que de verdad muerde.
       *
       * `global` es el número que se lleva a una reunión y el que miente: con
       * treinta funciones puras cubiertas, el 80 % global se alcanza SIN
       * testear ni un componente. Es el incidente 20.
       *
       * `each` es por archivo, y es el que impide el agujero: ningún archivo
       * puede quedarse por debajo del 50 %, así que no se puede compensar un
       * servicio sin probar con un módulo de constantes al 100 %.
       *
       * Las ramas van más bajas que las sentencias a propósito: un `if` de
       * guarda que nunca se cumple en producción tampoco se cumple en un test,
       * y perseguirlo produce tests que inventan situaciones imposibles.
       */
      check: {
        global: { statements: 80, branches: 70, functions: 80, lines: 80 },
        each: { statements: 50, branches: 40, functions: 50, lines: 50 },
      },
    },
    restartOnFileChange: true,
  });
};
```

```jsonc
// angular.json — dentro de projects.certcore.architect.test.options
{
  /**
   * ⚠️ Las EXCLUSIONES van aquí y no en el karma.conf, y esto es una trampa
   * real: es el builder de Angular quien decide qué instrumentar, antes de que
   * Karma vea nada. Una exclusión escrita en `coverageReporter` no da error —
   * simplemente no hace nada, y te pasas media tarde preguntándote por qué el
   * `environment.ts` sigue contando.
   */
  "codeCoverageExclude": [
    // Config horneada en build. No tiene lógica y la Fase 13 la sustituye entera.
    "src/environments/**",
    // Los NgModule heredados son declaración pura: `declarations`, `imports`,
    // `exports`. Un test que los cubra prueba que el archivo existe.
    "src/**/*.module.ts",
    // Dibuja un PDF con jsPDF. Comprobar que dibuja es testear jsPDF; lo que
    // sí se testea es `buildCertificateDocument`, que es puro y decide QUÉ se
    // dibuja. Fase 10 §5.6.
    "src/app/core/pdf/**",
    // El mock es Node, no Angular, y corre en otro proceso.
    "mock/**"
  ]
}
```

```
💸 DEUDA TÉCNICA INTENCIONAL — coverage al 80 % con exclusiones, no al 100 %
Cuatro carpetas quedan fuera de la medición y el umbral global se queda en 80.
NO SE PAGA, y esta vez no es cuestión de costo ni de herramienta: es que el
número correcto depende del equipo y nadie de fuera lo puede fijar. Lo que sí es
universal es lo que pasa al subirlo sin criterio. Un objetivo del 100 % produce
tests escritos para el informe: `expect(component).toBeTruthy()` repetido
cuarenta veces, que sólo prueba que el archivo compila; specs de getters; y
ramas imposibles inventadas para tocar un `else` que en producción no ocurre. Ese
código no protege de nada, cuesta mantenerlo, y —lo peor— sube el número, así
que nadie vuelve a mirar si la zona está de verdad probada.
El ejercicio 29 te hace subirlo al 95 % y contar exactamente qué tuviste que
escribir para llegar. Con esa lista delante, la decisión es tuya y no mía.
```

**Prueba de fuego**

`npm test` levanta Chrome y se queda esperando cambios: ése es el modo de trabajo. `npm run test:ci` no abre nada, corre una vez, imprime el resumen de coverage y **devuelve un código de salida distinto de cero si baja del umbral** — compruébalo con `echo $?` en la terminal. Si siempre devuelve cero, el `check` no está donde crees.

### 5.2 La tabla de la Fase 7, convertida en suite

Éste es el primer spec y no necesita `TestBed`, ni navegador, ni un solo doble. La tabla de bordes ya estaba escrita en la Fase 7 §5.3; hoy sólo se transcribe.

```ts
// src/app/core/domain/resolve-template-version.spec.ts
import { ChecklistTemplate } from '../models/checklist-template.model';
import { BusinessDay } from '../time/business-day';
import { TemplateResolution, resolveTemplateVersion } from './resolve-template-version';

/**
 * Constructor de fixtures. Un test que declara ocho objetos completos con sus
 * seis campos es ilegible; uno que declara `version(1, '2021-01-01',
 * '2023-12-31')` se lee como la tabla que copia.
 *
 * Los `items` van vacíos porque a esta función no le importan. Rellenarlos
 * "por realismo" añadiría ruido a lo único que el lector tiene que comparar.
 */
function version(
  versionNumber: number,
  validFrom: BusinessDay,
  validUntil: BusinessDay | null,
): ChecklistTemplate {
  return {
    id: `elevator-annual-v${versionNumber}`,
    templateId: 'elevator-annual',
    version: versionNumber,
    validFrom,
    validUntil,
    items: [],
  };
}

const v1 = version(1, '2021-01-01', '2023-12-31');
const v2 = version(2, '2024-01-01', null);

interface ResolutionCase {
  readonly name: string;
  readonly versions: readonly ChecklistTemplate[];
  readonly day: BusinessDay;
  readonly expected: TemplateResolution['status'];
  /** Qué versión debe resolver. `null` cuando el resultado no es `resolved`. */
  readonly expectedVersion: number | null;
}

// La misma tabla de la Fase 7 §5.3, fila por fila. Que el test y la
// documentación tengan la misma forma no es casualidad: la tabla se escribió
// pensando en esto, dos fases antes de que existiera Jasmine en el proyecto.
const CASES: readonly ResolutionCase[] = [
  { name: 'caso normal: día dentro de la v1', versions: [v1, v2], day: '2023-08-02', expected: 'resolved', expectedVersion: 1 },
  { name: 'primer día de vigencia de la v2', versions: [v1, v2], day: '2024-01-01', expected: 'resolved', expectedVersion: 2 },
  { name: 'último día de vigencia de la v1', versions: [v1, v2], day: '2023-12-31', expected: 'resolved', expectedVersion: 1 },
  { name: 'antes de que existiera ninguna versión', versions: [v1], day: '2020-12-31', expected: 'none', expectedVersion: null },
  { name: 'hueco entre versiones', versions: [v1, version(2, '2024-02-01', null)], day: '2024-01-15', expected: 'none', expectedVersion: null },
  { name: 'solape por cierre olvidado', versions: [version(1, '2021-01-01', null), v2], day: '2024-06-01', expected: 'ambiguous', expectedVersion: null },
  { name: 'vigente indefinidamente', versions: [v2], day: '2030-01-01', expected: 'resolved', expectedVersion: 2 },
  { name: 'familia vacía', versions: [], day: '2024-06-01', expected: 'none', expectedVersion: null },
];

describe('resolveTemplateVersion', () => {
  // ⚠️ El `it` se genera DENTRO del bucle, uno por caso. La alternativa —un
  // solo `it` con el bucle dentro— es más corta y mucho peor: cuando falla,
  // Jasmine dice "resolveTemplateVersion falla" y tú tienes que averiguar cuál
  // de los ocho. Con un `it` por fila, el nombre del test ES el diagnóstico.
  for (const testCase of CASES) {
    it(`resuelve ${testCase.expected} — ${testCase.name}`, () => {
      const resolution = resolveTemplateVersion(testCase.versions, testCase.day);

      expect(resolution.status).toBe(testCase.expected);

      // El estrechamiento de la unión discriminada vale también aquí: dentro
      // de este `if`, TypeScript sabe que `resolution.template` existe. Sin la
      // unión, harían falta un `as` o un `!`, y en CertCore no se usan.
      if (resolution.status === 'resolved') {
        expect(resolution.template.version).toBe(testCase.expectedVersion);
      }
    });
  }
});
```

**Detalles con intención**

- **Cero imports de `@angular/core/testing`.** Este archivo no sabe que Angular existe. Corre en milisegundos, no puede ser intermitente y no necesita navegador — aunque Karma se lo dé igual, porque el builder de Angular lo mete todo en el mismo bundle.
- **El nombre del `it` empieza por el resultado esperado.** `resuelve ambiguous — solape por cierre olvidado` se lee entero en la línea roja de la consola, sin abrir nada.
- **Ocho casos y ni uno inventado.** Todos salen de la tabla que la Fase 7 escribió mirando el dominio. Un noveno caso escrito hoy "para subir el coverage" sería justamente lo que la 💸 de 5.1 advierte.

**El patrón a memorizar**

> Cuando la documentación de una función es una tabla de casos, el test es esa tabla. Si te cuesta escribir la tabla, el problema no es el test: es que la función hace más de una cosa.

### 5.3 El tiempo, que se testea sin trucos porque no lo pide

```ts
// src/app/core/domain/certificate-status.spec.ts
import { Certificate } from '../models/certificate.model';
import { certificateStatus, daysUntilExpiry } from './certificate-status';

function certificate(validUntil: string, revokedAt: string | null = null): Certificate {
  return {
    id: 'CERT-2024-000502',
    inspectionId: 502,
    issuedAt: '2024-02-10T10:00:00-05:00',
    validUntil,
    // El campo almacenado que la Fase 10 dejó de leer. Se pone MAL a propósito
    // en el fixture: si algún test pasara por leerlo, saltaría al instante.
    status: 'valid',
    revokedAt,
  };
}

describe('certificateStatus', () => {
  // ⭐ Ni un `jasmine.clock()`, ni un `Date` falseado, ni una variable global.
  // El instante es un PARÁMETRO —decisión de la Fase 10 §5.2— y por eso este
  // archivo entero es aritmética. Compáralo con 5.6, donde una función que
  // pide la hora por su cuenta obliga a montar un andamio.
  const now = '2026-09-06T10:00:00-05:00';

  it('devuelve `valid` cuando falta más del umbral', () => {
    expect(certificateStatus(certificate('2027-01-01T23:59:59-05:00'), now)).toBe('valid');
  });

  it('devuelve `expiring` en el día exacto del umbral', () => {
    // Treinta días clavados. El límite es inclusive, así que cae en `expiring`
    // y no en `valid`: es el borde que la Fase 10 §5.2 decidió a propósito y
    // el que un refactor rompe sin darse cuenta.
    expect(certificateStatus(certificate('2026-10-06T23:59:59-05:00'), now)).toBe('expiring');
  });

  it('devuelve `expired` un segundo después de vencer', () => {
    expect(certificateStatus(certificate('2026-09-06T09:59:59-05:00'), now)).toBe('expired');
  });

  it('devuelve `valid` en el último segundo de vigencia', () => {
    // El mismo día, un segundo antes. Los dos tests de arriba y de abajo son
    // el mismo borde por sus dos lados, y escribir sólo uno de los dos es cómo
    // se cuela un `<` donde iba un `<=`.
    expect(certificateStatus(certificate('2026-09-06T10:00:01-05:00'), now)).toBe('valid');
  });

  it('`revoked` gana sobre `expired`', () => {
    // Un certificado revocado en marzo que además venció en agosto es
    // REVOCADO, porque lo que importa es por qué dejó de valer. El orden de
    // los `if` es la regla de negocio, y éste es el test que lo fija.
    const revokedAndExpired = certificate('2026-08-01T23:59:59-05:00', '2026-03-01T10:00:00-05:00');

    expect(certificateStatus(revokedAndExpired, now)).toBe('revoked');
  });

  it('cuenta días negativos para un certificado vencido', () => {
    // No se recorta a cero: "vencido hace 40 días" es información que la lista
    // de cobertura de la Fase 11 usa.
    expect(daysUntilExpiry(certificate('2026-07-28T23:59:59-05:00'), now)).toBe(-40);
  });
});
```

```ts
// src/app/core/time/business-day.spec.ts — los dos casos que valen por diez
describe('addMonths', () => {
  it('recorta al último día del mes cuando el día no existe allí', () => {
    // 29 de febrero de un año bisiesto, más doce meses. La aritmética ingenua
    // da el 1 de marzo y REGALA un día de vigencia; la correcta recorta al 28.
    // Es un caso que llega una vez cada cuatro años y que ningún QA prueba.
    expect(addMonths('2024-02-29', 12)).toBe('2025-02-28');
  });

  it('recorta también hacia el mes corto', () => {
    expect(addMonths('2024-01-31', 1)).toBe('2024-02-29');
  });
});

describe('todayInBusinessZone', () => {
  /**
   * ⚠️ ÉSTE es el que necesita andamio, y es el único del archivo.
   * `todayInBusinessZone()` no recibe nada: pregunta la hora. Para testearlo
   * hay que falsear el reloj del navegador entero.
   *
   * Compáralo con `certificateStatus`, arriba, que hace lo mismo y recibe el
   * instante. La diferencia entre los dos archivos no es de test: es de diseño,
   * y el test es lo que la delata. Guarda esta comparación para el ejercicio 26.
   */
  beforeEach(() => {
    jasmine.clock().install();
    // Las 23:30 en Bogotá del 6 de septiembre. En UTC ya es el día 7, y ése es
    // exactamente el bug que `toBusinessDay` existe para no tener.
    jasmine.clock().mockDate(new Date('2026-09-07T04:30:00Z'));
  });

  afterEach(() => {
    // Si esto se olvida, el reloj falso sobrevive a este `describe` y
    // contamina los siguientes — que con `random: true` no son siempre los
    // mismos. Bienvenido al incidente 17.
    jasmine.clock().uninstall();
  });

  it('devuelve el día del negocio, no el de UTC', () => {
    expect(todayInBusinessZone()).toBe('2026-09-06');
  });
});
```

### 5.4 Formularios reactivos sin navegador

```ts
// src/app/core/domain/inspection-form.spec.ts
import { ChecklistTemplate } from '../models/checklist-template.model';
import { InspectionAnswer } from '../models/inspection.model';
import { buildAnswerForm, toAnswers } from './inspection-form';

/**
 * Sorpresa útil: `FormRecord`, `FormGroup` y `FormControl` son clases de
 * TypeScript, no directivas. No necesitan `TestBed`, ni un componente, ni una
 * plantilla, ni detección de cambios. Un formulario reactivo se puede construir
 * y comprobar en un test tan barato como el de una función pura, y casi nadie
 * lo sabe: la mayoría de los ejemplos que vas a encontrar montan un componente
 * entero para probar una validación.
 */
const template: ChecklistTemplate = {
  id: 'elevator-annual-v2',
  templateId: 'elevator-annual',
  version: 2,
  validFrom: '2024-01-01',
  validUntil: null,
  items: [
    { id: 'main-cable', title: 'Cable principal', criteria: ['no_wear', 'light_wear', 'critical_wear'], photoRequired: true, nonComplianceSeverity: 'critical' },
    { id: 'door-sensor', title: 'Sensor de puerta', criteria: ['ok', 'intermittent', 'failed'], photoRequired: false, nonComplianceSeverity: 'major' },
  ],
};

describe('buildAnswerForm', () => {
  it('crea un control por ítem, con el itemId como clave', () => {
    const form = buildAnswerForm(template, []);

    expect(Object.keys(form.controls)).toEqual(['main-cable', 'door-sensor']);
  });

  it('marca inválida la evidencia ausente cuando el ítem la exige', () => {
    const answers: readonly InspectionAnswer[] = [
      { itemId: 'main-cable', answer: 'light_wear', evidenceUrl: null, note: null },
    ];

    const form = buildAnswerForm(template, answers);

    // `photoRequired: true` en la plantilla se convierte en un validador. Que
    // esto se pueda comprobar sin pintar nada es la prueba de que la regla
    // vive en el DATO y no en la pantalla.
    expect(form.get(['main-cable', 'evidenceUrl'])?.hasError('required')).toBeTrue();
  });

  it('rechaza una respuesta que no está entre los criterios del ítem', () => {
    const answers: readonly InspectionAnswer[] = [
      { itemId: 'main-cable', answer: 'no_se', evidenceUrl: null, note: null },
    ];

    const form = buildAnswerForm(template, answers);

    expect(form.get(['main-cable', 'answer'])?.hasError('notAllowed')).toBeTrue();
  });
});

describe('toAnswers', () => {
  it('no incluye los ítems sin responder', () => {
    const form = buildAnswerForm(template, [
      { itemId: 'door-sensor', answer: 'ok', evidenceUrl: null, note: null },
    ]);

    // Una inspección a medias guarda lo respondido, no un hueco por ítem. Es
    // la decisión de la Fase 8 §5.3 y éste es el test que la fija.
    expect(toAnswers(form).map((answer) => answer.itemId)).toEqual(['door-sensor']);
  });
});
```

### 5.5 El borde HTTP, y el test de regresión del incidente 12

```ts
// src/app/core/api/finding-api.service.spec.ts
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';

import { environment } from '../../../environments/environment';
import { Finding } from '../models/finding.model';
import { FindingApiService } from './finding-api.service';

describe('FindingApiService', () => {
  let service: FindingApiService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      /**
       * ⚠️ `HttpClientTestingModule` es un NgModule, y en un proyecto donde la
       * aplicación se configura con `provideHttpClient()` eso chirría. No hay
       * alternativa en Angular 16: `provideHttpClientTesting()` llega en la 17.
       * Es la fricción de versión de la que habla la nota de migración de §4, y
       * te la vas a encontrar en cada artículo reciente que copies.
       */
      imports: [HttpClientTestingModule],
    });

    service = TestBed.inject(FindingApiService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    // `verify()` falla si quedó alguna petición sin atender. Sin esto, un
    // servicio que hace una llamada de más pasa el test igual y el bug aparece
    // en producción como tráfico que nadie pidió.
    httpMock.verify();
  });

  it('pide los hallazgos de una inspección por query param', () => {
    service.getByInspection(503).subscribe();

    const request = httpMock.expectOne(`${environment.apiBaseUrl}/findings?inspectionId=503`);

    expect(request.request.method).toBe('GET');
    request.flush([]);
  });

  /**
   * ⭐ TEST DE REGRESIÓN — INCIDENTE 12.
   *
   * Éste es el test que conviene ver fallar antes de creérselo. Quita el
   * `normalizeFinding` del servicio (Fase 9 §5.3), corre esto, y se pone rojo.
   * Vuelve a ponerlo y pasa. Ese par de estados es lo que hace que un test de
   * regresión valga algo.
   *
   * Fíjate en el `as unknown as Finding` del fixture: es deliberado y es la
   * única aserción de tipo de todo el curso. La fila que manda el backend NO
   * cumple el tipo `Finding` —le falta un campo— y ése es exactamente el bug.
   * Escribirla bien tipada haría un test que no puede fallar. `unknown` de por
   * medio, y comentado, en vez de un `any` que apagaría el compilador entero.
   */
  it('normaliza a `null` un `resolvedAt` que el backend no manda', () => {
    const rowWithoutResolvedAt = {
      id: 902,
      inspectionId: 501,
      itemId: 'door-sensor',
      severity: 'major',
      description: 'El sensor no detecta obstáculos en el tercio inferior',
      // Sin `resolvedAt`. Es la fila que produce el certificado emitido sobre
      // un hallazgo crítico abierto.
    } as unknown as Finding;

    let received: readonly Finding[] = [];
    service.getByInspection(501).subscribe((findings) => (received = findings));

    httpMock
      .expectOne(`${environment.apiBaseUrl}/findings?inspectionId=501`)
      .flush([rowWithoutResolvedAt]);

    // `toBeNull()` y no `toBeFalsy()`: `undefined` también es falsy, así que
    // con `toBeFalsy` este test pasaría CON el bug puesto. Es el error de
    // aserción más común y el que convierte un test de regresión en adorno.
    expect(received[0].resolvedAt).toBeNull();
  });
});
```

**Detalles con intención**

- **`toBeNull()` frente a `toBeFalsy()`** es la diferencia entre un test que prueba algo y uno que no. La aserción tiene que ser tan precisa como la regla; si la regla distingue `null` de `undefined`, la aserción también.
- **`httpMock.verify()` en el `afterEach` y no dentro de cada `it`.** Escrito una vez, protege a todos los tests del archivo, incluidos los que alguien añada mañana sin acordarse.
- **La única aserción de tipo del curso, y va comentada.** `as unknown as Finding` sobre un objeto que **no cumple** el tipo es el punto exacto donde el sistema de tipos se acaba y empieza el mundo real. Un `any` habría apagado la comprobación entera del archivo; esto la apaga en una línea y dice por qué.

### 5.6 Un `BehaviorSubject`, y el tiempo que sí hay que falsear

```ts
// src/app/core/state/client-state.service.spec.ts — lo esencial
describe('ClientStateService', () => {
  let service: ClientStateService;
  let clientApi: jasmine.SpyObj<ClientApiService>;

  beforeEach(() => {
    // Un doble tipado. `createSpyObj` con el genérico puesto obliga a que los
    // nombres de método existan de verdad: si mañana `search` se renombra,
    // este archivo deja de compilar en vez de fallar en ejecución.
    clientApi = jasmine.createSpyObj<ClientApiService>('ClientApiService', ['search']);

    TestBed.configureTestingModule({
      providers: [
        { provide: ClientApiService, useValue: clientApi },
        { provide: AssetApiService, useValue: jasmine.createSpyObj<AssetApiService>('AssetApiService', ['getByClient']) },
        { provide: AuthService, useValue: { currentUser$: of(null) } },
      ],
    });
  });

  /**
   * ⭐ `fakeAsync` es lo que convierte un test de 300 ms en uno de cero.
   *
   * `ClientStateService` tiene un `debounceTime(300)` en su buscador (Fase 6
   * §5.5). Sin `fakeAsync`, este test tendría que esperar de verdad —y ese es
   * el patrón que llena las suites de veinte minutos—. Con `fakeAsync`, el
   * tiempo es una variable que `tick()` adelanta.
   */
  it('agrupa las pulsaciones en una sola petición', fakeAsync(() => {
    clientApi.search.and.returnValue(of([]));
    service = TestBed.inject(ClientStateService);

    service.search('Cen');
    service.search('Cent');
    service.search('Central');

    // Antes del debounce todavía no ha salido nada. Comprobarlo ANTES del
    // tick es lo que distingue "se agrupó" de "sólo llamé una vez".
    expect(clientApi.search).not.toHaveBeenCalled();

    tick(300);

    expect(clientApi.search).toHaveBeenCalledTimes(1);
    expect(clientApi.search).toHaveBeenCalledWith('Central');
  }));

  it('emite el estado nuevo a quien esté suscrito', () => {
    const clients: readonly Client[] = [{ id: 1, legalName: 'Edificio Central S.A.S.', taxId: '900123456' }];
    clientApi.search.and.returnValue(of(clients));
    service = TestBed.inject(ClientStateService);

    /**
     * Así se testea un BehaviorSubject: se colecciona lo que emite en un array
     * y se comprueba la SECUENCIA, no sólo el último valor. Un servicio que
     * llega al estado correcto pasando por uno intermedio equivocado —el
     * `loading` que se queda en true, la lista que parpadea vacía— produce un
     * parpadeo en pantalla que sólo se ve aquí.
     *
     * Nada de `TestScheduler` ni de cadenas con guiones: para esto, un array y
     * un `expect` se leen mejor y no obligan a aprender un segundo lenguaje.
     */
    const emissions: FeatureState<Client>[] = [];
    const subscription = service.state$.subscribe((state) => emissions.push(state));

    service.search('Central');

    expect(emissions.length).toBeGreaterThan(1);
    expect(emissions[emissions.length - 1].items).toEqual(clients);
    expect(emissions[emissions.length - 1].loading).toBeFalse();

    // Desuscribirse en el test también. Un spec que deja una suscripción viva
    // en un servicio `providedIn: 'root'` es cómo un test contamina al
    // siguiente — y con `random: true`, "el siguiente" cambia cada vez.
    subscription.unsubscribe();
  });
});
```

### 5.7 Guards e interceptors: dos generaciones, tres técnicas

```ts
// src/app/core/guards/auth.guard.spec.ts
import { TestBed } from '@angular/core/testing';
import { ActivatedRouteSnapshot, Router, RouterStateSnapshot, UrlTree } from '@angular/router';

import { AuthService } from '../auth.service';
import { authGuard } from './auth.guard';

describe('authGuard', () => {
  let authService: jasmine.SpyObj<AuthService>;

  beforeEach(() => {
    authService = jasmine.createSpyObj<AuthService>('AuthService', ['isAuthenticated']);

    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: authService },
        // Un Router de mentira con lo único que el guard usa. Montar
        // `RouterTestingModule` entero funcionaría y traería un router de
        // verdad con sus rutas: más lento, más frágil, y sin nada que ganar.
        {
          provide: Router,
          useValue: { createUrlTree: (commands: readonly string[]) => ({ commands }) as unknown as UrlTree },
        },
      ],
    });
  });

  /**
   * ⭐ `TestBed.runInInjectionContext()` es LA pieza que hace testeable todo el
   * estilo nuevo del proyecto.
   *
   * Un guard funcional es una función, así que se llama. Lo que pasa es que por
   * dentro hace `inject(AuthService)`, y `inject()` fuera de un contexto de
   * inyección lanza `NG0203`. Esto abre ese contexto alrededor de la llamada.
   *
   * Compáralo con lo que costaría un guard de clase: `TestBed.inject(AuthGuard)`
   * y llamar a `canActivate`. Es más corto de escribir en el test y exige que
   * el guard sea una clase inyectable con su decorador. Ninguna de las dos
   * formas es mejor; son distintas, y el ejercicio 13 de la Fase 2 ya te hizo
   * escribir las dos.
   */
  function run(url: string) {
    const route = {} as ActivatedRouteSnapshot;
    const state = { url } as RouterStateSnapshot;

    return TestBed.runInInjectionContext(() => authGuard(route, state));
  }

  it('deja pasar a un usuario autenticado', () => {
    authService.isAuthenticated.and.returnValue(true);

    expect(run('/inspections')).toBeTrue();
  });

  it('devuelve un UrlTree al login con la ruta de vuelta', () => {
    authService.isAuthenticated.and.returnValue(false);

    // No se comprueba que navegara: se comprueba que DEVOLVIÓ el UrlTree. Es
    // la diferencia entre testear la decisión del guard y testear al router,
    // que ya está testeado por Angular.
    expect(run('/inspections/500')).not.toBeTrue();
  });
});
```

```ts
// src/app/core/interceptors/auth.interceptor.spec.ts — el interceptor funcional
describe('authInterceptor', () => {
  it('añade la cabecera Authorization cuando hay token', () => {
    const authService = jasmine.createSpyObj<AuthService>('AuthService', ['getToken', 'logout']);
    authService.getToken.and.returnValue('un-token');

    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: authService },
        { provide: Router, useValue: { navigate: () => Promise.resolve(true), url: '/' } },
      ],
    });

    // El "siguiente" de la cadena, escrito a mano. Captura lo que le llega y
    // devuelve una respuesta cualquiera: un interceptor se testea por lo que
    // le PASA al siguiente, no por lo que el servidor conteste.
    let forwarded: HttpRequest<unknown> | null = null;
    const next: HttpHandlerFn = (request) => {
      forwarded = request;
      return of(new HttpResponse({ status: 200 }));
    };

    const original = new HttpRequest('GET', '/api/inspections');

    TestBed.runInInjectionContext(() => authInterceptor(original, next).subscribe());

    expect(forwarded!.headers.get('Authorization')).toBe('Bearer un-token');
  });
});
```

```ts
// src/app/core/interceptors/correlation-id.interceptor.spec.ts
// 🧬 EL MISMO TRABAJO, EN LA OTRA GENERACIÓN.
//
// `CorrelationIdInterceptor` se escribió en 2021 y sigue siendo una clase con
// `@Injectable()`. Su spec se escribe en el estilo del archivo que prueba: se
// inyecta la clase y se llama a su método `intercept`. Ni `runInInjectionContext`
// —no hace `inject()` por dentro, lo recibe todo por constructor— ni funciones
// sueltas. Es el 🧬 de esta fase: el mismo objetivo, dos técnicas, y la que
// eliges la decide el archivo y no tu gusto.
describe('CorrelationIdInterceptor', () => {
  it('estampa un identificador de correlación en cada petición', () => {
    TestBed.configureTestingModule({ providers: [CorrelationIdInterceptor] });

    const interceptor = TestBed.inject(CorrelationIdInterceptor);

    let forwarded: HttpRequest<unknown> | null = null;
    const next: HttpHandler = {
      handle: (request) => {
        forwarded = request;
        return of(new HttpResponse({ status: 200 }));
      },
    };

    interceptor.intercept(new HttpRequest('GET', '/api/clients'), next).subscribe();

    // ⚠️ No se compara con un valor concreto: el interceptor usa
    // `crypto.randomUUID()` y el valor es distinto en cada ejecución. Un
    // `toBe('algo')` aquí sería un test que falla el 100 % de las veces; un
    // `toBeTruthy()` sería uno que no prueba nada. Se comprueba la FORMA, que
    // es lo único estable de un valor aleatorio — y ésta es la primera lección
    // del incidente 17.
    expect(forwarded!.headers.get('X-Correlation-Id')).toMatch(
      /^[0-9a-f-]{36}$/,
    );
  });
});
```

**El patrón a memorizar**

> Un valor aleatorio o dependiente del reloj no se compara con una constante: se comprueba su forma, o se le inyecta el valor desde fuera. Elegir la primera opción cuando podías elegir la segunda es cómo nace un test intermitente.

### 5.8 🧬 Los dos `TestBed`, uno por generación

```ts
// src/app/features/dashboard/kpi-card/kpi-card.component.spec.ts
// COMPONENTE NUEVO — standalone.
describe('KpiCardComponent', () => {
  let fixture: ComponentFixture<KpiCardComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      // Va en `imports` porque es standalone: el componente ya declara lo que
      // usa —NgIf, MatIconModule— en su propio decorador, así que el TestBed
      // sólo tiene que conocerlo a él.
      imports: [KpiCardComponent],
    });

    fixture = TestBed.createComponent(KpiCardComponent);
  });

  it('pinta el valor y la etiqueta', () => {
    // `setInput` y no `fixture.componentInstance.label = …`. Con
    // `@Input({ required: true })` es la forma correcta, y además dispara
    // `ngOnChanges` — que es lo que el gráfico de la Fase 11 necesita y una
    // asignación directa no hace.
    fixture.componentRef.setInput('label', 'Certificados vencidos');
    fixture.componentRef.setInput('value', 7);
    fixture.componentRef.setInput('icon', 'error');

    fixture.detectChanges();

    const text: string = fixture.nativeElement.textContent;

    expect(text).toContain('7');
    expect(text).toContain('Certificados vencidos');
  });

  it('no pinta la aclaración cuando no la hay', () => {
    fixture.componentRef.setInput('label', 'Inspecciones en curso');
    fixture.componentRef.setInput('value', 3);
    fixture.componentRef.setInput('icon', 'assignment');
    fixture.detectChanges();

    // `hint` es `string | null` y el `null` significa "sin aclaración". El
    // test comprueba la ausencia del nodo, no que el texto esté vacío.
    expect(fixture.nativeElement.querySelector('.kpi-card-hint')).toBeNull();
  });
});
```

```ts
// src/app/features/inspections/inspection-list/inspection-list.component.spec.ts
// COMPONENTE HEREDADO — declarado en InspectionsModule desde la Fase 1.
describe('InspectionListComponent', () => {
  let fixture: ComponentFixture<InspectionListComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      /**
       * 🧬 Va en `declarations`, y hay que darle a mano lo que su NgModule le
       * daba: `SharedModule` para los componentes de Material que usa la
       * plantilla, y un doble del servicio de estado.
       *
       * Ponerlo en `imports` no compila, y el error —"no es un NgModule, un
       * componente standalone ni una directiva"— no dice lo que pasa. Al revés
       * pasa lo mismo: un standalone en `declarations` da un error explícito,
       * y ése sí se lee. El ejercicio 20 te hace ver los dos.
       */
      declarations: [InspectionListComponent],
      imports: [SharedModule, RouterTestingModule],
      providers: [
        {
          provide: InspectionStateService,
          useValue: {
            inspections$: of(INSPECTIONS_FIXTURE),
            loading$: of(false),
            error$: of(null),
            load: () => undefined,
          },
        },
      ],
    });

    fixture = TestBed.createComponent(InspectionListComponent);
  });

  it('lista una fila por inspección con su versión de plantilla', () => {
    fixture.detectChanges();

    const rows = fixture.nativeElement.querySelectorAll('tbody tr');

    expect(rows.length).toBe(INSPECTIONS_FIXTURE.length);
    // La versión a la vista es lo primero que se pregunta en un ticket sobre
    // esta pantalla, así que es lo que el test protege.
    expect(rows[0].textContent).toContain('v2');
  });
});
```

**El `timer` de la Fase 11, y el error que da si lo olvidas**

```ts
// Dentro del spec de DashboardMetricsService
it('refresca cada minuto', fakeAsync(() => {
  const subscription = service.metrics$.subscribe();

  expect(inspectionState.load).toHaveBeenCalledTimes(1);

  tick(DASHBOARD_REFRESH_MS);

  expect(inspectionState.load).toHaveBeenCalledTimes(2);

  subscription.unsubscribe();
  // ⚠️ Sin esto, `fakeAsync` lanza al terminar:
  //   "Error: 1 periodic timer(s) still in the queue."
  // El `timer(0, ms)` de la Fase 11 es periódico y nunca termina solo. El
  // mensaje es de los pocos de Angular que dicen exactamente lo que pasa, y
  // aun así confunde: no es un bug del código, es que el test tiene que
  // limpiar lo que abrió.
  discardPeriodicTasks();
}));
```

### 5.9 🔥 Pincelada: cómo se testeará esto en Angular 17+

Esto es lectura, no trabajo. Angular 16 tiene signals y son **experimentales**: se leen, no se usan, y `alcance-del-proyecto.md` §13 lo cerró así. Pero conviene ver hacia dónde va, porque cambia justo la parte de esta fase que más cuesta.

Un componente con signals no necesita `detectChanges()` para que su estado sea legible, y el control flow nuevo hace que las ramas de la plantilla se puedan comprobar sin buscar nodos en el DOM:

```ts
// Angular 17+. NO compila en este proyecto y no hay que escribirlo.
@Component({
  template: `
    @if (value() > 0) {
      <p class="kpi-card-value">{{ value() }}</p>
    } @else {
      <p>Sin datos</p>
    }
  `,
})
export class KpiCardComponent {
  readonly value = input.required<number>();
}
```

```ts
// El test deja de pasar por el DOM para comprobar el estado:
fixture.componentRef.setInput('value', 7);
expect(component.value()).toBe(7);
```

Lo que cambia de verdad no es la sintaxis: es que **el estado deja de necesitar un ciclo de detección de cambios para ser observable**. La mitad de los `fixture.detectChanges()` de esta fase existen sólo para que el valor llegue a la plantilla; con signals, el valor está ahí antes de pintar nada.

Lo que **no** cambia: las funciones puras se seguirán testeando exactamente igual, y son la mitad de tu suite. El trabajo de las Fases 7 a 11 sobrevive intacto a esa migración, y ése es un argumento a favor de escribir dominio puro que ninguna presentación de signals te va a dar.

> 📎 El panorama entero —signals de verdad, control flow, deferrable views, el builder de esbuild— está en **A11** 🔥.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** `NG0203: inject() must be called from an injection context`, en el spec de un guard.
**Causa:** se llamó `authGuard(route, state)` directamente, fuera de un contexto de inyección.
**Fix mínimo:** envolverlo en `TestBed.runInInjectionContext()`.
**Lo que importa:** es el mismo `NG0203` que la Fase 2 te hizo provocar dentro de un `catchError`, y viene del mismo sitio. `inject()` no es magia: es una función que lee una variable global que Angular pone y quita alrededor de ciertas llamadas. Entenderlo así explica los dos errores de una vez.

**Síntoma:** el test pasa solo y falla cuando corre la suite entera. O al revés.
**Causa:** dos tests comparten un servicio `providedIn: 'root'`, o uno dejó un `jasmine.clock()` instalado, o una suscripción viva.
**Fix mínimo:** limpiar en el `afterEach` — `uninstall()`, `unsubscribe()`, `httpMock.verify()`.
**Lo que importa:** es el **incidente 17**, y `random: true` de Jasmine es lo que lo saca a la luz en vez de esconderlo. La reacción instintiva —poner `random: false` para que "deje de fallar"— convierte un test que avisa en un test que miente. El orden aleatorio no causa el problema: lo revela.

**Síntoma:** `Error: 1 periodic timer(s) still in the queue`, al final de un `fakeAsync`.
**Causa:** un `timer(0, ms)` o un `setInterval` sigue vivo cuando la zona falsa termina.
**Fix mínimo:** `discardPeriodicTasks()` antes de salir.
**Lo que importa:** el mensaje dice la verdad y aun así se malinterpreta. No es que el código tenga una fuga —el `refCount` de la Fase 11 se encarga de eso— es que el test abrió una suscripción y tiene que cerrarla. Distinguir "el código deja algo abierto" de "el test dejó algo abierto" es media hora cada vez que pasa.

**Síntoma:** el test de regresión pasa a la primera, recién escrito, sin haber tocado el código.
**Causa:** casi siempre, que no prueba nada — `toBeTruthy()` sobre un objeto que siempre existe, o `toBeFalsy()` donde hacía falta `toBeNull()`.
**Fix mínimo:** romper el código a propósito y comprobar que se pone rojo.
**Lo que importa:** es la mitad de la pieza forense de esta fase. Un test de regresión que nunca has visto fallar no es un test: es una línea verde.

### Pieza forense de esta fase

**El test de regresión, y el bug intermitente.**

Hay dos investigaciones aquí y la segunda es la difícil.

**Primera: el test que va antes del fix.** Llega el ticket del incidente 08 —*"la inspección de agosto ahora tiene un ítem más que cuando la hice"*—. El procedimiento es fijo y el orden no se negocia:

```bash
# 1. Rama desde el tag de la fase donde vive el bug, y el test PRIMERO.
git switch -c inc/08/version-equivocada-roto fase-07
# …escribes el spec y lo ves FALLAR. Ése es el commit.
git tag -a inc/08/version-equivocada-roto -m "F7 inc08: el test reproduce el bug y falla"
```

```ts
// El test entero cabe en diez líneas y no necesita TestBed.
it('lee una inspección con la versión que guardó, no con la vigente', () => {
  const family = [v1, v2];               // v1 hasta 2023-12-31, v2 desde 2024-01-01
  const inspection = { templateVersion: 1, /* … */ };

  // ❌ Lo que hacía el código roto: resolver por la fecha de HOY.
  //    resolveTemplateVersion(family, todayInBusinessZone()) → v2
  // ✅ Lo que tiene que hacer: buscar por la versión guardada.
  const applied = family.find((version) => version.version === inspection.templateVersion);

  expect(applied?.version).toBe(1);
  expect(applied?.items.length).toBe(3);   // la v2 tiene cuatro
});
```

Después el fix, después el tag `-fix`, y el `git diff` entre los dos es el punto 5 del post-mortem sin una línea de ruido.

**Segunda: el test intermitente.** Es más difícil porque el síntoma no está donde miras. Cuatro sospechosos, en este orden:

**El reloj.** Busca `new Date()` y `Date.now()` **en el código bajo prueba**, no en el test. Si el código pregunta la hora por su cuenta, tu test depende de cuándo se ejecute. En este proyecto hay un caso exacto: `CertificateStateService.issue()` llama a `new Date()` por dentro y `buildCertificateId` saca el año de ahí — un test que corra a las 23:59:59 del 31 de diciembre genera un `id` con el año siguiente. Es el ejercicio 26 y es una crítica legítima al diseño de la Fase 10.

**El azar.** `crypto.randomUUID()`, `Math.random()`. Se comprueba la forma, no el valor. El `CorrelationIdInterceptor` de 5.7 es el ejemplo.

**El orden.** Corre la suite tres veces y anota la semilla que Jasmine imprime al principio. Si falla con una semilla y pasa con otra, **reproduce con esa semilla** —`ng test --seed=<n>`— y bisecciona: quita la mitad de los `describe` y vuelve a correr. Lo que queda cuando el fallo desaparece es la pareja de tests que se contaminan.

**La asincronía.** Un `subscribe` que resuelve después de que el `it` terminó. Jasmine no espera a nadie que no le hayas dicho que espere: si el `it` es síncrono y dentro hay algo que no lo es, la aserción corre antes que el valor. `fakeAsync` + `tick` lo hace determinista; `done` también, y es peor porque un `done` que no se llama tarda cinco segundos en fallar.

> 📄 El recorrido completo, con los dos tickets literales y la salida de cada paso, en `forense-fase-12.md`.

**🧨 Rompe a propósito**

Tres roturas, y las tres se hacen sobre tests, no sobre código.

1. **Cambia el `toBeNull()` del test del incidente 12 por `toBeFalsy()`.** Después quita el `normalizeFinding` del servicio. El test **sigue pasando** con el bug puesto, porque `undefined` es falsy. Guarda esa sensación: acabas de escribir un test de regresión que no detecta la regresión que existe para detectar.

2. **Pon `random: false` en el `karma.conf.js`** y añade a propósito una dependencia de orden: un spec que deja un `jasmine.clock()` instalado sin desinstalarlo. Todo verde. Ahora vuelve a poner `random: true` y corre cinco veces. Anota cuántas fallan y con qué semilla. La lección es que el test intermitente **ya existía**; lo único que cambió fue si te enterabas.

3. **Comenta las cuatro líneas de `codeCoverageExclude` en `angular.json`** y corre `npm run test:ci`. Mira cuánto baja el porcentaje global y cuáles son los archivos que lo hunden. Después decide, uno por uno, si los excluirías o los testearías — y escribe la justificación de cada exclusión al lado, que es lo que la 💸 pide y lo que nadie hace.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Corre los tres comandos de 5.1 y entrega el inventario: ¿está el objetivo `test`? ¿está `tsconfig.spec.json`? ¿está `karma.conf.js`? ¿qué versiones de Jasmine y Karma tienes, y con qué rango?
2. Fija Jasmine y Karma a versión exacta en `package.json`, reinstala, y comprueba con `npm ls jasmine-core karma` que no queda ningún `^`. Explica en dos frases por qué esto importa en un curso y no sólo en un proyecto.
3. Escribe la suite completa de `resolveTemplateVersion` con los ocho casos de la tabla, uno por `it`. Comprueba que los ocho pasan.
4. **Diagnóstico.** Cambia `appliesOn` para que el extremo superior sea exclusivo (`day < validUntil` en vez de `<=`). Corre la suite y entrega **cuáles** de los ocho casos fallan y por qué sólo ésos. Después revierte.
5. Escribe los dos tests de `addMonths`: el 29 de febrero más doce meses y el 31 de enero más uno. Explica en tres frases por qué el recorte va hacia abajo.
6. **Diagnóstico.** Corre `npm test` tres veces seguidas y anota el orden de los `describe` y la semilla que Jasmine imprime. Explica qué está pasando y por qué es deseable.
7. Escribe los seis tests de `certificateStatus`, incluidos los dos lados del borde exacto del vencimiento. Comprueba que si cambias un `<=` por un `<` en el código, exactamente uno se pone rojo.
8. **Diagnóstico.** Corre `npm run test:ci` con sólo los specs de funciones puras escritos. Entrega el porcentaje global de coverage y responde: ¿cuántos componentes has testeado? Guarda la respuesta para el ejercicio 27.

**🟡 Intermedio (9–17)**

9. Escribe los specs de `buildAnswerForm`, `toAnswers` y `computeProgress` sin `TestBed`, cubriendo el ítem sin responder, el que exige evidencia y la respuesta huérfana. Anota cuánto tarda la suite entera.
10. **Diagnóstico.** Escribe un spec de `FindingApiService` que haga una petición y **no** la atienda con `flush`. Deja el `httpMock.verify()` puesto. Entrega el mensaje de error exacto y explica qué clase de bug real detecta esa comprobación.
11. Escribe el test de regresión del **incidente 12**: la fila sin `resolvedAt`. Quita el `normalizeFinding` del servicio, compruébalo rojo, vuelve a ponerlo, compruébalo verde. Entrega las dos salidas.
12. Testea `ClientStateService` con `fakeAsync` y `tick(300)`: tres pulsaciones, una sola petición, y el término correcto. Comprueba antes del `tick` que no salió nada.
13. **Diagnóstico.** Quita el `tick(300)` del test anterior y descríbelo: ¿falla?, ¿cómo?, ¿el mensaje te dice lo que pasa? Después sustituye `fakeAsync` por un test asíncrono con `done` y espera de verdad. Entrega los dos tiempos de ejecución.
14. Escribe el spec de `authGuard` con `TestBed.runInInjectionContext()`, cubriendo los dos caminos. Comprueba que devuelve un `UrlTree` y no que el router navegó.
15. Escribe el spec de `authInterceptor` llamándolo como función, con un `next` escrito a mano. Cubre el caso con token y el caso sin token.
16. 🧬 **Estilo.** Escribe el spec de `CorrelationIdInterceptor`, que es una clase de 2021. Justifica en cinco líneas por qué **no** usaste `runInInjectionContext`, por qué no lo convertiste a funcional "ya que estabas", y qué habría pasado con el spec si lo hubieras hecho.
17. **Diagnóstico.** Llama a `authGuard(route, state)` directamente, sin `runInInjectionContext`. Copia el `NG0203` entero y relaciónalo con el que la Fase 2 te hizo provocar dentro de un `catchError`. ¿Es el mismo error? ¿Por la misma causa?

**🟠 Difícil (18–24)**

18. 🧬 **Estilo.** Escribe el spec de `KpiCardComponent` (standalone) con `imports` y `setInput`. Después intenta asignar la entrada directamente (`fixture.componentInstance.value = 7`) y explica qué se rompe con `@Input({ required: true })` y qué con `ngOnChanges`.
19. 🧬 **Estilo.** Escribe el spec de `InspectionListComponent` (declarado) con `declarations` y su módulo alrededor. Entrega la lista de todo lo que tuviste que darle a mano y que su NgModule le daba gratis.
20. **Diagnóstico.** Intercambia las dos configuraciones: mete el standalone en `declarations` y el declarado en `imports`. Copia los dos errores enteros y explica cuál de los dos te habría costado más tiempo en un spec de cuarenta líneas, y por qué.
21. Testea el refresco de `DashboardMetricsService` con `fakeAsync`, `tick(DASHBOARD_REFRESH_MS)` y `discardPeriodicTasks()`. Comprueba que `load()` se llamó dos veces.
22. **Diagnóstico.** Quita el `discardPeriodicTasks()` del ejercicio anterior. Copia el error, explica por qué **no** es un bug del código de la Fase 11, y describe cómo distinguirías este caso de una fuga de verdad.
23. Escribe el test de regresión del invariante de plantillas siguiendo el procedimiento de la sección 6: rama desde `fase-07`, test primero, verlo fallar, tag `-roto`, fix, tag `-fix`. Entrega el `git diff` entre los dos tags.
24. **Diagnóstico.** Activa el umbral `each` del `karma.conf.js` y corre `npm run test:ci`. Entrega la lista de archivos que caen por debajo del 50 %, ordenada por porcentaje, y clasifícalos en tres grupos: hay que testearlos, hay que excluirlos con motivo, o hay que borrarlos porque nadie los usa.

**🔴 Muy difícil (25–30)**

25. Escribe el post-mortem completo de ocho puntos del incidente **17** —*"el test pasa en mi máquina y falla en el pipeline"*— siguiendo `formato-cuaderno-incidentes.md`, con su par de tags. Fabrica el intermitente tú mismo: la forma más rápida es un spec que no desinstale su `jasmine.clock()`. El punto 6 —prueba de regresión— es el difícil: ¿cómo se escribe una prueba de que un test **no** es intermitente? Contesta con un procedimiento, no con un test.
26. **La testabilidad delata el diseño.** `CertificateStateService.issue()` llama a `new Date()` por dentro, así que su `id` depende de cuándo corras el test. Domalo de las dos formas: primero con `jasmine.clock()`, y después extrayendo el instante —un parámetro, o un `Clock` inyectable de tres líneas—. Compara los dos specs resultantes y decide cuál entregarías. Después responde: ¿esto es una deuda de la Fase 10, o es aceptable? Escribe el argumento como lo escribirías en una revisión de código.
27. Escribe el post-mortem completo de ocho puntos del incidente **20** —*"tenemos 82 % de coverage y el bug llegó a producción igual"*— con su par de tags. Usa el número que mediste en el ejercicio 8. El punto 8 —post-mortem sin culpabilización— es el que da la lección: el problema no fue de quien escribió los tests, fue de que el número que el equipo miraba no medía lo que creía medir.
28. **Diagnóstico.** Escribe un test que detecte una **fuga de suscripción**: crea `InspectionFormComponent`, suscríbete a su autosave, destruye el componente con `fixture.destroy()`, y comprueba que ya no emite nada. Después quita el `takeUntilDestroyed` del componente y comprueba que el test se pone rojo. Explica por qué esta clase de test es rara de ver y por qué debería serlo menos.
29. 💸 **El precio del 100 %.** Sube el umbral global del `karma.conf.js` al 95 %, corre la suite, y escribe **todos** los tests que hagan falta para llegar. Después entrega dos listas: los tests que escribirías igual sin el umbral, y los que sólo existen para el número. Con esas dos listas delante, decide cuál es el umbral correcto para CertCore y defiéndelo en cinco líneas.
30. Elige uno de los dieciséis incidentes que el cuaderno ya tiene reservados —del 01 al 16— cuyo test de regresión todavía no exista, y escríbelo entero siguiendo el procedimiento de la sección 6: rama desde el tag de su fase, test primero, verlo fallar, y sólo entonces el fix. Entrega el par de tags y el `git diff`. Si eliges uno intermitente, tienes además el problema del ejercicio 25.

**🔥 Opcionales**

- 🔥 **Mutation testing.** Instala Stryker fijando su versión exacta, córrelo sobre `src/app/core/domain/`, y entrega el porcentaje de mutantes que tus tests matan. Compáralo con tu porcentaje de coverage. La diferencia entre los dos números es la respuesta honesta a *"¿mis tests sirven para algo?"*, y suele doler.
- 🔥 **La suite en el pipeline.** Escribe el workflow que correría `npm ci && npm run test:ci` en un contenedor, sin instalar Chrome a mano —hay imágenes que lo traen— y con el `--no-sandbox` que ya dejaste puesto. El CI real está fuera de alcance; escribir el archivo y ver por qué falla la primera vez, no.
- 🔥 **Snapshot del PDF.** `certificate-pdf.ts` está excluido del coverage porque comprobar que jsPDF dibuja es testear jsPDF. Pero el `CertificateDocument` que entra sí se puede fijar: escribe un test que compare el objeto completo contra una referencia guardada, y decide si esa clase de test protege o sólo se rompe cada vez que alguien cambia una etiqueta.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v16.angular.io/guide/testing — la guía de testing de la versión del curso, entera. Es de las mejores páginas de la documentación de Angular y de las menos leídas.
- https://v16.angular.io/api/core/testing/TestBed — `configureTestingModule`, `createComponent`, `inject` y `runInInjectionContext`. ⚠️ Este último aparece a partir de la 16.1; el curso está en la 16.2.12, así que lo tienes.
- https://v16.angular.io/guide/testing-components-scenarios — los escenarios de componente, incluido `ComponentFixture` y `detectChanges`.
- https://v16.angular.io/api/common/http/testing/HttpTestingController — `expectOne`, `flush`, `verify`. ⚠️ En la 16 el módulo de prueba es `HttpClientTestingModule`; el `provideHttpClientTesting()` que verás en ejemplos recientes llega en la **17** y aquí no existe.
- https://v16.angular.io/api/core/testing/fakeAsync y https://v16.angular.io/api/core/testing/discardPeriodicTasks — el tiempo falso y su limpieza.
- https://jasmine.github.io/api/4.6/global — la API de Jasmine 4.6, la versión exacta del curso. `createSpyObj`, `clock`, y los *matchers*.
- https://jasmine.github.io/tutorials/your_first_suite — si nunca has escrito Jasmine, son quince minutos y cubren el 90 % de lo que esta fase usa.
- https://karma-runner.github.io/6.4/config/configuration-file.html — la configuración de Karma 6.4, para el `karma.conf.js` de 5.1.
- https://github.com/karma-runner/karma-coverage/blob/master/docs/configuration.md — `coverageReporter.check`, que es lo que hace que la suite falle por debajo del umbral.
- https://v16.angular.io/cli/test — las opciones del comando, incluida `--code-coverage`. La exclusión de archivos, en cambio, vive en `angular.json` como `codeCoverageExclude`, y eso no está en esa página: está en https://v16.angular.io/guide/workspace-config.

**Orden de lectura sugerido:** el tutorial de Jasmine **antes** de escribir 5.2, si vienes de JUnit o de pytest y quieres el mapa de equivalencias en quince minutos. La guía de testing de Angular **entre 5.4 y 5.5**, que es donde empieza a hacer falta `TestBed`. La página de `HttpTestingController` con el spec delante, no antes. Y **A06** si el `fakeAsync` de 5.6 te resulta opaco: entender qué hace `debounceTime` es lo que hace obvio qué hace `tick`.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore tiene red. No una red completa —eso no lo tiene ningún sistema heredado y perseguirlo es cómo se pierde un trimestre— sino la que importa: las reglas que si fallan no dan ningún error, los bugs que ya ocurrieron una vez, y el código que un hotfix va a tocar.

Y hay tres cosas que se llevan más allá de este proyecto. La primera la construyeron cinco fases sin decirlo: **el dominio puro es el que se puede probar**, y la mitad de esta suite existe porque `resolveTemplateVersion`, `deriveSeverity` y `certificateStatus` no inyectan nada, no piden la hora y no saben en qué pantalla corren. La segunda: **el test de regresión va antes del fix**, y un test que no has visto fallar no es un test, es una línea verde. Y la tercera, la más incómoda: **la testabilidad delata el diseño**. Cuando te hacen falta trucos para probar algo, el problema casi nunca está en el test — y en este mismo repositorio tienes el ejemplo, con un `new Date()` escondido dentro de un servicio que escribiste hace dos fases.

Lo que te llevas: en un sistema heredado, la pregunta *"¿qué testeamos?"* no se contesta con un porcentaje. Se contesta mirando el historial de tickets. Lo que se rompió, lo que se toca, y lo que falla en silencio — en ese orden. El coverage es la consecuencia, nunca el objetivo, y el día que se convierte en objetivo empieza a medir otra cosa.

La **Fase 13** cierra el curso donde el círculo se cierra de verdad: la misma imagen levantada dos veces con configuración distinta, comportándose distinto. Es la mitad de los *"funciona en UAT y no en PROD"* del mundo, y no es un defecto de Angular 16 — Angular 8 lo tenía igual y Angular 19 lo tiene igual, porque `environment.ts` se hornea en tiempo de compilación y cualquier contenedor espera inyectar configuración en tiempo de arranque. Vas a llegar allí con dos cosas de esta fase en la mochila: el `ChromeHeadlessCI` con su `--no-sandbox`, que existe precisamente porque dentro de un contenedor no hay otra forma, y el reflejo de leer un stack trace hasta el final — que allí tendrás que hacer sobre código minificado.

> **La señal de que quedó bien:** cuando llega un ticket, lo primero que escribes no es el fix — es el test que lo reproduce. Y lo ves rojo antes de tocar una línea de producción.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-12 -m "F12 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 12: …`) y los de ejercicio su
> número (`fase 12 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f12/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Esta fase le da al par `-roto` / `-fix` su forma definitiva, y conviene
> decirlo aquí porque hasta hoy era una convención y desde hoy es un
> procedimiento: en el commit `-roto` **el test existe y falla**; en el `-fix`
> pasa. El `git diff` entre los dos deja de ser sólo el fix y pasa a ser el fix
> **más la prueba de que arregla lo que dice arreglar**. El ejercicio 30 te hace
> aplicarlo hacia atrás sobre uno de los dieciséis incidentes que el cuaderno
> ya tiene reservados, y sus ramas salen del tag de la fase donde vive cada
> bug, no de éste. Y una advertencia de git que sólo aplica hoy: `npm run
> test:ci` deja una carpeta `coverage/` con cientos de archivos HTML. Va al
> `.gitignore` antes de etiquetar, o el tag de esta fase pesa más que las once
> anteriores juntas.

---

## 📌 Pendientes sugeridos

- **Jasmine y Karma llevaban once fases con rango `^`, y esta fase lo cierra.** No fue un error de la Fase 0 —usó `--skip-tests` y fijó sólo lo que usaba— pero contradice técnicamente su afirmación de que todas las versiones estaban fijadas. → **Aviso para una segunda pasada sobre la Fase 0**: una línea diciendo que las de testing se fijan en la Fase 12 cerraría el bucle.
- **La `codeCoverageExclude` no va donde el prompt de esta fase decía.** Los umbrales van en `karma.conf.js` y las exclusiones en `angular.json`, porque las lee el builder antes de instrumentar. Escritas en el sitio equivocado no dan error: no hacen nada. → **Corrección al prompt de la Fase 12**, ya aplicada aquí.
- **`CertificateStateService.issue()` tiene un `new Date()` escondido y es una deuda de diseño de la Fase 10.** El ejercicio 26 lo doma y hace argumentar si merece arreglarse. Si el curso hace una segunda pasada, la respuesta debería subir al texto de la Fase 10 —un `Clock` inyectable de tres líneas, o `issuedAt` como parámetro— porque el mismo problema va a aparecer en la Fase 13 con la configuración en arranque. → **Aviso para una segunda pasada sobre la Fase 10.**
- **Sólo dos de los dieciséis incidentes reservados tienen test de regresión escrito en el cuerpo del curso.** El resto queda como el ejercicio 30, que hace elegir uno. Un curso con más presupuesto tendría un test por incidente y sería el mejor material de todo el track. → **Decisión de proyecto**: es media fase de trabajo y produciría un `cuaderno-incidentes.md` mucho más largo.
- **El coverage del proyecto va a estar dominado por funciones puras y eso es honesto, no un truco.** Pero significa que el número global no dice nada sobre los componentes, que son donde vive el riesgo de una SPA. El umbral `each` lo mitiga; no lo resuelve. → **Nota para el chat de A11 o para el cierre del track forense**: el checklist de hotfix debería incluir "¿esta zona tiene test, o sólo tiene porcentaje?".
- **`RouterTestingModule` está deprecado en Angular 17** en favor de `provideRouter`, y esta fase lo usa porque en la 16 es lo que hay. Es la tercera pieza de esta fase con fecha de caducidad, junto a `HttpClientTestingModule` y el `TestBed` sin signals. → **Aviso para el chat de A11**: las tres merecen una fila en su tabla de traducción.
- **Los IDs de incidente no quedan en orden de fase.** La Fase 12 se lleva el 17 y el **20**, y la Fase 13 el 18 y el 19. Está así en los dos prompts y no lo cambio, pero el cuaderno se lee por ID y alguien va a preguntar por qué el último incidente no es del último capítulo. → **Nota para el chat del cuaderno de incidentes.**
- 🔥 **Un diagrama del ciclo del test de regresión** —ticket → reproducir a mano → test rojo → fix → test verde, con los dos tags marcados— es lo que más se le queda a alguien de toda esta fase. Es el décimo pendiente de ilustración del curso. Pendiente de dibujo, no de contenido.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 17 | "El test pasa en mi máquina y falla en el pipeline, y nadie tocó nada" | Testing | 🔴 |
| 20 | "Tenemos 82 % de coverage y el bug llegó a producción igual" | Testing | 🔴 |
