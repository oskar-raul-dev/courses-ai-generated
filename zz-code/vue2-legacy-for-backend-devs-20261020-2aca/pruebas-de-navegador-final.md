# 🧭 Pruebas de navegador del paquete Vue 2 — desechable

> **Desechable.** Lo abrió el 20/10/2026 la sesión de cierre de los cursos legacy, para que una sesión
> `claude --chrome` haga lo que la validación por ejecución no pudo: **mirar las pantallas**. Se borra
> cuando el autor lo autorice. Nada de lo que dice aquí se cita desde el curso.

## 1. Para qué

La guía (§17.4) deja «a mano del autor» todo lo que solo se ve en el navegador: las pantallas de F0 a
F11, las salidas de DevTools, el smoke test del contrato del Curso 02 y lo visual de las rutas (z-index,
modo oscuro, layout). Además, el incidente 05 del Curso 01 se rediseñó el 20/10/2026 y su síntoma se
reprodujo con una prueba de componente, no en pantalla. Esta sesión lo mira todo en Chrome y anota.

## 2. Reglas

1. **Docker solo con los dos ayudantes de §3.** Nada de `docker system prune`, `volume prune`, `image
   prune` ni `builder prune`. Hay contenedores, volúmenes e imágenes de otros cursos: no se tocan.
2. **Un alias a la vez.** El frontend tiene fijos `http://localhost:3000` y `http://localhost:4000`; el
   ayudante publica esos dos puertos solo en `127.0.0.1` y solo si están libres. Antes de otro alias,
   `./bajar.sh`.
3. **Se anota, no se corrige.** El resultado de cada prueba va a la tabla de §5 de este archivo. Si algo
   del curso está mal, se describe con su archivo y su sección; las correcciones las hace después una
   sesión normal. La excepción es una errata evidente de una palabra, y aun así se anota.
4. **Sin commits.** Git lo maneja el autor.
5. **Al terminar:** `./bajar.sh --todo` y un último `docker ps -a --filter label=tanda=navegador` vacío.

## 3. Cómo se levanta cada cosa

Desde la raíz del repositorio:

```bash
cd zz-code/vue2-legacy-for-backend-devs-20261020-2aca/navegador
./levantar.sh f11        # imprime la URL del frontend (puerto aleatorio de 127.0.0.1)
./bajar.sh               # contenedores y red; conserva node_modules para la próxima vez
./bajar.sh --todo        # al final: también los volúmenes de node_modules
```

La primera vez de cada alias tarda unos minutos (`npm ci` dentro del contenedor). Si el frontend
responde 200 pero la pantalla dice que no hay API, espera unos segundos y recarga (en `nx` la Mock API
tarda unos 15 s más, porque `npx` la descarga) y, si sigue, mira `docker logs vue2-nav-<alias>`. Antes
de la Fase 8 no hay servidor de sockets: el 4000 sin respuesta en `f03`, `f07` e `inc05` es lo esperado.
Los nueve alias se probaron el 20/10/2026: arrancan y responden.

| Alias | Árbol | Qué corre | Sirve para |
|---|---|---|---|
| `f03` | Curso 01, estado final de F3 | Mock API + Vue CLI | Pantallas de F0 a F3 |
| `f07` | Curso 01, estado final de F7 | Mock API + Vue CLI | Pantallas de F4 a F7 |
| `inc05` | F7 con la rama `incidente/05` y su `db.json` | Mock API + Vue CLI | El incidente 05 (§4.4) |
| `f09` | Curso 01, estado final de F9 | Mock API + sockets + Vue CLI | Pantallas de F8 y F9 (dos ventanas) |
| `f11` | Curso 01, estado final de F11 | Mock API + sockets + Vue CLI | F10 (Vuex) y el estado final del tronco |
| `vu` | Ruta VU (Vuetify), cerrada | Mock API + sockets + Vue CLI | VU1 a VU4 |
| `q` | Ruta Q (Quasar 1.22.10), cerrada | Mock API + sockets + `quasar dev` | Q1 a Q4 |
| `nx` | Ruta NX (Nuxt 2.15) | Mock API + `nuxt` | NX1 a NX4, incluido el SSR |
| `backend` | Curso 02: Express + Mongo 4.4 (seed y contraseñas) y el frontend de F11 sin Mock API | API + sockets en 3000/4000, frontend aparte | El smoke test del contrato (§4.5) |

