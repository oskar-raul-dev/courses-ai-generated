# 🚀 Ficha de arranque
## Proteo — el modelo documental a fondo

> **Qué es:** las respuestas de la discusión de arranque (E0), confirmadas por el autor el 06/10/2026,
> y su traducción a las decisiones `D-xx` del alcance. Es la entrada de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que manda sobre ella desde que existe.
> **Origen:** la semilla de agosto (`_desechable-semilla.md`) y cuatro preguntas cerradas en la sesión.
> Lo que el autor no respondió va con el valor por defecto heredado de Ruta NoSQL Lite, marcado
> *(por defecto)*.

---

## 1. 🏷️ Título tentativo

**Proteo — el modelo documental a fondo.** De qué va: cuándo un dominio vota documento, cómo se modela,
cómo se mide contra el relacional bien jugado y qué pasa dentro del motor cuando la cosa crece.
**Por qué ahora:** es el primer curso de la Ruta NoSQL, la continuación en profundidad de Ruta NoSQL
Lite; y una base para contenido en video.

## 2. 🧩 Tipo de curso

**Curso completo** *(por defecto)*: el lector construye y opera el backend del catálogo de una empresa y
mide cada decisión.

## 3. 👤 Audiencia

**Senior, que ya hizo Ruta NoSQL Lite** (D-14). Sabe SQL y modelado relacional de oficio, programa en
TypeScript, y trae de lite: las cinco preguntas, el arnés de medida, el minicurso documental (embeber o
referenciar, `explain`, `$lookup`, índices multikey, el límite de 16 MB, transacciones) y la costumbre
de apostar antes de medir. **No se le vuelve a explicar nada de eso.**

## 4. 🔬 Profundidad

**Full geek** (D-15): lo de la semilla, más el motor por dentro —WiredTiger (caché, compresión,
checkpoints), oplog y replica set, change streams con reanudación, y sharding con la clave mal elegida
medida—.

## 5. 🧪 Ejercicios

**Sí, 20–30 por fase**, de 🟢 a 🔴 con 🔥 opcionales, al menos un tercio de diagnóstico o medición
*(por defecto, el criterio de lite)*.

## 6. 🛠️ Taller

**Uno global**: el backend del catálogo de Mercado Ceibo, que crece fase a fase. Un 💀 boss por bloque
cuando el bloque lo admita, y el proyecto final del alcance §13 (cerrado el 06/10/2026).

## 7. ✅ Respuestas

**Sin solución publicada**: cada ejercicio trae su criterio para autoevaluarse (cerrado el 06/10/2026).

## 8. 💻 Código de ejemplo

**Sí** *(por defecto)*: TypeScript ejecutado nativo en Node 24 para el arnés y el generador, como en
lite; driver nativo de MongoDB, sin ODM; API mínima con Express 5; Meilisearch para la búsqueda;
Valkey con `iovalkey` para carrito y caché (cerrado el 06/10/2026).

## 9. 🎨 Inspiración

| Ruta | Tomar el tema | Tomar el estilo | Tomar la estructura |
|---|---|---|---|
| `prompts/_desechable-semilla.md` | sí | no | sí, como borrador de E2 |
| `cursos-bd/ruta-no-sql-lite/` | no (se da por sabido) | sí: tono, mediciones, honestidad | parcialmente: plantilla de fase y documentos vivos |
| `zz-instrucciones/plantillas/` | no | no | sí: forma de `prompts/` |

## 10. 📐 Diagramas

**Mermaid** *(por defecto)*.

## 11. 🧫 Tipo de prueba

**Creación y ejecución en contenedor** *(por defecto)*. Amazon DocumentDB es la excepción: cuesta dinero,
así que se trata desde su documentación y todo lo que se diga de él se marca **no verificado** (D-16).

## 12. 📦 Código generado en `zz-code/`

**Sí, con documentación completa** *(por defecto)*.

## 13. 🎭 Historia

**Sí: Mercado Ceibo**, elegida entre tres candidatas el 06/10/2026. Marketplace regional nacido en
Medellín vendiendo libros usados, hoy con cuatro verticales y operación en Lima. En 2019 compró una
tienda de electrónica cuyo e-commerce traía un catálogo EAV, y ese PIM quedó como el de toda la empresa.
El dolor que abre el curso: la quinta vertical, repuestos de moto, con compatibilidades por modelo y año.
La historia vive en `../00-historia-de-mercado-ceibo.md`.

## 14. 📝 Lo demás

- **Lo que NO quiero:** repetir lite; seguir con Cóndor.
- **Tamaño:** unas **100 h en 10–12 fases** de unas 10 h (D-04).
- **Rivales:** PostgreSQL (EAV y JSONB), Couchbase y Amazon DocumentDB (D-16). El autor considera
  suficientes tres casos de estudio.
- **Notas:** el curso es la primera de once fichas de la ruta; las decisiones comunes están en
  `../../_desechable-plan-de-la-ruta.md`.

---

## 🔢 Traducción a decisiones

| Respuesta | Decisión del alcance | Estado |
|---|---|---|
| Tipo | D-02 curso completo | ✅ por defecto |
| Audiencia y prerrequisito | D-14 Ruta NoSQL Lite como requisito | ✅ |
| Profundidad | D-15 full geek | ✅ |
| Tamaño | D-04 ~100 h, 10–12 fases | ✅ |
| Rivales | D-16 PostgreSQL, Couchbase, DocumentDB (solo documentación) | ✅ |
| Historia | D-11 Mercado Ceibo | ✅ |
| Diagramas | D-12 Mermaid | ✅ por defecto |
| Ejercicios, taller y respuestas | D-05, D-09 | ✅ |
| Autocontención | D-03 lite solo como requisito, sin usar su contenido | ✅ |
| Stack fuera del arnés | D-17 Express 5, D-18 Meilisearch, D-19 Valkey | ✅ |
| Mediciones | D-20 `BENCHMARKS.md` | ✅ |
| Liquidación | D-23 mini-servicio real | ✅ |
