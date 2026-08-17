# 🅱️ Prompts B por fase — Listos para copiar y pegar
## Tutorial React 16 — Rifas y chances

Cada prompt está listo para copiar y pegar en el chat de esa fase. Los datos ya están completados según PLAN-DEL-CURSO.md y CATALOGO-FASES-Y-APENDICES.md.

Usá el Prompt B.1 para la primera redacción. Luego usá B.2 cada vez que necesites iterar con correcciones. Finalmente usá B.3 cuando el archivo quede aprobado y listo para cerrar.

---

## Fase 0 — Setup + Hola mundo CRA

### B.1 — Primera redacción

```
Generá el archivo fase-00-setup-hola-mundo-cra.md de la Fase 0 —
Setup + Hola mundo CRA.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md:
1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué queda fuera por ahora
4. 🧠 Conceptos mínimos
5. 💻 Implementación y código comentado
6. ⚠️ Errores comunes y pieza forense
7. 🧪 Ejercicios (30 en total: ~8 🟢, ~9 🟡, ~7 🟠, ~4-6 🔴, más 🔥 aparte)
8. 📚 Referencias (oficial / libros si aplica / video / orden de lectura)
9. 🚀 Cierre y conexión con la Fase 1

Aplicá el tono y las convenciones de GUIA-DE-ESTILO-Y-CONVENCIONES.md:
cálido, informal, segunda persona, humor con moderación, prosa antes que
listas, tablas solo para comparar. Usá los callouts (📝 nota de época, 📚
referencia inline, 🪦 retiro, ⚠️ advertencia, 💡 truco) donde aporten, y
las secciones narrativas (💸 pago de deuda, detalles con intención, el
patrón a memorizar, prueba de fuego, mini-repaso, la señal de que quedó
bien) donde el contenido lo pida.

Código: ejecutable, mínimo, coherente con el stack confirmado
(DECISIONES-CONFIRMADAS.md), sin contradecir fases anteriores. Dominio:
siempre rifas y chances, cero referencia al sistema real bajo NDA.

Foco de esta fase:
- Setup en tres plataformas (Windows 11 nativo, macOS Apple Silicon con Colima, Linux).
- NVM para Node 14.21.3.
- CRA 4 con create-react-app.
- Bootstrap 4.6.2 con dart-sass.
- Primer componente funcional con hooks.
- React DevTools y Network tab básicos.

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones y 1-2 líneas por sección.
- La lista de los 3-5 "qué queda listo" propuestos.
- Los nombres de componentes nuevos que vas a introducir.

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-00-setup-hola-mundo-cra.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar en cada
punto. Si una corrección contradice una decisión ya aprobada en
DECISIONES-CONFIRMADAS.md, avisame explícitamente en vez de aplicarla
en silencio.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 0.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13 (9 secciones, tono, código ejecutable,
sin contradecir fases previas, callouts usados, 💸/🔥 marcados, 25-35
ejercicios balanceados, pieza forense e incidentes enlazados, referencias
completas, cero NDA, "señal de que quedó bien" presente).

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 0 de ⏳ a ✅.
```

---

## Fase 1 — Estructura base + Router 5

### B.1 — Primera redacción

```
Generá el archivo fase-01-estructura-base-router-5.md de la Fase 1 —
Estructura base + Router 5.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md:
1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué queda fuera por ahora
4. 🧠 Conceptos mínimos
5. 💻 Implementación y código comentado
6. ⚠️ Errores comunes y pieza forense
7. 🧪 Ejercicios (30 en total: ~8 🟢, ~9 🟡, ~7 🟠, ~4-6 🔴, más 🔥 aparte)
8. 📚 Referencias (oficial / libros si aplica / video / orden de lectura)
9. 🚀 Cierre y conexión con la Fase 2

Aplicá el tono y las convenciones de GUIA-DE-ESTILO-Y-CONVENCIONES.md:
cálido, informal, segunda persona, humor con moderación, prosa antes que
listas, tablas solo para comparar. Usá los callouts y las secciones
narrativas donde el contenido lo pida.

Código: ejecutable, mínimo, coherente con el stack confirmado, sin
contradecir la Fase 0 ya cerrada. Dominio: rifas y chances, cero NDA.

Foco de esta fase:
- React Router 5.3.x con BrowserRouter y Route.
- useHistory, useLocation, useParams hooks de router.
- Layout y navbar con Bootstrap.
- Class components legacy + functional components con hooks conviviendo.
- Componentes de página: RifasList, RifaDetail.

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones y 1-2 líneas por sección.
- La lista de los 3-5 "qué queda listo" propuestos.
- Los nombres de componentes nuevos (RifasList, RifaDetail, Layout, Navbar, etc.).

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-01-estructura-base-router-5.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar en cada
punto. Si una corrección contradice la Fase 0 ya cerrada, avisame
explícitamente en vez de aplicarla en silencio.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 1.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13.

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 1 de ⏳ a ✅.
```

