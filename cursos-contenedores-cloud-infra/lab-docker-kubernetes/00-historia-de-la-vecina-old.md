# 🏘️ Droguerías La Vecina · Coodrosan, cooperativa de droguistas de Santander

> La empresa del curso **Laboratorio de contenedores y Kubernetes local**. Ficticia, y la única:
> todo lo narrativo del curso sale de aquí —las autopsias de la Fase 00, las escenas que abren
> cada fase, las voces que encargan los incidentes, las reglas de negocio de la venta y de sus
> compensaciones, y la recomendación que cierra el curso—.
>
> **Estado:** **la empresa del curso**, decisión cerrada el 30/09/2026 (D18). Se evaluaron una
> cadena de supermercados en el sur del Perú y un mayorista que surte tiendas de barrio en la Costa
> colombiana. Ganó La Vecina por tres razones: el **préstamo entre droguerías** es una transacción
> distribuida con consecuencia real —un paciente que se queda sin su medicamento esa noche—, la
> empresa tiene **una razón de negocio con número** para salir de su arquitectura actual, y su
> estructura corporativa explica sin forzar por qué el sistema nuevo tiene cuatro stacks con
> cuatro dueños.
>
> **Sobre el nombre.** La cooperativa tiene dos. La razón social, la que va en los contratos y en
> las actas, es **Coodrosan** —Cooperativa de Droguistas de Santander—, puesta en 1998 por la
> contadora con la creatividad que se le pide a una contadora. La marca, la que está en las
> fachadas, salió de una frase: cuando a una regente le faltaba algo, la respuesta en toda la red
> era *"pregúntele a la vecina"*. En 2002, cuando la asamblea formalizó el préstamo y el domicilio,
> Don Aurelio propuso que la frase fuera el nombre, y que debajo fuera el lema: **"Droguerías La
> Vecina. Siempre llega."** Ganó por trece votos contra uno. Doña Graciela votó en contra, y
> todavía hoy dice que fue por el nombre y no por la idea. Desde que la red llegó a Bogotá, la
> sigla de la razón social provoca la misma pregunta en cada reunión con un proveedor nuevo:
> *"¿y por qué siguen siendo de Santander?"*. La respuesta de Doña Graciela es siempre la misma:
> *"Porque de allá somos."*
>
> 📝 **El nombre es ficticio.** Cualquier droguería real que se llame parecido no tiene relación
> con esta historia.
>
> ⚠️ **Advertencia de alcance, y es normativa.** Este curso **no enseña regulación farmacéutica**
> ni pretende ser exacto en ella. La fórmula médica, los lotes y vencimientos, la cadena de frío,
> los medicamentos de control especial y la dispensación a las EPS **no existen en el modelo** y
> no se modelan. El precio regulado está simplificado hasta el punto exacto en que le sirve al
> servicio de precios. Si algo de este documento choca con la realidad del oficio, gana la
> plataforma: es una empresa de mentira construida para enseñar infraestructura de verdad.
>
> 📝 **Sobre los proveedores reales.** Oracle, Sun, Microsoft, Siebel, WebLogic y GlassFish
> aparecen con su nombre porque la historia de la empresa es la historia de sus decisiones de
> compra, y esas decisiones son públicas en el sector. Las cifras de licencias que se citan son
> **precios de lista** consultados en septiembre de 2026, y se vuelven a verificar con fecha antes
> de que una fase las cite; en la vida real todo eso se negocia, y ningún proveedor de esta
> historia es el villano.

---

## 1. 🛠️ Cómo llegó a existir

### 1.1 🤝 1998: la cooperativa, para comprar mejor

La cooperativa no nació por una idea brillante sino por una cuenta. A finales de los noventa, las
cadenas grandes empezaron a llegar al área metropolitana de Bucaramanga con precios que una
droguería de barrio no podía igualar, porque les compraban a los laboratorios y a los
distribuidores por volumen. Las droguerías independientes de Bucaramanga, Floridablanca, Girón y
Piedecuesta hicieron lo que en Santander se hace cuando el problema es de plata: se reunieron,
discutieron tres meses y montaron una cooperativa.

**Coodrosan**, la Cooperativa de Droguistas de Santander, se constituyó en 1998 con catorce
droguerías socias y **un solo objetivo**: **negociar juntas con los proveedores** y repartir el
descuento. Para eso, cada socia mandaba cada
quince días a la oficina de la cooperativa una lista de lo que necesitaba y de lo que tenía, y la
contadora consolidaba el pedido. Nada más. Nadie hablaba todavía de prestarse nada.

En las reuniones de compras se conocieron los que después iban a ser los dos fundadores que
importan. **Doña Graciela Serrano**, la regente de la droguería del parque de Girón, que llevaba
las cuentas al peso y guardaba siempre dos de cada cosa. Y **Don Aurelio Prada**, de una droguería
de tres metros de frente en Floridablanca, que cerraba tarde y conocía de memoria lo que tenía
cada colega. Los dos quedaron en el consejo de administración, y con ellos quedó instalada la
discusión que ordena la empresa hasta hoy: ella sostiene que **lo que no está en el anaquel no se
vende**; él, que **el cliente no tiene por qué saber en qué anaquel estaba su medicamento**.

### 1.2 🚗 La noche del salbutamol

El préstamo apareció sin que nadie lo buscara, como aparecen muchas buenas ideas de negocio.

Un martes de 1999, a las diez y media de la noche, entró a la droguería de Don Aurelio una señora
con un niño con una crisis de asma y una fórmula que pedía un inhalador que él no tenía. Don
Aurelio sí sabía quién lo tenía, porque había visto la lista de la última compra conjunta: la
droguería de Girón. Llamó. Doña Graciela contestó con la voz de quien ya se había acostado, y dijo
lo que después iba a repetir durante treinta años:

> *"Yo le presto, Aurelio, pero me lo anota y me lo devuelve. Lo que se presta se devuelve.
> ¿Me oyó?"*

Don Aurelio no podía cerrar la droguería con la señora adentro, así que le prestó las llaves del
carro a su sobrino, **Wilson**, que tenía diecinueve años y licencia de hacía tres meses. Fue a
Girón y volvió en menos de una hora. Doña Graciela anotó el préstamo en un cuaderno de tapa dura,
verde, que tenía para las cuentas de la droguería. **Fue la primera línea del cuaderno de
préstamos.**

### 1.3 📒 El cuaderno, la moto y el Excel

Lo que pasó después no lo planeó nadie. Las socias se conocían de las reuniones de compras y
sabían más o menos qué tenía cada una por las listas de la contadora, así que empezaron a llamarse
entre ellas: un antibiótico un domingo, una caja de suero un festivo, el jarabe que el
distribuidor dejó de despachar tres semanas. La regla fue la de Doña Graciela: **se anota, y se
devuelve**. Cada droguería llevaba su propio cuaderno.

El transporte se fue armando igual, sin plan. Wilson se compró una moto usada en 2000 y empezó a
hacer los préstamos lejanos por encargo. Para 2002 la cooperativa le pagaba a él y a otros cuatro
muchachos: **bicicletas para lo cercano, dentro del mismo barrio, y motos para ir más lejos**, entre
municipios del área metropolitana. Y una vez que había motos yendo de una droguería a otra, la
pregunta de Don Aurelio fue la obvia: *"¿y por qué no se lo llevamos a la casa al cliente?"*. Así
apareció el domicilio, colgado del préstamo.

En 2002 la asamblea formalizó las dos cosas como servicios de la cooperativa. La frase que todas
usaban cuando faltaba algo —*"pregúntele a la vecina"*— pasó a ser la marca, y debajo quedó el lema
que hoy está en cada fachada:

> **"Droguerías La Vecina. Siempre llega."**

La tecnificación de esos años fue la mínima, y a lo más llegó a **un Excel que se intercambiaba
por correo**. Desde 2003, cada droguería que prestaba algo agregaba una fila al archivo y lo
reenviaba **a todas las demás**, casi siempre a una cuenta de Hotmail que la regente revisaba
cuando el mostrador la dejaba. La regla, que nadie escribió pero todas cumplían, era sencilla:
**el último Excel de la bandeja de entrada es el bueno**. La regla funcionaba mientras los correos
llegaran en orden y nadie trabajara sobre una copia vieja. En la práctica circulaban tres o cuatro
versiones a la vez, con nombres como `prestamos_FINAL_v2_graciela.xls`, y la versión "buena" de
una droguería no era la misma que la de la vecina. Las listas de precios viajaban en fotocopia. Cada
droguería tenía, en el mejor de los casos, un computador con la contabilidad. Y funcionaba, por
dos razones que nadie escribió nunca: **todas se conocían**, y **eran pocas**. Una regente podía
tener en la cabeza qué le debía a quién y qué le debían a ella.

> 🧠 **Para quien lee este documento antes de escribir una fase:** la discusión de los fundadores
> es, dicha por dos droguistas de Santander, la de consistencia contra disponibilidad. El curso
> vuelve a ella en la Parte IV, y el veredicto final la responde con números.

### 1.4 🏔️ 2006: Tunja, los pueblos, y el año en que el cuaderno y el Excel no alcanzaron

El primer salto fuera de Santander fue a **Tunja**, por una socia boyacense que se había casado
con un bumangués y que quería abrir en su tierra. Tunja era un mercado más grande que cualquier
municipio del área metropolitana, con universidad, con hospitales y con frío, y la droguería de
la plaza empezó a recibir pedidos de domicilio **de los pueblos de alrededor**: Samacá,
Ventaquemada, Motavita, Oicatá. El domiciliario boyacense, que llamaba a todo el mundo
*sumercé*, salía en moto con la ruana encima y volvía con tres encargos nuevos.

Para entonces la cooperativa ya tenía treinta y cinco droguerías, entre socias fundadoras y nuevas.
Con Tunja, los pueblos y el área metropolitana de Bucaramanga funcionando al mismo tiempo, el
cuaderno y el Excel se rompieron en el sitio exacto donde se sostenían: **ya no todas se conocían, y
ya no eran pocas**. En ocho meses de 2006 pasaron tres cosas que el consejo todavía cuenta en orden:

- Una caja de antibiótico **se prestó dos veces**, a dos droguerías distintas, porque las dos
  llamaron a la de Piedecuesta con diez minutos de diferencia y el auxiliar que contestó la
  segunda llamada no vio el cuaderno.
- Un préstamo de Tunja a Bucaramanga **no se devolvió nunca**, y nadie supo si la culpa era del
  bus intermunicipal, de la droguería que lo recibió o del Excel, que decía "devuelto" en una de
  las versiones que circulaban por correo y "pendiente" en las otras dos.
