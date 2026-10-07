# 🗓️ Plan de producción: tandas, estado y checklist

Este documento dice **en qué orden se prepara y se escribe el curso, cuándo una tanda está terminada y
dónde va la producción**. Hay dos fases: la **preparación** (tandas `P1`–`P11`), que solo toca
`prompts/` y el laboratorio de verificación y no escribe ni una fase, y la **escritura** (tandas
`T0`–`T16`), que arranca cuando está cerrada la parte de la preparación que cada tanda necesita
(regla 7). Es operativo: se actualiza al
cerrar cada sesión, y cualquier sesión que retome `ruta-sql/` empieza leyendo §3 (estado), §6
(deuda), §7 (bitácora) y §8 (checklist).

- La forma la manda [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md).
- Los nombres, [`contrato-de-nombres.md`](contrato-de-nombres.md) y
  [`diccionario-de-terminos.md`](diccionario-de-terminos.md).
- El qué lo manda [`alcance-del-proyecto.md`](alcance-del-proyecto.md).
- Horas, ejercicios y fichas: [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) y
  [`propuesta-apendices-y-alcance.md`](propuesta-apendices-y-alcance.md).
- La entrada de cada tanda es su prompt: [`prompts-de-fase.md`](prompts-de-fase.md),
  [`prompts-de-apendice.md`](prompts-de-apendice.md) y
  [`prompts-sqlserver-fase.md`](prompts-sqlserver-fase.md).
- **El orden lo manda este documento.**

> **Caducidad:** es un documento de producción. Al cerrar T16 se conserva en `prompts/` como
> referencia (que no viaja al repositorio público), salvo que Oskar pida borrarlo;
> `_desechable-propuesta-ruta.md` se borra con su permiso. **No se cita desde ninguna fase, apéndice
> ni README.**
>
> **Vigencia:** 2026-10-06.

