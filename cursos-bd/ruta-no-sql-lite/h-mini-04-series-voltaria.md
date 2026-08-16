# ⏱️ Miniproyecto 04 · Series temporales — Voltaria

> **Familia:** series temporales · **Motor:** TimescaleDB · **Línea base:** PostgreSQL particionado
> **Cierra:** el minicurso de series temporales (Fases 09–10) · **Empresa:** ⚡ Voltaria
> **Estado:** opcional · **No entra a la bitácora de medición**

---

## 🏢 La empresa

Voltaria es una distribuidora eléctrica regional. Pasó de cuarenta mil a novecientos mil
clientes en doce años y tres adquisiciones, y arrastra de cada una de ellas un sistema, una
numeración de activos y un equipo que sigue haciendo las cosas como las hacía antes.

De esos novecientos mil clientes, **trescientos cuarenta mil tienen medidor inteligente** que
reporta cada quince minutos. Los demás siguen con lectura mensual, la de toda la vida, hecha
por una persona que camina. Esa convivencia —dos poblaciones de medidores con dos cadencias que
se diferencian en cuatro órdenes de magnitud— es la primera decisión de modelado del
miniproyecto y la que más gente resuelve mal.

El regulador les exige conservar las lecturas cinco años y poder producirlas cuando las pida.

## ⚰️ El dolor

**Borrar el año pasado tarda dos días y bloquea la facturación.**

En 2014, cuando el piloto de medición inteligente eran ocho mil medidores, alguien creó la
tabla `reading` con el medidor, el instante, la magnitud y el valor, más un índice sobre
medidor y fecha. Era la decisión correcta y es la que habría tomado cualquiera. Funcionó
durante seis años.

Hoy esa tabla recibe **más de treinta millones de filas al día** y es la más grande de la
empresa por dos órdenes de magnitud. Tres cosas se rompieron, y ninguna de golpe:

**La retención.** Pasados los cinco años hay que borrar, y borrar es un `DELETE` que recorre,
marca, genera trabajo de limpieza y compite con todo lo demás. La última purga se corrió en
dos tandas de fin de semana y aun así invadió el lunes de facturación.

**El espacio.** Nadie comprimió nunca nada, porque la tabla se diseñó cuando comprimir no hacía
falta. El almacenamiento crece de forma lineal e imparable, y la conversación anual con
finanzas ya es un rito.

**Y la cardinalidad, que es la que nadie vio venir.** En 2022 empezaron a medir por fase
—tres fases, con voltaje, corriente y potencia cada una— y lo que era una serie por medidor se
volvieron nueve. Nadie lo pensó como una decisión: se agregó una columna y se siguió. A partir
de ahí, las consultas que antes tardaban segundos empezaron a tardar minutos, y la explicación
que circuló internamente fue *"es que hay más datos"*, que es verdad y no explica nada.

**La factura tiene fecha.** En julio de 2025 el regulador pidió el detalle de un circuito para
un período de reclamación de hacía cuatro años. **Tardaron nueve días en producirlo** y la
consulta hubo que correrla de noche para no tumbar la facturación. La respuesta llegó fuera de
plazo.

## 🎯 El encargo

**Lo pide Édgar Nieto, gerente de medición.**

> *"Necesito tres cosas y ninguna es un tablero. Que borrar el año viejo no me tumbe el lunes.
> Que el disco deje de crecer como crece. Y que cuando el regulador me pida cuatro años atrás
> yo pueda contestarle el mismo día. Si además me dices **cuánto me habría costado hacerlo bien
> desde el principio**, mejor, porque esa conversación la voy a tener con la junta."*

## 🧩 Lo que se construye

El mismo histórico de lecturas, modelado tres veces y medido en las tres:

- **La tabla tal como está hoy**, para tener el punto de partida. Es el villano y hay que
  construirlo de verdad, no describirlo.
- **Postgres con particionado declarativo por rango de tiempo**, que es la respuesta sin
  extensiones: la que le ahorra un componente a Voltaria si alcanza.
- **La hypertable con compresión, política de retención y agregados continuos** —de quince
  minutos a hora, de hora a día—, que es la que hay que justificar con números si va a entrar.

Más la decisión de modelado que atraviesa las tres: **qué identifica una serie**, y qué pasa
con la cardinalidad cuando la respuesta incluye la fase.

## 📐 Lo que se observa

- **Particiones o chunks tocados** por cada uno de los tres regímenes de consulta: el día de
  ayer al detalle, el mes pasado agregado, y el mismo mes contra el del año anterior.
- **Tamaño en disco antes y después de comprimir**, por año de antigüedad.
- **El costo de borrar un año**: `DELETE` contra desprender una partición. No es una diferencia
  de porcentaje y por eso vale la pena verla.
- **El efecto de la cardinalidad**: la misma consulta con una serie por medidor y con nueve.