- Y el mismo medicamento **costaba distinto en cada droguería de la cooperativa**, porque cada
  una ponía el precio que le parecía y las listas viajaban en fotocopia.

Lo que hizo la directiva después es lo que distingue a La Vecina de cualquier otra cooperativa de
su tamaño. No buscó a alguien que "les hiciera un programita". **Contrató a una firma de
consultoría organizacional de Bogotá**, de las que entran a una empresa que creció más rápido que su
estructura, miran cómo se trabaja y salen con un organigrama. Doña Graciela lo defendió en la
asamblea con la claridad que la caracteriza:

> *"Nosotros sabemos vender medicamentos. Para lo otro hay que traer a alguien que sepa, y pagarle
> lo que vale. Lo barato sale caro, y lo que se improvisa se cobra en préstamos que nadie
> devuelve."*

Los consultores estuvieron cuatro meses entre droguerías, bodegas y la oficina de la contadora, y
entregaron un diagnóstico que el consejo todavía cita: *la cooperativa opera como treinta y cinco
droguerías que se hacen favores, no como una empresa*. Su recomendación central fue darle
estructura, y la estructura fue un organigrama con **vicepresidencias**:

- **Compras y adquisiciones**, para la negociación conjunta con laboratorios y distribuidores, que
  era la razón de ser de la cooperativa.
- **Operaciones**, para las droguerías, las regentes y el estándar del mostrador.
- **Logística**, para los centros de distribución, los traslados y los domiciliarios. Wilson
  terminó ahí, primero como jefe de rutas y después como coordinador de domicilios de toda la red.
- **Financiera**, para que la contadora dejara de ser la única persona que entendía la plata.
- **Comercial**, para la marca, las campañas y, años después, el club de afiliados.
- **Sistemas**, con un encargo que el informe escribió en una línea: **automatizar el préstamo,
  unificar los precios, y dejar de depender del cuaderno y del Excel**.

La directiva aceptó el organigrama completo y salió a buscar a las seis personas. La de sistemas
fue la última en llegar.

### 1.5 📐 Germán y la casa con contrato

**Germán Camargo** era tunjano, ingeniero de sistemas, y venía de ocho años en el área de
tecnología de un banco en Bogotá. Llegó en septiembre de 2006, el último de los seis
vicepresidentes que pidió la consultora, con tres convicciones que había aprendido en el banco y
que iban a definir los siguientes veinte años de la cooperativa.

La primera: **una cooperativa de droguistas no se puede dar el lujo de depender de algo sin un
proveedor que responda**. Si el sistema se cae un sábado, alguien con contrato tiene que
contestar el teléfono.

La segunda: **el diseño va antes que el código**. Germán no escribió el sistema, pero estuvo
detrás de cada pieza. Hizo los diseños técnicos, dibujó los diagramas de clases y de secuencia
del módulo de préstamos, se sentó en cada reunión de arquitectura con el equipo que contrató, y
eligió cada proveedor con una hoja de cálculo de criterios que todavía existe. El documento de
diseño del módulo de préstamos, de marzo de 2007, sigue en una carpeta compartida. Es impecable
para su época.

La tercera: **comprar a pocos proveedores es comprar un solo número de teléfono**. Entre 2006 y
2008 la cooperativa se tecnificó sobre dos casas:

- **Oracle Database** para los datos, porque era lo que se usaba en el banco y lo que cualquier
  auditor reconocía.
- **El servidor de aplicaciones Java EE comercial de Sun**, construido sobre GlassFish, para el
  sistema central: era el servidor de referencia del estándar, venía con soporte de Sun y costaba
  mucho menos que las alternativas de entonces.
- **Microsoft** para todo lo que toca a la gente: el directorio de usuarios, el correo, Office,
  las estaciones de trabajo, el software de las cajas y los servidores de las bodegas.

El sistema central se llamó **SIGA**, *Sistema Integrado de Gestión y Abastecimiento*: un nombre
que salió del equipo de Germán en la primera semana, con la creatividad habitual de un área de
sistemas, y que nadie volvió a discutir. En toda la red se le dice **el Siga**, y la mesa de ayuda
tiene un chiste que ya nadie encuentra gracioso: *"¿Se cayó el Siga?" "Siga intentando."* Su
primer módulo fue exactamente el que había obligado a contratar a Germán: **el préstamo entre
droguerías**, que salió del cuaderno y del Excel y entró a la base de datos en 2007. El segundo fue
la lista de precios única. El cuaderno verde de Doña Graciela quedó en un cajón de la droguería de
Girón, y ella nunca lo botó.

### 1.6 🔀 2010: de Sun a Oracle sin pedirlo

En 2010 **Oracle terminó de comprar Sun**, y la cooperativa se despertó un día con su servidor de
aplicaciones convertido en **Oracle GlassFish Server**. Nadie lo decidió en Bucaramanga: se
decidió en otra parte, y el matrimonio con Oracle se volvió doble por una adquisición ajena. A
Germán no le pareció mal. Un solo proveedor para la base y para el servidor era, en su hoja de
cálculo, una ventaja.

En noviembre de 2013, Oracle anunció que **no habría versión comercial de GlassFish 4** y les
recomendó a sus clientes comerciales planear el paso a **WebLogic**. Entre 2014 y 2015 el equipo
migró el Siga. Fue un proyecto bien hecho, a tiempo y sin caídas, y es el que la jefa de
arquitectura cita cuando alguien dice que en La Vecina no saben migrar. De esa migración quedó
también una herencia que nadie revisa: los parámetros de arranque de la JVM, con un `-Xmx` fijo
que se copia de servidor en servidor desde 2015 y que nadie recuerda quién eligió. **Con WebLogic
empezó la factura por procesador**, que en 2015 era razonable y que creció con cada servidor que la
expansión hizo necesario.

En 2012 llegó **Siebel**, para el programa de afiliados —el **Club Vecinos**, con puntos,
descuentos de cumpleaños y campañas por temporada— y para las campañas comerciales. Para entonces
Siebel ya era de Oracle, que lo había comprado en 2006, así que no fue un proveedor nuevo sino una
pieza más del mismo matrimonio. Siebel corre sobre la base Oracle, y eso, que en 2012 era un
detalle, en 2026 es una de las razones por las que Oracle no se va a ir del todo.

### 1.7 🗺️ Boyacá entera, y después la capital

Durante la década de 2010 la cooperativa llegó a **Duitama, Sogamoso, Paipa y Chiquinquirá**. El
préstamo entre droguerías se volvió el servicio insignia: el Siga buscaba qué droguería
cercana tenía el producto y generaba un traslado, que salía en moto en el área metropolitana y en
el bus intermunicipal entre ciudades. Cada quince minutos, un proceso por lotes del Siga
cruzaba las solicitudes con las existencias. Funcionaba. Funcionaba tan bien que nadie lo tocaba.

En 2018 la cooperativa dio **el salto a Cundinamarca y Bogotá**: Zipaquirá y Chía primero, y
después cuarenta droguerías en la capital en tres años. Los primeros dos años fueron de
crecimiento tranquilo, con el mismo modelo de Santander. Lo que cambió todo fue la pandemia, con el
domicilio multiplicado por cinco en dos meses: **todo lo que en Bogotá ya se venía notando —la
logística, los préstamos, la distancia hasta el Siga— se volvió urgente de un día para otro.**

En esos años entraron dos piezas que no estaban en el Siga: una justo antes de la pandemia, y otra
en pleno confinamiento:

- **El portal**, que entró como una prueba de concepto. En 2019 el domicilio fuera de la red propia
  se hacía por convenio con las **plataformas de domicilios** de las apps, que se quedaban con una
  comisión por pedido, y la vicepresidencia comercial quería probar si valía la pena una tienda
  propia para depender menos de ellas. En el comité era un piloto más, *"una página para que la
  gente pida por internet"*, y en el roadmap quedó con el nombre que le pone un área de sistemas a
  un piloto: **PPVW**, *Portal de Pedidos y Ventas Web*. Nadie lo volvió a decir completo; desde el
  primer día fue **"el portal"**. Se puso en el roadmap con la medida de siempre: **un trimestre**.
  La estimación salió de Germán y de Luz Marina en una reunión de media hora, y fue, como casi todas
  las estimaciones de un piloto, optimista: con el Núcleo ocupado en el Siga, a nadie se le ocurrió
  que el trimestre fuera poco. **El chicharrón le quedó, otra vez, a Andrés Suárez**, el
  arquitecto de software que tres años antes había sacado adelante Contingencia (§1.8), con ese
  plazo y casi nada de presupuesto. Andrés resolvió con lo que tenía a mano: **los
  aprendices del SENA** que la cooperativa está obligada por ley a tener, y que cuestan bastante
  menos que un desarrollador, más un par de **pasantes de ingeniería de sistemas**. Y propuso **PHP
  con Laravel** por una razón que no tenía nada de técnica: era lo que los muchachos sabían, se
  montaba en cualquier servidor, y había que tener algo andando **antes de que cerrara el
  trimestre**, que coincidía con el fin del semestre de los muchachos. Como no hubo plata para
  meterla al datacenter, arrancó en **un servidor virtual alquilado afuera, pagado con la tarjeta
  corporativa de la vicepresidencia comercial**, y ahí sigue. **Entró a producción en diciembre de
  2019**, a tiempo, como piloto. Nadie se imaginaba lo que iba a pasar tres meses después: con la
  pandemia, las plataformas de domicilios se saturaron, el portal pasó a ser el canal principal de
  Bogotá, y se volvió crítico en dos semanas sin que nadie lo decidiera. La cooperativa contrató a
  una de las pasantes, **Daniela Ortiz**, porque era la única que sabía cómo funcionaba. Hoy Daniela
  dirige un equipo de tres personas que lo mantiene, y lo defiende con razón.
- **La logística de última milla**, que la cooperativa resolvió **comprando una startup** en
  plena pandemia, porque no había tiempo de hacer otro sistema como el portal: **Braquistócrona**,
  un sistema de despacho de motos en **Node**, nacido en Bucaramanga. Sistemas le compró una
  licencia entre abril y mayo de 2020, en pleno confinamiento, para el área metropolitana; en el
  tercer trimestre la cooperativa compró la empresa entera y la llevó a Bogotá (§1.9).

