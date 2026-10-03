# 🧪 Laboratorio Alameda, la empresa del curso
## Ruta SQL — borrador narrativo

> 📝 **Estado:** desde el 30/09/2026, con el alcance escrito
> ([`prompts/alcance-del-proyecto.md`](prompts/alcance-del-proyecto.md)), este documento es la
> **fuente de verdad de todo lo narrativo**, igual que `00-historia-de-condor.md` en la NoSQL
> Lite o `00-historia-de-cordillera.md` en el curso de C#. Lo marcado con 🔍 en §8 sigue sin
> usarse como material hasta que se verifique.

Laboratorio Alameda es ficticio, igual que la clínica y la red que lo absorbieron, y conviene
decirlo una vez. Ninguno de sus dolores está inventado para que el curso quede bonito. Todas las
tablas raras del sistema tienen un año y una razón que ese año era correcta. Esa es la diferencia
entre enseñar diseño relacional y burlarse de quien hizo lo que pudo con lo que tenía.

---

## 1. Cómo llegó a existir

En 1996, tres bioquímicos de Córdoba (Argentina) que llevaban años trabajando por su cuenta
decidieron juntarse. **Norma Castellani** hacía hematología y química clínica en el turno tarde
de un sanatorio. **Héctor Rinaldi** tenía un pequeño laboratorio de barrio que no le alcanzaba
para vivir. **Liliana Ferraro** era microbióloga en el hospital provincial y quería trabajar menos
horas por más plata. Cada uno tenía sus pacientes, sus médicos derivantes y sus convenios con dos
o tres obras sociales. Juntos tenían un laboratorio.

Faltaba la plata, y la puso **Rubén Bertolotti**, contador y cuñado de Héctor. Compró la mitad de un
autoanalizador de química de fabricación nacional, pagó los primeros seis meses de alquiler de un
local sobre la avenida —una casa vieja con patio, frente a una alameda que le dio el nombre— y se
quedó con un cuarto de la sociedad anónima que armaron. También se quedó con algo que nadie le
pidió: **las computadoras**.

Rubén no era programador y nunca dijo que lo fuera. Era un contador de los que en los ochenta
aprendieron solos a usar Lotus 1-2-3, después Excel, y un día descubrieron que Access venía en
el mismo CD de Office. Le gustaba, se le daba bien y lo hacía de noche. Esa combinación —alguien
competente, sin pretensiones, que resuelve el problema de mañana— es la que construyó la mitad
de los sistemas administrativos de la pequeña empresa latinoamericana. El curso la trata con
respeto porque funcionó durante veinticinco años.

Y hubo una tercera figura que casi toda PYME de esos años tuvo y que ninguna historia oficial
recuerda: **el técnico de PC**. En Alameda fue **Daniel "el Flaco" Moyano**, que cobraba por visita,
armó la primera red, instaló todo el software desde una carpeta de CD grabados y cambió cada
fuente quemada durante quince años. **El Office 97 de Alameda nunca tuvo licencia**, como la mayoría
del software de oficina de las PYME argentinas de la época. El curso lo dice una vez, sin
moralizar, porque es así como Access llegó a medio país.

📝 **Un glosario mínimo para quien no es de Argentina:**
- **Obra social:** entidad de cobertura de salud ligada al trabajo.
- **Prepaga:** cobertura privada.
- **Nomenclador:** lista oficial de prácticas con su código y su valor en **unidades
  bioquímicas (UB)**. Cada obra social paga la UB a un precio distinto.
- **Protocolo:** el número que identifica una orden en el laboratorio. En otros países se dice
  *orden*, *folio* o *accession number*.
- **Débito:** lo que la obra social descuenta del pago mensual por cada práctica que considera
  mal presentada.
- **DNI:** documento nacional de identidad.

El curso usa estos términos porque son los del negocio, y el diccionario de traducción los mapea.

---

## 2. 🟦 Por qué esta historia

Hay dos cursos en el repositorio que ya cuentan historias de sistemas heredados, y esta tiene que
contar otra cosa.

