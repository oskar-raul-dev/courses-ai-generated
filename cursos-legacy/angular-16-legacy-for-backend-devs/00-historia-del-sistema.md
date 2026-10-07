# 🏢 Historia del sistema

> Tutorial Angular 16 — Inspecciones y certificaciones · Ficha de contexto ·
> **Se lee antes de la Fase 0**
> ~30 minutos · No hay código acá: hay motivos. · Vigencia: 2026-10-07.

Este documento cuenta de dónde viene CertCore, el sistema que vas a mantener. No
es decoración narrativa: es la información que en un trabajo real **nadie te da**
y que te pasarías tres semanas reconstruyendo a partir de `git log`, de un correo
reenviado cuatro veces y de gente que ya cambió de proyecto.

> 📝 **Todo lo que sigue es ficción, y a propósito.** Plomada Ingeniería de Inspección
> S.A.S., sus filiales, sus clientes y su gente no existen, y CertCore tampoco. Las
> normas, los entes acreditadores y los husos horarios sí son reales, y están
> citados como son. Inventamos la empresa entera para poder contarte la historia
> completa —con fechas, decisiones y errores incluidos— sin omitir nada. Un caso
> de estudio real siempre viene recortado por un NDA; este viene entero. Y lo que
> es más importante: **el curso construye CertCore pieza por pieza**, así que
> cuando el material diga "esto está así", vas a poder abrir el archivo y verlo.

---

## 1. 🧭 Por qué esto va antes que el código

Hay una pregunta que separa al mantenedor que sirve del que no, y aparece la
primera vez que abres un archivo raro: **¿esto está así a propósito o por
error?**

Sin contexto, no tiene respuesta. En un sistema *viejo* al menos la pista es
obvia: si el código parece de 2015, es de 2015. Pero CertCore no es viejo, es
**migrado**, y ese es otro problema. Vas a abrir dos archivos vecinos, escritos
por el mismo equipo, que resuelven lo mismo de dos maneras distintas y correctas.
Uno inyecta con `constructor`, el otro con `inject()`. Uno declara un componente
en un `NgModule`, el otro es standalone. Ninguno de los dos está mal.

Sin la historia, esa convivencia se lee como desorden y da ganas de "uniformar".
Con la historia se lee como lo que es: **una línea de tiempo**. El archivo de
`constructor` es de 2021 y el de `inject()` es de 2024, y lo que se hace con el
código fechado no es reescribirlo, es tocarlo con cuidado y saber por dónde.

Y hay una segunda pregunta, que esta empresa añade por operar en tres países:
**¿esto vale para Colombia, o para los tres?** Más de una rareza de CertCore es
una regla colombiana que nadie volvió a mirar cuando llegaron Lima y Quito.

Por eso esta ficha va antes que la Fase 0. Léela una vez ahora y vuelve a ella
cuando una decisión del código te parezca inexplicable. Casi siempre está acá.

---

## 2. 🏭 La empresa y la gente que la hizo

### 🛗 Qué hace Plomada, en un párrafo

Plomada Ingeniería de Inspección inspecciona y certifica activos ajenos: sobre todo
ascensores, y también calderas, tanques y sistemas contra incendio. Un cliente
tiene activos; cada activo se inspecciona periódicamente contra una **plantilla
de checklist** que sale de una norma; el inspector va a campo, responde el
checklist, deja evidencia y registra hallazgos; si no hay ningún hallazgo
`critical`, se emite un certificado con vigencia; cuando la vigencia se acerca a
su fin, alguien tiene que llamar al cliente antes de que se venza.

El negocio es mediano y regulado: unas cuatro decenas de inspectores repartidos
en tres países, dos personas en el área de calidad que administran las
plantillas, y en cada país un ente acreditador que audita a la empresa y espera
que el histórico cuadre. Esa parte —la auditoría— explica más decisiones del
sistema que cualquier consideración técnica. Un dato mal guardado acá no es un
bug de interfaz: es un hallazgo de auditoría, y con mala suerte es la
acreditación de una filial.

### 📜 Un mercado que nació de un acuerdo del Concejo

El mercado de Plomada no lo inventó nadie en una reunión de negocios: lo creó
una norma. En 2011 el Concejo de Bogotá expidió el **Acuerdo 470**, que obliga a
los propietarios y administradores de ascensores, escaleras eléctricas, rampas y
puertas eléctricas a hacer una **revisión general anual**, contratada con una
persona natural o jurídica **acreditada por ONAC**, que certifique el
funcionamiento según la norma técnica colombiana que corresponda —para
ascensores, la **NTC 5926-1**—. De la noche a la mañana, miles de copropiedades
necesitaban un certificado que antes nadie les pedía, y había muy pocos
organismos acreditados para darlo.

**Gustavo Pinzón** llevaba catorce años en una firma de mantenimiento de
ascensores cuando salió el acuerdo. Ingeniero mecánico de la Nacional, conocía
cada máquina de tracción de Chapinero por dentro y tenía una agenda llena de
administradores de edificio que lo llamaban por su nombre. Lo que no sabía era
cómo se acredita un organismo de inspección. Eso lo sabía **Claudia Benavides**,
ingeniera industrial y auditora de sistemas de calidad, que había llevado dos
laboratorios por el proceso de acreditación y conocía la ISO/IEC 17020 casi de
memoria. Se conocieron en un seminario sobre el acuerdo, en una sala de hotel
con café de greca, y a la salida Gustavo le dijo la frase que Claudia repite en
cada aniversario: *"Yo sé de ascensores y usted sabe de papeles. Hagamos
plata."*

Fundaron la empresa en 2012 y la acreditación salió en 2013. El nombre lo
propuso Gustavo: la **plomada** es lo primero que saca un técnico para ver si un
hueco de ascensor está a plomo, y a Claudia le gustó porque sonaba a algo que no
miente. El apellido lo puso ella: **Ingeniería de Inspección**, y no
"Certificaciones", porque en 2012 media docena de oficinas nuevas vendían
certificados como quien vende un trámite, y Claudia quería que el nombre dijera
desde la tarjeta que detrás de cada firma había un ingeniero que se subió al
techo de la cabina.

### 🗂️ Los años del Word y la carpeta de red

De 2013 a 2016 Plomada certificó con lo que había. Cada certificado era una
plantilla de Word que el inspector llenaba en la oficina al volver de campo; el
control de vencimientos era una hoja de cálculo compartida, `VENCIMIENTOS
2014.xlsx` y sus descendientes, que **Jeimy Paola Rozo**, la asistente de
calidad, filtraba todos los lunes para llamar a los clientes; y el histórico
vivía en una carpeta de red, `\\SERVIDOR\Calidad\Certificados`, ordenada por año
y por cliente, que nadie se atrevía a reorganizar porque el auditor de ONAC
pedía muestras de ahí.

