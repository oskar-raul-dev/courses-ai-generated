# ✍️ Guía de estilo, tono y convenciones
## Tutorial React 16 — Rifas y chances

Esta guía es la fuente de verdad editorial. Cualquier chat que produzca un
`.md` la sigue. Su objetivo: que los ~50 documentos del proyecto se lean
como escritos por la misma mano, orientados a la práctica de mantenimiento.

> 🔄 **Cambio de convención (2026-07-15):** a partir de esta fecha, todo el
> código fuente del curso (nombres, constantes, endpoints) se escribe en
> **inglés**. La narrativa, los comentarios y los textos de interfaz de
> usuario se mantienen en **español**. Ver §4 para el detalle completo y
> `DICCIONARIO-CODIGO-INGLES.md` para el diccionario operativo de términos
> del dominio. Las fases ya escritas deben ajustarse a esta convención (ver
> §4.6); las fases nuevas se escriben directamente con ella.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien arregle un sistema real sin
romperlo.** No enseñamos React "bonito". Enseñamos a leer, entender,
reproducir, corregir y prevenir. Si un párrafo no ayuda a diagnosticar,
depurar o arreglar, sobra.

---

## 2. Tono

El tono es **cálido, informal y directo** — de colega senior a colega
senior, con humor cuando cae bien. No es un manual acartonado: es alguien
que ya sufrió este código explicándotelo con confianza y sin solemnidad.

- **Segunda persona, cercana.** Háblale al lector de "tú": "apaga json-server y verás el error", "si esto te suena flojo, 15 minutos de docs bastan".
- **Humor seco permitido.** Un 😉, un chiste sobre "perder 20 minutos debuggeando el frontend cuando el mock estaba apagado", un 🪦 para jubilar código. El humor sirve para desdramatizar la fricción del legacy, no para rellenar.
- **Honesto sobre lo feo.** Cuando algo es horrible (y en legacy lo es a menudo), se dice con gracia: "este patrón es horrible pero está en producción y así se lee". No se finge elegancia.
- **Orientado a la duda real.** Anticipa "¿y esto por qué está así?" y respóndela, muchas veces con una nota de época que da contexto histórico.
- **Cercanía sin condescendencia.** El lector es senior. Cálido no significa explicarle HTTP, JSON o tokens.

Evitar: promesas vacías ("vas a dominar React"), motivación de coach,
solemnidad de manual corporativo, y explicar lo obvio para el perfil. El
humor es condimento, no plato principal.

---

## 3. Idioma y forma (narrativa)

- Español claro y técnico para todo lo que **no** es código (títulos, explicaciones, ejercicios, referencias). Los términos del stack se dejan en inglés cuando son el nombre real: *hook*, *slice*, *epic*, *store*, *dispatch*, *race condition*, *memory leak*, *polling*. No se traducen forzadamente.
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla. Los subtítulos internos también pueden llevar emoji-tipo (ver §7) cuando aporta lectura rápida.
- **Prosa antes que listas.** Se prefiere explicar razonando en párrafos. Las listas se usan cuando son de verdad una lista (pasos, ítems paralelos).
- **Tablas solo para comparar, decidir o mapear.** "Cuándo usar X vs Y", matrices de decisión, mapeos versión-a-versión, tablas de opciones/directivas. No para narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Esta sección es normativa para **todo** fragmento de código del curso, sea
en el cuerpo de una fase, en un incidente, en un apéndice o en un ejercicio
resuelto.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Código fuente** (identificadores) | 🇬🇧 Inglés | `function sellNumber(id) {}`, `const isLoading = false` |
| **Endpoints y rutas** | 🇬🇧 Inglés | `/raffles`, `/raffles/:id/numbers`, `/login` |
| **Constantes y enums internos** | 🇬🇧 Inglés | `status: 'open'`, `RAFFLE_STATUS.CLOSED` |
| **Nombres de archivo, componente, slice, epic** | 🇬🇧 Inglés | `RaffleForm.jsx`, `raffleSlice.js`, `pollingEpic.js` |
| **Comentarios de código** | 🇪🇸 Español | `// la reserva expira a los 5 min` |
| **Textos de interfaz (UI)** | 🇪🇸 Español | `<button>Vender número</button>`, `"Cargando rifas…"` |
| **Narrativa del tutorial** | 🇪🇸 Español | Todo el texto fuera de bloques de código |

