# 🔮 Proyecto Proteo — Idea inicial de stack y fases

> **Documento semilla.** Captura la decisión de dominio, stack y estructura
> de fases acordada para el curso "MongoDB moderno, no-legacy". Sirve como
> punto de partida para la redacción — igual que `TRACK-B-SEMILLA.md` lo fue
> para el curso anterior. Nada aquí es definitivo hasta que se redacte la
> fase correspondiente.

---

## 🎯 Por qué este curso existe

El curso anterior (`fase-00` → `fase-14`, Mini Jira / Track B) demostró un
caso real: **un sistema tipo Jira vota relacional 5-0**, y alguien lo
construyó en Mongo porque "el líder quería NoSQL". Ese curso enseñó a
diagnosticar y operar ese legacy con criterio.

Proteo es el **caso simétrico**: un dominio que vota **documento 5-0** de
verdad, construido desde cero con el stack de 2026, sin deuda legacy que
simular. Donde el curso anterior enseñaba a sobrevivir una mala decisión
ajena, este enseña a **reconocer y ejecutar bien la decisión correcta**.

Y a diferencia del curso anterior, aquí el rival (SQL) no es un enemigo de
paja: se construye **en paralelo**, se mide en cada fase, y gana en más de
un capítulo. El objetivo no es vender Mongo — es medir sin fanboyismo.

---

## 🏗️ El dominio: catálogo multi-vertical + PIM

Un marketplace con **4 verticales radicalmente heterogéneas**, cada una con
su propia forma de atributos:

| Vertical | Atributos distintivos |
|---|---|
| 📱 Electrónica | RAM, CPU, puertos (array), garantía |
| 👕 Moda | talla, color, material, instrucciones de cuidado |
| 📚 Libros | ISBN, autores múltiples, idioma, editorial |
| 🥫 Alimentos | peso, fecha de caducidad, tabla nutricional, alérgenos (array) |

La heterogeneidad **no es un accidente del modelado: es el requisito del
producto.** Nuevas categorías (y nuevos atributos por categoría) deben poder
llegar sin `ALTER TABLE` ni migración de pánico — esa es la tesis central
del curso, aplicada por primera vez como **decisión de diseño desde el día
0**, no como diagnóstico de algo ya construido.

### Aplicando el marco de la Fase 14 del curso anterior, ANTES de modelar

| Pregunta | Veredicto para Proteo |
|---|---|
| ¿Qué se lee junto? | la ficha completa del producto, siempre — localidad perfecta |
| ¿Quién custodia la forma? | forma distinta por categoría; categorías nuevas llegan sin aviso |
| ¿Cuánto se une en caliente? | casi nada: el documento ES la página del producto |
| ¿Dónde viven las invariantes? | dentro del producto (validación por categoría) |
| ¿Qué pide la operación? | lectura masiva, escritura moderada, evolución constante de atributos |

**Veredicto: 5-0 documento.** El villano de este curso es el crimen inverso
a `soporte_v1`: **EAV** (Entity-Attribute-Value), la tabla
`atributo/tipo/valor` que el mundo relacional inventó para simular lo que un
documento hace gratis.

---

## 📐 Stack (2026, sin nostalgia legacy)

| Componente | Versión / elección | Rol |
|---|---|---|
| MongoDB | **8.0** | motor documental principal (catálogo, snapshots de pedido) |
| Node | **22 LTS** | runtime |
| Lenguaje | **TypeScript** | tipado en todo el backend |
| Express | **5** | API — verificar en Fase 0 si el bug de promesas del A3 del curso anterior sigue existiendo (spoiler: no) |
| PostgreSQL | **16** | rival permanente en el arnés de "vs"; también motor de pagos/contabilidad en el veredicto final |
| Redis / Valkey | última | carrito de compra (TTL), caché |
| Meilisearch | última | motor de búsqueda ligero (alternativa moderna a Elastic) |
| Zod | — | validación de aplicación (paralelo al `$jsonSchema` del motor) |
| Couchbase | — | segundo rival documental (memoria-first, N1QL) — el "documento vs documento" que el curso anterior no tenía |

### Decisión de validación en capas
- **Zod** en la app (TypeScript, developer experience).
- **`$jsonSchema`** en el motor (última línea, la que ningún cliente puede
  esquivar — la lección de la Fase 4 del curso anterior, aplicada desde el
  origen).

---

## ⚖️ El método del "vs": un arnés, no anécdotas

Desde la Fase 0 se monta `scripts/vs.ts`: un harness que ejecuta **la misma
consulta semántica** contra los motores en juego, cronometra, y acumula
resultados en `BENCHMARKS.md` — el documento que crece capítulo a capítulo.
Ningún "vs" del curso se narra sin medir primero.