En Plomada nadie programaba. Los computadores los arreglaba **Wilmer Cubillos**,
un técnico independiente que venía cuando lo llamaban, y "sistemas" era el
correo, la impresora y la carpeta de red.

### 🌎 Por qué tres países: un cliente que no quería tres proveedores

En 2017 entró a la cartera **Aurum Suites**, una cadena de hoteles para
ejecutivos en viaje de negocios: torres de suites con cocineta en los distritos
financieros, estancias de una noche a varias semanas, lavandería, salas de
reuniones, desayuno temprano y transporte al aeropuerto, y la mayoría de las
reservas por convenio con empresas, no por turismo. Tenía dos edificios en
Bogotá y uno en Medellín, y estaba creciendo hacia el sur siguiendo a sus
clientes corporativos. Ascensores, calderas de agua caliente, redes contra
incendio y tanques: una torre de suites tiene los cuatro tipos de activo que
Plomada sabía certificar.

Para Aurum el certificado no era un trámite municipal: era un requisito de
venta. Las multinacionales que alojan a su gente revisan antes de firmar el
convenio que el hotel cumpla las normas de seguridad del país, y la primera
pregunta de su área de viajes es por los ascensores. El gerente de mantenimiento
de la cadena quedó contento con el primer año, y en 2018 hizo la pregunta que
cambió la empresa: *"¿Ustedes me pueden certificar también Lima? Yo no quiero un proveedor
por país."*

Claudia dijo que sí antes de saber cómo, y después averiguó lo que eso
significaba: **una acreditación no viaja.** En Perú el certificado tiene que
salir de un organismo de inspección acreditado por **INACAL**, y en Ecuador por
el **SAE**, el Servicio de Acreditación Ecuatoriano. Cada país tiene su norma, su ente, su
periodicidad y su autoridad local que verifica. Abrir una oficina no alcanza:
hace falta una empresa local acreditada.

La salida fue la de casi todas las expansiones de la región: **una compra por
contactos.** Gustavo había conocido en un congreso de mantenimiento en Lima a
**Jorge Salazar**, ingeniero mecánico-electricista, dueño de una pequeña
firma acreditada en Miraflores con cinco inspectores, *Inspecciones Rímac
S.A.C.* Jorge quería crecer y no tenía clientes corporativos; Plomada tenía el
cliente y no tenía la acreditación. En 2019 Plomada compró la mayoría de la
firma, que pasó a llamarse **Plomada Perú S.A.C.**, y Jorge se quedó como
gerente.

Ecuador llegó en 2021, otra vez detrás de Aurum Suites, que abría una torre
en Quito, cerca de la avenida Amazonas, y otra en Guayaquil. Esta vez no hubo
compra: **Patricio Villacís**, inspector quiteño que llevaba años en la filial de una certificadora europea, aceptó
montar **Plomada Ecuador Cía. Ltda.** como socio local, con tres inspectores y
un proceso de acreditación que tomó casi un año.

El SAE acredita a los organismos de inspección contra la **NTE INEN ISO/IEC
17020**, la misma ISO/IEC 17020 que Claudia conocía de Bogotá, adoptada como
norma ecuatoriana. Hasta 2014 se llamaba **OAE**, Organismo de Acreditación
Ecuatoriano: lo creó la Ley del Sistema Ecuatoriano de la Calidad en 2007, y el
Decreto Ejecutivo 338 de 2014 le cambió el nombre. Patricio lo aprendió en su
primera semana: los organismos acreditados antes del cambio siguen teniendo
códigos que empiezan por `OAE OI`, y los nuevos por `SAE OI`. *"Es la misma
institución con dos nombres, y los dos van a aparecer en los papeles."* A
Plomada Ecuador le tocó el nuevo. Quien mantenga un sistema con datos de
acreditación va a ver los dos.

### 🏝️ El piloto de Galápagos (2024)

En 2024 Aurum Suites probó algo que no era su negocio de siempre. Sus
clientes corporativos le pedían cada vez más un lugar para el evento que viene
con premio: la convención anual de la fuerza de ventas de un laboratorio
farmacéutico, con el lanzamiento interno de un producto y un día libre para
bucear; el viaje de incentivo de los mejores distribuidores de una aseguradora.

Galápagos era el destino que todos pedían, y Aurum no podía construir ahí. La
Ley Orgánica de Régimen Especial de la Provincia de Galápagos, de 2015, reserva
la autorización de nueva infraestructura turística a los **residentes
permanentes** de las islas. Así que hizo lo que se hace allá: un contrato de
operación con la familia Chiriboga, residentes de Puerto Ayora, dueña de una
hostería de tres estrellas con veinte habitaciones y un salón para eventos. La
hostería pasó a llamarse **Aurum Inn Galápagos**, como piloto de un concepto
de convenciones con turismo. Aurum pone la marca, los convenios corporativos
y el estándar de servicio; el edificio, el permiso y el RUC siguen siendo de
*Hostería Chiriboga Cía. Ltda.*

Para Plomada eso trajo un cliente que no es Aurum, aunque el contrato lo
negoció Aurum: la empresa de la familia, con su propio RUC de trece dígitos.
Y trajo una pregunta que Patricio hizo en la primera reunión: *"¿Y allá qué
certificamos? Si no hay ascensor."* No lo hay: la hostería tiene dos pisos y
nunca lo necesitó. Y ninguna norma de las islas le pide a nadie una
inspección de tercero para una caldera de agua caliente o para una red contra
incendio: el permiso anual lo da el cuerpo de bomberos con su propia visita.

Lo que la pide es el contrato, y no es la primera vez. Con Aurum el
certificado nunca fue un trámite municipal sino un requisito de venta (§2, *Por
qué tres países*), y el piloto lo llevó al extremo. El **estándar de marca** de
Aurum exige en todas sus propiedades una certificación anual, hecha por un
organismo acreditado, de los activos de seguridad de vida —calderas, redes contra
incendio, tanques de agua, ascensores donde los haya—, sin importar lo que pida
la ley local. Lo exige porque se lo exigen a ella: el área de cumplimiento del
laboratorio que lleva ochenta vendedores a una convención en una isla pide el
certificado antes de firmar, y la aseguradora del evento también. En Bogotá el
certificado del ascensor lo pide el Acuerdo 470; en Puerto Ayora, el anexo de un
contrato corporativo.

