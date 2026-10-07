# 🚀 Ficha de arranque
## Portalón — el modelo clave-valor a fondo

> **Qué es:** las respuestas de la discusión de arranque (E0), confirmadas por el autor el 06/10/2026,
> y su traducción a las decisiones `D-xx` del alcance. Es la entrada de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que manda sobre ella desde que existe.
> **Origen:** la semilla de agosto (`_desechable-semilla.md`), cuatro preguntas cerradas en la sesión y
> las reglas de la ruta. Lo que el autor no respondió va con el valor de la ruta o el precedente de
> Proteo, marcado *(por defecto)*.

---

## 1. 🏷️ Título tentativo

**Portalón — el modelo clave-valor a fondo.** De qué va: el estado caliente y efímero que se sienta
delante de la base de verdad, modelado con la estructura nativa que le corresponde, medido contra tres
motores compatibles y contra PostgreSQL, y entendido por dentro. **Por qué ahora:** segundo curso de la
Ruta NoSQL, la continuación en profundidad del minicurso clave-valor de Ruta NoSQL Lite; base para
contenido en video.

## 2. 🧩 Tipo de curso

**Curso completo** *(por defecto)*.

## 3. 👤 Audiencia

**Senior que ya hizo Ruta NoSQL Lite** (D-14). Trae de lite, y no se le vuelve a explicar: que el nombre
de la clave es el esquema, hashes con TTL, `SET NX` para reservar, el candado que solo suelta su dueño,
colas con sorted set, streams con grupos de consumidores, pipeline y autopipelining, que todo vive en
RAM, RDB contra AOF y la tabla `UNLOGGED` como línea base.

## 4. 🔬 Profundidad

**Full geek** (D-15): el motor por dentro —el bucle de eventos y los hilos de E/S, las codificaciones
compactas y lo que ahorran, la fragmentación del asignador, el fork y la copia al escribir del snapshot,
el backlog de replicación y el failover, los hash slots del clúster, el caché del lado del cliente con
RESP3, Lua y las funciones—.

## 5. 🧪 Ejercicios

**Sí, 20–30 por fase**, 🟢🟡🟠🔴 y 🔥, un tercio de diagnóstico o medición, **sin solución publicada**
*(por defecto, precedente de Proteo)*.

## 6. 🛠️ Taller

**Uno global** *(por defecto)*: el gateway de Liga Pixel, que crece fase a fase. Un 💀 boss por bloque
cuando el bloque lo admita, y el proyecto final del alcance.

## 7. ✅ Respuestas

**Sin solución publicada** *(por defecto)*: cada ejercicio trae su criterio.

## 8. 💻 Código de ejemplo

**Sí** *(por defecto)*: TypeScript nativo en Node 24, API del gateway con Express 5, cliente `iovalkey`
contra los cuatro motores compatibles con el protocolo.

## 9. 🎨 Inspiración

| Ruta | Tomar el tema | Tomar el estilo | Tomar la estructura |
|---|---|---|---|
| `prompts/_desechable-semilla.md` | sí | no | sí, como borrador de E2 |
| `cursos-bd/ruta-no-sql-lite/` | no (requisito, R-07) | sí | parcialmente |
| `../00-proteo/prompts/` | no | sí | sí: la forma de `prompts/` de la ruta |

## 10. 📐 Diagramas

**Mermaid** *(por defecto)*.

## 11. 🧫 Tipo de prueba

**Creación y ejecución en contenedor** *(por defecto)*. Los cuatro motores en memoria y PostgreSQL corren
en el laboratorio; ninguno cuesta dinero.

## 12. 📦 Código generado en `zz-code/`

**Sí, con documentación completa** *(por defecto)*.

## 13. 🎭 Historia

**Sí: Liga Pixel**, elegida entre tres candidatas el 06/10/2026. Plataforma de torneos de videojuegos de
Ciudad de México con operación en Bogotá: rankings en vivo con millones de jugadores, cola de
emparejamiento, sesiones de partida y límites contra bots. Villano: los perfiles, el inventario de
premios y el saldo de monedas guardados en Redis *"porque el ranking ya estaba ahí"*. La historia vive
en `../00-historia-de-liga-pixel.md`.

## 14. 📝 Lo demás

- **Lo que NO quiero:** repetir lite; seguir con Cóndor; **la coda en Java y Go** (el autor no la marcó:
  queda fuera, D-26).
- **Tamaño:** unas **100 h en 10–12 fases** (D-04).
- **Rivales:** Redis 8, Dragonfly y Microsoft Garnet frente a Valkey; PostgreSQL como base de verdad de
  control (D-16).

---

## 🔢 Traducción a decisiones

| Respuesta | Decisión del alcance | Estado |
|---|---|---|
| Tipo | D-02 curso completo | ✅ por defecto |
| Prerrequisito y autocontención | D-14 lite como requisito; D-03 sin usar su contenido (R-07) | ✅ |
| Profundidad | D-15 full geek | ✅ |
| Tamaño | D-04 ~100 h, 10–12 fases | ✅ |
| Rivales | D-16 Redis 8, Dragonfly, Garnet; PostgreSQL de control | ✅ |
| Historia | D-11 Liga Pixel | ✅ |
| Coda multilenguaje | D-26 fuera | ✅ |
| Ejercicios, taller, código, diagramas, pruebas | D-05, D-09, D-12, D-08 | ✅ por defecto |
