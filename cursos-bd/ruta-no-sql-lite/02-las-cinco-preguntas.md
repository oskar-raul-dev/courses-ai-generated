# ❓ Fase 02 — Las cinco preguntas: el instrumento que decide antes que el motor

> **Curso:** Ruta NoSQL Lite · Fase 02 de 25 · Bloque 0 — El instrumento · **3 h**
> **Motor:** ninguno — esta fase se lee
> **Entorno de ejecución:** ninguno
> **Depende de:** Fase 01 · **Habilita:** Fase 03
> **Apéndices de apoyo:** ninguno
> **Fecha de verificación ejecutada:** no aplica: esta fase no ejecuta nada
> **Objetivo:** que puedas contestar las cinco preguntas sobre un sistema **antes** de nombrar
> ningún motor, y planificar la salida cuando la decisión ya se tomó mal.

---

## 🧭 1. Dónde estamos

La [Fase 00](00-la-decision-que-se-hereda.md) terminó con seis decisiones heredadas y una pregunta
que faltó debajo de cada una. La [Fase 01](01-el-dominio-de-flota-y-el-arnes.md) montó el
instrumento de medida y lo calibró contra Postgres. Esta fase entrega el otro instrumento, el que
no mide nada y decide casi todo: **las cinco preguntas**.

Son la parte del curso que no se puede copiar de la documentación de nadie, porque la
documentación de cada motor explica lo que el motor hace bien, y estas preguntas sirven para
descubrir **lo que tu dominio necesita**, con independencia del motor. Se presentan aquí completas
y vuelven al final de cada minicurso, contestadas para esa familia.

Y la fase cierra con la sección que más vas a usar en tu trabajo: qué hacer cuando la decisión ya
se tomó mal y hay 400 GB en producción.

---

## 🎯 2. Objetivos de esta fase

1. Contestar las cinco preguntas sobre cada parte de un sistema, no sobre el sistema entero.
2. Nombrar el modo de fallo que predice cada pregunta cuando se contesta mal o no se contesta.
3. Explicar por qué la frontera transaccional es **la que más caro sale ignorar**.
4. Usar las respuestas para **descartar** familias, no para elegir un producto.
5. Planificar un triaje de migración: qué se migra primero, cómo se convive y cómo se mide que va
   bien.

---

## 🚫 3. Qué NO entra todavía

- **Las respuestas por familia.** Cada minicurso trae las suyas en su fase B, con medición.
- **La mecánica de la sincronización entre motores** —doble escritura, outbox, CDC—: aquí se
  nombra, y se desarrolla y se mide en la Fase 24.
- **El caso de Cóndor.** Tiene exactamente el problema del triaje de la sección 4.7, y lo resuelve
  el boss del Bloque V.

---

## ❓ 4. Las cinco preguntas

### 4.1 Por qué las habituales no predicen nada

*"¿Tengo esquema fijo?"*, *"¿quiero evitar joins?"*, *"¿esto escala?"*. Las tres suenan a
ingeniería, y ninguna distingue un sistema que va a funcionar de uno que va a fallar. Todo sistema
tiene esquema, declarado o escondido en el código; los joins no desaparecen, se mudan a la
aplicación; y "escala" sin un número no es una pregunta. La
[Fase 00](00-la-decision-que-se-hereda.md) mostró las seis autopsias a las que llevan.

Las cinco que siguen tienen una propiedad que aquellas no tienen: **cada una predice un modo de
fallo concreto**. Contestarla mal no da un sistema peor en general, sino una factura con fecha y
con forma reconocible. Y se contestan **por partes**. Cóndor no tiene *una* respuesta: la ficha de
aeronave, el catálogo, la trazabilidad y los parámetros de vuelo contestan distinto, y por eso un
mismo sistema puede acabar con más de una familia.

### 4.2 ¿Dónde está la frontera transaccional?

**La pregunta:** ¿qué hechos tienen que cambiar juntos, o no cambiar ninguno? ¿Y esos hechos viven
en el mismo agregado o cruzan entidades?

**En Cóndor:** instalar una pieza es un solo hecho con dos caras: la orden de trabajo que la
instala y la pieza que pasa a estar en esa aeronave. Si una cara se escribe y la otra no, la
empresa tiene dos verdades. Y la frontera más cara de todas es la **liberación al servicio**: un
inspector firma con su licencia que todo lo instalado tiene trazabilidad válida. Esa firma no
puede apoyarse en datos a medio escribir.

