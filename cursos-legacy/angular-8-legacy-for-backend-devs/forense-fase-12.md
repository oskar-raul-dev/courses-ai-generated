# 🕵️ Forense Fase 12 — El test verde que no puede cazar el bug

> Pieza forense de la [**Fase 12 — Testing desde cero + coverage**](./12-testing-coverage.md) · Recorrido: ~50 min · [Índice del track](./forense-master.md)
> Herramientas: Karma y Jasmine · el spec rojo antes del fix · la cobertura **de casos**, no la de líneas
> Síntoma que cubre: una suite entera en verde sobre un bug que el usuario sufre todos los días.

Acá no depuras la aplicación: **depuras tu red de seguridad**. Es el único recorrido del track donde el sospechoso es tu propio código de pruebas, y donde "está en verde" es la evidencia a desconfiar en vez del criterio de éxito.

El caso se trabaja de punta a punta con la inversión del orden natural —prueba antes que código—, que es la disciplina que el alcance del curso pone como criterio de éxito.

---

## 🎫 El ticket

> *"Guardo dos pacientes seguidos cuando el sistema va lento y uno se pierde. Ustedes dicen que hay pruebas de eso."*

**Reportado por:** la coordinadora de recepción, reenviando la queja de su equipo
**Ambiente:** UAT
**Lo que trae adjunto:** una captura de la suite en verde que alguien le mandó para tranquilizarla.

La última frase es el ticket de verdad. **Hay pruebas de eso y están en verde**, y el bug existe. Una de las dos cosas es falsa, y no es la queja.

---

## 🧭 La ruta

Cinco pasos. Los dos primeros interrogan a la suite existente, el tercero escribe el spec que falta, el cuarto lo pone en rojo, y el quinto es el único que toca el código de producción. **El orden es la disciplina entera: si aplicas el fix antes del paso 4, nunca sabrás si el test servía.**

### Paso 1 — ¿Qué prueba realmente el test que dicen que cubre esto?

Ábrelo y léelo buscando una sola cosa: **cuántas acciones empuja**.

```typescript
it('createPatient$ despacha createPatientSuccess con el paciente que devolvio el server', function (done) {
  serviceSpy.createPatient.and.returnValue(of(returned));

  actions$ = new ReplaySubject(1);
  actions$.next(PatientsActions.createPatient({ patient: sent as any }));   // ← UNA

  effects.createPatient$.subscribe(function (outAction: any) {
    expect(outAction.type).toBe(PatientsActions.createPatientSuccess.type);
    done();
  });
});
```

Una acción. **Qué descarta.** El test es correcto y prueba lo que dice probar: que una creación produce un éxito. Lo que **no** prueba es lo que reporta el ticket, que ocurre con dos guardados solapados. Y aquí está el hallazgo central de la pieza:

> 🧭 **Con una sola acción, `mergeMap` y `switchMap` se comportan idéntico.** El operador de aplanado sólo se distingue cuando hay concurrencia; con un evento, los cuatro dan el mismo resultado. Un test que no ejercita la concurrencia **no puede cazar un bug de concurrencia**, esté en verde y aunque el coverage diga 100%.

Compruébalo, que es de las cosas más útiles que vas a ver en el curso: cambia `mergeMap` por `switchMap` en `createPatient$` —en el archivo de producción— y corre la suite.

```
Chrome 8x.x.x: Executed 47 of 47 SUCCESS (1.312 secs / 1.104 secs)
```

Cuarenta y siete en verde sobre el bug puesto a mano. La suite no está mintiendo: está contestando otra pregunta.

### Paso 2 — ¿Y el coverage no lo habría dicho?

```bash
npx ng test --watch=false --code-coverage
```

```
=============================== Coverage summary ===============================
Statements   : 84.2% ( 512/608 )
Branches     : 71.4% ( 105/147 )
Functions    : 80.9% ( 148/183 )
Lines        : 84.7% ( 498/588 )
================================================================================
```

Y la línea del `mergeMap` está cubierta: el test la ejecuta.

**Qué descarta.** Mata la hipótesis más cómoda —"nos faltaba cobertura"—. La cobertura mide **líneas ejecutadas**, no **casos ejercitados**, y son cosas distintas: esa línea se ejecutó una vez, con una acción, en el único escenario donde el bug no aparece. Un 100% de líneas es perfectamente compatible con un 0% de los casos que importan.

