# 🗺️ Prompts iniciales — Ruta NoSQL 2026

Carpeta con el prompt de arranque de cada tutorial de la ruta, más la guía de
estilo que todos comparten. Cada archivo `.md` de tecnología trae: el **prompt**
listo para pegar en un chat nuevo, más **recomendaciones** de contexto,
anti-patrón y arnés de medición para ese motor.

## Cómo usar cada prompt

Cada archivo `NN-*.md` trae, en este orden: recomendaciones de contexto, la
descripción del proyecto grande, **los dos campos para la base del proyecto de
Claude** (descripción breve + instrucciones/custom instructions, listos para
copiar) y el **prompt inicial** del primer chat.

1. Crea un proyecto de Claude para la tecnología.
2. Pega en la config del proyecto la **Descripción** y las **Instrucciones del
   proyecto** del archivo (sección 📌).
3. Sube al proyecto `GUIA-DE-ESTILO-TRANSVERSAL.md`, `RUTA-NOSQL-2026.md`,
   `LENGUAJES-DE-INTERFAZ.md` y `PLANTILLA-SEMILLA.md` (para Proteo, además
   `PROTEO-SEMILLA.md`).
4. Abre un chat y pega el **prompt inicial** del archivo.
5. El chat devuelve **primero un documento semilla** (`NN-<CURSO>-SEMILLA.md`):
   dominio, stack, marco de decisión, "vs" y estructura de fases. Lo discutes y
   consolidas.
6. Con la semilla pactada, das visto bueno y recién ahí el chat redacta la
   Fase 0.

> Las **instrucciones del proyecto** (custom instructions) fijan rol, fuentes de
> verdad, método (semilla → fases con aprobación), estilo y no-negociables para
> *todos* los chats del proyecto. El **prompt inicial** arranca el primer chat.
> Son complementarios: las primeras persisten, el segundo inicia.

> El **documento semilla** es el primer entregable de cada curso: captura la
> decisión antes que la escritura. Su anatomía está en `PLANTILLA-SEMILLA.md`, y
> `PROTEO-SEMILLA.md` es el ejemplar de referencia. Proteo ya tiene la suya
> escrita, así que su chat la *consolida* en vez de generarla desde cero.

## Orden de los archivos (prioridad de redacción / progresión pedagógica)

| Archivo | Familia | Lenguaje de interfaz | Nota de prioridad |
|---|---|---|---|
| `00-PROTEO-documental.md` | 🍃 Documental | TS + Java/Spring | **Primero a redactar** (dominio y stack ya cerrados) |
| `01-PORTALON-clave-valor.md` | 🔑 Clave-valor | Go (exclusivo) | Arranca la progresión pedagógica |
| `02-CRISTALERIA-analitico-embebido.md` | 🦆 Analítico embebido | Python + Rust 🔥 | |
| `03-ORACULO-DE-BOLSILLO-vectorial.md` | 🧬 Vectorial | Python + Rust 🔥 | **#1 por mercado** |
| `04-TELARANA-grafos.md` | 🕸️ Grafos | C#/.NET (exclusivo) | |
| `05-CENTINELA-DE-FLOTA-columnar-ancha.md` | 🏛️ Columnar ancha | Java (exclusivo) | |
| `06-BUSCAFINO-busqueda.md` | 🔍 Búsqueda | Elixir (exclusivo) | |
| `07-BITACORA-DE-CAMPO-offline-first.md` | 📴 Offline-first | Elixir/Phoenix + Kotlin | **#2 por mercado** · CouchDB ≠ Couchbase |
| `08-EL-VIGIA-series-temporales.md` | ⏱️ Series temporales | Elixir (exclusivo) | |
| `09-LIBRO-MAYOR-newsql-distribuido.md` | ⚡ NewSQL/distribuido | Java (exclusivo) | |
| `10-EL-ARBITRO-poliglota-capstone.md` | ⚖️ Políglota | Go + Java + Python | **Cierre de ruta** (vs arquitectónico) |

> El lenguaje de interfaz de cada curso, su justificación y el control de
> cobertura de ecosistemas están en `LENGUAJES-DE-INTERFAZ.md`.

> Dos prioridades conviven en la ruta: **pedagógica** (recalibra el instinto más
> rápido: Portalón → … → Árbitro) y **por mercado** (Oráculo > Bitácora > Proteo
> > Portalón > Telaraña). La numeración de archivos sigue la de la lista maestra
> con Proteo al frente por ser el primero a escribir. Cada archivo anota ambas
> prioridades.

## Molde común de los 11 prompts

Todos piden lo mismo, adaptado a la familia:

- **Rol** de ingeniero senior que ya operó ese motor en producción + diseñador instruccional.
- **Justificación y audiencia** (senior SQL, modelo de acceso que dura, criterio sobre hype).
- **Ruta ≤ 120 h** teórico-prácticas en fases.
- **Proyecto grande** (el que la ruta ya asigna a esa familia) + **mini-proyecto por sección**.
- **Guía de estilo** (formato, español + código nativo del motor + **lenguaje de interfaz del curso** para app y arnés, ejercicios 🟢🟡🟠🔴, 5 pilares).
- **Dos campos para la base del proyecto de Claude**: descripción breve + instrucciones del proyecto (custom instructions con rol, fuentes de verdad, método y no-negociables).
- **Anti-patrón ⚰️** propio + **arnés "vs"** con `scripts/vs.*` + **árbol de decisión ⚖️**.
- **Descripción del proyecto** (dominio y mini-proyectos) e **instrucciones del proyecto** (reglas de construcción del dominio).
- Cierra pidiendo como **primer entregable el documento semilla** (`NN-<CURSO>-SEMILLA.md`, ver `PLANTILLA-SEMILLA.md`), no las fases completas. Proteo consolida su semilla ya existente.
