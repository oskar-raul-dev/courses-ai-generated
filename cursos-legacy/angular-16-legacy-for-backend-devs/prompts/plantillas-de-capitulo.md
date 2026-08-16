# 🧩 Plantillas de capítulo
## Tutorial Angular 16 — Inspecciones y certificaciones

Este archivo contiene los dos esqueletos que se copian al abrir un chat nuevo: la
**plantilla de fase** (rígida, 9 secciones, idéntica en todo el curso) y la
**plantilla de apéndice** (laxa, porque el contenido de un apéndice es
heterogéneo por naturaleza).

Junto con la guía de estilo y el alcance, forman el marco para que las fases,
escritas cada una en su chat, se lean como un solo documento.

> **Nota de coherencia:** las cifras de referencia son las de
> `propuesta-fases-y-alcance.md` §2 — **108h de fases + 14h de cuaderno de
> incidentes = 122h**, con la Fase 14 opcional y sin horas. Si alguna vez cambian,
> esta plantilla se actualiza primero y las fases después.

---

# 📐 Plantilla de fase

Copiar el bloque completo, rellenar los `{{placeholders}}` y borrar las notas
entre llaves antes de entregar.

````markdown
# {{emoji}} Fase {{NN}} — {{Nombre}}

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase {{N}} de 14 · **{{X}} horas**
> Depende de: {{fase previa}} · Habilita: {{fase siguiente}}
> Apéndices de apoyo: {{A0N, A0M}} · Incidentes asociados: {{NN, NN}}
> Estilo de esta fase: {{heredado (NgModule + constructor) | nuevo (standalone + inject()) | mixto 🧬}}

---

## 🎯 1. Propósito

{{Una o dos frases: qué resuelve esta fase y por qué le importa a alguien que va
a *mantener* este sistema, no a construirlo. Anclar al dominio de inspecciones y
certificaciones.}}

---

## ✅ 2. Qué queda listo al terminar

- [ ] {{resultado verificable 1}}
- [ ] {{resultado verificable 2}}
- [ ] {{...3 a 5 ítems}}

{{Verificable = se puede comprobar abriendo el navegador, corriendo un comando o
mirando el Network tab. "Entender X" no es un resultado verificable.}}

---

## 🚫 3. Qué NO entra todavía

- {{tema diferido}} → Fase {{M}}.
- {{...}}

---

## 🧠 4. Concepto mínimo

{{Sólo la teoría que hace falta para escribir el código de esta fase. Prosa, no
bullets. El problema antes que la herramienta. Si el concepto ya vive en un
apéndice, enlazarlo en vez de repetirlo.}}

{{Si la fase toca por primera vez una API que tiene dos formas vivas, va aquí la
micro-sección **¿Nuevo o heredado?** 🧬: el mismo fragmento en los dos estilos,
cuál usarías en cada situación, y la regla del proyecto — código nuevo estilo
nuevo, código heredado se toca lo mínimo y en su propio estilo.}}

> 📝 **Nota de migración.** {{Qué versión trajo esta API, qué reemplazó, y por
> qué lo anterior sigue vivo en el repositorio. Situada en la cronología fija:
> CertCore nació en 2021 sobre Angular 12 y se migró a 16 durante 2024.}}

---

## 💻 5. Código mínimo con comentarios

{{El grueso de la fase. Código ejecutable, coherente con las versiones fijadas.
Identificadores en inglés, comentarios en español con tildes, textos de interfaz
literales en español.}}

{{Distinguir con claridad qué vive en componente / servicio de estado
(`*StateService`) / servicio de API (`*ApiService`) / guard / interceptor / mock
server.}}

{{Estilo obligatorio del curso — §6 de la guía:
- `strict: true` siempre. Cero `any`; `unknown` y estrechamiento donde el tipo no
  se conoce. Nulabilidad explícita en modelos y en `FormControl`.
- Código nuevo: standalone, `inject()`, `OnPush`, guards e interceptors
  funcionales, `takeUntilDestroyed`, arrow functions.
- Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. Se toca lo mínimo y no se moderniza al pasar.
- Nunca los dos estilos dentro del mismo archivo. Los puntos de contacto entre
  ellos van marcados con 🧬.
- RxJS moderado: `async` pipe para pintar, `.subscribe()` para efectos — y
  entonces alguien se desuscribe.
- Fechas con offset explícito, nunca `new Date()` suelto donde importe el día.}}

{{💸 Marcar cada deuda técnica intencional con una nota de dos partes: qué sería
lo correcto, y **en qué fase se paga**. Si no se paga, decirlo y explicar por qué.
Un 💸 sin destino es un error de escritura.}}

**Detalles con intención**
- {{decisión deliberada del bloque anterior}} — {{su porqué}}.