> ⚠️ Dos trampas del propio reporte, para no perder tiempo con ellas: si el número no se mueve al borrar un test, o el archivo está excluido, o estás mirando un HTML de una corrida vieja. `--watch=false` y borrar `coverage/` antes resuelve el segundo caso.

### Paso 3 — El spec que reproduce el bug, escrito **antes** del fix

Ahora sí, el test que faltaba. Mismo mecanismo del spec ancla, con la única diferencia que importa: **dos acciones**.

```typescript
// src/app/patients/store/patients.effects.spec.ts — el test de regresión
it('createPatient$ no pierde un alta cuando llegan dos seguidas', function (done) {
  var first   = { fullName: 'Ana Ruiz',  documentId: 'CC-1001', active: true };
  var second  = { fullName: 'Beto Diaz', documentId: 'CC-1002', active: true };

  // El servicio devuelve algo distinto por cada llamada, para poder distinguirlas.
  serviceSpy.createPatient.and.returnValues(
    of({ id: 1, ...first }),
    of({ id: 2, ...second })
  );

  // Dos acciones, sin esperar a que la primera resuelva. Un ReplaySubject de
  // buffer 2 las conserva las dos: con buffer 1 el test probaría otra cosa.
  actions$ = new ReplaySubject(2);
  actions$.next(PatientsActions.createPatient({ patient: first as any }));
  actions$.next(PatientsActions.createPatient({ patient: second as any }));

  var successes: any[] = [];
  effects.createPatient$.subscribe(function (outAction: any) {
    successes.push(outAction);
    // Dos altas tienen que producir DOS éxitos. Con switchMap llega uno solo
    // y este test se queda esperando hasta el timeout de Jasmine.
    if (successes.length === 2) {
      expect(successes[0].patient.id).toBe(1);
      expect(successes[1].patient.id).toBe(2);
      done();
    }
  });
});
```

**Qué descarta.** El spec no descarta: **decide**. Si pasa con el código roto, no reproduce el bug y hay que volver a escribirlo. Si falla, es un test de regresión de verdad.

### Paso 4 — Verlo rojo, que es el paso que casi todo el mundo se salta

Con el `switchMap` todavía puesto:

```
PatientsEffects
  ✗ createPatient$ no pierde un alta cuando llegan dos seguidas
    Error: Timeout - Async callback was not invoked within timeout specified
    by jasmine.DEFAULT_TIMEOUT_INTERVAL.

Chrome 8x.x.x: Executed 48 of 48 (1 FAILED) (5.421 secs / 5.208 secs)
```

**Qué descarta.** Rojo **por la razón correcta**, que es lo único que valida un test de regresión. Fíjate en la forma del fallo: no es una aserción que compara mal, es un **timeout** — el segundo éxito nunca llegó porque `switchMap` canceló la primera petición y nadie despachó nada por ella. La cancelación de RxJS no es un error, así que `catchError` tampoco se ejecutó. **El sistema perdió un registro sin enterarse**, y el test lo dice de la única manera en que se puede decir: esperando algo que no llega.

Si el fallo hubiera sido un `Expected 1 to be 2`, también sería válido; un test que falla con un mensaje que no habla del bug, no.

### Paso 5 — El fix, y verlo verde

Ahora sí se toca producción. Una palabra:

```typescript
mergeMap((action: any) => {        // en vez de switchMap
```

```
Chrome 8x.x.x: Executed 48 of 48 SUCCESS (1.402 secs / 1.187 secs)
```

**Qué descarta.** Verde con el test que antes estaba rojo, y las otras cuarenta y siete siguen pasando: el fix arregla el caso y no rompe nada conocido. Ese par —rojo antes, verde después, con el mismo spec— **es** el punto 6 del post-mortem de ocho puntos, y es lo único que demuestra que el test sirve para algo.

