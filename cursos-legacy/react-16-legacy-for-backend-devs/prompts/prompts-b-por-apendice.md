# 🅱️ Prompts B por apéndice — Listos para copiar y pegar
## Tutorial React 16 — Rifas y chances

Cada prompt está listo para copiar y pegar en el chat de ese apéndice. Los datos ya están completados según 00-alcance-del-proyecto.md.

Usa el Prompt B.1 para la primera redacción. Luego usa B.2 cada vez que necesites iterar con correcciones. Finalmente usa B.3 cuando el archivo quede aprobado y listo para cerrar.

Los apéndices son material de consulta rápida, no lectura secuencial. No siguen la plantilla de 9 secciones de las fases.

---

## Apéndice A1 — Bootstrap 4 y Sass

### B.1 — Primera redacción

```
Genera el archivo A1-bootstrap-4-y-sass.md.

Los apéndices NO siguen la plantilla de 9 secciones de las fases. Sigue el
formato de consulta rápida (prompts/guia-de-estilo-y-convenciones.md §7 y §9):

- Índice de salto rápido al inicio.
- Secciones cortas por subtema, cada una con: cuándo usarlo, ejemplo
  mínimo ejecutable, error común.
- Una tabla "cuándo usar qué" que compare opciones (p. ej. grid vs
  flexbox, clases utilitarias vs componentes Bootstrap, etc.).
- 5-10 ejercicios cortos, sin numeración por rango de dificultad.
- Referencias con URL completa, en secciones (oficial / video si aplica /
  orden de lectura), con advertencia si algún link cubre otra versión.

Tono: cálido, informal, directo. Prosa antes que listas donde se explica
un porqué; tabla solo para comparar.

Código: ejecutable, mínimo, coherente con el stack confirmado.

Contenido esperado (según 00-alcance-del-proyecto.md §6):
- Grid Bootstrap: rows, cols, responsive, breakpoints.
- Cards: estructura, contenido, utilidades.
- Tablas: básicas, responsivas, coloreadas.
- Forms: inputs, validación básica, accesibilidad.
- Utilidades: spacing, display, text, borders, colores.
- Customización de paleta: variables Sass, overrides.

Antes de escribir el archivo completo, muéstrame:
- El índice propuesto (títulos de sección).
- La tabla "cuándo usar qué" en borrador.

Espera mi aprobación de ese índice antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo A1-bootstrap-4-y-sass.md que generaste:

Corrige lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantén sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confírmame en una línea qué vas a cambiar en cada
punto. Si una corrección contradice una fase ya cerrada que referencia este
apéndice, avísame explícitamente.

Cuando quede aprobado, genera la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A1.

Antes de darlo por cerrado, verifica: índice de salto rápido presente,
secciones cortas con ejemplo ejecutable + error común, tabla "cuándo usar
qué" incluida, 5-10 ejercicios, referencias completas con advertencia de
versión, autocontenido (guía §11), coherencia con Fase 0 y fases
posteriores que lo referencian.

Dime si algo no se cumple. Si todo está en orden, entrega el archivo
final y recuérdame actualizar el índice de README.md: Apéndice A1
de ⏳ a ✅.
```

---

## Apéndice A2 — Mini Design System con Sass

### B.1 — Primera redacción

```
Genera el archivo A2-mini-design-system.md.

Sigue el formato de consulta rápida (prompts/guia-de-estilo-y-convenciones.md §7 y §9):
- Índice de salto rápido.
- Secciones cortas: cuándo usarlo, ejemplo mínimo, error común.
- Tabla "cuándo usar qué".
- 5-10 ejercicios cortos.
- Referencias completas.

Contenido esperado (según 00-alcance-del-proyecto.md §6):
- Variables Sass: colors, spacing, typography, breakpoints.
- Tokens: cómo el proyecto define sus propias variables.
- Mixins: responsive, utilities, theme overrides.
- Convenciones de nombramiento: _base.scss, _utilities.scss, _components.scss.
- Cómo extender Bootstrap sin tocarlo (override sin modificar node_modules).

Código: ejecutable (archivos Scss), mínimo, coherente con dart-sass.

Antes de escribir el archivo completo, muéstrame:
- El índice propuesto.
- La tabla "cuándo usar qué" en borrador.

Espera mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo A2-mini-design-system.md que generaste:

Corrige lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantén sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confírmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 1 o posteriores, avísame explícitamente.

Cuando quede aprobado, genera la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A2.

Verifica: índice, secciones con ejemplo + error común, tabla, 5-10
ejercicios, referencias, autocontenido (guía §11), coherencia con fases.

Dime si algo no se cumple. Si está en orden, entrega el archivo final y
recuérdame actualizar el índice de README.md: Apéndice A2 de ⏳ a ✅.
```

