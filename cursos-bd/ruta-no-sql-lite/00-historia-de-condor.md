# ✈️ Cóndor MRO · Taller Aeronáutico de Reparación

> La empresa del curso **Ruta NoSQL Lite**. Ficticia, y la única: todo lo narrativo del curso
> sale de aquí — las autopsias de la Fase 00, el dominio que se modela diez veces, las nueve
> entidades, los tres volúmenes y el proyecto global.
>
> **Estado:** **la empresa del curso**, decisión cerrada. Durante la discusión se evaluaron
> seis alternativas —una distribuidora eléctrica, una cooperativa cafetera, una agencia de
> publicidad, un operador portuario, un proveedor de internet y la flota industrial genérica
> con la que nació el temario— y están registradas en
> [`prompts/propuestas-historias.md`](prompts/propuestas-historias.md). Ganó Cóndor por dos
> razones: la **trazabilidad de una pieza a través del tiempo** es una búsqueda de patrón de
> profundidad desconocida y no un árbol —que es lo único que justifica un grafo—, y la
> **liberación al servicio** es una frontera transaccional con consecuencia legal personal
> para quien firma. Las otras seis no se perdieron: cada una aporta el miniproyecto de una
> familia, y eso vive en
> [`propuestas-mini-proyectos.md`](propuestas-mini-proyectos.md).
>
> **Sobre el nombre.** El cóndor es el ave de los Andes, que es donde vuela esta flota, y
> tiene la propiedad que define al negocio: **planea**. No bate alas: lee el aire y se sostiene
> durante horas sin gastar energía. Eso es exactamente lo que Cóndor le vende a sus clientes
> —que el avión esté arriba, no que el taller trabaje mucho—. Se evaluaron *Cóndor
> Aeroservicios* (suena a los años ochenta) y *Ala Andina* (bonito y olvidable); se prefirió
> **Cóndor MRO** porque las tres letras del oficio —mantenimiento, reparación y revisión
> general— son las que usa todo el mundo en el hangar y ninguna traducción mejora.
>
> ⚠️ **Advertencia de alcance, y es normativa.** Este curso **no enseña regulación
> aeronáutica** y no pretende ser exacto en ella. Las autoridades, los certificados y los
> programas que aparecen aquí están simplificados a propósito hasta el punto exacto en que le
> sirven al modelo de datos, y ni un milímetro más. Si una decisión de este documento choca
> con la realidad del oficio, gana el modelo de datos: es una empresa de mentira construida
> para enseñar bases de datos de verdad.

---

## 1. 🛠️ Cómo llegó a existir

**Hernán Peñaloza** empezó a los diecinueve años barriendo un hangar en Guaymaral y a los
veintiséis ya firmaba trabajos como técnico de línea. Es de los que huelen una fuga antes de
verla y de los que no se dejan apurar: en treinta y nueve años de oficio no ha firmado una
sola liberación al servicio con la que no estuviera tranquilo, y esa frase —dicha así, sin
énfasis— es la única cosa de la que presume.

**Lucía Arango** llegó desde el otro lado. Ingeniera aeronáutica, ocho años en planeación de
mantenimiento de una aerolínea de verdad, donde aprendió lo que no está en el pénsum: **el
negocio no es arreglar aviones, es que el avión esté disponible el martes**. Un avión en
tierra no cuesta lo que cuesta repararlo; cuesta los vuelos que no hizo.

Se conocieron en 2011 peleando. Ella coordinaba la parada de un turbohélice que tenía que
volar al día siguiente; él era el técnico contratado que se negó a liberarlo porque faltaba
la trazabilidad de un actuador que alguien había instalado dos años antes en otro taller. El
avión no voló. La aerolínea perdió tres rotaciones. Y tres semanas después, cuando apareció
el papel y el actuador resultó estar bien, Lucía lo llamó — no para reclamar, sino para
preguntarle cuánta gente firmaba así.

En 2014 alquilaron media nave en el hangar 7 del aeropuerto de Villavicencio, con dos
clientes, un carro de herramientas y un certificado de taller aeronáutico de reparación que
les costó catorce meses de trámite. **Cóndor MRO**, decía el letrero, y debajo, en letra más
chica, *"mantenimiento de aviación general y regional"*.

