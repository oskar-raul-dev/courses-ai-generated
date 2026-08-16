# 🕵️ Forense Fase 12 — "Pasa en mi máquina y falla en el pipeline"

> Pieza forense de la **Fase 12 — Testing desde cero + coverage** · Recorrido: ~50 min
> Herramientas: la semilla de Jasmine · bisección de la suite · `fakeAsync` · `git bisect`
> Síntoma que cubre: dos tickets sobre tests — el que hay que escribir **antes** del fix, y el que falla una de cada diez veces.

Los tests son la única parte del sistema donde el bug puede estar **en el instrumento de medida**. Por eso las dos rutas de esta pieza empiezan igual: convirtiendo algo no determinista en determinista, porque un fallo que no se puede reproducir no se puede investigar.

La fase resume los cuatro sospechosos del intermitente. Aquí están los dos tickets y la salida de cada paso.

---

## 🎫 Ticket A — el test que va antes del fix

> *"Confirmado el bug de la inspección de agosto. Antes de tocar nada quiero el test que lo reproduce, y quiero poder ver el `git diff` del fix sin el ruido de la fase."*

**Reportado por:** tu líder técnico · **Ambiente:** — · **Cierra el incidente 08**

## 🎫 Ticket B — el intermitente

> *"El test pasa en mi máquina y falla en el pipeline, y nadie tocó nada. A veces vuelve a pasar si relanzo el job."*

**Reportado por:** un compañero del equipo · **Ambiente:** integración continua · **Es el incidente 17**

**"A veces vuelve a pasar si relanzo"** es la frase que define el ticket B, y también la que hace que mucha gente lo relance hasta que pase y siga con su día. Ésa es la decisión que esta pieza intenta que no tomes.

---

## 🧭 Ruta A — el test de regresión, y por qué va primero

Va primero porque es **lo más barato que existe**: un test que falla convierte un ticket en una condición reproducible, y a partir de ahí cada hipótesis se descarta en segundos en vez de en una sesión de depuración. La ruta B —el intermitente— cuesta un orden de magnitud más en cada paso, y por eso sus cuatro sospechosos van en el orden en que van.

### Paso 1 — La rama sale del tag de la fase, no de tu rama de trabajo

```bash
# El commit de partida es el tag que pusiste al cerrar la Fase 7: ahí el bug
# existe y nada más lo enturbia.
git switch -c inc/08/version-equivocada-roto fase-07
```

**Qué descarta.** Partir de `master` mete en el diff todo lo que hicieron las Fases 8 a 11. Partiendo del tag, el `git diff` final contiene **el bug y su fix, y nada más** — que es exactamente el punto 5 de un post-mortem.

### Paso 2 — El test, y verlo fallar

Escribirlo antes no es disciplina: es la única forma de saber que el test **prueba lo que crees**. Un test escrito después del fix pasa desde el primer momento, y no hay ninguna evidencia de que habría fallado antes.

```ts
// El test entero cabe en diez líneas y no necesita TestBed: la regla vive en
// una función pura, que es lo que hace posible esto.
it('lee una inspección con la versión que guardó, no con la vigente', () => {
  const family = [templateV1, templateV2];   // v1 hasta 2023-12-31, v2 desde 2024-01-01
  const inspection = { templateVersion: 1, templateId: 'elevator-annual' } as Inspection;

  const applied = family.find((version) => version.version === inspection.templateVersion);

  expect(applied?.version).toBe(1);
  expect(applied?.items.length).toBe(3);     // la v2 tiene cuatro
});
```

```
Chrome Headless 120.0.0: Executed 1 of 1 (1 FAILED) (0.031 secs / 0.008 secs)

TemplateResolution
  ✗ lee una inspección con la versión que guardó, no con la vigente
    Expected 2 to be 1.
```

**Qué descarta.** `Expected 2 to be 1` es la evidencia de que el test **ve** el bug. Si hubiera pasado en verde, el test no estaría probando lo que dice probar, y habrías desplegado un fix sin red.

```bash
git commit -am "incidente(08): repro — el test reproduce el bug y falla"
git tag -a inc/08/version-equivocada-roto -m "F7 inc08: el test reproduce el bug y falla"
```

