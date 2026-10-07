# 🔍 Miniproyecto 05 · Búsqueda — Bengala

> **Familia:** búsqueda · **Motor:** OpenSearch · **Línea base:** PostgreSQL con `tsvector` y GIN
> **Cierra:** el minicurso de búsqueda (Fases 11–12) · **Empresa:** 📣 Bengala
> **Estado:** opcional · **No entra a la bitácora de medición**
> ⚠️ **Es uno de los dos miniproyectos con veredicto incómodo.** Ver
> [`miniproyectos.md`](miniproyectos.md) §3.1.

---

## 🏢 La empresa

Bengala es la agencia de publicidad y medios de
[`h-mini-03-analitico-bengala.md`](h-mini-03-analitico-bengala.md): ochenta personas, tres
países, y diez años de trabajo acumulado.

Ese trabajo acumulado es un activo del que nadie habla en las reuniones y que vale más que la
mitad del equipo: **ciento ochenta mil piezas** producidas desde 2016 —videos, audios, gráficos,
guiones, textos, piezas para redes, correos— para cuarenta y tres clientes de once sectores. Con
sus briefs, sus versiones aprobadas y rechazadas, sus resultados, y los comentarios de quien las
aprobó.

## ⚰️ El dolor

**Vuelven a producir lo que ya existe, y a veces se lo venden al mismo cliente.**

El archivo está en un almacenamiento en la nube, organizado por carpetas de cliente, año y
campaña — que es la estructura que tenía sentido cuando eran ocho personas y una oficina. Para
buscar, hay una tabla con el nombre del archivo, el cliente, la fecha y unas etiquetas que
alguien puso al subir, cuando se acordó. La búsqueda es un `LIKE` sobre el nombre.

Eso encuentra lo que ya sabías que existía. No encuentra nada más.

La decisión que lo causó tenía su argumento y era bueno: *"nadie va a etiquetar ciento ochenta
mil piezas hacia atrás, así que no montemos un sistema que dependa de que alguien etiquete"*.
Es verdad y sigue siendo verdad. Lo que no se vio es que **el texto ya estaba ahí** —los briefs,
los guiones, los copys, los comentarios de aprobación— y que nadie lo estaba usando.

Hoy el archivo se consulta preguntando en el chat de la agencia: *"¿alguien se acuerda de si
hicimos algo de día del padre para una marca de licores?"*. Funciona mientras quien se acuerde
siga trabajando ahí. La rotación en publicidad es de dos años y medio.

**La factura tiene fecha.** En noviembre de 2025 produjeron desde cero una campaña de fin de
año para un cliente de retail. Cuatro semanas de equipo. En febrero, alguien encontró que en
2021 se había producido una pieza casi idéntica **para ese mismo cliente**, aprobada y no
emitida porque el cliente cambió de plan. Nadie lo supo porque la pieza se llamaba
`RET_FDA_v7_FINAL_ok.mp4` y estaba en la carpeta del año equivocado.

## 🎯 El encargo

**Lo pide Ismael Cabrera, director creativo.**

> *"Yo no quiero un buscador de archivos. Quiero poder escribir **lo que recuerdo** —'esa de la
> abuela y el perro, para el banco, creo que 2022'— y que salga. Y quiero poder filtrar después:
> solo video, solo ese cliente, solo lo aprobado. Que me deje equivocarme escribiendo, porque
> nadie escribe bien el nombre de una marca."*

## 🧩 Lo que se construye

Un servicio de búsqueda sobre el archivo creativo, con la fuente de verdad **donde ya está**:

- **El índice derivado**, reconstruible por completo desde la base transaccional en cualquier
  momento. Es la regla de la familia y aquí hay que demostrarla tirando el índice y
  regenerándolo.
- **Relevancia sobre el texto que ya existe:** brief, guion, copy y comentarios de aprobación,
  con pesos distintos por campo — porque una coincidencia en el guion no vale lo mismo que en
  un comentario de pasillo.
- **Facetas** por cliente, sector, formato, año y estado de aprobación, **recalculadas en cada
  consulta**, que es lo que las hace útiles y lo que las hace caras.
- **Tolerancia a errores de tecleo y sinónimos del oficio**, que en publicidad son un idioma
  aparte.
- **Y la misma búsqueda montada en Postgres con `tsvector` y un índice GIN**, bien jugada, con
  su diccionario y su ranking. Sin eso, el veredicto de este miniproyecto no vale nada.

## 📐 Lo que se observa

- **Qué encuentra cada uno y qué no**, sobre un conjunto de consultas reales escritas de
  antemano — incluida la de la abuela y el perro.
- **Segmentos consultados** y comportamiento de las facetas al crecer el número de filtros.
- **Cuánto dura la reconstrucción completa** del índice, que es el número que decide si esto es
  operable.
