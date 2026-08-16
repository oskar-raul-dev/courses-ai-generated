# ⚛️ React 16 Legacy — para devs de backend

Tutorial práctico y **autocontenido** de **96 horas** para desarrolladores senior
de backend que necesitan aprender a mantener una aplicación React 16 heredada.
El objetivo no es que aprendas a escribir React bonito: es que puedas **leer
código ajeno y viejo, reproducir un bug desde un ticket vago, depurarlo y
aplicar un hotfix que no rompa otras tres cosas**.

No necesitas acceso a ningún sistema previo, ni a un repositorio de empresa, ni
a un instructor. Todo lo que el curso usa lo construyes tú a lo largo de las
fases, con las versiones y los comandos exactos escritos en
`prompts/decisiones-y-versiones.md`.

## 🏢 El sistema: Rifas y Chances S.A.S.

**Rifas y Chances S.A.S. es una empresa ficticia** y su plataforma también lo
es. La inventamos para este curso, íntegra, y esa es justamente la gracia: te
podemos contar su historia completa —quién escribió cada parte, en qué año, con
qué prisa y con qué mala idea— porque no hay nada que ocultar.

La plataforma administra rifas, números, participantes, resultados de una
lotería simulada y liquidaciones. Se eligió ese dominio porque cualquiera
entiende una rifa sin explicación previa, y porque concentra en poco espacio las
cuatro cosas que hacen difícil un frontend: **concurrencia** (dos vendedores
peleando por el mismo número), **tiempo** (una hora de cierre con zona horaria),
**dinero** (que no perdona un centavo) y **reactividad** (polling que hay que
saber apagar).

La historia del sistema —sus tres eras, quién dejó cada cosa y por qué está como
está— vive en `00-historia-del-sistema.md`. Léela antes de la Fase 0: entender por
qué un código es como es cambia por completo cómo lo tocas.

## 🎯 Qué vas a saber hacer al terminar

Leer código legacy mezclado (clases con `componentDidMount` conviviendo con
hooks, `connect()` conviviendo con `useSelector`) sin marearte. Detectar y
reproducir bugs en cualquier capa: componente, store, epic o backend. Entender
epics de `redux-observable` —cancelación, race conditions, memory leaks—, que es
el salto conceptual real de este curso. Distinguir una corrección mínima de una
refactorización, y defender cuál corresponde. Escribir la prueba de regresión
**antes** del fix.

Lo que **no** es objetivo: formar arquitectos de React, promover patrones
modernos idealizados ni migrar el sistema. La modernización aparece solo como
comparación o en secciones 🔥.

## 👤 Para quién es

Desarrollador **backend o full-stack senior**. Damos por sabidos JavaScript,
HTML, CSS, HTTP, JSON, autenticación y APIs REST — no se gasta espacio
explicándolos. Puedes conocer React moderno, pero probablemente no class
components, y casi seguro no RxJS ni marble testing. Ahí es donde el curso pone
el peso.

## 📚 Estructura

**Doce fases (0-11)**, cada una en su `.md`, con la misma plantilla de nueve
secciones: propósito, qué queda listo, qué queda fuera, conceptos mínimos,
implementación comentada, errores comunes y pieza forense, ejercicios,
referencias y cierre.

| # | Fase | Foco |
|---|---|---|
| 00 | Setup + Hola mundo CRA | Ambiente, CRA 4, primer componente |
| 01 | Estructura base + Router 5 | Rutas, layout, clases y hooks juntos |
| 02 | Autenticación mínima | Store, interceptores, `requestId` |
| 03 | Mock API con Express y caos | Fallos, latencia y 401 a propósito |
| 04 | CRUD de rifas | Thunks, slices, estados de carga |
| 05 | ⭐ Venta de números | Race conditions, reservas, rollback |
| 06 | ⭐ redux-observable a fondo | Epics, cancelación, memory leaks |
| 07 | Cierre y polling de resultados | Hora dura, zona horaria, `takeUntil` |
| 08 | Liquidación y cálculo de premio | Dinero en enteros, nunca floats |
| 09 | Dashboard | Memoización, performance, charts |
| 10 | Testing mínimo | Jest, RTL, marbles, smoke |
| 11 | Cierre y puente a React moderno | Migrar con red, cerrar el ciclo |

**Trece apéndices** de consulta rápida, que no se leen de corrido: los abres
cuando una fase te manda a ellos.

