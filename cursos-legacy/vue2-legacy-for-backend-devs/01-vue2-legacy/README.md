# 📘 Curso 01 · Vue 2 Legacy — Mini Jira

Curso práctico de **Vue 2 legacy (época 2018–2021)** para desarrolladores
backend que necesitan entrar rápido a una base de código heredada.

Proyecto hilo conductor: **Mini Jira**, una mesa de soporte interna.

El curso tiene **dos niveles**:

- 🌳 **Tronco (F0–F11)** — obligatorio, secuencial. Vue 2 **a pelo**.
- 🔀 **Rutas (Q / VU / NX)** — opcionales y **excluyentes entre sí**. Qué pasa
  cuando encima del Vue hay **Quasar, Vuetify o Nuxt**.

> El tronco enseña **Vue**. Las rutas enseñan **el framework**.
> No se puede lo segundo sin lo primero: si empiezas por Quasar, nunca sabrás
> qué es Vue y qué es Quasar.

Este curso es la primera mitad del paquete Mini Jira. La segunda —el backend
real que reemplaza al mock— vive en
[`../02-complement-mongodb-backend/`](../02-complement-mongodb-backend/README.md).

---

## 🧭 Documentos maestros

| Archivo | Qué es |
|---|---|
| **Este `README.md`** | 📑 **Índice del curso** — empieza aquí |
| [`0-plan-del-curso.md`](0-plan-del-curso.md) | 🗺️ Plan, alcance, stack unificado fijado, convenciones y autodiagnóstico inicial |
| [`0-ESTRUCTURA-CURSO.md`](0-ESTRUCTURA-CURSO.md) | 🏛️ **Arquitectura**: qué es obligatorio, qué opcional, grafo de dependencias, reglas de exclusión, notas de producción |
| [`../prompts/convencion-de-git-y-tags.md`](../prompts/convencion-de-git-y-tags.md) | 🏷️ **Cómo llevas el progreso en git**: repo propio, un tag por fase, tags de ejercicio, y cómo volver a un estado sano cuando el ejercicio 22 te deje el proyecto irreconocible |
| [`../prompts/guia-de-estilo-y-convenciones.md`](../prompts/guia-de-estilo-y-convenciones.md) | ✍️ Guía editorial compartida con el Curso 02 |
| [`forense-master.md`](forense-master.md) | 🕵️ **La puerta del track forense**: el método de cuatro preguntas y el 🩺 índice de síntomas. Se entra por lo que ves, no por la fase |
| [`cuaderno-incidentes.md`](cuaderno-incidentes.md) | 📓 **12 incidentes** con el ticket como llegó, pistas plegadas y solución de referencia |

Si algo del `0-ESTRUCTURA-CURSO.md` contradice a este índice o al plan, hay
que reconciliarlo — no ignorarlo.

---

## 🌳 Tronco — fases obligatorias, en orden

| Archivo | Fase | Qué entra |
|---|---|---|
| [`00-setup-hola-mundo.md`](00-setup-hola-mundo.md) | 🛠️ **F0** | Node con NVM, disección de `package.json`, editores, lineamientos de código, mock Stubby y Hello World explicado idea por idea |
| [`01-estructura-base-legacy.md`](01-estructura-base-legacy.md) | 🏗️ **F1** | Estructura de carpetas, layout, router, vistas placeholder |
| [`02-autenticacion-minima.md`](02-autenticacion-minima.md) | 🔐 **F2** | Login mock, `localStorage`, guard de router, interceptor de axios, logout |
| [`03-mock-api-minima.md`](03-mock-api-minima.md) | 🧪 **F3** | json-server, `db.json`, `ticketService` real, login asíncrono. 🪦 Stubby se jubila |
| [`04-dashboard-tickets.md`](04-dashboard-tickets.md) | 📋 **F4** | Tabla Bootstrap, badges de estado, filtros con `computed`, loading y error |
| [`05-crud-tickets.md`](05-crud-tickets.md) | 📝 **F5** | Crear, editar y eliminar tickets con vuelidate en serio |
| [`06-wizard-minimo.md`](06-wizard-minimo.md) | 🪜 **F6** | Wizard de 3 pasos, `keep-alive`, `$refs`, estado local contra store |
| [`07-metricas-minimas.md`](07-metricas-minimas.md) | 📊 **F7** | chart.js 2.x y la fricción de las librerías imperativas |
| [`08-websockets-minimos.md`](08-websockets-minimos.md) | 💬 **F8** | socket.io 2.x, mini servidor Node, notificación en vivo |
| [`09-panel-soporte.md`](09-panel-soporte.md) | 🎧 **F9** | Panel de agente: cola, asignación, comentarios. Fase de síntesis |
| [`10-vuex-a-fondo.md`](10-vuex-a-fondo.md) | 🗂️ **F10** | Refactor consciente del estado global · **cimiento de las rutas** |
| [`11-testing-minimo.md`](11-testing-minimo.md) | ✅ **F11** | Jest + vue-test-utils · **prerequisito duro de X0** |

