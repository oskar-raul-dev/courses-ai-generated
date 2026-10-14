# 🧰 `prompts/` — la maquinaria del curso
## El Árbitro — la persistencia políglota a fondo

Este directorio no es material del curso: es **lo que se usa para escribirlo**. El lector nunca lo abre. Quien
escribe una fase lo lee entero antes de teclear la primera línea.

> **Estado:** en preparación. Ficha, alcance (36 decisiones cerradas) y guía cerrados el 07/10/2026, salvo lo
> que depende de las fases. **Solo faltan la propuesta de fases (E2) y la versión final de la historia**, que se
> trabajan ahora que los once cursos de la ruta tienen su `prompts/`.

---

## 📖 Qué hay aquí, y cuándo se lee

| Documento | Qué es | Cuándo se lee |
|---|---|---|
| [`ficha-de-arranque.md`](ficha-de-arranque.md) | las respuestas de la discusión de arranque y su traducción a decisiones | al retomar el diseño; manda el alcance |
| [`alcance-del-proyecto.md`](alcance-del-proyecto.md) | qué enseña el curso, a quién, con qué límites; las decisiones `D-xx` | antes de escribir cualquier cosa |
| [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md) | cómo se escribe; checklist de §12 | en cada sesión, siempre |
| [`../00-historia-de-palco.md`](../00-historia-de-palco.md) | la empresa, su gente, sus cifras y sus reglas; la lee el lector | cada vez que una fase necesita un dato de la empresa |

**Por escribir**, en este orden: `propuesta-fases-y-alcance.md` y `propuesta-apendices-y-alcance.md` (E2),
`plan-de-produccion.md` (E3), `diccionario-de-terminos.md`, `contrato-de-nombres.md`,
`plantillas-de-capitulo.md` y el verificador (E4), `prompts-de-fase.md` y `prompts-de-apendice.md` (E5).

**De consulta, sin autoridad** (los documentos de agosto; no se citan desde el curso):

| Documento | Para qué sirve todavía |
|---|---|
| `_desechable-semilla.md` | **el borrador del temario**: manda como fuente de temas hasta que la propuesta de fases se cierre; Ágora pasó a ser Palco, y su tabla de la factura es el punto de partida de D-27 |
| `_desechable-alcance-v1.md` | el árbol de "cuándo NO sumar un motor", a reutilizar en E2 |
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
    HI["historia de Palco"] -. "manda en lo narrativo" .-> PU
```

> 🧭 **Si una contradicción aparece al escribir, se arregla en el documento de arriba primero.**

---

## 🚀 Lo que sigue

1. **E2**: el arco de bloques y la lista de fases primero; con el arco aprobado, las fichas. Punto de partida: la
   semilla, el alcance §9 y los dieciocho dolores de la historia. **Antes**, mirar si las fases 23 a 25 de Ruta
   NoSQL Lite ya están escritas: el recorte se hizo contra su propuesta, y su bloque V ya es un cierre políglota.
2. Con las fases, la versión final de la historia (cada dolor atado a su fase; confirmar el nombre de la empresa),
   la plantilla de fase de la guía y el formato de `FACTURA.md`.
3. E3 en adelante, según `zz-instrucciones/00-workflow-de-un-curso.md`.

---

## ⚠️ Las tres cosas que más se van a romper al escribir

- **Volver a explicar lo que lite ya enseñó** (las familias, la fuente de verdad, la escritura doble contra la bandeja
  en lo básico), o **convertir una fase en el tutorial de un motor**.
- **Publicar una arquitectura sin su factura**, una divergencia sin la verdad contra el derivado, o un consumidor sin
  su clave de idempotencia.
- **Inventar un dato de Palco** que debía salir de la historia, o citar los otros cursos de la ruta desde lo publicado.
