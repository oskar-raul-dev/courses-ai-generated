# 🗺️ Propuesta de fases, apéndices y alcance
## Tutorial Angular 16 — Inspecciones y certificaciones

Documento de encuadre. Consolida las decisiones tomadas sobre CertCore y reparte
el presupuesto:
**108h de fases + 14h de cuaderno de incidentes = 122h**.

> 🧭 Junto con `alcance-del-proyecto.md`, este documento **depreca a
> `_deprecado-tutorial-angular16.md`**. La cifra de 96h, el mapa de 12 fases y la
> numeración de apéndices A1-A8 de aquel documento ya no circulan.

---

## ✅ 1. Decisiones cerradas

Estas respuestas ya no se discuten en los chats siguientes; se dan por hechas.

| Pregunta | Decisión | Qué cambia |
|---|---|---|
| Naturaleza del sistema | **CertCore es ficticio y el curso lo construye** | Se retira el NDA como coartada; nace la regla "si lo afirmas, muéstralo" (guía §11) |
| Gestión de estado | **Servicios con `BehaviorSubject`** | Nace la Fase 4 y el apéndice A07; el CRUD se hace contra servicios de estado, no contra el `HttpClient` desde el componente |
| Estilo de componentes | **Mixto y deliberado**: NgModule en Fases 1-4, standalone desde la Fase 5 | La Fase 5 deja de ser "migración" y pasa a ser "convivencia"; el legacy no se refactoriza |
| Inyección | **`inject()` en código nuevo, `constructor` en legacy** | A04 se vuelve apéndice de consulta permanente |
| TypeScript | **`strict: true` (TS-2)** desde la Fase 0 | Aparece una familia entera de bugs de `null` vs `undefined` que el Track A no tiene |
| Signals | **Pincelada, no estilo** | Fase 12 los lee, A11 los proyecta; ninguna fase los usa en producción |
| i18n | **Fuera del cuerpo**: español literal en plantilla | El presupuesto se va al motor de plantillas; apéndice A13 🔥 para quien lo necesite |
| CSS | **Material 16 (MDC)** principal; Bootstrap 5 **opcional** en A02 | Ninguna fase asume Bootstrap |
| Testing preexistente | **Cero specs** | La Fase 12 monta todo desde nada y llega a coverage medible |
| PDF | **Generación en cliente** con `jspdf` 2.5.1 | La Fase 10 se vuelve técnica; nace A08 |
| Gráficos | **ng2-charts 4 + Chart.js 4** | El dashboard gana material forense real |
| Auth | **JWT en storage**, sin backend | Sin refresh token real; el interceptor sigue siendo el centro |
| Producción | **Contenedor con nginx**; cluster opcional | La Fase 13 enseña Docker + config en runtime, no orquestación |
| Apple Silicon | **A12 🔥**, fuera del cuerpo | Node 18 no da guerra en M-series; lo que la da es la arquitectura de la imagen |

### El tema central que ordena todo el final del curso

Angular 16 hornea `environment.ts` **en tiempo de compilación**, exactamente
igual que Angular 8. Cualquier orquestador espera inyectar configuración **en
tiempo de arranque**. Ocho versiones mayores no movieron esa piedra, y ahí está
la lección: no es un defecto de una versión vieja, es una propiedad de las SPAs.

Por eso la Fase 13 es obligatoria y de Docker; el cluster es opcional.

### El tema central que ordena todo el medio del curso

**Una plantilla versionada no se re-renderiza con otra versión.** Nunca. Las
Fases 7 y 8 son 26h porque esa regla, que se enuncia en una línea, se rompe de
seis maneras distintas y cada una produce un ticket diferente.

---

## ⏱️ 2. Reparto horario: 122h

**108h de fases (track forense embebido) + 14h de cuaderno de incidentes.**

Las horas de apéndices **no cuentan** dentro de las 122: son consulta bajo
demanda. La Fase 14 tampoco: es opcional y va sin horas asignadas al calendario.