Por eso en Galápagos no hay plantilla de ascensores: hay `boiler-annual-ec`, la de
redes contra incendio y la de tanques, y una logística propia. Una vez al año, dos
inspectores de Guayaquil vuelan a Baltra, cruzan a Santa Cruz y certifican todo
en un solo viaje: la caldera, la red contra incendio y los tanques de agua dulce,
que en una isla donde el agua potable es escasa son el activo que más le
preocupa a la familia Chiriboga. El viaje se planea con dos meses de
anticipación, así que nadie quiere repetirlo por un certificado mal emitido.

Con el piloto llegó también a CertCore **el primer activo fuera de UTC−5**. El
sistema llevaba años dando por hecho que todos sus activos compartían reloj, y
ese supuesto es de 2022, dos años más viejo que la isla.

> 🧠 **Tres países, tres normas, un solo sistema.** Plomada no es una empresa
> colombiana con sucursales: son tres empresas acreditadas por tres entes
> distintos, que comparten clientes, gente y —desde 2016— una sola base de datos.
> Casi todo lo que vas a encontrar raro en CertCore viene de esa última parte.

---

## 3. 🕰️ Las eras del código

CertCore no lo escribió una persona con un plan. Lo escribieron tres equipos en
cuatro años, cada uno resolviendo el problema que tenía delante con las
herramientas de su momento. Las capas se ven a simple vista cuando sabes qué
buscar.

Antes de esos tres equipos hay una cuarta capa que no es Angular y que casi nunca
se cuenta: **la API contra la que la aplicación habla, que es cinco años más vieja
que ella**. Empezamos por ahí, porque explica la mitad de las rarezas del
contrato.

### 🗄️ Era 0 (2016-2018) — `certcore-api`, la que ya estaba

En 2016 Plomada certificaba unos cuatrocientos activos al año, y la hoja de
vencimientos ya no daba: dos clientes se enteraron de que su certificado había
vencido por una visita del IDIGER, la entidad del distrito que verifica la
revisión anual, y uno de ellos se fue. Claudia decidió digitalizar la emisión de
certificados, y como en la empresa nadie programaba, buscó entre sus contactos.

Le llegó **Wilson Arévalo**, ingeniero de sistemas, ocho años en el área de
desarrollo de un banco, que acababa de renunciar para lanzarse como consultor
independiente. Empezó en septiembre de 2016, y Plomada iba a ser su primer
cliente. Wilson venía del mundo
**.NET**, con algo de PHP de proyectos propios, y lo natural habría sido hacerlo
en lo que sabía. No lo hizo, y la razón fue la cuenta: en 2016, .NET en una
empresa significaba Windows Server y, como en el banco, SQL Server, licencias
que una firma de quince personas no iba a pagar por un servicio. El .NET que
corría en Linux, .NET Core 1.0, había salido en junio de ese año y nadie lo
ponía todavía en producción. Un servidor Linux con PHP costaba una fracción, y
PostgreSQL no cobraba licencia. *"Si la idea es ahorrar, lo hago en PHP, que
eso lo corre cualquier hosting."*

En ese momento **Lumen era "Laravel pero rápido, para servicios"**: PHP 7
acababa de doblar el rendimiento, los microservicios estaban en su pico, y para
alguien que venía de ASP.NET Web API, un microframework que solo sabía de rutas
y de JSON era lo más parecido a lo que conocía. Wilson eligió Lumen **para un
servicio** —emitir el certificado y guardarlo— y para ese servicio fue un acierto
que se cobró durante años.

Lo que pasó después es el pecado de este sistema, y no se parece a una estupidez:
**todo lo demás se fue colgando de ahí y nadie volvió a decidir nunca**. Los
clientes, los activos, las plantillas, las inspecciones y los hallazgos entraron
al mismo servicio uno tras otro, cada uno con una prisa distinta. Y en 2019 entró
**un país entero**: los clientes y activos de Lima se cargaron en la misma base,
con la misma estructura, por un script que corrió una noche. Nadie se sentó a
preguntar si un modelo pensado para Bogotá servía para Lima. Funcionó, así que no
hizo falta.

La base de datos salió del mismo momento: **PostgreSQL, contratado como servicio
gestionado**. Y ahí aparece la asimetría que ordena media historia del sistema:

> 🧠 **A la infraestructura la actualizan; a la aplicación no.** La base tenía
> dueño —un proveedor con calendario propio, y unas auditorías de acreditación
> que exigen correr sobre versiones soportadas—. El código no tenía ninguno. El
> proveedor subió la versión cuatro veces en ocho años, cada una en su ventana de
> mantenimiento y cada una anunciada por un correo que alguien archivó. La
> aplicación no se movió nunca.

Con una ironía que el dominio pone gratis: fue una **auditoría de cumplimiento**
la que forzó las subidas. *La certificadora no pasaba su propia auditoría.*

Y hay un detalle de plantilla que importa tanto como el técnico. El mercado de
devs **PHP** es enorme; el de devs **Lumen** no existe. Después de Wilson, todos
los que pasaron por `certcore-api` llegaron reciclados de otro sitio —de Laravel,
de Symfony, de CakePHP—, se formaron a costa de la empresa, y no duraron más de año y
medio, porque nadie quiere "Lumen 2018" en su CV. **El código tiene estratos por
procedencia, no solo por fecha.**

Cómo llegaban también importa. Wilson nunca fue de planta: facturaba como
independiente, por **prestación de servicios**. En marzo de 2018 se fue detrás de un
contrato más grande, con su antiguo banco, y dejó la API con un README y un mes
de respuestas por correo. Para reemplazarlo, Claudia armó lo más parecido a una
licitación que una empresa de ese tamaño puede armar: pidió propuestas a **dos
consultoras pequeñas** de Bogotá, porque las grandes —las que les venden a bancos
y ministerios— cotizaban en otro orden de magnitud.

Se presentaron **Teusacá Software**, una docena de personas, con una bolsa de
horas mensual para mantener la API tal como estaba, y **Sabana Labs**, unas
veinte, que propuso reescribirla en Laravel antes de seguir. Ganó la bolsa de
horas: era más barata y no tocaba nada que funcionara.

Teusacá no asignó un equipo: asignó a quien tuviera libre ese mes. Dos se
quedaron lo suficiente para dejar huella; los demás pasaron por una semana y un
ticket. Así llegaron
los dos que siguieron, cada uno con los reflejos de su proyecto anterior:

- **Ferney Castillo** (abril de 2018 a septiembre de 2019), de Laravel, que dejó la mitad del código
  actual y la última subida de Lumen, hasta que la consultora lo movió a un
  cliente más grande.