La ubicación fue puntería sin que ellos lo supieran del todo. Villavicencio es la puerta del
llano y de la selva: de ahí salen los aviones que llevan carga a pistas sin torre, los que
sacan enfermos de donde no hay carretera, y los que trabajan para las petroleras y las
mineras. Es una aviación que vuela mucho, en condiciones malas, con aeronaves que tienen más
años que los técnicos que las atienden, y cuyos dueños **no tienen taller propio ni lo van a
tener**. Los primeros veinte clientes salieron de un radio de dos pistas.

Lo que de verdad los despegó no estaba en el plan. En 2017, un operador de carga les pidió
algo raro: que dejaran de cobrarle por hora de técnico y le cobraran una tarifa fija por hora
volada, a cambio de hacerse cargo de todo el programa de mantenimiento de sus cuatro
aeronaves. El operador quería presupuestar; no quería sorpresas de cuarenta millones un
martes.

Hernán dijo que no. Dijo que eso era regalar el trabajo, que un avión viejo puede comerse el
margen entero en una inspección mayor, y que el día que apareciera corrosión en un larguero
iban a estar pagando ellos. Tenía razón en todo. Lucía dijo que sí de todas formas, y cuando
tres años después ese contrato era el 40 % de los ingresos de la casa, la discusión cambió de
tema pero no se acabó: sigue viva y **es el reparto de poder de la empresa**.

En 2019 abrieron la segunda base, en Bogotá, y contrataron a la persona que hoy sostiene la
operación: **Yamile Cruz**, coordinadora de planeación, que llegó a hacer un reemplazo de tres
meses.

En 2022 llegó el salto internacional. Un cliente se llevó dos aeronaves a operar desde Iquitos
y les pidió que lo siguieran atendiendo. Cóndor abrió estación en Perú sin tener idea de lo
que implicaba tener registros bajo dos autoridades distintas. Funcionó, y detrás vino Ecuador.

Y en 2023 vino la compra que todavía están pagando. **Aerotécnica del Sur**, un taller de
componentes de Bogotá con once personas, un banco de pruebas de instrumentos y —esto es lo que
importa para este curso— **un sistema propio, hecho en casa, que funcionaba mejor que el de
Cóndor**. Se lo compraron a su dueño, **Camilo Duarte**, que se quedó dirigiendo el taller de
componentes y que sigue defendiendo su sistema en cada comité. No le falta razón. El problema
no es su sistema: es que ahora hay dos.

Hoy, 2026, **Cóndor son ciento cuarenta aeronaves de ocho operadores en tres países**, seis
bases —Villavicencio, Bogotá, Barrancabermeja, Neiva, Iquitos y el Coca—, **doscientas diez
personas**, de las cuales treinta y ocho son técnicos con licencia y once son inspectores con
firma. Unas **novecientas órdenes de trabajo al mes** y alrededor de **cuarenta mil piezas con
número de serie** que la empresa está obligada a poder rastrear.

Hernán sigue firmando. Lucía sigue vendiendo horas de vuelo que todavía no ocurrieron.

### 1.1 🕊️ Ala Continua, el producto que los hizo y que los tiene despiertos

Lo que Cóndor vende hoy no es mano de obra: es **disponibilidad**. El producto se llama **Ala
Continua** y es lo que Lucía le vendió al operador de carga en 2017 contra el criterio de su
socio.

El trato, en una frase: **el operador paga una tarifa fija por hora volada y Cóndor se hace
cargo del programa de mantenimiento completo de la aeronave**, con un compromiso de
disponibilidad. Si el avión está en tierra más de lo pactado, Cóndor paga. Si el avión vuela
sin novedad, Cóndor gana.

| Etapa | Quién manda | Qué resuelve | Ritmo típico |
|---|---|---|---|
| **0 · Admisión de la aeronave** | Los dos, juntos | Auditoría de registros, estado real contra papeles, y la deuda de trazabilidad que trae de su taller anterior | 3 a 8 semanas |
| **1 · Programa de rutina** | Hernán | Las inspecciones por horas, ciclos y calendario. Es el 70 % del trabajo y no se ve: cuando está bien hecho, no pasa nada | Continuo |
| **2 · Componentes y reparación externa** | **Un taller aliado** | Motores, hélices, ensayos no destructivos, aviónica, estructura. **Cóndor no tiene estas capacidades** y no piensa tenerlas | 2 semanas a 8 meses |
| **3 · Inspección mayor** | Hernán y Édinson | La parada grande, la que se planea con un año y se pasa de presupuesto igual | 3 a 10 semanas |
| **4 · Liberación y seguimiento** | **Un inspector con firma** | La aeronave vuelve al servicio, y alguien pone su nombre y su licencia debajo | Cada vez |

