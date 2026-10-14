# 🚀 Ficha de arranque
## El Vigía — el modelo de series temporales a fondo

> **Qué es:** las respuestas de la discusión de arranque (E0), confirmadas por el autor el 07/10/2026, y su
> traducción a las decisiones `D-xx` del alcance. Es la entrada de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que manda sobre ella desde que existe.
> **Origen:** la semilla de agosto (`_desechable-semilla.md`), una pregunta cerrada en la sesión y las reglas
> de la ruta. Lo que el autor no respondió va con el valor de la ruta o el precedente de los cursos anteriores,
> marcado *(por defecto)*.

---

## 1. 🏷️ Título tentativo

**El Vigía — el modelo de series temporales a fondo.** De qué va: la observabilidad de un servicio de facturación
electrónica de cinco países, con métricas de infraestructura y un nivel de servicio por cliente que tiene efectos
contractuales; con el tiempo como eje físico, la cardinalidad como presupuesto y el percentil del mes como
número que hay que poder defender; medido contra Prometheus, TimescaleDB, MongoDB y la tabla de PostgreSQL de
siempre. **Por qué ahora:** noveno curso de la Ruta NoSQL, la continuación en profundidad del minicurso de series
temporales de Ruta NoSQL Lite; base para contenido en video.

## 2. 🧩 Tipo de curso

**Curso completo** *(por defecto)*.

## 3. 👤 Audiencia

**Senior que ya hizo Ruta NoSQL Lite** (D-14). Trae de lite, y no se le vuelve a explicar: hypertables y
particionado por tiempo, roll-ups continuos de minuto a hora a día, retención y compresión como parte del modelo,
`DELETE` contra `DROP` de partición, la explosión de cardinalidad, el backfill contra una hypertable comprimida,
el particionado declarativo de PostgreSQL contra TimescaleDB, y que la compresión y los roll-ups continuos de
Timescale van bajo su licencia propia.

> 📝 Las fases 09 y 10 de lite **todavía no están escritas**: el recorte se hace contra su propuesta de fases
> (`ruta-no-sql-lite/prompts/propuesta-fases-y-alcance.md`) y se revisa cuando se publiquen. Como lite ya midió
> TimescaleDB contra PostgreSQL particionado, El Vigía pone el centro en lo que lite no tocó: los motores
> dedicados por dentro, la cardinalidad en cada uno, los percentiles agregados y PromQL.

## 4. 🔬 Profundidad

**Full geek** (D-15) *(por defecto, como los anteriores)*: la compresión por dentro (diferencias de diferencias,
XOR de punto flotante, diccionarios, Parquet), InfluxDB 3 por dentro (registro de escritura, Parquet, catálogo,
almacenamiento de objetos, consultas SQL), Prometheus por dentro (cabeza, registro, bloques, compactación), los
fragmentos y el almacenamiento columnar de TimescaleDB, la cardinalidad medida en cada motor, histogramas y
bocetos de cuantiles con su error, contadores y tasas, datos tardíos y fuera de orden, y las consultas de
ventana.

## 5. 🧪 Ejercicios

**Sí, 20–30 por fase**, 🟢🟡🟠🔴 y 🔥, un tercio de diagnóstico o medición, **sin solución publicada** *(por
defecto, precedente de Proteo)*.

## 6. 🛠️ Taller

**Uno global** *(por defecto)*: la observabilidad de Timbra, que crece fase a fase. Un 💀 boss por bloque cuando el
bloque lo admita, y el proyecto final del alcance.

## 7. ✅ Respuestas

**Sin solución publicada** *(por defecto)*: cada ejercicio trae su criterio.

## 8. 💻 Código de ejemplo

**Sí** *(por defecto, como la semilla)*: TypeScript nativo en Node 24 para el simulador de servicios, el
middleware de métricas, la API del tablero (Express 5), el arnés y el generador; el cliente de cada motor. **Sin
codas en otros lenguajes**; si el generador no alcanza la cadencia del cierre de mes, se resuelve con procesos
paralelos en TypeScript, no con otro lenguaje (D-30).