- **Fernando Rubio** (enero de 2020 a junio de 2021), de CakePHP, el que más años llevaba en el
  oficio, que escribió el módulo de plantillas y certificados con las
  convenciones de tabla que traía puestas.

A mediados de 2023, ya con una gerencia de sistemas, Plomada dejó de pagar la
bolsa de horas y contrató directamente a una freelance:

- **Tatiana Fernández** (julio de 2023 a diciembre de 2024), de Symfony, limeña, que trabajaba remoto y
  llegó recomendada por Jorge. Empezó una reescritura ordenada y no alcanzó a
  terminarla.

Ninguno duró más de dieciocho meses, y ninguno tuvo a quién preguntarle, porque
el anterior ya no estaba. Cada uno
recibió un acceso al repositorio, una contraseña de la base y una lista de
pendientes.

> 🧠 **Durante seis años Plomada no tuvo un equipo de software: tuvo
> proveedores.** Un independiente, dos consultoras pequeñas y una freelance,
> cada uno contratado para lo que hacía falta ese trimestre. Ninguno estaba ahí para revisar lo que
> había dejado el anterior, y nadie lo hizo.

> 🧠 **CertCore, la aplicación, nació en 2021. `certcore-api`, contra la que
> habla, es de 2016 y nadie la revisó nunca.**

Eso explica de una sola vez cuatro cosas que vas a encontrar en el curso y que,
sin esta historia, parecen caprichos: que el contrato devuelva **el objeto
completo, sin paginar** (en 2016 había doce inspecciones en la base); que el
`status` del certificado venga **guardado como dato** en vez de calculado; que
las plantillas versionadas se identifiquen con un `id` compuesto que nadie
diseñó, sino que fue quedando; y que la pantalla de clientes **haya nacido
pensando en el NIT**, aunque hoy un tercio de los clientes tenga RUC.

En este curso **no tocas la API**: en la Fase 3 construyes un mock que la imita, y
con eso alcanza para todo lo demás. Pero cuando una fase diga *"esto se arregla
del otro lado"*, ya sabes de qué otro lado habla — y de qué año.

### 🪨 Era 1 (2021) — "que salga el piloto con dos clientes"

En 2021 Plomada tenía Bogotá, Lima y Ecuador arrancando, y un problema que la
API sola no resolvía: los inspectores seguían llenando el checklist en papel o en
un Excel en el celular, y alguien en la oficina lo transcribía después. En Lima
esa persona era Jorge, los sábados. Claudia, ya gerente general, pidió una
aplicación para el inspector en campo y para calidad, y la pidió para el
trimestre. El piloto sería con dos clientes reales: **Aurum Suites**, porque
era el cliente de los tres países, y **la Clínica del Norte**, en Bogotá, porque
su jefe de mantenimiento se ofreció a probar.

Para eso no alcanzaba la bolsa de horas: había que hacer una aplicación entera
en un trimestre, y Teusacá no tenía gente de frontend. Claudia volvió a llamar a
**Sabana Labs**, la consultora que había perdido en 2018, que esta vez ofreció
el piloto **a precio fijo y en dieciséis semanas**, con noventa días de
garantía. Sabana Labs puso un
equipo de tres: **Diego Moncada**, el líder técnico, y **Jimena Galeano**, los dos
de Bogotá, y **Renzo Chávez**, un dev limeño que la consultora había contratado
remoto durante la pandemia y que venía de una software house donde todo el
código se escribía en inglés. De él viene la convención que vas a ver todo el
curso: **código en inglés, interfaz en español.**

El precio fijo explica más del código que cualquier decisión técnica. Cuando el
cronograma se apretó, en la semana diez, lo que salió del alcance fue lo que el
cliente no veía en la demo. La entrega fue un repositorio, un README de dos
páginas y una reunión de dos horas por videollamada.

El piloto salió en tiempo, además, porque **había una API esperándola**: nadie tuvo que diseñar el modelo, solo consumirlo. Angular
12 era lo estable de entonces y todo se hizo como Angular documentaba en 2021:
**`AppModule`, `CoreModule`, `SharedModule`, un módulo por feature con
`RouterModule.forChild`, componentes declarados en `declarations`, e inyección por
`constructor`**. Guards e interceptors de clase, con `@Injectable()` y
`HTTP_INTERCEPTORS`.

Una cosa la hicieron bien casi sin querer: el CLI 12 ya generaba proyectos con
`strict: true` y **nadie lo apagó**. Suena menor y no lo es. Media docena de bugs
que en otros sistemas viven años escondidos —el `null` que se coló como
`undefined`, el campo opcional que en realidad significaba otra cosa— acá el
compilador los pone sobre la mesa.

Lo que quedó de esa era y sigue vivo: la estructura de módulos, la autenticación
con el token en `localStorage`, y el `SharedModule` que reexporta media librería
de Angular Material "por comodidad" porque así nadie tenía que pensar qué
importar. Esa comodidad tiene precio y lo vas a pagar tú, en la Fase 5, con el
bundle medido antes y después.

Lo que se hizo mal: cero pruebas. Ni una. El piloto tenía fecha y precio fijo,
y las pruebas siempre son lo primero que se recorta.

> 🧠 **Lo que te llevas de esta era.** Cuando veas un `NgModule` con
> `declarations` y un `constructor(private readonly http: HttpClient)`, no estás
> viendo a alguien anticuado: estás viendo 2021. El apéndice **A04** es el
> traductor entre las dos formas de inyectar, y **A07** explica por qué el estado
> quedó donde quedó.

### 🏢 Entre eras (2022) — "esto ya no es una oficina, es una empresa"

Con Ecuador abierto, Plomada tenía tres países, casi cuarenta inspectores y la
misma forma de una oficina de quince personas. Claudia era gerente general, jefa
de calidad de hecho y la que aprobaba la compra de cada computador; los
celulares de los inspectores los configuraba Wilmer cuando podía; y el software
de la empresa estaba repartido entre una bolsa de horas en Teusacá y un piloto
que Sabana Labs cobraba por hora cada vez que alguien pedía un cambio. A
finales de 2021 Claudia contrató a una firma de consultoría organizacional, que
en cuatro meses de entrevistas y talleres entregó lo que se entrega en esos
casos: un organigrama, un manual de funciones y la recomendación de crear áreas
que hasta entonces eran personas.