> 🧭 **La etapa 1 es la que sostiene la 4.** Ese es el argumento comercial y el técnico a la
> vez, y es la discusión que Hernán y Lucía nunca terminaron: ella vende un precio fijo, él
> vende certeza, y ninguno de los dos productos existe sin el otro.

Para el curso, esto no es color. **Es el objeto de negocio más difícil que tiene la empresa**,
y casi todo lo que vas a modelar termina chocando contra él:

- **El ingreso no coincide con el trabajo.** El operador paga por hora volada, mes a mes,
  mientras el costo —una inspección mayor, un motor al taller aliado, una pieza que hay que
  importar— se causa en momentos completamente distintos y a veces años después de firmar.
- **La aeronave es una y el contrato es otro.** El mismo avión puede entrar en Ala Continua,
  salirse al vencer el contrato y volver con otro operador dos años después. **La historia de
  la aeronave sobrevive al contrato, y el sistema tiene que saber eso.**
- **La pieza viaja.** Un actuador sale de una aeronave, se repara en un taller aliado en otro
  país, entra a almacén, y seis meses después se instala en una aeronave distinta de un
  operador distinto. La pieza tiene su propia vida, sus propias horas y sus propios ciclos,
  **y su historia no es la historia de ningún avión: es la suya**.
- **Y el trabajo es compartido entre bases y entre países.** Una aeronave matriculada en
  Ecuador puede recibir mantenimiento de rutina en el Coca y la inspección mayor en Bogotá.
  El registro es uno solo; **las autoridades son dos, y cada una espera poder pedirlo**.

#### 🤝 Los talleres aliados, o qué pasa cuando la pieza sale de la casa

Cóndor hace mantenimiento de rutina, inspecciones mayores y reparación de componentes de baja
complejidad. **No hace motores, ni hélices, ni ensayos no destructivos, ni reparación
estructural mayor, ni aviónica de fondo**, y no piensa hacerlos: cada una de esas capacidades
es una certificación aparte, un banco aparte y un negocio aparte.

La solución de Lucía fue la de siempre: convenios. Hoy hay **diecinueve talleres aliados**
—cuatro de motores, dos de hélices, tres de ensayos no destructivos, cinco de aviónica, dos de
estructura y tres de instrumentos— repartidos entre Colombia, Perú, Ecuador y dos en Estados
Unidos para lo que aquí no se puede hacer. Cóndor les manda el componente con su expediente,
el aliado lo repara y lo devuelve con su certificado, y Cóndor lo factura al operador con su
margen.

Lo que no funciona es todo lo que pasa después de mandar la caja:

- **Nadie sabe dónde está la pieza.** Sale de Villavicencio, pasa por una agencia de carga,
  entra al aliado, espera repuestos que el aliado a su vez importa, y vuelve. Entre la salida y
  el regreso pueden pasar ocho meses, y durante ocho meses el estado real es una cadena de
  correos y un par de llamadas. Yamile lo lleva en una pestaña que actualiza cuando se acuerda.
- **El certificado llega en papel, o en un PDF escaneado torcido.** Y ese papel es lo único
  que sostiene la aeronavegabilidad de la pieza. Si se pierde, la pieza **no vale nada**
  aunque esté perfecta: sin trazabilidad no se instala, y se convierte en un pisapapeles de
  ochenta millones.
- **Las horas y los ciclos se descuadran.** El aliado devuelve el componente con un contador
  que dice una cosa y el expediente de Cóndor dice otra, porque alguien anotó una vez la hora
  del motor en vez de la del componente. Nadie sabe cuál es la buena, y la diferencia importa
  porque decide cuándo hay que sacarla otra vez.
- **Y a veces la pieza que vuelve no es la que se fue.** Es normal en el oficio y se llama
  intercambio: el aliado devuelve una equivalente reparada para no tener al avión en tierra.
  Es legítimo y está previsto. Pero significa que **el número de serie cambió y la historia se
  bifurcó**, y si eso no queda escrito, la trazabilidad se rompió en silencio.