**El modo de fallo que predice:** **inconsistencias sin fecha de entrada.** Cuando la frontera
cruza dos agregados —dos colecciones, dos servicios, dos motores— y nada la sostiene, no pasa nada
el primer día ni el primer mes. Se nota dos años después, cuando alguien pide un expediente y los
dos sistemas no coinciden, y ya no hay forma de saber desde cuándo.

**Por qué es la que más caro sale ignorar:** porque **cuando se disuelve, no avisa**. Las otras
cuatro preguntas, contestadas mal, dan errores que se ven: una consulta lenta, un índice que no
cabe, un resultado que no es el que se buscaba. Esta da datos que parecen correctos. El sistema de
Camilo funcionó durante años con la frontera disuelta, y la factura llegó en forma de cuatro días
de tres personas reconstruyendo un solo actuador. Por eso se contesta **primero**: si la respuesta
dice que la frontera cruza agregados, las demás preguntas se contestan dentro de esa restricción.

### 4.3 ¿Conoces tus consultas de antemano, y son estables?

**La pregunta:** ¿puedes escribir hoy la lista de consultas que el sistema va a hacer, y va a seguir
siendo la misma dentro de un año?

**En Cóndor:** *"los parámetros de vuelo de una aeronave entre dos fechas"* es conocida y estable:
es la única forma en que se consultan. *"¿En qué aeronaves estuvo alguna vez una pieza de este
lote?"* no lo es: llega un jueves, con una directiva que nadie esperaba, y hay que contestarla ese
día.

**El modo de fallo que predice:** **cada consulta nueva cuesta un rediseño.** Casi toda la familia
NoSQL modela para las consultas: en columnar ancha, literalmente, cada consulta nueva es una tabla
nueva más un *backfill*. No es un defecto, es el trato. Y la ironía que conviene tener delante: la
gente suele elegir NoSQL justamente cuando **menos** conoce sus consultas, porque confunde
*"no sé qué voy a necesitar"* con *"necesito flexibilidad"*. Si no conoces tus consultas, lo
flexible es el modelo relacional, que te deja escribir la que no previste.

### 4.4 ¿Cuál es la unidad de lectura?

**La pregunta:** cuando el sistema lee, ¿lee un agregado entero —una ficha, un expediente— o
rebanadas de muchos agregados —tres columnas de un millón de filas—?

**En Cóndor:** la ficha de una aeronave se lee entera, siempre: matrícula, configuración y
equipamiento opcional, de una vez. El costo por hora volada es lo contrario: horas y costos de
todas las órdenes de un modelo en un año, y ningún otro campo de esas órdenes.

**El modo de fallo que predice:** **traer lo que no se usa, o ir a buscar muchas veces lo que se
usa junto.** Si la unidad es el agregado y lo partes en tablas, cada lectura es un viaje por
tabla, y el N+1 de la Fase 01 lo mostró con números: 66 viajes donde bastaba uno. Si la unidad son
rebanadas y guardas agregados enteros, cada lectura trae documentos completos para usar tres
campos, que es la autopsia del *"JSON completo"*. Es la pregunta que separa documental de
columnar, y la que decide dentro de documental si se embebe o se referencia (Fases 03–04).

### 4.5 ¿Cuántos saltos tiene tu relación típica, y los conoces de antemano?

**La pregunta:** para contestar tus consultas, ¿cuántas relaciones hay que recorrer? ¿Siempre las
mismas, o depende de los datos?

**En Cóndor:** el despiece es un árbol de profundidad conocida: una aeronave tiene conjuntos, y un
conjunto tiene piezas. La trazabilidad no: una pieza estuvo en una aeronave, salió a un taller
aliado, volvió como intercambio con otro número de serie y se instaló en otra aeronave. **El
camino y la profundidad no se conocen hasta recorrerlos.**

**El modo de fallo que predice:** en un sentido, **pagar un motor de grafos por uno o dos saltos**
que un `JOIN` resuelve. En el otro, **una consulta que no se puede escribir**: la búsqueda de
patrones de profundidad desconocida, con ciclos. La parte incómoda para el instinto es que
Postgres, con `WITH RECURSIVE`, aguanta mucho más de lo que la mayoría cree. Lo que rompe no es la
profundidad, es el patrón. Las Fases 13–14 lo miden, y es donde el curso espera perder una apuesta
en público.

