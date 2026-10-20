# 🗓️ Plan de edición: cerrar el paquete Tiquetera
## Paquete Tiquetera — Curso 01 (Vue 2 legacy) + Curso 02 (MongoDB/Express)

Este documento dice **qué falta para declarar cerrado el paquete, en qué orden y cuándo una tanda
está terminada**. Los dos cursos están escritos completos (Curso 01: 12 fases, 5 apéndices, 3 rutas
de 5 fases con su historia, 15 piezas forenses y 13 incidentes; Curso 02: 16 fases, 5 apéndices, 12
piezas forenses y 12 incidentes), y la historia de la Tiquetera ya está llevada a los dos (T0–T7 de
[`_desechable-plan-tiquetera.md`](_desechable-plan-tiquetera.md)). Lo que falta es de cuatro clases:

- **Alinear con `zz-instrucciones/`**: la guía no declara sus excepciones, no hay verificador ni
  `prompts/README.md`, y los documentos publicados citan `prompts/` 68 veces.
- **Validar por ejecución**: el código del paquete **nunca se ha ejecutado**.
- **Revisar el código**: que cada fragmento publicado sea el que corrió y siga la guía (tandas K).
- **Cerrar**: E8 (revisión total, README con el estado real, `zz-code/` cerrado, `_desechable-*`
  borrados) y, si el autor lo decide, E9.

Es un **plan de edición** y no un plan de producción, con el mismo criterio que el de Angular 16:
el paquete existe y no cambia de estructura, y la plantilla completa sobraría. **Absorbe**
[`_desechable-plan-de-produccion.md`](_desechable-plan-de-produccion.md) (2026-10-06): sus tandas
V0–V7, R1 y R2 y sus pendientes de §6 están aquí, renumerados donde hizo falta. Desde ahora manda
este plan; aquel se borra en la tanda C.

- **El qué** lo mandan la ficha [`../00-historia-del-sistema.md`](../00-historia-del-sistema.md) y
  el contrato [`../02-complement-mongodb-backend/00-audit-contrato.md`](../02-complement-mongodb-backend/00-audit-contrato.md).
- **La forma**, [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md) y sus anexos
  (§13.1).
- **El método**, `zz-instrucciones/` (workflow §2, tipo legacy en `01-tipos-de-curso.md` §3, E8 y E9
  en `02-prompts-de-etapa.md`, y `03-lecciones-de-produccion.md`).
- **El orden**, este documento.

> **Caducidad:** desechable. **No se cita desde ninguna fase, apéndice ni README.** Al cerrar la
> tanda C se borra con permiso del autor; lo que deba sobrevivir pasa a la guía (§17).
>
> **Vigencia:** 2026-10-15. **Estado:** P1, R1–R4, V0–V7 y K1–K6 cerradas (la comprobación en navegador de F0–F11 y de
> lo visual de las rutas —z-index, modo oscuro, layout— queda como verificación manual del autor). **Cerrado el 2026-10-18** (C y E9).

**Salto rápido:** [0](#0--cómo-se-retoma) · [1](#1--decisiones) · [2](#2--reglas-de-orden) · [3](#3--estado) · [4](#4--inventario) · [5](#5--las-tandas) · [6](#6--hechos-por-verificar) · [7](#7--bitácora) · [8](#8--checklist-final) · [9](#9-️-directorios-de-zz-code)

---

## 0. 🚪 Cómo se retoma

Cada sesión lee, en este orden: este plan (§1, §2, §3 y §7), la guía (§13 y, desde R1, §17),
`zz-instrucciones/README.md` y `zz-instrucciones/03-lecciones-de-produccion.md`. Las tandas V leen
además las fases de su alcance. Después abre **una** tanda de §5 y aplica el protocolo de tres pasos
de `zz-instrucciones/00-workflow-de-un-curso.md` §2: preguntas sin redactar, redacción,
autoverificación contra la guía §15. Al cerrar, actualiza §3, §7, §8 y §9.

Prompt para pegar al abrir la sesión (cambiando `R1` por la tanda que toque):

```text
Paquete: cursos-legacy/vue2-legacy-for-backend-devs. Vamos a ejecutar la tanda R1 del plan
prompts/_desechable-plan-de-edicion.md. Lee el plan (§0–§3 y §7), la guía (§13 y §17 si existe),
zz-instrucciones/README.md y zz-instrucciones/03-lecciones-de-produccion.md.
Las decisiones de §1 marcadas ✅ están cerradas: no las reabras; si una no se sostiene, para y
pregunta. Paso 1: dime qué vas a tocar y tus preguntas, sin redactar. Sin agentes, git lo hago yo,
pruebas en contenedor y código en zz-code/. Al cerrar, actualiza §3, §7, §8 y §9 del plan.
```

---

## 1. 🧭 Decisiones

Cerradas el 2026-10-14 por defecto: el autor dijo «todo default». Cada una trae su opción recomendada
primero, y es la que rige.

### 1.1 Lo que toca el contenido publicado

- **D1 — Los datos que propuso Claude en la ficha.** Quedaron sin confirmar el 06/10: el nombre
  *Tiquetera*, las dos Lauras `LMC` (la segunda entra en 2022), Valentina Ospina (2020–2022), Mongo
  abierto sin contraseña un año, las cifras (~80 → ~250 → ~400 comercios; ~30.000 tickets) y el
  preventista de la cervecería. **(a) Se confirman tal como están** · (b) el autor cambia los que no
  le sirvan, y la tanda R2 los propaga.
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).
- **D2 — La convención de git, que los publicados enlazan 53 veces dentro de `prompts/`.** Cada fase
  la cita desde su bloque 🏷️, así que el lector la necesita, y `prompts/` no viaja (E9).
  **(a) Pasa a la raíz del paquete como `00-convencion-de-git-y-tags.md`**, material publicado como
  la ficha, igual que en React 16; los 53 enlaces se reescriben · (b) se queda en `prompts/` y cada
  bloque 🏷️ lleva lo mínimo en prosa (más largo, y se pierde el detalle de los pares `-roto`/`-fix`).
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).
- **D3 — Las demás citas a `prompts/` (15).** `formato-piezas-forenses` (5), la guía (3),
  `diccionario-codigo` (2), `instrucciones-proyecto-track-b` (2), `plantilla-de-fase` (1),
  `formato-cuaderno-incidentes` (1), y la mención a `_desechable-` en el README del Curso 02 (línea
  ~45). **(a) Se pasan a prosa con lo que el lector necesita saber**, y el README del paquete conserva
  una línea sin enlace ("el material de autoría vive aparte") · (b) se quitan sin reemplazo.
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).
- **D4 — Diagramas (`D-12`).** El paquete no tiene ningún bloque Mermaid; los dibujos son ASCII
  (los más cargados: `q1`, `nx1`, `q2`, `q0`, `vu0`, `vu4`, `q4`, F05, F04, `0-ESTRUCTURA-CURSO`,
  el README del paquete). **(a) Mermaid para los diagramas de verdad** (flujos, estados, secuencias,
  capas, el grafo de rutas), y en texto los árboles de archivos, las salidas de terminal y de
  DevTools y las correspondencias de una línea, con los criterios de React 16 §17.1 · (b) todo se
  queda en ASCII, declarado · (c) solo el grafo de rutas y los flujos de las fases ⭐.
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).
- **D5 — Ejercicios fuera de la banda de la guía §10.** Los apéndices traen 30–40 ejercicios (la
  guía dice 5–10) y tres fases del Curso 02 pasan de 35 (F09: 36, F10: 37, F12: 38). **(a) Se declara
  lo publicado** (bloqueo de contenido): apéndices de práctica con 30–40, techo de 38 en el Curso 02
  · (b) se recortan los apéndices a 10 y las tres fases a 35.
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).
- **D6 — Incidentes por debajo del tipo legacy.** `01-tipos-de-curso.md` §3 da 15–25 por curso; el
  paquete tiene 13 y 12. **(a) Se declara** (el paquete es de dos cursos: 25 entre los dos) · (b) se
  escriben incidentes nuevos hasta 15 por curso (sale de este plan: sería una tanda de escritura).
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).
- **D7 — Los `mock/db.incidente-NN.json`.** El alumno los arma desde la descripción de cada
  incidente. **(a) Se quedan así, y `prompts/preparaciones-de-incidentes.md` (que el tipo legacy
  pide y no existe) registra cómo se arma cada uno, escrito en V4 y V6 a partir de lo que se corrió**
  · (b) se publican los archivos dentro del cuaderno.
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).
- **D8 — El NIT en el título.** Solo aparece en el recuadro de F3 y en el ejercicio 33 de la F4 del
  Curso 02; la semilla no lo usa, y sus títulos los citan pruebas y búsquedas en más de 15 lugares.
  **(a) Se queda así**, y la guía lo dice · (b) un ticket nuevo de la semilla lo lleva (no se toca
  ninguno de los existentes).
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).

