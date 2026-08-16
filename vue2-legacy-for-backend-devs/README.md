# 📘 Curso Vue 2 Legacy — Mini Jira

Curso práctico de **Vue 2 legacy (2018–2021)** para desarrolladores backend que
necesitan entrar rápido a una base de código heredada.

Proyecto hilo conductor: **Mini Jira**, una mesa de soporte interna.

El curso tiene **dos niveles**:

- 🌳 **Tronco (F0–F11)** — obligatorio, secuencial. Vue 2 **a pelo**.
- 🔀 **Rutas (Q / VU / NX)** — opcionales y **excluyentes entre sí**. Qué pasa
  cuando encima del Vue hay **Quasar, Vuetify o Nuxt**.

> El tronco enseña **Vue**. Las rutas enseñan **el framework**.
> No se puede lo segundo sin lo primero: si empiezas por Quasar, nunca sabrás qué
> es Vue y qué es Quasar.

---

## 📂 Contenido del paquete

### 🧭 Documentos maestros

| Archivo | Qué es |
|---|---|
| `FASES.md` | 📑 **Índice del curso** — empieza aquí |
| `ESTRUCTURA-CURSO.md` | 🗺️ **Arquitectura**: qué es obligatorio, qué opcional, grafo de dependencias, reglas de exclusión |
| `0-plan-del-curso.md` | 🗺️ Plan, alcance, stack unificado, convenciones y autodiagnóstico |
| `RESUMEN-ALCANCE-VUE2.md` | 📄 Resumen ejecutivo (contexto para otros proyectos) |

### 🌳 Tronco — Fases (obligatorias, en orden)

| Archivo | Qué es |
|---|---|
| `00-setup-hola-mundo.md` | 🛠️ **Fase 0** — Node/NVM, disección de npm y package.json, editores (VS Code / WebStorm), lineamientos de código, YAML/Stubby y Hello World explicado idea por idea |
| `01-estructura-base-legacy.md` | 🏗️ Fase 1 — Estructura de carpetas, layout, router |
| `02-autenticacion-minima.md` | 🔐 Fase 2 — Login mock, guard, interceptor, logout |
| `03-mock-api-minima.md` | 🧪 Fase 3 — json-server, servicios HTTP, login asíncrono |
| `04-dashboard-tickets.md` | 📋 Fase 4 — Tabla, badges, filtros con computed |
| `05-crud-tickets.md` | 📝 Fase 5 — CRUD con vuelidate |
| `06-wizard-minimo.md` | 🪜 Fase 6 — Wizard de 3 pasos, keep-alive, $refs |
| `07-metricas-minimas.md` | 📊 Fase 7 — chart.js y librerías imperativas |
| `08-websockets-minimos.md` | 💬 Fase 8 — socket.io y tiempo real |
| `09-panel-soporte.md` | 🎧 Fase 9 — Panel de agente (fase de síntesis) |
| `10-vuex-a-fondo.md` | 🗂️ Fase 10 — Estado global con criterio · **cimiento de las rutas** |
| `11-testing-minimo.md` | ✅ Fase 11 — Jest + vue-test-utils · **prerequisito duro de X0** |

### 📎 Apéndices (consulta, no lectura)

| Archivo | Qué es |
|---|---|
| `A1-bootstrap.md` | 🎨 Bootstrap 4 — *no se jubila: **convive** con Quasar/Vuetify* |
| `A2-node.md` | 🟢 Node — *en Nuxt deja de ser "solo tooling": corre en producción* |
| `A3-npm.md` | 📦 npm |
| `A4-axios.md` | 🌐 axios (incluye multipart/subida de archivos) — *el interceptor cambia de casa en las rutas* |
| `A5-webpack-babel.md` | ⚙️ Webpack y Babel — *`vue.config.js` no existe en Quasar ni en Nuxt* |

### 🔀 Rutas (opcionales — elige **una**, después de F11)

| Archivo | Qué es |
|---|---|
| `QUASAR-FASES.md` | 🅠 **Ruta Q — Quasar 1.22** · Q0 → Q4. Se come el proyecto: `quasar.conf.js`, boot files, layouts |
| `VUETIFY-FASES.md` | 🅥 **Ruta VU — Vuetify 2.6** · VU0 → VU4. No se come el proyecto, pero el theming vive en JS |
| `NUXT-FASES.md` | 🅝 **Ruta NX — Nuxt 2.15** · NX0 → NX4. ⚠️ **Otro molde**: SSR, hidratación, `window is not defined` |

---

## 🗺️ El mapa de un vistazo