Una de esas áreas no existía en absoluto: la **gerencia de sistemas**, con dos
departamentos debajo. **Soporte técnico** —redes, equipos, licencias, los
celulares de campo, la mesa de ayuda— quedó a cargo de Wilmer, que pasó de
técnico independiente a jefe de soporte de planta. **Desarrollo** quedó para el
software. La gerencia, en cambio, no tenía a quién, y Claudia hizo la llamada
que nadie esperaba: a **Wilson Arévalo**.

Wilson ya tenía una consultoría con varios clientes y no quería volver a un
cargo. Aceptó ser **gerente de sistemas encargado, por horas y por seis meses**:
organizar el área, escribir sus reglas y dejar contratado a quien se quedara.
Hizo lo que había aprendido en ocho años de banco:

- **Armó el departamento de desarrollo con los que ya conocían el sistema.**
  Les ofreció a Diego y a Jimena pasar de Sabana Labs a Plomada, de planta. El
  contrato con la consultora tenía una cláusula de no contratación de doce
  meses, y se resolvió como se resuelven esas cláusulas cuando las dos partes se
  conocen: Plomada pagó el equivalente a dos meses de cada uno, y Sabana Labs se
  quedó con un cliente agradecido, que es lo que una consultora pequeña quiere:
  que la vuelvan a llamar. Renzo siguió en la consultora y salió del proyecto.
- **Escribió las prácticas del departamento**, en un documento de seis páginas
  que todavía está en la carpeta compartida: un repositorio por sistema, ramas
  y tags por versión, dos ambientes —UAT y producción— y nada en producción que
  no haya pasado por UAT, los pedidos por un tablero de tickets y no por correo,
  y despliegues los martes. Las **pruebas automatizadas** quedaron en la lista
  como "siguiente etapa", y la siguiente etapa no llegó.
- **Separó las dos cosas que la empresa llamaba "sistemas".** Un ticket de
  impresora va a soporte; un ticket de CertCore va a desarrollo. Parece obvio, y
  hasta entonces los dos llegaban al mismo correo.

Y dejó una cosa fuera, a propósito. Su contrato decía *organizar el área*, no
*revisar la API*. Wilson abrió `certcore-api`, reconoció su código de 2016 debajo
de lo que habían agregado Ferney y Fernando, y escribió en el acta de entrega una
línea que vas a encontrar citada más de una vez: *"certcore-api funciona; no se
toca sin un plan"*. La bolsa de horas de Teusacá siguió.

> 🧠 **El único que podía revisar la decisión de 2016 volvió en 2022, y no la
> revisó.** No por descuido: su mandato era la estructura, sus horas eran pocas
> y la API funcionaba. Así se ve la ausencia de revisión desde adentro: nadie la
> evita, porque a nadie le toca.

En 2023 la gerencia pasó a alguien de planta: **Hernando Gil**, que venía de la
gerencia de sistemas de una aseguradora. Hernando heredó el documento de Wilson
y lo cumplió casi entero. A mediados de ese año canceló la bolsa de horas de
Teusacá y contrató a Tatiana para la API. Es quien hoy recibe los tickets que no
son de nadie, quien firma las contrataciones y quien sigue llamando a Sabana Labs
cuando quiere una opinión de afuera.

### 🧱 Era 2 (2022-2023) — "cambió la norma, y va a volver a cambiar"

El piloto funcionó, entraron clientes, y con ellos llegó el problema que define
al sistema: **la norma cambia, y cambia en un país a la vez**. Los ítems del
checklist de ascensores dejaron de ser los mismos, y alguien preguntó lo correcto
en el momento correcto: *¿qué pasa con las inspecciones que ya hicimos?*

Quien lo preguntó fue Jorge, desde Lima, y no por teoría. En Perú las
instalaciones de transporte mecánico se rigen por la **Norma EM.070** del
Reglamento Nacional de Edificaciones, que exige demostrar ante la autoridad local
el mantenimiento con un certificado de inspección anual, y que la municipalidad
verifica en la **Inspección Técnica de Seguridad en Edificaciones**. En Ecuador
los ascensores tienen su propio reglamento técnico, el **RTE INEN 095**. Tres
países, tres normas, tres calendarios de cambio. Cuando calidad en Bogotá
actualizaba el checklist colombiano, el de Lima seguía siendo el viejo, y una
inspección hecha con una versión no podía mostrarse con la otra.

La respuesta a esa pregunta es el corazón de CertCore. Se decidió que **las
plantillas se versionan**: cuando cambia la norma nace una v2 con su `validFrom`,
la v1 queda intacta, y cada inspección guarda el `templateVersion` con el que se
ejecutó. De ahí sale el invariante que el curso repite hasta el cansancio:

> 🧭 **Una inspección se lee siempre con la versión de plantilla con la que se
> ejecutó. Siempre. Aunque haya una versión más nueva y aunque la nueva sea "la
> correcta".**

El motor que resuelve esa regla lo escribió una sola persona, **Jimena Galeano**,
la del piloto, en un par de semanas intensas de finales de 2022, y Jimena se fue
a una fintech en 2023. Funciona. Está poco documentado. Y es la fuente de
aproximadamente la mitad de los tickets que vas a ver, porque la regla se enuncia
en una línea y se rompe de seis maneras distintas. Por eso la Fase 7 es la más
pesada del curso ⭐.

Esta era también fijó dónde vive el estado. Con cuatro pantallas necesitando
saber qué plantilla está vigente, el equipo evaluó NgRx y dijo que no: dos
personas, un dominio chico, y una librería que exige ceremonia. Se quedaron con
**servicios inyectables con un `BehaviorSubject` privado y un `Observable`
público**, que es la decisión más común del ecosistema Angular y también la que
más fugas de suscripción produce. No fue una mala decisión. Fue una decisión con
un costo que se paga en suscripciones que nadie cierra, y ese costo lo vas a
cazar tú (Fase 4 y su pieza forense).

### 🔀 Era 3 (2024) — "hay que migrar antes de que se nos caiga"

Angular 12 salió de soporte, y Aurum Suites, que en 2023 había firmado un
contrato regional de tres años, pidió en su revisión anual de proveedores el
reporte de vulnerabilidades de las dependencias. La migración dejó de ser
opcional. La lideró **Diego Moncada**, ya de planta, con un freelance contratado
por tres meses para los estilos que rompió Material, y se hizo el camino largo, salto por salto —13, 14, 15, 16— con `ng update`, en cuatro tandas,
a lo largo de 2024. Terminó en **Angular 16.2.12**, que es donde está el sistema
hoy.

Tres cosas de esa migración te van a aparecer en la cara:

- **Material 15 trajo MDC.** Los componentes se llaman igual y por dentro son
  otros. Se rompieron estilos que nadie había tocado, y algunos se arreglaron con
  parches de CSS que siguen ahí. Cualquier artículo de Material anterior a 2023
  describe un componente distinto con el mismo nombre (**A01**).