| Fase | Nombre | Horas | Nota |
|---|---|---|---|
| 🛠️ 0 | Setup + hola mundo standalone | **6h** | Node 18, CLI 16, `bootstrapApplication`, TS strict desde el minuto uno |
| 🏗️ 1 | Estructura base con NgModules | **8h** | El legacy que se hereda: módulos, routing, layout, core/shared |
| 🔐 2 | Autenticación mínima | **6h** | Guard funcional, interceptor funcional con `inject()`, JWT en storage |
| 🧪 3 | Mock API + Express caos | **6h** | El middleware se construye, no se copia |
| 🧠 4 | Estado con servicios y `BehaviorSubject` | **7h** | El patrón que sostiene el resto del curso |
| 🧩 5 | Standalone conviviendo con NgModules | **6h** | Convivencia, no migración |
| 👥 6 | Clientes y activos | **8h** | Primer CRUD completo, formularios tipados, Material 16 |
| 📋 7 | **Plantillas versionadas** ⭐ | **14h** | La fase más pesada del curso |
| 📝 8 | **Formulario dinámico desde plantilla** ⭐ | **12h** | `FormGroup` construido en runtime |
| ⚠️ 9 | Hallazgos y severidad | **6h** | El `critical` que bloquea el certificado |
| 📜 10 | Certificados, vigencia y PDF | **8h** | Zona horaria + jsPDF en cliente |
| 📊 11 | Dashboard y alertas | **6h** | Por vencer a 30/60/90 días |
| ✅ 12 | Testing desde cero + coverage | **8h** | Jasmine, TestBed, coverage, y el guiño a Signals |
| 🚚 13 | Build, despliegue y cierre | **7h** | Docker + nginx + config en runtime |
| 🔥 14 | Ambiente "casi prod" con kind | **—** | **Opcional.** Sin horas en el calendario |
| | **Subtotal fases** | **108h** | |
| 📓 | **Cuaderno de incidentes** | **14h** | 20 incidentes, ≈3.5h por semana |
| | **Total** | **122h** | |

Son **veintiséis días de media jornada**, algo más que el mes que preveía el
documento base. La diferencia se la comen tres cosas que aquel no contemplaba: el
estado (Fase 4), la convivencia de estilos (Fase 5) y el despliegue (Fase 13).

### Sobre la numeración de la Fase 14

Va numerada **por convención de archivos**: el entregable es
`14-casi-prod-kind.md` y así el directorio se ordena solo por nombre. El número
es infraestructura, no jerarquía. Su carácter opcional se marca con 🔥, con guion
en la columna de horas, y con una línea explícita al inicio del capítulo: *"esta
fase no es requisito del onboarding; el líder la asigna a quien tenga interés."*

---

## 🪜 3. Fases con alcance ajustado

Detallo las que no se explican solas con el título.

### 🛠️ Fase 0 — Setup + hola mundo standalone (6h)

Node 18 con `.nvmrc`, Angular CLI 16, y un `bootstrapApplication` sin un solo
NgModule. Un componente, un formulario reactivo tipado, un POST a un endpoint
hardcodeado. **`strict: true` desde el primer archivo**, para que el primer
`Object is possibly 'null'` llegue el día uno y no en la Fase 8.

Es deliberado que la primera fase enseñe el estilo *nuevo* y la siguiente el
*viejo*: así el estudiante conoce el destino antes de conocer la herencia, y
puede leer la Fase 1 preguntándose *"¿por qué está así?"* en vez de creer que es
la única forma.

### 🏗️ Fase 1 — Estructura base con NgModules (8h)

Aquí llega la herencia. `AppModule`, `CoreModule`, `SharedModule`, módulos de
feature con lazy loading, `RouterModule.forChild`, y componentes declarados en
`declarations`. Se explica qué resolvía cada pieza y qué la reemplazó.

💸 Deuda intencional: el `SharedModule` que reexporta media librería de Material
"por comodidad". **Se paga en la Fase 5**, y es el primer sitio donde el
estudiante ve una deuda cobrarse de verdad.

### 🔐 Fase 2 — Autenticación mínima (6h)

Login contra el mock, JWT en `localStorage`, **guard funcional**
(`CanActivateFn`) e **interceptor funcional** (`HttpInterceptorFn`), los dos con
`inject()`. Es la primera vez que el código nuevo aparece dentro de una app de
NgModules, y el `provideHttpClient(withInterceptors(...))` conviviendo con
`HTTP_INTERCEPTORS` es material forense por sí solo.

### 🧪 Fase 3 — Mock API y caos (6h)

