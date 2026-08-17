# 🅱️ Prompts B por apéndice — Listos para copiar y pegar
## Tutorial React 16 — Rifas y chances

Cada prompt está listo para copiar y pegar en el chat de ese apéndice. Los datos ya están completados según PLAN-DEL-CURSO.md y CATALOGO-FASES-Y-APENDICES.md.

Usá el Prompt B.1 para la primera redacción. Luego usá B.2 cada vez que necesites iterar con correcciones. Finalmente usá B.3 cuando el archivo quede aprobado y listo para cerrar.

Los apéndices son material de consulta rápida, no lectura secuencial. No siguen la plantilla de 9 secciones de las fases.

---

## Apéndice A1 — Bootstrap 4 y Sass

### B.1 — Primera redacción

```
Generá el archivo Apéndice A1 — Bootstrap 4 y Sass.md.

Los apéndices NO siguen la plantilla de 9 secciones de las fases. Seguí el
formato de consulta rápida (GUIA-DE-ESTILO-Y-CONVENCIONES.md §7 y §9):

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

Contenido esperado (según tutorial-react16.md / catálogo):
- Grid Bootstrap: rows, cols, responsive, breakpoints.
- Cards: estructura, contenido, utilidades.
- Tablas: básicas, responsivas, coloreadas.
- Forms: inputs, validación básica, accesibilidad.
- Utilidades: spacing, display, text, borders, colores.
- Customización de paleta: variables Sass, overrides.

Antes de escribir el archivo completo, mostrame:
- El índice propuesto (títulos de sección).
- La tabla "cuándo usar qué" en borrador.

Esperá mi aprobación de ese índice antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo Apéndice A1 — Bootstrap 4 y Sass.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar en cada
punto. Si una corrección contradice una fase ya cerrada que referencia este
apéndice, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A1.

Antes de darlo por cerrado, verificá: índice de salto rápido presente,
secciones cortas con ejemplo ejecutable + error común, tabla "cuándo usar
qué" incluida, 5-10 ejercicios, referencias completas con advertencia de
versión, cero referencia al dominio real, coherencia con Fase 0 y fases
posteriores que lo referencian.

Decime si algo no se cumple. Si todo está en orden, entregá el archivo
final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md: Apéndice A1
de ⏳ a ✅.
```

---

## Apéndice A2 — Mini Design System con Sass

### B.1 — Primera redacción

```
Generá el archivo Apéndice A2 — Mini Design System con Sass.md.

Seguí el formato de consulta rápida (GUIA-DE-ESTILO-Y-CONVENCIONES.md §7 y §9):
- Índice de salto rápido.
- Secciones cortas: cuándo usarlo, ejemplo mínimo, error común.
- Tabla "cuándo usar qué".
- 5-10 ejercicios cortos.
- Referencias completas.

Contenido esperado (según tutorial-react16.md / catálogo):
- Variables Sass: colors, spacing, typography, breakpoints.
- Tokens: cómo el sistema real define sus propias variables.
- Mixins: responsive, utilities, theme overrides.
- Convenciones de nombramiento: _base.scss, _utilities.scss, _components.scss.
- Cómo extender Bootstrap sin tocarlo (override sin modificar node_modules).

Código: ejecutable (archivos Scss), mínimo, coherente con dart-sass.

Antes de escribir el archivo completo, mostrame:
- El índice propuesto.
- La tabla "cuándo usar qué" en borrador.

Esperá mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo Apéndice A2 — Mini Design System con Sass.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 1 o posteriores, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A2.

Verificá: índice, secciones con ejemplo + error común, tabla, 5-10
ejercicios, referencias, cero NDA, coherencia con fases.

Decime si algo no se cumple. Si está en orden, entregá el archivo final y
recordame actualizar CATALOGO-FASES-Y-APENDICES.md: Apéndice A2 de ⏳ a ✅.
```

---

## Apéndice A3 — Node y npm

### B.1 — Primera redacción

