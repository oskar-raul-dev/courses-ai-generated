# 🧪 vue2-legacy-for-backend-devs-20261014-b44a · cómo correr estas pruebas

> **Curso:** vue2-legacy-for-backend-devs · **Tanda:** P1, R1–R4, V0–V7, K1–K6 y C · **Creado:** 2026-10-14
> **Estado:** archivado el 2026-10-18, al cerrar el paquete (§19).
> **Propósito:** la edición completa del paquete: lineamientos, validación por ejecución, revisión de código y cierre.
> Plan: `prompts/_desechable-plan-de-edicion.md` del paquete, **borrado en C**; su resultado y sus reglas
> pasaron a la guía del paquete, §17.4 y §17.5, y su bitácora queda en las secciones de este README.

## 1. 🎯 Qué se prueba y para qué

- **R3, diagramas:** los 22 bloques Mermaid del paquete se exportan con `zz-instrucciones/herramientas/exportar-diagramas.py --motor docker`. Salida en `salidas/diagramas/` (21 pares) y `salidas/diagramas-01-readme/` (el README del Curso 01, separado porque su nombre colisiona con el raíz).
- **R1–R2, verificador:** `prompts/verificar-corpus.py` (y `--publicacion`). Corridas en `salidas/vue-r1-run*.txt`, `salidas/vue-r2-*.txt`, `salidas/vue-r3-*.txt`.
- **V0, ambiente:** imágenes, arquitectura y versiones congeladas en el registro de npm. Hallazgos en §7.

## 2. 🛠️ Prerrequisitos

| Herramienta | Versión | Dónde |
|---|---|---|
| Docker (server) | 29.8.0, linux/arm64 | host del autor |
| `node` | 14.21.3 (`npm` 6.14.18) | `node:14.21.3`, arm64 nativo |
| `node` alternativo (Apple Silicon, F0) | 16.20.2 | `node:16.20.2`, arm64 nativo |
| `mongo` | 4.4 | `mongo:4.4`, arm64 nativo (imagen Ubuntu 20.04) |
| `mermaid-cli` | imagen `minlag/mermaid-cli` (la que elige `exportar-diagramas.py --motor docker`) | contenedor, sin Node en el host |

Estado previo: el inventario de Docker al empezar está en `salidas/inventario-docker-inicio.txt`. Había contenedores del curso `vue2-legacy` ninguno; las imágenes `node:14.21.3`, `node:14.21.3-bullseye-slim`, `node:18.18.2-alpine` y `node:20` ya existían y no se tocaron.

## 3. 🧭 Reglas antes de correr

```bash
mkdir -p salidas
docker ps -aq --no-trunc > salidas/contenedores-antes.txt
docker images -q --no-trunc | sort -u > salidas/imagenes-antes.txt
docker volume ls -q > salidas/volumenes-antes.txt
docker network ls -q > salidas/redes-antes.txt
```

Todo corre con `--label curso=vue2-legacy --label tanda=<V0…V7>`, en contenedor, con puertos en `127.0.0.1` y sin publicar 8080, 3000, 4000 ni 27017 en el host.

## 4. ▶️ Cómo se corre

Desde la raíz del repositorio:

```bash
# verificador del paquete (R1–R2)
cd cursos-legacy/vue2-legacy-for-backend-devs && python3 prompts/verificar-corpus.py --publicacion

# exportación de diagramas (R3), un archivo o carpeta
python3 zz-instrucciones/herramientas/exportar-diagramas.py cursos-legacy/vue2-legacy-for-backend-devs/01-vue2-legacy --motor docker --salida zz-code/vue2-legacy-for-backend-devs-20261014-b44a/salidas/diagramas
```

Consulta del registro (V0), con un contenedor efímero:

```bash
docker run --rm --label curso=vue2-legacy --label tanda=V0 node:14.21.3 sh -c 'npm view vue@2.6.14 version'
```

## 5. 📏 Cómo se mide

No hay mediciones de rendimiento en esta sesión. Las comprobaciones son de existencia y de salida: que una versión se pueda consultar y que un diagrama se exporte sin error.

## 6. 🧮 Los intermedios que amasan la salida

- `exportar-diagramas.py` escribe un `.mmd` y un `.png` por bloque, con nombre `<archivo>-NN`. Dos documentos con el mismo nombre de archivo (dos `README.md`) pisan su salida: por eso el README del Curso 01 va en `diagramas-01-readme/`, y el del raíz se renombró a `raiz-README-01.*` en `diagramas/`.
- El conteo de bloques Mermaid sale de `grep -rn '^\s*```mermaid' --include='*.md' . | grep -v '^./prompts/' | wc -l` (22).

## 7. ✅ Qué se espera ver

**V0, resultados:**

| Elemento | Versión pedida | Resultado | Fuente |
|---|---|---|---|
| `node` | 14.21.3 | ✅ `v14.21.3` (arm64 nativo) | `salidas/V0-arquitectura-imagenes.txt` |
| `node` Apple Silicon | 16.20.2 | ✅ imagen arm64 descargada | idem |
| `mongo` | 4.4 | ✅ imagen arm64 nativa (`linux/arm64`, Ubuntu 20.04) | idem |
| `vue` | 2.6.14 | ✅ | `salidas/V0-registro-npm.txt` |
| `vuex` | 3 | ✅ (3.6.2 es la última 3.x) | idem |
| `vue-router` | 3 | ✅ | idem |
| `bootstrap` | 4.6.2 | ✅ | idem |
| `jquery` | 3.6.0 | ✅ | idem |
| `axios` | 0.21.1 | ✅ | idem |
| `json-server` | 0.16.3 | ✅ | idem |
| `chart.js` | 2.9.4 | ✅ | idem |
| `vuelidate` | 0.7.7 | ✅ | idem |
| `socket.io` | 2.4.1 | ✅ | idem |
| `mongodb` (driver) | 3.6 | ✅ (3.6.12 es la última 3.6.x) | idem |
| `quasar` | 1.22 | ✅ `1.22.10` | `salidas/V0-registro-npm-rutas.txt` |
| `vuetify` | 2.6 | ✅ `2.6.16` | idem |
| `nuxt` | 2.15 | ✅ `2.15.8` | idem |
| `@nuxtjs/axios` | — | ✅ `5.13.6` (la última; la de Nuxt 2 es la 5.x) | idem |
| `jest` | 26 | ✅ | idem |