- **Nadie mide a la red.** Cuál aliado cumple el tiempo prometido, cuál devuelve con novedades,
  cuál cobra lo pactado, cuál tiene el convenio vencido — porque los convenios se firmaron
  entre 2016 y 2024, con condiciones distintas, y cuatro vencieron sin que nadie renovara nada.

⚠️ **Y hay una arista que el curso no puede esquivar.** Cuando un inspector firma la liberación
al servicio, **está poniendo su licencia debajo de la afirmación de que todo lo instalado en
esa aeronave tiene trazabilidad válida** — incluida la pieza que volvió de un aliado con un
papel escaneado torcido. Si esa cadena no se puede reconstruir, el problema deja de ser
administrativo: es la licencia de Hernán, y es la de los otros diez inspectores. Modelar esto
bien no es una comodidad operativa. Es, literalmente, proteger a las once personas que firman.

⚰️ Hoy todo esto vive en un archivo de Yamile llamado **`FLOTA_CONTROL.xlsx`**, con una hoja
por base, una fila por aeronave, los componentes en columnas, el estado escrito a mano —"ok",
"en el aliado", "esperando papel", "preguntar a Camilo"— y una pestaña `AFUERA` que solo ella
entiende del todo. Cuando un operador llama a preguntar cuándo vuelve su avión, la respuesta
tarda entre diez minutos y dos días, según quién conteste.

---

## 2. 👥 Quién es quién

**Hernán Peñaloza**, cofundador e inspector con firma. Es el freno de la casa y el que dice
que no delante del cliente. Lento a propósito, desconfiado de todo lo que no puede verificar
él mismo, y la única persona de la empresa que ha leído entero el manual de mantenimiento de
las cuatro familias de aeronave que atienden. No usa el sistema: usa su libreta, y después
alguien pasa la libreta al sistema. Ese hábito es el origen de la mitad de los descuadres, y
él lo sabe y no lo va a cambiar, porque las dos veces que confió en la pantalla la pantalla
estaba mal.

**Lucía Arango**, cofundadora y gerente. Es la que vendió Ala Continua, la que compró
Aerotécnica del Sur y la que abrió Perú — tres decisiones que salieron bien y que se tomaron
con menos información de la que debían. Rápida, comercial, convence. Su punto ciego es
exactamente el de su socio al revés: ella cree que si el número está en un tablero, el número
es verdad.

**Yamile Cruz**, coordinadora de planeación. Es quien sabe dónde está cada cosa, y es el
mayor riesgo operativo de la empresa. Si Yamile se va, se va **la única copia** de cómo se
concilia el contador de un componente con el de la aeronave, qué aliado responde los sábados y
cuál es el correo bueno del que despacha en Iquitos. Nadie ha escrito nunca nada de eso.
`FLOTA_CONTROL.xlsx` es suyo y lo defiende, y tiene motivos: las dos veces que intentaron
reemplazarlo por un módulo del sistema, el módulo no soportaba el intercambio de componentes.

**Édinson Riaño**, jefe de taller de estructura y planta motriz. Veintiocho años en el oficio,
tres en Cóndor. Es el que ve primero cuando una inspección mayor se va a pasar del
presupuesto, y el que lleva la cuenta mental de qué aeronave trae vicios de su taller anterior.

**Camilo Duarte**, director del taller de componentes, ex dueño de Aerotécnica del Sur. Llegó
con la adquisición de 2023 y con su sistema debajo del brazo. Es el mejor ingeniero de datos
que tiene la empresa sin saber que ese es su oficio, y es también el motivo por el que hoy hay
dos verdades sobre el inventario. Defiende su sistema con argumentos buenos, que es lo que lo
hace difícil.

**Freddy Manrique**, técnico de línea itinerante. Se sube a una avioneta un lunes con una caja
de herramientas y vuelve el jueves habiendo atendido cuatro aeronaves en tres pistas del
Guaviare donde no hay señal de celular ni electricidad estable. Levanta todo en papel y lo
transcribe el viernes, cuando se acuerda de lo que vio el lunes.

**Sandra Vélez**, jefe de almacén y compras. Es quien pelea con el catálogo de partes, con los
números alternos, con los proveedores que llaman "equivalente" a lo que no lo es, y con la
gente que busca *"la junta esa del tren"* en un catálogo de ochenta mil referencias.

