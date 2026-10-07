# rescatado de la sesión f9f4966e, 2026-09-10T02:36:44Z · Stitch Vuetify route phases
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser2
V="forense-ruta-vu.md"

coser2("vu0-red-de-seguridad.md", V,
"""La pieza de ruta se lee entera **una vez**, antes de migrar nada, para saber qué
forma tienen los fallos que vienen. El eje de la ruta 🅥 es que **Vuetify falla
sutilmente**: no desaparecen componentes enteros como en Quasar, se descoloca una
línea, un color no cambia con el tema, un diálogo no abre — y la consola, limpia.
Por eso la red de seguridad de esta fase es lo que te va a decir que rompiste
algo: con fallos que no gritan, el test es el único testigo. Y hay un
comprobante que la pieza da por hecho: que tus tests saben fallar.""",
"""Rompe a propósito una de las vistas que acabas de cubrir y corre la red:

```bash
npx vue-cli-service test:unit
```

Si sigue verde, el agujero está en tu red y hoy es barato taparlo. Deshaz con
`git checkout -- src/`.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("vu1-leer-vuetify.md", V,
"""Dos trampas concentran la mitad de los casos de esta ruta y las dos aparecen al
leer Vuetify por primera vez. La primera es estructural: **sin `<v-app>` en la
raíz, muchos componentes se pintan pero no funcionan** —los diálogos no abren,
los overlays no se posicionan— y no hay error que lo diga. La segunda es de
documentación: buscar "vuetify data table" en Google devuelve **Vuetify 3**, y
las props cambiaron de nombre; media hora peleando con un ejemplo que nunca fue
para tu versión. Las dos son el paso 1 y el paso 2 de la pieza de ruta.""",
"""Quita `<v-app>` de la raíz de la aplicación y recarga.

Mira lo que sigue funcionando —la mayoría de la pantalla, y ése es el problema—
y después abre un diálogo. Ni error, ni aviso, ni pista. Deshaz con
`git checkout -- src/App.vue` y anota el síntoma: lo vas a reconocer en un
proyecto ajeno dentro de dos años.""",
"## ⚠️ 6. Errores comunes","## ⚠️ 6. Errores comunes y pieza forense","### Errores comunes")

coser2("vu2-migrar-crud-vuetify.md", V,
"""El fallo propio de esta fase es el paso 3 de la pieza: **el valor que guarda el
componente no es el que ves.** Un `v-select` con `items` de objeto guarda el
objeto entero salvo que le digas lo contrario con `item-value`, así que la
prioridad de un ticket deja de ser `"high"` y pasa a ser `{ text: "Alta", value:
"high" }`. La migración no da error: guarda, y el `db.json` queda con un
documento de otra forma. El síntoma aparece **más tarde y en otra pantalla** —el
badge del dashboard en blanco para ese ticket—, que es lo que convierte un
cambio trivial en un caso de una hora.""",
"""Guarda un ticket con el `v-select` migrado y ve a mirar el dato crudo, que es
donde vive la verdad:

```bash
grep -n '"priority"' db.json | head
```

Compara con un ticket de la semilla. Si uno tiene un string y el otro un objeto,
ya sabes qué pantalla va a romperse después. Restaura con `npm run mock:reset`.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("vu3-migrar-dashboard-vdatatable.md", V,
"""Aquí llega el conflicto central de las tres rutas, y por eso la Fase 10 del
tronco no era opcional: **`v-data-table` quiere ser dueña del estado que tu store
ya controla.** El síntoma típico es que la tabla no ordena al hacer clic en la
cabecera y no pasa nada — ni error, ni movimiento. La causa suele ser que la
tabla está en modo servidor (`server-items-length`) esperando que **tú** ordenes,
mientras tu store espera que ordene ella. Es el paso 4 de la pieza, y la pregunta
que lo resuelve no es *"¿por qué no ordena?"* sino **"¿quién manda?"**.""",
"""Pon a los dos a mandar a la vez —conserva el orden en el store y deja también
que la tabla ordene— y haz clic en una cabecera.

Compara tres cosas: el orden que muestra la tabla, el que tiene el store en Vue
DevTools → Vuex, y el que pidió Network. Con tres verdades, cualquier arreglo
local solo mueve el síntoma de sitio.""",
"## ⚠️ 6. Errores comunes","## ⚠️ 6. Errores comunes y pieza forense","### Errores comunes")

coser2("vu4-timeline-vuetify.md", V,
"""La fase de cierre junta los dos hilos de la ruta: el **tema como estado global**
—en Vuetify los colores no son CSS, viven en `plugins/vuetify.js`, y un hex
escrito a mano en un `style` es exactamente lo que rompe el modo oscuro— y la
forma del dato que llega a la línea de tiempo. Con la vista terminada delante,
vale la pena releer el 🩺 índice de síntomas de la pieza de ruta: a estas alturas
ya reconoces las cuatro maneras en que Vuetify falla sin decir nada, y ése es el
entregable real de la ruta.""",
"""Escribe un color a mano donde debería ir un color del tema:

```html
<v-timeline-item color="#1976D2">   <!-- en vez de color="primary" -->
```

Cambia el tema a oscuro. El resto de la interfaz responde y ese punto no. Nadie
avisa, y el bug aparecerá el día que alguien cambie la paleta.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")