**Hallazgos (H-V0-n):**

- **H-V0-1, `@quasar/app` 1.22.x no existe.** La tabla de `0-plan-del-curso.md` (§Rutas) pide `@quasar/app` 1.22.x. El registro tiene `@quasar/app` 1.x hasta la **1.9.6**, y 2.x desde la 2.0.0. El README del Curso 01 dice «`@quasar/app`: ^2.x». Son dos afirmaciones del paquete que no cuadran. Se resuelve en V5 (ruta Q), con el `package.json` que corre. No se corrige aquí.
- **H-V0-2, Vue CLI: 3.x o 4.x.** `0-plan-del-curso.md` pide Vue CLI 3.x; la tanda V0 del plan decía «Vue CLI 4». El registro tiene `@vue/cli` 3.12.1 y 4.x. Se queda 3.x, que es lo que la tabla oficial dice. Se corrige el plan, no el curso.
- **H-V0-3, `@nuxtjs/axios`.** La tabla de Rutas no fija versión; el registro tiene 5.13.6, que es la de Nuxt 2. Se anota.
- **H-V0-4, `vue-template-compiler`.** La fase 0 hace que el alumno instale `vue-template-compiler@2.6.12` a propósito (ejercicio 4). El plan fija 2.6.14. Son dos versiones en el mismo curso, intencionales: se verifica en V1.
- **H-V0-5, Stubby.** El plan dice «última»: el registro da 5.1.1. Se instala en F0.

Ninguna versión congelada faltó en el registro.

**V1, F0 a F3 (cerrada el 2026-10-15; navegador a mano del autor).**

- **H-V1-1, `vue create` con yarn no se reproduce.** Con `vue create --default` (yarn por defecto), la instalación falla en `node:14.21.3`: `node-releases@2.0.58` exige Node ≥18. No hay lockfile que fije los transitivos. Con `--packageManager npm` termina y crea `package-lock.json`. Se usa npm en la tanda V1. Consecuencia para el alumno: el curso debe decir que la primera instalación usa npm, o que el lockfile de F0 se incluye.
- El scaffold de prueba está en `repo/tiquetera-legacy/`, sin `node_modules` ni `.git`. Se regenera con `npm install -g @vue/cli@3` y `vue create --default --force --packageManager npm tiquetera-legacy` dentro de `node:14.21.3`.
- **Corregidos en el texto (2026-10-15):** H-V1-2 (F0 pide borrar `HelloWorld.vue` y `logo.png`) y H-V1-4 (`PageTitle` en F1).
- **H-V1-2, restos del `vue create`.** El scaffold deja `src/components/HelloWorld.vue` y `src/assets/logo.png`, y la fase 0 dice que la estructura de hoy es solo `main.js` y `App.vue`. Se borran a mano en la prueba. El documento no lo dice.
- **H-V1-3, retirado (falso positivo).** Se creyó que F0 decía «versiones exactas» y guardaba `^` por descuido. La sección siguiente de F0, «el `^` que npm escribió sin preguntarte», lo hace a propósito: enseña el `^` y pide quitárselo a mano solo a `vue` y `vue-template-compiler`. El `--save-exact` que se añadió el 15/10 se revirtió en F0, y el `package.json` del repo quedó como pide la fase: `vue` y `vue-template-compiler` en `2.6.14`, el resto con `^`.
- **H-V1-4, `PageTitle` se usa antes de existir. Decidido por defecto: se publica en F1 como código** (el ejercicio 6 cambia a «quita la prop y lee la advertencia»; `PageTitle.vue` en la prueba es el de F1). `views/LoginView.vue` de F2 importa `../components/common/PageTitle.vue`, y F3 y las fases siguientes también. F1 solo lo describe como **ejercicio 6**. Sin ese archivo, F2 no compila (`This relative module was not found`). En la prueba se creó a partir de la especificación del ejercicio (prop `title`, pinta un `<h1>`), marcado como no publicado. **Decisión**: (a) publicar `PageTitle.vue` como código en F1, aplicada por defecto.
- **H-V1-5, json-server en Docker.** `json-server --port 3000` escucha solo en `127.0.0.1` dentro del contenedor; desde el host, el puerto mapeado devuelve `000`. Dentro del contenedor, las rutas responden (200, 404 para `/tickets/999`) y el CORS permite `localhost:8080`. Es un detalle del entorno de prueba: en un portátil, `localhost` funciona. Las pruebas se hacen con `docker exec`.
- **H-V1-6, avisos de tamaño de bundle.** `vue-cli-service build` da dos avisos de rendimiento (el entrypoint supera 244 KiB desde F1). No son errores.

**Resultados de V1, por fase:**

| Fase | Build | Comprobación | Estado |
|---|---|---|---|
| F0 | ✅ | mock Stubby: `POST /api/hello` → 200, latencia ~0.42 s, CORS para `localhost:8080`; `GET` sin POST → 404; `npm run serve` → 200 | ✅ (formulario en navegador: **pendiente, manual**) |
| F0 · ejercicio «rompe a propósito» | ✅ error reproducido | `npm install vue-template-compiler@2.6.10 --save-exact` → `Vue packages version mismatch`, coincide con la fase | ✅ |
| F1 | ✅ | `/`, `/tickets`, `/tickets/5` y una ruta inexistente → 200 (shell de la app); el bundle contiene las cuatro vistas | ✅ (navegación y 404 pintado en cliente: **pendiente, manual**) |
| F2 | ✅ (con `PageTitle` de H-V1-4) | no hay prueba de servidor: el guard y el login son cliente | ⚠️ guard y login: **pendiente, manual** |
| F3 | ✅ | `/tickets`, `/tickets/1`, `/tickets?status=open`, `/tickets/999` (404), `/users` desde dentro del contenedor | ✅ (lista y detalle en navegador: **pendiente, manual**; 🔥 caos **no corrido**, es opcional) |