```
 F0 ─ F1 ─ F2 ─ F3 ─ F4 ─ F5 ─ F6 ─ F7 ─ F8
setup base auth mock dash crud wiz chart ws
                                          │
      ┌───────────────────────────────────┘
      │
 F9 ─ F10 ─ F11
panel vuex  test
              │
  ✅ Mini Jira "a pelo" completo
              │
  ┌───────────┼────────────┐
  ▼           ▼            ▼
╔═══════╗ ╔════════╗  ╔═══════╗
║ RUTA  ║ ║  RUTA  ║  ║ RUTA  ║
║   Q   ║ ║   VU   ║  ║  NX   ║
║Quasar ║ ║Vuetify ║  ║ Nuxt  ║
║  1.x  ║ ║  2.x   ║  ║  2.x  ║
╚═══════╝ ╚════════╝  ╚═══════╝
 Q0 → Q4  VU0 → VU4   NX0 → NX4

  ⚠️ elige UNA. No se acumulan.
```

---

## 🧭 Cómo usarlo

1. Lee `FASES.md` para el mapa completo y `0-plan-del-curso.md` para el alcance,
   el stack y las convenciones.
2. Sigue el tronco **en orden** (F0 → F11). **Sin saltos.** Cada fase está
   pensada para una sesión corta de estudio.
3. Completa al menos los ejercicios 🟢 y 🟡 de cada fase antes de avanzar.
4. Los **apéndices son opcionales**: material de consulta cuando el tema aparezca
   o algo te suene flojo.
5. **Al terminar F11**, elige **una** ruta — idealmente la que use tu empresa. Si
   no usa ninguna, has terminado: el tronco ya te dejó donde tenías que estar.

> ⚠️ **F10 (Vuex) y F11 (Testing) no son opcionales si vas a hacer una ruta.**
> El conflicto central de Q3/VU3 y NX3 es *el framework quiere el estado que tu
> store ya controla* — sin F10 no lo ves venir. Y sin F11 no puedes escribir la
> red de seguridad de X0, y **sin red no se migra nada**.

---

## 🔀 Qué te enseña cada ruta (y por qué son distintas)

| | 🅠 **Quasar 1** | 🅥 **Vuetify 2** | 🅝 **Nuxt 2** |
|---|---|---|---|
| **Qué es** | UI + build system | UI (plugin de Vue CLI) | **Meta-framework SSR** |
| **¿Se come el proyecto?** | **Sí.** No hay `main.js` | No. Sigues con tu `main.js` | **Sí.** No hay `main.js` ni `App.vue` |
| **La fricción central** | Boot files, layouts, `quasar.conf.js` | **Theming en JS** + bundle a 500kb | **`window is not defined`** |
| **La tensión con F10** | `:pagination.sync` vs tu Vuex | `:options.sync` vs tu Vuex | **`asyncData` vs Vuex** |
| **Qué te cambia** | Vocabulario | Vocabulario | **El modelo mental** |
| **Proyecto final** | Híbrido (Quasar + Bootstrap) | Híbrido (Vuetify + Bootstrap) | Reconstruido sobre otro modelo de ejecución |

**Si tu empresa no usa ninguna y quieres la que más te aporta:** NX. Q y VU son
"mismo Vue, otros componentes". Nuxt es *"tu componente corre en un Node que no
tiene `window`, y luego otra vez en el navegador, y tienen que coincidir o el DOM
se rompe"*.

---

## 📊 El material en números

**Tronco (terminado):**

- **1 plan + 12 fases** + **5 apéndices** + índice
- **~630 ejercicios** graduados (🟢 fácil → 🟡 intermedio → 🟠 difícil → 🔴 muy difícil)
- Stack de época: Node 14, Vue 2.6.14, Vue Router 3, Vuex 3, axios 0.21,
  Bootstrap 4.6, vuelidate 0.7, chart.js 2.9, socket.io 2.4,
  Jest + vue-test-utils 1.x

**Rutas (bosquejadas — contenido en producción):**

- **3 rutas × 5 fases** = 15 fases nuevas, mismas reglas (plantilla de 9 puntos,
  20–30 ejercicios graduados, Options API, código de época)
- Stack añadido: Quasar 1.22 · Vuetify 2.6 · Nuxt 2.15
- **Bootstrap 4.6 se queda en las tres** — la convivencia es contenido, no un
  descuido

| Documento | Estado |
|---|---|
| Tronco F0–F11 + apéndices | ✅ terminado |
| `ESTRUCTURA-CURSO.md` | ✅ terminado |
| `QUASAR-FASES.md` / `VUETIFY-FASES.md` / `NUXT-FASES.md` | ✅ bosquejo |
| Fases Q0–Q4 · VU0–VU4 · NX0–NX4 (contenido) | ⬜ pendiente |

---

## 🎓 La promesa del curso

**Tronco:**

> "Me sueltan mañana en un Vue 2 ajeno de 80.000 líneas y no siento pánico:
> sé leer sus patrones, sé dónde vive cada tipo de cosa, sé qué oler,
> por dónde empezar a testear — y sé qué NO tocar todavía."

**Ruta:**

> "Me sueltan en un Vue 2 **con Quasar/Vuetify/Nuxt encima** y sé distinguir qué
> es Vue, qué es el framework, y **qué me está haciendo por debajo** — incluido
> lo que me está quitando sin avisar. Y antes de migrar nada, escribo la red."
