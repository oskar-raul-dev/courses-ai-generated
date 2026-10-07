# rescatado de la sesión f9f4966e, 2026-09-10T02:37:25Z · Stitch Nuxt route phases
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser2
N="forense-ruta-nx.md"

coser2("nx0-red-de-seguridad.md", N,
"""La pieza de ruta se lee entera **una vez** antes de migrar nada. El eje de la
ruta 🅝 no lo tiene ninguna otra: **tu código corre en dos sitios con capacidades
distintas**, y casi todos los fallos son un trozo de código ejecutándose donde no
debería. Eso cambia hasta dónde se mira primero — en Nuxt, la **terminal del
servidor** va antes que la consola del navegador, porque la mitad de los errores
ni siquiera llegan al navegador. La red de seguridad de esta fase es lo que te
permitirá distinguir "lo rompí yo" de "esto ya se comportaba así en el
servidor".""",
"""Rompe a propósito una vista cubierta y corre la red:

```bash
npx vue-cli-service test:unit
```

Y una comprobación propia de esta ruta: prueba cada pantalla **recargando con
F5**, no solo navegando desde el menú. Son dos caminos distintos —uno pinta en
el servidor y el otro no— y tu red debería cubrir los dos. Deshaz con
`git checkout -- src/`.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("nx1-leer-nuxt.md", N,
"""Leer Nuxt por primera vez tiene un síntoma clásico: *"si entro desde el menú
funciona, pero si recargo con F5 se cae"*. La causa es la que este capítulo
explica y la pieza de ruta convierte en reflejo: **el ciclo de vida se ejecuta
dos veces**, y `created()` corre también en el servidor, donde no hay `window` ni
`localStorage`. La primera pregunta de cualquier investigación en esta ruta es
por tanto *"¿dónde se ejecutó el código que falló?"*, y la respuesta está en la
terminal del servidor Nuxt, no en la consola del navegador.""",
"""Pon una línea que solo puede vivir en el navegador dentro de `created()` de
cualquier página:

```js
created: function () { console.log(window.innerWidth); }
```

Navega a esa página **desde el menú**: funciona. Ahora recarga con **F5**: se
cae, y el error sale en la terminal, no en la consola. Mueve la misma línea a
`mounted()` y repite las dos pruebas. Ésa es toda la ruta en un experimento.""",
"## ⚠️ Errores y confusiones típicas al leer Nuxt por primera vez",
"## ⚠️ Errores, confusiones típicas y pieza forense",
"### Errores y confusiones típicas al leer Nuxt por primera vez")

coser2("nx2-hidratacion-window-not-defined.md", N,
"""Esta fase cubre los dos primeros pasos de la pieza de ruta, que son el corazón
del track: **dónde se ejecutó el código que falló**, y **si el servidor y el
cliente pintaron lo mismo**. El primer síntoma —`window is not defined`— es
honesto y se arregla rápido. El segundo es el traicionero: *"aparece un parpadeo
raro y después la lista sale vacía, pero en el código fuente de la página sí
están los tickets"*. Eso es una **falta de coincidencia de hidratación**: el
servidor pintó una cosa, el cliente pintó otra, y Vue tiró lo primero. Se
diagnostica con "Ver código fuente de la página" —no con el inspector, que
muestra el DOM ya hidratado— y la causa casi siempre es un `Date.now()`, un
`Math.random()` o un dato que solo existe en un lado.""",
"""Provoca la falta de coincidencia a propósito: pinta algo que no puede coincidir
entre las dos ejecuciones.

```html
<p>Generado: {{ new Date().toLocaleTimeString() }}</p>
```

Recarga con F5 y mira dos sitios en este orden: el aviso de hidratación en la
consola, y "Ver código fuente de la página" comparado con lo que ves. Son dos
HTML distintos, y uno de los dos perdió.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("nx3-asyncdata-vs-vuex.md", N,
"""Aquí está el conflicto central de las tres rutas en su forma más pura, y por eso
la Fase 10 del tronco no era opcional: **`asyncData` quiere ser dueño de datos
que tu store ya controla.** Es el paso 3 de la pieza —*"¿de quién son los datos,
de la página o del store?"*— y en Nuxt duele más que en Quasar o Vuetify, porque
`asyncData` se ejecuta **antes de que el componente exista** y no tiene `this`:
lo que devuelve se fusiona con el `data` de la página y no pasa por ninguna
mutation. Resultado: dos copias del mismo dato, una de ellas invisible para el
registro de Vuex, que era justamente el testigo en el que aprendiste a
confiar.""",
"""Haz que las dos fuentes se contradigan y mira cuál gana:

```js
asyncData: function ({ $axios }) { return { tickets: [] }; }   // vacío a propósito
```

…con el store lleno. Recarga con F5 y navega después desde el menú: los dos
caminos dan resultados distintos, y el registro de mutations no menciona ninguno
de los dos. Deshaz y decide, con la pieza delante, cuál de las dos fuentes manda
en tu aplicación.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("nx4-pagina-ssr-nueva.md", N,
"""La fase de cierre añade el cuarto paso de la pieza, el que solo aparece cuando
la aplicación sale de tu máquina: **¿esto depende de dónde esté corriendo el
proceso?** *"El login no funciona en el servidor de pruebas y en local va bien"*
es el ticket, y la causa vive en la frontera —variables de entorno que existen en
un lado y no en el otro, una URL de API relativa que el servidor no sabe
resolver, cookies contra `localStorage`—. Con la página nueva terminada, vale la
pena releer el 🩺 índice de síntomas de la pieza: ya reconoces los cuatro modos
de fallo de la ruta, y ése es el entregable real.""",
"""Comprueba la frontera con el experimento más barato que existe: apaga una
variable de entorno que tu página use y arranca en modo producción.

```bash
npm run build && npm run start
```

Compara el fallo con el que produce el mismo cambio en `npm run dev`. Si no se
parecen, ya sabes por qué "en local va bien" nunca fue un diagnóstico.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")
