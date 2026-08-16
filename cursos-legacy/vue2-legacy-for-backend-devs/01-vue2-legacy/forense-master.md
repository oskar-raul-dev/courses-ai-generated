# 🕵️ Track forense — índice y método
## Curso 01 · Vue 2 Legacy — Mini Jira

> Puerta de entrada del track. Cubre las doce piezas de tronco,
> `forense-fase-00.md` … `forense-fase-11.md`, y las tres de ruta.

Ésta es la puerta. Nadie llega a una investigación sabiendo de qué fase es su problema:
llega con un síntoma, y casi siempre con uno mal descrito. Por eso el índice que de verdad
importa acá no es el de fases (§2), sino el de **síntomas** (§3).

El track no es material adicional: es el desarrollo de la sección 6 que cada fase ya trae.
La fase te dice **qué** se rompe; la pieza te enseña **en qué orden mirar**.

---

## 1. El método: cuatro preguntas, siempre en este orden

El orden no es una preferencia. Es que cada pregunta cuesta un orden de magnitud más que
la anterior, y contestar la barata primero descarta la mitad de las caras.

**Pregunta 1 — ¿se reproduce, y con qué?** Antes de mirar una línea de código: ¿esto se
reproduce **con un flag** del inyector de caos del mock, **con un dato** distinto en
`db.json`, o hace falta **otro código**? Las tres respuestas llevan a investigaciones
distintas, y averiguar cuál es te ahorra la mitad del camino. Es la misma pregunta que
ordena la preparación de los incidentes del cuaderno.

**Pregunta 2 — ¿qué dice la evidencia observable, antes que el código?** La URL de una
petición, el cuerpo crudo de la respuesta, el `state` de un módulo en Vue DevTools, el
frame que pasó por el socket. Casi todas las rutas de este track se resuelven acá, y
ninguna requiere abrir un archivo. **El código es el paso 4, no el paso 1.**

**Pregunta 3 — ¿en qué capa está?** Componente, store, servicio HTTP o mock. Son cuatro, y
casi todo el curso consiste en aprender a distinguirlas rápido. Localizar la capa es el
entregable de una investigación; el fix suele ser de tres líneas y viene después.

**Pregunta 4 — ¿de qué lado de la frontera está?** La frontera es lo que el mock promete y
lo que tu código asume. Un ticket que llega sin un campo, un `id` que es número donde
esperabas string, un evento de socket que emitió otro navegador: el síntoma es tuyo, la
causa está en el contrato. Contestar esto antes de escribir evita el fix que tapa el
problema en la capa equivocada.

> 🔑 **La frase para memorizar:** *"funciona en mi máquina", "a veces pasa" y "desde ayer"
> no son descripciones de un bug: son descripciones de una diferencia.* El trabajo es
> encontrar cuál.

---

## 2. 📇 Índice de las piezas

**Tronco — doce piezas, una por fase.**

| Fase | El síntoma que cubre | Herramienta principal | Archivo |
|---|---|---|---|
| 0 | "Instalé todo y no arranca", con errores que no hablan de lo que pasa | La salida de `vue-cli-service` en la terminal | `forense-fase-00.md` |
| 1 | "Entré a un ticket que no existe y la pantalla no dice nada" | Vue DevTools → Components, junto a la URL | `forense-fase-01.md` |
| 2 | "Me saca al login sin decir nada" | DevTools → Application → `localStorage` | `forense-fase-02.md` |
| 3 | "A veces carga y a veces se queda pensando" | Network | `forense-fase-03.md` |
| 4 | "Cambié el filtro y la tabla se quedó igual" ⭐ | Vue DevTools → Components | `forense-fase-04.md` |
| 5 | "Le di a guardar y no pasó nada" | La consola, y después Network | `forense-fase-05.md` |
| 6 | "Volví atrás en el wizard y perdí lo que había escrito" | Vue DevTools → el árbol de componentes | `forense-fase-06.md` |
| 7 | "La pestaña se va poniendo lenta y el ventilador se dispara" | Performance y Memory de Chrome | `forense-fase-07.md` |
| 8 | "Tomé el ticket y a mi compañero le sigue apareciendo libre" ⭐ | Network → WS, con dos navegadores | `forense-fase-08.md` |
| 9 | "Cambié el estado y el detalle no se enteró" | Vue DevTools → Components, y Network | `forense-fase-09.md` |
| 10 | "El estado cambió y nadie sabe quién lo cambió" ⭐ | Vue DevTools → Vuex, registro de mutations | `forense-fase-10.md` |
| 11 | "El test pasa solo cuando lo corro aislado" | La salida de Jest, con y sin `--runInBand` | `forense-fase-11.md` |

