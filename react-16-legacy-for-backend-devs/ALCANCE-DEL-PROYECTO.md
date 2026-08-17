# 🎯 Alcance del proyecto
## Tutorial React 16 — Rifas y chances

Documento de encuadre. Define qué es este proyecto, para quién, qué
produce y —tan importante— qué **no** hace. Se lee antes de escribir
cualquier fase.

---

## 1. En una frase

Un tutorial práctico de **96 horas** que prepara a desarrolladores senior
para **mantener, depurar y hacer hotfixes** en una aplicación React 16
heredada, real y en producción — sin reescribirla.

---

## 2. El problema que resuelve

Un equipo de Maintenance hereda un sistema construido entre 2019 y 2023.
El sistema real está bajo NDA, así que todo el tutorial usa un dominio
**proxy**: una plataforma de **rifas y chances**. El código proxy imita
fielmente las características que hacen difícil el sistema real:

- Class components pre-16.8 conviviendo con hooks post-16.8.
- Redux Toolkit junto a `connect()` clásico.
- Epics de `redux-observable` con RxJS — la fuente de bugs más difícil.
- Bootstrap 4 + Sass con un mini design system propio.
- Create React App con Webpack oculto.

El estudiante no aprende a *escribir* React idiomático moderno. Aprende a
*leer, entender y arreglar* un producto existente.

---

## 3. Objetivo pedagógico (lo que el estudiante sabrá hacer)

Al terminar, el estudiante puede:

- Leer código legacy mezclado (clases + hooks) sin confundirse.
- Detectar y reproducir bugs en cualquier capa: componente, store, epic, backend.
- Depurar código productivo, incluso minificado, con source maps.
- Comparar ambientes (desarrollo, UAT, producción) y explicar por qué algo "funciona en UAT pero no en PROD".
- Entender epics de `redux-observable`: cancelación, race conditions, memory leaks.
- Resolver hotfixes con el menor riesgo posible.
- Distinguir una corrección mínima de una refactorización.
- Escribir pruebas de regresión y post-mortems que sirvan.

Lo que **NO** es objetivo: formar arquitectos de React, promover patrones
modernos idealizados, ni migrar el sistema. La modernización aparece solo
como comparación o fase opcional 🔥.

---

## 4. Perfil del estudiante

Se asume un desarrollador **backend o full-stack senior**:

- Domina JavaScript, HTML, CSS, HTTP, JSON, autenticación, APIs REST.
- Puede conocer React moderno, pero no necesariamente class components.
- No domina necesariamente RxJS, Observables ni marble testing.
- Necesita mantener un producto, no reescribirlo.

No se gasta espacio explicando lo que este perfil ya sabe. El salto
conceptual real está en **RxJS/epics** y en **leer código de transición**.

---

## 5. El dominio proxy: rifas y chances

La aplicación administra rifas, números (disponibles / reservados /
vendidos), participantes, resultados de una lotería simulada, liquidaciones
y un dashboard.

**Flujo de estados de una rifa:**

```
borrador → abierta → cerrada → resuelta → liquidada
```

**Reglas de negocio (que son también las fuentes de bug):**

- Un mismo número no puede venderse dos veces (race condition inevitable).
- Las reservas deben expirar correctamente.
- No se vende después de la hora de cierre (hora dura + zona horaria).
- Las fechas consideran timezone y cambios de día (medianoche).
- Los resultados se consultan por polling (la lotería tarda variable).
- El polling debe detenerse al cerrar, desmontar o cerrar sesión.
- Los cálculos monetarios no usan floats.
- Toda operación relevante conserva trazabilidad.

Este dominio se eligió porque cualquiera entiende una rifa (curva de
dominio nula) y porque concentra concurrencia, tiempo, dinero y
reactividad en un espacio que cabe holgado en 96 horas.

---

## 6. Estructura del proyecto Claude

Un solo proyecto que hospeda **~24 chats**, cada uno productor de **un
archivo `.md` entregable**:

- 1 chat maestro → `PLAN-DEL-CURSO`.
- 12 chats de fase → `fase-NN-slug.md`.
- 8 chats de apéndice → `apendice-slug.md`.
- 1 chat de track forense → `forense-*.md`.
- 1 chat de cuaderno de incidentes → `cuaderno-incidentes.md` + fichas.
- 1 chat de smoke + regresión → `smoke-tests.md`, `regresion-*.md`.
- 1 chat "sala de dudas" → sin entregable fijo.

Total: **~50–60 archivos `.md`**.

---

## 7. Lo que está dentro del alcance

- 12 fases (0-11) que suman exactamente 96 horas.
- Track forense integrado en cada fase.
- 15-20 incidentes con post-mortem (mínimo 4 de RxJS/epics).
- Apéndices de consulta rápida.
- Testing mínimo: unitario (Jest/RTL), epics (marbles), smoke (Playwright/Cypress).
- Setup multiplataforma con workarounds reales (Windows, Linux, macOS Apple Silicon).

---

## 8. Lo que está fuera del alcance

- Reescritura o migración real del sistema.
- React 17/18, React Router 6, RTK moderno o RxJS 7 en el código principal (solo como comparación o fase opcional).
- Pasarela de pago real, BI real, e2e exhaustivo.
- Cualquier referencia al dominio real bajo NDA.
- Roles y permisos avanzados, refresh tokens, i18n (a menos que se justifique).

Si algo interesante aparece fuera de alcance, se registra como **pendiente**
y se recomienda ubicarlo en un apéndice, incidente, fase posterior o
ejercicio 🔥. No se infla la fase actual.

---

## 9. Restricciones de versiones (no negociables sin justificar)

- Node.js 14.21.3, npm 6.
- React / React DOM 16.14.0.
- CRA y react-scripts 4.0.3.
- Redux 4.1.x, Redux Toolkit 1.6.x/1.8.x, React-Redux 7.2.x.
- redux-observable 1.2.0, RxJS 6.6.7.
- React Router 5.x, axios 0.21.4.
- Bootstrap 4.6.2, Sass (dart-sass).
- json-server 0.16.x + Express caos propio.
- Jest 26, React Testing Library 11.
- Playwright o Cypress (última LTS) para smoke.

Cuando una versión no esté confirmada con el sistema real, se declara
**pendiente** en lugar de asumirla. Ver `DECISIONES-PENDIENTES`.

---

## 10. Criterios de éxito del proyecto

El tutorial funciona si un estudiante que lo completa puede:

1. Clonar el repo, levantar el ambiente (en su plataforma) y correr la app.
2. Recibir un ticket, reproducir el bug y localizar la capa responsable.
3. Escribir el post-mortem y el test de regresión antes del fix.
4. Aplicar el hotfix mínimo sin romper nada más.
5. Explicar por qué un epic tenía un memory leak y cómo lo corrigió.

Si el estudiante sale sabiendo *arreglar sin miedo*, el proyecto cumplió.
