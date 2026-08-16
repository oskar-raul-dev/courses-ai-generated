# 🏢 Historia del sistema

> Tutorial Angular 8 — Laboratorio clínico · Ficha de contexto ·
> **Se lee antes de la Fase 0**
> ~20 minutos · No hay código acá: hay motivos.

Este documento cuenta de dónde viene LabCore, el sistema que vas a mantener. No
es decoración narrativa: es la información que en un trabajo real **nadie te da**
y que te pasarías tres semanas reconstruyendo a partir de `git blame`, de un
Confluence desactualizado y de gente que ya no está en la empresa.

> 📝 **Todo lo que sigue es ficción, y a propósito.** Laboratorios Andina S.A.S.
> no existe y LabCore tampoco. Los inventamos enteros para este curso, y esa es
> exactamente la razón de que podamos contarte la historia completa —con fechas,
> decisiones y errores incluidos— sin omitir nada. Un caso de estudio real
> siempre viene recortado por un NDA; este viene entero. Y lo más importante:
> **el curso construye LabCore pieza por pieza**, así que cuando el material diga
> "así lo hace LabCore", vas a poder abrir el archivo y comprobarlo.

---

## 1. 🧭 Por qué esto va antes que el código

Hay una pregunta que separa al mantenedor que sirve del que no, y aparece la
primera vez que abres un archivo feo: **¿esto está así a propósito o por error?**

Sin contexto, no tiene respuesta. Ves un componente de cuatrocientas líneas con
la regla de negocio adentro, cuatro `.subscribe()` que nadie cierra y un `any`
que atraviesa tres capas, y solo puedes elegir entre dos reacciones igual de
malas: *"esto está mal, lo reescribo"* —y rompes tres cosas que dependían de ese
desorden— o *"esto es intocable"* —y no arreglas nunca nada.

Con contexto, la pregunta se responde sola. Ese componente se escribió en 2019
contra una fecha de salida, por gente que ya no está, sobre un Angular que
todavía no tenía la mitad de lo que hoy das por sentado. No está mal: está
**fechado**. Y lo que se hace con el código fechado no es reescribirlo, es
tocarlo con cuidado y saber por dónde.

Hay además un dato que ordena todas las decisiones del curso y conviene tenerlo
delante desde el primer día: **LabCore tiene fecha de muerte**. La decomisión
está prevista en dos o tres años. Eso no es una excusa para dejarlo podrirse,
pero sí cambia la aritmética de cada deuda: pagar una que tarda un mes en un
sistema al que le quedan veinticuatro es, muchas veces, la decisión equivocada.
Por eso este curso declara sus deudas 💸 en voz alta y **casi ninguna se paga**.
Aprender a *no* arreglar algo, y saber decir por qué, es parte del oficio.

Léela una vez ahora y vuelve a ella cuando una decisión del código te parezca
inexplicable. Casi siempre está acá.

---

## 2. 🏭 La empresa, en un párrafo

Laboratorios Andina S.A.S. es una red de laboratorios clínicos: una sede central
con los analizadores grandes y varias sucursales que toman muestras y las
despachan. Un médico genera una orden para un paciente; en la sucursal se toma la
muestra y arranca su cadena de custodia; la muestra viaja, se recibe, se procesa;
el resultado se compara contra un **rango de referencia** que sale de una norma;
un analista lo valida —y esa validación es irreversible—; el informe se entrega en
PDF y el turno se mira desde un dashboard.

El negocio es mediano y regulado, y esa segunda parte explica más decisiones del
sistema que cualquier consideración técnica. Cada tanto llega una auditoría y
pide el histórico: quién tomó la muestra, a qué hora, quién validó el resultado y
contra qué versión de la norma. Un dato mal guardado acá no es un bug de
interfaz; es un hallazgo de auditoría con nombre y apellido.

---

## 3. 🕰️ Las tres eras del código

LabCore no lo escribió una persona con un plan. Lo escribieron tres equipos en
tres años, cada uno resolviendo el problema que tenía delante con las
herramientas de su momento. Las capas se ven a simple vista cuando sabes qué
buscar.

### 🪨 Era 1 (2019) — "que salga para la sede central"

La primera versión la escribió un equipo contratado, contra la fecha en que la
sede central dejaba el sistema anterior. Angular 8 había salido en mayo de ese
año y era lo estable; todo lo de esta era se escribió como Angular documentaba en
2019, y buena parte de lo que hoy te va a chocar viene de ahí:

- **NgRx, elegido en plena discusión "NgRx o servicios"**, y montado al estilo de
  la época: acciones, reducers con `switch`, `action: any`, sin `runtimeChecks`.
  Nada de `createFeature` ni de las comodidades que llegaron después, porque no
  existían.
