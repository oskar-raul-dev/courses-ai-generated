# 🏢 Historia del sistema

> Tutorial Angular 8 — Laboratorio clínico · Ficha de contexto ·
> **Se lee antes de la Fase 0**
> ~25 minutos · No hay código acá: hay motivos.

Este documento cuenta de dónde viene LabCore, el sistema que vas a mantener. No
es decoración narrativa: es la información que en un trabajo real **nadie te da**
y que te pasarías tres semanas reconstruyendo a partir de `git blame`, de un
Confluence desactualizado y de gente que ya no está en la empresa.

> 📝 **Todo lo que sigue es ficción, y a propósito.** Andina Laboratories Inc. no
> existe, sus fundadores tampoco, y LabCore menos. Los inventamos enteros para
> este curso, y esa es exactamente la razón de que podamos contarte la historia
> completa —con fechas, decisiones y errores incluidos— sin omitir nada. Un caso
> de estudio real siempre viene recortado por un NDA; este viene entero. Lo que sí
> es real es el escenario: las ciudades, las leyes y los caminos de migración
> existen, y la historia se mueve dentro de ellos. Y lo más importante: **el curso
> construye LabCore pieza por pieza**, así que cuando el material diga "así lo
> hace LabCore", vas a poder abrir el archivo y comprobarlo.

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

## 2. 🏭 La empresa y la gente que la hizo

### 🔬 Qué hace Andina, en un párrafo

Andina Laboratories Inc. —Laboratoires Andina del lado de Quebec— es una red
chica de laboratorio clínico en la región de la capital de Canadá: un laboratorio
central en Ottawa, con los analizadores grandes, y varios puntos de toma de
muestras repartidos a los dos lados del río Ottawa, en Ottawa (Ontario) y en
Gatineau (Quebec). Un médico genera una orden para un paciente; en el punto de
toma se extrae la muestra y arranca su cadena de custodia; la muestra cruza la
ciudad —a veces cruza la frontera provincial—, se recibe, se procesa; el
resultado se compara contra un **rango de referencia**; un analista lo valida
—y esa validación es irreversible—; el informe se entrega en PDF y el turno se
mira desde un dashboard.

El negocio es mediano y regulado, y esa segunda parte explica más decisiones del
sistema que cualquier consideración técnica. Cada tanto llega una auditoría y
pide el histórico: quién tomó la muestra, a qué hora, quién validó el resultado y
contra qué versión del rango. Un dato mal guardado acá no es un bug de
interfaz; es un hallazgo de auditoría con nombre y apellido.

### 🧳 Las fundadoras: de la caja registradora al laboratorio propio

Andina la fundaron dos profesionales de laboratorio que llegaron a Canadá en
2008 por el programa federal de trabajadores calificados: **Liliana Ospina**,
bacterióloga colombiana, y **Rocío Paredes**, tecnóloga médica peruana. Se
conocieron en una clase de inglés para recién llegados en Ottawa, y lo que sigue
es la historia de cualquier profesional latinoamericano que migró con un título
que Canadá no reconoce de entrada.

Los primeros años fueron de trabajo de supervivencia. Liliana fue cajera en un
supermercado y después dependienta en una farmacia; Rocío hizo turnos de limpieza
nocturna en un hospital, que era lo más cerca de un laboratorio a lo que podía
entrar. Mientras tanto, certificaron el inglés, y después —porque en la región
de la capital el francés abre la mitad de las puertas— empezaron con el francés.
La convalidación les llevó casi tres años: evaluación de estudios, el examen de
certificación nacional de tecnólogos de laboratorio médico, el registro ante el
colegio profesional de Ontario y prácticas supervisadas. Hacia 2011 las dos
trabajaban como tecnólogas en laboratorios de clínicas de Ottawa.

Ahí vieron lo que después fue el negocio. Una parte grande de los pacientes de
esas clínicas eran latinoamericanos —recién llegados, trabajadores temporales,
familias con abuelos que no hablaban ni inglés ni francés— y la experiencia de
hacerse un examen era, para ellos, una cadena de malentendidos: la preparación
mal entendida, el ayuno que no se hizo, el informe que nadie les podía explicar.
Liliana hizo un posgrado en gestión de laboratorios clínicos; Rocío, una maestría
en microbiología. En 2016 tenían el plan: un laboratorio privado que atendiera
en los tres idiomas de su barrio.

### 🩺 El patólogo y la plata

