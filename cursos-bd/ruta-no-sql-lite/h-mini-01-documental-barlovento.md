# 🍃 Miniproyecto 01 · Documental — Barlovento

> **Familia:** documental · **Motor:** MongoDB · **Línea base:** PostgreSQL JSONB
> **Cierra:** el minicurso documental (Fases 03–04) · **Empresa:** 🚢 Barlovento
> **Estado:** opcional · **No entra a la bitácora de medición** (ver
> [`miniproyectos.md`](miniproyectos.md) §1)

---

## 🏢 La empresa

Barlovento opera cuatro terminales de contenedores y dos patios extraportuarios entre dos
países. Mueve carga ajena: llega en barco, se queda unos días en el patio, se la lleva un
camión. El negocio no está en mover la caja —eso lo hace cualquiera— sino en **saber en todo
momento qué hay dentro, quién puede reclamarla y qué permiso le falta**.

Los clientes son navieras y agentes de aduana, y ninguno de los dos perdona. La naviera quiere
que la caja salga del barco en cuatro horas; la aduana quiere que no salga del patio hasta que
un funcionario lo diga. Entre esas dos presiones vive toda la operación, y las dos generan
multas distintas.

La empresa empezó en 2008 con un patio y ochenta contenedores al día. Hoy son cuatro
terminales, cerca de doce mil movimientos diarios, y un sistema que se escribió cuando el
único tipo de carga que importaba era "contenedor lleno o contenedor vacío".

## ⚰️ El dolor

**La carga no es una cosa: son muchas cosas que se parecen desde afuera.**

Un contenedor refrigerado tiene temperatura de consigna, rango tolerado, ventilación, humedad,
registro de la cadena de frío y un enchufe que alguien tiene que conectar. Uno de carga
peligrosa tiene clase, número de identificación de la sustancia, punto de inflamación, reglas de
segregación —qué no puede ir al lado de qué— y una ficha de seguridad que la autoridad puede
pedir. Uno de carga sobredimensionada tiene medidas que se salen del contenedor, distribución de
peso y puntos de izaje. Y uno de carga a granel no tiene contenedor en absoluto.

En 2011 alguien tomó una decisión perfectamente razonable: **una tabla `cargo` con todas las
columnas de todos los tipos, anulables**. Era lo correcto entonces. Había tres tipos, la tabla
tenía veintidós columnas y funcionaba.

Hoy esa tabla tiene **noventa y cuatro columnas**, de las cuales ochenta y una son anulables, y
al lado hay una segunda tabla —`cargo_attribute`, con `cargo_id`, `key` y `value` en texto—
donde se fueron metiendo los campos que llegaron después. Tiene cuarenta millones de filas y
tres formas distintas de escribir la clave del punto de inflamación, porque la escribieron tres
equipos en tres años.

**La factura tiene fecha.** En agosto de 2025 un contenedor de carga peligrosa se estibó al lado
de uno incompatible porque la regla de segregación estaba en `cargo_attribute` con una clave mal
escrita y el validador no la encontró. No pasó nada. La auditoría que vino después costó once
días de dos personas y un compromiso por escrito con la autoridad, y la frase que cerró el
informe fue: *"el sistema no valida lo que no sabe que existe"*.

## 🎯 El encargo

**Lo pide Mariela Ospina, jefa de operaciones de terminal.**

> *"Cada año entra un tipo de carga nuevo y cada año me dicen que son tres meses de desarrollo.
> Yo no necesito que el sistema sepa de antemano todos los tipos que van a existir. Necesito que
> **no me deje registrar una carga peligrosa sin sus datos de peligrosa**, y que cuando el
> inspector abra la ficha la vea completa de una vez, no en seis pestañas."*

## 🧩 Lo que se construye

Un modelo documental de `cargo` para los cuatro tipos vigentes —refrigerada, peligrosa,
sobredimensionada y contenedor seco estándar— con tres piezas:

- **Validación por tipo.** El esquema es polimórfico: los campos comunes son obligatorios
  siempre, y los campos de cada tipo son obligatorios **solo para su tipo**. Un tipo nuevo se
  añade sin tocar los documentos existentes, que es todo el punto.
- **La ficha completa en una lectura.** Lo que el inspector necesita ver —carga, permisos
  vigentes, restricciones de estiba y último movimiento— tiene que resolverse en un solo viaje.
  Decide qué se embebe y qué se referencia, y justifica cada decisión con la unidad de lectura.
- **El mismo modelo en Postgres con JSONB** y un índice GIN, porque sin la línea base al lado
  esto es una opinión.

## 📐 Lo que se observa

No se publica nada de aquí, pero sí se anota para el veredicto:

- **Viajes** para armar la ficha completa, en el modelo embebido y en el referenciado.
- **Documentos examinados contra devueltos** en la consulta que más usa la operación: *"todas
  las cargas peligrosas en patio con permiso vencido"*.
