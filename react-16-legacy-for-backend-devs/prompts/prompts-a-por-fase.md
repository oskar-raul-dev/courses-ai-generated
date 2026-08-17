# 🅰️ Prompts A por fase — Listos para copiar y pegar
## Tutorial React 16 — Rifas y chances

Cada prompt está listo para copiar y pegar en un chat nuevo. Los datos ya están completados según PLAN-DEL-CURSO.md y CATALOGO-FASES-Y-APENDICES.md. Solo cópialo tal cual al abrir el chat de esa fase.

---

## Fase 0 — Setup + Hola mundo CRA

```
Este es el chat de redacción de la Fase 0 — Setup + Hola mundo CRA del
tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 0 de 11.
- Nombre: Setup + Hola mundo CRA.
- Horas: 6h.
- Depende de: ninguna (es la primera).
- Habilita: Fase 1 — Estructura base + Router 5.
- Qué entra: NVM, CRA 4, componente único, Bootstrap+Sass básico.
- Qué NO entra (se difiere): routing, Redux.
- Pieza forense de esta fase: Consola, Network tab, React DevTools básicos.
- Incidentes del cuaderno que esta fase puede resolver: 🟢 básicos de configuración y CORS.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0.
- D3 JavaScript plano ES2019, sin TypeScript. JSDoc donde aporte.
- D11 Sass = dart-sass, sin node-sass. Compatibilidad macOS ARM.
- D13 Colima recomendado, Docker Desktop como alternativa.
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Primer componente: funcional con hooks.
- Deuda técnica intencional marcada con 💸; opcionales con 🔥.
- Distinguir siempre frontend / store / epic / backend.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```

---

## Fase 1 — Estructura base + Router 5

```
Este es el chat de redacción de la Fase 1 — Estructura base + Router 5
del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 1 de 11.
- Nombre: Estructura base + Router 5.
- Horas: 8h.
- Depende de: Fase 0 — Setup + Hola mundo CRA, ya cerrada y aprobada.
- Habilita: Fase 2 — Autenticación mínima.
- Qué entra: React Router 5, layout, Bootstrap navbar, mixta class/función.
- Qué NO entra (se difiere a Fase 2): Redux, autenticación.
- Pieza forense de esta fase: Componente que no re-renderiza — cómo saber por qué.
- Incidentes del cuaderno que esta fase puede resolver: 🟢 de estructura y navbar.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0.
- D3 JavaScript plano ES2019, sin TypeScript. JSDoc donde aporte.
- D5 React Router 5.3.x (useHistory, useLocation, useParams + <Route> clásica).
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Class components para módulos legacy; hooks para módulos nuevos, ambos conviven.
- Distinguir siempre frontend / store / epic / backend.
- Explicar diferencia entre corrección mínima y refactorización cuando haya un fix.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```

---

## Fase 2 — Autenticación mínima

```
Este es el chat de redacción de la Fase 2 — Autenticación mínima del
tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 2 de 11.
- Nombre: Autenticación mínima.
- Horas: 8h.
- Depende de: Fase 1 — Estructura base + Router 5, ya cerrada y aprobada.
- Habilita: Fase 3 — Mock API + Express caos.
- Qué entra: Login mock, slice de auth, PrivateRoute, interceptor axios.
- Qué NO entra (se difiere): roles, refresh token.
- Pieza forense de esta fase: Debug de interceptor axios — request-id, correlación.
- Incidentes del cuaderno que esta fase puede resolver: 🟢 de login y auth.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0.
- D3 JavaScript plano ES2019, sin TypeScript. JSDoc donde aporte.
- D4 Redux Toolkit 1.8.x (createSlice).
- D5 React Router 5.3.x (useHistory, useLocation, useParams + <Route>).
- D8 Sin interceptors de axios preexistentes: se construyen desde cero en esta fase.
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Slice Redux Toolkit nuevo para auth.
- Componentes funcionales con hooks para login.
- Deuda técnica intencional marcada con 💸; opcionales con 🔥.
- Distinguir siempre frontend / store / epic / backend.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```

---

## Fase 3 — Mock API + Express caos