En Bogotá, el préstamo entre vecinas dejó de funcionar como en Girón. **En Bogotá nadie conoce a
nadie.** El lote de quince minutos se volvió una eternidad para un domicilio prometido en una
hora, y las regentes empezaron a resolver por WhatsApp lo que el Siga no alcanzaba. En
noviembre de 2021 pasó lo que el coordinador de domicilios llama *"lo de las dos motos"*: una
regente de Chapinero escribió en el grupo *"¿quién tiene?"*, contestaron dos droguerías, y **al
mismo cliente le llegaron dos motos con el mismo inhalador**. El cliente pagó uno. El otro volvió
en la moto, bajo la lluvia, y nadie supo nunca a qué droguería se le descontó.

### 1.8 🏢 El Siga en dos ciudades: escalar el monolito antes de partirlo

La Vecina no saltó del monolito a los microservicios. Antes recorrió, paso a paso, el camino que
recorre casi toda empresa que crece sobre un sistema central: **hacerlo más grande, después
duplicarlo, y después partirlo**. Cada paso fue razonable, cada uno resolvió el problema de su año,
y casi todos sumaron licencias.

**2012, más máquinas.** El Siga pasó de un servidor a un **cluster de varios nodos** en el
datacenter de Bucaramanga, detrás de un balanceador: sobre GlassFish entonces, y sobre WebLogic
desde la migración de 2015. Es lo que había que hacer, y es la primera vez que la factura de
licencias creció sin que creciera el negocio: en un cluster se licencia cada nodo.

**2016, la copia que espera.** Después de un apagón de seis horas en el datacenter de Bucaramanga,
Germán montó un **segundo datacenter en Bogotá** —lejos del primero, con mejor conectividad y con
los proveedores cerca— **con una réplica de la base en espera**, lista para tomar el control si el
principal se caía. Funcionó las dos veces que hizo falta. El resto del
tiempo era una copia completa del Siga que no atendía a nadie y que pagaba licencias como si
atendiera.

**2016, también: Contingencia.** El apagón dejó otra lección, y la pagaron las droguerías más que el
datacenter: durante seis horas, nadie pudo vender con el sistema. Y en los pueblos de Boyacá eso no
pasaba una vez cada diez años sino cada vez que se caía el internet del pueblo. La directiva pidió
que las sedes críticas —los dos centros de distribución, las droguerías más grandes y las de los
pueblos de Boyacá, unos sesenta sitios— **pudieran seguir operando aunque el Siga central no
contestara**.

El encargo le cayó a **Andrés Suárez**, arquitecto de software del equipo de Luz Marina. Andrés
reporta a arquitectura en lo técnico, a Germán en las decisiones de plataforma y a compras en todo
lo que tenga licencia, y por eso le tocan, casi siempre, los encargos que cruzan las tres cosas.
Diseñó un Siga reducido que corre en un solo sitio: si el central no contesta, se enciende, la
droguería sigue vendiendo en local, guarda cada transacción en un log, y cuando el central vuelve,
le envía el log para sincronizar. Oficialmente es **SIGA Contingencia**; Andrés, que es aficionado
a la mitología, lo bautizó **Asclepio**, por el dios de la medicina y de las urgencias. En la red
nadie usa ninguno de los dos nombres: es **Contingencia**, sin artículo, como se dice en una
droguería cuando se cae el sistema: *"¡prendan Contingencia!"*.

El plan original era el obvio: la misma pila del Siga en cada sitio, con su base Oracle. Y ahí
apareció el primer obstáculo, que no fue técnico. **Licenciar Oracle en sesenta computadores no se
pudo definir a tiempo.** La propuesta pasó por el comité de inversiones, que pidió una segunda
cotización; la segunda cotización volvió con otra métrica de licencias, y compras pidió concepto al
área legal; el área legal pidió una reunión con el proveedor, y la reunión se agendó para dentro de
seis semanas. Mientras tanto, el plazo de la directiva seguía corriendo y en Boyacá empezaban las
lluvias.

Andrés hizo lo que se hace con un chicharrón: lo resolvió con lo que tenía a mano. Montó **una
prueba de concepto de dos semanas**, sin presupuesto, en la que pasó a **PostgreSQL** las tablas
principales del Siga. Como el Siga usa JPA con **Hibernate**, para la mayor parte del código bastó
con cambiar el driver y el dialecto. Contingencia, además, **no necesita la lógica pesada**: no
calcula precios, no factura ni liquida; solo vende, descuenta y registra préstamos. Hace CRUD, y la
lógica en PL/SQL se quedó en el central. Hubo que portar a mano un puñado de procedimientos, y
pelear con las diferencias de siempre: en Oracle el texto vacío es `NULL` y en Postgres no, las
secuencias se manejan distinto, `NVL` y `ROWNUM` no existen, y un par de consultas nativas escritas
a mano que Hibernate no tradujo. Y como pagar WebLogic por sitio era impensable, **Contingencia se
quedó en GlassFish**, en su edición abierta, el servidor donde el Siga había nacido.

En los centros de distribución y en las droguerías grandes, Contingencia vive en un servidor
pequeño en el cuarto de atrás. En los pueblos de Boyacá es otra cosa, y es la imagen que todo el
mundo tiene de ella: **un computador de escritorio debajo del mostrador, conectado a una planta
eléctrica pequeña** que arranca sola cuando se va la luz. En un pueblo, el internet y la luz suelen
irse juntos, y Contingencia se diseñó para eso: mientras la planta tenga gasolina, la droguería
vende. La planta la prueba la regente cada lunes, y el ruido es tan conocido que en algunos pueblos
los clientes saben que se fue la luz por el motor de la droguería antes que por el bombillo.

La prueba funcionó, salió a los sesenta sitios antes de que el comité terminara de evaluar la
propuesta de licencias, y **nadie volvió a abrir la discusión**. Así entró el software libre a La
Vecina: no por una decisión de arquitectura, sino porque un comité se demoró más que las lluvias de
Boyacá. Diez años después, **Postgres lleva una década en producción en sesenta sitios**, sin que
nadie fuera de sistemas lo sepa.

Contingencia tiene sus mañas, y son las de cualquier sistema que opera desconectado. La
sincronización del log al volver es *"el último Excel de la bandeja es el bueno"*, ahora con
transacciones: una venta que se reenvía dos veces, un préstamo hecho en local que choca con otro
hecho en el central. Una parte de los huérfanos que Luz Marina busca cada lunes viene de ahí. Y
tiene una regla de encendido que en 2016 parecía obvia: **se prende cuando el Siga no contesta**.

**2021, el Siga activo en Bogotá.** Con la pandemia, Bogotá y Cundinamarca pasaron en tres años de
ser la región nueva a vender más que Santander, y las cajas de la capital sufrían la distancia: cada
venta viajaba a Bucaramanga y volvía. El equipo de Luz Marina puso **un segundo Siga activo en el
datacenter de Bogotá** y **partió la base por región**, con la técnica de *sharding* que Oracle
soporta: el inventario de Santander y Boyacá en Bucaramanga, el de Cundinamarca y Bogotá en Bogotá.
El catálogo, los precios y el préstamo entre regiones quedaron en el **nodo central** de
Bucaramanga, y una herramienta de replicación los copiaba al otro lado.

Las cajas de Bogotá volaron. Y aparecieron, uno detrás de otro, los problemas que el curso enseña
en su segunda mitad, solo que con otro nombre y otra factura:

- **Las réplicas se atrasan.** En hora pico, la lista de precios de Bogotá iba dos o tres minutos
  detrás de la de Bucaramanga. Un medicamento costó distinto en Chía y en Piedecuesta durante
  esos minutos, que es exactamente el problema que el Siga había resuelto en 2007.
- **El préstamo entre regiones es una transacción entre dos bases.** Prestar de Tunja a Chía exige
  descontar en un shard y sumar en el otro. El lote de quince minutos lo coordinaba, y cuando
  fallaba a la mitad, el préstamo quedaba descontado en un lado y sin sumar en el otro. Luz Marina
  tiene una consulta, que llama *"la de los huérfanos"*, que corre cada lunes para encontrarlos.
- **Dos Siga, dos despliegues.** Cada cambio exige ahora dos ventanas de fin de semana, una por
  datacenter, y una tercera cuando alguna de las dos sale mal.
- **Y cada paso sumó licencias**: los nodos del cluster, la copia en espera, el segundo Siga, la
  base partida y la herramienta de replicación, cada una con su línea en la factura. Todos, menos
  Contingencia, la única pieza que no agregó una línea, y por razones que nadie planeó.

> 🧭 **Para quien escribe la Fase 00:** este es el arco que hace creíble el curso. **Distribuir el
> monolito no es partirlo**: cada instancia del Siga sigue conteniendo todo el sistema, y por eso
> un problema en una parte sigue alcanzando a todas. Luz Marina lo dice mejor que nadie:
> *"Lo multiplicamos, pero no lo separamos."* Paracelso es el paso siguiente del mismo camino, no
> un salto: separar por responsabilidad lo que hasta ahora se separó por geografía.

### 1.9 🏍️ La Braqui: la flota propia y el módulo que no era Java

**Braquistócrona** la fundaron en 2018 dos ingenieros recién egresados de una universidad de
Bucaramanga, con más gusto por la física que por el mercadeo. El nombre es el de la curva por la
que una bola llega más rápido de un punto a otro, que no es la línea recta, y les pareció perfecto
para un sistema de rutas. Atendían un nicho que casi nadie había visto: **los domicilios de comida
callejera**, los puestos de arepas, empanadas y perros que no estaban en ninguna aplicación y que
necesitaban despachar con dos motos y un celular. Por eso, en un mundo pequeño, eran conocidos.

En abril de 2020, con el país encerrado y los domicilios multiplicados por cinco, no había tiempo de
hacer otro sistema como el portal. Uno de los consejeros tenía el contacto de un profesor de la
universidad que conocía a los muchachos, y la llamada se hizo un jueves.

**La demo fue esa misma llamada.** No hubo presentación ni documento técnico: uno de los
fundadores compartió la pantalla de su celular, abrió la aplicación y pidió un domicilio a una
venta de tacos del barrio **Provenza**. En la pantalla se vio la moto asignada, la ruta y el tiempo
estimado, y a los veintidós minutos el taco llegó a la casa del fundador, que se lo comió frente a
la cámara. Germán preguntó por la base de datos y por los respaldos; las respuestas fueron
cortas. Luz Marina dejó una línea en el acta —*"habría que ver cómo se integra con el Siga"*— que
nadie volvió a leer hasta 2023.