A un laboratorio clínico en Canadá no lo dirige quien quiere. La licencia
provincial exige un director médico, y ninguna de las dos lo era. Lo encontraron
por la red de amigos latinos de Ottawa, en un asado de cumpleaños: **Tomás
Lagos**, patólogo general, nacido en Montreal en 1976, hijo de una pareja de
chilenos que llegó como refugiada después del golpe de 1973. Tomás creció
hablando francés en la escuela, inglés en el hospital y español en la mesa, y
entendió el proyecto en diez minutos, porque había visto a sus padres pasar por
lo mismo.

Tomás aceptó ser el director médico con una participación minoritaria, y trajo
algo que las fundadoras no tenían: credibilidad ante el dinero. Reunió a los
inversores —dos médicos colegas y un empresario de la comunidad latina de
Ottawa con una cadena de tiendas de alimentos— y Andina abrió en 2017.

El nicho era el **pago privado**, no el sistema público: pacientes que pagan de
su bolsillo o por un seguro complementario porque quieren el resultado rápido,
recién llegados que todavía no tienen cobertura provincial, exámenes laborales
para empresas, y clínicas privadas que necesitaban un laboratorio que les
contestara el teléfono. Y la promesa de la casa, la que figuraba en el folleto
desde el primer día: **te atendemos y te explicamos el resultado en tu idioma**.

### 🗣️ Por qué tres idiomas

Esa promesa es la razón de que LabCore hable tres idiomas, y conviene entender
que los tres no pesan lo mismo.

El **inglés** es el idioma de Ontario y el de la sede: es el idioma en que
trabaja el laboratorio central y el que se usa ante el regulador de Ontario. El
**francés** llegó con Gatineau, y llegó como obligación legal: en Quebec la
Carta de la lengua francesa exige que el comercio y el trabajo se hagan en
francés, y la Ley 96 de 2022 la endureció. El **español** no lo exige nadie: es
la decisión de las fundadoras, y es lo que diferencia a Andina de los
laboratorios grandes.

La consecuencia práctica es una asimetría que vas a ver en el código y en el
negocio. El informe que vale ante un auditor es el inglés en Ontario y el
francés en Quebec; el español se entrega como cortesía. Un texto que falta en
`es.json` es una molestia; uno que falta en `fr.json`, del lado de Gatineau, es
un incumplimiento.

---

## 3. 🕰️ Las tres eras del código

LabCore no lo escribió una persona con un plan. Lo escribieron tres equipos en
tres años, cada uno resolviendo el problema que tenía delante con las
herramientas de su momento. Las capas se ven a simple vista cuando sabes qué
buscar.

### 🪨 Era 1 (2019) — "que salga antes de que renueve la licencia"

De 2017 a 2019 Andina trabajó con un sistema de laboratorio comercial alquilado
por usuario, pensado para hospitales anglófonos: sin español, con un francés de
catálogo y con un costo de licencia que crecía con cada técnico contratado.
Cuando los inversores decidieron que Andina iba a crecer, también decidieron que
no iba a crecer pagando esa licencia. El sistema propio tenía que estar listo
antes de la renovación de septiembre de 2019.

Para escribirlo contrataron a **Chaudière Conseils**, una consultora chica de
Gatineau que hacía proyectos para el gobierno federal y que, como tantas en
Canadá, construía con un equipo *nearshore*: el líder técnico y el analista en
Gatineau, y cinco desarrolladores en San José, Costa Rica. El equipo era mixto
—canadienses, costarricenses, un nicaragüense— y el inglés fue la lengua común
del código, convención que quedó hasta hoy.

Angular 8 había salido en mayo de ese año y era lo estable; todo lo de esta era
se escribió como Angular documentaba en 2019, y buena parte de lo que hoy te va
a chocar viene de ahí:

- **NgRx, elegido en plena discusión "NgRx o servicios"**, y montado al estilo de
  la época: acciones, reducers con `switch`, `action: any`, sin `runtimeChecks`.
  Nada de `createFeature` ni de las comodidades que llegaron después, porque no
  existían.
- **`strict: false` y `any` tolerado** — el TS-0 del curso. Que quede claro que no
  fue pereza: el modo estricto como opción de `ng new` llegó en Angular 10, y por
  defecto en la 12. En la 8 ni siquiera era una casilla que alguien pudiera
  marcar.
- **RxJS al mínimo**: `subscribe()` a pelo, `mergeMap` donde hoy pondrías
  `concatMap`, y `rxjs-compat` arrastrado desde un proyecto anterior de la
  consultora.