**Salto rápido:** [1](#1--las-reglas-de-orden) · [2](#2--qué-es-una-tanda) · [3](#3--estado) · [4](#4--las-verificaciones) · [5](#5--las-tandas-una-por-una) · [6](#6--deuda-de-enlaces-abierta) · [7](#7--bitácora) · [8](#8--checklist-final) · [9](#9--directorios-de-zz-code)

---

## 1. 🧭 Las reglas de orden

Son veintisiete fases, once apéndices, cinco fases de track y tres documentos vivos. Escritos en
orden de carpeta, el Bloque II mediría sobre un modelo que todavía no existe y la bitácora iría
siempre atrasada. Las tandas van por **dependencia**, y cada una deja el curso coherente y
publicable hasta donde llega. Diez reglas:

1. **Ninguna tanda se cierra con un documento vivo ni un solucionario atrasado.** Las mediciones de
   la tanda entran en `bitacora-de-medicion.md`, los errores en `a08-catalogo-de-errores.md` y los
   instintos en `INSTINTOS.md`, y cada documento con ejercicios nace con su
   `soluciones/<mismo-nombre>.md` completo y ejecutado (D18, guía §10.3), en la misma tanda.
2. **Ningún enlace interno apunta a un documento que no existe.** La referencia va en prosa y se
   anota en la deuda de enlaces (§6); la tanda que escribe el destino la convierte en enlace.
3. **Los README y `0-ESTRUCTURA-CURSO.md` se escriben en una tanda final y aparte (T15), y ninguna
   otra tanda los toca.** Escribir una fase o un apéndice **no crea ni actualiza** ningún
   `README.md` (ni el de la raíz del curso ni los de `src/`) ni `0-ESTRUCTURA-CURSO.md`. Tampoco se
   agregan filas, enlaces ni estados "para ir adelantando". Lo que una tanda querría decir en uno de
   ellos se anota en §6 como deuda de T15. **Mientras tanto, el mapa son los desechables**: §3 de
   este plan para el estado y la propuesta de fases §11 para el temario.
4. **Nada se nombra sin comprobarlo en la misma sesión**: imagen y digest, versión, función del motor,
   URL por código de estado, libro con edición y capítulo.
5. **Una fase no se cierra sin haberse corrido entera**: el laboratorio, las mediciones, la rotura y
   la prueba de fuego, con la salida literal y fechada.
6. **Ningún número de Oracle ni de SQL Server entra en un documento publicado.** Las corridas
   privadas viven fuera del repositorio (alcance §6.1).
7. **Ninguna tanda de escritura empieza con su preparación abierta.** Cada una exige lo suyo:
   - **T0** exige P7 y P10: todas las decisiones cerradas y trasladadas. ✅ desde el 30/09/2026.
   - **T1** exige además **P8** (la verificación de laboratorio) y **P11** (lo verificado,
     trasladado): sin digests, sin RAM medida y sin perfiles calibrados no hay `a01`, `a02`, `a05`
     ni `a06`.
   - **T2** exige además **P9**: `a09` cita el texto de las licencias, y F00–F02 citan los libros
     base.
8. **Sin commits**: git lo hace Oskar. Se borra con `rm`, nunca con `git rm`.
9. **La máquina de Oskar no se toca sin permiso**: nada se instala ni genera cargos. Los contenedores
   de las pruebas llevan la etiqueta `curso=ruta-sql`, usan **puertos altos y aleatorios** (nunca los
   de por defecto, que otro contenedor puede tener ocupados; el curso sí puede publicarlos) y se
   borran **con sus volúmenes** al terminar, comparando contra un inventario inicial; nada que ya
   existía se borra.
10. **Todo el código de las sesiones va a `zz-code/`**: un directorio por sesión
    (`python3 zz-code/nuevo.py ruta-sql`), registrado en §9 con su estado. Lo efímero (logs, salidas,
    copias) va a su `salidas/`; nada en el scratchpad ni en `/tmp`. Los comandos sueltos que producen
    algo citable se copian a un archivo, y el `README.md` de cada directorio dice cómo correr y medir
    cada prueba. Ningún documento del curso cita `zz-code/` (guía §19.5).

**Prioridad si el tiempo aprieta:** T1 → T2 → T3 → T4 (Bloque 0 y Bloque I, con su boss: un curso
utilizable por sí solo), después **T7** (F15–F16, el folio sin huecos, que es la fase estrella y el
primer vídeo). Lo que falte de las tandas saltadas va en prosa y a la deuda de enlaces.

---

## 2. 📦 Qué es una tanda

### 2.0 Una tanda de preparación

Un documento de `prompts/`, o un paso que lo deja coherente con los demás: una decisión, una
verificación, un traslado. **No crea nada fuera de `prompts/`**, salvo P8, que prueba en
`zz-code/` y deja sus hallazgos en `prompts/verificacion-de-laboratorio/hallazgos.md`. Terminada cuando sus enlaces pasan §4 y los documentos que la
citan están al día.

### 2.1 Una tanda de escritura

Un grupo de fases o apéndices que se enlazan entre sí, con su laboratorio corrido. La rutina, igual
en todas:

1. Pegar el prompt de cada documento y seguir su protocolo de tres pasos.
2. Tener delante el checklist de la guía §16, que se recorre **al cerrar cada archivo**.
3. Releer la ficha de la propuesta: el "Entra" es el piso, la apuesta y la rotura son candidatas.
4. Comprobar versiones, funciones del motor, URLs y libros **antes** de escribirlos.
5. Ejecutar y anotar (el error antes de arreglarlo), después escribir.
6. Escribir el solucionario de cada documento en la misma sesión, y alimentar los tres documentos
   vivos.
7. Resolver la deuda de enlaces que la tanda cierra.
8. Correr las verificaciones de §4 (`verificar-corpus.py` en cero, sin el aviso `README`).
9. Actualizar §3, §6, §7 y §8 de este documento, que es el mapa hasta T15.

### 2.2 Peso de cada tanda

```text
ligera   T0 · T15 · T16                         esqueletos, README y estructura, o cierre
normal   T2 · T3 · T4 · T5 · T6 · T7 · T8 · T9 · T10 · T12 · T14
densa    T1 · T11 · T13                         infraestructura nueva: lab, API y broker, SQL Server
```

Las **densas** llevan verificación de imagen, digest y memoria antes de escribir una línea, anotada
con fecha en el documento.

---

## 3. 📊 Estado

Leyenda: ⬜ pendiente · 🟡 en curso · ✅ terminada y verificada.

| Tanda | Entrega | Docs nuevos | Peso | Estado |
|---|---|---|---|---|
| **P1** | Guía de estilo y convenciones, derivada de la de la NoSQL Lite | 1 | — | ✅ |
| **P2** | Alcance del proyecto | 1 | — | ✅ |
| **P3** | Propuestas de fases y de apéndices, con el registro de decisiones | 2 | — | ✅ |
| **P4** | Plantillas de capítulo (tema, Bloque 0, árbitro, track, apéndice) | 1 | — | ✅ |
| **P5** | Prompts de fase, de apéndice y del track | 3 | — | ✅ |
| **P6** | Este plan | 1 | — | ✅ |
| **P7** | Decisiones D1–D16 cerradas por Oskar | — | — | ✅ |
| **P8** | Verificación de laboratorio: imágenes, digests, RAM, emulación, drivers, perfiles de volumen | — | densa | ⬜ |
| **P9** | Fuentes base: edición y año de los seis libros de la guía §11; texto de las licencias para `a09` | — | — | ⬜ |
| **P10** | Traslado de las decisiones a alcance, guía, propuestas y prompts | — | — | ✅ |
| **P11** | Traslado de lo verificado en P8 y P9 (versiones, perfiles, driver, ediciones) | — | — | ⬜ |
| **P12** | Alineación con los lineamientos de producción: diccionario, contrato de nombres, `prompts/README.md`, verificador, guía §17 y §19, alcance §12.1 | 5 | — | ✅ |
| **T0** | Arranque: esqueletos de los documentos vivos y de a03, a04, a07, y `src/.gitignore` | 6 | ligera | ⬜ |
| **T1** | Laboratorio: a01, a02 (+ compose), a05 (+ generador), a06 | 4 | densa | ⬜ |
| **T2** | a09 y Bloque 0: F00, F01, F02 | 4 | normal | ⬜ |
| **T3** | Bloque I, primera mitad: F03, F04, F05 | 3 | normal | ⬜ |
| **T4** | Bloque I, segunda mitad: F06, F07, F08 y 💀 boss I | 3 | normal | ⬜ |
| **T5** | Bloque II, primera mitad: F09, F10, F11 | 3 | normal | ⬜ |
| **T6** | Bloque II, segunda mitad: F12, F13, F14 y 💀 boss II | 3 | normal | ⬜ |
| **T7** | Bloque III, primera mitad: F15, F16 | 2 | normal | ⬜ |
| **T8** | Bloque III, segunda mitad: F17, F18 y 💀 boss III | 2 | normal | ⬜ |
| **T9** | Bloque IV: F19, F20, F21 y 💀 boss IV | 3 | normal | ⬜ |
| **T10** | F22: la exportación, CDC y la cola en la base | 1 | normal | ⬜ |
| **T11** | F23: PostgREST y RLS, 💀 boss V y 💀☕ boss del puente (Java 21 y Artemis) | 1 | densa | ⬜ |
| **T12** | Bloque VI: F24, F25, F26 y el cierre de 🏆 "Un martes" | 3 | normal | ⬜ |
| **T13** | Track SQL Server: ss01–ss05 y ssa-01 | 6 | densa | ⬜ |
| **T14** | a10 (+ extraer la prueba del Access de `zz-code/`) y cierre de a03, a04, a07, a08 | 1 | normal | ⬜ |
| **T15** | Los README y la estructura, aparte: el README del curso, los de `src/` y `0-ESTRUCTURA-CURSO.md` | 2 | ligera | ⬜ |
| **T16** | Cierre: verificación global, borrar plan y propuesta | — | ligera | ⬜ |

**Total: 91 documentos del curso** (27 fases, 11 apéndices, 5 fases de track, **43 solucionarios**
—uno por cada uno de esos documentos, todos con ejercicios—, los 2 de raíz que crecen con el curso
—`INSTINTOS.md` y `bitacora-de-medicion.md`—, los 2 que se escriben en T15
—`0-ESTRUCTURA-CURSO.md` y el README— y la historia), más los 13 documentos de `prompts/` que
existen durante la producción (2 de ellos desechables), los dos scripts del verificador y el código
de `src/`.

**Por qué el track va después del Bloque VI:** es opcional y depende del camino base hasta F18. Se
puede adelantar a después de T8 si hay un motivo (un vídeo, un lector de un shop .NET), sin tocar
ninguna otra tanda.

**Por qué a09 va en T2 y no en T1:** no bloquea el laboratorio, pero la regla de publicación se usa
desde F03, y conviene que el texto de la licencia esté citado antes.

---

## 4. 🔍 Las verificaciones

Se corren al cerrar cada tanda, y todas en T16.

**El verificador del curso**, desde la raíz de `ruta-sql/` (guía §19.4):

```bash
python3 prompts/verificar-corpus.py                 # enlaces, anclas, restos, ejercicios, palabras, diagramas
python3 prompts/verificar-corpus.py --publicacion   # además, prompts/ y material privado (E9)
```

- Reemplaza el script de enlaces y anclas que estaba aquí hasta el 06/10/2026, que calculaba mal las
  anclas de los encabezados con ⚠️, ⚖️ o 🗂️ (el U+FE0F que GitHub conserva).
- Su aviso `README` salta si `README.md` o `0-ESTRUCTURA-CURSO.md` aparecen antes de T15; T15 cambia
  `ESCRITOS_LOS_README` a `True`.
- Cada bloque `mermaid` nuevo se dibuja con `mmdc` antes de publicarlo (D-12, guía §19.1).

**Ningún documento del curso cita un desechable**, desde la raíz de `ruta-sql/`:

```bash
grep -ln "_desechable-" *.md    # no debe devolver nada
```

**Ningún README cambió fuera de T15**, desde la raíz de `ruta-sql/` (solo lectura: git lo maneja
Oskar):

```bash
git status --short -- ':(glob)**/README.md'    # fuera de T15 no debe devolver nada
ls 0-ESTRUCTURA-CURSO.md 2>/dev/null             # antes de T15 no debe existir
```

**Ejercicios contra la propuesta y longitud del cuerpo:** los dos los cuenta el verificador
(`EJERCICIOS`, `NUMERACION` y `PALABRAS`), contra la propuesta §11 y §10 y la banda de la guía §9.

**Ningún número de Oracle ni de SQL Server**: no hay forma de automatizarlo bien. Al cerrar cada
fase se relee cada mención de Oracle y de SQL Server y se confirma que va como 🪞🔒, como estructura
de plan o como mensaje de error.

**URL externas**, por código de estado y sin seguir a ciegas las redirecciones: aterrizar en la
portada de la documentación cuenta como roto.

---

## 5. 📦 Las tandas, una por una

Lo que cada documento escribe, pesa y arriesga está en su ficha y en su prompt. Aquí va solo lo que
no cubren: por qué la tanda va en ese lugar y cuándo está terminada.

### P1 a P6 — Los documentos de `prompts/`

Escritos el 2026-09-30, en este orden: el alcance primero, porque decide el qué; la guía, porque
todo lo demás la cita; las propuestas, que fijan nombres, horas y ejercicios; las plantillas; los
prompts, que citan las fichas en lugar de copiarlas; y este plan. Si uno cambia, se corrigen después
los que cuelgan de él, **nunca al revés**.

### P7 — Decisiones

Cerradas por Oskar el 2026-09-30 sobre la tabla de la propuesta de fases §12. Cambiaron respecto de
lo propuesto: **D3** (el puente Java pasa a ser un boss y F22 queda en SQL y Python), **D4** (S y M
por defecto, M acotado por 16 GB), **D9** (se suma el boss del puente), **D10** (palabras completas
y convención habitual de SQL), **D11** (Java solo en el boss y en `a10`), **D12** (última estable o
LTS a la fecha de la verificación) y **D13** (`legacy` donde hace falta).

### P8 — Verificación de laboratorio

**Entrega:** `prompts/verificacion-de-laboratorio/hallazgos.md` (formato de la Lite: `H1`, `H2`…).
Los scripts, el `compose.yaml` de prueba y los *logs* van a un directorio de `zz-code/` (regla 10),
con su `README.md` de corrida y medición; `hallazgos.md` lo nombra. **Qué se verifica:**

- **las versiones según D12** (la última estable, o la última LTS donde el fabricante tenga esa
  línea: MySQL y Java), con la fecha de la comprobación;
- las imágenes de Postgres, MySQL, Oracle Free, MongoDB, Artemis, PostgREST y SQL Server: digest,
  arranque, *healthcheck*, **memoria en reposo y con el perfil M cargado**;
- **Oracle Free en arm64**: si corre nativo o necesita emulación, y cuánto tarda en estar listo;
- **SQL Server con Rosetta en Docker Desktop y en Podman** (riesgo declarado en el alcance §8);
- la tabla de RAM: qué combinaciones de perfiles entran en 16 GB;
- los drivers de Python de los tres motores, con transacciones y `autocommit`, y la elección del de
  MySQL;
- **el prototipo del generador**: que produce la suciedad con las proporciones de la historia, que
  guarda la verdad y que los perfiles S y M se cargan en un tiempo razonable (D4);
- las funciones que las fases dan por supuestas en la versión elegida: `uuidv7()`, `WITHOUT
  OVERLAPS`, *skip scan*, `pg_hint_plan` disponible, `pgstattuple`, `pg_trgm`, `pgvector`.

**Terminada cuando** todas tienen un hallazgo con fecha, y lo que no funciona tiene alternativa
decidida. Solo macOS arm64 es obligatorio; Linux y WSL2 quedan como pendiente transversal, igual que
en la Lite.

### P9 — Fuentes base

Edición y año de los seis libros de la guía §11, comprobados una vez en páginas de la editorial o
del autor. **Los capítulos concretos no se fijan aquí**: se comprueban en la tanda que los cita. Y el
texto vigente de las licencias de Oracle Database Free y de SQL Server en lo que toca a divulgar
resultados, con enlace y fecha, para `a09`.

### P10 — Traslado de las decisiones

Hecho el 2026-09-30: lo decidido en P7 pasó a alcance §9, §7.1, §11, §12 y §13, a la guía §5, §10.1,
§12 y §18, a las dos propuestas y a los prompts de fase y de apéndice. La propuesta de fases queda
como temario y registro.

### P11 — Traslado de lo verificado

Lo que salga de P8 y P9 pasa a su sitio: versiones y digests a `a02` (y a la guía §18, que hoy dice
que están sin fijar), conteos de los perfiles a `a05` y al alcance §7.1, el driver de MySQL a la
propuesta de apéndices §14, las ediciones de los libros a la guía §11, y cualquier función de
Postgres que no exista en la versión elegida a la ficha de la fase que la usaba. **Terminada cuando**
ningún documento de `prompts/` dice "a verificar" sobre algo que P8 o P9 ya verificaron, y §4 sale
limpia sobre `prompts/`.

### T0 — Arranque

**Entrega:** los esqueletos de `INSTINTOS.md`, `bitacora-de-medicion.md`,
`a08-catalogo-de-errores.md`, `a03`, `a04` y `a07`, con su encabezado y la nota "crece con el
curso", **sin enlaces** a fases que todavía no existen; y `src/.gitignore`, el único del curso (guía
§19.5). `0-ESTRUCTURA-CURSO.md` **no** se crea aquí:
va en T15 (regla 3).