Don Aurelio no se quedó con la demo. El sábado siguiente, con tapabocas y en contravía de todos los
consejos del consejo, se fue a **La Concordia** a la venta de mute de **doña Ofelia**, que todo
Bucaramanga conoce, y le preguntó por la aplicación. Doña Ofelia le contestó lo único que él
necesitaba oír:

> *"Ay, don Aurelio, con esa cosa yo vendo mute hasta en Cañaveral. Antes no salía del barrio."*

**Sistemas le compró una licencia a la Braqui entre abril y mayo**, en pleno confinamiento, para
despachar los domicilios del **área metropolitana de Bucaramanga**, que es donde nació la
aplicación y donde los muchachos ya conocían cada calle. Funcionó tan bien y se volvió tan
necesaria que, en el **tercer trimestre de 2020**, la cooperativa **compró la empresa entera**, con
sus dos fundadores, para que operara **solo para La Vecina**. De Bucaramanga pasó a Bogotá, que era
donde más se necesitaba. Los puestos de comida callejera se quedaron sin su sistema —doña Ofelia
incluida—, y uno de los fundadores todavía lo menciona con culpa.

A la red, el nombre le pareció imposible de pronunciar, y en dos semanas ya todo el mundo le decía
**la Braqui**.

Hoy la Braqui despacha en el área metropolitana de Bucaramanga y en Bogotá. **En Boyacá no
entró**: allá el domicilio siguió funcionando como siempre, con los muchachos de cada droguería en
bicicleta y en moto, que conocen los pueblos mejor que cualquier ruta calculada. **Bogotá, en
cambio, no aguantó el modelo de Bucaramanga.** El volumen y las distancias de la
ciudad obligaron a la cooperativa a algo que nunca había tenido: **una flota propia**. En 2022 ya
eran ciento veinte motos de la cooperativa en Bogotá, con domiciliarios de nómina, turnos,
mantenimiento, combustible y liquidaciones. La vicepresidencia de logística tenía, sin haberlo
pedido, **una línea de negocio nueva**, y la Braqui pasó de despachar motos a administrar una flota
entera.

Ahí vino la decisión que todavía se discute. Una línea de negocio así necesitaba lo mismo que el
resto de la cooperativa: el mismo inicio de sesión, los mismos reportes en el BI, la misma
auditoría, el mismo inventario para saber qué lleva cada moto. Germán decidió en 2023 que la Braqui
dejara de ser un sistema aparte y pasara a ser **un módulo más del Siga**. Fue una decisión de
gobierno, no de tecnología, y en su lógica era impecable: una sola fuente de verdad.

En la práctica, "un módulo más" quedó así. La Braqui siguió escrita en **JavaScript, sobre
Node**, en sus propios servidores, porque nadie iba a reescribirla en Java EE. Pero **dejó su base
propia y pasó a leer y escribir directamente en las tablas del Siga**, en la base Oracle. Sus
pantallas aparecen dentro del menú del Siga, y sus cambios de esquema entran en las ventanas de
despliegue del Siga, aprobados por arquitectura.

Y la fricción vino sola, por los dos lados:

- **Los cambios de la Braqui hacen fila.** Una columna nueva en la tabla de despachos espera la
  aprobación de arquitectura y la próxima ventana de fin de semana, aunque el código de la Braqui
  se pueda desplegar un martes. Los dos fundadores, acostumbrados a desplegar diez veces al día,
  aprendieron a desplegar dos veces al mes.
- **La Braqui pregunta cada treinta segundos.** Como no hay forma de que el Siga le avise que hay un
  despacho nuevo, la Braqui consulta las tablas de despachos pendientes cada medio minuto, desde
  cada uno de sus procesos. En un día normal no se nota. El 14 de octubre se notó (§3).
- **Nadie sabe de quién es un despacho que falla.** Si la moto no sale, ¿es la Braqui, que no lo
  leyó, o el Siga, que no lo escribió? Las dos guardias se pasan el incidente, y Wilson, en el
  medio, llama a los dos.
- **Y los apodos.** En el equipo del Núcleo le dicen *"el módulo de los JavaScript"*; en la Braqui
  le dicen al Siga *"el abuelo"*. Nadie lo dice en una reunión, y todos lo dicen en el café.

> ⚰️ **Para quien escribe la Fase 12:** esta es la autopsia de **integrar por la base de datos**.
> Fue la decisión razonable de alguien que quería una sola verdad, y produjo dos equipos atados a
> un mismo esquema, a un mismo calendario y a una misma base que ninguno de los dos puede tocar sin
> el otro. El curso lo muestra con su principio, *una base por servicio*, y con la divergencia que
> el laboratorio declara: un solo Postgres, con una base y un usuario por servicio, y ninguna tabla
> compartida.

### 1.10 🌴 Cartagena, 2025: *"¿y eso quién se lo hizo?"*

En septiembre de 2025, Don Aurelio fue en representación del consejo a un congreso del sector
droguero en Cartagena. Iba por las charlas de compras y volvió con otra cosa.

En la cena de la segunda noche le tocó al lado de **Don Rodrigo Restrepo**, dueño de una cadena de
cuarenta droguerías en el Valle de Aburrá, que llevaba media hora quejándose de lo que le cobraba
su proveedor de software y de lo poco que le servía. Don Aurelio, que no sabe quedarse callado
cuando algo le sale bien, sacó el celular y le mostró los tableros del Siga en el BI de Microsoft
que el equipo de Germán había montado en 2023: los préstamos del día por zona, los domicilios por
hora, la reposición de la semana, las droguerías en rojo por faltantes. Don Rodrigo miró un buen
rato y preguntó lo que no se esperaba:

> *"¿Y eso qué casa de software se lo vendió, don Aurelio?"*
>
> *"Nadie, mano. Eso lo hicimos nosotros."*
>
> *"¿Y no lo venden?"*

Don Aurelio no durmió esa noche, y en el vuelo de regreso a Bucaramanga ya tenía la idea entera,
dicha a su manera: si a Don Rodrigo le servía, les servía a todas las cadenas pequeñas del país
que estaban pagando por software que no les entendía el negocio. **¿Y si el Siga se pudiera
vender?** En las dos semanas siguientes llamó a tres colegas más, de Cali, de Pereira y de la
Costa. Los tres dijeron lo mismo: *"Si ustedes lo venden, yo lo miro."*

### 1.11 🧾 La junta: *"¿y qué es esa vaina del SaaS?"*

Don Aurelio llevó la idea al consejo sin avisarle a Germán, que se enteró en la misma reunión. El
CTO tuvo la decencia de no decir que no de entrada, y la claridad de explicar por qué la idea, tal
como venía, no se podía hacer. La conversación quedó en el acta, y la cooperativa la cuenta así.

> *"Don Aurelio, lo que usted vio en Cartagena tiene nombre. Se llama software como servicio, o
> SaaS, por la sigla en inglés. No le vendemos el programa a Don Rodrigo, ni se lo instalamos en
> sus computadores. Lo corremos nosotros, en un solo sitio, y él paga una mensualidad por cada
> droguería que lo use. Como el arriendo: él no compra el local, paga por usarlo."*
>
> *"¿Y eso qué es, mano, como alquilar el Siga?"*
>
> *"Algo así. Y el negocio está en una cuenta sencilla. Construir el sistema cuesta lo mismo si lo
> usa una cadena o si lo usan diez. Lo que cambia con cada cadena nueva es poco: un poco más de
> máquina, un poco más de soporte. Pero la mensualidad entra entera, todos los meses. Con unas
> cuantas cadenas del tamaño de la de Don Rodrigo, la plataforma se paga sola, incluida la parte
> que hoy usamos nosotros."*
>
> *"¡Ave María! ¿Y entonces qué esperamos?"*
>
> *"Que el Siga no se puede vender, Don Aurelio. Por tres razones."*

Las tres razones de Germán son, sin que él lo supiera, el temario de la segunda mitad del curso:

1. **El Siga está hecho para una sola cadena.** Cada regla de La Vecina —el préstamo entre
   vecinas, los umbrales, los precios— vive en el PL/SQL de una sola base de datos. Para servirle a
   diez cadenas, cada una tiene que tener su marca, sus precios y sus datos separados de los de las
   demás, **en el mismo sistema**. Eso no se le agrega a un monolito de 2007: se diseña desde el
   principio.
2. **Las licencias no se revenden.** La base, el servidor de aplicaciones y Java están
   licenciados para el uso de la cooperativa. Correr el sistema para otras empresas es otro tipo de
   uso, con otros contratos y otra factura. *"Si con nosotros solos la renovación ya nos asusta,
   imagínese con diez cadenas encima."*
3. **Un producto no se despliega un fin de semana al mes.** Si diez cadenas dependen del sistema,
   no hay ventana de mantenimiento que les sirva a todas, y la pregunta de la asamblea se vuelve
   diez veces más seria: *"¿quién lo arregla un domingo?"*. Tiene que poder actualizarse sin
   apagarse, y que una cadena en quincena no le quite la máquina a las demás.

Y entonces Germán dijo la frase que cambió el tono de la reunión:

> *"Pero fíjese en una cosa, Don Aurelio. Esa migración ya la tenemos que hacer, por la factura de
> Oracle y por lo que sea que nos esté esperando en la próxima temporada de lluvias. La pregunta
> no es si gastamos esa plata. La pregunta es si la gastamos en arreglar lo nuestro, o en
> arreglarlo de una forma que algún día se pueda vender. Lo segundo cuesta un poco más al
> principio, y deja una puerta abierta."*

Doña Graciela, que había escuchado todo sin decir nada, cerró el punto como cierra todos:

> *"Nosotros vendemos medicamentos, no programas. Pero si de todas formas hay que hacer el
> arreglo, que quede bien hecho. Y nadie le promete nada a Don Rodrigo hasta que esto funcione."*

El consejo no aprobó ningún producto. Aprobó algo más modesto y más útil: que el sistema nuevo,
si se hacía, **se hiciera de forma que pudiera servir a más de una cadena**. Tres semanas después,
el 14 de octubre, llovió en Boyacá (§3), y la discusión dejó de ser teórica.

> 🧭 **Para quien escribe una fase:** el producto es **un embrión**, y la historia no lo convierte
> en otra cosa. Nadie lo ha aprobado, no tiene nombre ni precio, y Don Rodrigo no es cliente. Lo
> que sí existe es la condición del consejo, y es la que el curso usa: la plataforma tiene que
> poder instalarse para una segunda cadena sin copiarlo todo. Facturar, dar de alta clientes,
> autenticar a varias cadenas y el modelo de datos de un SaaS de verdad **quedan fuera del curso**.


---

## 2. 👥 Quién es quién