El middleware de caos se **construye** paso a paso en vez de entregarse hecho. Es
código propio del curso y escribirlo enseña más que usarlo. Entra json-server,
`db.json` con el modelo de §5.1 del alcance, el inyector de fallos (latencia, 500
intermitente, payload malformado, CORS roto, token expirado, timeout) y los
servicios tipados que lo consumen.

### 🧠 Fase 4 — Estado con servicios y `BehaviorSubject` (7h)

La fase que el documento base no tenía y sin la cual las siguientes no se
sostienen. Un servicio de estado por feature: `BehaviorSubject` privado,
`Observable` público de sólo lectura, métodos que reemplazan el estado en vez de
mutarlo, y el `providedIn: 'root'` frente al provider de ruta.

También el ciclo de vida completo: quién se suscribe, quién se desuscribe,
`takeUntilDestroyed`, `async` pipe, y por qué un `BehaviorSubject` en un servicio
raíz sobrevive a todas las navegaciones aunque el componente ya no exista. La
mitad de las fugas del curso nacen aquí y se cazan aquí.

💸 Deuda intencional: no hay inmutabilidad forzada. Un servicio expone el array y
un componente lo muta. **Se paga en la Fase 6**, cuando la lista deja de
refrescarse con `OnPush`.

### 🧩 Fase 5 — Standalone conviviendo con NgModules (6h)

No es una migración: es aprender a vivir con las dos generaciones. Se convierte
**un** módulo de feature a standalone —el que la Fase 6 va a necesitar—, se deja
el resto intacto, y se documenta la regla del proyecto: *código nuevo standalone,
código heredado se toca lo mínimo.*

Aquí se cobra la deuda del `SharedModule` de la Fase 1: los componentes standalone
importan lo que usan y ni una cosa más, y se mide la diferencia en el bundle. Se
paga la parte medible —los módulos de Material que no usa nadie— y el resto queda
declarado y **sin pagar**, porque saldarlo exige convertir los módulos heredados
que lo importan, es decir, la migración que este curso decidió no hacer. Que un
módulo compartido lo importe alguien *eager* es lo que lo mete en el bundle
inicial, y esa es la lección que se lleva el estudiante.

Material forense: cómo se ve en consola un `NullInjectorError` de un standalone
que olvidó importar, frente al mismo error en un NgModule. No se parecen, y saber
distinguirlos ahorra media tarde.

### 📋 Fase 7 — Plantillas versionadas ⭐ (14h)

El corazón. La plantilla como entidad de primera clase: `id`, `version`,
`validFrom`, `validUntil`, `items[]`. El editor que crea la v2 sin tocar la v1. La
resolución de "qué versión aplica a esta fecha", que suena trivial y no lo es. Y
el invariante que el curso repite hasta el cansancio: **una inspección guarda su
`templateVersion` y se lee siempre con ésa.**

Material forense: el debug del versionado. *"¿Por qué esta inspección se ve con
la plantilla vieja?"* — y su gemela malvada, *"¿por qué esta inspección de hace
un año se ve con la plantilla nueva?"*, que es un bug de verdad y la anterior no.

### 📝 Fase 8 — Formulario dinámico desde plantilla ⭐ (12h)

Construir un `FormGroup` en runtime desde datos, con tipos. Validadores derivados
de `photoRequired` y de `criteria`. Respuestas que se guardan con su versión.
`valueChanges` que dispara guardado y no se muerde la cola. Autosave con
`debounceTime` y el estado `dirty` que sobrevive a una navegación.

Material forense: el bucle infinito de `valueChanges`, el `FormControl` huérfano
que quedó tras cambiar de plantilla, y `ExpressionChangedAfterItHasBeenCheckedError`
en su hábitat natural.

### 📜 Fase 10 — Certificados, vigencia y PDF (8h)

Emisión bloqueada por hallazgo `critical`, vigencia con zona horaria explícita,
renovación programada, y el PDF generado en cliente con jsPDF: fuentes con
acentos, tabla de hallazgos, y el peso del bundle cuando alguien importa la
librería en el módulo raíz.

Material forense: el certificado que "venció ayer" según el servidor y hoy según
el usuario. Nunca es un bug de fechas: es un bug de decidir a qué hora del día
vence algo.