## 💥 Dónde se rompe

**La explosión de cardinalidad**, y hay que provocarla. Añade una dimensión más a la clave de
la serie —el número de fase, y después el tipo de tarifa— y observa cuándo el motor deja de
poder con los metadatos de las series antes que con los datos.

Y el segundo, que es el que más se parece a la vida real: **el backfill.** Llega una corrección
de un medidor con dos meses de retraso, y hay que meterla en un período que ya está comprimido.
Averigua qué cuesta eso, porque es la diferencia entre "los datos llegan ordenados" como
hipótesis y como hecho.

## ⚖️ El veredicto que tiene que salir

**El particionado declarativo de Postgres resuelve la retención, que era el dolor urgente.**
Desprender una partición es instantáneo frente a un `DELETE` que tarda dos días, y eso no
necesita ninguna extensión. Ese solo cambio le habría devuelto el lunes de facturación a
Voltaria.

**La compresión y los agregados continuos son lo que justifica la extensión**, y hay que decirlo
por separado: son otro problema y otra factura. Si Voltaria solo tuviera el problema de borrar,
la respuesta honesta sería *"esto lo resuelve Postgres y no necesitas nada más"*.

Y el tercer veredicto, que es el que cierra la familia: **series temporales cuando los datos
llegan ordenados, no se actualizan y se consultan por rango.** Voltaria cumple dos de tres —las
correcciones retroactivas existen— y el diseño tiene que hacerse cargo de esa tercera en vez de
suponer que no pasa.

> 🧭 **Y un puente hacia adelante que conviene dejar abierto.** A trescientos cuarenta mil
> medidores esto cabe en un nodo bien afinado. Cuando Voltaria termine de instalar los
> novecientos mil y empiece a medir por fase, dejará de caber — y esa es exactamente la
> pregunta del Bloque IV. El miniproyecto debe terminar diciendo **a qué volumen** deja de
> caber, no si dejará de caber.

## 🧰 El stack

| Pieza | Qué se usa | Nota |
|---|---|---|
| Entorno | **Node + TypeScript** | |
| Motor | **TimescaleDB** · perfil `series` | Es una extensión de Postgres: **mismo `psql`, mismo driver, mismo dialecto**, y ese es medio argumento de la familia |
| Línea base | **PostgreSQL** con particionado declarativo por rango · perfil `base` | Más la tabla plana de hoy, construida de verdad como villano |
| Driver | `pg` para las tres formas | Un solo cliente contra tres modelos es lo que hace limpia la comparación |
| Modelado | Hypertable · compresión por antigüedad · política de retención · agregados continuos | Las cuatro son **parte del modelo**, no mantenimiento |
| Medición | `EXPLAIN (ANALYZE, BUFFERS)` · chunks tocados · `pg_total_relation_size` y las funciones de tamaño de la extensión | El tamaño antes y después de comprimir es la medición central |
| Datos | Generador del curso | **Dos poblaciones de medidores**: 340 k cada 15 minutos y el resto mensual. Un generador uniforme esconde el problema de cardinalidad |
| Entregable | `src/h-mini-04-series-voltaria/` | |

**Qué NO entra:** Grafana ni ninguna capa de visualización —es 🔥 opcional y no forma parte del
núcleo—, replicación, ni alta disponibilidad. El backfill sobre un período comprimido **sí**
entra, porque es donde la hipótesis "los datos llegan ordenados" se pone a prueba.

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

Es la **Fase 09**: los parámetros de vuelo que se descargan al aterrizar son la misma forma de
dato —llegan ordenados, no se corrigen, se consultan por rango y por aeronave— con dos
diferencias que vale la pena señalar en la fase.

La primera es de volumen: Cóndor tiene treinta aeronaves con registro y Voltaria trescientos
cuarenta mil medidores, y **la decisión de modelado es la misma aunque la escala no lo sea**.
La segunda es de propósito: Voltaria conserva por obligación regulatoria y Cóndor conserva para
ver la tendencia antes de que se vuelva una novedad. Misma familia, motivos distintos, y el
motivo cambia la política de retención — que es la parte del modelo que casi nadie modela.

## 📋 Criterios de aceptación

```text
[ ] Están las tres formas montadas: tabla plana, Postgres particionado, hypertable
[ ] Está medido el costo de borrar un año en las tres, con el mismo volumen
[ ] Está medido el tamaño en disco antes y después de comprimir, por antigüedad
[ ] Los tres regímenes de consulta están medidos en particiones o chunks tocados
[ ] Está provocada la explosión de cardinalidad y está escrito dónde empieza a doler
[ ] Está medido el costo de un backfill sobre un período ya comprimido
[ ] El veredicto separa qué resuelve Postgres solo y qué justifica la extensión
[ ] Está escrito a qué volumen esto deja de caber en un nodo
```