- **Bootstrap 4 heredado de otro producto de la consultora, más Angular Material
  añadido encima** porque el datepicker y la tabla venían gratis. Dos design
  systems, ninguna capa de aislamiento, y una cascada que se pelea sola.
- **El token JWT en `localStorage`, sin refresh**, que en 2019 era la opción por
  defecto de casi cualquier tutorial aunque ya se supiera que es vulnerable a XSS.
  La alternativa segura exigía cambios en un backend que era de otro frente.
- **Las fechas con desfase fijo.** Los datos de prueba y buena parte del código
  escriben las horas con `-05:00` pegado, el desfase de Ottawa en invierno. El
  proyecto arrancó en febrero, el equipo que más código escribió vivía en Costa
  Rica —donde la hora no cambia nunca— y nadie se hizo la pregunta de marzo. Es
  la deuda de tiempo más cara del sistema, y la que menos se ve: hablamos de ella
  en §4.

En la primera versión la interfaz no tenía i18n: Andina tenía una sola sede, en
Ottawa, y las pantallas salieron con los textos en inglés escritos directo en
las plantillas.

Lo que se hizo mal y se paga hasta hoy: **cero pruebas**. Ni una. El equipo
de San José pasó a otro cliente de la consultora cuando terminó el contrato, y
con él se fue el único modelo mental completo del sistema.

> 🧠 **Lo que te llevas de esta era.** Cuando veas un reducer con `switch` y un
> `action: any`, no estás viendo a alguien perezoso: estás viendo 2019. El
> apéndice **A06** es el traductor de NgRx de la época, y **A05** el de RxJS de
> supervivencia.

### 🧱 Era 2 (2020) — "esto ya no es una sede, es una red"

En 2020 llegó la pandemia, y para un laboratorio privado eso fue, ante todo,
demanda. Las pruebas PCR de pago para viajeros, para empresas y para quienes no
querían esperar la fila pública multiplicaron el volumen en meses. Andina abrió
puntos de toma en Ottawa y, por primera vez, cruzó el río: dos puntos en
Gatineau, uno de ellos en un barrio con mucha población latinoamericana.

El sistema creció con la empresa, y creció por el camino que Angular hacía
natural: **un módulo con carga diferida por cada feature, cada uno arrastrando
su propio slice de estado**. Elegante en el diagrama; el problema —que el estado
de la aplicación dependa de por dónde navegó el usuario— tardó años en
reconocerse como tal, y solo aparece cuando hay siete slices y alguien entra
directo por un enlace que le pasaron por chat.

De esta era son también dos cosas que van a definir tu experiencia leyendo el
código. La primera es **el componente gordo**: la pantalla que consulta el store,
despacha acciones, formatea, valida y decide reglas de negocio, todo en el mismo
archivo. La segunda es **la regla repetida**: LabCore acumuló reglas de negocio en
tres pantallas distintas a lo largo de los años, escritas por gente distinta, y en
alguna de esas copias falta un caso. Acá construyes una sola, y el reflejo que te
llevas es buscar las otras dos antes de dar un fix por cerrado.

La internacionalización también es de esta era, y la trajo Gatineau. Del lado de
Quebec el personal tenía derecho a trabajar en francés, los pacientes latinos
eran la razón de ser de la empresa, y en 2019-2020 el i18n nativo de Angular 8 no
permitía cambiar de idioma **sin recargar la aplicación**: `@angular/localize`
llega en la 9. Así que se montó `@ngx-translate` con carga por HTTP. La extracción
de los textos la hizo un segundo contrato con la misma consultora, otra vez desde
San José, y el equipo hizo lo que haría cualquiera que piensa en español: escribió
primero `es.json`, sacó `en.json` de los textos originales y mandó el francés a
una agencia de traducción, que entregaba por lotes y con semanas de retraso. Por
eso el idioma por defecto quedó en `'es'` —era el idioma de trabajo de quienes lo
configuraron, y nadie volvió a mirarlo— y por eso `fr.json` siempre va un paso
detrás de los otros dos. El árbol de claves creció desde ahí por sedimentación.

### 🧬 Era 3 (2021) — "cambió el rango, y vino la auditoría"

El último crecimiento grande lo empujaron dos cosas del negocio, no de la
tecnología.