Al terminar F11 tienes el Mini Jira completo, "a pelo" y testeado, hablándole
a json-server. Ese es el punto de bifurcación.

---

## 📎 Apéndices — consulta, no lectura

Opcionales y no secuenciales. Se leen cuando el tema aparece o algo suena
flojo. Todos sus ejercicios son opcionales.

| Archivo | Qué es |
|---|---|
| [`a1-bootstrap.md`](a1-bootstrap.md) | 🎨 Bootstrap 4 — grid, utilidades, componentes, el lío de jQuery. *No se jubila: **convive** con Quasar y Vuetify* |
| [`a2-node.md`](a2-node.md) | 🟢 Node — lo mínimo para sobrevivir al tooling. *En Nuxt deja de ser "solo tooling": corre en producción* |
| [`a3-npm.md`](a3-npm.md) | 📦 npm — dependencies contra devDependencies, lockfile, scripts |
| [`a4-axios.md`](a4-axios.md) | 🌐 axios — instancia, interceptores, errores, multipart. *El interceptor cambia de casa en las rutas* |
| [`a5-webpack-babel.md`](a5-webpack-babel.md) | ⚙️ Webpack y Babel — qué hace Vue CLI por debajo. *`vue.config.js` no existe en Quasar ni en Nuxt* |

---

## 🔀 Rutas — opcionales, elige **una**, después de F11

### 🅠 Ruta Q — Quasar 1.22

Se come el proyecto: no hay `main.js`, hay `quasar.conf.js` y boot files.

| Archivo | Fase | Qué hace |
|---|---|---|
| [`q0-red-de-seguridad.md`](q0-red-de-seguridad.md) | 🛡️ **Q0** | Tests de regresión sobre el código que vas a borrar |
| [`q1-leer-quasar.md`](q1-leer-quasar.md) | 🔷 **Q1** | Leer Quasar sin migrar nada. Reconocimiento puro |
| [`q2-migrar-crud-qform.md`](q2-migrar-crud-qform.md) | 📝 **Q2** | Migrar el CRUD (F5) a `QForm`. 🪦 vuelidate sale del proyecto |
| [`q3-migrar-dashboard-qtable.md`](q3-migrar-dashboard-qtable.md) | 📋 **Q3** | Migrar el dashboard (F4) a `QTable`. **El conflicto con Vuex** |
| [`q4-timeline-actividad.md`](q4-timeline-actividad.md) | 🕒 **Q4** | Crear el timeline de actividad con `QTimeline`. Framework puro |

### 🅥 Ruta VU — Vuetify 2.6

No se come el proyecto (tu `main.js` sobrevive), pero el **theming vive en
JS** y el bundle se te va a 500 kb.

| Archivo | Fase | Qué hace |
|---|---|---|
| [`vu0-red-de-seguridad.md`](vu0-red-de-seguridad.md) | 🛡️ **VU0** | Red de seguridad. Y la pregunta abierta: `<v-app>` puede romper tu `mount()` |
| [`vu1-leer-vuetify.md`](vu1-leer-vuetify.md) | 🅥 **VU1** | Leer Vuetify: `<v-app>`, theming en JS, la trampa de `v-flex` |
| [`vu2-migrar-crud-vuetify.md`](vu2-migrar-crud-vuetify.md) | 📝 **VU2** | Migrar el CRUD a `v-form` y `:rules`. 🪦 vuelidate sale |
| [`vu3-migrar-dashboard-vdatatable.md`](vu3-migrar-dashboard-vdatatable.md) | 📋 **VU3** | Migrar el dashboard a `v-data-table`. **El conflicto con Vuex** + convivencia con Bootstrap |
| [`vu4-timeline-vuetify.md`](vu4-timeline-vuetify.md) | 🕒 **VU4** | Crear el timeline con `v-timeline` |

