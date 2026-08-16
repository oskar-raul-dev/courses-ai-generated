# 🎯 Alcance del proyecto
## Tutorial Angular 8 — Laboratorio clínico

Documento de encuadre. Define qué es este proyecto, para quién, qué produce y
—tan importante— qué **no** hace. Se lee antes de escribir cualquier fase.

---

## 1. En una frase

Un tutorial práctico de **122 horas** que prepara a desarrolladores senior para
**mantener, depurar y hacer hotfixes** en una aplicación Angular 8 heredada y en
producción — sin reescribirla.

> 🧭 **La cifra está cerrada y verificada.** 108h de fases más 14h de cuaderno,
> **122h**, comprobado sumando los encabezados de las quince fases. La cifra de
> 96h y 12 fases que circulaba venía de `_deprecado-tutorial-angular8.md`, que ya
> no es fuente de verdad de nada.

---

## 2. El problema que resuelve

Un equipo de Maintenance hereda un sistema construido entre 2019 y 2021, hoy en
mantenimiento y con decomisión prevista en dos o tres años. Casi no entran
features nuevas: entran cambios normativos, legales y hotfixes.

Ese sistema tiene nombre —**LabCore**—, dominio —un **laboratorio clínico**— y una
propiedad que lo hace posible como material de enseñanza: **es ficticio y el curso
lo construye entero**. No es un sustituto de otro sistema que no se puede enseñar;
es el sistema. Y lleva puesto, a propósito, todo lo que hace difícil un legacy:

- Estilo **"Java Swing con TypeScript"**: componentes gordos, lógica de negocio
  adentro, `subscribe()` a pelo.
- **TS-0**: `strict: false` y `any` tolerado, a propósito.
- **RxJS de uso mínimo**, nada idiomático.
- **NgRx** montado al estilo de 2019: reducers en `switch`, sin `createFeature`.
- **Bootstrap 4 y Angular Material conviviendo**, con los choques de cascada que
  eso implica.
- Angular CLI 8 con **Webpack oculto** y `environment.ts` horneado en el build.

El estudiante no aprende a *escribir* Angular moderno. Aprende a *leer, entender
y arreglar* un producto existente.

> 🧭 **Por qué construirlo en vez de entregarlo hecho.** Un repositorio de partida
> ahorraría fases enteras, y sería peor: el estudiante leería código ajeno sin
> saber qué es decisión y qué es accidente. Al escribirlo con la deuda declarada en
> voz alta —esto se hace así, esto sería lo correcto hoy, esto no se paga y por
> qué— se lleva el criterio, que es lo que después transfiere a un sistema que no
> escribió. La regla que lo protege es la §11 de la guía de estilo: **si el curso
> afirma que algo está así en LabCore, tiene que poder mostrarlo.**

---

## 3. Objetivo pedagógico

Al terminar, el estudiante puede:

- Leer componentes gordos y código de 2019 sin perder el hilo ni el ánimo.
- Detectar y reproducir bugs en cualquier capa: plantilla, componente, store,
  effect, interceptor, backend.
- Depurar código productivo, incluso minificado, con source maps.
- Leer el flujo de acciones en Redux DevTools como si fuera una máquina del
  tiempo.
- Comparar ambientes y explicar por qué algo "funciona en UAT y no en PROD",
  empezando por la configuración horneada en tiempo de compilación.
- Resolver hotfixes con el menor riesgo posible, distinguiendo la corrección
  mínima de la refactorización.
- Escribir pruebas de regresión y post-mortems que sirvan.

Lo que **NO** es objetivo: formar arquitectos de frontend, promover patrones
modernos idealizados, ni migrar el sistema. La modernización aparece solo como
comparación o fase opcional 🔥.

---

## 4. Perfil del estudiante

Un desarrollador **backend o full-stack senior**. Domina JavaScript, HTML, CSS,
HTTP, JSON, autenticación y APIs REST, y no necesita que se lo expliquen. Puede
no haber tocado Angular nunca, y casi seguro no domina RxJS, Observables ni el
ciclo de detección de cambios.

