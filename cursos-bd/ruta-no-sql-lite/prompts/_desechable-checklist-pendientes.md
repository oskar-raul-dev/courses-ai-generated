# 🗒️ Checklist de pendientes — Ruta NoSQL Lite

> ⛔ **OBSOLETO desde el 29/09/2026.** Sustituido por `_desechable-plan-de-tandas.md`, que
> tiene todo lo que aquí quedaba abierto. Se conserva solo como registro; se puede borrar.

> 🗑️ **Desechable.** Tu hoja de ruta personal para saber dónde vas. No se cita ni se enlaza
> desde ningún archivo del curso, y no hace falta mantenerla sincronizada con nada.
> **Creada:** 29/09/2026 · Marca `[x]` al terminar cada tarea.

---

## 1. 🧱 Andamiaje editorial (T1–T9)

- [x] T1 · `prompts/alcance-del-proyecto.md`
- [x] T2 · `prompts/guia-de-estilo-y-convenciones.md`
- [x] T3 · `prompts/propuesta-fases-y-alcance.md`
- [x] T4 · `prompts/propuesta-apendices-y-alcance.md`
- [x] T5 · `prompts/plantillas-de-capitulo.md`
- [x] T6 · `prompts/formato-bitacora-de-medicion.md`
- [x] T7 · `prompts/prompts-de-fase.md` (26 prompts)
- [x] T8 · `prompts/prompts-de-apendice.md` (10 prompts)
- [x] T9 · `README.md`
- [x] Extra · `prompts/analisis-modelos-no-sql.md`
- [x] Extra · `prompts/propuestas-historias.md`
- [x] Extra · `00-historia-de-condor.md`: la empresa del curso
- [x] Extra · `propuestas-mini-proyectos.md` y los diez `h-mini-01…10-*.md`

## 2. 🧹 Limpieza de desechables

- [x] Quitar las citas a `nuevas-ideas` / `plan-accion-creacion-docs-base` en:
  - [x] `prompts/prompts-de-fase.md`
  - [x] `prompts/plantillas-de-capitulo.md`
  - [x] `prompts/guia-de-estilo-y-convenciones.md`: regla y checklist §15 ahora genéricos
        sobre `_desechable-*`
- [x] Rescatar lo que valga: `nuevas-ideas.md` era copia idéntica de
      `propuestas-cursos/nuevas-ideas.md`, así que no se perdió nada. Del plan solo faltaba
      la "hipoteca de mantenimiento", que ahora está en el alcance §6
- [x] Borrar `plan-accion-creacion-docs-base.md`
- [x] Borrar `nuevas-ideas.md`
- [x] Comprobación: el grep no devuelve nada, salvo este checklist

## 3. ❓ Decisiones abiertas

**Miniproyectos** (`propuestas-mini-proyectos.md` §6–7)
- [x] Encaje de horas: **opción A**, fuera de las 252 h y anunciados al abrir la fase B
- [x] Registrar el prefijo `h-mini-NN-` en la propuesta de fases §10 y en la guía §5.2
- [x] Tag de git propio `mini-NN-<slug>`: **sí** (guía y propuesta de fases §10)
- [x] ¿Archivo de historia propio para las cinco empresas? **No**
- [x] Cambiar el estado de `propuestas-mini-proyectos.md` a decidido

**Propagar Cóndor y los miniproyectos a los documentos base** (encontrado el 29/09)
- [x] `alcance-del-proyecto.md`: §7 reescrito sobre Cóndor y decisión 3 de §12 cerrada
- [x] Boss global unificado como **El Hangar** en todos los documentos
- [x] Miniproyectos dados de alta en alcance §13, guía §8, §9.3 y callouts, y en la
      plantilla de fase B
- [x] `prompts-de-fase.md`: cada fase B anuncia su `h-mini`; el marco suma la historia
- [x] Entidades renombradas 1:1: `vehicle`→`aircraft`, `failureReport`→`pirep`,
      `workshop`→`hangar`
- [x] Cada fase traducida a su dolor de Cóndor; F13/F14 como trazabilidad y F21/F22 como
      residencia de datos