La app pedagógica (como la real) **no tiene i18n**: es una app en español
para usuarios de habla hispana. Por eso los textos que ve la persona
usuaria —labels, botones, mensajes de alerta, placeholders— se escriben en
español, tal como se escribirían en el sistema real. Lo que cambia a
inglés es el código que lee y mantiene el equipo: nombres de función,
variable, componente, acción, endpoint y constante.

> 📝 **Por qué este cambio.** El sistema real es mantenido por un equipo
> internacional y su código está en inglés (con comentarios en español,
> igual que acá). Antes de este cambio el curso mezclaba nombres en
> español (`rifasSlice`, `crearRifa`, `numero`) que no reflejan el código
> que la persona va a mantener de verdad. Ajustamos el pedagógico para que
> el vocabulario de identificadores sea el mismo que va a encontrar en
> producción, sin tocar el dominio bajo NDA (ver §11).

### 4.2 Qué se traduce y qué no (criterio rápido)

| Elemento | ¿Inglés? | Ejemplo |
|---|---|---|
| `function`, `const`, `let` (nombre) | ✅ Sí | `function getRaffles()` |
| Propiedades de estado / props | ✅ Sí | `state.raffles.items`, `<RaffleForm initialRaffle={...} />` |
| Endpoints (`apiClient.get(...)`) | ✅ Sí | `apiClient.get('/raffles')` |
| Acciones y `actionTypes` de Redux clásico | ✅ Sí | `SELL_NUMBER`, `START_POLLING` |
| Valores de enum/status internos | ✅ Sí | `status: 'open'` (no `'abierta'`) |
| Nombres de componente, archivo, slice, epic | ✅ Sí | `RaffleTable.jsx`, `raffleSlice.js` |
| Clases CSS/Sass propias del proyecto | ✅ Sí | `.raffle-card`, no `.tarjeta-rifa` |
| Comentarios `//` y `/* */` | ❌ No | `// valida antes de confiar en response.data` |
| Strings de interfaz (lo que ve el usuario) | ❌ No | `"Vender número"`, `"No hay rifas todavía…"` |
| Mensajes de error legibles para el usuario | ❌ No | `{ message: 'No se pudo cargar la rifa' }` — la **key** `message` en inglés, el **valor** en español |
| `data-testid` | ✅ Sí (para que combine con el código) | `data-testid="number-sold"` |
| Nombres del dominio de negocio en la narrativa | ❌ No (siguen en español) | El texto sigue hablando de "rifas", "números", "liquidación" |

> ⚠️ **Caso mixto frecuente — mensajes de error y textos de UI.** El
> objeto en sí usa keys en inglés (`{ message, type }`), pero el **valor**
> de `message` que ve el usuario va en español: `{ message: 'El servidor
> no respondió a tiempo', type: 'timeout' }`. Igual con los `case` de un
> mapeo de estado a etiqueta: el `case` es inglés, el `return` es la
> etiqueta en español que ve el usuario: `case 'open': return 'Abierta'`.

### 4.3 Diccionario del dominio (rifas y chances)

El diccionario completo y jerarquizado vive en
`DICCIONARIO-CODIGO-INGLES.md` — se consulta ahí para cualquier término
nuevo. Como referencia mínima, los términos centrales del dominio:

| Español (dominio, narrativa, UI) | Inglés (código) |
|---|---|
| rifa / rifas | `raffle` / `raffles` |
| número / números | `number` / `numbers` |
| disponible | `available` |
| reservado | `reserved` |
| vendido | `sold` |
| participante | `participant` |
| resultado | `result` |
| liquidación | `settlement` |
| borrador → abierta → cerrada → resuelta → liquidada | `draft` → `open` → `closed` → `resolved` → `settled` |
| premio (base) | `(base)Prize` |
| hora de cierre | `closingTime` / `closesAt` |