El salto conceptual real está en tres puntos: **el flujo de datos con NgRx**,
**RxJS de supervivencia** y **la diferencia entre lo que corre en el navegador y
lo que corre en el servidor**. Ahí se gasta el espacio; en lo demás, no.

---

## 5. El dominio: laboratorio clínico

LabCore administra pacientes y órdenes médicas, muestras con cadena de custodia,
procesos de análisis, resultados contra rangos de referencia versionados, entrega
de informes en PDF y un dashboard operativo.

**Flujo de estados de una orden:**

```
pending → in_process → partial_results → complete → delivered → expired
```

**Flujo de estados de una muestra:**

```
scheduled → collected → received → in_process → processed → discarded
```

**Reglas de negocio (que son también las fuentes de bug):**

- Las transiciones de estado son estrictas y la validación de un resultado es
  irreversible.
- Dos analistas pueden intentar validar el mismo resultado a la vez.
- Un resultado tiene vigencia, y una orden sin toma vence sola. Las fechas
  llevan zona horaria explícita: los resultados de fin de semana viven de eso.
- Los rangos de referencia se **versionan**: cuando cambia la norma nace una v2
  y el histórico queda intacto.
- Todo lo relevante deja rastro en el `auditLog`: quién tomó, procesó, validó y
  entregó.
- Un resultado crítico dispara alerta.
- Un analizador externo simulado empuja resultados que la aplicación no controla.

El dominio se eligió porque se entiende en cinco minutos y concentra máquina de
estados, concurrencia, tiempo, cambio normativo y trazabilidad — las cinco fuentes
de bug que un dev de mantenimiento persigue de verdad. El dinero y el modo kiosco
quedan fuera: añaden reglas y no añaden ninguna clase de fallo nueva.

---

## 6. Estructura del proyecto Claude

Un solo proyecto que hospeda alrededor de **30 chats**, cada uno productor de
**un archivo `.md` entregable**: un chat por fase, trece de apéndice, uno de track
forense, uno de cuaderno de incidentes, y una sala de dudas sin entregable fijo.

> 🪦 **Corregido al revisar el curso.** Esta sección preveía además un chat maestro
> para un `plan-del-curso.md` que nunca se escribió, y uno de *smoke y regresión*
> para los tests de Playwright, que salieron del alcance (§13). Los dos se retiran:
> un chat sin entregable, o sobra o se salió de alcance, y esa regla vale también
> para los chats que este documento imaginó.

Los nombres van con dos dígitos en todo, incluidos los apéndices, para que el
directorio se ordene solo, y el número de la fase **es** el prefijo del archivo:
`00-setup-hola-mundo.md`, `a09-kubernetes.md`, `forense-fase-04.md`. Total
esperado: **40-50 archivos**.

A esos se suma un documento de encuadre que el estudiante sí lee:
`00-convencion-de-git-y-tags.md`, en la raíz, con cómo versiona el código que
escribe mientras hace el curso —un repo, commits con el prefijo de la fase, un
tag anotado por fase cerrada, y los pares `-roto` / `-fix` de los incidentes—.
No es burocracia añadida: el cuaderno reparte el sistema roto con ramas
`incidente/NN` que salen del commit donde se cerró la fase correspondiente, así
que ese commit necesita tener nombre. Cada fase y cada apéndice cierran
enlazándolo desde su bloque 🏷️.

> 🪦 **Corregido al escribir el cuaderno.** Esta sección preveía además un
> archivo por incidente (`incidente-07-*.md`). No sobrevivió: los incidentes
> viven dentro de `cuaderno-incidentes.md`, que es el único archivo de
> incidentes del curso, porque el estudiante trabaja sin instructor y necesita
> índice, enunciado, pistas, solución y bitácora a un scroll de distancia. Los
> IDs siguen siendo globales y no se reasignan.

Si un chat no produce archivo, o sobra o se salió de alcance.

---

## 7. Lo que está dentro del alcance

