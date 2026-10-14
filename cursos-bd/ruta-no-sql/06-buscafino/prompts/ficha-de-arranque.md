# 🚀 Ficha de arranque
## Buscafino — el modelo de búsqueda a fondo

> **Qué es:** las respuestas de la discusión de arranque (E0), confirmadas por el autor el 07/10/2026, y su
> traducción a las decisiones `D-xx` del alcance. Es la entrada de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que manda sobre ella desde que existe.
> **Origen:** la semilla de agosto (`_desechable-semilla.md`), dos preguntas cerradas en la sesión y las
> reglas de la ruta. Lo que el autor no respondió va con el valor de la ruta o el precedente de los cursos
> anteriores, marcado *(por defecto)*.

---

## 1. 🏷️ Título tentativo

**Buscafino — el modelo de búsqueda a fondo.** De qué va: el buscador de un portal de empleo multipaís, con
ofertas en español, inglés y portugués, la relevancia, las facetas y el error de tecleo como problemas de
primera clase, y el índice siempre derivado de PostgreSQL; medido contra Elasticsearch, contra dos motores
livianos y contra lo mejor que hace PostgreSQL. **Por qué ahora:** séptimo curso de la Ruta NoSQL, la
continuación en profundidad del minicurso de búsqueda de Ruta NoSQL Lite; base para contenido en video.

## 2. 🧩 Tipo de curso

**Curso completo** *(por defecto)*.

## 3. 👤 Audiencia

**Senior que ya hizo Ruta NoSQL Lite** (D-14). Trae de lite, y no se le vuelve a explicar: el índice invertido
en lo básico (analizadores, tokens, stemming), los sinónimos y la tolerancia a errores en lo básico, las facetas
y las agregaciones en lo básico, que el mapeo es un esquema, el full-text de PostgreSQL con `tsvector` y GIN,
cuánto dura un reindexado completo, el índice en solo lectura por disco lleno, el tiempo hasta que un documento
nuevo se ve, y **que el buscador es un índice y no una fuente de verdad**.

> 📝 Las fases 11 y 12 de lite **todavía no están escritas**: el recorte se hace contra su propuesta de fases
> (`ruta-no-sql-lite/prompts/propuesta-fases-y-alcance.md`) y se revisa cuando se publiquen. **Ojo con el
> veredicto:** lite ya cierra con *"índice, no fuente de verdad"*. Buscafino no lo vuelve a demostrar: lo da por
> sabido y mide lo que viene después —por dónde se cuela el dato que solo vive en el índice, cómo se arquitectura
> la entrada para que no pase, y cuánto cuesta cada camino—.

## 4. 🔬 Profundidad

**Full geek** (D-15) *(por defecto, como los anteriores)*: Lucene por dentro (segmentos, refresco, registro de
transacciones, fusiones, documentos borrados, *doc values*), BM25 y sus parámetros, la explicación de una
puntuación, la evaluación de la relevancia con juicios, los analizadores por idioma y los sinónimos en grafo, las
agregaciones repartidas en fragmentos y su error, el autocompletado y sus estructuras, fragmentos, réplicas,
memoria y cortacircuitos, y cómo resuelven lo mismo Meilisearch, Typesense y ParadeDB por dentro.

## 5. 🧪 Ejercicios

**Sí, 20–30 por fase**, 🟢🟡🟠🔴 y 🔥, un tercio de diagnóstico o medición, **sin solución publicada** *(por
defecto, precedente de Proteo)*.

## 6. 🛠️ Taller

**Uno global** *(por defecto)*: el buscador de Vacantia, que crece fase a fase. Un 💀 boss por bloque cuando el
bloque lo admita, y el proyecto final del alcance.

## 7. ✅ Respuestas

**Sin solución publicada** *(por defecto)*: cada ejercicio trae su criterio.

## 8. 💻 Código de ejemplo

**Sí** *(por defecto, como la semilla)*: TypeScript nativo en Node 24 para el servicio de búsqueda (Express 5 con
Zod en la frontera), el arnés, el generador, el importador de feeds y la copia al índice; el cliente oficial de
cada motor y `pg` contra PostgreSQL. **Sin codas en otros lenguajes** *(por defecto, como Portalón)*.