- [x] Boss de bloque I–IV reescritos como encargos internos, con quién los pide
- [x] README: Cóndor, miniproyectos y nombre del boss
- [x] `propuestas-historias.md`: estado cerrado
- [x] Boss I–IV revisados y aprobados
- [x] Son cinco boss: el del Bloque V es "Las dos verdades" (reconciliar `SIGMA` y el
      sistema de Camilo); el Bloque 0 no lleva

**Técnicas** (guía §17, propuesta de fases §11): se resuelven midiendo, en T10
- [x] **Cassandra**, con el heap fijado (alcance §12, 16). La RAM no discriminó una vez
      fijado el heap; decidió la licencia de ScyllaDB (*source-available*)
- [x] **`iovalkey`** como cliente de Valkey (alcance §12, 17)
- [x] **`intfloat/multilingual-e5-small`** como modelo de embeddings (alcance §12, 18)

  Medición del 29/09 en macOS arm64 (VM de Docker con 7,75 GiB, en reposo, un nodo):
  Cassandra 5.0.9 con heap de 512M, 1,04 GiB y 60 s · Cassandra por defecto, 4,63 GiB
  y 66 s · ScyllaDB 2026.3.1 con 750M y 1 núcleo, 90 MiB y 6 s · ScyllaDB por defecto,
  420 MiB y 6 s.
  Digests: `cassandra@sha256:8819d1b7877e…` · `scylladb/scylla@sha256:705b9cc8d815…`

## 4. 🔬 T10 · Sesión de verificación de laboratorio

**Bloquea la publicación de la primera fase.** Todo lo de esta sesión vive en
`prompts/verificacion-de-laboratorio/`: `compose.yaml`, `medir.sh`, `comprobaciones/`,
`resultados-<plataforma>.tsv`, `logs-<plataforma>/` y **`hallazgos.md`**, que es el resumen.

**macOS arm64 — 29/09/2026**
- [x] Los diez motores levantados y medidos (tiempo hasta healthy y RAM en reposo)
- [x] CouchDB medido: 5 s y 99 MiB, con las bases de sistema creadas en el healthcheck (§H9)
- [x] Digests fijados de las diez imágenes (`resultados-darwin-arm64.tsv`)
- [x] RAM: las tres JVM ≈ 2,7 GiB con el heap limitado; el resto < 650 MiB (tabla en
      hallazgos). Base de la advertencia de RAM de `a02`
- [x] Errores literales anotados para `a09`: Mongo y kernel (§H1), timeout de descarga (§H2),
      worker de Timescale (§H4), candado de DuckDB (§H6) y bases de sistema de CouchDB (§H9)
- [x] **Mongo fijado en 8.0.20** por el kernel 7.0.12 de Docker Desktop (§H1), como parche
      temporal
- [x] Prueba de carga de Mongo 8.0.20 (10 min, 32 trabajadores): **aguantó**, con 19 323
      operaciones, 1,29 M de documentos, 0 fallos y 0 reinicios (§H1)
- [x] Cassandra con heap fijado: 62 s y 1,16 GiB; los 1190 s de la primera tanda eran
      congestión de Docker (§H3)
- [x] e5-small: paridad Python y `transformers.js` confirmada, con revisión `614241f6…`
      fijada (§H8)
- [x] iovalkey 0.4.0 contra Valkey 9.1.2: candado, Lua y pipeline OK (§H7)
- [x] DuckDB 1.5.6: proyección de columnas visible y error de candado literal (§H6)

**Otras plataformas**
Abiertas a propósito: se hacen cuando se trabaje en cada equipo.
- [ ] Linux: `./medir.sh` completo y la prueba de carga de Mongo (el kernel del host decide
      §H1)
- [ ] Windows 11 (WSL2): lo mismo, en el equipo con Windows

**Decisiones que abrió T10**
- [x] **CockroachDB multi-región:** `cockroach demo --nodes=9 --global` para F22 y el boss
      IV, un nodo para F21 (alcance §12, 19). Probado: 68 contra 133 ms, sin licencia y con
      1,71 GiB (§H10)
- [x] **TimescaleDB con TSL**, aceptada y declarada en `a10` y en el veredicto de F10
      (alcance §12, 20)