Los nombres de componentes, thunks, epics y acciones se arman combinando
estos términos con los verbos técnicos habituales (`get`, `fetch`,
`create`, `update`, `delete`, `sell`, `reserve`, `expire`) — ver ejemplos
completos en el diccionario.

### 4.4 Convenciones de nombrado

- **Componentes:** `PascalCase` en inglés — `RaffleTable`, `RaffleForm`, `SaleWizard`.
- **Archivos de componente:** mismo nombre que el componente, `.jsx` o `.js` según venga usando el proyecto — `RaffleTable.jsx`.
- **Funciones y variables:** `camelCase` en inglés — `sellNumber`, `isRaffleOpen`, `closingTime`.
- **Slices:** `<dominio>Slice.js` en inglés — `raffleSlice.js`, `saleSlice.js`.
- **Thunks:** verbo + dominio — `fetchRaffles`, `createRaffle`, `sellNumber`.
- **Epics:** `<propósito>Epic` — `pollingEpic`, `saleEpic`.
- **Action types (Redux clásico):** `SNAKE_CASE` en inglés — `SELL_NUMBER`, `STOP_POLLING`, `LOGOUT`.
- **Selectores:** `select` + dominio — `selectRaffleCount`, `selectOpenRaffles`.
- **Endpoints REST:** sustantivo en plural, inglés — `/raffles`, `/raffles/:id/numbers`, `/results`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` — `CHAOS_LEVEL`, `POLLING_INTERVAL_MS`.

### 4.5 Lo que nunca cambia

- **Comentarios de código:** 100% español, explicando el porqué (§5).
- **Textos de interfaz de usuario:** 100% español — labels, botones, placeholders, mensajes de alerta, `alt` de imágenes, `title` de tooltips.
- **Narrativa del tutorial:** 100% español.
- **Nombres propios del dominio en la narrativa:** "rifa", "número", "liquidación" siguen siendo las palabras que usás para *hablar* del sistema, aunque el código diga `raffle`, `number`, `settlement`.

### 4.6 Ajuste de fases ya escritas

Las fases 0 a 5 (y cualquier apéndice ya entregado) fueron escritas antes
de este cambio y usan identificadores en español (`rifasSlice`,
`crearRifa`, `RifasTabla`, `numero`, `estado`, etc.). Se ajustan siguiendo
este proceso, fase por fase, en el orden en que fueron escritas:

1. Aplicar el diccionario (`DICCIONARIO-CODIGO-INGLES.md`) a cada bloque de código.
2. Verificar consistencia con las fases que ya se ajustaron (si `raffleSlice` usa `fetchRaffles`, la fase siguiente no puede usar `getRaffles` para lo mismo).
3. Dejar intactos comentarios, narrativa y textos de UI.
4. Revisar ejercicios y referencias que citen nombres de código (ej. "agregá el thunk `crearRifa`" pasa a "agregá el thunk `createRaffle`").
5. Marcar el archivo como ajustado en la matriz de verificación (ver plantilla operativa en `DICCIONARIO-CODIGO-INGLES.md` §6).

No se reescribe la explicación ni la pedagogía: es un cambio de
identificadores, no de contenido.

---

## 5. Orientación a la práctica

Cada concepto se ancla en el dominio de rifas y en código que corre.

- **Nada de teoría suelta.** Si se explica `switchMap`, se explica sobre el epic de polling del resultado de la lotería, no en abstracto.
- **Código ejecutable y coherente.** Todo fragmento debe correr con las versiones fijadas y no contradecir fases anteriores. Nada de pseudocódigo que "se entiende".
- **Código mínimo.** El fragmento más pequeño que muestra el punto. Se recorta lo accesorio, pero el resultado sigue siendo ejecutable.
- **Comentarios que explican el porqué, no el qué, siempre en español.** `// la reserva expira a los 5 min: si no, el número queda bloqueado para siempre` sí; `// increments i` no (ni en español ni en inglés).
- **Distinguir capas.** Siempre queda claro si un comportamiento vive en el frontend, en el store (Redux), en el epic (RxJS) o en el backend (mock). Es la distinción que salva al que depura.

