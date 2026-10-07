# 🚀 Ficha de arranque
## Cristalería — el modelo analítico embebido a fondo

> **Qué es:** las respuestas de la discusión de arranque (E0), confirmadas por el autor el 06/10/2026,
> y su traducción a las decisiones `D-xx` del alcance. Es la entrada de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que manda sobre ella desde que existe.
> **Origen:** la semilla de agosto (`_desechable-semilla.md`), cuatro preguntas cerradas en la sesión y
> las reglas de la ruta. Lo que el autor no respondió va con el valor de la ruta o el precedente de
> Proteo y Portalón, marcado *(por defecto)*.

---

## 1. 🏷️ Título tentativo

**Cristalería — el modelo analítico embebido a fondo.** De qué va: la analítica de solo lectura sobre
archivos que caben en un proceso, consultados donde están, materializados cuando se repiten y
publicados en el navegador sin servidor; medida contra dos librerías de dataframes, contra el embebido
por filas, contra PostgreSQL y contra el clúster que la empresa ya paga. **Por qué ahora:** tercer curso
de la Ruta NoSQL, la continuación en profundidad del minicurso de analítico embebido de Ruta NoSQL Lite;
base para contenido en video.

## 2. 🧩 Tipo de curso

**Curso completo** *(por defecto)*.

## 3. 👤 Audiencia

**Senior que ya hizo Ruta NoSQL Lite** (D-14), con Python de trabajo. Trae de lite, y no se le vuelve a
explicar: almacenamiento por columnas contra por filas con su aritmética, Parquet como formato de
intercambio, agregar sobre millones de filas sin servidor, el pivote, el `EXPLAIN` básico de DuckDB, que
el spilling existe y que dos procesos no escriben el mismo archivo.

> 📝 Las fases 07 y 08 de lite todavía no están escritas: el recorte se hace contra su propuesta de
> fases (`ruta-no-sql-lite/prompts/propuesta-fases-y-alcance.md`) y se revisa cuando se publiquen.

## 4. 🔬 Profundidad

**Full geek** (D-15): el motor por dentro —ejecución vectorizada y paralelismo por morsels, la anatomía
de Parquet (row groups, páginas, estadísticas, codificaciones), el formato de almacenamiento de DuckDB
y su compresión, el buffer manager y el spilling, MVCC optimista, WAL y checkpoint, los algoritmos de
unión (hash, ASOF, rango), las extensiones, y DuckDB-Wasm por dentro (memoria, hilos, lectura por
rangos HTTP)—.

## 5. 🧪 Ejercicios

**Sí, 20–30 por fase**, 🟢🟡🟠🔴 y 🔥, un tercio de diagnóstico o medición, **sin solución publicada**
*(por defecto, precedente de Proteo)*.

## 6. 🛠️ Taller

**Uno global** *(por defecto)*: el pipeline analítico de Pasaje, que crece fase a fase hasta el tablero
publicado. Un 💀 boss por bloque cuando el bloque lo admita, y el proyecto final del alcance.

## 7. ✅ Respuestas

**Sin solución publicada** *(por defecto)*: cada ejercicio trae su criterio.

## 8. 💻 Código de ejemplo

**Sí. Python con `uv` para el pipeline, el generador, el arnés y los duelos; TypeScript solo para el
tablero en el navegador** (D-17). Es la divergencia que la semilla ya proponía frente al valor de la
ruta (TypeScript en todo, R-06): pandas y Polars viven en Python, y el idioma de la analítica es
Python con SQL.

## 9. 🎨 Inspiración

| Ruta | Tomar el tema | Tomar el estilo | Tomar la estructura |
|---|---|---|---|
| `prompts/_desechable-semilla.md` | sí | no | sí, como borrador de E2 |
| `cursos-bd/ruta-no-sql-lite/` | no (requisito, R-07) | sí | parcialmente |
| `../01-portalon/prompts/` | no | sí | sí: la forma de `prompts/` de la ruta |

## 10. 📐 Diagramas

**Mermaid** *(por defecto)*.

## 11. 🧫 Tipo de prueba

**Creación y ejecución en contenedor** *(por defecto)*. DuckDB, pandas, Polars, SQLite, PostgreSQL,
Spark de un nodo, el almacenamiento de objetos y el servidor estático corren en el laboratorio; ninguno
cuesta dinero. El warehouse gestionado del villano se trata solo desde su documentación (☁️).

## 12. 📦 Código generado en `zz-code/`

**Sí, con documentación completa** *(por defecto)*.

## 13. 🎭 Historia

**Sí: Pasaje**, elegida entre tres candidatas el 06/10/2026. Consultora de movilidad urbana de Quito
que analiza el recaudo con tarjeta, el GPS de los buses y los conteos a bordo para seis municipios.
Villano: la plataforma de warehouse gestionado y Spark gestionado que firmó en 2021 para el GPS y que
hoy responde todo, incluidas preguntas que caben en una laptop. Incidente: la semana del pasaje, cuando
la plataforma se suspendió por el tope de gasto, el tablero público cayó en plena sesión del concejo y
una muestra subestimó los viajes estudiantiles. La historia vive en `../00-historia-de-pasaje.md`.

## 14. 📝 Lo demás

- **Lo que NO quiero:** repetir lite; seguir con Cóndor.
- **Tamaño:** unas **100 h en 10–12 fases** *(por defecto, como Proteo y Portalón)* (D-04).
- **Rivales:** pandas 3 y Polars (dataframes), SQLite (embebido por filas), PostgreSQL de control y Spark
  de un nodo para medir al villano; el warehouse gestionado, solo desde documentación (D-16).

---

## 🔢 Traducción a decisiones

| Respuesta | Decisión del alcance | Estado |
|---|---|---|
| Tipo | D-02 curso completo | ✅ por defecto |
| Prerrequisito y autocontención | D-14 lite como requisito; D-03 sin usar su contenido (R-07) | ✅ |
| Profundidad | D-15 full geek | ✅ |
| Tamaño | D-04 ~100 h, 10–12 fases | ✅ por defecto |
| Lenguaje | D-17 Python con TypeScript en el borde | ✅ |
| Rivales | D-16 pandas, Polars, SQLite, PostgreSQL; D-22 Spark de un nodo | ✅ |
| Historia | D-11 Pasaje | ✅ |
| Ejercicios, taller, código, diagramas, pruebas | D-05, D-09, D-12, D-08 | ✅ por defecto |
