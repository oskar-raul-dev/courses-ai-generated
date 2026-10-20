# 🧰 `prompts/` — la maquinaria del paquete
## Tiquetera: Curso 01 (Vue 2 legacy) y Curso 02 (MongoDB/Express)

Este directorio no es material del curso: es **lo que se usa para escribirlo**. El lector nunca lo abre, y
ningún documento publicado lo enlaza (guía §17.2). Quien escribe o revisa una fase lo lee entero antes de
tocar el archivo.

> **Estado:** cerrado el 18/10/2026. Los dos cursos están escritos, alineados con los lineamientos del
> repositorio y validados por ejecución; qué se corrió y qué queda está en la guía §17.4.

---

## 📖 Qué hay aquí, y cuándo se lee

| Documento | Qué es | Cuándo se lee |
|---|---|---|
| [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md) | cómo se escribe el paquete, con sus excepciones declaradas en §17 | en cada sesión, siempre |
| [`plantilla-de-fase.md`](plantilla-de-fase.md) | el esqueleto de las nueve secciones de una fase | al empezar y al cerrar cada fase |
| [`diccionario-codigo.md`](diccionario-codigo.md) | los identificadores del código del dominio, en inglés | cada vez que dudes de un nombre en el código |
| [`instrucciones-proyecto-track-b.md`](instrucciones-proyecto-track-b.md) | el alcance y el marco del Curso 02 | antes de escribir cualquier fase del Curso 02 |
| [`formato-piezas-forenses.md`](formato-piezas-forenses.md) | el formato de cada pieza del track forense | al escribir una pieza forense |
| [`formato-cuaderno-incidentes.md`](formato-cuaderno-incidentes.md) | el formato de cada incidente del cuaderno | al escribir o revisar un incidente |
| [`preparaciones-de-incidentes.md`](preparaciones-de-incidentes.md) | cómo se arma cada incidente de los dos cuadernos (el `db.json` alterno del Curso 01, la base de cada uno del Curso 02), con lo que se corrió | al revisar o cambiar un incidente del cuaderno |
| `verificar-corpus.py` y `verificador_base.py` | las validaciones base del repositorio y las propias del paquete | al cerrar cada tanda |

No queda ningún `_desechable-*`: se borraron al cerrar, el 18/10/2026, y el historial de git los conserva.
Si una edición futura necesita un plan, lo abre con ese prefijo y lo borra al terminar (guía §13.3).

**Orden de autoridad**, cuando dos documentos se contradicen: (1) la ficha `../00-historia-del-sistema.md`
y el contrato `../02-complement-mongodb-backend/00-audit-contrato.md`, (2) la guía de estilo, (3) los
formatos y las plantillas, (4) el plan de la edición en curso, si hay uno, solo sobre el orden, (5) los documentos ya publicados, (6) las
decisiones del chat actual.

> 🧭 **Si una contradicción aparece al escribir, se arregla en el documento de arriba primero.** Parchear
> la fase y dejar la guía desactualizada es como empiezan las divergencias que nadie detecta hasta la fase
> doce.

---

## 🚀 Cómo abrir una sesión

1. Lee la guía, §13 y §17: §17.4 dice qué se validó y qué decisiones quedaron abiertas, y §17.5 las reglas
   de ejecución que dejó la edición anterior.
2. Si la sesión es parte de una edición con plan, lee el plan.
3. Sigue el protocolo de tres pasos del repositorio: preguntas, redacción, autoverificación contra la guía
   §15 y el verificador.
4. Al cerrar: `python3 prompts/verificar-corpus.py` y, si lo hay, el plan al día.

**Una sesión, una tanda.** No se mezclan tandas en la misma sesión, y el código de prueba va a `zz-code/`,
no aquí.

---

## ✅ Cómo se verifica

Desde la raíz del paquete:

```bash
python3 prompts/verificar-corpus.py                  # el paquete entero
python3 prompts/verificar-corpus.py 01-vue2-legacy   # un curso
python3 prompts/verificar-corpus.py --publicacion    # además, lo que exige la etapa E9
```

Los avisos aceptados, y por qué, están en la guía §17.3. Cualquier otro aviso o error es trabajo pendiente.

---

## ⚠️ Lo que más se rompe al escribir

- **Citar un archivo de `prompts/` desde lo publicado.** En el repositorio público no existiría. Lo que el
  lector necesita se escribe en prosa, y la referencia se quita.
- **Dejar un diagrama en ASCII.** Los flujos, estados y secuencias van en Mermaid (guía §17.1); el verificador
  avisa con `DIAGRAMA`.
- **Afirmar sin ejecutar.** Un comando o una salida que no se corrió se marca «no verificado por ejecución»;
  no se publica como si hubiera corrido.