### Paso 3 — El fix, y el segundo tag

```bash
# …aplicas el fix, el test pasa…
git commit -am "incidente(08): fix — leer templateVersion de la inspección, no del template"
git tag -a inc/08/version-equivocada-fix -m "F7 inc08: causa raíz y fix, con el test en verde"
```

Y ahora el entregable, que es lo que justifica los dos tags:

```bash
git diff inc/08/version-equivocada-roto inc/08/version-equivocada-fix
```

```diff
-    const template = resolveTemplateVersion(family, todayInBusinessZone());
+    const template = family.find(
+      (version) => version.version === inspection.templateVersion,
+    );
```

**Dos líneas.** Ése es el punto 5 del post-mortem, aislado del ruido de once fases, y se puede pegar en un ticket. Sin los dos tags, encontrarlo dentro de seis meses cuesta una tarde de arqueología.

> 💡 **Y el atajo para releer el cuaderno entero sin abrir un archivo:** `git tag -n99 -l 'inc/*'` lista todos los incidentes con el mensaje completo de cada tag.


**Aquí termina la ruta A.** El incidente queda cerrado con su par de tags y su `git diff` de dos líneas. Si lo que tienes no es un fallo reproducible sino uno que aparece y desaparece, la tuya es la **ruta B**.

---

## 🧭 Ruta B — el intermitente, en cuatro sospechosos

### Paso 0 — Antes de nada: hazlo determinista

Un fallo que ocurre una de cada diez veces no se investiga: **se hace ocurrir siempre.** Todo lo que sigue depende de este paso.

```bash
# Correr la misma suite varias veces y ver si el patrón aparece:
ng test --watch=false --browsers=ChromeHeadless
```

```
Randomized with seed 47291
Chrome Headless 120.0.0: Executed 128 of 128 SUCCESS (2.104 secs)
```

```
Randomized with seed 83104
Chrome Headless 120.0.0: Executed 128 of 128 (1 FAILED) (2.233 secs)
```

**Qué descarta.** La semilla es lo primero que Jasmine imprime y lo primero que casi nadie lee. Si con una semilla falla y con otra pasa, **el problema es el orden** (sospechoso 3). Si falla con todas o con ninguna, el orden no es el culpable y hay que mirar los otros tres.

```bash
# Y a partir de aquí, la semilla se fija y el fallo es reproducible:
ng test --watch=false --browsers=ChromeHeadless --seed=83104
```

### Sospechoso 1 — El reloj

```bash
# Búscalo en el CÓDIGO BAJO PRUEBA, no en el test. El test no pregunta la hora:
# la pregunta el código, y por eso el test depende de cuándo se ejecute.
grep -rn "new Date()\|Date.now()" src/app --include="*.ts" | grep -v spec
```

En este proyecto hay un caso exacto y vale la pena verlo:

```ts
// CertificateStateService.issue() llama a new Date() por dentro, y
// buildCertificateId saca el año de ahí.
const id = buildCertificateId(new Date());   // 'CERT-2025-000503'
```

Un test que corra a las **23:59:59 del 31 de diciembre** genera un `id` con el año siguiente. Falla una vez al año, durante un segundo, en un pipeline que probablemente no esté corriendo. Es la clase de intermitente que nadie caza nunca — y es una crítica legítima al diseño, no al test: **un método que pregunta la hora por su cuenta no se puede probar de forma determinista.**

```ts
// ✅ El arreglo, y es de diseño: el instante entra como parámetro.
issue(inspectionId: number, now: string): void { … }
```

**Aquí termina la ruta.** Si el test toca una fecha, una hora o un `Date.now()` propio, el sospechoso es éste y ya está localizado. **Si no toca ninguna de las tres, pasa al Sospechoso 2**: el orden de los cuatro es de más barato a más caro de descartar.

### Sospechoso 2 — El azar

```bash
grep -rn "randomUUID\|Math.random" src/app --include="*.ts" | grep -v spec
```

El `CorrelationIdInterceptor` estampa un `crypto.randomUUID()` en cada petición. Un test que compruebe el **valor** de esa cabecera falla siempre; uno que compruebe su **forma** pasa siempre:

```ts
// ❌ expect(headers.get('X-Correlation-Id')).toBe('3f2a9c1e-…');
// ✅
expect(headers.get('X-Correlation-Id')).toMatch(/^[0-9a-f-]{36}$/);
```

**Aquí termina la ruta.** Si la aserción compara contra un valor generado —un identificador, una semilla, un orden que dependa de un `Math.random()`—, el sospechoso es éste. **Si todas las aserciones comparan contra valores fijos, pasa al Sospechoso 3.**

### Sospechoso 3 — El orden, y la bisección

Con la semilla fija del paso 0, el fallo es reproducible. Ahora se acorrala:

```
1. Marca la mitad de los `describe` con `xdescribe` y corre con la misma semilla.
2. ¿Sigue fallando? El culpable está en la mitad que quedó. ¿Dejó de fallar?
   Está en la que quitaste.
3. Repite con esa mitad. Siete iteraciones bastan para 128 tests.
```

Lo que queda cuando el fallo desaparece es **la pareja de tests que se contaminan**, y la contaminación casi siempre es una de estas tres:

| Qué quedó sucio | Cómo se ve | Cómo se limpia |
|---|---|---|
| Un servicio `providedIn: 'root'` con estado | el segundo test ve los datos del primero | `TestBed.resetTestingModule()` (lo hace Karma solo entre `it`, no entre `describe` mal montados) |
| Un espía global | `jasmine.clock()` o un `spyOn` sobre algo compartido | `afterEach` que lo restaure |
| `localStorage` | el token del test de login sobrevive | `afterEach(() => localStorage.clear())` |

> 🧭 **Un test que sólo pasa si otro corrió antes no es un test: es media prueba.** Y su fallo aparece el día que alguien añada un `it` en otro archivo, que es cuando nadie lo va a relacionar con nada.

**Qué descarta.** Si el test pasa aislado y falla en la suite, el sospechoso es éste y la tabla de arriba tiene las fugas de estado que lo producen. **Si falla igual aislado**, el orden no tiene nada que ver y pasas al **Sospechoso 4**, que es el último y el más caro.

### Sospechoso 4 — La asincronía

El más silencioso, porque **el test pasa en verde sin haber comprobado nada**:

```ts
// ❌ El `it` es síncrono. El subscribe resuelve después de que terminó.
//    Jasmine no espera a nadie que no le hayas dicho que espere.
it('carga las plantillas', () => {
  service.load();
  service.templates$.subscribe((templates) => {
    expect(templates.length).toBe(3);   // esto puede no ejecutarse NUNCA
  });
});
```

```
Chrome Headless 120.0.0: Executed 1 of 1 SUCCESS (0.012 secs)
```

**Verde, y no probó nada.** La forma de detectarlo es brutal y eficaz: **pon una aserción imposible dentro del callback**. Si el test sigue pasando, el callback no se está ejecutando.

```ts
// ✅ Determinista: el tiempo virtual se controla.
it('carga las plantillas', fakeAsync(() => {
  service.load();
  httpMock.expectOne('/templates').flush(threeTemplates);
  tick();

  let received: readonly ChecklistTemplate[] = [];
  service.templates$.subscribe((templates) => (received = templates));
  tick();

  expect(received.length).toBe(3);
}));
```

`done` también funciona y es peor: un `done` que no se llama **tarda cinco segundos en fallar**, y con veinte tests así el pipeline pasa de dos minutos a diez sin que nadie sepa por qué.

**Aquí termina la ruta.** Es el último de los cuatro sospechosos y el más caro de descartar, que es por lo que va el cuarto. **Si tampoco es éste**, no queda nada que razonar y empieza la fuerza bruta: el `git bisect` del paso final.

### Paso final — Si nada de lo anterior: `git bisect`

Cuando el intermitente empezó "desde algún commit" y no sabes cuál:

```bash
git bisect start
git bisect bad HEAD
git bisect good fase-11
# En cada paso, corre la suite N veces con la semilla que falla:
git bisect run sh -c 'ng test --watch=false --browsers=ChromeHeadless --seed=83104'
```