**Cóndor MRO** (NoSQL Lite) sirve para ver qué pasa cuando un dominio no es relacional en todas
sus partes. **Cordillera Media** (C#) sirve para ver qué pasa con el *código* heredado: FoxPro,
pasantes y una migración de runtime. **Alameda** es la historia del *modelo de datos* heredado:
qué pasa cuando alguien usa una base de datos relacional sin saber que lo es. Para Rubén, Access
era "tablas unidas por rayitas con un formulario arriba", y durante años eso alcanzó.

Además, esta historia hace que **los cuatro motores del curso lleguen solos**, igual que
Cordillera nunca decidió ser una casa Microsoft:

- **Access** porque venía en el CD de Office.
- **SQL Server** porque la software house de la clínica que compró el laboratorio trabajaba con él.
- **MySQL** porque la agencia que hizo el portal trabajaba con PHP.
- **Oracle** porque la red que compró la clínica construyó su propio sistema sobre Oracle hace
  veinte años.

Nadie eligió ninguno de los cuatro. El curso es la primera vez que alguien lo va a hacer.

---

## 3. 🧬 La genealogía del sistema, 1996–2026

**1996 · el cuaderno.** El laboratorio abre con un cuaderno de protocolos numerado a mano, una
libreta de deudores y los resultados tipeados en una Olivetti sobre un formulario preimpreso.
Atienden 25 pacientes por día. Las prácticas se facturan con los códigos del **nomenclador del
INOS**, que valoriza cada una con dos unidades: la bioquímica y la de gasto. El cuaderno funciona
perfecto, y va a ser el último sistema del laboratorio con una sola fuente de verdad.

**1997 · el recibo.** Con la convertibilidad, lo importado está barato, y Rubén compra una
Pentium de 133 MHz con Windows 95 y una **Epson LX-300** de matriz de puntos. El Flaco le instala
Office 97 Profesional. El primer problema que Rubén resuelve no es clínico sino suyo: **hacer un
recibo**. Crea una tabla `Recibos`, un formulario con el asistente, un informe para imprimir en
papel continuo y listo. Tarda un fin de semana.

Después la cosa crece de la única forma en que crece un sistema así, **un problema a la vez**:

- Hacía falta una lista de pacientes para no volver a tipear el nombre en cada recibo, así que
  nació la tabla `Pacientes`. En realidad era una agenda (ver más abajo).
- Norma quería dejar de tipear hemogramas a máquina, así que nació `Hemograma`, **una tabla con
  una columna por parámetro** (`Hematocrito`, `Hemoglobina`, `GlobRojos`, `GlobBlancos`…), con su
  formulario y su informe.
- Después vino `Quimica`, con `Glucemia`, `Urea`, `Creatinina`, `Colesterol`… Y `Orina`. Y
  `Coagulograma`. **Cada examen nuevo era una tabla nueva, un formulario nuevo y un informe
  nuevo.** Rubén lo hacía en una tarde.
- Antes de internet, avisar que un resultado estaba listo significaba que alguien llamara por
  teléfono. Así nació `ParaLlamar`: una tabla con el nombre, el teléfono y una casilla
  **"Llamado"**. La recepcionista la recorría a las cuatro de la tarde con el teléfono en la mano.
- Los pacientes particulares que pagaban después se anotaban en `Deudores`, que primero fue una
  copia de `Recibos` con una columna de saldo.
- A fin de mes había que armar la **presentación a cada obra social**: una planilla con los
  pacientes, sus números de afiliado y las prácticas con su código del nomenclador. Esa fue la
  primera consulta de verdad que Rubén escribió, y la primera que un día dio mal.

En la ventana de *Relaciones* había rayitas entre casi todas las tablas. **Ninguna tenía marcada
la casilla "Exigir integridad referencial"**, porque la primera vez que Rubén la marcó el
formulario de recibos dejó de funcionar, y la desmarcó.

### 3.1 Todo es texto, y el nombre trae el DNI adentro

Rubén descubrió muy pronto que los campos de texto **nunca le daban error**. Un campo numérico
rechazaba `"45 años"`, uno de fecha rechazaba `"marzo"`, uno de texto aceptaba todo. Así que casi
todo fue texto, incluidos el DNI, la edad, el número de afiliado y el precio en la primera
versión.

Y como el formulario de pacientes tenía un solo campo grande que decía **Nombre**, la recepción
lo usó como se usa un campo grande:

```text
PEREZ PEDRO DNI 23456789
GONZALEZ MARIA ESTHER DNI 11222333 OSDE 210
RN GONZALEZ MARIA DNI 11222333
LOPEZ JUAN CARLOS (EL HIJO) DNI 30111222
SILVA ROSA - PAMI 150123456789/00
VARGAS MAMANI JUANA PASAP BOL 4455667
```

El recién nacido no tiene DNI todavía, así que se carga como `RN` más el nombre y el **DNI de la
madre**, y en los datos queda indistinguible de la madre salvo por esas dos letras. El teléfono
sigue la misma lógica: `"4251234 (VECINA DE ENFRENTE)"`, `"15-6123456 SOLO TARDE"`.

Rubén no se desespera: escribe **"el parser"**. Es una función de VBA de unas cuarenta líneas,
`ExtraerDNI()`, que busca la palabra `DNI`, toma lo que sigue hasta el próximo espacio y, si no
encuentra la palabra, se queda con el primer número de siete u ocho cifras. Hay otra,
`ExtraerOS()`, que busca nombres de obras sociales conocidas. **Las dos funcionan en el 90 % de los
casos**, y el 10 % restante es la razón por la que la presentación de fin de mes tiene débitos.

La regla que Rubén le dejó escrita a la recepción en un papel pegado al monitor —*"APELLIDO NOMBRE
espacio DNI espacio NÚMERO"*— es, sin que nadie lo supiera, **la primera especificación de formato
de la empresa**. También es la prueba de que el problema nunca fue la gente: el esquema no tenía
dónde poner lo que la gente sabía.

### 3.2 La genealogía del parser

El parser de 1998 sabía una sola cosa: **una persona es un DNI**. Durante veinte años, cada vez que
llegó alguien que no encajaba, la respuesta fue un `ElseIf` más. Ninguno fue una mala decisión el
día que se tomó; juntos son la mejor demostración del curso de que **parchear una función que
manipula texto no reemplaza definir una regla de negocio**.

**1998 · la versión original (Rubén).** Busca `DNI` más el número, con o sin puntos. Si no
encuentra la palabra, toma el primer número de siete u ocho cifras. Todo lo demás es nombre,
fecha o dirección, según dónde caiga. Unas cuarenta líneas.

**2003 · primer parche: la señora de Bolivia (Rubén).** Llega a la sede nueva una paciente
boliviana con pasaporte y sin DNI. El parser le asigna el número del pasaporte como DNI y le deja
`PASAP BOL` pegado al nombre. Rubén agrega la regla: si viene `P` o `PASAP`, lo siguiente es el
**país en tres letras** y después el número. Guarda el número en el campo `dni`, porque no hay otro
campo, y el país en el nombre, entre paréntesis. Funciona hasta que la recepción escribe `BO`,
`BOLIVIA` o `PASAPORTE`, o hasta que el pasaporte trae letras.

**2005 · las libretas (Rubén).** Aparecen los jubilados con **Libreta de Enrolamiento** y **Libreta
Cívica**, los documentos que existían antes del DNI. Rubén acepta `LE` y `LC` como si fueran `DNI`.
El número se conservó cuando esas personas tramitaron su DNI, así que la misma señora queda dos
veces, con el mismo número y dos "tipos" distintos que el sistema no distingue.

**2008 · los recién nacidos (Matías).** El `RN` con el DNI de la madre deja de ser costumbre de la
recepción y pasa a ser regla del parser: si el nombre empieza con `RN`, el DNI que sigue *es el de
la madre* y se guarda igual. Madre e hijo comparten identidad en la base hasta que alguien los
separe, y nadie lo hace.

**2012 · los residentes extranjeros (nadie).** Los extranjeros con residencia empiezan a llegar con
**DNI argentino**, en una numeración muy por encima de la de los nativos. El parser no cambia, porque
"es un DNI". Lo que se rompe es otra cosa: toda regla que asocie el número de DNI con la edad del
paciente, incluida la que Matías usa para detectar el año de dos dígitos.

**2016 · el port (Matías).** Matías porta el parser a una función escalar de T-SQL para usarla desde
los reportes, **copiando la versión de ese momento**. Desde ese día hay dos parsers, y nadie
recuerda que hay que mantenerlos iguales. Las dos diferencias que nadie documentó salen de ahí:

- **El año de dos dígitos cambia de ventana.** VBA sigue la regla de Windows (del `00` al `29` es
  20xx). SQL Server usa por defecto su propia opción, con corte en **2049**. Un `15/03/35` es 1935 en
  el frontal y 2035 en el reporte.
- **El parche de 2019 solo existe en VBA** (ver abajo). Los reportes siguen sin entenderlo.

**2019 · la refugiada (Matías).** Una paciente con un **certificado de residencia precaria**, el
documento que se entrega mientras se tramita un pedido de refugio. No es DNI, no es pasaporte y
tiene un formato que nadie en el laboratorio había visto. El parche es `OTRO` más lo que venga, y
es el primero que ya ni intenta entender.

En 2026 el parser de VBA tiene unas **cuatrocientas líneas**, y Matías lo resume en una frase que el
curso va a citar: *"nadie sabe qué hace con un pasaporte chileno"*.

🧠 **Lo que el parser intentaba decir y el esquema nunca pudo:**

- Un documento es **tipo, país emisor y número**, no un número. Cada tipo tiene su formato, y ese
  formato es una restricción que el motor puede verificar.
- **Una persona no es su documento.** Tiene documentos a lo largo del tiempo: el recién nacido que
  después tiene DNI, el extranjero con pasaporte que después obtiene residencia, la libreta que se
  convirtió en DNI. La clave del paciente no puede ser ninguno de ellos.
- **"Sin documento" es un estado válido**, no un texto vacío ni un DNI prestado.

Cada parche codificó una regla sin declararla. El esquema no podía defenderla, el optimizador no
podía usarla y el siguiente desarrollador no podía leerla. Una restricción en el modelo hace las
tres cosas, y ese es el argumento con el que el curso abre el bloque de modelado.

**1999 · la tabla por práctica deja de escalar, y el Y2K.** Ya son 34 tablas de examen. Una
práctica nueva significa agregar una columna, tocar el formulario y rehacer el informe. Rubén lo
sigue haciendo, pero cada vez tarda más, y aparecen las primeras columnas `Otro1`, `Otro2` y
`Obs`, que existen para no tener que agregar columnas.

El Flaco pasa por todas las PC por el Y2K, y el año 2000 llega sin sobresaltos. El problema
verdadero aparece **en enero de 2000 y dura veinte años**: la fecha de nacimiento se carga con año
de dos dígitos, y Windows interpreta del `00` al `29` como 20xx. Una paciente nacida en 1925 que
se carga como `15/03/25` queda **nacida en 2025**, con edad negativa, y los valores de referencia
por edad del informe se vuelven disparates. Rubén agrega una validación en el formulario; los
datos ya cargados se quedan como están.

**2002 · la crisis.** Llegan la devaluación y la inflación. Las obras sociales renegocian el valor
de la unidad bioquímica cada pocos meses, y cada una por su lado. Rubén tenía el precio en una
tabla `Precios` con **un valor por práctica**, así que cuando cambiaba lo **pisaba**. En
septiembre, una obra social pidió refacturar marzo y **el sistema ya no sabía cuánto valía marzo**.
Rubén lo reconstruyó a mano desde los recibos impresos, durante tres fines de semana. Desde ese
día existe `Precios_Historico`, que en realidad es una copia de `Precios` hecha el día 1 de cada
mes, con el mes en el nombre de la tabla: `Precios_2002_09`, `Precios_2002_10`… Hoy son 280.

**2003 · la segunda sede.** Abren un **centro de extracción** en otro barrio. Allí se sacan las
muestras y se atiende la caja; las muestras viajan en moto al laboratorio central, dos veces por
día. La sede tiene su propia PC con su propia copia de la base, porque compartir una carpeta
entre dos edificios no es algo que una PYME sepa hacer todavía.

Durante un año, la sincronización es **un pendrive que viaja en la misma moto que las
muestras**. Rubén escribe una macro que importa lo nuevo. Cuando el mismo paciente se atiende en
las dos sedes, queda **dos veces**, con dos historiales que nadie vuelve a juntar.

**2004 · la replicación.** Las dos sedes ya tienen ADSL, y el Flaco arma una VPN con dos routers
baratos. Rubén pasa todo a **Access 2003** y descubre la **replicación de Jet**: cada sede tiene
su réplica y de noche se sincronizan por la VPN. Parece magia. Para que las réplicas no choquen al
generar claves, Access convierte los autonuméricos en **aleatorios**. Durante una semana, los
informes salen con números de protocolo como `-1847263541`. Un médico derivante llama para
preguntar si es un chiste.

Rubén resuelve el número visible con un campo `NroProtocolo` que se calcula en el formulario con
**`DMax("NroProtocolo", "Protocolos") + 1`**, con un prefijo por sede. Con una PC por sede
funciona perfecto.

El mismo año llega el primer **autoanalizador con salida serie**. Rubén no sabe leer un puerto
RS-232, así que el equipo imprime y alguien transcribe. Por ahora.

**2005 · los lunes, y el nomenclador nuevo.** La base del central ya vive en una carpeta
compartida y la usan cinco PC: dos de recepción, dos del laboratorio y la de Rubén. Aparecen los
clásicos de Access multiusuario, y el curso los va a tratar como datos, no como anécdotas:

- **Registros bloqueados.** Alguien deja el formulario de hemograma abierto a la hora del
  almuerzo y nadie más puede cargar.
- **La base corrupta**, casi siempre porque alguien apagó la PC con un formulario abierto o se
  cortó la luz. El mensaje *"Unrecognized database format"* se volvió una frase del laboratorio.
- **El ritual de "Compactar y reparar"** de los lunes a las siete de la mañana. El respaldo es un
  CD que Rubén graba los viernes y se lleva a su casa. Si el lunes salía mal, se restauraba el CD
  y se volvía a cargar el fin de semana a mano, desde los papeles.
- **El número de protocolo duplicado.** Con dos recepcionistas cargando a la vez, `DMax + 1` da
  el mismo número a dos pacientes distintos. Pasa dos o tres veces por semana, y la regla pasa a
  ser *"si sale repetido, bórralo y cárgalo de nuevo"*.

En noviembre de ese año, en Córdoba justamente, se aprueba el **Nomenclador Bioquímico Único**
(NBU). Unifica las dos unidades del INOS en una sola **unidad bioquímica** y **recodifica las
prácticas**. Las obras sociales lo adoptan de a una, a lo largo de años. Rubén agrega una columna
`CodNBU` al lado de `CodINOS`, y durante un tiempo largo la misma glucemia se factura con un
código u otro según quién pague. Cuando en 2012 sale la versión nueva del NBU, aparece una tercera
columna.

**2006 · el techo de los 2 GB, y la primera mirada al mercado.** Las obras sociales exigen que la
**orden médica** —con firma, sello, diagnóstico y número de afiliado— acompañe cada práctica
facturada, y faltarla es causa de débito. Para no perder papeles, Rubén agrega un campo **Objeto
OLE** en `Protocolos` y la recepción empieza a **escanear cada orden a la base**. Access guarda
cada imagen como un mapa de bits sin comprimir. En catorce meses el `.mdb` llega al máximo de
**2 GB**.

La solución es la de siempre: todo lo anterior a 2005 se mueve a `Alameda_Historico.mdb` y se deja
vinculado. Consultar la historia de un paciente crónico ahora significa abrir dos bases.

Ese año los socios miran por primera vez el mercado. Hay varios **sistemas de laboratorio (LIS)**
de proveedores argentinos, y dos vienen a hacer la demostración. Los dos son mejores que "la
base" en casi todo. Uno cuesta unos veinticinco mil dólares más una licencia por puesto; el otro,
un poco menos, pero la **migración de la historia se cotiza aparte y por hora**, y ninguno de los
dos entiende la facturación a obras sociales tal como la hace Alameda: los convenios, los
coseguros, las prácticas que una paga y otra no. Héctor hace la cuenta en una servilleta y dice la
frase que decide la década: *"la base anda"*. Y anda.

**2008 · Matías, la tabla genérica y los equipos.** **Matías Ledesma** había entrado en 2004 como
administrativo de recepción, a los 22 años, y Rubén lo formó durante cuatro. Matías sabe algo que
Rubén no sabía: que VBA puede leer archivos y puertos, y que no hace falta una tabla por examen.

Lo primero que hace es **conectar los equipos**. Los analizadores nuevos exportan sus resultados
como archivos de texto a una carpeta compartida, y Matías escribe el módulo `ImportarEquipos`,
que cada cinco minutos lee esa carpeta y carga lo que encuentra. Los valores llegan **como los
escribe cada equipo**: con coma o con punto según la configuración regional, con `<` o con `>`
cuando el valor sale del rango de medición, y con leyendas como `HEMOLIZADA` o `REPETIR`. Matías
los guarda tal cual. No hay otra forma sin romper algo.

Lo segundo es dónde guardarlos. Diseña `Determinaciones` y `ResultadoItem` (protocolo, código de
determinación, valor como texto, unidad, rango de referencia como texto) y, a partir de ese día,
**todo examen nuevo va a la tabla genérica**. Las 71 tablas viejas se quedan, porque migrarlas no
le sirve a nadie ese mes.

Desde entonces, **Alameda tiene los dos extremos del mismo error al mismo tiempo**: una tabla ancha
por examen para lo viejo y un EAV puro para lo nuevo. Un hemograma de 2007 y uno de 2009 viven en
estructuras que no se parecen en nada, y el informe hace `UNION` entre las dos.

El mismo año, Matías hace el módulo de **turnos** en Access 2007 con el formato nuevo `.accdb`,
que tiene algo irresistible: **campos multivalor**. En el turno, "Exámenes solicitados" es *un*
campo que guarda *varios* exámenes. Anda muy bien, y va a ser un problema cuando haya que sacarlo
de Access. Para no comprar Access en cada PC, las recepciones usan **Access Runtime**.

**2009.** Alameda tiene el central y cuatro centros de extracción, con unos 180 pacientes por día.
La sincronización nocturna tarda cada vez más, y hay mañanas en que la sede de Villa Allende abre
sin los resultados de ayer.

**2011 · la clínica.** La **Clínica Mediterránea**, una clínica privada de 90 camas, compra el 60 %
del laboratorio. No tenía laboratorio propio y le pagaba a terceros; Alameda tenía buena reputación
y los socios fundadores ya pensaban en retirarse.

La clínica tiene un área de sistemas de dos personas y un sistema administrativo hecho por una
**software house** local sobre **SQL Server 2008 R2 Standard**. El servidor y la licencia son de la
software house, que se niega a alojar una base ajena en "su" instancia. La decisión de integración
se toma en una reunión de media hora: *"que la base de Alameda vaya a un SQL Server propio, y que
ellos sigan usando su Access"*. Matías corre el **Asistente para convertir a SQL Server** de
Access 2010, y los datos pasan a una instancia **SQL Server Express**, gratuita, en un servidor
nuevo. El frontal sigue siendo el mismo Access, ahora con **tablas vinculadas por ODBC**.

Durante unos meses todo mejora: se acabaron los lunes de compactar y reparar. Después aparecieron
los problemas nuevos:

- **Las tablas sin clave primaria quedaron de solo lectura** en Access. Había 23. Se les agrega
  una columna `IDENTITY` a las apuradas, y en tres de ellas la columna se llama `id`, `ID` e `Id`.
- **Los formularios siguen enlazados a tablas enteras.** Con 30 PC y los centros entrando por
  VPN, abrir el formulario de protocolos trae por la red cientos de miles de filas. Hay consultas
  que Access resuelve **del lado del cliente**, con joins que traen dos tablas completas para
  cruzarlas localmente.
- **Aparece `#Eliminado`** en filas que no fueron eliminadas.
- **El módulo de turnos no migra.** Los campos multivalor no tienen equivalente, así que el
  `.accdb` de turnos se queda en la PC de recepción del central, con una vinculación hacia el
  servidor para todo lo demás. Sigue ahí en 2026.

La respuesta oficial durante dos años fue *"la base está lenta"*. **La base no estaba lenta.**

**2012 · el LIS que no fue.** La dirección de la clínica, que viene de gestionar un sanatorio con
sistemas comprados, decide que el laboratorio no puede seguir en "un Access". Compra uno de los
LIS que Alameda había visto en 2006, ya en su versión web. La implantación dura **siete meses** y
se abandona por tres razones, y las tres son de datos:

- **La migración de la historia salió incompleta.** El proveedor migró los pacientes y los
  resultados desde 2008, los de `ResultadoItem`. Las 71 tablas anchas quedaron para "una segunda
  etapa" que costaba otra vez por hora. Norma se negó a firmar informes de pacientes crónicos sin
  sus antecedentes.
- **Los pacientes se multiplicaron.** El importador del proveedor no entendía `PEREZ PEDRO DNI
  23456789`: donde el parser de Rubén acertaba el 90 %, el importador creó un paciente nuevo por
  cada variante.
- **La facturación.** El LIS facturaba por NBU y un precio por obra social. Alameda tenía
  coseguros, topes mensuales por afiliado, prácticas que se facturan juntas y convenios con fecha
  de corte. Los débitos del primer mes se triplicaron.

Se vuelve a "la base". El LIS deja dos herencias: una tabla `MIG_LIS_PACIENTES` que nadie borró, y
la convicción de toda la empresa de que **"migrar es imposible"**, que el curso tiene que
desmontar con cuidado, porque tiene algo de razón.

**2013 · el portal.** Los médicos derivantes piden ver los resultados sin llamar, y los pacientes
también. La clínica contrata a una agencia de Rosario que arma un **portal de resultados en PHP con
MySQL**, alimentado por una exportación nocturna desde SQL Server: un paquete que vuelca los
protocolos del día y genera los PDF.

El portal muestra los resultados **hasta ayer**, y nadie lo considera un problema. La URL de cada
resultado es `resultados.alameda.com.ar/ver.php?protocolo=C-0048213`. La tabla `ParaLlamar` se
sigue usando, porque los mayores de setenta años siguen queriendo que los llamen.

Para "que no se pierdan", **los PDF de cada informe se guardan también en SQL Server**, en una
columna `varbinary(max)`, al lado de las órdenes escaneadas que llegaron de Access.

**2014 · el techo de los 10 GB.** SQL Server Express limita cada base a 10 GB. Con órdenes
escaneadas y PDF adentro, Alameda llega en **once meses**. La clínica compra una licencia Standard
a regañadientes. Nadie discute lo de los PDF.

**2015 · la factura electrónica.** Desde el **1 de julio**, todos los responsables inscriptos en
IVA tienen que emitir comprobantes electrónicos, y Alameda, que es una sociedad anónima inscripta,
entra. Cada comprobante se autoriza contra el web service del organismo recaudador, que exige que
el número sea **exactamente el último autorizado más uno** para ese punto de venta y ese tipo de
comprobante. Si no lo es, lo rechaza.

El `DMax + 1` de 2004, que ahora corre en tres cajas contra el mismo SQL Server, emite dos
comprobantes con el mismo número una tarde de julio. El segundo se rechaza, la caja queda trabada
con cuarenta pacientes en la sala de espera y un contador externo tarda dos días en entender qué
pasó. Matías agrega una tabla `UltimoNumero` con un `UPDATE` y un `SELECT`, en ese orden y sin
transacción. Los rechazos bajan a uno por mes.

**2018 · el incidente del portal.** Un estudiante de sistemas, paciente del laboratorio, nota que
el número de protocolo de su URL es secuencial, le resta uno y ve el resultado de otra persona.
Escribe un script que descarga **catorce mil informes** en una noche, incluidas serologías de HIV,
y se los manda a un periodista para demostrar el punto. Aparece en el diario local. La **Agencia de
Acceso a la Información Pública**, que desde fines de 2017 es la autoridad de aplicación de la ley
de protección de datos personales, abre una actuación, y la clínica paga abogados durante un año.

La corrección de la agencia es **cambiar el número por un hash MD5 del número**. El curso vuelve
sobre esto en el capítulo de identificadores, porque es exactamente la corrección que no corrige
nada.

**2020 · la pandemia.** El laboratorio se habilita para PCR de COVID-19. En seis semanas pasa de
unos 400 protocolos diarios a **2.600**, con un autoservicio de hisopado en el estacionamiento de
la clínica. Cada caso estudiado —positivo o negativo— hay que notificarlo al **SNVS 2.0**, dentro
del SISA, con modalidad inmediata: dentro de las doce horas.

**Es el momento en que el sistema se sale de las manos**, y todo lo anterior cobra a la vez:

- el frontal Access con 45 usuarios simultáneos;
- `UltimoNumero` bloqueando la caja;
- el parser de Rubén frente a miles de pacientes nuevos por día, muchos cargados de apuro en el
  estacionamiento;
- la exportación nocturna al portal, que empieza a las 22:00 y **termina a las 9:40 del día
  siguiente**, con miles de pacientes llamando para saber su resultado;
- la tabla `ParaLlamar` con cuatro personas llamando en turnos;
- la notificación obligatoria, que se hace **copiando y pegando desde una consulta de Access a una
  planilla**, que a su vez se carga en el sistema oficial.

Matías trabaja once semanas seguidas y lo saca adelante. En noviembre renuncia y vuelve seis
meses después, con un sueldo que la clínica debió haberle pagado desde 2011.

**2022 · la red.** **Horizonte Salud**, una red con catorce clínicas en el centro del país y sede
en Buenos Aires, absorbe a la Clínica Mediterránea, y con ella al laboratorio.

Horizonte no tiene un sistema comprado: tiene **"el SIH"**, un sistema de información hospitalaria
**propio**, construido desde 2004 sobre **Oracle** con Oracle Forms y miles de paquetes PL/SQL, y
migrado a web a medias. Horizonte creció comprando clínicas, y **cada clínica que llegó traía su
propio sistema**: uno en Clipper, dos con sistemas comprados de proveedores que ya no existen, uno
en Visual Basic 6 sobre SQL Server. Integrarlas le enseñó a la red una lección que repite en cada
reunión: los sistemas comprados no se adaptan a sus convenios, a sus reglas de internación ni a sus
auditorías. Desde 2010, **Horizonte construye; no compra**. Eso le dio control y un sistema que hace
exactamente lo que la red necesita. También le dio veinte años de reglas ad hoc por clínica,
tablas con el nombre de la clínica en el nombre y un equipo de DBA muy bueno que vive saturado,
porque cada clínica nueva son seis meses de integración.

La primera exigencia para Alameda es la **integración**: las órdenes de laboratorio de las catorce
clínicas tienen que entrar a "la base" y los resultados tienen que volver al SIH. Se hace con una
interfaz de mensajes que un integrador construye en cuatro meses, y que desde entonces es la pieza
del sistema que más incidentes genera. Los pacientes duplicados de Alameda se encuentran con los
pacientes duplicados del SIH, que tiene los suyos.

Alameda pasa a ser el **laboratorio central de la red para el interior del país**. En 2026 procesa
unos **3.000 protocolos por día**.

**2024 · la app.** El equipo digital de Horizonte lanza la **app de pacientes**, hecha en Node.js
sobre **MongoDB Atlas**. Turnos, credencial digital, historia de consultas. Lo que la gente más le
pide a la app, por lejos, son **los resultados de laboratorio**, que hoy abren un enlace al portal
PHP de 2013.

**2026 · el encargo.** La dirección de Horizonte decide que el laboratorio central no puede seguir
sobre un frontal Access de 1997 atornillado a un SQL Server, más un portal PHP con MySQL, una
interfaz frágil hacia el SIH y un `.accdb` de turnos en la PC de recepción. Hay presupuesto, un año
de plazo y una condición: **el laboratorio no para ni un día**.

La pregunta obvia —*"¿por qué no compran un LIS?"*— se hizo, y en la red tiene tres respuestas. La
primera es la doctrina: Horizonte no compra desde 2010. La segunda es 2012: el LIS que no fue sigue
en la memoria de todos. La tercera es la que importa para el curso: **aunque se comprara uno, el
problema de fondo no cambia**. Hay que migrar treinta años de historia sin perder trazabilidad,
unificar el maestro de pacientes con el del SIH y rehacer la facturación con sus convenios. Todo
eso es un problema de modelo de datos, y ningún proveedor lo resuelve por hora.

Sobre la mesa hay tres propuestas, y las tres las defiende gente competente. La sección 6 las
presenta.

**El primer día, "la caja".** Nadie le da acceso de escritura a producción al arquitecto nuevo, y
Verónica tampoco. Lo que recibes es una carpeta compartida que Matías armó durante un fin de
semana, con un `LEEME.txt` escrito a las dos de la mañana:

- cada tabla de `ALAMEDA` exportada a CSV con `bcp`, un par de ellas en Latin-1 "porque así
  salieron";
- el script de creación que generó el SQL Server Management Studio;
- los módulos VBA de Rubén exportados como texto, `ExtraerDNI()` incluido, y la versión en T-SQL
  que Matías portó;
- el `.accdb` de turnos exportado a CSV, con los exámenes solicitados separados por punto y coma;
- las planillas que llegan de afuera: padrones de afiliados de tres obras sociales, el NBU, los
  convenios de precios y la planilla de notificación de la pandemia;
- en lugar del terabyte de imágenes y PDF, un listado con el nombre y el tamaño de cada archivo.

El `LEEME.txt` termina con una línea que el curso va a citar más de una vez: *"cualquier cosa
me llaman, pero no los martes que es día de facturación"*.

📝 Al sistema nadie le puso nunca nombre. Rubén lo llamaba **"la base"**, la clínica lo llamó
**"el Access de Alameda"** hasta 2014 y la red lo llama **"el LIS de Córdoba"** en los documentos
oficiales. En el laboratorio, todo el mundo le sigue diciendo **"la base"**.

---

## 4. 🩻 Cómo se ve por dentro, en 2026

Este inventario es el material didáctico del curso. Cada punto tiene una fase que lo ataca.

- **Una instancia de SQL Server Standard** con la base `ALAMEDA`: **214 tablas**, de las cuales
  unas 60 nadie sabe si se usan. Entre ellas, `MIG_LIS_PACIENTES`.
- **`Pacientes.Nombre`** con el DNI, la obra social y a veces el parentesco adentro, en unos 1,9
  millones de filas. El parser de Rubén, `ExtraerDNI()`, **sigue en producción** y ahora también
  existe como función escalar de T-SQL, portada por Matías con dos diferencias de comportamiento
  que nadie documentó (§3.2).
- **Casi todo en texto**: DNI, número de afiliado, edad, teléfono con notas. La fecha de nacimiento
  sí es fecha, pero **unos 4.000 pacientes nacieron en el futuro**, herencia del año de dos
  dígitos.
- **Pacientes duplicados** entre el 15 % y el 20 %, según Matías: el mismo DNI con dos nombres, el
  mismo nombre con DNI vacío, recién nacidos con el DNI de la madre y extranjeros con el pasaporte
  en el campo DNI.
- **71 tablas de examen "anchas"** anteriores a 2008 (`Hemograma`, `Quimica`, `Orina`,
  `Coagulograma`, `Tiroideo`…), con columnas `Otro1`–`Otro4` y `Obs`.
- **`ResultadoItem`**, el EAV de 2008: **unos 140 millones de filas**, con el valor como texto, tal
  como lo escribió cada equipo: `"5,2"`, `"5.2"`, `"< 0,5"`, `">1000"`, `"HEMOLIZADA"`.
- **Rangos de referencia en texto libre** (`"70 - 110"`, `"hasta 200"`, `"Niños: 3-7 / Adultos:
  4-10"`), que el informe no interpreta. El resaltado de valores fuera de rango se hace con una
  función VBA de 300 líneas que solo conoce Matías.
- **Tres columnas de código de práctica** (`CodINOS`, `CodNBU`, `CodNBU2012`) y una tabla de
  equivalencias incompleta.
- **La obra social como texto** en protocolos anteriores a 2012 (`"OSDE"`, `"Osde"`, `"O.S.D.E"`,
  `"osde 210"`). Después de 2012 existe una tabla de obras sociales, pero la columna vieja se quedó
  y hay pantallas que todavía escriben ahí.
- **280 tablas `Precios_AAAA_MM`**, de 2002 a 2025. En 2025 Matías cambió a una tabla con
  `vigencia_desde`, pero la vigencia **no tiene fin**, así que cuando dos se superponen no se puede
  saber cuál estaba vigente.
- **`Protocolos` sin clave natural confiable.** El `NroProtocolo` visible tiene prefijo de sede,
  duplicados históricos y un salto en 2004 (los negativos de la replicación, renumerados a mano,
  casi todos).
- **`UltimoNumero`** como generador de folios fiscales, sin transacción.
- **Órdenes escaneadas y PDF de informes** dentro de la base: **1,1 TB** de los 1,4 TB totales. El
  respaldo completo tarda seis horas y ya no entra en la ventana nocturna.
- **Ninguna llave foránea** hasta 2011. Después se agregaron algunas con `NOCHECK` para que no
  fallaran contra los huérfanos que ya había.
- **`ParaLlamar`**, que sigue viva, con una columna `Llamado` de tipo `bit` y otra `LlamadoDos`
  agregada durante la pandemia.
- **El `.accdb` de turnos** en la PC de recepción, con su campo multivalor.
- **Del lado del portal, MySQL 5.7** —fuera de soporte desde 2023—, con la base que la agencia
  diseñó: sus propias tablas de pacientes, **sin relación con las de SQL Server salvo por el
  nombre y el DNI**, y el protocolo en MD5.
- **Del lado de la red, el SIH sobre Oracle**, con su propio maestro de pacientes, las órdenes y el
  espejo de resultados que devuelve la interfaz.

---

## 5. Quién es quién

**Norma Castellani**, 68 años, bioquímica fundadora y **directora técnica** del laboratorio. Es la
que firma los resultados con su matrícula, y por eso hace la pregunta que el sistema nunca pudo
contestar: *"¿quién cambió este resultado, cuándo, y qué decía antes?"*. No entiende de bases de
datos y no le hace falta; entiende de trazabilidad mejor que cualquier ingeniero. Fue ella la que
frenó el LIS en 2012.

**Rubén Bertolotti**, 74 años, contador, socio fundador y autor de "la base". Se jubiló en 2019 y lo
siguen llamando. Sabe por qué existe cada tabla, y cuando se lo preguntan contesta con el año y el
problema que resolvía, que es exactamente la información que el curso necesita. **Rubén no es el
villano de nada.** Construyó un sistema que sostuvo un negocio durante veinticinco años, de noche
y sin cobrar.

**Matías Ledesma**, 44 años, "el de sistemas del laboratorio". Nunca estudió informática. Sabe
VBA, SQL "del que sale en Access" y T-SQL aprendido a los golpes, y **es la única persona que
entiende el sistema completo**. Conectó los equipos, hizo el EAV y portó el parser. Su EAV fue una
buena idea mal terminada, y él lo sabe. El curso tiene que dejar algo que Matías pueda operar,
porque el día que se vaya el laboratorio no tiene cómo reemplazarlo.

**Verónica Colombo**, 51 años, **gerenta de datos de Horizonte**. Viene de quince años como DBA de
Oracle en un banco y entró a la red en 2012, justo cuando empezaba a comprar clínicas. Integró
nueve. Rigurosa, conservadora y casi siempre con razón. Su propuesta es la más fácil de defender
en un comité.

**Florencia Marchetti**, 34 años, **líder técnica del equipo digital** de Horizonte, que hizo la app.
Viene de startups, es muy buena y **su postura no es un hombre de paja**. Su propuesta tiene un argumento que
el curso le va a tener que conceder en parte.

**Tú**, contratado por Horizonte como **arquitecto de datos** para el proyecto del laboratorio. Te
reportas a Verónica, trabajas con Matías todos los días, te cruzas con Florencia en cada reunión y
le presentas a Norma. Nadie te pidió elegir un motor; te pidieron que el laboratorio deje de
sufrir. Elegir el motor va a ser consecuencia.

---

## 6. ⚔️ Las tres propuestas sobre la mesa

**🏛️ La de Verónica: "el laboratorio es un módulo más del SIH".** Alameda pasa a ser un esquema
del Oracle corporativo, con el equipo de DBA que ya existe, los respaldos que ya existen y la
licencia que ya se paga. Tiene fuerza: una sola fuente de verdad para pacientes y órdenes, y el
fin de la interfaz de mensajes. Es además lo que la doctrina de la red pide. Su punto débil es el
propio SIH: veinte años de reglas ad hoc, un equipo saturado que tarda seis semanas en aprobar una
columna, un costo de licencia que crece con cada núcleo, y el riesgo de meter treinta años de datos
sucios del laboratorio en el sistema que sostiene la internación de catorce clínicas.

**🍃 La de Florencia: "los resultados son documentos".** Florencia tiene un argumento real: hay unos 1.100
tipos de determinación, cada examen tiene una forma distinta y el EAV de Matías es la prueba de
que el modelo relacional no les calzó. Propone que cada protocolo sea un documento en MongoDB, con
sus resultados embebidos tal como se informan, servido directo a la app. Tiene fuerza en la
lectura: un informe es una unidad de lectura evidente. Su punto débil está en todo lo demás:
facturación a obras sociales, precios con vigencia, folios fiscales correlativos, auditoría de
correcciones y cruces epidemiológicos que nadie pidió todavía y que el ministerio va a pedir.

**🐘 La tercera, que todavía no tiene dueño.** Postgres como base del laboratorio: un modelo
relacional pensado de verdad, `jsonb` donde la forma del examen varía de verdad, historia temporal
de resultados y precios, identificadores que no se puedan enumerar, y una API para la app
generada desde el esquema con PostgREST y seguridad por fila. **El curso no la presenta como
la respuesta.** La presenta como la hipótesis que hay que defender contra las otras dos, con
mediciones y con el veredicto honesto de dónde pierde.

---

## 7. 🗺️ Cada dolor apunta a un bloque del curso

| El dolor de Alameda | Lo que enseña | Bloque |
|---|---|---|
| `PEREZ PEDRO DNI 23456789` y el parser de Rubén | atomicidad de valores, 1FN de verdad, restricciones como documentación ejecutable | I · El modelo |
| Una tabla por examen y un EAV para lo nuevo | normalización, los dos extremos del error, y cuándo `jsonb` es la respuesta honesta | I · El modelo |
| Pacientes duplicados, "RN" con DNI de la madre, pasaportes | claves naturales contra sustitutas, dependencias funcionales, identidad de entidad | I · El modelo |
| La genealogía del parser: pasaporte, libretas, residentes, refugiada | el documento como tipo + país + número, la persona separada de sus documentos, reglas declaradas contra reglas escondidas en código | I · El modelo |
| El parser en VBA y en T-SQL que se separaron | una regla en dos lugares siempre diverge; la restricción vive en un solo sitio | I · El modelo |
| `CodINOS`, `CodNBU`, `CodNBU2012` | datos de referencia versionados, equivalencias entre catálogos | I · El modelo |
| `Precios_2002_09` y la vigencia sin fin | tiempo válido, 6FN, tablas temporales, y el costo en joins | I · El modelo |
| "¿Quién cambió este resultado?" | auditoría, historia de sistema, inmutabilidad | I · El modelo |
| Pacientes nacidos en 2025 | tipos y restricciones `CHECK` como primera línea de calidad de dato | I · El modelo |
| Formularios que traen tablas enteras por ODBC | planes de ejecución, N+1, paginación, "la base no estaba lenta" | II · La física |
| 140 M de filas de `ResultadoItem` en texto | estadísticas, cardinalidad, índices sobre datos sucios | II · La física |
| `-1847263541` y el portal enumerado | identificadores: secuencias, UUIDv4/v7, qué filtra cada uno, por qué el MD5 no corrige nada | II · La física |
| 1,1 TB de imágenes y PDF en la base | qué va en la base y qué no, crecimiento, particionado, el respaldo que no entra | II · La física |
| `DMax + 1` y `UltimoNumero` contra el web service fiscal | aislamiento, carreras, folios correlativos sin huecos | III · La concurrencia |
| El formulario abierto a la hora del almuerzo | bloqueos, MVCC y su factura en cada motor | III · La concurrencia |
| La exportación que termina a las 9:40 y la notificación en doce horas | lote contra flujo, la ventana nocturna que se acaba | III / IV |
| La propuesta de Florencia | JSON en el motor relacional, Duality Views, el duelo medido contra Mongo | IV · Lo NoSQL dentro del SQL |
| La app que abre un enlace al portal de 2013 | PostgREST, RLS, el esquema como contrato | V · La base como producto |
| El LIS que no fue y la propuesta de Verónica | migración con historia, maestro de pacientes, el capstone defendido ante el comité | VI · El árbitro |

---

## 8. 📝 Nota de verosimilitud

La historia se apoya en fechas y prácticas reales. Lo marcado con 🔍 **todavía no está
verificado** y no se usa como material hasta que lo esté.

| Hito de la historia | Realidad | Estado |
|---|---|---|
| Computadora importada en 1997 | la convertibilidad (1 peso = 1 dólar, 1991–2001) abarató lo importado | ✅ coherente |
| Office 97 Profesional con Access 97 | Access 97 salió a comienzos de 1997; la edición Profesional lo incluía | ✅ coherente |
| Software sin licencia en PYME | tasas de piratería muy altas en la Argentina de fines de los 90 | ✅ coherente; 🔍 buscar una cifra con fuente si el curso la cita |
| Año de dos dígitos: del 00 al 29 es 20xx | regla de Windows (ventana 1930–2029) | ✅ exacta |
| SQL Server con otro corte para el año de dos dígitos | la opción *two digit year cutoff* vale 2049 por defecto | ✅ exacta |
| Libreta de Enrolamiento y Libreta Cívica | documentos anteriores al DNI; al pasar a DNI se conservaba el número | ✅ coherente; 🔍 confirmar lo del número si un episodio depende de eso |
| DNI de residentes extranjeros en una numeración alta | se asignan en un rango propio muy por encima del de los nativos | 🔍 confirmar el rango antes de citar cifras |
| Certificado de residencia precaria para solicitantes de refugio | documento provisorio mientras se tramita la solicitud | 🔍 confirmar denominación |
| Límite de 2 GB del `.mdb` | desde Access 2000; en Access 97 el límite era 1 GB | ✅ coherente (el techo llega con Access 2003) |
| Objetos OLE que inflan el `.mdb` | las imágenes incrustadas como OLE se guardan sin comprimir | ✅ comportamiento conocido |
| Replicación de Jet con autonuméricos aleatorios | los autonuméricos pasan a aleatorios en bases replicadas | ✅ exacta |
| Nomenclador del INOS con dos unidades | usaba unidad bioquímica y unidad de gasto; el NBU las unificó en la UB | ✅ exacta |
| NBU aprobado en Córdoba en 2005 | primera jornada de elaboración en Córdoba (julio de 2005), aprobado el 25/11/2005; versión 2012; Ley 27.232 de 2015 | ✅ exacta |
| Orden médica y débitos | la falta de orden, diagnóstico o número de afiliado es causa de débito | ✅ exacta |
| Campos multivalor | llegan con Access 2007 y el formato `.accdb`, que no admite replicación | ✅ coherente (turnos es un `.accdb` aparte) |
| Asistente para convertir a SQL Server | existió hasta Access 2010; se quitó en Access 2013 | ✅ coherente en 2011 |
| Tablas vinculadas sin clave: solo lectura | comportamiento documentado de Access con ODBC | ✅ exacta |
| SQL Server 2008 R2 Express, 10 GB por base | 2008 R2 subió el límite de 4 a 10 GB | ✅ exacta |
| Factura electrónica para responsables inscriptos | RG AFIP 3749/2015, obligatoria desde el 1/7/2015 | ✅ exacta |
| Número correlativo exigido por el web service | WSFEv1 rechaza con el error 10016 si el número no es el último autorizado más uno | ✅ exacta |
| Condición de Alameda frente al IVA | se asume S.A. responsable inscripta; los exentos entraron recién con la RG 4290/2018, desde 2019 | 🔍 confirmar con un contador que un laboratorio así sería inscripto |
| MySQL 5.7 fuera de soporte | fin de vida en octubre de 2023 | ✅ exacta |
| AAIP como autoridad de datos personales en 2018 | Decreto 746/2017 le asignó la aplicación de la Ley 25.326 | ✅ exacta |
| Notificación de COVID-19 | obligatoria al SNVS 2.0 (dentro del SISA), modalidad inmediata de 12 horas, también para laboratorios privados | ✅ exacta |
| LIS de proveedores argentinos desde los 2000 | existían varios | 🔍 verificar y, en todo caso, no nombrar ninguno |
| Crisis y devaluación de 2002 | salida de la convertibilidad en enero de 2002 | ✅ exacta |
| Controlador fiscal para servicios de salud | no se usa en la historia porque no se pudo confirmar que aplicara | ⛔ fuera |

🧭 Igual que en Cordillera, lo importante de esta sección no es la nostalgia. Lo importante es que
**cada tabla incómoda del esquema actual tiene un origen razonable y fechable**, y que el curso
puede mirarla a los ojos sin burlarse.

---

## 9. ❓ Lo que este borrador todavía no decide

1. **País y ciudad.** Córdoba (Argentina) se eligió por tres razones: obras sociales con
   convenios distintos, precios que la inflación obliga a versionar y una red que absorbe
   clínicas del interior. Además, el NBU nació en Córdoba. Si el curso prefiere otro país, esos
   tres dolores se tienen que poder reconstruir allí. En Colombia, por ejemplo, el profesional
   sería *bacteriólogo* y el pagador, una EPS.
2. **El tamaño de los datos sintéticos.** Hace falta definir cuánto de los 1,9 M de pacientes y
   los 140 M de `ResultadoItem` cabe en un laboratorio de 16 GB de RAM. La NoSQL Lite ya resolvió
   esto con semilla determinista. El generador tiene que reproducir **la suciedad**: nombres con
   DNI adentro, fechas en el futuro, valores con coma y con punto.
3. ~~Si el `.accdb` de turnos entra en el curso.~~ **Decidido:** Access solo existe en la
   historia. El lector recibe "la caja" (§3, 2026) y la carga en Postgres. Ver `prompts/alcance-del-proyecto.md`
   §9.
4. **Los proyectos boss**, que deberían salir de aquí como en Cordillera: la exportación nocturna,
   el maestro de pacientes, los folios fiscales, el portal y la migración de las 71 tablas anchas,
   cada uno con su sistema roto de partida.

---

## 📚 Fuentes de la verificación

- NBU: [Ley 27.232 en el Boletín Oficial](https://www.boletinoficial.gob.ar/detalleAviso/primera/139391/20160104) ·
  [Bioanálisis, "Nomenclador Bioquímico Único"](https://revistabioanalisis.com/images/flippingbook/Rev19%20n/Nota6.pdf) ·
  [CUBRA, NBU versión 2012](https://cubra.org.ar/wp-content/uploads/2024/07/NBU-Version-2012-Act.-2016.pdf)
- Débitos: [COBITUC, causales de débitos por obra social](http://www.cobituc.org.ar/2021/07/12/causales-de-debitos-por-obra-social/)
- Factura electrónica: [RG AFIP 3749/2015](https://www.argentina.gob.ar/normativa/nacional/resoluci%C3%B3n-3749-2015-244572) ·
  [RG AFIP 4290/2018 para exentos](https://contadoresenred.com/factura-electronica-o-controlador-fiscal-para-todos-rg-4290/) ·
  [Manual del desarrollador WSFEv1](https://www.afip.gob.ar/fe/ayuda/documentos/wsfev1-COMPG.pdf)
- Datos personales: [AAIP en Wikipedia](https://es.wikipedia.org/wiki/Agencia_de_Acceso_a_la_Informaci%C3%B3n_P%C3%BAblica_(Argentina)) ·
  [IAPP, nueva autoridad de aplicación](https://iapp.org/news/a/nueva-autoridad-de-aplicacion-de-la-ley-de-proteccion-de-datos-personales-en-argentina)
- COVID-19: [Ministerio de Salud, notificación y diagnóstico](https://www.argentina.gob.ar/salud/coronavirus/notificacion) ·
  [COFyBCF, notificación obligatoria](https://www.cofybcf.org.ar/noticia.php?n=2626)
- Año de dos dígitos: [Microsoft, cómo Excel trata los años de dos dígitos](https://learn.microsoft.com/en-us/troubleshoot/microsoft-365-apps/excel/two-digit-year-numbers)
