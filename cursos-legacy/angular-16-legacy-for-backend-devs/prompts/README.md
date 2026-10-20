# 🧰 `prompts/` — la maquinaria del curso
## Tutorial Angular 16 — Inspecciones y certificaciones (track BE incluido)

> **Nota:** el manual de operación del `prompts/` de este curso, con el inventario real de sus archivos.
> Describe solo lo normativo; el estado de cada edición vive en su plan.

Este directorio no es material del curso: es **lo que se usa para escribirlo**. El lector nunca lo
abre. Quien escribe una fase lo lee entero antes de teclear la primera línea.

> **Estado:** edición de la historia y del track BE cerrada el 14/10/2026. Pendiente de revisión final
> del autor; el plan de edición que la guio ya no existe, y lo que debía sobrevivir está en la §16 de
> la guía y en la historia.

---

## 📖 Qué hay aquí, y cuándo se lee

| Documento | Qué es | Cuándo se lee |
|---|---|---|
| [`alcance-del-proyecto.md`](alcance-del-proyecto.md) | qué enseña el curso, a quién, con qué límites y con cuántas horas (123h) | antes de escribir cualquier cosa |
| [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md) | cómo se escribe; la ficción (§11, §15.5); las excepciones a los lineamientos (§16) | en cada sesión, siempre |
| [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) | la secuencia de las 15 fases del track base, sus horas y la ficha de cada una | en cada sesión de fase |
| [`propuesta-fases-backend.md`](propuesta-fases-backend.md) | el track BE: sus ocho fases, la defensa de Lumen y la ficción de `certcore-api` | en cada sesión del track BE |
| [`plantillas-de-capitulo.md`](plantillas-de-capitulo.md) | los esqueletos de fase, apéndice y cuaderno | al empezar y al cerrar cada documento |
| [`prompts-extendidos-fases.md`](prompts-extendidos-fases.md) | el marco común y un bloque por fase del track base | al abrir cada sesión de fase |
| [`prompts-backend-fase.md`](prompts-backend-fase.md) | el marco y un bloque por fase del track BE | al abrir cada sesión del track BE |
| [`prompts-extendidos-apendices.md`](prompts-extendidos-apendices.md) | un bloque por apéndice del track base | al abrir cada sesión de apéndice |
| [`prompts-backend-apendice.md`](prompts-backend-apendice.md) | un bloque por apéndice del track BE | al abrir cada sesión de apéndice BE |
| [`formato-cuaderno-incidentes.md`](formato-cuaderno-incidentes.md) | la plantilla de cada incidente, su categoría, su escala y su conteo | al escribir un incidente |
| [`preparaciones-de-incidentes.md`](preparaciones-de-incidentes.md) | cómo llega cada incidente roto a la máquina del lector, por archivo de datos, rama o flag | al preparar un incidente |
| [`preparaciones-de-incidentes-be.md`](preparaciones-de-incidentes-be.md) | lo mismo, para el cuaderno del track BE | al preparar un incidente BE |
| [`formato-piezas-forenses.md`](formato-piezas-forenses.md) | la forma de las piezas forenses que cierran cada fase | al escribir una pieza forense |
| [`verificar-corpus.py`](verificar-corpus.py) y [`verificador_base.py`](verificador_base.py) | las validaciones base del repositorio y las del curso (ver abajo) | al cerrar cada tanda |
| [`verificar-forenses.py`](verificar-forenses.py) | la estructura de cada pieza forense y las dos marcas de cierre de cada paso (lo que se puede comprobar sin leer) | al cerrar cada fase |

Fuera de `prompts/`, en la raíz del curso: `00-convencion-de-git-y-tags.md` (commits y tags de fase,
ejercicio e incidente, publicado) y `00-historia-del-sistema.md` (la empresa, su historia y su
cronología; manda sobre cualquier dato narrativo).

**Orden de autoridad**, cuando dos documentos se contradicen:

1. el alcance;
2. la guía de estilo (su §16 manda sobre el resto de la guía);
3. la historia de la empresa, para cualquier dato narrativo;
4. la propuesta de fases;
5. las plantillas, los formatos y las preparaciones;
6. los prompts;
7. el plan de edición, solo sobre el orden de las tandas;
8. los documentos ya publicados;
9. las decisiones de la conversación actual.

> 🧭 **Si una contradicción aparece al escribir, se arregla en el documento de arriba primero.**
> Parchear la fase y dejar la propuesta desactualizada es como empiezan las divergencias que nadie
> detecta hasta la fase doce.

---

## 🚀 Cómo abrir una sesión de escritura

1. Lee el alcance y la guía (§11, §15.5 y §16 si el capítulo es del track BE).
2. Lee la historia (`00-historia-del-sistema.md`) si el capítulo nombra a alguien, a una empresa, una
   fecha o un cliente. Ningún dato narrativo se inventa en el capítulo.
3. Pega el marco común y el bloque del capítulo de `prompts-extendidos-*` o `prompts-backend-*`.
4. Sigue el protocolo de tres pasos: preguntas sin redactar → redacción → autoverificación contra la
   guía §14.
5. Al cerrar: `python3 prompts/verificar-corpus.py` y, si hay piezas forenses, `verificar-forenses.py`.

**Una sesión, un archivo** (más lo que ese archivo alimenta en la misma tanda). Si una sesión no
produce entregable, sobra o se salió de alcance.

---

## 🧪 Verificación

- `python3 prompts/verificar-corpus.py` corre el perfil `courses-ia` de `verificador_base.py` (copiado
  de `zz-instrucciones/herramientas/`) con las excepciones de la guía §16: emoji en `###` de marcadores
  y secciones, callouts propios, encabezados sin fecha de vigencia y el aviso `DIAGRAMA`.
- Salida esperada: un único `ERROR FUERA` (el enlace a `../angular-8-legacy-for-backend-devs`, §16) y
  cero avisos.
- `python3 prompts/verificar-forenses.py` revisa las 15 piezas forenses del track base.

---

## 🪦 Lo que cambió al escribir

- **La empresa y su historia** cambiaron de nombre y de origen: hoy es **Plomada Ingeniería de
  Inspección S.A.S.**, con filiales en Lima y Quito, y `certcore-api` lo empezó un independiente de .NET
  que eligió Lumen por costo de licencias y hosting (historia §3, D3).
- **El curso dejó de ser de un solo país**: Bogotá, Lima y Quito van en `-05:00`; Galápagos (UTC−6) es
  la excepción que cobra el incidente 21.
- **Dos incidentes nuevos** en el cuaderno base: el 21 (Galápagos, fase 10) y el 22 (el RUC, fase 6).
  El cuaderno pasó de 20 a 22 incidentes y de 14 a 15 horas; el curso, de 122 a 123 horas.
- **Las excepciones a los lineamientos** se escribieron como decisión en la guía §16; antes eran
  práctica sin declarar.

---

## ⚠️ Lo que más se rompe al editar

- **Cifras repetidas en varios documentos.** Las horas y los conteos de incidentes aparecen en el
  alcance, la propuesta, las plantillas, el formato y el README: cambiar una sin las demás deja el
  curso con dos cifras a la vez. Se buscan con `grep` antes de cerrar.
- **Frases de «un solo país».** Al decir «en Colombia no hay horario de verano» en el track, Galápagos
  queda fuera sin que nadie lo note. Hoy se dice «Colombia, Perú y Ecuador continental».
- **El origen y el nombre anteriores sobreviven en la prosa.** Un origen de sistema interno en PHP, o el
  nombre de la empresa de antes, reaparecen en propuestas y apéndices que no se revisan en
  cada tanda. Un `grep` de esas palabras al cerrar cada tanda lo atrapa.
