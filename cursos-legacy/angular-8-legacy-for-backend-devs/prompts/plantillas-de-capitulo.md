# 🧩 Plantillas de capítulo

## Tutorial Angular 8 — Laboratorio clínico

Este archivo contiene los dos esqueletos que se copian al abrir un chat nuevo:
la **plantilla de fase** (rígida, 9 secciones, idéntica en todo el curso) y la
**plantilla de apéndice** (laxa, porque el contenido de un apéndice es
heterogéneo por naturaleza).

Junto con la guía de estilo y el alcance, forman el marco para que las fases,
escritas cada una en su chat, se lean como un solo documento.

> **Nota de coherencia:** las cifras de referencia son las de
> `propuesta-fases-y-alcance.md` — **108h de fases + 14h de cuaderno de incidentes
> = 122h**, con la última fase opcional y sin horas. Están cerradas y verificadas
> sumando los encabezados; si alguna vez cambian, esta plantilla se actualiza
> primero y las fases después.

---

# 📐 Plantilla de fase

Copiar el bloque completo, rellenar los `{{placeholders}}` y borrar las notas
entre llaves antes de entregar.

```markdown
# {{emoji}} Fase {{NN}} — {{Nombre}}

> Tutorial Angular 8 — Laboratorio clínico · Fase {{N}} de 14 · **{{X}} horas**
> Depende de: {{fase previa}} · Habilita: {{fase siguiente}}
> Apéndices de apoyo: {{A0N, A0M}} · Incidentes asociados: {{NN, NN}}

---

## 🎯 1. Propósito

{{Una o dos frases: qué resuelve esta fase y por qué le importa a alguien que
va a *mantener* este sistema, no a construirlo. Anclar al dominio de
laboratorio clínico.}}

---

## ✅ 2. Qué queda listo al terminar

- [ ] {{resultado verificable 1}}
- [ ] {{resultado verificable 2}}
- [ ] {{...3 a 5 items}}

{{Verificable = se puede comprobar abriendo el navegador, corriendo un comando
o mirando Redux DevTools. "Entender X" no es un resultado verificable.}}

---

## 🚫 3. Qué NO entra todavía

- {{tema diferido}} → Fase {{M}}.
- {{...}}

---

## 🧠 4. Concepto mínimo

{{Solo la teoría que hace falta para escribir el código de esta fase. Prosa,
no bullets. Explicar el porqué de cada decisión, no solo el cómo. Si el
concepto ya vive en un apéndice, enlazarlo en vez de repetirlo.}}

{{Si aplica: nota sobre cómo lo resolvía la época (Angular 8, NgRx sin
`createFeature`, `NgModule` siempre) frente a cómo se haría hoy — una línea,
sin nostalgia y sin sermón.}}

---

## 💻 5. Código mínimo con comentarios

{{El grueso de la fase. Código ejecutable, coherente con las versiones
fijadas del stack. Comentarios que explican el porqué, no el qué.}}

{{Distinguir con claridad qué vive en componente / store (actions, reducer,
effects, selectores) / servicio / mock server.}}

{{Estilo obligatorio del curso:
- `function () {}` en métodos de clase, no arrow.
- Componentes gordos, lógica de negocio dentro; así es LabCore.
- `.subscribe()` a pelo es aceptable; RxJS mínimo.
- `any` tolerado. Se comenta, no se corrige.
- NgModules. Nada de standalone.}}

{{💸 Marcar cada deuda técnica intencional con una nota de dos partes:
qué sería lo correcto hoy, y por qué en Track A **no se paga**.}}

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

{{2-4 errores típicos en formato síntoma → causa → fix mínimo. Distinguir
siempre el fix mínimo de la refactorización correcta: el estudiante va a
hacer hotfixes, no rediseños.}}

### Pieza forense de esta fase

{{Qué se debuggea específicamente aquí. Enlazar a `forense-fase-{{NN}}.md`.}}

{{Incluir al menos un ejercicio de "rompe a propósito y observa": qué tocar,
qué se espera ver en consola / Network / DevTools, y qué mentira te va a
contar la pantalla si no miras el lugar correcto.}}

---

## 🧪 7. Ejercicios ({{total}})

**🟢 Fácil (1–{{a}})**
1. {{...}}

**🟡 Intermedio ({{a+1}}–{{b}})**
{{...}}

**🟠 Difícil ({{b+1}}–{{c}})**
{{...}}

**🔴 Muy difícil ({{c+1}}–{{total}})**
{{...}}

**🔥 Opcionales**
- 🔥 {{...}}

{{Mínimo 25, ideal 30-35. Numeración continua; el título lleva el conteo.
Reparto equilibrado: no cargar todo en 🟢. Accionables, verificables y
anclados al laboratorio. Al menos un tercio de diagnóstico —entregar un bug
y pedir reproducir y localizar— no solo de construcción.}}

---

## 📚 8. Referencias

**Documentación oficial**
- {{URL completa}} — {{nota de versión: v8 vs latest}}

**Libros / artículos de referencia** (si aplican)
- {{...}}

**Video / apoyo**
- {{crash course o charla, URL completa}}

**Orden de lectura sugerido:** {{qué leer antes de escribir código → qué
consultar durante → a qué volver después}}

> ⚠️ {{URLs, títulos y contenidos pueden haber cambiado o desaparecido; el
> lector debe verificarlos. Advertir explícitamente cuando un enlace cubra
> una versión distinta a la del curso.}}

---

## 🚀 9. Cierre y conexión con la siguiente fase

{{Qué quedó construido y por qué la Fase {{siguiente}} es el paso natural:
qué necesita de esta fase para existir.}}

> **La señal de que quedó bien:** {{criterio en forma de cita — cómo se
> siente el trabajo bien hecho de esta fase.}}

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> {{bloque bash: git tag -a fase-{{slug-del-archivo}} -m "F{{N}} cerrada: <el checklist, en una línea por ítem>"}}
>
> Los commits de la fase llevan su prefijo (`f{{NN}}: …`) y los de ejercicio su
> número (`f{{NN}} ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f{{NN}}/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md).
```

---

## Recordatorios al rellenar una fase

- Las horas deben coincidir con la tabla de `propuesta-fases-y-alcance.md` §2. El
  total de fases es **108h**; el cuaderno de incidentes aporta las 14h restantes.
- No contradecir nombres de acciones, selectores, servicios ni componentes
  definidos en fases previas. Ante la duda, revisar el entregable anterior.
- **El bloque 🏷️ del tag es obligatorio y de forma fija** (guía §8.1). El nombre
  del tag es `fase-` + el mismo slug del archivo `.md`, y el prefijo de commit es
  `f` + los dos dígitos de la fase. Va después de La señal de que quedó bien y
  antes del `---` que abre los 📌 Pendientes. No se reexplica la convención en la
  fase: se enlaza.
- Enlazar la pieza forense y los incidentes que caen en esta fase.
- Las versiones salen del stack fijado en el `README.md` y en
  `propuesta-fases-y-alcance.md` §8, que están cerradas. Ninguna se da por buena de
  memoria y ninguna se verifica contra nada externo: el curso es autocontenido.
- Coherencia de la ficción: LabCore es el sistema heredado y es del curso. Si una
  fase afirma que algo está así en LabCore, tiene que poder mostrarlo (guía §11).

---

# 📎 Plantilla de apéndice

Deliberadamente laxa. Un apéndice de Material y uno de Kubernetes no se
parecen en nada; lo único que comparten es el marco: **encabezado, índice,
secciones cortas con ejemplo mínimo, tabla de decisión, referencias,
ejercicios**. Todo lo del medio es libre.

```markdown
# 📎 Apéndice {{A0N}} — {{Nombre}}

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **{{X}} horas**
> Usado por: Fase {{N}}, Fase {{M}} · Versión cubierta: {{lib}} {{x.y.z}}
> {{Si aplica: 🔥 Opcional por plataforma / opcional del curso.}}

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice
buscando algo concreto y se sale. {{Una línea sobre qué problema resuelve.}}

