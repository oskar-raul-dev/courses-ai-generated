# 🔑 Miniproyecto 02 · Clave-valor — Nodo Sur

> **Familia:** clave-valor · **Motor:** Valkey · **Línea base:** tabla `UNLOGGED` de PostgreSQL
> **Cierra:** el minicurso de clave-valor (Fases 05–06) · **Empresa:** 📡 Nodo Sur
> **Estado:** opcional · **No entra a la bitácora de medición**

---

## 🏢 La empresa

Nodo Sur es un proveedor regional de internet por fibra. Empezó en 2015 tendiendo cable en un
municipio donde el operador grande no quería invertir, y creció de la única forma en que crece
un negocio así: **un barrio a la vez, y más rápido de lo que la plataforma aguantaba**.

Hoy son ciento sesenta mil suscriptores en cuatro departamentos. Tienen un portal de
autogestión donde la gente paga, revisa su consumo y reinicia el equipo, y una aplicación
móvil que hace lo mismo peor. Los dos pegan contra la misma API, y esa API pega contra la
misma base de datos que lleva la facturación.

La gente que trabaja ahí sabe de redes. **Nadie sabe de bases de datos**, y eso no es un
reproche: es el perfil de la mitad de las empresas de este tamaño.

## ⚰️ El dolor

**El estado caliente vive en la base de datos fría.**

En 2016, cuando eran cuatro mil clientes, alguien resolvió las sesiones del portal con una
tabla: `session`, con el identificador, el usuario, la fecha de creación y la de expiración. Era
la decisión obvia y era la correcta. Ya tenían Postgres, no tenían un componente más que
operar, y la tabla cabía en memoria sin que nadie pensara en ello.

Diez años después, esa tabla recibe **escrituras en cada petición** —porque cada llamada
refresca la expiración—, tiene un índice que se actualiza con cada una, y su limpieza es un
`DELETE` programado a las tres de la mañana que a veces no termina antes de las seis. El
autovacuum va detrás recogiendo, y los días de pico va perdiendo.

Encima se le fueron colgando cosas, cada una por la misma buena razón: una tabla
`rate_limit_counter` para que nadie golpee la API de recargas, una tabla `provisioning_lock`
para que dos técnicos no aprovisionen el mismo puerto a la vez, y una tabla `job_queue` con un
`SELECT ... FOR UPDATE SKIP LOCKED` que funciona bien y que es lo mejor escrito de todo el
sistema.

**La factura tiene fecha.** El 6 de cada mes es día de pago y el portal recibe cuatro veces su
tráfico normal. En marzo de 2026 el portal se cayó cuarenta minutos, y no se cayó por las
consultas de facturación: se cayó porque **la tabla de sesiones y su índice se volvieron el
cuello de botella de todo lo demás que vive en esa base**, incluido el cobro. Perdieron el pico
de recaudo del día más importante del mes.

## 🎯 El encargo

**Lo pide Nelson Aguirre, líder de plataforma.**

> *"El 6 no se puede caer. Y no me sirve que me digas 'métele más CPU', porque eso ya lo
> hicimos dos veces. Necesito saber **qué de todo esto no debería estar en esa base**, cuánto
> gano sacándolo, y qué me cuesta tener un componente más — porque el que lo va a levantar a
> las tres de la mañana soy yo."*

## 🧩 Lo que se construye

Las cuatro piezas de estado caliente, sacadas a un motor clave-valor y comparadas contra lo
que ya existe:

- **Sesiones** con expiración nativa, e invalidación explícita: cerrar una sesión y cerrar
  todas las sesiones de un usuario, que es lo que pide la gente cuando le roban el celular.
- **Rate limiting** por suscriptor y por dirección de origen, en ventana fija y en ventana
  deslizante, y la diferencia de comportamiento entre las dos en el minuto del pico.
- **El candado de aprovisionamiento**, con su expiración — porque un candado sin expiración es
  una caída esperando su turno.
- **La cola de trabajos**, que es la única de las cuatro que **hoy está bien resuelta** en
  Postgres, y que hay que medir precisamente para poder decidir no moverla.

## 📐 Lo que se observa

- **Comandos por operación**, contados en el cliente: cuántas idas y vueltas cuesta una
  validación de sesión en cada diseño.
- **Qué pasa con la tabla `session`** cuando sale de la base: tamaño del índice, trabajo de
  limpieza, y qué deja de competir con la facturación.
- **Uso de memoria** del motor clave-valor con el volumen real de sesiones vivas, que es el
  número que decide si esto cabe.
- **El comportamiento en el borde de la ventana** del rate limiting: cuánto se puede colar
  justo en el cambio de ventana fija.

## 💥 Dónde se rompe

**Cuando la memoria se acaba.** Configura un tope bajo a propósito, llena el motor y observa
qué se lleva por delante la política de evicción — y anota el mensaje literal, que es una de
las entradas más buscadas del catálogo de errores del curso.