**El patrón a memorizar**
> {{Una o dos frases con la lección transferible del fragmento.}}

**Prueba de fuego**
{{Verificación manual concreta: qué hacer, qué esperar, qué mentira te va a
contar la pantalla si miras el lugar equivocado.}}

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

{{2-4 errores típicos en formato síntoma → causa → fix mínimo. Distinguir siempre
el fix mínimo de la refactorización correcta, y recordar que el fix mínimo se
escribe **en el estilo del archivo que tocas**.}}

### Pieza forense de esta fase

{{Qué se depura específicamente aquí. Enlazar a `forense-fase-{{NN}}.md`.}}

{{Incluir al menos un ejercicio de 🧨 "rompe a propósito y observa": qué tocar,
qué se espera ver en consola / Network / DevTools, y en qué se diferencia ese
error del que produciría el otro estilo.}}

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

{{Mínimo 25, ideal 30-35. Numeración continua; el título lleva el conteo. Reparto
equilibrado. Accionables, verificables y anclados al dominio. Al menos un tercio
de diagnóstico. Desde la Fase 5, al menos dos de estilo 🧬: dado un archivo,
decidir si el fix va en estilo nuevo o heredado y justificarlo.}}

---

## 📚 8. Referencias

**Documentación oficial**
- {{URL completa}} — {{nota de versión: v16.angular.io, y advertencia si el
  enlace lleva a angular.dev}}

**Libros / artículos de referencia** (si aplican)
- {{...}}

**Video / apoyo**
- {{crash course o charla, URL completa}}

**Orden de lectura sugerido:** {{qué leer antes de escribir código → qué
consultar durante → a qué volver después}}

> ⚠️ {{URLs, títulos y contenidos pueden haber cambiado o desaparecido; el lector
> debe verificarlos. Advertir explícitamente cuando un enlace cubra una versión
> distinta a la del curso — con Angular pasa casi siempre.}}

---

## 🚀 9. Cierre y conexión con la siguiente fase

{{Qué quedó construido y por qué la Fase {{siguiente}} es el paso natural: qué
necesita de esta fase para existir.}}