**Doña Graciela Serrano**, cofundadora, regente histórica de Girón y presidenta del consejo de
administración. Habla poco, en voz baja y de usted, y nunca se ha equivocado con un inventario.
Es el freno de la cooperativa y su memoria. **"Lo que no está en el anaquel no se vende"** es su
frase, y no la dice como consigna sino como regla de contabilidad. Todavía tiene el cuaderno
verde en el cajón.

**Don Aurelio Prada**, cofundador, el droguista de Floridablanca que convirtió el préstamo en
domicilio. Habla duro, cuenta la historia del salbutamol cada vez que hay alguien nuevo y termina
cada argumento con *"¡siempre llega, mano!"*. Es el acelerador de la cooperativa: fue él quien
empujó Tunja, Bogotá y el portal, y el que volvió de Cartagena con la idea de vender
el Siga. Su punto ciego es el de su socia al revés: cree que si el cliente quedó contento, el
inventario se arregla solo.

**Germán Camargo**, CTO. Fue el vicepresidente de sistemas que llegó en 2006 y diseñó la casa
Oracle y Microsoft. Hoy su realidad es otra: vive en el presupuesto, en el comité de inversiones,
en las renovaciones de contratos y en la asamblea. Ya no dibuja diagramas; delega lo técnico en
arquitectura y en los equipos. Es **quien patrocina el POC**, porque la renovación de licencias
cae en su presupuesto, y es quien tiene el mejor argumento de la sala en contra de cambiar nada:

> *"En veinte años no nos hemos caído un día completo. Si me van a pedir que cambie eso,
> tráiganme algo mejor que entusiasmo. Y tráiganme un número."*

La frase es verdad a medias, y en sistemas todos lo saben. El Siga nunca estuvo caído un día
entero, pero eso se pagó en **noches**: el equipo amaneciendo para apagar incendios, la réplica
de Bogotá que se desincronizaba y había que volver a cuadrar con **scripts que cargaban CSV a mano**
a las tres de la mañana, los préstamos huérfanos de los lunes, la ventana de fin de semana que se
alargaba hasta el domingo. Desde el comité eso no se ve: el lunes las cajas abren y el Siga está
arriba. En sistemas tiene un nombre. Cuando alguien ve venir un incidente —un correo raro de la
Braqui un viernes a las cinco, una alerta de réplica atrasada en quincena— lo anuncia con la frase
de la casa: ***"hoy comemos pizza"***.

**Luz Marina Quintero**, jefa de arquitectura. Entró al equipo de Germán en 2008, como
desarrolladora del módulo de préstamos, y creció con el Siga. Dirigió el cluster de 2012 y la
partición por región de 2021, y es quien corre cada lunes la consulta de los préstamos huérfanos.
Conoce cada parche de los últimos dieciocho años, y sabe exactamente dónde se separaron el diseño de
2007 y el sistema real. Es el freno técnico: no se opone al POC, pero exige que demuestre lo que
promete.

> *"Mi monolito aguanta. Lo que no aguanta es la factura, y eso no se arregla con YAML. Si me
> van a sacar un pedazo, que sea uno que funcione mejor afuera que adentro."*

**Valentina Mantilla**, líder de **Alquimia**, la unidad de I+D de sistemas, y antes líder de
plataforma. Bumanguesa, la contrató Luz Marina en 2021, cuando la cooperativa armó un equipo de
plataforma para Bogotá. Dirige el **proyecto Paracelso** y arma **La Rebotica**, el laboratorio en
portátiles donde se construye, porque todavía no hay presupuesto de nube aprobado. Su relación con
Luz Marina es la de alumna y maestra discutiendo con números, no la de lo nuevo contra lo viejo.
Escribió el servicio de precios en Go porque era el primero que le tocaba extraer y el más pequeño.
Es la voz que el lector escucha más a menudo.

**Wilson Rangel**, coordinador de domicilios de toda la red, en la vicepresidencia de logística.
Fue el sobrino que manejó el carro la noche del salbutamol y el primero en comprar moto. Hoy
coordina cuatrocientos domiciliarios en tres departamentos, conoce cada barrio de Bucaramanga y
cada curva de la carretera a Tunja, y desconfía de cualquier sistema que no sepa que la calle 45
está cerrada por obras. Encarga los incidentes de domicilios.

**Andrés Suárez**, arquitecto de software del equipo de Luz Marina. Reporta a arquitectura en lo
técnico, a Germán en las decisiones de plataforma y a compras en todo lo que tenga licencia, y por
eso le caen los encargos que cruzan las tres cosas, casi siempre sin presupuesto. *"A Andrés le
tocan los chicharrones"* se dice en sistemas, y es verdad: sacó Contingencia en 2016 y el portal en
2019, las dos veces con lo que tenía a mano. Aficionado a la mitología, bautizó Asclepio a
Contingencia, y empezó una costumbre que Valentina siguió con Paracelso. No le gusta que le
recuerden que el software libre entró a la empresa por él.

**Daniela Ortiz**, líder del equipo del portal. Llegó en 2019 como pasante de ingeniería de
sistemas, hizo el portal con los practicantes del SENA en un trimestre, y la
cooperativa la contrató para que el proyecto no quedara sin dueño. Es la que mejor conoce lo que
el cliente ve, y la que menos paciencia tiene con la sincronización nocturna del catálogo.

**Yolanda Ardila**, regente de la droguería del parque de Girón, la más antigua de la red, y
ahijada de Doña Graciela. Atiende el mostrador desde los diecinueve años y encarga los incidentes
del mostrador. Cuando la caja se congela, no llama a sistemas: saca el cuaderno.

**Los cuatro equipos de los cuatro stacks.** El **equipo del Núcleo**, en Java, bajo
arquitectura, que mantiene el Siga y extrae `inventory`. **El equipo del portal**, el de
Daniela, en Laravel, que mantiene el portal y su catálogo (`catalog`). **El equipo de la
Braqui**, en Node, que hace la reposición y los despachos (`replenish`). Y **el equipo de
plataforma**, el de Valentina, en Go (`pricing`). Cada servicio tiene un dueño, y cada dueño
eligió lo que sabía operar: **ese es el motivo del poliglotismo del curso**, y en una empresa con
estructura corporativa es el motivo correcto.

**Los otros vicepresidentes.** Son cinco, y en el comité tienen cada uno su pregunta. **Martha
Lucía Cáceres**, la vicepresidenta financiera, es la que convierte cada propuesta en pesos por mes
y la primera en pedirle a Germán *"el número"*. **Fabio Arenas**, el de operaciones, habla por las
263 regentes, y su única métrica es si la caja se congela. Los de compras, logística y comercial
aparecen cuando la decisión les toca: el de logística, porque Wilson trabaja para él; el comercial,
porque el Club Vecinos es suyo.

**Don Rodrigo Restrepo**, dueño de una cadena de cuarenta droguerías en el Valle de Aburrá. No es
de la cooperativa ni es cliente: es la pregunta de Cartagena con nombre propio, y la primera
persona a la que nadie le puede prometer nada.

**La asamblea de socios.** Ciento cuarenta y dos droguistas con voto. No saben qué es Kubernetes
y preguntan lo único que importa: *"¿cuánto cuesta, y quién lo arregla un domingo?"*

---

## 3. 🗄️ Los sistemas que hay hoy, y de dónde salieron

Este apartado alimenta la **Fase 00**, y se lee como un expediente, no como un juicio. Cada una
de estas decisiones la tomó gente con buena información y buenas razones, y casi todas fueron
correctas el año en que se tomaron.

**El Siga (2007).** El sistema central: inventario por droguería, movimientos, préstamos y
traslados, precios, facturación y la integración con las cajas. Es un monolito Java EE desplegado
como un solo archivo en **WebLogic** desde 2015, sobre **Oracle Database** con buena parte de la
lógica en PL/SQL. Hoy corre en **dos datacenters**, Bucaramanga y Bogotá, cada uno con su cluster de
WebLogic, sobre una base **partida por región** y replicada, más una copia en espera (§1.8). Las
cajas de las droguerías —en Windows— le hablan por **servicios SOAP**, que en 2008 eran
exactamente lo que había que hacer. Tiene cuatro decisiones de época que hoy pesan:

- **Un solo pool de conexiones a la base para todo.** El mostrador, el portal y el
  lote de préstamos comparten las mismas conexiones. En 2007 eran cuarenta droguerías y una sola
  forma de vender; hoy es el canal por el que un pico de domicilios congela las cajas de todo el
  país.
- **Un solo despliegue para todo.** Cambiar el precio de un medicamento exige desplegar el
  Siga entero, y desplegar el Siga entero exige una ventana de fin de semana. **La
  circular de precios que llega un martes se aplica, con suerte, el domingo de la semana
  siguiente.**
- **Multiplicado, no separado.** Las dos instancias del Siga contienen el sistema entero, y lo
  que es de todos —el catálogo, los precios, el préstamo entre regiones— vive en el nodo central de
  Bucaramanga. Cualquier cosa que sature el nodo central alcanza a las dos ciudades.
- **El lote de préstamos cada quince minutos.** Diseñado para que la base no sufriera en horas de
  mostrador, y perfecto para un mundo donde el préstamo viajaba en bus intermunicipal. En un mundo
  donde el domicilio se promete en una hora, quince minutos de espera son la cuarta parte de la
  promesa.

**El Club Vecinos, en Siebel (2012).** Afiliados, puntos y campañas. Funciona, el área comercial
lo conoce de memoria, y **corre sobre Oracle Database**: Siebel admite Oracle, SQL Server y DB2 como
base, y no Postgres. Mientras el Club viva en Siebel, una base Oracle sigue encendida. Y tiene su
propio reloj: Siebel sigue vigente y con actualizaciones, pero lo que Oracle empuja hoy es su CRM
en la nube, por suscripción, y el ejecutivo de cuenta ya lo sugirió. **"Siebel se queda por ahora"
es una decisión con fecha de vencimiento**, y es la próxima renovación que espera a Germán.

