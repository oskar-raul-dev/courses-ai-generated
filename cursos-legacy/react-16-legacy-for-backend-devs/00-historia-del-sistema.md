# 🏢 Historia del sistema

> Tutorial React 16 — Rifas y Chances · Ficha de contexto · **Se lee antes de la Fase 0**
> ~20 minutos · No hay código acá: hay motivos.

Este documento cuenta de dónde viene el sistema que vas a mantener. No es
decoración narrativa: es la información que en un trabajo real **nadie te da** y
que te pasarías tres semanas reconstruyendo a partir de commits y de gente que
ya no está en la empresa.

> 📝 **Todo lo que sigue es ficción, y a propósito.** Rifas y Chances S.A.S. no
> existe. La inventamos entera para este curso, y esa es exactamente la razón de
> que podamos contarte la historia completa —con nombres, fechas y malas
> decisiones incluidas— sin omitir nada. Un caso de estudio real siempre viene
> recortado; este viene entero.

---

## 1. Por qué esto va antes que el código

Hay una pregunta que separa al mantenedor que sirve del que no, y aparece la
primera vez que abres un archivo feo: **¿esto está así a propósito o por
error?**

Sin contexto, no tiene respuesta. Ves un componente de 400 líneas con lógica de
negocio adentro y solo puedes elegir entre dos reacciones igual de malas:
"esto está mal, lo reescribo" —y rompes tres cosas que dependían de ese
desorden— o "esto es intocable" —y no arreglas nunca nada.

Con contexto, la pregunta se responde sola. Ese componente se escribió en 2019
contra un deadline, por alguien que no volvió, sobre un React que todavía no
tenía hooks. No está mal: está **fechado**. Y lo que se hace con el código
fechado no es reescribirlo, es tocarlo con cuidado y saber por dónde.

Por eso esta ficha va antes que la Fase 0. Léela una vez ahora y vuelve a ella
cuando una decisión del código te parezca inexplicable. Casi siempre está acá.

---

## 2. La empresa, en un párrafo

Rifas y Chances S.A.S. vende rifas. Una rifa tiene diez mil números
(`0000`–`9999`), un precio por número y un premio base; se abre, se venden
números durante unos días, se cierra a una hora exacta, se resuelve contra el
resultado de una lotería y se liquida. Los vendedores trabajan en kioscos y en
sus teléfonos, la tesorería mira el dashboard, y todo el mundo llama a soporte
cuando algo no cuadra.

El negocio es chico —una decena de personas usando la plataforma a diario— y esa
escala importa: explica por qué muchas decisiones que en Google serían absurdas
acá fueron sensatas. No hay un equipo de plataforma, no hay SRE, no hay
presupuesto para reescribir nada.

---

## 3. Las tres eras del código

El sistema no lo escribió una persona con un plan. Lo escribieron tres equipos
distintos en cuatro años, cada uno resolviendo el problema que tenía delante con
las herramientas de su momento. Las capas se ven a simple vista cuando sabes qué
buscar.

### 🪨 Era 1 (2019) — "que funcione para el sorteo de diciembre"

La primera versión la escribió un contratista externo en tres meses, contra la
fecha del sorteo de fin de año. React 16.8 acababa de salir con hooks, pero nadie
los conocía todavía y la documentación oficial seguía llena de clases: **todo lo
de esta era son class components**, con `componentDidMount`, `this.setState` y
`connect()` de react-redux.

Lo que quedó de esa era y sigue vivo hoy: la tabla de rifas (`RaffleTable`,
todavía una clase), el patrón de páginas en `src/pages/`, y la costumbre —que
nadie discutió después— de que los componentes de listado se conecten al store
directamente en vez de recibir datos por props.

Lo que se hizo mal y se paga hasta hoy: no hubo tests. Ni uno. El contratista se
fue en enero y con él se fue el único modelo mental completo del sistema.

> 🧠 **Lo que te llevas de esta era.** Cuando veas una clase con `connect()`, no
> estás viendo a alguien anticuado: estás viendo 2019. El apéndice
> `A5-class-components-vs-hooks.md` es el traductor.

### 🧱 Era 2 (2020-2021) — "ahora sí, con Redux Toolkit"

En 2020 entró un equipo interno de dos personas. Encontraron un Redux clásico
con action types a mano y un `switch` de doscientas líneas, y tomaron una
decisión razonable: **no reescribir lo viejo, pero escribir lo nuevo con Redux
Toolkit**. `createSlice`, `createAsyncThunk`, `configureStore`.

De ahí sale la mezcla que define este sistema y que vas a tener delante todo el
curso: **slices modernos conviviendo con `connect()` clásico**, hooks conviviendo
con clases, en la misma pantalla y despachando al mismo store. No es un
accidente ni un descuido: fue la decisión correcta. Reescribir lo que funciona
para uniformar estilo es gastar riesgo sin comprar nada.