**Sin tags.** El plan pide un tag `fase-<slug>` por fase en el repo del alumno. No se crearon, porque para etiquetar hace falta un commit y la memoria de Oskar prohíbe commitear. Las instantáneas `.tgz` de cada fase se guardaron en `salidas/fases/`, que ya no está en disco (ver §8). Si quieres tags, lo decides tú y se hacen en el repo del alumno.

**Pendiente de V1:** la verificación en navegador de F0 a F3 (formulario de F0, navegación, guard de F2, lista y detalle de F3), y la decisión H-V1-4.

**Sin verificar en V0:** que `npm install` de cada paquete termine en el contenedor; eso lo prueban las tandas V1–V7, fase por fase.

## 8. 📂 Salidas

`salidas/` ya no está en disco (comprobado el 25/10/2026): no se versiona y `limpiar.py` la libera como regenerable. Las cifras de este README son el registro.
Los registros, las corridas del verificador y los diagramas se rehacen corriendo las pruebas; **no** se rehacen
las instantáneas de `salidas/fases/` ni los `backend-*.tgz` (el estado de cada fase hay que reconstruirlo desde su
documento), ni el inventario inicial de Docker. La de F11 sobrevive desempacada en `…-20261018-fb1d/f11/`. Lo que
tenía:

| Archivo | Qué es |
|---|---|
| `salidas/inventario-docker-inicio.txt` | contenedores, imágenes `node`/`mermaid` y `mongo` antes de empezar |
| `salidas/V0-arquitectura-imagenes.txt` | arquitectura y OS de cada imagen |
| `salidas/V0-registro-npm.txt` | versiones congeladas del tronco en el registro |
| `salidas/V0-registro-npm-rutas.txt` | versiones de rutas, Vue CLI, Nuxt y Jest |
| `salidas/V0-registro-quasar-vuecli.txt` y `…-peers.txt` | la búsqueda de `@quasar/app` 1.x y la de peer dependencies (sin resultado útil) |
| `salidas/vue-r*.txt` | corridas del verificador (R1–R3) |
| `salidas/export-*.txt` | salida de `exportar-diagramas.py` |
| `salidas/diagramas/`, `salidas/diagramas-01-readme/` | `.mmd` y `.png` de los 22 diagramas |

## 9. 🧹 Limpieza

No se crearon contenedores ni volúmenes de prueba: las consultas de V0 usaron `--rm`. Para comprobarlo:

```bash
docker ps -a --filter label=curso=vue2-legacy --format '{{.ID}} {{.Names}}'
```

Sin salida = nada que limpiar. Las imágenes `node:16.20.2` y `mongo:4.4` quedan descargadas a propósito, para V1 y V6.

**Al cerrar (C, 2026-10-18)** se borraron con `docker rm -f -v` los seis contenedores del curso que quedaban (`curso-mongo-v6`, `curso-mongo-v7`, `curso-mongo-rs`, `tiq-q-noeslint`, `tiq-q-app1`, `tiq-q-scaffold`), con sus volúmenes anónimos, y las redes `v6net` y `v7net`. El filtro `label=curso=vue2-legacy` queda vacío en contenedores y redes. **Imágenes que bajaron las tandas y siguen en el disco** (no estaban en el inventario inicial; las borra el autor si quiere): `mongo:4.4` (565 MB, más una capa `mongo:<none>` de 1,26 GB), `node:16.20.2` (1,27 GB), `node:14.21.3-alpine` (180 MB) y la variante amd64 de `node:14.21.3`, que se sumó a la arm64 que ya existía. `minlag/mermaid-cli` y `ghcr.io/mermaid-js/mermaid-cli` son de la herramienta de diagramas, compartida con otros cursos.

## 10. 🚫 Qué se dejó fuera

- `node_modules`, la imagen de `mermaid-cli` y los `.png` de salida: se regeneran con `exportar-diagramas.py`.
- Las dependencias del curso no se instalan en el host (regla 11 del plan).


## 11. 🧭 V2 · F4 a F7 (2026-10-15)

**Qué se hizo.** Los archivos de cada fase se extrajeron del documento con la línea exacta de su cerca de código (`salidas/` no lo guarda; el script de extracción está en la sesión de trabajo). Los parches sobre archivos ya existentes se aplicaron por ancla de texto exacta, y el build de cada fase se corrió en `node:14.21.3`.

**Resultados, por fase.**

| Fase | Build | Comprobación | Estado |
|---|---|---|---|
| F4 · dashboard | ✅ | rutas `/tickets`, `/tickets/new`, `/tickets/1/edit`, `/tickets/5`, `/metrics` → 200; bundle con la vista | ✅ (tabla, búsqueda y filtro: **a mano del autor**) |
| F5 · CRUD | ✅ | bundle con «Nuevo ticket», «Eliminando…», la confirmación y el error de borrado; API de F3 para create/patch/delete existe en `ticketService` | ✅ (formularios y validación Vuelidate: **a mano del autor**) |
| F6 · wizard | ✅ | `/tickets/wizard` → 200; bundle con «Asistente» | ✅ (pasos, cache y confirmación: **a mano del autor**) |
| F7 · métricas | ✅ | `/metrics` → 200; bundle con «Tabla de puntajes», «Métricas»; `scoreBoard` ejecutado en Node 14 sobre el `db.json` de F3 | ✅ (gráficos chart.js 2.9.4: **a mano del autor**) |

**Lodash y Bootstrap, lo que V2 pedía comprobar.** En lodash 4.17.21 existen `keyBy`, `groupBy`, `sumBy` y `countBy`. En Bootstrap 4.6.2 la clase `.text-monospace` está en el CSS compilado.

**La tabla de puntajes, con datos reales.** Con el `db.json` de F3, `scoreBoard` devuelve una fila: `LMC`, 1 ticket resuelto, 100 puntos. El 900 y el «4 resueltos» del comentario de F7 son un ejemplo ilustrativo, no el resultado de esta base (esos datos aparecen en un incidente posterior).

**Hallazgos de V2.**

