# 🚀 Ficha de arranque
## Telaraña — el modelo de grafos a fondo

> **Qué es:** las respuestas de la discusión de arranque (E0), confirmadas por el autor el 06/10/2026,
> y su traducción a las decisiones `D-xx` del alcance. Es la entrada de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que manda sobre ella desde que existe.
> **Origen:** la semilla de agosto (`_desechable-semilla.md`), cuatro preguntas cerradas en la sesión y
> las reglas de la ruta. Lo que el autor no respondió va con el valor de la ruta o el precedente de los
> cursos anteriores, marcado *(por defecto)*.

---

## 1. 🏷️ Título tentativo

**Telaraña — el modelo de grafos a fondo.** De qué va: el antifraude de una billetera digital, con la
relación como ciudadana de primera clase donde la profundidad es variable —anillos, árboles, caminos,
comunidades— y con la tabla donde basta un salto; medido contra PostgreSQL con lo mejor que hace SQL,
contra Cypher dentro de PostgreSQL y contra un grafo en memoria. **Por qué ahora:** quinto curso de la
Ruta NoSQL, la continuación en profundidad del minicurso de grafos de Ruta NoSQL Lite; base para
contenido en video.

## 2. 🧩 Tipo de curso

**Curso completo** *(por defecto)*.

## 3. 👤 Audiencia

**Senior que ya hizo Ruta NoSQL Lite** (D-14). Trae de lite, y no se le vuelve a explicar: nodos,
relaciones y propiedades, Cypher básico, la diferencia entre un árbol y un grafo que no lo es, la
cardinalidad de travesía, que PostgreSQL aguanta la travesía de un árbol por profundidad con `WITH
RECURSIVE`, que el argumento real del grafo es la consulta de patrón, el producto cartesiano de Cypher, y
que operar un motor más cuesta.

> 📝 Las fases 13 y 14 de lite **todavía no están escritas**: el recorte se hace contra su propuesta de
> fases (`ruta-no-sql-lite/prompts/propuesta-fases-y-alcance.md`) y se revisa cuando se publiquen.

## 4. 🔬 Profundidad

**Full geek** (D-15) *(por defecto, como los anteriores)*: el almacenamiento de Neo4j y la adyacencia sin
índice, la caché de páginas, el planificador y sus accesos, los operadores ansiosos, los patrones de
camino cuantificados, el problema del supernodo, el bloqueo al escribir nodos muy conectados, Memgraph en
memoria con su persistencia, los algoritmos de grafo por dentro (proyecciones, iteraciones,
convergencia), Apache AGE sobre el planificador de PostgreSQL, y la cláusula `CYCLE` y los límites de `WITH
RECURSIVE`.

## 5. 🧪 Ejercicios

**Sí, 20–30 por fase**, 🟢🟡🟠🔴 y 🔥, un tercio de diagnóstico o medición, **sin solución publicada**
*(por defecto, precedente de Proteo)*.

## 6. 🛠️ Taller

**Uno global** *(por defecto)*: el antifraude de Quetzal Pay, que crece fase a fase. Un 💀 boss por bloque
cuando el bloque lo admita, y el proyecto final del alcance.

## 7. ✅ Respuestas

**Sin solución publicada** *(por defecto)*: cada ejercicio trae su criterio.

## 8. 💻 Código de ejemplo

**Sí** *(por defecto, como la semilla)*: TypeScript nativo en Node 24 para el servicio antifraude
(Express 5), el arnés, el generador y el conector simulado; `neo4j-driver` por Bolt contra Neo4j y
Memgraph, `pg` contra PostgreSQL y AGE. **Kotlin solo en el apéndice 🔥 de la JVM**, fuera del núcleo y de
las mediciones.

## 9. 🎨 Inspiración

| Ruta | Tomar el tema | Tomar el estilo | Tomar la estructura |
|---|---|---|---|
| `prompts/_desechable-semilla.md` | sí | no | sí, como borrador de E2 |
| `cursos-bd/ruta-no-sql-lite/` | no (requisito, R-07) | sí | parcialmente |
| `../01-portalon/prompts/` a `../03-oraculo-de-bolsillo/prompts/` | no | sí | sí: la forma de `prompts/` de la ruta |

## 10. 📐 Diagramas

**Mermaid** *(por defecto)*. Los grafos de ejemplo, pequeños, también en Mermaid.

## 11. 🧫 Tipo de prueba

**Creación y ejecución en contenedor** *(por defecto)*. Neo4j, Memgraph, PostgreSQL con Apache AGE y el
servicio corren en el laboratorio; ninguno cuesta dinero. Neptune se trata solo desde su documentación
(☁️).

## 12. 📦 Código generado en `zz-code/`

**Sí, con documentación completa** *(por defecto)*.

## 13. 🎭 Historia

**Sí: Quetzal Pay**, elegida entre tres candidatas el 06/10/2026. Billetera digital de Ciudad de
Guatemala: pagos entre personas, comercios, remesas, agentes de retiro y un programa de referidos.
Villano: todo el antifraude llevado a Neo4j en 2023, incluidas las treinta y cuatro reglas de un salto
que se evalúan en cada pago. Incidente: la quincena de diciembre, cuando la búsqueda nocturna de anillos
satura el servidor, los pagos se aprueban sin antifraude durante cinco horas y una red de mil ciento
cuarenta cuentas cobra los referidos y retira Q 2,3 M. La historia vive en `../00-historia-de-quetzal-pay.md`.

## 14. 📝 Lo demás

- **Lo que NO quiero:** repetir lite; seguir con Cóndor.
- **Tamaño:** unas **100 h en 10–12 fases** *(por defecto)* (D-04).
- **Rivales:** Neo4j como principal; Memgraph, Apache AGE y PostgreSQL con `WITH RECURSIVE` como control;
  Neptune solo desde documentación; SQL/PGQ y GQL nombrados y medidos donde exista un motor libre que los
  implemente (D-16, D-22, D-26).
- **Algoritmos:** el catálogo de fraude —componentes, PageRank, Louvain, similitud de nodos y
  centralidad—, cada uno contra su versión en SQL cuando existe (D-24).
- **El apéndice 🔥 de la JVM:** dentro, en Kotlin (D-28).

---

## 🔢 Traducción a decisiones

| Respuesta | Decisión del alcance | Estado |
|---|---|---|
| Tipo | D-02 curso completo | ✅ por defecto |
| Prerrequisito y autocontención | D-14 lite como requisito; D-03 sin usar su contenido (R-07) | ✅ |
| Profundidad | D-15 full geek | ✅ por defecto |
| Tamaño | D-04 ~100 h, 10–12 fases | ✅ por defecto |
| Rivales | D-16 Neo4j, Memgraph, AGE, PostgreSQL; D-22 Neptune ☁️; D-26 SQL/PGQ y GQL | ✅ |
| Algoritmos | D-24 catálogo de fraude | ✅ |
| Apéndice JVM | D-28 dentro, en Kotlin | ✅ |
| Historia | D-11 Quetzal Pay | ✅ |
| Ejercicios, taller, código, diagramas, pruebas | D-05, D-09, D-12, D-08, D-17 | ✅ por defecto |
