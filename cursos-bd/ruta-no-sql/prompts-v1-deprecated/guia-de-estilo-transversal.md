# ✍️ Guía de estilo transversal — Ruta NoSQL 2026

> **Fuente de verdad editorial de toda la ruta.** Cualquier chat que produzca
> un `.md` de cualquiera de los 11 tutoriales sigue esta guía. Su objetivo:
> que los cientos de documentos de la ruta se lean como escritos por la misma
> mano. Cada prompt inicial de tecnología referencia este archivo; no lo
> repite.

Esta guía generaliza la editorial del tutorial React 16 (rifas) y del Track A/B
(mesa de soporte) para que aplique a **cualquier familia NoSQL**. Donde el
original decía "rifas" o "React", aquí decimos "el dominio del curso" y "el
motor del curso".

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien elija, opere y arregle un
sistema de datos real sin romperlo — y sepa cuándo *no* usar el motor que
está aprendiendo.** No enseñamos "el producto bonito". Enseñamos a modelar
por patrón de acceso, medir, diagnosticar y decidir. Si un párrafo no ayuda a
diseñar, depurar, medir o decidir, sobra.

El lector es un **ingeniero senior** con años en un paradigma que ya domina
(normalmente SQL relacional). No se le explica HTTP, JSON, índices o
transacciones desde cero: se le explica **en qué se parecen y en qué lo
traicionan** en el motor nuevo.

---

## 2. Tono

Cálido, informal y directo — de colega senior a colega senior, con humor
seco cuando cae bien. No es un manual acartonado: es alguien que ya sufrió
este motor en producción explicándotelo con confianza y sin solemnidad.

- **Segunda persona, cercana.** "apaga el índice y mide", "si esto te suena, 15 min de docs bastan".
- **Humor seco permitido**, como condimento y no plato principal. Un 😉, un 🪦 para jubilar un patrón.
- **Honesto sobre lo feo.** Cuando un motor es mala idea para un caso, se dice con números, no con fe.
- **Orientado a la duda real.** Anticipa "¿y esto por qué es así?" y contesta, muchas veces con nota de época.
- **Cercanía sin condescendencia.** El lector es senior. Cálido no es explicarle lo obvio para su perfil.

Evitar: promesas vacías ("vas a dominar Redis"), motivación de coach,
solemnidad corporativa, fanboyismo de producto. **El fanboy es el villano
transversal de toda la ruta.**

---

## 3. Idioma y forma

