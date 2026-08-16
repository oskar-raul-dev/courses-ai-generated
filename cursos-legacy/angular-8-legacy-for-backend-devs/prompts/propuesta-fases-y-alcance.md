# 🗺️ Propuesta de fases, apéndices y alcance

Documento de encuadre. Consolida las decisiones tomadas sobre LabCore y reparte
el presupuesto:
**108h de fases + 14h de cuaderno de incidentes = 122h**.

---

## ✅ 1. Decisiones cerradas

Estas respuestas ya no se discuten en los chats siguientes; se dan por hechas.

| Pregunta | Decisión | Qué cambia |
|---|---|---|
| Gestión de estado | **NgRx** | Fase 1 se vuelve la más densa; nace apéndice de NgRx; el CRUD se hace con store desde el día uno |
| Testing preexistente | **Cero specs** | La fase de testing pasa de "escribir tests" a "montar todo desde nada y llegar a coverage rápido" |
| CSS | **Bootstrap 4 + Material**, versiones de la época | A02 deja de ser opcional; aparece el tema de conflictos de cascada |
| Angular | **8.2.x** | Stack confirmado sin cambios |
| PDF | **Generación en cliente** | La fase de entrega se vuelve técnica; nace apéndice de PDF |
| Gráficos | **Chart.js + ngx-charts** | El dashboard gana material forense real (leaks, re-render) |
| Auth | **JWT en storage**, sin backend | Sin refresh token real; el interceptor sigue siendo el centro |
| Idiomas | **EN / ES / FR** — el proyecto se escribe en español pero con i18n montado | i18n asciende a fase propia; nace apéndice |
| Equipos | **Windows 11 mayoritario**; macOS a apéndice | Todo lo de Apple Silicon sale del cuerpo del curso |
| Ambiente de desarrollo | **Imagen dockerizada**, sin cluster | La Fase 13 enseña Docker + nginx, no orquestación |
| Producción | **Kubernetes**, sin atarse a distribución | Kubernetes va a apéndice de consulta; el cluster local es fase opcional |

### El tema central que ordena todo el final del curso

Angular 8 hornea `environment.ts` **en tiempo de compilación**. Cualquier
orquestador espera inyectar configuración **en tiempo de arranque**. Esa fricción
es la fuente de la mitad de los "funciona en UAT y no en PROD" de cualquier SPA
en contenedores, y se puede enseñar entera con dos `docker run` y variables de
entorno distintas. No hace falta cluster para que caiga la ficha.

Por eso la Fase 13 es obligatoria y de Docker; el cluster es opcional.

---

## ⏱️ 2. Reparto horario: 122h

**108h de fases (horas del track forense incluidas) + 14h de cuaderno de incidentes.**

Las horas de apéndices **no cuentan** dentro de las 120: son consulta bajo
demanda. La Fase 14 tampoco: es opcional y va sin horas asignadas al calendario.

| Fase | Nombre | Horas | Nota |
|---|---|---|---|
| 🛠️ 0 | Setup + hola mundo | **8h** | Bootstrap y Material conviviendo desde el arranque |
| 🏗️ 1 | Estructura base + NgRx | **12h** | La más densa del curso |
| 🌐 2 | Internacionalización | **6h** | 🆕 sale de la Fase 1 |
| 🔐 3 | Autenticación mínima | **8h** | |
| 🧪 4 | Mock API + caos | **6h** | El middleware se construye, no se copia |
| 🏥 5 | Pacientes | **6h** | Primer CRUD con store; fija el molde de slice |
| 📋 6 | Órdenes | **4h** | 🆕 sale de la Fase 5: el molde repetido, y lo que no se copia |
| 🧫 7 | Muestras y cadena de custodia | **8h** | |
| 🧬 8 | Resultados y rangos versionados | **10h** | |
| 📦 9 | Entrega y PDF en cliente | **8h** | |
| 📊 10 | Dashboard | **8h** | Chart.js + ngx-charts conviviendo |
| 📜 11 | Trazabilidad y audit log | **7h** | +1h: §5.10 el `before` y §5.11 el cruce entre slices |
| ✅ 12 | Testing desde cero + coverage | **10h** | |
| 🚚 13 | Build, despliegue y cierre | **7h** | 🆕 Docker + nginx + config en runtime · +1h: §5.9 los diccionarios de i18n en el contenedor |
| 🔥 14 | Ambiente "casi prod" con kind | **—** | 🆕 **Opcional.** Sin horas en el calendario |
| | **Subtotal fases** | **108h** | |
| 📓 | **Cuaderno de incidentes** | **14h** | 21 incidentes, ≈3.5h/semana |
| | **Total** | **122h** | |