### 🚚 Fase 13 — Build, despliegue y cierre (7h)

Todo con Docker, sin orquestador. Entra:

- Dockerfile multi-stage: build con `node:18.18.2-alpine`, runtime con
  `nginx:1.25-alpine`.
- `try_files` y el 404 al recargar una ruta profunda del router.
- **El corazón de la fase**: un `entrypoint.sh` que escribe la configuración desde
  variables de entorno antes de arrancar nginx, leída por la app con
  `APP_INITIALIZER` desde `assets/config.json`. La misma imagen levantada dos
  veces con valores distintos, comportándose distinto.
- Presupuestos de bundle del CLI 16, source maps en producción y cómo se ve un
  stack trace minificado cuando sí los tienes y cuando no.
- Cierre: checklist de hotfix de una página y guiño hacia Angular 17.

### 🔥 Fase 14 — Ambiente "casi prod" con kind (opcional, sin horas)

Toma la imagen de la Fase 13 sin modificarla y la lleva a un Kubernetes local con
kind: crear el cluster, cargar la imagen local (el primer tropiezo de todo el
mundo —el nodo no ve tus imágenes—, convertido en ejercicio en vez de escondido),
Deployment, Service, el ConfigMap montado como volumen alimentando el mismo
`entrypoint.sh`, Ingress y rolling update en vivo.

Corre sobre **el runtime de contenedores que ya tengas**. No se ata a ninguno.

⚠️ En Apple Silicon la imagen debe ser arm64 o el pod queda en `CrashLoopBackOff`
sin explicar por qué. Enlaza con **A12**.

---

## 🎨 4. Apéndices

Consulta rápida. Sus horas **no cuentan** en el calendario.

| Apéndice | Contenido | Horas |
|---|---|---|
| **A01 Angular Material 16 (MDC)** | Theming con `define-palette` y tokens, el cambio de MDC y qué se rompió respecto a Material 14, `mat-form-field` moderno, table, dialog, snackbar | 3h |
| **A02 Bootstrap 5 + Sass** 🔥 | Convivencia con Material: quién gana en la cascada, grid con componentes de Material, variables Sass. Opcional: ninguna fase lo asume | 2h |
| **A03 Node y npm** | `.nvmrc`, lockfile v3, `npm ci` vs `npm i`, peer deps en la era npm 9, y cómo comparar tu árbol contra el del curso | 2h |
| **A04 `inject()` vs constructor** | Qué cambia, dónde se puede llamar y dónde explota (contexto de inyección), herencia sin `super()` interminable, y la regla del proyecto | 2h |
| **A05 Formularios reactivos tipados** | `FormGroup<T>`, `FormControl<T \| null>` y el `nonNullable` que casi nadie pone, `FormBuilder` tipado, formularios construidos en runtime | 3h |
| **A06 RxJS 7 idiomático** | Los operadores que sí aparecen: `map`, `switchMap`, `combineLatest`, `debounceTime`, `catchError`, `takeUntilDestroyed`. Y los tres antipatrones que produce cada uno | 3h |
| **A07 Estado con servicios** | El patrón `BehaviorSubject` privado + `Observable` público, `providedIn` y ámbitos, cuándo el patrón se queda corto, y qué resolvería NgRx —que CertCore no usa— | 3h |
| **A08 PDF en cliente con jsPDF 2** | Armado del documento más allá de cinco líneas, fuentes embebidas y acentos, tablas con `jspdf-autotable`, peso del bundle y carga diferida, límites de la librería | 3h |
| **A09 Docker y Kubernetes para el dev de front** | Leer un manifiesto ajeno, qué le pasa a tu imagen después del build (registry, tag contra digest), ConfigMap y Secret (y por qué un Secret no es un secreto), la caja de herramientas 👁️/✍️, estados de un pod traducidos | 3h |
| **A10 Puente Angular 8/9 → 16** | Para lectores del Track A: las cuatro puertas del camino largo, Ivy, `strict`, standalone, `inject()`, RxJS 6 → 7, tipado de formularios, y la tabla para traducir un ejemplo de LabCore al stack de CertCore | 3h |
| **A11 Puente Angular 16 → 17+** 🔥 | Signals de verdad, control flow `@if/@for/@switch`, deferrable views, el nuevo builder de esbuild. Horizonte, no material de examen | 2h |
| **A12 macOS Apple Silicon y arm64** 🔥 | Dónde estás parado (máquina contra Node contra imagen), Colima y Docker Desktop, el Chromium de Karma en arm64, imágenes multi-arch para la Fase 13, diagnóstico por síntoma 🩺 | 2h |
| **A13 i18n moderno** 🔥 | Qué haría falta para internacionalizar CertCore: `@angular/localize` compile-time frente a `@ngx-translate` en runtime, el costo de cada uno, y por qué este curso no lo hace. Lectura, no ejercicio | 2h |