- **`strict: false` y `any` tolerado** — el TS-0 del curso. Que quede claro que no
  fue pereza: el modo estricto como opción de `ng new` llegó en Angular 10, y por
  defecto en la 12. En la 8 ni siquiera era una casilla que alguien pudiera
  marcar.
- **RxJS al mínimo**: `subscribe()` a pelo, `mergeMap` donde hoy pondrías
  `concatMap`, y `rxjs-compat` arrastrado desde un proyecto anterior.
- **Bootstrap 4 heredado de otro producto de la casa, más Angular Material
  añadido encima** porque el datepicker y la tabla venían gratis. Dos design
  systems, ninguna capa de aislamiento, y una cascada que se pelea sola.
- **El token JWT en `localStorage`, sin refresh**, que en 2019 era la opción por
  defecto de casi cualquier tutorial aunque ya se supiera que es vulnerable a XSS.
  La alternativa segura exigía cambios en un backend que era de otro equipo.

Lo que se hizo mal y se paga hasta hoy: **cero pruebas**. Ni una. El equipo
contratado se fue cuando terminó el contrato y con él se fue el único modelo
mental completo del sistema.

> 🧠 **Lo que te llevas de esta era.** Cuando veas un reducer con `switch` y un
> `action: any`, no estás viendo a alguien perezoso: estás viendo 2019. El
> apéndice **A06** es el traductor de NgRx de la época, y **A05** el de RxJS de
> supervivencia.

### 🧱 Era 2 (2020) — "esto ya no es una sede, son seis"

Cuando la red creció, el sistema creció con ella, y creció por el camino que
Angular hacía natural: **un módulo con carga diferida por cada feature, cada uno
arrastrando su propio slice de estado**. Elegante en el diagrama; el problema
—que el estado de la aplicación dependa de por dónde navegó el usuario— tardó años
en reconocerse como tal, y solo aparece cuando hay siete slices y alguien entra
directo por un enlace que le pasaron por chat.

De esta era son también dos cosas que van a definir tu experiencia leyendo el
código. La primera es **el componente gordo**: la pantalla que consulta el store,
despacha acciones, formatea, valida y decide reglas de negocio, todo en el mismo
archivo. La segunda es **la regla repetida**: LabCore acumuló reglas de negocio en
tres pantallas distintas a lo largo de los años, escritas por gente distinta, y en
alguna de esas copias falta un caso. Acá construyes una sola, y el reflejo que te
llevas es buscar las otras dos antes de dar un fix por cerrado.

La internacionalización también es de esta era. Al entrar sucursales con público
en otros idiomas hizo falta cambiar de idioma **sin recargar la aplicación**, y en
2019-2020 el i18n nativo de Angular 8 simplemente no permitía eso: `@angular/localize`
llega en la 9. Así que se montó `@ngx-translate` con carga por HTTP, y con él un
árbol de claves que fue creciendo por sedimentación durante dos años.

### 🧬 Era 3 (2021) — "cambió la norma, y vino la auditoría"

El último crecimiento grande lo empujaron dos cosas del negocio, no de la
tecnología.

La primera fue **un cambio normativo**: los rangos de referencia dejaron de ser
los mismos. Alguien preguntó lo correcto en el momento correcto —*¿y qué pasa con
los resultados que ya validamos?*— y de ahí salió la decisión que sostiene medio
curso: **los rangos se versionan**, nace una v2 con su vigencia, el histórico
queda intacto, y un resultado se lee siempre contra la versión que estaba vigente
cuando se validó. La regla se enuncia en una línea y se rompe de varias maneras;
la Fase 8 vive de eso.

La segunda fue **la auditoría**, que pidió trazabilidad completa y la pidió para
ayer. El backend estaba congelado y era de otro equipo, así que se tomó la
decisión defendible-en-2019 y difícil-de-defender-hoy: **el audit log lo escribe
el frontend**. El actor sale del token que vive en el navegador, el timestamp sale
del reloj de la máquina del operador, y si la escritura del asiento falla, la
mutación ya ocurrió y nadie se entera. Es exactamente el bug del incidente **17**,
y es la razón de que ese incidente se sienta injusto: lo es.

En esa misma tanda entraron el dashboard operativo y la entrega en PDF, y con el
dashboard llegó la deuda más visual del sistema: **dos motores de gráficos
conviviendo**. `ngx-charts` estaba desde antes por un gráfico que nadie quiso
tocar; `ng2-charts` entró para lo nuevo. Hay año y medio de distancia entre las
fechas de publicación de las dos, las dos siguen en el `package.json`, y las dos
pesan en el bundle.

### 🧊 Hoy — mantenimiento y cuenta regresiva