- **H-V2-1, fragmentos sin archivo en el árbol de F7.** `utils/statusColors.js` se publica como bloque, pero el árbol «Estructura que se agrega» de F7 no lo lista. Sin ese archivo, `StatusDoughnut.vue` no compila. Corrección sugerida: añadirlo al árbol.
- **H-V2-2, fragmentos que completan archivos.** Varias fases publican fragmentos sin nombre de archivo que hay que pegar en otro: F4 (`main.js`, Vue.filter), F5 (`main.js` con Vuelidate, `router/index.js`, `TicketDetailView.vue`, botón en `TicketsView.vue`), F6 (ruta y botón), F7 (`ticketStats.js` continúa, router, sidebar). Se aplicaron por ancla de texto. El curso debería decir, en cada fragmento, dónde va. Es coherente con la guía, pero el lector puede equivocarse.
- **H-V2-3, retirado.** Mismo caso que H-V1-3: el `^` de `chart.js` es el comportamiento que F0 enseña, y la regla de F0 solo fija `vue` y `vue-template-compiler`.
- **H-V2-4, ejemplo de puntajes.** El comentario de F7 `[{ initials: "LMC", solved: 4, points: 900 }, ...]` no sale de los datos de la fase. Conviene decir que es ilustrativo.
- **Instantáneas.** Solo se guardó el estado final de F7 (`salidas/fases/fase-07-metricas-minimas-estado-final.tgz`). Los estados intermedios de F4 a F6 no se guardaron.

**Pendiente de V2.** La verificación en navegador de F4 a F7 (tabla, búsqueda, formularios, wizard, gráficos). La suite de pruebas empieza en F11, así que no hay suite que correr en V2.


## 12. 🧭 V3 · F8 a F11 (2026-10-15)

| Fase | Build | Prueba | Estado |
|---|---|---|---|
| F8 · websockets | ✅ | `npm run dev` (concurrently 5.3.0) levanta mock, sockets y serve. `salidas/pruebas/f8-broadcast.js`: dos clientes socket.io-client 2.4.0; B recibe el `ticket:created` de A y A no se lo recibe a sí misma. El log del servidor coincide con la fase | ✅ |
| F9 · panel de soporte | ✅ | rutas y bundle; guard por roles en el router | ✅ (cola, transiciones y comentarios: **a mano del autor**) |
| F10 · Vuex | ✅ | `salidas/pruebas/f10-registro-temprano.js` reproduce el fallo del registro temprano y prueba el arreglo | ✅ |
| F11 · testing | — | `npm run test:unit`: **6 suites, 26 pruebas en verde** (21 publicadas + 5 nuevas de `initialsOf` y `scoreBoard`) | ✅ |

**Hallazgos de V3, todos corregidos en el texto salvo H-V3-4:**

- **H-V3-1.** F8 añade el script `dev` con `concurrently`, que ninguna fase instala (era el ejercicio 15 opcional de F3). F8 dice ahora `npm install --save-dev concurrently@5.3.0`, y su fragmento de scripts conserva `build`.
- **H-V3-2.** F8 pide `<live-toast />` en `App.vue` sin importar ni registrar `LiveToast`: Vue avisa de un elemento desconocido y no pinta nada. El fragmento trae ahora el import y `components`.
- **H-V3-3.** F9 «gradúa» `userService.js` en su árbol, pero no publica su código, y `SupportView` no compila sin él. Publicado en F9, con el molde de `commentService`.
- **H-V3-4.** F7 dice que «`userService` llega en la Fase 9» como pago de una 💸, pero ninguna fase cambia `MetricsView` para usarlo. F9 dice ahora que desde allí `MetricsView` *puede* usarlo; la deuda sigue abierta en el código. **Decisión del autor**, si se quiere pagar en una fase.
- **H-V3-5.** El fragmento «DESPUÉS» de `TicketsView` en F10 omitía los imports, `name` y `components`, y cerraba con un `</script>` que no se abrió. Corregido.
- **H-V3-6, el más serio.** El plugin de Vuex de F10 registra sus handlers al crear el store, antes de `connect()`, y el `socketService` de F8 ignora `on()` sin socket: el store **nunca** recibía eventos en vivo. F10 afirmaba lo contrario. Reproducido con el servidor real; F10 publica ahora un `socketService` que guarda los handlers y los aplica al conectar, y su frase se corrigió.
- **H-V3-7.** `vue add unit-jest` instala hoy el plugin 5.0.9 (Vue CLI 5); su generador muere en este proyecto y no deja ni el script ni `tests/`. F11 instala ahora `@vue/cli-plugin-unit-jest@3.12.1` y corre `vue invoke unit-jest`. Ese plugin trae **Jest 23.6.0**, `vue-jest` 3.0.7 y `@vue/test-utils` 1.0.0-beta.29, no Jest 26: corregidas las tablas de `README.md` y `0-plan-del-curso.md` del Curso 01 y la mención de NX0. (El Curso 02 sí usa Jest 26, instalado directo.)
- **H-V3-8.** El generador deja `tests/unit/example.spec.js`, que importa el `HelloWorld.vue` que F0 manda borrar: la suite empieza en rojo. F11 pide ahora borrarlo.

**Pruebas escritas en V3:** cinco en el Test 1 de F11 (`initialsOf` y `scoreBoard`), sin fijar la 💸 de agrupar por iniciales, que paga el incidente 13.


## 13. 🧭 V4 · cuaderno y forenses del Curso 01 (2026-10-15)

**Qué se hizo.** Los 13 incidentes, cada uno en un directorio `incidentes/NN/` con el estado de su
fase sacado de la instantánea, la preparación del cuaderno aplicada, y su prueba de regresión
corrida roja con el bug y verde con el arreglo. El detalle por incidente, y el `db.json` alterno del
13, están en `prompts/preparaciones-de-incidentes.md` del paquete. Y las 12 piezas forenses del
tronco, contrastando cada salida de terminal (`grep`, `curl`, Stubby, Jest) con la real.

**Lo que el cuaderno publicaba y no corría.** Casi todas las pruebas de regresión tenían un `{ … }`
sin rellenar o nombres que no existen en el código de la fase. Todas quedan ejecutables. Las
correcciones de fondo:

- **Incidente 02.** La solución no publicaba el cambio de plantilla que su prueba exige; el `setData`
  necesita `$nextTick()` con este test-utils.
- **Incidente 03.** El guard no se podía importar (función anónima), el parche usaba `store` sin
  importarlo, y la prueba esperaba `token` en `null` cuando `CLEAR_SESSION` lo deja en `""`.
