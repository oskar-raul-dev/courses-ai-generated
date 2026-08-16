# ⚡ Miniproyecto 10 · NewSQL — Barlovento

> **Familia:** NewSQL distribuido · **Motor:** CockroachDB · **Línea base:** PostgreSQL de un nodo
> **Cierra:** el minicurso de NewSQL (Fases 21–22) · **Empresa:** 🚢 Barlovento
> **Estado:** opcional · **No entra a la bitácora de medición**

---

## 🏢 La empresa

Barlovento es el operador portuario de
[`h-mini-01-documental-barlovento.md`](h-mini-01-documental-barlovento.md): cuatro terminales y
dos patios extraportuarios entre dos países, doce mil movimientos diarios, y un negocio que
consiste en saber en todo momento qué hay dentro de cada caja y quién puede reclamarla.

Hay una operación que atraviesa la frontera y que es donde vive este miniproyecto: **el
trasbordo**. Un contenedor llega en barco a una terminal del país A, se queda unos días y se
embarca hacia una terminal del país B, donde se entrega. El contenedor es uno. El expediente es
uno. Las autoridades son dos.

Y hay una restricción que no es técnica y decide la arquitectura: **el contrato con la autoridad
de uno de los dos países dice, con todas las letras, que sus registros aduaneros no salen de su
territorio.** No es una recomendación de seguridad; es una cláusula.

## ⚰️ El dolor

**La misma carga liberada dos veces, en dos países, con doce minutos de diferencia.**

Cada terminal tiene su propia base de datos. Esa decisión no fue pereza ni ignorancia: fue la
correcta. Las terminales se construyeron y se compraron por separado, en momentos distintos, y
sobre todo **una terminal tiene que poder operar cuando el enlace se cae** — y el enlace se cae,
porque el mundo real tiene fibra cortada por una retroexcavadora. Un puerto que se detiene
porque no hay internet es un puerto que no sirve.

Lo que se montó encima fue lo natural: **una conciliación nocturna** que cruza los movimientos
de las cuatro terminales y levanta las diferencias. Funciona. Lleva nueve años funcionando.

El problema es que la conciliación es nocturna y la liberación es de las once de la mañana.

**La factura tiene fecha.** El 14 de mayo de 2025, un contenedor en trasbordo se entregó en la
terminal del país A a un transportador con una orden válida, y **doce minutos después** se
entregó otra vez en el patio extraportuario del país B a un segundo transportador, con otra
orden igual de válida. Las dos bases decían que la carga estaba disponible, porque cada una
tenía razón con la información que tenía.

El segundo transportador no existía. Fue un fraude, y fue un fraude **posible porque el sistema
lo permitía**: alguien que conocía la ventana de conciliación esperó a que la hubiera. La carga
se recuperó tres semanas después. Lo que no se recuperó fue la conversación con la autoridad,
que preguntó lo único que había que preguntar: *"¿cuántas veces ha pasado esto sin que ustedes
se enteren?"*. Nadie supo contestar.

## 🎯 El encargo

**Lo pide Mariela Ospina, jefa de operaciones de terminal.**

> *"Necesito que una carga no se pueda entregar dos veces, punto. Y necesito que la terminal
> siga operando si se cae el enlace, porque eso pasa. Y los registros del país B no pueden salir
> del país B. Ya sé cómo suena eso junto. **Dime qué me cuesta cada una de las tres**, porque me
> imagino que no puedo tener las tres gratis."*

## 🧩 Lo que se construye

El libro de movimientos de carga, con la liberación como operación atómica, montado dos veces:

- **CockroachDB con tres localidades** —país A, país B y una tercera para el quórum—, con las
  cargas **geo-particionadas por su país de origen**, de modo que la residencia de datos quede
  declarada en el esquema y no en un documento de intenciones.
- **Postgres de un nodo con réplica de lectura**, que es la alternativa barata y el rival real:
  una base central en un país, con lecturas locales. Es lo que la mayoría haría y hay que
  medirlo bien, no descartarlo de entrada.
- **La liberación como transacción**, en las dos: verificar disponibilidad, marcar entregada y
  registrar el retiro, sin que exista un instante en que otra terminal pueda leer "disponible".

Y el laboratorio que hace real el ejercicio: **latencia entre regiones inyectada, y la
partición de red provocada**, para ver qué hace cada opción cuando se corta el enlace.

## 📐 Lo que se observa

Esta es **la única familia del curso donde el tiempo sí es el argumento**, y está declarado en
`prompts/formato-bitacora-de-medicion.md` §2.4: la latencia entre regiones es física —la
velocidad de la luz entre dos ciudades— y no hardware. Aquí se mide, y se dice por qué se puede.

- **Latencia de confirmación** de la liberación, según dónde esté la carga y desde dónde se
  libera.
- **Saltos de red y rangos tocados** por la transacción, que es la medida estructural que
  explica la latencia en vez de solo reportarla.
- **Tasa de aborto y reintentos** bajo contención: dos terminales intentando liberar la misma
  carga al mismo tiempo, a propósito.
- **Qué pasa en cada opción cuando se parte la red:** qué sigue funcionando, qué se detiene, y
  —lo que de verdad importa— **qué sigue funcionando pero mal**.

## 💥 Dónde se rompe

**La transacción distribuida con contención alta.** Haz que varias terminales peleen por las
mismas cargas y observa cómo suben los abortos y los reintentos hasta que el sistema deja de
avanzar aunque nada haya fallado.

