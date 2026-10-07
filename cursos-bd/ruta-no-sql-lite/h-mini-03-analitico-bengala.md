# 🦆 Miniproyecto 03 · Analítico embebido — Bengala

> **Familia:** analítico embebido · **Motor:** DuckDB · **Línea base:** PostgreSQL
> **Cierra:** el minicurso de analítico embebido (Fases 07–08) · **Empresa:** 📣 Bengala
> **Estado:** opcional · **No entra a la bitácora de medición**

---

## 🏢 La empresa

Bengala es una agencia de publicidad y medios que fundaron en 2016 una creativa y un
planificador de medios que se fueron de una multinacional con dos clientes y un computador.
Hoy son ochenta personas en tres países y manejan pauta ajena por una cifra que les quita el
sueño.

El claim de la casa —**"la atención se compra; la memoria se construye"**— es también su
discusión interna: ella vende marca a largo plazo, él vende conversión esta semana, y ninguno
de los dos productos existe sin el otro.

Lo que hay que entender del negocio para este miniproyecto es una sola cosa, y es incómoda:
**Bengala no es dueña de sus propias métricas.** Los números los produce cada plataforma
donde compra pauta, se descargan como archivos, y cambian retroactivamente cuando la
plataforma recalcula a quién le atribuye una conversión. El número de ayer puede no ser el
mismo hoy, y eso no es un error: es cómo funciona.

## ⚰️ El dolor

**El tablero que arma tres personas y sale distinto tres veces.**

Cada lunes hay que decirle a cada cliente cuánto se gastó, en qué, y qué produjo. Los datos
llegan como exportaciones —un archivo por plataforma, por cuenta y por día— con columnas que
no se llaman igual en ninguna de las dos, monedas distintas, zonas horarias distintas, y una
plataforma que reporta el gasto con impuestos y otra sin ellos.

El proceso de hoy: alguien descarga, alguien pega en una hoja de cálculo, alguien cruza con la
tabla de tarifas, alguien revisa. **Cuatro horas los lunes buenos y una tarde entera los
malos**, repetido por tres personas en tres oficinas que resuelven los casos raros con
criterios distintos.

Y la decisión que lo causó fue razonable. En 2019 alguien propuso montar un almacén de datos y
la respuesta fue *"no tenemos ingeniero de datos, y no vamos a contratar uno para hacer un
Excel más rápido"*. Tenía razón: el almacén se habría quedado sin quién lo mantuviera. Pero la
alternativa que se quedó no fue "algo más simple": fue **nada**, y siete años después el costo
acumulado de esas cuatro horas semanales por tres personas es mayor que el del almacén que no
compraron.

**La factura tiene fecha.** En enero de 2026 le reportaron a un cliente un costo por
adquisición un 30 % mejor del real, porque una exportación traía el gasto sin impuestos y nadie
lo notó. El cliente subió el presupuesto sobre ese número. Cuando apareció el error, la
conversación no fue sobre el error: fue sobre si se podía confiar en algo de lo que Bengala
reportaba.

## 🎯 El encargo

**Lo pide Marianela Buitrago, directora de cuentas.**

> *"No quiero un tablero bonito. Quiero que el número que le digo al cliente el lunes salga
> siempre del mismo sitio y de la misma forma, que se pueda volver a calcular cuando la
> plataforma cambie el pasado, y que yo pueda ver **por qué** cambió. Y no me traigas nada que
> necesite un servidor, porque no hay quién lo cuide."*

## 🧩 Lo que se construye

Un tablero de rendimiento reproducible, de tres tramos, sin servidor:

- **Consulta directa sobre los archivos.** Las exportaciones se consultan donde están, en su
  formato de origen, sin cargarlas a ninguna parte primero. Ese gesto es toda la tesis de la
  familia.
- **Un derivado materializado.** La consulta que se repite cada lunes se proyecta, se ordena y
  se guarda en un formato columnar, con el antes y el después en tamaño y en columnas leídas.
- **La reformulación del pasado.** Cuando llega una exportación que cambia números ya
  reportados, el proceso tiene que poder **recalcular y mostrar la diferencia**, no
  sobrescribir en silencio. Es la parte que el negocio necesita y la que nadie construye.

Y el mismo tablero armado en Postgres, para que la comparación exista.

## 📐 Lo que se observa

- **Columnas leídas contra columnas de la tabla**, que es la medida propia de esta familia y la
  que no depende del hardware.
