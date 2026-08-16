# 🩺 Angular 8 legacy para devs de backend

> Tutorial de **122 horas** · Dominio: laboratorio clínico · Español
> latinoamericano, código en inglés

Un curso para desarrolladores **backend o full-stack senior** que heredan una
aplicación Angular 8 en mantenimiento. No enseña a escribir Angular moderno:
enseña a **leer, depurar y hacer hotfixes** sobre un producto existente sin
romperlo, que es el trabajo que de verdad hace un equipo de Maintenance.

## 🧬 LabCore

Todo el curso gira alrededor de un sistema con nombre propio:

> **LabCore** es el sistema de gestión de laboratorio clínico que tu equipo
> heredó. Lo escribió entre 2019 y 2021 un equipo que ya no está, hoy está en
> mantenimiento y tiene decomisión prevista en dos o tres años. Casi no entran
> features nuevas: entran cambios normativos, legales y hotfixes.

Administra pacientes, órdenes médicas, muestras con cadena de custodia,
resultados contra rangos de referencia versionados, entrega en PDF, un dashboard
operativo y una bitácora de auditoría. Y tiene, a propósito, todo lo que hace difícil un legacy de
verdad: componentes gordos con lógica de negocio adentro, `strict: false` con
`any` tolerado, RxJS mínimo, NgRx montado al estilo de 2019, Bootstrap 4 y
Material peleándose la cascada, y `environment.ts` horneado en tiempo de
compilación.

**LabCore es ficticio, y lo construyes tú.** Ese es el trato del curso: cada fase
levanta una pieza del sistema que después vas a mantener, con sus deudas puestas
adrede. Al terminar la última fase obligatoria no tienes un ejercicio de clase:
tienes un legacy completo en tu disco, del que conoces cada atajo porque lo
escribiste. Cuando un capítulo diga *"así lo hace LabCore"*, puedes abrir el
archivo y comprobarlo.

## 🎯 Qué te llevas

Al terminar puedes recibir un ticket vago, reproducir el bug, localizar la capa
responsable —plantilla, componente, store, effect, interceptor o backend—,
escribir el post-mortem y el test de regresión **antes** del fix, aplicar la
corrección mínima, y explicar por qué la misma imagen se comportó distinto en
UAT y en PROD.

Lo que **no** es: formación de arquitectos de frontend, promoción de patrones
modernos ideales, ni un plan de migración. Angular 9 en adelante aparece solo
como comparación, en apéndices o en secciones 🔥.

## 📚 Las fases

Antes de la primera hay una lectura de veinte minutos que no es una fase y no
ocupa calendario: [`00-historia-del-sistema.md`](00-historia-del-sistema.md), la
ficha de contexto que cuenta de dónde viene LabCore. Se lee **antes de la Fase 0**
y es lo que evita que el estudiante juzgue el código en vez de entenderlo.

Catorce fases obligatorias suman **108h**, más **14h** de cuaderno de incidentes.
Las horas del track forense van dentro de las de cada fase, no aparte. Las horas de apéndices no
cuentan en el calendario.

| Fase | Archivo | Horas |
|---|---|---|
| 🛠️ 0 · Setup + hola mundo | [`00-setup-hola-mundo.md`](00-setup-hola-mundo.md) | 8h |
| 🏗️ 1 · Estructura base + NgRx ⭐ | [`01-estructura-base-ngrx.md`](01-estructura-base-ngrx.md) | 12h |
| 🌐 2 · Internacionalización | [`02-i18n.md`](02-i18n.md) | 6h |
| 🔐 3 · Autenticación mínima | [`03-autenticacion.md`](03-autenticacion.md) | 8h |
| 🧪 4 · Mock API + caos | [`04-mock-api-caos.md`](04-mock-api-caos.md) | 6h |
| 🏥 5 · Pacientes | [`05-pacientes.md`](05-pacientes.md) | 6h |
| 📋 6 · Órdenes | [`06-ordenes.md`](06-ordenes.md) | 4h |
| 🧫 7 · Muestras y cadena de custodia | [`07-muestras-custodia.md`](07-muestras-custodia.md) | 8h |
| 🧬 8 · Resultados y rangos versionados | [`08-resultados-rangos.md`](08-resultados-rangos.md) | 10h |
| 📦 9 · Entrega y PDF en cliente | [`09-entrega-pdf.md`](09-entrega-pdf.md) | 8h |
| 📊 10 · Dashboard | [`10-dashboard.md`](10-dashboard.md) | 8h |
| 📜 11 · Trazabilidad y audit log | [`11-trazabilidad-audit-log.md`](11-trazabilidad-audit-log.md) | 7h |
| ✅ 12 · Testing desde cero + coverage | [`12-testing-coverage.md`](12-testing-coverage.md) | 10h |
| 🚚 13 · Build, despliegue y cierre | [`13-build-despliegue.md`](13-build-despliegue.md) | 7h |
| 🔥 14 · Ambiente "casi prod" con kind | [`14-casi-prod-kind.md`](14-casi-prod-kind.md) | — |

