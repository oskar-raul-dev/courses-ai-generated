# 🗺️ Fase 00 — Plan del curso, alcance y proyecto Mini Jira

## 🎯 De qué va este curso

Este es un curso práctico de **Vue 2 legacy (época 2018–2021)** pensado para
desarrolladores backend con algo de frontend que necesitan entrar rápido a una
base de código heredada.

No vamos a aprender "el Vue moderno". Vamos a aprender el Vue que te vas a
encontrar cuando te asignen mantener un sistema interno escrito hace 5 años:

- Options API clásica
- Vue CLI + Webpack (oculto)
- Vue Router 3 y Vuex 3
- axios con interceptores
- Bootstrap 4 y jQuery dando vueltas por ahí
- mocks locales en vez de backend real
- y, muy probablemente, **un framework encima**: Quasar, Vuetify o Nuxt

**Filosofía del curso:** en cada fase se hace *lo mínimo necesario*, pero con
forma de proyecto real. Menos código, más intención.

---

## 🏛️ La arquitectura del curso: tronco y rutas

El curso tiene **dos niveles**, y conviene entenderlo antes de empezar:

```
🌳 TRONCO (F0–F11) — obligatorio
   Vue 2 a pelo. Sin framework de UI encima. Todo lo escribes tú.

🔀 RUTAS (Q / VU / NX) — opcionales y EXCLUYENTES entre sí
   Qué pasa cuando encima del Vue hay un framework.
```

**Por qué en ese orden.** Si empiezas por Quasar nunca vas a saber qué es Vue y
qué es Quasar. Vas a copiar `QTable` sin entender qué está haciendo por ti — y el
día que se rompa, no sabrás dónde mirar. El tronco te obliga a **escribir a mano**
el filtro, el orden y la paginación. Después, cuando el framework te los borre de
un plumazo, **sabrás exactamente qué acabas de perder** y por qué el componente y
tu Vuex se están peleando por el mismo estado.

> El tronco enseña **Vue**. Las rutas enseñan **el framework**.
> Es imposible aprender lo segundo sin lo primero.

Las rutas **no se acumulan**: eliges una, idealmente la que use tu empresa. La
estructura completa (grafo de dependencias, reglas de exclusión, notas de
producción) está en **`ESTRUCTURA-CURSO.md`**.

---

## 🧑‍💻 Perfil del estudiante

- Backend con experiencia (Java, .NET, Node, Python, lo que sea)
- Sabe HTML/CSS/JS básico
- No necesita que le expliquen qué es HTTP, JSON o un token
- Quiere autonomía: pasos concretos + enlaces para profundizar por su cuenta

---

## 🏗️ El proyecto: Mini Jira (mesa de soporte)

Durante todo el curso construiremos una **mesa de soporte interna** estilo
mini-Jira. Es el hilo conductor de todas las fases — **y de las rutas**, que lo
migran pieza a pieza.

### Funcionalidad final (tronco)

- Login mock con sesión persistida
- Dashboard con listado de tickets, filtros y badges de estado
- CRUD completo de tickets con validación
- Wizard de creación de ticket en 3 pasos
- Métricas simples con gráficos
- Notificaciones en vivo por WebSocket
- Panel de agente de soporte (cola, asignación, comentarios)

### Funcionalidad final (si haces una ruta)

Un **híbrido**: el dashboard y el CRUD reescritos con el framework, el resto
todavía en Bootstrap. **Eso no es una carencia — es un legacy real a medio
migrar.** Y ahí es donde vas a trabajar.

*(Excepto en Nuxt, donde el proyecto se reconstruye entero sobre otro modelo de
ejecución. Ver `NUXT-FASES.md`.)*

### Modelo de datos de referencia

```json
{
  "tickets": [
    {
      "id": 1,
      "title": "La impresora no imprime",
      "description": "Otra vez.",
      "status": "open",
      "priority": "high",
      "assignee": "agente1",
      "reporter": "usuario1",
      "createdAt": "2020-03-10T10:00:00Z"
    }
  ],
  "users": [
    { "id": 1, "username": "admin", "name": "Usuario Demo", "role": "agent" }
  ],
  "comments": [
    { "id": 1, "ticketId": 1, "author": "agente1", "body": "¿Probaste apagarla y prenderla?" }
  ]
}
```

Estados de ticket: `open` → `in_progress` → `resolved` → `closed`.
Prioridades: `low`, `medium`, `high`.

Este modelo crece poco a poco; no hace falta memorizarlo ahora. **Las rutas le
añaden una colección más** (`activity`), para el timeline de X4.

---

## 🧱 Stack unificado del curso

> ⚠️ Estas versiones son **las oficiales del curso**. Si un capítulo dice otra
> cosa, gana esta tabla.

