# 🧩 Lenguajes de interfaz por tutorial — Ruta NoSQL 2026

> Cada tutorial suma un **lenguaje de interfaz** propio del ecosistema de su
> motor. La audiencia son devs backend senior: aprender un lenguaje sobre la
> marcha no es la dificultad, es parte del valor. El criterio no es "variar por
> variar", sino usar **el idioma con el que ese motor se opera de verdad en
> producción**, o el que mejor expone la lección del curso.

## Principios de asignación

1. **Encaje técnico primero.** Driver de primera clase, idiomático y mantenido —
   no un binding olvidado.
2. **El lenguaje ilumina el motor.** Se elige cuando enseña algo que otro
   idioma escondería (GC bajo alta escritura, actores para ingesta concurrente,
   etc.), no como decoración.
3. **Exclusivo vs convive con TS, según dónde viva la lección.** Si la lección
   está en el motor/arnés → el lenguaje nuevo es exclusivo. Si está en la
   orquestación o el frontend → convive con el TypeScript de pegamento.
4. **Cobertura sin sobrecarga.** Ningún ecosistema queda huérfano ni
   monopoliza; ver reparto al final.

---

## Tabla definitiva

| # | Curso | Familia | Lenguaje de interfaz | Modo | Por qué ese lenguaje |
|---|---|---|---|---|---|
| 00 | Proteo | 🍃 Documental | **TS/Node** (fijado) + **Java/Spring** como 2.º driver | Convive | Ya venía cerrado en TS. Java/Spring muestra el driver Mongo enterprise y ODMs tipados: contraste sano del mismo motor desde dos ecosistemas. |
| 01 | Portalón | 🔑 Clave-valor | **Go** | **Exclusivo** | Redis, Dragonfly y los gateways reales viven en Go. Un gateway con rate-limit, colas y leaderboard *es* el caso de uso canónico de Go. |
| 02 | Cristalería | 🦆 Analítico embebido | **Python** base · **Rust** en fase 🔥 | Convive (TS solo para el dashboard WASM) | Python es el idioma real del análisis de datos; Rust (Polars, binding DuckDB) como ampliación de rendimiento opcional. |
| 03 | Oráculo de Bolsillo | 🧬 Vectorial | **Python** base · **Rust** en fase 🔥 | Convive | El ecosistema de embeddings/IA es Python de facto; Rust (cliente Qdrant) para quien quiere bajar al metal. |
| 04 | Telaraña | 🕸️ Grafos | **C#/.NET** | **Exclusivo** | Neo4j tiene driver .NET de primera; el mundo de fraude/enterprise es muy .NET. Introduce un ecosistema que aún no aparece en la ruta. |
| 05 | Centinela de Flota | 🏛️ Columnar ancha | **Java** | **Exclusivo** | Cassandra *es* Java; el tuning de GC y el backpressure bajo alta escritura son parte de la lección, no decoración. |
| 06 | Buscafino | 🔍 Búsqueda | **Elixir** | **Exclusivo** | Refuerza el modelo BEAM (concurrencia, tolerancia a fallos) sobre indexación y consultas facetadas; deja .NET reservado a Telaraña. |
| 07 | Bitácora de Campo | 📴 Offline-first | **Elixir/Phoenix** (servidor sync) + **Kotlin** (cliente) | Convive | El sync tiene dos lados: Phoenix Channels para el servidor de replicación, Kotlin para un cliente móvil real que se va offline y reconcilia. |
| 08 | El Vigía | ⏱️ Series temporales | **Elixir** | **Exclusivo** | Ingesta concurrente masiva + alertas: el modelo de actores de la BEAM enseña algo que otro lenguaje escondería. |
| 09 | Libro Mayor | ⚡ NewSQL / distribuido | **Java** | **Exclusivo** | Mundo financiero-distribuido clásico sobre la JVM; el idioma del dominio pesa más que el driver (CockroachDB habla protocolo Postgres). |
| 10 | El Árbitro | ⚖️ Políglota (capstone) | **Go + Java + Python** (2–3 servicios) | Mixto/políglota | El capstone sobre componer sistemas debe ser políglota también en lenguajes: cada servicio en el idioma de su motor, y la factura de esa mezcla (operativa, cognitiva) es *parte de la lección*. |

**Leyenda de "Modo":**
- **Exclusivo** — el curso se escribe en ese lenguaje; no hay TS de pegamento.
- **Convive** — el lenguaje nuevo entra en las fases de app/driver; TS se queda para orquestación, arnés o frontend según el curso.
- **Mixto/políglota** — varios lenguajes conviven por diseño (solo el capstone).

---

## Reparto de ecosistemas (control de cobertura)

| Ecosistema | Cursos donde aparece | Total |
|---|---|---|
| **Go** | Portalón (01), El Árbitro (10) | 2 |
| **Java / JVM** | Proteo (00, 2.º driver), Centinela (05), Libro Mayor (09), El Árbitro (10) | 4 |
| **C#/.NET** | Telaraña (04) | 1 |
| **Python** | Cristalería (02), Oráculo (03), El Árbitro (10) | 3 |
| **Rust** | Cristalería (02, 🔥), Oráculo (03, 🔥) | 2 (opcionales) |
| **Elixir / BEAM** | Buscafino (06), Bitácora (07), El Vigía (08) | 3 |
| **Kotlin** | Bitácora (07, cliente) | 1 |
| **TypeScript** | Proteo (00), transversal como pegamento donde convive | transversal |

Sin ecosistema huérfano ni monopolizado. Elixir y Java son los más presentes,
pero cada aparición está justificada por encaje, no por relleno.

---

## Choques resueltos (para no reabrir)

- **Elixir pedía tres sitios** (Buscafino, Bitácora, Vigía). Se aceptan los tres:
  cada uno usa una faceta distinta de la BEAM (consultas facetadas concurrentes /
  servidor de sync con Channels / ingesta masiva con actores). No es repetición.
- **C#/.NET quedó solo en Telaraña** por decisión explícita, para no competir con
  Elixir en Buscafino.
- **Libro Mayor = Java** (no Go ni Rust): se prioriza el idioma del dominio
  financiero sobre la moda de infraestructura.
- **Proteo conserva TS** por estar ya fijado; Java/Spring entra como segundo
  driver, no como reemplazo.

---

## Cómo se refleja esto en cada prompt

En cada archivo `NN-*.md` se añade, dentro del bloque de prompt, una instrucción
de **lenguaje de interfaz** que:

1. Nombra el lenguaje y su modo (exclusivo / convive / políglota).
2. Pide que el driver/cliente usado sea el idiomático y mantenido de ese ecosistema.
3. Ajusta la regla de código de la guía de estilo: *lenguaje nativo del motor
   para lo que es del motor + el lenguaje de interfaz para la app/arnés* (en vez
   de "TS de pegamento" por defecto).
4. Mantiene los 5 pilares y la plantilla de 9 secciones intactos.

Y en `GUIA-DE-ESTILO-TRANSVERSAL.md` §3/§10 se generaliza la regla de idioma del
código para admitir el lenguaje de interfaz por curso, no solo TS.