La Fase 14 es **opcional** y no ocupa calendario: el líder la asigna a quien
tenga interés en ver su imagen corriendo en un cluster de verdad.

Las fases van en orden y cada una depende de la anterior; el encabezado de cada
capítulo dice de cuáles depende y a cuáles habilita, así que se puede comprobar
antes de empezar. La única pareja que conviene no separar es **5 y 6**:
Pacientes fija el molde de slice —acciones, reducer en `switch`, selectores,
servicio, effects— y Órdenes lo repite sobre otra entidad para que se vea qué se
copia y qué no. Ese contraste es el material de la 6, y se pierde si pasan días
entre las dos.

Cada fase sigue la misma plantilla de nueve secciones: propósito, qué queda
listo, qué no entra todavía, concepto mínimo, código mínimo con comentarios,
errores comunes y pieza forense, ejercicios, referencias y cierre.

### 📎 Los trece apéndices

Consulta bajo demanda: se entra por el índice buscando algo concreto y se sale.
Sus horas no cuentan en el calendario.

| Apéndice | Archivo | Usado por |
|---|---|---|
| 🎨 A01 · Angular Material | [`a01-material.md`](a01-material.md) | Fases 3, 5, 6, 7, 8 |
| 💅 A02 · Bootstrap 4 + Sass | [`a02-bootstrap-sass.md`](a02-bootstrap-sass.md) | Fases 0, 1, 4, 5, 6, 8, 10, 13 |
| 📦 A03 · Node y npm | [`a03-node-npm.md`](a03-node-npm.md) | Fases 0, 4, 12, 13, 14 |
| 🧱 A04 · Webpack oculto | [`a04-webpack-oculto.md`](a04-webpack-oculto.md) | Fases 10, 13 |
| 🌊 A05 · RxJS de supervivencia | [`a05-rxjs.md`](a05-rxjs.md) | Fases 1-4, 8-12 |
| 🗃️ A06 · NgRx 8 | [`a06-ngrx.md`](a06-ngrx.md) | Fases 1, 5-12 |
| 🌐 A07 · i18n en Angular 8 | [`a07-i18n.md`](a07-i18n.md) | Fases 2-4, 6-10, 13 |
| 📄 A08 · PDF en cliente | [`a08-pdf-cliente.md`](a08-pdf-cliente.md) | Fase 9 |
| ☸️ A09 · Kubernetes para el dev de front | [`a09-kubernetes.md`](a09-kubernetes.md) | Fases 13, 14 |
| 🔥 A10 · Migración 8 → 9 | [`a10-migracion-8-9.md`](a10-migracion-8-9.md) | Fases 3, 4, 12, 13, como referencia |
| 🔥 A11 · Migración 9 → 16 | [`a11-migracion-9-16.md`](a11-migracion-9-16.md) | Fases 4, 13, como referencia |
| 🔥 A12 · Dependencias problemáticas en arm64 / M1 | [`a12-arm64-m1.md`](a12-arm64-m1.md) | Fases 0, 14 |
| 🔥 A13 · Docker + Colima en Apple Silicon | [`a13-docker-colima.md`](a13-docker-colima.md) | Fases 0, 13, 14 |

## 📓 El cuaderno de incidentes

[`cuaderno-incidentes.md`](cuaderno-incidentes.md) es el otro eje del curso:
**veintiún tickets vagos, escritos**, con su preparación, tres pistas escalonadas
y la solución colapsada, que se trabajan **sin instructor**. Los veintiún IDs los
reservan las fases que los producen —cada una los declara en su cierre— y el
índice del archivo dice a partir de qué fase se puede resolver cada uno; el ID
nunca se reasigna. Cada incidente cierra con un post-mortem de ocho puntos y sin
culpabilización.

