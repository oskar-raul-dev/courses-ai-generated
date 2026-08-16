# 🧷 Prompts de redacción e iteración

## Tutorial Angular 8 — Laboratorio clínico

Este archivo es el **kit de arranque de chats**. Contiene cuatro piezas:

1. Un **prompt maestro de fase** con placeholders.
2. La **tabla de valores** de esos placeholders para las quince fases (0-14).
3. Un **prompt maestro de apéndice** con placeholders, y su tabla para los trece apéndices.
4. Dos **prompts de iteración** (fase y apéndice) para pedir revisiones o cambios sobre un entregable ya escrito.

Todos los prompts obligan a la IA a **preguntar antes de redactar**. Sigue siendo una decisión de diseño y no un adorno, aunque su motivo original haya cambiado: nació porque había pendientes bloqueantes vivos —i18n runtime o compile-time, versión de NgRx, librería de PDF— y una fase escrita sobre una suposición equivocada cuesta más que una ronda de preguntas. Esos tres están cerrados (ver `alcance-del-proyecto.md` §13), así que hoy la ronda de preguntas sirve para lo otro: **detectar contradicciones con lo ya escrito antes de producir mil líneas**, que en un curso de veintisiete documentos es el riesgo que queda.

> 🧭 **Cifra cerrada.** **122h**: 108h de fases más 14h de cuaderno, verificado sumando los encabezados de las fases. La cifra de 96h y 12 fases venía de `_deprecado-tutorial-angular8.md`. El `plan-del-curso.md` que este archivo citaba nunca llegó a existir; la tabla de horas vigente es la de `propuesta-fases-y-alcance.md` §2.

---

## 📐 1. Prompt maestro de fase

Copiar completo al abrir el chat de una fase, rellenar los `{{placeholders}}` con la fila correspondiente de la tabla de §2, y borrar las notas entre llaves.

```markdown
Este es el chat de la **Fase {{NN}} — {{NOMBRE}}** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es el archivo `{{NN}}-{{SLUG}}.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`propuesta-fases-y-alcance.md`, `alcance-del-proyecto.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md` —con
`00-convencion-de-git-y-tags.md` como su anexo para todo lo que toque git, repos
y tags—, entregables de fases anteriores y decisiones de este chat.

La plantilla de fase (9 secciones) está en `plantillas-de-capitulo.md`: se sigue
literal, sin secciones extra ni reordenadas. El cierre termina con el bloque
🏷️ del tag de la fase, de forma fija y sin reexplicar la convención: guía §8.1. La voz, el tuteo, la regla del
andamio, la prosa antes que listas y las listas antes que tablas están en
`guia-de-estilo-y-convenciones.md`.

Recordatorio de las tres reglas que más se rompen:
- **Código en inglés, comentarios en español.** Sin excepciones, ni en el
  fragmento más feo ni en `db.json` ni en el Dockerfile. Textos de interfaz vía
  claves de i18n.
- **Estilo de la época:** NgModules, `function () {}` en métodos de clase,
  componentes gordos con lógica adentro, `.subscribe()` a pelo, `any` tolerado,
  NgRx sin `createFeature` ni `createActionGroup`. Se comenta, no se corrige.
- **Coherencia de la ficción.** El sistema heredado se llama **LabCore**, es del
  curso, y el curso lo construye entero. Si afirmas que algo está así en LabCore,
  tiene que estar en alguna fase; lo que no se construye se cuenta como historia y
  en pasado. Guía §11.

## Identidad de esta fase

- Número y nombre: Fase {{N}} de 14 — {{EMOJI}} {{NOMBRE}}
- Horas: **{{HORAS}}**
- Depende de: {{DEPENDE}}
- Habilita: {{HABILITA}}
- Apéndices de apoyo: {{APENDICES}}
- Incidentes asociados: {{INCIDENTES}}
- Estado: {{OBLIGATORIA_U_OPCIONAL}}

## Alcance

- **Propósito (una línea):** {{PROPOSITO}}
- **Qué entra:** {{ENTRA}}
- **Qué NO entra todavía:** {{NO_ENTRA}}
- **Conceptos clave a introducir:** {{CONCEPTOS}}
- **Deuda técnica intencional 💸:** {{DEUDA}}
  (declarar qué sería lo correcto hoy y por qué en Track A no se paga)