---

## Fase 2 — Autenticación mínima

### B.1 — Primera redacción

```
Generá el archivo fase-02-autenticacion-minima.md de la Fase 2 —
Autenticación mínima.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md:
1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué queda fuera por ahora
4. 🧠 Conceptos mínimos
5. 💻 Implementación y código comentado
6. ⚠️ Errores comunes y pieza forense
7. 🧪 Ejercicios (30 en total: ~8 🟢, ~9 🟡, ~7 🟠, ~4-6 🔴, más 🔥 aparte)
8. 📚 Referencias
9. 🚀 Cierre y conexión con la Fase 3

Código: ejecutable, mínimo, coherente con el stack confirmado, sin
contradecir Fases 0-1 ya cerradas. Dominio: rifas y chances, cero NDA.

Foco de esta fase:
- Redux Toolkit slice para auth.
- Login mock (sin backend real).
- Interceptor axios: request-id, autorización.
- PrivateRoute con React Router.
- Componente LoginForm funcional con hooks.

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones.
- La lista de los 3-5 "qué queda listo" propuestos.
- Nombres de slice, acciones, componentes.

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-02-autenticacion-minima.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice Fases 0-1 ya cerradas, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 2.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13.

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 2 de ⏳ a ✅.
```

---

## Fase 3 — Mock API + Express caos

### B.1 — Primera redacción

```
Generá el archivo fase-03-mock-api-express-caos.md de la Fase 3 —
Mock API + Express caos.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md.

Código: ejecutable, mínimo, coherente con el stack confirmado, sin
contradecir Fases 0-2 ya cerradas. Dominio: rifas y chances, cero NDA.

Foco de esta fase:
- json-server con db.json para CRUD básico.
- Express middleware caos: latencia, errores 5xx, timeouts.
- Mock API de lotería separada.
- Cómo inyectar fallos para reproducir bugs.

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones.
- La lista de los 3-5 "qué queda listo" propuestos.

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-03-mock-api-express-caos.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice Fases 0-2 ya cerradas, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 3.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13.

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 3 de ⏳ a ✅.
```

---

## Fase 4 — Rifas CRUD

### B.1 — Primera redacción

```
Generá el archivo fase-04-rifas-crud.md de la Fase 4 — Rifas CRUD.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md.

Código: ejecutable, mínimo, coherente con el stack confirmado, sin
contradecir Fases 0-3 ya cerradas. Dominio: rifas y chances, cero NDA.

Foco de esta fase:
- Redux Toolkit slice para rifas.
- createAsyncThunk para fetch, create, update, delete.
- Tabla de rifas con Bootstrap.
- Formulario de crear/editar rifa.
- Componentes funcionales con hooks + useDispatch, useSelector.

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones.
- La lista de los 3-5 "qué queda listo" propuestos.
- Nombres de slice, acciones, componentes.

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-04-rifas-crud.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice Fases 0-3 ya cerradas, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 4.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13.

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 4 de ⏳ a ✅.
```

---

## Fase 5 ⭐ — Venta de números

### B.1 — Primera redacción

