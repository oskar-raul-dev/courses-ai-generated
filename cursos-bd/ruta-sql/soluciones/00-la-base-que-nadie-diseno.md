# ✅ Soluciones — Fase 00: La base que nadie diseñó

> **Curso:** Ruta SQL · Solucionario de la [Fase 00](../00-la-base-que-nadie-diseno.md)
> **Ejercicios:** 12 · **Perfil:** no aplica · **Motores:** ninguno: la fase se lee
> **Fecha de verificación ejecutada:** no aplica: los datos salen de la
> [historia de Alameda](../00-historia-de-alameda.md), revisada el 12/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–4)

### Ejercicio 1

**Enunciado (resumen):** ubicar los cinco pasos en la autopsia de `DMax + 1`.

**Solución.**

1. **La decisión:** *"El número más alto que hay, más uno. Con la letra de la sede adelante, para que
   no choquen."*
2. **Por qué era razonable:** *"Cada sede tenía una PC, con su réplica."* Sin concurrencia, leer el
   máximo y sumar uno es correcto.
3. **Qué pasó después:** los repetidos de 2005 (*"dos o tres veces por semana"*) y el error 10016 de
   2015, con la caja trabada y cuarenta pacientes esperando.
4. **Cuánto costó salir:** *"No se salió"*: `UltimoNumero` bajó los rechazos a uno por mes, y en 2020
   pasó a bloquear la caja.
5. **La pregunta que faltó:** *¿dónde está la frontera transaccional?*

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-1--los-cinco-pasos)

### Ejercicio 2

**Enunciado (resumen):** la tabla que dejó cada año y el problema que resolvía.

**Solución.**

| Año | Qué quedó | Qué resolvía |
|---|---|---|
| 1997 | `Recibos`, y después `Pacientes` con el DNI dentro de `Nombre` | imprimir un recibo sin tipear el nombre cada vez |
| 2002 | `Precios_2002_09` y las siguientes | saber cuánto valía una práctica un mes ya pasado |
| 2004 | `NroProtocolo` con `DMax + 1` | un número legible cuando la replicación hizo aleatorios los autonuméricos |
| 2008 | `ResultadoItem` | cargar lo que exportan los equipos sin una tabla nueva por examen |
| 2015 | `UltimoNumero` | el número correlativo que exige la factura electrónica |

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-2--la-tabla-que-dejó-cada-año)

### Ejercicio 3

**Enunciado (resumen):** clasificar cuatro frases según la cara del villano.

**Solución.**

- *"`varchar(255)` en todo, por las dudas"* → **la base como pote**: usa el motor sin pedirle que
  defienda ningún valor.
- *"MongoDB porque no tiene esquema"* → **Mongo por moda**: el esquema existe igual, en el código; la
  frase descarta lo relacional sin saber qué ofrece.
- *"El aislamiento que viene por defecto"* → **la base como pote**: no es un error en sí, pero dicho
  sin saber qué anomalía deja pasar, es usar el motor sin conocerlo.
- *"Medimos y la unidad de lectura es el documento"* → **ninguna**: es una decisión con una pregunta
  y una medición detrás, aunque termine en Mongo.

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-3--las-dos-caras)

### Ejercicio 4

**Enunciado (resumen):** el mejor argumento de Verónica y el de Florencia, en su voz.

**Solución de referencia.**

- **Verónica:** *"Tenemos una sola fuente de verdad para pacientes y órdenes en catorce clínicas, y
  la única pieza que se rompe todas las semanas es la interfaz con el laboratorio. Si el laboratorio
  vive en el mismo Oracle, esa interfaz deja de existir, con DBA, respaldos y licencia que ya
  pagamos."*
- **Florencia:** *"Hay mil cien tipos de determinación y cada uno tiene su forma; el EAV de Matías
  demuestra que una tabla no les calza. Lo que la app muestra es el informe entero, y un informe es un
  documento. Guardémoslo como se lee."*

> ⚠️ **Error típico:** agregar el punto débil dentro del argumento ("aunque el SIH es lento…"). El
> ejercicio pide el mejor argumento, no el balance.

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-4--el-mejor-argumento)

## 🟡 Intermedio (5–8)

### Ejercicio 5

**Enunciado (resumen):** la autopsia de las tablas `Precios_AAAA_MM`.

**Solución de referencia.**

1. **La decisión** (Rubén, 2002): *"El día 1 de cada mes copio `Precios` en una tabla con el mes en el
   nombre. Así nunca más pierdo un precio."*
2. **Por qué era razonable:** la tabla `Precios` tenía un valor por práctica y se pisaba. En septiembre
   una obra social pidió refacturar marzo, y Rubén tuvo que reconstruirlo a mano desde los recibos
   impresos durante **tres fines de semana**. Una copia mensual resolvía exactamente eso, con lo que
   sabía hacer en Access.