- **Pieza forense de esta fase:** {{FORENSE}}
  (enlazar a `forense-fase-{{NN}}.md`, no desarrollarla entera acá)
- **Ejercicios:** {{EJERCICIOS}} en total, repartidos 🟢🟡🟠🔴 según la guía,
  con al menos un tercio de diagnóstico y todos anclados al laboratorio.

## Pendientes que pueden bloquear esta fase

{{BLOQUEANTES}}

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
   y si las {{HORAS}}h te cuadran con el contenido pedido.
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

## 📋 2. Tabla de valores por fase

La tabla va partida en bloques porque una tabla de doce columnas no se lee. Cada bloque cubre las mismas quince filas.

### 2.1 Identidad

| `{{NN}}` | `{{EMOJI}}` | `{{NOMBRE}}` | `{{SLUG}}` | `{{HORAS}}` | `{{OBLIGATORIA_U_OPCIONAL}}` |
|---|---|---|---|---|---|
| 00 | 🛠️ | Setup + hola mundo | `setup-hola-mundo` | 8h | Obligatoria |
| 01 | 🏗️ | Estructura base + NgRx | `estructura-base-ngrx` | 12h | Obligatoria ⭐ |
| 02 | 🌐 | Internacionalización | `i18n` | 6h | Obligatoria |
| 03 | 🔐 | Autenticación mínima | `autenticacion` | 8h | Obligatoria |
| 04 | 🧪 | Mock API + caos | `mock-api-caos` | 6h | Obligatoria ⭐ |
| 05 | 🏥 | Pacientes | `pacientes` | 6h | Obligatoria |
| 06 | 📋 | Órdenes | `ordenes` | 4h | Obligatoria |
| 07 | 🧫 | Muestras y cadena de custodia | `muestras-custodia` | 8h | Obligatoria |
| 08 | 🧬 | Resultados y rangos versionados | `resultados-rangos` | 10h | Obligatoria ⭐ |
| 09 | 📦 | Entrega y PDF en cliente | `entrega-pdf` | 8h | Obligatoria |
| 10 | 📊 | Dashboard | `dashboard` | 8h | Obligatoria |
| 11 | 📜 | Trazabilidad y audit log | `trazabilidad-audit-log` | 7h | Obligatoria |
| 12 | ✅ | Testing desde cero + coverage | `testing-coverage` | 10h | Obligatoria |
| 13 | 🚚 | Build, despliegue y cierre | `build-despliegue` | 7h | Obligatoria ⭐ |
| 14 | 🔥 | Ambiente "casi prod" con kind | `casi-prod-kind` | — | 🔥 Opcional, sin horas |

### 2.2 Cadena y apoyos

| Fase | `{{DEPENDE}}` | `{{HABILITA}}` | `{{APENDICES}}` | `{{INCIDENTES}}` |
|---|---|---|---|---|
| 00 | ninguna | Fase 1 | A02, A03, A12, A13 | 01, 02 |
| 01 | Fase 0 | Fases 2-14 | A06, A05, A02 | 03 |
| 02 | Fase 1 | Fases 3-14 | A07, A05 | 04 |
| 03 | Fases 1 y 2 | Fases 5-12 | A05, A01, A07 | 05 |
| 04 | Fases 1, 2 y 3 | Fases 5-12 | A03, A05, A02, A07 | 06, 08 |
| 05 | Fases 1, 2 y 4 | Fase 6 | A01, A02, A06 | 09, 10 |
| 06 | Fase 5 | Fase 7 | A01, A02, A06, A07 | — |
| 07 | Fases 5 y 6 | Fases 8 y 11 | A01, A06, A07 | 11, 21 |
| 08 | Fase 7 | Fases 9 y 11 | A01, A02, A05, A06, A07 | 07, 12, 13 |
| 09 | Fase 8 | Fase 11 | A08, A07, A05 | 14, 15 |
| 10 | Fases 5, 6, 7 y 8 | Fases 11 y 12 | A05, A06, A07, A02, A04 | 16 |
| 11 | Fases 5, 6, 7, 8 y 9 | Fase 12 | A06, A05 | 17 |
| 12 | Fases 1-12 | Fase 13 | A03, A05, A06 | 18 |
| 13 | Fase 12 | Fase 14 | A04, A09, A03, A07, A02 | 19, 20 |
| 14 | Fase 13 | ninguna | A09, A03, A12, A13 | — |