---

## Apéndice A3 — Node y npm

### B.1 — Primera redacción

```
Genera el archivo A3-node-y-npm.md.

Sigue el formato de consulta rápida (prompts/guia-de-estilo-y-convenciones.md §7 y §9):
- Índice de salto rápido.
- Secciones cortas: cuándo usarlo, ejemplo mínimo, error común.
- Tabla "cuándo usar qué" (npm ci vs npm i, package.json vs
  package-lock.json, semver ranges, etc.).
- 5-10 ejercicios cortos.
- Referencias completas.

Contenido esperado (según 00-alcance-del-proyecto.md §6):
- package.json: dependencies, devDependencies, scripts, versioning.
- package-lock.json: qué es, por qué NO se modifica, reproducibilidad.
- npm ci vs npm i: diferencias, cuándo usar cada uno.
- semver: ~ y ^, exactitud, lockfile lock.
- .nvmrc: Node 14.21.3 pinneado.
- npm scripts: cómo se leen, cómo se ejecutan.

Código: ejemplos de configuración, no código ejecutable propiamente.

Antes de escribir el archivo completo, muéstrame:
- El índice propuesto.
- La tabla "cuándo usar qué" en borrador.

Espera mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo A3-node-y-npm.md que generaste:

Corrige lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantén sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confírmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 0 o posteriores, avísame explícitamente.

Cuando quede aprobado, genera la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A3.

Verifica: índice, secciones con ejemplo + error común, tabla, 5-10
ejercicios, referencias, autocontenido (guía §11), coherencia con Fase 0.

Dime si algo no se cumple. Si está en orden, entrega el archivo final y
recuérdame actualizar el índice de README.md: Apéndice A3 de ⏳ a ✅.
```

---

## Apéndice A4 — CRA por Dentro

### B.1 — Primera redacción

```
Genera el archivo A4-cra-por-dentro.md.

Sigue el formato de consulta rápida (prompts/guia-de-estilo-y-convenciones.md §7 y §9):
- Índice de salto rápido.
- Secciones cortas: cuándo usarlo, ejemplo mínimo, error común.
- Tabla "cuándo hacer qué" (eject, config, env variables, etc.).
- 5-10 ejercicios cortos.
- Referencias completas.

Contenido esperado (según 00-alcance-del-proyecto.md §6):
- Estructura de carpetas de CRA: public/, src/, node_modules/.
- Webpack oculto: por qué, cuándo necesitas verlo, riesgos de eject.
- Environment variables: .env.local, .env.development, .env.production.
- react-scripts: qué hace, cómo customizar sin eject (override files).
- Proxy en desarrollo: setupProxy.js.
- Performance hints: lazy loading, code splitting, source maps.

Código: ejemplos de configuración y estructura.

Antes de escribir el archivo completo, muéstrame:
- El índice propuesto.
- La tabla "cuándo hacer qué" en borrador.

Espera mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo A4-cra-por-dentro.md que generaste:

Corrige lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantén sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confírmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 1 o posteriores, avísame explícitamente.

Cuando quede aprobado, genera la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A4.

Verifica: índice, secciones con ejemplo + error común, tabla, 5-10
ejercicios, referencias, autocontenido (guía §11), coherencia con Fase 1.

Dime si algo no se cumple. Si está en orden, entrega el archivo final y
recuérdame actualizar el índice de README.md: Apéndice A4 de ⏳ a ✅.
```

---

## Apéndice A5 — Class Components vs Hooks

### B.1 — Primera redacción