3. **Qué pasó después:** **280 tablas** de 2002 a 2025, una por mes. Saber el precio de una práctica en
   una fecha exige saber qué tabla abrir, y comparar dos meses es un `UNION`.
4. **Cuánto cuesta salir:** en 2025 Matías pasó a una tabla con `vigencia_desde` **sin fin**, y cuando
   dos vigencias se superponen no se puede saber cuál regía. Salir de verdad pide unificar las 280 en
   un modelo temporal, que es trabajo del Bloque I.
5. **La pregunta que faltó:** *¿este dato tiene tiempo?* Un precio no es un valor: es un valor durante
   un período, y el período es parte de la clave.

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-5--la-autopsia-de-precios_2002_09)

### Ejercicio 6

**Enunciado (resumen):** una decisión propia que fue correcta y dejó de serlo sin que nadie la tocara.

**Rúbrica.** No hay solución única: es tu sistema. Una respuesta correcta tiene que:
- describir la decisión en la voz de quien la tomó, con su mejor argumento;
- nombrar **qué cambió alrededor** (volumen, concurrencia, un integrante nuevo, una regulación) y no
  qué cambió en el código;
- nombrar la regla que el esquema no declaraba y que habría avisado.

Y queda invalidada si:
- la decisión era incorrecta desde el primer día: entonces no es un `DMax + 1`, es otro problema.

Un ejemplo que cumple: un número de pedido calculado como `count(*) + 1` en un sistema con un solo
vendedor, que empieza a repetirse el día que se suma la tienda en línea.

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-6--tu-dmax--1)

### Ejercicio 7

**Enunciado (resumen):** por qué `UltimoNumero` baja los rechazos a uno por mes y no a cero, con dos
sesiones intercaladas.

**Solución.** `UPDATE` primero reduce la ventana: entre leer y escribir ya no pasa el tiempo de cargar
un formulario, sino el de dos sentencias. Pero sin transacción, **cada sentencia confirma sola**, y la
ventana entre las dos sigue existiendo:

```text
DOS CAJAS, UN NÚMERO

caja 1                                       caja 2
──────                                       ──────
UPDATE UltimoNumero SET Numero = Numero + 1
  → 48213, confirmado
                                             UPDATE UltimoNumero SET Numero = Numero + 1
                                               → 48214, confirmado
SELECT Numero FROM UltimoNumero → 48214
                                             SELECT Numero FROM UltimoNumero → 48214
emite 48214                                  emite 48214   ← el web service rechaza los dos
```

Nadie emite el 48213, y las dos piden el 48214. El web service espera exactamente el último autorizado
más uno, el 48213, así que **rechaza los dos** con el error 10016, no solo el segundo (la
[Fase 16](../16-el-folio-sin-huecos.md) lo reproduce contra un organismo simulado). Con más cajas y más carga, la ventana se
cruza más seguido: por eso en 2020 el problema volvió. Lo que lo cierra es que el `UPDATE` y el
`SELECT` sean **una sola operación** (`UPDATE … RETURNING`, por ejemplo) o una transacción que bloquee
la fila, que es lo que mide la [Fase 16](../16-el-folio-sin-huecos.md).

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-7--ultimonumero)

### Ejercicio 8

**Enunciado (resumen):** las tres razones de datos por las que se abandonó el LIS de 2012.

**Solución.**

1. **La historia, incompleta.** Se migró desde 2008 (`ResultadoItem`), y las 71 tablas anchas quedaron
   para "una segunda etapa". Norma no firmó sin los antecedentes de los crónicos. *Pregunta que faltó:*
   ¿qué datos tiene que poder leer quien firma, y desde cuándo?
2. **Los pacientes, multiplicados.** El importador no entendía `PEREZ PEDRO DNI 23456789` y creaba un
   paciente por variante. *Pregunta que faltó:* ¿qué identifica a una persona?, que es exactitud o
   parecido.
3. **La facturación.** El LIS tenía NBU y un precio por obra social; Alameda tenía coseguros, topes,
   prácticas que se facturan juntas y convenios con fecha de corte. Los débitos se triplicaron.
   *Pregunta que faltó:* ¿dónde están las reglas del negocio, y quién las sabe?

Las tres son de modelo de datos, y por eso la historia dice que comprar un sistema no resuelve el
problema de fondo.

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-8--el-lis-de-2012)

## 🟠 Difícil (9–11)

### Ejercicio 9

**Enunciado (resumen):** dos autopsias de 2031 de la propuesta de Verónica: si sale mal y si sale bien.

**Solución de referencia.** La misma decisión de partida: *"el laboratorio pasa a ser un esquema del
Oracle de la red"*.

- **Sale mal** si los datos del laboratorio entran como están: el maestro de pacientes de la red hereda
  los duplicados de Alameda, las reglas ad hoc del SIH se suman a las de "la base", y cada columna nueva
  espera seis semanas. Pregunta que faltó: *¿qué hay que limpiar antes de unificar?*
