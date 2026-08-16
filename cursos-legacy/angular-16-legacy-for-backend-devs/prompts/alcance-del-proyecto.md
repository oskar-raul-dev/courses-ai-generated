# 🎯 Alcance del proyecto
## Tutorial Angular 16 — Inspecciones y certificaciones

Documento de encuadre. Define qué es este proyecto, para quién, qué produce y
—tan importante— qué **no** hace. Se lee antes de escribir cualquier fase.

> 🧭 **Este documento depreca a `_deprecado-tutorial-angular16.md`.** Aquel fue el
> pistoletazo de salida y sirvió para eso; su mapa de 96h y 12 fases, su numeración
> de apéndices (A1-A8) y su coartada de NDA **ya no son fuente de verdad de nada**.

---

## 1. En una frase

Un tutorial práctico de **122 horas** que prepara a desarrolladores senior para
**mantener, depurar y hacer hotfixes** en una aplicación Angular 16 heredada y en
producción — una que ya sobrevivió a una migración y tiene las cicatrices puestas.

---

## 2. El problema que resuelve

Un equipo de Maintenance hereda un sistema nacido en Angular 12, migrado a
**Angular 16.2.12** hace poco y hoy en mantenimiento. Casi no entran features
nuevas: entran cambios normativos, legales y hotfixes.

Ese sistema tiene nombre —**CertCore**—, dominio —**inspecciones y
certificaciones**— y una propiedad que lo hace posible como material de
enseñanza: **es ficticio y el curso lo construye entero**. No es el proxy de un
sistema que no se puede enseñar; es el sistema.

Y lleva puesto, a propósito, lo que hace difícil un legacy *moderno*, que no es
lo mismo que un legacy viejo:

- **Código mixto por sedimentación.** NgModules de 2021 conviviendo con
  standalone components de 2024. `constructor(private x: X)` conviviendo con
  `inject(X)`. Ninguno de los dos estilos es un error; los dos están vivos.
- **TypeScript strict activado (TS-2)** — y con él, la clase de bug que sólo
  aparece cuando `strictNullChecks` te obliga a decidir qué significa `null`.
- **Estado en servicios con `BehaviorSubject`**, sin librería de store. Es la
  decisión más común del ecosistema y la que más fugas de suscripción produce.
- **Un motor de plantillas versionadas** escrito por alguien que ya no está en la
  empresa, que es el corazón del sistema y la fuente de la mitad de los tickets.
- **Formularios reactivos tipados y dinámicos**, generados desde datos: densos,
  difíciles de depurar y con `valueChanges` que se muerden la cola.
- Angular CLI 16 con **esbuild y Webpack conviviendo**, y `environment.ts`
  horneado en el build.

El estudiante no aprende a *escribir* Angular moderno. Aprende a *leer, entender
y arreglar* un producto existente que ya es moderno y aun así duele.

> 🧭 **Por qué construirlo en vez de entregarlo hecho.** Un repositorio de partida
> ahorraría fases enteras, y sería peor: el estudiante leería código ajeno sin
> saber qué es decisión y qué es accidente. Al escribirlo con la deuda declarada
> en voz alta —esto se hace así, esto sería lo correcto hoy, esto se paga en la
> fase tal— se lleva el criterio, que es lo que después transfiere a un sistema
> que no escribió. La regla que lo protege es la §11 de la guía de estilo: **si el
> curso afirma que algo está así en CertCore, tiene que poder mostrarlo.**

### 2.1 Cómo se relaciona con el Track A (Angular 8 — LabCore)

Son cursos hermanos y deliberadamente distintos. El Track A enseña legacy
**antiguo**: Angular 8, NgRx de 2019, `strict: false`, RxJS mínimo, el `this`
atado con `.bind`. Este —el Track B— enseña legacy **reciente**: el sistema que
alguien ya migró, donde el problema no es la antigüedad sino la convivencia de
dos generaciones de estilo en el mismo repositorio.

Un estudiante puede tomar cualquiera de los dos sin haber tomado el otro. Para
quien venga del Track A existe el **Apéndice A10 (puente 8/9 → 16)**, y para quien
llegue directo aquí no hay ningún prerrequisito del Track A en ninguna fase.

Las diferencias que importan, y que ninguna fase debe borrar:

| | Track A — LabCore | Track B — CertCore |
|---|---|---|
| Angular | 8.2.14 | 16.2.12 |
| TypeScript | `strict: false` (TS-0) | `strict: true` (TS-2) |
| Estado | NgRx 8.6 al estilo 2019 | Servicios con `BehaviorSubject` |
| Componentes | NgModule siempre | Mixto: NgModule legacy + standalone nuevo |
| Inyección | `constructor` siempre | `inject()` en nuevo, `constructor` en legacy |
| Deuda 💸 | **No se paga** | **Se paga cuando corresponde** |
| Idiomas de la interfaz | tres, con i18n en runtime | uno, español literal (§8) |

---

## 3. Objetivo pedagógico

Al terminar, el estudiante puede:

- Abrir un archivo cualquiera y decir en diez segundos si es código de 2021 o de
  2024, y qué implica eso para el fix que va a escribir.
- Detectar y reproducir bugs en cualquier capa: plantilla, componente, servicio
  de estado, interceptor, resolver, backend.
- Depurar código productivo, incluso minificado, con source maps.
- Rastrear una fuga de suscripción hasta el `BehaviorSubject` que la sostiene.
- Explicar por qué una inspección ejecutada con la plantilla v1 se está
  renderizando con la v2, y arreglarlo sin corromper el histórico.
- Comparar ambientes y explicar por qué algo "funciona en UAT y no en PROD",
  empezando por la configuración horneada en tiempo de compilación.
- Resolver hotfixes con el menor riesgo posible, distinguiendo la corrección
  mínima de la refactorización.
- Escribir pruebas de regresión y post-mortems que sirvan.

Lo que **NO** es objetivo: formar arquitectos de frontend, promover patrones
modernos idealizados, ni migrar el sistema a Angular 17+. La modernización
aparece como comparación (A11) o como fase opcional 🔥.

---

## 4. Perfil del estudiante

Un desarrollador **backend o full-stack senior**. Domina JavaScript, HTML, CSS,
HTTP, JSON, autenticación y APIs REST, y no necesita que se lo expliquen. Puede
no haber tocado Angular nunca, y casi seguro no domina RxJS, Observables ni el
ciclo de detección de cambios.

El salto conceptual real está en cuatro puntos, y ahí se gasta el espacio:
**RxJS de supervivencia**, **el estado compartido en servicios y su ciclo de
vida**, **los formularios reactivos tipados** y **la diferencia entre lo que
corre en el navegador y lo que corre en el servidor**. En lo demás, no.

Hay un quinto punto que es específico de este track y no existe en el A:
**leer dos estilos a la vez sin marearse**. Se entrena desde la Fase 5.

---

## 5. El dominio: inspecciones y certificaciones

CertCore administra clientes y sus activos, plantillas de checklist versionadas,
la ejecución de inspecciones en campo, los hallazgos con severidad, y la emisión
de certificados con vigencia y PDF.

**Flujo de una inspección:**

```
requested → scheduled → in_progress → completed → approved | rejected
```

**Flujo de un certificado:**

```
issued → valid → expiring → expired | revoked
```

**Reglas de negocio (que son también las fuentes de bug):**

- Las transiciones de estado son estrictas, y aprobar una inspección es
  irreversible.
- **Las plantillas de checklist se versionan.** Cuando cambia la norma nace una
  v2 con su `validFrom`, y el histórico queda intacto. Una inspección ejecutada
  con `templateVersion: 1` **no puede re-renderizarse con la v2**, nunca, aunque
  la v2 sea "la vigente". Ésta es la regla central del curso.
- Un hallazgo de severidad `critical` **bloquea** la emisión del certificado.
- Un certificado tiene vigencia con zona horaria explícita. "¿Vence hoy o ya
  venció?" depende de dónde esté parado quien pregunta.
- Todo lo relevante deja rastro: quién marcó cada ítem del checklist, cuándo, y
  quién lo modificó después.
- El inspector trabaja en campo con conexión intermitente: las respuestas se
  guardan localmente y se sincronizan.
- Un registro nacional de certificaciones simulado responde tarde, mal, o no
  responde.

El dominio se eligió porque se entiende en cinco minutos y concentra **máquina de
estados, tiempo, cambio normativo, trazabilidad y formularios densos** — las
fuentes de bug que un dev de mantenimiento persigue de verdad. El dinero y la
concurrencia alta quedan fuera: añaden reglas y no añaden ninguna clase de fallo
nueva que el curso no cubra ya.

### 5.1 Modelo de datos de referencia

Es la forma canónica, y el `db.seed.json` que construye la **Fase 3** la sigue al
pie de la letra. Se muestra una fila por colección; la semilla real trae tres
clientes, seis activos, tres plantillas, cinco inspecciones, cuatro hallazgos y
dos certificados.