```
Generá el archivo Apéndice A3 — Node y npm.md.

Seguí el formato de consulta rápida (GUIA-DE-ESTILO-Y-CONVENCIONES.md §7 y §9):
- Índice de salto rápido.
- Secciones cortas: cuándo usarlo, ejemplo mínimo, error común.
- Tabla "cuándo usar qué" (npm ci vs npm i, package.json vs
  package-lock.json, semver ranges, etc.).
- 5-10 ejercicios cortos.
- Referencias completas.

Contenido esperado (según tutorial-react16.md / catálogo):
- package.json: dependencies, devDependencies, scripts, versioning.
- package-lock.json: qué es, por qué NO se modifica, reproducibilidad.
- npm ci vs npm i: diferencias, cuándo usar cada uno.
- semver: ~ y ^, exactitud, lockfile lock.
- .nvmrc: Node 14.21.3 pinneado.
- npm scripts: cómo se leen, cómo se ejecutan.

Código: ejemplos de configuración, no código ejecutable propiamente.

Antes de escribir el archivo completo, mostrame:
- El índice propuesto.
- La tabla "cuándo usar qué" en borrador.

Esperá mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo Apéndice A3 — Node y npm.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 0 o posteriores, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A3.

Verificá: índice, secciones con ejemplo + error común, tabla, 5-10
ejercicios, referencias, cero NDA, coherencia con Fase 0.

Decime si algo no se cumple. Si está en orden, entregá el archivo final y
recordame actualizar CATALOGO-FASES-Y-APENDICES.md: Apéndice A3 de ⏳ a ✅.
```

---

## Apéndice A4 — CRA por Dentro

### B.1 — Primera redacción

```
Generá el archivo Apéndice A4 — CRA por Dentro.md.

Seguí el formato de consulta rápida (GUIA-DE-ESTILO-Y-CONVENCIONES.md §7 y §9):
- Índice de salto rápido.
- Secciones cortas: cuándo usarlo, ejemplo mínimo, error común.
- Tabla "cuándo hacer qué" (eject, config, env variables, etc.).
- 5-10 ejercicios cortos.
- Referencias completas.

Contenido esperado (según tutorial-react16.md / catálogo):
- Estructura de carpetas de CRA: public/, src/, node_modules/.
- Webpack oculto: por qué, cuándo necesitas verlo, riesgos de eject.
- Environment variables: .env.local, .env.development, .env.production.
- react-scripts: qué hace, cómo customizar sin eject (override files).
- Proxy en desarrollo: setupProxy.js.
- Performance hints: lazy loading, code splitting, source maps.

Código: ejemplos de configuración y estructura.

Antes de escribir el archivo completo, mostrame:
- El índice propuesto.
- La tabla "cuándo hacer qué" en borrador.

Esperá mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo Apéndice A4 — CRA por Dentro.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 1 o posteriores, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A4.

Verificá: índice, secciones con ejemplo + error común, tabla, 5-10
ejercicios, referencias, cero NDA, coherencia con Fase 1.

Decime si algo no se cumple. Si está en orden, entregá el archivo final y
recordame actualizar CATALOGO-FASES-Y-APENDICES.md: Apéndice A4 de ⏳ a ✅.
```

---

## Apéndice A5 — Class Components vs Hooks

### B.1 — Primera redacción

```
Generá el archivo Apéndice A5 — Class Components vs Hooks.md.

Seguí el formato de consulta rápida (GUIA-DE-ESTILO-Y-CONVENCIONES.md §7 y §9):
- Índice de salto rápido.
- Secciones cortas: cuándo usarlo, ejemplo mínimo, error común.
- Tabla de EQUIVALENCIAS grandes: componentDidMount → useEffect, etc.
- 5-10 ejercicios cortos.
- Referencias completas.

Contenido esperado (según tutorial-react16.md / catálogo):
- Ciclo de vida en clases: constructor, componentDidMount,
  componentDidUpdate, componentWillUnmount, componentWillReceiveProps.
- Hooks equivalentes: useState, useEffect, useContext, useReducer.
- Leer código mezclado: identifying patterns in legacy code.
- Conversión de class a hook: paso a paso (NO automatizada, didáctica).
- Trampas comunes: deps array, cleanup functions, re-renders.
- this.state vs useState, this.props vs component props.

Código: ejemplos reales en ambos estilos, lado a lado.

Antes de escribir el archivo completo, mostrame:
- El índice propuesto.
- La tabla de equivalencias en borrador (class → hooks).

Esperá mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo Apéndice A5 — Class Components vs Hooks.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 2 o posteriores, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A5.

Verificá: índice, secciones con ejemplo + error común, tabla de
equivalencias, 5-10 ejercicios, referencias, cero NDA, coherencia con
Fase 2 y posteriores.

Decime si algo no se cumple. Si está en orden, entregá el archivo final y
recordame actualizar CATALOGO-FASES-Y-APENDICES.md: Apéndice A5 de ⏳ a ✅.
```