### 🅝 Ruta NX — Nuxt 2.15

⚠️ **Otro molde.** Nuxt no es un framework de UI: es SSR. Tu componente corre
en un Node **sin `window`** y luego otra vez en el navegador, y tienen que
coincidir o el DOM se rompe.

| Archivo | Fase | Qué hace |
|---|---|---|
| [`nx0-red-de-seguridad.md`](nx0-red-de-seguridad.md) | 🛡️ **NX0** | Red de seguridad — y el descubrimiento de que **tus tests no detectan esto** |
| [`nx1-leer-nuxt.md`](nx1-leer-nuxt.md) | 📖 **NX1** | Leer Nuxt: `pages/`, `plugins/`, los dos ciclos de vida |
| [`nx2-hidratacion-window-not-defined.md`](nx2-hidratacion-window-not-defined.md) | 💥 **NX2** | Hidratación y `window is not defined`. La auth de F2 se rompe |
| [`nx3-asyncdata-vs-vuex.md`](nx3-asyncdata-vs-vuex.md) | 🔄 **NX3** | `asyncData` contra Vuex: ¿quién carga los datos? |
| [`nx4-pagina-ssr-nueva.md`](nx4-pagina-ssr-nueva.md) | 🆕 **NX4** | Crear una página SSR nueva (el timeline de actividad) |

---

## 🕵️ Track forense

Quince recorridos de investigación —doce de tronco y uno por ruta—, con el
ticket literal, la salida de cada paso y qué descarta. **No se leen de corrido:
se entra por el síntoma.**

La puerta es [`forense-master.md`](forense-master.md), que trae el método de
cuatro preguntas y —lo que de verdad se consulta— **el índice de síntomas
transversal**: nadie llega sabiendo de qué fase es su problema, llega con *"la
pantalla se quedó igual"*.

| | Síntoma que cubre |
|---|---|
| [`forense-fase-00.md`](forense-fase-00.md) | "Instalé todo y no arranca", con errores que no hablan de lo que pasa |
| [`forense-fase-01.md`](forense-fase-01.md) | "Entré a un ticket que no existe y la pantalla no dice nada" |
| [`forense-fase-02.md`](forense-fase-02.md) | "Me saca al login sin decir nada" |
| [`forense-fase-03.md`](forense-fase-03.md) | "A veces carga y a veces se queda pensando" |
| [`forense-fase-04.md`](forense-fase-04.md) | "Cambié el filtro y la tabla se quedó igual" ⭐ |
| [`forense-fase-05.md`](forense-fase-05.md) | "Le di a guardar y no pasó nada" |
| [`forense-fase-06.md`](forense-fase-06.md) | "Volví atrás en el wizard y perdí lo que había escrito" |
| [`forense-fase-07.md`](forense-fase-07.md) | "La pestaña se va poniendo lenta y el ventilador se dispara" |
| [`forense-fase-08.md`](forense-fase-08.md) | "Tomé el ticket y a mi compañero le sigue apareciendo libre" ⭐ |
| [`forense-fase-09.md`](forense-fase-09.md) | "Cambié el estado y el detalle no se enteró" |
| [`forense-fase-10.md`](forense-fase-10.md) | "El estado cambió y nadie sabe quién lo cambió" ⭐ |
| [`forense-fase-11.md`](forense-fase-11.md) | "El test pasa solo cuando lo corro aislado" |
| [`forense-ruta-q.md`](forense-ruta-q.md) 🅠 | El componente que no renderiza y no avisa · la tabla que pagina dos veces |
| [`forense-ruta-vu.md`](forense-ruta-vu.md) 🅥 | El `v-app` ausente que rompe en silencio · el hex que mata el tema |
| [`forense-ruta-nx.md`](forense-ruta-nx.md) 🅝 | `window is not defined` · la hidratación que no cuadra |

Las tres piezas de ruta cubren las cinco fases de su ruta en un solo archivo, y
se leen solas: como las rutas son excluyentes, solo vas a abrir una.

