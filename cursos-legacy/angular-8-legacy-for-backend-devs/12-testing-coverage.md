# ✅ Fase 12 — Testing desde cero + coverage

> Tutorial Angular 8 — Laboratorio clínico · Fase 12 de 14 · **10 horas**
> Depende de: Fases 1-11 · Habilita: Fase 13 — Build, despliegue y cierre
> Apéndices de apoyo: [A03 (Node y npm)](./a03-node-npm.md) · [A05 (RxJS de supervivencia)](./a05-rxjs.md) · [A06 (NgRx 8)](./a06-ngrx.md) · [Incidentes asociados](./cuaderno-incidentes.md): 18

---

## 🎯 1. Propósito

Heredas un proyecto con **cero specs**. No hay una sola prueba escrita en diez fases de código: ni un reducer, ni un selector, ni un effect están cubiertos. Y no es un descuido tuyo — así llegó LabCore, con la carpeta de tests que `ng new` generó y que nadie volvió a tocar. Esta fase no te enseña a "escribir tests bonitos": te enseña a **montar testing donde no hay nada y llegar a un coverage medible sin volverte loco**, que es un problema distinto y mucho más común en Maintenance.

Lo que te importa a ti, que vas a *mantener* esto, es que un test en un sistema legacy no sirve para lo que crees. No está ahí para "asegurar calidad" en abstracto. Está ahí para una sola cosa: **cuando llegue el ticket, escribir la prueba que reproduce el bug antes de tocar el código, verla fallar, aplicar el fix, y verla pasar.** Ese es el músculo de esta fase. El coverage es la brújula que te dice dónde no hay red de seguridad todavía — y, como toda brújula, a veces apunta mal, y aprender a leer sus mentiras es la mitad del trabajo.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `ng test` levanta Karma, abre Chrome, corre la suite y queda observando cambios; ves el conteo de specs en verde en la terminal y en la ventana del navegador.
- [ ] `ng test --code-coverage --watch=false` genera `coverage/index.html`; lo abres y ves las cuatro métricas (statements, branches, functions, lines) por archivo.
- [ ] `patients.reducer.spec.ts` cubre los tres estados de escritura y el `createPatientSuccess` que **no** inserta en `items`; si alguien "arregla" esa deuda sin querer, el test se pone rojo.
- [ ] `patients.effects.spec.ts` prueba que `createPatient$` usa `mergeMap` y no cancela un guardado en curso, y que `reloadAfterWrite$` traduce tres acciones de éxito en un solo `loadPatients`.
- [ ] `patients.service.spec.ts` verifica con `HttpTestingController` que `deactivatePatient` dispara un `PATCH` de un solo campo y `updatePatient` un `PUT` entero.
- [ ] El reporte de coverage global marca al menos **80%** una vez excluidos los archivos sin lógica (módulos, modelos, `environments`); el archivo `karma.conf.js` lleva esa exclusión escrita.
- [ ] Puedes señalar en el reporte un archivo con 100% de líneas y explicar por qué ese número no significa que esté probado.

> **Nota para el líder del equipo:** el umbral de **80% global** es la recomendación del curso, no una cifra impuesta por tu organización. Si tu líder fijó otro número —o ninguno—, este es el punto donde se reemplaza: se ajusta el `thresholds` de `karma.conf.js` (§5.7) y esta casilla del checklist. El resto de la fase no cambia.

---

## 🚫 3. Qué NO entra todavía

- End-to-end exhaustivo con flujos de usuario completos → **fuera de alcance del curso** (`alcance-del-proyecto.md` §8). Los smoke tests con Playwright existen en el proyecto pero se ven aparte, no en esta fase.
- CI real —correr la suite en cada push, bloquear el merge si baja el coverage— → **fuera de alcance**. Acá se corre en tu máquina; el pipeline es otra conversación.
- `fakeAsync` / `tick`, `TestScheduler` y marbles de RxJS **no se enseñan**: se nombran en §4 y §6 como el siguiente peldaño, y el código de esta fase prueba lo asíncrono con `of` y `throwError`, coherente con el RxJS mínimo del curso. La excepción está en el ejercicio 29, que te manda a buscarlos por tu cuenta — es deliberado y es el único del curso que lo hace, porque hay un test que no se puede escribir de otra forma y conviene descubrirlo chocando.
- Render real de componentes con Material montado en el `TestBed` (leer el DOM, hacer clic en un botón real) → se explica el porqué en §5.6 y la alternativa completa queda como ejercicio 🔥.
- Tests de los slices de `samples`, `results` y `audit` escritos línea por línea → se construye entero el de `patients` como molde y el resto queda como ejercicios de espejo (24 a 27).

---

## 🧠 4. Concepto mínimo

### El problema antes que la herramienta

Recibes un ticket: *"si guardo un paciente y sin esperar guardo otro, a veces se pierde el primero"*. Lo lees en la Fase 5: es el `mergeMap` de `createPatient$`, y si alguien lo hubiera cambiado a `switchMap` el guardado en curso se cancelaría en silencio. Ahora imagina que quieres arreglarlo con confianza. ¿Cómo sabes que tu fix no rompe otra cosa? ¿Cómo sabes, dentro de tres meses, que nadie volvió a meter el `switchMap`?

La respuesta manual es abrir el navegador, levantar el mock con latencia, hacer clic rápido dos veces y mirar el store. Funciona una vez. No funciona la número cuarenta, ni cuando el bug está en un reducer que solo se rompe con una combinación rara de acciones, ni cuando quien revisa tu hotfix un viernes a las seis no tiene tu contexto. **Un test es esa comprobación manual, escrita una vez y ejecutada para siempre.** Ese es todo el valor, y es enorme.

En un sistema legacy hay una tentación y una trampa. La tentación es "vamos a testear todo". La trampa es que testear todo en un código que no se escribió para ser testeado cuesta más que el código mismo, y termina en una suite que nadie corre. La disciplina de esta fase es la contraria: **testeas primero lo que es barato y valioso** —las funciones puras: reducers y selectores— y solo después pagas el costo de doblar dependencias para lo que lo necesita.

### Las tres capas, de barata a cara

Un reducer es una función pura: le entra un estado y una acción, te devuelve un estado nuevo, y no toca nada más — ni la red, ni el reloj, ni el DOM. Testear una función pura es el testing más barato que existe: la llamas con una entrada, comparas la salida, listo. No hace falta ninguna maquinaria. Lo mismo un selector: le das un objeto de estado a mano y verificas qué extrae. Si tu código tiene la lógica de negocio en funciones puras, tu suite es fácil; si la tiene enterrada en componentes gordos con dependencias por todos lados —que es exactamente lo que tienes—, es cara. Esa correlación no es casualidad: **el código difícil de testear suele ser el código mal separado**, y el coverage te lo va a gritar en la cara.