### 2.3 Alcance: propósito, qué entra, qué no

| Fase | `{{PROPOSITO}}` | `{{ENTRA}}` | `{{NO_ENTRA}}` |
|---|---|---|---|
| 00 | Dejar el entorno del equipo levantado y un primer componente que hable con un endpoint, sufriendo de paso el primer choque de cascada | nvm-windows, Angular CLI 8, proyecto base, Bootstrap 4 y Material conviviendo, componente único con formulario, POST a endpoint hardcodeado | routing, store, servicios reales, i18n → Fases 1, 2 y 4 |
| 01 | Montar el esqueleto que sostiene el curso entero: módulos, router y el store donde vivirá todo el estado | módulos por dominio, layout, router con vistas placeholder, NgRx (store, actions, reducers, effects, selectores), Redux DevTools, dónde vive la config por ambiente | auth, API real, CRUD, i18n → Fases 2, 3, 4 y 5 |
| 02 | Montar las tres llaves de idioma antes de que existan pantallas, para no reescribir cuarenta plantillas después | árbol de traducciones, selector de idioma, pluralización, formatos de fecha y número por locale | traducción real de todo el contenido, bundle por idioma en el build → Fase 13 |
| 03 | Simular el login y el interceptor sin backend, que es como lo vive LabCore en desarrollo | login mock, JWT en storage, guard, interceptor de token, logout, expiración | backend real, refresh token, roles y permisos finos → fuera de alcance |
| 04 | Construir el mock server y el inyector de caos, porque escribirlo enseña más que recibirlo hecho | json-server, `db.json` con el modelo del laboratorio, middleware de caos propio (latencia, 500, malformadas, CORS, token expirado, timeouts), effects que lo consumen | backend propio, paginación server-side → fuera de alcance |
| 05 | Primer CRUD completo pasando por el store, con el formulario denso de verdad y el molde de slice que copian las fases siguientes | tabla Material con filtro y paginador a mano, alta/edición/baja lógica de pacientes, formulario reactivo con validador asíncrono, feature state con su slice y su diálogo | las órdenes médicas → Fase 6; validación cruzada avanzada → Fase 8; permisos por rol → fuera de alcance |
| 06 | Repetir el molde de la fase anterior sobre otra entidad, para descubrir qué se copia y qué no | slice `orders` calcado del molde, `FormArray` de `testCodes`, cruce orden → paciente en el componente, `MatSelect` de estado sin guardas | guardas de transición → Fase 7; selector cruzado entre slices → Fase 10; permisos por rol → fuera de alcance |
| 07 | Enseñar la máquina de estados con transiciones estrictas y su rastro | estados de muestra, transiciones válidas e inválidas, timeline de custodia, guardas de transición en el reducer | trazabilidad transversal completa → Fase 11 |
| 08 | El corazón normativo: rangos versionados y validación irreversible | rangos v1/v2 con vigencia, cálculo fuera de rango, validación por profesional habilitado, resultado crítico | firma digital, workflow multinivel → fuera de alcance |
| 09 | Generar el informe en cliente y entender por qué a veces sale con datos viejos | armado del PDF, fuentes y acentos, vigencia del informe, marcado de entrega | firma digital real, envío por correo → fuera de alcance |
| 10 | Un dashboard que se pone lento, y las razones por las que se pone lento | KPIs, gráficos con las librerías fijadas, selectores memoizados, ciclo de vida de suscripciones | agregaciones server-side, BI real → fuera de alcance |
| 11 | Convertir el rastro disperso en un `auditLog` consultable que sirva para reconstruir un incidente | modelo de `auditLog`, qué se registra y qué no, timeline consultable, el action log como evidencia | encriptación y retención legal → fuera de alcance |
| 12 | Montar testing donde no hay nada y llegar a coverage medible sin volverse loco | Jasmine, Karma, TestBed, tests de reducer, selector, effect, servicio y componente; coverage y su lectura | e2e exhaustivo y CI real → smoke tests y fuera de alcance |
| 13 | La lección que ordena el curso: la imagen es la misma en UAT y en PROD, lo que cambia es lo de afuera | Dockerfile multi-stage, nginx con `try_files`, `entrypoint.sh` que inyecta config en arranque, checklist de hotfix, cierre y guiño a Angular 9 | orquestación, pipelines de CI → Fase 14 y fuera de alcance |
| 14 | Ver la imagen de la Fase 13 corriendo en un Kubernetes local, sin tocarla | cluster con kind, carga de la imagen local, Deployment, Service, ConfigMap como volumen, Ingress, rolling update | cluster real de la empresa, Helm, operadores → fuera de alcance |