| # | Apéndice | Para cuándo |
|---|---|---|
| A1 | `A1-bootstrap-4-y-sass.md` | Grid, cards, forms y utilidades de Bootstrap 4 |
| A2 | `A2-mini-design-system.md` | Tokens, mixins y cómo extender Bootstrap con Sass |
| A3 | `A3-node-y-npm.md` | `npm ci`, semver, lockfile, "en mi máquina anda" |
| A4 | `A4-cra-por-dentro.md` | Qué esconde `react-scripts` y por qué no hacemos `eject` |
| A5 | `A5-class-components-vs-hooks.md` | Traducir `componentDidMount` a `useEffect` y viceversa |
| A6 | `A6-redux-clasico-vs-toolkit.md` | `connect()` frente a `useSelector`, `switch` frente a `createSlice` |
| A7 | `A7-redux-observable-epica-por-epica.md` | Qué operador de RxJS toca y qué error trae cada uno |
| A8 | `A8-puente-a-react-moderno.md` | Qué hay del otro lado: React 17/18, RTK Query, RxJS 7 |
| A9 | `A9-entornos-y-contenedores.md` | Cuándo necesitas contenedor y cuándo no |
| A10 | `A10-aritmetica-de-dinero.md` | Centavos enteros, redondeo y repartos que cuadran |
| A11 | `A11-marble-testing.md` | Probar que un epic **deja** de emitir |
| A12 | `A12-mapa-de-deuda-tecnica.md` | Qué está feo a propósito y qué lo vuelve exigible |
| A13 | `A13-depurar-el-build-de-produccion.md` | Source maps, bundles minificados, UAT frente a PROD |

**Un cuaderno de incidentes** (`cuaderno-incidentes.md`): veinte tickets vagos
—como llegan en la vida real— con pistas escalonadas y solución de referencia
colapsada. Es donde se entrena el músculo central del curso. Cinco de los veinte
son de RxJS, porque son los que más caro salen.

Y una puerta de entrada que se usa más que el índice: la sección 🩺 **"Entrar por
el síntoma"**, con el método de cuatro preguntas y una tabla que va de la frase del
ticket —*"a veces no carga"*, *"verde en mi máquina, rojo en la de al lado"*— a la
primera herramienta que hay que abrir. Porque nadie llega a una investigación
sabiendo de qué fase es su problema.

> 🧭 **Tres de los veinte no terminan en un commit.** Uno cierra en documentación,
> otro en un *"no se reproduce, y acá está la evidencia"*, y el último —el que
> cierra el curso— en una decisión de equipo que hay que escribir y firmar. Ese
> desenlace es tan real como un fix y casi nunca se practica.

**Y una convención de git** (`00-convencion-de-git-y-tags.md`): cómo versionas
el código que escribes mientras haces el curso — un repo por aplicación,
commits con el prefijo de la fase, un tag anotado por fase cerrada, y los pares
`-roto` / `-fix` que convierten cada incidente resuelto en un `git diff` que se
entiende dentro de seis meses.

## 🔥 Track BE opcional — el backend de verdad (be00–be09)

Las doce fases de arriba se completan **enteras contra el mock**, y ahí termina
el curso de 96 horas. Pero el mock dejó deudas 💸 que ninguna fase de frontend
puede pagar: el token es una constante escrita a mano, el `409` de venta
duplicada lo produce un `if` en JavaScript, y la hora de cierre la evalúa el
reloj del navegador.

El **track BE** es opcional y las paga. Diez fases más (**84 horas aparte**, que
no cuentan en las 96) donde reemplazas `json-server` por un backend real en **Go
1.19 contra PostgreSQL 13**, con una regla que lo ordena todo:

> 🧭 **Se apaga el mock, se levanta el binario de Go en el mismo puerto `3001`, y
> la aplicación React no cambia ni un archivo.**

Se puede empezar **en cuanto termines la Fase 8**. El encuadre completo
—justificación, alcance y programa— está en
`prompts/propuesta-fases-backend.md`.