Catorce fases obligatorias (0-13) que suman **108h**, más **14h** de cuaderno de
incidentes: **122h** de calendario, alrededor de veinticuatro días de media jornada más el
margen que dio la ampliación. Las **horas** del track forense van dentro de las de
cada fase, no aparte —el track sí tiene archivos propios: `forense-master.md` y las
quince piezas `forense-fase-NN.md`—. Los incidentes son **21**, con post-mortem de ocho puntos.

También entran los apéndices de consulta rápida (que no cuentan horas de
calendario), el testing desde cero con Jasmine, Karma y TestBed hasta coverage
medible, el despliegue en contenedor con Docker y nginx, y el setup
multiplataforma con sus fricciones reales.

La **Fase 14** —llevar la imagen a un Kubernetes local con kind— es 🔥 opcional,
va sin horas asignadas y la asigna el líder a quien tenga interés.

---

## 8. Lo que está fuera del alcance

Reescritura o migración real del sistema. Angular 9 en adelante, standalone,
`inject()`, control flow nuevo o RxJS 7 en el código principal: solo aparecen
como comparación en apéndices de migración o en secciones 🔥. Backend propio,
refresh token real, firma digital real del PDF, orquestación de clusters, BI
real y e2e exhaustivo.

Si algo interesante aparece fuera de alcance, se registra como **pendiente** y se
recomienda ubicarlo en un apéndice, incidente, fase posterior o ejercicio 🔥. No
se infla la fase actual.

---

## 9. Restricciones de versiones

No negociables. **Todas están fijadas y verificadas contra el registro de npm**:
son las que se instalan y contra las que corre todo el material. El curso no
depende de ningún `package.json` externo. Quien llegue con un proyecto heredado
propio compara su árbol contra este con el procedimiento del **Apéndice A03 §8**.

| Herramienta | Versión |
|---|---|
| Node.js | 12.22.12 o 14.21.3 (`.nvmrc`) |
| npm | 6.x |
| Angular | 8.2.14 |
| Angular CLI | 8.3.29 |
| TypeScript | 3.5.3 |
| RxJS | 6.5.5 |
| Angular Material y CDK | 8.2.3 |
| zone.js | 0.9.1 |
| Bootstrap | 4.x + dart-sass |
| NgRx | 8.6.0 |
| ng2-charts / Chart.js | 2.4.3 / 2.9.4 |
| `@swimlane/ngx-charts` (heredada) | 12.1.0 |
| jsPDF | 1.5.3 |
| Jasmine / Karma | 3.4.x / 4.x |
| json-server · Express · jsonwebtoken *(del mock)* | 0.16.3 · 4.17.1 · 8.5.1 |

El middleware de caos es **código propio del curso**, no una librería: se
construye paso a paso en la Fase 4 e inyecta latencia, 500 intermitentes,
respuestas malformadas, CORS roto, token expirado y timeouts.

Ninguna versión queda declarada como pendiente: si alguna vez se añade una
dependencia nueva, se fija con su número exacto antes de escribir la primera línea
que la use.

---

## 10. Entornos de desarrollo

**Windows 11 es el entorno por defecto**, con nvm-windows y build tools nativas.
Linux amd64 funciona sin sorpresas. **macOS Apple Silicon sale del cuerpo del
curso y vive en los apéndices A12 y A13**: Docker con arm64 nativo y dart-sass, o
amd64 con Rosetta para paridad con PROD, sobre Colima o Docker Desktop.

Que `node-sass` no compile en arm64 no es una incidencia a esconder: es parte del
ejercicio. Un dev de Maintenance vive resolviendo "en mi máquina no compila".

---

## 11. El eje que ordena el final del curso

Angular 8 hornea `environment.ts` **en tiempo de compilación**. Cualquier
contenedor u orquestador espera inyectar configuración **en tiempo de arranque**.
Esa fricción es la fuente de la mitad de los "funciona en UAT y no en PROD" de
cualquier SPA en producción, y se enseña entera con dos `docker run` y variables
de entorno distintas. Por eso la Fase 13 es obligatoria y el cluster es opcional.