A02, A11, A12 y A13 quedan marcados como **opcionales**: el curso se toma
completo sin abrirlos.

**Nota obligatoria al cierre de A09:** un párrafo advirtiendo que el cluster real
de la empresa tiene particularidades que el Kubernetes de libro no cubre —el
contenedor puede no correr como root, y eso rompe nginx en el puerto 80— con la
instrucción de preguntarle al equipo de plataforma antes de improvisar.

---

## 🕵️ 5. Track forense

Embebido, repartido en las catorce fases obligatorias. Cada fase lleva su pieza
en la sección 6 y su archivo `forense-fase-NN.md`.

| Fase | Pieza forense |
|---|---|
| 0 | Consola, Network y source maps: la fuente de verdad, y cuándo miente |
| 1 | Errores de NgModule: `declarations` duplicadas, módulo no importado, lazy chunk que no aparece |
| 2 | Debug de interceptor funcional: dónde poner el breakpoint cuando `inject()` ya corrió |
| 3 | La SPA bajo caos: qué pinta tiene un 500 intermitente frente a un CORS roto |
| 4 | Cazar una suscripción viva: por qué la lista se actualizó dos veces |
| 5 | `NullInjectorError` en standalone contra el mismo error en NgModule |
| 6 | Reproducir un bug de usuario desde un ticket, sin acceso a producción |
| 7 | Debug del versionado: qué versión se resolvió, con qué fecha y por qué |
| 8 | Formularios dinámicos: `valueChanges` infinito, control huérfano, `ExpressionChanged...` |
| 9 | `null` vs `undefined` bajo `strict`: el hallazgo que no bloqueó nada |
| 10 | Zona horaria en producción: el certificado que venció ayer para uno y hoy para otro |
| 11 | Performance del dashboard: cuándo culpar a `ChangeDetectionStrategy` y cuándo no |
| 12 | El test de regresión que reproduce el bug **antes** del fix |
| 13 | Diff de ambientes, config horneada contra inyectada, y el stack minificado |

Cierre del track: el **checklist de hotfix** de una página que el estudiante se
lleva al trabajo real.

---

## 📓 6. Cuaderno de incidentes (14h)

**20 incidentes**, ≈3.5h por semana, todos dentro de `cuaderno-incidentes.md`.
El formato completo está en `formato-cuaderno-incidentes.md`.

Distribución por dificultad:

- **Semana 1** (fases 0-4): 4-5 🟢 — setup, endpoints mal, CORS, el primer error
  de `strict`.
- **Semana 2** (fases 5-8): 5-6 🟡 — standalone mal importado, plantilla
  renderizada con la versión equivocada, `FormGroup` dinámico corrupto.
- **Semana 3** (fases 9-11): 5-6 🟠 — hallazgo crítico que no bloquea,
  certificado emitido con hallazgo pendiente, PDF con datos stale, dashboard
  lento.
- **Semana 4** (fases 12-13): 4-5 🔴 — intermitentes, fuga de suscripción a
  `valueChanges`, zona horaria en producción, config apuntando al ambiente
  equivocado.

**Al menos tres incidentes son de versionado de plantillas** (08, 09 y 10), que es
el corazón del sistema, y al menos dos son de convivencia standalone/NgModule
(06 y 07), que es lo que distingue a este track. Dos más son de tipos bajo
`strict` (12 y 13), que es la categoría que sólo existe porque el proyecto lo
tiene puesto.

**Categorías:** máquina de estados · versionado normativo · tiempo ·
trazabilidad · formularios dinámicos · estado (servicios) · **convivencia de
estilos 🧬** · tipos (strict) · integración · performance · UI · despliegue ·
testing.

---

## 📁 7. Convención de nombres de archivo