La capa del medio es la que tiene dependencias controlables: el servicio depende de `HttpClient`, el effect depende del servicio y del stream de acciones. No las puedes llamar con una entrada y comparar la salida, porque en el medio hablan con algo. La solución es **doblar** ese algo: le pones un `HttpClient` de mentira que no hace peticiones reales sino que responde lo que tú digas, o un servicio falso que devuelve un `Observable` fabricado. El doble no es magia: es un objeto que se hace pasar por el real y que tú controlas.

La capa cara es el componente. Un componente de Angular vive dentro de un `TestBed` —un módulo de mentira que Angular arma solo para el test—, arrastra sus dependencias, su plantilla, y en tu caso todo Material y NgRx detrás. Montar eso entero para verificar que `ngOnInit` despacha una acción es usar una grúa para levantar una cuchara. Por eso en §5.6 vas a testear la **lógica** del componente doblando el store, sin renderizar la plantilla — con su deuda declarada.

### Las herramientas, en una línea cada una

**Jasmine** es el lenguaje del test: `describe` agrupa, `it` es un caso, `expect(x).toBe(y)` es la aserción, `beforeEach` prepara el terreno antes de cada caso. **Karma** es el corredor: levanta un navegador real, mete tus specs adentro, los corre y te reporta. **TestBed** es la utilidad de Angular para armar el módulo de mentira cuando el test necesita el sistema de inyección de dependencias. **Istanbul** (vía `karma-coverage-istanbul-reporter`) es quien instrumenta tu código mientras corre y cuenta qué líneas se ejecutaron.

> **Si vienes de backend**, Jasmine es tu JUnit o tu pytest: mismo `describe/it`, mismo `assert` con otro nombre. La analogía funciona para la estructura y **se rompe en dónde corre**: tu test de backend corre en la JVM o en el intérprete, aislado; el de Angular corre **dentro de un navegador de verdad** que Karma abre, con su DOM, sus timers y su bucle de eventos. Buena parte de las rarezas de esta fase —por qué un test asíncrono a veces "pasa" sin probar nada— vienen de ahí y no de Jasmine.

> 📝 **Nota de época.** En 2019, `ng new` te dejaba Jasmine, Karma, y también Protractor para e2e. Protractor está muerto hace años y no lo vas a ver acá. Karma abriendo un Chrome real para correr pruebas unitarias hoy se considera pesado —el mundo se movió a corredores sin navegador—, pero es lo que el proyecto tiene y lo que vas a mantener. No lo migramos.

---

## 💻 5. Código mínimo con comentarios

El orden de esta sección **es** la lección: se testea de lo más puro y barato a lo más caro y sucio. Ese es también el orden en que un dev de Maintenance debería atacar un coverage en cero — primero los reducers y selectores, que suben la cobertura rápido y con tests que valen, y solo después pagar el precio de doblar dependencias.

Todo el molde se construye sobre el slice de `patients` de la Fase 5. Los slices de `samples`, `results` y `audit` se testean igual y quedan como ejercicios.

### 5.1 `karma.conf.js` — la config que ya estaba

`ng new` generó este archivo hace diez fases. Casi nadie lo abre hasta que necesita el coverage, y entonces descubre que ya venía casi listo. Estas son las partes que importan; el resto es andamiaje del CLI que no se toca.

```javascript
// karma.conf.js (en la raíz del proyecto, generado por Angular CLI 8.3.29)
// Solo se muestran las claves relevantes para coverage. El resto lo dejó el CLI.
module.exports = function (config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine', '@angular-devkit/build-angular'],
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-launcher'),
      // Este plugin es el que produce el reporte de coverage. Ya venía en las
      // devDependencies del proyecto; no se instala nada nuevo.
      require('karma-coverage-istanbul-reporter'),
      require('@angular-devkit/build-angular/plugins/karma')
    ],
    coverageIstanbulReporter: {
      // Donde caen los reportes. La carpeta "coverage" se ignora en git.
      dir: require('path').join(__dirname, './coverage'),
      // "html" produce el reporte navegable; "text-summary" imprime el
      // resumen en la terminal al terminar. "lcovonly" es el que consumiría
      // un CI, que en Track A no tenemos: se deja apagado.
      reports: ['html', 'text-summary'],
      fixWebpackSourcePaths: true
      // El umbral (thresholds) y las exclusiones se agregan en 5.7. De fábrica
      // este bloque NO trae umbral: el coverage se calcula pero nunca falla.
    },
    reporters: ['progress'],
    browsers: ['Chrome'],
    // singleRun: false significa que "ng test" queda observando. Para una
    // corrida única de coverage se usa "ng test --watch=false", que lo pone
    // en true sin editar este archivo.
    singleRun: false,
    restartOnFileChange: true
  });
};
```

**Detalles con intención**

- `reports: ['html', 'text-summary']` y no `lcovonly`. El `lcov` es formato para máquinas (un CI que compara coberturas entre commits). Sin CI, no aporta. Lo dejamos anotado para la Fase 13, no lo activamos.
- El bloque **no trae umbral de fábrica**. Esto es importante: significa que hoy Karma calcula el coverage pero **nunca falla por él**. Puedes tener 4% y la suite pasa igual. El umbral se agrega a mano en §5.7, y ahí empieza a doler.

### 5.2 `patients.reducer.spec.ts` — el spec ancla

Empezamos por el reducer porque es lo más fácil de testear y lo más valioso de asegurar: es lógica pura, y es donde vive la deuda 💸 de la Fase 5 que un fix descuidado podría romper. Este spec es también el molde del **test de regresión** de la pieza forense (§6): mismo mecanismo, distinto propósito.

