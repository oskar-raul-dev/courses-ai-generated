# ⚰️ Fase 00 — La decisión que se hereda: nadie eligió mal a propósito

> **Curso:** Ruta NoSQL Lite · Fase 00 de 25 · Bloque 0 — El instrumento · **4 h**
> **Motor:** ninguno — esta fase se lee
> **Entorno de ejecución:** ninguno
> **Depende de:** nada · **Habilita:** Fase 01
> **Apéndices de apoyo:** ninguno
> **Fecha de verificación ejecutada:** 29/09/2026, solo para el mensaje de error de MongoDB que
> cita la sección 4.3 (`mongo:8.0.20`, sin replica set). Lo demás no ejecuta nada.
> **Objetivo:** que reconozcas tu propia decisión en una de estas autopsias antes de que el
> curso te proponga ningún motor.

---

## 🧭 1. Dónde estamos

Todavía no hay contenedores, ni datos, ni un solo `explain`. Hay una empresa y seis decisiones
que alguien tomó con buenas razones y que dos años después costaron caro. Este curso empieza por
ahí porque **casi nadie elige una base de datos desde cero**: la hereda. Llega a un equipo donde
Mongo ya está, o Cassandra, o un Postgres que nadie se atreve a tocar, y la pregunta que de
verdad importa no es "¿cuál es la mejor?", sino **"¿por qué esto duele, y qué habría tenido que
preguntar quien lo eligió?"**.

Escribo para alguien que sabe SQL, sabe qué es un índice y una transacción, y probablemente ya
tomó —o heredó— una de estas decisiones. No voy a explicarte qué es JSON. Sí voy a pedirte que
leas cada autopsia buscando **la pregunta que faltó**, porque de eso trata el curso entero.

El villano de esta historia no es MongoDB, ni Cassandra, ni el hype. Es **elegir con un criterio
que no predice el fracaso**. Las preguntas con las que la gente elige —*"¿tengo esquema fijo?"*,
*"¿quiero evitar joins?"*, *"¿esto escala?"*— suenan técnicas y no discriminan nada. Las que sí
lo hacen son otras cinco, y las vas a ver aparecer, una por una, debajo de cada autopsia.

---

## 🎯 2. Objetivos de esta fase

Al terminarla puedes:

1. Leer una decisión heredada en cinco pasos —decisión, argumento, por qué era razonable, factura
   y costo de salir— sin juzgar a quien la tomó.
2. Señalar, para cada autopsia de esta fase, cuál de las cinco preguntas habría cambiado el
   resultado.
3. Explicar por qué *"elegimos X por moda"* y *"nos quedamos en relacional por comodidad"* son
   la misma decisión tomada por el mismo motivo equivocado.
4. Decir en voz alta que **casi siempre gana Postgres**, y en qué tipo de caso no.

---

## 🚫 3. Qué NO entra todavía

- **Ningún motor ni ninguna medición.** Las cifras de las autopsias de Cóndor salen de su
  historia; las de la industria son escenarios declarados. Medir empieza en la
  [Fase 01](01-el-dominio-de-flota-y-el-arnes.md).
- **Las cinco preguntas desarrolladas.** Aquí se anuncian y se nombran; se convierten en
  instrumento en la [Fase 02](02-las-cinco-preguntas.md).
- **Cómo salir de una decisión ya tomada.** El triaje de migración es de la Fase 02, y cada
  familia trae su propio *"salir de aquí"* en su fase B.

---

## ⚰️ 4. Las autopsias

### 4.1 Cómo se lee una autopsia

Una autopsia se escribe sobre una **decisión**, nunca sobre una persona. Tiene cinco partes, y
siempre en este orden: la decisión en la voz de quien la tomó y con su mejor argumento; por qué
ese argumento era razonable **en ese momento**; qué pasó a los dos años, con número; cuánto costó
salir, con número; y cuál de las cinco preguntas habría cambiado el resultado.

El orden importa. Si empiezas por la factura, lo que escribes es un juicio, y pierdes justo al
lector que más necesita leerlo: el que tomó esa misma decisión. Y si alguna vez te descubres
pensando *"obviamente"*, vuelve al segundo paso. Nadie elige mal a propósito.

### 4.2 Cóndor: la misma empresa, equivocada en las dos direcciones

La empresa de este curso tiene la autopsia más útil de toda la fase, porque se equivocó **dos
veces y en sentidos opuestos**. Una vez por quedarse en el modelo que conocía, y otra por
cambiarse al que prometía resolverlo. Las dos decisiones las tomó gente competente, y las dos
terminaron en el mismo comité.