---

## 3. 🗄️ Los sistemas que hay hoy, y de dónde salieron

Este apartado es el que alimenta la **Fase 00** del curso, y conviene leerlo como lo que es:
un expediente, no un juicio. Cada una de estas decisiones la tomó alguien con buena
información y buenas razones.

**`SIGMA`, el sistema de siempre (2015).** Un sistema de mantenimiento comprado a un
proveedor local, sobre una base relacional, que hace bien lo que se le pidió en 2015: órdenes
de trabajo, horas de técnico y facturación. Sigue siendo la fuente de verdad de la plata, y
nadie discute eso. Lo que no previó nadie es que la empresa iba a operar en tres países y a
vender disponibilidad en vez de horas.

**El sistema de Camilo (2019, y llegó en 2023).** Aerotécnica del Sur manejaba componentes, y
un componente **no tiene los mismos campos que otro**: un instrumento tiene calibración, un
motor tiene ciclos y un neumático tiene recauchados. Camilo lo modeló en una base documental
con un argumento que era correcto: *"cada componente trae su propia ficha y el esquema va a
cambiar cada vez que entre una familia nueva"*. Tenía razón. Lo que no previó fue la segunda
colección, y el día que hubo que cruzar componentes con órdenes de trabajo, el cruce terminó
escrito en el código de la aplicación. Ahí se disolvió la frontera transaccional, y nadie lo
anotó en ningún lado.

**`FLOTA_CONTROL.xlsx` (siempre).** El sistema que de verdad usa la operación.

**Y el cuarto, que nadie llama sistema:** el archivador de Hernán, dos cajoneras de PDFs
escaneados y un disco duro externo que alguien respalda cuando se acuerda. Es donde viven los
certificados de los aliados, que son la única prueba de trazabilidad de la mitad de los
componentes instalados en la flota.

> ⚰️ **La factura de tener dos verdades.** En marzo de 2026, un operador pidió el expediente
> completo de un actuador de tren. `SIGMA` decía que estaba instalado en una aeronave que
> llevaba dos años fuera de la flota. El sistema de Camilo decía que estaba en almacén.
> Estaba, de hecho, en un taller aliado en Bogotá desde hacía once meses, esperando un repuesto
> que nunca llegó. **Reconstruir esa historia costó cuatro días de tres personas**, y la única
> razón por la que se pudo reconstruir es que Yamile se acordaba. La pregunta que Lucía hizo
> en ese comité —*"¿y si hubieran sido cien piezas y no una?"*— es el motivo por el que existe
> el proyecto del que vive este curso.

---

## 4. 💥 Los diez dolores, uno por familia

Cada uno de estos es un minicurso. Aquí están en la voz de la empresa; en el temario están en
la del modelo de acceso.

**🍃 La ficha que nunca tiene los mismos campos.** Un turbohélice de dieciocho puestos, un
monomotor de carga y un helicóptero no comparten casi nada — y dos aeronaves del mismo modelo
tampoco, porque el equipamiento opcional cambia qué hay que inspeccionar. `SIGMA` resolvió eso
con cuarenta columnas anulables y una tabla de "atributos adicionales" que hoy tiene doce
millones de filas.

**🔑 El hangar que se reserva dos veces.** Hay tres puestos con foso en Villavicencio y dos
grupos pidiendo el mismo el mismo día. Y la orden de trabajo que dos técnicos abren a la vez
desde dos terminales, que es como aparecen los duplicados que después nadie sabe cuándo
entraron.

**🦆 El costo por hora volada, que es el precio de venta.** Ala Continua se cotiza sobre el
costo histórico por hora de vuelo, por modelo y por operador. Hoy ese número lo arma Lucía
exportando de `SIGMA` a una hoja de cálculo, cruzando a mano con la del taller de componentes,
y confiando. **Si ese número está mal, el contrato nace perdiendo dinero y nadie se entera
hasta el año tres.**

**⏱️ Los datos que se descargan al aterrizar.** Treinta de las ciento cuarenta aeronaves traen
registro de parámetros de vuelo. Llegan ordenados, no se corrigen nunca, y sirven para una sola
cosa: ver la tendencia antes de que la tendencia se vuelva una novedad. Hoy se acumulan en un
disco y nadie los mira, porque no hay forma de consultarlos sin que la consulta tarde una tarde.