### 2.4 Conceptos, deuda y forense

| Fase | `{{CONCEPTOS}}` | `{{DEUDA}}` 💸 | `{{FORENSE}}` |
|---|---|---|---|
| 00 | CLI, estructura de un proyecto Angular, cascada CSS entre dos frameworks | dos sistemas de estilos conviviendo sin capa de aislamiento | consola y Network tab como fuente de verdad |
| 01 | NgModules, router, flujo unidireccional, store/action/reducer/effect/selector | store al estilo 2019: reducers en `switch`, sin `createFeature` | Redux DevTools como máquina del tiempo |
| 02 | Árbol de traducciones, locale, pluralización, `LOCALE_ID` | claves planas sin namespacing estricto | clave faltante en pantalla y locale equivocado en consola |
| 03 | Guard, interceptor, storage del token, expiración | token en `localStorage` y sin refresh | request-id y breakpoints condicionales en el interceptor |
| 04 | Mock server, inyección de fallos, manejo de error en effects | caos configurado por header global, sin panel | qué acción se despacha cuando el backend devuelve 500 |
| 05 | Formularios reactivos, tabla Material, feature state | componente gordo con la lógica de negocio adentro | reproducir un bug de usuario desde un ticket vago |
| 06 | `FormArray`, lectura rápida de un slice ajeno, cruce entre slices en el componente | `MatSelect` que ofrece las seis transiciones de estado sin guarda ninguna | el estado que no existe hasta que alguien navega a su ruta |
| 07 | Máquina de estados, invariantes de transición | validación de transición duplicada en componente y reducer | transición ilegal rastreada en logs |
| 08 | Versionado de reglas de negocio, irreversibilidad, concurrencia | fecha de vigencia comparada sin zona horaria explícita en un punto marcado | source maps en producción y por qué a veces mienten |
| 09 | Generación en cliente, fuentes y acentos, estado stale | copia del estado tomada al abrir la vista, no al generar | rastrear de dónde salió la copia vieja del estado |
| 10 | Memoización de selectores, ciclo de vida de suscripciones, re-render | suscripciones sin `unsubscribe` en un componente marcado | Performance panel: suscripciones huérfanas y redibujos |
| 11 | Auditoría como dato de primera clase | `auditLog` escrito desde el effect y no desde el backend | el action log como reconstrucción de incidente |
| 12 | TestBed, doblado de dependencias, coverage y sus mentiras | tests que dependen del orden de ejecución en un caso marcado | test de regresión que falla antes del fix, empezando por reducers |
| 13 | Build multi-stage, config horneada vs inyectada, `try_files` | `environment.ts` sigue horneado y se parchea desde fuera | diff de ambientes y feature flags para hotfix |
| 14 | Pod, Deployment, Service, ConfigMap, Ingress, rolling update | manifiestos mínimos, sin límites de recursos ni probes finas | `kubectl logs` y `describe` cuando el pod no arranca |

### 2.5 Ejercicios y bloqueantes

| Fase | `{{EJERCICIOS}}` | `{{BLOQUEANTES}}` |
|---|---|---|
| 00 | 30 | 🪦 Cerrado: Bootstrap **4.6.2** compilado con `node-sass` **4.14.1** |
| 01 | 35 | 🪦 Cerrado: NgRx **8.6.0** |
| 02 | 28 | 🪦 Cerrado: runtime con `@ngx-translate` 11.0.1 |
| 03 | 30 | Cómo genera y expira el token el mock: ¿JWT firmado de mentira o cadena opaca? |
| 04 | 30 | Ninguno duro; 🪦 Cerrado: `json-server` **0.16.3** |
| 05 | 31 | Nombres de acciones y selectores heredados de la Fase 1 |
| 06 | 25 | Nada bloqueante: el molde entero llega escrito desde la Fase 5 |
| 07 | 30 | Ninguno |
| 08 | 35 | Regla exacta de irreversibilidad: ¿se permite invalidar con rol superior? |
| 09 | 30 | 🪦 Cerrado: `jspdf` **1.5.3** |
| 10 | 30 | 🪦 Cerrado: `ng2-charts` **2.4.3** + `chart.js` **2.9.4** vivos, `@swimlane/ngx-charts` **12.1.0** heredada |
| 11 | 27 | Dónde vive el `auditLog`: ¿lo escribe el front o llega del backend? |
| 12 | 30 | ¿Hay número objetivo de coverage pedido por el líder? |
| 13 | 30 | Cómo resuelve hoy LabCore la config por ambiente; si ya hay patrón, se enseña ese |
| 14 | 15 🔥 | ¿El equipo toca `kubectl` o solo entrega el artefacto? |