### Sobre la numeración de la Fase 14

Va numerada **por convención de archivos**: el entregable es
`14-casi-prod-kind.md` y así el directorio se ordena solo por nombre. El número
es infraestructura, no jerarquía. Su carácter opcional se marca con 🔥, con
guion en la columna de horas, y con una línea explícita al inicio del capítulo:
*"esta fase no es requisito del onboarding; el líder la asigna a quien tenga
interés."*

### Sobre las 15 fases (0-14)

El documento base decía "12 fases máximo (0-11), no inflar". Ahora son 15, pero
solo 14 obligatorias y por razones concretas: i18n con tres idiomas no cabía
dentro de "estructura base"; el despliegue en contenedor dejó de ser opcional
cuando confirmamos que PROD es Kubernetes; y pacientes y órdenes, juntas, daban
una fase de 1.400 líneas que ninguna sesión de trabajo termina de una vez. La 14
no cuenta contra ese límite porque no ocupa calendario.

---

## 🪜 3. Fases con alcance ajustado

Solo detallo las nuevas o las que cambian.

### 🛠️ Fase 0 — Setup + hola mundo (8h)

Sube de 6h porque hay dos sistemas de estilos que instalar y hacer convivir.
Entra: nvm-windows, Angular CLI 8, Bootstrap 4 y Material juntos, componente
único, form, POST a un endpoint hardcodeado. El primer choque de cascada entre
ambos ocurre aquí y se explica aquí.

### 🏗️ Fase 1 — Estructura base y store (12h)

Módulos y layout, router con vistas placeholder, y **NgRx** con espacio para
respirar: store, actions, reducers, effects, selectores y Redux DevTools.
También dónde vive la configuración por ambiente, que se cobra en la Fase 13.

💸 Deuda intencional: el store se monta al estilo de la época —sin
`createFeature`, sin `createActionGroup`, reducers en `switch`. No se paga.

### 🌐 Fase 2 — Internacionalización (6h) 🆕

El árbol de traducciones, el selector de idioma, pluralización, y formatos de
fecha y número por locale. Se escribe todo en español pero con las tres llaves
puestas.

Material forense: la clave que falta y sale cruda en pantalla, el idioma que no
cambia hasta recargar, y la fecha formateada con el locale del navegador en vez
del de la app.

🪦 **Resuelto al escribir la fase: runtime con `@ngx-translate`** (`core@11.0.1`
y `http-loader@4.0.0`, que son las últimas líneas que declaran Angular 8 como
peer). Se descartó el i18n nativo compile-time porque obligaría a un build y un
despliegue por idioma, y porque el selector de idioma en caliente —que es donde
vive medio material forense de la fase— no existe en esa familia. La comparación
entre las dos opciones quedó escrita en §4 de `02-i18n.md`, no se borró: el
estudiante tiene que saber por qué LabCore eligió lo que eligió.

### 🧪 Fase 4 — Mock API y caos (6h)

El middleware de caos se **construye** paso a paso en vez de entregarse hecho.
Es código propio del curso y escribirlo enseña más que usarlo. Entra
json-server, `db.json`, el inyector de fallos, y los effects que lo consumen. El
caos se observa desde el store: se ve la acción de fallo entrando.

### 🚚 Fase 13 — Build, despliegue y cierre (7h)

Todo con Docker, sin orquestador. Entra:

- Dockerfile multi-stage: build con Node 12/14, runtime con nginx.
- `try_files` y el 404 al recargar una ruta profunda del router.
- **El corazón de la fase**: un `entrypoint.sh` que escribe la configuración
  desde variables de entorno antes de arrancar nginx. La misma imagen levantada
  dos veces con valores distintos, comportándose distinto. Ahí cae la ficha de
  "la imagen es la misma en UAT y en PROD; lo que cambia es lo de afuera".
- Los diccionarios de i18n servidos desde el contenedor: caché de archivos sin
  hash, el `try_files` que devuelve `index.html` en vez de un 404, y el
  `base href` cuando la aplicación vive en un subdirectorio. Es la ampliación
  que suma la hora extra y cierra lo que la Fase 2 dejó abierto.
- Cierre: checklist de hotfix y guiño hacia Angular 9 e Ivy.