```
Este es el chat de redacción de la Fase 3 — Mock API + Express caos del
tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 3 de 11.
- Nombre: Mock API + Express caos.
- Horas: 6h.
- Depende de: Fase 2 — Autenticación mínima, ya cerrada y aprobada.
- Habilita: Fase 4 — Rifas CRUD.
- Qué entra: json-server, db.json, middleware caos, mock lotería.
- Qué NO entra (se difiere): paginación server.
- Pieza forense de esta fase: Simular caos con Express — cómo reacciona la SPA.
- Incidentes del cuaderno que esta fase puede resolver: 🟡 de CORS, latencia, fallos.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0.
- D3 JavaScript plano ES2019, sin TypeScript. JSDoc donde aporte.
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Código del mock y middleware en Express, no en React.
- Deuda técnica intencional marcada con 💸; opcionales con 🔥.
- Distinguir siempre frontend / store / epic / backend.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```

---

## Fase 4 — Rifas CRUD

```
Este es el chat de redacción de la Fase 4 — Rifas CRUD del tutorial
React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 4 de 11.
- Nombre: Rifas CRUD.
- Horas: 8h.
- Depende de: Fase 3 — Mock API + Express caos, ya cerrada y aprobada.
- Habilita: Fase 5 — Venta de números.
- Qué entra: Redux Toolkit slice, tabla, formularios controlados.
- Qué NO entra (se difiere a Fase 5): venta, epics, validaciones complejas.
- Pieza forense de esta fase: Redux DevTools — time-travel, replay de acciones.
- Incidentes del cuaderno que esta fase puede resolver: 🟡 de slice y estado.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0.
- D3 JavaScript plano ES2019, sin TypeScript. JSDoc donde aporte.
- D4 Redux Toolkit 1.8.x (createSlice, createAsyncThunk si aplica).
- D5 React Router 5.3.x (useHistory, useLocation, useParams + <Route>).
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Slice Redux Toolkit nuevo para rifas.
- Componentes funcionales con hooks para formularios.
- Deuda técnica intencional marcada con 💸; opcionales con 🔥.
- Distinguir siempre frontend / store / epic / backend.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```

---

## Fase 5 ⭐ — Venta de números

```
Este es el chat de redacción de la Fase 5 — Venta de números del tutorial
React 16 + Rifas y chances. FASE CENTRAL ⭐.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 5 de 11. **CENTRAL ⭐**
- Nombre: Venta de números.
- Horas: 12h. **Fase larga.**
- Depende de: Fase 4 — Rifas CRUD, ya cerrada y aprobada.
- Habilita: Fase 6 — redux-observable a fondo.
- Qué entra: Tablero 0000-9999, unicidad, reserva temporal, race conditions.
- Qué NO entra (se difiere a Fase 6): cancelación epic, epics complejos.
- Pieza forense de esta fase: Race condition de venta — cómo se manifiesta en el store.
- Incidentes del cuaderno que esta fase puede resolver: 🟡-🟠 de venta duplicada, race conditions.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0.
- D3 JavaScript plano ES2019, sin TypeScript. JSDoc donde aporte.
- D4 Redux Toolkit 1.8.x (createSlice, createAsyncThunk).
- D5 React Router 5.3.x (useHistory, useLocation, useParams + <Route>).
- D2 redux-observable 1.2.0 + RxJS 6.6.7 presentes (usado en epics simples).
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Slice Redux Toolkit para números y reservas.
- Componentes funcionales con hooks para el tablero.
- Class components si la lógica de la fase anterior los introduce.
- Deuda técnica intencional marcada con 💸; opcionales con 🔥.
- Distinguir siempre frontend / store / epic / backend.
- Explicar diferencia entre corrección mínima y refactorización cuando haya un fix.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```

---

## Fase 6 ⭐ — redux-observable a fondo