### T1 — Laboratorio

a01, a02, a05 y a06, en ese orden, más `src/lab/compose.yaml` y `src/lab/generator/`. **Terminada
cuando** `lab up`, `lab load --profile m` y `lab measure` corren en macOS arm64 con los tres motores,
y la prueba de fuego de F01 da el número del generador.

### T2 a T9 — El camino base hasta el Bloque IV

Una tanda por medio bloque, en orden. Cada tanda que cierra un bloque (T4, T6, T8, T9) incluye su
💀 boss, con el sistema roto de partida en `src/` y la solución fuera del repositorio publicado,
como en la Lite. **Terminadas cuando** sus fases pasan la guía §16, los documentos vivos están al
día y §4 sale limpia.

### T10 y T11 — La base en la red

T10 es normal: F22 trabaja con Postgres, Python y la decodificación lógica, que ya están en el
laboratorio. T11 es densa porque suma dos perfiles del compose: `api` (PostgREST) y `puente` (Artemis
y el servicio Java 21 del boss del puente). Los dos se verifican antes de escribir.

### T12 — El árbitro

**Terminada cuando** cada argumento de F24–F26 cita su entrada de la bitácora, y el 🏆 "Un martes"
cierra con la facturación corriendo sobre la base nueva.

### T13 — El track

