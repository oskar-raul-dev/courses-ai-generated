# 🎨 Apéndice 1 — Bootstrap 4 (repaso de consulta)

## 🎯 Para qué sirve este apéndice

No es un curso de Bootstrap: es el **diccionario de todo el Bootstrap que el
Mini Jira usa**, para que puedas leer y extender la maquetación del proyecto
(o de cualquier legacy 2018–2021, donde Bootstrap 4 es omnipresente) sin
estudiar la documentación completa. Consúltalo cuando una clase del código no
te diga nada, o cuando quieras maquetar algo nuevo "al estilo del curso".

**Cómo entra al proyecto** 📍 *Fase 0*: solo el CSS —
`import "bootstrap/dist/css/bootstrap.min.css"` en `main.js`. El JavaScript
de Bootstrap (con jQuery y popper.js) NO se importa hasta necesitar
componentes interactivos (última sección de este apéndice).

> 🧭 **Todo este apéndice es opcional.** Es material de consulta y gimnasio:
> nada de aquí bloquea el avance de las fases. Léelo cuando lo necesites y
> toma de los ejercicios solo los que te sirvan — están para entrenar, no
> para completar.

---

## 🧱 El grid: container → row → col

El sistema de 12 columnas, la pieza que organiza cada pantalla del curso:

```html
<div class="container-fluid">   <!-- ancho completo; container = ancho fijo centrado -->
  <div class="row">             <!-- fila: SIEMPRE hija de container, madre de cols -->
    <div class="col-md-3">...</div>
    <div class="col-md-9">...</div>  <!-- 3 + 9 = 12 ✅ -->
  </div>
</div>
```

Los **breakpoints** definen desde qué ancho aplica cada clase (debajo, las
columnas se apilan a ancho completo):

| Prefijo | Aplica desde | Dispositivo típico |
|---|---|---|
| `col-` | siempre | — |
| `col-sm-` | ≥576px | móvil grande |
| `col-md-` | ≥768px | tablet |
| `col-lg-` | ≥992px | laptop |
| `col-xl-` | ≥1200px | desktop |

Se combinan para diseño responsive: `col-6 col-md-3` = media pantalla en
móvil, un cuarto en tablet+.

📍 **En el curso:** el layout maestro (`App.vue`, Fase 1) es
`col-md-3 col-lg-2` (sidebar) + `col-md-9 col-lg-10` (contenido); las
tarjetas de métricas (Fase 7) usan `col-6 col-md-3` — 2 por fila en móvil,
4 en escritorio; el panel de soporte (Fase 9) divide `col-md-4` cola /
`col-md-8` workspace.

---

## 🔧 Utilidades: las clases que hacen el 80% del trabajo

### Spacing — la fórmula `{propiedad}{lado}-{tamaño}`

```
m = margin, p = padding
t/b/l/r = top/bottom/left/right · x = izq+der · y = arriba+abajo · (nada) = todos
0–5 = de nada a mucho (escala de 0.25rem en 0.25rem, el 3 = 1rem)
```

Ejemplos del curso: `mt-5` (margen arriba grande, el login F2), `mb-3`
(separación estándar entre bloques), `px-3` (padding horizontal del header),
`py-2` (filas compactas de la cola F9), `mr-2` (entre botones), `p-0`
(anular el padding, la columna del sidebar).

### Flexbox — alinear sin CSS propio

| Clase | Qué hace | 📍 En el curso |
|---|---|---|
| `d-flex` | activa flex en el contenedor | por todas partes |
| `justify-content-between` | extremos opuestos | header: marca ↔ usuario (F2) |
| `justify-content-center` | centrar horizontal | login (F2) |
| `align-items-center` | centrar vertical | filas de la cola (F9) |
| `flex-column` | apilar vertical | `#app` y el nav del sidebar (F1) |
| `flex-grow-1` | "cómete el espacio sobrante" | el contenido bajo el header (F1) |
| `flex-fill` | repartir equitativo | círculos del wizard (F6) |

El combo `d-flex flex-column min-vh-100` + `flex-grow-1` del `App.vue` es la
receta clásica de "layout a pantalla completa con footer/contenido elástico".

### Texto y color

`text-muted` (gris secundario — subtítulos, metadatos), `text-center`,
`small` / `.small` (letra chica), `font-weight-bold`, `text-truncate`
(corta con "…", filas de la cola F9), `text-white`, `text-right`.

Los **colores contextuales** son un vocabulario que se repite en badges,
botones, alertas, texto y fondos — apréndelo una vez:

| Nombre | Color | Semántica en el Mini Jira |
|---|---|---|
| `primary` | azul | acción principal, seleccionado |
| `secondary` | gris | neutro, cerrado |
| `success` | verde | resuelto, éxito |
| `danger` | rojo | abierto/urgente, error, eliminar |
| `warning` | ámbar | en progreso, advertencia |
| `info` | celeste | informativo |
| `light`/`dark` | claro/oscuro | fondos, fallbacks |