### Tronco (F0–F11)

| Herramienta | Versión | Nota |
|---|---|---|
| Node.js | **14.21.3** (16.20.2 en macOS Apple Silicon) | Documentada en `.nvmrc` |
| Vue | **2.6.14** | Última 2.6; el Vue real de las bases 2018–2021 |
| vue-template-compiler | **2.6.14** | Siempre igual a la versión de Vue |
| Vue CLI | 3.x | Modo clásico |
| Vue Router | 3.x | Desde Fase 1 |
| Vuex | 3.x | Base en Fase 1, refactor en Fase 10 |
| axios | 0.21.1 | Cliente HTTP |
| Bootstrap | 4.6.2 | Maquetación rápida |
| jQuery / popper.js | 3.6.0 / 1.16.1 | Solo para componentes JS de Bootstrap |
| lodash | 4.17.21 | Utilidades |
| vuelidate | 0.7.7 | Se instala en Fase 0, se usa en serio en Fase 5 |
| stubby | última | Mock **solo en Fase 0** |
| json-server | 0.16.x | Mock API oficial **desde Fase 3** |
| chart.js | 2.9.x | Métricas en Fase 7 |
| socket.io | 2.x | WebSockets en Fase 8 |
| Jest + vue-test-utils | 26.x / 1.x | Testing en Fase 11 |

### Rutas (solo si eliges una)

| Ruta | Paquete | Versión | Por qué esa |
|---|---|---|---|
| 🅠 **Q** | `quasar` + `@quasar/app` | **1.22.x** | Última v1. Vue 2.6 + Options API. v2 es Vue 3 → fuera |
| 🅥 **VU** | `vuetify` + `vue-cli-plugin-vuetify` | **2.6.x** | Última v2. v3 es Vue 3 → fuera |
| 🅝 **NX** | `nuxt` + `@nuxtjs/axios` | **2.15.x** | Última v2. Nuxt 3 es Vue 3 → fuera. **EOL desde junio 2024** — y eso lo hace *más* relevante para un curso de legacy, no menos |

**Se mantiene siempre:** vue 2.6.14, vuex 3, axios 0.21.1, **bootstrap 4.6.2**
(convivencia, no se jubila), socket.io-client 2.4, json-server.

**Sale del proyecto en Q2 / VU2:** `vuelidate` → lo reemplaza `:rules`. 💸

### 🔁 Regla de los mocks (importante)

- **Fase 0:** usamos **Stubby** en el puerto `8888` porque es lo más rápido para
  un Hello World.
- **Fase 3:** Stubby **se retira formalmente** y entra **json-server** en el
  puerto `3000` como Mock API oficial del resto del curso.
- Por eso `apiClient.js` apunta a `localhost:3000` desde la Fase 2: ya queda
  listo para la transición.
- **json-server sobrevive a las rutas.** El backend no cambia porque cambies el
  framework de UI. *(En NX3 sí da guerra: dos `baseURL` distintas, servidor y
  cliente. 💸)*

---

## 🪜 Mapa de fases — Tronco (obligatorio)

| Fase | Nombre | Qué entra | Qué NO entra | Se usa después en |
|---|---|---|---|---|
| 🛠️ **0** | Setup + Hola Mundo | NVM, Vue CLI, deps, vista + form + POST a Stubby | router, vuex, estructura completa | — |
| 🏗️ **1** | Estructura base legacy | carpetas, layout, router, vistas placeholder, services/store preparados | auth, API real, CRUD | todo |
| 🔐 **2** | Autenticación mínima | login mock, localStorage, guard, interceptor, logout | backend real, refresh token, roles | Q1 (boot), NX1 (plugins), **NX2 (se rompe)** |
| 🧪 **3** | Mock API mínima | json-server, `db.json`, ticketService real, login async | backend propio, paginación server-side | todo |
| 📋 **4** | Dashboard de tickets | tabla Bootstrap, badges, filtro con computed, loading/error | edición, ordenamiento avanzado | **Q3 / VU3 / NX2** |
| 📝 **5** | CRUD de tickets | crear/editar/eliminar, vuelidate en serio, confirmación | permisos, soft-delete, optimistic UI | **Q2 / VU2** |
| 🪜 **6** | Wizard | alta de ticket en 3 pasos, estado local vs store | librerías de wizard, drafts en server | ejercicio 🔴 de X4 |
| 📊 **7** | Métricas | chart.js 2.x, tickets por estado y por agente | BI real, agregaciones server-side | **NX2 (se rompe: necesita `window`)** |
| 💬 **8** | WebSockets | socket.io 2.x, mini servidor Node, notificación en vivo | reconexión robusta, salas, escalado | **X4 (alimenta el timeline)** |
| 🎧 **9** | Panel de soporte | vista de agente: cola, asignación, comentarios (integra todo) | SLA, colas por prioridad reales | ejercicio 🔴 de X3 |
| 🗂️ **10** | Vuex a fondo | refactor consciente: qué migrar al store y qué no | Pinia, patrones enterprise | **X3 — el conflicto central** |
| ✅ **11** | Testing mínimo | Jest, un test de componente / store / servicio | e2e, coverage alto, CI | **X0 — prerequisito duro** |