- **Incidente 04.** El parche llamaba a un `applyFilters()` inexistente; la preparación dejaba la
  tabla vacía al arrancar; la prueba solo pasa con el `computed`, no con el parche (se dice así).
- **Incidente 05.** No reproducible con el curso (ni `tags` ni `onTicketUpdated` en `TicketsView`):
  marcado «no verificado por ejecución»; su refactorización perdía `createdAt` y `reporter`
  (corregida). **Decisión de autor pendiente.**
- **Incidente 06.** Nombres de F6 (`next`, `mergeCurrentStep`); prueba con `mount` y Vuelidate.
- **Incidente 07.** Prop `counts` y no `tickets`, `jest.mock("chart.js")`, parche con la
  configuración real.
- **Incidente 09.** F9 ya publica el arreglo del síntoma 2: la preparación ahora dice cómo
  recrearlo. El relé del servidor no reenvía `ticket:updated` (ejercicio 10 de F8): agregado al
  parche y probado con dos clientes.
- **Incidente 10.** El módulo `ui` no tenía `SET_LOADING`; `toThrow()` no ve el error de `strict`;
  el parche borraba `auth` y el plugin del store.
- **Incidente 11.** Apuntaba a pruebas que F11 no publica; rehecho sobre las publicadas.
- **Incidente 12.** `strict` no impide la escritura, la denuncia (corregido).
- **Incidente 13.** El conteo de la preparación no cuadraba con el ticket; las pruebas de V3 de F11
  pasan a `objectContaining` para no romperse con el arreglo.
- **Forenses.** Salidas de `grep` corregidas en F4, F6 (el patrón no encontraba nada), F8, F10 y
  F11; el `EADDRINUSE` real de Stubby sale por el 7443; la pieza de F11 rehecha (Jest aísla los
  archivos: «toqué el de al lado» era una pista falsa); y **«Canvas is already in use» no existe en
  chart.js 2.9.4** —es de la 3—, corregido en F7, `forense-master`, `forense-fase-07` y el cuaderno,
  igual que el monitor de tamaño de chart.js 2 (no hay listener en `window`).
- **Prerrequisitos del cuaderno.** Inyector de caos, `mock:reset` y plugin de pruebas: declarados en
  el cuaderno, en «Cómo se trabaja un incidente».

**Sin verificar en V4:** los pasos forenses que se miran en Vue DevTools, Network y Memory
(verificación manual del autor).


## 14. 🧭 V5 · las tres rutas (cerrada, 2026-10-15)

**Base de las rutas.** `rutas/base/`: F11 con las anclas `data-testid` de Q0 sembradas sobre las
plantillas reales, la red de regresión de Q0 y `@vue/test-utils` 1.3.6. `rutas/vu0/`: la misma base
con la red de VU0 en lugar de la de Q0. `rutas/nx/`: F11 con las anclas y la red de NX0.

**X0, las tres redes de seguridad:**

| Red | Resultado | Lo que hizo falta |
|---|---|---|
| Q0 | ✅ 9 archivos, 64 pruebas en verde | test-utils 1.3.6 (las pruebas encadenan `setValue().then`, que no existe en la beta del plugin); fábrica explícita en `jest.mock` del contrato |
| VU0 | ✅ 64 pruebas en verde | lo mismo que Q0 |
| NX0 | ✅ 40 pruebas en verde | el guard publicado como `src/router/authGuard.js`; el store de laboratorio con lo que lee la vista de F10; prioridad en el formulario y espera al repintado |

**Hallazgos de V5 (hasta ahora):**

- **H-V5-1, test-utils.** Las redes X0 usan el API de `@vue/test-utils` 1.x estable (`setValue` y
  `trigger` devuelven promesa). El plugin de Vue CLI 3 trae la 1.0.0-beta.29. F11 fija ahora la
  1.3.6; la suite de F11 y las pruebas del cuaderno se repitieron en verde con ella.
- **H-V5-2, el auto-mock de `apiClient`.** Con el babel-jest 23 del plugin, el auto-mock de la
  instancia de axios solo funciona si el servicio se importa antes que el cliente. La prueba de
  contrato de Q0 y VU0 lo importaba al revés y fallaba entera. Pasa a una fábrica explícita.
- **H-V5-3, el botón Reintentar.** Desde F10 la plantilla de `TicketsView` llamaba a
  `loadTickets`, que el refactor elimina. F10 dice ahora que ese botón pasa a `fetchTickets()`.
- **H-V5-4, NX0.** Su prueba del guard importaba un `@/router/authGuard` que nadie crea (el ejercicio
  19 de F11); su store de laboratorio no tenía lo que la vista lee; y su prueba de formulario no
  rellenaba la prioridad obligatoria. Corregido en NX0.
- **H-V5-5, Quasar 1 hoy.** `npm i -g @quasar/cli@1` instala la 1.4.0, cuyo `quasar create` ya no crea
  proyectos oficiales. Con la 1.2.2 y `--branch v1` sale un Quasar v1 (`quasar` ^1.0.0 con
  `@quasar/app` ^2.0.0, lo que resuelve H-V0-1). El starter kit v1 no hace las preguntas de la tabla
  de Q1 (no hay icon set, idioma ni modo de build) y su estrategia de import es **auto-import** o
  **todo**: no hay opción manual, y el experimento del `QChip` invisible de Q1 depende de ella.
- **H-V5-6, Vuetify hoy.** `vue add vuetify` instala `vue-cli-plugin-vuetify` 2.5.8 y Vuetify **2.7.2**
  (no 2.6). Los presets se llaman «Vuetify 2 - Configure Vue CLI (advanced)», etc., y aparecen
  opciones de Vuetify 3. Con el preset por defecto, **reemplaza** `App.vue` por la plantilla de
  bienvenida en lugar de envolverlo.
- **H-V5-7, Nuxt hoy.** `npx create-nuxt-app` resuelve la 6.0.0, que envuelve el generador de Nuxt 3
  y no arranca en Node 14. Para Nuxt 2 hay que fijar `create-nuxt-app@3.7.1`.