- **Español claro y técnico.** Los términos del stack se dejan en inglés cuando son el nombre real: *shard*, *pipeline*, *epic*, *embedding*, *upsert*, *tombstone*, *hot partition*, *eventual consistency*. No se traducen a la fuerza.
- **Markdown siempre.**
- **Idioma del código:** el **lenguaje nativo del motor** para lo que es del motor (SQL para DuckDB, Cypher para Neo4j, N1QL/query para el documental, comandos Redis, CQL para Cassandra, DSL de Elasticsearch…), y el **lenguaje de interfaz asignado al curso** (ver `LENGUAJES-DE-INTERFAZ.md`) para la app, los scripts y el arnés. Cada curso trae su propio lenguaje de interfaz del ecosistema del motor (Go, Java, C#, Python, Elixir, Kotlin, Rust o TS según la tabla); puede ser **exclusivo** o **convivir con TypeScript** según dónde viva la lección. Nunca pseudocódigo.
- **Encabezados con emoji con moderación** — uno por sección de plantilla.
- **Prosa antes que listas.** Se razona en párrafos. Las listas se usan cuando son de verdad una lista.
- **Tablas solo para comparar, decidir o mapear** — nunca para narrar.

---

## 4. Orientación a la práctica

Cada concepto se ancla en el dominio del curso y en código que corre.

- **Nada de teoría suelta.** Si se explica una consistencia eventual, se explica sobre el proyecto del curso, no en abstracto.
- **Código ejecutable y coherente** con las versiones fijadas; no contradice fases anteriores.
- **Código mínimo:** el fragmento más pequeño que muestra el punto, y sigue corriendo.
- **Comentarios que explican el porqué, no el qué.**
- **Distinguir capas.** Siempre queda claro si algo vive en el motor, en la app, en el arnés de medición o en la capa de sync/cache. Es la distinción que salva al que depura.

---

## 5. Los 5 pilares no negociables de la ruta

Todo curso, sin excepción, incluye estos elementos (heredados de la lista
maestra NoSQL 2026):

- 🪞 **Instinto falsable y medido.** El lector predice ("mi instinto SQL dice que esto será igual de rápido"), pone cronómetro y escribe el veredicto. La predicción va **antes** del número.
- 🩻 **Esto SÍ viaja igual.** Lo que la experiencia previa conserva intacto (selectividad, explain/plan, N+1, idempotencia…). Es lo reconfortante.
- ⚰️ **Anti-patrón transversal con autopsia.** El proyecto mal diseñado (el motor usado donde no toca), medido antes/después. Duele con números, no con adjetivos.
- 📖 **Diccionario de traducción** desde el paradigma que el estudiante ya domina hacia el motor nuevo, lado a lado.
- ⚖️ **Veredicto honesto.** Capítulo de cierre con árbol de decisión: *cuándo NO usar esta familia*, y qué usar en su lugar.

Y dos artefactos acumulativos que viven en el repo del curso:

- 📓 **`INSTINTOS.md`** — bitácora acumulativa: cada instinto SQL/previo que falló, con su medición y su corrección.
- 📊 **`BENCHMARKS.md`** — todo "vs" de productos medido con el **mismo arnés** (`scripts/vs.*`), nunca narrado de memoria. Un "vs" sin número no entra.

> El anti-patrón recurrente de **toda** la ruta: usar el motor donde no toca
> (Redis como base primaria, Neo4j para dos saltos, vectorial dedicado para
> 10k docs, Cassandra para un CRUD). Cada curso encarna su propia versión.

---

## 6. Marcadores y callouts (vocabulario visual compartido)

Idéntico en todos los documentos para que el lector lo reconozca de un vistazo.

### 6.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Shortcut que se deja a propósito, se declara en una fase y se **paga** en otra.
- 🔥 **Opcional / ampliación.** Excede el alcance base; no cuenta en las 120 h.
- ⭐ **Fase o pieza central.**
- 🟢🟡🟠🔴 **Dificultad de ejercicios.**

### 6.2 Callouts en blockquote (emoji-tipo)

- 📝 **Nota de época.** Contexto histórico/versión de un patrón.
- 📚 **Referencia rápida inline.** Enlace útil justo donde surge la duda.
- 🪦 **Retiro / jubilación** de una pieza que cumplió su función.
- ⚠️ **Advertencia.** Algo que rompe si lo ignoras (versión incompatible, límite del motor).
- 💡 **Truco o atajo** que ahorra tiempo real.

### 6.3 Secciones narrativas recurrentes (nombre fijo)

- **💸 Pago de deuda** — se salda una deuda declarada antes; se nombra de qué fase venía.
- **Detalles con intención** — lista corta de decisiones deliberadas de un bloque de código.
- **El patrón a memorizar** — una o dos frases con la lección transferible.
- **Prueba de fuego** — verificación manual concreta incrustada en el flujo.
- **Mini-repaso** — repaso exprés en tabla de sintaxis del motor que el lector quizá no domina, con su 📚.
- **La señal de que quedó bien** — cita de cierre que dice cómo se siente el trabajo bien hecho.

No hace falta usarlos todos en cada fase; se usan cuando aportan.

---

## 7. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación heredada.
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase.
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio. Aquí caben **Mini-repaso** y **Notas de época**.
5. **💻 Implementación y código comentado** — el grueso. Aquí caben **Detalles con intención**, **El patrón a memorizar**, **Prueba de fuego** y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe y cómo depurarlo.
7. **🧪 Ejercicios progresivos** — 30 a 40 (ver §8).
8. **📚 Referencias** — ver §9.
9. **🚀 Cierre y conexión con la siguiente fase** — incluye **La señal de que quedó bien**.

Los apéndices no siguen esta plantilla: índice de salto rápido + secciones
cortas + tabla "cuándo usar qué" + 5–10 ejercicios cortos.

---

## 8. Ejercicios

- **Cantidad: 30–40 por fase** (mínimo 30). Menos se queda corto.
- **Distribución equilibrada** entre 🟢🟡🟠🔴; no cargar todo en fácil. Guía para ~35: ~9 🟢, ~10 🟡, ~9 🟠, ~7 🔴, más los 🔥 aparte.
- **Numeración continua con encabezado de rango por dificultad:**

  ```
  ## 🧪 Ejercicios (35)

  **🟢 Fácil (1–9)**
  1. ...
  **🟡 Intermedio (10–19)**
  10. ...
  **🟠 Difícil (20–28)**
  20. ...
  **🔴 Muy difícil (29–35)**
  29. ...
  **🔥 Opcionales**
  - 🔥 ...
  ```

- **Progresión real.** Los 🟢 calientan; los 🔴 integran varias fases, obligan a medir o a depurar algo esquivo.
- **Accionables y verificables**, nunca "reflexiona sobre X".
- **Al menos un puñado de diagnóstico** por fase: se entrega un bug o una query lenta, se pide reproducir y localizar.
- **Enganchados al dominio** del curso.
- **Al menos uno mide un "vs"** con `scripts/vs.*` y anota en `BENCHMARKS.md`.
- Los 🔥 van aparte, sin numeración continua.

En apéndices bastan 5–10 ejercicios cortos.

---

## 9. Bibliografía y referencias

**Regla:** documentación oficial de la versión fijada **primero**; luego
libros; luego blogs, papers, videos. Se advierte siempre cuando un enlace
apunta a otra versión.

- **URLs completas y clicables**, no solo el dominio.
- **Secciones separadas** dentro de "Referencias": Documentación oficial (con nota de versión) · Libros · Video/apoyo · **Orden de lectura sugerido** (una línea que encadena qué leer primero).
- **Sobre citas:** las URLs y títulos pueden estar desactualizados; el lector verifica. **No se inventan** números de página, DOIs ni IDs de video.

---

## 10. Stack base de la ruta (2026)

Salvo que un curso justifique lo contrario, el stack por defecto es moderno:

| Componente | Versión / elección |
|---|---|
| Runtime app / pegamento | **Lenguaje de interfaz del curso** (ver `LENGUAJES-DE-INTERFAZ.md`); TS/Node 22 donde convive |
| Framework HTTP (cuando aplique) | El idiomático del lenguaje de interfaz (Express 5, Spring, Phoenix, ASP.NET, etc.) |
| Contenedores | Docker + docker-compose |
| Arnés de medición | `scripts/vs.*` propio, en el lenguaje de interfaz del curso, común en formato a la ruta |
| Motor del curso | **versión estable actual 2026** de cada producto |

El **lenguaje del código** dentro de cada fase es el nativo del motor para lo
que es del motor, más el **lenguaje de interfaz asignado al curso** para la app
y el arnés. La asignación (exclusivo / convive con TS / políglota) está en
`LENGUAJES-DE-INTERFAZ.md`, que es fuente de verdad para este punto.

---

## 11. Coherencia entre documentos

- **No contradecir fases anteriores** (mismo esquema, mismos nombres).
- **No reescribir decisiones aprobadas** sin señalar la incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto, (2) esta guía transversal, (3) `RUTA-NOSQL-2026.md`, (4) el `PLAN-DEL-CURSO` de la tecnología, (5) entregables aprobados de fases anteriores, (6) decisiones del chat actual.
- Nombres de archivos, colecciones/tablas, funciones y componentes estables entre fases; si algo se renombra, se documenta.

---

## 12. Post-mortems e incidentes

Cada incidente sigue ocho puntos: Síntoma · Reproducción · Evidencia
observable · Causa raíz · Corrección · Prueba de regresión · Prevención ·
Post-mortem **blameless**. Tono sereno y analítico; el humor baja un punto
aquí.

---

## 13. Checklist antes de cerrar un `.md`

- [ ] Plantilla de 9 secciones (o formato de apéndice).
- [ ] Tono cálido, informal, segunda persona, humor con moderación.
- [ ] Todo el código corre con las versiones fijadas.
- [ ] No contradice fases anteriores.
- [ ] Distingue capas (motor / app / arnés / sync-cache) donde importa.
- [ ] Usa el vocabulario de callouts y secciones narrativas donde aporten.
- [ ] Marca 💸 la deuda (y la paga si toca) y 🔥 lo opcional.
- [ ] 30–40 ejercicios con rangos 🟢🟡🟠🔴 equilibrados (o 5–10 en apéndice).
- [ ] Incluye los 5 pilares donde corresponda (🪞 🩻 ⚰️ 📖 ⚖️) y alimenta `INSTINTOS.md` / `BENCHMARKS.md`.
- [ ] Referencias con URL completa, secciones y advertencia de versión.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