### 1.2 Lo que toca `prompts/` y el cierre

- **D9 — Los documentos de `prompts/` que la plantilla pide y no existen** (alcance, propuestas,
  diccionario de términos, contrato de nombres, plantillas de capítulo, prompts de fase,
  preparaciones). **(a) No se crean a posteriori**: la guía §17.2 dice qué documento hace el papel de
  cada uno, como React 16 §17.2; solo se crean `prompts/README.md` y, por D7,
  `preparaciones-de-incidentes.md` · (b) se crean todos.
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).
- **D10 — El Curso 02 no tiene `0-ESTRUCTURA-CURSO.md`.** **(a) Se declara**: su papel lo hacen el
  README del curso y `instrucciones-proyecto-track-b.md` · (b) se escribe en la tanda C.
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).
- **D11 — Los nueve `_desechable-*` de `prompts/`.** **(a) Se borran todos en la tanda C**, este
  plan incluido; el historial de git los conserva · (b) se conservan la guía superada del Track B y
  los de traducción del código como registro, y se borra el resto.
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).
- **D12 — Publicación (E9).** La ficha y el contrato son de los dos cursos, así que publicarlos por
  separado los parte. **(a) Un solo repositorio público para el paquete**, y la tanda E9 entra en
  este plan · (b) dos repositorios, con la ficha copiada en cada uno · (c) E9 queda fuera de este
  plan: se cierra en E8.
  ✅ Cerrada el 2026-10-14: (a) por defecto (el autor: «todo default»).
- **D13 — La versión de la ruta Q (nueva, de V5).** La lista a mano de `framework.components`,
  eje de Q1–Q4 y del forense, solo existe con `@quasar/app` 1.x; el kit actual (`--branch v1`) da
  `@quasar/app` 2.x con auto-import y, desde su 2.4, Vue 2.7. **(a) Quasar 1.22.10 sobre
  `@quasar/app` 1.9.6** (`--branch app-v1`, Vue 2.6.11, sin ESLint) y la ruta intacta en su eje ·
  (b) `@quasar/app` 2.3.1 (Vue 2.6.14, auto-import) y reescribir la trampa de la lista en Q1–Q4.
  ✅ Tomada el 2026-10-15: (a) por defecto, a confirmar por el autor.

---

## 2. 🧱 Reglas de orden

1. **Las decisiones cerradas no se reabren.** Si una tanda descubre que una no se sostiene, para y
   consulta.
2. **Una tanda por sesión, en orden, en el hilo principal y sin agentes.** Se para al cerrar cada
   una.
3. **Cada tanda deja el paquete coherente hasta donde llega.** Si cambia un nombre, un archivo o un
   dato, cambia en la misma sesión en todos los lugares que lo repiten (fases de los dos cursos,
   forenses, cuadernos, README, `prompts/`).
4. **Se ejecuta lo que el lector ejecuta**, copiado del documento tal cual. Lo que no está escrito no
   se inventa para que funcione: es un hallazgo.
5. **El error se anota literal antes de arreglarlo**, con archivo y línea del documento que lo
   produjo.
6. **La fase gana, salvo que esté mal.** Si la salida real difiere de la publicada, se corrige la
   fase con la real. Lo que no se pueda ejecutar se marca en la fase «no verificado por ejecución» y
   queda ⬜ en §3.
7. **Todo corre en contenedores**, con la versión congelada del curso, `--label curso=vue2-legacy`,
   puertos altos y aleatorios en `127.0.0.1` (`-p 127.0.0.1::8080` y `docker port`). El curso publica
   8080, 3000, 4000 y 27017; las pruebas no los usan en el host.
8. **Inventario de Docker al empezar**, a un log en `zz-code/<id>/salidas/`; al cerrar se borra solo
   lo creado (`docker rm -v`, `docker compose down -v`). Nada de `prune`; nada ajeno se toca.
9. **Todo el código va a `zz-code/`**, un directorio por sesión
   (`python3 zz-code/nuevo.py vue2-legacy-for-backend-devs`), registrado en §9, con su `README.md` de
   corrida escrito mientras se prueba. Ahí vive el repo del alumno que se construye fase a fase, **sin
   commits ni tags** (la sesión no commitea): cada fase deja una instantánea
   `salidas/fases/fase-<slug>.tgz` sin `node_modules`. Si el autor quiere tags, los crea él. Ningún
   documento del paquete cita `zz-code/`.
10. **Git del paquete lo hace el autor.** Nada de `git mv` ni `git rm`; mover con `mv`, borrar con
    `rm`, archivo por archivo. `perl` siempre con `-CSD -Mutf8`, y al cerrar `grep -rl "Ã\|â"` en cero.
11. **Nada se instala en el host.**
12. **El README del paquete y los de cada curso se tocan solo en la tanda C**, salvo los enlaces que
    R2 tiene que reescribir.

---

## 3. 📊 Estado