- **H-V5-8, NX3.** El `fetch()` de la Opción B pasa por `ticketService` → `apiClient`, cuyo
  interceptor de F2 leía `localStorage`: en el servidor, `Error in fetch(): localStorage is not
  defined` y la tabla vacía con HTTP 200. NX2 ahora saca el interceptor de `apiClient`. El módulo de
  F10 necesita `state` como función (`WARN 'state' should be a method…`). `nuxtServerInit` usaba un
  `leerCookie` y un `auth/SET_TOKEN` que no existen: pasa a `this.$cookies` y `auth/SET_SESSION`
  (probado con la cookie: el state serializado trae el token). Nuxt no choca con json-server: avisa
  `Address localhost:3000 is already in use.` y sale por un puerto aleatorio; NX3 lo fija en 8080.
  La Opción B **sí** pinta la tabla en el HTML (no solo en `__NUXT__`) y responde 200 con la API
  caída; el 503 se pone a mano (probado). `this` en `asyncData`: `Cannot read property '$store' of
  undefined`, HTTP 500. `nuxtServerInit` en `store/tickets.js` no corre. Sin `return` en `fetch()`,
  el SSR sale vacío.
- **H-V5-9, NX4.** `ticketService.getById` no existe (es `getTicketById`); faltaban el
  `socketService` y `socket.io-client` en el proyecto Nuxt, y nadie llamaba a `connect()`; el `curl`
  iba al 3000 de json-server. Con eso: `<title>` y `description` en el HTML del servidor (una sola
  `description` gracias a `hid`), 404 de `asyncData` para `/tickets/999` («Ticket no encontrado») y
  de `validate()` para `/tickets/abc` sin tocar la API, relé de `activity:created` entre dos clientes,
  y build + `nuxt start` en producción.
- **H-V5-10, Quasar 1 con la lista a mano.** La lista de `framework.components` (`all: false`)
  solo existe con `@quasar/app` 1.x: el 2.x acepta `importStrategy` `auto` o `all` y convierte
  cualquier otro valor en `auto`; desde su 2.4 exige Vue `^2.7.1`. El kit `--branch app-v1`
  pregunta por *Manually specify what to import* y genera la lista **idéntica** a la de Q1 4.4:
  `quasar` 1.22.10, `@quasar/app` 1.9.6, Vue **2.6.11**, `core-js` 2.6.12. Comprobado ahí: sin
  `QChip` en la lista queda `<q-chip>` crudo **con su texto visible**; en desarrollo sale
  `[Vue warn]: Unknown custom element: <q-chip>`, en producción nada; `quasar dev` **relee**
  `quasar.conf.js` (`App changes detected. Updating app...`) y el chip aparece sin reiniciar; un
  nombre mal escrito tumba el build (`Unknown import from Quasar: Qselect`); sin el plugin,
  `this.$q.notify is not a function` (`$q` existe). `@quasar/cli@1` (1.4.0): «This command is now
  reserved only for scaffolding with CUSTOM starter kits or legacy v0.x projects.»; `@quasar/cli` a
  secas es la 5.0.9 (Node ≥ 20.20). El preset ESLint Standard tumba el build de la Tiquetera
  trasladada (decenas de errores por archivo): el andamio va sin ESLint.
- **H-V5-11, Q2.** El traslado del tronco a Quasar (dependencias, boot files, store como fábrica,
  rutas bajo `MainLayout`, Jest con `setup-quasar.js` y Babel en entorno `test`) deja la red de Q0 en
  **64/64** antes de migrar. Al sacar vuelidate se cae el build en los **pasos del wizard de F6**
  (no en el login, que nunca usó `$v`) y la suite del formulario por su `import`. Rojos reales del
  `QForm`: `setValue` sobre `QSelect`, envío asíncrono, ancla de error y `value` del select (DOM y
  tiempo) y el botón sin `disabled` (**comportamiento**: `:disable="saving"`). El `resetValidation()`
  en `mounted` no hacía falta y descartaba un submit en el mismo tick: fuera. `QForm` se detiene en
  el primer campo inválido salvo `greedy`. Sin `lazy-rules` o con `ondemand` la red sigue verde. El
  wizard migrado con `validate()` asíncrono y `next()` que espera la promesa: probado.
- **H-V5-12, Q3 y Q4.** `QTable` de Quasar 1 recibe las filas por `:data` (`:rows` es Quasar 2:
  "No data available"). La vista publicada no llevaba las anclas de Q0, ni reintentar, contador,
  limpiar o clic a detalle; su `onSaved` no guardaba; el modal pedía jQuery sin cargarlo. Rehecha:
  la red de Q0 sale 64/64 con dos ajustes (stub de `q-page` —`QPage` sin `QLayout` da `Cannot read
  property 'header' of undefined`— y el `elegir()` del filtro). Medido: el filtro objeto vuelve a la
  página 1; `.sync` contra un computed sin setter **no** es el error de Vuex sino `Computed property
  … has no setter` con la tabla clavada; `rowsNumber: 0` ya es modo servidor; json-server manda
  `X-Total-Count` y `Access-Control-Expose-Headers`; sin `QTd`, el contenido sale fuera de la celda
  con `Unknown custom element`; el menú de Quasar (6000) va sobre el modal de Bootstrap (1050). Q4:
  timeline, filtro del socket, `off` simétrico y dos eventos por PATCH, en verde; sin
  `QTimelineEntry`, contenido crudo y warning (no "vacía").
- **H-V5-13, ruta VU.** El proyecto de la ruta se rehízo con la red de VU0 (`mountView`) y `<v-app>`
  en `App.vue`. VU2: build roto por el wizard (no por el login); `mountView` con `Vue.use(Vuetify)`,
  `vuetify: new Vuetify()` y un `div[data-app]`; 16/18 a la primera y dos confesiones de DOM; el
  wizard migrado sin tocar `next()` (`validate()` síncrono). VU3: la vista con las anclas de VU0, el
  filtro de estado y los diálogos de VU2 pasa **14/14 sin tocar la prueba**. Medido: `sort-by`
  string funciona, `options.sortBy` string da `TypeError: this.options.sortBy.findIndex is not a
  function`, `align: "left"` pone `text-left`, `.sync` sin setter mueve la tabla y deja el store
  atrás, `server-items-length` emite `update:options` al montar y no ordena solo. Sin `<v-app>`: el
  diálogo abre en su sitio con `[Vuetify] Unable to locate target [data-app]` (también en
  producción), el tema no pinta (sus reglas cuelgan de `.v-application`) y el modo oscuro no llega a
  los componentes (`theme--light`).