Opcional y movible (§3). Densa por la emulación.

### T14 — El museo y los apéndices que crecen

`a10` copia la prueba de concepto de `zz-code/ruta-sql-20261006-fc2f/accdb-museo/` a
`src/a10-el-access-de-museo/` (sin `lib/` ni `out/`) y vuelve a ejecutar todo; su `README.md` se
copia **sin editarlo**, y se reescribe en T15. El directorio de `zz-code/` pasa a *extraído* en §9. `a03`,
`a04`, `a07` y `a08` se cierran: índice completo y ejercicios finales. `a08` llega a cincuenta
entradas o dice cuántas le faltan.

### T15 — Los README y la estructura

Una tanda propia, **después de que todo el contenido exista**, porque un README o un temario escritos
a medias describen un curso que no es el que se publica. Escribe:

- `0-ESTRUCTURA-CURSO.md`: el temario en una página, con horas, ejercicios, estado real y enlace a
  cada fase, apéndice y boss (como el `0-ESTRUCTURA-CURSO.md` de la Lite). Sale de la propuesta de
  fases §11 y de §3 de este plan, que dejan de ser el mapa;
- el `README.md` de la raíz del curso (qué es, para quién, cómo se sigue, el track y los apéndices);
- los README de `src/`, incluido el que `a10` trajo de `zz-code/` sin editar.

