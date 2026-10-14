# 🚀 Ficha de arranque
## Rastro — el modelo de columnar ancha a fondo

> **Qué es:** las respuestas de la discusión de arranque (E0), confirmadas por el autor el 07/10/2026, y su
> traducción a las decisiones `D-xx` del alcance. Es la entrada de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que manda sobre ella desde que existe.
> **Origen:** la semilla de agosto (`_desechable-semilla.md`, escrita como «Centinela de Flota»), dos
> preguntas cerradas en la sesión y las reglas de la ruta. Lo que el autor no respondió va con el valor de
> la ruta o el precedente de los cursos anteriores, marcado *(por defecto)*.

---

## 1. 🏷️ Título tentativo

**Rastro — el modelo de columnar ancha a fondo.** De qué va: el rastreo de paquetes de un courier de casilleros
virtuales que atiende siete países, con el río de eventos donde Cassandra está bien puesta y la plataforma de
marca blanca donde no; medido contra PostgreSQL con lo mejor que tiene y contra ScyllaDB, el rival dentro de
la familia. **Por qué ahora:** sexto curso de la Ruta NoSQL, la continuación en profundidad del minicurso de
columnar ancha de Ruta NoSQL Lite; base para contenido en video.

> 📝 **El nombre cambió** (D-34). La semilla se llamaba «Centinela de Flota», que sugería continuidad con la
> flota de lite que R-02 niega; con el dominio nuevo, el autor eligió renombrar. El directorio pasó de
> `05-centinela-de-flota/` a `05-rastro/` el 07/10/2026.

## 2. 🧩 Tipo de curso

**Curso completo** *(por defecto)*.

## 3. 👤 Audiencia

**Senior que ya hizo Ruta NoSQL Lite** (D-14). Trae de lite, y no se le vuelve a explicar: modelar por
consulta y no por entidad, la clave de partición contra la de agrupamiento, desnormalizar a propósito y
mantener varias tablas de lo mismo, la consistencia ajustable con quórum en lo básico, la partición caliente,
que borrar deja lápidas y que compactar cuesta, `ALLOW FILTERING` como olor, y que operar un motor más cuesta.

> 📝 Las fases 17 y 18 de lite **todavía no están escritas**: el recorte se hace contra su propuesta de fases
> (`ruta-no-sql-lite/prompts/propuesta-fases-y-alcance.md`) y se revisa cuando se publiquen.

## 4. 🔬 Profundidad

**Full geek** (D-15) *(por defecto, como los anteriores)*: el camino de escritura (registro de cambios, tabla en
memoria, volcado, SSTables), el camino de lectura (filtros de Bloom, índices de partición, cachés), las
estrategias de compactación y sus amplificaciones, las lápidas y el periodo de gracia, la reparación, los
avisos guardados y la reparación en lectura, el anillo de tokens y los nodos virtuales, las transacciones
ligeras y Paxos, los contadores, los lotes con y sin registro, SAI, la máquina virtual de Java y su
recolector, y ScyllaDB por dentro (un núcleo por fragmento, tabletas).

## 5. 🧪 Ejercicios

**Sí, 20–30 por fase**, 🟢🟡🟠🔴 y 🔥, un tercio de diagnóstico o medición, **sin solución publicada** *(por
defecto, precedente de Proteo)*.

## 6. 🛠️ Taller

**Uno global** *(por defecto)*: el rastreo y la plataforma de Encomienda 305, que crecen fase a fase. Un 💀 boss
por bloque cuando el bloque lo admita, y el proyecto final del alcance.

## 7. ✅ Respuestas

**Sin solución publicada** *(por defecto)*: cada ejercicio trae su criterio.

## 8. 💻 Código de ejemplo

**Sí** *(por defecto, como la semilla)*: TypeScript nativo en Node 24 para la API de rastreo (Express 5), la
plataforma mínima, la ingesta, el arnés, el generador y los simuladores; el driver de Node para Cassandra
contra Cassandra y ScyllaDB, `pg` contra PostgreSQL. **Sin codas en otros lenguajes** *(por defecto, como
Portalón)*.