**El portal (2019).** Se llama PPVW, Portal de Pedidos y Ventas Web, y nadie le dice así. Laravel,
hecho en un trimestre como prueba de concepto por aprendices del SENA y pasantes de ingeniería, con
Andrés Suárez, el arquitecto de Contingencia, a cargo, una estimación optimista y casi sin
presupuesto. Era un piloto para depender menos de las plataformas de domicilios, y la pandemia lo
volvió el canal principal de Bogotá tres meses después de salir. La decisión de PHP fue de plazo, no
de arquitectura, y fue correcta: había que tener algo andando antes de que cerrara el trimestre.
**Corre en un servidor virtual alquilado fuera de los dos datacenters**, pagado con la tarjeta
corporativa de la vicepresidencia comercial, y en el inventario de sistemas de Germán todavía figura
como *"piloto domicilios 2019 (temporal)"*, casi siete años después. Tiene su propio catálogo de
productos, que **se sincroniza con el del Siga cada noche**, y por eso un producto nuevo tarda un
día en aparecer en el portal. Como nadie lo miró mucho mientras se hacía, nadie le puso las reglas
del Siga encima, y por eso mismo es lo más moderno que tiene la empresa. Daniela lo defiende con
razón.

**La Braqui (2020, módulo del Siga desde 2023).** Node, licenciada en el confinamiento y comprada
con sus dos fundadores en el tercer trimestre de 2020. Despacha motos en el área metropolitana de
Bucaramanga y en Bogotá, calcula rutas, lleva el estado de cada pedido y administra la flota propia
de Bogotá. En Boyacá no entró. Hasta 2023 **se enteraba de los préstamos por correo electrónico**,
que es como los dos ingenieros lo resolvieron en la semana de la compra. Desde 2023 es **un módulo
del Siga**: sigue en Node y en sus propios servidores, pero **lee y escribe directamente en las
tablas del Siga**, consulta los despachos pendientes cada treinta segundos y despliega sus cambios
de esquema en las ventanas del Siga (§1.9).

**Contingencia (2016).** El Siga reducido que opera en un solo sitio cuando el central no contesta,
en unos sesenta sitios: los centros de distribución, las droguerías grandes y los pueblos de Boyacá,
donde es un computador de escritorio con una planta eléctrica al lado. Mismo código del Siga, con
JPA e Hibernate, en **GlassFish** y sobre **PostgreSQL**, porque la evaluación de licencias de
Oracle no llegó a tiempo (§1.8). Solo hace CRUD: la lógica pesada se quedó en el central. Guarda sus
transacciones en un log y lo envía al volver. Tiene una decisión de época que hoy pesa: **se
enciende cuando el Siga no contesta**, y no cuando contesta tarde.

**El puesto de trabajo y las cajas.** Todo Microsoft: directorio de usuarios, correo, Office,
estaciones de trabajo con Windows, las cajas de mostrador y los kioscos de autoservicio de
Bogotá. Germán impuso desde 2006 **un proxy corporativo que inspecciona todo el tráfico cifrado**
con un certificado propio de la empresa, por política de seguridad. Es una buena política, y es
el primer incidente que va a tener cualquiera que intente bajar una imagen de contenedor desde un
portátil de la cooperativa.

**Y los dos sistemas que nadie llama sistema.** El servidor del portal, que no aparece en
ningún contrato de datacenter y que el día que lo encuentre un auditor va a dar una conversación
larga. Y el cuaderno verde de Doña Graciela, que salió del cajón
una vez en veinte años. La noche del 14 de octubre de 2025.

> ⚰️ **La factura de tener un solo pool.** El martes 14 de octubre de 2025 llovió en Boyacá y en
> Bogotá como no llovía en diez años, y la temporada de gripa se adelantó tres semanas. Los
> domicilios de la tarde fueron el triple de un martes normal, casi todos en Bogotá, y la mitad
> con algún producto que la droguería no tenía. Cada uno disparó una búsqueda de préstamo entre
> regiones, y todas fueron a parar al nodo central de Bucaramanga, donde ya estaban las consultas
> de la Braqui preguntando cada treinta segundos por despachos pendientes. A las 6:40 p. m. el pool
> de conexiones del nodo central se llenó con todo eso y con las consultas del
> portal. Las cajas de Santander y Boyacá, que viven en ese nodo, se congelaron primero; las de
> Bogotá, que consultan precios y préstamos al nodo central, se quedaron esperando detrás. **Las
> cajas de las 263 droguerías se congelaron al mismo tiempo**: no podían consultar precios ni
> descontar inventario. Durante tres horas y cuarenta minutos se vendió a mano, con calculadora y
> en papel. **Contingencia no se prendió en ninguno de los sesenta sitios**: su regla era
> encenderse cuando el Siga no contestara, y el Siga contestaba, solo que tardaba un minuto en
> hacerlo. En sistemas, alguien dijo *"hoy comemos pizza"* a las 6:45, y la pizza llegó a las 7:30
> y se enfrió en la mesa. La droguería de Girón no tiene Contingencia, porque no es de las
> grandes: Yolanda sacó el cuaderno verde del cajón y anotó ciento doce ventas con la letra de
> Doña Graciela. El jueves siguiente, en el comité, Germán hizo
> la pregunta que da origen a este curso:
>
> *"¿Por qué un pico de domicilios en Bogotá le congela la caja a Yolanda en Girón, si para eso
> partimos el Siga en dos?"*

---

## 4. 💸 La factura, y el reloj

El 14 de octubre fue el detonante. Pero el comité ya venía mirando otro reloj, y ese reloj tiene
fecha.

**El soporte de Oracle vence en abril de 2027.** El contrato de soporte de la base y de WebLogic
se renueva por tres años, y la renovación cae en el presupuesto de Germán. La cuenta se hace por
procesador, y cada paso de §1.8 la hizo crecer: los nodos del cluster, la copia en espera, el
segundo Siga, la base partida y la herramienta de replicación.

**Java empezó a cobrarse por empleado.** Desde enero de 2023, la suscripción de Java SE de Oracle
se vende por **empleado de toda la empresa**: tiempo completo, medio tiempo, temporales y
contratistas, sin importar dónde corra Java. La Vecina tiene unas **4.200 personas**, casi todas
auxiliares de mostrador y domiciliarios que jamás han tocado Java. En la lista de precios
publicada, ese tamaño queda en el tramo de **USD 10,50 por empleado al mes**: del orden de
**medio millón de dólares al año de lista**, para cubrir los servidores donde corre Java. Germán
lo leyó dos veces. La segunda, en voz alta.

**Los datacenters.** Los servidores viven en dos datacenters alquilados, uno en Bucaramanga y otro
en Bogotá, y los dos contratos vencen en la misma ventana. Y en la primera reunión alguien dijo la
frase que siempre se dice: *"subamos todo a la nube"*.

**La trampa de subir todo tal cual.** Valentina hizo la cuenta antes del comité. En las nubes
autorizadas por Oracle que no son de Oracle, **dos vCPU cuentan como una licencia de procesador y
no se aplica la tabla de factor de núcleo** que en el datacenter propio reduce la cuenta a la
mitad. Mover el Siga tal cual a máquinas virtuales en la nube no baja la factura de
licencias: en muchos casos la sube. Lo que la baja es **sacar carga de Oracle**.

> 📝 Las cifras de este apartado son de las listas de precios y las políticas públicas de Oracle,
> y se vuelven a verificar con fecha antes de que ninguna fase las cite. Ninguna fase las usa como
> argumento técnico: son el contexto de negocio, no el contenido del curso.

---

## 5. ⚗️ Alquimia, el proyecto Paracelso y La Rebotica

### 5.1 Alquimia: el I+D de sistemas

En noviembre de 2025, tres semanas después del 14 de octubre, Germán llevó al comité una propuesta
que no era un proyecto sino una unidad: **un pequeño equipo de investigación y desarrollo dentro de
la vicepresidencia de sistemas**, de tres personas, con Valentina a la cabeza y un presupuesto
anual que hay que defender cada diciembre. Su trabajo es probar lo que el Siga no deja probar, sin
tocar producción, y traer de vuelta decisiones con número.

El nombre salió del comité, como salen los nombres de las unidades corporativas, y fue
**Alquimia**: por la botica, que viene de ahí. Martha Lucía, la vicepresidenta financiera, hizo la
pregunta que todos estaban pensando:

> *"¿Alquimia? ¿Eso no era lo de convertir plomo en oro, que nunca funcionó?"*
>
> *"Por eso, doctora. Todo lo que salga de ahí va a traer su número. Si no lo trae, no sale."*

Valentina contestó eso sin pensarlo mucho, y se volvió la regla de la unidad. Germán cerró el
punto con la frase que mejor explica por qué existe Alquimia:

> *"En el fondo, esto es poner por escrito lo que Andrés ya hizo dos veces sin presupuesto:
> Contingencia y el portal. La diferencia es que esta vez lo vamos a pagar."*

### 5.2 El proyecto Paracelso

El primer encargo de Alquimia tiene nombre propio, y lo puso Valentina siguiendo a propósito la
tradición de Andrés, que había bautizado Asclepio a Contingencia: **proyecto Paracelso**.
Paracelso fue el médico del siglo XVI que sacó a la alquimia de la búsqueda del oro y la puso a
fabricar medicinas, y el que dejó escrito que **la dosis hace el veneno**. Alquimia con medición:
justo lo que Martha Lucía había pedido.

Paracelso tiene **dos objetivos**, y la asamblea los aprobó juntos en febrero de 2026, con
presupuesto para el equipo y sin presupuesto de nube. El primero es **modernizar la plataforma**:
sacar del Siga, pieza por pieza, lo que ya no cabe en él. El segundo es **dejar la puerta abierta al
producto** de Cartagena (§1.11). La disposición a invertir vino de juntarlos: el arreglo que de
todas formas había que hacer podía, además, convertirse en algo que se vende.

### 5.3 La Rebotica: donde se construye

Paracelso no tiene servidores todavía. Se construye en un laboratorio en portátiles, con
contenedores y un Kubernetes local, y ese laboratorio tiene el nombre que le puso Doña Graciela
cuando Valentina le explicó que iban a probar el sistema nuevo antes de gastar un peso en
servidores:

> *"Ah, entonces es la rebotica. Allá atrás se prueba, y al mostrador sale solo lo que funciona."*

La rebotica es la trastienda de la botica antigua, el cuarto de atrás donde el boticario preparaba
lo que no estaba en el mostrador. **La Rebotica es el laboratorio del curso, y Paracelso es lo que
el curso construye en él.**

**Y arranca de Contingencia.** Valentina no podía llevar el Siga central a tres portátiles: pesa lo
que pesa un cluster de WebLogic, y ni WebLogic ni Oracle se pueden instalar en un portátil sin
abrir otra conversación de licencias con el comité. Contingencia, en cambio, ya es un Siga que cabe
en un solo sitio, corre en GlassFish y en Postgres, y no necesita ninguna licencia, porque así se
construyó en 2016. Al lado le pusieron copias del portal y de la Braqui. **Ese es el patrimonio con
el que empieza La Rebotica**: lo que La Vecina ya tiene, en la versión que cabe en un portátil.
Andrés, que pasa por La Rebotica más seguido de lo que su agenda le permite, lo resumió así:
*"Diez años después, el chicharrón de Contingencia nos está pagando el laboratorio."*

