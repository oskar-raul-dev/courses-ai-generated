# 🏢 Historia del sistema

> Paquete Vue 2 legacy + MongoDB — Mesa de soporte · Ficha de contexto ·
> **Se lee antes de la Fase 0 de cualquiera de los dos cursos**
> ~20 minutos · No hay código acá: hay motivos.
> **Vigencia:** 2026-10-06.

Este documento cuenta de dónde viene la Tiquetera, el sistema que vas a
mantener. No es decoración narrativa: es la información que en un trabajo real
**nadie te da** y que te pasarías tres semanas reconstruyendo a partir de
`git log`, de un README de 2019 y de un fundador que contesta por WhatsApp con
audios de cuatro minutos.

> 📝 **Todo lo que sigue es ficción, y a propósito.** Cuadre Software S.A.S. no
> existe, la Tiquetera tampoco, y nadie de esta historia es una persona real.
> Los inventamos enteros para este paquete, y esa es exactamente la razón de que
> podamos contarte la historia completa —con fechas, decisiones y errores
> incluidos— sin omitir nada. Un caso de estudio real siempre viene recortado
> por un NDA; este viene entero. Y lo más importante: **los dos cursos
> construyen la Tiquetera pieza por pieza**, el frontend en el Curso 01 y el
> backend en el Curso 02, así que cuando el material diga "así está", vas a
> poder abrir el archivo y comprobarlo.

---

## 1. 🧭 Por qué esto va antes que el código

Hay una pregunta que separa al mantenedor que sirve del que no, y aparece la
primera vez que abres un archivo raro: **¿esto está así a propósito o por
error?**

En la Tiquetera esa pregunta tiene una respuesta que no vas a encontrar en
otros legacies, y conviene tenerla desde el primer día: buena parte de este
código **no la escribió un ingeniero**. La escribió un técnico en electrónica
que aprendió a programar de noche, con cursos en línea, y que eligió cada pieza
del stack porque le gustó o porque fue la que vio en el último curso. No hubo
comparativas ni comité de arquitectura. Hubo entusiasmo, mucho, y un negocio que
necesitaba la herramienta para ayer.

Eso no hace al código malo; lo hace **legible de otra manera**. Cuando veas una
decisión que ningún arquitecto tomaría, no busques el razonamiento técnico que
no hubo: busca el curso, el gusto o la urgencia que la explican. Casi siempre
están en esta ficha. Y cuando veas un pedazo con otra mano —más ordenado, con
nombres consistentes, con algo parecido a una prueba—, ya sabrás que llegó
después, con otra persona o con un Felipe que ya había aprendido más.

Léela una vez ahora y vuelve a ella cuando una decisión del código te parezca
inexplicable.

---

## 2. 🏭 La empresa, en un párrafo (y el taller que vino antes)

**Cuadre Software S.A.S.** nació en Itagüí a comienzos de 2019 para venderle a
bares, estaderos, billares, tiendas de barrio y pequeñas pizzerías y ventas de
comida rápida un sistema sencillo: **Cuadre**, para que dejaran de quedarse
cortos de cerveza o de insumos por no saber cuánto pedir, y de cuadrar caja con
calculadora. La facturación electrónica llegó después, como un módulo que se
paga aparte. Es una empresa chica y lo sigue siendo: nunca tuvo inversionistas,
nunca tuvo departamento de recursos humanos, y la oficina fue durante años el
segundo piso de un taller.

Ese taller es la otra mitad de la historia. Desde 2011 la familia Ríos fabrica
**bolirranas** en Itagüí para tiendas, billares y estaderos del Valle de Aburrá,
y desde 2014 también **máquinas de arcade** con emuladores. El taller nunca hizo
millonario a nadie, pero hizo algo más importante para esta historia: le dio al
fundador **un piso económico**. Gracias a él pudo dedicarle medio tiempo al
software durante años sin apostar la comida de la casa, y pudo buscar socios
para emprender en vez de buscar empleo. Es un patrón muy común en las startups
colombianas que no salen de una aceleradora: el negocio familiar paga el
arriendo mientras el proyecto nuevo aprende a caminar.

La mesa de soporte de Cuadre —la que este paquete reconstruye— atiende a esos
comercios cuando algo falla: la impresora térmica, el cierre de caja que no
cuadra y, desde 2020, **la factura electrónica que FacilFactCol o la DIAN
rechazan**.

---

## 3. 📅 Cómo llegó hasta aquí

La Tiquetera no la escribió una persona con un plan. Empezó como el proyecto de
una persona que llevaba pocos años programando, entró a producción en tres
meses de pandemia, creció a punta de características que se le fueron pegando,
y la intentaron modernizar tres veces sin terminar ninguna. Las capas se ven a
simple vista cuando sabes qué buscar.