- **Angular 14 trajo formularios tipados**, y la migración automática los dejó a
  medias: mucho `FormControl<string | null>` donde el `null` no significa nada y
  nadie puso `nonNullable`. Con `strict` activo, eso se nota (**A05**).
- **Angular 16 trajo standalone estable**, y con él la decisión que define este
  track: **no se migró nada, pero todo lo nuevo se escribe standalone.**

Esa última decisión merece un párrafo, porque es la que más te va a confundir y
la que más razón tenía. Migrar cuarenta componentes que funcionan, sin una sola
prueba que te avise si rompiste algo, para ganar consistencia estética, es gastar
riesgo sin comprar nada. Así que la regla del proyecto quedó escrita en el
README y es la que rige todo el curso:

> 🧭 **Código nuevo, estilo nuevo. Código heredado, se toca lo mínimo y en su
> propio estilo.** Y el corolario, que es lo que de verdad te llevas: mezclar los
> dos estilos dentro de un mismo archivo es peor que cualquiera de los dos
> estilos puros.

Los sitios donde las dos generaciones se tocan —un standalone importado desde un
`NgModule`, un interceptor funcional corriendo junto a uno de clase— van marcados
en todo el material con 🧬. Es el marcador que más vas a buscar con `Ctrl+F`.

### 🧊 Hoy — mantenimiento, en tres países

Desde que terminó la migración casi no entran features. Entran **cambios
normativos de tres países, requerimientos de tres entes acreditadores y
hotfixes**. La aplicación se despliega como un contenedor con nginx delante, y
arrastra una fricción que no es culpa de Angular sino de cómo se construyen las
SPAs: **la configuración se hornea en tiempo de compilación y el contenedor
querría inyectarla en tiempo de arranque**. Ahí nace la mitad de los "funciona en
UAT y no en PROD" del sistema, y ahí termina el curso (Fase 13).

Nadie va a subir a Angular 17 este año. La razón es la única razón honesta que
existe: **funciona, está auditado en tres países, y no hay presupuesto para
arriesgarse a que deje de funcionar.**

---

## 4. 🔥 El ticket que te trajo

En febrero de 2025, la auditora regional de Aurum Suites, que trabaja desde
Quito y audita las torres de los tres países, pidió el histórico de un ascensor
de la torre de Bogotá: la inspección de 2023 y la de 2024. La
de 2024 salió bien. La de 2023 apareció en pantalla con un ítem en blanco,
*"Iluminación de cabina y de emergencia"*, sin respuesta, y la auditora anotó en
su informe *"inspección incompleta"*.

La inspección no estaba incompleta. Ese ítem no existía cuando se hizo: llegó con
la versión 2 de la plantilla colombiana, en 2024. Jeimy Paola lo explicó por teléfono, mandó un
PDF de 2023 escaneado y un correo largo, y la observación se levantó. Pero en el
comité del lunes Claudia hizo la pregunta que nadie supo contestar: *"¿Cuántas
pantallas más nos muestran una inspección vieja con la plantilla nueva?"*

Nadie sabía. Diego estaba asignado al portal de clientes y respondía cuando
podía, Jimena se había ido hacía dos años, y Tatiana, la freelance de la API,
había terminado su contrato en diciembre sin que nadie la reemplazara. Hernando
llevó al comité un número que había sacado él mismo: cuatro personas habían
pasado por la API en ocho años, y cada una había empezado de cero. Esa semana se
abrió, por primera vez, un **cargo de planta con proceso de selección** para
sostener las dos capas. Es la vacante a la que respondiste.

---

## 5. 🔎 Quién dejó qué (y qué sabemos de por qué)

En un sistema real esto se reconstruye leyendo `git blame` y preguntando en
Slack. Acá te lo damos hecho:

- **El `SharedModule` reexporta media librería de Material.** Fue comodidad de
  2021 y funcionó durante tres años. Hoy significa que un módulo que usa un botón
  arrastra veinte componentes al bundle. Se paga en la Fase 5 💸, y es el primer
  sitio donde vas a ver una deuda cobrarse con números.

- **El estado vive en servicios con `BehaviorSubject`, sin librería.** Decisión
  deliberada de 2022, con NgRx evaluado y descartado por tamaño de equipo. No es
  ignorancia: es una decisión de escala. Lo que costó está en la Fase 4 y en
  **A07**, que además explica qué resolvería NgRx y por qué aquí no está.

- **El token vive en `localStorage` y no hay refresh token.** Decisión de 2021,
  cuando "auth" significaba un endpoint que devuelve un JWT. Está mal por
  seguridad, está documentado como tal en la Fase 2, y no se arregla en este
  curso porque arreglarlo de verdad es trabajo de backend.

- **El motor de plantillas versionadas lo escribió Jimena, que ya no está.** Es
  la pieza más importante y la peor documentada, en ese orden y por esa razón:
  quien la escribió tenía el modelo completo en la cabeza y no le hizo falta
  escribirlo. Cuando termines la Fase 7 vas a tener ese modelo tú.

- **Las plantillas de los tres países las administra calidad, en Bogotá.** Dos
  personas, Jeimy Paola y un analista, cargan los checklists de Colombia, Perú y
  Ecuador a partir de lo que les mandan Jorge y Patricio por correo. Es la forma
  más barata de tener un solo dueño de las plantillas y también la razón de que
  la plantilla peruana a veces llegue tarde.

- **Los formularios de inspección se construyen en runtime desde datos.** No hay
  un formulario de ascensores y otro de calderas: hay un `FormGroup` armado a
  partir de los ítems de la plantilla. Es la decisión correcta —con tres normas
  cambiando a su propio ritmo, cada cambio normativo sería un release— y también
  la más difícil de depurar del sistema entero. Fase 8 ⭐.

- **Las fechas llevan zona horaria explícita en todas partes, y es siempre
  `-05:00`.** Esto fue una cicatriz: hubo un certificado que "venció ayer" para el
  servidor y "vence hoy" para el usuario, en pleno cierre de mes. Desde entonces,
  `-05:00` explícito hasta en el `db.json`, y nada de `new Date()` suelto donde
  importe el día. Que un solo desfase sirva para tres países no fue una decisión:
  fue **suerte**. Bogotá, Lima, Quito y Guayaquil están todas en UTC−5 y ninguna
  cambia la hora en el año, así que el atajo nunca falló. La única costura que
  nadie ha mirado está en las islas: **Galápagos va en UTC−6**, y desde 2024
  CertCore certifica los activos de Aurum Inn Galápagos, en Puerto Ayora.

