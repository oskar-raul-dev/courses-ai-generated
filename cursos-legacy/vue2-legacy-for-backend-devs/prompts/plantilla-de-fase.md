# 🧩 Plantilla de fase (esqueleto)
## Paquete Mini Jira — Curso 01 (Vue 2 legacy) + Curso 02 (MongoDB/Express)

Copia este esqueleto al iniciar cada fase y rellena los `{{placeholders}}`.
Mantiene la estructura de nueve secciones idéntica en los dos cursos. Borra las
notas entre llaves antes de entregar.

> 📐 **Sobre el encabezado de sección.** El emoji va **primero**, siempre. La
> numeración explícita (`## 🎯 1. Propósito`) es **opcional** y solo se usa en
> fases que numeran sus subsecciones y las citan con `§N` — hoy, las cuatro
> fases largas de ruta (`q1`, `q3`, `vu1`, `vu3`). El resto del paquete usa la
> forma sin número, que es la mayoritaria y la que muestra esta plantilla.

> 🔄 **Recordatorio de convención (ver
> `prompts/guia-de-estilo-y-convenciones.md` §5 y
> `02-complement-mongodb-backend/prompts/diccionario-codigo.md`):** todo
> identificador de código —variables, funciones, componentes, módulos Vuex,
> actions, mutations, endpoints, colecciones, campos, constantes, enums— va en
> **inglés**. Los comentarios de código, los textos de interfaz (labels,
> botones, mensajes de alerta) y toda la narrativa van en **español
> latinoamericano con tuteo**. Nada de voseo (§4.6 de la guía).

---

```markdown
# {{emoji}} Fase {{NN}} — {{Nombre}}

> {{Curso 01 — Vue 2 Legacy · Mini Jira | Curso 02 — MongoDB para cerebros SQL}}
> Fase {{N}} de {{total}}
> Depende de: {{fase previa}} · Habilita: {{fase siguiente}}

---

## 🎯 Propósito

{{Una o dos frases: qué resuelve esta fase y por qué importa para el
mantenimiento. Anclar al dominio de Mini Jira. Puede abrir con la situación
heredada de la fase anterior: "el dashboard ya lista tickets, pero cada
recarga vuelve a pedir todo…".}}

---

## ✅ Qué queda listo al terminar

- [ ] {{resultado verificable 1}}
- [ ] {{resultado verificable 2}}
- [ ] {{...3 a 5 ítems, verificables, no promesas}}

---

## 🚫 Qué NO entra todavía

- {{tema diferido}} → Fase {{M}}.
- {{...}}

---

## 🧠 Concepto mínimo

{{Solo lo necesario para esta fase, anclado al dominio. Prosa, no viñetas.
El problema antes que la herramienta (regla del andamio, §4.1 de la guía).
Explicar el porqué de cada decisión. Si un concepto ya vive en un apéndice,
enlazarlo en vez de repetirlo.}}

{{Aquí caben el **Mini-repaso** y las 📝 **Notas de época**.}}

{{En el Curso 02, aquí suelen vivir la 📖 tabla de traducción SQL ↔ Mongo y
los recuadros 🪞 "tu instinto SQL dice… y esta vez se equivoca" y 🩻 "esto sí
funciona igual".}}

---

## 💻 Código mínimo con comentarios

{{El grueso de la fase. Código mínimo, ejecutable, coherente con las versiones
fijadas del stack de su curso. Comentarios en español que explican el porqué,
no el qué.}}

{{Identificadores en inglés: componentes, archivos, módulos Vuex, actions,
mutations, getters, servicios, rutas de Express, controllers, colecciones,
campos e índices. Consultar el diccionario de código para el término correcto
del dominio (`ticket`, `comment`, `assignee`, `reporter`, `open`,
`in_progress`). Los textos que ve el usuario van en español literal — la app
no tiene i18n.}}

{{Distinguir con claridad qué vive en el componente, en el store, en el
servicio HTTP o —en el Curso 02— en la ruta, el controller, el service o el
propio Mongo.}}

{{Marcar 💸 cualquier deuda técnica intencional con nota de qué sería lo
correcto y en qué fase se paga. Si esta fase paga una deuda anterior, abrir un
bloque **💸 Pago de deuda** que nombre de dónde venía.}}

{{Aquí caben **Detalles con intención**, **El patrón a memorizar** y la
**Prueba de fuego**.}}

---

## ⚠️ Errores comunes y pieza forense

### Errores comunes

{{2-4 errores típicos: síntoma → causa → fix mínimo. Distinguir la corrección
mínima (lo que va en un hotfix) de la refactorización (lo que iría con calma y
pruebas).}}

### Pieza forense de esta fase

{{El RESUMEN que se lee de corrido: qué se rompe en esta fase, con qué se
depura —consola, Network, Vue DevTools, o en el Curso 02 logs, profiler y
`explain()`— y cuál es la señal que lo delata. El recorrido paso a paso NO va
acá: va en su archivo (guía §9.2).}}

**🧨 Rompe a propósito**

{{Una rotura concreta que el estudiante ejecuta y observa. Qué tocar, qué
esperar, y —si hace falta— cómo deshacerlo. Es lo que convierte la teoría de
esta sección en un reflejo.}}

> 📄 El recorrido completo, con las salidas literales, en
> `forense-fase-{{NN}}.md`.

{{Si un párrafo cabe igual de bien en la fase y en la pieza, va en la fase y la
pieza lo enlaza. La especificación está en
`prompts/formato-piezas-forenses.md`.}}

---

## 🧪 Ejercicios ({{total}})

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

{{Mínimo 25, ideal 30-35. Reparto equilibrado entre niveles (no cargar todo
en fácil). Numeración continua; el título lleva el conteo total. Accionables y
verificables, anclados al dominio de Mini Jira — tickets, comentarios,
agentes, reportadores, estados, prioridades; nunca `foo` y `bar`. Al menos un
tercio de diagnóstico: entregar un bug y pedir reproducir y localizar, no solo
construir. Cuando un enunciado nombra código, usar el identificador en inglés
vigente y el enunciado en tuteo (ej. "agrega la action `createTicket`").}}

---

## 📚 Referencias

**Documentación oficial**
- {{URL completa}} — {{nota de versión, y advertencia si el enlace cubre otra}}

**Libros** (si aplican)
- {{...}}

**Video / apoyo**
- {{crash course o tutorial, URL completa}}

**Orden de lectura sugerido:** {{qué leer primero → después → volver al código}}

> ⚠️ {{Aclarar que URLs, títulos y contenidos pueden estar desactualizados y
> que conviene verificarlos. Advertir cuando un enlace cubra otra versión —
> con Vue 2, Quasar 1, Vuetify 2, Nuxt 2 y Mongo 4.4 pasa casi siempre,
> porque los dominios raíz sirven las versiones nuevas.}}

---

## 🚀 Cierre y conexión con la siguiente fase

{{Resumen de lo logrado y puente a la Fase {{siguiente}}: qué se construye
allí y por qué es el paso natural.}}

> **La señal de que quedó bien:** {{criterio en forma de cita — cómo se
> siente el trabajo bien hecho de esta fase.}}

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de arriba en verde y
> `git status` limpio:
>
> {{bloque de código bash con: git tag -a fase-{{slug-del-archivo}} -m "{{FN}} cerrada: <el checklist, en una línea por ítem>"}}
>
> Los commits de la fase llevan su prefijo (`{{pfx}}: …`) y los de ejercicio su
> número (`{{pfx}} ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/{{pfx}}/17`, y un incidente resuelto en el par `inc/{{pfx}}/<slug>-roto` /
> `-fix`. Todo eso está en
> [`../prompts/convencion-de-git-y-tags.md`](../prompts/convencion-de-git-y-tags.md).

**Siguiente parada:** {{emoji}} Fase {{N+1}} — {{una o dos líneas de puente}}

---

### 📌 Reservas para el cuaderno de incidentes

{{Los IDs que esta fase reserva para el `cuaderno-incidentes.md` de su curso.
Título en palabras del usuario, no en lenguaje técnico. Si la fase no reserva
ninguno, se escribe "Esta fase no reserva incidentes" y se dice por qué.}}

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| {{NN}} | {{"tomé el ticket y a mi compañero le sigue apareciendo libre"}} | {{categoría}} | {{🟡}} |
```