---

## 📎 3. Prompt maestro de apéndice

```markdown
Este es el chat del **Apéndice {{ANN}} — {{NOMBRE}}** del tutorial Angular 8 +
Laboratorio clínico. Su único entregable es `apendice-{{ANN_MIN}}-{{SLUG}}.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto. Aquí manda la **plantilla
de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente laxa:
encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español, estilo de la
época, y coherencia de la ficción de LabCore (guía §11). Y el cierre lleva su bloque
🏷️, casi siempre en la variante negativa —un apéndice no lleva tag propio porque
el código que explica lo escriben las fases—, enlazando
`00-convencion-de-git-y-tags.md` (guía §8.1).

## Identidad

- Apéndice {{ANN}} — {{NOMBRE}}
- Horas de referencia: **{{HORAS}}** (no cuentan en el calendario de 122h)
- Versión cubierta: {{VERSION}}
- Usado por: {{USADO_POR}}
- Estado: {{ESTADO}}

## Alcance

- **Qué problema resuelve (una línea):** {{PROPOSITO}}
- **Secciones esperadas:** {{SECCIONES}}
- **Qué queda explícitamente fuera:** {{FUERA}}
- **Advertencias obligatorias:** {{ADVERTENCIAS}}
- **Ejercicios:** {{EJERCICIOS}} cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en {{USADO_POR}} y propón si
las enlazas o las reescribes desde otro ángulo. Si no tienes el entregable de esa
fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar
   una versión por buena de memoria; se toma del stack fijado en el README).
b) Qué convenciones de LabCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las {{HORAS}}h
   cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras
y preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente
sugerido al final. No infles el apéndice.
```

### 3.1 Tabla de valores por apéndice

| `{{ANN}}` | `{{NOMBRE}}` | `{{SLUG}}` | `{{HORAS}}` | `{{VERSION}}` | `{{USADO_POR}}` | `{{ESTADO}}` |
|---|---|---|---|---|---|---|
| A01 | Angular Material | `material` | 3h | Material y CDK 8.2.3 | Fases 3, 5, 6, 7, 8 | Base |
| A02 | Bootstrap 4 + Sass | `bootstrap-sass` | 3h | Bootstrap 4.6.2 + `node-sass` 4.14.1 | Fases 0, 1, 4, 5, 6, 8, 10, 13 | Base |
| A03 | Node y npm | `node-npm` | 2h | Node 12.22.12 / 14.21.3, npm 6.x | Fases 0, 4, 12, 13, 14 | Base |
| A04 | Webpack oculto | `webpack-oculto` | 2h | Angular CLI 8.3.29 | Fases 10, 13 | Base |
| A05 | RxJS de supervivencia | `rxjs-supervivencia` | 3h | RxJS 6.5.5 | Fases 1, 2, 3, 4, 8, 9, 10, 11, 12 | Base ⭐ |
| A06 | NgRx 8 | `ngrx` | 4h | NgRx **8.6.0** | Fases 1, 5, 6, 7, 8, 9, 10, 11, 12 | Base ⭐ |
| A07 | i18n en Angular 8 | `i18n` | 3h | `@ngx-translate/core` 11.0.1 + `http-loader` 4.0.0 sobre Angular 8.2.14 | Fases 2, 3, 4, 6, 7, 8, 9, 10, 13 | Base |
| A08 | PDF en cliente | `pdf-cliente` | 3h | jsPDF 1.5.3 (comparadas: `jspdf-autotable` 3.5.x, `pdfmake` 0.1.x) | Fase 9 | Base |
| A09 | Kubernetes para el dev de front | `kubernetes` | 3h | API `v1`, `apps/v1`, `networking.k8s.io/v1`; herramientas, las de la Fase 14 §5 | Fases 13, 14 | Base |
| A10 | Migración 8 → 9 | `migracion-8-9` | 3h | Angular 8.2.14 → línea **9.0**, con Ivy | Fases 3, 4, 12, 13 (referencia) | 🔥 Opcional |
| A11 | Migración 9 → 16 | `migracion-9-16` | 2h | El camino de Angular 9 a la línea **16** (la 16 como mirador, no como meta) | Fases 4, 13 (referencia) | 🔥 Opcional |
| A12 | Dependencias problemáticas en arm64 / M1 | `arm64-m1` | 2h | `node-gyp`, `node-sass` 4.14.1 sobre Node 14.21.3, el Chromium de Karma | Fases 0, 14 | 🔥 Opcional por plataforma |
| A13 | Docker + Colima en Apple Silicon | `docker-colima` | 2h | La CLI de Docker y el formato de imagen; **sin fijar versiones de Colima ni de Docker Desktop, a propósito** | Fases 0, 13, 14 | 🔥 Opcional por plataforma |

### 3.2 Alcance por apéndice

| `{{ANN}}` | `{{PROPOSITO}}` · `{{SECCIONES}}` | `{{FUERA}}` | `{{ADVERTENCIAS}}` |
|---|---|---|---|
| A01 | Leer y modificar los formularios y tablas densos de LabCore · theming, `form-field`, `table` con `dataSource`, `dialog`, `snackbar`, form controls | componentes de Material que el proyecto no usa | la doc de material.angular.io cubre versiones muy posteriores |
| A02 | Que Bootstrap y Material convivan sin pelearse por la cascada · grid de Bootstrap con componentes de Material, quién gana la especificidad, paleta compartida, compilación Sass | rediseño visual del proyecto | tocar variables de Sass sin recompilar no cambia nada |
| A03 | Entender por qué el `npm install` de tu compañero produjo otro `node_modules` · lockfiles, `npm ci` vs `npm i`, dependencies vs devDependencies, `--legacy-peer-deps` | publicación de paquetes | `node_modules` compartido entre arquitecturas rompe |
| A04 | Saber qué hace el CLI por debajo cuando algo del build falla · pipeline del CLI 8, budgets, source maps, dónde vive el `ng eject` que ya no existe | escribir configuración de Webpack a mano | ejectar no es opción en Angular 8 |
| A05 | Los seis operadores que sí aparecen en código real · `map`, `filter`, `tap`, `catchError`, `switchMap`, `take`, más el manejo de la suscripción y su fuga | operadores que el proyecto no usa; sobreusar RxJS es antipatrón | rxjs.dev documenta RxJS 7: los imports cambian |
| A06 | Leer y escribir el store al estilo 2019 · store, actions, reducer en `switch`, effects, selectores, DevTools, estructura del feature state | `createFeature`, `createActionGroup`, Signals | la doc oficial de NgRx ya solo cubre versiones modernas |
| A07 | Usar la solución de i18n del proyecto · API de `@ngx-translate` 11, árbol de claves y claves construidas, pluralización, locales y formatos, traducir fuera de la plantilla, bundle por idioma | traducción del contenido real; RTL; el montaje del `I18nModule` (Fase 2) | 🪦 el bloqueo runtime vs compile-time quedó resuelto en la Fase 2 §4: **runtime con `@ngx-translate` 11**. La doc de la librería ya solo cubre versiones que exigen Angular 13+ |
| A08 | Generar el informe sin que los acentos salgan rotos · armado del documento, fuentes embebidas (Roboto normal y bold), la mecánica del acento roto, salidas y peso, límites de la librería, librerías vecinas | firma digital real; el dato viejo del snapshot (Fase 9); las herramientas de medición (A04 §5) | la doc que se encuentra es la de la 2.x, con otro `import`; un PDF no avisa cuando sale mal; embeber una fuente es distribuirla |
| A09 | Vocabulario para hablar con plataforma y leer un YAML ajeno · lectura de manifiestos, imagen tras el build (registry, digest, `imagePullSecrets`), vocabulario completo, ConfigMap y Secret, caja de herramientas 👁️/✍️, estados de pod traducidos | administración del cluster; qué *es* cada objeto (Fase 14 §4); el montaje con kind (Fase 14 §5) | **§8 obligatoria:** lo que kind permitió, el cluster real puede rechazarlo (root, puerto 80, sistema de archivos de solo lectura, cuotas); un Secret no está cifrado; un estado de pod no es un diagnóstico; preguntar a plataforma antes de improvisar |
| A10 | Ver qué costaría el salto a 9, con datos y no con opiniones · Ivy en lo que se nota, `ng update` y sus schematics, `ngcc`, errores nuevos, validación de dependencias sin tablas de versiones, ensayo en rama desechable, estimación por categorías, veredicto de cuándo NO migrar | migración real del sistema; todo lo posterior a la 9 (A11); las herramientas de medición (A04 §5); tablas de compatibilidad de librerías, a propósito | solo comparación, el código principal se queda en 8; `ng update` reescribe tu código y hay que leer el diff; una mayor por vez; con npm 6 un conflicto de peers no detiene la instalación; no encender `strictTemplates` en la misma tanda; el riesgo está en lo que compila y se comporta distinto |
| A11 | Ver a dónde fue el ecosistema, y poder leer un ejemplo moderno sin estrellarse · las cuatro puertas del camino, standalone, `inject()`, `strict`, NgRx siete versiones después, signals, tabla de traducción moderno → stack del curso | migración real; el método de migrar (A10); el tramo 8 → 9 (A10); `node-sass` → `sass` (A12); tablas de versiones compatibles | solo comparación, nada se lleva al proyecto; el **control flow es de la 17**, no de la 16; la 16 ya no es la última línea; no mezclar versión con modernización ni con `strict` |
| A12 | Que el Mac del compañero compile · dónde estás parado (arquitectura de la máquina contra la del Node), por qué un `npm install` compila C++, las tres salidas de `node-sass`, `node-gyp` y Python en las tres plataformas, el Chromium que abre Karma, diagnóstico por síntoma, higiene de arquitectura | soporte a plataformas fuera del equipo; el par node-sass ↔ Node (A02 §1.1); por qué 14.21.3 (A03 §1.2); Docker y Colima (A13); **Puppeteer, retirado del alcance porque el proyecto no lo usa** | el curso se completa sin abrir este apéndice; tu arquitectura no es la de tu Node; borra `node_modules` antes de reinstalar; `node_modules` no se comparte jamás; dart-sass sobre el CLI 8 **no está verificado**; pelear con el entorno tiene límite de tiempo |
| A13 | Levantar el proyecto en Apple Silicon sin pelearse con el runtime · la decisión en dos ejes (runtime y arquitectura), los dos Rosetta y cuál es cuál, perfiles arm64 y amd64+vz-rosetta, dónde vive `node_modules`, devcontainer del proyecto, construir para la arquitectura correcta (`--platform`, `buildx`), cambiar de runtime sin romper nada | comparativa exhaustiva de runtimes; el Dockerfile de producción (Fase 13); `node-sass` y `node-gyp` (A12); kind (Fase 14) | **verificado en web (sept. 2026):** Rosetta 2 se mantiene completo en macOS 27 y se retira en gran parte en **macOS 28**, con un subconjunto para juegos antiguos; afecta al perfil amd64 y al Node 14 x64 de A03 §1.2. Además: el contenedor reubica el problema de arquitectura, no lo borra; `node_modules` en el bind mount rompe; el contenedor de desarrollo no es el de la Fase 13 |

---

## 🔁 4. Prompt de iteración

Estos dos se usan **dentro del chat que ya produjo el documento**, o en uno nuevo si adjuntas el `.md` vigente.

### 4.1 Iteración sobre una fase

```markdown
Revisión de `fase-{{NN}}-{{SLUG}}.md` (versión vigente: {{VERSION_O_FECHA}}).