```typescript
// src/app/patients/store/patients.reducer.spec.ts
import { patientsReducer, initialState, PatientsState } from './patients.reducer';
import * as PatientsActions from './patients.actions';

// Un reducer es una función pura: no hay TestBed, no hay que doblar nada.
// Se importa la función, se la llama, se compara la salida. Esto es lo más
// barato que vas a testear en todo el curso; aprovéchalo.
describe('patientsReducer', function () {

  it('deja el estado intacto ante una acción desconocida', function () {
    // El "default" del switch. Un reducer NUNCA debe romperse ante una acción
    // que no reconoce: devuelve el estado tal cual.
    var unknownAction = { type: '[Otro] Algo' } as any;
    var result = patientsReducer(initialState, unknownAction);
    expect(result).toBe(initialState); // misma referencia: no se tocó nada
  });

  it('loadPatients pone loading en true y limpia el error', function () {
    var previousState: PatientsState = { ...initialState, error: 'algo viejo' };
    var action = PatientsActions.loadPatients();
    var result = patientsReducer(previousState, action);
    expect(result.loading).toBe(true);
    expect(result.error).toBeNull();
  });

  it('loadPatientsSuccess apaga loading y guarda los items', function () {
    var previousState: PatientsState = { ...initialState, loading: true };
    // Datos anclados al dominio: pacientes, no foo/bar.
    var list = [{ id: 1, fullName: 'Ana Ruiz', documentId: 'CC-1001', active: true }];
    var action = PatientsActions.loadPatientsSuccess({ patients: list });
    var result = patientsReducer(previousState, action);
    expect(result.loading).toBe(false);
    expect(result.items).toBe(list);
  });

  // Los tres verbos de escritura comparten el mismo "case" caído en el switch
  // (create/update/delete -> saving: true). Un solo test que recorre los tres
  // asegura que la caída sigue en pie. Si alguien mete un "return" de más entre
  // ellos, este test lo caza.
  it('create, update y delete ponen saving en true', function () {
    var actions = [
      PatientsActions.createPatient({ patient: { fullName: 'X' } as any }),
      PatientsActions.updatePatient({ patient: { id: 1 } as any }),
      PatientsActions.deletePatient({ patientId: 1 })
    ];
    actions.forEach(function (action) {
      var result = patientsReducer(initialState, action as any);
      expect(result.saving).toBe(true);
      expect(result.saveError).toBeNull();
    });
  });

  // El test que protege la deuda 💸 de la Fase 5: createPatientSuccess NO
  // inserta el paciente en items. Apaga "saving" y nada más, porque el effect
  // va a recargar la lista entera. Si alguien "arregla" esto insertando en
  // items (que sería lo correcto hoy), este test se pone rojo y obliga a leer
  // la deuda antes de tocarla.
  it('createPatientSuccess apaga saving pero NO agrega a items', function () {
    var previousState: PatientsState = {
      ...initialState,
      saving: true,
      items: [{ id: 1, fullName: 'Ana Ruiz' } as any]
    };
    var created = { id: 2, fullName: 'Beto Diaz', documentId: 'CC-1002', active: true };
    var action = PatientsActions.createPatientSuccess({ patient: created });
    var result = patientsReducer(previousState, action);
    expect(result.saving).toBe(false);
    // La aserción clave: items quedó con UN solo elemento, el de antes.
    expect(result.items.length).toBe(1);
  });

  it('createPatientFailure apaga saving y guarda saveError', function () {
    var previousState: PatientsState = { ...initialState, saving: true };
    var action = PatientsActions.createPatientFailure({ error: 'boom' });
    var result = patientsReducer(previousState, action);
    expect(result.saving).toBe(false);
    expect(result.saveError).toBe('boom');
  });
});
```

**El patrón a memorizar**

Un reducer se testea sin ninguna maquinaria: `patientsReducer(previousState, action)` y comparas la salida. La aserción `.toBe(initialState)` sobre el caso `default` es doble red: verifica que no se rompe **y** que devuelve la misma referencia, que es lo que hace que la memoización de los selectores funcione río abajo.

> ⚠️ **Sobre `PatientsActions.setPatientsFilter`.** Si en la Fase 5 lo agregaste como pedía el ejercicio 1, súmale acá un `it` que verifique que guarda el `filter` en el estado. Si no lo agregaste, el proyecto ni siquiera compila y ya sabes por qué.

### 5.3 `patients.selectors.spec.ts` — el estado a mano, sin store

Un selector también es una función pura si lo llamas bien: en lugar de sacarlo del store, le pasas el objeto de estado directamente con `.projector()`. Así testeas la lógica del selector sin montar NgRx entero.

```typescript
// src/app/patients/store/patients.selectors.spec.ts
import * as PatientsSelectors from './patients.selectors';
import { PatientsState } from './patients.reducer';

describe('patients selectors', function () {

  // Un estado de laboratorio armado a mano. Tres pacientes: dos activos y uno
  // dado de baja (active: false), más uno viejo sin el campo "active" para
  // reproducir el dato heredado de la Fase 5.
  var state: PatientsState = {
    items: [
      { id: 1, fullName: 'Ana Ruiz', documentId: 'CC-1001', active: true } as any,
      { id: 2, fullName: 'Beto Diaz', documentId: 'CC-1002', active: false } as any,
      { id: 3, fullName: 'Cielo Mora', documentId: 'CC-1003' } as any // sin "active"
    ],
    loading: false,
    error: null,
    selectedId: null,
    saving: false,
    saveError: null,
    filter: ''
  };

  // selectAllPatients devuelve TODO, incluido el dado de baja. Este selector
  // existe desde la Fase 1 y su convivencia con selectActivePatients es la
  // causa raíz del incidente 09. El test documenta que devuelve los tres.
  it('selectAllPatients devuelve todos, incluido el inactivo', function () {
    // .projector() ejecuta la función del selector con el estado que le doy,
    // saltándome el store y la memoización.
    var result = PatientsSelectors.selectAllPatients.projector(state.items);
    expect(result.length).toBe(3);
  });

  // selectActivePatients usa "active !== false", así el paciente sin campo
  // (Cielo, el dato viejo) cuenta como activo. Este test blinda esa defensa:
  // si alguien lo cambia a "active === true", Cielo desaparece y el test cae.
  it('selectActivePatients incluye al paciente sin campo active', function () {
    var all = PatientsSelectors.selectAllPatients.projector(state.items);
    var activePatients = PatientsSelectors.selectActivePatients.projector(all);
    // Ana (true) y Cielo (sin campo) entran; Beto (false) no. Son dos.
    expect(activePatients.length).toBe(2);
    var ids = activePatients.map(function (p) { return p.id; });
    expect(ids).toContain(3);
  });

  it('selectFilteredPatients filtra por texto sobre los activos', function () {
    var all = PatientsSelectors.selectAllPatients.projector(state.items);
    var activePatients = PatientsSelectors.selectActivePatients.projector(all);
    // El proyector de un selector con dos entradas recibe las dos: la lista
    // ya filtrada por active, y el string del filtro.
    var result = PatientsSelectors.selectFilteredPatients.projector(activePatients, 'ana');
    expect(result.length).toBe(1);
    expect(result[0].fullName).toBe('Ana Ruiz');
  });
});
```

**Detalles con intención**

- `.projector()` es la puerta trasera de un `createSelector`: ejecuta su función de proyección con los argumentos que le des, sin store y sin memoización. Es la forma correcta de testear la **lógica** de un selector aislada.
- El paciente sin campo `active` no está de adorno: es el dato heredado de la Fase 5, y el test lo blinda para que la defensa `active !== false` no se "simplifique" por accidente.

### 5.4 `patients.service.spec.ts` — primer TestBed, primer doble