📍 Este vocabulario es exactamente el que `STATUS_COLORS` (Fase 7) fija en
hexadecimales para chart.js — misma semántica, dos mundos.

---

## 📦 Componentes CSS que usa el curso

### Card — el contenedor universal

```html
<div class="card shadow-sm">          <!-- shadow-sm: sombra sutil -->
  <div class="card-body">...</div>
  <div class="card-footer">...</div>  <!-- los botones del wizard (F6) -->
</div>
```

📍 Login (F0/F2), tarjetas resumen (F4) y métricas (F7), el workspace (F9),
el shell del wizard (F6). `h-100` en cards dentro de un `row` las iguala en
altura.

### Table

```html
<table class="table table-hover table-sm">
  <thead class="thead-light">...</thead>
```

`table-hover` (resalta al pasar — señal de "clicable", F4), `table-striped`
(cebra), `table-sm` (compacta), `thead-light` (encabezado gris),
`table-danger` en un `<tr>` (fila resaltada — prioridad alta, F4 ej. 14).

### Badge

```html
<span class="badge badge-danger">Abierto</span>
<span class="badge badge-pill badge-warning">medium</span>  <!-- pill: redondeado -->
```

📍 La base de `TicketStatusBadge` y `TicketPriorityBadge` (F4) — el color se
resuelve con `:class` dinámico contra el mapa de configuración.

### Forms — el pegamento con vuelidate

```html
<div class="form-group">                          <!-- label + input + error -->
  <label for="x">Título</label>
  <input class="form-control is-invalid" />       <!-- is-invalid: borde rojo -->
  <div class="invalid-feedback">Mensaje.</div>    <!-- SOLO visible si el hermano
                                                       anterior tiene is-invalid -->
</div>
<div class="form-row"><div class="form-group col-md-6">…  <!-- campos lado a lado -->
```

⚠️ El detalle que rompe cabezas: `invalid-feedback` está **oculto por CSS**
salvo que el input hermano inmediato tenga `is-invalid`. Por eso en la Fase 5
el `:class="{ 'is-invalid': $v...$error }"` controla las DOS cosas a la vez:
borde rojo Y visibilidad del mensaje. Si tu mensaje "no aparece", revisa esa
clase y la posición del div.

### Botones, alertas y demás fauna

- **Botones:** `btn` + variante (`btn-primary`, `btn-outline-danger` — solo
  borde), tamaño (`btn-sm`), `btn-block` (ancho completo, login F2),
  `btn-link` (parece link — el Cancelar de F5). El atributo `disabled` ya
  trae estilo apagado.
- **Alertas:** `alert alert-danger/success/warning/info` — el trío
  error/éxito/aviso de todo el curso.
- **Spinner:** `spinner-border text-primary` (+ `spinner-border-sm`) — el
  loading oficial desde la Fase 3.
- **List group:** `list-group` + `list-group-item-action` (clicable) +
  `active` (seleccionado) + `list-group-item-warning` (resaltado) — la cola
  del panel (F9).
- **Nav / navbar:** `navbar navbar-dark bg-dark` (header F1),
  `nav flex-column` + `nav-item`/`nav-link` (sidebar F1).
- **Posicionamiento:** `position-fixed`, `border`, `border-right`,
  `border-danger`, `rounded-circle` (avatar/círculos del wizard), `shadow`.

---

## 🤝 El lío de jQuery y popper.js (léelo antes de usar un modal)

Bootstrap 4 tiene dos mitades: el **CSS** (todo lo anterior — cero JS) y los
**componentes interactivos**, que requieren jQuery y algunos también popper:

| Componente | Necesita | Componente | Necesita |
|---|---|---|---|
| Modal | jQuery | Tooltip / Popover | jQuery + popper |
| Dropdown | jQuery + popper | Collapse / Accordion | jQuery |
| Carousel, Toast, Tabs (JS) | jQuery | Alert *dismissible* | jQuery |

Para activarlos: `import "jquery"` (y popper) e
`import "bootstrap/dist/js/bootstrap.min.js"` en `main.js` — instalados desde
la Fase 0, dormidos hasta la Fase 5 (ejercicio 18, el modal de confirmación).

**Por qué chocan con Vue:** los plugins de Bootstrap manipulan el DOM por su
cuenta (`$('#modal').modal('show')` mueve nodos, agrega clases, escucha
teclas) — y Vue cree que el DOM es suyo. Dos dueños, un DOM: la receta de los
bugs de "el modal quedó abierto tras navegar". La disciplina es la de la
Fase 7: **tratar el plugin como librería imperativa** — invocarlo desde
methods, envolverlo en un componente frontera (`ConfirmModal.vue`), y limpiar
en `beforeDestroy` (`$('#modal').modal('dispose')`). En legacy verás la
versión indisciplinada por todas partes; ahora sabes leerla y encapsularla.

