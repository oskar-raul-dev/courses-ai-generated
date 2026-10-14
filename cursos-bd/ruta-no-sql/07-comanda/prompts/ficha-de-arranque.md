# 🚀 Ficha de arranque
## Comanda — el modelo offline-first a fondo

> **Qué es:** las respuestas de la discusión de arranque (E0), confirmadas por el autor el 07/10/2026, y su
> traducción a las decisiones `D-xx` del alcance. Es la entrada de
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que manda sobre ella desde que existe.
> **Origen:** la semilla de agosto (`_desechable-semilla.md`, escrita como «Bitácora de Campo»), una pregunta
> cerrada en la sesión y las reglas de la ruta. Lo que el autor no respondió va con el valor de la ruta o el
> precedente de los cursos anteriores, marcado *(por defecto)*.

---

## 1. 🏷️ Título tentativo

**Comanda — el modelo offline-first a fondo.** De qué va: las tablets de los meseros, las pantallas de cocina y
las cajas de una cadena de restaurantes que tiene que seguir vendiendo sin internet, con varias tablets
escribiendo sobre la misma mesa; con la replicación y el conflicto como primitivas del motor, medido contra un
CRDT, contra un servicio gestionado y contra la sincronización de PostgreSQL. **Por qué ahora:** octavo curso de
la Ruta NoSQL, la continuación en profundidad del minicurso offline-first de Ruta NoSQL Lite; base para
contenido en video.

> 📝 **El nombre cambió** (D-34). La semilla se llamaba «Bitácora de Campo», que describía inspecciones de campo;
> con el dominio de restaurantes que eligió el autor, la sesión renombró el curso a **Comanda** siguiendo el
> precedente de Rastro. El directorio pasó de `07-bitacora-de-campo/` a `07-comanda/` el 07/10/2026. A confirmar
> por el autor.

## 2. 🧩 Tipo de curso

**Curso completo** *(por defecto)*.

## 3. 👤 Audiencia

**Senior que ya hizo Ruta NoSQL Lite** (D-14). Trae de lite, y no se le vuelve a explicar: la replicación
bidireccional, la revisión del documento como historia y no como versión, detectar y resolver un conflicto en lo
básico, qué es un CRDT en una frase, el volumen de sincronización y el tamaño del historial, el conflicto masivo
provocado, la compactación, el límite razonable de una base local, y que esta familia tiene el mayor costo de
complejidad por unidad de beneficio.

> 📝 Las fases 19 y 20 de lite **todavía no están escritas**: el recorte se hace contra su propuesta de fases
> (`ruta-no-sql-lite/prompts/propuesta-fases-y-alcance.md`) y se revisa cuando se publiquen. **Por qué no
> inspecciones:** la semilla eran inspecciones de campo, y lite ya usó un técnico itinerante (Cóndor) y los
> extensionistas de Cumbre Roja; los restaurantes traen lo que el campo no trae: muchos dispositivos editando lo
> mismo a la vez, con cortes cortos y frecuentes.

## 4. 🔬 Profundidad

**Full geek** (D-15) *(por defecto, como los anteriores)*: el protocolo de replicación por dentro (feed de
cambios, puntos de control, diferencias de revisiones, pedidos por lote), el árbol de revisiones y la ganadora
determinista, relojes lógicos e híbridos, los CRDT por dentro (conjuntos, contadores, listas y su costo en
metadatos), la topología en tres niveles, la replicación filtrada, los adjuntos, la validación en el servidor, el
borrado y la purga, la compactación y el límite de revisiones, y el almacenamiento del dispositivo.

## 5. 🧪 Ejercicios

**Sí, 20–30 por fase**, 🟢🟡🟠🔴 y 🔥, un tercio de diagnóstico o medición, **sin solución publicada** *(por
defecto, precedente de Proteo)*.

## 6. 🛠️ Taller

**Uno global** *(por defecto)*: el sistema de mesas de La Cazuela, que crece fase a fase. Un 💀 boss por bloque
cuando el bloque lo admita, y el proyecto final del alcance.

## 7. ✅ Respuestas

**Sin solución publicada** *(por defecto)*: cada ejercicio trae su criterio.

## 8. 💻 Código de ejemplo

**Sí** *(por defecto, como la semilla)*: TypeScript nativo en Node 24 para las tablets simuladas (PouchDB), la
API de lo que no es sincronización (Express 5 con Zod), el arnés, el generador y los simuladores de red; el
cliente de cada rival. **Sin codas en otros lenguajes**.

## 9. 🎨 Inspiración

| Ruta | Tomar el tema | Tomar el estilo | Tomar la estructura |
|---|---|---|---|
| `prompts/_desechable-semilla.md` | sí, salvo el dominio de inspecciones | no | sí, como borrador de E2 |
| `cursos-bd/ruta-no-sql-lite/` | no (requisito, R-07) | sí | parcialmente |
| `../00-proteo/prompts/` a `../06-buscafino/prompts/` | no | sí | sí: la forma de `prompts/` de la ruta |

## 10. 📐 Diagramas

**Mermaid** *(por defecto)*. El árbol de revisiones, la topología tablet–local–nube y el recorrido de una
replicación, también en Mermaid.

## 11. 🧫 Tipo de prueba

**Creación y ejecución en contenedor** *(por defecto)*. CouchDB, las tablets simuladas, Automerge, el emulador de
Firestore, ElectricSQL y PostgreSQL corren en el laboratorio; ninguno cuesta dinero. El costo de Firestore se
trata solo desde su documentación (☁️).

## 12. 📦 Código generado en `zz-code/`

**Sí, con documentación completa** *(por defecto)*.

## 13. 🎭 Historia

**Sí: La Cazuela**, a partir del dominio que eligió el autor el 07/10/2026 (restaurantes y comandas). Nombre,
ciudad y gente los propuso la sesión y quedan a confirmar con la historia final. Cadena de restaurantes costeños
de Barranquilla con treinta y ocho locales. Villano: la cola de operaciones de cada tablet, que gana por el reloj
de la tablet y reescribe la cuenta entera. Incidente: el sábado de Carnaval de 2026, con cuatro locales cuatro
horas y cuarenta minutos sin internet, que venden bien y se descuadran al volver la red. La historia vive en
`../00-historia-de-la-cazuela.md`.

## 14. 📝 Lo demás

- **Lo que NO quiero:** repetir lite; seguir con Cóndor; otra app de inspecciones.
- **Tamaño:** unas **100 h en 10–12 fases** *(por defecto)* (D-04).
- **Rivales:** CouchDB con PouchDB como principal; Automerge como CRDT; Firestore en su emulador; ElectricSQL;
  PostgreSQL como base de verdad y como villano (D-16, D-24, D-25, D-33) *(por defecto, desde la semilla, con
  Automerge agregado porque la mesa compartida es el caso de los CRDT)*.

---

## 🔢 Traducción a decisiones

| Respuesta | Decisión del alcance | Estado |
|---|---|---|
| Tipo | D-02 curso completo | ✅ por defecto |
| Prerrequisito y autocontención | D-14 lite como requisito; D-03 sin usar su contenido (R-07) | ✅ |
| Profundidad | D-15 full geek | ✅ por defecto |
| Tamaño | D-04 ~100 h, 10–12 fases | ✅ por defecto |
| Rivales | D-16, D-24, D-25, D-33 | ✅ por defecto |
| Historia | D-11 La Cazuela | ✅ |
| Nombre | D-34 Comanda | ✅ a confirmar |
| Ejercicios, taller, código, diagramas, pruebas | D-05, D-09, D-12, D-08, D-17 | ✅ por defecto |