- **Bytes leídos del archivo contra bytes que ocupa** — cuánto se leyó de verdad para contestar.
- **El costo de una métrica nueva:** añadir una columna derivada en el modelo columnar contra
  hacerlo en la tabla ancha de Postgres.
- **Qué pasa cuando el dato no cabe en memoria** y el motor tiene que volcar a disco.

## 💥 Dónde se rompe

**Dos procesos escribiendo el mismo archivo.** Es el límite de la familia y hay que tocarlo con
la mano: dos personas recalculando el mismo derivado a la vez. Anota el mensaje literal.

Y el segundo, que es de diseño y no de motor: **el día que alguien quiere escribir en el
tablero.** Marcar un dato como revisado, dejar una nota, corregir una tarifa a mano. En cuanto
aparece un segundo escritor, esta familia deja de ser la respuesta y hay que decirlo.

## ⚖️ El veredicto que tiene que salir

**Gana el analítico embebido, y gana por goleada** — pero el veredicto interesante no es ese,
sino el que hay debajo: **lo que le faltaba a Bengala no era un almacén de datos, era un
proceso reproducible.** El error de 2019 no fue rechazar el almacén; fue creer que la única
alternativa al almacén era la hoja de cálculo.

Y el corte honesto, que va escrito con esas palabras: esto sirve mientras el dato quepa en una
máquina, cambie poco y los escritores sean uno. **Nunca como base de la aplicación.** El día
que Bengala quiera que el cliente entre al tablero y deje un comentario, esto no es la
respuesta.

## 🧰 El stack

Es uno de los dos miniproyectos con **Python**, por la regla de los dos entornos de `a06`: el ecosistema de
esta familia vive ahí de verdad. El arnés y el generador siguen siendo TypeScript.

| Pieza | Qué se usa | Nota |
|---|---|---|
| Entorno del pipeline | **Python** | Es donde vive Arrow y el resto del ecosistema columnar |
| Entorno del arnés y el generador | **TypeScript** | Regla de `a06`, sin excepción |
| Motor | **DuckDB** · perfil `analitico` | CLI `duckdb` para exploración, cliente de Python para el pipeline |
| Formato de origen | CSV y **Parquet** | Las exportaciones de las plataformas, tal como llegan |
| Formato del derivado | **Parquet** proyectado, ordenado y comprimido | El antes y el después en tamaño es media medición del miniproyecto |
| Línea base | **PostgreSQL** · perfil `base` | La tabla ancha, cargada de verdad |
| Driver de la base | `psycopg` desde Python | |
| Medición | `EXPLAIN` de DuckDB · `EXPLAIN (ANALYZE, BUFFERS)` | **Columnas leídas contra columnas de la tabla**, que es la medida propia de la familia |
| Datos | Generador del curso | Exportaciones de tres plataformas con columnas que no se llaman igual, dos monedas y dos zonas horarias |
| Entregable | `src/h-mini-03-analitico-bengala/` | |

**Qué NO entra:** orquestadores de pipelines, herramientas de transformación declarativa, ni
ningún almacén de datos. 🔥 Como ampliación opcional: el mismo cálculo con una librería de
dataframes al lado, para medir SQL contra dataframe sobre el mismo archivo.

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

Es la **Fase 07** exacta: el costo por hora volada de Cóndor —que es su precio de venta— se
arma hoy igual que el tablero de Bengala, exportando y cruzando a mano, y se equivoca igual.
La diferencia es la consecuencia: en Bengala se pierde un cliente; en Cóndor, un contrato de
Ala Continua nace perdiendo dinero y nadie se entera hasta el año tres.

Y hay un puente conceptual que conviene señalar en la fase: **la reformulación retroactiva de
Bengala es el mejor ejemplo de consistencia eventual que tiene el curso**, y reaparece en la
Fase 24, cuando toque medir la ventana de inconsistencia entre motores.

## 📋 Criterios de aceptación

```text
[ ] El tablero se calcula desde los archivos originales, sin proceso de carga previo
[ ] El mismo comando produce el mismo número dos veces, en dos máquinas distintas
[ ] Está medido cuántas columnas lee la consulta contra cuántas tiene la tabla
[ ] Existe el derivado materializado, con su antes y después en tamaño
[ ] Una exportación que cambia el pasado produce una diferencia visible, no una sobrescritura
[ ] Está provocado y anotado el error de dos escritores sobre el mismo archivo
[ ] El veredicto dice explícitamente cuándo esta familia deja de servirle a Bengala
```
