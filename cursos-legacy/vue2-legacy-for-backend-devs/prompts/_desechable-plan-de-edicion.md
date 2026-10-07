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
> **Vigencia:** 2026-10-07. **Estado:** decisiones D1–D12 abiertas. **Siguiente paso: P1** (que el
> autor las cierre).

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

Todas abiertas. Cada una trae la recomendada primero. P1 las cierra con el autor y las marca ✅ con
fecha; las tandas no empiezan antes.

### 1.1 Lo que toca el contenido publicado

- **D1 — Los datos que propuso Claude en la ficha.** Quedaron sin confirmar el 06/10: el nombre
  *Tiquetera*, las dos Lauras `LMC` (la segunda entra en 2022), Valentina Ospina (2020–2022), Mongo
  abierto sin contraseña un año, las cifras (~80 → ~250 → ~400 comercios; ~30.000 tickets) y el
  preventista de la cervecería. **(a) Se confirman tal como están** · (b) el autor cambia los que no
  le sirvan, y la tanda R2 los propaga.
- **D2 — La convención de git, que los publicados enlazan 53 veces dentro de `prompts/`.** Cada fase
  la cita desde su bloque 🏷️, así que el lector la necesita, y `prompts/` no viaja (E9).
  **(a) Pasa a la raíz del paquete como `00-convencion-de-git-y-tags.md`**, material publicado como
  la ficha, igual que en React 16; los 53 enlaces se reescriben · (b) se queda en `prompts/` y cada
  bloque 🏷️ lleva lo mínimo en prosa (más largo, y se pierde el detalle de los pares `-roto`/`-fix`).
- **D3 — Las demás citas a `prompts/` (15).** `formato-piezas-forenses` (5), la guía (3),
  `diccionario-codigo` (2), `instrucciones-proyecto-track-b` (2), `plantilla-de-fase` (1),
  `formato-cuaderno-incidentes` (1), y la mención a `_desechable-` en el README del Curso 02 (línea
  ~45). **(a) Se pasan a prosa con lo que el lector necesita saber**, y el README del paquete conserva
  una línea sin enlace ("el material de autoría vive aparte") · (b) se quitan sin reemplazo.
- **D4 — Diagramas (`D-12`).** El paquete no tiene ningún bloque Mermaid; los dibujos son ASCII
  (los más cargados: `q1`, `nx1`, `q2`, `q0`, `vu0`, `vu4`, `q4`, F05, F04, `0-ESTRUCTURA-CURSO`,
  el README del paquete). **(a) Mermaid para los diagramas de verdad** (flujos, estados, secuencias,
  capas, el grafo de rutas), y en texto los árboles de archivos, las salidas de terminal y de
  DevTools y las correspondencias de una línea, con los criterios de React 16 §17.1 · (b) todo se
  queda en ASCII, declarado · (c) solo el grafo de rutas y los flujos de las fases ⭐.
- **D5 — Ejercicios fuera de la banda de la guía §10.** Los apéndices traen 30–40 ejercicios (la
  guía dice 5–10) y tres fases del Curso 02 pasan de 35 (F09: 36, F10: 37, F12: 38). **(a) Se declara
  lo publicado** (bloqueo de contenido): apéndices de práctica con 30–40, techo de 38 en el Curso 02
  · (b) se recortan los apéndices a 10 y las tres fases a 35.
- **D6 — Incidentes por debajo del tipo legacy.** `01-tipos-de-curso.md` §3 da 15–25 por curso; el
  paquete tiene 13 y 12. **(a) Se declara** (el paquete es de dos cursos: 25 entre los dos) · (b) se
  escriben incidentes nuevos hasta 15 por curso (sale de este plan: sería una tanda de escritura).
- **D7 — Los `mock/db.incidente-NN.json`.** El alumno los arma desde la descripción de cada
  incidente. **(a) Se quedan así, y `prompts/preparaciones-de-incidentes.md` (que el tipo legacy
  pide y no existe) registra cómo se arma cada uno, escrito en V4 y V6 a partir de lo que se corrió**
  · (b) se publican los archivos dentro del cuaderno.