### 5.4 El encargo

El encargo de Paracelso, escrito por Germán en una sola página, tiene cuatro preguntas:

1. **¿Se puede sacar del Siga lo que más cambia y lo que más carga recibe**, sin tocar el
   mostrador de nadie?
2. **¿Cómo se comporta eso sobre Postgres**, en microservicios, en una plataforma de contenedores
   que algún día corra en un proveedor de nube con buen soporte para Java?
3. **¿Cuánto cuesta operarlo**, y quién lo arregla un domingo?
4. **¿Se puede instalar para una segunda cadena sin copiarlo todo?** Es la condición del consejo,
   y la única parte de la idea de Don Aurelio que entra al POC.

Y una condición, que es la mejor definición de requisitos que ha escrito nadie en esa empresa:

> *"Que cuando yo le presente esto a la asamblea, cada número tenga detrás una prueba que alguien
> pueda repetir. Y si algo no se pudo medir, que lo digan, en vez de ponerme una cifra bonita."*

**El orden de extracción** lo decidió Luz Marina, y es el orden del curso:

- **Primero los precios**, porque son lo que más cambia —la circular que llega un martes— y lo
  que menos depende del resto. Es el servicio de Valentina, en Go: `pricing`.
- **Después el inventario**, que es el corazón: `inventory`, en Spring Boot, por el equipo del
  Núcleo, que sabe Java desde 2008.
- **El portal ya está afuera**: `catalog` se suma al POC con el equipo de Daniela y su
  stack. Es la ironía que Valentina repite: lo único que nació fuera del Siga lo hicieron los
  practicantes.
- **La Braqui está a medio camino**: tiene su propio código, pero vive pegada a las tablas del
  Siga. `replenish` es la Braqui despegada: con su base propia, hablándole al resto por contrato y
  no por tablas compartidas. Para sus dos fundadores es, sobre todo, volver a desplegar un martes.
- **El préstamo entre droguerías va al final.** Es lo más viejo y lo más tocado del Siga, el
  primer encargo de Germán, y la pieza más peligrosa de mover. Es la Parte IV del curso.

**Lo que Paracelso no hace**, y está escrito en el encargo: no migra datos del Siga ni convierte su
PL/SQL en general —con una excepción, el procedimiento del préstamo entre droguerías, que deja de
ser una transacción en una sola base y pasa a ser una saga entre servicios—; no toca Siebel, que se
queda en Oracle por ahora; no compara Oracle contra Postgres; y **no elige proveedor de nube**. Eso
último es una discusión para después del POC, y ya empezó:

- **Oracle** fue el primero en sentarse. Su ejecutivo de cuenta ofreció su propia nube, donde las
  licencias que la cooperativa ya tiene rinden más, y su base de datos gestionada **también dentro
  de Azure**, gracias a la alianza entre los dos. De paso, sugirió llevar el Club Vecinos de
  Siebel a su CRM en la nube. Es una oferta razonable, y Germán la tiene encima del escritorio.
- **Microsoft** llegó segundo, con una ventaja que no tiene que ver con la tecnología: la
  cooperativa ya tiene un acuerdo corporativo con consumo de Azure comprometido. *"Eso ya lo
  estamos pagando"* es una frase que en un comité de inversiones pesa más que cualquier
  diagrama. Y trae Kubernetes gestionado, Postgres gestionado y su propia distribución de
  OpenJDK con soporte.
- **AWS y Google** están nombrados en el acta. Nadie los invitó todavía.

Pero sobre el escritorio de Germán hay algo más que las dos ofertas, y no está en ninguna planilla
de costos: **la presión de Don Aurelio por convertir el Siga en un producto**. Nadie la dice en voz
alta en el comité, porque el consejo solo aprobó "que sirva a más de una cadena" y Doña Graciela
dejó claro que a Don Rodrigo no se le promete nada. Pero desde Cartagena la idea tiene
entusiasmada a buena parte de la directiva. Martha Lucía ya hizo, por su cuenta, la cuenta de
cuántas cadenas harían falta para pagar la plataforma; el vicepresidente comercial pregunta en
cada reunión *"¿y eso se podría mostrar?"*; y Fabio Arenas, el de operaciones, que no se entusiasma
con nada, dijo una vez que *"si a otros les sirve, a nosotros nos sirve más"*.

Eso cambia la conversación con los proveedores, y Germán lo sabe. **Paracelso no es una migración a
la nube.** Subir el Siga tal cual a OCI o a Azure es una discusión de licencias y de máquinas
virtuales, y es la que hoy está sobre la mesa. Repensar el sistema para que algún día sea un
servicio que corren muchas cadenas es otra cosa: otra arquitectura, otro modelo de costos, otro
contrato. Si Paracelso sale bien, **habrá una segunda discusión con los proveedores de nube**, y
esta vez no se va a tratar de dónde poner el Siga, sino de dónde correr un producto. Germán guarda
las dos ofertas en la misma carpeta, y en la tapa escribió con lapicero: *"Primera ronda"*.

> 🧭 **El curso no elige la nube.** Les da a Germán y a la asamblea el diccionario para leer las
> ofertas, y la medición para hacer la cuenta. La decisión es de ellos.

**Y un detalle de compras que define el laboratorio.** Docker Desktop exige suscripción paga en
empresas de 250 empleados o más, o con 10 millones de dólares o más de ingresos. Compras no
aprobó otra suscripción por puesto para un POC. Valentina armó La Rebotica para que funcione igual
con **Docker y con Podman**, y por eso el curso trabaja con los dos.

### 5.5 🏛️ Y lo que sueña Don Aurelio

La historia se cierra donde empieza el curso, con Paracelso recién aprobado y La Rebotica armada en
tres portátiles. Pero Don Aurelio ya está más adelante.

En la misma asamblea de febrero, a la salida, le mostró a Doña Graciela una servilleta con un
organigrama dibujado con lapicero. Arriba decía **Grupo La Vecina**, y debajo colgaban tres cajas:
**la cooperativa**, con sus droguerías; **la Braqui**, como empresa de logística de última milla
que algún día podría volver a despacharle a otros —*"hasta a doña Ofelia, mano"*—; y una **casa de
software** que vendería el Siga nuevo a las cadenas como la de Don Rodrigo. Un holding, dicho por un
droguista de Floridablanca que empezó con tres metros de frente.

Doña Graciela miró la servilleta un buen rato, la dobló en cuatro y se la guardó en la cartera:

> *"Primero que funcione, Aurelio. Después hablamos de holdings. Y anote que lo que se presta se
> devuelve: si esto sale mal, la plata es de los socios."*

Germán, que venía detrás, solo agregó una condición, y la dijo en serio:

> *"Si algún día hay holding, que ninguna de esas tres cajas dependa de una licencia que no podamos
> revender."*

> 🧭 **Para quien escribe una fase:** el holding es un sueño de Don Aurelio, y así se queda. No tiene
> fecha, no tiene estructura y no lo aprobó nadie. Sirve para una sola cosa: recordar que lo que
> Paracelso decida sobre la plataforma tiene consecuencias más allá de La Vecina, y que por eso cada
> decisión se defiende con número. El curso termina con la recomendación de la Fase 27, no con el
> holding.

---

## 6. 💥 Los dolores, uno por parte del curso

Cada uno es la puerta de entrada de una parte. Aquí están en la voz de la empresa; en el temario
están en la de la plataforma.

**🧰 Parte 0 — "En mi portátil no corre."** Los portátiles de la cooperativa tienen Windows,
políticas corporativas y el proxy que inspecciona todo. Lo primero que hace Valentina al armar La
Rebotica es pelear con la virtualización, con el motor de contenedores y con el certificado del
proxy. El equipo de la Braqui, que trabaja en Mac, no entiende de qué se queja nadie.

**🔬 Parte I — "¿Y eso es una máquina virtual chiquita?"** Luz Marina lleva dieciocho años
pensando en servidores de aplicaciones, dominios y clusters de WebLogic. Su primera pregunta sobre
un contenedor es cuánta memoria hay que asignarle a la máquina, y la pregunta es razonable: así
funcionó toda su vida profesional.

**☸️ Parte II — "Siempre llega, pero ¿a cuál réplica?"** El inventario que, con dos copias del
servicio, dice que hay y que no hay según quién conteste. La circular de precios que se aplicó en
una réplica y no en la otra. El servicio de Java que tarda en arrancar y recibe tráfico antes de
estar listo.

**🔭 Parte III — "¿Quién está mirando?"** El 14 de octubre, nadie supo durante cuarenta minutos
por qué se congelaban las cajas. Y el día que el certificado del portal de afiliados se venció un
domingo, el área comercial se enteró por las quejas de los clientes. Esto no es hipotético: en una
empresa con un proxy que inspecciona todo, los certificados son el pan de cada día.

**🔀 Parte IV — Las dos motos.** El préstamo entre vecinas, distribuido de verdad. Los préstamos
huérfanos que Luz Marina busca cada lunes, descontados en una región y nunca sumados en la otra. El
"último Excel de la bandeja es el bueno", que en 2003 viajaba por Hotmail y en 2021 viajaba entre
dos bases replicadas. La droguería de Sogamoso que tarda doce segundos en contestar si tiene el
producto. La venta que se cobró y el traslado que no salió. El aviso a la Braqui que se perdió. Y
las dos motos con el mismo inhalador, que es la lección que el coordinador de domicilios no deja
olvidar.

**⚖️ El cierre — ¿Y todo esto para qué?** La recomendación que Valentina le entrega a Germán: qué
sale del Siga, qué se queda, qué se queda en Oracle, y —con la misma honestidad— si para el
tamaño de La Vecina hacía falta un orquestador o alcanzaba con menos. **Y qué cambia en esa
respuesta si un día son diez cadenas y no una**: para La Vecina sola, la respuesta honesta puede
ser que no; para el producto de Don Aurelio, la cuenta es otra.

---

## 7. 📊 Los números de la casa

Son los de la historia, y **ninguno es una meta del laboratorio**. El laboratorio corre en un
portátil y nunca extrapola a estos números; Valentina se lo explica a Germán en la Fase 16, y es
una de las escenas que el curso repite a propósito.