- **Sale bien** si la migración separa primero el modelo del laboratorio, lo limpia con reglas en el
  esquema y recién entonces lo integra, y si el laboratorio consigue un circuito de cambios más corto
  que el del resto del SIH. La interfaz de mensajes desaparece, que era su mejor argumento.

**Rúbrica.** Una respuesta correcta tiene que:
- partir de la misma decisión en las dos;
- poner la diferencia en **cómo** se ejecuta y en qué se limpia antes, no en el motor;
- tener números o hechos de la historia en el paso 3 de cada una (las seis semanas, las catorce
  clínicas, los duplicados).

Y queda invalidada si:
- la versión mala culpa a Oracle como motor.

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-9--la-propuesta-de-verónica-en-una-autopsia-futura)

### Ejercicio 10

**Enunciado (resumen):** dónde el argumento de Florencia es fuerte y dónde es débil, con datos de la
historia.

**Solución de referencia.**

| Fuerte | Dato |
|---|---|
| el informe de resultados | la app y el portal muestran el informe entero, y es lo que más piden los pacientes |
| la variedad de exámenes | unos 1.100 tipos de determinación, cada uno con su forma |
| el EAV no calzó | `ResultadoItem` guarda todo como texto, y el informe hace `UNION` con las tablas anchas |

| Débil | Dato |
|---|---|
| el folio fiscal | el web service exige el último más uno: una frontera transaccional entre comprobantes |
| los precios | 280 tablas mensuales y vigencias superpuestas: el precio depende del tiempo |
| la auditoría | Norma pregunta quién cambió un resultado, cuándo y qué decía antes |
| los cruces | la notificación de COVID y los pedidos del ministerio cruzan pacientes, prácticas y fechas |

**Rúbrica.** Una respuesta correcta tiene que:
- tener al menos tres filas de cada lado, cada una con un dato de la historia;
- separar la lectura (donde Florencia gana) de la escritura, la facturación y la auditoría.

Y queda invalidada si:
- trata la propuesta como un error sin concederle la lectura.

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-10--lo-que-florencia-tiene-de-razón)

### Ejercicio 11

**Enunciado (resumen):** tres parches del parser y la regla que cada uno codificaba sin declararla.

**Solución de referencia.**

- **2003, el pasaporte:** *un documento tiene tipo, país emisor y número, y el número de un pasaporte
  no es un DNI.*
- **2005, las libretas:** *una persona puede tener varios documentos a lo largo de su vida, y el mismo
  número con otro tipo es otro documento de la misma persona.*
- **2008, los recién nacidos:** *un paciente puede no tener documento todavía, y ese estado es válido;
  el documento de la madre no es el suyo.*

Otras válidas: 2019 (*"existen documentos que el sistema no conoce, y el tipo tiene que admitirlo"*) y
2016 (*"una regla vive en un solo sitio"*, que la copia en T-SQL rompió).

**Rúbrica.** Una respuesta correcta tiene que:
- escribir cada regla como una afirmación sobre los datos, no como un `if`;
- poder imaginarse como una tabla, una clave o un `CHECK`.

Y queda invalidada si:
- describe lo que hace el código ("busca la palabra `PASAP`") en lugar de la regla.

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-11--la-regla-escondida)

## 🔴 Muy difícil (12)

### Ejercicio 12

**Enunciado (resumen):** un guion de cinco minutos ante el comité, sin recomendar todavía, con tres
mediciones.

**Solución de referencia.** Un guion que cumple:

> *"Las tres propuestas resuelven algo real. La de Verónica elimina la interfaz con el SIH; la de
> Florencia sirve el informe tal como se lee; la de Postgres pone las reglas en el esquema. Antes de
> elegir voy a medir tres cosas sobre una copia de nuestros datos: cuántos pacientes duplicados hay de
> verdad y cuántos encuentra cada enfoque; cuánto cuesta leer un informe completo en un modelo
> relacional contra un documento; y si un folio correlativo resiste diez cajas concurrentes en cada
> propuesta. Si el informe relacional cuesta varias veces más que el documento y nada más lo compensa,
> la propuesta de Florencia gana esa parte. Si la limpieza de pacientes no se puede hacer antes de
> unificar, la de Verónica pierde su mejor argumento. Vuelvo con los números."*

**Rúbrica.** Una respuesta correcta tiene que:
- conceder el mejor argumento de cada propuesta antes de nombrar las mediciones;
- nombrar mediciones concretas sobre datos de Alameda, no "evaluar el rendimiento";
- decir **qué resultado cambiaría la recomendación**.

Y queda invalidada si:
- recomienda una propuesta;
- usa una medición que no se puede repetir, o un tiempo como argumento.

[← Volver al ejercicio](../00-la-base-que-nadie-diseno.md#-ejercicio-12--cinco-minutos-ante-el-comité)