- **D8 — El NIT en el título.** Solo aparece en el recuadro de F3 y en el ejercicio 33 de la F4 del
  Curso 02; la semilla no lo usa, y sus títulos los citan pruebas y búsquedas en más de 15 lugares.
  **(a) Se queda así**, y la guía lo dice · (b) un ticket nuevo de la semilla lo lleva (no se toca
  ninguno de los existentes).

### 1.2 Lo que toca `prompts/` y el cierre

- **D9 — Los documentos de `prompts/` que la plantilla pide y no existen** (alcance, propuestas,
  diccionario de términos, contrato de nombres, plantillas de capítulo, prompts de fase,
  preparaciones). **(a) No se crean a posteriori**: la guía §17.2 dice qué documento hace el papel de
  cada uno, como React 16 §17.2; solo se crean `prompts/README.md` y, por D7,
  `preparaciones-de-incidentes.md` · (b) se crean todos.
- **D10 — El Curso 02 no tiene `0-ESTRUCTURA-CURSO.md`.** **(a) Se declara**: su papel lo hacen el
  README del curso y `instrucciones-proyecto-track-b.md` · (b) se escribe en la tanda C.
- **D11 — Los nueve `_desechable-*` de `prompts/`.** **(a) Se borran todos en la tanda C**, este
  plan incluido; el historial de git los conserva · (b) se conservan la guía superada del Track B y
  los de traducción del código como registro, y se borra el resto.
- **D12 — Publicación (E9).** La ficha y el contrato son de los dos cursos, así que publicarlos por
  separado los parte. **(a) Un solo repositorio público para el paquete**, y la tanda E9 entra en
  este plan · (b) dos repositorios, con la ficha copiada en cada uno · (c) E9 queda fuera de este
  plan: se cierra en E8.

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
   corrida escrito mientras se prueba. Ahí vive el repo del alumno que se construye fase a fase, con
   sus tags `fase-…` (esos sí los crea la sesión). Ningún documento del paquete cita `zz-code/`.
10. **Git del paquete lo hace el autor.** Nada de `git mv` ni `git rm`; mover con `mv`, borrar con
    `rm`, archivo por archivo. `perl` siempre con `-CSD -Mutf8`, y al cerrar `grep -rl "Ã\|â"` en cero.
11. **Nada se instala en el host.**
12. **El README del paquete y los de cada curso se tocan solo en la tanda C**, salvo los enlaces que
    R2 tiene que reescribir.

---

## 3. 📊 Estado

| Tanda | Alcance | Escrita | Corrida | Estado |
|---|---|---|---|---|
| P1 | Decisiones D1–D12 con el autor | — | — | ⬜ |
| R1 | `prompts/` a los lineamientos: guía §17, `prompts/README.md`, verificador | ⬜ | ⬜ | ⬜ |
| R2 | Restos de producción en lo publicado: citas a `prompts/`, convención de git, anclas, callouts | ⬜ | — | ⬜ |
| R3 | Diagramas según D4 | ⬜ | — | ⬜ |
| V0 | Ambiente: imágenes, arquitectura, versiones congeladas | ✅ | ⬜ | ⬜ |
| V1 | Curso 01 · F0–F3 (setup, base, auth, mock) | ✅ | ⬜ | ⬜ |
| V2 | Curso 01 · F4–F7 (dashboard, CRUD, wizard, métricas con la tabla de puntajes) | ✅ | ⬜ | ⬜ |
| V3 | Curso 01 · F8–F11 (sockets, panel, Vuex, testing) | ✅ | ⬜ | ⬜ |
| V4 | Curso 01 · cuaderno (13) y piezas forenses del tronco | ✅ | ⬜ | ⬜ |
| V5 | Curso 01 · rutas Q, VU y NX (X0–X4 cada una) | ✅ | ⬜ | ⬜ |
| V6 | Curso 02 · F0–F9 (Mongo 4.4, modelo, `soporte_v1`, autopsia, aggregation con el opcional de puntajes) | ✅ | ⬜ | ⬜ |
| V7 | Curso 02 · F10–F15, apéndices, cuaderno (12) y la promesa del `baseURL` | ✅ | ⬜ | ⬜ |
| R4 | URL, versiones y libros de las referencias | ⬜ | ⬜ | ⬜ |
| K1 | Revisión de código · Curso 01, F0–F5 y apéndices a1–a5 (~1.920 líneas) | — | ⬜ | ⬜ |
| K2 | Revisión de código · Curso 01, F6–F11 y forenses del tronco (~2.100) | — | ⬜ | ⬜ |
| K3 | Revisión de código · Curso 01, X0 de las tres rutas y cuaderno (~2.110) | — | ⬜ | ⬜ |
| K4 | Revisión de código · Curso 01, ruta Q (Q1–Q4 y su forense) (~1.930) | — | ⬜ | ⬜ |
| K5 | Revisión de código · Curso 01, rutas VU y NX (X1–X4 y sus forenses) (~2.020) | — | ⬜ | ⬜ |
| K6 | Revisión de código · Curso 02 completo (~2.300) | — | ⬜ | ⬜ |
| C | E8: README, revisión total, `zz-code/` cerrado, `_desechable-*` borrados | — | — | ⬜ |
| E9 | Publicación, solo si D12 = (a) o (b) | — | — | ⬜ |