- **La interfaz es monolingüe en español, con los textos literales en la
  plantilla.** No hay i18n ni claves de traducción, y no fue un olvido: los tres
  países hablan español y cada auditoría es local. El código, en cambio, está en
  inglés, por Renzo y la convención que trajo. Es una mezcla rara y es la que vas
  a ver todo el curso.

- **El "modo caos" del mock no existe en producción.** Este es el único
  componente que no es herencia: lo construyes tú en la Fase 3. En producción el
  caos viene gratis y sin avisar, un martes a las cuatro. Acá lo hacemos
  reproducible porque el objetivo es entrenar el ojo, no sufrir al azar.

---

## 6. 🕳️ Lo que el sistema NO tiene

Tan importante como lo que hay. Si buscas alguna de estas cosas, no las vas a
encontrar, y no es que no las hayas visto todavía.

No hay librería de store. No hay pruebas hasta que las escribas tú (Fase 12). No
hay i18n. No hay signals: en Angular 16 son experimentales y CertCore no los usa.
No hay control flow `@if/@for`, que llegó con la 17. No hay backend en este
repositorio: `certcore-api` existe, es de 2016 y está descrita arriba, pero lo que
tú levantas es un mock que la imita (Fase 3). No hay refresh token, no hay firma
digital real en el PDF, no hay offline-first con service workers, no hay pruebas
end-to-end, y no hay observabilidad más allá de la consola del navegador.

Y tampoco hay **país como concepto de primera clase**. Ninguna pantalla te deja
filtrar por filial, el PDF del certificado dice lo mismo en Lima que en Bogotá
—la filial peruana le agrega a mano el sello y la referencia a su acreditación—,
y la zona horaria no es un dato del activo sino una constante del código.

Y hay algo que CertCore sí tiene y el curso no construye: **los cuarenta y pico
de componentes de las eras 1 y 2 que nadie migró**. Acá vas a escribir unos
pocos, y el reflejo que te llevas es exactamente ese — no tocar los otros sin un
motivo escrito.

Esa lista es, palabra por palabra, el backlog técnico eterno de miles de sistemas
reales. Que te resulte familiar es el punto.

---

## 7. 👥 La gente

| Personaje | Rol | Cómo habla | Qué quiere | Aparece en |
|---|---|---|---|---|
| **Claudia Benavides**, 54 | cofundadora y gerente general; viene de auditoría de calidad | precisa, cita la cláusula de la norma de memoria | que ninguna auditoría encuentre algo que ella no encontró antes | apertura del curso; F07, F10, F12 |
| **Gustavo Pinzón**, 61 | cofundador y director técnico de inspección | de taller, con ejemplos de máquinas que conoce por dentro | que el checklist pregunte lo que de verdad hace caer un ascensor | F07, F08, F09 |
| **Jeimy Paola Rozo**, 36 | asistente y luego coordinadora de calidad desde 2013; administra las plantillas de los tres países | ordenada, todo por correo y con copia | que el sistema le avise los vencimientos antes que el cliente | F07, F10, F11 |
| **Jorge Salazar**, 50 | gerente de Plomada Perú desde 2019; antes dueño de Inspecciones Rímac | cordial y directo, mide todo en horas de inspector | que Lima deje de ser "la sucursal" en las reuniones | F07, F09, cuaderno |
| **Patricio Villacís**, 44 | socio local y gerente de Plomada Ecuador desde 2021 | calmado, explica dos veces | que la acreditación ecuatoriana no dependa de un correo a Bogotá | §4, F10, cuaderno |
| **Wilson Arévalo** | consultor independiente, ex desarrollador .NET de un banco; escribió `certcore-api` en 2016, en PHP por costos, y salió en 2018; volvió en 2022 como gerente de sistemas encargado, por seis meses | no aparece: aparecen su código y su acta de entrega | — | Era 0, entre eras, track BE |
| **Wilmer Cubillos** | técnico independiente desde 2014; jefe de soporte técnico de planta desde 2022 | práctico, todo lo resuelve "reiniciando primero" | que no le lleguen tickets de CertCore | entre eras; F13 |
| **Hernando Gil** | gerente de sistemas desde 2023; venía de la gerencia de sistemas de una aseguradora | en reuniones, con una diapositiva | que el sistema deje de depender de una sola persona | §4, F12, F13, be07, be-12 |
| **Diego Moncada** | líder técnico del piloto en Sabana Labs (2021), de planta desde 2022, líder de la migración (2024); hoy asignado al portal de clientes | rápido, contesta con un audio | que no lo saquen del portal | F01, F05, F13 |
| **Jimena Galeano** | dev del piloto en Sabana Labs, de planta desde 2022; escribió el motor de plantillas a finales de 2022; se fue a una fintech en 2023 | no aparece: aparece su código | — | F07, F08 |
| **Renzo Chávez** | dev limeño de Sabana Labs en el piloto; trajo la convención del código en inglés; se quedó en la consultora | — | — | F01 |
| **Ferney Castillo**, **Fernando Rubio** | devs de Teusacá Software asignados a la API (Laravel, CakePHP) | no aparecen: aparecen sus parcelas | — | track BE (be02) |
| **Tatiana Fernández** | freelance limeña de la API (Symfony), 2023–2024 | no aparece: aparece su reescritura a medias | — | track BE (be02, be06) |
| **Teusacá Software** | consultora bogotana pequeña; ganó en 2018 la bolsa de horas de la API | — | — | Era 0 |
| **Sabana Labs** | consultora bogotana pequeña; perdió en 2018, hizo el piloto en 2021 a precio fijo | — | — | Era 1; be-12 |
| **Tú** | dev senior de backend, nuevo en el equipo de mantenimiento | — | sobrevivir al lunes | todo |

---

## 8. 🌎 Los tres países