Desde 2021 no entran features. Entran **cambios normativos, requerimientos
legales y hotfixes**. Node quedó en la 12 (la 14 en las máquinas donde `node-sass`
no compilaba de otra forma), Angular en 8.2.14, y nadie va a subir eso: la
decomisión está a dos o tres años y migrar cuesta más que aguantar.

La aplicación se despliega como un contenedor con nginx delante, y arrastra la
fricción que ordena el final del curso: **la configuración se hornea en tiempo de
compilación y el contenedor querría inyectarla en tiempo de arranque**. De ahí
sale la mitad de los "funciona en UAT y no en PROD" del sistema, y de ahí sale el
incidente **19**.

### 🗄️ La otra mitad del sistema — el backend, que era de otro equipo

Todo lo anterior es el navegador. Del otro lado del cable hay un sistema que este
curso casi no menciona y que conviene que conozcas, porque explica varias
decisiones que de otro modo parecen caprichos.

En la misma tanda de 2019, otro frente del equipo contratado escribió el backend:
**Java 8, Spring Boot 2.1 y MongoDB**. La elección de la base tiene una historia
y no es la que uno esperaría. Venían de un Oracle corporativo con un DBA que
tardaba tres semanas en aprobar una columna nueva, y alguien dijo la frase que
funda medio sistema: *"con Mongo el esquema lo movemos nosotros"*.

**Y tenía razón.** Ese dolor era real. Hay más: **una parte del dominio de un
laboratorio sí es documental de verdad**. Un hemograma y un perfil lipídico no
comparten forma, y modelarlos en tablas duele. El equipo vio ese caso, acertó, y
**generalizó desde ahí a todo el sistema** — pacientes, órdenes, custodias y rangos
incluidos. Ese es el error interesante: no fue ignorancia, fue una buena
intuición aplicada fuera de su rango.

Dos detalles del despliegue de 2019 que nadie volvió a revisar y que siguen vivos:
se levantó **un `mongod` suelto**, no un replica set; y la base quedó contratada
como servicio gestionado, con un proveedor que tiene calendario propio. Desde
entonces el proveedor la subió de versión cuatro veces, cada una en su ventana de
mantenimiento y cada una anunciada por un correo que alguien archivó. La
aplicación, en cambio, no se movió nunca.

> 🧠 **A la infraestructura la actualizan; a la aplicación no.** La base tenía
> dueño —un proveedor, una auditoría, un calendario ajeno—. El código no tenía
> ninguno.

Cuando el contrato terminó, ese frente se fue igual que el del frontend. El
backend quedó **congelado y sin dueño**, y así sigue: en los papeles lo heredó
Maintenance, o sea tú. Esa es la frase que explica dos de las deudas más incómodas
del sistema, y ahora ya sabes por qué se tomaron:

- **El audit log lo escribe el frontend** (Fase 11) no porque a nadie se le
  ocurriera algo mejor, sino porque pedirle un endpoint nuevo a un backend
  congelado y ajeno no era una conversación que se pudiera tener en 2021.
- **El timestamp y el "quién" de la cadena de custodia los pone el navegador**
  (Fase 7), por lo mismo.

En este curso **no tocas el backend**: en la Fase 4 construyes un mock que lo
imita, y con eso alcanza para todo lo demás. Pero cuando una fase diga *"esto se
arregla del otro lado"*, ya sabes de qué otro lado habla.

---

---

## 4. 🔎 Quién dejó qué (y qué sabemos de por qué)

En un sistema real esto se reconstruye leyendo commits y preguntando en el canal
de Slack. Acá te lo damos hecho:

- **Los siete slices los escribió gente distinta a lo largo de tres años.** Por
  eso no hay `runtimeChecks` encendidos: activarlos hoy, sobre ese código, muy
  probablemente rompa el arranque en algún sitio que nadie toca hace meses. Eso es
  un ticket de investigación con fecha, no una línea de configuración que se cuela
  en el hotfix del viernes. Lo que sí haces es saber que el interruptor existe
  (**A06 §9.4**): el día que persigas un "la pantalla no se actualiza", encenderlo
  en tu rama es la primera prueba que corres.

- **El token vive en `localStorage` y no expira solo.** Decisión de 2019, cuando
  "auth" significaba un endpoint que devuelve un JWT. Está mal por seguridad,
  está documentado como tal en la Fase 3, y no se arregla en este curso porque
  arreglarlo de verdad es trabajo del backend. La señalas y sigues.

- **El timestamp y el "quién" de la cadena de custodia los pone el navegador.**
  La hora sale del reloj de una máquina que el operador puede cambiar, y el actor
  sale de un token que vive en `localStorage`. En un sistema auditado eso es
  exactamente lo que un auditor busca, y es lo que hace posibles los incidentes
  **11** y **17**.

