# 🕵️ Forense Fase 11 — "El test pasa solo cuando lo corro aislado"

> **Sale de:** [Fase 11 — Testing mínimo](11-testing-minimo.md) ·
> **Herramientas:** la salida de Jest (con `-t` y `--runInBand`), y el propio
> código del test · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el mismo test, con el mismo código, da verde o
> rojo según con quién corra.

Un test que depende del orden no es un test: es un dado. Y hay un caso todavía
peor que el de hoy —el test que **nunca** falla— porque ése ni siquiera te
avisa de que algo va mal. Las dos patologías tienen la misma raíz: **estado que
sobrevive de un test a otro**, o promesas que nadie esperó.

---

## 🎫 El ticket

> "El test de `fetchTickets` me falla desde ayer. Lo corro solo con `-t` y pasa
> perfecto. Lo corro con toda la suite y falla. No toqué ese archivo, toqué el
> de al lado. Ya borré `node_modules` y sigue igual."
>
> — un compañero del equipo, en el canal de dev · **Ambiente:** local y CI

"Toqué el de al lado" parece el dato que orienta todo el recorrido, y es una pista
falsa que vale la pena desarmar primero: Jest corre **cada archivo** con su propio
registro de módulos, así que un archivo no le hereda mocks ni estado a otro. Lo que
cambia entre "solo" y "con toda la suite" es qué tests corren **antes, dentro del
mismo archivo**. Ahí está el sospechoso.

---

## 🧭 La ruta

Del más barato al más caro: primero se confirma la dependencia del orden (dos
comandos), después se busca qué se comparte, y solo al final se lee el test.

### Paso 1 — ¿de verdad depende del orden?

Corre el test solo, y después el archivo entero en serie:

```bash
npx vue-cli-service test:unit tests/unit/store-tickets.spec.js -t "con caché"
```

```
PASS tests/unit/store-tickets.spec.js
      ✓ con caché: si hay items y no hay force, NO toca la red (19ms)
```

```bash
npx vue-cli-service test:unit tests/unit/store-tickets.spec.js --runInBand
```

```
FAIL tests/unit/store-tickets.spec.js
      ✓ en éxito: enciende loading, guarda tickets, apaga loading (1ms)
      ✓ en error: guarda el mensaje, apaga loading y RE-LANZA (1ms)
      ✕ con caché: si hay items y no hay force, NO toca la red (48ms)

    expect(jest.fn()).not.toHaveBeenCalled()

    Expected mock function not to be called but it was called with:
      [{"_order": "desc", "_sort": "createdAt"}], [{"_order": "desc", "_sort": "createdAt"}]
```

**Qué descarta.** Descarta el código de producción por completo: la action hace
lo mismo en los dos casos. Y el mensaje de fallo trae el diagnóstico casi
regalado — **dos llamadas donde esperabas ninguna**, con los parámetros de las
pruebas anteriores, no es un bug de tu store: es un espía que venía con cuentas
de antes.

### Paso 2 — ¿qué se comparte entre tests?

Busca los dos sospechosos habituales, en este orden:

```bash
grep -rn "jest.mock\|clearAllMocks\|resetModules" tests/unit/
```

```
tests/unit/ticketService.spec.js:4:jest.mock("@/services/apiClient"); // el cable a axios, cortado
tests/unit/ticketService.spec.js:8:    jest.clearAllMocks();
tests/unit/store-tickets.spec.js:4:jest.mock("@/services/ticketService"); // el cable a HTTP, cortado
tests/unit/store-tickets.spec.js:34:      jest.clearAllMocks(); // que un test no herede llamadas del anterior
```

**Qué descarta.** Si `clearAllMocks` está y el fallo persiste, descarta la causa
más común y sigue al paso 3. Si **no** está en el archivo que falla, ya
terminaste: los mocks son objetos vivos que acumulan llamadas, y sin limpieza
entre tests el segundo hereda el historial del primero. Es exactamente el
"falla en conjunto pero no solo" del reporte.

### Paso 3 — ¿o es estado que sobrevive entre tests?

Si los mocks están limpios, el sospechoso es cualquier cosa con memoria que se
cree una sola vez. En este archivo, el `context` falso de la action: si se crea
fuera del `beforeEach`, su `commit` espía acumula lo de todos.

```js
// al principio del test de caché, antes de nada:
console.log("commits heredados:", context.commit.mock.calls.length);
```

```
commits heredados: 0      // corrido solo, con -t
commits heredados: 8      // corrido después de las pruebas de éxito y de error
```

**Qué descarta.** Cierra el caso cuando el culpable es estado compartido: un
`context` —o un store— creado una vez para todo el archivo arrastra lo que
hicieron los tests anteriores, y la prueba que exige "ningún commit" recibe los
de las demás. La fase lo resuelve creándolo dentro del `beforeEach`, y en los
tests de componentes, con un `createLocalVue` por test.

### Paso 4 — el caso peor: el test que nunca falla

Aprovecha que estás acá y comprueba lo contrario, que es más grave y no reporta
nadie. Quítale el `return` al test de `getTickets` de `ticketService.spec.js`:

```js
it("getTickets pide /tickets con los params y devuelve res.data", function () {
  apiClient.get.mockResolvedValue({ data: [{ id: 1 }], status: 200 });
  ticketService.getTickets({ status: "open" }).then(function (result) {   // ⚠️ sin return
    expect(result).toEqual([{ id: 1 }]);
  });
});
```

Rompe el servicio a propósito —que `getTickets` devuelva `res` en vez de
`res.data`— y corre:

```
PASS tests/unit/ticketService.spec.js
  ✓ getTickets pide /tickets con los params y devuelve res.data (2ms)
```

**Qué descarta.** Descarta la idea de que "verde" signifique algo. El test
termina antes de que la promesa se resuelva, así que la aserción corre cuando ya
nadie la escucha y nunca falla. Con el `return` puesto, el mismo servicio roto da
`FAIL`. **Un test que sigue en verde con el código roto no está probando nada**, y
la única forma de descubrirlo es la que acabas de hacer: romper a propósito lo
que dice probar.

### Paso 5 — ¿es el test o es la maquetación?

Si el fallo apareció después de un cambio de plantilla y no de lógica, el mensaje
de un selector acoplado al DOM se ve así:

```
FAIL tests/unit/TicketsTable.spec.js
  ✕ muestra el estado del ticket (28ms)

    [vue-test-utils]: find did not return .col-md-6 > div:nth-child(2), cannot call text() on empty Wrapper
```

**Qué descarta.** Descarta el componente: hace lo que debe, y lo que se rompió
fue el selector. Un test acoplado al DOM prueba la maquetación de ayer. La fase
lo resuelve con `data-testid`, y el criterio es sencillo: si un cambio visual
que no altera el comportamiento tumba un test, el test estaba mal escrito.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Pasa solo, falla en conjunto | Estado compartido: mocks sin limpiar, o módulo con memoria |
| "Expected mock function not to be called", con parámetros de otro test | Un mock que arrastra llamadas de tests anteriores |
| Un test que nunca falla, aunque rompas el código | Async sin `return`/`await`: la aserción corre antes de tiempo |
| Falla al cambiar la maquetación, sin tocar lógica | Selectores acoplados al DOM en vez de `data-testid` |
| Falla solo en CI | Orden distinto, paralelismo, o zona horaria de la máquina |
| El test es lentísimo y falla por un hijo ajeno | `mount` donde bastaba `shallowMount` |
| El test se rompe con cada refactor inocente | Está probando implementación, no comportamiento |
| Todo verde y el bug sigue en producción | Falta el test de la invariante: mira qué NO se está probando |

---

## ⚰️ Los callejones

**"Borro `node_modules` y reinstalo."** Ya lo hizo quien reportó, y no cambió
nada — como era esperable: el problema no es qué versión hay instalada, es qué
estado sobrevive **dentro de una misma corrida**. Es el mismo reflejo caro que
aparece en la [pieza de la Fase 0](forense-fase-00.md), en otro contexto.

**"Es que Jest corre los tests en paralelo."** Puede empeorar el síntoma, pero
`--runInBand` los pone en serie y el fallo sigue: el paso 1 lo demuestra. El
paralelismo revela dependencias de orden, no las crea.

**"Le pongo `.skip` mientras tanto y sigo."** Es la muerte de las suites legacy,
y ocurre exactamente en este punto: un test intermitente molesta, se salta, y
seis meses después nadie sabe si probaba algo importante. Si de verdad hay que
saltarlo, que sea con un comentario que diga qué invariante quedó sin cubrir.

---

## 🧨 Deshacer

El paso 4 te pide romper el servicio a propósito y quitar un `return`. Para volver:

```bash
git checkout -- src/services/ticketService.js tests/unit/ticketService.spec.js
npx vue-cli-service test:unit
```

Y si el experimento te resultó revelador, es material de commit: el par
`ej/f11/3-roto` / `ej/f11/3-fix` de la
[convención de tags](../00-convencion-de-git-y-tags.md) existe para eso.

---

## 🧠 El patrón transferible

**Un test que depende del orden y un test que nunca falla son el mismo bug visto
desde dos lados: nadie controló el estado con el que empieza y termina cada
prueba.** El primero te lo grita de forma incómoda; el segundo se calla y te deja
creer que estás cubierto, que es mucho peor.

De ahí la única técnica que de verdad se lleva uno de esta pieza, y que sirve en
cualquier lenguaje y cualquier framework: **rompe a propósito lo que el test
dice probar.** Si sigue en verde, no tienes un test, tienes decoración. Es un
minuto de trabajo, se puede hacer sobre una suite heredada que no escribiste, y
es la forma más rápida que existe de saber cuánto vale la red de seguridad que
te acaban de entregar — que es exactamente lo que las fases X0 de las tres rutas
te van a pedir antes de migrar nada.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 11](11-testing-minimo.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); y el caso completo en el
[incidente 11](cuaderno-incidentes.md) del cuaderno.