**Rutas — tres piezas, una por ruta.** Son **opcionales y excluyentes**: cada una cubre
las cinco fases de su ruta y se lee sola. Si elegiste Quasar, las otras dos no te
incumben.

| Ruta | Lo que investiga | Herramienta principal | Archivo |
|---|---|---|---|
| 🅠 Quasar 1 | El componente que no renderiza y no avisa · la tabla que pagina dos veces | Vue DevTools → Components, y `quasar.conf.js` | `forense-ruta-q.md` |
| 🅥 Vuetify 2 | El `v-app` ausente que rompe en silencio · el hex que mata el tema | El inspector de elementos, sobre el DOM renderizado | `forense-ruta-vu.md` |
| 🅝 Nuxt 2 | `window is not defined` · la hidratación que no cuadra | La terminal del servidor Nuxt, antes que la consola | `forense-ruta-nx.md` |

---

## 3. 🩺 Índice de síntomas transversal

La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la
derecha, dónde empezar. Todo lo que está acá sale de lo que las fases ya enseñan —casi
todo, de sus secciones «⚠️ Errores comunes»; el resto, de su código o de sus ejercicios—:
no hay ningún síntoma inventado. Lo que ninguna fase produce está en §6, y no en esta
tabla.

| Lo que ves o te cuentan | Empieza en |
|---|---|
| `Vue packages version mismatch` al compilar | Fase 0 — `vue` y `vue-template-compiler` desalineados |
| `EADDRINUSE` al levantar algo | Fase 0 — un proceso zombi de otra terminal |
| El editor "baila" al guardar, o el `.vue` no tiene resaltado | Fase 0 — dos formateadores compitiendo, o Volar (que es de Vue **3**) junto a Vetur |
| `this` es `undefined` dentro de un método, y el código "es idéntico" al de al lado | Fase 0 → Fase 3 — una arrow function en las opciones del componente: `this` dejó de ser la instancia |
| "Entré a un ticket que no existe y la pantalla no dice nada" | Fase 1 — la vista de detalle no distingue "no existe" de "todavía no cargó" |
| El mismo dato se pide desde tres componentes y cada uno lo trae distinto | Fase 1 — falta la capa de servicios; no es un bug todavía, es el que viene |
| "Me saca al login sin decir nada" | Fase 2 — el guard redirige sin mensaje; y solo mira que el token **exista** |
| El token venció (o es basura) y la aplicación se comporta como si nada | Fase 2 — existencia no es validez: hasta que el mock conteste 401, nadie lo desmiente |
| Borraste el token a mano en DevTools y la sesión siguió en pantalla hasta navegar | Fase 2 — el guard y el interceptor leen `localStorage`, el store tiene su propia copia, y nadie las sincroniza |
| "Le di a guardar y no pasó nada", consola limpia | Fase 5 — el formulario contesta antes que el código: `$error` frente a `$invalid`, y el `$touch()` que falta |
| Se crearon dos tickets iguales de un solo clic | Fase 5 — botón sin `disabled` durante el request |
| El formulario sale en rojo antes de escribir una letra | Fase 5 — `$invalid` en vez de `$error` |
| "Perdí 20 minutos depurando y el mock estaba apagado" | Fase 3 — por eso el mensaje de error pregunta por la Mock API 😉 |
| El error de una petición no aparece por ningún lado | Fase 3 — la action no devuelve la Promise, o hay un `try/catch` síncrono sobre código asíncrono |
| Editaste `db.json` a mano y tus cambios desaparecieron | Fase 3 — json-server con `--watch` pisándote |
| "Cambié el filtro y la tabla se quedó igual" | Fase 4 — estado duplicado: `filteredTickets` en `data` sincronizado con watchers |
| Cambiaste un campo del ticket y la tabla no se enteró, pero con F5 sí aparece | Fase 4 → Fase 9 — reactividad de Vue 2: la propiedad no existía cuando el objeto entró |
| Las filas se mezclan o conservan estado al reordenar | Fase 4 — falta `:key` en el `v-for`, o es el índice |
| Una tabla vacía sin mensaje, que parece rota y no lo está | Fase 4 — falta el estado vacío; **no es un bug**, y hay que demostrarlo |
| Vue grita en consola que estás mutando una prop | Fase 4 → Fase 9 — el hijo muta lo que debería emitir |
| "Volví atrás y el paso salió vacío" | Fase 6 — falta `keep-alive` en el wizard |
| "Me dejó avanzar con el paso 2 sin llenar" | Fase 6 — se validó todo al final en vez de por paso |
| La pestaña se arrastra y el ventilador se dispara | Fase 7 — la instancia del chart guardada en `data`: reactividad recursiva sobre un objeto gigante |
| `Canvas is already in use` al volver a una vista | Fase 7 — falta `chart.destroy()` en `beforeDestroy` |
| El gráfico no se ve, o mide treinta mil píxeles de alto | Fase 7 — canvas dentro de un contenedor sin dimensiones, con `responsive: true` |
| `this.$refs.canvas` es `undefined` | Fase 7 — lo pediste en `created`, y ahí todavía no hay DOM |
| Al navegar y volver, el evento del socket se aplica dos, tres veces | Fase 8 — listeners sin `off`, o `.bind(this)` distinto en el alta y en la baja |
| "Tomé el ticket y a mi compañero le sigue apareciendo libre" | Fase 8 ⭐ — quién emite el evento, y si el otro cliente lo recibió o no lo aplicó |
| El socket conecta y nada llega, con errores que no mencionan versiones | Fase 8 — cliente y servidor de socket.io desparejados |
| "Cambié el estado del ticket y el detalle siguió mostrando lo de antes" | Fase 9 — se guardó el **objeto** seleccionado en `data` en vez del `id` |
| Ves medio segundo los comentarios del ticket anterior, o texto ajeno en el textarea | Fase 9 — falta `:key`: instancia reutilizada sin reset |
| Asignaste `tickets[i] = updated` y no pasó nada | Fase 9 — asignación por índice en un array: Vue 2 no la ve |
| "El estado cambió y no sé quién lo cambió" | Fase 10 ⭐ — mutación fuera de una mutation; `strict` existe para cazarla |
| Un getter o una action responde a otro módulo, o a ninguno | Fase 10 — falta `namespaced: true` y los nombres colisionan en silencio |
| La vista no puede encadenar nada después de despachar | Fase 10 → Fase 3 — la action no devuelve la Promise. Es la misma trampa, por tercera vez |
| El test pasa solo, falla en conjunto | Fase 11 — mocks sin `clearAllMocks`: llamadas fantasma del test anterior |
| Un test que nunca falla, aunque rompas lo que prueba | Fase 11 — verde falso: `async` sin `return` de la Promise |
| Un cambio de maquetación tumbó media suite | Fase 11 — selectores acoplados al DOM en vez de `data-testid` |
| En el build de producción se comporta distinto que en `npm run serve` | Fase 10 → ruta Q — `strict` está apagado en producción: Vuex muta en silencio |
| 🅠 Copiaste un template y no se ve nada, sin error en consola | `forense-ruta-q.md` — el componente no está en `framework.components` |
| 🅥 Los colores del tema no aplican y los diálogos no abren, consola limpia | `forense-ruta-vu.md` — falta `<v-app>` en la raíz |
| 🅝 `window is not defined` al recargar una página que en navegación funciona | `forense-ruta-nx.md` — `created()` corre en el servidor |
| 🅝 El HTML del servidor y el del cliente no coinciden | `forense-ruta-nx.md` — `Date.now()`, `Math.random()` o `new Date()` en el render |
| El header `X-Total-Count` llega `undefined` y en Network se ve | rutas Q y VU — axios normaliza los headers a minúsculas; y si en minúsculas tampoco, es CORS |