Salda toda la deuda de §6 dirigida a T15. **Terminada cuando** los tres describen lo que existe y
sus enlaces pasan §4.

### T16 — Cierre

**Terminada cuando** §4 sale limpia en todo el curso, las URL externas están verificadas, ningún
directorio de `zz-code/` queda *vigente* en §9, los contenedores del curso están borrados con sus
volúmenes, y —con permiso de Oskar— `_desechable-propuesta-ruta.md` está borrado sin menciones. Este
plan se conserva en `prompts/` como referencia, salvo que Oskar pida borrarlo.

---

## 6. 🧾 Deuda de enlaces abierta

Cada mención en prosa que espera a que exista su destino. Formato: origen → destino → tanda que la
cierra.

| Origen | Destino pendiente | La cierra |
|---|---|---|
| — | — | — |

---

## 7. 📓 Bitácora

Una entrada por sesión, la más reciente arriba: qué se cerró, qué quedó a medias y por qué, qué se
comprobó y cómo, y las trampas que la próxima sesión debe conocer.

**2026-10-06 · D-05 cerrada: solucionario aparte (D18).** Pedido de Oskar: *"ejercicios con solución
en archivo separado, deja anotada la solución donde corresponda"*. Todo ejercicio —de fase, apéndice
y track— lleva solución en `soluciones/<mismo-nombre>.md`, escrita y ejecutada en la misma sesión
que su documento: completa en 🟢 y 🟡, de referencia con rúbrica en 🟠 y 🔴, sin números de Oracle ni
de SQL Server. **Confirmado por Oskar el mismo día:** los boss siguen sin publicar su solución (es un
encargo, no un ejercicio). Trasladado a alcance §12 (11) y §12.1 (D-05), propuesta
de fases §2 y §12 (D18), propuesta de apéndices, guía §5.2, §10, §10.3 nueva, §16, §17 (excepción 9
retirada) y §19, plantillas (plantilla de solucionario nueva), contrato §3, los marcos de los prompts,
el README de `prompts/`, el verificador (`SOLUCIONARIO` y `ENLACE-SOL`) y este plan (regla 1, §2.1,
§3, §8). **Trampa:** el ancla de vuelta desde la solución al ejercicio es la del encabezado completo
(`#-ejercicio-1--contar-…`), no `#ejercicio-1`; la de ida, a `soluciones/`, sí es `#ejercicio-1`.