La primera fue **un cambio en los rangos de referencia**. El laboratorio adoptó
intervalos armonizados para varios analitos, y los rangos dejaron de ser los
mismos. Alguien preguntó lo correcto en el momento correcto —*¿y qué pasa con
los resultados que ya validamos?*— y de ahí salió la decisión que sostiene medio
curso: **los rangos se versionan**, nace una v2 con su vigencia, el histórico
queda intacto, y un resultado se lee siempre contra la versión que estaba vigente
cuando se validó. La regla se enuncia en una línea y se rompe de varias maneras;
la Fase 8 vive de eso.

La segunda fue **la auditoría**. Con el volumen de la pandemia, Andina quería
contratos con aseguradoras y con clínicas grandes, y esos contratos pedían una
acreditación de calidad que exigía trazabilidad completa, y la exigía para ayer.
El backend estaba congelado y sin dueño, así que se tomó la decisión
defendible-en-2019 y difícil-de-defender-hoy: **el audit log lo escribe el
frontend**. El actor sale del token que vive en el navegador, el timestamp sale
del reloj de la máquina del operador, y si la escritura del asiento falla, la
mutación ya ocurrió y nadie se entera. Es exactamente el bug del incidente
**17**, y es la razón de que ese incidente se sienta injusto: lo es.

En esa misma tanda entraron el dashboard operativo y la entrega en PDF, y con el
dashboard llegó la deuda más visual del sistema: **dos motores de gráficos
conviviendo**. `ngx-charts` estaba desde antes por un gráfico que nadie quiso
tocar; `ng2-charts` entró para lo nuevo. Hay año y medio de distancia entre las
fechas de publicación de las dos, las dos siguen en el `package.json`, y las dos
pesan en el bundle.

### 🧊 Hoy — mantenimiento y cuenta regresiva

En 2022 la demanda de PCR desapareció tan rápido como había llegado. Andina
quedó más grande de lo que era en 2019 y más chica de lo que soñó en 2021, y los
inversores tomaron la decisión que explica el presente: no se invierte más en un
sistema propio. LabCore se va a reemplazar por un sistema de laboratorio
comercial cuando la empresa pueda pagarlo, y eso, según el plan, es en dos o
tres años.

Desde 2021 no entran features. Entran **cambios normativos, requerimientos
legales y hotfixes**, y casi todos vienen del lado de Quebec: la Ley 96 obliga a
cada vez más empresas a trabajar en francés, y la Ley 25 cambió las reglas sobre
qué datos personales pueden salir de la provincia y en qué condiciones. Node
quedó en la 12 (la 14 en las máquinas donde `node-sass` no compilaba de otra
forma), Angular en 8.2.14, y nadie va a subir eso: migrar cuesta más que
aguantar.

La aplicación se despliega como un contenedor con nginx delante, y arrastra la
fricción que ordena el final del curso: **la configuración se hornea en tiempo de
compilación y el contenedor querría inyectarla en tiempo de arranque**. De ahí
sale la mitad de los "funciona en UAT y no en PROD" del sistema, y de ahí sale el
incidente **19**.

### 🗄️ La otra mitad del sistema — el backend, que era de otro frente

Todo lo anterior es el navegador. Del otro lado del cable hay un sistema que este
curso casi no menciona y que conviene que conozcas, porque explica varias
decisiones que de otro modo parecen caprichos.

En la misma tanda de 2019, otro frente de la consultora escribió el backend:
**Java 8, Spring Boot 2.1 y MongoDB**. La elección de la base tiene una historia
y no es la que uno esperaría. El líder técnico venía de años de proyectos para
el gobierno federal, sobre un Oracle con un DBA que tardaba tres semanas en
aprobar una columna nueva, y en la primera reunión dijo la frase que funda medio
sistema: *"con Mongo el esquema lo movemos nosotros"*.

**Y tenía razón.** Ese dolor era real. Hay más: **una parte del dominio de un
laboratorio sí es documental de verdad**. Un hemograma y un perfil lipídico no
comparten forma, y modelarlos en tablas duele. El equipo vio ese caso, acertó, y
**generalizó desde ahí a todo el sistema** — pacientes, órdenes, custodias y rangos
incluidos. Ese es el error interesante: no fue ignorancia, fue una buena
intuición aplicada fuera de su rango.

Dos detalles del despliegue de 2019 que nadie volvió a revisar y que siguen vivos:
se levantó **un `mongod` suelto**, no un replica set; y la base quedó contratada
como servicio gestionado, en una región canadiense porque los datos de salud no
podían salir del país, con un proveedor que tiene calendario propio. Desde
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
  congelado y sin dueño no era una conversación que se pudiera tener en 2021.