| # | Fase | Foco |
|---|---|---|
| be00 | El contrato: auditoría del mock | Qué consume el frontend, medido con Network |
| be01 | Go 1.19 y la forma del monolito | `net/http`, middlewares, `context`, el caos en Go |
| be02 | La costura de datos | Dos motores, migraciones y el mito de la agnosia SQL |
| be03 | CRUD y el reemplazo 🪦 | El mock se apaga y el frontend no se entera |
| be04 | Identidad real | bcrypt, JWT, un CVE y su post-mortem |
| be05 | ⭐ Venta concurrente | Índice único, `FOR UPDATE`, el `409` que sí protege |
| be06 | Hora dura y zonas horarias | `TIMESTAMPTZ` y la autoridad del reloj |
| be07 | Liquidación transaccional | Dinero entero en la base, repartos que cuadran |
| be08 | Pruebas y la regla del motor | Cuándo SQLite te engaña y cómo demostrarlo |
| be09 | Empaquetado y pipeline | Imagen, ambientes, CI y el veredicto honesto |

Y **diez apéndices propios** (`bea-01` a `bea-10`): Go para quien no escribe
Go, la receta de imagen y compose, dialectos SQL, JWT por dentro, concurrencia
en Postgres, tiempo y relojes, correlación por `request-id`, seguridad de API,
el mapa de deuda del backend y —opcional— datos de prueba con faker.

Y **su propio cuaderno de incidentes** (`cuaderno-incidentes-be.md`): dieciséis
tickets vagos que ocurren del otro lado del cable —en el binario, en Postgres, en
el contenedor o en el pipeline—, con pistas
escalonadas y solución de referencia colapsada. Seis son hermanos de incidentes
del track base: el mismo síntoma resuelto en la capa donde de verdad vivía.

> 🧭 Y seis de los dieciséis **no terminan en un commit**. Dos registran hallazgos
> de contrato, dos concluyen que el sistema hizo lo correcto y hay que
> explicárselo a alguien, y dos terminan en una decisión de negocio. Ese desenlace
> es tan real como un fix, y casi nunca se practica.

---

## 🛠️ Stack

Node 14.21.3 · React 16.14.0 · CRA / react-scripts 4.0.3 · Redux 4.1.2 · Redux
Toolkit 1.8.6 · redux-observable 1.2.0 · RxJS 6.6.7 · React Router 5.3.4 · axios
0.21.4 · Bootstrap 4.6.2 · Jest 26 · React Testing Library 11 · chart.js 2.9.4.

Las versiones exactas, el `package.json` completo, qué instala cada fase y el
porqué de cada decisión están en **`prompts/decisiones-y-versiones.md`**, que es la
fuente de verdad. Si un número aparece en dos sitios y no coinciden, gana ese
archivo.

Nada de React 17/18, Router 6, RTK 2 ni RxJS 7 en el código principal: aparecen
solo como comparación. Todo corre local, contra un `json-server` y un mock de
Express que **falla a propósito**.

## 🚀 Cómo se recorre

Lee `00-historia-del-sistema.md` primero, para saber qué estás heredando. Después
las fases en orden: cada una construye sobre la anterior y ninguna se sostiene
sola. Los apéndices se consultan cuando la fase te manda a ellos. Los incidentes
se abren cuando llegas a la fase que los produce — el índice del cuaderno te dice
cuál corresponde a cada momento.

**Cierra cada fase con su tag** (`git tag -a fase-04-rifas-crud …`). Es el hábito
que después te deja correr `git tag -l 'fase-*'` y saber dónde estás sin releer
nada — y, en un curso donde vas a romper cosas a propósito, el que te deja volver
a un estado sano sin pensarlo. La convención completa está en
`00-convencion-de-git-y-tags.md` y se lee en diez minutos.

Y una advertencia sobre el cuaderno: cada incidente trae su solución adentro,
colapsada. Abrirla antes de escribir tu propio diagnóstico no te ahorra tiempo,
te ahorra el aprendizaje. 😉

## 📐 Convenciones

Tu progreso se lleva en git: un repo por aplicación, commits con el prefijo de
la fase (`f04: …`), un tag anotado por fase cerrada y pares de tags
`-roto` / `-fix` para los incidentes. Todo eso está en
`00-convencion-de-git-y-tags.md`.

El código va **en inglés** (identificadores, endpoints, constantes). Los
comentarios, los textos de interfaz y toda la narrativa van **en español
latinoamericano con tuteo**. El detalle está en
`prompts/guia-de-estilo-y-convenciones.md`, que es la fuente de verdad
editorial, y el diccionario de términos del dominio en
`prompts/diccionario-codigo-ingles.md`.