---

## 6. Manejo del código legacy (el corazón del tutorial)

- **No modernizar automáticamente.** Si el módulo real es una clase con `componentDidMount`, se muestra la clase. No se "mejora" a hooks salvo en una fase o ejercicio 🔥 marcado.
- **Clases y hooks conviven.** Se enseñan ambos y se muestra cómo leer código mezclado sin marearse.
- **`connect()` y `useSelector` conviven.** Igual: ambos aparecen según el módulo.
- **Redux Toolkit para slices nuevos**, pero se muestra el estilo clásico cuando sea pedagógicamente útil.
- **RxJS con moderación.** Los epics son necesarios, pero se enseña *cuándo NO usar un epic* — a veces un thunk basta. Sobreusar RxJS es un antipatrón que se nombra.
- **Corrección mínima vs refactor.** Siempre que haya un fix, se explica la diferencia entre el parche mínimo (lo que va en un hotfix) y la refactorización (lo que iría en otro momento, con más pruebas).
- **El idioma del código (§4) no es negociable ni siquiera en código legacy "feo".** Un módulo viejo y mal escrito se muestra viejo y mal escrito, pero con identificadores en inglés — la fealdad legacy que se enseña es de arquitectura y decisiones, no de idioma. Si el sistema real tuviera código legacy con nombres en español, sería parte del NDA; acá se normaliza a inglés siempre.

### Convenciones de código concretas

- `function () {}` en métodos de clase; arrow functions en componentes funcionales y callbacks.
- Dinero en enteros (centavos/pesos), nunca floats.
- Fechas con timezone explícito; nunca `new Date()` sin considerar TZ.
- Los epics con `.pipe()` y operadores nombrados, no encadenamientos crípticos.
- Identificadores, endpoints y constantes en inglés (§4); comentarios y textos de UI en español (§4.5).

---

## 7. Marcadores y callouts (vocabulario visual del curso)

Este vocabulario se usa igual en todos los documentos para que el lector lo
reconozca de un vistazo.

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Todo shortcut o patrón feo que se deja a propósito. Se declara en una fase y se **paga** explícitamente en otra (ver §7.3).
- 🔥 **Opcional / ampliación.** Ejercicios o secciones que exceden el alcance base. No cuentan en las 96h.
- ⭐ **Fase o pieza central.** Fases 5 y 6, y los incidentes más formativos.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy difícil.

### 7.2 Callouts en blockquote (emoji-tipo)

Se usan como blockquotes cortos para marcar el *tipo* de nota:

- 📝 **Nota de época.** Contexto histórico de un patrón feo. Ej: "usamos `var self = this` + `function () {}` para mantener el sabor legacy; en bases reales verás también arrow functions o `.bind(this)`."
- 📚 **Referencia rápida inline.** Un enlace útil justo donde surge la duda, sin esperar a la sección de referencias. Ej: "> 📚 Si esto te suena flojo, 15 min en https://... bastan."
- 🪦 **Retiro / jubilación.** Cuando algo cumple su función y se retira del proyecto. Ej: "> 🪦 Retiro formal de `stubby`: puedes borrarlo o dejarlo en `docs/legacy/` como recuerdo."
- ⚠️ **Advertencia.** Algo que rompe si lo ignoras (versión incompatible, `node_modules` compartido entre arquitecturas, etc.).
- 💡 **Truco o atajo** que ahorra tiempo real.

No hace falta usarlos todos en cada fase; se usan cuando aportan.

### 7.3 Secciones narrativas recurrentes

Estas micro-secciones tienen nombre fijo y aparecen cuando el contenido lo pide:

- **💸 Pago de deuda.** Sección donde una deuda declarada en una fase anterior se salda. Se nombra qué deuda era, de qué fase venía, y se muestra el cambio. Cierra el ciclo declarar → pagar.
- **Detalles con intención.** Lista corta que destila las decisiones deliberadas de un bloque de código ("devolvemos `res.data`, no la respuesta cruda de axios, porque el componente no debería conocer la forma del objeto de axios").
- **El patrón a memorizar.** Una o dos frases que extraen la lección transferible de un fragmento ("`loading = true` → llamar servicio → `.then` guarda datos → `.catch` guarda error legible → `.finally` apaga el loading").
- **Prueba de fuego.** Verificación manual concreta incrustada en el flujo, no en los ejercicios: "apaga json-server, recarga, confirma que ves el error con botón de reintento; vuelve a levantarlo y reintenta."
- **Mini-repaso.** Cuando una fase usa sintaxis del framework que el backend dev quizá no domina (JSX, hooks, operadores RxJS), un repaso exprés en tabla antes de entrar al código. Con su 📚 a la doc oficial.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de cita que dice cómo se siente el trabajo bien hecho: "> si mañana me cambian el mock por un backend real, solo toco el `baseURL` y ninguna vista se entera."

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación heredada ("hasta ahora la app vive de mentiras piadosas…").
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase.
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio. Aquí caben el **Mini-repaso** y las **Notas de época**.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable con comentarios de porqué, identificadores en inglés (§4). Aquí caben **Detalles con intención**, **El patrón a memorizar**, **Prueba de fuego** y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente y cómo depurarlo (enlaza con `FORENSE-FASE-NN`).
7. **🧪 Ejercicios progresivos** — 25 a 35 (ver §9).
8. **📚 Referencias** — ver §10.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué. Aquí va **La señal de que quedó bien**.

Los apéndices no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: mínimo 25, ideal 30-35 por fase.** Menos de 25 se queda corto.
- **Distribución equilibrada por nivel.** Reparte de forma pareja entre 🟢🟡🟠🔴; no cargues todo en fácil. Una guía razonable para ~30 ejercicios: ~8 🟢, ~9 🟡, ~7 🟠, ~4-6 🔴, más los 🔥 aparte.
- **Numeración continua con encabezado de rango por dificultad**, al estilo del curso Vue 2:
  ```
  ## 🧪 Ejercicios (30)

  **🟢 Fácil (1–8)**
  1. ...
  **🟡 Intermedio (9–17)**
  9. ...
  **🟠 Difícil (18–24)**
  18. ...
  **🔴 Muy difícil (25–30)**
  25. ...
  **🔥 Opcionales**
  - 🔥 ...
  ```
  El título de la sección lleva el conteo total: `## 🧪 Ejercicios (30)`.
- **Progresión real.** Los 🟢 calientan; los 🔴 exigen integrar varias fases o depurar algo esquivo.
- **Accionables y verificables.** "Haz que el número 0347 no pueda venderse dos veces bajo doble click rápido" — no "reflexiona sobre concurrencia".
- **Algunos de diagnóstico.** En cada fase, al menos un puñado entrega un bug y pide reproducir y localizar, no solo construir.
- **Enganchados al dominio.** Los ejercicios usan rifas, números, participantes, resultados y liquidaciones, no ejemplos abstractos.
- **Cuando un ejercicio nombra código, usa el identificador en inglés vigente** ("agregá el thunk `createRaffle`", no "agregá el thunk `crearRifa`"), aunque el enunciado en sí esté en español.
- Los 🔥 son opcionales y se listan aparte, sin numeración continua.

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial compatible con las versiones legacy
**primero**; luego libros; luego blogs, videos y tutoriales. Siempre se
advierte cuando un enlace apunta a docs de una versión distinta a la fijada.

### 10.1 Formato

- **URLs completas y clicables**, no solo el dominio. `https://legacy.reactjs.org/docs/react-component.html`, no "legacy.reactjs.org". Igual que el curso Vue 2.
- **Secciones separadas** dentro de "Referencias":
  - **Documentación oficial** (con URL completa y nota de versión).
  - **Libros** cuando apliquen.
  - **Video / apoyo** — screencasts, crash courses y tutoriales en YouTube u otros, con URL completa. Son bienvenidos: a este perfil le sirven.
  - **Orden de lectura sugerido** — una línea que encadena qué leer primero. Ej: "README de redux-observable → RxJS operators → volver al epic."

