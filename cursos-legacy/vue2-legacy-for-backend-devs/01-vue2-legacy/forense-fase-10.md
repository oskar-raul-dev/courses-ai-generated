# 🕵️ Forense Fase 10 — "El estado cambió y nadie sabe quién lo cambió" ⭐

> **Sale de:** [Fase 10 — Vuex a fondo](10-vuex-a-fondo.md) ·
> **Herramientas:** Vue DevTools → pestaña **Vuex** (registro de mutations y
> time travel), y `git log -S` · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** un dato compartido cambia solo, y el registro
> de mutations no tiene ninguna entrada que lo explique.

Ésta es la tercera pieza estrella, y la que mejor resume por qué existe Vuex. La
ceremonia del store —mutations con nombre, actions que orquestan, plugins— no es
burocracia: es lo que convierte "el estado cambió" en **"la mutation
`SET_TICKETS` lo cambió a las 10:42:07 con este payload"**. Cuando ese registro
tiene un hueco, el hueco es el bug.

---

## 🎫 El ticket

> "A veces la lista de tickets se queda con datos raros: aparecen tickets que
> ya resolví, o desaparece uno que acabo de crear. No sé decirte cuándo pasa.
> Y cuando pasa, si navego a otra pantalla y vuelvo, unas veces se arregla y
> otras no."
>
> — coordinadora de soporte · **Ambiente:** desarrollo y UAT

Un reporte sin pasos de reproducción, que es lo normal cuando el estado global
es el enfermo: el usuario no puede ver el estado, solo sus consecuencias, y las
consecuencias aparecen en pantallas distintas de donde estuvo el daño.

---

## 🧭 La ruta

Del más barato al más caro: el registro de mutations ya está grabando —solo hay
que abrirlo—, el time travel cuesta un clic, y el `grep` es lo último.

### Paso 1 — ¿está encendido el testigo?

Vue DevTools → pestaña **Vuex**. Antes de investigar nada, comprueba que el
sistema esté siendo vigilado:

```js
// src/store/index.js
strict: process.env.NODE_ENV !== "production",
```

**Qué descarta.** No descarta un bug: decide si esta investigación es posible.
Con `strict` encendido, cualquier escritura al state fuera de una mutation
lanza un error inmediato en desarrollo. Si está apagado —o si estás mirando un
build de producción, donde **siempre** está apagado— las mutaciones furtivas
ocurren en silencio y el time travel muestra una historia falsa. Éste es también
el motivo de que un bug pueda existir solo en producción: no es que el código
cambie, es que el vigilante se fue.

### Paso 2 — ¿hay mutation para lo que pasó?

Reproduce lo que puedas y mira el registro.

```
Mutations
  tickets/SET_LOADING     10:42:06.912   true
  tickets/SET_TICKETS     10:42:07.238   Array[8]
  tickets/SET_LOADING     10:42:07.240   false
```

Ahora provoca el síntoma —o espera a que aparezca— y vuelve a mirar:

```
(sin entradas nuevas, y el state es distinto)
```

**Qué descarta.** Éste es el paso que parte el caso en dos. Si el estado cambió y
**no hay mutation**, alguien escribió el state directamente y ya sabes qué tipo
de bug tienes; salta al paso 3. Si **sí** hay mutation pero con un payload que
no esperabas, el bug está en quien la despacha: salta al paso 4.

### Paso 3 — ¿quién escribe fuera de una mutation?

Con `strict` encendido, el propio Vuex te lo dice en la consola:

```
Error: [vuex] do not mutate vuex store state outside mutation handlers.
```

Y si necesitas ubicar el sitio, pregúntale a git antes que al editor:

```bash
git log --oneline -S "state.items.push"
```

```
c81f0a2 f10 ej14: el socket alimenta el store
```

**Qué descarta.** Cierra el caso. Los sospechosos habituales son tres, y los
tres aparecen en los errores comunes de la fase: un componente que escribe
`this.$store.state.tickets.items` directamente, una action que se salta su
propia mutation (`context.state.items.push(...)`), o un plugin que commitea mal.
Fíjate en la ironía útil: **el error de strict mode es el mejor regalo de esta
fase**, porque convierte un bug intermitente en uno que salta al instante y con
stack trace.

### Paso 4 — ¿la mutation correcta, en el módulo correcto?

Si la mutation existe pero el efecto es otro, mira el nombre completo con su
espacio de nombres:

```
Mutations
  SET_TICKETS            10:51:02.114   Array[3]     ← ⚠️ sin prefijo de módulo
```

```bash
grep -rn "namespaced" src/store/modules/
```

```
src/store/modules/tickets.js:4:  namespaced: true,
src/store/modules/ui.js:3:  // namespaced: true,
```

