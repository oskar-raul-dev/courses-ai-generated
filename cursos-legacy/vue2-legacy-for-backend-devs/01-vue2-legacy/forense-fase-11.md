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

"Toqué el de al lado" es el dato que orienta todo el recorrido: si un cambio en
otro archivo altera este resultado, la suite comparte algo entre archivos, y ese
algo es el sospechoso.

---

## 🧭 La ruta

Del más barato al más caro: primero se confirma la dependencia del orden (dos
comandos), después se busca qué se comparte, y solo al final se lee el test.

### Paso 1 — ¿de verdad depende del orden?

Corre el test solo, y después toda la suite en serie:

```bash
npx vue-cli-service test:unit -t "fetchTickets"
```

```
PASS  tests/unit/store-tickets.spec.js
  ✓ fetchTickets guarda los tickets en el state (12 ms)
```

```bash
npx vue-cli-service test:unit --runInBand
```

```
FAIL  tests/unit/store-tickets.spec.js
  ✕ fetchTickets guarda los tickets en el state (8 ms)

    expect(jest.fn()).toHaveBeenCalledTimes(expected)
    Expected number of calls: 1
    Received number of calls: 3
```

**Qué descarta.** Descarta el código de producción por completo: el store hace
lo mismo en los dos casos. Y el mensaje de fallo trae el diagnóstico casi
regalado — **tres llamadas donde esperabas una** no es un bug de tu store, es un
contador que venía con cuentas de antes.

### Paso 2 — ¿qué se comparte entre tests?

Busca los dos sospechosos habituales, en este orden:

```bash
grep -rn "jest.mock\|clearAllMocks\|resetModules" tests/unit/
```

```
tests/unit/store-tickets.spec.js:4:jest.mock("@/services/ticketService");
tests/unit/store-tickets.spec.js:22:    jest.clearAllMocks();
tests/unit/ticketService.spec.js:3:jest.mock("@/services/apiClient");
```

**Qué descarta.** Si `clearAllMocks` está y el fallo persiste, descarta la causa
más común y sigue al paso 3. Si **no** está en el archivo que falla, ya
terminaste: los mocks son objetos vivos que acumulan llamadas, y sin limpieza
entre tests el segundo hereda el historial del primero. Es exactamente el
"falla en conjunto pero no solo" del reporte.

### Paso 3 — ¿o es un módulo que guarda estado?

Si los mocks están limpios, el sospechoso es cualquier módulo con memoria. En
este proyecto hay dos con nombre y apellido: la **caché de la action** de la
Fase 10 y el **singleton del socket** de la Fase 8.

```js
// en el test, antes de nada:
console.log(store.state.tickets.items.length);
```

```
0      // corrido solo
8      // corrido después del test que puebla el store
```

**Qué descarta.** Cierra el caso cuando el culpable es estado de módulo: un
store creado una vez para todo el archivo —o peor, importado del `store/index.js`
real— arrastra lo que hicieron los tests anteriores, y la action con caché
decide no llamar al servicio porque "ya tiene datos". De ahí el contador de
llamadas que no cuadra. La fase lo resuelve creando el store dentro del
`beforeEach`, con `createLocalVue`.

### Paso 4 — el caso peor: el test que nunca falla

Aprovecha que estás acá y comprueba lo contrario, que es más grave y no reporta
nadie:

```js
it("guarda los tickets", function () {
  store.dispatch("tickets/fetchTickets");        // ⚠️ sin return, sin await
  expect(store.state.tickets.items).toHaveLength(3);
});
```

```
PASS  tests/unit/store-tickets.spec.js
  ✓ guarda los tickets (3 ms)
```

Rompe el store a propósito —cambia la mutation para que no guarde nada— y vuelve
a correr:

```
PASS  tests/unit/store-tickets.spec.js
  ✓ guarda los tickets (3 ms)
```

**Qué descarta.** Descarta la idea de que "verde" signifique algo. El test
termina antes de que la promesa se resuelva, así que la aserción corre sobre el
state inicial y nunca falla. **Un test que sigue en verde con el código roto no
está probando nada**, y la única forma de descubrirlo es la que acabas de hacer:
romper a propósito lo que dice probar.

### Paso 5 — ¿es el test o es la maquetación?

Si el fallo apareció después de un cambio de plantilla y no de lógica:

```
FAIL  tests/unit/TicketsTable.spec.js
  ✕ muestra el estado del ticket

    Cannot read property 'text' of undefined
      wrapper.find(".col-md-6 > div:nth-child(2)")
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
| "Expected 1 call, received 3" | Un mock que arrastra llamadas de tests anteriores |
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

El paso 4 te pide romper el store a propósito. Para volver:

```bash
git checkout -- src/store/modules/tickets.js
npx vue-cli-service test:unit
```

Y si el experimento te resultó revelador, es material de commit: el par
`ej/f11/3-roto` / `ej/f11/3-fix` de la
[convención de tags](../prompts/convencion-de-git-y-tags.md) existe para eso.

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
