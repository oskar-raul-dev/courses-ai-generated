# rescatado de la sesión f9f4966e, 2026-09-10T02:32:56Z · Stitch phases 00-03 of course 01
import sys, io
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser

RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("00-setup-hola-mundo.md", "forense-fase-00.md",
"""Lo que se rompe en esta fase casi nunca es tu código: es el entorno. Un
`Vue packages version mismatch`, un muro de `gyp ERR!` o un `EADDRINUSE` hablan
de versiones, de Node y de puertos, y ninguno de los tres se depura abriendo un
`.vue`. La señal está siempre en las **primeras líneas** de la salida de
`vue-cli-service` —no en las últimas, que es donde todo el mundo mira— y el
entorno entero se descarta en tres minutos con `node -v` y
`npm ls vue vue-template-compiler`. Si esas dos versiones no coinciden, ya
terminaste: no sigas leyendo el error.""",
"""Desalinea el compilador de plantillas a propósito y lee el error completo antes
de arreglarlo — es el que te vas a encontrar en la mitad de los proyectos Vue 2
ajenos:

```bash
npm install vue-template-compiler@2.6.10 --save-exact
npm run serve
```

Para volver: `npm install vue@2.6.14 vue-template-compiler@2.6.14 --save-exact`.""",
RES + '| 01 | "Clonaste el repo y no me arranca, a ti sí te funciona" | Build | 🟢 |')

coser("01-estructura-base-legacy.md", "forense-fase-01.md",
"""La investigación típica de esta fase no termina en un bug: termina en **una
decisión que nadie tomó**. Entras a `/tickets/999`, el router hace match, la
vista se monta y lo que se pinta es un hueco — sin error en consola, porque
nadie cometió ninguno. Se depura con Vue DevTools → **Components** junto a la
URL, en este orden: qué se montó, qué tiene adentro, y quién devolvió el hueco.
La señal que lo delata es un `data` con la propiedad en `undefined` y una
consola limpia: el servicio contestó bien —un `Array.find` que no encuentra
devuelve `undefined`, y eso es correcto— y la vista nunca preguntó si el ticket
no existe o todavía no llegó. Esa pregunta es de presentación, no de datos, y en
la Fase 3 se vuelve cara: el mismo `undefined` va a significar además "el
servidor no contestó".""",
"""Con la app corriendo, entra a mano a una URL con un `id` que no existe:

```
http://localhost:8080/tickets/999
```

Abre Vue DevTools → Components, selecciona la vista de detalle y mira su `data`.
Anota tres cosas: qué componente se montó, qué tipo tiene `$route.params.id`
(pista: no es un número) y cuántos errores hay en la consola. Las tres importan
más que el fix.""",
"""Esta fase no reserva incidentes. La estructura, el router y el layout se
prueban en cada fase posterior, así que sus fallos llegan al cuaderno
disfrazados de otra cosa: el arranque roto es de la Fase 0 y el hueco sin
mensaje se convierte en material de la Fase 3, cuando el mismo síntoma puede
tener tres causas distintas.""")

coser("02-autenticacion-minima.md", "forense-fase-02.md",
"""El fallo característico de esta fase es que **la aplicación toma una decisión
importante y no deja rastro**: te devuelve a `/login` sin mensaje, sin error en
consola y sin nada en Network. Esa ausencia de evidencia es la evidencia — si
nada se registró, el que te expulsó fue código tuyo que no consideró digno de
contarse lo que hizo. Se depura con DevTools → **Application → `localStorage`**
y Vue DevTools → **Vuex**, y la pregunta que ordena el recorrido es cuál de las
**dos copias del mismo dato** manda: la del storage o la del store. Cuando no
coinciden, el guard cree una cosa y la interfaz muestra otra. Y hay un límite
que esta fase no puede cruzar y conviene tener claro: el guard comprueba que el
token **esté**, no que **sirva** — sin un servidor que conteste 401, no hay
forma de saberlo desde acá.""",
"""Con la sesión abierta, borra el token a mano y navega **sin recargar**:

```js
> localStorage.removeItem("token")
```

Haz clic en otra vista protegida. ¿Te expulsa ahora, al recargar, o nunca?
La respuesta te dice cuál de las dos copias está mandando en cada momento.
Para volver: `localStorage.clear()` y entra de nuevo con `admin` / `1234`.""",
RES + '| 03 | "Me sacó al login a mitad de la mañana, sin decir nada" | Estado | 🟡 |')

coser("03-mock-api-minima.md", "forense-fase-03.md",
"""Ésta es la fase que más rinde del tronco, y no porque sus bugs sean difíciles:
es porque acá se aprende a leer **Network**, que sirve para todas las que
vienen. La lección central es incómoda: desde el código del cliente, *"el
servidor está apagado"*, *"el navegador me bloqueó la respuesta"* y *"el
servidor recibió el request y no contestó"* son **el mismo evento** — tu `catch`
no puede distinguirlos, y Network sí. El orden del recorrido es el barato
primero: ¿el request salió, volvió o se quedó a medias?, ¿el servidor está vivo
y solo no contesta esta ruta?, ¿contesta a `curl` y no al navegador? Y el caso
que más despista: el request volvió **en verde** y la pantalla igual está
vacía — ahí el problema ya no es de red, es de forma del dato.""",
"""El inyector de caos de este capítulo existe justo para esto. Levanta el mock
mintiendo y mira la lista de tickets:

```bash
CHAOS=timeout npm run mock      # el mock no contesta
CHAOS=malformed npm run mock    # el mock contesta cualquier cosa
```

Con cada uno, anota qué ve el usuario, qué dice la consola y qué dice Network.
Los tres son distintos, y ésa es la lección. Se apaga solo: `Ctrl+C` y
`npm run mock` sin variable.""",
RES + '| 02 | "A veces carga y a veces se queda pensando" | Integración (mock) | 🟢 |')