## 9. 🎨 Inspiración

| Ruta | Tomar el tema | Tomar el estilo | Tomar la estructura |
|---|---|---|---|
| `prompts/_desechable-semilla.md` | sí, salvo el catálogo de marketplace y Meilisearch como titular | no | sí, como borrador de E2 |
| `cursos-bd/ruta-no-sql-lite/` | no (requisito, R-07) | sí | parcialmente |
| `../00-proteo/prompts/` a `../05-rastro/prompts/` | no | sí | sí: la forma de `prompts/` de la ruta |

## 10. 📐 Diagramas

**Mermaid** *(por defecto)*. El camino de un documento hasta ser buscable, los segmentos y sus fusiones, y el
camino de un feed, también en Mermaid.

## 11. 🧫 Tipo de prueba

**Creación y ejecución en contenedor** *(por defecto)*. OpenSearch, Elasticsearch, Meilisearch, Typesense,
PostgreSQL con ParadeDB y el servicio corren en el laboratorio; ninguno cuesta dinero. Amazon OpenSearch Service,
Elastic Cloud y Algolia se tratan solo desde su documentación (☁️).

## 12. 📦 Código generado en `zz-code/`

**Sí, con documentación completa** *(por defecto)*.

## 13. 🎭 Historia

**Sí: Vacantia**, a partir del dominio que dio el autor el 07/10/2026: un portal de empleo con ofertas por país y
trabajo remoto de otros países, al estilo de LinkedIn o Indeed. El nombre de la empresa y su sede (San José de
Costa Rica, con nueve países) los propuso la sesión y quedan a confirmar con la historia final. Villano: las
ofertas remotas de los feeds escritas directo al índice, y los destacados pagados y el contador de postulaciones
guardados solo como campos del documento. Incidente: la cuesta de enero de 2026, con la reconstrucción "desde
PostgreSQL" que pierde lo que nunca estuvo ahí, la instantánea restaurada que devuelve currículos suprimidos, y
la búsqueda a 4,1 s. La historia vive en `../00-historia-de-vacantia.md`.

> 📝 **Por qué no el marketplace.** La semilla era el catálogo de un marketplace. Se descartó porque se pisa con
> Mercado Ceibo (Proteo, que además ya usa Meilisearch como derivado), con el catálogo de partes de lite y con el
> archivo de Bengala, el miniproyecto de búsqueda de lite. Un portal de empleo trae lo que el marketplace no:
> tres idiomas, sinónimos de cargos, salarios en varias monedas, búsqueda por zona horaria y datos personales.

## 14. 📝 Lo demás

- **Lo que NO quiero:** repetir lite; seguir con Cóndor; otro catálogo de productos.
- **Tamaño:** unas **100 h en 10–12 fases** *(por defecto)* (D-04).
- **Rivales:** **OpenSearch como titular** (elegido por el autor); Elasticsearch medido donde difiere;
  Meilisearch y Typesense como livianos; PostgreSQL con su búsqueda de texto y trigramas, y ParadeDB con BM25,
  como control dentro de la base de verdad; los gestionados solo desde documentación (D-16, D-22, D-35).
- **Fuera:** búsqueda semántica, vectorial e híbrida (D-28) *(por defecto)*.

---

## 🔢 Traducción a decisiones

| Respuesta | Decisión del alcance | Estado |
|---|---|---|
| Tipo | D-02 curso completo | ✅ por defecto |
| Prerrequisito y autocontención | D-14 lite como requisito; D-03 sin usar su contenido (R-07) | ✅ |
| Profundidad | D-15 full geek | ✅ por defecto |
| Tamaño | D-04 ~100 h, 10–12 fases | ✅ por defecto |
| Rivales | D-16 OpenSearch titular y rivales; D-22 gestionados ☁️; D-35 Elasticsearch | ✅ |
| Historia | D-11 Vacantia | ✅ |
| Semántica y vectores | D-28 fuera | ✅ por defecto |
| Ejercicios, taller, código, diagramas, pruebas | D-05, D-09, D-12, D-08, D-17 | ✅ por defecto |