**`SIGMA`, 2015: la zona de confort.** Cóndor compró a un proveedor local un sistema de
mantenimiento sobre una base relacional. Hacía bien lo que se le pidió en 2015 —órdenes de
trabajo, horas de técnico, facturación— y sigue siendo la fuente de verdad de la plata. El
argumento era impecable: *"lo relacional es lo que sabemos operar, y el negocio es tabular"*.
Era razonable, porque en 2015 Cóndor tenía dos clientes y un solo país.

La factura llegó por el lado que nadie miró: **las aeronaves no tienen los mismos campos**. Un
turbohélice de dieciocho puestos, un monomotor de carga y un helicóptero no comparten casi
nada, y dos aeronaves del mismo modelo tampoco, por el equipamiento opcional. `SIGMA` lo resolvió
como se resuelve siempre en relacional sin pensarlo: **cuarenta columnas anulables y una tabla de
"atributos adicionales" que hoy tiene doce millones de filas**. Leer la ficha de una aeronave es
reconstruirla fila por fila desde esa tabla. La pregunta que faltó fue **la unidad de lectura**:
*¿qué se lee siempre junto?* La ficha completa, de una vez. Y la respuesta honesta, que la
[Fase 04](04-documental-romper-y-medir.md) va a medir, es que ni siquiera hacía falta cambiar de
motor: **una columna JSONB en ese mismo Postgres lo habría resuelto**.

**El sistema de Camilo, 2019: el cambio de paradigma.** Aerotécnica del Sur manejaba componentes,
y un componente tampoco tiene los mismos campos que otro: un instrumento tiene calibración, un
motor tiene ciclos y un neumático tiene recauchados. Camilo Duarte lo modeló en una base
documental con un argumento **correcto**: *"cada componente trae su propia ficha y el esquema va a
cambiar cada vez que entre una familia nueva"*. Tenía razón, y conviene decirlo antes que
cualquier otra cosa: para la ficha de un componente, el modelo documental era el adecuado.

Lo que no previó fue **la segunda colección**. El día que hubo que cruzar componentes con órdenes
de trabajo —qué pieza se instaló en qué orden—, el cruce terminó escrito en el código de la
aplicación: leer de una colección, leer de la otra, y confiar en que ninguna de las dos cambiara
en el medio. Ahí se disolvió la **frontera transaccional**, y nadie lo anotó en ningún lado.

### 4.3 La factura de marzo de 2026

En 2023 Cóndor compró Aerotécnica del Sur, y con ella el sistema de Camilo. Desde entonces hay dos
verdades sobre qué pieza está dónde. En marzo de 2026, un operador pidió el expediente completo
de un actuador de tren:

- `SIGMA` decía que estaba **instalado** en una aeronave que llevaba dos años fuera de la flota.
- El sistema de Camilo decía que estaba **en almacén**.
- Estaba, de hecho, **en un taller aliado de Bogotá desde hacía once meses**, esperando un
  repuesto que nunca llegó.

**Reconstruir esa historia costó cuatro días de tres personas**, y solo se pudo porque Yamile, la
coordinadora de planeación, se acordaba. La pregunta que Lucía hizo en ese comité es la que abre
este curso: *"¿y si hubieran sido cien piezas y no una?"*.

**Cuánto costó salir: todavía no se sabe**, porque Cóndor no ha salido. El sistema que reconcilia
las dos verdades es el proyecto global del curso, y decidir si el de Camilo se retira es el boss
del Bloque V. Lo que sí se sabe es qué pregunta faltaba: **dónde está la frontera
transaccional**. La instalación de una pieza y la orden que la instala son un solo hecho, y en
cuanto viven en dos sistemas sin transacción entre ellos, la divergencia deja de ser un riesgo y
pasa a ser cuestión de tiempo.

> 📝 **La precisión que marca la casa.** Cuando un sistema documental pierde su frontera
> transaccional, la explicación que más se oye es *"Mongo no tenía transacciones"*. No es cierta:
> las tiene, multi-documento, desde la 4.0. La autopsia honesta suele ser otra: **las había, pero
> exigen un replica set, y muchos sistemas se montan sobre un nodo solo**, donde no existen. Es lo
> que responde un Mongo sin replica set cuando se le pide una transacción (`mongo:8.0.20`,
> verificado el 29/09/2026):
>
> ```text
> MongoServerError: Transaction numbers are only allowed on a replica set member or mongos (code 20, IllegalOperation)
> ```
>
> Es la primera entrada de [`a09`](a09-catalogo-de-errores.md), y la Fase 04 la reproduce.