| Año | Qué pasó | Quién | Lo que dejó |
|---|---|---|---|
| 2011 | Don Arturo y Felipe abren el taller de bolirranas | La familia | El piso económico de todo lo que sigue |
| 2014 | La maquinita del vecino: el primer arcade, sobre Raspberry Pi | Felipe | Su primer roce con Linux y con código ajeno |
| 2014–2015 | "¿Y si las vendemos por encargo?": la web del taller | Don Arturo propone, Felipe la hace | Bootstrap y jQuery en los dedos; el gusanillo |
| 2015–2017 | Los arcades agarran tracción; Felipe delega la fabricación | La familia | El instructivo y la imagen maestra de la memoria SD |
| 2017 | El sistemita de pedidos del taller, en PHP a pelo | Felipe | `pedidos.php`, MySQL, y la confianza de que podía |
| 2017–2018 | La "carrera" de desarrollo web en Platzi; ahí conoce Vue | Felipe | La elección de Vue, por una metáfora |
| 2018 | Empieza la Tiquetera, desde cero y en inglés, para el soporte de los arcades | Felipe | El esquema relacional que luego viaja a Mongo |
| 2019 | Un estadero de diez bolirranas pide pedidos y cuadre de caja: nace Cuadre | Felipe, el Mono y Diana Patricia | La empresa y el soporte por WhatsApp |
| 2019 | El hosting pasa a PHP 7; la Tiquetera se va a un VPS con Node y Mongo | Felipe | `soporte_v1` |
| Abr–jun 2020 | "Denme tres meses": la Tiquetera entra a Cuadre | Felipe, el Mono y Valentina | Vuex a medio camino, sockets, la base `tiquetera` |
| 2020 | Módulo de factura electrónica, integrado con un proveedor por SOAP | Felipe y Diana Patricia | Los feature flags, aprendidos a las malas |
| 2021–2022 | Chicos por horas, características encima de características | Felipe y los que fueron llegando | La tabla de puntajes en el monitor; la segunda Laura |
| 2021–2023 | Tres ramas de los sábados: Quasar, Vuetify y Nuxt | Felipe y uno o dos de los chicos | Tres ramas a medio terminar |
| 2023–2025 | Vue 2 sin soporte; "si sirve, no lo toque" | Felipe | El congelamiento del stack, no de las características |
| 2025–2026 | PizzaPaisa: el contacto, la demostración en una sede y la auditoría | Un amigo del Mono abre la puerta; Felipe y Diana Patricia presentan | El primer cuestionario de seguridad de la empresa |
| 2026 | Entran los primeros desarrolladores contratados con proceso | Tú | Este paquete |

### 🔧 Era 0 (2011–2015) — el taller, la maquinita y la web

Andrés Felipe Ríos —Felipe, en la casa, en el barrio y en el resto de esta
ficha— es **técnico en electrónica del SENA**. En 2011 abrió con su papá, don
Arturo, un taller de bolirranas en Itagüí. El reparto quedó claro desde el
primer día: don Arturo llevaba las cuentas y los clientes, y Felipe hacía la
parte que nadie más sabía hacer, el tablero electrónico que cuenta los puntos.
Las ventas llegaban por boca a boca entre propietarios de estaderos y bares, y
así funcionó tres años. A nadie se le había ocurrido tener una página web,
porque no hacía falta.

En 2014 un vecino de la cuadra había visto en internet lo de los emuladores y
le preguntó a Felipe si *"se le medía"* a armarle una maquinita para jugar
**Mortal Kombat y Street Fighter**, que eran sus juegos de toda la vida.
Sacaron costos, se pusieron de acuerdo, y Felipe armó su primer **arcade con
emuladores sobre una Raspberry Pi**. Ahí tuvo el primer roce serio con el
software, aunque él no lo llamaba así: instalar una distribución de Linux desde
la consola, pelear con archivos de configuración que no cargaban, y copiar de
un foro el script que hacía que los botones respondieran. El mueble, en cambio,
fue lo fácil: un taller que ya cortaba MDF, pintaba y metía electrónica en una
caja de madera para las bolirranas tenía resuelto lo que a cualquier otro
armador le costaba más.

La primera maquinita tuvo su cicatriz. Street Fighter corría bien, pero
**Mortal Kombat se ponía lento justo en los fatalities**, y el vecino lo hacía
notar cada vez que Felipe pasaba por la casa. Se arregló a comienzos de 2015,
cuando salió la Raspberry Pi 2 y Felipe le cambió la placa sin cobrarle. Para
entonces ya sabía que existían las tarjetas chinas con cientos de juegos
precargados, que se conectaban y listo; las descartó porque no las entendía por
dentro, y a él le gustaba entender. Es la misma decisión que va a repetir, años
después, frente a las herramientas comerciales de soporte.

Don Arturo vio la máquina terminada en la sala del vecino e hizo la pregunta
que cambió todo: *"Oiga, mijo, ¿será que esas maquinitas se le pueden vender a
otros muchachos? ¿De pronto si las ponemos a la venta por encargo, a ver?"*. El
boca a boca de los estaderos no llegaba a ese público, y por primera vez el
taller necesitó **una página web**.

Felipe la hizo él mismo. La primera versión fue un WordPress en un hosting
compartido con cPanel; la segunda la rehízo "a mano" copiando plantillas de
**Bootstrap** y pegando snippets de **jQuery**. Lo que más le quedó de esa web
no fueron las ventas: fue **el gusanillo de la programación**.

### 🕹️ Era 1 (2015–2017) — la tracción y el sistemita del taller

Los encargos llegaron, y en dos o tres años los arcades dejaron de ser un
experimento. Apareció un público que nadie esperaba: **hombres de cuarenta y
pico que querían un arcade en la sala de su casa** con todos los juegos de
cuando eran pelados, en los ochenta y los noventa. Primero por la web, después
por Mercado Libre, la línea de arcades pasó a ser la que más le aportaba al
taller, y lo sigue siendo.

