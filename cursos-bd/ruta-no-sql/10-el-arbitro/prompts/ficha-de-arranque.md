# 🚀 Ficha de arranque
## El Árbitro — la persistencia políglota a fondo

> **Qué es:** las respuestas de la discusión de arranque (E0), confirmadas por el autor el 07/10/2026, y su
> traducción a las decisiones `D-xx` del alcance. Es la entrada de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que manda sobre ella desde que existe.
> **Origen:** la semilla de agosto (`_desechable-semilla.md`), una pregunta cerrada en la sesión y las reglas de
> la ruta. Lo que el autor no respondió va con el valor de la ruta o el precedente de los cursos anteriores,
> marcado *(por defecto)*.

---

## 1. 🏷️ Título tentativo

**El Árbitro — la persistencia políglota a fondo.** De qué va: una boletería de tres países que pasó de un
PostgreSQL a seis motores, con siete patrones de acceso genuinamente distintos y la costura entre motores como
objeto de estudio; con la fuente de verdad única, los derivados reconstruibles, la captura de cambios real, el
restore coherente y la factura operativa medida, para decidir cuántos motores hacen falta. **Por qué ahora:**
undécimo y último curso de la Ruta NoSQL, su cierre; la continuación en profundidad del bloque políglota de Ruta
NoSQL Lite; base para contenido en video.

## 2. 🧩 Tipo de curso

**Curso completo** *(por defecto)*.

## 3. 👤 Audiencia

**Senior que ya hizo Ruta NoSQL Lite** (D-14). Trae de lite, y no se le vuelve a explicar: las cinco preguntas
aplicadas a un sistema por partes, la fuente de verdad como decisión que ordena todo, que todo derivado tiene que
ser reconstruible, la escritura doble contra la bandeja de salida y la captura de cambios en lo básico, la ventana
de inconsistencia medida, la reconstrucción de un índice, qué hacer con un motor secundario caído, el costo
operativo de varios motores, y el árbol de veredicto de las diez familias.

> 📝 Las fases 23 a 25 de lite **todavía no están escritas**: el recorte se hace contra su propuesta de fases
> (`ruta-no-sql-lite/prompts/propuesta-fases-y-alcance.md`) y se revisa cuando se publiquen. **Ojo:** el bloque V
> de lite ya es un cierre políglota, con Cóndor. El Árbitro no lo repite: lo da por sabido y entra donde lite se
> detuvo —la captura de cambios real sobre el registro de PostgreSQL, la tubería de eventos con sus garantías, la
> evolución de los eventos, la reconciliación por rangos, el restore coherente entre motores y la factura medida
> con un método declarado—.

## 4. 🔬 Profundidad

**Full geek en la costura, no en cada motor** (D-15, D-35): ranuras de replicación y decodificación lógica de
PostgreSQL, Debezium y la tubería de eventos (particiones, orden por clave, desplazamientos, entrega al menos una
vez, consumidores idempotentes, mensajes que no se pueden procesar), contratos de eventos y su evolución,
reconciliación por sumas de control sobre rangos, restauración a un instante coordinada, y la factura. Cada motor
entra solo con la profundidad que pide la decisión de sumarlo: el riesgo de este curso es tocar seis motores de
refilón, y la defensa es que la profundidad vive en la integración.

## 5. 🧪 Ejercicios

**Sí, 20–30 por fase**, 🟢🟡🟠🔴 y 🔥, un tercio de diagnóstico o medición, **sin solución publicada** *(por
defecto, precedente de Proteo)*.

## 6. 🛠️ Taller

**Uno global** *(por defecto)*: la plataforma de Palco en sus tres arquitecturas, que crece fase a fase. Un 💀 boss
por bloque cuando el bloque lo admita, y el proyecto final del alcance.

## 7. ✅ Respuestas

**Sin solución publicada** *(por defecto)*: cada ejercicio trae su criterio.

