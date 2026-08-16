# 📍 Prompts extendidos por fase

Cada sección es el prompt completo de la fase, listo para copiar al chat. Los placeholders están rellenados con los valores reales de la tabla de `prompts-de-redaccion.md`.

---

## # Fase 00

```markdown
Este es el chat de la **Fase 00 — 🛠️ Setup + hola mundo** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `00-setup-hola-mundo.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 00 de 14 — 🛠️ Setup + hola mundo
- Horas: **8h**
- Depende de: ninguna
- Habilita: Fase 1
- Apéndices de apoyo: A02, A03, A12, A13
- Incidentes asociados: 01, 02
- Estado: Obligatoria

## Alcance

- **Propósito (una línea):** Dejar el entorno del equipo levantado y un primer componente que hable con un endpoint, sufriendo de paso el primer choque de cascada.
- **Qué entra:** nvm-windows, Angular CLI 8, proyecto base, Bootstrap 4 y Material conviviendo, componente único con formulario, POST a endpoint hardcodeado.
- **Qué NO entra todavía:** routing, store, servicios reales, i18n → Fases 1, 2 y 4.
- **Conceptos clave a introducir:** CLI, estructura de un proyecto Angular, cascada CSS entre dos frameworks.
- **Deuda técnica intencional 💸:** Dos sistemas de estilos conviviendo sin capa de aislamiento.
  (La forma correcta es una capa de aislamiento CSS o BEM; en Track A no se paga porque lo que importa es saber que existe el problema.)