**Dependencias.** R1 va primero porque deja el verificador que corre al cerrar todas las demás. R2
y R3 antes de las V, para que la validación corra sobre el texto definitivo. V0 antes de cualquier V;
V1–V3 en orden (cada una parte del tag de la anterior); V4 y V5 parten del tag `fase-11` de V3; V6
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

- Construir el repo del alumno de F0 a F11 copiando cada fase, con un tag `fase-<slug>` por fase.
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

- Una pasada por ruta sobre el tag `fase-11` de V3: Q (Quasar 1.22), VU (Vuetify 2.6) y NX (Nuxt 2).
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
2. **Comparar cada fragmento con el repo del alumno** en el tag de su fase (`git show fase-<slug>:<ruta>`).
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

- **K1 — Curso 01, F0–F5 y a1–a5** (~1.920 líneas). Repo en `fase-00` … `fase-05`. Escribe
  `extraer-bloques.py` y deja fijada la versión de ESLint y del plugin. Atención: F2 y F3 (auth y
  mock, el inyector de caos) y `a4-axios` (el patrón `apiClient`, que las fases reusan).
- **K2 — Curso 01, F6–F11 y las doce forenses del tronco** (~2.100). Repo en `fase-06` … `fase-11`.
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

---

## 8. ✅ Checklist final

- [ ] D1–D12 cerradas por el autor.
- [ ] Guía §17 escrita; `prompts/README.md` escrito; `prompts/verificar-corpus.py` en cero errores.
- [ ] Ningún publicado cita `prompts/` ni un `_desechable-*` (`--perfil=publicacion` sin `PROMPTS`
      ni `PRIVADO` fuera de `prompts/`).
- [ ] Diagramas según D4, exportados sin fallos.
- [ ] V0–V7 cerradas, con cada fase corrida o marcada «no verificado por ejecución».
- [ ] La promesa del `baseURL` probada en V7.
- [ ] `preparaciones-de-incidentes.md` escrito (si D7 = a).
- [ ] URL, versiones y libros verificados (R4).
- [ ] K1–K6 cerradas: cada fragmento publicado coincide con el repo del alumno, lint sin errores
      fuera de la deuda declarada y suites en verde después de cada corrección.
- [ ] README del paquete y de cada curso con el estado real.
- [ ] El resultado de la validación anotado en la guía.
- [ ] `zz-code/` sin directorios *vigentes*.
- [ ] Contenedores y volúmenes de las pruebas borrados; nada ajeno tocado.
- [ ] `_desechable-*` borrados según D11, este plan el último, con permiso del autor.

---

## 9. 🗂️ Directorios de `zz-code/`

| Directorio | Tanda | Estado | Qué tiene |
|---|---|---|---|
| `vue2-legacy-for-backend-devs-20261006-c6c0` | — | archivado | Rescate de las verificaciones del corpus de 2026-09 (tres forenses); sin corridas del código del curso. Registro de la versión anterior a la Tiquetera: no se renombra |
