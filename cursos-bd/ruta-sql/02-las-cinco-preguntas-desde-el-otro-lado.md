# ❓ Fase 02 — Las cinco preguntas, desde el otro lado: qué parte de Alameda es relacional y cuál no

> **Curso:** Ruta SQL · Fase 02 de 27 · Bloque 0 — El instrumento · **3 h**
> **Motores:** ninguno: esta fase se lee
> **Entorno de ejecución:** ninguno
> **Depende de:** Fase 01 · **Habilita:** Fase 03
> **Apéndices de apoyo:** ninguno
> **Fecha de verificación ejecutada:** no aplica: esta fase no ejecuta nada; las cifras de la caja
> salen de la [Fase 01](01-la-caja-y-el-arnes.md) y de [`a05`](a05-la-caja-y-el-generador.md)
> **Objetivo:** que puedas contestar las cinco preguntas sobre cada parte de Alameda, decir cuál es
> relacional y cuál no con un argumento, y ordenar qué se toca primero en una base que no se puede parar.

---

## 🧭 1. Dónde estamos

La [Fase 00](00-la-base-que-nadie-diseno.md) terminó con una pregunta debajo de `DMax + 1`. La
[Fase 01](01-la-caja-y-el-arnes.md) montó el instrumento que mide: la caja cargada y el plan leído por
sus bloques. Esta fase entrega el otro instrumento, el que no mide nada y decide casi todo: **las cinco
preguntas**.

Son las mismas que la Ruta NoSQL Lite presenta en su segunda fase, y no se repiten aquí. Allí sirven para
descubrir cuándo un motor NoSQL gana; aquí se contestan **desde el lado relacional**, sobre un sistema
que ya está en producción, y cada una se convierte en un argumento a favor o en contra del modelo
relacional para una parte concreta de Alameda. Vuelven en el veredicto de cada fase, contestadas para lo
que esa fase enseñó.

---

## 🎯 2. Objetivos de esta fase

1. Explicar por qué *"¿esquema fijo?"* y *"¿necesito escalar?"* no predicen nada.
2. Contestar las cinco preguntas para el comprobante, el informe, la presentación a la obra social, la
   búsqueda de pacientes y el nomenclador.
3. Conceder con datos la parte de Alameda donde la respuesta no es relacional.
4. Ordenar el triaje de una base heredada que no se puede parar.

---

## 🚫 3. Qué NO entra todavía

- **Las mediciones.** Cada pregunta se mide en su bloque: la frontera transaccional en el III, la unidad
  de lectura en el IV.
- **La deduplicación de pacientes.** La pregunta 5 la anticipa; la [Fase 05](05-una-persona-no-es-su-documento.md) la resuelve.
- **La migración.** El triaje dice qué va primero; cómo se hace sin parar es la [Fase 25](25-la-migracion-sin-parar.md).

---

## ❓ 4. Las cinco preguntas, aplicadas a Alameda

### 4.1 Las dos preguntas que no predicen nada

*"¿Tengo esquema fijo?"* y *"¿necesito escalar?"* son las dos con que empieza casi toda discusión entre
lo relacional y lo NoSQL, y ninguna distingue un sistema que va a funcionar de uno que va a fallar.

**El esquema existe siempre.** Alameda tiene el esquema más flexible que se puede tener: 1.219 columnas
`varchar` de 1.766, el DNI dentro del nombre, la edad como texto libre. Y tiene un esquema rígido igual,
escondido en un parser que pasó de cuarenta a casi trescientas líneas. La pregunta útil no es si el esquema
es fijo, sino **dónde vive**: en el motor, que lo hace cumplir, o en el código, que se acuerda o no.

**"Escalar" sin un número no es una pregunta.** Alameda procesa unos 3.000 protocolos por día y la caja
de M carga 1,3 millones en un portátil. El techo de Alameda nunca fue el volumen: fue `DMax + 1` con dos
recepcionistas, y la exportación que terminaba a las 9:40. Las dos son de concurrencia y de diseño, y
ninguna se arregla con más máquinas.