| | Colombia | Perú | Ecuador |
|---|---|---|---|
| **Empresa** | Plomada Ingeniería de Inspección S.A.S. (matriz, Bogotá) | Plomada Perú S.A.C. (Miraflores, Lima) | Plomada Ecuador Cía. Ltda. (Quito; inspectores también en Guayaquil) |
| **Desde** | 2012; acreditada en 2013 | 2019, por compra de Inspecciones Rímac | 2021, con socio local |
| **Ente acreditador** | ONAC | INACAL | SAE (Servicio de Acreditación Ecuatoriano; OAE hasta 2014) |
| **Norma de acreditación** | ISO/IEC 17020 | NTP-ISO/IEC 17020 | NTE INEN ISO/IEC 17020 |
| **Norma de ascensores** | NTC 5926-1 (Acuerdo 470 de 2011 en Bogotá) | Norma EM.070 del RNE | RTE INEN 095 |
| **Quién verifica en la ciudad** | IDIGER, en Bogotá | la municipalidad, en la ITSE | — |
| **Identificación del cliente** | NIT | RUC | RUC |
| **Huso** | UTC−5, sin cambio de hora | UTC−5, sin cambio de hora | UTC−5; **Galápagos, UTC−6** (`America/Galapagos`) |
| **Clientes de Aurum** | 4 torres (Aurum Suites S.A.S.) | 3 torres (Aurum Suites Perú S.A.C.) | 2 torres (Aurum Suites Ecuador S.A.) y el Inn de Galápagos (Hostería Chiriboga Cía. Ltda.) |
| **Moneda** | peso colombiano | sol | dólar estadounidense |

---

## 9. 💰 Las cifras

Todas son **ficticias** salvo donde se dice otra cosa, y acotadas a lo que el
laboratorio del curso maneja con comodidad. La semilla del mock es una muestra
mínima de esto, no una copia.

| Cifra | Valor | Fuente o supuesto |
|---|---|---|
| Activos certificados al año, 2016 | ~400 | ficticia |
| Activos certificados al año, hoy | ~5.200 (CO 3.400 · PE 1.200 · EC 600) | ficticia |
| Inspectores | ~40 (CO 26 · PE 9 · EC 5) | ficticia |
| Clientes activos | ~650, un tercio con RUC | ficticia |
| Torres de Aurum Suites que Plomada certifica | 9 (CO 4 · PE 3 · EC 2), más el Inn de Galápagos | ficticia |
| Habitaciones del Inn de Galápagos | 20, y un salón para eventos | ficticia |
| Viajes de inspección a Galápagos | 1 al año, dos inspectores de Guayaquil | ficticia |
| Personas de calidad que administran plantillas | 2, en Bogotá | ficticia |
| Inspecciones en la base cuando nació la API | 12 | heredada de la ficha v1 |
| Componentes de las eras 1 y 2 sin migrar | cuarenta y pico | heredada de la ficha v1 |
| Subidas de versión de PostgreSQL | 4 en ocho años (9.6 → 11 → 13 → 16) | heredada del track BE |
| Visitas e inspecciones del distrito a transporte vertical en Bogotá, 2024 | 1.953 | real, publicada por la Alcaldía de Bogotá; por verificar la cifra exacta |

---

## 10. 📏 Las reglas de negocio

- **Una inspección se lee siempre con la versión de plantilla con la que se
  ejecutó.** Es la regla de la Fase 7 y no tiene excepciones.
- **Una plantilla es de un país.** Cada país tiene sus propias familias de
  plantillas y sus propias versiones; una versión nueva en Colombia no cambia nada
  en Perú. **El sistema no lo sabe**: lo sostiene calidad con el nombre. Las
  familias sin sufijo (`elevator-annual`, `boiler-annual`) son las colombianas,
  las primeras que existieron; las de Perú y Ecuador llevan el país al final
  (`elevator-annual-pe`, `boiler-annual-ec`).
- **Un hallazgo `critical` impide emitir el certificado.** Los `major` y `minor`
  quedan registrados y se hace seguimiento.
- **El certificado vale hasta el final del día de su `validUntil`**, en la hora
  local del lugar donde está el activo. En el continente, en los tres países, eso
  es `23:59:59-05:00`; en Galápagos, `23:59:59-06:00`. La regla está escrita así
  desde siempre; el código solo conoce la primera mitad.
- **La revisión es anual.** Para ascensores la piden el Acuerdo 470 en Bogotá y
  la EM.070 en Perú; en todas las propiedades de Aurum, su estándar de marca.
  La vigencia del certificado es de un año desde la emisión.
- **Un certificado no se borra**: se revoca, con fecha y motivo, y el revocado
  sigue en el histórico.
- **El histórico es de la auditoría**: nada de lo emitido se reescribe, aunque la
  plantilla actual diga otra cosa.

---

## 11. 🗣️ Cómo hablan

Voces regionales con moderación, una frase por escena; la narración y las
instrucciones al lector siguen en tuteo neutro.

- **Claudia:** *"Eso no es un bug, es un hallazgo de auditoría."*
- **Gustavo:** *"El ascensor no se cae por lo que dice el papel, se cae por lo que
  el papel no pregunta."*
- **Jeimy Paola:** *"Le reenvío el correo, con copia a Claudia."*
- **Jorge:** *"Eso lo vemos al toque"*, y lo ve.
- **Patricio:** *"Ya mismo le mando"*, que en Quito puede ser hoy o el jueves.
- **Diego:** contesta con un audio de dos minutos que empieza por *"Parce, eso es
  de la migración…"*.

---

## 12. 🎭 Tu rol en esta ficción

Entras al equipo de mantenimiento, en Bogotá, con usuarios en tres países, y
eres la primera persona contratada de planta, con proceso, para sostener la API y
la aplicación a la vez. Eres senior en backend y esta es tu primera vez sosteniendo un frontend ajeno. Nadie te
va a hacer onboarding porque no hay quien: Renzo y Jimena ya no están, Diego
está asignado al portal de clientes y responde cuando puede, y la última persona
que tocó la API terminó su contrato en diciembre sin que nadie la reemplazara.

Tienes el código, esta ficha, y los tickets que van a ir llegando en el
`cuaderno-incidentes.md`. Vas a notar que llegan de tres sitios distintos y con
tres tonos distintos.

El curso te hace construir el sistema fase por fase antes de pedirte que lo
mantengas, y eso es una licencia pedagógica deliberada: escribir cada capa con
sus decisiones explicadas en voz alta es la forma más rápida de que después
reconozcas esas decisiones cuando te las encuentres tomadas por otro. Fíjate en
el orden, que también es intencional: la **Fase 0 te enseña el estilo nuevo** y
la **Fase 1 te entrega la herencia**. Conoces el destino antes que el pasado,
para que puedas leer los `NgModule` preguntándote *"¿por qué está así?"* en vez
de creer que es la única forma que existe.

Al llegar a la Fase 7 ya no vas a sentir que escribiste ese código: vas a sentir
que lo heredaste. Esa es la sensación que buscamos.

> **La señal de que esta ficha hizo su trabajo:** cuando abras un archivo raro y
> tu primera reacción no sea "qué inconsistente está esto", sino "¿de qué año es
> esto, de qué país, y en cuál de los dos estilos va mi fix?".