### 10.2 Fuentes oficiales por tema (usar URL completa al citar)

- **React clases (legacy):** https://legacy.reactjs.org
- **React hooks:** https://react.dev (advertir: cubre ≥ 16.8; cuidado con APIs de 17/18).
- **Redux / Redux Toolkit:** https://redux.js.org · https://redux-toolkit.js.org (fijar en 1.x).
- **redux-observable:** https://redux-observable.js.org
- **RxJS 6:** https://rxjs.dev (advertir diferencias con RxJS 7 en imports y operadores).
- **React Router 5:** https://v5.reactrouter.com
- **Bootstrap 4.6:** https://getbootstrap.com/docs/4.6
- **Testing:** https://jestjs.io · https://testing-library.com · https://playwright.dev
- **MDN** para JS base (Promises, Intl, etc.): https://developer.mozilla.org

### 10.3 Advertencias

- **Sobre citas:** cuando se mencione un artículo, libro, video o post específico, hay que dejar claro que las URLs y títulos pueden estar desactualizados o ser inexactos; el lector debe verificarlos. No se inventan números de página, DOIs ni IDs de video.
- **No usar en el código principal:** APIs exclusivas de React 17/18, React Router 6, RTK moderno (listener middleware, etc.) o RxJS 7. Las alternativas modernas aparecen solo como comparación o en fase opcional 🔥.

---

## 11. Confidencialidad (NDA)

Cero referencia al dominio aeronáutico real. Todo se expresa en clave de
rifas y chances. Si un ejemplo se acerca peligrosamente al dominio real,
se reemplaza por uno más genérico. Ante la duda, se generaliza.

El cambio de idioma del código (§4) no afecta esta regla: se traduce el
vocabulario del dominio pedagógico ("rifa" → `raffle`), nunca se introduce
vocabulario del dominio real.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Un fragmento de la Fase 6 no puede usar una estructura de store distinta a la que definió la Fase 4.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto, (2) `TUTORIAL-REACT16`, (3) `PLAN-DEL-CURSO`, (4) entregables aprobados de fases anteriores, (5) decisiones explícitas del chat actual.
- Nombres de archivos, slices, acciones y componentes se mantienen estables entre fases (ahora en inglés, ver §4.4). Si algo se renombra, se documenta el cambio.

---

## 13. Post-mortems e incidentes

Cada incidente sigue esta estructura de ocho puntos:

1. Síntoma.
2. Pasos de reproducción.
3. Evidencia observable (logs, DevTools, Network).
4. Causa raíz.
5. Corrección.
6. Prueba de regresión.
7. Prevención.
8. Post-mortem **sin culpabilización** (blameless): se analiza el sistema y el proceso, no a la persona.

El tono del post-mortem es sereno y analítico. Nada de buscar culpables.
(El humor cálido del resto del curso baja un punto aquí: un post-mortem es
serio, aunque no acartonado.)

---

## 14. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona, humor con moderación.
- [ ] Todo el código corre con las versiones fijadas.
- [ ] **Identificadores, endpoints, constantes y enums del código en inglés (§4).**
- [ ] **Comentarios de código y textos de interfaz (UI) en español (§4.5).**
- [ ] No contradice ninguna fase anterior (ni en pedagogía ni en nombres de código).
- [ ] Distingue frontend / store / epic / backend donde importa.
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y las secciones narrativas donde aporten.
- [ ] Marca 💸 la deuda técnica (y la paga si corresponde) y 🔥 lo opcional.
- [ ] Tiene 25-35 ejercicios numerados con rangos 🟢🟡🟠🔴 equilibrados (o 5-10 en apéndices).
- [ ] Enlaza su pieza forense y sus incidentes.
- [ ] Referencias con URL completa, secciones (oficial / libros / video / orden de lectura), advertencia de versión.
- [ ] Cero referencia al dominio bajo NDA.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