- **El timestamp y el "quién" de la cadena de custodia los pone el navegador**
  (Fase 7), por lo mismo.

En este curso **no tocas el backend**: en la Fase 4 construyes un mock que lo
imita, y con eso alcanza para todo lo demás. Pero cuando una fase diga *"esto se
arregla del otro lado"*, ya sabes de qué otro lado habla.

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

- **Las fechas se comparan con `Date` pelado, y el desfase es fijo.** No se
  adoptó ninguna librería de tiempo con zona horaria: en 2019, con NgRx recién
  montado, meter otra dependencia era una conversación que nadie quería tener. Y
  el `-05:00` de la Era 1 es correcto de noviembre a marzo; de marzo a noviembre
  Ottawa y Gatineau están en `-04:00`, y una hora escrita con el desfase de
  invierno es un instante que ocurrió una hora más tarde de lo que dice el reloj
  de la pared. El resultado es una lógica correcta casi todos los días y falsa
  los fines de semana, en las madrugadas y en los dos domingos del año en que
  cambia la hora. Los incidentes de tiempo del cuaderno viven todos ahí, y el
  del cambio de hora es el **22**.

- **Paginar, filtrar y ordenar se hace en el navegador.** El backend nunca expuso
  paginación, así que la lista se trae entera y se corta con `slice()`. Con
  veinticinco registros es instantáneo; LabCore tiene tablas donde eso significa
  varios megabytes por pantalla.

- **La interfaz sale de claves de i18n, siempre, y el idioma por defecto es el
  español.** Es la diferencia visible más grande con cualquier tutorial de
  Angular que hayas visto: acá no hay textos literales en la plantilla. Que la
  aplicación arranque en `'es'` en una empresa con sede en Ontario parece un
  error, y en parte lo es, pero tiene la historia de la Era 2: fue el idioma de
  quienes extrajeron los textos. Cambiarlo hoy toca el arranque, el fallback de
  las claves que faltan y la costumbre de cuarenta operadores; por eso sigue ahí.
  El código, en cambio, está en inglés, porque el equipo de la consultora era
  mixto y la convención quedó.

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
refresh token. No hay paginación de servidor. No hay zona horaria en ningún
lado: solo desfases. No hay observabilidad más allá de la consola y de la
bitácora que escribe el propio front. No hay feature flags. No hay backend en
este repositorio: el de LabCore existe, no tiene dueño y está descrito arriba,
pero lo que tú levantas es un mock que lo imita (Fase 4). Y no hay nada
posterior a Angular 8 —ni Ivy, ni standalone, ni `inject()`, ni el control flow
nuevo—; todo eso aparece solo como comparación, en **A10** y **A11**.

Hay además cosas que LabCore sí tiene y este curso no construye: las mil claves de
traducción crecidas por sedimentación, los siete slices de siete manos, las
pantallas que repiten la misma regla. Se cuentan como historia porque son la
razón de la mitad de las deudas, pero no vas a poder abrirlas: acá construyes una
versión chica y honesta de cada cosa, y lo que te llevas es el reflejo.

Esa lista es, palabra por palabra, el backlog técnico eterno de miles de sistemas
reales. Que te resulte familiar es el punto.

---

## 6. 🎭 Tu rol en esta ficción

Entras al equipo de Maintenance de Andina. Eres senior en backend y esta es tu
primera vez sosteniendo un frontend ajeno. Trabajas a distancia, como casi todo
el equipo de tecnología desde la pandemia, y eso tiene una consecuencia que vas
a sentir desde el primer día: la evaluación de privacidad que Andina tuvo que
hacer por la Ley 25 terminó en una regla simple, **nadie ve datos de producción
desde fuera del laboratorio**. Todo lo que investigues lo vas a reproducir sobre
datos inventados, y por eso el mock de la Fase 4 no es un juguete: es tu única
ventana al sistema.

Nadie te va a hacer onboarding porque no hay quien: el equipo de San José pasó a
otro cliente de la consultora en 2020, de los que crecieron el sistema en 2021
queda una persona asignada a otro producto que responde cuando puede, y la
documentación que existe describe una versión del sistema que ya no es la que
está desplegada. Liliana, que hoy es la directora de operaciones, te va a
escribir cuando algo se rompa del lado de Gatineau; no sabe de Angular, pero
sabe exactamente qué paciente está esperando qué resultado.

Tienes el código, esta ficha, y veintidós tickets vagos esperándote en el
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