| Tanda | Alcance | Escrita | Corrida | Estado |
|---|---|---|---|---|
| P1 | Decisiones D1–D12 con el autor | — | — | ✅ 2026-10-14 (todas por defecto) |
| R1 | `prompts/` a los lineamientos: guía §17, `prompts/README.md`, verificador | ✅ | ✅ | ✅ 2026-10-14 |
| R2 | Restos de producción en lo publicado: citas a `prompts/`, convención de git, anclas, callouts | ✅ | ✅ | ✅ 2026-10-14 |
| R3 | Diagramas según D4 | ✅ | ✅ | ✅ 2026-10-14 |
| V0 | Ambiente: imágenes, arquitectura, versiones congeladas | ✅ | ✅ | ✅ 2026-10-14 (hallazgos H-V0-1…5 en el README de zz-code) |
| V1 | Curso 01 · F0–F3 (setup, base, auth, mock) | ✅ | ✅ build y API en contenedor; navegador a mano del autor | ✅ 2026-10-15 (H-V1-2 y H-V1-4 corregidos en el texto; H-V1-3 retirado, era un falso positivo) |
| V2 | Curso 01 · F4–F7 (dashboard, CRUD, wizard, métricas con la tabla de puntajes) | ✅ | ✅ build y API en contenedor; navegador a mano del autor | ✅ 2026-10-15 (H-V2-1 corregido en el árbol de F7; H-V2-2 y H-V2-4 anotados; H-V2-3 retirado) |
| V3 | Curso 01 · F8–F11 (sockets, panel, Vuex, testing) | ✅ | ✅ suite `test:unit` 26/26; broadcast probado | ✅ 2026-10-15 (H-V3-1 a H-V3-8; H-V3-4 a decisión del autor) |
| V4 | Curso 01 · cuaderno (13) y piezas forenses del tronco | ✅ | ✅ 13 incidentes con su prueba roja/verde (el 05, solo la refactorización); salidas de terminal de las 12 forenses | ✅ 2026-10-15 (incidente 05 a decisión del autor; DevTools a mano) |
| V5 | Curso 01 · rutas Q, VU y NX (X0–X4 cada una) | ✅ | ✅ Q: andamio `app-v1` (lista a mano), traslado, red de Q0 64/64 tras Q2 y Q3, Q4 y build; VU: red de VU0 64/64 tras VU2 y VU3 (14/14 sin tocar la prueba), VU4 y build; NX: SSR de NX2–NX4, cookies, 404/503 y `nuxt start` | ✅ 2026-10-15 (lo visual de las rutas, a mano) |
| V6 | Curso 02 · F0–F9 (Mongo 4.4, modelo, `soporte_v1`, autopsia, aggregation con el opcional de puntajes) | ✅ | ✅ seed con sus 3 referencias rotas; `generate.js` y `seed-antipattern.js` escritos y publicados; F2, F4, F6, F7 y F9 corridos; autopsia de referencia medida; 🔥 de puntajes y ej. 33 de F4 viables | ✅ 2026-10-15 |
| V7 | Curso 02 · F10–F15, apéndices, cuaderno (12) y la promesa del `baseURL` | ✅ | ✅ promesa probada por diferencial (12 llamadas del frontend: mismo status y forma que json-server); F11–F14 corridos; Jest + supertest 6/6 en verde; los 12 incidentes con su preparación y su prueba roja/verde | ✅ 2026-10-15 |
| R4 | URL, versiones y libros de las referencias | ✅ | ✅ | ✅ |
| K1 | Revisión de código · Curso 01, F0–F5 y apéndices a1–a5 (~1.920 líneas) | — | ✅ | ✅ 2026-10-16 |
| K2 | Revisión de código · Curso 01, F6–F11 y forenses del tronco (~2.100) | — | ✅ | ✅ 2026-10-16 |
| K3 | Revisión de código · Curso 01, X0 de las tres rutas y cuaderno (~2.110) | — | ✅ | ✅ 2026-10-16 |
| K4 | Revisión de código · Curso 01, ruta Q (Q1–Q4 y su forense) (~1.930) | — | ✅ | ✅ 2026-10-16 |
| K5 | Revisión de código · Curso 01, rutas VU y NX (X1–X4 y sus forenses) (~2.020) | — | ✅ | ✅ 2026-10-16 |
| K6 | Revisión de código · Curso 02 completo (~2.300) | — | ✅ | ✅ 2026-10-16 |
| C | E8: README, revisión total, `zz-code/` cerrado, `_desechable-*` borrados | ✅ | ✅ | ✅ 2026-10-18 |
| E9 | Publicación, solo si D12 = (a) o (b) | ✅ | ✅ | ✅ 2026-10-18 (lista para copiar; la copia la hace el autor) |

**Dependencias.** R1 va primero porque deja el verificador que corre al cerrar todas las demás. R2
y R3 antes de las V, para que la validación corra sobre el texto definitivo. V0 antes de cualquier V;
V1–V3 en orden (cada una parte del estado que dejó la anterior); V4 y V5 parten del estado de F11 que deja V3; V6
puede ir en paralelo a V4–V5, pero V7 necesita el frontend de V3. R4 en cualquier momento después de
R1. Las K van después de todas las V, porque comparan cada fragmento publicado con el repo del
alumno que las V dejaron etiquetado; entre ellas, en orden (K1 escribe las herramientas que las
demás reusan). C al final.

---

## 4. 🔎 Inventario

Medido el 2026-10-07 sobre el paquete, con los comandos que cada línea indica. Los números de línea
son aproximados: se buscan por texto.

- **Verificador base, perfil del repositorio**
  (`python3 zz-instrucciones/herramientas/verificador_base.py cursos-legacy/vue2-legacy-for-backend-devs --perfil=courses-ia`):
  **6 errores y 335 avisos.**
  - 1 `ANCLA-FE0F` en `01-vue2-legacy/0-ESTRUCTURA-CURSO.md:62` (`#-nota-de-producción-…` debe ser
    `#️-nota-de-producción-…`). Es el único error en material publicado.
  - 1 `FUERA` y 4 `ROTO`, todos en `_desechable-*` (se van en C).
  - 254 `EMOJI` en `###` (la guía los usa a propósito: se declara en §17).
  - 29 `ENCAB` sin «Vigencia» en las fases (se declara, como en React 16).
  - 52 `CALLOUT` fuera de la lista del perfil: 🔑 (12) y ⭐ (2) ya están en la guía §8; el resto,
    de uno a nueve usos cada uno (✅ 9, 🧩 4, 📄 4, 🔒 🔗 🔌 🅥 📌 💥 2, 🏭 🍃 🛡️ 🌟 🅝 🎯 🐳 ⚡ 🔀 1).
    R1 los admite en la subclase o R2 los cambia por uno de la lista.
- **Perfil de publicación** (`… --perfil=publicacion`): además, **68 `PROMPTS`** (53 a
  `convencion-de-git-y-tags.md`, una por fase y ruta, más los README) y **1 `PRIVADO`** (README del
  Curso 02, ~45, cita `_desechable-`). Ver D2 y D3.
