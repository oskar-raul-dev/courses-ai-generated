# 🚀 Ficha de arranque
## Oráculo de Bolsillo — el modelo vectorial a fondo

> **Qué es:** las respuestas de la discusión de arranque (E0), confirmadas por el autor el 06/10/2026,
> y su traducción a las decisiones `D-xx` del alcance. Es la entrada de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que manda sobre ella desde que existe.
> **Origen:** la semilla de agosto (`_desechable-semilla.md`), cuatro preguntas cerradas en la sesión y
> las reglas de la ruta. Lo que el autor no respondió va con el valor de la ruta o el precedente de
> Proteo, Portalón y Cristalería, marcado *(por defecto)*.

---

## 1. 🏷️ Título tentativo

**Oráculo de Bolsillo — el modelo vectorial a fondo.** De qué va: la recuperación por similitud de un
asistente con citas verificables, puesta donde viven los permisos, medida por su calidad antes que por
su velocidad, comprimida y llevada a disco cuando el volumen aprieta, y comparada con un motor dedicado
y con el servicio gestionado que nadie tiene que operar. **Por qué ahora:** cuarto curso de la Ruta
NoSQL, la continuación en profundidad del minicurso vectorial de Ruta NoSQL Lite; base para contenido
en video.

## 2. 🧩 Tipo de curso

**Curso completo** *(por defecto)*.

## 3. 👤 Audiencia

**Senior que ya hizo Ruta NoSQL Lite** (D-14). Trae de lite, y no se le vuelve a explicar: qué es un
embedding y qué no, los prefijos que pide el modelo, el punto con su vector, payload e id, coseno y
producto interno, HNSW y el dial de `ef`, el filtro de payload, recall contra una verdad conocida, y
pgvector contra Qdrant sobre un millón de vectores con su memoria y su punto de rotura.

> 📝 Las fases 15 y 16 de lite **están escritas y verificadas** (30/09/2026): el recorte se hace contra
> ellas, no contra su propuesta.

## 4. 🔬 Profundidad

**Full geek** (D-15) *(por defecto, como los tres anteriores)*: HNSW por dentro (construcción, `M`,
`ef_construction`, inserciones y borrados, mantenimiento), IVF y DiskANN, cuantización escalar,
binaria y por producto con su reevaluación, iterative scans y el filtrado con índices de payload,
vectores dispersos y fusión, rerankers, la evaluación de la recuperación, la consistencia entre el
índice y la base de verdad, y la migración de modelo.

## 5. 🧪 Ejercicios

**Sí, 20–30 por fase**, 🟢🟡🟠🔴 y 🔥, un tercio de diagnóstico o medición, **sin solución publicada**
*(por defecto, precedente de Proteo)*.

## 6. 🛠️ Taller

**Uno global** *(por defecto)*: el Oráculo de Valdivieso, que crece fase a fase. Un 💀 boss por bloque
cuando el bloque lo admita, y el proyecto final del alcance.

## 7. ✅ Respuestas

**Sin solución publicada** *(por defecto)*: cada ejercicio trae su criterio.

## 8. 💻 Código de ejemplo

**Sí** *(por defecto, como la semilla y lite)*: TypeScript nativo en Node 24 para el servicio del
Oráculo (Express 5), el arnés y el generador; **Python con `uv` solo para la ingesta, los embeddings y
el reranker**, donde vive el ecosistema de modelos.

## 9. 🎨 Inspiración

| Ruta | Tomar el tema | Tomar el estilo | Tomar la estructura |
|---|---|---|---|
| `prompts/_desechable-semilla.md` | sí | no | sí, como borrador de E2 |
| `cursos-bd/ruta-no-sql-lite/` | no (requisito, R-07) | sí | parcialmente |
| `../01-portalon/prompts/` y `../02-cristaleria/prompts/` | no | sí | sí: la forma de `prompts/` de la ruta |

## 10. 📐 Diagramas

**Mermaid** *(por defecto)*.

## 11. 🧫 Tipo de prueba

**Creación y ejecución en contenedor** *(por defecto)*. PostgreSQL con pgvector y pgvectorscale,
Qdrant, el servicio de embeddings y reranker, y el modelo de lenguaje local corren en el laboratorio;
ninguno cuesta dinero. Pinecone se trata solo desde su documentación (☁️).

## 12. 📦 Código generado en `zz-code/`

**Sí, con documentación completa** *(por defecto)*.

## 13. 🎭 Historia

**Sí: Valdivieso Abogados**, elegida entre tres candidatas el 06/10/2026. Estudio jurídico de Lima con
oficina en Arequipa, ciento cuarenta abogados, con un asistente interno —el Oráculo— sobre su sistema
documental y su biblioteca de jurisprudencia. Villano: el motor vectorial dedicado de 2024, con los
permisos copiados a sus metadatos por un cron nocturno. Incidente: la semana de la casación, con una
cita textual atribuida a la resolución equivocada y un fragmento que cruzó una muralla ética cuatro
horas y media después de levantada. La historia vive en `../00-historia-de-valdivieso-abogados.md`.

## 14. 📝 Lo demás

- **Lo que NO quiero:** repetir lite; seguir con Cóndor; **Weaviate** (el autor no lo marcó: queda fuera,
  y con él la búsqueda híbrida "de plataforma"); **las codas en Java y C++** (fuera, como en Portalón).
- **Tamaño:** unas **100 h en 10–12 fases** *(por defecto)* (D-04).
- **Rivales:** pgvector como titular; pgvectorscale (DiskANN) y Qdrant como rivales; Pinecone solo desde
  documentación (D-16).
- **Generación:** un modelo de lenguaje local en contenedor, detrás de una interfaz (D-23).

---

## 🔢 Traducción a decisiones

| Respuesta | Decisión del alcance | Estado |
|---|---|---|
| Tipo | D-02 curso completo | ✅ por defecto |
| Prerrequisito y autocontención | D-14 lite como requisito; D-03 sin usar su contenido (R-07) | ✅ |
| Profundidad | D-15 full geek | ✅ por defecto |
| Tamaño | D-04 ~100 h, 10–12 fases | ✅ por defecto |
| Rivales | D-16 pgvector titular; pgvectorscale y Qdrant; D-22 Pinecone ☁️ | ✅ |
| Generación | D-23 modelo local en contenedor | ✅ |
| Codas Java y C++ | D-28 fuera | ✅ |
| Historia | D-11 Valdivieso Abogados | ✅ |
| Ejercicios, taller, código, diagramas, pruebas | D-05, D-09, D-12, D-08, D-17 | ✅ por defecto |