```
Generá el archivo fase-05-venta-de-numeros.md de la Fase 5 —
Venta de números. FASE CENTRAL ⭐ DE 12 HORAS.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md.

Código: ejecutable, mínimo, coherente con el stack confirmado, sin
contradecir Fases 0-4 ya cerradas. Dominio: rifas y chances, cero NDA.

Foco de esta fase (la más grande y con más incidentes):
- Tablero visual 0000-9999 con estado de cada número.
- Slice Redux para números y reservas.
- Reserva temporal (5-10 min): número → reservado → vendido | disponible.
- Race condition: dos clientes compran el mismo número al mismo tiempo.
- Transacción atómica del lado del servidor (mock).
- Manejo de optimistic updates y rollback.

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones.
- La lista de los 3-5 "qué queda listo" propuestos.
- Nombres de slice, acciones (venderNumero, reservarNumero, etc.).
- Estructura de componentes (NumerosTablero, NumerosCard, etc.).

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-05-venta-de-numeros.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice Fases 0-4 ya cerradas, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 5.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13.

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 5 de ⏳ a ✅.
```

---

## Fase 6 ⭐ — redux-observable a fondo

### B.1 — Primera redacción

```
Generá el archivo fase-06-redux-observable-a-fondo.md de la Fase 6 —
redux-observable a fondo. FASE CENTRAL ⭐ DE 12 HORAS.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md.

Código: ejecutable, mínimo, coherente con el stack confirmado, sin
contradecir Fases 0-5 ya cerradas. Dominio: rifas y chances, cero NDA.

Foco de esta fase (conceptualmente la más densa — fuente de bugs más difícil):
- Epics con redux-observable 1.2.0 y RxJS 6.6.7.
- .pipe() y operadores: map, mergeMap, switchMap, debounce, throttle, retry, catchError, takeUntil.
- Cancelación de epics al logout o desmontar.
- Memory leak por suscripción sin cancelación.
- Pattern matching con ofType.
- Epic de validación de número en tiempo real.
- Epic de reintento automático al fallar.

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones.
- La lista de los 3-5 "qué queda listo" propuestos.
- Nombres de epics que vamos a introducir (validarNumeroEpic, reintentoEpic, etc.).

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-06-redux-observable-a-fondo.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice Fases 0-5 ya cerradas, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 6.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13.

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 6 de ⏳ a ✅.
```

---

## Fase 7 — Cierre + polling resultado

### B.1 — Primera redacción

```
Generá el archivo fase-07-cierre-polling-resultado.md de la Fase 7 —
Cierre + polling resultado.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md.

Código: ejecutable, mínimo, coherente con el stack confirmado, sin
contradecir Fases 0-6 ya cerradas. Dominio: rifas y chances, cero NDA.

Foco de esta fase:
- Cierre a hora dura (no se permite venta después de una timestamp exacta).
- Zona horaria: considerar offset UTC.
- Epic de polling a mock API de lotería.
- Intervalo configurable, reintentos, backoff exponencial.
- Cancelación de polling al cerrar la rifa o logout.

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones.
- La lista de los 3-5 "qué queda listo" propuestos.
- Nombres de slice/acciones/epics nuevos.

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-07-cierre-polling-resultado.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice Fases 0-6 ya cerradas, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 7.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13.

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 7 de ⏳ a ✅.
```

---

## Fase 8 — Liquidación + cálculo de premio

### B.1 — Primera redacción

```
Generá el archivo fase-08-liquidacion-calculo-premio.md de la Fase 8 —
Liquidación + cálculo de premio.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md.

Código: ejecutable, mínimo, coherente con el stack confirmado, sin
contradecir Fases 0-7 ya cerradas. Dominio: rifas y chances, cero NDA.

Foco de esta fase:
- Dinero en enteros (centavos), nunca floats.
- Cálculo de premio: fracción exacta del número ganador.
- Margen del organizador.
- Redondeo exacto sin floats: métodos Math.floor, Math.round con cuidado.
- Slice Redux para liquidación.
- Cierre de rifa irreversible.

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones.
- La lista de los 3-5 "qué queda listo" propuestos.
- Nombres de slice/acciones nuevas.

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-08-liquidacion-calculo-premio.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice Fases 0-7 ya cerradas, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 8.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13.

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 8 de ⏳ a ✅.
```

---