Con la tracción vino el problema de siempre: Felipe era el único que sabía
dejar una máquina funcionando. Para soltarla armó dos cosas que todavía se usan
en el taller: una **imagen maestra de la memoria SD**, con el sistema, los
emuladores y los juegos ya configurados, para que bastara con clonarla; y un
**instructivo con fotos**, plastificado y pegado en la pared, con los pasos para
cargarla, probar los controles y empacar. Camilo, su hermano menor, aprendió a
armar las máquinas con eso, y hacia 2017 la fabricación ya no dependía de
Felipe.

El tiempo que le quedó libre lo gastó en el primer sistema de verdad que
escribió: **el sistemita de pedidos del taller**. El dolor era concreto. Con
bolirranas y arcades saliendo a la vez, don Arturo llevaba los pedidos en un
cuaderno, las facturas en un talonario y los materiales de memoria, y cada
tanto **se acababa una pintura o faltaban joysticks en plena producción**, con
los repuestos importados tardando semanas en llegar. Felipe lo resolvió en un
par de meses de noches con lo que había aprendido de los tutoriales de PHP de
Maestros del Web, La Web del Programador y los foros de la época:

```php
<?php
// pedidos.php — 2017. Conexión, consulta y HTML, todo en el mismo archivo.
$link = mysql_connect("localhost", "taller", "********");
mysql_select_db("taller", $link);
$pedidos = mysql_query("SELECT * FROM pedidos ORDER BY fecha DESC");
while ($p = mysql_fetch_assoc($pedidos)) {
    echo "<tr><td>" . $p['cliente'] . "</td><td>" . $p['producto'] . "</td></tr>";
}
```

Era PHP a pelo, con la lógica, la base y el HTML en el mismo archivo, nombres
en español, y la impresión de la factura saliendo directo del navegador.
También funcionó: la contabilidad de don Arturo se ordenó, los pedidos de
material empezaron a salir con tiempo, y Felipe se quedó con algo más
importante que el sistema, la confianza de que podía construir uno.

De esos años le quedaron tres hábitos que vas a reconocer en la Tiquetera:
Bootstrap y jQuery los escribe de memoria, MySQL era la única base de datos que
conocía, y la costumbre de que **un solo archivo lo haga todo** —consultar,
decidir y pintar— pasó intacta de `pedidos.php` a los componentes grandes de
Vue.

### 🌱 Era 2 (2017–2019) — Platzi, la Tiquetera y Cuadre

Entre 2017 y 2018 Felipe hizo en las madrugadas la "carrera" de desarrollo web
de Platzi. Años después se enteró de que uno de sus fundadores era el mismo de
Maestros del Web, el sitio de los tutoriales de PHP con los que había empezado. En el curso de Vue tuvo el momento que define todo el frontend:
*"son como etiquetas HTML, pero cada una es un componente completo"*. Para
alguien que venía de copiar plantillas de Bootstrap y de mezclar PHP con HTML,
eso fue amor a primera vista. No hubo comparación con React ni con Angular, y
no hacía falta: era la herramienta que entendía.

En 2018 empezó con Vue un proyecto propio: **su gestor de tickets**. El primer
uso no fue una mesa de soporte de software, sino **el soporte de los arcades**:
los compradores de Mercado Libre escribían que el botón tres no respondía o que
la máquina no prendía después de un apagón, y esos casos se perdían entre
WhatsApp y el cuaderno de don Arturo. Existían herramientas comerciales y él
las conocía, pero tenía el proyecto en la cabeza, le gustaba construir sus
propias cosas, y con el taller detrás podía darse el lujo. Es la decisión de
muchísimos fundadores técnicos, y no es irracional: es la diferencia entre usar
algo y entenderlo.

Esta vez decidió hacerlo **desde cero y bien**, con lo que los cursos llamaban
buenas prácticas, y la primera de la lista era escribir el código **en
inglés**. No le costó. Como muchos niños de los noventa, Felipe aprendió buena
parte de su inglés a la fuerza, con diccionario al lado, para entender los
juegos de rol de consola que eran sus favoritos y las letras de las canciones de
rock y pop que se sabía de memoria. Desde 2017, además, le dedicaba unas horas a
la semana a la ruta de inglés de Platzi. Por eso `pedidos.php` está en español y
la Tiquetera no: entre uno y otro, Felipe decidió que ya era programador.

El backend lo hizo con lo que sabía, PHP y MySQL, con un archivo por recurso.

A comienzos de 2019 vino el salto, y vino de los clientes del taller. Los bares
y estaderos que compraban bolirranas tenían el mismo dolor que el taller con la
pintura, pero con la cerveza: cuando pasaba el preventista de la cervecería a
tomar el pedido de la semana, nadie sabía bien cuánto pedir, y el sábado en la
noche se quedaban cortos de la que más se vendía. Felipe les mostró el sistemita
de pedidos, y a varios les sirvió casi tal cual.