Todo ordenable por nombre, con dos dígitos en todo. **El número del archivo es el
número de la fase**, sin prefijo `fase-`:

```
README.md
00-setup-hola-mundo.md
01-estructura-base-ngmodules.md
02-autenticacion.md
03-mock-api-caos.md
04-estado-servicios.md
05-standalone-convivencia.md
06-clientes-activos.md
07-plantillas-versionadas.md
08-formulario-dinamico.md
09-hallazgos-severidad.md
10-certificados-vigencia.md
11-dashboard-alertas.md
12-testing-coverage.md
13-build-despliegue.md
14-casi-prod-kind.md
a01-material.md
a02-bootstrap-sass.md
a03-node-npm.md
a04-inject-vs-constructor.md
a05-formularios-tipados.md
a06-rxjs.md
a07-estado-servicios.md
a08-pdf-cliente.md
a09-docker-kubernetes.md
a10-migracion-8-16.md
a11-puente-16-17.md
a12-arm64-m1.md
a13-i18n.md
forense-master.md
forense-fase-00.md … forense-fase-14.md
cuaderno-incidentes.md
```

Los apéndices llevan tres caracteres (`a01`, no `a1`) para que `a09` no quede
después de `a10`.

---

## 📌 8. Versiones: todas cerradas

**Ninguna versión queda pendiente.** La tabla vive en
`alcance-del-proyecto.md` §9 y es la única fuente. Aquí sólo el mapa de dónde se
usa cada cosa:

| Tema | Cómo quedó | Dónde vive |
|---|---|---|
| Angular | 16.2.12 y CLI 16.2.12 | Fase 0 · todo el curso |
| TypeScript | 5.1.6 con `strict: true` | Fase 0 §5 · A05 |
| Estado | Servicios con `BehaviorSubject`, sin librería | Fase 4 · A07 |
| Material | 16.2.14 con MDC | Fase 6 · A01 |
| RxJS | 7.8.1 | A06 · transversal |
| PDF | `jspdf` 2.5.1 + `jspdf-autotable` 3.8.x | Fase 10 · A08 |
| Gráficos | `ng2-charts` 4.1.1 + `chart.js` 4.4.x | Fase 11 |
| Mock | `json-server` 0.17.4, `express` 4.18.2, `jsonwebtoken` 9.0.2 | Fase 2 · Fase 3 |
| Testing | Jasmine 4.6, Karma 6.4, coverage **80% global** con exclusiones | Fase 12 |
| Config en runtime | `assets/config.json` + `APP_INITIALIZER` + `entrypoint.sh` | Fase 13 |
| Contenedor | `node:18.18.2-alpine` build, `nginx:1.25-alpine` runtime | Fase 13 · A09 |

Si alguna vez se añade una dependencia nueva, se fija con su número exacto
**antes** de escribir la primera línea que la use.

---

## 🚦 9. Siguiente paso

No queda ninguna respuesta bloqueante. Lo que sigue es escribir, en este orden:

1. El `README.md` del curso, con el stack y el mapa de fases.
2. Las fases 0 a 4, que fijan estilo, estructura, estado y el mock. Todo lo
   demás depende de ellas.
3. Las fases 5 a 8, que son el núcleo formativo (⭐ 7 y 8).
4. Los apéndices A03, A04, A05, A06 y A07, que las fases anteriores ya citan.
5. Las fases 9 a 13, los apéndices restantes, las piezas forenses, y los veinte
   enunciados del cuaderno.

La Fase 14 y los apéndices 🔥 van al final: son opcionales y nada los espera.

---

## 🔥 El track opcional de backend

Este documento cubre **el track base y solo el track base**. El track opcional de
backend —ocho fases `be00–be07`, once apéndices `bea-01–bea-11`, 72h más 8h de
cuaderno, todo declarado **fuera de las 122h**— tiene su propio documento de
encuadre y es su fuente de verdad:

**[`propuesta-fases-backend.md`](propuesta-fases-backend.md)**

Sus prompts de redacción viven aparte, en `prompts-backend-fase.md` y
`prompts-backend-apendice.md`, y no se mezclan con los del track base: un chat de
la Fase 7 no debe arrastrar contexto de PHP 7.4 + Lumen + PostgreSQL 16 que no necesita.