**2026-10-06 · P12. Revisión contra los lineamientos de producción.** Pedido de Oskar: *"revisión
final de que ruta-no-sql-lite y ruta-sql se pliegan a la estructura de zz-instrucciones, y los
ajustes en sus directorios prompts, nombres de archivos de historia, contenido…"*. **Decisiones de
Oskar:** D-03 editorial sin enlaces, D-12 Mermaid obligatorio, mover `taller/accdb-museo/` a
`zz-code/` (alcance §12.1). **Por defecto, a revisar:** que los ejercicios no traigan solución
publicada (guía §17, excepción 9). **Hecho:** diccionario, contrato de nombres (con ⏳ para lo que fija
T1), `prompts/README.md`, verificador (`verificar-corpus.py` sobre `verificador_base.py`), guía §17
(excepciones 8 y 9) y §19, alcance §12.1 y §15, y este plan (reglas 9 y 10, §4 con el verificador, §9).
La historia de Alameda dejó de ser borrador: encabezado con `Vigencia`, sin citas a `prompts/` ni a
otros cursos, un emoji por sección y la §9 ("lo que el borrador no decide", ya decidido) reescrita
como "cómo usa el curso esta historia". `taller/accdb-museo/` → `zz-code/ruta-sql-20261006-fc2f/`,
con su README de corrida; `taller/` ya no existe. Las instrucciones de "enlazar" la Lite y el curso de
Docker pasaron a "nombrar en prosa". **Corregido:** la guía §9 ponía el track en la banda de 10 h; la
propuesta le da 8 h por fase. **Comprobado:** `verificar-corpus.py` 0/0 en los dos modos. **No se
ejecutó** nada del laboratorio. **Recursos levantados:** ninguno. **`zz-code/`:**
`ruta-sql-20261006-fc2f/` (vigente hasta T14). **Tags para el autor:** ninguno. **Siguiente:** T0, y
P8 y P9 en sus propias sesiones.

**2026-09-30 · La estructura, al final.** Por decisión de Oskar, `0-ESTRUCTURA-CURSO.md` sigue la
regla de los README: se escribe en T15 y ninguna otra tanda lo crea ni lo toca. Hasta entonces el
mapa son los desechables (§3 de este plan y la propuesta de fases §11). T0 baja a seis esqueletos.
Declarado como excepción al `CLAUDE.md` en la guía §17.

**2026-09-30 · P7 y P10. Decisiones cerradas y trasladadas.** Oskar cerró D1–D16. Las que cambiaron
respecto de lo propuesto están en §5, P7; la más visible es **D3**: el puente Java con Artemis deja
de ser el laboratorio de F22 y pasa a ser un **boss propio, "El puente"**, al cierre del Bloque V
junto al boss V, pedido por Matías. F22 queda en SQL y Python, mide la cola dentro de la base y deja
la pregunta "¿hacía falta un broker?" como deuda para ese boss. T10 baja a normal y T11 sube a densa.
**D4** fija S como perfil por defecto de `lab load` y M acotado por 16 GB; **D10**, palabras
completas con el límite de 63 bytes de Postgres y los sufijos de restricción por defecto; **D13**,
`legacy` en Postgres siempre y por tablas en los otros dos. P10 se partió: las decisiones ya están
trasladadas, y el traslado de lo verificado pasa a una tanda nueva, **P11**. La regla 7 ahora exige
a cada tanda solo la preparación que necesita: **T0 ya puede empezar**; T1 espera a P8 y P11, y T2 a
P9. **Siguiente:** T0 en una sesión nueva, y P8 y P9 en sus propias sesiones.

**2026-09-30 · Regla de los README.** Por pedido de Oskar, los README van en una tanda final y
aparte (T15), y **ninguna otra tanda los toca**, ni el de la raíz ni los de `src/`. El cierre pasa a
T16. La regla quedó en §1 (regla 3), §4 (verificación con `git status`), la guía §14 y §16, las
plantillas y los marcos de los prompts de fase y de apéndice. P7–P10 siguen abiertas.

**2026-09-30 · P1–P6.** Discutido el temario con Oskar sobre la propuesta de diseño y la historia de
Alameda, y escritos los ocho documentos de `prompts/` que no son desechables, más este plan: alcance,
guía (derivada de la de la NoSQL Lite, con la regla de publicación por licencia como divergencia
principal), propuestas de fases (27 fases, 252 h, 634 ejercicios) y de apéndices (10 más `ssa-01`),
plantillas (cinco), prompts de fase, de apéndice y del track. Los prompts **citan las fichas de la
propuesta en lugar de copiarlas**, para que no se desincronicen. Reubicados: la historia pasó a
`00-historia-de-alameda.md` (con su nota de estado al día) y la propuesta de diseño a
`prompts/_desechable-propuesta-ruta.md`. **No se tocó `taller/accdb-museo/`**: pasa a `src/` en T14.
Decisiones D1–D16 escritas con el valor recomendado y **pendientes de Oskar**; se escribió con esos
valores. Nada ejecutado todavía: ninguna versión, ningún número. **Siguiente: P7** (Oskar), y en
paralelo se puede empezar **P8**, que no depende de P7 salvo en D4 y D12.