> ⚠️ **Ninguna fase del tronco se puede saltar si vas a hacer una ruta.** F10 y
> F11 en particular son los cimientos: sin Vuex no entiendes por qué `QTable` y
> tu store se pelean; sin testing no puedes escribir la red de seguridad, y sin
> red **no se migra nada**.

### 📎 Apéndices (consulta rápida, no secuenciales)

1. 🎨 **Bootstrap 4** — grid, cards, tablas, forms, utilidades
2. 🟢 **Node** — lo mínimo para sobrevivir al tooling
3. 📦 **npm** — dependencies vs devDependencies, lockfile, scripts
4. 🌐 **axios** — instancia, interceptores, manejo de errores
5. ⚙️ **Webpack y Babel** — qué hace Vue CLI por debajo

---

## 🔀 Rutas opcionales (después de F11 — elige **una**)

Arrancan con el Mini Jira **terminado a pelo**. Las tres tienen 5 fases (X0 → X4)
y **son excluyentes**: se elige una, no se acumulan.

| Ruta | Framework | Naturaleza | Qué te cambia |
|---|---|---|---|
| 🅠 **Q** | Quasar 1.22 | Framework de UI **+ build system** | Se come el proyecto: no hay `main.js`, hay `quasar.conf.js` y boot files |
| 🅥 **VU** | Vuetify 2.6 | Framework de UI (plugin de Vue CLI) | **No** se come el proyecto. Pero el **theming vive en JS**, y el bundle se te va a 500kb |
| 🅝 **NX** | Nuxt 2.15 | **Meta-framework SSR** | Tu componente se ejecuta en un Node **sin `window`**, y luego otra vez en el navegador. Modelo mental nuevo |

### El esquema común (Q y VU)

| Fase | Qué hace |
|---|---|
| 🛡️ **X0** | **Red de seguridad.** Tests de regresión sobre el código que vas a borrar |
| 📖 **X1** | **Leer el framework.** Sin migrar nada. Reconocimiento puro |
| 📝 **X2** | **Migrar el CRUD** (F5) al form del framework. Y **vuelidate sale del proyecto** |
| 📋 **X3** | **Migrar el dashboard** (F4) a la tabla del framework. **El conflicto con Vuex (F10)** |
| 🕒 **X4** | **Crear** el timeline de actividad. Framework puro, sin traducir nada |

### Dónde se rompe el esquema (NX)

**Nuxt no es un framework de UI.** No hay `NxTable` ni `NxForm`; "migrar el CRUD a
Nuxt" no significa nada — el formulario se queda igual. Lo que cambia es **dónde
se ejecuta el código**. Por eso NX2 y NX3 tienen temas propios:

| | Q / VU | **NX** |
|---|---|---|
| **X2** | Migrar CRUD | 💥 **Hidratación y `window is not defined`** |
| **X3** | Migrar dashboard | 🔄 **`asyncData` vs Vuex** |

### ⚖️ Cuál elegir

> **La que use tu empresa.** Es un curso de mantenimiento, no de arquitectura.

Si no usa ninguna, el tronco ya te dejó donde tenías que estar. Si te sobra
tiempo y quieres la que **más te cambia la cabeza**, es **NX**: Q y VU son "mismo
Vue, otros componentes"; Nuxt es otro modelo de ejecución.

Detalle de cada una: `QUASAR-FASES.md` · `VUETIFY-FASES.md` · `NUXT-FASES.md`

---

## 📐 Plantilla de cada capítulo

Todos los capítulos siguen la misma estructura — **también los de las rutas** —
para que puedas estudiar una fase en poco tiempo y usar el documento como
referencia después:

1. 🎯 Propósito
2. ✅ Qué queda listo al terminar
3. 🚫 Qué NO entra todavía
4. 🧠 Concepto mínimo (la teoría justa)
5. 💻 Código mínimo con comentarios didácticos
6. ⚠️ Errores comunes
7. 🧪 Ejercicios (20–30, de fácil a muy difícil)
8. 📚 Referencias (oficiales primero)
9. 🚀 Cierre

---

## 🧭 Convenciones del curso