La escala quedó en **2 🟢 · 8 🟡 · 9 🟠 · 2 🔴**, repartidos 7 / 7 / 4 / 3 por
semana: el curso carga incidentes en las fases que producen material y se
aligera al final, cuando ya estás desplegando. Y **no todos terminan en fix**:
seis de ellos —el 03, el 04, el 07, el 11, el 12 y el 17— terminan en un
diagnóstico, un recuento o una declaración por escrito, que es lo que de verdad
se hace cuando lo que está mal es una decisión de hace siete años o un dato que
llegó roto de otra puerta.

Cómo llega el sistema roto a tu máquina lo dice cada incidente en su «🔧
Preparación», y hay exactamente tres formas —un flag del inyector de caos, un
`db.incidente-NN.json`, o una rama `incidente/NN`—, siempre la más barata que
sirva.

## 🔥 Track opcional de backend (completo)

Del otro lado del cable hay un backend que este curso no construye: lo escribió
otro frente del equipo contratado de 2019 en **Java 8 + Spring Boot 2.1 sobre un
`mongod` suelto**, quedó congelado y sin dueño, y está descrito en
`00-historia-del-sistema.md`. El **track BE** es la continuación opcional que lo
levanta, lo mide y lo contiene.

No es "hagamos el backend bien". Es lo contrario:

> 🧠 **El backend no viene a redimir nada. El backend es la escena del crimen.**
> Qué haces el lunes cuando lo que está mal es una decisión de arquitectura de
> hace siete años, el sistema factura, y no hay presupuesto para deshacerla.

Nueve fases (`be00`–`be08`) y doce apéndices (`bea-01`–`bea-12`), **80h más 8h
de cuaderno propio**, declaradas **aparte de las 122h** del curso. Prerrequisito:
la Fase 11 terminada. Regla no negociable: **el frontend no se toca** — se apaga
`npm run mock`, se levanta el contenedor en el mismo puerto 3000, y la aplicación
Angular no cambia ni un archivo.

| Fase | Archivo | Horas |
|---|---|---|
| 📜 be00 · El contrato: auditoría del mock ✅ | [`be00-el-contrato-auditoria-del-mock.md`](be00-el-contrato-auditoria-del-mock.md) | 6h |
| ☕ be01 · Java 8, Spring Boot 2.1 y la forma del monolito ✅ | [`be01-java-spring-y-la-forma-del-monolito.md`](be01-java-spring-y-la-forma-del-monolito.md) | 8h |
| 🔬 be02 · Lo que hay de verdad guardado: medir la deriva ⭐ ✅ | [`be02-medir-la-deriva-de-esquema.md`](be02-medir-la-deriva-de-esquema.md) | 10h |
| 🗄️ be03 · La costura: de `db.json` a Mongo, y el reemplazo ✅ | [`be03-la-costura-y-el-reemplazo.md`](be03-la-costura-y-el-reemplazo.md) | 10h |
| 📜 be04 · El audit log que escribía el navegador ✅ | [`be04-el-audit-log-que-escribia-el-navegador.md`](be04-el-audit-log-que-escribia-el-navegador.md) | 8h |
| ⛓️ be05 · La cadena de custodia y la transacción que no existe ⭐⭐ ✅ | [`be05-la-cadena-de-custodia-y-la-transaccion.md`](be05-la-cadena-de-custodia-y-la-transaccion.md) | 10h |
| 🧬 be06 · Los rangos versionados y la historia que se sobrescribió ✅ | [`be06-los-rangos-y-la-historia-perdida.md`](be06-los-rangos-y-la-historia-perdida.md) | 10h |
| 📅 be07 · La subida que nadie decidió: 4.0 → 4.4 → 6.0 → 7.0 ✅ | [`be07-la-subida-que-nadie-decidio.md`](be07-la-subida-que-nadie-decidio.md) | 8h |
| 🧯 be08 · La contención medida y la declaración de lo irrecuperable ✅ | [`be08-la-contencion-y-lo-irrecuperable.md`](be08-la-contencion-y-lo-irrecuperable.md) | 10h |