El que lo cambió todo fue don Gildardo, dueño de un estadero grande sobre la
autopista Sur con **diez bolirranas**, de los mejores clientes del taller. Le
preguntó si al sistema le podía agregar **el cuadre de caja**, que en su
estadero se hacía a mano, con calculadora, al cierre de cada noche, y que
*"siempre, siempre"* daba distinto. Felipe se lo hizo, y del nombre de esa
pantalla salió el de la empresa.

Con eso vio el negocio. Le dejó el día a día del taller a don Arturo y a
Camilo, se quedó como socio y con medio tiempo, y fundó **Cuadre** con dos
socios (§4): **Jhon Fredy, "el Mono"**, un vecino tecnólogo en sistemas que
también le metía mano al código, y su prima **Diana Patricia**, técnica
contable, que llevaba las cuentas. El producto nació como la versión seria del
sistemita: pedidos a proveedores y cuadre de caja, reescrito para muchos
comercios y no para uno. El soporte arrancó como arrancan casi todos: un
WhatsApp Business, un Gmail compartido y un Excel llamado `PENDIENTES.xlsx`.

Ese mismo año el hosting compartido pasó a PHP 7 y **`pedidos.php` amaneció en
blanco**: las funciones `mysql_*` ya no existían. Felipe lo parchó una noche
cambiando a `mysqli` con buscar y reemplazar, y sacó una conclusión que pesa en
este paquete: no quería seguir en PHP. Había hecho otro curso, uno de stack
MEAN, y salió convencido de que *"con Mongo es JSON de punta a punta"*. Contrató
un **VPS en Hostinger**, el más barato, instaló Node y MongoDB siguiendo un
tutorial, reescribió el backend de la Tiquetera con Express y pasó los datos
**transcribiendo su esquema de MySQL tabla por tabla**: una colección por tabla,
un entero por llave foránea, una tabla de prioridades y otra de estados. Ese
modelo sigue vivo en la base **`soporte_v1`**, y es el que el Curso 02
diagnostica y opera. No es el trabajo de alguien descuidado: es el de alguien
que aplicó lo único que sabía de bases de datos a un motor que pedía otra cosa.

El tutorial, de paso, no decía nada de contraseñas: MongoDB quedó escuchando en
el puerto por defecto, abierto a internet y sin autenticación, durante casi un
año. Nadie entró. El Mono lo descubrió leyendo un artículo sobre bases de Mongo
secuestradas, y esa noche nadie durmió.

### 🔥 Era 3 (abril–junio de 2020) — "denme tres meses"

En marzo de 2020 llegó la pandemia y el equipo se fue a trabajar desde la casa.
El WhatsApp de soporte, que en la oficina se atendía gritándose *"¡ese es
mío!"* de un escritorio al otro, se volvió inmanejable: dos personas
respondiendo el mismo mensaje, mensajes que nadie respondía, y el Excel de
pendientes abierto en tres computadores con tres versiones distintas.

Diana Patricia puso sobre la mesa la cotización de una mesa de ayuda comercial.
Se cobraba por agente y en dólares, y **el dólar acababa de pasar los cuatro
mil pesos**. Para una empresa de tres socios con los bares y estaderos —la mitad
de su clientela— cerrados por decreto, la tachó ella misma. Las herramientas
baratas tampoco servían: ninguna amarraba el ticket al **NIT del comercio**,
que era lo primero que había que mirar en cada caso.

Felipe dijo la frase que funda el sistema: *"eso lo hacemos nosotros, yo ya
tengo algo"*. Y lo tenía: llevaba más de un año atendiendo el soporte de los
arcades con la Tiquetera, a medias y para un solo taller. Pidió tres meses.

Para cumplirlos se sumó **Valentina Ospina**, ingeniera de sistemas recién
graduada, que llegó por recomendación —era hermana del dueño de una de las
pizzerías clientes— y fue la primera persona con formación formal que tocó el
código. Entre abril y junio, con el equipo de soporte usando la Tiquetera en
producción mientras ellos la pulían, pasaron casi todas las cosas que vas a
reconocer:

- **Vuex entró a mitad de camino.** Cuando el estado compartido ya se había
  regado por los componentes, Felipe hizo un curso de Vuex un fin de semana y
  lo metió el lunes, con Valentina empujando para que fuera en todo y perdiendo
  contra el calendario. Por eso conviven pantallas que leen del store con
  pantallas que piden sus propios datos. Esa tensión es la Fase 10.
- **Los WebSockets entraron porque ya nadie estaba en la oficina.** El grito de
  *"¡entró uno!"* tuvo que llegar solo. Felipe había visto la demo del chat en
  tiempo real de socket.io en un curso y la adaptó en una noche. Es la Fase 8.
- **La base limpia, `tiquetera`**, la diseñó Valentina para lo nuevo, sin migrar
  lo viejo: `soporte_v1` siguió viva porque tenía el histórico de los arcades y
  de los primeros meses de Cuadre, y nadie tuvo tiempo de pasarlo. Las dos bases conviven desde entonces.
- **Cero pruebas.** Nadie le había enseñado a Felipe a escribirlas, y en el
  taller los arcades "se probaban jugando". Valentina quiso escribirlas y perdió
  esa discusión, también contra el calendario.

### 🧾 La factura electrónica y los feature flags aprendidos a las malas (2020)