- **Los componentes se suscriben sin cerrar.** En 2019 no existía nada que lo
  hiciera por ti; el patrón de la época era `takeUntil(this.destroy$)` con un
  `Subject` que emite en `ngOnDestroy`, y LabCore lo usa **en algunos sitios sí y
  en otros no**, sin criterio escrito. Funcionaba hasta que el dashboard empezó a
  arrastrarse al final del turno, que es el incidente **16**.

- **Las fechas se comparan con `Date` pelado.** No se adoptó ninguna librería de
  tiempo con zona horaria: en 2019, con NgRx recién montado, meter otra
  dependencia era una conversación que nadie quería tener. El resultado es una
  lógica correcta el noventa y cinco por ciento de los días y falsa los fines de
  semana. Los incidentes de tiempo del cuaderno viven todos en ese cinco por
  ciento.

- **Paginar, filtrar y ordenar se hace en el navegador.** El backend nunca expuso
  paginación, así que la lista se trae entera y se corta con `slice()`. Con
  veinticinco registros es instantáneo; LabCore tiene tablas donde eso significa
  varios megabytes por pantalla.

- **La interfaz sale de claves de i18n, siempre.** Es la diferencia visible más
  grande con cualquier tutorial de Angular que hayas visto: acá no hay textos
  literales en la plantilla. El código, en cambio, está en inglés, porque el
  equipo del arranque era mixto y la convención quedó.

- **El "modo caos" del mock no existe en producción.** Este es el único componente
  que no es herencia: lo construyes tú en la Fase 4. En producción el caos viene
  gratis y sin avisar, un martes a las cuatro. Acá lo hacemos reproducible porque
  el objetivo es entrenar el ojo, no sufrir al azar.

---

## 5. 🕳️ Lo que el sistema NO tiene

Tan importante como lo que hay. Si buscas alguna de estas cosas, no las vas a
encontrar, y no es que no las hayas visto todavía.

No hay `strict` ni tipado de formularios —`patientForm.get('documentId').value` es
`any`, y escribirlo con una mayúscula de más devuelve `null` sin que nadie te
avise—. No hay pruebas hasta que las escribas tú (Fase 12). No hay CI. No hay
refresh token. No hay paginación de servidor. No hay observabilidad más allá de
la consola y de la bitácora que escribe el propio front. No hay feature flags. No
hay backend en este repositorio: el de LabCore existe, es de otro equipo y está
descrito arriba, pero lo que tú levantas es un mock que lo imita (Fase 4). Y no hay
nada posterior a Angular 8 —ni Ivy, ni standalone, ni `inject()`, ni el control
flow nuevo—; todo eso aparece solo como comparación, en **A10** y **A11**.

Hay además cosas que LabCore sí tiene y este curso no construye: las mil claves de
traducción crecidas por sedimentación, los siete slices de siete manos, las
pantallas que repiten la misma regla. Se cuentan como historia porque son la
razón de la mitad de las deudas, pero no vas a poder abrirlas: acá construyes una
versión chica y honesta de cada cosa, y lo que te llevas es el reflejo.

Esa lista es, palabra por palabra, el backlog técnico eterno de miles de sistemas
reales. Que te resulte familiar es el punto.

---

## 6. 🎭 Tu rol en esta ficción

Entras al equipo de Maintenance. Eres senior en backend y esta es tu primera vez
sosteniendo un frontend ajeno. Nadie te va a hacer onboarding porque no hay quien:
el equipo contratado del arranque se fue en 2020, de los que crecieron el sistema
en 2021 queda una persona asignada a otro producto que responde cuando puede, y
la documentación que existe describe una versión del sistema que ya no es la que
está desplegada.

Tienes el código, esta ficha, y veintiún tickets vagos esperándote en el
`cuaderno-incidentes.md`.

El curso te hace construir LabCore fase por fase antes de pedirte que lo
mantengas, y eso es una licencia pedagógica deliberada: escribir cada capa con sus
deudas declaradas en voz alta es la forma más rápida de que después reconozcas
esas decisiones cuando te las encuentres tomadas por otro. Al llegar a la Fase 10
ya no vas a sentir que escribiste ese dashboard: vas a sentir que lo heredaste, y
vas a estar buscando dónde alguien olvidó cerrar una suscripción. Esa es la
sensación que buscamos.

> **La señal de que esta ficha hizo su trabajo:** cuando abras un archivo feo y tu
> primera reacción no sea "qué mal está esto", sino "¿de qué era es esto, qué
> problema resolvía, y cuánto le queda de vida al sistema como para que valga la
> pena arreglarlo?".
