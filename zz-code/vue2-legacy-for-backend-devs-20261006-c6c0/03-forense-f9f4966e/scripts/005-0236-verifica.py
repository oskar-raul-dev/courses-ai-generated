# rescatado de la sesión f9f4966e, 2026-09-10T02:36:05Z · Stitch Quasar route phases
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser2
Q="forense-ruta-q.md"

coser2("q0-red-de-seguridad.md", Q,
"""Antes de migrar nada, la pieza de ruta se lee entera **una vez** — no para
resolver un bug de hoy, sino para saber qué forma tienen los bugs que vas a
provocar mañana. El eje de toda la ruta 🅠 es que **en Quasar casi nada grita**:
la mitad de los fallos no producen error, y la otra mitad produce uno que habla
de Vuex cuando el problema es de la tabla. La red de seguridad que montas en
esta fase existe justo por eso — con un framework silencioso, el test es el
único que avisa. Y hay una comprobación de esta fase que la pieza asume hecha:
que tus tests fallan cuando tienen que fallar.""",
"""Rompe a propósito una de las vistas que acabas de cubrir —quita el filtro,
invierte una condición— y corre la red de seguridad:

```bash
npx vue-cli-service test:unit
```

Si sigue verde, tu red tiene un agujero **hoy**, que es infinitamente más barato
que descubrirlo a mitad de la migración. Deshaz con `git checkout -- src/`.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("q1-leer-quasar.md", Q,
"""El síntoma característico de leer Quasar por primera vez es *"copié el template
y no se ve nada, y no sale ningún error"*. La causa está a diez segundos de
distancia y no está en tu código: un componente de Quasar 1 que **no está
declarado en `framework.components` de `quasar.conf.js` no renderiza y no
avisa** —y si tenía `<slot>`, se lleva por delante el contenido de adentro—. Eso
explica también el clásico "en la máquina de Ana funciona": copiaste el
template, no la configuración. Es el paso 1 de la pieza de ruta y conviene
tenerlo de reflejo antes de escribir una línea.""",
"""Quita un componente de la lista de `framework.components` en `quasar.conf.js`
—uno que estés usando, por ejemplo `QChip`— y recarga:

```bash
grep -n "components:" -A 12 quasar.conf.js
```

Mira la pantalla y mira la consola. Anota cuánto tarda en aparecer un mensaje
que te sirva de algo. Vuelve a ponerlo y recarga: en `quasar.conf.js` los
cambios exigen reiniciar el servidor de desarrollo.""",
"## ⚠️ 6. Errores clásicos","## ⚠️ 6. Errores clásicos y pieza forense","### Errores clásicos")

coser2("q2-migrar-crud-qform.md", Q,
"""El fallo propio de esta fase es un formulario que **guarda aunque dejes campos
vacíos**, cuando antes no dejaba. Es el paso 2 de la pieza de ruta: los métodos
del framework no devuelven lo que tu instinto espera. La validación de `QForm`
es asíncrona —`validate()` devuelve una **Promise**, y una Promise siempre es
"verdadera" en un `if`— así que la migración silencia la validación sin cambiar
una sola regla. El mismo cuidado vale para el valor que el componente guarda:
un `QSelect` con opciones de objeto no guarda el string que ves.""",
"""Escribe la trampa a propósito y míralas fallar a las dos:

```js
if (this.$refs.form.validate()) { this.save(); }   // ← siempre entra
```

Guarda con el título vacío: pasa. Ahora corrígelo con `await` o `.then()` y
repítelo. Dos líneas, dos comportamientos, cero errores en consola — que es
exactamente el modo en que esta ruta rompe las cosas.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("q3-migrar-dashboard-qtable.md", Q,
"""Aquí aparece el conflicto central de toda la ruta, y por eso la Fase 10 del
tronco no era opcional: **`QTable` quiere ser dueña del estado que tu store ya
controla.** El síntoma llega disfrazado —"dice 1-10 de 10 y hay 87 tickets", "al
pasar a la página 2 me muestra la 1"— y la causa es que la tabla está paginando
y ordenando por su cuenta un conjunto que tu store ya paginó. Es el paso 3 de la
pieza: la pregunta no es *"¿por qué falla la tabla?"* sino **"¿quién manda,
ella o mi store?"**, y las dos respuestas son válidas mientras elijas una.""",
"""Deja que manden los dos a la vez, que es el estado natural de una migración a
medias: conserva tu paginación en el store y no declares `:pagination.sync` ni
`server-side` en la tabla.

Navega a la página 2 y compara tres números: los que muestra la tabla, los que
tiene el store en Vue DevTools → Vuex, y los que pidió Network. Cuando los tres
no coinciden, el bug no está en ninguno de los tres: está en que hay tres.""",
"## 🐛 6. Errores clásicos","## 🐛 6. Errores clásicos y pieza forense","### Errores clásicos")

coser2("q4-timeline-actividad.md", Q,
"""La fase donde se juntan los dos fallos de la ruta: el componente que no está
declarado —`QTimeline` y sus hijos son los grandes olvidados de
`framework.components`— y el dato que llega con otra forma. Vale la pena releer
el 🩺 índice de síntomas de la pieza de ruta con la vista terminada delante: a
estas alturas ya reconoces los cuatro modos en que Quasar falla sin decir nada, y
ése es el verdadero entregable de la ruta.""",
"""Comprueba el silencio una última vez, ahora que ya lo esperas: quita
`QTimelineEntry` de `framework.components` y deja `QTimeline`.

La línea de tiempo se pinta **vacía**, con su marco y sin sus entradas. Ningún
error. Si esta vez lo diagnosticaste en menos de un minuto, la ruta cumplió.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")