Con la convención de tags del curso queda además archivado sin esfuerzo: el `inc/<ID>/<slug>-roto` guarda el estado del paso 4 y el `-fix` el del paso 5, y el `git diff` entre los dos es el punto 5 del post-mortem aislado del ruido de la fase.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| Suite verde sobre un bug real | el test no ejercita el caso que falla | cuántas acciones/eventos empuja el spec |
| Coverage alto y bug vivo | la cobertura mide líneas, no casos | qué escenario recorre esa línea |
| Un `it` verde que sabes que debería fallar | el `expect` está dentro de un `subscribe` que nunca emitió | mete `done` en la firma: si se cuelga, no emite |
| El test se cuelga hasta el timeout al añadir `done` | el observable no emite: **ése es el bug** | el operador de aplanado, o el `catchError` |
| `NullInjectorError: No provider for X` en el `TestBed` | falta una dependencia del constructor en `providers` | añádela como doble, nunca la real |
| Un test unitario que sale a la red | se inyectó el servicio real en vez del espía | `useValue` con el `createSpyObj` |
| El coverage no baja al borrar un test | archivo excluido, o reporte de una corrida vieja | `--watch=false` y borra `coverage/` |
| `ExpressionChangedAfterItHasBeenChecked` en un test | el componente cambia un valor durante la detección | en test suele bastar un segundo `detectChanges()` |
| Lo mismo, en producción | es un bug de ciclo de vida, no ruido de test | ahí sí hay que perseguirlo |
| Un test pasa solo y falla en la suite completa | estado compartido entre specs, u orden | qué deja sucio el `beforeEach` anterior |
| Pasa en tu máquina y falla en la de al lado | reloj, azar, orden de ejecución o DOM sucio | siembra de Jasmine y `fdescribe` olvidados |

---

## ⚰️ Los callejones

**"Subamos el coverage al 90%."** Es la reacción de gestión a este ticket y no habría evitado nada: la línea culpable **ya estaba cubierta**. Subir el porcentaje añade tests de las líneas fáciles que faltan, que casi nunca son las que fallan. Lo que faltaba no era cobertura de líneas: era un caso.

**"El bug está en el test, no en el código."** Al revés, y conviene decirlo con claridad porque suena parecido: el test estaba bien escrito y era honesto sobre lo que probaba. El error fue **creer que probaba otra cosa**. Un test no miente; lo que miente es la interpretación de su nombre.

**"Con marbles y `TestScheduler` esto se veía a la primera."** Cierto, y es la refactorización correcta para tiempo determinista. También es un cambio de herramienta que no hace falta para este caso —dos `next` sobre un `ReplaySubject` bastan— y meterlo en el mismo commit del hotfix mezcla dos discusiones. Queda como ticket propio.

**"Ya lo probamos a mano y funciona."** Probarlo a mano con el mock rápido es exactamente el escenario donde el bug **no** aparece. Para reproducirlo hace falta latencia, y ése es el puente entre esta pieza y [`forense-fase-05.md`](./forense-fase-05.md): lo que en la aplicación se provoca con `CHAOS=latency`, en el test se provoca con dos acciones seguidas.

---

## 🧨 Deshacer

Este recorrido rompe el código de producción a propósito y deja artefactos:

```bash
# 1. El switchMap metido a mano en el effect, si no llegaste al paso 5.
git checkout -- src/app/patients/store/patients.effects.ts

# 2. El reporte de cobertura, para que la proxima corrida no te muestre uno viejo.
rm -rf coverage/
```

Y una revisión que vale más que las dos anteriores: **busca `fdescribe` y `fit` antes de commitear**. Un `fit` olvidado deja la suite ejecutando un solo test y reportando verde, que es precisamente la clase de mentira que esta pieza entrena a detectar.

```bash
grep -rn "fdescribe\|fit(" src/
```

---

## 🧠 El patrón transferible

> **Un test verde prueba que el escenario que escribiste funciona, no que el sistema funciona.** Cuando la suite está en verde y el bug existe, la pregunta no es "¿qué test falta?" sino "**¿qué caso no ejercita ninguno de los que hay?**". Casi siempre es un caso de concurrencia, de orden o de tiempo — los tres invisibles para una prueba de un solo evento, y los tres responsables de la mayoría de los tickets que llegan como "a veces".

Y el segundo, que es la disciplina completa en una frase: **el test de regresión se escribe antes del fix y se mira en rojo.** Un test que nace verde no demuestra nada: puede estar probando otra cosa, o nada. Verlo fallar **por la razón correcta** es la única prueba de que va a avisarte el día que alguien reintroduzca el bug — que es, al final, lo único que un test de regresión promete.

**Incidentes del cuaderno que usan esta ruta:** el **18** —*"el test pasa en mi máquina y falla en la de al lado"*—, que es la otra cara de esta pieza: allá el test miente por el entorno, acá por el caso.
**Amplía:** [`forense-fase-05.md`](./forense-fase-05.md) para el bug que este test tenía que cazar, visto desde la aplicación, y el [**Apéndice A05**](./a05-rxjs.md) para la diferencia entre `mergeMap`, `switchMap`, `concatMap` y `exhaustMap` con su tabla de cuándo usar cuál.