---

## 4. 🧰 Las herramientas, y en qué miente cada una

Ninguna miente por malicia: cada una contesta una pregunta muy concreta, y el error es
preguntarle otra.

**Vue DevTools** miente por *timeline*. La pestaña de componentes te muestra el estado
**después** de la mutation, no quién la lanzó ni con qué payload; para eso está el registro
de mutations, que es otra vista. Cuando el dato en el store es correcto y la pantalla no,
DevTools te va a dar la razón y no la respuesta.

**La consola** miente de dos formas. Por **omisión**, cuando un `catch` vacío se traga el
fallo entero y te deja la pantalla congelada con la consola limpia. Y por **build**: los
warns de reactividad de Vue 2 solo salen en desarrollo, así que un bug que en
`npm run serve` grita, en el build de producción es mudo — y el bug sigue ahí.

**La pestaña Network** miente por status. Un `201` significa que el mock contestó, no que
hizo lo que crees. Y para los sockets hay que acordarse de que los frames están en su
propia pestaña, **WS**, no entre las peticiones.

**El `db.json`** miente por escritura. json-server guarda de verdad, así que después de
media hora de ejercicios el "caso limpio del enunciado" ya no existe. Antes de dar por
bueno un síntoma raro, mira si el dato es el que crees
([convención de git §🧹](../prompts/convencion-de-git-y-tags.md)).