- **Cuánto tarda en verse una pieza recién subida**, que es lo que la gente reclama primero.

## 💥 Dónde se rompe

**El disco lleno y el índice en solo lectura.** Provócalo y anota el mensaje literal: es de las
entradas más buscadas del catálogo de errores del curso, y le pasa a todo el mundo la primera
vez.

Y el segundo, que es el que de verdad importa en esta empresa: **el día que alguien trate el
índice como fuente de verdad.** Si la única copia del comentario de aprobación está en el
índice, el día que se reindexe deja de existir. Busca en tu propio diseño si ya lo hiciste.

## ⚖️ El veredicto que tiene que salir — y es incómodo

**La mitad de este problema era un índice de Postgres.** El texto ya estaba en la base; lo que
faltaba no era un motor, era **buscar en el texto en vez de en el nombre del archivo**. Un
`tsvector` bien construido sobre brief, guion y copy, con su índice GIN, habría encontrado la
pieza de la abuela y el perro. Eso hay que medirlo y hay que publicarlo, aunque incomode.

**Lo que sí justifica el motor dedicado son otras tres cosas**, y solo esas: las facetas
recalculadas en cada consulta, la tolerancia a errores de tecleo, y el ajuste fino de relevancia
por campo. Si Bengala solo necesitara encontrar, Postgres alcanza. Necesita además explorar, y
eso es otra cosa.

Y el veredicto de la familia, que aquí se ve con toda claridad: **un índice de búsqueda no es
una fuente de verdad.** Siempre al lado, siempre reconstruible desde otro sitio, y con el tiempo
de reconstrucción medido y escrito — porque el día que haga falta, nadie va a tener tiempo de
averiguarlo.

## 🧰 El stack

| Pieza | Qué se usa | Nota |
|---|---|---|
| Entorno | **Node + TypeScript** | |
| Motor | **OpenSearch** · perfil `busqueda` | Es JSON sobre HTTP: `curl` para entender qué se manda, cliente oficial de JS para el servicio |
| Fuente de verdad | **PostgreSQL** · perfil `base` | El índice se reconstruye desde aquí, siempre. Si un dato solo existe en el índice, el diseño está mal |
| Línea base | El mismo Postgres con `tsvector` + `GIN` | Diccionario en español, pesos por campo y `ts_rank`. **Bien jugado o el veredicto no vale** |
| Sincronización | Patrón **outbox** desde Postgres al índice | 🔥 CDC como ampliación, no en el camino base |
| Análisis de texto | Analizador en español, sinónimos del oficio, tolerancia a errores de tecleo | El `mapping` es un esquema aunque se llame de otra forma |
| Medición | `profile: true` · segmentos consultados · reindexado **cronometrado** · `EXPLAIN (ANALYZE)` en Postgres | |
| Datos | Generador del curso | Briefs, guiones y comentarios con jerga publicitaria y nombres de marca escritos de cuatro formas |
| Entregable | `src/h-mini-05-busqueda-bengala/` | |

**Qué NO entra:** clúster multinodo, búsqueda vectorial o híbrida —esa es la familia 07 y
mezclarlas aquí arruina el veredicto—, y cualquier panel de visualización. El intercambio de
alias para reconstruir sin cortar el servicio **sí** entra.

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

Es la **Fase 11**: el catálogo de partes de Cóndor —ochenta mil referencias, con alternos,
equivalentes por modelo y proveedores que escriben el mismo número de cuatro maneras— es el
mismo problema con vocabulario distinto, y Sandra Vélez busca exactamente igual que Ismael:
encontrando lo que ya sabía que existía.

Y hay una diferencia que vale la pena mirar de frente en la fase, porque cambia el veredicto:
**en Bengala la consulta es difusa y en Cóndor es exacta.** Ismael no sabe qué busca; Sandra
busca un número de parte concreto y lo que falla es la escritura. Son dos problemas distintos
que se resuelven con la misma familia y con configuraciones opuestas, y confundirlos es el
error de modelado más común de esta familia.

## 📋 Criterios de aceptación

```text
[ ] El índice se reconstruye por completo desde la fuente de verdad, cronometrado
[ ] Existe la misma búsqueda en Postgres con tsvector y GIN, bien jugada, con su ranking
[ ] Hay un conjunto de consultas escrito ANTES de montar nada, y las dos se evalúan con él
[ ] Las facetas se recalculan en cada consulta y está medido lo que cuestan
[ ] Una consulta con el nombre de marca mal escrito devuelve el resultado correcto
[ ] Está provocado y anotado el error del índice en solo lectura por disco lleno
[ ] Está escrito qué parte del problema resolvía Postgres solo, con su medición
[ ] Ningún dato existe únicamente dentro del índice, y está demostrado tirándolo
```