```json
{
  "clients": [
    { "id": 1, "legalName": "Edificio Central S.A.S.", "taxId": "900123456" }
  ],
  "assets": [
    { "id": "ASC-CENTRAL-03", "clientId": 1, "type": "elevator",
      "description": "Ascensor lado norte, torre A", "installedAt": "2015-06-10" }
  ],
  "templates": [
    {
      "id": "elevator-annual-v2",
      "templateId": "elevator-annual",
      "version": 2,
      "validFrom": "2024-01-01",
      "validUntil": null,
      "items": [
        { "id": "main-cable", "title": "Estado y tensión del cable principal",
          "criteria": ["no_wear", "light_wear", "critical_wear"],
          "photoRequired": true, "nonComplianceSeverity": "critical" }
      ]
    }
  ],
  "inspections": [
    {
      "id": 500,
      "assetId": "ASC-CENTRAL-03",
      "inspectorId": "INS-15",
      "templateId": "elevator-annual",
      "templateVersion": 2,
      "status": "in_progress",
      "startedAt": "2024-03-15T09:00:00-05:00",
      "completedAt": null,
      "answers": [
        { "itemId": "main-cable", "answer": "light_wear",
          "evidenceUrl": "assets/evidence/500-main-cable.jpg",
          "note": "Revisar en 6 meses" }
      ]
    }
  ],
  "findings": [
    { "id": 900, "inspectionId": 503, "itemId": "main-cable", "severity": "critical",
      "description": "Desgaste severo del cable principal, con hilos visibles",
      "resolvedAt": null }
  ],
  "certificates": [
    {
      "id": "CERT-2024-000502",
      "inspectionId": 502,
      "issuedAt": "2024-02-10T10:00:00-05:00",
      "validUntil": "2025-02-10T23:59:59-05:00",
      "status": "valid",
      "revokedAt": null
    }
  ]
}
```

**Tres decisiones del modelo que no son cosméticas**, cerradas al escribir la
Fase 3:

- 🪦 **El `id` de una plantilla es compuesto (`elevator-annual-v2`) y el
  identificador lógico vive en `templateId`.** Con `id: "elevator-annual"` a
  secas, la v1 y la v2 colisionan —json-server usa `id` como clave única— y el
  invariante central del curso deja de ser expresable en el mock. Las
  inspecciones siguen guardando `templateId` + `templateVersion`, sin cambio.
- 🪦 **`findings` es una colección de primer nivel**, con `inspectionId`. Así
  json-server sirve `/inspections/:id/findings` —el endpoint que la guía de
  estilo §5.3 ya nombraba— sin configurar nada, y la Fase 9 no tiene que
  modificar un `db.json` sobre el que seis fases construyeron.
- ⚠️ **El `status` de un certificado está almacenado y debería ser derivado** de
  `validUntil` contra el reloj. Se deja así a propósito: es un antipatrón real,
  el dato empieza a mentir al día siguiente, y **la Fase 10 lo convierte en
  calculado** como parte de su material.

---

## 6. Estructura del proyecto Claude

Un solo proyecto que hospeda alrededor de **30 chats**, cada uno productor de
**un archivo `.md` entregable**: un chat por fase, uno por apéndice, uno de track
forense, uno de cuaderno de incidentes, y una sala de dudas sin entregable fijo.

Si un chat no produce archivo, o sobra o se salió de alcance.

Los nombres van con dos dígitos en todo, incluidos los apéndices, para que el
directorio se ordene solo. La convención exacta está en
`propuesta-fases-y-alcance.md` §7. Total esperado: **40-50 archivos**.

A esos se suma un documento de encuadre que el estudiante sí lee:
`00-convencion-de-git-y-tags.md`, en la raíz, con cómo versiona el código que
escribe mientras hace el curso —un repo, commits con el prefijo de la fase
(`fase 04: …`), un tag anotado por fase cerrada (`fase-04`), y los pares
`-roto` / `-fix` de los incidentes—. Es la regla que la **Fase 0 §9** ya fija,
desarrollada: sin ella, el ejercicio 30 de la Fase 1 no se puede hacer —el tag
`fase-00` es el único sitio donde sobrevive el hola mundo que la Fase 1 retira— y
las ramas `incidente/NN` del cuaderno no tienen commit de partida que nombrar.
Cada fase y cada apéndice cierran enlazándolo desde su bloque 🏷️.