## Fase 9 — Dashboard

### B.1 — Primera redacción

```
Generá el archivo fase-09-dashboard.md de la Fase 9 — Dashboard.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md.

Código: ejecutable, mínimo, coherente con el stack confirmado, sin
contradecir Fases 0-8 ya cerradas. Dominio: rifas y chances, cero NDA.

Foco de esta fase:
- Gráficos con chart.js.
- KPIs: números más vendidos, margen por rifa, tasa de venta, participantes recurrentes.
- Componentes funcionales con hooks.
- useMemo para optimizar cálculos.
- Selectores de Redux para agregar datos.

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones.
- La lista de los 3-5 "qué queda listo" propuestos.
- Nombres de componentes (DashboardKPI, GraficoVentas, etc.).

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-09-dashboard.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice Fases 0-8 ya cerradas, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 9.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13.

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 9 de ⏳ a ✅.
```

---

## Fase 10 — Testing mínimo

### B.1 — Primera redacción

```
Generá el archivo fase-10-testing-minimo.md de la Fase 10 — Testing
mínimo.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md.

Código: ejecutable, mínimo, coherente con el stack confirmado, sin
contradecir Fases 0-9 ya cerradas. Dominio: rifas y chances, cero NDA.

Foco de esta fase:
- Jest 26 + React Testing Library 11 para unitarios y componentes.
- Test de slice: acciones, reducers, estado.
- Test de componente: renderizado, interacción.
- Test de epic con rxjs-marbles: timing, operadores, cancelación.
- Cypress para smoke tests (happy path).

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones.
- La lista de los 3-5 "qué queda listo" propuestos.
- Ejemplos de tests concretos a incluir.

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-10-testing-minimo.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice Fases 0-9 ya cerradas, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 10.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13.

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 10 de ⏳ a ✅.
```

---

## Fase 11 — Cierre + puente a React moderno

### B.1 — Primera redacción

```
Generá el archivo fase-11-cierre-puente-react-moderno.md de la Fase 11
— Cierre + puente a React moderno. ÚLTIMA FASE.

Seguí exactamente la plantilla de 9 secciones de PLANTILLA-DE-FASE.md.

Código: ejecutable, mínimo, coherente con el stack confirmado, sin
contradecir Fases 0-10 ya cerradas. Dominio: rifas y chances, cero NDA.

Foco de esta fase (reflexión y cierre):
- Recuento de 96 horas: qué aprendimos sobre mantenimiento de legacy.
- Opcional: refactor de un componente de clase a hooks puros.
- Opcional: reemplazo de connect() por useSelector/useDispatch.
- Guiño a React 17-18, RTK Query, RxJS 7 — solo comparativo, sin código principal.
- Apéndice A8 "Puente a React moderno" es recurso complementario.

Antes de escribir el archivo completo, mostrame:
- Un esqueleto con los títulos de las 9 secciones.
- La lista de los 3-5 "qué queda listo" propuestos.
- Componentes/slices que vas a usar de ejemplo para refactor opcional.

Esperá mi aprobación de ese esqueleto antes de generar el .md completo.
```

### B.2 — Iterar con correcciones

```
Sobre el archivo fase-11-cierre-puente-react-moderno.md que generaste:

Corregí lo siguiente sin reescribir lo que ya está aprobado:
- {{sección o línea afectada}}: {{qué está mal o qué falta}}.
- {{...}}

Mantené sin cambios: {{secciones que ya quedaron bien}}.

Antes de reescribir, confirmame en una línea qué vas a cambiar. Si una
corrección contradice Fases 0-10 ya cerradas, avisame explícitamente.

Cuando quede aprobado, generá la versión final completa del archivo.
```

### B.3 — Cierre de la fase

```
Este archivo queda aprobado como versión final de la Fase 11.

Antes de darlo por cerrado, verificá contra el checklist de
GUIA-DE-ESTILO-Y-CONVENCIONES.md §13.

Decime si algo del checklist no se cumple. Si todo está en orden, entregá
el archivo final y recordame actualizar CATALOGO-FASES-Y-APENDICES.md:
Fase 11 de ⏳ a ✅.
```