El servicio habla con la red vía `HttpClient`. No lo puedes llamar y comparar la salida, porque en el medio hay una petición. Aquí entra el primer `TestBed` y el primer doble: `HttpClientTestingModule` reemplaza el `HttpClient` real por uno que **no** hace peticiones, y `HttpTestingController` te deja inspeccionar y responder cada petición a mano.

```typescript
// src/app/patients/patients.service.spec.ts
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';

import { PatientsService } from './patients.service';
import { environment } from '../../environments/environment';

describe('PatientsService', function () {
  var service: PatientsService;
  var httpMock: HttpTestingController;

  beforeEach(function () {
    // TestBed arma un módulo de mentira. HttpClientTestingModule mete el
    // HttpClient doblado; nadie sale a la red de verdad.
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [PatientsService]
    });
    service = TestBed.get(PatientsService); // .get() y no .inject(): API de Angular 8
    httpMock = TestBed.get(HttpTestingController);
  });

  afterEach(function () {
    // Verifica que no quedó ninguna petición sin responder. Un test que deja
    // una petición colgada contamina al siguiente: es una de las causas de
    // "el test pasa solo o falla solo" de la deuda de 5.5.
    httpMock.verify();
  });

  it('deactivatePatient hace PATCH de un solo campo', function () {
    // La baja lógica: un PATCH con { active: false } y nada más. Si alguien lo
    // cambia a un PUT del recurso entero, este test lo caza.
    service.deactivatePatient(7).subscribe();
    var req = httpMock.expectOne(environment.apiUrl + '/patients/7');
    expect(req.request.method).toBe('PATCH');
    expect(req.request.body).toEqual({ active: false });
    req.flush({}); // responde la petición para que verify() no se queje
  });

  it('updatePatient hace PUT del recurso entero', function () {
    // El PUT que borra campos si no los mandas: la trampa del ejercicio 31 de
    // la Fase 5. El test fija que es PUT, no PATCH, para que la diferencia sea
    // visible y deliberada, no un accidente.
    var patient = { id: 7, fullName: 'Ana Ruiz', documentId: 'CC-1001', active: true };
    service.updatePatient(patient).subscribe();
    var req = httpMock.expectOne(environment.apiUrl + '/patients/7');
    expect(req.request.method).toBe('PUT');
    expect(req.request.body).toEqual(patient);
    req.flush(patient);
  });

  it('findByDocumentId consulta con el documento codificado en la URL', function () {
    service.findByDocumentId('CC 1001').subscribe();
    // El espacio debe ir codificado (%20 o +); si el encode se rompe, el mock
    // no matchea y el validador asíncrono de la Fase 5 falla en silencio.
    var req = httpMock.expectOne(function (r) {
      return r.url.indexOf('/patients') >= 0 && r.params.keys().length >= 0;
    });
    expect(req.request.method).toBe('GET');
    req.flush([]);
  });
});
```

**El patrón a memorizar**

`HttpTestingController` invierte el flujo: en vez de que el servicio salga a la red, tú **esperas** la petición (`expectOne`), la inspeccionas (método, URL, body), y la respondes a mano (`flush`). El `verify()` en el `afterEach` es la red de seguridad: si el servicio hizo una petición que no esperabas, el test falla, y eso a menudo es el bug.

> ⚠️ En Angular 8 la API de inyección en tests es `TestBed.get(Token)`. El `TestBed.inject(Token)` con tipado fuerte llegó después. Si copias un ejemplo de la web que usa `inject()`, va a compilar raro o fallar; es una de las diferencias de versión que más muerden. El día que alguien plantee migrar, este cambio es de los cómodos —`get()` sigue funcionando en la 9, solo queda obsoleto (**Apéndice A10 §3**)—; lo que no es cómodo, y por eso importa esta fase, es que **la cobertura que consigas acá es la red de seguridad de esa migración**: sin ella, el salto es una apuesta (**A10 §⚖️**).

### 5.5 `patients.effects.spec.ts` — doblar el stream y el servicio

El effect es la capa más cara de esta fase. Depende de dos cosas: del stream de acciones (`Actions`) y del servicio. Hay que doblar las dos. Para el stream, NgRx trae `provideMockActions`, que te deja **empujar** una acción y ver qué sale. Para el servicio, un espía de Jasmine que devuelve un `Observable` fabricado con `of` o `throwError` — sin marbles, sin `TestScheduler`, coherente con el RxJS mínimo del curso.

```typescript
// src/app/patients/store/patients.effects.spec.ts
import { TestBed } from '@angular/core/testing';
import { provideMockActions } from '@ngrx/effects/testing';
import { Observable, of, throwError, ReplaySubject } from 'rxjs';

import { PatientsEffects } from './patients.effects';
import { PatientsService } from '../patients.service';
import * as PatientsActions from './patients.actions';

describe('PatientsEffects', function () {
  var effects: PatientsEffects;
  var actions$: ReplaySubject<any>;
  var serviceSpy: any;

  beforeEach(function () {
    // El servicio doblado: un objeto con spies en vez de métodos reales.
    // jasmine.createSpyObj arma un falso PatientsService con esos tres métodos.
    serviceSpy = jasmine.createSpyObj('PatientsService', [
      'getPatients', 'createPatient', 'updatePatient', 'deactivatePatient'
    ]);

    TestBed.configureTestingModule({
      providers: [
        PatientsEffects,
        // provideMockActions recibe una función que devuelve el stream de
        // acciones que vamos a controlar. El ReplaySubject nos deja empujar
        // acciones a mano en cada test.
        provideMockActions(function () { return actions$; }),
        { provide: PatientsService, useValue: serviceSpy }
      ]
    });

    effects = TestBed.get(PatientsEffects);
  });

  it('createPatient$ despacha createPatientSuccess con el paciente que devolvió el server', function (done) {
    var sent = { fullName: 'Beto Diaz', documentId: 'CC-1002', active: true };
    var returned = { id: 2, ...sent }; // json-server asigna el id
    serviceSpy.createPatient.and.returnValue(of(returned));

    actions$ = new ReplaySubject(1);
    actions$.next(PatientsActions.createPatient({ patient: sent as any }));

    // El effect es asíncrono: nos suscribimos y comparamos la acción de salida.
    effects.createPatient$.subscribe(function (outAction: any) {
      expect(outAction.type).toBe(PatientsActions.createPatientSuccess.type);
      expect(outAction.patient.id).toBe(2);
      done(); // avisa a Jasmine que el test asincrono termino
    });
  });

  it('createPatient$ despacha createPatientFailure cuando el server falla', function (done) {
    serviceSpy.createPatient.and.returnValue(throwError({ status: 500 }));

    actions$ = new ReplaySubject(1);
    actions$.next(PatientsActions.createPatient({ patient: { fullName: 'X' } as any }));

    effects.createPatient$.subscribe(function (outAction: any) {
      // catchError convierte el error en una acción, NO en una excepción. El
      // effect nunca debe morir; si muere, deja de escuchar y la app se congela
      // en silencio. Ese es el bug que este test previene.
      expect(outAction.type).toBe(PatientsActions.createPatientFailure.type);
      done();
    });
  });

  // reloadAfterWrite$ es el effect más importante de la Fase 5: tres acciones
  // de éxito distintas entran, UNA sola sale (loadPatients). Este test lo fija.
  it('reloadAfterWrite$ traduce createPatientSuccess en loadPatients', function (done) {
    actions$ = new ReplaySubject(1);
    actions$.next(PatientsActions.createPatientSuccess({ patient: { id: 1 } as any }));

    effects.reloadAfterWrite$.subscribe(function (outAction: any) {
      expect(outAction.type).toBe(PatientsActions.loadPatients.type);
      done();
    });
  });
});
```