Esta era también trajo el problema que define la Fase 5. Cuando la venta pasó de
un kiosco a tres, aparecieron los números vendidos dos veces. La solución de
entonces fue optimista: pintar la celda al instante y revertir si el servidor
protestaba. Funciona el 99% de las veces, y el 1% restante es el incidente ⭐ 11.

### 🌀 Era 3 (2022-2023) — "esto necesita cancelación"

El problema que rompió el modelo anterior fue el polling. La lotería tarda entre
dos y veinte minutos en publicar el resultado, así que hay que preguntar cada
pocos segundos. Con `setInterval` funcionaba… hasta que alguien cerraba sesión y
el navegador seguía preguntando. Para siempre.

Ahí entró **redux-observable con RxJS 6**, y con él la parte más difícil de
mantener de todo el sistema. Los epics resolvieron de verdad los problemas de
cancelación —`takeUntil`, `switchMap`, `debounceTime`—, pero introdujeron una
clase de bug nueva: **el que no se ve**. Un `takeUntil` olvidado no rompe nada
hoy; deja una suscripción viva que dispara acciones fantasma la semana que viene.

Esta es la era que más caro sale y por eso el curso le dedica doce horas (Fase 6)
más un apéndice entero (`A7-redux-observable-epica-por-epica.md`).

En 2023 se congeló todo. Node 14, React 16.14, CRA 4. Nadie subió nada desde
entonces, y la razón es la única razón honesta que existe: **funciona, y nadie
tiene presupuesto para arriesgarse a que deje de funcionar.**

---

## 4. Quién dejó qué (y qué sabemos de por qué)

En un sistema real esto se reconstruye leyendo `git blame` y preguntando en el
canal de Slack. Acá te lo damos hecho:

- **La tabla de rifas es una clase y el formulario es un hook.** No es
  inconsistencia: la tabla es de 2019 y el formulario de 2021. Nadie migró la
  tabla porque migrar un componente que funciona, sin tests, es riesgo puro. La
  Fase 11 la migra —pero recién después de que la Fase 10 le puso la red.

- **El token vive en `localStorage` y no expira.** Decisión de 2019, cuando "auth"
  significaba un endpoint que devuelve un string. Está mal por seguridad y está
  documentado como tal en la Fase 2. No se arregla en este curso porque
  arreglarlo de verdad es trabajo de backend, y el curso es de frontend.

- **El dinero se guarda en centavos, como entero, sin librería.** Esta sí fue una
  buena decisión, y de las pocas que se tomaron con la cabeza fría: vino después
  de una liquidación de 2021 que dio catorce centavos de diferencia y le costó a
  tesorería una tarde de conciliación. El post-mortem de entonces es el incidente
  18.

- **El mock tiene un "modo caos" que la producción no tiene.** Este es el único
  componente que no es herencia: lo agregamos para el curso (Fase 3). En
  producción el caos viene gratis y sin avisar, un martes a las cuatro. Acá lo
  hacemos reproducible porque el objetivo es entrenar el ojo, no sufrir al azar.

- **No hay i18n.** La app es en español para usuarios de habla hispana, y así se
  escribió: los textos de interfaz van directo en el JSX, sin claves de
  traducción. El código, en cambio, va en inglés, porque el contratista de 2019
  era de fuera y la convención quedó. Es una mezcla rara y es la que vas a ver.

---

## 5. Lo que el sistema NO tiene

Tan importante como lo que hay. Si buscas alguna de estas cosas, no las vas a
encontrar, y no es que no las hayas visto todavía:

No hay TypeScript, no hay tests hasta que tú los escribas (Fase 10), no hay CI,
no hay feature flags, no hay observabilidad más allá de `console.log`, no hay
roles ni permisos —cualquiera logueado puede hacer todo—, no hay refresh token,
no hay paginación, no hay manejo de imágenes, y el `db.json` se resetea a mano.

Esa lista es, palabra por palabra, el backlog técnico eterno de miles de sistemas
reales. Que te resulte familiar es el punto.

---

## 6. Tu rol en esta ficción

Entras al equipo de mantenimiento. Eres senior en backend y esta es tu primera
vez sosteniendo un frontend ajeno. Nadie te va a hacer onboarding porque no hay
quien: el contratista se fue, uno de los dos de la era 2 también, y el que queda
está en otro proyecto.

Tienes el código, esta ficha, y los tickets que van a ir llegando.

El curso te hace construir el sistema fase por fase antes de pedirte que lo
mantengas, y eso es una licencia pedagógica deliberada: construir cada capa con
sus decisiones explicadas es la forma más rápida de que después reconozcas esas
decisiones cuando te las encuentres escritas por otro. Al llegar a la Fase 5 ya
no vas a sentir que escribiste ese código: vas a sentir que lo heredaste. Esa es
la sensación que buscamos.

> **La señal de que esta ficha hizo su trabajo:** cuando abras un archivo raro y
> tu primera reacción no sea "qué mal está esto", sino "¿de qué era es esto y qué
> problema resolvía?".