En la segunda mitad de 2020, con los negocios reabriendo de a poco, el
calendario de **facturación electrónica** de la DIAN alcanzó a muchos de los
clientes de Cuadre: la resolución que lo fijó en mayo de ese año les dio a los
sectores más golpeados por la pandemia hasta el 1 de noviembre. Felipe no llegaba en blanco: el propio taller había tenido
que pasarse a factura electrónica, y él había peleado con el portal del
proveedor, con los rechazos y con la resolución de numeración.

Cuadre no podía emitir facturas electrónicas por su cuenta —para eso hay que
ser proveedor tecnológico habilitado, y una empresa de tres socios no lo es—,
así que hizo lo que hacen casi todos los sistemas pequeños: **se integró con un
proveedor tecnológico**. Escogieron **FacilFactCol**, un proveedor de bajo costo
que opera para pymes, cobra por paquetes de documentos y era el mismo que ya
usaba el taller. Su API era lo usual de la época, **SOAP y XML**, con un WSDL de
doscientas páginas y una documentación en PDF que no coincidía del todo con lo
que el servicio respondía. Desde entonces, cuando una factura se cae, el
soporte tiene que averiguar primero de quién es la culpa: de Cuadre, de
FacilFactCol o de la DIAN.

Diana Patricia decidió que el módulo se **cobraba aparte**, y ahí Felipe
aprendió los feature flags a las malas. La primera versión de "quién tiene
factura electrónica" fue una lista de NIT escrita en el código; la segunda, un
campo en la base que un deploy dejó en `true` para todos un viernes. Durante un
fin de semana, una docena de comercios que no lo habían pagado facturaron
electrónicamente, y el lunes Diana Patricia tuvo que llamarlos uno por uno.

Para la Tiquetera eso dejó una regla que nunca llegó al código: todo ticket de
un comercio lleva su **NIT**, y los de facturación, además, su **resolución de
numeración**. El campo iba a llegar "en la próxima versión". Mientras tanto,
los agentes escriben el NIT **al comienzo del título**, entre corchetes, y el
buscador es la única forma de encontrar los casos de un comercio. La ironía no
se le escapa a nadie: amarrar el ticket al NIT era una de las razones para no
comprar una herramienta comercial.

### 📈 Era 4 (2021–2022) — los chicos por horas

El soporte dejó de alcanzar con los socios, y el desarrollo también. Cuadre
contrató como contratan las empresas chicas sin departamento de recursos
humanos: **por contactos y con un aviso en la cartelera** de una institución
universitaria de Medellín, buscando estudiantes de sistemas que pudieran
trabajar por horas, como freelance. Sin proceso de selección, sin prueba
técnica: una conversación con Felipe, un repositorio compartido y un *"hágale,
mire a ver qué tal"*. Así se sostuvo el crecimiento, y así llegó al código la
variedad de estilos que vas a encontrar.

Con más manos llegaron más características, todas sobre el mismo Vue 2: filtros
nuevos, el panel de soporte, etiquetas, plantillas de respuesta. Cuando el
equipo volvió a la oficina en 2021, la tabla de puntajes (§5), que en la casa
había sido una pestaña compartida, pasó a un monitor en la pared. Y en 2022
entró **la segunda Laura**, con las mismas iniciales que la primera.

### 🔀 Las ramas de los sábados (2021–2023)

Felipe seguía aprendiendo, y con el tiempo maduró como ingeniero de software
más que muchos con el título. Ya intuía que el sistema necesitaba algo más que
características nuevas, y empezó a **cacharrear frameworks sobre Vue** los
sábados, con uno o dos de los chicos, buscando herramientas con más cosas
resueltas. Los tres intentos tenían sentido, y los tres quedaron en ramas a
medio terminar:

| Rama | Qué buscaban | Por qué quedó a medias |
|---|---|---|
| `quasar-app` | *"Con Quasar sacamos la app del celular con el mismo código"*: la cola y las notificaciones en el teléfono, sin una app aparte | Funcionó en el celular de Felipe y en ninguno más; los agentes siguieron en el portátil |
| `vuetify-redesign` | Dejar de escribir a mano el orden, el filtro y la paginación de cada tabla; `v-data-table` lo traía hecho | El chico que la llevaba se fue a trabajar remoto para una empresa de afuera, en dólares |
| `nuxt-ayuda` | Un centro de ayuda público con SSR, para que Google lo indexara y bajaran los tickets de *"¿cómo anulo una factura?"* | Se cruzó con un cierre de año de la DIAN y nadie lo retomó |

Por eso las rutas del Curso 01 son **excluyentes**: no es una regla de diseño
del curso, es que heredas tres ramas y alguien tiene que escoger **cuál
rescatar**. Las otras dos se quedan donde están, cerradas con un tag de archivo.
Lo propio de cada rama —quién la llevó, en qué estado quedó y qué le pide hoy
la cadena (sección siguiente)— sigue en la historia de tu ruta:
[`q00-historia-ruta-q.md`](01-vue2-legacy/q00-historia-ruta-q.md),
[`vu00-historia-ruta-vu.md`](01-vue2-legacy/vu00-historia-ruta-vu.md) o
[`nx00-historia-ruta-nx.md`](01-vue2-legacy/nx00-historia-ruta-nx.md).

### 🧊 2023–2025 — "si sirve, no lo toque"