---

## 8. ✅ Checklist final

Se marca `[x]` al cerrar cada punto. Una tanda se marca terminada solo cuando todos sus puntos lo
están, y entonces se cambia su estado en §3.

### Preparación (`prompts/`)

- [x] P1 · `prompts/guia-de-estilo-y-convenciones.md`
- [x] P2 · `prompts/alcance-del-proyecto.md`
- [x] P3 · `prompts/propuesta-fases-y-alcance.md` y `prompts/propuesta-apendices-y-alcance.md`
- [x] P4 · `prompts/plantillas-de-capitulo.md`
- [x] P5 · `prompts/prompts-de-fase.md`, `prompts/prompts-de-apendice.md` y `prompts/prompts-sqlserver-fase.md`
- [x] P6 · `prompts/_desechable-plan-de-produccion.md`
- [x] P7 · D1 · D2 · D3 · D4 cerradas
- [x] P7 · D5 · D6 · D7 · D8 cerradas
- [x] P7 · D9 · D10 · D11 · D12 cerradas
- [x] P7 · D13 · D14 · D15 · D16 cerradas
- [ ] P8 · Versiones según D12, con fecha
- [ ] P8 · Imágenes y digests de los siete servicios, con memoria medida
- [ ] P8 · Oracle Free en arm64 y SQL Server con Rosetta (Docker y Podman)
- [ ] P8 · Tabla de RAM en 16 GB
- [ ] P8 · Drivers de Python y elección del de MySQL
- [ ] P8 · Prototipo del generador: suciedad, verdad y perfiles S y M
- [ ] P8 · Funciones de Postgres que las fases dan por supuestas
- [ ] P9 · Edición y año de los seis libros base
- [ ] P9 · Texto de las licencias de Oracle Free y SQL Server sobre divulgación de resultados
- [x] P10 · Decisiones trasladadas; ⏳ del alcance cerradas; §4 limpia sobre `prompts/`
- [ ] P11 · Lo verificado en P8 y P9 trasladado; nada "a verificar" que ya esté verificado; los ⏳
      del contrato de nombres que dependen de P8, fijados
- [x] P12 · `prompts/diccionario-de-terminos.md` y `prompts/contrato-de-nombres.md`
- [x] P12 · `prompts/README.md`, `prompts/verificar-corpus.py` y `prompts/verificador_base.py`
- [x] P12 · Guía §17 (excepciones 8 y 9) y §19; alcance §12.1 (D-01–D-13) y §15
- [x] P12 · La historia sin citas a `prompts/` ni a otros cursos; `taller/` en `zz-code/`
- [x] P12 · D-05 cerrada por Oskar: solución en archivo separado (D18, guía §10.3); excepción 9 retirada

### T0 — Arranque

- [ ] Esqueletos de `INSTINTOS.md`, `bitacora-de-medicion.md` y `a08`
- [ ] Esqueletos de `a03`, `a04` y `a07`
- [ ] `src/.gitignore`, el único del curso

### T1 — Laboratorio

- [ ] a01 · Laboratorio contenerizado
- [ ] a02 · El `compose.yaml` de la ruta, con `src/lab/compose.yaml`
- [ ] a05 · La caja y el generador, con `src/lab/generator/`
- [ ] a06 · Python, Java y los drivers
- [ ] `lab up`, `lab load --profile m` y `lab measure` corridos en macOS arm64

### T2 — a09 y Bloque 0

- [ ] a09 · Licencias, publicación y riesgo
- [ ] F00 · La base que nadie diseñó
- [ ] F01 · La caja y el arnés, con la prueba de fuego corrida
- [ ] F02 · Las cinco preguntas, desde el otro lado
- [ ] Solucionarios y documentos vivos al día · §4 limpia

### T3 — Bloque I, primera mitad

- [ ] F03 · Lo que SQL le hace al modelo relacional
- [ ] F04 · Un valor, un hecho (fija el formato de la tabla de rechazos)
- [ ] F05 · Una persona no es su documento
- [ ] Solucionarios y documentos vivos al día · §4 limpia

### T4 — Bloque I, segunda mitad

- [ ] F06 · Cuarta y quinta forma normal
- [ ] F07 · El tiempo en el modelo
- [ ] F08 · Los dos extremos del mismo error
- [ ] 💀 Boss I · La señora que es tres pacientes
- [ ] Solucionarios y documentos vivos al día · §4 limpia

### T5 — Bloque II, primera mitad

- [ ] F09 · El tamaño de las cosas
- [ ] F10 · Identificadores (deja la deuda del IDOR para F23)
- [ ] F11 · Índices y lo que cuestan
- [ ] Solucionarios y documentos vivos al día · §4 limpia

### T6 — Bloque II, segunda mitad