### 4.4 Cuatro autopsias de la industria

Las de Cóndor son reales dentro de la historia del curso. Las siguientes son **escenarios
declarados**: sistemas de un tamaño y una forma típicos, con cifras plausibles que no salen de
ningún caso medido. Están aquí porque cada una retoma una familia del curso y su pregunta.

**"Elegimos Cassandra porque escala."** Un equipo de seis personas esperaba mucho tráfico de
escritura, y Cassandra escribe en paralelo sin un nodo maestro. El argumento era real: si el
tráfico hubiera llegado, un Postgres solo no lo habría aguantado. A los dos años, el volumen seguía
siendo el de un solo nodo, pero el modelo tenía **once tablas para cuatro consultas**, porque en
columnar ancha cada consulta nueva es una tabla nueva más un *backfill*. Cada pedido de producto
("¿podemos filtrar también por región?") costaba una semana. Salir costó un trimestre de doble
escritura. **La pregunta que faltó: ¿conoces tus consultas de antemano, y son estables?** Si la
respuesta es no, esta familia es una trampa cara (Fases 17–18).

**"Metimos el JSON completo y listo."** La API externa devolvía un JSON grande, y guardarlo tal
cual era rápido de programar y no perdía nada. Era razonable: nadie sabía todavía qué campos iban a
importar. A los dos años, los documentos pesaban **2 MB de media**, y la pantalla más usada leía
tres campos de cada uno: **cada lectura traía 2 MB para usar unos cientos de bytes**. **La pregunta
que faltó: ¿cuál es tu unidad de lectura?** Guardar el documento entero es modelar para quien
escribe, no para quien lee (Fases 03–04).

**Redis como almacén primario.** Las sesiones, los candados de las reservas y después "ya que
estamos" los carritos se guardaron en Redis, porque respondía en menos de un milisegundo. Lo era.
El día que el servidor se reinició con la persistencia mal configurada, se perdieron **cuarenta y
cinco minutos de escrituras**, y con ellas reservas que ningún otro sistema tenía. **La pregunta que
faltó: ¿dónde vive la verdad?** Un almacén clave-valor en memoria es un **efecto, no una causa**:
va al lado de la fuente de verdad, nunca en su lugar (Fases 05–06).

**Elasticsearch como fuente de verdad.** El catálogo se cargaba en el buscador para tener
búsqueda con tolerancia a errores, y como ya estaba ahí, las altas nuevas empezaron a escribirse
**solo** ahí. Era cómodo, y durante meses nadie lo notó. Un cambio de *mapping* obligó a
reindexar, y al reconstruir el índice desde la base original faltó el **0,4 % del catálogo**: lo
que se había dado de alta solo en el buscador. **La pregunta que faltó: ¿necesitas exactitud o
parecido?** Un motor de búsqueda existe para devolver lo parecido, y es **un índice, no una fuente
de verdad**: si no se puede reconstruir desde otro sitio, es una segunda verdad (Fases 11–12).

### 4.5 La misma decisión, dos veces

Lee las seis autopsias juntas y aparece el patrón. En `SIGMA`, alguien se quedó en el modelo que
conocía **por comodidad**. En el sistema de Camilo, en Cassandra y en el buscador, alguien cambió
de modelo **por lo que el motor prometía**. Parecen errores opuestos, y el curso los trata como uno
solo: en los dos casos el criterio real fue *qué conozco* o *qué se está usando*, y no *qué modelo
de acceso tiene este dominio*.

**Ninguna de las seis decisiones fue una tontería.** Todas tenían un argumento legítimo con el
instrumento equivocado: *"el esquema va a cambiar"*, *"esto tiene que escalar"*, *"lo relacional es
lo que sabemos operar"*. El curso no te va a enseñar a desconfiar de esos argumentos, sino a
ponerles delante las preguntas que los ponen a prueba. Son cinco:

1. **¿Dónde está la frontera transaccional?** La más cara de ignorar: Camilo, Redis.
2. **¿Conoces tus consultas de antemano, y son estables?** Cassandra.
3. **¿Cuál es la unidad de lectura?** `SIGMA`, el JSON completo.
4. **¿Cuántos saltos tiene tu relación típica?** No aparece en ninguna de estas autopsias, y es la
   que las Fases 13–14 ponen a prueba con la trazabilidad de Cóndor.