**Credenciales.** El frontend del Curso 01 entra con `admin` / `1234` (login simulado de la Fase 2).
El backend del Curso 02 tiene a cada usuario de la semilla con la contraseña `<usuario>123` (por
ejemplo, `admin` / `admin123`), por si alguna prueba llama a `POST /auth/login`.

## 4. Qué mirar

### 4.1 Las pantallas del Curso 01 (F0–F11)

Para cada fase, abre `01-vue2-legacy/NN-*.md`, lee su sección **✅ «Qué queda listo al terminar»** (en
algunos documentos se llama «Qué queda al terminar», con número) y
comprueba en pantalla cada punto que sea visible (lo que sea de código o de terminal, sáltalo). Una fila
de la tabla por fase. F0–F3 con `f03`; F4–F7 con `f07`; F8 y F9 con `f09` (los sockets se ven con dos
ventanas o pestañas a la vez); F10 y F11 con `f11`. Si la fase tiene una pieza forense con capturas o
salidas de navegador (`forense-fase-NN.md`), compárala también.

### 4.2 DevTools

Las fases y piezas forenses que muestran salidas de **Vue DevTools** (sobre todo F10 y sus forenses) solo
se pueden comprobar si la extensión está instalada en este Chrome. Si no está, anota «no aplica: sin
extensión» y sigue; no la instales sin preguntarle al autor. Las salidas de la consola y de la pestaña
Network sí se comprueban.

### 4.3 Las rutas Q, VU y NX

Con `q`, `vu` y `nx`, la sección ✅ «Qué queda (listo) al terminar» de X1 a X4 de cada ruta, y en
especial lo que la validación dejó a mano: **z-index** (menús, diálogos y toasts por encima de la tabla),
**modo oscuro** (los actos 1 y 2 de VU4), **layout** de la convivencia Bootstrap + Quasar en Q (que la
tabla y el formulario migrados no se desarmen al angostar la ventana) y **el tiempo real en dos
pestañas**. En NX, que la primera carga llegue renderizada desde el servidor (ver
el código fuente de la página) y que la navegación siguiente sea del cliente.

### 4.4 El incidente 05, rediseñado

Con `inc05` (lee antes el incidente 05 de `01-vue2-legacy/cuaderno-incidentes.md`):

1. Entra con `admin` / `1234` y ve a la lista de tickets. El ticket 2 trae la etiqueta `correo`; el 1 y
   el 3, ninguna.
2. Clic en **🏷️ facturación** del ticket 3. **Esperado:** la fila no cambia.
3. Clic en **🏷️ facturación** del ticket 2. **Esperado:** aparece `facturación` en su fila. Anota si en
   ese momento aparece también la del 3 (debería: la tabla se repinta entera).
4. Recarga con F5. **Esperado:** las dos filas muestran sus etiquetas.
5. Opcional: aplica el parche mínimo del cuaderno (`$set`) en `trabajo/inc05/src/views/TicketsView.vue`,
   espera la recompilación, recarga la página (el `db.json` ya trae las etiquetas guardadas: para volver
   a la semilla del incidente, `./levantar.sh inc05` otra vez) y repite el paso 2 con el ticket 1.
   **Esperado:** ahora sí aparece.

### 4.5 El smoke test del contrato (Curso 02)

Con `backend`, la lista **«✅ Smoke test de la promesa»** de
`02-complement-mongodb-backend/00-audit-contrato.md`, punto por punto. El frontend es el de F11 sin
tocar: `baseURL` ya apunta a `http://localhost:3000`, que ahora es Express. El último punto (`git diff`
del frontend) no aplica aquí: anótalo así.

## 5. Resultados

Una fila por prueba. Resultado: ✅ como dice el curso · ❌ no coincide (di qué ves y dónde lo dice el
curso) · ⚠️ coincide con matices · — no aplica.