- **Pieza forense de esta fase:** consola y Network tab como fuente de verdad.
  (enlazar a `forense-fase-00.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **Versión exacta de Bootstrap 4.x:** ¿4.6.0, 4.6.1? ¿Se compila desde Sass o se consume el CSS ya construido?
- Nada más bloqueante para la Fase 00.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 8h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 01

```markdown
Este es el chat de la **Fase 01 — 🏗️ Estructura base + NgRx** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `01-estructura-base-ngrx.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 01 de 14 — 🏗️ Estructura base + NgRx
- Horas: **12h**
- Depende de: Fase 0
- Habilita: Fases 2-13
- Apéndices de apoyo: A06, A05
- Incidentes asociados: 03
- Estado: Obligatoria ⭐

## Alcance

- **Propósito (una línea):** Montar el esqueleto que sostiene el curso entero: módulos, router y el store donde vivirá todo el estado.
- **Qué entra:** módulos por dominio, layout, router con vistas placeholder, NgRx (store, actions, reducers, effects, selectores), Redux DevTools, dónde vive la config por ambiente.
- **Qué NO entra todavía:** auth, API real, CRUD, i18n → Fases 2, 3, 4 y 5.
- **Conceptos clave a introducir:** NgModules, router, flujo unidireccional, store/action/reducer/effect/selector.
- **Deuda técnica intencional 💸:** Store al estilo 2019: reducers en `switch`, sin `createFeature`.
  (Lo correcto es `createFeature` y `createActionGroup`; en Track A no se paga porque estos helpers no existían en la época y el patrón `switch` es lo que encontrará en producción.)
- **Pieza forense de esta fase:** Redux DevTools como máquina del tiempo.
  (enlazar a `forense-fase-01.md` cuando exista)
- **Ejercicios:** 35 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **Versión exacta de NgRx:** ¿8.6.0? ¿Hay `@ngrx/entity` en uso o solo store y effects?
- Nada más bloqueante para la Fase 01.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 12h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 02

```markdown
Este es el chat de la **Fase 02 — 🌐 Internacionalización** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `02-i18n.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 02 de 14 — 🌐 Internacionalización
- Horas: **6h**
- Depende de: Fase 1
- Habilita: Fases 5-9
- Apéndices de apoyo: A07
- Incidentes asociados: 04
- Estado: Obligatoria

## Alcance

- **Propósito (una línea):** Montar las tres llaves de idioma antes de que existan pantallas, para no reescribir cuarenta plantillas después.
- **Qué entra:** árbol de traducciones, selector de idioma, pluralización, formatos de fecha y número por locale.
- **Qué NO entra todavía:** traducción real de todo el contenido, bundle por idioma en el build → Fase 13.
- **Conceptos clave a introducir:** Árbol de traducciones, locale, pluralización, `LOCALE_ID`.
- **Deuda técnica intencional 💸:** Claves planas sin namespacing estricto.
  (Lo correcto es un esquema jerárquico con namespaces claros; en Track A no se paga porque aquí enseñamos el patrón de producción que es el que encontrarás.)
- **Pieza forense de esta fase:** Clave faltante en pantalla y locale equivocado en consola.
  (enlazar a `forense-fase-02.md` cuando exista)
- **Ejercicios:** 25 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **i18n runtime o compile-time.** Bloquea la fase entera.
  Pregunta: ¿LabCore inyecta el idioma al arrancar (runtime) o cada idioma es un build separado (compile-time)? La respuesta cambia cómo se escriben todos los ejemplos.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 7h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 03

```markdown
Este es el chat de la **Fase 03 — 🔐 Autenticación mínima** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `03-autenticacion.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 03 de 14 — 🔐 Autenticación mínima
- Horas: **8h**
- Depende de: Fase 1
- Habilita: Fases 5-11
- Apéndices de apoyo: A05
- Incidentes asociados: 05
- Estado: Obligatoria

## Alcance

- **Propósito (una línea):** Simular el login y el interceptor sin backend, que es como lo vive LabCore en desarrollo.
- **Qué entra:** login mock, JWT en storage, guard, interceptor de token, logout, expiración.
- **Qué NO entra todavía:** backend real, refresh token, roles y permisos finos → fuera de alcance.
- **Conceptos clave a introducir:** Guard, interceptor, storage del token, expiración.
- **Deuda técnica intencional 💸:** Token en `localStorage` y sin refresh.
  (Lo correcto es sessionStorage o una cookie httpOnly con refresh token; en Track A no se paga porque LabCore usa localStorage y tiene sus problemas, que se ven en los incidentes.)
- **Pieza forense de esta fase:** Request-id y breakpoints condicionales en el interceptor.
  (enlazar a `forense-fase-03.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **Cómo genera y expira el token el mock:** ¿JWT firmado de mentira o cadena opaca? Esto define si usamos `jwt_decode` o solo textos.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 8h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 04

```markdown
Este es el chat de la **Fase 04 — 🧪 Mock API + caos** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `04-mock-api-caos.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 04 de 14 — 🧪 Mock API + caos
- Horas: **6h**
- Depende de: Fases 1 y 3
- Habilita: Fases 5-10
- Apéndices de apoyo: A03, A05
- Incidentes asociados: 06, 07
- Estado: Obligatoria ⭐

## Alcance

- **Propósito (una línea):** Construir el mock server y el inyector de caos, porque escribirlo enseña más que recibirlo hecho.
- **Qué entra:** json-server, `db.json` con el modelo del laboratorio, middleware de caos propio (latencia, 500, malformadas, CORS, token expirado, timeouts), effects que lo consumen.
- **Qué NO entra todavía:** backend propio, paginación server-side → fuera de alcance.
- **Conceptos clave a introducir:** Mock server, inyección de fallos, manejo de error en effects.
- **Deuda técnica intencional 💸:** Caos configurado por header global, sin panel.
  (Lo correcto es un panel de control o variable de entorno; en Track A no se paga porque primero hay que entender el efecto antes de agregar UI.)
- **Pieza forense de esta fase:** Qué acción se despacha cuando el backend devuelve 500.
  (enlazar a `forense-fase-04.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- Ninguno duro; confirmar versión de json-server 0.16.x si es distinta.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 6h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 05

```markdown
Este es el chat de la **Fase 05 — 🏥 Pacientes** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `05-pacientes.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 05 de 14 — 🏥 Pacientes
- Horas: **6h**
- Depende de: Fases 1 y 4
- Habilita: Fase 6 — Órdenes
- Apéndices de apoyo: A01, A02, A06
- Incidentes asociados: 09, 10
- Estado: Obligatoria

## Alcance

- **Propósito (una línea):** Primer CRUD completo pasando por el store, con el formulario denso de verdad y el molde de slice que copian las cinco fases siguientes.
- **Qué entra:** tabla Material con filtro y paginador escritos a mano, alta/edición/baja lógica de pacientes, formulario reactivo con validador asíncrono, feature state con su slice y su diálogo de confirmación.
- **Qué NO entra todavía:** las órdenes médicas → Fase 6; validación cruzada avanzada → Fase 8; permisos por rol → fuera de alcance.
- **Conceptos clave a introducir:** Formularios reactivos, tabla Material, feature state.
- **Deuda técnica intencional 💸:** Componente gordo con la lógica de negocio adentro.
  (Lo correcto es servicios especializados; en Track A no se paga porque es exactamente lo que encontrarás en la base de código.)
- **Pieza forense de esta fase:** Reproducir un bug de usuario desde un ticket vago.
  (enlazar a `forense-fase-05.md` cuando exista)
- **Ejercicios:** 31 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **Nombres de acciones y selectores heredados de la Fase 1.** Confirmar que los que usaré no chocan con lo que ya existe en el store.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 6h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 06

```markdown
Este es el chat de la **Fase 06 — 📋 Órdenes** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `06-ordenes.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 06 de 14 — 📋 Órdenes
- Horas: **4h**
- Depende de: Fase 5
- Habilita: Fases 7-11
- Apéndices de apoyo: A01, A02, A06, A07
- Incidentes asociados: —
- Estado: Obligatoria

## Alcance

- **Propósito (una línea):** Repetir el molde de la fase anterior sobre otra entidad, para descubrir qué se copia y qué no, y dejar el slice `orders` del que cuelgan muestras, resultados, entrega y dashboard.
- **Qué entra:** slice `orders` completo calcado del molde, `FormArray` de `testCodes`, el cruce orden → paciente resuelto en el componente, y el `MatSelect` de estado sin máquina de estados detrás.
- **Qué NO entra todavía:** las guardas de transición → Fase 7; el selector cruzado entre slices → Fase 10; permisos por rol → fuera de alcance.
- **Conceptos clave a introducir:** `FormArray`, lectura rápida de un slice ajeno, cruce entre slices en el componente.
- **Deuda técnica intencional 💸:** Un `MatSelect` que ofrece las seis transiciones de estado sin guarda ninguna.
  (Lo correcto es una máquina de estados; en Track A no se paga acá porque la Fase 7 la construye y el contraste es el material.)
- **Pieza forense de esta fase:** El estado que no existe hasta que alguien navega a su ruta.
  (enlazar a `forense-fase-06.md` cuando exista)
- **Ejercicios:** 25 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **Nada bloqueante.** El molde entero llega escrito desde la Fase 5; lo único que se decide acá es qué *no* se copia.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 4h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 07

```markdown
Este es el chat de la **Fase 07 — 🧫 Muestras y cadena de custodia** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `07-muestras-custodia.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 07 de 14 — 🧫 Muestras y cadena de custodia
- Horas: **8h**
- Depende de: Fase 5
- Habilita: Fases 8 y 10
- Apéndices de apoyo: A01, A06
- Incidentes asociados: 10, 11
- Estado: Obligatoria

## Alcance

- **Propósito (una línea):** Enseñar la máquina de estados con transiciones estrictas y su rastro.
- **Qué entra:** estados de muestra, transiciones válidas e inválidas, timeline de custodia, guardas de transición en el reducer.
- **Qué NO entra todavía:** trazabilidad transversal completa → Fase 11.
- **Conceptos clave a introducir:** Máquina de estados, invariantes de transición.
- **Deuda técnica intencional 💸:** Validación de transición duplicada en componente y reducer.
  (Lo correcto es single source of truth; en Track A no se paga porque el código real tiene esta redundancia y hay que saber detectarla.)
- **Pieza forense de esta fase:** Transición ilegal rastreada en logs.
  (enlazar a `forense-fase-07.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- Ninguno bloqueante.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 8h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 08

```markdown
Este es el chat de la **Fase 08 — 🧬 Resultados y rangos versionados** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `08-resultados-rangos.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 08 de 14 — 🧬 Resultados y rangos versionados
- Horas: **10h**
- Depende de: Fase 7
- Habilita: Fases 9 y 10
- Apéndices de apoyo: A01, A06
- Incidentes asociados: 12, 13
- Estado: Obligatoria ⭐

## Alcance

- **Propósito (una línea):** El corazón normativo: rangos versionados y validación irreversible.
- **Qué entra:** rangos v1/v2 con vigencia, cálculo fuera de rango, validación por profesional habilitado, resultado crítico.
- **Qué NO entra todavía:** firma digital, workflow multinivel → fuera de alcance.
- **Conceptos clave a introducir:** Versionado de reglas de negocio, irreversibilidad, concurrencia.
- **Deuda técnica intencional 💸:** Fecha de vigencia comparada sin zona horaria explícita en un punto marcado.
  (Lo correcto es siempre UTC o con zona explícita; en Track A no se paga porque es exactamente el bug que encontrarás en producción.)
- **Pieza forense de esta fase:** Source maps en producción y por qué a veces mienten.
  (enlazar a `forense-fase-08.md` cuando exista)
- **Ejercicios:** 35 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **Regla exacta de irreversibilidad:** ¿Se permite invalidar un resultado con rol superior, o es irreversible de verdad?

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 10h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 09

```markdown
Este es el chat de la **Fase 09 — 📦 Entrega y PDF en cliente** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `09-entrega-pdf.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 09 de 14 — 📦 Entrega y PDF en cliente
- Horas: **8h**
- Depende de: Fase 8
- Habilita: Fase 11
- Apéndices de apoyo: A08, A07
- Incidentes asociados: 14, 15
- Estado: Obligatoria

## Alcance

- **Propósito (una línea):** Generar el informe en cliente y entender por qué a veces sale con datos viejos.
- **Qué entra:** armado del PDF, fuentes y acentos, vigencia del informe, marcado de entrega.
- **Qué NO entra todavía:** firma digital real, envío por correo → fuera de alcance.
- **Conceptos clave a introducir:** Generación en cliente, fuentes y acentos, estado stale.
- **Deuda técnica intencional 💸:** Copia del estado tomada al abrir la vista, no al generar.
  (Lo correcto es capturar en el momento de generar; en Track A no se paga porque es exactamente el bug que causa refunds.)
- **Pieza forense de esta fase:** Rastrear de dónde salió la copia vieja del estado.
  (enlazar a `forense-fase-09.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **Librería de PDF en cliente.** Afecta fuentes y acentos, que es donde duele en francés.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 8h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 10

```markdown
Este es el chat de la **Fase 10 — 📊 Dashboard** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `10-dashboard.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 10 de 14 — 📊 Dashboard
- Horas: **8h**
- Depende de: Fases 5-8
- Habilita: Fase 12
- Apéndices de apoyo: A05, A06
- Incidentes asociados: 16
- Estado: Obligatoria

## Alcance

- **Propósito (una línea):** Un dashboard que se pone lento, y las razones por las que se pone lento.
- **Qué entra:** KPIs, gráficos con las librerías fijadas, selectores memoizados, ciclo de vida de suscripciones.
- **Qué NO entra todavía:** agregaciones server-side, BI real → fuera de alcance.
- **Conceptos clave a introducir:** Memoización de selectores, ciclo de vida de suscripciones, re-render.
- **Deuda técnica intencional 💸:** Suscripciones sin `unsubscribe` en un componente marcado.
  (Lo correcto es OnDestroy + unsubscribe, o async pipe; en Track A no se paga porque es lo que encontrarás y hay que saber detectarlo.)
- **Pieza forense de esta fase:** Performance panel: suscripciones huérfanas y redibujos.
  (enlazar a `forense-fase-10.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **Versiones de Chart.js y ngx-charts:** ¿Conviven de verdad o una está muerta en el `package.json`?

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 8h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 11

```markdown
Este es el chat de la **Fase 11 — 📜 Trazabilidad y audit log** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `11-trazabilidad-audit-log.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 11 de 14 — 📜 Trazabilidad y audit log
- Horas: **6h**
- Depende de: Fases 5-9
- Habilita: Fase 12
- Apéndices de apoyo: A06
- Incidentes asociados: 17
- Estado: Obligatoria

## Alcance

- **Propósito (una línea):** Convertir el rastro disperso en un `auditLog` consultable que sirva para reconstruir un incidente.
- **Qué entra:** modelo de `auditLog`, qué se registra y qué no, timeline consultable, el action log como evidencia.
- **Qué NO entra todavía:** encriptación y retención legal → fuera de alcance.
- **Conceptos clave a introducir:** Auditoría como dato de primera clase.
- **Deuda técnica intencional 💸:** `auditLog` escrito desde el effect y no desde el backend.
  (Lo correcto es que el backend registre; en Track A no se paga porque el front computa y te enseña dónde está el punto de falla.)
- **Pieza forense de esta fase:** El action log como reconstrucción de incidente.
  (enlazar a `forense-fase-11.md` cuando exista)
- **Ejercicios:** 25 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **Dónde vive el `auditLog`:** ¿Lo escribe el front o llega del backend?

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 6h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 12

```markdown
Este es el chat de la **Fase 12 — ✅ Testing desde cero + coverage** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `12-testing-coverage.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 12 de 14 — ✅ Testing desde cero + coverage
- Horas: **10h**
- Depende de: Fases 1-11
- Habilita: Fase 13
- Apéndices de apoyo: A03, A05
- Incidentes asociados: 18
- Estado: Obligatoria

## Alcance

- **Propósito (una línea):** Montar testing donde no hay nada y llegar a coverage medible sin volverse loco.
- **Qué entra:** Jasmine, Karma, TestBed, tests de reducer, selector, effect, servicio y componente; coverage y su lectura.
- **Qué NO entra todavía:** e2e exhaustivo y CI real → smoke tests y fuera de alcance.
- **Conceptos clave a introducir:** TestBed, doblado de dependencias, coverage y sus mentiras.
- **Deuda técnica intencional 💸:** Tests que dependen del orden de ejecución en un caso marcado.
  (Lo correcto es tests verdaderamente aislados; en Track A no se paga porque encontrarás esto en la base de código y hay que saber detectarlo.)
- **Pieza forense de esta fase:** Test de regresión que falla antes del fix, empezando por reducers.
  (enlazar a `forense-fase-12.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **¿Hay número objetivo de coverage pedido por el líder?** Eso define la estrategia.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 10h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 13

```markdown
Este es el chat de la **Fase 13 — 🚚 Build, despliegue y cierre** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `13-build-despliegue.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 13 de 14 — 🚚 Build, despliegue y cierre
- Horas: **7h**
- Depende de: Fase 12
- Habilita: Fase 14
- Apéndices de apoyo: A04, A09, A03, A07
- Incidentes asociados: 19, 20
- Estado: Obligatoria ⭐

## Alcance

- **Propósito (una línea):** La lección que ordena el curso: la imagen es la misma en UAT y en PROD, lo que cambia es lo de afuera.
- **Qué entra:** Dockerfile multi-stage, nginx con `try_files`, `entrypoint.sh` que inyecta config en arranque, los diccionarios de i18n servidos desde el contenedor (caché de archivos sin hash, `try_files` que devuelve `index.html`, `base href` en subdirectorio), checklist de hotfix, cierre y guiño a Angular 9.
- **Qué NO entra todavía:** orquestación, pipelines de CI → Fase 14 y fuera de alcance.
- **Conceptos clave a introducir:** Build multi-stage, config horneada vs inyectada, `try_files`.
- **Deuda técnica intencional 💸:** `environment.ts` sigue horneado y se parchea desde fuera.
  (Lo correcto es todo inyectado en runtime; en Track A no se paga porque es el patrón real y hay que saber dónde está el punto débil.)
- **Pieza forense de esta fase:** Diff de ambientes y feature flags para hotfix.
  (enlazar a `forense-fase-13.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **Cómo resuelve hoy LabCore la config por ambiente:** ¿Ya hay patrón? Si es así, se enseña ese, no uno inventado.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las 6h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 14

```markdown
Este es el chat de la **Fase 14 — 🔥 Ambiente "casi prod" con kind** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `14-casi-prod-kind.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado es **LabCore** y el curso lo
  construye entero: si afirmas que algo está así en LabCore, tiene que estar en
  alguna fase. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase 14 de 14 — 🔥 Ambiente "casi prod" con kind
- Horas: — (sin horas contadas)
- Depende de: Fase 13
- Habilita: ninguna
- Apéndices de apoyo: A09, A12, A13
- Incidentes asociados: —
- Estado: 🔥 Opcional, sin horas

## Alcance

- **Propósito (una línea):** Ver la imagen de la Fase 13 corriendo en un Kubernetes local, sin tocarla.
- **Qué entra:** cluster con kind, carga de la imagen local, Deployment, Service, ConfigMap como volumen, Ingress, rolling update.
- **Qué NO entra todavía:** cluster real de la empresa, Helm, operadores → fuera de alcance.
- **Conceptos clave a introducir:** Pod, Deployment, Service, ConfigMap, Ingress, rolling update.
- **Deuda técnica intencional 💸:** Manifiestos mínimos, sin límites de recursos ni probes finas.
  (Lo correcto es liveness, readiness, resource limits; en Track A no se paga porque aquí se ve "cómo funciona", no "cómo se pone en producción".)
- **Pieza forense de esta fase:** `kubectl logs` y `describe` cuando el pod no arranca.
  (enlazar a `forense-fase-14.md` cuando exista)
- **Ejercicios:** 15 en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

- **¿El equipo toca `kubectl` o solo entrega el artefacto?** Define si hacemos ejercicios prácticos o solo visualización.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases
   previas, decisiones de diseño que esta fase fija y las siguientes heredan.
   Numéralas y marca cuáles son bloqueantes y cuáles puedes asumir con un valor
   por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di,
   y si las horas te cuadran con el contenido pedido (es opcional, así que no tiene presupuesto).
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, y qué queda fuera. Quiero verlo antes de que escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo.
Si en mitad de la redacción aparece una duda nueva, prefiero que **pares y
preguntes** a que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de
§14 de la guía de estilo y repórtame en una lista corta qué ítems cumples y
cuáles no, con el motivo.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## Cómo se usan estos prompts

Abre el chat de la fase que quieras redactar, copia el bloque completo de su sección, pega en el chat, y espera las preguntas antes de redactar. Los placeholders ya están rellenados con los valores reales de la tabla.

Si necesitas iterar sobre un documento ya escrito, usa los prompts de iteración de `prompts-de-redaccion.md`.