> 💸 **Deuda técnica intencional: tests asíncronos que dependen del orden y del estado compartido.** Fíjate que `actions$` es una variable de la suite, no local a cada `it`. Si un test la deja en un estado raro y el siguiente no la reinicia, el segundo puede pasar por lo que hizo el primero, no por lo suyo. Peor: el `done()` callback esconde una trampa clásica — si el effect **nunca** emite (porque el `mergeMap` se rompió), el `subscribe` no se dispara, `done()` no se llama, y el test no "falla", se queda esperando hasta el timeout. Un test que se cuelga y otro que pasa por contaminación son las dos caras de la misma suite frágil.
>
> **Lo correcto hoy** sería aislar cada test por completo: reconstruir `actions$` en un `beforeEach`, usar `TestScheduler` con marbles para tener control determinista del tiempo en vez del `done()` callback, y afirmar explícitamente cuántas acciones se emitieron, no solo la primera. Con marbles, un effect que no emite falla al instante en lugar de colgarse.
>
> **En Track A no se paga.** La suite real que heredas está escrita así —con `done()` callbacks, estado de suite compartido y dependencia implícita del orden de Karma— porque así se escribía en 2019 y porque marbles tiene una curva de aprendizaje que el equipo nunca subió. Cambiarlo es reescribir la suite entera, no un hotfix. Lo que sí te llevas es el reflejo: **cuando un test pase o falle según el orden en que corras la suite, no busques un bug en el código de producción, busca estado compartido entre specs.** Eso es exactamente el incidente 18.

### 5.6 `patient-list.component.spec.ts` — el store doblado, la plantilla afuera

Testear un componente montando su plantilla real arrastra todo Material, todo NgRx y media docena de imports. Para verificar que `ngOnInit` despacha `loadPatients`, eso es desproporcionado. La alternativa: doblar el store con `provideMockStore`, ignorar la plantilla con `NO_ERRORS_SCHEMA`, y probar solo la **lógica** del componente.

```typescript
// src/app/patients/patient-list/patient-list.component.spec.ts
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { provideMockStore, MockStore } from '@ngrx/store/testing';

import { PatientListComponent } from './patient-list.component';
import * as PatientsActions from '../store/patients.actions';
import * as PatientsSelectors from '../store/patients.selectors';

describe('PatientListComponent', function () {
  var fixture: ComponentFixture<PatientListComponent>;
  var component: PatientListComponent;
  var store: MockStore;

  beforeEach(function () {
    TestBed.configureTestingModule({
      declarations: [PatientListComponent],
      providers: [
        // provideMockStore da un store falso con estado inicial fijo. No hay
        // reducers reales: los selectores se sobrescriben con overrideSelector.
        provideMockStore({ initialState: {} })
      ],
      // NO_ERRORS_SCHEMA le dice a Angular que ignore cualquier etiqueta que no
      // conozca (todos los <mat-table>, <mat-paginator>, etc). Así no hay que
      // importar Material. El costo: la plantilla NO se prueba. Ver la deuda.
      schemas: [NO_ERRORS_SCHEMA]
    });

    store = TestBed.get(MockStore);
    // Cada selector que el componente consuma hay que sobrescribirlo con un
    // valor fijo; si no, revienta porque el estado falso está vacío.
    store.overrideSelector(PatientsSelectors.selectFilteredPatients, []);
    store.overrideSelector(PatientsSelectors.selectPatientsLoading, false);
    store.overrideSelector(PatientsSelectors.selectPatientsError, null);

    fixture = TestBed.createComponent(PatientListComponent);
    component = fixture.componentInstance;
  });

  it('despacha loadPatients al inicializar', function () {
    // Espiamos el dispatch del store falso para ver que acciones salen.
    var dispatchSpy = spyOn(store, 'dispatch');
    fixture.detectChanges(); // dispara ngOnInit
    expect(dispatchSpy).toHaveBeenCalledWith(PatientsActions.loadPatients());
  });
});
```

> 💸 **Deuda técnica intencional: probar el componente sin su plantilla.** Con `NO_ERRORS_SCHEMA` estás diciéndole a Angular que ignore todo lo que no entienda en el HTML. La consecuencia es que si la plantilla tiene un `{{ paciente.nombre }}` que apunta a una propiedad que no existe, o un `(click)` atado a un método mal escrito, **este test no lo ve**. Cubres la clase, no la vista.
>
> **Lo correcto hoy** sería importar los módulos de Material reales (o doblados con `MockComponent`), llamar `fixture.detectChanges()`, y leer el DOM: verificar que la tabla renderiza las filas, que el botón dispara el diálogo. Eso prueba de verdad el componente.
>
> **En Track A no se paga**, y esta vez la razón es de coste-beneficio explícito: montar Material en el `TestBed` para cada componente triplica el tiempo de la suite y la vuelve frágil ante cada actualización de Material. El equipo eligió `NO_ERRORS_SCHEMA` a sabiendas. El reflejo que te llevas: **un componente con 90% de coverage puede tener la plantilla completamente rota.** El coverage cuenta la clase; la vista no aparece en el número. La alternativa completa es el ejercicio 🔥.

### 5.7 Leer el coverage y ponerle umbral

Ahora corres `ng test --code-coverage --watch=false`, abres `coverage/index.html`, y ves cuatro columnas por archivo. **Statements** (sentencias ejecutadas), **branches** (ramas de `if`/`switch`/ternario recorridas), **functions** (funciones invocadas) y **lines** (líneas ejecutadas). La que más miente es *lines*; la que menos, *branches*.

El umbral se agrega al bloque de `karma.conf.js` de §5.1, y con él el coverage deja de ser informativo y empieza a fallar la suite si no se cumple:

```javascript
// Dentro de coverageIstanbulReporter, en karma.conf.js:
coverageIstanbulReporter: {
  dir: require('path').join(__dirname, './coverage'),
  reports: ['html', 'text-summary'],
  fixWebpackSourcePaths: true,

  // El umbral del curso: 80% global. Si el coverage cae por debajo, la corrida
  // falla. Ajusta estos números al valor que fije tu líder (ver la nota de 2).
  thresholds: {
    emitWarning: false, // false = falla de verdad; true = solo advierte
    global: {
      statements: 80,
      lines: 80,
      branches: 70,   // branches siempre va más bajo: es lo más duro de cubrir
      functions: 80
    }
  }
}
```

Pero un 80% sobre **todos** los archivos es una trampa: los `*.module.ts`, los modelos que solo declaran interfaces, `environment.ts`, `main.ts` y `polyfills.ts` no tienen lógica que testear, y arrastran el número hacia abajo sin que haya nada real que probar. Se excluyen del cálculo con la clave `check.exclude` del `angular.json`, o —más simple en CLI 8— con un archivo `.istanbul.yml` o el patrón de exclusión del propio reporter. La forma más portable es marcar la exclusión en la configuración del builder de test dentro de `angular.json`:

```jsonc
// angular.json -> projects -> <app> -> architect -> test -> options
"codeCoverageExclude": [
  "src/environments/**",
  "src/**/*.module.ts",
  "src/**/*.model.ts",
  "src/main.ts",
  "src/polyfills.ts",
  "src/test.ts"
]
```

> 💡 La exclusión no es hacer trampa con el número: es **medir lo que importa**. Contar la cobertura de un archivo que solo declara una interfaz no dice nada sobre si tu lógica está probada. Lo que sí sería trampa es excluir un componente gordo porque "es difícil de testear" — ese es justo el que necesita la red.

**La mentira central del coverage.** Abre el reporte y busca un componente con 100% de líneas. Puede que no tenga una sola aserción útil detrás: un test que crea el componente, llama `detectChanges()` y no verifica **nada** ejecuta todas las líneas del `ngOnInit` y las cuenta como cubiertas. Cien por ciento verde, cero garantía. **El coverage mide qué código se ejecutó durante los tests, no qué código está probado.** Son cosas distintas y confundirlas es la razón por la que equipos con 90% de cobertura siguen teniendo bugs en producción. Un reducer con 70% bien testeado vale más que un componente con 100% sin aserciones.

**Prueba de fuego.** Escribe un `it` que cree `PatientListComponent`, llame `fixture.detectChanges()` y no tenga un solo `expect`. Corre el coverage y mira cómo sube el número del componente. Después bórralo y confirma que bajó. Acabas de ver, con tus ojos, cómo se infla un coverage sin probar nada.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**El test asíncrono que pasa sin probar nada.** Síntoma: un `it` de un effect o un servicio está en verde, pero sabes que el código está roto. Causa: el `subscribe` con el `expect` adentro nunca se ejecutó —porque el observable no emitió o porque olvidaste el `done`—, así que Jasmine terminó el test sin llegar a la aserción y lo dio por bueno. Fix mínimo: mete un `done` en la firma del `it` y llámalo dentro del `subscribe`; si el test ahora se cuelga hasta el timeout, ya sabes que el observable no emite y ese es el bug real. Refactorización correcta: `TestScheduler` con marbles, que hace determinista el tiempo y falla al instante si no hay emisión.

**`NullInjectorError: No provider for X`.** Síntoma: el `TestBed` explota al crear el componente o el servicio. Causa: una dependencia del constructor que no declaraste en `providers`. Fix mínimo: agrégala como doble (`{ provide: X, useValue: spy }`) o importa su módulo de testing. No la agregues como la real: un test que inyecta el servicio HTTP real sale a la red y deja de ser un test unitario.

**El coverage no baja aunque borres un test.** Síntoma: quitas un spec y el número global no se mueve. Causa: ese archivo estaba en las exclusiones, o el reporte que estás mirando es de una corrida vieja (`--watch` no siempre regenera el HTML). Fix mínimo: corre con `--watch=false` y borra la carpeta `coverage/` antes.

**`ExpressionChangedAfterItHasBeenCheckedError` en un test de componente.** Síntoma: aparece en consola durante `detectChanges()`. Causa: el componente cambia un valor durante la detección de cambios. Fix mínimo en un test suele ser un segundo `detectChanges()`; pero ojo, porque en producción esto es un síntoma real de un bug de ciclo de vida, no ruido de test.

### Pieza forense de esta fase

Lo que se depura acá es distinto a las fases anteriores: no depuras la app, **depuras tu red de seguridad**. El caso central es el **test de regresión que reproduce el bug antes del fix, empezando por reducers**: recibes un ticket, escribes el spec que falla por la misma razón que el usuario sufre, lo ves rojo, aplicas el fix, lo ves verde. Es la inversión del orden natural —prueba antes que código— y es la disciplina que `alcance-del-proyecto.md` §12 pone como criterio de éxito del curso entero.

El desarrollo completo del caso —el ticket, el spec rojo paso a paso, el fix mínimo y la confirmación en verde, arrancando por un reducer y subiendo hacia el effect— vive en **[`forense-fase-12.md`](./forense-fase-12.md)**. Acá quedó el mecanismo (§5.2 es el molde); allá queda el caso trabajado de punta a punta.

**Rompe a propósito y observa.** En `patients.effects.spec.ts` (§5.5), cambia el `mergeMap` de `createPatient$` por `switchMap` en el archivo de producción `patients.effects.ts`. Corre la suite. El test de `createPatient$` para un solo guardado **sigue pasando en verde**, porque con una sola acción `switchMap` y `mergeMap` se comportan idéntico. La pantalla —o en este caso el test— te está mintiendo: el bug solo aparece con dos guardados solapados, y tu spec solo probó uno. Qué mirar: no la consola, sino la **cobertura de casos** de tu propio test. Un test que no ejercita la concurrencia no puede cazar un bug de concurrencia, aunque esté en verde y aunque el coverage diga 100%. Ese es el hueco que un test de regresión bien escrito tiene que cerrar, y la razón por la que el ejercicio 30 te pide escribirlo con dos acciones.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Corre `ng test` por primera vez y confirma que Karma abre Chrome y reporta los specs que ya existen. Anota cuántos hay antes de que escribas ninguno.
2. Corre `ng test --code-coverage --watch=false`, abre `coverage/index.html` y anota el porcentaje global de `lines` de partida. Es tu línea base.
3. Escribe el `it` faltante de `patients.reducer.spec.ts` que verifica `loadPatientsFailure`: debe apagar `loading` y guardar el `error`.
4. Agrega a `patients.reducer.spec.ts` el caso de `setPatientsFilter` (el que definiste en el ejercicio 1 de la Fase 5): verifica que guarda el `filter` en el estado.
5. En `patients.selectors.spec.ts`, agrega un test para `selectSelectedPatient` que verifique que devuelve `null` cuando `selectedId` no coincide con ningún paciente.
6. Corre la suite dos veces seguidas sin cambiar nada y confirma que el conteo de specs es idéntico. Guárdalo: te va a servir en el ejercicio 28.
7. Identifica en el reporte de coverage un `*.module.ts` con cobertura baja y explica en una línea por qué no tiene sentido testearlo.
8. Agrega la exclusión de `src/environments/**` al `codeCoverageExclude` del `angular.json`, vuelve a correr el coverage y anota cuánto subió el global.

