# 🏗️ Angular 16 legacy para devs de backend

> Tutorial de **122 horas** · Dominio: inspecciones y certificaciones · Español
> latinoamericano, código en inglés

Un curso para desarrolladores **backend o full-stack senior** que heredan una aplicación Angular 16 en mantenimiento. No enseña a escribir Angular moderno: enseña a **leer, depurar y arreglar** un sistema que ya es moderno y que aun así duele — porque alguien lo migró, y las cicatrices están puestas.

## 🧬 CertCore

Todo el curso gira alrededor de un sistema con nombre propio:

> **CertCore** es el sistema de inspecciones y certificaciones que tu equipo heredó. Nació en 2021 sobre Angular 12, se migró a **Angular 16.2.12** durante 2024, y hoy está en mantenimiento. Casi no entran features nuevas: entran cambios normativos, legales y hotfixes.

Administra clientes y sus activos, plantillas de checklist **versionadas**, la ejecución de inspecciones en campo, hallazgos con severidad, y la emisión de certificados con vigencia y PDF.

**CertCore es ficticio, y lo construyes tú.** Ése es el trato: cada fase levanta una pieza del sistema que después vas a mantener, con sus deudas puestas adrede. Al terminar la última fase obligatoria no tienes un ejercicio de clase: tienes un legacy completo en tu disco del que conoces cada atajo, porque lo escribiste. Cuando un capítulo diga *"así lo hace CertCore"*, puedes abrir el archivo y comprobarlo.

Y lleva puesto, a propósito, lo que hace difícil un legacy **moderno**, que no es lo mismo que uno viejo:

- **Código mixto por sedimentación.** NgModules de 2021 conviviendo con componentes standalone de 2024. `constructor(private x: X)` conviviendo con `inject(X)`. Ninguno de los dos estilos es un error; los dos están vivos.
- **`strict: true` desde el primer archivo**, y con él la familia de bugs que sólo aparece cuando `null`, `undefined` y "campo ausente" son tres cosas distintas.
- **Estado en servicios con `BehaviorSubject`**, sin librería de store: la decisión más común del ecosistema y la que más fugas de suscripción produce.
- **Un motor de plantillas versionadas** escrito por alguien que ya no está, que es el corazón del sistema y la fuente de la mitad de los tickets.
- **Formularios reactivos tipados y dinámicos**, generados desde datos, con `valueChanges` que se muerden la cola.
- **`environment.ts` horneado en tiempo de compilación**, que es la razón por la que "funciona en UAT y no en PROD".

## 🎯 Qué te llevas

Al terminar puedes abrir un archivo cualquiera y decir en diez segundos si es código de 2021 o de 2024 —y qué implica eso para el fix que vas a escribir—; recibir un ticket vago y convertirlo en un diagnóstico; rastrear una fuga hasta el `BehaviorSubject` que la sostiene; explicar por qué una inspección de hace un año se está renderizando con la plantilla de hoy y arreglarlo sin corromper el histórico; leer un stack trace minificado; y escribir el post-mortem y el test de regresión **antes** del fix.

Lo que **no** es: formación de arquitectos de frontend, promoción de patrones modernos ideales, ni un plan de migración. Angular 17 en adelante aparece sólo como comparación, en el apéndice A11 o en secciones 🔥.

## 📚 Las fases

Catorce fases obligatorias suman **108h**, más **14h** de cuaderno de incidentes. **El track forense va embebido en cada fase**, no aparte. Las horas de apéndices no cuentan en el calendario.