Vue 2 llegó al final de su soporte el 31 de diciembre de 2023. Felipe lo sabía
—lo había leído, lo había comentado, tenía una nota en el README que dice
`TODO: migrar a Vue 3`—, y aun así pesó más la regla de taller: **si sirve, no
lo toque**. Desde entonces el stack está congelado —Node 14, Vue 2.6, Vuex 3,
Bootstrap 4, socket.io 2, MongoDB 4.4, con los últimos parches que alguien subió
en 2022—, pero las características no: se le siguieron metiendo, sobre la misma
versión, cada vez que un cliente o el soporte lo pidió.

Cuadre siguió siendo chica: unos pocos cientos de comercios, la oficina en
Itagüí, y la Tiquetera también para los tickets internos —por eso vas a ver
casos de impresoras y de carpetas compartidas—. Valentina se fue en 2022, y
desde entonces el código lo sostienen Felipe, el Mono y los chicos que van y
vienen.

### 🍕 Hoy (2025–2026) — PizzaPaisa y la primera auditoría

El cambio no vino de adentro. Vino del cliente más grande que Cuadre ha tenido.

**PizzaPaisa** es una cadena con más de veinte sucursales en Medellín y el Valle
de Aburrá, buena parte de ellas franquiciadas, con una oficina central chica y
la tecnología tercerizada en una firma externa. Creció más rápido que sus
procesos: cada sede hacía el cuadre de caja a su manera, los pedidos de insumos
salían por WhatsApp, y la oficina central consolidaba todo en un Excel que
llegaba por correo, incompleto, al día siguiente.

A Cuadre llegó por donde llegan las empresas chicas a las grandes: **por un
contacto**. Un amigo del Mono desde el colegio trabaja en la parte
administrativa de la cadena. En 2025 sabía que la gerencia estaba buscando
proveedor para un sistema de cajas, y en un partido de fútbol de los jueves se
acordó de que el Mono andaba en *"algo de software para cuadrar caja"*. La
pregunta fue casi la misma que años antes hizo don Arturo: *"¿y eso de ustedes
no serviría para nosotros?"*.

Él les consiguió lo único que podía conseguirles: **una demostración en una
sede pequeña**, de las franquiciadas, con un franquiciado dispuesto a probar.
Durante un mes esa sede hizo sus pedidos y su cuadre en Cuadre, y el
franquiciado, que no conocía a nadie de la empresa, lo contó en la reunión
mensual de franquicias. Con eso el contacto pudo pedir la cita que de otro modo
no habría conseguido: Felipe y Diana Patricia presentaron ante el jefe de
operaciones y la de compras, en una sala de juntas de verdad, con proyector, y
salieron con un *"nos interesa, pero lo tiene que revisar TI"*.

Lo que vino después fue nuevo para Cuadre: la firma que le maneja la tecnología
a la cadena mandó **un cuestionario de seguridad y continuidad** como requisito
antes de firmar, y pidió una reunión para revisar las respuestas. No era nada
exótico para una empresa de ese tamaño, pero Cuadre nunca había tenido que
responder uno, y varias preguntas dolieron:

- **¿Qué versiones de sus componentes están en soporte?** Vue 2, Node 14 y
  MongoDB 4.4 llevaban años sin él.
- **¿Cómo miden los tiempos de respuesta del soporte?** La cadena pedía un
  acuerdo de nivel de servicio con tiempos medidos, y las métricas de la
  Tiquetera se calculan en el navegador de quien las mira (§5).
- **¿Quién tiene acceso a los datos, y cómo se protegen?** Datos de veinte sedes,
  con la ley de protección de datos personales de por medio.
- **¿Qué pasa si la persona que conoce el sistema no está?** La respuesta
  honesta era *"lo conoce Felipe"*.

Cuadre firmó con un **plan de remediación** como anexo del contrato, con fechas
y en tres etapas: primero, **una red de pruebas** sobre lo que hay, antes de
tocar nada; segundo, **entregar lo que la cadena pidió** —seguir los casos desde
el celular, informes de cumplimiento por sede, el historial de cada caso al
alcance de quien lo abrió—; y tercero, **migrar a Vue 3**, con la fecha más
lejana. Cada pedido de la segunda etapa calza con una de las ramas de los
sábados, y Felipe fue el primero en notarlo: las había empezado las tres sin
saber para quién. El presupuesto alcanza para rescatar **una**.

Y por primera vez la empresa contrata desarrolladores **con un proceso de
selección**, para estabilizar lo que hay antes de pensar en migrar. Felipe
sigue en Cuadre, medio tiempo en el taller, y fue el primero en decirlo en voz
alta: el código necesita a alguien que no sea él.

---

## 4. 👥 La gente