---

## Apéndice A6 — Redux Clásico vs Toolkit

### B.1 — Primera redacción

```
Generá el archivo Apéndice A6 — Redux Clásico vs Toolkit.md.

Seguí el formato de consulta rápida (GUIA-DE-ESTILO-Y-CONVENCIONES.md §7 y §9):
- Índice de salto rápido.
- Secciones cortas: cuándo usarlo, ejemplo mínimo, error común.
- Tabla de EQUIVALENCIAS: connect() → useSelector/useDispatch, manual
  actions → createAction, etc.
- 5-10 ejercicios cortos.
- Referencias completas.

Contenido esperado (según tutorial-react16.md / catálogo):
- Redux clásico: createStore, reducers manuales, actions manuales, connect().
- Redux Toolkit: createSlice (combine actions + reducer), createAsyncThunk,
  createEntityAdapter, configureStore.
- useSelector vs mapStateToProps.
- useDispatch vs mapDispatchToProps.
- Immer integration (automático en Toolkit).
- Leer código mezclado: ambos estilos conviviendo.
- Conversión de slice manual a createSlice.

Código: ejemplos reales en ambos estilos, lado a lado.

Antes de escribir el archivo completo, mostrame:
- El índice propuesto.
- La tabla de equivalencias en borrador.

Esperá mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo Apéndice A6 — Redux Clásico vs Toolkit.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 3 o posteriores, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A6.

Verificá: índice, secciones con ejemplo + error común, tabla de
equivalencias, 5-10 ejercicios, referencias, cero NDA, coherencia con
Fase 3 y posteriores.

Decime si algo no se cumple. Si está en orden, entregá el archivo final y
recordame actualizar CATALOGO-FASES-Y-APENDICES.md: Apéndice A6 de ⏳ a ✅.
```

---

## Apéndice A7 — Redux-Observable Épica por Épica

### B.1 — Primera redacción

```
Generá el archivo Apéndice A7 — Redux-Observable Épica por Épica.md.

Seguí el formato de consulta rápida (GUIA-DE-ESTILO-Y-CONVENCIONES.md §7 y §9):
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

Antes de escribir el archivo completo, mostrame:
- El índice propuesto (lista de 8+ patrones).
- La tabla "cuándo usar qué operador" en borrador.
- Un ejemplo de marble test en borrador.

Esperá mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo Apéndice A7 — Redux-Observable Épica por Épica.md que
generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice la Fase 6 o posteriores, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A7.

Verificá: índice (8+ patrones), secciones con ejemplo + error común +
marble test, tabla "cuándo usar qué", 5-10 ejercicios (varios con
marbles), referencias, cero NDA, coherencia con Fase 6 y posteriores.

Decime si algo no se cumple. Si está en orden, entregá el archivo final y
recordame actualizar CATALOGO-FASES-Y-APENDICES.md: Apéndice A7 de ⏳ a ✅.
```

---

## Apéndice A8 — Puente a React Moderno (opcional)

### B.1 — Primera redacción

```
Generá el archivo Apéndice A8 — Puente a React Moderno.md.

Seguí el formato de consulta rápida (GUIA-DE-ESTILO-Y-CONVENCIONES.md §7 y §9):
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

Antes de escribir el archivo completo, mostrame:
- El índice propuesto.
- La tabla "React 16 vs 17 vs 18" en borrador.

Esperá mi aprobación antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo Apéndice A8 — Puente a React Moderno.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o ejemplo afectado}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección introduce código ejecutable de React 18/RTK moderno en el archivo,
avisame explícitamente — este apéndice es COMPARATIVO, no aplicado.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre del apéndice

```
Este archivo queda aprobado como versión final del Apéndice A8.

Verificá: índice, secciones comparativas sin código ejecutable, tabla
"React 16 vs 17 vs 18", 5-10 ejercicios de lectura, referencias, CERO
código de React 18 en producción, marcado como OPCIONAL Y COMPARATIVO,
coherencia con Fase 11 (referencia solamente).

Decime si algo no se cumple. Si está en orden, entregá el archivo final y
recordame actualizar CATALOGO-FASES-Y-APENDICES.md: Apéndice A8 de ⏳ a ✅.
```