### 4.2 ¿Dónde está la frontera transaccional?

**La pregunta:** ¿qué hechos tienen que cambiar juntos, o ninguno?

**Desde el lado relacional, es la carta más fuerte.** El comprobante fiscal es el ejemplo perfecto: un
número que tiene que ser exactamente el último autorizado más uno, un comprobante con sus líneas, y un
protocolo que pasa a "facturado". Si cualquiera de los tres queda a medias, el web service rechaza el
siguiente o la obra social debita la práctica. Un motor relacional defiende esa frontera con una
transacción y una restricción, en el mismo sitio donde viven los datos. Fuera de él, se defiende con
código que alguien tiene que acordarse de mantener, y `UltimoNumero` sin transacción es lo que pasa
cuando nadie se acuerda.

**En Alameda:** el comprobante, la corrección de un resultado con su auditoría (Norma pregunta quién lo
cambió y qué decía antes) y la factura con sus prácticas. Las tres cruzan filas y tablas, y las tres
son relacionales.

### 4.3 ¿Conoces tus consultas de antemano?

**La pregunta:** ¿sabes hoy qué le vas a preguntar a estos datos dentro de dos años?

**Desde el lado relacional, no saberlo es una ventaja.** Un modelo normalizado responde con SQL preguntas
que nadie hizo cuando se diseñó. En 2020, el ministerio pidió notificar cada caso de COVID en doce
horas, y Alameda lo hizo copiando de una consulta de Access a una planilla: los datos estaban, aunque el
camino fuera malo. El cruce epidemiológico del año que viene no se puede modelar hoy, y en un modelo
relacional tampoco hace falta.

**En Alameda:** la presentación mensual a la obra social es la consulta que Rubén escribió en 1997 y que
"un día dio mal". Cruza pacientes, afiliaciones, prácticas, códigos de tres nomencladores y precios de un
mes. Cambia cada vez que una obra social cambia su convenio. Es relacional, y cada vez que alguien la
quiso precalcular, se desactualizó.

### 4.4 ¿Cuál es la unidad de lectura?

**La pregunta:** ¿qué se lee junto, casi siempre, de una sola vez?

**Esta es la que Florencia contesta bien, y el curso se la concede desde ahora.** El informe de laboratorio
*es* una unidad de lectura evidente: un protocolo, sus prácticas y sus resultados, unos nueve por protocolo
en la caja (12,1 millones de resultados para 1,3 millones de protocolos), leídos siempre juntos, por el
paciente en la app y por el médico en el portal. Hay unos 1.100 tipos de determinación, cada uno con su
forma, y el EAV de Matías demuestra que una tabla rígida no les calzó. Para leer un informe, un documento
gana, y el Bloque IV lo mide.

**La pregunta de verdad es si esa unidad de lectura es también la de escritura, la de auditoría y la de
facturación.** En Alameda no lo es. Los resultados llegan de a uno, desde cada equipo, a horas distintas;
se corrigen de a uno, con su auditoría; y se facturan por práctica, no por informe. El informe se lee como
documento, y se escribe y se cobra como filas.

### 4.5 ¿Cuántos saltos tiene tu relación típica, y los conoces?

**La pregunta:** ¿cuántas relaciones recorres para contestar lo habitual, y sabes de antemano cuántas son?

**Desde el lado relacional, uno o dos saltos conocidos son su terreno.** El nomenclador tiene prácticas que
se componen de otras (un perfil lipídico son cuatro determinaciones), y la cadena de derivaciones va del
médico al protocolo y del protocolo al paciente. Son pocos saltos, se conocen, y un `JOIN` o un `WITH
RECURSIVE` los resuelven.

**En Alameda no aparece** lo que rompe a un motor relacional: buscar un patrón de profundidad desconocida,
como "todos los contactos de un contacto hasta donde lleguen". Si alguna vez aparece, es la parte que hay
que mirar con otro motor, y la NoSQL Lite tiene la familia para eso.

### 4.6 ¿Necesitas exactitud o parecido?

**La pregunta:** ¿la respuesta tiene que ser exacta, o alcanza con la más parecida?