| Personaje | Rol | Cómo habla | Qué quiere |
|---|---|---|---|
| **Andrés Felipe Ríos** (`AFR`, usuario `admin`) | Fundador. Técnico en electrónica del SENA, autodidacta | Entusiasta, con metáforas de arcade; *"hágale, que eso sale"* | Que la Tiquetera sea suya, que sea divertida, y que alguien le ayude a cuidarla |
| **Jhon Fredy "el Mono" Álvarez** | Socio. Vecino, tecnólogo en sistemas; también programa | Callado, práctico | Que el servidor no se caiga un sábado |
| **Diana Patricia Ríos** (`dprios`) | Prima de Felipe y socia. Técnica contable | Precisa, con números; *"¿y eso cuánto vale?"* | Que la DIAN no le cierre ningún cliente, y que cada módulo se cobre |
| **Valentina Ospina** | Ingeniera de sistemas, llegó por recomendación en 2020; se fue en 2022 | Directa; la que dice que no | Orden: Vuex en todo, una base limpia, pruebas que nunca llegaron |
| **Sebastián Zapata** | Amigo del barrio, diseñador y gamer; trabajos por encargo | Relajado; *"eso está muy bacano"* | Que se vea bien. Hizo el pixel art de la tabla de puntajes |
| **Los chicos por horas** | Estudiantes de sistemas que llegaron por la cartelera desde 2021 | Cada uno con su estilo | Experiencia, horas y una línea en la hoja de vida |
| **Laura Marcela Cano** (`LMC`, usuario `lmcano`) | Agente de soporte desde 2020 | Paciente con los dueños de negocio | Cerrar la cola antes de las seis |
| **Laura Milena Correa** (`LMC`, usuario `lmcorrea`) | Agente de soporte desde 2022 | — | Que dejen de llegarle los tickets de la otra Laura |
| **Los que se fueron** (`jpmesa`, `cvelez`, `mrestrepo`) | Un agente y dos personas de ventas de 2019–2020; sus usuarios se borraron, sus tickets no (§6) | — | — |
| **Don Arturo Ríos** | Papá de Felipe; lleva las cuentas del taller | *"Oiga, mijo…"*; pregunta antes de opinar | Que el taller siga dando, y que el muchacho no se quiebre con el software |
| **Camilo Ríos** | Hermano menor; arma los arcades y publica en Mercado Libre | — | Que Felipe vuelva a ayudar en diciembre, que es cuando más piden |

Que se repitan las iniciales de las dos Lauras no es un descuido de esta
ficha. Es un incidente (§5).

---

## 5. 🕹️ La rareza de la casa: la tabla de puntajes

Todo sistema heredado tiene una pieza que no existiría si lo hubiera diseñado
otra persona. La de la Tiquetera viene directo del taller.

Felipe sostenía que *"un arcade sin tabla de puntajes no lo juega nadie"*, y le
puso una a la mesa de soporte. Cada agente aparece con **tres iniciales**, como
en las máquinas que él mismo armaba, y suma puntos por cada ticket resuelto;
los de prioridad alta valen más. En 2020, con todos en la casa, era una pestaña
que cada quien tenía abierta; cuando volvieron a la oficina en 2021 pasó a un
monitor en la pared, con el pixel art de Sebastián y música de ocho bits que
alguien silenció en la segunda semana. Valentina se opuso y perdió: fue una de
las ideas que Felipe no soltó.

Hay que decir lo que la tabla hizo bien, porque lo hizo. En los meses de
trabajo remoto era lo único que hacía sentir al equipo como un equipo. Y dejó
tres decisiones que vas a reconocer en el código:

- **Las iniciales son identificador.** En muchos sitios el agente se guarda y se
  compara por sus tres letras, no por su usuario. Funcionó dos años, hasta que
  en 2022 entró la segunda Laura con las mismas iniciales y empezaron a cruzarse
  los tickets y los puntos.
- **El puntaje se calcula en el navegador.** Nace del mismo conteo por agente de
  las métricas, hecho en el cliente sobre la lista que cada quien tiene
  cargada. Dos personas mirando la tabla al mismo tiempo pueden ver puntajes
  distintos, y ninguna de las dos está viendo la verdad.
- **Se premia resolver, no que lo resuelto se quede resuelto.** Cerrar rápido
  paga: el ticket suma en la tabla de esa semana. Si el comercio lo reabre, sale
  de la cuenta sin dejar rastro, pero la semana ya se celebró. Durante meses las
  métricas mostraron productividad récord mientras subía la tasa de tickets
  reabiertos. Nadie hizo trampa: la tabla premiaba eso, y la gente jugó el juego
  que le pusieron.

> 🧠 **Lo que te llevas de esta pieza.** Una métrica que se convierte en
> marcador deja de medir y empieza a mandar. Antes de confiar en un número de la
> Tiquetera, pregunta quién lo calcula, dónde, y qué conducta premia.

---

## 6. 🔎 Quién dejó qué (y qué sabemos de por qué)

En un sistema real esto se reconstruye leyendo `git blame` y preguntándole al
fundador. Acá te lo damos hecho:

- **Componentes grandes con Options API, que piden sus propios datos.** Felipe,
  2018–2020, como enseñaba su curso y como hacía `pedidos.php`. Funcionan; el
  costo aparece cuando dos pantallas necesitan el mismo dato.
- **Bootstrap 4 y jQuery conviviendo con Vue.** Venían en los dedos desde la web
  del taller. jQuery sobrevive en un par de rincones donde *"era más rápido"*.
- **Estilos distintos según el archivo.** Desde 2021 cada chico por horas
  escribió como sabía, sin guía ni revisión de código. No hay un estilo
  equivocado: hay cinco.
- **El `reporter` lo pone el navegador, y el evento del socket lo emite el
  cliente.** En 2020 el backend lo escribían Felipe y el Mono a las once de la
  noche, y era más rápido resolverlo en el frontend. El Curso 02 lo paga.