**Qué descarta.** Descarta el módulo que sí está bien y explica los efectos
fantasma. Sin `namespaced: true`, los getters y las actions de ese módulo viven
en el espacio global: dos módulos con un `SET_LOADING` se pisan **en silencio**,
sin warning, y un `dispatch("fetchTickets")` puede ejecutar el de otro módulo.
No hay error porque, para Vuex, no hay nada malo: le pediste algo que existe.

### Paso 5 — ¿y si la vista nunca se enteró del final?

Última rama, y es una reincidencia declarada: la vista despacha, la action hace
su trabajo, y la vista se queda esperando algo que nunca llega.

```js
> $vm0.$store.dispatch("tickets/fetchTickets").then(function () { console.log("ok"); })
Uncaught TypeError: Cannot read property 'then' of undefined
```

**Qué descarta.** Descarta el store: los datos llegaron, las mutations están en
el registro, el state es correcto. Lo que falta es el `return` de la Promise
dentro de la action. La [Fase 3](forense-fase-03.md) enseñó este mismo error con
un servicio; acá tiene más víctimas, porque toda vista que despache se queda sin
poder encadenar nada — ni redirigir, ni apagar un spinner propio, ni mostrar un
error.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| El estado cambió y no hay mutation en el registro | Escritura directa al state: `strict` la caza |
| `do not mutate vuex store state outside mutation handlers` | Ya tienes el sitio: mira el stack, es literal |
| Una mutation sin prefijo de módulo | Falta `namespaced: true`: colisión silenciosa |
| Un `dispatch` ejecuta la action de otro módulo | Lo mismo, desde el otro lado |
| La vista no puede encadenar tras despachar | La action no devuelve la Promise (Fase 3, otra vez) |
| Todo va bien en `npm run serve` y raro en el build | `strict` está apagado en producción: las mutaciones furtivas ya no avisan |
| El time travel muestra estados que no cuadran | Hay async dentro de una mutation: el registro miente por diseño |
| El evento de socket se aplica N veces | Quedaron los handlers de las vistas **y** el plugin del store |
| Un getter recalcula sin parar dentro de un `v-for` | Getter-función sin caché: deriva un mapa en un getter normal |
| El store navega, o importa un componente | El flujo es UI → store; la navegación es de la vista que despachó |

---

## ⚰️ Los callejones

**"Vuex está roto, mejor lo saco."** Es la conclusión que saca mucha gente tras
un caso así, y es exactamente al revés: sin Vuex este bug no habría sido
diagnosticable en absoluto. Con un `data` compartido a mano, el estado cambia
igual —o peor— y no hay registro, ni payload, ni time travel. La ceremonia es lo
que te dejó ver el hueco.

**"Habría que meter también los filtros y la selección en el store."** La
auditoría de la fase decidió que no, con nueve fases de evidencia detrás. Un
store más grande no diagnostica mejor: solo hace que haya más sitios donde
alguien pueda escribir sin mutation, que es justo el bug de hoy.

**"Es la caché de la action, que devuelve datos viejos."** La action cachea a
propósito —segunda visita al dashboard sin viaje a la red— y eso puede parecer
el síntoma. La evidencia que lo separa está en el registro: una lectura cacheada
**no produce mutations**, así que si ves `SET_TICKETS` con datos raros, la caché
no fue; y si no ves nada de nada, tampoco fue la caché: fue una escritura
furtiva.

---

## 🧨 Deshacer

Si apagaste `strict` para probar el comportamiento de producción, o si tocaste
un módulo:

```bash
git checkout -- src/store/
```

Y recarga la aplicación: el estado del store vive en memoria y no se limpia con
un `git checkout`.

---

## 🧠 El patrón transferible

**Un cambio sin registro es un cambio que no existió, hasta que hace daño.** Todo
lo que Vuex te cobra —nombrar las mutations, no escribir el state a mano,
concentrar la orquestación en actions— se paga en una sola moneda: la
trazabilidad. Y la trazabilidad no sirve para escribir código, sirve para el día
de esta pieza.

Lo que se transfiere fuera de Vue, y fuera del frontend: **cuando diseñes un
sistema con estado compartido, la pregunta no es "¿cómo lo cambio?" sino "¿cómo
sabré después quién lo cambió?"**. Es la misma pregunta que en tu backend de
siempre justificaba una tabla de auditoría en vez de un `UPDATE` a secas — y la
misma que hace que un `strict` apagado en producción sea una decisión, no un
detalle.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 10](10-vuex-a-fondo.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); los casos completos en los
[incidentes 10 y 12](cuaderno-incidentes.md); y el mismo conflicto —el
framework queriendo el estado que tu store ya controla— en las piezas de ruta
[Q](forense-ruta-q.md), [VU](forense-ruta-vu.md) y [NX](forense-ruta-nx.md).