Y el segundo, que es el que de verdad enseña: **el día que alguien guarda ahí algo que no era
efímero.** Pasa siempre, pasa por comodidad, y pasa sin que nadie lo anote. Busca en el diseño
qué pieza está a un paso de convertirse en fuente de verdad sin que nadie lo haya decidido.

## ⚖️ El veredicto que tiene que salir

**Tres de las cuatro se van; una se queda.** Sesiones, rate limiting y candados son estado
caliente, efímero y reconstruible: son el caso puro de esta familia y sacarlos de la base
transaccional le devuelve aire a lo que sí importa.

**La cola de trabajos se queda en Postgres**, y hay que decirlo con el número delante. Ya
funciona, es transaccional con el resto del negocio, y moverla significaría coordinar dos
sistemas para garantizar lo que hoy garantiza uno solo. Un miniproyecto que se lleva las cuatro
piezas está vendiendo motores.

Y el veredicto de fondo, que es el de la familia entera: **clave-valor es un efecto, no una
causa.** Va al lado de la fuente de verdad, nunca en su lugar.

## 🧰 El stack

| Pieza | Qué se usa | Nota |
|---|---|---|
| Entorno | **Node + TypeScript** | |
| Motor | **Valkey** · perfil `clave-valor` | CLI `valkey-cli`, más `MONITOR` y `SLOWLOG` para mirar qué pasa |
| Cliente | **`iovalkey`** | El fork de ioredis que mantiene valkey-io: MIT, JS puro y con la API conocida. La versión y el porqué viven en `a06` |
| Atomicidad | **Lua del lado del servidor** (`EVAL`) | El rate limiting deslizante y el candado con expiración se escriben aquí, no en el cliente |
| Línea base | **PostgreSQL** · perfil `base` | Tabla `UNLOGGED` para sesiones · `SELECT … FOR UPDATE SKIP LOCKED` para la cola, que es lo que hoy está bien hecho |
| Driver de la base | `pg` | |
| Medición | `INFO memory` · comandos contados **en el cliente** · `pg_stat_statements` | Los viajes no los reporta ningún motor: los cuenta el arnés |
| Datos | Generador del curso | Sesiones, suscriptores y un pico de tráfico que reproduzca el día 6 |
| Entregable | `src/h-mini-02-clave-valor-nodo-sur/` | |

**Qué NO entra:** clúster de Valkey, Sentinel, ni persistencia de producción. La configuración
de `maxmemory` y la política de evicción sí entran, porque son el punto de rotura.

> ⚠️ **Ninguna versión ni digest se escribe aquí.** Viven en `a02` y se fijan ejecutando, en la
> sesión de verificación de laboratorio. Este stack nombra piezas, no números.
>
> 🧭 **Dos reglas del curso que este miniproyecto no puede saltarse.** El **arnés de medida y el
> generador de datos son TypeScript siempre** (`a06`): son el instrumento, y un instrumento
> con dos implementaciones deja de ser un instrumento. Y **se habla con los motores
> directamente**: nada de ORM, ODM ni cliente de alto nivel (`a06`), porque esas capas esconden
> justo lo que queremos medir.

---

## 🔗 El puente con Cóndor

Es la **Fase 05** con otro uniforme: el candado de la orden de trabajo abierta y la reserva del
puesto con foso en el hangar son el mismo problema que el candado de aprovisionamiento de Nodo
Sur, y fallan igual cuando no tienen expiración. La **Fase 06** añade dos matices que conviene llevar
puestos: un candado consultivo de Postgres no vence, pero se suelta solo cuando cae la conexión que lo
tiene; y una expiración más corta que el trabajo que protege deja pasar el duplicado, que es el boss
del Bloque I.

Y un tercero, sobre el veredicto: en la Fase 06, una tabla `UNLOGGED` resolvió la sesión **en los
mismos viajes que Valkey y con menos bytes**. Lo que ahí no se midió es justo el dolor de Nodo Sur: la
sesión que se **refresca en cada petición**. Si tu medición de tuplas muertas y limpieza no muestra
esa factura, el veredicto de las sesiones puede ser otro, y se escribe como salga.

El puente más útil no es técnico sino de criterio: en Cóndor, `SIGMA` también tiene una tabla
que se escribe en cada petición y que nadie ha mirado nunca. **Encontrarla es el ejercicio**.

## 📋 Criterios de aceptación

```text
[ ] Cerrar todas las sesiones de un suscriptor funciona y está resuelto sin recorrer claves
[ ] El rate limiting de ventana deslizante es atómico, y está demostrado que lo es
[ ] Todo candado tiene expiración, y está escrito qué pasa si el proceso muere con él tomado
[ ] Está medido el costo en comandos de una validación de sesión, contado en el cliente
[ ] Está anotado el mensaje literal del error de memoria llena, provocado a propósito
[ ] La cola de trabajos se queda en Postgres, y la decisión está justificada con su medición
[ ] Está identificada al menos una pieza en riesgo de volverse fuente de verdad sin decidirlo
```