## Qué quiero cambiar

- **Tipo de cambio:** {{corrección puntual | reescritura de sección | cambio de
  alcance | cambio de decisión heredada | ajuste de horas | ajuste de estilo}}
- **Sección o secciones afectadas:** {{números de la plantilla, p. ej. §5 y §7}}
- **El cambio, en una frase:** {{...}}
- **Por qué:** {{motivo — decisión nueva, pendiente resuelto, incoherencia
  detectada, feedback del líder}}
- **Qué NO quiero que toques:** {{lo que ya está aprobado y debe quedar igual}}

## Efecto en cadena

Este cambio puede afectar a: {{fases, apéndices, incidentes o piezas forenses}}.

Antes de editar, dime **qué más se rompe** si aplicamos esto: nombres de
acciones, selectores, componentes o archivos que otras fases ya usan; promesas
abiertas del tipo "esto lo vemos en la Fase {{M}}" que quedarían sin cerrar;
horas que dejarían de cuadrar con la tabla de `propuesta-fases-y-alcance.md` §2.

## Cómo quiero que trabajes

**Paso 1 — Preguntas y diagnóstico.** No edites todavía. Devuélveme:
a) Las preguntas que necesites para no romper coherencia.
b) El listado de impactos en cadena del punto anterior.
c) Tu propuesta concreta de edición, resumida: qué queda, qué se va, qué entra.
d) Si crees que el cambio es mala idea, dilo con argumento. Prefiero la objeción
   ahora que el arrepentimiento en la Fase {{N+3}}.