- **Tomar un ticket no tiene candado.** Dos agentes pueden tomar el mismo al
  mismo tiempo, y los dos creen que es suyo. En los tres meses no hubo tiempo de
  pensarlo; con dos agentes casi nunca pasaba.
- **El token vive en `localStorage`.** Lo que enseñaba el tutorial. Está mal por
  seguridad y está documentado como tal en la Fase 2.
- **Tickets que apuntan a usuarios que no existen.** Cuando alguien se iba de
  Cuadre, Felipe borraba su usuario para que no quedara activo, y sus tickets
  quedaron con un `assignee` o un `reporter` que ya no está en ninguna parte
  (`jpmesa`, `cvelez`, `mrestrepo`). Nadie se dio cuenta, porque nada lo
  verificaba.
- **Dos bases, `soporte_v1` y `tiquetera`.** Una de Felipe y otra de Valentina,
  sin migración entre ellas. El Curso 02 hace la autopsia de la primera.
- **El código en inglés y la interfaz en español.** Felipe empezó la Tiquetera
  desde cero en 2018 decidido a seguir las buenas prácticas de los cursos, y la
  primera era escribir el código en inglés; la interfaz es para comercios de
  Itagüí. Valentina y los chicos respetaron la convención casi siempre.

---

## 7. 💰 Las cifras

Todas son ficticias y están acotadas a lo que el laboratorio de los dos cursos
sostiene.

| Cifra | Valor | Fuente o supuesto |
|---|---|---|
| Comercios con Cuadre | ~80 a finales de 2019 · ~250 en 2022 · ~400 en 2026 | Ficticia |
| Mensualidad de Cuadre | ~$49.000; la factura electrónica, ~$25.000 más | Ficticia |
| Tickets por día | ~15 normales · ~40 en los picos de la DIAN | Ficticia |
| Agentes de soporte | 2 en 2020 · 5 en 2022 | Ficticia |
| Tickets acumulados hasta 2026 | ~30.000 | Ficticia; la semilla del Curso 02 los multiplica para que las mediciones se vean |
| Arcades vendidos por Mercado Libre | 8 a 12 al mes | Ficticia |
| Dólar en marzo de 2020 | Por encima de $4.000 (récord de $4.153,91 el 20 de marzo) | Verificada el 2026-10-06 con la serie de la TRM |

---

## 8. 📏 Las reglas de negocio

- Un ticket recorre `open → in_progress → resolved → closed`, y puede volver a
  `open` desde `resolved` o `closed`.
- Un ticket en curso tiene **un solo** agente asignado. (La regla existe; el
  candado que la sostiene, no: §6.)
- Todo ticket de un comercio debe llevar su **NIT**, y los de facturación,
  además, su **resolución de numeración**. (La regla existe; el campo, no: van
  al comienzo del título por convención, `[900123456] …`.)
- Puntaje por ticket resuelto o cerrado: baja 100, media 200, alta 300. Un
  ticket reabierto deja de contar, sin dejar rastro.

---

## 9. 🗣️ Cómo hablan

La narración y las instrucciones van siempre en tuteo neutro. Las voces de
Itagüí aparecen solo en las citas, y con moderación: una frase por escena, con
**ustedeo**, no con voseo (*"hágale"*, *"¿usted ya miró la resolución?"*,
*"eso está muy bacano"*, *"de una"*). Las frases de Felipe tiran a la metáfora
de arcade; las de Diana Patricia, a la cuenta.

---

## 10. 🕳️ Lo que el sistema NO tiene

Tan importante como lo que hay. No hay pruebas hasta que las escribas tú
(Fase 11 del Curso 01, Fase 13 del Curso 02). No hay TypeScript. No hay CI. No
hay revisión de código. No hay roles finos: un agente puede hacer casi todo. No
hay refresh token. No hay paginación de servidor, hasta que la construyas en el
Curso 02. No hay migración de `soporte_v1` a nada, hasta que la autopsia del
Curso 02 la rediseñe y la migre. Y no hay backend en el Curso 01: lo que levantas es
un mock que imita al de verdad, y el de verdad lo construyes en el Curso 02.

Esa lista es, palabra por palabra, el backlog técnico eterno de miles de
sistemas reales. Que te resulte familiar es el punto.

---

## 11. 🎭 Tu rol en esta ficción

Eres de los primeros desarrolladores que Cuadre contrata con un proceso de
verdad, y llegas con el plan de remediación de PizzaPaisa encima de la mesa. Eres senior en backend y esta es tu primera vez sosteniendo un frontend
ajeno. No llegas solo: hay otros desarrolladores entrando contigo, y entre todos
van a heredar lo mismo.

Nadie te va a hacer onboarding completo, porque no hay quien. Valentina se fue,
el chico de la rama de Vuetify también, y Felipe responde con gusto y con poca
memoria: se acuerda perfecto de por qué eligió Vue y no se acuerda de dónde
quedó el script que crea los índices.

Tienes el código, esta ficha y los tickets del `cuaderno-incidentes.md`.

> **La señal de que esta ficha hizo su trabajo:** cuando abras un archivo raro y
> tu primera reacción no sea "qué mal está esto", sino "¿esto lo escribió Felipe
> en 2018, Valentina en 2020 o uno de los chicos en 2022, y qué curso o qué
> urgencia lo explica?".