```
Este es el chat de redacción de la Fase 6 — redux-observable a fondo del
tutorial React 16 + Rifas y chances. FASE CENTRAL ⭐.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 6 de 11. **CENTRAL ⭐ — FUENTE DE BUGS MÁS DIFÍCIL.**
- Nombre: redux-observable a fondo.
- Horas: 12h. **Fase larga y conceptualmente densa.**
- Depende de: Fase 5 — Venta de números, ya cerrada y aprobada.
- Habilita: Fase 7 — Cierre + polling resultado.
- Qué entra: Epics, .pipe(), debounce, switchMap, takeUntil, retry, cancelación, pattern matching.
- Qué NO entra (se difiere a Fase 7): polling resultado, testing de epics con marbles.
- Pieza forense de esta fase: Debug de epics — memory leak por no takeUntil, switchMap vs mergeMap, epic que no cancela.
- Incidentes del cuaderno que esta fase puede resolver: 🟠-🔴 de epics, memory leaks, cancelación mal hecha.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0.
- D3 JavaScript plano ES2019, sin TypeScript. JSDoc donde aporte.
- D4 Redux Toolkit 1.8.x.
- D2 redux-observable 1.2.0 + RxJS 6.6.7 presentes y centrales en esta fase.
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Epics con .pipe() y operadores nombrados, nunca encadenamientos crípticos.
- RxJS con moderación: epics solo cuando el async lo justifique.
- Deuda técnica intencional marcada con 💸; opcionales con 🔥.
- Distinguir siempre frontend / store / epic / backend.
- Explicar diferencia entre corrección mínima y refactorización cuando haya un fix.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```

---

## Fase 7 — Cierre + polling resultado

```
Este es el chat de redacción de la Fase 7 — Cierre + polling resultado
del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 7 de 11.
- Nombre: Cierre + polling resultado.
- Horas: 10h.
- Depende de: Fase 6 — redux-observable a fondo, ya cerrada y aprobada.
- Habilita: Fase 8 — Liquidación + cálculo de premio.
- Qué entra: Hora dura con TZ, polling epic al mock lotería, reintentos.
- Qué NO entra (se difiere a Fase 8): liquidación, cálculo de premio.
- Pieza forense de esta fase: Polling que no para al desmontar componente.
- Incidentes del cuaderno que esta fase puede resolver: 🟠 de polling infinito, hora dura, TZ.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0.
- D3 JavaScript plano ES2019, sin TypeScript. JSDoc donde aporte.
- D4 Redux Toolkit 1.8.x.
- D2 redux-observable 1.2.0 + RxJS 6.6.7 (epics con polling).
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Epics de polling con switchMap, interval, takeUntil.
- Deuda técnica intencional marcada con 💸; opcionales con 🔥.
- Distinguir siempre frontend / store / epic / backend.
- Explicar diferencia entre corrección mínima y refactorización cuando haya un fix.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```

---

## Fase 8 — Liquidación + cálculo de premio

```
Este es el chat de redacción de la Fase 8 — Liquidación + cálculo de
premio del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 8 de 11.
- Nombre: Liquidación + cálculo de premio.
- Horas: 8h.
- Depende de: Fase 7 — Cierre + polling resultado, ya cerrada y aprobada.
- Habilita: Fase 9 — Dashboard.
- Qué entra: Dinero sin floats, redondeo exacto, cierre de rifa irreversible.
- Qué NO entra (se difiere): pasarela de pago real.
- Pieza forense de esta fase: Bug de dinero — floats vs enteros, redondeo silencioso.
- Incidentes del cuaderno que esta fase puede resolver: 🟠 de dinero mal redondeado, cálculo erróneo.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0.
- D3 JavaScript plano ES2019, sin TypeScript. JSDoc donde aporte.
- D4 Redux Toolkit 1.8.x.
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Dinero en enteros (centavos/pesos), nunca floats.
- Slice Redux Toolkit para liquidación.
- Deuda técnica intencional marcada con 💸; opcionales con 🔥.
- Distinguir siempre frontend / store / epic / backend.
- Explicar diferencia entre corrección mínima y refactorización cuando haya un fix.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```

---

## Fase 9 — Dashboard