*Alternativa de época que verás en otros proyectos:* **bootstrap-vue** —
reimplementa los componentes como componentes Vue nativos, sin jQuery. Este
curso no lo usa (más fiel al legacy crudo), pero reconócelo: `<b-modal>`,
`<b-table>` en un template = bootstrap-vue.

---

## ⚠️ Diagnóstico rápido

| Síntoma | Causa probable |
|---|---|
| Nada tiene estilo | falta el `import` del CSS en `main.js` |
| `invalid-feedback` no aparece | el input hermano no tiene `is-invalid`, o el div no es hermano inmediato |
| El modal/dropdown no reacciona | falta importar el JS de Bootstrap, o jQuery/popper no instalados |
| Columnas que no alinean / márgenes raros | `col-*` sin `row` padre, o `row` sin `container` |
| Todo apilado en desktop | usaste `col-` a secas esperando comportamiento `md` |
| El modal sobrevive a la navegación | plugin jQuery sin `dispose` en `beforeDestroy` |
| `!important` para pisar un estilo | casi siempre hay una utilidad que ya lo hace: busca antes de pisar |

---

## 🧪 Ejercicios (40) — todos opcionales

**🟢 Fácil (1–10)**

1. Cambia el header a `bg-primary` y evalúa el contraste del texto.
2. Haz las tarjetas de métricas 3-por-fila en `lg` (`col-lg-4`).
3. Agrega `table-striped` a la tabla del dashboard y decide si convive bien
   con `table-hover`.
4. Reemplaza un margen hecho con CSS propio (si tienes alguno) por
   utilidades de spacing.
5. Convierte los badges de prioridad a `badge-pill` en TODA la app y evalúa
   la coherencia (¿estado también, o solo prioridad?).
6. Redimensiona la ventana con DevTools abierto e identifica en qué píxel
   exacto se apila el layout maestro. Relaciónalo con la tabla de breakpoints.
7. Agrega un `sr-only` con texto descriptivo al spinner de carga
   ("Cargando tickets") — accesibilidad en una línea.
8. Agrupa los botones de transición del panel (F9) con `btn-group` y compara
   contra los botones sueltos con `mr-2`.
9. Crea una alerta "dismissible" solo-CSS: la `×` la controla Vue con un
   `v-if`, sin el plugin de Bootstrap.
10. Usa `text-truncate` en los títulos de la tabla del dashboard y descubre
    su requisito escondido (necesita un ancho acotado — investiga).

**🟡 Intermedio (11–20)**

11. Construye la fila "logo | buscador centrado | usuario" solo con
    utilidades flex, sin CSS.
12. Haz el sidebar colapsable en móvil con `d-none d-md-block` + un botón
    hamburguesa que lo alterne con una clase (sin el plugin Collapse).
13. Recrea el toast de la Fase 8 usando las clases `toast` de Bootstrap
    (solo CSS, controlando visibilidad con Vue).
14. Envuelve el buscador del dashboard en un `input-group` con icono 🔍 de
    prepend y botón de limpiar como append.
15. Haz la cola del panel (F9) `position-sticky` bajo el header al hacer
    scroll. Documenta el requisito de altura/overflow que descubras.
16. Convierte el indicador del wizard (F6) en una `progress` bar de
    Bootstrap con porcentaje — y compara contra tu solución del ejercicio 9
    de esa fase.
17. Aplica `table-responsive` a la tabla del dashboard y evalúa en móvil el
    trade-off scroll-horizontal vs apilar columnas.
18. Reemplaza los checkboxes nativos de tus ejercicios previos por
    `custom-control custom-checkbox` y nota qué exige el markup.
19. Estiliza la paginación del ejercicio 24 de la Fase 4 con el componente
    `pagination` (clases `page-item`/`page-link`/`active`/`disabled`).
20. Iguala alturas de las cards de métricas con `h-100` y provoca el caso
    donde NO funciona (falta el `row` con align) para entender por qué.

**🟠 Difícil (21–29)**

21. Implementa el `ConfirmModal.vue` del ejercicio 18 de la Fase 5 si no lo
    hiciste — con `dispose` en `beforeDestroy`.
22. Tema oscuro de juguete: sobrescribe las variables de color con una hoja
    CSS propia cargada después de Bootstrap (sin recompilar SASS) y
    documenta los límites del enfoque.
23. Menú de usuario en el header como `dropdown` real (plugin jQuery),
    envuelto en un componente frontera con su limpieza — la disciplina de la
    Fase 7 aplicada a Bootstrap JS.