**Casi todo en Alameda es exactitud**: un precio, un número de comprobante, el valor de una glucemia. Y
hay una parte que es **parecido**, y es la que más duele: **la búsqueda de pacientes**. `PEREZ PEDRO` y
`PERES PEDRO JOSE` pueden ser la misma persona; en M, el 17,5 % de las filas de `Pacientes` repite a
alguien, y la [Fase 01](01-la-caja-y-el-arnes.md#46-la-prueba-de-fuego) mostró que un `LIKE` exacto
encuentra 18.936 de los 25.575 documentos escritos en el nombre.

Es el único sitio del curso donde el motor relacional tiene que hacer algo que no es su naturaleza. La
[Fase 05](05-una-persona-no-es-su-documento.md) mide hasta dónde llega Postgres con `pg_trgm` y una tabla de identidades, y dónde hace falta
otra cosa.

### 4.7 Las cinco, por partes

**Se contestan por partes, no para el sistema entero.** Alameda no tiene *una* respuesta: cada parte
contesta distinto, y por eso un mismo sistema puede terminar con más de un modelo.

| Parte de Alameda | Frontera transaccional | Consultas conocidas | Unidad de lectura | Saltos | Exactitud |
|---|---|---|---|---|---|
| El comprobante fiscal | **cruza tablas**: número, líneas, protocolo | sí, y fijas | el comprobante | 1–2 | exacta |
| El informe de resultados | dentro del protocolo | sí | **el informe entero** | 1 | exacta |
| La presentación a la obra social | la presentación del mes | **no: cambia con cada convenio** | filas de muchas tablas | 3–4, conocidos | exacta |
| La búsqueda de pacientes | ninguna | sí | el paciente | 1 | **parecido** |
| El nomenclador | la versión del catálogo | sí | la práctica con sus equivalencias | 1–2, recursivos | exacta |

Leída por columnas, la tabla dice dónde pierde el modelo relacional: **la unidad de lectura del
informe**, a favor de Florencia, y **el parecido de la búsqueda**, que es un problema para todos. Leída
por filas, dice que cuatro de las cinco partes son relacionales sin discusión.

---

### 4.8 Ya está en producción: el triaje

> 📝 **Escenario de Alameda.** El encargo de la historia: un sistema de treinta años, unas 420 tablas,
> 3.000 protocolos por día y una condición, que el laboratorio no pare ni un día. La NoSQL Lite trae el
> triaje para salir de una base documental mal elegida; este es el de una base relacional mal usada, y
> el orden es distinto.

**1. Nada se toca hasta tener una copia que se pueda medir.** La caja existe por eso: Matías no le dio
acceso de escritura a nadie, y tenía razón. Todo lo que el curso propone se prueba primero sobre
`legacy`, con la prueba de fuego pasada.

**2. Contesta las cinco preguntas por partes**, como en la tabla de arriba. Casi nunca está mal todo.

**3. Lo primero que se toca es lo que hoy pierde dinero, datos o la ley**, no lo más feo. En Alameda, en
este orden: el folio fiscal (un rechazo por mes, y la caja trabada cuando hay carga), los resultados que
el portal expone (2018, catorce mil informes), y el respaldo que ya no entra en la ventana nocturna. Las
280 tablas de precios son feas y pueden esperar: duelen una vez por mes, a mano.

**4. Las reglas nuevas entran sin romper lo viejo.** Una restricción nueva sobre datos sucios falla el
día que se crea. La salida no es la de 2011, `WITH NOCHECK` para siempre, sino crearla **sin validar lo
existente, validarla después de limpiar**, y medir cuántas filas faltan cada semana. Postgres lo hace con
`NOT VALID` y `VALIDATE CONSTRAINT`, y el Bloque I lo usa.

**5. Cada entidad tiene un solo sitio donde se escribe**, también durante la convivencia. El parser en
VBA y su copia en T-SQL son la prueba de lo que pasa cuando una regla vive en dos lugares: en 2019 se
separaron, y nadie se enteró.

**6. Se mide que va bien con números que no dependen de nadie**: filas rechazadas por regla, por semana,
y un criterio de salida escrito antes de empezar. El Bloque I lo arma con la tabla de rechazos, y el
Bloque VI lo defiende ante el comité.

> 🧭 **El orden es el triaje.** Empezar por lo más feo en lugar de por lo más caro es la forma más común
> de pasar un año migrando sin que el laboratorio deje de sufrir.

---

## 🐘 5. Lo que el motor relacional ya te daba

Si las cinco respuestas dicen que la frontera cruza tablas, que las consultas no se conocen del todo, que
la unidad de lectura cambia según quién lea, que los saltos son pocos y que hace falta exactitud, **la
respuesta por defecto es un modelo relacional bien hecho**. Ese perfil describe a cuatro de las cinco
partes de Alameda.

**Deja de serlo en dos sitios**, y el curso los mide en lugar de esconderlos: la lectura del informe, que
el Bloque IV pone frente a un documento en Mongo y frente al `jsonb` del propio Postgres, y la búsqueda por
parecido, que la [Fase 05](05-una-persona-no-es-su-documento.md) lleva hasta su límite. Si en alguno de los dos el modelo relacional pierde, el
veredicto lo dice con el número delante.

---

## ⚠️ 6. Errores comunes y diagnóstico

- **Contestar las preguntas para el sistema entero.** "Alameda es relacional" es tan inútil como "Alameda
  son documentos". La respuesta útil es por parte.
- **Contestar con el motor ya elegido.** Si tus respuestas coinciden exactamente con lo que ofrece el motor
  que preferías, contéstalas otra vez pensando en el que no.
- **Negarle a Florencia la unidad de lectura.** Es la pregunta que gana, y negarla quita credibilidad a todo
  lo demás que el curso le discute.
- **Empezar el triaje por lo más feo.** Las 280 tablas de precios invitan, y no son lo que más cuesta.
- **Leer "exactitud o parecido" como un detalle.** Es la pregunta que decide si la deduplicación es una
  consulta o un proyecto.

---

## 📋 7. Checklist de validación

- [ ] Sé explicar por qué *"¿esquema fijo?"* y *"¿necesito escalar?"* no predicen nada.
- [ ] Puedo contestar las cinco preguntas para cada parte de la tabla de la sección 4.7.
- [ ] Puedo conceder la unidad de lectura del informe con el dato que la sostiene.
- [ ] Puedo ordenar el triaje de Alameda y defender el orden.

---

## 🧪 8. Ejercicios (12)

Ninguno se ejecuta: son de lectura y de decisión. Las soluciones traen una respuesta de referencia y,
desde los 🟠, una rúbrica.

## 🟢 Fácil — contestar (1–4)

### 🟢 Ejercicio 1 — La pregunta que falta

Para cada una de estas decisiones de Alameda, di cuál de las cinco preguntas faltó: `DMax + 1`,
`ResultadoItem` con el valor como texto, el parser en VBA y en T-SQL, las 280 tablas de precios.

**Objetivo:** una pregunta por decisión, con una línea de razón.

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-1)