## 8. 💻 Código de ejemplo

**Sí** *(por defecto, como la semilla)*: TypeScript nativo en Node 24 para la plataforma (Express 5 con Zod), los
publicadores y consumidores de la costura, el reconciliador, el simulador de preventa, el arnés y el generador; el
cliente de cada motor. **Sin codas en otros lenguajes**.

## 9. 🎨 Inspiración

| Ruta | Tomar el tema | Tomar el estilo | Tomar la estructura |
|---|---|---|---|
| `prompts/_desechable-semilla.md` | sí, con Palco en lugar de Ágora | no | sí, como borrador de E2 |
| `cursos-bd/ruta-no-sql-lite/` | no (requisito, R-07) | sí | parcialmente |
| `../00-proteo/prompts/` a `../09-libro-mayor/prompts/` | no | sí | sí: la forma de `prompts/` de la ruta |

## 10. 📐 Diagramas

**Mermaid** *(por defecto)*. Las tres arquitecturas, la tubería con sus desplazamientos y el restore coherente,
también en Mermaid.

## 11. 🧫 Tipo de prueba

**Creación y ejecución en contenedor** *(por defecto)*. Todos los motores, la tubería y el simulador corren en el
laboratorio; ninguno cuesta dinero. Los servicios gestionados se tratan solo desde su documentación (☁️).

## 12. 📦 Código generado en `zz-code/`

**Sí, con documentación completa** *(por defecto)*.

## 13. 🎭 Historia

**Sí: Palco**, empresa propia como eligió el autor el 07/10/2026 (la boletería de la semilla, con historia propia, y
no una empresa de la ruta). Nombre, ciudad y gente los propuso la sesión y quedan a confirmar con la historia final;
el sistema de la semilla se llamaba Ágora. Boletería de Santiago de Chile que opera en Chile, Perú y Colombia.
Villano: la arquitectura de seis motores de 2022, elegidos cada uno por su mejor caso, con escrituras dobles,
Kafka a medias, copias desparejas y nadie que opere Neo4j. Incidente: la preventa de Los Tiburones del Sur del 21 de
abril de 2026, con sobreventa, búsqueda que vendía lo agotado, precio viejo, liquidación descuadrada y un restore sin
instante común. La historia vive en `../00-historia-de-palco.md`.

> 📝 **Por qué empresa propia.** El plan de la ruta dejaba abierto si El Árbitro llevaba empresa propia o las de los
> otros diez cursos. Reutilizar una empresa de la ruta habría roto la regla de una empresa por curso y obligado a
> haber hecho los otros cursos; con empresa propia, el curso se sostiene solo con lite como requisito.

## 14. 📝 Lo demás

- **Lo que NO quiero:** repetir lite; seguir con Cóndor; un capstone que toque seis motores de refilón.
- **Tamaño:** unas **100 h en 10–12 fases** *(por defecto)* (D-04).
- **El "vs" es de arquitecturas, no de productos** (D-16): todo en PostgreSQL, la reducida que la medición
  defienda, y la de seis motores *(semilla)*.

---

## 🔢 Traducción a decisiones

| Respuesta | Decisión del alcance | Estado |
|---|---|---|
| Tipo | D-02 curso completo | ✅ por defecto |
| Prerrequisito y autocontención | D-14 lite como requisito; D-03 sin usar su contenido (R-07); D-34 la relación con la ruta | ✅ |
| Profundidad | D-15 full geek en la costura; D-35 cada motor solo lo que la decisión pide | ✅ por defecto |
| Tamaño | D-04 ~100 h, 10–12 fases | ✅ por defecto |
| Arquitecturas y motores | D-16, D-24, D-25, D-33 | ✅ por defecto |
| Historia | D-11 Palco | ✅ |
| Ejercicios, taller, código, diagramas, pruebas | D-05, D-09, D-12, D-08, D-17 | ✅ por defecto |