Cada fase enlaza a la suya desde su sección **⚠️ Errores comunes y pieza
forense**, donde además hay un bloque 🧨 **Rompe a propósito** para provocar el
fallo en tu propia máquina. La especificación del formato vive en
[`../prompts/formato-piezas-forenses.md`](../prompts/formato-piezas-forenses.md).

---

## 📓 Cuaderno de incidentes

[`cuaderno-incidentes.md`](cuaderno-incidentes.md) — **12 incidentes** repartidos
por todo el curso, con su propia dificultad 🟢🟡🟠🔴. Cada uno trae el ticket
**como llegó** —vago, en palabras del usuario y sin lenguaje técnico—, la
preparación para tener el sistema roto en tu máquina, tres pistas plegadas, un
espacio en blanco para tu investigación, y la solución de referencia con causa
raíz, parche mínimo, refactorización correcta, **prueba de regresión en código**,
prevención y post-mortem.

Se puede empezar por cualquiera cuya fase ya hayas hecho: cada fase reserva sus
IDs en un bloque 📌 al final, y el índice del cuaderno los lista todos. Hay tres
formas de preparación y cada incidente usa **la más barata que sirva** —un flag
del inyector de caos, un `db.json` alterno o una rama de git—, porque una
preparación complicada es una excusa para saltarse el incidente.

Y una regla que es la mitad del ejercicio: **la solución viene incluida, y
abrirla antes de escribir la tuya no te ahorra tiempo — te ahorra el ejercicio.**

---

## 🗺️ El mapa de un vistazo

```
 F0 ─ F1 ─ F2 ─ F3 ─ F4 ─ F5 ─ F6 ─ F7 ─ F8 ─ F9 ─ F10 ─ F11
setup base auth mock dash crud wiz chart ws  panel vuex  test
                                                           │
                                     ✅ Mini Jira "a pelo" completo
                                                           │
                            ┌──────────────┼───────────────┐
                            ▼              ▼               ▼
                        ╔═══════╗      ╔════════╗      ╔═══════╗
                        ║ RUTA  ║      ║  RUTA  ║      ║ RUTA  ║
                        ║   Q   ║      ║   VU   ║      ║  NX   ║
                        ║Quasar ║      ║Vuetify ║      ║ Nuxt  ║
                        ║  1.x  ║      ║  2.x   ║      ║  2.x  ║
                        ╚═══════╝      ╚════════╝      ╚═══════╝
                        Q0 → Q4        VU0 → VU4       NX0 → NX4

                        ⚠️ elige UNA. No se acumulan.
```

---

## 🧭 Cómo usarlo

1. Lee este índice para el mapa completo y
   [`0-plan-del-curso.md`](0-plan-del-curso.md) para el alcance, el stack y las
   convenciones. Haz el autodiagnóstico inicial: si fallas varias preguntas,
   los apéndices existen para eso.
2. Sigue el tronco **en orden** (F0 → F11). **Sin saltos.** Cada fase está
   pensada para una sesión corta de estudio. **Cierra cada una con su tag**
   (`git tag -a fase-04-dashboard-tickets …`): es el hábito que después te deja
   correr `git tag -l 'fase-*'` y saber dónde estás sin releer nada.
3. Completa al menos los ejercicios 🟢 y 🟡 de cada fase antes de avanzar.
4. Los **apéndices son opcionales**: material de consulta cuando el tema
   aparezca o algo te suene flojo.
5. **Al terminar F11**, elige **una** ruta — idealmente la que use tu empresa.
   Si no usa ninguna, has terminado: el tronco ya te dejó donde tenías que
   estar.
6. Si además vas a mantener el backend, sigue con el
   [Curso 02](../02-complement-mongodb-backend/README.md), que apaga el mock y
   paga las deudas 💸 que este curso declaró.

> ⚠️ **F10 (Vuex) y F11 (Testing) no son opcionales si vas a hacer una ruta.**
> El conflicto central de Q3/VU3 y NX3 es *el framework quiere el estado que tu
> store ya controla* — sin F10 no lo ves venir. Y sin F11 no puedes escribir la
> red de seguridad de X0, y **sin red no se migra nada**.

---