### 🟢 Ejercicio 2 — El esquema que sí había

Señala tres sitios de Alameda donde el esquema existía aunque no estuviera en el motor.

**Objetivo:** tres reglas, cada una con el lugar donde vivía.

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-2)

### 🟢 Ejercicio 3 — La frontera del comprobante

Lista los hechos que tienen que cambiar juntos cuando la caja emite un comprobante.

**Objetivo:** al menos tres hechos, y qué pasa si uno queda a medias.

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-3)

### 🟢 Ejercicio 4 — La unidad de lectura del informe

Describe en tres líneas qué se lee junto cuando un paciente abre su informe en la app.

**Objetivo:** qué entidades, cuántas filas aproximadas en la caja y por qué eso favorece a Florencia.

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-4)

## 🟡 Intermedio — decidir (5–8)

### 🟡 Ejercicio 5 — Turnos

Contesta las cinco preguntas para el módulo de turnos, el `.accdb` de 2008 con su campo multivalor.

**Objetivo:** las cinco respuestas y una conclusión: ¿es relacional?

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-5)

### 🟡 Ejercicio 6 — `ParaLlamar`

Contesta las cinco preguntas para la tabla `ParaLlamar`, que la recepción recorre con el teléfono en la
mano.

**Objetivo:** las cinco respuestas, y si la tabla tiene que existir en el modelo nuevo.

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-6)