## 9. 🎨 Inspiración

| Ruta | Tomar el tema | Tomar el estilo | Tomar la estructura |
|---|---|---|---|
| `prompts/_desechable-semilla.md` | sí | no | sí, como borrador de E2 |
| `cursos-bd/ruta-no-sql-lite/` | no (requisito, R-07) | sí | parcialmente |
| `../00-proteo/prompts/` a `../07-comanda/prompts/` | no | sí | sí: la forma de `prompts/` de la ruta |

## 10. 📐 Diagramas

**Mermaid** *(por defecto)*. El camino de un punto hasta el disco en cada motor, la retención por resoluciones y
las ventanas, también en Mermaid.

## 11. 🧫 Tipo de prueba

**Creación y ejecución en contenedor** *(por defecto)*. InfluxDB 3 Core, TimescaleDB, Prometheus, MongoDB,
PostgreSQL, Grafana y el simulador corren en el laboratorio; ninguno cuesta dinero. Los servicios gestionados se
tratan solo desde su documentación (☁️).

## 12. 📦 Código generado en `zz-code/`

**Sí, con documentación completa** *(por defecto)*.

## 13. 🎭 Historia

**Sí: Timbra**, a partir del dominio que eligió el autor el 07/10/2026 (observabilidad, como la semilla, en una
empresa concreta). Nombre, ciudad y gente los propuso la sesión y quedan a confirmar con la historia final. Un
servicio de facturación electrónica de Guadalajara con cuarenta y ocho mil clientes en cinco países. Villano: la
tabla `request_metrics` en PostgreSQL, con una fila por petición escrita dentro de la petición, y el percentil del
mes calculado sobre ella. Incidente: el cierre de marzo de 2026, con la API frenada por sus propias métricas, el
middleware apagado, el proveedor de certificación degradado sin alerta durante seis horas y veinte minutos, y un
reporte de SLA que no se pudo calcular. La historia vive en `../00-historia-de-timbra.md`.

> 📝 **Por qué no otra telemetría.** Lite ya usó los parámetros de vuelo de Cóndor y los medidores de Voltaria, y
> Rastro (el curso de columnar ancha de la ruta) se quedó con el río de eventos de paquetes. La observabilidad
> de un servicio trae lo que esos no traen: la cardinalidad por cliente, los percentiles y PromQL.

## 14. 📝 Lo demás

- **Lo que NO quiero:** repetir lite; seguir con Cóndor; otra telemetría de sensores.
- **Tamaño:** unas **100 h en 10–12 fases** *(por defecto)* (D-04).
- **Rivales:** InfluxDB 3 Core como principal, condicionado a la verificación previa (D-24); TimescaleDB;
  **Prometheus**, agregado porque el dominio es observabilidad; las colecciones de series de MongoDB con el
  patrón de cubetas a mano; PostgreSQL como base de verdad y villano (D-16) *(por defecto, desde la semilla)*.

---

## 🔢 Traducción a decisiones

| Respuesta | Decisión del alcance | Estado |
|---|---|---|
| Tipo | D-02 curso completo | ✅ por defecto |
| Prerrequisito y autocontención | D-14 lite como requisito; D-03 sin usar su contenido (R-07) | ✅ |
| Profundidad | D-15 full geek | ✅ por defecto |
| Tamaño | D-04 ~100 h, 10–12 fases | ✅ por defecto |
| Rivales | D-16, D-24, D-25 | ✅ por defecto |
| Historia | D-11 Timbra | ✅ |
| Nombre | D-34 El Vigía se mantiene | ✅ por defecto |
| Ejercicios, taller, código, diagramas, pruebas | D-05, D-09, D-12, D-08, D-17 | ✅ por defecto |