**No hay `plan-del-curso.md`.** El documento base lo pedía; su función la cumplen
`propuesta-fases-y-alcance.md` §2 y el `README.md` del curso, y un tercer
documento que repita las mismas cifras sólo garantiza que algún día se
contradigan.

**Los incidentes viven todos dentro de `cuaderno-incidentes.md`**, un único
archivo. El estudiante trabaja sin instructor y necesita índice, enunciado,
pistas, solución y su propia bitácora a un scroll de distancia. Los IDs son
globales y no se reasignan. El formato está en `formato-cuaderno-incidentes.md`.

---

## 7. Lo que está dentro del alcance

Catorce fases obligatorias (0-13) que suman **108h**, más **14h** de cuaderno de
incidentes: **122h** de calendario, alrededor de veintiséis días de media
jornada. El track forense va **embebido** en cada fase, no aparte. Los incidentes
son **20**, con post-mortem de ocho puntos.

También entran los apéndices de consulta rápida (que no cuentan horas de
calendario), el testing desde cero con Jasmine, Karma y TestBed hasta coverage
medible, y el despliegue en contenedor con Docker y nginx.

La **Fase 14** —llevar la imagen a un Kubernetes local con kind— es 🔥 opcional,
va sin horas asignadas y la asigna el líder a quien tenga interés.

---

## 8. Lo que está fuera del alcance

- **Migración real** del sistema a Angular 17+. Signals, control flow `@if/@for` y
  deferrable views aparecen como pincelada en la Fase 12 y como apéndice A11.
- **NgRx u otra librería de store.** CertCore no la usa. Se nombra en A07 para
  explicar qué problema resolvería y por qué aquí no está.
- **i18n multi-idioma.** Decisión cerrada en §9 de `propuesta-fases-y-alcance.md`:
  CertCore es monolingüe en español y los textos de interfaz van como literales en
  plantilla. El presupuesto que el Track A gasta en i18n, este track lo gasta en
  el motor de plantillas versionadas. Quien necesite i18n moderno tiene el
  apéndice **A13** 🔥, que es de lectura y no toca ninguna fase.
- Backend propio, refresh token real, firma digital real del PDF, offline-first
  con service workers, BI real y e2e exhaustivo con Playwright.

Si algo interesante aparece fuera de alcance, se registra como **pendiente 📌** y
se recomienda ubicarlo en un apéndice, incidente, fase posterior o ejercicio 🔥.
No se infla la fase actual.

---

## 9. Restricciones de versiones

No negociables, y todas fijadas antes de escribir la primera línea que las use.
El curso no depende de ningún `package.json` externo: es lo que lo hace
autocontenido. Quien llegue con un proyecto heredado propio compara su árbol
contra este con el procedimiento del **Apéndice A03**.

| Herramienta | Versión |
|---|---|
| Node.js | 18.18.2 exacto (`.nvmrc`) |
| npm | 9.8.1 — el que empaqueta Node 18.18.2 |
| Angular y Angular CLI | 16.2.12 |
| TypeScript | 5.1.6 |
| RxJS | 7.8.1 |
| Angular Material y CDK | 16.2.14 (MDC) |
| zone.js | 0.13.3 |
| Bootstrap *(opcional, A02)* | 5.3.x + dart-sass |
| jsPDF | 2.5.1 |
| ng2-charts / Chart.js | 4.1.1 / 4.4.x |
| Jasmine / Karma | 4.6.x / 6.4.x |
| json-server · Express · jsonwebtoken *(del mock)* | 0.17.4 · 4.18.2 · 9.0.2 |
| Docker · nginx *(Fase 13)* | node:18.18.2-alpine · nginx:1.25-alpine |
| kind *(Fase 14, 🔥)* | el que traiga tu runtime de contenedores |

El middleware de caos es **código propio del curso**, no una librería: se
construye paso a paso en la Fase 3 e inyecta latencia, 500 intermitentes,
respuestas malformadas, CORS roto, token expirado y timeouts.

---

## 10. Entornos de desarrollo

**Windows 11 y Linux amd64 son los entornos por defecto**, con nvm o
nvm-windows. Node 18 se instala sin compilar nada en las tres plataformas, así
que aquí no hay el drama de `node-sass` del Track A.

**macOS Apple Silicon funciona nativo y sin fricción**; lo que sí necesita
atención es la arquitectura de la imagen de la Fase 13, y eso vive en el
apéndice **A12** 🔥. El curso se completa sin abrirlo.