**Y `git log -S`**, que no es una herramienta de depuración hasta que lo es:
`git log --oneline -S "socket.emit"` encuentra el commit donde una línea apareció o
desapareció, y contesta el *"esto antes funcionaba"* sin discutirlo.

---

## 5. Cómo se cierra el track

Este archivo te dice **dónde empezar**. Las piezas te dicen **cómo recorrer** cada camino.
Y lo que te llevas al trabajo real no está en ninguno de los dos: está en el hábito de
contestar las cuatro preguntas de §1 en orden, sobre un sistema que no es Mini Jira.

Las piezas que más rinden son las de las fases 4, 8 y 10 ⭐, por el mismo motivo: las tres
terminan en algo que no se ve en la pantalla —una propiedad que no es reactiva, un evento
que emitió el cliente equivocado, una mutación que nadie registró— y las tres se
diagnostican mirando, no leyendo código.

> 🧭 **El criterio para saber si el track hizo su trabajo:** que ante un ticket vago, tu
> primer movimiento ya no sea abrir el editor.

---

## 6. 📌 Síntomas sin pieza (pendientes)

Estos tres se consideraron para el índice y **no entraron**, porque ninguna fase del curso
los produce. Se anotan acá en vez de inventarles una fase, que es lo que manda
[`formato-piezas-forenses.md`](../prompts/formato-piezas-forenses.md) §9. Si alguna fase
llega a cubrirlos, suben a §3.

| Síntoma | Por qué no tiene pieza |
|---|---|
| "Cierro sesión en una pestaña y en la otra sigo dentro" | Ninguna fase toca el evento `storage` ni la sesión multi-pestaña: la Fase 2 guarda en `localStorage` y ahí se queda |
| "La métrica del dashboard no cuadra con el número de filas de la tabla" | La Fase 7 calcula sus métricas sobre el mismo arreglo que pinta la tabla, así que el curso nunca produce la divergencia |
| "El mock devuelve 404 en un endpoint anidado y en Postman funciona" | El curso consume los comentarios como `GET /comments?ticketId=X` (Fase 3), nunca en forma anidada |