Es el último recurso porque cuesta N ejecuciones completas de la suite, y es infalible cuando el resto no dio nada.


**Aquí termina la ruta B.** Si ninguno de los cuatro sospechosos era, la bisección localiza el commit y ahí se acaba el razonamiento: a partir de ese commit, el diagnóstico vuelve a ser de lectura. Es el único paso de la pieza que no descarta nada — busca.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Sospechoso | Primera comprobación |
|---|---|---|
| Falla con una semilla y pasa con otra | 3 · orden | fija la semilla y bisecciona |
| Falla siempre en el pipeline y nunca en local | 1 · reloj, o 3 · orden | ¿qué hora es en el runner?, ¿qué semilla usa? |
| Falla una vez al año, o al cambiar de mes | 1 · reloj | `new Date()` en el código bajo prueba |
| El valor esperado nunca coincide | 2 · azar | comprueba la forma, no el valor |
| Pasa en verde y no prueba nada | 4 · asincronía | mete una aserción imposible dentro del callback |
| Un test tarda 5 s en fallar | 4 · un `done` que no se llama | `fakeAsync` + `tick` |
| El segundo test ve datos del primero | 3 · contaminación | `afterEach` que limpie estado y `localStorage` |
| Empezó a fallar y nadie tocó nada | — | `git bisect run` con la semilla fija |

---

## ⚰️ Los callejones

**"Relánzalo, a veces pasa."** No es un callejón: es la decisión de no investigar, y es la más cara de todas. Un test intermitente que se relanza hasta que pasa enseña al equipo a ignorar los fallos rojos, y el día que uno sea real nadie lo va a mirar. **Un test intermitente es un test roto**, aunque el código que prueba esté bien.

**"Es el pipeline, que es más lento."** Medio callejón. Sí es más lento, y eso **revela** intermitentes de asincronía en vez de causarlos: un `subscribe` que en tu máquina resuelve en 2 ms y en el runner en 40 ms cambia el orden de ejecución. El pipeline no rompió el test; lo destapó.

**"Le subo el timeout."** Tapa el sospechoso 4 y sólo a veces. Un test que necesita más tiempo está esperando algo que no controla, y la respuesta es controlarlo con `fakeAsync`, no darle más margen al azar.

**"Voy a poner `xit` mientras tanto."** Es legítimo **como decisión consciente y con fecha**, y es un desastre como reflejo. Un `xit` sin comentario ni ticket es un test que nadie va a volver a mirar, y encima el coverage sigue contando la línea como cubierta si otro test la toca de refilón — que es exactamente el incidente 20.

---

## 🧨 Deshacer

Quita los `xdescribe` de la bisección: uno olvidado desactiva media suite y el coverage baja sin que nadie sepa por qué. `grep -rn "xdescribe\|xit\|fdescribe\|fit" src/` antes de commitear — y `fdescribe` es peor que `xdescribe`, porque hace pasar la suite entera ejecutando **un solo bloque**.

Si terminaste una bisección: `git bisect reset`. Si dejaste ramas de incidente sin fusionar, los tags `inc/…` ya conservan los dos puntos, así que la rama se puede borrar sin perder nada.

---

## 🧠 El patrón transferible

> **Un test intermitente es un test roto.** No es una molestia del pipeline ni una peculiaridad del runner: es una prueba que a veces no prueba, y eso vale menos que no tenerla, porque además genera confianza.

Y el segundo, que es el que más cambia la forma de trabajar: **el test va antes que el fix, y el motivo no es la disciplina.** Un test escrito después pasa desde el primer momento y no hay ninguna evidencia de que habría fallado antes. Verlo en rojo es lo único que demuestra que prueba lo que dice probar — y el par de tags que lo rodea convierte esa evidencia en algo que sigue ahí dentro de seis meses.

**Incidentes del cuaderno que usan esta ruta:** 17 (el intermitente) y 20 (el coverage que no protegió), más el 08, cuyo cierre **es** la ruta A de esta pieza — y con él el de todos los demás: cada incidente del cuaderno termina con su test de regresión.
**Amplía:** **A11** §7 para lo que caduca de esta suite en Angular 17+, y [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) para el par de tags `-roto` / `-fix`.