5. **¿Necesitas exactitud o parecido?** El buscador como fuente de verdad.

La [Fase 02](02-las-cinco-preguntas.md) las convierte en instrumento.

---

## 🐘 5. Casi siempre gana Postgres

Conviene decirlo ahora y no al final: **la mayoría de las veces, la respuesta honesta es
Postgres**. Tiene JSONB para la ficha que no tiene los mismos campos, búsqueda de texto completo,
`pgvector` para el parecido, `WITH RECURSIVE` para recorrer un árbol, particionado declarativo
para las series y tablas `UNLOGGED` para lo que puede perderse. De las seis autopsias, al menos
dos —`SIGMA` y el JSON completo— se resolvían sin salir de él.

Este curso va a por los casos donde eso **no alcanza**, y los va a demostrar con las dos bases
montadas y medidas, nunca con una cita. Cuando otro motor gane, casi siempre será **al lado** de
Postgres y no en su lugar. Y cuando no gane, lo vas a leer escrito con esas palabras y con el
número delante.

---

## ⚠️ 6. Errores comunes y diagnóstico

En esta fase los errores son de criterio: preguntas que suenan técnicas y no discriminan nada.

- **"¿Tengo esquema fijo?"** Todo sistema tiene esquema. La diferencia es si lo declara la base o
  lo mantiene el código a mano. 🩺 Busca en el código cuántos sitios asumen que un campo existe:
  ese es tu esquema, sin documentar.
- **"¿Quiero evitar joins?"** Los joins no desaparecen: se mudan a la aplicación, como en el
  sistema de Camilo, y se llevan la transacción. 🩺 Pregunta qué pasa si una de las dos lecturas
  cambia en medio.
- **"¿Esto escala?"** Sin un número, no es una pregunta. 🩺 Pide el volumen, la tasa de escritura
  y cuándo se espera llegar a ellos. Si nadie lo sabe, todavía no hay un problema de escala.
- **"Es lo que usa todo el mundo" / "es lo que sabemos operar".** Las dos son la misma pregunta
  superficial (4.5). 🩺 Contesta las cinco preguntas antes de nombrar ningún motor.

---

## 📋 7. Checklist de validación

```text
[ ] Puedo contar una autopsia en sus cinco pasos sin juzgar a quien decidió
[ ] Sé qué pregunta faltó en cada una de las seis autopsias de esta fase
[ ] Puedo explicar por qué SIGMA y el sistema de Camilo son la misma decisión
[ ] Sé por qué "Mongo no tenía transacciones" no es la autopsia honesta
[ ] Puedo nombrar las cinco preguntas, aunque todavía no sepa aplicarlas
[ ] Sé en qué dos autopsias la respuesta era Postgres
```

---

## 🧪 8. Ejercicios (12)

Todos son de lectura y decisión (esta fase es de criterio, no de
ejecución, y por eso lleva doce y no veinte). Ninguno pide levantar nada.

### 🟢 Fácil — leer una autopsia (1–4)

#### 🟢 Ejercicio 1 — Los cinco pasos

Toma la autopsia de *"metimos el JSON completo"* y sepárala en sus cinco partes.

**Objetivo:** identificar cuál de las cinco partes es la más corta en el texto, y por qué no puede
faltar.

#### 🟢 Ejercicio 2 — El mejor argumento

Para cada una de las seis autopsias, escribe en una línea el mejor argumento de quien decidió,
**en su voz**.

**Objetivo:** que ninguna de las seis líneas contenga "obviamente", "por moda" ni "por no saber".

#### 🟢 Ejercicio 3 — La pregunta que faltó

Relaciona cada autopsia con una de las cinco preguntas.

**Pregunta:** ¿qué pregunta no aparece en ninguna, y por qué crees que el curso la guarda para
grafos?

#### 🟢 Ejercicio 4 — Las dos verdades

Con la sección 4.3, dibuja dónde creía cada sistema que estaba el actuador y dónde estaba de
verdad.

**Pregunta:** ¿cuál de los tres lugares no estaba registrado en ningún sistema, y qué dice eso de
dónde vive hoy la verdad en Cóndor?

### 🟡 Intermedio — tu propia decisión (5–8)

#### 🟡 Ejercicio 5 — Tu autopsia

Elige una decisión de base de datos que hayas tomado o heredado y escríbela con los cinco pasos.

**Objetivo:** que el segundo paso —por qué era razonable— sea al menos tan largo como el tercero,
la factura.