| Fase | Archivo | Horas | Ejercicios |
|---|---|---|---|
| 🛠️ 0 · Setup + hola mundo standalone | [`00-setup-hola-mundo.md`](00-setup-hola-mundo.md) | 6h | 28 |
| 🏗️ 1 · Estructura base con NgModules | [`01-estructura-base-ngmodules.md`](01-estructura-base-ngmodules.md) | 8h | 30 |
| 🔐 2 · Autenticación mínima | [`02-autenticacion.md`](02-autenticacion.md) | 6h | 28 |
| 🧪 3 · Mock API + Express caos | [`03-mock-api-caos.md`](03-mock-api-caos.md) | 6h | 26 |
| 🧠 4 · Estado con servicios y `BehaviorSubject` | [`04-estado-servicios.md`](04-estado-servicios.md) | 7h | 30 |
| 🧩 5 · Standalone conviviendo con NgModules 🧬 | [`05-standalone-convivencia.md`](05-standalone-convivencia.md) | 6h | 28 |
| 👥 6 · Clientes y activos | [`06-clientes-activos.md`](06-clientes-activos.md) | 8h | 30 |
| 📋 7 · **Plantillas versionadas** ⭐ | [`07-plantillas-versionadas.md`](07-plantillas-versionadas.md) | 14h | 35 |
| 📝 8 · **Formulario dinámico desde plantilla** ⭐ | [`08-formulario-dinamico.md`](08-formulario-dinamico.md) | 12h | 35 |
| ⚠️ 9 · Hallazgos y severidad | [`09-hallazgos-severidad.md`](09-hallazgos-severidad.md) | 6h | 26 |
| 📜 10 · Certificados, vigencia y PDF | [`10-certificados-vigencia.md`](10-certificados-vigencia.md) | 8h | 30 |
| 📊 11 · Dashboard y alertas | [`11-dashboard-alertas.md`](11-dashboard-alertas.md) | 6h | 26 |
| ✅ 12 · Testing desde cero + coverage | [`12-testing-coverage.md`](12-testing-coverage.md) | 8h | 30 |
| 🚚 13 · Build, despliegue y cierre | [`13-build-despliegue.md`](13-build-despliegue.md) | 7h | 28 |
| 🔥 14 · Ambiente "casi prod" con kind | [`14-casi-prod-kind.md`](14-casi-prod-kind.md) | sin horas 🔥 | 15 |

Cada fase sigue la misma plantilla de nueve secciones y cierra con **25-35 ejercicios** graduados 🟢🟡🟠🔴 —**410 en las catorce obligatorias**, más 15 en la Fase 14—, de los que **al menos un tercio son de diagnóstico** —se entrega algo roto y se pide reproducir, localizar y explicar— y **al menos dos, desde la Fase 5, son de estilo** 🧬: dado un archivo, decidir si el fix va en estilo nuevo o heredado, y justificarlo.

**Antes de la Fase 0** conviene leer dos documentos cortos:

- [`00-historia-del-sistema.md`](00-historia-del-sistema.md) — las eras de CertCore —incluida la de la API, que es de 2016—, quién dejó qué, y por qué el sistema es como es.
- [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) — un tag por fase, el par `-roto`/`-fix` de cada incidente, y cómo se lee la factura de una deuda con `git diff`.

## 🕵️ Track forense

Quince recorridos de investigación, uno por fase, con el ticket literal y la salida de cada paso. **No se leen de corrido**: se entra por el síntoma.

La puerta es [`forense-master.md`](forense-master.md), que trae el método de cuatro preguntas y —lo que de verdad se consulta— **el índice de síntomas transversal**: nadie llega sabiendo de qué fase es su problema, llega con *"la pantalla se queda en blanco"*.

| | Síntoma que cubre |
|---|---|
| [`forense-fase-00.md`](forense-fase-00.md) | "Le di guardar y no pasó nada" |
| [`forense-fase-01.md`](forense-fase-01.md) | "La ruta funciona pero la pantalla sale en blanco" |
| [`forense-fase-02.md`](forense-fase-02.md) | "Me saca al login sin decir nada" |
| [`forense-fase-03.md`](forense-fase-03.md) | Los seis fallos del caos, y cuál miente |
| [`forense-fase-04.md`](forense-fase-04.md) | "La lista se actualizó dos veces" |
| [`forense-fase-05.md`](forense-fase-05.md) | Los dos `NullInjectorError` 🧬 |
| [`forense-fase-06.md`](forense-fase-06.md) | "No me deja guardar y no dice por qué" |
| [`forense-fase-07.md`](forense-fase-07.md) | "Esta inspección se ve con otra plantilla" ⭐ |
| [`forense-fase-08.md`](forense-fase-08.md) | "Escribo y la aplicación se queda pegada" ⭐ |
| [`forense-fase-09.md`](forense-fase-09.md) | "El sistema me dejó aprobar y no debía" |
| [`forense-fase-10.md`](forense-fase-10.md) | "Venció ayer para uno y hoy para otro" |
| [`forense-fase-11.md`](forense-fase-11.md) | "Desde ayer el panel va lentísimo" |
| [`forense-fase-12.md`](forense-fase-12.md) | "Pasa en mi máquina y falla en el pipeline" |
| [`forense-fase-13.md`](forense-fase-13.md) | "En UAT entra y en PROD no" |
| [`forense-fase-14.md`](forense-fase-14.md) | "El pod no arranca" 🔥 |

## 📓 Cuaderno de incidentes

[`cuaderno-incidentes.md`](cuaderno-incidentes.md) — **20 incidentes, 14 horas**, repartidos a lo largo del mes. Cada uno trae el ticket como llegó, la preparación para tener el sistema roto, tres pistas plegadas, un espacio para tu investigación, y la solución de referencia con parche mínimo, refactorización correcta, **test de regresión en código**, prevención y post-mortem.