> 📐 **Sobre el bloque de reservas y "Siguiente parada".** El bloque 📌 va
> físicamente al final, después de "Siguiente parada", y eso no contradice
> §9.1 de la guía: aquel dice que "Siguiente parada" es lo último **de la
> fase**, y el 📌 no es narrativa de la fase — es un bloque de servicio,
> dirigido a quien escribe el cuaderno y a quien audita que los IDs cuadren.
> Los IDs son correlativos **por curso** y no se reasignan nunca, ni siquiera
> cuando un incidente se retira. La especificación está en
> `prompts/formato-cuaderno-incidentes.md`.

---

## Recordatorios al rellenar

- **No contradigas nombres de fases previas ni del otro curso.** Componentes,
  módulos Vuex, actions, servicios, endpoints, colecciones y campos se
  mantienen idénticos a ambos lados del contrato.
- **El contrato manda.** Si la fase toca la forma de una respuesta, un enum o
  un evento de socket, se verifica contra
  `02-complement-mongodb-backend/00-audit-contrato.md` antes de escribir
  código.
- **Todo identificador de código en inglés; comentarios, textos de UI y
  narrativa en español** (guía §5).
- **Tuteo latinoamericano, cero voseo.** Antes de cerrar el archivo, pasa el
  `grep` de la tabla de sustitución (guía §4.7).
- **Options API siempre** en el Curso 01, también en las rutas.
  `function () {}` en métodos de componente. En el Curso 02, driver nativo
  antes de Mongoose.
- **Cierra los bucles.** Toda deuda 💸 declarada aquí necesita una fase donde
  se paga, aunque sea del otro curso.
- **Cita solo archivos que existan** con su nombre vigente (guía §13.2): las
  fases del Curso 01 son `00`–`11`, sus apéndices `a1`–`a5`, sus rutas
  `q0`–`q4` / `vu0`–`vu4` / `nx0`–`nx4`; las fases del Curso 02 son `00`–`15`
  y sus apéndices `a01`–`a05`.
- **El bloque 🏷️ del tag es obligatorio y de forma fija** (guía §9.1). El
  nombre del tag es `fase-` + el mismo slug del archivo `.md`; el prefijo de
  commit es `f` + dos dígitos en las fases numeradas (`f04`) y el código de
  ruta en las de ruta (`q2`, `vu3`, `nx0`). Va después de "La señal de que
  quedó bien" y antes de "Siguiente parada". No reexpliques la convención en la
  fase: enlázala.
- **La sección 6 se reparte** (guía §9.2): el resumen y el 🧨 en la fase, el
  recorrido en `forense-fase-NN.md`. La línea 📄 que las une es de forma fija y
  tiene que apuntar a un archivo que exista. En las fases de ruta apunta a la
  pieza de **su** ruta (`forense-ruta-q.md`, `-vu.md`, `-nx.md`), que es una
  por ruta y no una por fase.
- **Los apéndices no usan esta plantilla:** índice de salto rápido, secciones
  cortas, guía final de "cuándo usar qué" y 5–10 ejercicios cortos. Tampoco
  llevan pieza forense, ni bloque 📌 de reservas, ni bloque 🏷️ de tag.