Los tres duelos que atraviesan el curso:
1. **Mongo vs PostgreSQL/JSONB** — documento vs relacional (el eje principal)
2. **Mongo vs Couchbase** — documento vs documento (memoria-first, N1QL)
3. **Mongo vs Meilisearch** — cuándo el documento deja de bastar para buscar

---

## 🌳 Estructura de fases (idea inicial — 13 fases)

| # | Fase | Núcleo | Vs. de la fase |
|---|---|---|---|
| **0** | 🧪 El laboratorio de dos motores | Compose con Mongo + Postgres + Redis + Meilisearch. Generador de datos que produce el mismo dataset semántico en ambas formas. Nace `scripts/vs.ts` | — (montaje) |
| **1** | ⚖️ El marco, para decidir | Las 5 preguntas aplicadas ANTES de modelar. Se construye el EAV en SQL y se siente el dolor en vivo | EAV vs JSONB vs documento (escritura y lectura) |
| **2** | 🧬 Heterogeneidad como feature | Catálogo de 4 verticales en documentos, `$jsonSchema` **polimórfico** (`oneOf` por categoría) | EAV vs JSONB con GIN vs documento — costo de categoría nueva sin migración |
| **3** | 📄 La página del producto: localidad como ventaja | El `findOne` que sirve la ficha completa | Aquí JSONB **empata** en lectura de blob — primer "vs" honesto donde Mongo no gana |
| **4** | ⭐ Reseñas: embeber, referenciar, o "depende del tamaño" | Bucket pattern para miles de reseñas, computed pattern para el promedio | Agregación SQL (`AVG`/`COUNT`) vs patrones de documento — costo de escritura de una reseña |
| **5** | 📦 Inventario multi-almacén: arrays que respiran | Stock por almacén/variante como array de subdocumentos, `$inc` atómico | Tabla puente `warehouse_stock` — decremento concurrente en ambos |
| **6** | 🕰️ Historial de precios y el pedido como fotografía | El documento de orden congela el producto tal como estaba al comprar (inmutable por diseño) | Patrón SCD Type 2 de SQL (legítimo, más ceremonioso) |
| **7** | 🔍 Búsqueda y facetas: cuándo el documento no basta | `$facet` de aggregation resolviendo filtros con conteos | SQL+GIN vs Mongo `$facet` vs Meilisearch — se instala "índice derivado, nunca fuente de verdad" |
| **8** | 🕸️ "Quienes compraron X también compraron Y" | Co-ocurrencia con aggregation | Por qué esto es agregación y no grafo — puente al futuro curso de Neo4j |
| **9** | 🛒 El carrito: el key-value en su hábitat | Redis con TTL para el carrito vivo | Redis vs carrito-como-colección-Mongo — latencia y durabilidad; diseño híbrido |
| **10** | 🔄 Change Streams: mantener sincronizados los derivados | Mongo alimentando Meilisearch y caché de Redis en tiempo real, sin polling ni outbox manual | — (técnica nueva) |
| **11** | ⚰️ La autopsia inversa | El catálogo EAV completo medido de punta a punta (página = 15 joins; categoría nueva = migración de pánico). Conversión a documento con números antes/después | El ritual del curso anterior, en espejo |
| **12** | ⚖️ El veredicto con las dos manos | Documento gana el catálogo 5-0, pero pagos/contabilidad siguen votando relacional (ACID real, auditoría) | Sistema final políglota, defendido con criterio: Mongo + Postgres + Redis + Meilisearch |

**Total estimado: 13 fases, ~400 ejercicios**, con `BENCHMARKS.md` como
contrapeso medido de `INSTINTOS.md` del curso anterior.

---

## 🧩 Decisiones pendientes de confirmar antes de redactar Fase 0

- [ ] ¿El generador de datos vive como script TS reusable o como seed por fase?
- [ ] ¿Couchbase entra desde la Fase 0 (montado siempre) o se reserva para un
      capítulo puntual de "documento vs documento" más adelante?
- [ ] ¿El proyecto de pagos/contabilidad de la Fase 12 se implementa de
      verdad (mini-servicio Postgres aparte) o se documenta como diseño?
- [ ] Nombre definitivo de las 4 verticales y su dataset semilla (¿datos
      sintéticos generados o un dataset público adaptado?)
- [ ] ¿Se mantiene el formato de 9 puntos por capítulo del curso anterior o
      se ajusta por ser un curso más corto/moderno?

---

## 🔗 Continuidad con la ruta general

Proteo es el ítem **#0** de `RUTA-NOSQL-2026.md` — el curso documental
"moderno" que complementa al legacy. Su "vs" documento-documento (Couchbase)
es el que la ruta general no cubría en ningún otro punto.