- **El costo de un tipo nuevo**, medido en las dos formas: cuántos documentos hay que tocar en
  el modelo documental, y cuántas columnas y filas en la tabla ancha con su tabla de atributos.
- **El tamaño del documento** cuando se le embebe el historial de movimientos.

## 💥 Dónde se rompe

Dos límites, y el lector tiene que encontrarlos solo:

**El primero es de crecimiento.** Si embebes el historial de movimientos dentro de la carga
—que es lo cómodo, porque casi siempre se lee junto— el documento de un contenedor que lleva
seis meses en patio crece sin cota. Encuentra a partir de cuántos movimientos deja de ser
buena idea y qué patrón lo resuelve.

**El segundo es la frontera transaccional**, y es el que importa. La liberación de la carga
toca la carga, el permiso aduanero y el registro de entrega **a la vez**. Modela eso con
referencias y el "a la vez" se convierte en tres escrituras que la aplicación coordina a mano.
Entregar dos veces el mismo contenedor no es un descuadre contable: es un delito.

## ⚖️ El veredicto que tiene que salir

**Documental gana la ficha de carga y pierde la liberación.** La polimorfia real —tipos que no
comparten campos y tipos nuevos cada año— es exactamente el caso de esta familia, y la tabla
ancha con su tabla de atributos es la forma cara de simular un documento sin sus garantías.

Pero la liberación tiene una frontera transaccional que cruza entidades, y ese es el corte. La
respuesta honesta es de reparto: **el documento para la ficha, el relacional para la entrega**.
Si el miniproyecto termina con "todo a Mongo", está mal resuelto.

## 🧰 El stack

| Pieza | Qué se usa | Nota |
|---|---|---|
| Entorno | **Node + TypeScript** | El entorno por defecto del curso |
| Motor | **MongoDB** · perfil `documental` | CLI `mongosh` para inspección manual |
| Driver | `mongodb`, el oficial de Node | **Sin Mongoose ni ningún ODM** |
| Línea base | **PostgreSQL** · perfil `base` | `JSONB` con índice `GIN`, y `jsonb_path_ops` donde cambie el plan |
| Driver de la base | `pg` | Consultas a mano, sin capa de acceso |
| Validación | `$jsonSchema` en el motor · Zod en el borde | El esquema polimórfico vive en el motor; Zod solo valida la entrada |
| Medición | `explain("executionStats")` · `EXPLAIN (ANALYZE, BUFFERS)` | `totalDocsExamined` contra `nReturned`; el contador de viajes lo pone el arnés |
| Datos | Generador del curso (`a05`) | Volúmenes `10k` y `1m`, semilla determinista |
| Entregable | `src/h-mini-01-documental-barlovento/` | Un directorio por miniproyecto, como manda el repositorio |

**Qué NO entra:** sharding de Mongo, réplica más allá del nodo único que exigen las
transacciones, y cualquier framework de aplicación. Un tipo de carga nuevo se añade escribiendo
un esquema, no un módulo.

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

Es el mismo problema de la **Fase 03**: la ficha de aeronave, donde dos unidades del mismo
modelo no comparten campos por el equipamiento opcional. Cambia el negocio y no cambia nada
más — y esa es toda la demostración.

Hay además un eco que conviene señalar en la fase: la tabla `cargo_attribute` de Barlovento y
la tabla de "atributos adicionales" de `SIGMA` en Cóndor son **el mismo anti-patrón inventado
dos veces por dos equipos que no se conocen**. Cuando un error aparece dos veces en dos
dominios distintos, deja de ser un error y pasa a ser un síntoma.

Y un matiz de la **Fase 04** que el veredicto tiene que resistir: medido sobre un millón de piezas,
**JSONB con GIN examinó exactamente lo mismo que Mongo** en la consulta polimórfica (1,00×), con un
índice de menos de la mitad que el comodín. La tabla ancha con su tabla de atributos pierde contra los
dos; contra JSONB, el polimorfismo solo no decide. Si la ficha de carga se queda en Mongo, que sea por
la unidad de lectura del inspector y por la validación por tipo, y que tu comparación contra JSONB lo
muestre.

## 📋 Criterios de aceptación

```text
[ ] Un documento de carga peligrosa sin número de sustancia es rechazado por el motor,
    no por el código de la aplicación
[ ] Añadir un quinto tipo de carga no requiere tocar ningún documento existente
[ ] La ficha completa que ve el inspector se resuelve en un solo viaje, demostrado con explain
[ ] La consulta de peligrosas con permiso vencido usa índice: examinados ≈ devueltos
[ ] El mismo caso está montado en Postgres con JSONB y GIN, y su plan está leído
[ ] Está escrito a partir de cuántos movimientos el historial embebido deja de servir
[ ] El veredicto reparte: qué queda en documento y qué queda en relacional, con el porqué
```