### 🔥 Fase 14 — Ambiente "casi prod" con kind (opcional, sin horas) 🆕

Para quien quiera ver su imagen corriendo en un cluster de verdad. Toma la
imagen de la Fase 13 sin modificarla y la lleva a un Kubernetes local con kind.

Entra: crear el cluster, cargar la imagen local al cluster (el primer tropiezo
de todo el mundo —el nodo no ve tus imágenes de Docker—, convertido en ejercicio
en vez de escondido), Deployment y Service, el ConfigMap montado como volumen
alimentando el mismo `entrypoint.sh`, Ingress, y el rolling update en vivo.

Corre sobre **el runtime de contenedores que ya tengas** (Docker Desktop, Colima,
Podman). No se ata a ninguno.

⚠️ En Apple Silicon la imagen debe ser arm64 o el pod queda en `CrashLoopBackOff`
sin explicar por qué. Enlaza directo con los apéndices A12 (dependencias en arm64) y A13 (Docker + Colima en Apple Silicon).

---

## 🎨 4. Apéndices

| Apéndice | Contenido | Horas |
|---|---|---|
| **A01 Angular Material** | Theming, form-field, table, dialog, snackbar | 3h |
| **A02 Bootstrap 4 + Sass** | Convivencia con Material: quién gana en la cascada, grid con componentes de Material, paleta | 3h |
| **A03 Node y npm** | Lockfiles, `npm ci` vs `npm i`, dependencies vs devDependencies | 2h |
| **A04 Webpack oculto** | Qué hace el CLI 8 por debajo, dónde vive el `ng eject` que ya no existe | 2h |
| **A05 RxJS de supervivencia** | `map`, `filter`, `tap`, `catchError`, `switchMap`, `take` | 3h |
| **A06 NgRx 8** | Store, actions, reducers, effects, selectores, DevTools. Al estilo de la época | 4h |
| **A07 i18n en Angular 8** | API de `@ngx-translate` 11, árbol de claves y claves construidas, pluralización, locales y formatos, traducir fuera de la plantilla, el bundle por idioma | 3h |
| **A08 PDF en cliente** | Armado del documento más allá de cinco líneas, fuentes embebidas (Roboto normal y bold), la mecánica de los acentos rotos, salidas y peso, límites de la librería, `jspdf-autotable` y `pdfmake` | 3h |
| **A09 Kubernetes para el dev de front** 🆕 | Leer un manifiesto ajeno, qué le pasa a tu imagen después del build (registry, tag contra digest), el vocabulario completo, ConfigMap y Secret (y por qué un Secret no es un secreto), la caja de herramientas 👁️/✍️, los estados de un pod traducidos, y la advertencia obligatoria sobre el cluster real | 3h |
| **A10 Migración 8 → 9** (opcional) | Ivy en lo que se nota, `ng update` y sus schematics, `ngcc`, los errores nuevos, la ficha de validación por dependencia, el ensayo en rama desechable, cómo estimar el costo y cuándo NO migrar | 3h |
| **A11 Migración 9 → 16** (opcional) | Las cuatro puertas del camino largo, standalone, `inject()`, `strict`, NgRx siete versiones después, signals, y la tabla para traducir un ejemplo moderno al stack del curso. El control flow es de la 17 y se declara como horizonte | 2h |
| **A12 Dependencias problemáticas en arm64 / M1** | Dónde estás parado (máquina contra Node), por qué un `npm install` compila C++, las tres salidas de `node-sass`, `node-gyp` y Python en las tres plataformas, el Chromium de Karma, diagnóstico por síntoma e higiene de arquitectura | 2h |
| **A13 Docker + Colima en Apple Silicon** | La decisión en dos ejes (runtime y arquitectura), los dos Rosetta y su fecha de retirada, perfiles arm64 y amd64+vz-rosetta, dónde vive `node_modules`, un devcontainer para el proyecto, construir para la arquitectura correcta, y cambiar de runtime sin romper nada | 2h |

A12 y A13 quedan marcados como **opcionales por plataforma**: el curso se toma
completo sin abrirlos. Existen para que cualquiera con Mac pueda seguirlo.

**Nota obligatoria al cierre de A09:** un párrafo advirtiendo que el cluster real
de la empresa tiene particularidades que el Kubernetes de libro no cubre —el
contenedor puede no correr como root, y eso rompe nginx en el puerto 80— con la
instrucción de preguntarle al equipo de plataforma antes de improvisar. Sin esa
advertencia, el primer estudiante que despliegue va a asumir que su Dockerfile
de curso funciona tal cual.