**🔍 *"La junta esa del tren"*.** El catálogo son ochenta mil referencias con números de parte,
alternos, equivalentes por modelo y proveedores que escriben el mismo número de cuatro formas.
Sandra busca con el equivalente de un `LIKE` y encuentra lo que ya sabía que existía. Lo que no
encuentra es el alterno que le habría ahorrado la importación.

**🕸️ La directiva que llega un jueves.** Llega un boletín sobre un lote de piezas fabricadas en
un rango de fechas. La pregunta que hay que contestar **hoy** es: *¿en cuáles de nuestras
ciento cuarenta aeronaves estuvo instalada alguna vez una pieza de ese lote, y qué más se
desmontó junto con ella?* No es descender un árbol: las piezas se mueven entre aeronaves, se
intercambian por equivalentes, pasan por almacén y vuelven, y **la profundidad y el camino son
desconocidos de antemano**. Esta es la pregunta que hoy se contesta con cuatro días y la
memoria de Yamile.

**🧬 *"Esto ya lo vimos"*.** Los reportes de piloto son tres líneas escritas con prisa, con
jerga y con faltas: *"ruido metálico al bajar tren, intermitente"*. Freddy sabe que eso ya
pasó en otra aeronave hace dos años y que la causa no era el tren. Pero esa memoria está en
Freddy, no en el sistema, y no hay forma de buscarla — porque buscar "ruido metálico" no
encuentra "golpeteo al extender".

**🏛️ Los parámetros que no caben.** Si las ciento cuarenta aeronaves tuvieran registro, serían
miles de parámetros por segundo por aeronave, escritos y jamás actualizados, consultados
siempre por aeronave y por rango de fechas. Ahí la coordinación central deja de ser viable, y
esa es una conversación que la empresa todavía no ha tenido.

**📴 Freddy en el Guaviare.** Tres días sin señal, cuatro aeronaves, todo en papel, y la
transcripción del viernes que introduce errores que nadie detecta hasta la auditoría. Y el
caso que nadie quiere nombrar: **dos técnicos que trabajaron sobre la misma aeronave sin
poder verse**, y que al sincronizar escribieron cosas incompatibles sobre el mismo componente.

**⚡ El expediente que no puede salir del país.** Tres autoridades, tres países, y un operador
estatal cuyo contrato dice con todas las letras que sus registros no salen de su territorio.
Pero la aeronave sí sale: hace rutina en el Coca y la inspección mayor en Bogotá. **El
expediente es uno solo y tiene que ser consistente en los dos lados**, y esa es la frontera
transaccional más cara que tiene la empresa.

---

## 5. 📊 Los números de la casa

Son los que fijan los tres volúmenes del curso y no se improvisan por fase.

| Magnitud | Hoy |
|---|---|
| Aeronaves atendidas | 140, de 8 operadores, en 3 países |
| Bases | 6 · Villavicencio, Bogotá, Barrancabermeja, Neiva, Iquitos, el Coca |
| Personas | 210 · 38 técnicos con licencia · 11 inspectores con firma |
| Órdenes de trabajo | ≈ 900 al mes |
| Piezas con número de serie rastreadas | ≈ 40.000 |
| Referencias en el catálogo de partes | ≈ 80.000 |
| Talleres aliados con convenio | 19 · de los cuales 4 vencidos |
| Aeronaves con registro de parámetros | 30 de 140 |
| Reportes de piloto acumulados | ≈ 26.000 desde 2015 |

**Los tres volúmenes del curso** salen de ahí y son los mismos en las diez familias:

- **10 k** — un mes de operación de una base. Es el volumen de los ejemplos: cabe en pantalla
  y se carga en segundos.
- **1 M** — cinco años de la red entera. Es el volumen donde **empiezan a notarse las
  decisiones de modelado**, y es donde se hacen las mediciones publicadas.
- **rotura** — el que cada familia calibra por su cuenta hasta que el motor falla de verdad.

---

## 6. 📖 El vocabulario de la casa

Las **nueve entidades** del dominio, que son las mismas en las diez familias y que **ninguna
fase renombra**. En inglés, como manda la guía de estilo; el glosario es para leer el texto.