24. Tooltips en los badges de estado (título completo del estado) vía plugin
    jQuery: inicialización en `mounted`, `dispose` en `beforeDestroy`, y el
    caso trampa: badges dentro de un `v-for` que cambia (¿cuándo
    re-inicializas?).
25. Versión plugin del sidebar móvil: reemplaza tu solución del ejercicio 12
    por el Collapse real de Bootstrap y compara ambos enfoques en 5 líneas.
26. Navbar responsive completa: `navbar-expand-md` + `navbar-toggler` +
    colapso del menú, conviviendo con Vue Router (los `router-link` dentro).
27. Hoja de estilos de impresión: con `d-print-none`/`d-print-block`, haz
    que imprimir el detalle de un ticket oculte sidebar, header y botones.
28. Toast del plugin real (`$('.toast').toast('show')`) contra tu versión
    CSS del ejercicio 13: tabla de 3 pros y 3 contras de cada uno.
29. Formulario del CRUD (F5) en modo horizontal (`form-group row` +
    `col-form-label`) y evalúa cuándo ese layout gana al vertical.

**🔴 Muy difícil (30–40)**

30. Audita el proyecto: lista todo CSS propio que escribiste y clasifica
    cada regla en "utilidad de Bootstrap la cubría" / "genuinamente custom".
    Refactoriza las del primer grupo.
31. Compila Bootstrap desde SASS: instala la versión de `sass-loader`/`sass`
    compatible con la época, importa `bootstrap.scss` y sobrescribe
    `$primary`, `$danger` y `$border-radius` ANTES del import. El bundle
    ahora trae TU Bootstrap. Documenta el pantano de versiones que cruzaste.
32. Theme switcher real: genera dos builds CSS (claro/oscuro, sobre el
    ejercicio 31), intercámbialos en runtime cambiando el `<link>`, y
    persiste la elección. Maneja el flash-of-wrong-theme al cargar.
33. Capa de design tokens: define CSS custom properties
    (`--mj-color-open`, etc.) consumidas tanto por tus estilos como
    inyectadas a `STATUS_COLORS` (F7) leyendo `getComputedStyle` — un solo
    origen para colores en CSS y en chart.js. Evalúa si el truco vale su
    complejidad.
34. Reimplementa el modal SIN jQuery: componente Vue puro con backdrop,
    cierre por ESC y clic afuera, focus trap (Tab no escapa), y bloqueo del
    scroll del body. Compáralo con el plugin: ¿qué te regalaba jQuery que no
    viste hasta reimplementarlo?
35. Auditoría de accesibilidad con teclado: navega el flujo completo
    (login → dashboard → detalle → editar) SOLO con Tab/Enter/Esc. Lista
    cada punto donde te atoras y arréglalos (orden de foco, `:focus`
    visible, aria-labels en botones-icono).
36. Purga el CSS muerto: integra PurgeCSS al build, mide los KB de Bootstrap
    antes/después, y encuentra la trampa — las clases construidas
    dinámicamente por Vue (`:class` con strings del mapa) que la purga se
    lleva por delante. Configura la safelist y documenta el riesgo.
37. Grid casero: implementa un sistema de 12 columnas con flexbox en ~40
    líneas de CSS (container/row/col-1..12 + un breakpoint) y reconstruye el
    layout maestro con él. Entender el de Bootstrap por reconstrucción.
38. Migra UNA vista (la de métricas) a bootstrap-vue: instala la versión de
    época, reescribe cards y tabla con `<b-card>`/`<b-table>`, y escribe la
    comparación honesta: qué ganó (props, slots, sin jQuery) y qué costó
    (bundle, otra capa, lock-in).
39. Agrega un breakpoint `xxl` (≥1400px) al proyecto: media queries propias
    que extiendan el grid (`col-xxl-*` para las clases que usas) y aplícalo
    al panel de soporte en monitores grandes. Documenta por qué esto en
    Bootstrap 4 exige recompilar o duplicar (y cómo lo resolvió el 5).
40. RTL de exploración: fuerza `dir="rtl"` en el `<html>` y recorre la app.
    Cataloga qué sobrevive (flex, text-align lógico) y qué se rompe
    (spacing direccional `ml-/mr-`, el sidebar). Esboza qué costaría un
    soporte RTL real en Bootstrap 4.

---

## 📚 Referencias

- Bootstrap 4.6 — Introducción: https://getbootstrap.com/docs/4.6/getting-started/introduction/
- Grid: https://getbootstrap.com/docs/4.6/layout/grid/
- Utilities (spacing, flex, colors, display): https://getbootstrap.com/docs/4.6/utilities/spacing/
- Forms: https://getbootstrap.com/docs/4.6/components/forms/
- Components (cards, badges, modal…): https://getbootstrap.com/docs/4.6/components/card/
- bootstrap-vue (para reconocerlo en otros legacy): https://bootstrap-vue.org/
