# 🚀 Ficha de arranque
## Libro Mayor — el modelo NewSQL distribuido a fondo

> **Qué es:** las respuestas de la discusión de arranque (E0), confirmadas por el autor el 07/10/2026, y su
> traducción a las decisiones `D-xx` del alcance. Es la entrada de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que manda sobre ella desde que existe.
> **Origen:** la semilla de agosto (`_desechable-semilla.md`), una pregunta cerrada en la sesión y las reglas de
> la ruta. Lo que el autor no respondió va con el valor de la ruta o el precedente de los cursos anteriores,
> marcado *(por defecto)*.

---

## 1. 🏷️ Título tentativo

**Libro Mayor — el modelo NewSQL distribuido a fondo.** De qué va: el libro de partida doble de una fintech de
cuentas multimoneda en tres regiones con residencia de datos, donde hoy hay tres PostgreSQL unidos por sagas y
antes hubo uno con réplica asíncrona; con SQL y ACID sobre un sistema distribuido como respuesta al falso dilema
entre corrección y escala, medido contra las dos caras de ese dilema y contra PostgreSQL de un nodo. **Por qué
ahora:** décimo curso de la Ruta NoSQL, la continuación en profundidad del minicurso de NewSQL de Ruta NoSQL Lite;
base para contenido en video.

## 2. 🧩 Tipo de curso

**Curso completo** *(por defecto)*.

## 3. 👤 Audiencia

**Senior que ya hizo Ruta NoSQL Lite** (D-14). Trae de lite, y no se le vuelve a explicar: SQL y ACID sobre un
sistema distribuido como idea, rangos, réplicas y consenso sin misticismo, la localidad de datos en el esquema y la
residencia por autoridad, que el reloj es el problema de fondo, la latencia de confirmación por localidad medida,
la contención sobre la misma fila desde dos regiones, el reintento como modelo de programación, y que si una región
basta, PostgreSQL es más simple, más barato y más rápido.

> 📝 Las fases 21 y 22 de lite **todavía no están escritas**: el recorte se hace contra su propuesta de fases
> (`ruta-no-sql-lite/prompts/propuesta-fases-y-alcance.md`) y se revisa cuando se publiquen. Lite midió sobre
> CockroachDB solo; Libro Mayor pone el centro en lo que lite no tocó: las dos caras del villano construidas y
> rotas, los tres motores por dentro, el reloj y la incertidumbre, la cuenta caliente y el esquema en línea.

## 4. 🔬 Profundidad

**Full geek** (D-15) *(por defecto, como los anteriores)*: Raft por dentro (líderes, arrendamientos, marcas de
tiempo cerradas), relojes lógicos híbridos e intervalo de incertidumbre, confirmaciones en paralelo, intenciones de
escritura y registros de transacción, lecturas de seguidor y de instante, metas de supervivencia, tablas globales
y ubicación por fila, rangos calientes e índices repartidos por hash, cambios de esquema en línea, Percolator y el
oráculo de marcas de tiempo de TiDB, DocDB y las tabletas de YugabyteDB, y las sagas por dentro.

## 5. 🧪 Ejercicios

**Sí, 20–30 por fase**, 🟢🟡🟠🔴 y 🔥, un tercio de diagnóstico o medición, **sin solución publicada** *(por
defecto, precedente de Proteo)*.

## 6. 🛠️ Taller

**Uno global** *(por defecto)*: el libro de Kambio, que crece fase a fase. Un 💀 boss por bloque cuando el bloque
lo admita, y el proyecto final del alcance.

## 7. ✅ Respuestas

**Sin solución publicada** *(por defecto)*: cada ejercicio trae su criterio.

## 8. 💻 Código de ejemplo

**Sí** *(por defecto, como la semilla)*: TypeScript nativo en Node 24 para la API del libro, el orquestador de
sagas del villano, el arnés, el generador y la inyección de fallas; `pg` contra CockroachDB, YugabyteDB y
PostgreSQL, y el cliente de MySQL contra TiDB. **API con Express 5**, por coherencia con la ruta, en lugar del
Fastify que proponía la semilla (D-32). **Sin codas en otros lenguajes**.

## 9. 🎨 Inspiración

| Ruta | Tomar el tema | Tomar el estilo | Tomar la estructura |
|---|---|---|---|
| `prompts/_desechable-semilla.md` | sí | no | sí, como borrador de E2 |
| `cursos-bd/ruta-no-sql-lite/` | no (requisito, R-07) | sí | parcialmente |
| `../00-proteo/prompts/` a `../08-el-vigia/prompts/` | no | sí | sí: la forma de `prompts/` de la ruta |

## 10. 📐 Diagramas

**Mermaid** *(por defecto)*. Las tres regiones, el recorrido de una confirmación con sus idas y vueltas, y la saga
con su compensación, también en Mermaid.

## 11. 🧫 Tipo de prueba

**Creación y ejecución en contenedor** *(por defecto)*. CockroachDB, YugabyteDB, TiDB, PostgreSQL, el inyector de
latencia y fallas, y el servicio corren en el laboratorio; ninguno cuesta dinero. Spanner, Aurora DSQL y los
servicios gestionados de los tres motores se tratan solo desde su documentación (☁️).

## 12. 📦 Código generado en `zz-code/`

**Sí, con documentación completa** *(por defecto)*.

## 13. 🎭 Historia

**Sí: Kambio**, a partir del dominio que eligió el autor el 07/10/2026 (cuentas multimoneda para freelancers en
tres regiones con residencia de datos). Nombre, ciudad y gente los propuso la sesión y quedan a confirmar con la
historia final. Fintech de Montevideo con cuentas en dólares, euros y reales. Villano, el falso dilema con sus dos
caras: el PostgreSQL de Virginia con réplica asíncrona y conmutación manual, y los tres libros por región unidos
por sagas. Incidente: la caída de Virginia del 4 de junio de 2026, con transacciones confirmadas perdidas, dinero
en el limbo durante treinta y una horas, dobles créditos y la tesorería bloqueada a la vuelta. La historia vive en
`../00-historia-de-kambio.md`.

> 📝 **El nombre del curso se mantiene.** El plan de la ruta advertía que la empresa de NewSQL no podía ser
> Barlovento, la del miniproyecto de lite; no lo es, y «Libro Mayor» describe exactamente el dominio.

## 14. 📝 Lo demás

- **Lo que NO quiero:** repetir lite; seguir con Cóndor; un expediente o un trasbordo como los de lite.
- **Tamaño:** unas **100 h en 10–12 fases** *(por defecto)* (D-04).
- **Rivales:** CockroachDB como principal; YugabyteDB y TiDB como las otras dos arquitecturas; PostgreSQL de un
  nodo como testigo y como las dos caras del villano; Spanner y Aurora DSQL solo desde documentación (D-16, D-22)
  *(por defecto, desde la semilla)*.

---

## 🔢 Traducción a decisiones

| Respuesta | Decisión del alcance | Estado |
|---|---|---|
| Tipo | D-02 curso completo | ✅ por defecto |
| Prerrequisito y autocontención | D-14 lite como requisito; D-03 sin usar su contenido (R-07) | ✅ |
| Profundidad | D-15 full geek | ✅ por defecto |
| Tamaño | D-04 ~100 h, 10–12 fases | ✅ por defecto |
| Rivales | D-16, D-22, D-24 | ✅ por defecto |
| Historia | D-11 Kambio | ✅ |
| Nombre | D-34 Libro Mayor se mantiene | ✅ por defecto |
| Ejercicios, taller, código, diagramas, pruebas | D-05, D-09, D-12, D-08, D-17 | ✅ por defecto |