```
Genera el archivo A5-class-components-vs-hooks.md.

Sigue el formato de consulta rápida (prompts/guia-de-estilo-y-convenciones.md §7 y §9):
- Índice de salto rápido.
- Secciones cortas: cuándo usarlo, ejemplo mínimo, error común.
- Tabla de EQUIVALENCIAS grandes: componentDidMount → useEffect, etc.
- 5-10 ejercicios cortos.
- Referencias completas.

Contenido esperado (según 00-alcance-del-proyecto.md §6):
- Ciclo de vida en clases: constructor, componentDidMount,
  componentDidUpdate, componentWillUnmount, componentWillReceiveProps.
- Hooks equivalentes: useState, useEffect, useContext, useReducer.
- Leer código mezclado: identifying patterns in legacy code.
- Conversión de class a hook: paso a paso (NO automatizada, didáctica).
- Trampas comunes: deps array, cleanup functions, re-renders.
- this.state vs useState, this.props vs component props.

Código: ejemplos reales en ambos estilos, lado a lado.

Antes de escribir el archivo completo, muéstrame:
- El índice propuesto.
- La tabla de equivalencias en borrador (class → hooks).

Espera mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo A5-class-components-vs-hooks.md que generaste:

Corrige lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantén sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confírmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 2 o posteriores, avísame explícitamente.

Cuando quede aprobado, genera la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A5.

Verifica: índice, secciones con ejemplo + error común, tabla de
equivalencias, 5-10 ejercicios, referencias, autocontenido (guía §11), coherencia con
Fase 2 y posteriores.

Dime si algo no se cumple. Si está en orden, entrega el archivo final y
recuérdame actualizar el índice de README.md: Apéndice A5 de ⏳ a ✅.
```

---

## Apéndice A6 — Redux Clásico vs Toolkit

### B.1 — Primera redacción

```
Genera el archivo A6-redux-clasico-vs-toolkit.md.

Sigue el formato de consulta rápida (prompts/guia-de-estilo-y-convenciones.md §7 y §9):
- Índice de salto rápido.
- Secciones cortas: cuándo usarlo, ejemplo mínimo, error común.
- Tabla de EQUIVALENCIAS: connect() → useSelector/useDispatch, manual
  actions → createAction, etc.
- 5-10 ejercicios cortos.
- Referencias completas.

Contenido esperado (según 00-alcance-del-proyecto.md §6):
- Redux clásico: createStore, reducers manuales, actions manuales, connect().
- Redux Toolkit: createSlice (combine actions + reducer), createAsyncThunk,
  createEntityAdapter, configureStore.
- useSelector vs mapStateToProps.
- useDispatch vs mapDispatchToProps.
- Immer integration (automático en Toolkit).
- Leer código mezclado: ambos estilos conviviendo.
- Conversión de slice manual a createSlice.

Código: ejemplos reales en ambos estilos, lado a lado.

Antes de escribir el archivo completo, muéstrame:
- El índice propuesto.
- La tabla de equivalencias en borrador.

Espera mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo A6-redux-clasico-vs-toolkit.md que generaste:

Corrige lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantén sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confírmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 3 o posteriores, avísame explícitamente.

Cuando quede aprobado, genera la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A6.

Verifica: índice, secciones con ejemplo + error común, tabla de
equivalencias, 5-10 ejercicios, referencias, autocontenido (guía §11), coherencia con
Fase 3 y posteriores.

Dime si algo no se cumple. Si está en orden, entrega el archivo final y
recuérdame actualizar el índice de README.md: Apéndice A6 de ⏳ a ✅.
```

---

## Apéndice A7 — Redux-Observable Épica por Épica

### B.1 — Primera redacción