- [x] Prefijos de e5: pasan de "anti-patrón medible" a **apuesta falsable de F15** (§H8);
      alcance 18 y prompt de F15 corregidos
- [ ] Volver de Mongo 8.0.20 a la 8.0 vigente cuando Docker Desktop traiga un kernel
      7.0.14 o posterior

## 5. 📎 Apéndices

Antes de la primera fase:
- [x] `a01-laboratorio-contenerizado.md`: verificado en macOS; Linux, WSL2, Colima y Podman
      marcados como no ejecutados (hay que completarlos al verificar en esos equipos)
- [x] `a02-compose-de-la-ruta.md` + `src/lab/compose.yaml` y `.env.example`: persistencia
      de las diez familias, `newsql-global` con sidecar y combinaciones en 8 GB (§H11–H13);
      columna de 16 GB estimada, no medida
- [ ] `a05-el-dominio-de-flota.md`
- [ ] `a06-lenguajes-y-drivers.md`

Crecen con el curso:
- [ ] `a03-clis-de-los-motores.md`
- [ ] `a04-el-arnes-de-medida.md`
- [ ] `a08-diccionario-y-glosario.md`
- [ ] `a09-catalogo-de-errores.md`

Cuando toque su familia:
- [ ] `a07-postgres-linea-base.md`
- [ ] `a10-licencias-y-riesgo.md`

## 6. 📄 Documentos vivos y de estructura

- [ ] `0-programa-del-curso.md`: se escribe junto con la primera fase
- [ ] `INSTINTOS.md`
- [ ] `bitacora-de-medicion.md`
- [ ] `src/`: generador de datos (TypeScript), `compose.yaml` y arnés

## 7. 📚 Fases

**Bloque 0 · El instrumento**
- [ ] `00-la-decision-que-se-hereda.md`
- [ ] `01-el-dominio-de-flota-y-el-arnes.md`
- [ ] `02-las-cinco-preguntas.md`

**Bloque I · Los dos que ya usas**
- [ ] `03-documental-levantar-y-modelar.md`
- [ ] `04-documental-romper-y-medir.md`
- [ ] `05-clave-valor-levantar-y-modelar.md`
- [ ] `06-clave-valor-romper-y-medir.md`
- [ ] 💀 Boss del bloque I

**Bloque II · Leer de otra forma**
- [ ] `07-analitico-levantar-y-modelar.md`
- [ ] `08-analitico-romper-y-medir.md`
- [ ] `09-series-levantar-y-modelar.md`
- [ ] `10-series-romper-y-medir.md`
- [ ] `11-busqueda-levantar-y-modelar.md`
- [ ] `12-busqueda-romper-y-medir.md`
- [ ] 💀 Boss del bloque II

**Bloque III · Preguntas que no sabes escribir en SQL**
- [ ] `13-grafos-levantar-y-modelar.md`
- [ ] `14-grafos-romper-y-medir.md`: la fase más importante del curso
- [ ] `15-vectorial-levantar-y-modelar.md`: se publica en tercer lugar
- [ ] `16-vectorial-romper-y-medir.md`
- [ ] 💀 Boss del bloque III

**Bloque IV · Cuando el dato no cabe en un nodo**
- [ ] `17-columnar-levantar-y-modelar.md`
- [ ] `18-columnar-romper-y-medir.md`
- [ ] `19-offline-levantar-y-modelar.md`
- [ ] `20-offline-romper-y-medir.md`
- [ ] `21-newsql-levantar-y-modelar.md`
- [ ] `22-newsql-romper-y-medir.md`
- [ ] 💀 Boss del bloque IV

**Bloque V · El árbitro**
- [ ] `23-poliglota-el-diseno.md`
- [ ] `24-poliglota-la-costura.md`
- [ ] `25-poliglota-la-factura.md`
- [ ] 💀 Boss del bloque V — "Las dos verdades", va en F25
- [ ] 🏆 Boss global "El Taller", que cierra con el capstone

## 8. 🚀 Orden de publicación sugerido

1. Bloque 0 (F00–F02)
2. Documental (F03–F04)
3. Clave-valor (F05–F06)
4. Vectorial (F15–F16), adelantado a propósito
5. El resto, en el orden de aprendizaje