| Magnitud | Hoy |
|---|---|
| Droguerías bajo la marca | 263 · en Santander, Boyacá, Cundinamarca y Bogotá |
| Socios con voto | 142 droguistas |
| Personas | ≈ 4.200 · de ellas, 38 en tecnología |
| Domiciliarios | ≈ 400 · de ellos, ≈ 120 de la flota propia de Bogotá; el resto, muchachos de cada droguería y aliados |
| Domicilios por día | ≈ 11.000 · el triple en un pico como el del 14 de octubre |
| Préstamos entre droguerías por día | ≈ 1.800 |
| Referencias en el catálogo | ≈ 9.500 |
| Afiliados al Club Vecinos | ≈ 610.000 |
| Centros de distribución | 2 · Girón y Funza |
| Datacenters | 2 · Bucaramanga (el nodo central) y Bogotá |
| Sitios con Contingencia | ≈ 60 · los dos centros de distribución, las droguerías más grandes y las de los pueblos de Boyacá |
| Vicepresidencias | 6 · compras, operaciones, logística, financiera, comercial y sistemas |

> 🧭 **La regla de los números**, y es la más importante de este apartado. Las mediciones del
> curso se hacen sobre el laboratorio, con datos sembrados para el laboratorio, y se publican como
> **proporciones** entre alternativas. Ninguna fase dice "esto aguanta los 11.000 domicilios de
> La Vecina", porque un portátil no es la nube y la frase sería mentira.

---

## 8. 📖 El vocabulario de la casa

### 8.1 Las entidades

Son las siete del contrato del curso, en inglés y sin renombrar nunca. El glosario es para leer el
texto:

| Entidad | Qué es en la droguería |
|---|---|
| `store` | La **droguería**: el punto de venta, con su mostrador, su regente y su barrio |
| `product` | El producto en su **presentación**: el medicamento con su concentración y su empaque, o el artículo de cuidado personal |
| `category` | La categoría del catálogo: venta libre, cuidado personal, bebés, nutrición |
| `stockLevel` | Cuántas unidades hay de un producto en una droguería, y el umbral bajo el cual se repone |
| `stockMovement` | Cada entrada o salida: venta, reposición, **préstamo** y devolución de préstamo |
| `replenishmentOrder` | La **reposición**: el pedido a un centro de distribución **o a otra droguería**. Un préstamo entre vecinas es una reposición cuyo origen es una `store` |
| `price` | El precio vigente de un producto en una droguería, con su promoción y, cuando aplica, el **tope regulado** |

> 📝 **Tres precisiones que ahorran discusiones.** El préstamo **no es una entidad nueva**: es una
> `replenishmentOrder` con origen en otra droguería, y sus movimientos son `stockMovement`. El
> **pendiente** —lo que se le debe a un cliente cuando nadie tenía el producto— **es un estado** de
> la compensación de la venta, no una tabla. Y el **tope regulado** es configurable: una regla de
> `pricing` que se enciende o se apaga, porque en la vida real solo aplica a algunos productos y
> en el curso sirve para enseñar configuración, no regulación.

### 8.2 Las palabras del mostrador

**Droguería** (no farmacia, y nunca botica, salvo en el nombre de La Rebotica) · **regente**, quien
está a cargo de la droguería · **mostrador** · **domicilio** y **domiciliario** · **préstamo** y
**traslado** · **el portal**, la tienda en línea, que oficialmente se llama PPVW · **la Braqui**, el
módulo de despachos y flota · **pendiente** · **la vecina**, con minúscula, cualquier droguería de
la red que pueda tener lo que falta · **la circular**, la actualización de precios regulados ·
**afiliado** · **quincena**, cuando la carga se dobla · ***"hoy comemos pizza"***, en sistemas, el
aviso de que viene una noche larga · **el Siga** · **el nodo central**, el Siga de Bucaramanga, del
que dependen todos · **los huérfanos**, los préstamos que quedaron a medias entre dos regiones ·
**el último Excel**, la forma en que la red dice "la versión buena", con ironía · **Alquimia**, la
unidad de I+D de sistemas · **Paracelso**, su proyecto de migración y de producto ·
**Contingencia**, sin artículo, el Siga reducido que opera sin el central (oficialmente SIGA
Contingencia, para Andrés, Asclepio) · **La Rebotica**, el laboratorio en portátiles donde se
construye.

### 8.3 Las palabras de la tierra

Los personajes hablan como hablan. En Santander, **de usted**, incluso entre amigos y con los
hijos; en Boyacá, de **sumercé**. Ninguno tutea al otro, y el curso no los corrige. La narración y
todas las instrucciones al lector siguen en el español neutro del curso, con tuteo.

| Dicho | Qué quiere decir |
|---|---|
| *mano* | compañero, amigo; va al final de casi cualquier frase de Don Aurelio |
| *¡hágale!* | adelante, hazlo |
| *¡ave María!* | sorpresa, para bien o para mal |
| *qué pena con usted* | disculpe; se dice antes de dar una mala noticia |
| *berraco* | difícil, o admirable, según el tono; *"eso está berraco"* es lo primero, *"Valentina es berraca"* lo segundo |
| *de una* | de inmediato, sin discutir |
| *eso es pa' ya* | es urgente |
| *sumercé* | usted, en Boyacá y Cundinamarca, con cariño |

---

## 9. 🧭 Cómo usa el curso esta historia

- **La Fase 00** sale de §1 y §3: las decisiones de Germán, de Luz Marina, de los practicantes del
  portal y de la Braqui son las autopsias, y se escriben con la estructura de la guía §2.1.
  **Autopsia, no juicio:** el Siga estuvo bien diseñado y el texto tiene que dejarlo claro, o pierde
  al lector que construyó exactamente lo mismo. El arco del préstamo entre vecinas —el problema que
  trajo la tecnología a la empresa en 2006 y el que la saca del monolito en 2026— abre el curso, y
  lo recorre en orden: el cuaderno, **el último Excel de la bandeja** (la regla de "gana la última
  escritura", versión 2003), el Siga, el cluster, la copia en espera y la base partida (§1.8). Que
  se vea como un continuo, no como un salto.
- **Las escenas de apertura de cada fase** salen de §6, en la voz de quien tiene el problema.
- **La autopsia de la Fase 12** es la Braqui pegada a las tablas del Siga (§1.9): integrar por la
  base de datos, con su mejor argumento —una sola verdad— y su factura —dos equipos atados a un
  esquema y a un calendario—. Es la que justifica *una base por servicio*, y la que el curso
  contrasta con su propia divergencia declarada: un Postgres, una base y un usuario por servicio.
- **Los encargos del cuaderno de incidentes** los hacen Yolanda (mostrador), Wilson (domicilios),
  Luz Marina (arquitectura) y Valentina (plataforma). El incidente del proxy corporativo lo encarga
  la mesa de ayuda, que es la primera que se entera.
- **Las mediciones** son las que Germán lleva a la asamblea, y se presentan como proporciones con
  la máquina declarada (§7).
- **Los perfiles del generador de caos** de la Fase 22 llevan nombre de ciudad: *"Girón un
  martes"* (todo bien), *"Sogamoso con lluvia"* (latencia alta y cortes), *"Bogotá en quincena"*
  (carga).
- **La saga de la Fase 24** es el préstamo entre vecinas. Sus compensaciones salen de la
  discusión de los fundadores: liberar la reserva en la vecina, reembolsar, o dejar el pedido
  **pendiente** con aviso al cliente. "Siempre llega" no significa "siempre llega ya".
- **El experimento de la Fase 26** son las dos motos.
- **El curso es el proyecto Paracelso**, construido en La Rebotica por la unidad Alquimia (§5). El
  lector trabaja como un integrante más del equipo de Valentina.
- **La Fase 27** es la recomendación que Valentina le entrega a Germán, con la respuesta honesta a
  su pregunta del 14 de octubre y a la de la asamblea: cuánto cuesta y quién lo arregla un domingo.
  El veredicto tiene dos ramas: La Vecina sola, y La Vecina con una segunda cadena (§1.11).
- **El embrión del producto** (§1.10 y §1.11) es un motivo de negocio, no un tema del curso. Entra
  como la cuarta pregunta del encargo y en tres fases: la **Fase 14** instala la plataforma una
  segunda vez, para "la cadena de Don Rodrigo", con otros valores; la **Fase 15** pone cuotas por
  namespace para que una cadena en quincena no le quite la máquina a la otra; y la **Fase 20**
  aísla la red de las dos cadenas. Nada más.
- **La discusión de la nube** (§5) sigue abierta al cerrar el curso, y en dos rondas: la primera,
  dónde poner el Siga (OCI o Azure, y el CRM de Siebel); la segunda, dónde correr un producto, que
  solo existe si Paracelso sale bien. El curso le da el diccionario y la medición, no la respuesta,
  y la Fase 27 deja claro que lo que el laboratorio midió sirve para la segunda ronda más que para
  la primera.
- **El holding de Don Aurelio** (§5.5) es un sueño y no un tema: aparece, como mucho, en la escena
  de cierre de la Fase 27, y nunca como encargo.
- **El patrimonio de arranque** del laboratorio es el de La Rebotica (§5.3): Contingencia, con el
  código del Siga en GlassFish y Postgres, el portal y la Braqui. Corre en **Eclipse GlassFish**
  porque es la línea abierta del servidor donde el Siga nació, y en **Postgres** porque así se
  construyó Contingencia en 2016: el motor del laboratorio no es una concesión del curso, es una
  decisión que la empresa ya tomó, por accidente, hace diez años. Lo que el curso enseña es la
  migración de arquitectura, no la de motor.
- **La autopsia de la elección de Postgres** es la de un comité más lento que las lluvias:
  Andrés no eligió Postgres por convicción, lo eligió porque la evaluación de licencias no llegaba.
  Se cuenta con su mejor argumento y sin heroísmo: funcionó, y nadie lo planeó.
- **La Fase 15 y la Fase 22** tienen su escena en Contingencia: un sistema de respaldo que no se
  prendió porque su regla preguntaba si el Siga contestaba, no si contestaba a tiempo.
- **La Fase 24** lleva el procedimiento del préstamo, que hoy vive en PL/SQL en el central y en
  PL/pgSQL en Contingencia, a una saga entre servicios. Es la única pieza de PL/SQL que Paracelso
  toca, y la toca para sacarla de la base.

> 🧭 **La regla que protege la historia, y es la más importante de este documento.** **Las fechas,
> las cifras, los nombres y las reglas de negocio de este documento no se inventan de nuevo en
> ninguna fase.** Si una fase necesita un dato que no está aquí, se agrega aquí primero, con su
> fecha, y después se usa.