**🟡 Intermedio (9–17)**

9. Escribe `samples.reducer.spec.ts` completo siguiendo el molde de §5.2, cubriendo las transiciones de estado de muestra de la Fase 7.
10. En `patients.service.spec.ts`, agrega un test para `createPatient` que verifique que el objeto enviado **no** lleva `id` y que la respuesta del server **sí** lo trae.
11. Escribe un test de `getPatients` que use `req.flush([], { status: 500, statusText: 'Server Error' })` y verifique que el `Observable` emite error, no valor.
12. Escribe `results.selectors.spec.ts` para el selector `selectOutOfRangeCount` que el dashboard de la Fase 10 consume.
13. En `patients.effects.spec.ts`, agrega el test de `updatePatient$`: verifica que un `updatePatient` produce `updatePatientSuccess` con el paciente devuelto.
14. Agrega el test de `deletePatient$`: verifica que produce `deletePatientSuccess` con el `patientId` correcto.
15. Escribe el test de `upsertPatient$`: verifica que sin `id` despacha `createPatient` y con `id` despacha `updatePatient`. Es un effect que no toca la red, así que no hace falta doblar el servicio.
16. Agrega el umbral de coverage a `karma.conf.js` con `emitWarning: true` (solo advierte) y confirma que la suite pasa aunque no llegues al 80%. Después ponlo en `false` y observa la diferencia.
17. Escribe `patient-form.component.spec.ts` que verifique que el formulario reactivo se marca inválido cuando `documentId` está vacío, doblando el store con `provideMockStore`.

**🟠 Difícil (18–24)**

18. **Diagnóstico.** Te entrego una suite donde `patients.reducer.spec.ts` pasa solo si corre antes que `patients.selectors.spec.ts`, y falla si el orden se invierte. Reproduce el fallo forzando el orden, localiza el estado compartido entre los dos archivos y explícalo. No lo arregles todavía: solo nómbralo.
19. **Diagnóstico.** Un effect tiene un test en verde, pero en producción el bug persiste. El spec usa `subscribe` sin `done`. Reprodúcelo, explica por qué el `expect` nunca corrió, y muestra la línea exacta que lo delata.
20. **Diagnóstico.** El reporte de coverage marca `patient-list.component.ts` en 95%, pero la plantilla tiene un binding roto que rompe la pantalla en runtime. Explica por qué el coverage no lo detecta y qué tipo de test lo cazaría.
21. Escribe el test de regresión que reproduce el incidente 09 de la Fase 5: un consumidor que usa `selectAllPatients` en vez de `selectActivePatients` y por eso muestra pacientes dados de baja. El test debe fallar con el selector equivocado y pasar con el correcto.
22. **Diagnóstico.** Te entrego un `service.spec.ts` sin `httpMock.verify()` en el `afterEach`. Un test deja una petición colgada y contamina al siguiente. Reprodúcelo y localiza cuál test deja la petición abierta.
23. Escribe `auth.guard.spec.ts` para el guard de la Fase 3: verifica que redirige a `/login` cuando no hay token y deja pasar cuando lo hay, doblando el `AuthService` y el `Router`.
24. Escribe `auth.interceptor.spec.ts` que verifique con `HttpTestingController` que el interceptor agrega el header `Authorization` a las peticiones salientes, y que **no** lo agrega cuando no hay token —el `Bearer null` del error común de la Fase 3 §6—.

**🔴 Muy difícil (25–30)**

25. Escribe el slice completo de tests de `orders` —reducer, selectores y effects— siguiendo el molde de `patients`, y llévalo a 80% de coverage propio.
26. **Diagnóstico.** Una suite tiene 88% de coverage global pero un bug de producción sin cubrir. Encuentra el archivo con branches sin recorrer (mira la columna `branches`, no `lines`) y escribe el test que cierra el hueco.
27. Escribe el test de `AuditEffect` de la Fase 11: verifica que una mutación successesa de la Fase 5 produce un asiento en el audit log con la entidad y el actor correctos.
28. **Diagnóstico.** Toma la suite del ejercicio 6 y hazla intermitente a propósito: introduce una dependencia de orden entre dos specs de effect vía estado de suite compartido. Documenta el síntoma (pasa a veces, falla a veces según el orden de Karma) como lo verías en un ticket real. Este es el material del incidente 18.
29. **Diagnóstico + regresión.** El validador asíncrono de `documentId` de la Fase 5 tiene un `timer(400)` de debounce delante, así que un test normal termina antes de que el validador haya empezado y pasa en verde sin probar nada — el mismo fallo que §6 describe. Escribe el spec con `subscribe` y `done` y observa el problema; después reescríbelo controlando el tiempo. Vas a necesitar dos cosas que esta fase deja fuera de alcance (§3): busca `fakeAsync` y `tick` en la guía de testing de v8, o `TestScheduler` en la doc de RxJS. Es el único ejercicio del curso que te manda a aprender una herramienta que no se enseñó, y es a propósito: el día que un test asíncrono te mienta, ese es el camino.
30. **Diagnóstico + regresión.** Escribe el test de regresión del bug de `mergeMap`/`switchMap` de `createPatient$` **con dos acciones solapadas**, de modo que falle si el operador es `switchMap` y pase si es `mergeMap`. Este es el test que el "Rompe a propósito" de §6 demostró que faltaba.

**🔥 Opcionales**

