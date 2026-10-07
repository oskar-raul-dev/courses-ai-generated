# 🗓️ Plan de producción: pendientes de validación y ejecución
## Paquete Tiquetera — Curso 01 (Vue 2 legacy) + Curso 02 (MongoDB/Express)

> ✏️ **Desechable excepcional.** Este paquete se escribió antes del método de tandas de
> `zz-instrucciones/` y **su código nunca se ha ejecutado**: el rescate de
> `zz-code/vue2-legacy-for-backend-devs-20261006-c6c0/` lo dice textual ("no hay corridas del
> código del curso"). Este plan reúne lo que falta para poder decir que el paquete está listo
> para su uso: la **validación por ejecución** (tandas `V`), la **revisión contra
> `zz-instrucciones/`** (tandas `R`) y los pendientes sueltos (§6). Usa el formato de la plantilla
> `zz-instrucciones/plantillas/plan-de-produccion.md`, recortado a lo que aplica.
>
> **No se cita desde ninguna fase, apéndice ni README.** Se borra (con permiso del autor) cuando
> las tandas cierren y su resultado quede en la guía.
>
> **Vigencia:** 2026-10-06. **Estado:** sin empezar; se hará en sesiones futuras.
>
> El trabajo narrativo anterior (la historia de la Tiquetera llevada a los dos cursos, T0–T7) está
> cerrado y registrado en [`_desechable-plan-tiquetera.md`](_desechable-plan-tiquetera.md).

**Cualquier sesión que retome este plan empieza leyendo §3 (estado), §6 (pendientes), §7
(bitácora) y §8 (checklist).**

---

## 1. 🧭 Las reglas

1. **Una tanda por sesión, en orden, en el hilo principal y sin agentes.** Al cerrar cada una se
   actualizan §3 y §7 y se para hasta que el autor diga.
2. **Se ejecuta lo que el lector ejecuta**, copiado del documento tal cual: comandos, archivos y
   pasos. Lo que no está escrito no se inventa para que funcione; si hace falta, es un hallazgo.
3. **El error se anota literal antes de arreglarlo**, con el archivo y la línea del documento que
   lo produjo.
4. **La fase gana, salvo que esté mal.** Si la salida real difiere de la publicada, se corrige la
   fase con la salida real. Ninguna salida se reconstruye de memoria: lo que no se pueda ejecutar
   se marca en la fase como «no verificado por ejecución» y queda ⬜ en §3.
5. **Todo corre en contenedores, nunca en el host.** Imágenes oficiales con la versión congelada
   del curso, etiqueta `--label curso=vue2-legacy`, **puertos altos y aleatorios** ligados a
   `127.0.0.1` (`-p 127.0.0.1::8080`, leído con `docker port`). El curso publica 8080, 3000, 4000 y
   27017; la prueba no los usa en el host.
6. **Inventario de Docker al empezar cada sesión**, a un log; al cerrar se borra solo lo creado
   (`docker rm -v`, `docker compose down -v`), comparando contra el inventario. Nada de `prune`, y
   nada ajeno al curso se toca.
7. **Todo el código va a `zz-code/`**: un directorio por sesión
   (`python3 zz-code/nuevo.py vue2-legacy-for-backend-devs`), registrado en §9, con su `README.md`
   de corrida y medición. Ahí vive el repo del "alumno" que se construye fase a fase, con sus tags
   `fase-…`, y lo efímero en `salidas/`. Ningún documento del curso cita `zz-code/`.
8. **Git del curso lo hace el autor.** Se borra con `rm`, nunca con `git rm`. Los tags del repo de
   prueba en `zz-code/` sí los crea la sesión, porque son parte de lo que se valida.
9. **La máquina del autor no se toca sin permiso**: nada se instala en el host.

---

## 2. 🧩 Qué es una tanda

Una tanda está cerrada cuando:

- cada fase de su alcance se corrió entera en contenedor, con sus comandos copiados del documento;
- cada salida publicada coincide con la real, o la fase se corrigió con la real;
- lo que no se pudo correr quedó marcado en la fase y en §3;
- los hallazgos que no se resolvieron quedaron en §6;
- la bitácora (§7) tiene la entrada de la sesión, con versiones de imagen y fecha.

---

## 3. 📊 Estado

| Tanda | Alcance | Escrita | Corrida | Estado |
|---|---|---|---|---|
| V0 | Ambiente: imágenes, arquitectura, versiones congeladas | ✅ | ⬜ | ⬜ sin empezar |
| V1 | Curso 01 · F0–F3 (setup, base, auth, mock) | ✅ | ⬜ | ⬜ |
| V2 | Curso 01 · F4–F7 (dashboard, CRUD, wizard, métricas **con la tabla de puntajes nueva**) | ✅ | ⬜ | ⬜ |
| V3 | Curso 01 · F8–F11 (sockets, panel, Vuex, testing) | ✅ | ⬜ | ⬜ |
| V4 | Curso 01 · cuaderno de incidentes (13) y piezas forenses del tronco | ✅ | ⬜ | ⬜ |
| V5 | Curso 01 · rutas Q, VU y NX (X0–X4 cada una) | ✅ | ⬜ | ⬜ |
| V6 | Curso 02 · F0–F9 (Mongo 4.4, modelo, `soporte_v1`, autopsia, aggregation **con el opcional de puntajes**) | ✅ | ⬜ | ⬜ |
| V7 | Curso 02 · F10–F15 y apéndices (Express, el `baseURL` que cambia, auth, sockets, testing, operación) | ✅ | ⬜ | ⬜ |
| R1 | Verificador del paquete (`prompts/verificar-corpus.py` adaptado de la plantilla) | ⬜ | ⬜ | ⬜ |
| R2 | Revisión contra `zz-instrucciones/`: guía, Mermaid, bandas, callouts | — | — | ⬜ |
| C | Cierre: resultado en la guía, borrar este plan con permiso | — | — | ⬜ |

---

## 4. 🔎 Las verificaciones

- **Por fase:** los comandos del documento, en orden, en el contenedor; la salida real contra la
  publicada; las pruebas de la fase en verde donde las haya.
- **Por tanda:** el repo de prueba con el tag de la última fase de la tanda, y la suite completa
  hasta ahí (`npm run test:unit` en el Curso 01; Jest + supertest en el Curso 02).
- **La promesa del paquete (V7):** se cambia el `baseURL` del frontend y la aplicación no se
  entera. Se prueba con el checklist de smoke de `00-audit-contrato.md` y el frontend de V3 sin
  tocar.
- **Desde R1:** `python3 prompts/verificar-corpus.py` en cero al cerrar cada tanda.

---

## 5. 🧱 Las tandas, una por una

### V0 — Ambiente

- Comprobar que existen y corren las imágenes de la época: `node:14.21.3` (y `node:16.20.2`, la
  alternativa de Apple Silicon de F0), `mongo:4.4`, y lo que pidan Quasar CLI 1, Vue CLI 4 y
  Nuxt 2. La máquina del autor es arm64: anotar qué imagen tiene variante `linux/arm64` y cuál
  necesita `--platform linux/amd64` (emulación, que cambia tiempos y algunos mensajes).
- Comprobar que el registro de npm sigue sirviendo las versiones congeladas: `vue@2.6.14`,
  `vuex@3`, `vue-router@3`, `bootstrap@4.6.2`, `jquery@3.6.0`, `axios@0.21.1`,
  `json-server@0.16.3`, `chart.js@2.9.4`, `vuelidate@0.7.7`, `socket.io@2.4.1`, `mongodb@3.6`.
- Decidir cómo se validan las piezas que se miran en el navegador (Vue DevTools, Network, Memory):
  a mano en el navegador del autor contra el contenedor, anotadas como «verificado a mano».

### V1–V3 — Tronco del Curso 01

- Construir el repo del alumno de F0 a F11 copiando cada fase.
- **Atención especial en V2:** la tabla de puntajes de F7 es código escrito el 2026-10-06 y nunca
  corrido (`initialsOf`, `scoreBoard`, `ScoreBoard.vue`, la carga de `/users` en `MetricsView`).
  Comprobar que `_.keyBy`, `_.groupBy` y `_.sumBy` existen en la versión de lodash que instala F0, y
  que la clase `text-monospace` existe en Bootstrap 4.6.2.
- En V3, que la prueba de F11 cubra `ticketStats.js` con las funciones nuevas.

### V4 — Cuaderno y forense del Curso 01

- Preparar cada incidente con su forma declarada (flag del inyector, `db.json` alterno o rama).
- **Incidente 13 es nuevo:** armar `mock/db.incidente-13.json` desde su descripción y comprobar
  que reproduce las dos `LMC` sumadas y la fila `???`; correr su prueba de regresión.

### V5 — Rutas

- Una pasada por ruta, sobre el tag `fase-11` del repo de V3: Q (Quasar 1.22), VU (Vuetify 2.6) y
  NX (Nuxt 2). Comprobar que los X0 se pueden escribir con el estado de F11 y que los X2–X4 corren.
- Comprobar que lo que dicen `q00-`, `vu00-` y `nx00-historia-ruta-*.md` del estado de cada rama no
  contradice lo que X1–X4 asumen (regla 4 de la guía §13.4).

### V6–V7 — Curso 02

- Mongo 4.4 en contenedor, seed del `db.json` heredado (con las referencias rotas a `jpmesa`,
  `cvelez` y `mrestrepo`), el generador de 100k y `soporte_v1`, la autopsia con sus mediciones.
- El opcional de la F9 sobre la tabla de puntajes (pipeline por username, usuarios borrados,
  tasa de reapertura con `history`), y el ejercicio 33 de la F4 (el NIT en el título).
- La promesa del paquete con el frontend de V3 (§4).

### R1 — Verificador

- Copiar `zz-instrucciones/herramientas/verificador_base.py` y `verificar-corpus.py` a `prompts/`
  y adaptar la subclase a esta guía: callouts de §8, plantilla de 9 secciones de §9, banda de
  ejercicios de §10, nomenclatura de §13.2 (incluidas las historias de ruta y el `prompts/` único).
- Correrlo y llevar el corpus a cero.

### R2 — Revisión contra `zz-instrucciones/`

- Lo que se revisó en React 16, Angular y docker-container-legacy: la guía frente a la plantilla
  vigente, los diagramas en Mermaid, las bandas, el apartado de verificación de la guía.
- Registrar en la guía las divergencias que se mantengan, con su razón (como §13.3).

---

## 6. 📌 Pendientes sueltos

- **Código nuevo sin correr** (2026-10-06): F7 (tabla de puntajes), el incidente 13 y su prueba,
  el 🔥 opcional de puntajes de la F9 del Curso 02, el ejercicio 33 de la F4 del Curso 02. Entra en
  V2, V4 y V6.
- **Los archivos `db.incidente-NN.json` no vienen hechos:** el alumno los arma desde la descripción
  de cada incidente. Decidir en V4 si se mantiene así o si se publican.
- **El ejemplo de NIT en el título** solo aparece en el recuadro de F3 y en el ejercicio 33: los
  títulos del `db.json` de F3 no lo usan. Decidir si algún ticket de la semilla debe llevarlo, sabiendo
  que esos títulos los usan pruebas y búsquedas en más de 15 lugares.
- **Los `_desechable-` de `prompts/`** (guía superada del Track B, plan descartado, prompts de
  revisión, traducción del código, plan de la historia): confirmar con el autor si se conservan o se
  borran al cerrar este plan.
- **Mermaid:** el paquete usa diagramas ASCII (grafo de rutas, flujos de las fases). R2 decide cuáles
  pasan a Mermaid según la guía vigente de `zz-instrucciones/`.

---

## 7. 📓 Bitácora

| Fecha | Tanda | Qué se hizo | Imágenes y versiones | Resultado |
|---|---|---|---|---|
| 2026-10-06 | — | Plan creado al cerrar la historia de la Tiquetera | — | — |

---

## 8. ✅ Checklist final

- [ ] V0–V7 cerradas, con cada fase corrida o marcada «no verificado por ejecución».
- [ ] La promesa del `baseURL` probada en V7.
- [ ] El verificador del paquete en cero.
- [ ] La revisión contra `zz-instrucciones/` registrada en la guía.
- [ ] Los pendientes de §6 resueltos o pasados a la guía con su razón.
- [ ] El resultado de la validación anotado en la guía (qué se corrió, con qué y cuándo).
- [ ] Este plan borrado, con permiso del autor.

---

## 9. 🗂️ Directorios de `zz-code/`

| Directorio | Tanda | Estado | Qué tiene |
|---|---|---|---|
| `vue2-legacy-for-backend-devs-20261006-c6c0` | — | archivado | Rescate de las verificaciones del corpus de 2026-09; sin corridas del código del curso |