**Cierre de V5.** Redes 64/64 en Q y VU, builds en verde en las tres rutas, SSR por `curl` en NX.
Instantáneas en `salidas/rutas/`. Queda a mano lo visual: z-index, modo oscuro (actos 1 y 2 de
VU4), layout de la convivencia Bootstrap + Quasar, y el tiempo real en dos pestañas.

## 15. 🍃 V6 · Curso 02, F0–F9 (cerrada, 2026-10-15)

**Laboratorio.** Red `v6net`, `curso-mongo-v6` (`mongo:4.4`, sin puertos publicados) y
`curso-mongo-rs` (replica set de un nodo, para F6). Cliente `mongosh` 2.x desde la imagen local
`mongo` 8.0.20 (solo como cliente) y el shell clásico `mongo` de la imagen 4.4. Backend de pruebas
en `backend/tiquetera-backend/` (Node 14.21.3, `mongodb@3.6.12`), con `scripts/generate.js` y
`scripts/seed-antipattern.js` publicados en F1 y F3.

**Autopsia de referencia (F8)**, Apple M1 Pro, Docker con 8 CPU, 2026-10-15; 100 corridas,
promedio / p95 en ms; migración v1→v2 del lado del servidor en 56,4 s:

| Operación | v1 crudo | v1 indexado | v2 |
|---|---|---|---|
| Dashboard (20 legibles) | 22,7 / 24 | 2,4 / 4 | 0,5 / 1 |
| Detalle completo | 143,7 / 149 | 3,8 / 3 | 0,8 / 1 |
| Búsqueda `?q=` (prefijo) | 23,0 / 25 | 0,4 / 1 | 0,5 / 1 |
| Transversal (actividad de un agente) | 69,1 / 74 | 3,9 / 5 | 0,5 / 1 |
| Transición de estado | 0,7 / 1 | 0,6 / 1 | 0,4 / 1 |
| Disco + índices | 35,1 MB | 46,2 MB | 33,6 MB |

**Hallazgos (H-V6).** El seed real es 3/3/1. Los dos generadores que el curso citaba no
existían. En 4.4 `errInfo` llega vacío. `bsonType: "int"` acepta el `3` de `mongosh` y del driver
y rechaza el del shell clásico. El seed con `dropDatabase()` borra el validator. La transacción en
standalone dice *does not support retryable writes*. La regex flotante con índice examina 100k
claves y es más lenta que el COLLSCAN. 4.4 adelanta el `$match` antes del `$lookup` solo. `$round`
redondea al par. Detalle en la bitácora del plan.

## 16. 🚀 V7 · Curso 02, F10–F15, apéndices y cuaderno (cerrada, 2026-10-15)

**Backend de prueba.** `backend/tiquetera-backend/src/`: lo publicado en F10–F13 más la unión
mínima marcada `[unión de V7]` (config, rutas, servicios de users y comments, el `makeService` del
ejercicio 8 de F13). Instantáneas en `salidas/backend-f10.tgz` y `salidas/backend-f13.tgz`.

**La promesa del `baseURL`.** `scripts/diferencial.js`: las 12 llamadas que hace el frontend
(`ticketService`, `commentService`, `userService`, 404 y ruta inexistente) contra json-server 0.16.3
y contra Express sobre el mismo `db.json`; mismo status y misma forma en las 12 (los ids pasan de
número a string hex, la diferencia declarada en el audit). El diff del frontend es de cero líneas: el
Express de F10 escucha en el `:3000` de json-server.

**Pruebas.** Jest 26.6.3 + supertest 6.1.6 + mongodb-memory-server 6.9.6 (binario 4.4.18): 3
suites, 6 pruebas en verde con `--platform linux/amd64` (en arm64 no hay binario 4.4 para Debian).
Cuaderno: `incidentes/cuaderno02.js` (02, 04, 06, 08 rojo → verde) más las mediciones de los demás.

**Hallazgos (H-V7)** en la bitácora del plan: login inyectable por `username`, multer en 500,
`getUri()` como promesa, default 4.0.14 de mongodb-memory-server, `?replicaSet` con el RS en
`localhost`, el choque de puertos que es de Docker, `mongosh` ausente en `mongo:4.4`, el `$lookup`
sin índice como causa real del incidente 05.

## 17. 🔗 R4 · URL, versiones y libros (cerrada, 2026-10-15)

