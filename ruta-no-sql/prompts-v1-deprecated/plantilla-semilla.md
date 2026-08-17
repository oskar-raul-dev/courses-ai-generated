# 🌱 Plantilla del documento semilla — Ruta NoSQL 2026

> **Qué es.** El *documento semilla* (`NN-<CURSO>-SEMILLA.md`) es el **primer
> entregable** de cada curso: captura la decisión de dominio, stack y estructura
> de fases ANTES de redactar la Fase 0. Es el punto de partida de la redacción,
> no el curso en sí. `PROTEO-SEMILLA.md` es el ejemplar de referencia.
>
> Cada prompt inicial pide, como primer paso, producir la semilla de su curso
> siguiendo esta plantilla. Nada en la semilla es definitivo hasta que se
> redacta la fase correspondiente.

---

## Principio

La semilla existe para **forzar la decisión antes que la escritura**: obliga a
declarar por qué el motor encaja (o no) en el dominio, con qué se va a medir, y
cómo se reparten las fases — todo revisable de un vistazo y barato de corregir.
Es el equivalente, a nivel de curso, de diseñar el esquema antes de escribir
código.

---

## Anatomía obligatoria (secciones, en orden)

Toda semilla reproduce estas secciones. Se adapta el contenido al motor y
dominio; la estructura se mantiene para que las 11 semillas se lean igual.

1. **🎯 Por qué este curso existe.** Dos o tres párrafos: qué problema real
   encarna el dominio, qué enseña este curso que otro no, y —clave— por qué el
   motor es la decisión correcta (o el matiz honesto de cuándo no lo es). Si hay
   un curso hermano o un contraste con otra familia, se nombra aquí.

2. **🏗️ El dominio.** Descripción del proyecto grande + una **tabla** que
   desglosa lo que hace singular al dominio (verticales, entidades, patrones de
   acceso…). Deja explícito qué requisito del producto motiva usar este motor.

3. **⚖️ El marco aplicado ANTES de modelar.** Una **tabla** que corre las
   preguntas de decisión de la ruta sobre este dominio (qué se lee junto, quién
   custodia la forma/consistencia, cuánto se une/coordina en caliente, dónde
   viven las invariantes, qué pide la operación) y cierra con un **veredicto**
   (p. ej. "5-0 documento", "columnar gana la escritura, pierde el CRUD"). Nombra
   el **anti-patrón ⚰️** del curso aquí.

4. **📐 Stack.** **Tabla** Componente · Versión/elección · Rol, con el stack 2026
   del curso, el/los rival(es) del "vs", el lenguaje de interfaz asignado, y
   cualquier decisión de capas (validación, cache, etc.).

5. **⚖️ El método del "vs".** Cómo se monta `scripts/vs.*` desde la Fase 0, qué
   duelos atraviesan el curso, y la regla de oro: ningún "vs" se narra sin medir
   primero; los números viven en `BENCHMARKS.md`.

6. **🌳 Estructura de fases (idea inicial).** **Tabla** con # · Fase · Núcleo ·
   "Vs" de la fase, respetando ≤120 h y los 5 pilares. Marca la fase de
   anti-patrón ⚰️ y la de veredicto ⚖️. Cierra con total estimado de fases y
   ejercicios.

7. **🧩 Decisiones pendientes de confirmar antes de la Fase 0.** Checklist de
   preguntas abiertas (dataset, alcance de un rival, qué se implementa vs se
   documenta, formato de capítulo…). Es lo que se discute antes de escribir.

8. **🔗 Continuidad con la ruta.** Posición del curso en `RUTA-NOSQL-2026.md`,
   qué aporta que ningún otro cubre, y los puentes hacia/desde cursos vecinos.

---

## Reglas de la semilla

- **Es discutible, no definitiva.** Se entrega para pactar, no para ejecutar a
  ciegas. Termina invitando a revisar antes de redactar la Fase 0.
- **Coherente con las fuentes de verdad** (instrucciones del proyecto, guía
  transversal, `RUTA-NOSQL-2026.md`, `LENGUAJES-DE-INTERFAZ.md`).
- **Honesta con el motor.** Si hay fases donde el rival gana, se dicen en la
  tabla de fases; la semilla no vende, mide.
- **Cabe en una lectura.** Tablas antes que prosa larga; es un mapa, no el
  territorio.
- **Nombre del archivo:** `NN-<CURSO>-SEMILLA.md` (p. ej. `01-PORTALON-SEMILLA.md`).