---

## 11. El eje que ordena el final del curso

Angular 16 sigue horneando `environment.ts` **en tiempo de compilación**, igual
que Angular 8, igual que Angular 19. Cualquier contenedor u orquestador espera
inyectar configuración **en tiempo de arranque**. Esa fricción es la fuente de la
mitad de los "funciona en UAT y no en PROD" de cualquier SPA en producción, y se
enseña entera con dos `docker run` y variables de entorno distintas.

Que el problema sea idéntico ocho versiones mayores después **es la lección**: no
es un defecto de Angular 8 que la 16 arregló, es una propiedad de cómo se
construyen las SPAs. Por eso la Fase 13 es obligatoria y el cluster es opcional.

---

## 12. Criterios de éxito

El tutorial funciona si un estudiante que lo completa puede:

1. Clonar el repo, levantar el ambiente en su plataforma y correr la aplicación.
2. Recibir un ticket vago, reproducir el bug y localizar la capa responsable.
3. Mirar un archivo y decidir si el fix va en estilo legacy o en estilo nuevo,
   **y justificarlo**.
4. Escribir el post-mortem y el test de regresión **antes** del fix.
5. Aplicar el hotfix mínimo sin romper otras tres cosas.
6. Explicar por qué la misma imagen se comportó distinto en UAT y en PROD.

Si el estudiante sale sabiendo *arreglar sin miedo*, el proyecto cumplió.

---

## 13. Decisiones cerradas

Ninguna decisión bloquea hoy la escritura. Las que estuvieron abiertas en
`_deprecado-tutorial-angular16.md` §10, y dónde quedó cada una:

- 🪦 **Versión: Angular 16.2.12**, la última estable de la línea 16. Cerrada, y
  no se verifica contra ningún sistema externo: el curso es autocontenido.
- 🪦 **Estilo: mixto y deliberado.** NgModule para el código heredado de las
  Fases 1-4, standalone para todo lo nuevo desde la Fase 5. No se refactoriza el
  legacy salvo donde una fase lo declare explícitamente.
- 🪦 **Estado: servicios inyectables con `BehaviorSubject`**, sin librería.
  **Fase 4**, apéndice **A07**.
- 🪦 **Signals: pincelada.** En Angular 16 son experimentales y CertCore no los
  usa. Aparecen en la **Fase 12** como lectura y en **A11** como horizonte.
- 🪦 **i18n: fuera del cuerpo del curso.** Español literal en plantilla;
  apéndice **A13** 🔥 para quien lo necesite.
- 🪦 **Bootstrap: opcional.** Material 16 con MDC es el sistema de estilos
  principal. La convivencia con Bootstrap 5 vive en **A02** y no se asume en
  ninguna fase.
- 🪦 **Testing preexistente: cero specs.** La Fase 12 monta todo desde nada.
- 🪦 **PDF: generación en cliente** con `jspdf` 2.5.1. **Fase 10**, apéndice
  **A08**.
- 🪦 **NDA: retirado.** CertCore es ficticio y el curso lo construye. La regla
  §11 de la guía de estilo sustituye a la coartada.

Lo que sigue abierto son **decisiones de proyecto**, no de escritura, y ninguna
frena una línea: cuánto legacy se migra a standalone después del onboarding, si
se adopta el control flow de la 17, y si el equipo sube el umbral de coverage.

---

## 🔥 El track opcional de backend

**Fuera del alcance obligatorio, y declarado como tal.** El curso se completa
entero con el mock: las 122h no cambian y ninguna fase base depende del track BE.

El **track BE** levanta el backend de CertCore —**PHP 7.4 + Lumen + PostgreSQL 16**— para medir y contener
lo que costó una decisión de arquitectura que nadie revisó. Son ocho fases
(`be00–be07`) y once apéndices (`bea-01–bea-11`), **72h más 8h de cuaderno propio**,
declaradas aparte. Prerrequisito: **Fase 10 del track base terminada**.

Su regla no negociable manda sobre cualquier otra consideración de diseño: **el
frontend no se toca**. Se apaga `npm run mock`, se levanta el contenedor en el mismo
puerto 3000, y la aplicación Angular no cambia ni un archivo.

El entregable final no es código: es un *assessment* de riesgo tecnológico con cuatro opciones costeadas.

**El encuadre completo, con el stack y sus versiones verificadas, está en
`prompts/propuesta-fases-backend.md`**, que es la fuente de verdad del track y
manda sobre este documento en todo lo que sea del backend.