| # | Prueba | Alias | Resultado | Nota |
|---|---|---|---|---|
| 1 | F0 | f03 | ⚠️ | Lo único visible en el estado final de F3 es Bootstrap integrado (estilos activos en toda la app). El Hello World de F0 (vista + formulario + Stubby) ya no existe en este árbol (rutas: `/`, `/login`, `/tickets`); el resto de la ✅ de F0 es de terminal/editor. |
| 2 | F1 | f03 | ✅ | Header «Tiquetera» + sidebar (Inicio, Tickets) + contenido; se ve como sistema interno; se navega entre vistas; Bootstrap maquetando. |
| 3 | F2 | f03 | ✅ | `/login` con `admin`/`1234` entra; `/tickets` sin sesión redirige a `/login` en silencio (como dice forense-fase-02); la sesión sobrevive a la recarga; cada request lleva `Authorization: Bearer mock-jwt-token-123`; «Salir» vuelve al login y re-protege las rutas. |
| 4 | F3 | f03 | ✅ | `/tickets` lista los 3 tickets de `db.json` vía `GET localhost:3000/tickets` (200); detalle `/tickets/1` con estado/prioridad/asignado; interceptor verificado en los requests. |
| 5 | F4 | f07 | ✅ | Tabla Bootstrap con filas clicables; badges de estado (Abierto rojo, En progreso amarillo) y prioridad; tarjetas con conteos (1/1/1/0); búsqueda y filtro en cliente con «Mostrando N de 3 tickets»; estado vacío «No hay tickets que coincidan con los filtros»; fechas con filtro («11 de mar de 2020»). |
| 6 | F5 | f07 | ✅ | `/tickets/new`: errores por campo solo tras intentar enviar («El título es obligatorio», etc.); creado el #4 y redirigido a su detalle; `/tickets/4/edit` reutiliza el mismo formulario prellenado y guarda; Eliminar confirma («¿Eliminar el ticket #4? Esta acción no se puede deshacer.») y vuelve a la lista sin el ticket. El `window.confirm` nativo se interceptó por JS (un diálogo nativo congela la automatización); el flujo y el texto son los del curso. |
| 7 | F6 | f07 | ✅ | Asistente en `/tickets/wizard`: indicador 1-2-3 con pasos completados en verde; validación por paso (no avanza y pinta «mínimo 10 caracteres»); «Atrás» conserva lo escrito; confirmación de solo lectura con aviso de estado Abierto y reportero; crea el ticket y no molesta con el confirm tras crear; el guard de abandono salta («Tienes un ticket a medias…») y al responder «no» se queda. Matiz menor: el guard mira `draft`, que solo se llena en Siguiente/Atrás — si escribes en el paso 1 y te vas sin avanzar, no pregunta (coherente con el código, pero un lector puede probarlo así y extrañarse). |
| 8 | F7 | f07 | ⚠️ | Todo lo visible coincide: dona por estado con los colores de los badges, barras horizontales por agente, tarjetas (3 · 1 · 33% · 0), tabla de puntajes 🕹️ y enlace «actualizar». El matiz: «los gráficos se actualizan al recargar datos sin recrearse» no se observa desde el enlace «actualizar» — `loadTickets()` pone `loading=true` y el `v-if` de `MetricsView.vue` desmonta y remonta los charts (canvas distintos tras actualizar, verificado). El `chart.update()` del watcher (`StatusDoughnut.vue`) solo actuaría si `counts` cambiara sin pasar por `loading`. Lo dice `01-vue2-legacy/07-metricas-minimas.md` § ✅. |
| 9 | F8 | f09 | ✅ | Con dos pestañas: al crear el #4 en la B, la A (sin recargar) mostró el toast «Nuevo ticket #4 — Ticket en vivo F8» y la fila apareció al instante con los contadores actualizados. Indicador «🟢 en vivo» en el header de ambas. (En el estado desconectado el header muestra solo «🔴» con tooltip «Sin conexión en vivo», no el texto literal «🔴 sin conexión» de la ✅; cosmético.) |
| 10 | F9 | f09 | ✅ | `/support` con enlace «Soporte» en el sidebar; master-detail (cola Sin asignar/Míos a la izquierda, workspace a la derecha); «Tomar» asignó el #4 a admin y lo movió a Míos; botones de transición generados del mapa (en progreso → «Marcar resuelto» / «Reabrir»); comentario agregado y listado (CommentBox se limpia al enviar); el #5 creado en la pestaña B entró a la cola **en vivo y resaltado en amarillo**, con su toast. El «solo para agentes» no es ejercitable en pantalla: el login mock tiene un único usuario y es `agent`. |
| 11 | F10 | f11 | ✅ | Store con módulos `auth`/`tickets`/`ui` y `strict: true`; dashboard, panel de soporte y métricas leyendo del mismo store (el #4 creado en otra pestaña apareció en los tres sin recargar: fila+toast, cola «Sin asignar», tarjetas 4 · 2 · 25% · 1); los eventos de socket entran por el plugin. Mutación furtiva desde consola → el error exacto del forense: «[vuex] do not mutate vuex store state outside mutation handlers.» |
| 12 | F11 (estado final del tronco) | f11 | ✅ | El tronco completo funciona en su estado final: login, sesión que sobrevive recarga, dashboard con filtros, CRUD, asistente, soporte, métricas y tiempo real entre pestañas. La ✅ de F11 (Jest, `npm run test:unit`) es de terminal: no aplica en pantalla. |
| 13 | DevTools | f11 | ⚠️ | La extensión Vue DevTools SÍ está instalada (hook `__VUE_DEVTOOLS_GLOBAL_HOOK__` presente), pero su panel vive en la ventana de DevTools, inalcanzable para la automatización: las pestañas Vuex/Components no se pudieron mirar como las pinta el curso. Lo equivalente se comprobó por consola y por el hook: estado del store, error de strict mode (forense-fase-10 paso 3, literal), header `Authorization` en Network (F2/F3). Pendiente a ojo del autor si quiere ver el panel mismo. |
| 14 | Ruta VU | vu | ⚠️ | Lo central coincide: `v-data-table` con chips del tema y paginación propia (VU3); crear/editar en `v-dialog` con `:rules`, botón deshabilitado hasta validar y formulario reutilizado (VU2); el menú del `v-select` por encima del diálogo y de la tabla (z-index ✓); timeline `v-timeline` del detalle actualizándose **en vivo** al editar desde otra pestaña («asignado: admin → jpmesa», sin recargar); dark mode con sus dos actos tal como los cuenta VU4 (lo Vuetify se adapta; el sidebar `bg-light` y los botones Bootstrap quedan como cajas blancas — y en oscuro las tarjetas resumen Bootstrap quedan con el número **blanco sobre blanco**, invisible: radiografía extrema del Acto 2, no la menciona el curso). Dos matices: **(a)** crear desde el diálogo de VU3 (botón «Nuevo ticket» del dashboard, el camino por defecto del híbrido final) NO emite `ticket:created` — las otras pestañas no ven toast ni fila (verificado: el #5 nunca llegó a la pestaña A); por `/tickets/new` y el wizard sí llega (el #6 llegó con toast), así que la promesa literal de F8 («formulario o wizard») se mantiene, pero el camino nuevo quedó mudo y ninguna lección lo declara como deuda (cf. `zz-code …/vu/src/views/TicketsView.vue` `onSubmit` vs `TicketCreateView.vue` «📣 anunciar a los demás»; VU4 sí documenta la deuda análoga del panel F9, que se comprobó: cambios de estado en `/support` no registran actividad, por diseño). **(b)** El pie del `v-data-table` sale en inglés («Rows per page», «1-3 of 3»): locale por defecto de Vuetify en una UI en español; cosmético pero visible. |
| 15 | Ruta Q | q | ⚠️ | Funciona lo prometido: `QLayout`+`QDrawer`, `QTable` con los badges de F4 intactos vía slots, filtros y contadores; el modal Bootstrap de crear con campos Quasar y `:rules` («Este campo es obligatorio») guardando de verdad; `$q.notify` verde «Ticket #4 guardado»; `QTimeline` del detalle actualizándose **en vivo** desde otra pestaña; wizard con validación por paso que al crear **sí** anuncia (toast «Nuevo ticket #5» en la otra pestaña). Hallazgos: **(a) los `q-btn` estándar salen visualmente rotos** — «NUEVO TICKET» y «GUARDAR» con el texto recortado y el fondo corrido, porque `.q-btn__wrapper` usa clases `col row` y aquí gana el CSS de Bootstrap 4 (la colisión «peligrosa» que Q3 §«El `.row`» enseña); Q3 promete la convivencia «Funcionando» y funcional lo está, pero ningún ✅ avisa de que los botones del estado final se ven así. **(b)** En el wizard las etiquetas quedan recortadas por la izquierda («ítulo *», «escripción *») — mismo origen. **(c)** En Q el único camino que emite `ticket:created` es el wizard: ni `/tickets/new` ni el modal de Q3 anuncian (en el tronco F8 prometía «formulario o wizard»; cf. `zz-code …/q/src/views/TicketCreateView.vue`, sin `socketService`). **(d)** Cosmético: pie de `QTable` en inglés («Records per page»), fecha del timeline en formato en-US, pestaña del navegador «Quasar App» en vez de un título propio. **Pendiente a ojo del autor:** angostar la ventana (la herramienta de redimensionar no actuó sobre esta ventana de Chrome; no se pudo probar el layout angosto). |
| 16 | Ruta NX | nx | ⚠️ | El corazón SSR coincide: `curl` con la cookie `token` a `/tickets` devuelve los títulos de los tickets en el HTML del servidor (asyncData, NX3); `/tickets/1/activity` llega renderizado con sus eventos y con `<title>Actividad · La impresora no imprime</title>` dinámico por `head()` (NX4); `validate()` responde 404 a `/tickets/abc/activity` sin tocar la API; tras hidratar, la navegación es del cliente (un marcador en `window` sobrevivió al cambio de ruta); la raíz `/` conserva el welcome de Nuxt (coherente con NX1, proyecto recién generado). Dos cosas: **(a)** la «actualización en vivo» del timeline (NX4) no se pudo probar — el `server/socket-server.js` del árbol nx no arranca («Cannot find module 'socket.io'»): `nx/package.json` trae `socket.io-client` pero no `socket.io`; NX4 en realidad cuenta con el socket-server **del tronco**, así que es un hueco del empaquetado del ayudante/árbol `nx` de zz-code, no del texto — la página degrada bien y muestra «🔴 histórico». **(b)** Cosmético: el port NX va sin CSS global (`css: []`, sin Bootstrap), las páginas se ven «a palo seco»; ninguna ✅ promete estilos y el ejemplo de NX1 muestra dónde iría Bootstrap, pero un lector que venga de F4 puede extrañarse. |
| 17 | Incidente 05 | inc05 | ✅ | Los cinco pasos de §4.4, calcados al cuaderno: semilla correcta (solo el #2 con `correo`); clic en 🏷️ del #3 → la fila NO cambia aunque el PATCH guardó (la API ya tenía `['facturación']`); clic en el #2 → aparece la suya **y también la del #3** (la tabla se repinta entera: el «a veces sí» explicado); F5 → las dos filas con sus etiquetas; y el paso opcional: con el parche mínimo del cuaderno (`$set`) aplicado en `trabajo/inc05`, el #1 muestra la etiqueta al instante (parche revertido después de la prueba). |
| 18 | Smoke test del contrato | backend | ⚠️ | **Las lecturas, calcadas a la promesa:** login mock entra y el dashboard carga tickets desde Express; búsqueda y filtro en la UI, y `?q=`, `?status=`, `_sort`/`_order` verificados también por curl; detalle carga (con el ObjectId de Mongo como `#`, consecuencia esperable del frontend intacto); id inexistente → «El ticket no existe.»; métricas calculan en cliente sin errores y `/stats` devuelve **exactamente** lo mismo (byStatus 1/1/1, 33%, carga por agente); la recarga con sesión activa sobrevive; el punto del `git diff` no aplica aquí (anotado según §4.5). **Pero todas las escrituras desde la UI fallan:** crear muestra «No se pudo crear el ticket.» porque el backend final exige JWT real (`middleware/authenticate.js` → 401 «Token inválido o expirado» con `mock-jwt-token-123`), y lo mismo valdría para editar/tomar/estado/comentar/eliminar. Con un JWT real de `POST /auth/login` (admin/admin123) todo el contrato de escritura responde por curl: POST 201 con id asignado, PATCH 200 con rol `agent`, comentarios 201 y listados, DELETE 200. **El desencaje es de fases, no del texto:** el checklist es «de la Fase 10» (antes de `11-auth-real-y-pago-de-deudas.md`, que declara `POST /auth/login` como la única ruptura pactada y pide cambiar el `login()` del frontend); el alias `backend` de zz-code empaqueta el backend FINAL (auth F11 + sockets F12) con el frontend F11 sin tocar, combinación con la que el checklist de escrituras no puede pasar. Para correr el smoke test tal como lo promete 00-audit habría que apuntar al estado de F10 (sin `authenticate`) o aplicar el cambio de login de F11. Menor, visto por curl: `POST /comments` acepta un body sin `author` y guarda `author: null` (el controlador no toma el autor del token); el frontend sí manda `author`, así que no afecta la UI. |

## 6. Al cerrar

- `./bajar.sh --todo` y el `docker ps -a --filter label=tanda=navegador` vacío.
- Un resumen de tres líneas al final de este archivo: cuántos ✅, qué ❌ y en qué archivos.
- Avisarle al autor. Los ❌ se corrigen en una sesión aparte, y este archivo se borra con su permiso.

## 7. Resumen (sesión del 20/10/2026, cerrada con `bajar.sh --todo` y 0 contenedores/volúmenes)

11 ✅ (F1–F7, F9–F11 y el incidente 05, calcado al cuaderno) y 7 ⚠️, sin ❌ secos; los ⚠️ con sustancia: el diálogo de VU3 no emite `ticket:created` (fila 14, `zz-code …/vu/src/views/TicketsView.vue`), en Q los `q-btn` salen rotos por la colisión `.col/.row` y solo el wizard anuncia (fila 15, `q/src/…`), al árbol `nx` le falta `socket.io` para su propio socket-server (fila 16, `nx/package.json`), y el alias `backend` junta el backend final (auth F11) con el frontend intacto, así que las escrituras del smoke test dan 401 (fila 18, checklist de `02-…/00-audit-contrato.md` que es «de la Fase 10»).
Pendientes a ojo del autor: el panel de Vue DevTools (fila 13, la extensión está instalada pero la automatización no llega a esa ventana), el layout angosto de Q (la herramienta no pudo redimensionar la ventana) y el matiz de F7 («actualizar» remonta los charts por el `v-if` de `loading`, fila 8); las correcciones, si las hay, van en sesión aparte.

## 8. Segunda ronda (arreglos del 20/10/2026, tarde)

Lo de la primera ronda se corrigió en el curso y en los árboles de zz-code. Esta ronda confirma en
pantalla lo que cambió; el resto no hace falta repetirlo. Mismos ayudantes y mismas reglas (§2, §3).
El alias `backend` ahora entra con el login real: **`admin` / `admin123`** (el `admin` / `1234` de
la Mock API ya no sirve ahí).

| # | Qué cambió | Alias | Qué mirar | Resultado | Nota |
|---|---|---|---|---|---|
| R1 | VU3: el diálogo de crear anuncia `ticket:created` | vu | Crear desde «Nuevo ticket» del dashboard en la pestaña B: en la A aparecen el toast y la fila | ✅ | El #4 creado desde el diálogo en B llegó a la A sin recargar: toast «Nuevo ticket #4 — R1: el diálogo anuncia», la fila en el store (4 items) y los contadores actualizados (2 Abiertos). |
| R2 | VU1: Vuetify en español | vu | El pie del `v-data-table` dice «Filas por página» | ✅ | «Filas por página: 10 · 1-3 de 3»; `$vuetify.lang.current = "es"`. |
| R3 | VU4: fecha del timeline | vu | En el detalle, la fecha del timeline sale en español | ✅ | Entrada en vivo «asignado: admin → jpmesa» con fecha «20/10/2026, 2:42:53 p. m.» (formato es). De paso: el chip ya no tapa el nombre del actor (cosmético de la ronda 1, también resuelto). |
| R4 | Q3: cortafuegos CSS | q | «Nuevo ticket» y «Guardar» con su texto dentro del botón; etiquetas completas en el asistente («Título *») | ✅ | «+ NUEVO TICKET» del dashboard, «GUARDAR»/«CANCELAR» del modal y «← Atrás»/«Siguiente →» del asistente, todos con su texto dentro; etiquetas «Título *» y «Descripción *» completas en modal y asistente (adiós «ítulo»). |
| R5 | Q2 y Q3: crear anuncia `ticket:created` | q | Crear por `/tickets/new` y por el modal del dashboard: la otra pestaña recibe el toast y la fila | ✅ | Los dos caminos anuncian: el #4 creado desde el modal y el #5 desde `/tickets/new` llegaron a la pestaña A en vivo con su toast, la fila y los contadores (3 Abiertos, 5 de 5). |
| R6 | Q: idioma, fecha y título | q | Pie de `QTable` en español, fecha del timeline en español, pestaña «Tiquetera» | ✅ | Pie «Filas por página: 10 · 1-5 de 5»; fecha del timeline «20/10/2026, 2:46:39 p. m.»; pestaña del navegador «Tiquetera». Roce cosmético que sigue (fuera del alcance de R6): en el `QTimeline` el chip «asignado» tapa la primera letra del actor («…dmin»); en VU ya no pasa. |
| R7 | NX: sockets y Bootstrap en el árbol | nx | El timeline de NX4 se actualiza en vivo al editar desde otra pestaña; las páginas con estilos de Bootstrap | ✅ | El socket-server del árbol ya arranca (`socket.io` 2.4.1 en `nx/package.json`; `/socket.io/` responde 200) y Bootstrap 4.6.2 pinta las páginas (también en el HTML del servidor). Como la UI de NX no tiene desde dónde cambiar estado (NX4 cuenta con «otro usuario» en el tronco), el otro usuario se simuló emitiendo `activity:created` con `socket.io-client` desde el contenedor: la entrada «lmcorrea cambió el estado de in_progress a resolved» apareció **arriba del timeline, en vivo y sin recargar**. Matiz nuevo, anotado sin corregir: el badge se queda en «🔴 histórico» aunque el socket esté conectado y los eventos lleguen — `activity.vue` hace `this.isLive = socketService.isConnected()` una sola vez en `mounted`, justo tras `connect()`, antes de que termine el handshake; haría falta escucharlo (patrón F8) en vez de la foto única. |
| R8 | Smoke test con el login real | backend | La lista de §4.5 completa, ahora también las escrituras (crear, editar, tomar, estado, comentar, eliminar) | ✅ | Con `admin`/`admin123` (el `authService` ya llama a `POST /auth/login`): login entra y el dashboard carga desde Express con «🟢 en vivo»; **crear por el formulario Y por el wizard** → detalle con su ObjectId asignado y toast; **editar** guarda («(editado)» reflejado); en `/support`: **Tomar** (asignado a admin, a Míos, En progreso), **Marcar resuelto** (los botones pasan a «Cerrar / Reabrir»: el mapa de transiciones vivo), **comentar** (ver R9) y **eliminar** con su confirmación → la lista vuelve a los 3 de la semilla (verificado también por API); métricas 3 · 1 · 33% · 0 sin errores tras recarga completa con la sesión viva. Las lecturas (búsqueda, filtros, `?q=`, `_sort`, 404, `/stats`) ya habían pasado en la ronda 1 y no cambiaron. |
| R9 | Curso 02: autor de los comentarios | backend | Un comentario creado desde la UI sale con `admin` como autor | ✅ | El comentario de la UI sale listado con autor **admin**; en la API quedó `author: "admin"`, y un POST por curl con `author: "impostor"` en el body también guarda `admin` — el controlador toma el autor de `req.user.sub`, como promete el arreglo. |
| R10 | Layout angosto de Q (pendiente de la ronda 1) | q | Angostar la ventana: la tabla y el formulario no se desarman. Si la herramienta no redimensiona, anótalo y queda para el autor | ✅ | Esta vez el resize sí actuó: a 454px las tarjetas apilan en 2×2, el drawer colapsa a hamburguesa, la `QTable` queda legible con su pie, y el modal de crear muestra los campos apilados con «GUARDAR»/«CANCELAR» intactos. Nada se desarma. |

Ya verificado sin navegador, por si sirve de referencia: las redes de VU0 y Q0 en 66/66 y sus
builds en verde con los cambios; el bundle de VU con «Filas por página» y el de Q con «Filas por
página» y el título «Tiquetera»; el cortafuegos con capturas de Chromium headless antes y después;
NX con sockets y Bootstrap 4.6.2 en el HTML del servidor; `POST /comments`: 401 sin token, y con
token el autor es el del token aunque el body diga otro.

### Cierre de la segunda ronda (20/10/2026, tarde; `bajar.sh --todo`, 0 contenedores/volúmenes)

**10/10 ✅.** Todos los arreglos confirmados en pantalla, incluidos los dos pendientes de la ronda 1
que esta vez sí se pudieron mirar (el layout angosto de Q en R10 — el resize de la ventana actuó —
y el vivo de NX en R7, simulando al «otro usuario» del tronco con `socket.io-client` desde el
contenedor). Quedan dos roces cosméticos anotados sin corregir, a decisión del autor: el chip
«asignado» del `QTimeline` tapa la primera letra del actor (en VU ya no pasa; fila R6), y el badge
de `nx/pages/tickets/_id/activity.vue` se queda en «🔴 histórico» con el socket conectado, porque
`isLive` es una foto única en `mounted` en vez de escuchar connect/disconnect (fila R7). Del
pendiente de la ronda 1 sigue solo el panel de Vue DevTools, inalcanzable para la automatización.

## 9. Tercera ronda (cierre del 20/10/2026, noche)

Lo que cambió después de la segunda ronda. Mismos ayudantes; hay un alias nuevo, **`f00`**, con el
árbol de la Fase 0 y su Stubby (publica también el 8888 de `127.0.0.1`).

| # | Qué cambió | Alias | Qué mirar | Resultado | Nota |
|---|---|---|---|---|---|
| T1 | F0 con su propio árbol (en la ronda 1 se miró sobre F3) | f00 | La ✅ de `00-setup-hola-mundo.md` que sea visible: el Hola Mundo con su formulario y la respuesta del Stubby | ✅ | Todo el Hola Mundo en pantalla: tarjeta Bootstrap «Hola mundo legacy»; enviar vacío pinta «El nombre es obligatorio.» (campo en rojo, `is-invalid`); con nombre, el botón pasa a «Enviando...» durante los 400 ms de latencia del stub y aparece el alert verde «Hola desde el mock 👋 Oskar». El Stubby del 8888 verificado también por curl (200, el JSON del `stubby.yml`). Con esto la fila 1 de la ronda 1 (⚠️ por mirarse sobre el árbol de F3) queda saldada. |
| T2 | Q3: cortafuegos completo (todos los componentes de Quasar) | q | El chip del timeline ya no tapa el nombre («asignado admin»); el pie de la tabla con su selector y sus flechas en una línea; botones redondos y `dense` (el lápiz de editar) con su forma; ítems del menú lateral y barra superior alineados; el modal de Bootstrap con sus dos columnas como antes | ✅ | Los cinco puntos en pantalla: el chip del `QTimeline` en su línea y «admin» completo debajo («asignado / admin / jpmesa → lmcano», con zoom); pie «Filas por página: 10 ▾ 1-3 de 3» en una sola línea; los lápices de editar con su forma de botón plano (zoom a los tres); drawer (Tickets / Nuevo ticket / Métricas / Soporte) y barra superior alineados con sus iconos; y el modal Bootstrap conserva sus dos columnas (Prioridad ▾ | Asignado a) con «GUARDAR»/«CANCELAR» enteros. El grid de Bootstrap intacto, como midió el banco headless (60 → 3 elementos alterados, el píxel declarado). |
| T3 | NX4: la deuda del indicador, declarada | nx | El «🔴 histórico» con los eventos llegando es lo que dice ahora la ✅ de `nx4-pagina-ssr-nueva.md` (se paga en el ejercicio 12); no es un hallazgo | ✅ | La ✅ de NX4 ahora dice, literal, lo observado en R7: «El indicador, en cambio, se queda en 🔴 histórico en la primera visita aunque los eventos lleguen: lee la conexión una sola vez, antes de que termine el handshake. Es una deuda declarada, y pagarla es el ejercicio 12»; el código de la lección lleva el comentario «El ejercicio 12 lo vuelve reactivo» y el ejercicio 12 existe («Haz que el indicador 🟢/🔴 reaccione de verdad a connect/disconnect»). Comportamiento en pantalla ya verificado en R7 (evento en vivo arriba del timeline, badge rojo); solo cambió el texto, así que no se relevantó el alias. |
| T4 | El panel de Vue DevTools | f11 | Si la automatización sigue sin llegar a esa ventana, «— no aplica» y queda para el autor | — | No aplica, y esta vez con el porqué técnico completo: la ventana de DevTools es UI del navegador, fuera de toda pestaña (las capturas de la extensión solo ven el viewport de la página), y además abrir DevTools sobre una pestaña que la extensión está depurando desconectaría su debugger (Chrome admite uno por pestaña), matando la sesión de automatización. Queda para el ojo del autor; lo equivalente (store, strict mode, Network) se verificó por consola y por el hook en la fila 13. |

Ya verificado sin navegador: el cortafuegos con el banco de medidas de Chromium headless (60
elementos de Quasar alterados por Bootstrap → 3, el píxel declarado del `q-btn__wrapper`; el grid de
Bootstrap intacto); las redes de VU0 y Q0 en 66/66 y sus builds en verde; el Stubby de `f00`
respondiendo desde el Mac.

### Cierre de la tercera ronda (20/10/2026, noche; `bajar.sh --todo`, 0 contenedores/volúmenes)

**3 ✅ y 1 — (T4, no aplica).** Con esto no queda ningún hallazgo abierto de las tres rondas: la fila
1 de la ronda 1 la salda T1 (F0 completo sobre su propio árbol, Stubby incluido), los dos roces
cosméticos de la ronda 2 los saldan T2 (chip del timeline Q) y T3 (la deuda del indicador NX,
declarada en la ✅ y pagadera en el ejercicio 12), y el panel de Vue DevTools queda explicado como
no automatizable (T4) y a ojo del autor. El desechable está listo para borrarse cuando el autor lo
autorice; los commits los maneja él.