| Apéndice | Archivo |
|---|---|
| ☕ bea-01 · Java 8 y Spring para quien no escribe Java ✅ | [`bea-01-java-8-y-spring-para-quien-no-escribe-java.md`](bea-01-java-8-y-spring-para-quien-no-escribe-java.md) |
| 🐳 bea-02 · Receta de imagen y compose ✅ | [`bea-02-receta-de-imagen-y-compose.md`](bea-02-receta-de-imagen-y-compose.md) |
| 🧩 bea-03 · Modelar documentos: ¿embeber o referenciar? ✅ | [`bea-03-modelar-documentos-embeber-o-referenciar.md`](bea-03-modelar-documentos-embeber-o-referenciar.md) |
| 🔬 bea-04 · Agregaciones como instrumento de medida ✅ | [`bea-04-agregaciones-como-instrumento-de-medida.md`](bea-04-agregaciones-como-instrumento-de-medida.md) |
| 🗂️ bea-05 · Índices y `explain()` en MongoDB ✅ | [`bea-05-indices-y-explain-en-mongodb.md`](bea-05-indices-y-explain-en-mongodb.md) |
| 🧪 bea-06 · `$jsonSchema` sobre datos sucios ✅ | [`bea-06-jsonschema-sobre-datos-sucios.md`](bea-06-jsonschema-sobre-datos-sucios.md) |
| ⛓️ bea-07 · Transacciones, replica sets y el standalone ✅ | [`bea-07-transacciones-replica-sets-y-el-standalone.md`](bea-07-transacciones-replica-sets-y-el-standalone.md) |
| 🕰️ bea-08 · Tiempo, zonas y fechas en Mongo ✅ | [`bea-08-tiempo-zonas-y-fechas-en-mongo.md`](bea-08-tiempo-zonas-y-fechas-en-mongo.md) |
| 🔴 bea-09 · Cassandra: la tentación y el acierto que nadie tuvo ✅ | [`bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md`](bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md) |
| ⚖️ bea-10 · Riesgo de licencia: SSPL y compañía ✅ | [`bea-10-riesgo-de-licencia-sspl.md`](bea-10-riesgo-de-licencia-sspl.md) |
| 💸 bea-11 · Mapa de deuda del track BE ✅ | [`bea-11-mapa-de-deuda-del-track-be.md`](bea-11-mapa-de-deuda-del-track-be.md) |
| 🔥 bea-12 · Datos de prueba y volumen ✅ | [`bea-12-datos-de-prueba-y-volumen.md`](bea-12-datos-de-prueba-y-volumen.md) |

Sus horas no cuentan en ningún calendario: son consulta bajo demanda, igual que
`a01`–`a13` del track base.

El track **no vende MongoDB ni Java**: vende el método para diagnosticar un
sistema cuyo modelo de datos se volvió un pasivo, y para defender por escrito la
decisión de **no migrarlo**. LabCore tiene decomisión en dos o tres años; el
entregable final es un plan de contención medido y una declaración firmada de lo
que ya no se puede recuperar.

El encuadre completo —stack con versiones verificadas, las nueve fases, los doce
apéndices y los riesgos— está en
[`prompts/propuesta-fases-backend.md`](prompts/propuesta-fases-backend.md), y los
prompts de redacción en `prompts/prompts-backend-fase.md` y
`prompts/prompts-backend-apendice.md`.

**El track BE está completo:** las nueve fases, los doce apéndices y
[`cuaderno-incidentes-be.md`](cuaderno-incidentes-be.md) con sus doce incidentes
`be-01`–`be-12`, en un rango de IDs independiente del cuaderno base. Seis de esos
doce **no tienen fix**: tienen una medición, una declaración y un procedimiento,
que es exactamente lo que el track viene a enseñar.

## 🗂️ Cómo está organizado el repositorio

- [`00-historia-del-sistema.md`](00-historia-del-sistema.md) — la ficha de contexto que se lee antes de la
  Fase 0. No lleva código: lleva los motivos de cada decisión de 2019, y es de
  donde sale el encuadre del track BE.
- `NN-*.md` — las fases, en orden de lectura.
- [`cuaderno-incidentes.md`](cuaderno-incidentes.md) — **el único archivo de incidentes**: índice,
  enunciados, pistas, soluciones y tu bitácora. No hay un `.md` por incidente.
- [`forense-master.md`](forense-master.md) — la puerta del track forense: el método de cuatro
  preguntas, el índice de síntomas transversal —el que se consulta cuando no
  sabes de qué fase es tu problema— y en qué miente cada herramienta.
- `forense-fase-NN.md` — el paso a paso de la pieza forense de cada fase. Cada
  fase deja el gancho en su sección 6 y el desarrollo vive acá.
- `aNN-*.md` — consulta rápida bajo demanda: los trece apéndices, con su tabla
  completa y a quién sirve cada uno, están en **📚 Las fases → 📎 Los trece
  apéndices**.
- [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) — cómo versionas el código que escribes
  mientras haces el curso: un repo, commits con el prefijo de la fase, un tag
  anotado por fase cerrada, y los pares `-roto` / `-fix` que convierten cada
  incidente resuelto en un `git diff` que se entiende dentro de seis meses.