### 4.6 ¿Necesitas exactitud o parecido?

**La pregunta:** ¿la respuesta correcta es **la** que coincide, o **las** que se parecen?

**En Cóndor:** el número de parte `32-424956-06` es una pregunta de exactitud, aunque los
proveedores lo escriban de cuatro formas. *"Esto ya lo vimos"* sobre un reporte de piloto es una
pregunta de parecido: *"ruido metálico al bajar tren"* tiene que encontrar *"golpeteo al extender"*,
y ninguna búsqueda por palabra clave las une.

**El modo de fallo que predice:** usar un índice de parecido donde hacía falta exactitud —un
buscador o un índice vectorial como fuente de verdad, la autopsia del 0,4 % del catálogo— o una
búsqueda exacta donde hacía falta parecido: un `LIKE` que encuentra lo que ya sabías que existía.
Es la frontera entre búsqueda por texto y búsqueda vectorial, y la única familia del curso sin
equivalente relacional razonable (Fases 11–16).

### 4.7 Ya elegiste mal: el triaje

> 📝 **Escenario declarado.** Un sistema de reservas de 400 GB en una base documental, con la
> frontera transaccional disuelta entre reservas e inventario, como la del sistema de Camilo. Las
> cifras son de un escenario típico, no de un caso medido.

Es lunes y el sistema duplica reservas una vez por semana. Nadie puede parar el negocio, y
reescribirlo todo en un fin de semana es la segunda mala decisión del mismo equipo. El triaje
tiene seis pasos, y el orden es lo que lo hace funcionar.

**1. Contesta las cinco preguntas por partes, no por sistema.** Casi nunca está mal todo. En el
escenario, las fichas de producto están bien modeladas como documentos: la unidad de lectura es el
agregado y nadie las cruza con nada. Lo que está mal es **una frontera**: reserva e inventario, que
tienen que cambiar juntos y viven en dos colecciones. Eso, y solo eso, es lo que se migra primero.

**2. Una sola fuente de verdad por entidad, siempre.** Durante la convivencia habrá datos en las dos
bases, pero cada entidad tiene **un solo sistema donde se escribe**, y el otro recibe una copia. La
tentación es escribir en las dos desde la aplicación —la doble escritura—, y **entre dos sistemas
sin una transacción que los una** es la forma más rápida de fabricar dos verdades: basta que una
de las dos escrituras falle. Hay equipos que la usan igual, como Stripe (en las referencias), y la
sostienen con lo que el paso 3 describe: comparan las dos lecturas todo el tiempo y alertan de cada
diferencia. Sin esa comparación, no la uses. Las alternativas que no dependen de ella son el patrón
*outbox* y la captura de cambios (CDC), que se miden en la Fase 24.

**3. Primero las lecturas, en sombra.** Antes de mover una sola escritura, el sistema nuevo recibe
la copia y **se leen los dos a la vez**, comparando respuestas sin mostrárselas a nadie. Las
diferencias salen antes de que cuesten algo, y cada una es un error del modelo nuevo o una
inconsistencia vieja que nadie había visto.

**4. Después las escrituras, por segmentos.** Una base, un país, un tipo de reserva: se cambia la
fuente de verdad de un segmento, se observa y se sigue. Nunca todo a la vez. Mientras el sistema
viejo siga recibiendo la copia, **volver atrás es cambiar una bandera**, no una migración inversa.

**5. Mide que va bien, con números que no dependan de la opinión de nadie.** La reconciliación es
parte del sistema, no un script que se corre una vez:

- conteos por partición en las dos bases, cada noche;
- sumas de control de los campos que importan (importes, estados, cantidades);
- una muestra de registros comparados campo a campo;
- **divergencias nuevas por día**, que tienen que tender a cero y no volver a subir.

Y un **criterio de salida escrito antes de empezar**: por ejemplo, treinta días seguidos sin
divergencias en un segmento antes de apagar su copia vieja. Sin ese criterio, la convivencia no
termina nunca.

**6. Decide qué no se migra.** El histórico frío que nadie lee puede quedarse donde está en solo
lectura, o exportarse a archivos. Migrar datos que no se consultan es trabajo sin retorno.

