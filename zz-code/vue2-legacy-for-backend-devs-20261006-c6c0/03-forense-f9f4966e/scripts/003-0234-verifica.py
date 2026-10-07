# rescatado de la sesión f9f4966e, 2026-09-10T02:34:03Z · Stitch phases 04-07
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser
RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("04-dashboard-tickets.md","forense-fase-04.md",
"""⭐ Una de las tres piezas estrella del curso, y la que más veces vas a
reencontrar en un legacy ajeno: **el control cambia, el estado cambia, y lo que
se pinta se quedó en la versión anterior.** El bug no es de Vue, es de
arquitectura de estado — alguien guardó un dato **derivado** como si fuera un
dato crudo, y desde entonces hay dos verdades que alguien tiene que sincronizar
a mano. La mano se olvida. Se depura con Vue DevTools → Components, y la
pregunta que parte el caso en dos es la del paso 2: **¿esto es un `computed` o
es un `data`?** Si es un `data`, ya sabes por qué se quedó atrás; si es un
`computed`, el problema está en lo que lee, no en él. Network aparece solo para
descartarla, y `git log -S` para averiguar cuándo dejó de ser derivado.""",
"""Convierte una lista derivada en una copia guardada y siente el bug en carne
propia. En `TicketsView.vue`, cambia el `computed` que filtra por un `data` que
se asigna una sola vez en `created()`:

```js
// antes: computed: { filteredTickets: function () { … } }
// ahora: data: function () { return { filteredTickets: [] }; }
//        created: function () { this.filteredTickets = this.filter(this.tickets); }
```

Cambia el filtro en la interfaz. La tabla se queda igual, y ahora sabes por qué.
Para volver: `git checkout -- src/views/TicketsView.vue`.""",
RES + '| 04 | "Pongo el filtro y la tabla se queda con lo de antes" | Estado | 🟡 |')

coser("05-crud-tickets.md","forense-fase-05.md",
"""El fallo típico de esta fase es **el silencio**: el clic en guardar no produce
ni request, ni error, ni mensaje. Y el silencio tiene causa concreta — el
formulario ya decidió que no envía, y esa decisión no se pinta en ninguna parte.
Vuelidate sabe perfectamente qué campo está mal; el usuario no, porque el bloque
que muestra los errores depende de una condición que nadie cumplió. El orden es
el de siempre, del más barato al más caro: ¿salió algún request? (Network),
¿llegó a ejecutarse el handler? (un `console.log` o un breakpoint), y solo
entonces ¿qué campo está mal y por qué no se pinta? La fase deja además dos
casos hermanos que conviene reconocer: el formulario que nace en rojo antes de
que el usuario escriba nada, y el ticket que se creó **dos veces** porque el
botón no se deshabilita mientras el request viaja.""",
"""Rompe el vínculo entre la validación y su mensaje: quita del `<template>` la
condición que muestra el error de un campo requerido —o cambia `$v.form.title.$error`
por `false`— y deja la validación intacta. Intenta guardar con el título vacío.

No pasa nada, y ese "nada" es exactamente lo que reporta el usuario. Mira en Vue
DevTools que `$v.form.$invalid` sí es `true`: el sistema lo sabía todo el tiempo.
Para volver: `git checkout -- src/views/TicketFormView.vue`.""",
RES + '| 05 | "Le puse la etiqueta y la tabla no se enteró" | Reactividad | 🟡 |')

coser("06-wizard-minimo.md","forense-fase-06.md",
"""Acá el sistema no pierde datos: **destruye componentes**, que es otra cosa y se
diagnostica distinto. Vuelves a un paso anterior del asistente y lo encuentras
vacío, aunque nadie borró nada. La investigación consiste en separar tres
estados que el usuario ve como uno solo —lo que está en el borrador, lo que está
en el formulario del paso, y lo que está en el estado de validación— y averiguar
cuál de los tres murió. Se depura con Vue DevTools → Components mirando el
**árbol** y los hooks del ciclo de vida: si el componente del paso vuelve a
aparecer con otra instancia, no volvió, **nació otra vez**. Lo que sobrevive es
lo que vive por encima de él; lo que se pierde es lo que vivía adentro.""",
"""Pon un `console.log` en `created()` y otro en `beforeDestroy()` del componente
de un paso, y navega adelante y atrás dos veces:

```js
created: function () { console.log("nace", this._uid); },
beforeDestroy: function () { console.log("muere", this._uid); }
```

Cuenta los `_uid` distintos. Si el mismo paso tiene tres identidades en dos
minutos, ya no estás depurando un bug de datos. Borra los `console.log` antes de
commitear.""",
RES + '| 06 | "Volví atrás en el asistente y perdí la descripción" | Formularios y wizard | 🟡 |')

coser("07-metricas-minimas.md","forense-fase-07.md",
"""La primera investigación del curso que **no tiene un momento de fallo**: no hay
un clic que rompa nada, ni una petición en rojo, ni excepción — hay una
aplicación que a los diez minutos va peor que a los dos. Los bugs de degradación
se diagnostican al revés que los demás: no se busca qué se rompió, se busca
**qué se acumula**. Las herramientas dejan de ser la consola y pasan a ser
**Performance y Memory** de Chrome, y la primera pregunta es si el síntoma es
acumulativo de verdad (navegar diez veces a la misma vista y comparar) antes de
sospechar de nadie. El sospechoso habitual de esta fase es un gráfico que se
crea en cada montaje y no se destruye al salir, más los `setInterval` y los
listeners que nadie dio de baja.""",
"""Comenta el `beforeDestroy()` donde el gráfico se destruye, navega diez veces
entre el dashboard y las métricas, y mira el heap en DevTools → Memory:

```js
// beforeDestroy: function () { this.chart.destroy(); }
```

Toma un snapshot al empezar y otro al terminar. La diferencia es el número que
convierte "va lento" en un reporte que alguien puede priorizar. Para volver:
`git checkout -- src/components/metrics/` y recarga con `Ctrl+Shift+R` — los
gráficos zombi viven en la memoria del navegador, no en tu código.""",
RES + '| 07 | "A la media hora la laptop suena como un avión" | Reactividad | 🟠 |')