Tres de versionado de plantillas, dos de convivencia de estilos 🧬, dos de tipos bajo `strict`. Y una regla que es la mitad del ejercicio: **la solución viene incluida, y abrirla antes de escribir la tuya no te ahorra tiempo — te ahorra el ejercicio.**

Cómo llega el sistema roto a tu máquina lo dice cada incidente en su bloque «🔧 Preparación», y hay exactamente tres formas —un flag del inyector de caos, un `mock/db.incidente-NN.json`, o una rama `incidente/NN`—, siempre la más barata que sirva. Cada incidente enlaza además su **ruta forense**, porque el cuaderno da el ticket y el track forense da el método.

## 📎 Apéndices

Consulta rápida: **33h y 93 ejercicios cortos** que **no cuentan en el calendario**. El curso se completa sin abrir los marcados 🔥.

| | Contenido | Horas |
|---|---|---|
| [`a01-material.md`](a01-material.md) | Angular Material 16 (MDC): tema, `mat-form-field`, tablas, diálogos, densidad | 3h |
| [`a02-bootstrap-sass.md`](a02-bootstrap-sass.md) 🔥 | Bootstrap 5 y Material conviviendo: quién gana la cascada | 2h |
| [`a03-node-npm.md`](a03-node-npm.md) | `.nvmrc`, `npm ci` frente a `npm i`, lockfile v3, y comparar **tu** proyecto contra el del curso | 2h |
| [`a04-inject-vs-constructor.md`](a04-inject-vs-constructor.md) | El contexto de inyección, `NG0203`, y la regla del proyecto 🧬 | 2h |
| [`a05-formularios-tipados.md`](a05-formularios-tipados.md) | `FormControl<T>`, `nonNullable`, `FormRecord`, y `getRawValue()` | 3h |
| [`a06-rxjs.md`](a06-rxjs.md) | Los ocho operadores que aparecen de verdad, y los antipatrones de cada uno | 3h |
| [`a07-estado-servicios.md`](a07-estado-servicios.md) | El patrón de estado de punta a punta, y **dónde se queda corto** | 3h |
| [`a08-pdf-cliente.md`](a08-pdf-cliente.md) | jsPDF más allá del ejemplo: acentos, tablas, los 300 KB, y los límites | 3h |
| [`a09-docker-kubernetes.md`](a09-docker-kubernetes.md) | Leer un manifiesto ajeno y hablar con plataforma sin sentirte turista | 3h |
| [`a10-migracion-8-16.md`](a10-migracion-8-16.md) | Puente Angular 8/9 → 16, para quien viene del Track A | 3h |
| [`a11-puente-16-17.md`](a11-puente-16-17.md) 🔥 | Signals, control flow, esbuild: qué viene después y qué costaría | 2h |
| [`a12-arm64-m1.md`](a12-arm64-m1.md) 🔥 | macOS con Apple Silicon: las tres capas, y el `CrashLoopBackOff` que es arquitectura | 2h |
| [`a13-i18n.md`](a13-i18n.md) 🔥 | Qué costaría internacionalizar CertCore, y por qué este curso no lo hace | 2h |

## 🔥 Track opcional de backend — CertCore desde el otro lado del cable

CertCore, la aplicación, nació en 2021. **`certcore-api`, contra la que habla, es
de 2016 y nadie la revisó nunca** — está en la Era 0 de
[`00-historia-del-sistema.md`](00-historia-del-sistema.md), y explica de una sola
vez por qué el contrato devuelve el objeto completo sin paginar, por qué el
`status` del certificado viene guardado como dato, y por qué las plantillas
versionadas tienen un `id` compuesto que nadie diseñó. El **track BE** es la
continuación opcional que la levanta —**PHP 7.4.33 + Lumen 5.8.13 + PostgreSQL
16.9**—, la mide y la contiene.

No es "hagamos el backend bien". Es lo contrario:

> 🧠 **El backend no viene a redimir nada. El backend es la escena del crimen.**
> Qué haces el lunes cuando lo que está mal es una decisión de arquitectura de
> hace ocho años, el sistema factura, y no hay presupuesto para deshacerla.

**Ocho fases (`be00`–`be07`) y once apéndices (`bea-01`–`bea-11`), 72h más 8h de
cuaderno propio, declaradas aparte de las 122h del curso.** Prerrequisito: la
Fase 10 terminada. Regla no negociable: **el frontend no se toca** — se apaga
`npm run mock`, se levanta el contenedor en el mismo puerto 3000, y la aplicación
Angular no cambia ni un archivo. Al cerrar la última fase,
`git diff fase-10-certificados-vigencia..HEAD -- src/` sigue devolviendo vacío.