```
Genera el archivo A7-redux-observable-epica-por-epica.md.

Sigue el formato de consulta rápida (prompts/guia-de-estilo-y-convenciones.md §7 y §9):
- Índice de salto rápido.
- Secciones ESPECÍFICAS POR PATRÓN: debounce, switchMap, mergeMap,
  concatMap, exhaustMap, takeUntil, retry, catchError. Cada una con:
  cuándo usarlo, ejemplo mínimo, error común, y cómo probarlo con marbles
  (rxjs-marbles, D9).
- Tabla "cuándo usar qué operador".
- 5-10 ejercicios (+ algunos con marble testing).
- Referencias completas (Redux Observable docs, RxJS 6 docs, marble
  testing docs).

Contenido esperado (ESENCIAL, 4h):
- **debounce**: esperar X ms sin eventos → emitir últmo. Para búsqueda.
- **switchMap**: cancelar suscripción anterior. Para polling, navegación.
- **mergeMap**: mantener varias suscripciones concurrentes. Para llamadas paralelas.
- **concatMap**: encolar, emitir en orden. Para transacciones.
- **exhaustMap**: ignorar nuevos eventos mientras procesa. Para submit de form.
- **takeUntil**: cancelar al recibir trigger. Para cleanup, logout.
- **retry**: reintentar N veces con backoff. Para fallos transientes.
- **catchError**: manejar error sin destruir epic. Para error handling.
- Memory leaks: cómo detectarlas, cómo prevenirlas (takeUntil).
- Marble testing: syntax básica, cómo testear timing.

Código: ejemplos reales de epics, NO pseudocódigo.

Antes de escribir el archivo completo, muéstrame:
- El índice propuesto (lista de 8+ patrones).
- La tabla "cuándo usar qué operador" en borrador.
- Un ejemplo de marble test en borrador.

Espera mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo A7-redux-observable-epica-por-epica.md que
generaste:

Corrige lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantén sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confírmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 6 o posteriores, avísame explícitamente.

Cuando quede aprobado, genera la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A7.

Verifica: índice (8+ patrones), secciones con ejemplo + error común +
marble test, tabla "cuándo usar qué", 5-10 ejercicios (varios con
marbles), referencias, autocontenido (guía §11), coherencia con Fase 6 y posteriores.

Dime si algo no se cumple. Si está en orden, entrega el archivo final y
recuérdame actualizar el índice de README.md: Apéndice A7 de ⏳ a ✅.
```

---

## Apéndice A8 — Puente a React Moderno (opcional)

### B.1 — Primera redacción

```
Genera el archivo A8-puente-a-react-moderno.md.

Sigue el formato de consulta rápida (prompts/guia-de-estilo-y-convenciones.md §7 y §9):
- Índice de salto rápido.
- Secciones cortas: comparativa mental models (no código en producción).
- Tabla "React 16 vs 17 vs 18" (features, breaking changes, qué cambiar).
- 5-10 ejercicios de lectura/reflexión (NO implementación).
- Referencias completas.

Contenido esperado (COMPARATIVO SOLAMENTE, 2h):
- React 16 → 17: qué cambió (event delegation, JSX Transform).
- React 17 → 18: Suspense, Transitions, Concurrent Features.
- Redux Toolkit → RTK Query: caching, invalidation.
- RxJS 6 → 7: breaking changes en imports, tree-shaking.
- Redux observable → alternatives (Redux Saga, thunks).
- Hooks-only era: cómo refactorizar connect() a hooks.
- Estrategia de migración: paso a paso, sin urgencia.

Código: NO código ejecutable. Solo ejemplos de antes/después marcados
como "si fuera React 18" o "alternativa moderna".

Marcado con advertencia: este apéndice es OPCIONAL, COMPARATIVO,
CONTEXTO HISTÓRICO. No es para aplicar en Fase 11; es para leer y entender.

Antes de escribir el archivo completo, muéstrame:
- El índice propuesto.
- La tabla "React 16 vs 17 vs 18" en borrador.

Espera mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo A8-puente-a-react-moderno.md que generaste:

Corrige lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantén sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confírmame en una línea qué vas a cambiar. Si una
corrección introduce código ejecutable de React 18/RTK moderno en el archivo,
avísame explícitamente — este apéndice es COMPARATIVO, no aplicado.

Cuando quede aprobado, genera la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A8.

Verifica: índice, secciones comparativas sin código ejecutable, tabla
"React 16 vs 17 vs 18", 5-10 ejercicios de lectura, referencias, CERO
código de React 18 en producción, marcado como OPCIONAL Y COMPARATIVO,
coherencia con Fase 11 (referencia solamente).

Dime si algo no se cumple. Si está en orden, entrega el archivo final y
recuérdame actualizar el índice de README.md: Apéndice A8 de ⏳ a ✅.
```