- 🔥 Reescribe `patient-list.component.spec.ts` (§5.6) importando los módulos de Material reales o doblándolos con `MockComponent` de `ng-mocks`, y verifica leyendo el DOM que la tabla renderiza las filas. Compara el tiempo de corrida con la versión de `NO_ERRORS_SCHEMA` y mide cuánto se encareció la suite.
- 🔥 Reescribe `patients.effects.spec.ts` con `TestScheduler` y marbles en vez de `done()` callbacks. Demuestra que la versión con marbles falla al instante cuando el effect no emite, mientras que la de `done()` se cuelga hasta el timeout.
- 🔥 Configura `karma-coverage-istanbul-reporter` para emitir `lcovonly` y explora qué haría un CI con ese archivo: comparar el coverage de tu rama contra `main` y bloquear el merge si baja. No montes el CI; solo describe el flujo.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v8.angular.io/guide/testing — la guía de testing de Angular 8, la referencia por defecto. Cubre `TestBed`, `ComponentFixture` y el patrón de specs. ⚠️ La guía equivalente en https://angular.io documenta versiones muy posteriores con `TestBed.inject()` (que en 8 es `TestBed.get()`) y utilidades que no existen en tu stack.
- https://v8.angular.io/api/common/http/testing/HttpTestingController — `HttpTestingController` y `HttpClientTestingModule`, para los tests de servicio de §5.4.
- https://jasmine.github.io/api/3.4/global — API de Jasmine 3.4, la versión del stack. `describe`, `it`, `expect`, `spyOn`, `createSpyObj`. ⚠️ El sitio de Jasmine sirve la versión más reciente por defecto; ancla la URL a `/3.4/` o los matchers pueden no coincidir.
- https://ngrx.io/guide/effects/testing — testing de effects con `provideMockActions`. ⚠️ Cubre versiones posteriores a NgRx 8; `provideMockActions` y `provideMockStore` son compatibles, pero las guías vecinas muestran `createActionGroup` y utilidades que **no existen** en la versión del curso.
- https://github.com/typicode/json-server — recordatorio de cómo responde el mock que los tests de servicio simulan; útil para fijar los `flush` con formas de respuesta realistas.

**Libros / artículos de referencia**

- Sobre por qué el coverage no es garantía de nada: cualquier fuente seria sobre *"coverage is not correctness"* o *"assertion-free tests"* explica la mentira central de §5.7. La idea es vieja y transferible; no depende de Angular. ⚠️ Títulos y URLs varían; verifica.

**Video / apoyo**

- *Angular 8 unit testing* — búsqueda sugerida: https://www.youtube.com/results?search_query=angular+8+unit+testing+jasmine+karma — material de la época. ⚠️ Verifica la fecha: cualquier video posterior a 2021 usa `TestBed.inject()`, corredores sin navegador y utilidades que tu stack no tiene.

**Orden de lectura sugerido:** antes de escribir código, la guía de testing de Angular 8 solo hasta entender `TestBed` y el patrón `describe/it` — no el capítulo entero. Durante, la página de `HttpTestingController` cuando llegues a §5.4 y la de testing de effects cuando llegues a §5.5. Después, con la suite ya escrita, la idea de "coverage no es correctness" para leer tu propio reporte con desconfianza sana.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido desde que se escribió esto; verifícalos. Los enlaces a `v8.angular.io` arrastran el pendiente abierto de verificación de las fases anteriores. Cualquier documentación de NgRx o Jasmine en su sitio oficial cubre, por defecto, una versión posterior a la del curso: léela sabiendo que parte de lo que ofrece no existe en tu stack.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Quedó montado el testing donde no había nada: `ng test` corre, `ng test --code-coverage` reporta, y hay specs reales de reducer, selector, servicio, effect y componente sobre el slice de `patients`, con el molde listo para copiar a los slices que faltan. Quedó el umbral de 80% escrito en `karma.conf.js` —ajustable a la cifra que fije tu líder— con las exclusiones que hacen que el número mida lo que importa. Y quedaron declaradas las deudas 💸 que no se pagan: los tests asíncronos con `done()` callbacks y estado de suite compartido, y los componentes probados sin su plantilla vía `NO_ERRORS_SCHEMA`. Ninguna se corrige; las dos se entienden, porque cada una es la fuente de un test que miente en verde.

Sobre todo quedó el reflejo central del curso: **la prueba se escribe antes que el fix, se ve fallar, y solo entonces se toca el código.** Ese es el músculo que separa un hotfix con red de uno a ciegas.

La **Fase 13** es el paso natural porque cierra el ciclo de vida del código que llevas once fases construyendo y ahora probando: build, contenedor y despliegue. Y necesita justo lo que esta fase instaló como hábito — porque el momento en que descubres que "funciona en UAT y no en PROD" es exactamente el momento en que agradeces tener una suite que corre en cualquier máquina y te dice qué se rompió y qué no. El testing es la red; el despliegue es el salto.

> **La señal de que quedó bien:** cuando te llegue el próximo ticket, tu primer movimiento no sea abrir el código a ver qué toco, sino abrir un `.spec.ts` y escribir la prueba que reproduce el bug — y que, al verla roja, sientas alivio en vez de fastidio, porque ya sabes que cuando se ponga verde el trabajo estará hecho de verdad.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-12-testing-coverage -m "F12 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f12: …`) y los de ejercicio su
> número (`f12 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f12/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> El número del coverage del día que cerraste la fase va en el mensaje del tag,
> no en tu memoria: es lo que después te deja decir si subió o bajó sin
> discutirlo de oído.

---

## 📌 Pendientes sugeridos

Cosas que aparecieron escribiendo esta fase y que no caben acá:

- **[A]** El **testing con marbles y `TestScheduler`** como forma correcta de probar lo asíncrono de forma determinista. Es un tema propio, con curva de aprendizaje, que reemplazaría los `done()` callbacks de toda la suite → sugerido para el **apéndice A05 (RxJS de supervivencia)** como sección "marbles: testear el tiempo sin sufrirlo", ya que es RxJS puro más que testing.
- **[B]** El **CI real** —correr la suite en cada push, comparar coverage contra la rama base, bloquear el merge— que el `lcovonly` del ejercicio 🔥 deja preparado pero no monta → sugerido como **pendiente de proyecto**; toca infraestructura del equipo, no una fase.
- **[C]** El **render real de componentes con Material** doblado con `ng-mocks` (ejercicio 🔥 de §7) como estrategia intermedia entre `NO_ERRORS_SCHEMA` y montar Material entero → sugerido para el **apéndice A01 (Angular Material)** como sección "testear un componente que usa Material sin morir en el intento".
- **[D]** Los **smoke tests con Playwright** que `alcance-del-proyecto.md` §7 incluye en el proyecto pero esta fase deja fuera → sugeridos para una **sección propia o apéndice de e2e**, fuera del cuerpo del onboarding obligatorio.

### Reservas para el cuaderno de incidentes

Esta fase toma el incidente **18**. Está en el índice del cuaderno y con su enunciado escrito allí, que es donde vive:

- **18** · Fase 12 · *"El test pasa en mi máquina y falla en la de al lado"* · Categoría: testing · Dificultad 🔴 — ancla la deuda 💸 de esta fase (tests dependientes del orden de ejecución de Karma y estado de suite compartido entre specs). Las dos pistas escalonadas: primero, que el fallo cambia según el orden en que Karma carga los archivos; segundo, que hay una variable de nivel de suite (`actions$` o un mock) que un spec deja sucia y otro hereda. El fix mínimo aísla el estado en un `beforeEach`; la corrección correcta reescribe con marbles. Material de la semana 4 (fases 12-12), coherente con la distribución de dificultad de `propuesta-fases-y-alcance.md` §6.