**Paso 2 — Edición.** Cuando apruebe, entrégame:
- El documento **completo** actualizado (no parches sueltos), salvo que te pida
  explícitamente solo el diff de una sección.
- Al final, un bloque corto de **changelog**: qué cambió, en qué sección, y qué
  otros archivos hay que actualizar en consecuencia, con su chat destino.

**Paso 3 — Verificación.** Pásale el checklist de §14 de la guía de estilo a las
secciones tocadas y confirma que el documento no contradice ninguna fase previa.
```

### 4.2 Iteración sobre un apéndice

```markdown
Revisión de `apendice-{{ANN_MIN}}-{{SLUG}}.md` (versión vigente:
{{VERSION_O_FECHA}}).

## Qué quiero cambiar

- **Tipo de cambio:** {{corrección técnica | versión cubierta | sección nueva |
  sección que sobra | reorganización del índice | tabla de decisión}}
- **Sección afectada:** {{...}}
- **El cambio, en una frase:** {{...}}
- **Por qué:** {{...}}
- **Qué NO quiero que toques:** {{...}}

## Contexto de coherencia

- Fases que consumen este apéndice: {{lista}}.
- ¿El cambio las obliga a ajustarse? Dímelo antes de editar.
- Si el cambio es de **versión cubierta**, verifícalo contra el `package.json`
  de LabCore. Si no lo tienes, pídemelo; no lo des por bueno de memoria.

## Cómo quiero que trabajes

**Paso 1 — Preguntas y propuesta.** No edites todavía: preguntas bloqueantes,
impacto en las fases que lo usan, y el índice resultante para que lo apruebe.

**Paso 2 — Edición.** Documento completo actualizado, con la tabla de "cuándo
usar qué" revisada (es lo que más se consulta) y las advertencias al día.

**Paso 3 — Changelog corto** al final: qué cambió y qué otros archivos hay que
tocar.
```

---

## 🧭 5. Cómo se usa esto

Abres el chat de la Fase 8, copias el prompt de §1, rellenas la fila 07 de las cuatro tablas de §2, lo pegas y **esperas las preguntas**. Respondes, apruebas el esbozo de código, recibes el documento. Si después el líder pide otra cosa, usas §4.1 en el mismo chat.

Dos advertencias de operación. La primera: las tablas de §2 y §3 son un **punto de partida sugerido**, no la tabla de horas de `propuesta-fases-y-alcance.md` §2. Cuando el chat maestro cierre el plan, este archivo se ajusta a él, no al revés. La segunda: los incidentes asociados de §2.2 están repartidos por afinidad temática, pero el reparto real lo fija el chat del cuaderno de incidentes; si no coincide, gana el cuaderno.

### Pendientes sugeridos que salieron de este chat

- 🪦 **El chat maestro de temario no existe y no hace falta.** Su prompt vivía en `_deprecado-tutorial-angular8.md`, escrito para 96h y 12 fases; su entregable habría sido el `plan-del-curso.md`, que nunca llegó a escribirse porque `propuesta-fases-y-alcance.md` §2 y el README ya cierran el reparto. Se retira.
- **Prompts para los chats sin plantilla propia** — track forense, cuaderno de incidentes, smoke y regresión. Los templates C, D y E del documento base siguen sirviendo de base, pero no incluyen la ronda de preguntas obligatoria ni la autoverificación. Chat destino: uno aparte de "prompts auxiliares".
- **Prompt de auditoría cruzada.** Cuando haya ocho o diez entregables, va a hacer falta un prompt que revise coherencia entre documentos (nombres, promesas abiertas, horas) en vez de dentro de uno solo. Chat destino: sala de dudas o un chat de QA editorial.