**Qué queda fuera:** {{lo que el apéndice explícitamente no cubre, y dónde
buscarlo — el apéndice no explica la librería entera, solo lo que aparece en
el código real que van a mantener.}}

---

## Índice

- [{{Sección 1}}](#)
- [{{Sección 2}}](#)
- [{{...}}](#)
- [Cuándo usar qué](#)
- [Referencias](#)

---

## {{Sección}}

{{Formato libre según el tema. Lo que sí se mantiene:
- Secciones cortas, cada una respondiendo a una pregunta concreta.
- Ejemplo mínimo ejecutable, no ejemplo completo.
- El estilo de código del curso cuando haya código del proyecto.
- 💸 en cualquier práctica que se muestre por fidelidad a LabCore y no
  por ser correcta.}}

{{Repetir tantas secciones como haga falta.}}

---

## 🧭 Cuándo usar qué

| {{Situación}} | {{Opción}} | {{Por qué}} |
|---|---|---|
| {{...}} | {{...}} | {{...}} |

{{Tabla de decisión al final: es lo que más se consulta. Si el apéndice no
compara opciones, sustituir por una tabla de referencia rápida —operadores,
comandos, clases, atajos— o por un checklist.}}

---

## ⚠️ Advertencias

{{Bloque opcional pero necesario en apéndices de infraestructura: dónde el
libro se separa de la realidad de la empresa, y a quién preguntar antes de
improvisar.}}

---

## 📚 Referencias

- {{URL oficial completa}} — {{nota de versión}}
- {{...}}

> ⚠️ {{Los enlaces pueden estar desactualizados; verificar. Señalar cuándo la
> documentación oficial ya solo cubre versiones posteriores.}}

---

## 🧪 Ejercicios (5-10)

1. {{Cortos, de consulta: buscar algo en la doc, cambiar un valor y observar,
   reproducir un error típico del tema.}}

---

> 🏷️ **Este apéndice no lleva tag propio.** {{Variante normal: es consulta
> rápida, el código que explica lo escriben las fases, y lo que salga de leerlo
> se commitea con el prefijo de la fase desde la que se llegó (`f{{NN}}: …`);
> las mediciones van en el mensaje de un tag anotado `ej/{{aNN}}/3`.}}
> {{Variante excepcional —solo si el apéndice escribe archivos del repo, como
> A13 §6 con el `.devcontainer/`—: el commit se etiqueta
> `apendice-{{aNN}}-{{slug}}`.}} La convención completa está en
> [`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md).
```

---

## Recordatorios al rellenar un apéndice

- Las horas del apéndice **no cuentan** dentro de las 122h del calendario.
- Un apéndice no repite lo que ya explica una fase: enlaza.
- **También cierra con el bloque 🏷️** (guía §8.1), casi siempre en su variante
  negativa: los apéndices no llevan tag propio porque el código que explican lo
  escriben las fases. La excepción es el que deja archivos en el repositorio.
- Los apéndices de plataforma (arm64/M1, Docker+Colima) se marcan como
  opcionales; el curso se completa sin abrirlos.
- Confirmar antes de escribir: versión exacta a cubrir, qué convenciones de
  LabCore ya son conocidas, y qué queda explícitamente fuera.