En el escenario, eso da una convivencia de meses, no de un fin de semana. Es el precio honesto de
salir, y conviene decirlo en la primera reunión y no en la quinta.

> 🧭 **Cóndor tiene exactamente este problema**: `SIGMA` y el sistema de Camilo, con la frontera
> entre instalaciones y órdenes de trabajo disuelta desde 2023. Aplicarle este triaje —y decidir si
> el sistema de Camilo se retira o se queda como índice— es el boss del Bloque V, *"Las dos
> verdades"*.

---

## 🐘 5. Casi siempre gana Postgres

Si las cinco respuestas dicen que la frontera transaccional cruza entidades, que las consultas no
se conocen del todo, que la unidad de lectura cambia según la pantalla, que los saltos son pocos y
que hace falta exactitud, **la respuesta es un Postgres bien modelado**. Y ese perfil describe a la
mayoría de los sistemas de gestión que existen.

Las cinco preguntas no están hechas para elegir un motor NoSQL. Están hechas para **descartar** con
argumentos, y lo más frecuente es que descarten todas las familias menos una. A partir de la
[Fase 03](03-documental-levantar-y-modelar.md), cada minicurso va a buscar la parte de un dominio
donde la respuesta sí cambia, y lo va a medir.

---

## ⚠️ 6. Errores comunes y diagnóstico

- **Contestar con el motor ya elegido.** Si las respuestas coinciden con lo que ofrece el motor que
  querías, sospecha. 🩺 Contéstalas en voz alta ante alguien que defienda otra familia.
- **Contestar por el sistema entero.** *"Nuestra unidad de lectura es el documento"* casi nunca es
  cierto para todo. 🩺 Lista las cinco pantallas más usadas y contesta la tercera pregunta para cada
  una.
- **Confundir "no sé mis consultas" con "necesito flexibilidad".** 🩺 Si no puedes escribir hoy las
  diez consultas principales, la segunda pregunta ya descartó la mitad de las familias.
- **Saltarse la primera pregunta porque "todavía no hay transacciones".** 🩺 Busca los sitios del
  código que escriben en dos lugares seguidos. Cada uno es una frontera sin dueño.
- **Migrar todo de una vez, o con doble escritura.** 🩺 Si el plan no tiene lecturas en sombra ni
  criterio de salida, todavía no es un plan de migración.

---

## 📋 7. Checklist de validación

```text
[ ] Puedo enunciar las cinco preguntas y el modo de fallo de cada una
[ ] Sé explicar por qué la frontera transaccional se contesta primero
[ ] Puedo contestar las cinco por partes, para al menos cuatro partes de Cóndor
[ ] Sé por qué "no conozco mis consultas" favorece al relacional
[ ] Puedo describir los seis pasos del triaje en orden
[ ] Sé qué criterio de salida pondría a una convivencia de dos bases
```

---

## 🧪 8. Ejercicios (12)

Todos son de lectura y decisión (fase de criterio, como la 00: doce ejercicios y no veinte). Cada uno describe un dominio y
pide contestar las cinco preguntas y defender una familia, o planificar una salida.

### 🟢 Fácil — contestar (1–4)

#### 🟢 Ejercicio 1 — Cuatro partes de Cóndor

Contesta las cinco preguntas para la ficha de aeronave, el catálogo de partes, la trazabilidad y
los parámetros de vuelo.

**Objetivo:** una tabla de 4 × 5 donde ninguna fila coincida entera con otra.

#### 🟢 Ejercicio 2 — La frontera de la liberación

Enumera los hechos que tienen que ser ciertos a la vez cuando un inspector libera una aeronave.

**Pregunta:** ¿cuántas entidades del dominio cruzan? ¿Viven hoy en un solo sistema en Cóndor?

#### 🟢 Ejercicio 3 — Conocidas y estables

Escribe las cinco consultas que Yamile hace cada semana y marca cuáles son estables.

**Pregunta:** ¿cuál llegaría un jueves sin aviso, y qué familia la haría costosa?

#### 🟢 Ejercicio 4 — Exactitud o parecido

Clasifica: buscar un número de serie; *"juntas del tren parecidas a esta"*; el reporte más
parecido a uno nuevo; las órdenes de un técnico.

**Objetivo:** justificar cada respuesta con el modo de fallo de la sección 4.6.

### 🟡 Intermedio — decidir (5–8)