### 🟡 Ejercicio 7 — Escritura contra lectura

El informe se lee como documento y se escribe como filas.

**Pregunta:** ¿qué tendría que pasar en Alameda para que la unidad de escritura también fuera el
informe, y quién lo pagaría?

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-7)

### 🟡 Ejercicio 8 — Un dominio tuyo

Elige un sistema que conozcas, pártelo en cuatro partes y arma la tabla de la sección 4.7 para él.

**Objetivo:** la tabla completa y la parte que, según ella, no sería relacional.

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-8)

## 🟠 Difícil — diagnosticar (9–11)

### 🟠 Ejercicio 9 — "¿Esquema fijo?"

En una reunión, alguien defiende Mongo para Alameda porque "los exámenes cambian todo el tiempo y
necesitamos esquema flexible".

**Objetivo:** una respuesta de un párrafo que conceda lo que tiene de cierto y reformule la pregunta.

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-9)

### 🟠 Ejercicio 10 — El triaje, con otro orden

Un colega propone empezar por unificar las 280 tablas de precios, "que es lo más vergonzoso".

**Objetivo:** contestar con el orden del triaje y el costo de cada opción.

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-10)

### 🟠 Ejercicio 11 — La restricción que no se puede crear

Quieres que `Pacientes.FechaNac` no acepte fechas futuras, y la caja de M tiene 442.

**Pregunta:** ¿qué pasa si creas el `CHECK` hoy, qué hizo SQL Server en 2011 con las claves foráneas, y
cuál es el camino del paso 4 del triaje?

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-11)

## 🔴 Muy difícil — el plan del lunes (12)

### 🔴 Ejercicio 12 — El primer mes

Es lunes, te acaban de dar el encargo y Verónica te pide un plan para el primer mes.

**Objetivo:** un plan de una página con las primeras cuatro cosas que tocarías, en orden, con la pregunta
o el dato que justifica cada una y lo que **no** vas a tocar todavía.

[Solución](soluciones/02-las-cinco-preguntas-desde-el-otro-lado.md#ejercicio-12)

---

## 📚 9. Referencias

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 12/10/2026.

- **[Laboratorio Alameda, la empresa del curso](00-historia-de-alameda.md)** — las partes del sistema y sus
  dolores, con fecha.
- **Martin Kleppmann y Chris Riccomini, *Designing Data-Intensive Applications*, 2.ª ed., O'Reilly, 2026** —
  el capítulo de modelos de datos, para la unidad de lectura y la forma de los datos.
- **`ALTER TABLE … NOT VALID` en Postgres 18** — https://www.postgresql.org/docs/18/sql-altertable.html — el
  mecanismo del paso 4 del triaje.
- **C. J. Date, *SQL and Relational Theory*, 3.ª ed., O'Reilly, 2015** — por qué el esquema en el motor es
  una regla y no una formalidad.

**Orden sugerido:** esta fase entera; Kleppmann, cuando llegues al Bloque IV.

---

## 🏁 10. Resultado de la fase

Tienes los dos instrumentos del curso: el que mide, de la Fase 01, y el que decide, de esta. Sabes qué
parte de Alameda es relacional sin discusión, cuál le concedes a Florencia y dónde el problema es de
todos. El Bloque I empieza por la que más duele, el nombre con el DNI adentro, en las
fases 03 y 04.

> **La señal de que quedó bien:** *"Puedo decirle a Florencia en qué tiene razón con un número, y a
> Verónica qué tocaría primero el lunes y por qué."*

> 🏷️ **Tag:** `fase-02-las-cinco-preguntas-desde-el-otro-lado` · prefijo de commit `f02:`