- [ ] F12 · Estadísticas y cardinalidad
- [ ] F13 · El optimizador en tres motores
- [ ] F14 · La base no estaba lenta
- [ ] 💀 Boss II · El portal de 2018
- [ ] Solucionarios y documentos vivos al día · §4 limpia

### T7 — Bloque III, primera mitad

- [ ] `lab race` descrito en a04 y funcionando
- [ ] F15 · Aislamiento comparado
- [ ] F16 · El folio sin huecos
- [ ] Solucionarios y documentos vivos al día · §4 limpia

### T8 — Bloque III, segunda mitad

- [ ] F17 · MVCC y su factura
- [ ] F18 · Bloqueos, deadlocks y DDL
- [ ] 💀 Boss III · Una tarde de julio
- [ ] Solucionarios y documentos vivos al día · §4 limpia

### T9 — Bloque IV

- [ ] F19 · JSON en los motores
- [ ] F20 · La propuesta de Florencia, medida
- [ ] F21 · Hasta dónde llega el motor
- [ ] 💀 Boss IV · El informe en la app
- [ ] Solucionarios y documentos vivos al día · §4 limpia

### T10 — F22

- [ ] F22 · La exportación de las 9:40 (sin Java: la pregunta del broker queda para el boss del puente)
- [ ] Solucionarios y documentos vivos al día · §4 limpia

### T11 — F23

- [ ] Perfiles `api` (PostgREST) y `puente` (Artemis y Java 21) del compose verificados
- [ ] F23 · La base como producto (cierra la deuda de F10 y la de F22)
- [ ] 💀 Boss V · Las 9:40
- [ ] 💀☕ Boss del puente · El puente, con "¿hacía falta un broker?" medido
- [ ] Solucionarios y documentos vivos al día · §4 limpia

### T12 — Bloque VI

- [ ] F24 · El diseño
- [ ] F25 · La migración sin parar
- [ ] F26 · El comité
- [ ] 🏆 Boss global "Un martes", cerrado
- [ ] Solucionarios y documentos vivos al día · §4 limpia

### T13 — Track SQL Server

- [ ] Perfil `sqlserver` verificado con emulación
- [ ] ss01 · La base en su motor original
- [ ] ss02 · Pesimista contra RCSI
- [ ] ss03 · Query Store y parameter sniffing
- [ ] ss04 · Clustered, NEWSEQUENTIALID y tablas temporales
- [ ] ss05 · Data API builder y el tipo json
- [ ] ssa-01 · Qué cambia en Windows
- [ ] Solucionarios de `ss01`–`ss05` y `ssa-01` · §4 limpia

### T14 — El museo y los apéndices que crecen

- [ ] a10 · El Access de museo, con la prueba de `zz-code/ruta-sql-20261006-fc2f/accdb-museo/` extraída a `src/a10-el-access-de-museo/` y vuelta a ejecutar
- [ ] a03, a04 y a07 cerrados
- [ ] a08 con cincuenta entradas, o con lo que falta dicho
- [ ] Solucionarios de a03, a04, a07, a08 y a10 completos con sus ejercicios finales

### T15 — Los README y la estructura

- [ ] `0-ESTRUCTURA-CURSO.md`, con el estado real
- [ ] `README.md` del curso
- [ ] README de `src/`, incluido el de `src/a10-el-access-de-museo/`
- [ ] Deuda de §6 dirigida a T15, saldada
- [ ] `ESCRITOS_LOS_README = True` en `prompts/verificar-corpus.py`

### T16 — Cierre

- [ ] §4 limpia en todo el curso; URL externas verificadas
- [ ] Contenedores del curso borrados con sus volúmenes, comparados contra el inventario inicial
- [ ] `zz-code/`: ningún directorio del curso *vigente* en §9; cada uno con su `README.md` completo;
      vista previa de `zz-code/limpiar.py` mostrada a Oskar
- [ ] Con permiso de Oskar: `_desechable-propuesta-ruta.md` borrado, menciones limpias; este plan se
      conserva salvo que Oskar pida borrarlo

### E9 — Publicación

- [ ] `python3 prompts/verificar-corpus.py --publicacion` sin errores
- [ ] README que se sostiene solo; licencia; `.gitignore` del repositorio público
- [ ] Ningún secreto ni dato personal en el código ni en los ejemplos
- [ ] Oskar copió la carpeta sin `prompts/` a su repositorio público

---

## 9. 🧪 Directorios de `zz-code/`

Cada directorio de código intermedio de las sesiones de este curso, con su estado (*vigente*,
*extraído* o *archivado*). El detalle, en su `MANIFIESTO.md`; cómo se corre, en su `README.md`.

| Directorio | Tanda | Qué se probó | Estado | README completo | Regenerable liberado |
|---|---|---|---|---|---|
| `zz-code/ruta-sql-20261006-fc2f/` | diseño (29/09/2026), mudado en P12 | la prueba de concepto del Access de museo (`accdb-museo/`), el script que alineó la historia y la prueba del chequeo de solucionarios del verificador | vigente hasta T14 | sí | no (`lib/` y `out/`, 12 MB) |