#### 🟡 Ejercicio 5 — Un taller de motos

Una red de talleres de motos quiere registrar reparaciones, repuestos y el historial de cada moto.

**Objetivo:** contestar las cinco preguntas y defender una familia, o defender que basta con
Postgres.

#### 🟡 Ejercicio 6 — Sensores en una planta

Una planta registra 4000 sensores cada segundo y consulta siempre por sensor y rango de fechas.

**Pregunta:** ¿qué pregunta decide más aquí, y qué te obligaría a cambiar de opinión?

#### 🟡 Ejercicio 7 — El buscador de un marketplace

Un marketplace quiere búsqueda con tolerancia a errores, y el equipo propone guardar los productos
solo en el buscador.

**Objetivo:** encontrar la pregunta que contesta a esa propuesta y escribir la objeción en una
línea, sin juzgar a nadie.

#### 🟡 Ejercicio 8 — La red social interna

Una empresa quiere sugerir *"personas con quienes podrías colaborar"* a partir de proyectos
compartidos.

**Pregunta:** ¿cuántos saltos tiene la relación, los conoces de antemano, y alcanza con
`WITH RECURSIVE`?

### 🟠 Difícil — diagnosticar (9–11)

#### 🟠 Ejercicio 9 — Dónde se disolvió

Un sistema de pedidos guarda el pedido en un servicio y el cobro en otro, y cada tanto aparecen
pedidos cobrados dos veces.

**Objetivo:** señalar la frontera, explicar por qué no avisó y proponer dónde tiene que vivir.

#### 🟠 Ejercicio 10 — El criterio de salida

Para el triaje de la sección 4.7, escribe el criterio de salida del primer segmento.

**Pregunta:** ¿qué medirías cada noche, qué umbral pondrías y qué harías si la divergencia vuelve a
subir el día 25?

#### 🟠 Ejercicio 11 — Lo que no se migra

En el escenario del triaje, el 70 % de los 400 GB son reservas de hace más de tres años.

**Objetivo:** decidir qué hacer con ellas, y qué pregunta tendrías que hacerle al negocio antes.

### 🔴 Muy difícil — el plan del lunes (12)

#### 🔴 Ejercicio 12 — Tu sistema

Toma un sistema real que conozcas, contesta las cinco preguntas por partes y escribe el triaje como
si tuvieras que presentarlo el lunes.

**Objetivo:** un plan con qué se migra primero, cómo se convive, cómo se reconcilia y cuándo se
termina. Si al contestar las preguntas descubres que no hay que migrar nada, escríbelo: también es
un resultado.

---

## 📚 9. Referencias

> ⚠️ Las URLs y sus contenidos cambian.

- **Martin Kleppmann, *Designing Data-Intensive Applications*** (O'Reilly) — capítulo 2 para la
  unidad de lectura, capítulo 7 para la frontera transaccional y capítulo 11 para la captura de
  cambios.
- **Martin Fowler, *Strangler Fig Application*** —
  https://martinfowler.com/bliki/StranglerFigApplication.html — reemplazar un sistema por partes
  mientras sigue funcionando.
- **Martin Fowler, *Parallel Change*** — https://martinfowler.com/bliki/ParallelChange.html —
  cambiar una interfaz en tres fases sin romper a quien la usa.
- **Stripe, *Online migrations at scale*** — https://stripe.com/blog/online-migrations — un triaje
  real en cuatro pasos: doble escritura, cambio de las lecturas, cambio de las escrituras y borrado
  del modelo viejo, con las dos lecturas comparadas en producción (Scientist).

**Orden sugerido:** esta fase antes de cualquier minicurso; Fowler y Stripe antes de escribir tu
propio triaje; Kleppmann cuando una fase lo cite.

---

## 🏁 10. Resultado de la fase

Tienes los dos instrumentos del curso: el que mide, de la Fase 01, y el que decide, de esta. Desde
aquí, cada minicurso toma una familia, la monta, la mide contra el Postgres de la Fase 01 y termina
contestando estas cinco preguntas para ella.

> **La señal de que quedó bien:** *"Antes de nombrar un motor, puedo decir qué familias descarta mi
> dominio y por qué, y si ya elegí mal, sé por dónde empezar a salir."*

> 🏷️ **Tag:** `fase-02-las-cinco-preguntas` · prefijo de commit `f02:`
