# 🧰 `prompts/` — la maquinaria del curso
## Buscafino — el modelo de búsqueda a fondo

Este directorio no es material del curso: es **lo que se usa para escribirlo**. El lector nunca lo abre. Quien
escribe una fase lo lee entero antes de teclear la primera línea.

> **Estado:** en preparación. Ficha, alcance (36 decisiones cerradas) y guía cerrados el 07/10/2026, salvo lo
> que depende de las fases. **Solo faltan la propuesta de fases (E2) y la versión final de la historia**, que se
> trabajan cuando todos los cursos de la ruta tengan su `prompts/`.

---

## 📖 Qué hay aquí, y cuándo se lee

| Documento | Qué es | Cuándo se lee |
|---|---|---|
| [`ficha-de-arranque.md`](ficha-de-arranque.md) | las respuestas de la discusión de arranque y su traducción a decisiones | al retomar el diseño; manda el alcance |
| [`alcance-del-proyecto.md`](alcance-del-proyecto.md) | qué enseña el curso, a quién, con qué límites; las decisiones `D-xx` | antes de escribir cualquier cosa |
| [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md) | cómo se escribe; checklist de §12 | en cada sesión, siempre |
| [`../00-historia-de-vacantia.md`](../00-historia-de-vacantia.md) | la empresa, su gente, sus cifras y sus reglas; la lee el lector | cada vez que una fase necesita un dato de la empresa |

**Por escribir**, en este orden: `propuesta-fases-y-alcance.md` y `propuesta-apendices-y-alcance.md` (E2),
`plan-de-produccion.md` (E3), `diccionario-de-terminos.md`, `contrato-de-nombres.md`,
`plantillas-de-capitulo.md` y el verificador (E4), `prompts-de-fase.md` y `prompts-de-apendice.md` (E5).

**De consulta, sin autoridad** (los documentos de agosto; no se citan desde el curso):

| Documento | Para qué sirve todavía |
|---|---|
| `_desechable-semilla.md` | **el borrador del temario**: manda como fuente de temas hasta que la propuesta de fases se cierre, **salvo el dominio y el titular**: el marketplace y Meilisearch como motor principal quedaron fuera (ficha §13, D-16) |
| `_desechable-alcance-v1.md` | el árbol de "cuándo NO usar un motor de búsqueda", a reutilizar en E2 |
| `_desechable-guia-de-estilo-v1.md` | la guía de agosto, ya absorbida por la nueva |
| `_desechable-prompts-v1.md` | los prompts de agosto, de referencia para E5 |

**Orden de autoridad**, cuando dos se contradicen: (1) el alcance, (2) la guía, (3) el contrato y el
diccionario, (4) la propuesta, (5) las plantillas y los formatos, (6) los prompts, (7) el plan, solo sobre el
orden, (8) los documentos ya publicados, (9) las decisiones del chat actual. La historia manda sobre todo lo
narrativo.

```mermaid
flowchart TD
    AL["alcance"] --> GU["guía"] --> NO["contrato y diccionario"] --> PR["propuesta"]
    PR --> PL["plantillas y formatos"] --> PF["prompts"] --> PP["plan: solo el orden"]
    PP --> PU["documentos publicados"] --> CH["decisiones del chat"]
    HI["historia de Vacantia"] -. "manda en lo narrativo" .-> PU
```

> 🧭 **Si una contradicción aparece al escribir, se arregla en el documento de arriba primero.**

---

## 🚀 Lo que sigue

1. **E2**, cuando los once cursos de la ruta tengan su `prompts/`: el arco de bloques y la lista de fases
   primero; con el arco aprobado, las fichas. Punto de partida: la semilla (sin el marketplace), el alcance §9 y
   los veinte dolores de la historia. **Antes**, mirar si las fases 11 y 12 de Ruta NoSQL Lite ya están
   escritas: el recorte se hizo contra su propuesta, y lite ya cierra con "índice, no fuente de verdad".
2. Con las fases, la versión final de la historia (cada dolor atado a su fase; confirmar el nombre y la sede de
   la empresa) y la plantilla de fase de la guía.
3. E3 en adelante, según `zz-instrucciones/00-workflow-de-un-curso.md`.

---

## ⚠️ Las tres cosas que más se van a romper al escribir

- **Volver a explicar lo que lite ya enseñó** (el índice invertido, los analizadores básicos, el disco lleno, y
  sobre todo volver a demostrar que el índice no es una fuente de verdad).
- **Publicar un cambio de relevancia sin su número contra los juicios**, una faceta sin su conteo contra el
  exacto, o un tiempo sin corpus, idiomas y consultas por segundo; o dejar a PostgreSQL sin ParadeDB.
- **Inventar un dato de Vacantia** que debía salir de la historia, o deslizarse a la búsqueda semántica, que no
  es este curso.