Todo en `r4/`. `urls.json` tiene las URL únicas extraídas de lo publicado. `verificar_urls.py` sigue las
redirecciones a mano: una que cae en la portada cuenta como rota. `resultado-primera-pasada.json`
guarda la corrida inicial y `resultado.json` la de después de corregir. `reemplazos.json` lista las 131
redirecciones cambiadas por su destino final. `youtube.py` y `youtube.json` confirman título y canal
por oEmbed. `versiones.txt` y `versiones-npm.txt` cruzan cada `paquete@versión` de las fases con el
registro de npm, y el resultado está en `resultado-versiones.txt` (46 de 46 existen). Lo que queda sin
200 es antibot (403 de npm, O'Reilly y CACM, confirmados por registro o archive.org) y un 429 de
GitHub que antes había dado 200. F13 fija ahora las versiones probadas con `--save-exact`. El detalle
está en el registro del plan de edición.

## 18. 🔍 K1–K6 · revisión de código (cerrada, 2026-10-16)

Todo en `k/`. Las herramientas son estas:

- `extraer-bloques.py`: saca los bloques de código con archivo, línea y lenguaje, y con `--conteo` rehace el inventario del plan (13.415 líneas en 1.230 bloques).
- `comparar.py`: busca cada línea de cada fragmento en la instantánea de su fase. Con `--sin-comentarios` ignora los comentarios al final de línea y la diferencia entre comillas simples y dobles; con `--lineas` acota el rango del documento.
- `correr.sh` y `correr-ruta.sh`: build, lint y suites en `node:14.21.3`, con los `node_modules` de otro repo montados.
- `ids-espanol.py`: identificadores en español (guía §5). Lee también los valores de `v-model`, `:prop` y `@evento`.
- `ejercicios-ids.py` (guía §10) y `sintaxis.py` (`node --check` con envolturas).

El lint usa ESLint 5.16.0 con `eslint-plugin-vue` 5.2.3, las versiones que deja el `vue create` de F0.

Con lo que corrió en K se rehicieron las instantáneas:

- `salidas/fases/` F0–F3 y F7–F11: `PageTitle` publicado y script `lint`.
- `salidas/backend-k6.tgz`: F11 integrado, `server.js` de F12, Dockerfile y compose.

Las pruebas propias de K, que no se publican, son estas:

- `rutas/q|vu/…/tests/unit/k-x4-detalle.spec.js`: el timeline en el detalle y dos eventos por PATCH.
- `k/inc09` y `k/inc07`: el parche del 09 y el mixin del 07.
- `backend/…/scripts/k6-f11.js` y `k6-f10-paginas.js`.
- `k/f14/`: el compose levantado con puertos en `127.0.0.1` aleatorios y etiquetas del curso. El proyecto `k6f14` ya se bajó y su imagen se borró.

Corridas, con su resultado:

| Corrida | Resultado |
|---|---|
| Redes X0 (`base`, `vu0`) | 64/64 |
| Q y VU | 66/66 |
| NX0 | 40/40 |
| Nuxt | 1/1 y build |
| F11 (tronco) | 26/26 |
| Integración Q4 y VU4 | GET y POST `/activity` y el relé |
| F11 (backend) contra `curso-mongo-v7` | 401, 403, 422, 200 y 409, `reporter` y `by` del token |
| Incidente 08 con `soporte_v1` | 59.495 en `null`, `fix-08` en 23 s |
| Incidente 02 | `fix-dates` y `audit-types`, idempotentes |

El detalle de cada hallazgo y de su decisión está en la fila K1–K6 del registro del plan de edición.

Las suites de F13 se corrieron el 18/10 con emulación (`docker run --platform linux/amd64 node:14.21.3 node node_modules/.bin/jest --runInBand`): 3 suites, 6/6 en verde sobre el backend de K6. Jest no terminaba ("Jest did not exit one second after the test run has completed"), porque F13 pide cerrar el cliente en `afterAll` y el `db.js` de F10 no exportaba con qué. Se agregó `close()` a `db.js` (F10, lección y código) y `afterAll(close)` a `tickets.routes.test.js` (F13, lección y código). Con eso la corrida termina sola en ~7 s.

La imagen `node:14.21.3-alpine`, base del Dockerfile de A01, se descargó en K6 y se dejó para repetir la prueba.

## 19. 🏁 C y E9 · cierre y preparación para publicar (2026-10-18)

**F13 en amd64 (K6, 18/10).** `docker run --rm --platform linux/amd64 --label curso=vue2-legacy --label tanda=K6-f13 -v "$PWD":/app -w /app node:14.21.3 node node_modules/.bin/jest --runInBand --ci` desde `backend/tiquetera-backend`: 3 suites, 6/6. Jest no terminaba hasta que `db.js` exportó `close()` y la prueba HTTP lo llamó en `afterAll` (corregido en F10 y F13).

**E8, revisión total.** Verificador del paquete en los dos modos, antes y después: `salidas/c-verif-courses.txt`, `salidas/c-verif-pub.txt` y, con el verificador base y `--perfil=publicacion`, `salidas/c-verif-base-pub.txt` (sus 1 `FUERA` y 4 `ROTO` estaban en desechables, ya borrados). Hallazgos corregidos:

- README del Curso 01: 911 ejercicios → **915** (suma de los títulos `## 🧪 Ejercicios (N)`: tronco 315, apéndices 184, rutas 416). El del Curso 02, 695, cuadra (F10 se titula «37 + 🔥» y un conteo ingenuo lo pierde).
- README del Curso 02: el arco del curso seguía en ASCII (R3 no lo había convertido) → Mermaid, exportado sin error en `salidas/diagramas-c-readme-02/`; la tabla de stack con las versiones que corrieron (Mongoose 5.13.20, Express 4.17.1, socket.io 2.4.1, Jest 26.6.3, supertest 6.1.6, mms 6.9.6).
- README raíz: «una sola línea» → «a lo sumo una línea» (la prueba diferencial de V7 dio cero líneas con Express en el `:3000`).
- Los tres README y `0-ESTRUCTURA-CURSO.md` dicen ahora qué se corrió, con qué y qué queda a mano.
- `preparaciones-de-incidentes.md`: la fila 08 del Curso 02 seguía en la versión de V7 (20.000 tickets, mapa desde 0); alineada con el incidente rehecho en K6.
- Dato personal: el usuario del autor aparecía en dos salidas de `lsof` (forenses 00 y 12 del Curso 02) → `dev`.

**Pendiente de §6 del plan.** *Cuadre Software* no aparece como empresa (búsqueda web del 18/10). *La Tiquetera* sí: es una boletera de eventos de Medellín, fundada en 2014. No es una mesa de soporte, pero está en la misma área metropolitana que el Itagüí de la ficha. El README del paquete declara ahora la ficción, y renombrar queda a decisión del autor (guía §17.4).

**E9.** `LICENSE.md` (CC BY-SA 4.0, como NoSQL Lite) y `.gitignore` (sistema operativo, editores, `node_modules/`) en la raíz del paquete. Sin secretos, tokens ni correos en lo publicado (`grep` de credenciales, JWT y correos sin resultados); los secretos de los ejemplos son de demostración y salen de variables de entorno.

**Borrado.** Los diez `_desechable-*` de `prompts/`, archivo por archivo con `rm`, el plan de edición el último. Sus menciones se limpiaron en la guía (§13.1, §13.3, §17, §17.2), en `prompts/README.md` y en `instrucciones-proyecto-track-b.md`.

**limpiar.py.** Vista previa en `salidas/c-limpiar-vista-previa.txt`: 6 GB regenerables en 42 directorios (`node_modules`, `dist`, `.nuxt`, `coverage`) de los 9 GB del directorio. El `--borrar` lo da el autor.