#### 🟡 Ejercicio 6 — Reescribir un juicio

Esta frase es un juicio: *"Eligieron Cassandra porque estaba de moda y no entendían el modelo de
datos"*. Reescríbela como el primer paso de una autopsia.

**Objetivo:** conservar la información útil de la frase original sin atribuir la decisión a la
ignorancia de nadie.

#### 🟡 Ejercicio 7 — La factura con número

La autopsia de Redis dice "cuarenta y cinco minutos de escrituras". Propón qué habría que medir
para convertir esa cifra en el costo real para el negocio.

**Pregunta:** ¿qué dato de otro sistema necesitas para saber cuántas reservas se perdieron de
verdad?

#### 🟡 Ejercicio 8 — Postgres primero

Para `SIGMA` y para el JSON completo, describe en tres líneas cómo lo habría resuelto el mismo
Postgres.

**Objetivo:** nombrar la funcionalidad concreta de Postgres en cada caso, sin cambiar de motor.

### 🟠 Difícil — diagnosticar un sistema (9–11)

#### 🟠 Ejercicio 9 — La frontera disuelta

Un sistema guarda los pedidos en Mongo y el stock en Postgres. Al confirmar un pedido, la
aplicación inserta el pedido y después descuenta el stock.

**Pregunta:** ¿dónde está la frontera transaccional, dónde se disuelve y qué ves en los datos
dentro de dos años? Descríbelo como la factura de una autopsia.

#### 🟠 Ejercicio 10 — Las transacciones que sí existían

Un equipo dice: *"Nos fuimos de Mongo porque no tenía transacciones"*.

**Objetivo:** escribir las tres preguntas que harías para saber si esa autopsia es honesta, usando
el mensaje literal de la sección 4.3.

#### 🟠 Ejercicio 11 — Zona de confort o hype

Describe un sistema real o inventado donde **quedarse** en relacional fue el error, y otro donde
**cambiarse** lo fue.

**Pregunta:** ¿qué pregunta de las cinco, contestada a tiempo, habría evitado los dos?

### 🔴 Muy difícil — el comité (12)

#### 🔴 Ejercicio 12 — El comité de marzo

Eres quien presenta en el comité de Cóndor de marzo de 2026. Lucía acaba de preguntar *"¿y si
hubieran sido cien piezas?"*, y Camilo está en la mesa defendiendo su sistema.

**Objetivo:** escribir la primera página del informe: qué pasó, qué pregunta faltó y qué **no**
proponer todavía. La trampa es proponer un motor. La respuesta correcta propone una pregunta, y
deja a Camilo con su mejor argumento intacto.

---

## 📚 9. Referencias

> ⚠️ Las URLs y sus contenidos cambian, y la documentación de estos productos suele cubrir solo
> la última versión.

- **Martin Kleppmann, *Designing Data-Intensive Applications*** (O'Reilly) — el capítulo 2
  (modelos de datos) y el 7 (transacciones) son el fondo teórico de las cinco preguntas. Leer
  antes de la Fase 02.
- **Pramod Sadalage y Martin Fowler, *NoSQL Distilled*** (Addison-Wesley) — corto, y el origen
  del concepto de *agregado*, que es la unidad de lectura con otro nombre.
- **Transacciones en MongoDB** — https://www.mongodb.com/docs/manual/core/transactions/ — qué
  exigen y desde qué versión.
- **Persistencia en Valkey** — https://valkey.io/topics/persistence/ — RDB, AOF y qué se pierde
  con cada una.
- **Tipos JSON de PostgreSQL** — https://www.postgresql.org/docs/current/datatype-json.html — lo
  que `SIGMA` tenía a mano.

**Orden sugerido:** esta fase entera antes que cualquier otra; Kleppmann antes de la Fase 02; los
enlaces de documentación, cuando una fase los retome.

---

## 🏁 10. Resultado de la fase

No levantaste nada, y eso es parte del resultado: ahora sabes qué buscar antes de levantarlo. Tienes
seis autopsias, la pregunta que faltó en cada una y la idea que ordena el resto del curso: **la
decisión mala casi nunca es tonta; es una buena preocupación con el instrumento equivocado**.

> **La señal de que quedó bien:** *"Puedo contar la decisión que heredé sin culpar a nadie, y sé
> cuál de las cinco preguntas no se hizo."*

> 🏷️ **Tag:** `fase-00-la-decision-que-se-hereda` · prefijo de commit `f00:`