- **Nomenclatura:** el tronco se llama **Fase N**; las rutas, **Q0–Q4 / VU0–VU4 /
  NX0–NX4**. Cuando algo aplica a las tres rutas, se escribe **X0…X4**.
- **Options API siempre.** Nada de Composition API, Pinia, Vite ni TypeScript.
  **Tampoco en las rutas** — Quasar 1, Vuetify 2 y Nuxt 2 son Vue 2.
- **`function () {}` en vez de arrow functions** dentro de componentes, para
  mantener el sabor de la época y evitar sorpresas con `this`.
- **Estructura fija de carpetas** desde la Fase 1: `views/`, `components/`,
  `router/`, `services/`, `store/`. *(Las rutas la rompen — y esa ruptura es
  contenido: `src/boot/` en Quasar, `pages/` y `plugins/` en Nuxt.)*
- **Deuda técnica explícita:** cuando dejemos algo "mal a propósito" (pasa en
  proyectos legacy reales), lo marcamos con 💸 y decimos en qué fase se paga.
- **Bootstrap no se jubila.** Aunque entres a una ruta, Bootstrap 4 sigue cargado
  y **conviviendo** con el framework nuevo. Sí, se pisan los estilos. Sí,
  funcionan juntos. Eso es un legacy real y es contenido explícito de X3.

---

## 🧪 Autodiagnóstico inicial (20 preguntas)

No es un examen: si fallas varias, los apéndices existen para eso.

**🟢 Básico (1–8)**
1. ¿Qué diferencia hay entre `npm install` y `npm install -g`?
2. ¿Qué es `package-lock.json` y por qué se versiona?
3. ¿Qué hace `node -v`?
4. ¿Qué es el DOM?
5. ¿Qué diferencia hay entre `let`, `const` y `var`?
6. ¿Qué devuelve una llamada `fetch` o `axios.get`?
7. ¿Qué es un status HTTP 401 y en qué se diferencia del 403?
8. ¿Qué es JSON y cómo se parsea en JS?

**🟡 Intermedio (9–15)**
9. ¿Qué es una SPA y en qué se diferencia de un sitio multipágina?
10. ¿Qué problema resuelve un bundler como Webpack?
11. ¿Para qué sirve Babel?
12. ¿Qué es `this` en una función normal vs una arrow function?
13. ¿Qué es una Promise y qué hace `.then` / `.catch`?
14. ¿Qué es `localStorage` y cuándo se borra?
15. ¿Qué es un header `Authorization: Bearer ...`?

**🟠 Avanzado (16–20)**
16. ¿Qué es data binding bidireccional?
17. ¿Qué es un componente y qué son sus props?
18. ¿Por qué el estado global compartido puede ser un problema?
19. ¿Qué riesgos tiene guardar un token en localStorage?
20. ¿Qué es XSS en una frase?

Si respondes cómodo del 1 al 15, estás listo para la Fase 0.

### 🔀 Autodiagnóstico de ruta (solo si vas a hacer una)

No lo respondas ahora: **respóndelo al terminar F11.** Si no puedes, vuelve al
tronco.

1. ¿Por qué un test que busca `.b-table` es un **mal** test de regresión?
2. Tu store de F10 tiene el filtro y la página actual. Si el componente de tabla
   también los quiere, **¿quién debería mandar y por qué?**
3. `mounted()` toca el DOM. **¿Qué pasa si ese componente se renderiza en un
   servidor Node?**
4. Si sacas vuelidate del proyecto, **¿qué pierdes exactamente?** (No "nada".)

---

## 🚀 Cómo estudiar el curso

1. Lee la Fase 0 y deja el ambiente funcionando (≈30 min).
2. Avanza una fase por sesión de estudio; cada una está pensada para ser corta.
3. Haz al menos los ejercicios 🟢 y 🟡 de cada fase antes de seguir.
4. Usa los apéndices como consulta, no como lectura obligatoria.
5. Al terminar la Fase 9 ya tienes un sistema completo; las Fases 10 y 11 son
   de calidad y refactor — **y son las que más te van a servir después**.
6. **Después de F11**, decide: ¿tu empresa usa Quasar, Vuetify o Nuxt? Haz **esa**
   ruta. ¿No usa ninguna? Has terminado.

La señal de éxito del curso no es "terminé todos los capítulos", sino:

> "me sueltan en una base Vue 2 real y sé dónde vive cada cosa,
> qué tocar y qué no romper".

Y si hiciste una ruta, hay una segunda:

> "me sueltan en una base Vue 2 **con un framework encima** y sé distinguir
> qué es Vue, qué es el framework, y **qué me está haciendo por debajo** —
> incluido lo que me está quitando sin avisar".