---

## 🕵️ 5. Track forense

Sus horas van repartidas en las 14 fases obligatorias; sus archivos son propios:
`forense-master.md` y una pieza `forense-fase-NN.md` por fase.

| Fase | Pieza forense |
|---|---|
| 0 | Consola y Network tab como fuente de verdad |
| 1 | Redux DevTools como máquina del tiempo: leer el flujo de acciones |
| 2 | Traducción faltante y locale equivocado: cómo se ven en pantalla y en consola |
| 3 | Debug de interceptor HTTP: request-id, breakpoints condicionales |
| 4 | El store bajo caos: qué acción se despacha cuando el backend devuelve 500 |
| 5 | Reproducir un bug de usuario desde el ticket, sin acceso a producción |
| 6 | El estado que no existe hasta que alguien navega a su ruta |
| 7 | Debug de máquina de estados: transición ilegal en logs |
| 8 | Source maps en producción: cómo activarlos y por qué a veces mienten |
| 9 | El PDF con datos stale: rastrear de dónde salió la copia vieja del estado |
| 10 | Performance panel: suscripciones huérfanas y gráficos que se redibujan de más |
| 11 | El action log como reconstrucción de incidente |
| 12 | Test de regresión que reproduce el bug antes del fix, empezando por reducers |
| 13 | Diff de ambientes, config horneada vs inyectada, y feature flags para hotfix |
| 14 | 🔥 `kubectl logs` y `describe` cuando el pod no arranca |

Cierre del track: el **checklist de hotfix** de una página que el estudiante se
lleva.

---

## 📓 6. Cuaderno de incidentes (14h)

21 incidentes, ≈3.5h por semana. Distribución por dificultad:

- **Semana 1** (fases 0-4): 4-5 🟢 — configuración, endpoints mal, CORS.
- **Semana 2** (fases 5-8): 5-6 🟡 — máquinas de estado rotas, validación floja,
  rangos mal aplicados.
- **Semana 3** (fases 9-11): 5-6 🟠 — audit log incompleto, PDF con datos stale,
  race condition en validación.
- **Semana 4** (fases 12-13): 4-5 🔴 — intermitentes, memory leak de suscripción,
  orden vencida que se validó igual, config apuntando al ambiente equivocado.

Categorías nuevas que habilitaron las decisiones de este chat:

- **Estado**: acción que muta el store fuera del reducer; selector que devuelve
  referencia nueva en cada llamada y redibuja todo.
- **i18n**: clave faltante que se muestra cruda; fecha con el locale equivocado.
- **Despliegue**: URL del API horneada apuntando a UAT; router que devuelve 404
  al recargar una ruta profunda.

Se mantienen: máquina de estados, concurrencia, tiempo, normativo, trazabilidad,
integración, performance, UI.

---

## 📁 7. Convención de nombres de archivo

Todo ordenable por nombre, y sin desfase entre el número de fase y el número de
archivo: el prefijo **es** el número de la fase.

```
README.md
00-setup-hola-mundo.md
01-estructura-base-ngrx.md
02-i18n.md
03-autenticacion.md
04-mock-api-caos.md
05-pacientes.md
06-ordenes.md
07-muestras-custodia.md
08-resultados-rangos.md
09-entrega-pdf.md
10-dashboard.md
11-trazabilidad-audit-log.md
12-testing-coverage.md
13-build-despliegue.md
14-casi-prod-kind.md
a01-material.md ... a13-docker-colima.md
forense-master.md
forense-fase-00.md ... forense-fase-14.md
cuaderno-incidentes.md
```

> 🪦 **Corregido al escribir el curso.** Este documento proponía prefijos
> `fase-NN-` y `apendice-aNN-`. No sobrevivieron: el prefijo redundante alargaba
> cada enlace cruzado sin aportar nada, porque el número ya ordena y la
> extensión ya dice que es un capítulo. La convención vigente es la de arriba y
> es la que usan los archivos en disco.

> 🪦 **Corregido al escribir el cuaderno.** Este esquema preveía un archivo por
> incidente (`incidente-01-*.md` … `incidente-20-*.md`). No sobrevivió al primer
> borrador: los incidentes viven dentro de `cuaderno-incidentes.md`, que
> es el único archivo de incidentes del curso, porque el estudiante trabaja sin
> instructor y necesita índice, enunciado, pistas, solución y su propia bitácora
> a un scroll de distancia. Los IDs siguen siendo globales y no se reasignan.

