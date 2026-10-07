# rescatado de la sesión f9f4966e, 2026-09-10T02:34:48Z · Stitch phases 08-11
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser
RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("08-websockets-minimos.md","forense-fase-08.md",
"""⭐ La pieza estrella del curso, y no por dificultad técnica: es la única cuyo
recorrido termina **encontrando una deuda 💸 que este material te declaró cien
líneas antes** y que probablemente leíste sin entender del todo. Una pantalla se
enteró y la otra no, y las dos creen tener la verdad. Se depura con Network →
**WS** y dos navegadores abiertos, y el orden importa: primero si el evento se
propagó o simplemente no se pintó, después qué pasó por el socket, y solo
entonces **quién emite y qué emite**. Ahí llega la pregunta incómoda —*¿y quién
**debería** emitirlo?*— cuya respuesta no es un fix de esta fase: el cliente
está anunciando un hecho que él mismo decidió, y el servidor es un simple relé
que repite lo que le digan. Se paga cuando exista un backend que confirme la
escritura antes de anunciarla.""",
"""Miente por el socket, desde la consola de un navegador, sin tocar el `db.json`:

```js
> socket.emit("ticket:updated", { id: 1, status: "closed", assignee: "quien-sea" })
```

Mira la otra pestaña: se lo cree. Nadie escribió nada, y la interfaz ya cambió.
Recarga y desaparece — porque nunca existió. Ese experimento de veinte segundos
es toda la lección de la fase.""",
RES + '| 08 | "Se me duplican los tickets cuando entra uno nuevo" | Tiempo real | 🟠 |')

coser("09-panel-soporte.md","forense-fase-09.md",
"""Esta fase pone **dos vistas del mismo dato en la misma pantalla** —la cola y el
workspace— y ahí es donde los bugs de identidad dejan de ser teóricos. El PATCH
salió bien, la lista se actualizó, y el panel de al lado sigue mostrando lo de
antes. Todos los casos de la pieza son variantes de una sola pregunta: **¿los
dos paneles miran el mismo objeto, o cada uno tiene el suyo?** Se depura con Vue
DevTools → Components comparando lo que tiene cada panel, y la distinción que
resuelve el caso es la del paso 3: copia o referencia. Un `Object.assign` bien
intencionado en el sitio equivocado convierte una referencia compartida en dos
objetos que ya no se hablan. El paso 5 añade el hermano silencioso: la
propiedad que se agregó después y a la que Vue 2 nunca se suscribió.""",
"""Toma un ticket desde la cola con el workspace abierto en ese mismo ticket, y
compara los dos objetos en Vue DevTools antes y después:

```js
> $vm0.ticket === $vm1.ticket     // ¿el mismo objeto, o dos?
```

Después hazlo al revés: cambia el estado desde el workspace y mira la cola.
Si una de las dos direcciones funciona y la otra no, ya sabes de qué lado está
la copia. Si probaste tomando tickets, `npm run mock:reset` deja el mock limpio.""",
RES + '| 09 | "Tomé el ticket y a mi compañera le sigue apareciendo libre" | Estado | 🟠 |')

coser("10-vuex-a-fondo.md","forense-fase-10.md",
"""⭐ La tercera pieza estrella, y la que mejor resume por qué existe Vuex. Un dato
compartido cambia solo y el registro de mutations no tiene ninguna entrada que
lo explique: **el hueco en el registro es el bug.** La ceremonia del store
—mutations con nombre, actions que orquestan, plugins— no es burocracia: es lo
que convierte "el estado cambió" en *"la mutation `SET_TICKETS` lo cambió a las
10:42:07 con este payload"*. Se depura en Vue DevTools → pestaña **Vuex**, con
el registro y el time travel, y el recorrido va de si el testigo está encendido
(`strict`) a quién escribe fuera de una mutation, pasando por el módulo
equivocado. El paso 5 cubre el caso simétrico y más molesto: la mutation ocurrió,
el estado es correcto, y la vista nunca se enteró.""",
"""Escribe en el estado por la puerta de atrás, desde la consola, con el store en
modo `strict`:

```js
> this.$store.state.tickets.items.push({ id: 999, title: "fantasma" })
```

Mira dos cosas a la vez: el aviso que Vue lanza en consola, y el registro de
mutations, que sigue vacío. Después apaga `strict` y repítelo: el aviso
desaparece y el bug se queda. Para volver: `git checkout -- src/store/` y
recarga la aplicación.""",
RES + '| 10 | "El contador del menú dice una cosa y la tabla otra" | Estado (Vuex) | 🟠 |\n| 12 | "En el servidor de pruebas se comporta distinto que en mi máquina" | Build | 🔴 |')

coser("11-testing-minimo.md","forense-fase-11.md",
"""Un test que depende del orden no es un test: es un dado. Y hay un caso peor que
el de hoy —el test que **nunca** falla—, porque ése ni siquiera avisa. Las dos
patologías tienen la misma raíz: **estado que sobrevive de un test a otro**, o
promesas que nadie esperó. Se depura con la propia salida de Jest antes que con
el código: `-t` para correr uno solo, `--runInBand` para quitar el paralelismo,
y la comparación entre las dos corridas es la que dice si el orden importa.
Ojo con la conclusión cómoda: si `--runInBand` lo pone verde, eso **no** es el
arreglo — es el diagnóstico. El arreglo es que cada test monte lo suyo y lo
desmonte, y el mejor test de tu suite es el que rompes a propósito para
comprobar que sabe fallar.""",
"""Comprueba que tus tests saben fallar. Rompe la lógica que uno de ellos dice
proteger —invierte una condición en una mutation del store— y corre la suite:

```bash
npx vue-cli-service test:unit
```

Si sigue en verde, ese test no estaba probando lo que creías. Para volver:
`git checkout -- src/store/modules/tickets.js`. El experimento es material de
commit: el par `ej/f11/3-roto` / `ej/f11/3-fix` existe para eso.""",
RES + '| 11 | "El test pasa solo cuando lo corro aislado" | Testing | 🔴 |')