Y el segundo, que es el más instructivo de todos: **en Postgres de un nodo, provoca la partición
de red y mira qué hace la terminal del otro lado.** No da error. Sigue leyendo su réplica, que
está atrasada, y sigue diciendo que la carga está disponible. **Eso es exactamente lo que pasó
el 14 de mayo**, y verlo ocurrir explica el problema mejor que cualquier párrafo.

## ⚖️ El veredicto que tiene que salir

Y aquí está la lección que el curso lleva cinco meses construyendo, así que conviene no
apurarla.

**No es cierto que Barlovento necesite una base distribuida.** Lo que necesita es que **una
operación** —la liberación— sea atómica entre países. Todo lo demás —los movimientos de patio,
las inspecciones, las fichas de carga, la facturación, el tráfico de camiones— es local, se
consulta local, y se resuelve de sobra con un Postgres por terminal.

Esa es la salida correcta, y es una de arquitectura y no de motor: **estrechar la frontera
transaccional hasta que solo quede lo que de verdad la necesita**, y pagar el costo distribuido
únicamente ahí. En volumen, es una fracción mínima de las operaciones de la empresa. En
consecuencia, es el cien por ciento del problema.

El veredicto de la familia, entonces, con las dos caras: **NewSQL cuando necesitas ACID de
verdad sobre varias regiones** — y Barlovento lo necesita, para una sola cosa. **Si te basta una
región, Postgres es más simple, más barato y más rápido**, y la mayoría de quienes proponen esta
familia están en ese caso y no lo han medido.

Y una advertencia que el miniproyecto debe dejar escrita, porque es la trampa de esta familia:
**que hable SQL y sea ACID no lo hace Postgres con más nodos.** El esquema copiado tal cual, sin
pensar la localidad, produce transacciones que cruzan la frontera dos veces para contestar algo
que era local. La geografía tiene que estar en el esquema, y eso hay que diseñarlo.

## 🧰 El stack

| Pieza | Qué se usa | Nota |
|---|---|---|
| Entorno | **Node + TypeScript** | |
| Motor | **CockroachDB** · perfil `newsql` | Tres nodos con **localidad declarada**: país A, país B y el tercero que da el quórum |
| CLI | `cockroach sql` | |
| Driver | **`pg`, el mismo cliente de Postgres** | Habla el protocolo de Postgres, y eso es medio argumento comercial de la familia — **y también la fuente de su trampa** |
| Línea base | **PostgreSQL de un nodo con réplica de lectura** · perfil `base` | Es lo que la mayoría haría. Hay que medirlo bien, no descartarlo de entrada |
| Localidad | Particionamiento por región declarado **en el esquema** | ⚠️ Qué está disponible exactamente en la edición libre se verifica en la sesión de laboratorio y se declara. La geografía va en el esquema, no en la infraestructura |
| Laboratorio de fallos | **Toxiproxy** | Latencia entre regiones inyectada y partición de red limpia. Sin esto el miniproyecto es teoría |
| Medición | `EXPLAIN ANALYZE` (rangos tocados, saltos de red) · abortos y reintentos **contados en el cliente** · latencia de confirmación | **La única familia donde el tiempo es el argumento**, porque es física (`formato-bitacora-de-medicion.md` §2.4) |
| Datos | Generador del curso | Cargas en trasbordo entre los dos países, con contención provocada sobre las mismas |
| Entregable | `src/h-mini-10-newsql-barlovento/` | |

**Qué NO entra:** despliegue real multi-región en la nube, respaldo y restauración, ni
operación del clúster. El **reintento de transacción sí entra como parte del modelo de
programación**, que es la lección de la familia y no un detalle del cliente.

> ⚠️ **Ninguna versión ni digest se escribe aquí.** Viven en `a02` y se fijan ejecutando, en la
> sesión de verificación de laboratorio. Este stack nombra piezas, no números.
>
> 🧭 **Dos reglas del curso que este miniproyecto no puede saltarse.** El **arnés de medida y el
> generador de datos son TypeScript siempre** (alcance §9): son el instrumento, y un instrumento
> con dos implementaciones deja de ser un instrumento. Y **se habla con los motores
> directamente**: nada de ORM, ODM ni cliente de alto nivel (`a06`), porque esas capas esconden
> justo lo que queremos medir.

---

## 🔗 El puente con Cóndor

Es la **Fase 21**, y el paralelo es casi literal. El expediente de una aeronave matriculada en
Ecuador que recibe rutina en el Coca y la inspección mayor en Bogotá es **el mismo trasbordo**:
un objeto, un expediente, dos autoridades, y un contrato que dice que los registros del operador
estatal no salen de su país.

Y la conclusión que tiene que viajar de aquí a Cóndor es la misma, porque es la del curso
entero: **en Cóndor tampoco hace falta distribuir todo.** Hace falta que la liberación al
servicio sea atómica y consistente en los dos lados, y que el resto viva donde le toca. Estrechar
la frontera transaccional antes de distribuirla es el consejo más barato y más ignorado de esta
ruta.

## 📋 Criterios de aceptación

```text
[ ] La liberación es atómica y está demostrado que no se puede ejecutar dos veces
[ ] La residencia de datos está declarada en el esquema, no en un documento aparte
[ ] Está montada la alternativa Postgres de un nodo con réplica, bien jugada
[ ] Está inyectada la latencia entre regiones y medida la confirmación en cada escenario
[ ] Está provocada la partición de red en las dos opciones, y escrito qué hace cada una
[ ] Está documentado el caso "sigue funcionando pero mal", que es el que causó el incidente
[ ] Está medida la tasa de aborto y reintentos bajo contención provocada
[ ] El veredicto identifica qué operaciones NO necesitan ser distribuidas, con su proporción
[ ] Hay al menos una consulta que cruza regiones por un esquema mal localizado, y su arreglo
```