## 9. 🎨 Inspiración

| Ruta | Tomar el tema | Tomar el estilo | Tomar la estructura |
|---|---|---|---|
| `prompts/_desechable-semilla.md` | sí, salvo el dominio de telemetría | no | sí, como borrador de E2 |
| `cursos-bd/ruta-no-sql-lite/` | no (requisito, R-07) | sí | parcialmente |
| `../00-proteo/prompts/` a `../04-telarana/prompts/` | no | sí | sí: la forma de `prompts/` de la ruta |

## 10. 📐 Diagramas

**Mermaid** *(por defecto)*. El anillo de tokens, el camino de escritura y lectura, y los dos centros de datos,
también en Mermaid.

## 11. 🧫 Tipo de prueba

**Creación y ejecución en contenedor** *(por defecto)*. Cassandra en varios nodos, ScyllaDB, PostgreSQL y el
servicio corren en el laboratorio; ninguno cuesta dinero. Bigtable, Amazon Keyspaces y los demás servicios
gestionados se tratan solo desde su documentación (☁️).

## 12. 📦 Código generado en `zz-code/`

**Sí, con documentación completa** *(por defecto)*.

## 13. 🎭 Historia

**Sí: Encomienda 305**, a partir del dominio que dio el autor el 07/10/2026: un courier de Miami con casilleros
virtuales, que recibe compras de Estados Unidos, China y Europa y las entrega en México, Panamá, Venezuela,
Colombia, Ecuador, Perú y Chile. El nombre de la empresa lo propuso la sesión (el código de área de Miami) y
queda a confirmar con la historia final. Villano: la plataforma de marca blanca puesta entera en el mismo
Cassandra que el rastreo —tarifas en seis tablas, saldo con contadores, consecutivos con transacciones
ligeras, reportes con `ALLOW FILTERING`—. Incidente: el Black Friday de 2025, con el rastreo sobreviviendo a
cuarenta minutos sin enlace entre centros de datos y todo lo demás fallando. La historia vive en
`../00-historia-de-encomienda-305.md`.

> 📝 **Por qué no telemetría.** La semilla era telemetría de una flota con roll-ups. Se descartó porque se pisa
> con la flota de lite (sus fases de columnar ancha usan los parámetros de vuelo) y con El Vigía, el curso de
> series temporales de la ruta, que es telemetría de infraestructura con agregación escalonada. El rastro de
> paquetes es escritura inmutable con consultas fijas, que es la familia, sin ser una serie de métricas.

## 14. 📝 Lo demás

- **Lo que NO quiero:** repetir lite; seguir con Cóndor; un curso de telemetría que se pise con El Vigía.
- **Tamaño:** unas **100 h en 10–12 fases** *(por defecto)* (D-04).
- **Rivales:** Cassandra como principal; ScyllaDB como rival de la familia; PostgreSQL particionado como
  control del rastreo y destino de la plataforma; Bigtable, Amazon Keyspaces y Astra solo desde documentación
  (D-16, D-22) *(por defecto, desde la semilla)*.
- **Carga:** generador propio en TypeScript; `cassandra-stress` solo si el generador no alcanza el caudal del
  pico (D-27) *(por defecto)*.

---

## 🔢 Traducción a decisiones

| Respuesta | Decisión del alcance | Estado |
|---|---|---|
| Tipo | D-02 curso completo | ✅ por defecto |
| Prerrequisito y autocontención | D-14 lite como requisito; D-03 sin usar su contenido (R-07) | ✅ |
| Profundidad | D-15 full geek | ✅ por defecto |
| Tamaño | D-04 ~100 h, 10–12 fases | ✅ por defecto |
| Rivales | D-16 Cassandra, ScyllaDB, PostgreSQL; D-22 gestionados ☁️ | ✅ por defecto |
| Historia | D-11 Encomienda 305 | ✅ |
| Nombre | D-34 Rastro | ✅ |
| Ejercicios, taller, código, diagramas, pruebas | D-05, D-09, D-12, D-08, D-17 | ✅ por defecto |