| Fase | Archivo | Horas | Ejercicios |
|---|---|---|---|
| 📜 be00 · El contrato: auditoría del mock | [`be00-el-contrato-auditoria-del-mock.md`](be00-el-contrato-auditoria-del-mock.md) | 6h | 26 |
| 🐘 be01 · Lumen sobre PHP 7.4, y la familiaridad falsa ⭐ | [`be01-lumen-y-la-familiaridad-falsa.md`](be01-lumen-y-la-familiaridad-falsa.md) | 10h | 32 |
| 🧬 be02 · Estratos por procedencia | [`be02-estratos-por-procedencia.md`](be02-estratos-por-procedencia.md) | 8h | 29 |
| 🗄️ be03 · El reemplazo: de `db.json` a Postgres 16 | [`be03-el-reemplazo.md`](be03-el-reemplazo.md) | 10h | 31 |
| 📅 be04 · El salto de versión que nadie corrió | [`be04-el-salto-de-version-que-nadie-corrio.md`](be04-el-salto-de-version-que-nadie-corrio.md) | 10h | 32 |
| ⭐ be05 · **La invariante que no sostenía nadie** ⭐⭐ | [`be05-la-invariante-que-no-sostenia-nadie.md`](be05-la-invariante-que-no-sostenia-nadie.md) | 10h | 33 |
| 🧱 be06 · La reescritura que se quedó a medias | [`be06-la-reescritura-a-medias.md`](be06-la-reescritura-a-medias.md) | 8h | 29 |
| 📊 be07 · El *assessment* de riesgo tecnológico | [`be07-el-assessment-de-riesgo.md`](be07-el-assessment-de-riesgo.md) | 10h | 27 |

Su fase insignia cierra el círculo con el corazón de este curso: la Fase 7 enseña
que *una inspección de hace un año se renderiza con la plantilla de hoy* y lo
arregla en el frontend. **be05** muestra que ninguna restricción de la base
sostenía esa invariante, y que el bug nunca fue del frontend.

**Los once apéndices** —consulta bajo demanda, sus horas no cuentan en ningún
calendario— cubren lo que las fases delegan: PHP y Lumen para quien no escribe
PHP ([`bea-01`](bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md)), la receta
de imagen y compose con **la cápsula del tiempo de una imagen que se murió en
directo** ([`bea-02`](bea-02-receta-de-imagen-y-compose.md)), el contenedor y por
qué `grep` falla
([`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md)), Eloquent y
lo que **no** absorbe
([`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md)), los dialectos de
PostgreSQL
([`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md)), las
restricciones sobre datos sucios
([`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md)), el tiempo
y `TIMESTAMPTZ` ([`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md)), la seguridad
sobre un runtime sin parches
([`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md)), Symfony
como vara de medir ([`bea-09`](bea-09-symfony-como-vara-de-medir.md)), el mapa de
deuda del track ([`bea-10`](bea-10-mapa-de-deuda-del-track-be.md)) y los datos de
prueba y volumen ([`bea-11`](bea-11-datos-de-prueba-y-volumen.md) 🔥).

Y el track **no vende Lumen** —nadie va a buscar trabajo de Lumen, y conviene
decirlo—: vende el método para diagnosticar un sistema cuya tecnología se volvió
un pasivo. El entregable final no es código, es un ***assessment* de riesgo
tecnológico** con cuatro opciones costeadas y una regla: *la respuesta correcta
depende de la fecha de decomisión, no de la calidad del código.*

### 📓 Cuaderno de incidentes del track

[`cuaderno-incidentes-be.md`](cuaderno-incidentes-be.md) — **12 incidentes, 8
horas**, con IDs propios (`be-01` … `be-12`) que **no se cruzan** con los del
cuaderno base. Doce tickets del otro lado del cable: la respuesta ya no está en
DevTools, está en un log, en un `EXPLAIN`, en una línea del `.env`, o en un `grep`
que **no** encuentra nada.

Dos 🟡, siete 🟠 y tres 🔴 — **no hay 🟢**, y se declara por qué: para llegar aquí
hay que haber hecho diez fases del track base con sus incidentes, así que no queda
ninguno de principiante que dar. Y **tres de los doce no terminan en un fix de
código**: uno se cierra con una frase escrita en `INVARIANTES.md`, otro con un
correo de despliegue que nadie mandó, y el último con una nota de una página que
desmonta un *assessment* ajeno.