- `prompts/` — documentos de encuadre: alcance, propuesta de fases, guía de
  estilo, plantillas y el formato de las piezas forenses. Se leen antes de
  escribir o editar cualquier fase.
- 🔥 `beNN-*.md`, `bea-NN-*.md` y [`cuaderno-incidentes-be.md`](cuaderno-incidentes-be.md) — el track
  opcional de backend, completo. Su encuadre está en
  [`prompts/propuesta-fases-backend.md`](prompts/propuesta-fases-backend.md), y su cuaderno de incidentes es **un
  archivo aparte del base**: quien haga solo el track base no recibe incidentes
  de MongoDB mezclados con los suyos.

Con eso, **el curso está completo**: las catorce fases, los trece apéndices, el
track forense —[`forense-master.md`](forense-master.md) y las quince piezas, de
[`forense-fase-00.md`](forense-fase-00.md) a
[`forense-fase-14.md`](forense-fase-14.md)—, los **veintiún incidentes** de
[`cuaderno-incidentes.md`](cuaderno-incidentes.md) con su enunciado, sus pistas
escalonadas y su solución de referencia, y el 🔥 track BE entero con su propio
cuaderno. No queda ningún enlace del material sin resolver.

**Cierra cada fase con su tag** (`git tag -a fase-07-muestras-custodia …`). Es el
hábito que después te deja correr `git tag -l 'fase-*'` y saber dónde estás sin
releer nada, y el que te da permiso para romper cosas a propósito, que es la
mitad de este curso. No es opcional por una razón mecánica: las ramas
`incidente/NN` del cuaderno salen del commit donde cerraste la fase que produce
cada incidente, y sin tag ese commit no tiene nombre. La convención completa está
en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) y se lee en diez minutos.

## 🧰 Stack fijado

Angular 8.2.14 · Angular CLI 8.3.29 · TypeScript 3.5.3 · RxJS 6.5.5 (con
`rxjs-compat` heredado, ver A05) · Angular
Material y CDK 8.2.3 · zone.js 0.9.1 · NgRx 8.6.0 · `@ngx-translate/core` 11.0.1
con `http-loader` 4.0.0 · Bootstrap 4.6.2 compilado con `node-sass` 4.14.1 ·
ng2-charts 2.4.3 con Chart.js 2.9.4 y `@swimlane/ngx-charts` 12.1.0 heredado ·
jsPDF 1.5.3 · Jasmine 3.4.x y Karma 4.x · y del lado del mock, que es código del
curso y no de LabCore: json-server 0.16.3, Express 4.17.1 y jsonwebtoken 8.5.1 ·
Node **12.22.12** (npm 6.14.16) en Windows y Linux, **14.21.3**
(npm 6.14.18) en macOS Apple Silicon — el `.nvmrc` declara la 14 y el apéndice
A03 explica el reparto.

La i18n va por **runtime** con `@ngx-translate`, no por el i18n nativo de
compile-time: la comparación entre las dos familias y el porqué de la decisión
están en la Fase 2.

Windows 11 es el entorno por defecto y Linux amd64 funciona sin sorpresas;
macOS Apple Silicon vive en los apéndices A12 y A13, donde `node-sass` que no
compila en arm64 deja de ser una molestia y pasa a ser parte del ejercicio.

> 🧭 **Estas versiones están fijadas y el curso es autocontenido:** son las que
> se instalan y contra las que corre todo el material, sin depender de ningún
> `package.json` externo. Si llevas el curso sobre un sistema propio, el ejercicio
> de comparar tu árbol real contra este está en el **Apéndice A03**, que es donde
> vive el `package-lock.json` y el porqué de cada línea.

## 🧭 Estándares editoriales

La fuente de verdad es [`prompts/guia-de-estilo-y-convenciones.md`](prompts/guia-de-estilo-y-convenciones.md). Los dos
puntos que más se olvidan: **todo el código fuente va en inglés y todos los
comentarios en español**, y los textos de interfaz salen siempre de claves de
i18n, nunca literales. El resto —tuteo latinoamericano sin voseo, prosa antes
que listas, listas antes que tablas anchas, 25-35 ejercicios por fase repartidos
en 🟢🟡🟠🔴 con al menos un tercio de diagnóstico— está detallado ahí. La única
fase por debajo de ese mínimo es la 14, que es 🔥 opcional y se queda en 15. A eso
se suma una pieza de forma fija: **cada fase y cada apéndice cierran con el
bloque 🏷️ del tag de git** —el tag de la fase, o la nota de por qué el apéndice
no lleva uno— enlazando a [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) sin reexplicarla.