- **Autocontención:** ningún enlace sale del paquete (el único `FUERA` es de un desechable).
- **Diagramas:** cero bloques `mermaid` (`grep -c '```mermaid'`); dibujos ASCII en unos 30 archivos.
- **Ejercicios** (conteo del título `## 🧪 Ejercicios (N)`): Curso 01, 25–30 por fase y 26–30 por
  fase de ruta; Curso 02, 25–38 (F09 36, F10 37, F12 38); apéndices 30–40 en los dos cursos. Ver D5.
- **Incidentes:** 13 en el Curso 01 (el 13, de las Lauras, nuevo del 06/10) y 12 en el Curso 02.
  Ver D6.
- **Documentos de la plantilla que faltan en `prompts/`:** `README.md`, el verificador,
  `preparaciones-de-incidentes.md`, y los que D9 decide no crear.
- **Código nuevo sin correr** (2026-10-06): F7 (`initialsOf`, `scoreBoard`, `ScoreBoard.vue`, la
  carga de `/users` en `MetricsView`), el incidente 13 y su prueba, el 🔥 de puntajes de la F9 del
  Curso 02 y el ejercicio 33 de la F4 del Curso 02.
- **Referencias:** 484 URL distintas en los publicados, sin verificar por código de estado.
- **Código publicado: ~12.400 líneas** en bloques `js`, `vue`, `html`, `json`, `yaml`, `sql`,
  `css`, `dockerfile` y `md` (sin contar `bash`, `text` ni los bloques sin lenguaje), contadas con
  una expresión regular sobre las cercas de cada `.md` de los dos cursos. Por documento, las más
  cargadas: `vu0` 790, `q3` 736, `q0` 730, `vu3` 585, `q1` 525, F09 513; el Curso 02 entero suma
  ~2.300. Con ese conteo se partieron las tandas K en seis de ~1.900–2.300 líneas. K1 guarda el
  script en `zz-code/` y lo vuelve a correr, por si R2, R3 o las V movieron los números.
- **`.DS_Store`:** hay tres en el disco; el `.gitignore` de la raíz los ignora y ninguno está en git.
  No se tocan.

---

## 5. 🧩 Las tandas

### P1 — Decisiones

- Presentar D1–D12 al autor, en orden, con su recomendación; marcar cada una ✅ con fecha en §1.
- Si D1 cambia algún dato de la ficha, se cambia en la ficha en esta misma tanda y R2 lo propaga.
- **Cierra cuando:** las doce tienen ✅ y §3 dice qué tandas quedan en el plan (R3 y E9 dependen de
  D4 y D12).

### R1 — `prompts/` a los lineamientos

- **Guía §17, nueva, de excepciones**, después de §16 para no renumerar (§13.1 y las fases citan la
  guía por número). Modelo: React 16 §17. La tabla regla general → lo que hace el paquete → por qué,
  al menos con:
  - comentarios de código en español (§5) contra el inglés del `CLAUDE.md`;
  - la plantilla de nueve secciones (§9) contra setup → conceptos → antipatrones → traducción →
    ejercicios → veredicto (el veredicto honesto vive en la F15 del Curso 02);
  - 25–35 ejercicios por fase y lo que D5 decida, contra 20–30;
  - sin solucionario de ejercicios: la solución colapsada vive en los cuadernos;
  - 13 + 12 incidentes contra 15–25 (D6);
  - `0-ESTRUCTURA-CURSO.md` solo en el Curso 01 (D10), y `0-plan-del-curso.md` como documento
    maestro;
  - sin `BENCHMARKS.md` ni `INSTINTOS.md`: las mediciones van en su fase (la autopsia de la F8 del
    Curso 02) y los instintos en las secciones de §8.3–§8.4;
  - apéndices `a1-…` en el Curso 01 y `a01-…` en el Curso 02 (§13.2), sin mezclar dentro de un curso;
  - sin `src/`: el alumno construye su repo fase a fase;
  - encabezados sin vigencia, emoji en `###` y los callouts propios (§8 más los que R1 admita);
  - un solo `prompts/` para dos cursos (ya en §13.3: la tabla lo enlaza, no lo repite);
  - diagramas según D4, con su §17.1 si es Mermaid.
- **§17.2**, qué documento hace el papel de cada plantilla de `zz-instrucciones/` (D9): alcance →
  `01-vue2-legacy/0-plan-del-curso.md` e `instrucciones-proyecto-track-b.md`; diccionario y contrato
  de nombres → §5 de la guía, `diccionario-codigo.md` y `00-audit-contrato.md`; plantillas de
  capítulo → `plantilla-de-fase.md`; formatos propios → los dos `formato-*`; plan de producción → este
  plan mientras viva; prompts de fase → no se conservaron como documento (el registro de cómo se
  escribió está en los `_desechable-*` hasta C).
- **§17.3, cómo se verifica**: los comandos del verificador y lo que se acepta como aviso.
- **§15** (checklist): una casilla por la §17 y otra por el verificador en cero.
- **`prompts/README.md`** sobre `zz-instrucciones/plantillas/readme-de-prompts.md`: qué hay, qué
  manda, cómo se retoma una sesión.
- **Verificador:** copiar `zz-instrucciones/herramientas/verificador_base.py` a `prompts/` y escribir
  `prompts/verificar-corpus.py` como subclase de `PerfilCoursesIA`, con
  `react-16-legacy-for-backend-devs/prompts/verificar-corpus.py` como modelo: callouts de la guía §8
  más los admitidos; bandas de ejercicios por tipo de documento (fase, fase de ruta, apéndice) según
  D5; las nueve secciones de §9 en las fases; la nomenclatura de §13.2 (historias de ruta, forenses,
  `prompts/` único); excluir `_desechable-*`.
- **Cierra cuando:** `python3 prompts/verificar-corpus.py` corre desde la raíz del paquete y sus
  errores son solo los que R2 va a resolver.

### R2 — Restos de producción en lo publicado

- Según D2: `mv prompts/convencion-de-git-y-tags.md 00-convencion-de-git-y-tags.md` (raíz del
  paquete), revisar su texto para el lector (que no hable de "este `prompts/`") y reescribir los 53
  enlaces; la guía §13.1, §13.2, §13.3 y §9.1 con el nombre nuevo.
- Según D3: las 15 citas restantes a `prompts/` y la mención a `_desechable-` del README del Curso 02.
- El `ANCLA-FE0F` de `0-ESTRUCTURA-CURSO.md:62`.
- Los callouts que R1 no admitió, cambiados por uno de la guía §8.
- Si D1 cambió datos de la ficha, propagarlos (`grep` de cada nombre o cifra en todo el paquete).
- **Cierra cuando:** `verificar-corpus.py` en cero errores y
  `verificador_base.py … --perfil=publicacion` sin `PROMPTS` ni `PRIVADO` fuera de `prompts/`.

### R3 — Diagramas (si D4 ≠ b)

- Convertir los dibujos que D4 incluya, archivo por archivo, empezando por el grafo de rutas del
  README del paquete y de `0-ESTRUCTURA-CURSO.md`.
- Cada diagrama se dibuja antes de darlo por bueno:
  `python3 zz-instrucciones/herramientas/exportar-diagramas.py <archivo> --motor docker --salida zz-code/<id>/salidas/diagramas`
  (ninguno puede fallar).
- **Cierra cuando:** los archivos de D4 no tienen ASCII de diagrama y la exportación sale con cero
  fallos.

### V0 — Ambiente

- Que existen y corren las imágenes de la época: `node:14.21.3` (y `node:16.20.2`, la alternativa de
  Apple Silicon de F0), `mongo:4.4`, y lo que pidan Quasar CLI 1, Vue CLI 4 y Nuxt 2. La máquina del
  autor es arm64: anotar qué imagen tiene variante `linux/arm64` y cuál necesita
  `--platform linux/amd64` (emulación, que cambia tiempos y algunos mensajes).
- Que el registro de npm sirve las versiones congeladas: `vue@2.6.14`, `vuex@3`, `vue-router@3`,
  `bootstrap@4.6.2`, `jquery@3.6.0`, `axios@0.21.1`, `json-server@0.16.3`, `chart.js@2.9.4`,
  `vuelidate@0.7.7`, `socket.io@2.4.1`, `mongodb@3.6`.
- Cómo se validan las piezas que se miran en el navegador (Vue DevTools, Network, Memory): a mano en
  el navegador del autor contra el contenedor, anotadas «verificado a mano».
- **Cierra cuando:** la tabla de imágenes y versiones está en el README del directorio de `zz-code/`
  y cada versión que no instale es un hallazgo en §7.

### V1–V3 — Tronco del Curso 01

- Construir el repo del alumno de F0 a F11 copiando cada fase, con una instantánea
  `salidas/fases/fase-<slug>.tgz` por fase (sin tags: regla 9).
- **V2:** la tabla de puntajes de F7 nunca corrió. Comprobar que `_.keyBy`, `_.groupBy` y `_.sumBy`
  existen en la lodash que instala F0, y que `text-monospace` existe en Bootstrap 4.6.2.
- **V3:** que la prueba de F11 cubra `ticketStats.js` con las funciones nuevas; `npm run test:unit`
  en verde.
- **Cierra cada una cuando:** sus fases corrieron enteras, las salidas publicadas coinciden con las
  reales o se corrigieron, y la suite hasta su última fase está en verde.

### V4 — Cuaderno y forense del Curso 01

- Preparar cada incidente con su forma declarada (flag del inyector, `db.json` alterno o rama) y
  correr su prueba de regresión: roja antes del fix, verde después.
- **Incidente 13:** armar `mock/db.incidente-13.json` desde su descripción; que reproduzca las dos
  `LMC` sumadas y la fila `???`.
- Cada pieza forense: que cada paso dé la salida que publica.
- Según D7: escribir `prompts/preparaciones-de-incidentes.md` con lo que se corrió.

### V5 — Rutas

- Una pasada por ruta sobre el estado de F11 que deja V3 (su instantánea): Q (Quasar 1.22), VU (Vuetify 2.6) y NX (Nuxt 2).
  Que los X0 se escriban con el estado de F11 y que X1–X4 corran.
- Que `q00-`, `vu00-` y `nx00-historia-ruta-*.md` no contradigan lo que X1–X4 asumen (guía §13.4,
  regla 4).

### V6–V7 — Curso 02

- **V6:** Mongo 4.4 en contenedor; seed del `db.json` heredado (con las referencias rotas a
  `jpmesa`, `cvelez` y `mrestrepo`); el generador de 100k y `soporte_v1`; la autopsia de F8 con sus
  mediciones (las cifras van con fecha y máquina); el 🔥 de puntajes de F9 y el ejercicio 33 de F4.
- **V7:** F10–F15 y los apéndices; los incidentes del cuaderno (D7 aplica igual); y **la promesa del
  paquete**: se cambia el `baseURL` del frontend de V3, sin tocar nada más, y la aplicación no se
  entera. Se prueba con el checklist de smoke de `00-audit-contrato.md`.
- **Cierran cuando:** igual que V1–V3, con Jest + supertest en verde, y en V7 la promesa probada.

### R4 — URL, versiones y libros

- Las 484 URL de los publicados por código de estado, sin seguir redirecciones a ciegas (un `302` a
  la portada cuenta como roto); las SPA, por su repositorio. Script y salida en `zz-code/`.
- Cada versión que nombra una fase, contra la fuente primaria y contra lo que V0 instaló.
- Libros con edición y año.
- **Cierra cuando:** cada URL rota se cambió o se quitó, y la guía §11 lleva la fecha de la
  verificación.

### K1–K6 — Revisión de código

Las V comprueban que el código **corre**; las K comprueban que el código publicado **es el que
corrió y está escrito como la guía manda**. Se parten por volumen de código (§4), no por número de
documentos, para que cada sesión lleve una carga parecida: ~1.900–2.300 líneas de código, una suite
de pruebas que correr y un lint. Cada K agrupa documentos que comparten estado del repo del alumno,
así se levanta un solo ambiente por sesión.

**Lo mismo en todas:**

1. **Extraer** los bloques de código de los documentos de la tanda, con archivo, línea y lenguaje
   (`extraer-bloques.py`, escrito en K1 y reusado; también recalcula el conteo de §4).
2. **Comparar cada fragmento con el repo del alumno** en la instantánea de su fase
   (`salidas/fases/fase-<slug>.tgz`, o el tag si el autor lo creó). F4, F5 y F6 no tienen instantánea
   propia (V2 guardó solo el estado final de F7): se regeneran repitiendo la extracción de V2 fase por
   fase antes de comparar.
   Lo que el fragmento muestra tiene que existir igual en el repo: una diferencia es un hallazgo, y
   gana el código que corrió (regla 6), salvo que la diferencia sea la deuda 💸 declarada.
3. **Lint en contenedor**, con las herramientas de la época y sin instalar nada en el host:
   `node:14.21.3` con ESLint y `eslint-plugin-vue` en la versión mayor que soporta Vue 2 (se fija y se
   comprueba en K1, desde la fuente primaria), y `node --check` sobre los fragmentos de JS sueltos.
   El lint mide, no corrige: un aviso que es deuda a propósito se anota como tal, no se arregla.
4. **Reglas de la guía que ninguna herramienta ve**, revisadas a mano:
   - identificadores en inglés y comentarios en español (§5), con el diccionario de §5.3 y
     `diccionario-codigo.md`;
   - Options API, `function () {}` en métodos, driver nativo antes de Mongoose, nada moderno fuera
     de 🔥 (§15);
   - cada 💸 declarado en su fase y pagado donde dice; ningún atajo sin 💸 que la guía §7 exigiría
     declarar;
   - el contrato: endpoints, formas, enums, eventos de socket e `id` ↔ `_id` iguales a
     `00-audit-contrato.md` (§13);
   - los ejercicios que nombran código usan el identificador que existe en la fase (§10).
5. **Si una corrección toca código**, se corre otra vez la suite del tag afectado y la de los tags
   siguientes que lo heredan, en la misma sesión. Un fix que no se vio correr no cierra la tanda.
6. **Registro:** hallazgos en el `README.md` del directorio de `zz-code/` con archivo, línea, regla y
   decisión (corregido, deuda declarada o falso positivo), y el resumen en §7.

**Cada una cierra cuando:** cada fragmento de su alcance coincide con el repo o se corrigió, el lint
no tiene errores que no sean deuda declarada, sus suites están en verde y `verificar-corpus.py`
sigue en cero.

- **K1 — Curso 01, F0–F5 y a1–a5** (~1.920 líneas). Instantáneas de F0 a F3; F4 y F5 se regeneran (paso 2). Escribe
  `extraer-bloques.py` y deja fijada la versión de ESLint y del plugin. Atención: F2 y F3 (auth y
  mock, el inyector de caos) y `a4-axios` (el patrón `apiClient`, que las fases reusan).
- **K2 — Curso 01, F6–F11 y las doce forenses del tronco** (~2.100). F6 se regenera; F7 tiene el estado final; F8 a F11 las deja V3.
  Atención: F7 (la tabla de puntajes del 06/10), F9 (el documento con más código del tronco) y F10–F11
  (Vuex y la suite que las demás tandas dan por buena).
- **K3 — Curso 01, X0 de las tres rutas y el cuaderno** (~2.110). Los tres X0 comparten el núcleo
  común de la red de seguridad y se revisan juntos: lo que diverge entre `q0`, `vu0` y `nx0` tiene
  que ser propio de la ruta. El cuaderno, con cada prueba de regresión roja antes del fix y verde
  después, contra las ramas o los `db.incidente-NN.json` de V4 (el 13 incluido).
- **K4 — Ruta Q, Q1–Q4 y `forense-ruta-q`** (~1.930). Repo de la ruta en Quasar 1.22. Atención:
  `q3` (736 líneas, buena parte HTML de plantilla) y `q1`.
- **K5 — Rutas VU y NX, X1–X4 y sus forenses** (~2.020). Dos ambientes (Vuetify 2.6 y Nuxt 2), pero
  la ruta NX es corta (~550 líneas): por eso van juntas. Atención: `vu3` y `nx2` (hidratación).
- **K6 — Curso 02 completo** (~2.300): fases, apéndices, cuaderno y forenses. Repo del backend en sus
  tags, Mongo 4.4 en contenedor. El lint es de Node, sin el plugin de Vue; los fragmentos de `mongosh`
  se revisan contra la sesión que V6 corrió. Atención: F09–F13 (aggregation, Express, auth, sockets y
  testing) y la costura con el frontend de K2.

### C — Cierre (E8)

- El prompt E8 de `zz-instrucciones/02-prompts-de-etapa.md`, puntos 1–6 y 8 (el 7 es R3), sobre los
  dos cursos y la ficha.
- README del paquete y de cada curso con el estado real: conteos, horas, qué se corrió y con qué;
  `0-ESTRUCTURA-CURSO.md` y `0-plan-del-curso.md` al día.
- La guía registra el resultado de la validación (qué se corrió, con qué imágenes y cuándo) y lo
  que este plan deja como regla.
- `zz-code/`: cada directorio de §9 *extraído* o *archivado*, con su `README.md` completo; vista
  previa de `python3 zz-code/limpiar.py <ids>` (el `--borrar` lo da el autor).
- Según D11: `rm` de los `_desechable-*`, archivo por archivo y con permiso, este plan el último, y
  sus menciones limpias en la guía §13.1 y §13.3.
- Memoria del proyecto al día.
- **Cierra cuando:** el informe de E8 termina en «Sí, se puede cerrar».

### E9 — Publicar (si D12 = a o b)

- El prompt E9: `--perfil=publicacion` limpio, README que se sostiene solo, licencia, secretos y
  datos personales, `.gitignore` del paquete (hoy no hay: sin `src/`, solo hace falta si el autor lo
  pide).

---

## 6. 🔬 Hechos por verificar

Verificados el 2026-10-06 y ya en la ficha: TRM 4.153,91 del 20/03/2020; Resolución 000042 de mayo de
2020; Raspberry Pi 2 del 02/02/2015; `mysql_*` fuera en PHP 7.0; Maestros del Web y Platzi con
fundador común; curso de Vue en Platzi desde 2016; fin de soporte de Quasar 1, Vuetify 2 y Nuxt 2;
ni *FacilFactCol* ni *PizzaPaisa* aparecen como empresas.

Pendientes:

- **P1:** los datos de D1.
- **V0:** las once versiones congeladas en el registro de npm y las imágenes en arm64.
- **R4:** las URL, versiones y libros de §4.
- **C:** que *Cuadre Software* y *la Tiquetera* no correspondan a una empresa o producto real (no se
  buscaron el 06/10).

---

## 7. 📓 Bitácora

| Fecha | Tanda | Qué se hizo | Imágenes y versiones | Resultado y trampas |
|---|---|---|---|---|
| 2026-10-06 | — | `_desechable-plan-de-produccion.md` creado al cerrar la historia | — | — |
| 2026-10-07 | — | Este plan: revisión del paquete contra `zz-instrucciones/`, inventario de §4 con el verificador base y `grep`; absorbe el plan de producción | — | El perfil `courses-ia` no marca las citas a `prompts/`: solo `--perfil=publicacion` las ve. `sort`/`uniq` en zsh cuentan mal los emoji; para contar callouts, Python |
| 2026-10-07 | — | Tandas K1–K6 de revisión de código agregadas, partidas por líneas de código para equilibrar la carga | — | El conteo de §4 sale de una expresión regular sobre las cercas; K1 lo guarda como script |
| 2026-10-14 | P1 | Decisiones D1–D12 cerradas por defecto (el autor: «todo default»): la opción recomendada de cada una rige | — | D2 ya estaba físicamente hecha (convención en la raíz) |
| 2026-10-14 | R1 | Guía §17 (tabla de excepciones, §17.1 Mermaid, §17.2 papel de cada documento, §17.3 avisos aceptados, §17.4 lo que queda); `prompts/README.md`; `prompts/verificador_base.py` (copia de zz-instrucciones) y `prompts/verificar-corpus.py` (subclase con bandas por tipo, `preguntas()` que lee «**🟢 9.**» de las rutas, `_desechable-*` excluidos, callouts de §8 más 🧭 🧠 🧪 📄 📌) | Corrida: `zz-code/vue2-legacy-for-backend-devs-20261014-b44a/salidas/vue-r1-run*.txt` | Sin errores salvo el ANCLA-FE0F de R2. Avisos aceptados: EMOJI (254), SIN-SOL (52), ORDEN (3, a revisar a mano), DIAGRAMA (23 hasta R3) |
| 2026-10-14 | R2 | `convencion` ya en la raíz; 15 citas a `prompts/` en prosa y filas de tabla quitadas; ANCLA-FE0F corregida; 74 callouts fuera de la lista de §8 cambiados a su equivalente; 📄 y 📌 admitidos (§9.2 y §15) | `vue-r2-pub-antes.txt` y `vue-r2-pub-despues.txt` en la misma carpeta | `--publicacion`: 0 errores. Trampa: la cita a `prompts/` del README raíz estaba en un callout de «un solo prompts/», reescrito sin nombrar el directorio |
| 2026-10-14 | R3 | 23 bloques ASCII: 22 a Mermaid (grafos de rutas, flujos, estados, secuencias, capas, pirámide de pruebas), 1 tabla Markdown (equivalencias de Nuxt, en nx1) | `mermaid-cli` vía `exportar-diagramas.py --motor docker`: 22 diagramas, 0 con error; `salidas/diagramas/` y `diagramas-01-readme/`, en `zz-code/vue2-legacy-for-backend-devs-20261014-b44a/` | Colisión de nombres `README-01` (dos READMEs): la exportación del README del Curso 01 va en carpeta propia. Un fragmento sobrante de la tabla de Nuxt se borró a mano. Revisado el grafo raíz en PNG: la nota «elige UNA» pasó de colgar de la arista Q–VU a un nodo unido a la tiquetera |
| 2026-10-14 | V0 | Imágenes `node:14.21.3`, `node:16.20.2` y `mongo:4.4` descargadas en arm64 nativo; versiones del tronco, rutas, Vue CLI 3, Nuxt y Jest consultadas en el registro; sin contenedores del curso que limpiar | `zz-code/vue2-legacy-for-backend-devs-20261014-b44a/` (README §7) | H-V0-1 a H-V0-5: `@quasar/app` 1.22 no existe (1.x llega a 1.9.6); Vue CLI 3 o 4 según el plan; `@nuxtjs/axios` 5.13.6; `vue-template-compiler` 2.6.12 a propósito en F0; Stubby 5.1.1 |
| 2026-10-15 | V1 | Repo del alumno en `zz-code/…-b44a/repo/tiquetera-legacy/` (npm, `node:14.21.3`). F0: scaffold, deps, `main.js`, `App.vue`, Stubby en 8888, ejercicio «rompe a propósito» reproducido. F1: árbol, router, vistas, servicios, store. F2: login, guard, interceptor. F3: json-server, `db.json`, `ticketService`, `TicketsView`, login asíncrono, detalle. Build de cada fase en contenedor; API de F3 probada con `docker exec` | Node 14.21.3; `vue` 2.6.14; `vue-router` 3.6.5; `vuex` 3.6.2; `json-server` 0.16.3; `stubby` 5.1.1 | Hallazgos H-V1-1 a H-V1-6 en `zz-code/…-b44a/README.md`. Los dos que bloquean o cambian el curso: H-V1-4 (`PageTitle` se usa en F2 pero solo está como ejercicio 6 de F1), y H-V1-3 (la fase dice «versiones exactas» y el comando guarda `^`; retirado el 15/10 como falso positivo). Sin tags ni commits (regla de Oskar). Pendiente: navegador (F0 formulario, F1 navegación, F2 guard, F3 lista y detalle) y la decisión de H-V1-4 |
| 2026-10-15 | V1 (cierre) | Decisión por defecto de H-V1-4: `PageTitle.vue` publicado como código en F1 (su ejercicio 6 pasa a «quita la prop y lee la advertencia»); H-V1-2: F0 pide borrar `HelloWorld.vue` y `logo.png`; H-V1-3: F0 instala con `--save-exact`, como dice el texto (retirado en la revisión del 15/10: ver la fila «revisión previa a R4»). Verificador de Curso 01: 0 errores | `node:14.21.3`: build de F0–F3 y verificador en 0 errores | Corregidos en el texto de F0 y F1; el navegador queda como verificación manual del autor |
| 2026-10-15 | V2 | F4 a F7 sobre el repo de V1: archivos extraídos por la línea de su cerca y parches por ancla de texto (`main.js`, router, `TicketDetailView`, `TicketsView`, sidebar, `ticketStats.js` continúa). Build de cada fase; rutas y bundle probados con el servidor de desarrollo; `scoreBoard` ejecutado en Node sobre el `db.json` de F3 | `chart.js` 2.9.4; lodash 4.17.21 (`keyBy`, `groupBy`, `sumBy`, `countBy`); `.text-monospace` en Bootstrap 4.6.2 | H-V2-1: `utils/statusColors.js` no estaba en el árbol de F7 y sin él no compila (corregido). H-V2-2: fragmentos sin archivo de destino. H-V2-4: el ejemplo «LMC, 4, 900» de F7 es ilustrativo; con el `db.json` de F3 sale LMC, 1, 100. Solo hay instantánea del estado final de F7. Trampa: un `rm -rf` con variable lo bloquea el entorno; no se usa |
| 2026-10-15 | V3 | F8–F11 sobre el repo de V2. F8: socket.io 2.4.1 / client 2.4.0 y `concurrently` 5.3.0; prueba de difusión con dos clientes. F9: seis componentes, guard por roles. F10: store adulto con plugin; reproducido y corregido el registro temprano de handlers. F11: plugin de pruebas de Vue CLI 3 y suite en verde; cinco pruebas nuevas para la tabla de puntajes | Jest 23.6.0, vue-jest 3.0.7, @vue/test-utils 1.0.0-beta.29 (no Jest 26) | H-V3-1 a H-V3-8 en el README de la sesión; el más serio, H-V3-6 (el store nunca recibía eventos en vivo). Trampa: `vue add` sin versión instala el plugin de Vue CLI 5, y su generador muere con exit 137 |
| 2026-10-15 | V4 | Cuaderno: 13 incidentes preparados desde la instantánea de su fase, con la prueba de regresión del cuaderno corrida roja y verde; `prompts/preparaciones-de-incidentes.md` escrito (D7). Forenses: salidas de terminal contrastadas | Jest 23, test-utils 1.0.0-beta.29; chart.js 2.9.4; stubby 5.1.1; serve 14.2.6 | La mayoría de las pruebas del cuaderno no corrían tal como estaban (elisiones, nombres inexistentes, `toThrow` sobre `strict`); incidente 05 no reproducible con el curso; «Canvas is already in use» no existe en chart.js 2. Trampas: `setData` necesita `$nextTick()`; `toBe` entre instancias de Vue agota la memoria de Jest; `npx --yes` no existe en npm 6; un `rm` dentro de `sh -c` lo bloquea el entorno |
| 2026-10-15 | Revisión previa a R4 | Continuidad y contenido de P1–V2. Corregido: (1) `vu0:16`, un 🅥 dentro de una frase que el cambio automático de R2 había convertido en 📝; (2) cuatro citas a la guía sin nombre de archivo en lo publicado (README raíz, que además decía «estas cuatro» con cinco reglas; `00-audit-contrato.md`; `0-ESTRUCTURA-CURSO.md` dos veces); (3) R3: leyenda «Flecha `──`» del grafo, los pasos `[1]…[8]` de `q1` que cita su solución, y los avisos ⚠️ de `q4` y `vu4` que se habían perdido dentro del bloque ASCII, ahora con los pasos 1–9 numerados; (4) H-V1-3 era un **falso positivo**: F0 deja el `^` a propósito y enseña a quitárselo solo a `vue` y `vue-template-compiler`; se revirtió `--save-exact` en F0 y el `package.json` del repo; H-V2-3 cae por lo mismo; (5) el párrafo de `PageTitle` en F1 hablaba de «una prop» y tiene dos; (6) la nota de F0 usaba 🧹, fuera de la guía: pasa a 🪦; (7) guía §15 con las dos casillas que pedía R1, y §17 al día; (8) regla 9 y tandas K sin tags, con instantáneas | Verificador: 0 errores en los dos modos; diagramas de q1, q4, vu4 y `0-ESTRUCTURA` reexportados sin error | Las citas a «la guía» sin nombre de archivo no las ve el verificador: se buscan con `grep` (guía §17.3) |
| 2026-10-15 | V5 | Las tres rutas corridas sobre F11. **NX:** NX2 saca el interceptor de `apiClient`; NX3 con el módulo de F10 en `store/`, `state` como función, `nuxtServerInit` con `this.$cookies`, el 8080 fijado, el 503 de la Opción B y la deuda de las dos `baseURL` reescrita; NX4 con `getTicketById`, el socket y el `curl` al 8080. **Q:** decisión por defecto D13 — Quasar 1.22.10 sobre `@quasar/app` 1.9.6 (kit `--branch app-v1`, Vue 2.6.11, sin ESLint), porque la lista de `framework.components` solo existe ahí; Q1 rehecho con lo medido (el `<q-chip>` crudo con texto, el warning de desarrollo, la relectura de `quasar.conf.js`); Q2 con el traslado completo y los rojos reales de Q0; Q3 con `:data` (no `:rows`), las anclas de Q0, jQuery para el modal y el `.sync` sin setter corregido; Q4 sin cambios de lógica. **VU:** VU2 llena `mountView` y migra el wizard; VU3 con las anclas de VU0, el filtro de estado y los diálogos de VU2; `v-app` corregido en VU1, VU4 y el forense (warning `data-app`, tema bajo `.v-application`, modo oscuro solo bajo `v-app`). Historias de ruta revisadas: `q00` ancla la lista a una plantilla de 2020 | Redes 64/64 en Q y VU, builds en verde, SSR por `curl`; verificador 0 errores (254/52/3) | Detalle por fase en el README de `zz-code` (H-V5-8 a H-V5-13) |
| 2026-10-15 | V6 | Curso 02 F0–F9 sobre `mongo:4.4` (red propia, sin puertos; `mongosh` 2.x y el shell clásico `mongo` de la imagen). **F1:** el seed da 3/3/1 (no 6/14/23) y `npm run seed` pasa al cuerpo de la fase. **Generadores:** el curso decía «traer» `scripts/seed-antipattern.js` y usaba `scripts/generate.js`, y ninguno existía: escritos, probados (100k/400k en 3 s; `soporte_v1` 100k/400k/300k con huérfanos en 5 s) y publicados en F1 y F3. **F2:** bonus de arrays sobre un ticket que no existía. **F4:** en 4.4 `errInfo` llega vacío (el detalle es de 5.0) → diagnóstico por partes con `$jsonSchema`; `bsonType: "int"` y los dos shells (`mongosh` y el driver mandan `int`, el clásico `double`); el seed con `dropDatabase()` **se lleva el validator** (forense 04 rehecho). **F6:** la transacción en standalone da un error de *retryable writes* que despista; RS de un nodo probado; `takeTicket` con dos agentes a la vez: uno gana, otro `conflict`. **F7:** la regex flotante con índice es `IXSCAN` de 100k claves y **más lenta** que el COLLSCAN; el compuesto al revés no da COLLSCAN sino un `IXSCAN` que examina todo (forense 07 rehecho con salidas reales). **F5 forense:** 4.4 mueve el `$match` antes del `$lookup` solo; lo lento es el `$lookup` sin índice (1372 ms contra 25). **F8:** migración de referencia v1→v2 (56 s) y tabla medida en M1 Pro. **F9:** `$round` al par confirmado; `computeStats` 371 ms | Verificador 0 errores (254/52/3) | Cifras inventadas que quedan en el cuaderno (41230, 3184 ms, `status_id`): V7 |
| 2026-10-15 | V7 | Backend de F10 armado con lo publicado más la unión mínima (config, rutas, servicios de users/comments; marcada `[unión de V7]`). **Promesa:** prueba diferencial json-server ↔ Express sobre el mismo `db.json`, 12 llamadas del frontend con el mismo status y la misma forma; el diff del frontend es de **cero** líneas (Express en el `:3000` de json-server) → «a lo sumo una línea» en el audit, F0, F9 y la convención; `ticketById` con `Number(id)` existe pero ninguna vista lo usa. **F10:** faltaba la instalación de express/cors/morgan; `/boom` iba al `:4000` y no era del todo callado (`UnhandledPromiseRejectionWarning`). **F11:** el `login` publicado era **inyectable por el `username`** (`{ $ne: null }` entra como admin) → valida tipos (400); el `$ne` en password daba 500; instalación agregada. **F12:** imports con nombres que F11 no tiene (`lib/jwt`, `middleware/auth`), `buildTicket` sin definir, `curl` al `:4000`; el límite de multer daba 500 → traducción a 413 en el manejador central. **F13:** en mongodb-memory-server 6, `getUri()` es promesa (sin `await`, `MongoParseError`); su default es 4.0.14, no "lo último"; sin binario 4.4 para Linux arm64; 6/6 en verde en amd64. **F14/A01:** `?replicaSet=rs0` con el RS iniciado como `localhost` rompe al `api` y al `backup` (ECONNREFUSED) → URI directa, transacciones probadas. **A04:** ataque 2 confirmado contra F10; ReDoS ya desactivado por `escapeRegex`. **Cuaderno:** 01 (el choque de puerto es de Docker, no de `mongod`; `mongosh` no está en la imagen), 05 (la causa real: `$lookup` sin índice y `$sort`/`$limit` después; 3.351 ms → 44 ms), 07, 08 (snake_case → camelCase, `seed-antipattern.js`), 09, 10 (backend en `:3001`), `down -v` no borra bind mounts; preparaciones del Curso 02 en `prompts/preparaciones-de-incidentes.md` | Verificador 0 errores (254/52/3) | Quedan a mano: el smoke en navegador del audit y el modo oscuro/z-index de las rutas |
| 2026-10-15 | R4 | **URL:** 466 únicas de lo publicado, redirecciones seguidas a mano. Rotas cambiadas: Sarah Mei → archive.org (F15, A05), cheat sheet de JWT de OWASP (F11, A04), docs de Jest 26 → GitHub v26.6.3, mongodb-memory-server → typegoose, json-server → `tree/v0.16.3`, guía de upgrade de Quasar → archive 20230131, unit testing de Vue → cookbook; tres videos con su título real (oEmbed); 131 redirecciones reemplazadas por su destino final (docs de MongoDB v4.4 → manual, axios → axios.rest, WSTG). Guía §11.2 al día y §11.4 nueva con la fecha. **Versiones:** 46 `paquete@versión`, todas existen; F13 pasa a `--save-exact jest@26.6.3 supertest@6.1.6 mongodb-memory-server@6.9.6` (las probadas; `@6` ya resuelve a 6.3.4/6.10.0). **Libros:** año y edición en Halliday (2018), Fowler (1.ª 1999; 2.ª 2018, Q0 y VU0), Copeland (2013), Casciaro & Mammino (3.ª, 2020); el resto ya los llevaba | Script `r4/verificar_urls.py`; 403 antibot (npm, O'Reilly, CACM) confirmados por registro o archive.org; un 429 de GitHub ya visto en 200 | — |
| 2026-10-16 | K1–K6 | Herramientas en `zz-code/…/k/`: `extraer-bloques.py` (13.415 líneas en 1.230 bloques; el conteo de §4 al día), `comparar.py` (cada fragmento contra la instantánea de su fase, con o sin comentarios y comillas), `correr.sh`/`correr-ruta.sh` (build, lint y suites en `node:14.21.3`), `ids-espanol.py` (guía §5), `ejercicios-ids.py` (§10) y `sintaxis.py`. Lint: ESLint 5.16.0 + `eslint-plugin-vue` 5.2.3 (los del `vue create` de F0), sin errores en F0–F11, X0 y las rutas; ESLint 5 sobre el backend, 0 errores. **K1:** a F0, F3 y F8 les faltaba el script `lint` del andamio en sus `"scripts"`; F4 decía que el computed dependía de `statusFilter`; inyector de caos de F3 corrido en sus siete modos (V1 no lo había corrido). **K2:** el `watch deep` de F7 usaba `chartData`/`refreshChart`, que no existen (es `counts`); la prueba de `scoreBoard` de F11 alineada con lo publicado (26/26). **K3:** el parche del incidente 09 llamaba a `self.onTicketUpdated` donde no existe y, puesto en la vista, haría ping-pong entre navegadores: el aviso sale de `TicketWorkspace.patchTicket` y el oyente lleva alta y baja (probado); refactor del 04 con el computed real de F4; mixin `chartLifecycle` del 07 probado (3/3); botones de Q0/VU0 con sus clases. **K4:** el traslado de Q2 no instalaba json-server, socket.io ni concurrently ni traía los scripts `mock`/`sockets`/`dev`; Q3 4.7 tenía un `onSaved` que reventaba al crear; Q1 atribuía el proxy a F3 (es de A5); Q4 integrado de punta a punta (colección `activity`, relé, GET/POST); **identificadores en español** (§5) renombrados en Q0, VU0, Q1–Q3, VU1, VU2, NX2 y NX4 y en los repos, con las cuatro redes en 64/64. **K5:** el fragmento de VU2 usaba `error`, que en F10 es el `mapState` del store (Vue descarta el computed: medido), ahora `saveError`; Q4/VU4 ponían `<ticket-form>` en `TicketDetailView`, que no tiene formulario; VU4 reescribía el `AppHeader` y perdía usuario, «en vivo» y Salir; `updateTicket` reventaba si el ticket no estaba en el store (`|| {}`); NX2 no decía dónde corre la API; `plugins/vuetify.js` publicado en el repo de VU. Q y VU 66/66, builds y lint limpios; NX build y su suite verdes. **K6:** F11 integrado y probado contra Mongo 4.4 (401, 403, `reporter` del token, 422 de transición ilegal —nuevo en el contrato—, 200 y 409 a la vez, `history` con `by`); `whitelist` no existía y `create` no tenía `try/catch`; F10 sin `config.js` y la unión leía `MONGO_URI`; F11 sin `mongoose.connect` y la unión concatenaba la base; el `server.js` de F12 perdía las conexiones; F12 usaba un `buildTicket` inexistente; paginación opcional de F10 probada; el compose de F14 levantado con el Dockerfile de A01 (seed, GET y backup con `--oplog`) y la nota del RS desde cero; incidente 08 sin script de preparación (publicado) y con el bug mal descrito (el `closed` queda en `null`; tabla medida; `fix-08` en 23 s con índice); `fix-dates` y `audit-types` del 02 corridos; `src/api` → `src/lib`; `filtro`/`cambio`/`ensayo`/`campo` → inglés | Verificador 0 errores (254/52/3) en los dos modos | Falso positivo retirado: `reopened` en `serializeActivity` es extensión pactada en el audit. Las suites de F13 quedaron para el 18/10 (fila siguiente) |
| 2026-10-18 | K6 | Suites de F13 corridas con emulación (`--platform linux/amd64`, `node:14.21.3`) sobre el backend de K6: 3 suites, 6/6 en verde. Jest no terminaba porque F13 pide cerrar el cliente en `afterAll` y el `db.js` de F10 no exportaba con qué: `close()` agregado a `db.js` (F10) y `afterAll(close)` a la prueba HTTP (F13), en lección y código | 6/6, la corrida termina sola en ~7 s | — |
| 2026-10-18 | C y E9 | E8 sobre los dos cursos y la ficha; README raíz y de cada curso con «Cómo se validó»; 915 ejercicios en el Curso 01; arco del Curso 02 a Mermaid; stack del Curso 02 con versiones; fila 08 de preparaciones; usuario del autor fuera de las salidas de `lsof`; guía §17.4 (resultado de la validación) y §17.5 (reglas); `LICENSE.md` (CC BY-SA 4.0) y `.gitignore`; aviso de ficción (La Tiquetera existe como boletera de Medellín); contenedores y redes del curso borrados; diez desechables borrados, este el último, con copia en `zz-code/…-b44a/salidas/plan-de-edicion-final.md` | Verificador 0 errores (254/52/3) en los dos modos | Abiertas para el autor: D13, incidente 05, H-V3-4, `testid` de NX0, el nombre Tiquetera, el navegador, las imágenes de Docker y el `--borrar` de `limpiar.py` |

---

## 8. ✅ Checklist final

- [x] D1–D12 cerradas (2026-10-14, por defecto: «todo default» del autor).
- [x] Guía §17 escrita; `prompts/README.md` escrito; `prompts/verificar-corpus.py` en cero errores.
- [x] Ningún publicado cita `prompts/` ni un `_desechable-*` (`--perfil=publicacion` sin `PROMPTS`
      ni `PRIVADO` fuera de `prompts/`).
- [x] Diagramas según D4, exportados sin fallos (22, mermaid-cli en contenedor).
- [x] V0–V7 cerradas, con cada fase corrida o marcada «no verificado por ejecución».
- [x] La promesa del `baseURL` probada en V7.
- [x] `preparaciones-de-incidentes.md` escrito (si D7 = a): Curso 01 en V4; el Curso 02 se agrega en V7.
- [x] URL, versiones y libros verificados (R4).
- [x] K1–K6 cerradas: cada fragmento publicado coincide con el repo del alumno, lint sin errores
      fuera de la deuda declarada y suites en verde después de cada corrección (2026-10-16).
- [x] README del paquete y de cada curso con el estado real.
- [x] El resultado de la validación anotado en la guía (§17.4 y §17.5).
- [x] `zz-code/` sin directorios *vigentes*.
- [x] Contenedores y volúmenes de las pruebas borrados; nada ajeno tocado.
- [x] `_desechable-*` borrados según D11, este plan el último, con permiso del autor («Termina C y E9», 2026-10-18).

---

## 9. 🗂️ Directorios de `zz-code/`

| Directorio | Tanda | Estado | Qué tiene |
|---|---|---|---|
| `vue2-legacy-for-backend-devs-20261014-b44a` | P1, R1–R4, V0–V7, K1–K6, C | archivado | Repo del alumno en `repo/tiquetera-legacy/` (estado de F7) e instantáneas en `salidas/fases/` (F0–F3 y F7 final); verificador del paquete y sus corridas; exportación de los 22 diagramas Mermaid (docker mermaid-cli); inventario de Docker al inicio en `salidas/inventario-docker-inicio.txt` |
| `vue2-legacy-for-backend-devs-20261006-c6c0` | — | archivado | Rescate de las verificaciones del corpus de 2026-09 (tres forenses); sin corridas del código del curso. Registro de la versión anterior a la Tiquetera: no se renombra |