> **La señal de que quedó bien:** {{criterio en forma de cita — cómo se siente el
> trabajo bien hecho de esta fase.}}

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-{{NN}} -m "F{{N}} cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase {{NN}}: …`) y los de ejercicio
> su número (`fase {{NN}} ej17: …`). Si un ejercicio merece su propio marcador va
> en `ej/f{{NN}}/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md).
>
> {{Si la fase tiene algo propio que decir sobre git —paga una deuda 💸 declarada
> antes y el diff entre dos tags es la factura, produce un incidente cuya rama
> sale de este tag, estrena la imagen— va un párrafo corto acá, no un bloque
> nuevo.}}

---

## 📌 Pendientes sugeridos

{{Material de autoría, no de lectura. Lo que apareció al escribir la fase y no
cabía adentro, con destino explícito: otra fase, un apéndice, un ejercicio 🔥 o
una decisión de proyecto.}}

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| {{NN}} | {{en palabras del usuario}} | {{categoría}} | {{🟢🟡🟠🔴}} |
````

---

## Recordatorios al rellenar una fase

- Las horas deben coincidir con la tabla de `propuesta-fases-y-alcance.md` §2. El
  total de fases es **108h**; el cuaderno aporta las 14h restantes.
- **Declara el estilo de la fase en el encabezado.** Es la primera cosa que el
  lector necesita saber en este track, y la que evita que copie un patrón de la
  Fase 2 dentro de un componente de la Fase 8.
- No contradecir nombres de servicios, componentes ni modelos definidos en fases
  previas. Ante la duda, revisar el entregable anterior.
- Enlazar la pieza forense y los incidentes que caen en esta fase.
- **Cerrar con la etiqueta de git.** Toda fase termina con el bloque 🏷️ de forma
  fija (guía §8.1), que pide `git tag -a fase-NN` sobre el commit que la cierra y
  enlaza `00-convencion-de-git-y-tags.md` **sin reexplicarla**. La convención se
  fija en la Fase 0 y se recuerda en el cierre de cada fase: es lo que permite
  volver a un punto del curso, comparar dos fases con
  `git diff fase-03 fase-04 --stat`, y que un ejercicio pueda decir "recupera el
  estado de la fase anterior" sin ambigüedad. El nombre del tag es el número
  (`fase-07`), no el slug, y las ramas de trabajo llevan prefijo (`wip/`,
  `spike/`, `incidente/`) para no chocar con él.
- Las versiones salen del stack fijado en `alcance-del-proyecto.md` §9, que está
  cerrado. Ninguna se da por buena de memoria y ninguna se verifica contra nada
  externo: el curso es autocontenido.
- Coherencia de la ficción: CertCore es del curso. Si una fase afirma que algo
  está así en CertCore, tiene que poder mostrarlo (guía §11).
- El invariante central se respeta en cada fragmento que toque plantillas: **una
  inspección se lee siempre con la versión de plantilla con la que se ejecutó.**

---

# 📎 Plantilla de apéndice

Deliberadamente laxa. Un apéndice de Material y uno de Kubernetes no se parecen
en nada; lo único que comparten es el marco: **encabezado, índice, secciones
cortas con ejemplo mínimo, tabla de decisión, referencias, ejercicios**. Todo lo
del medio es libre.

````markdown
# 📎 Apéndice {{A0N}} — {{Nombre}}

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **{{X}} horas**
> Usado por: Fase {{N}}, Fase {{M}} · Versión cubierta: {{lib}} {{x.y.z}}
> {{Si aplica: 🔥 Opcional — el curso se completa sin abrir este apéndice.}}

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice
buscando algo concreto y se sale. {{Una línea sobre qué problema resuelve.}}

**Qué queda fuera:** {{lo que el apéndice explícitamente no cubre, y dónde
buscarlo — el apéndice no explica la librería entera, sólo lo que aparece en el
código real que van a mantener.}}

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
- El estilo de código del curso cuando haya código del proyecto: inglés,
  comentarios en español, `strict` respetado, y el estilo (nuevo o heredado) que
  corresponda a la fase que lo usa.
- 💸 en cualquier práctica que se muestre por fidelidad a CertCore y no por ser
  correcta, con su fase de cobro.
- 🧬 donde el apéndice compare la forma nueva y la heredada de la misma API — en
  A04, A05 y A10 eso es prácticamente todo el contenido.}}

{{Repetir tantas secciones como haga falta.}}

---

## 🧭 Cuándo usar qué

| {{Situación}} | {{Opción}} | {{Por qué}} |
|---|---|---|
| {{...}} | {{...}} | {{...}} |

{{Tabla de decisión al final: es lo que más se consulta. Si el apéndice no
compara opciones, sustituir por una tabla de referencia rápida —operadores,
comandos, clases, atajos— o por un checklist. En los apéndices de
infraestructura, marcar cada comando con 👁️ (solo lee) o ✍️ (modifica).}}

---

## ⚠️ Advertencias

{{Bloque opcional pero **obligatorio en A09**: dónde el libro se separa de la
realidad de la empresa, y a quién preguntar antes de improvisar.}}

---

## 📚 Referencias

- {{URL oficial completa}} — {{nota de versión}}
- {{...}}

> ⚠️ {{Los enlaces pueden estar desactualizados; verificar. Señalar cuándo la
> documentación oficial ya sólo cubre versiones posteriores — para Angular es la
> norma, no la excepción.}}

---

## 🧪 Ejercicios (5-10)

1. {{Cortos, de consulta: buscar algo en la doc, cambiar un valor y observar,
   reproducir un error típico del tema.}}

---

> 🏷️ **Este apéndice no lleva tag propio.** {{Variante normal: es consulta
> rápida, el código que explica lo escriben las fases, y lo que salga de leerlo
> se commitea con el prefijo de la fase desde la que se llegó (`fase {{NN}}: …`);
> las mediciones van en el mensaje de un tag anotado `ej/{{aNN}}/3`.}}
> {{Variante excepcional, sólo si el apéndice deja archivos versionados: el
> commit se etiqueta `apendice-{{aNN}}`.}} La convención completa está en
> [`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md).
````

---

## Recordatorios al rellenar un apéndice

- Las horas del apéndice **no cuentan** dentro de las 122h del calendario.
- Un apéndice no repite lo que ya explica una fase: enlaza.
- **También cierra con el bloque 🏷️** (guía §8.1), casi siempre en su variante
  negativa: los apéndices no llevan tag propio porque el código que explican lo
  escriben las fases. Sólo se etiqueta el que deje archivos versionados.
- Los apéndices opcionales (A02, A11, A12, A13) llevan 🔥 en el encabezado y una
  línea diciendo que el curso se completa sin abrirlos.
- **A10 (puente 8/9 → 16) tiene un lector distinto**: alguien que viene del Track A
  y trae los reflejos de LabCore puestos. Se escribe hablándole a esa persona, y
  es el único documento del **cuerpo** del curso donde nombrar LabCore
  es correcto — el otro sitio es la sección «Su curso hermano» del `README.md`.
  La regla completa está en §12.1 de la guía de estilo.
- Confirmar antes de escribir: versión exacta a cubrir, qué convenciones de
  CertCore ya son conocidas, y qué queda explícitamente fuera.