El insignia es **`be-06`**, y es el único incidente del repositorio **sin par
`-roto`/`-fix`**: su `git diff` está vacío porque la causa vive en una línea de un
archivo que no es código.

El encuadre completo —stack con versiones verificadas, las ocho fases, los once
apéndices y los riesgos— está en
[`prompts/propuesta-fases-backend.md`](prompts/propuesta-fases-backend.md); los
prompts de redacción en `prompts/prompts-backend-fase.md` y
`prompts/prompts-backend-apendice.md`; y el estado roto de cada incidente —material
de autoría que el estudiante no abre— en
`prompts/preparaciones-de-incidentes-be.md`. **El track está completo.**

## 🧰 El stack, fijado

Ninguna versión queda al azar: es lo que hace que el material siga funcionando dentro de dos años y que tu error sea el mismo que describe el texto.

Angular y Angular CLI **16.2.12** · TypeScript **5.1.6** con `strict: true` · RxJS **7.8.1** · Angular Material y CDK **16.2.14** (MDC) · zone.js **0.13.3** · Node **18.18.2** con npm **9.8.1** · jsPDF **2.5.1** · ng2-charts **4.1.1** con Chart.js **4.4.x** · Jasmine **4.6.x** y Karma **6.4.x** · json-server **0.17.4**, Express **4.18.2** y jsonwebtoken **9.0.2** para el mock · `node:18.18.2-alpine` y `nginx:1.25-alpine` para el contenedor.

**El curso no depende de ningún `package.json` externo.** Quien llegue con un proyecto heredado propio compara su árbol contra éste con el procedimiento del apéndice **A03** §7 — y ése es el único sitio del curso donde se te pide mirar un sistema que no es CertCore.

## 🧾 Cómo está hecho

El curso se escribe contra sus propios documentos rectores, en [`prompts/`](prompts): el alcance ([`alcance-del-proyecto.md`](prompts/alcance-del-proyecto.md)), la guía de estilo y convenciones ([`guia-de-estilo-y-convenciones.md`](prompts/guia-de-estilo-y-convenciones.md)) —que manda sobre las reglas por defecto del repositorio—, las plantillas de capítulo, y los formatos de las piezas forenses y del cuaderno. Si vas a editar un capítulo, ése es el orden en que se leen.

Cada fase termina además con **📌 Pendientes sugeridos**: lo que quedó fuera a propósito y quién decide si entra. No son un TODO olvidado; son la bitácora editorial del curso.

## 👤 Para quién es

Un desarrollador **backend o full-stack senior**. Dominas JavaScript, HTML, CSS, HTTP, JSON, autenticación y APIs REST, y no hace falta que nadie te lo explique. Puedes no haber tocado Angular nunca, y casi seguro no dominas RxJS ni el ciclo de detección de cambios.

El salto conceptual real está en cinco puntos, y ahí se gasta el espacio: **RxJS de supervivencia**, **el estado compartido en servicios y su ciclo de vida**, **los formularios reactivos tipados**, **la diferencia entre lo que corre en el navegador y lo que corre en el servidor**, y uno que no existe en ningún otro curso de este repositorio: **leer dos generaciones de estilo en el mismo repositorio sin marearte**, y decidir en cuál de las dos escribes el fix.

## 🔀 Su curso hermano

[`angular-8-legacy-for-backend-devs`](../angular-8-legacy-for-backend-devs) — **LabCore**, un laboratorio clínico sobre Angular 8. Es el mismo oficio con el legacy contrario: allí el problema es la **antigüedad** (NgRx de 2019, `strict: false`, `.bind(this)`); aquí es la **convivencia** de dos generaciones.

**Los dos se pueden tomar en cualquier orden y ninguno es prerrequisito del otro.** Para quien venga del Track A existe el apéndice [`a10-migracion-8-16.md`](a10-migracion-8-16.md), que traduce los reflejos de LabCore al stack de CertCore — incluida la fila que más vale: los dos sistemas versionan algo por fecha, los dos tienen su bug estrella en la misma pregunta, y lo que cambia el resultado es **dónde decidieron poner la regla**.

---

> 🧭 **El principio que ordena las 122 horas.** No enseñamos Angular bonito ni formamos arquitectos de frontend. Formamos ojo para leer código ajeno, reproducir un bug desde un ticket vago, comparar UAT contra PROD, y aplicar un hotfix que no rompa otras tres cosas.
>
> El filtro de cada párrafo es el mismo: **¿esto ayuda a diagnosticar, depurar, corregir o prevenir?** Si no, sobra. Aunque esté muy bien escrito.