```
Este es el chat de redacción de la Fase 9 — Dashboard del tutorial
React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 9 de 11.
- Nombre: Dashboard.
- Horas: 6h.
- Depende de: Fase 8 — Liquidación + cálculo de premio, ya cerrada y aprobada.
- Habilita: Fase 10 — Testing mínimo.
- Qué entra: Gráficos con chart.js, resumen de ventas, KPIs.
- Qué NO entra (se difiere): BI real, drill-down.
- Pieza forense de esta fase: Performance del dashboard — useMemo mal aplicado.
- Incidentes del cuaderno que esta fase puede resolver: 🟠 de performance, re-renders excesivos.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0.
- D3 JavaScript plano ES2019, sin TypeScript. JSDoc donde aporte.
- D4 Redux Toolkit 1.8.x.
- D12 Gráficos con chart.js (no recharts).
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Componentes funcionales con hooks para dashboard.
- useMemo y useCallback cuando realmente haga falta.
- Deuda técnica intencional marcada con 💸; opcionales con 🔥.
- Distinguir siempre frontend / store / epic / backend.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```

---

## Fase 10 — Testing mínimo

```
Este es el chat de redacción de la Fase 10 — Testing mínimo del tutorial
React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 10 de 11.
- Nombre: Testing mínimo.
- Horas: 6h.
- Depende de: Fase 9 — Dashboard, ya cerrada y aprobada.
- Habilita: Fase 11 — Cierre + puente a React moderno.
- Qué entra: Jest + RTL, test de slice, test de epic con marbles, test de componente.
- Qué NO entra (se difiere): e2e exhaustivo.
- Pieza forense de esta fase: Test de epic con marbles — cómo asegurar timing.
- Incidentes del cuaderno que esta fase puede resolver: 🔴 de bugs intermitentes, race conditions esquivas.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0.
- D3 JavaScript plano ES2019, sin TypeScript. JSDoc donde aporte.
- D4 Redux Toolkit 1.8.x.
- D6 Jest 26 + React Testing Library 11 + Cypress última LTS.
- D9 rxjs-marbles para marble testing de epics.
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Tests enfocados en comportamiento, no implementación.
- Marble testing con rxjs-marbles para epics.
- Deuda técnica intencional marcada con 💸; opcionales con 🔥.
- Explicar diferencia entre corrección mínima y refactorización cuando haya un fix.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```

---

## Fase 11 — Cierre + puente a React moderno

```
Este es el chat de redacción de la Fase 11 — Cierre + puente a React
moderno del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) instrucciones del proyecto, (2) tutorial-react16.md, (3)
PLAN-DEL-CURSO.md, (4) entregables aprobados de fases anteriores, (5)
decisiones de este chat.

Contexto de esta fase (ver PLAN-DEL-CURSO.md, mapa de 12 fases, y
tutorial-react16.md sección 5):
- Fase: 11 de 11. **ÚLTIMA FASE.**
- Nombre: Cierre + puente a React moderno.
- Horas: 6h.
- Depende de: Fase 10 — Testing mínimo, ya cerrada y aprobada.
- Habilita: nada (es la última).
- Qué entra: Refactor opcional con hooks puros, RTK Query mencionada, guiño a React 17-18.
- Qué NO entra: migración real, React 17-18 en código principal.
- Pieza forense de esta fase: Test de regresión que reproduce el bug antes del fix.
- Incidentes del cuaderno que esta fase puede resolver: 🔴 finales de reflexión.

Decisiones confirmadas que aplican (DECISIONES-CONFIRMADAS.md — no se
reabren en este chat):
- D1 React/React DOM 16.14.0 (punto final de referencia exacto).
- D3 JavaScript plano ES2019, sin TypeScript.
- D4 Redux Toolkit 1.8.x en código principal. RTK Query solo mencionada.
- Apéndice A8 "Puente a React moderno" es opcional y comparativo.
- D7 package-lock.json es norma; no se tocan versiones sin justificar.

Estilo del código de esta fase (GUIA-DE-ESTILO-Y-CONVENCIONES.md §5):
- Reflexión sobre el viaje de 96 horas.
- Opcional: refactor de un componente de clase a hooks.
- Opcional: comparación con React 17-18, RTK Query, RxJS 7.
- Deuda técnica 💸 que quedó; opcionales 🔥.
- Explicar diferencia entre corrección mínima y refactorización cuando haya un fix.

No hace falta preguntarme por versiones o decisiones de stack: ya están
todas confirmadas en DECISIONES-CONFIRMADAS.md. Si algo específico de esta
fase no está definido, preguntame antes de asumir.

Confirmame que tenés el contexto y quedamos listos para el Prompt B
(solicitud de redacción).
```