Dos dígitos en todo, incluidos apéndices, para que `a09` no quede después de
`a10`.

---

## 📌 8. Versiones y decisiones: todas cerradas

**Ninguna versión queda pendiente.** Todas están fijadas y comprobadas contra el
registro de npm, y el curso no depende de ningún `package.json` externo: es lo que
lo hace autocontenido. Quien llegue con un proyecto heredado propio compara su
árbol contra este con el procedimiento del **Apéndice A03 §8**.

| Tema | Cómo quedó | Dónde vive |
|---|---|---|
| i18n | 🪦 Runtime con `@ngx-translate` **11.0.1** + `http-loader` **4.0.0** | Fase 2 §4 · A07 |
| NgRx | 🪦 **8.6.0**, la última de la línea 8 | Fase 1 §5.1 · A06 |
| Gráficos | 🪦 `ng2-charts` **2.4.3** + `chart.js` **2.9.4** vivos; `@swimlane/ngx-charts` **12.1.0** heredada. El hueco de año y medio entre las dos fechas *es* la deuda 💸 | Fase 10 §4 y §5.6 |
| PDF | 🪦 **`jspdf@1.5.3`**. `jspdf-autotable` 3.5.x y `pdfmake` 0.1.x, comparadas y **no instaladas** | Fase 9 · A08 §8 |
| Bootstrap y Sass | 🪦 **4.6.2** compilado con `node-sass` **4.14.1**; Material con el prebuilt `indigo-pink` | A02 §1 y §5 |
| Mock | 🪦 `json-server` **0.16.3**, `express` **4.17.1**, `jsonwebtoken` **8.5.1**. Son del mock, o sea código del curso | Fase 3 §5.1 · Fase 4 §5.2 |
| Coverage | 🪦 **80% global** con exclusiones, como recomendación del curso. Un equipo con otra cifra toca un solo sitio | Fase 12 §5.7 |
| Config en runtime | 🪦 `assets/config.json` + `APP_INITIALIZER` + `entrypoint.sh`. Es la tesis del curso, no un detalle | Fase 13 |
| Acceso al cluster | 🪦 Lectura. A09 marca cada comando 👁️ o ✍️ y sirve igual si el equipo solo entrega el artefacto | A09 |
| Smoke tests | 🪦 **Playwright fuera del alcance.** Se declaraba en el stack y ninguna fase lo desarrollaba | A12 §5 conserva el aviso |

Lo que sigue abierto son **decisiones de proyecto**, no de escritura, y ninguna
frena una línea: si el código nuevo sigue el TS-0 heredado (**A11 §5**), si se paga
la deuda de la imagen non-root (**A09 §8**), y si se versiona el `.devcontainer/`
del **A13 §6**.

---

## 🚦 9. Siguiente paso

Ya no queda ninguna respuesta bloqueante: i18n se resolvió por runtime, las
catorce fases obligatorias están escritas y el track forense está cerrado
—`forense-master.md` más las quince piezas `forense-fase-00.md` a
`forense-fase-14.md`—. Lo único que sigue son los **veintiún enunciados** del
cuaderno de incidentes, cuyos IDs ya están reservados en el índice de
`cuaderno-incidentes.md`.

Los pendientes de versión que quedan (§8) no frenan nada: están declarados con
⚠️ dentro de cada fase y son **decisiones de proyecto**, no huecos de información.
El stack del curso está cerrado y es autocontenido: no se verifica contra ningún
`package.json` externo. Quien llegue con un sistema propio compara su árbol
contra el del curso en el **Apéndice A03 §8**.

---

## 🔥 El track opcional de backend

Este documento cubre **el track base y solo el track base**. El track opcional de
backend —nueve fases `be00–be08`, doce apéndices `bea-01–bea-12`, 80h más 8h de
cuaderno, todo declarado **fuera de las 122h**— tiene su propio documento de
encuadre y es su fuente de verdad:

**[`propuesta-fases-backend.md`](propuesta-fases-backend.md)**

Sus prompts de redacción viven aparte, en `prompts-backend-fase.md` y
`prompts-backend-apendice.md`, y no se mezclan con los del track base: un chat de
la Fase 7 no debe arrastrar contexto de Java 8 + Spring Boot 2.1 + MongoDB que no necesita.