## 🔀 Qué te enseña cada ruta (y por qué son distintas)

| | 🅠 **Quasar 1** | 🅥 **Vuetify 2** | 🅝 **Nuxt 2** |
|---|---|---|---|
| **Qué es** | UI + build system | UI (plugin de Vue CLI) | **Meta-framework SSR** |
| **¿Se come el proyecto?** | **Sí.** No hay `main.js` | No. Sigues con tu `main.js` | **Sí.** No hay `main.js` ni `App.vue` |
| **La fricción central** | Boot files, layouts, `quasar.conf.js` | **Theming en JS** + bundle a 500 kb | **`window is not defined`** |
| **La tensión con F10** | `:pagination.sync` contra tu Vuex | `:options.sync` contra tu Vuex | **`asyncData` contra Vuex** |
| **Qué te cambia** | Vocabulario | Vocabulario | **El modelo mental** |
| **Proyecto final** | Híbrido (Quasar + Bootstrap) | Híbrido (Vuetify + Bootstrap) | Reconstruido sobre otro modelo de ejecución |

**Si tu empresa no usa ninguna y quieres la que más te aporta:** NX. Q y VU
son "mismo Vue, otros componentes". Nuxt es *"tu componente corre en un Node
que no tiene `window`, y luego otra vez en el navegador, y tienen que coincidir
o el DOM se rompe"*.

Y una nota que no es un descuido: **el proyecto final de una ruta es un
híbrido**. Dashboard y CRUD en el framework, el resto todavía en Bootstrap.
Eso no es una carencia — **es el estado de cualquier legacy a medio migrar**, y
es donde el dev de mantenimiento va a vivir.

---

## 🧱 Stack de época (versiones fijadas)

Las versiones oficiales están en [`0-plan-del-curso.md`](0-plan-del-curso.md);
si un capítulo dice otra cosa, gana esa tabla. El resumen:

**Tronco:** Node 14.21.3 · Vue 2.6.14 · Vue Router 3 · Vuex 3 · axios 0.21.1 ·
Bootstrap 4.6.2 · vuelidate 0.7.7 · chart.js 2.9 · socket.io 2.x ·
json-server 0.16 · Jest 26 + vue-test-utils 1.x

**Rutas:** Quasar 1.22 · Vuetify 2.6 · Nuxt 2.15. **Bootstrap 4.6 se queda en
las tres** — la convivencia es contenido, no un descuido.

---

## 📊 El material en números

- **12 fases de tronco** + **5 apéndices** + **15 fases de ruta** (3 × 5)
- **15 piezas forenses** (12 de tronco + 3 de ruta) y **12 incidentes** en el
  cuaderno
- **911 ejercicios** graduados 🟢 fácil → 🟡 intermedio → 🟠 difícil →
  🔴 muy difícil, más los 🔥 opcionales
- 25–30 ejercicios por fase de tronco y de ruta; 34–40 por apéndice (todos
  opcionales)
- Al menos un tercio de los ejercicios son de **diagnóstico**: se entrega algo
  roto y se pide reproducir, localizar y explicar

| Bloque | Estado |
|---|---|
| Tronco F0–F11 | ✅ terminado |
| Apéndices a1–a5 | ✅ terminado |
| `0-ESTRUCTURA-CURSO.md` y `0-plan-del-curso.md` | ✅ terminado |
| Ruta Q (q0–q4) | ✅ terminada |
| Ruta VU (vu0–vu4) | ✅ terminada |
| Ruta NX (nx0–nx4) | ✅ terminada |
| Track forense (`forense-*.md`) | ✅ terminado |
| `cuaderno-incidentes.md` | ✅ terminado |

---

## 🎓 La promesa del curso

**Tronco:**

> "Me sueltan mañana en un Vue 2 ajeno de 80.000 líneas y no siento pánico: sé
> leer sus patrones, sé dónde vive cada tipo de cosa, sé qué oler, por dónde
> empezar a testear — y sé qué NO tocar todavía."

**Ruta:**

> "Me sueltan en un Vue 2 **con Quasar, Vuetify o Nuxt encima** y sé distinguir
> qué es Vue, qué es el framework, y **qué me está haciendo por debajo** —
> incluido lo que me está quitando sin avisar. Y antes de migrar nada, escribo
> la red."