---

## 12. Criterios de éxito

El tutorial funciona si un estudiante que lo completa puede:

1. Clonar el repo, levantar el ambiente en su plataforma y correr la aplicación.
2. Recibir un ticket vago, reproducir el bug y localizar la capa responsable.
3. Escribir el post-mortem y el test de regresión **antes** del fix.
4. Aplicar el hotfix mínimo sin romper otras tres cosas.
5. Explicar por qué la misma imagen se comportó distinto en UAT y en PROD.

Si el estudiante sale sabiendo *arreglar sin miedo*, el proyecto cumplió.

---

## 13. Decisiones cerradas

Ninguna decisión bloquea hoy la escritura. Las que estuvieron abiertas, y dónde
quedó cada una:

- 🪦 **i18n: runtime con `@ngx-translate` 11.** Era la más cara de resolver tarde
  porque cambia la Fase 2 entera y cómo se escribe cada plantilla del curso. Se
  decidió y se argumentó en la **Fase 2 §4**; el apéndice **A07** es su dueño.
- 🪦 **NgRx: 8.6.0.** La última de la línea 8. **Fase 1 §5.1**, apéndice **A06**.
- 🪦 **PDF: `jspdf` 1.5.3.** Con `jspdf-autotable` y `pdfmake` comparadas y **no**
  instaladas. **Fase 9**, apéndice **A08 §8**.
- 🪦 **Gráficos: ng2-charts 2.4.3 + Chart.js 2.9.4, con ngx-charts 12.1.0
  heredada.** El hueco de año y medio entre las dos fechas es la deuda 💸 de la
  **Fase 10 §5.6** hecha dato.
- 🪦 **Coverage: 80% global**, con las exclusiones de la **Fase 12 §5.7**. Es la
  recomendación del curso; un equipo puede fijar otra cifra tocando un solo sitio.
- 🪦 **Config por ambiente: `assets/config.json` leído con `APP_INITIALIZER` y
  reescrito por un `entrypoint.sh`.** **Fase 13**, que es la tesis del curso.
- 🪦 **Acceso al cluster: lectura.** El apéndice **A09** marca cada comando 👁️ o
  ✍️ y sirve igual si el equipo solo entrega el artefacto.
- 🪦 **Smoke tests con Playwright: fuera del alcance.** Se declaraba en el stack y
  ninguna fase lo desarrollaba. El aviso de que pertenece a la familia de
  herramientas que se descargan su propio navegador se queda en **A12 §5**, por si
  alguien lo añade algún día.

Lo que sí sigue abierto son **decisiones de proyecto**, no de escritura: si el
código nuevo que se escriba de aquí en adelante sigue el TS-0 heredado
(**A11 §5**), si se paga la deuda de la imagen non-root (**A09 §8**), y si se
versiona el `.devcontainer/` del **A13 §6**. Ninguna frena una sola línea.

---

## 🔥 El track opcional de backend

**Fuera del alcance obligatorio, y declarado como tal.** El curso se completa
entero con el mock: las 122h no cambian y ninguna fase base depende del track BE.

El **track BE** levanta el backend de LabCore —**Java 8 + Spring Boot 2.1 + MongoDB**— para medir y contener
lo que costó una decisión de arquitectura que nadie revisó. Son nueve fases
(`be00–be08`) y doce apéndices (`bea-01–bea-12`), **80h más 8h de cuaderno propio**,
declaradas aparte. Prerrequisito: **Fase 11 del track base terminada**.

Su regla no negociable manda sobre cualquier otra consideración de diseño: **el
frontend no se toca**. Se apaga `npm run mock`, se levanta el contenedor en el mismo
puerto 3000, y la aplicación Angular no cambia ni un archivo.

El entregable final no es código: es un plan de contención medido y una declaración firmada de lo irrecuperable.

**El encuadre completo, con el stack y sus versiones verificadas, está en
`prompts/propuesta-fases-backend.md`**, que es la fuente de verdad del track y
manda sobre este documento en todo lo que sea del backend.