| Entidad | Qué es en el hangar |
|---|---|
| `aircraft` | La aeronave: matrícula, modelo, año, configuración y equipamiento opcional |
| `part` | La pieza instalable **con identidad propia**: número de serie, horas, ciclos y su propia historia |
| `partCatalog` | El catálogo: números de parte, alternos, equivalentes por modelo, proveedores |
| `assembly` | El conjunto: motor, tren, hélice. Contiene piezas y se instala como una sola cosa |
| `workOrder` | La orden de trabajo. Es la entidad con frontera transaccional de verdad, y es donde se registran las instalaciones y los retiros |
| `reading` | La lectura descargada: parámetro de vuelo, horas, ciclos. Llega ordenada y no se corrige |
| `pirep` | El reporte del piloto, en prosa, con jerga y con faltas |
| `technician` | El técnico, y su licencia — que es lo que decide qué puede firmar |
| `hangar` | La base o el taller |
| `supplier` | El proveedor de partes **y** el taller aliado, distinguidos por su tipo |

> 📝 **Dos precisiones que ahorran discusiones.** La primera: `part` y `assembly` no son la
> misma cosa y la diferencia es de identidad, no de tamaño — una pieza con número de serie
> tiene historia propia, un consumible no. La segunda: **el grafo de trazabilidad no necesita
> una entidad nueva**; se construye con la historia de `workOrder` uniendo `part` con
> `aircraft` a lo largo del tiempo, y ese es exactamente el punto de la Fase 13.

---

## 7. 🏆 Lo que Cóndor quiere construir: **El Hangar**

Después del comité de marzo de 2026, Lucía aprobó lo que lleva tres años posponiendo:
**un sistema que sepa dónde está cada pieza, de dónde vino y qué sostiene su trazabilidad**.
Hernán puso una sola condición, y es la mejor definición de requisitos que ha escrito nadie en
esa empresa:

> *"Que cuando yo vaya a firmar, la pantalla me diga de dónde salió cada cosa que está en ese
> avión. Y si no lo sabe, que me lo diga, en vez de mostrarme un campo vacío como si no pasara
> nada."*

Eso es **El Hangar**, el proyecto global 🏆 del curso: acumulativo, opcional, y la única parte
de la ruta que se consume en orden. Cada bloque le suma un motor y una capacidad, y al final
del Bloque V está entero — con la factura de tenerlo escrita al lado, que es la otra mitad de
la lección.

Quien no lo haga no pierde nada del curso. Quien lo haga sale con el mejor portafolio que deja
esta ruta: un sistema políglota, medido, y con un documento que explica **por qué cada motor
está ahí y qué habría pasado si no estuviera**.

---

## 8. 🧭 Cómo usa el curso esta historia

- **La Fase 00** sale de §3: las decisiones heredadas de Cóndor son las autopsias, y se
  escriben con la estructura de §2.1 de la guía de estilo — la decisión, su mejor argumento,
  la factura a los dos años, el costo de salir. **Autopsia, no juicio:** Camilo no se equivocó,
  y el texto tiene que dejarlo claro o pierde al lector que tomó esa misma decisión.
- **Las Fases 01 y 02** salen de §5 y §6: el dominio, los volúmenes, el generador con semilla
  determinista y las cinco preguntas aplicadas a esta empresa.
- **Cada minicurso de familia** toma su dolor de §4 y lo modela a la manera de su familia,
  midiendo siempre contra Postgres.
- **Los cinco boss de bloque 💀** son encargos internos de Cóndor: los pide alguien de §2, y
  hay una consecuencia si salen mal.
- **Los diez miniproyectos de familia 🧰** **no** son de Cóndor: cada uno es de otra empresa,
  con otro dolor, y existen para demostrar que el modelo transfiere. Viven en
  [`propuestas-mini-proyectos.md`](propuestas-mini-proyectos.md) y en los archivos
  `h-mini-NN-*.md`.
- **El boss global 🏆** es El Hangar, de §7.

> 🧭 **La regla que protege la comparabilidad, y es la más importante de este documento.**
> **Todo lo que se mide se mide sobre Cóndor.** Las mediciones de la bitácora, las apuestas
> falsables, los puntos de rotura y la línea base de Postgres viven en este dominio y solo en
> este. Los miniproyectos de otras empresas se construyen y se razonan, pero **no entran al
> arnés de medición**: si cada familia midiera sobre un dominio distinto, no habría curso —
> habría diez tutoriales en fila, que es exactamente lo que esta ruta existe para no ser.
