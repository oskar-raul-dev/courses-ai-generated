# 🪞 Instintos

> **Curso:** Ruta SQL · documento vivo · **crece con el curso**
> **Qué es:** cada punto del curso donde **un instinto razonable falla** —el de quien heredó la base,
> el de quien la quiere reemplazar o el tuyo—, con la medición que lo demuestra. Es el documento que
> mejor resume la ruta entera, y el que más sentido tiene leer solo.
> **Formato de cada entrada:** el instinto en tu voz · por qué es razonable · dónde se rompe · la
> medición que lo prueba, con su entrada `M-NN` de la [bitácora](bitacora-de-medicion.md) · y **la
> pregunta del instrumento** que lo habría anticipado.
> **Estado:** abierto el 12/10/2026, con los dos instintos que midió el apéndice `a06`; las fases 03 a 05
> agregaron tres el 13/10/2026, las fases 06 a 08, tres más el 14/10/2026, y el Bloque II (fases 09 a 14),
> seis más el mismo día; los Bloques III a V llegaron a 26, y el Bloque VI (fases 25 y 26) agregó tres el 15/10/2026; el track de SQL Server, una el 18/10/2026.

---

> 🧭 **Un instinto que falla no es un instinto malo.** Casi todos los de este documento funcionaron
> durante años en Alameda, y por eso nadie los revisó. Lo que se registra aquí es el punto exacto
> donde dejan de funcionar, con el número delante.

---

## 📋 Índice

| # | Bloque | El instinto | Fase |
|---|---|---|---|
| 1 | laboratorio | "`rollback` deshace todo desde el último `commit`" | [`a06`](a06-python-java-y-drivers.md) |
| 2 | laboratorio | "sin `commit`, nada queda guardado" | [`a06`](a06-python-java-y-drivers.md) |
| 3 | I · El modelo | "un `JOIN` agrega columnas, no filas" | [Fase 03](03-lo-que-sql-le-hace-al-modelo.md) |
| 4 | I · El modelo | "si la función funciona, su copia también" | [Fase 04](04-un-valor-un-hecho.md) |
| 5 | I · El modelo | "los duplicados son nombres mal escritos" | [Fase 05](05-una-persona-no-es-su-documento.md) |
| 6 | I · El modelo | "si los datos se reconstruyen, la descomposición es segura" | [Fase 06](06-cuarta-y-quinta-forma-normal.md) |
| 7 | I · El modelo | "con rangos sin superposición, todo mes pasado tiene su precio" | [Fase 07](07-el-tiempo-en-el-modelo.md) |
| 8 | I · El modelo | "el EAV es el peor de todos, por mucho" | [Fase 08](08-los-dos-extremos-del-mismo-error.md) |
| 9 | II · La física | "reordenar las columnas achica la tabla" | [Fase 09](09-el-tamano-de-las-cosas.md) |
| 10 | II · La física | "un UUIDv7 cuesta casi lo mismo que un entero" | [Fase 10](10-identificadores.md) |
| 11 | II · La física | "un índice cuesta según lo que guarda" | [Fase 11](11-indices-y-lo-que-cuestan.md) |
| 12 | II · La física | "corregir la estimación mejora el plan" | [Fase 12](12-estadisticas-y-cardinalidad.md) |
| 13 | II · La física | "el plan reutilizado castiga al caso grande" | [Fase 13](13-el-optimizador-en-tres-motores.md) |
| 14 | II · La física | "la base está lenta" | [Fase 14](14-la-base-no-estaba-lenta.md) |
| 15 | III · La concurrencia | "un nivel alto protege la regla" | [Fase 15](15-aislamiento-comparado.md) |
| 16 | III · La concurrencia | "tomar un número es instantáneo" | [Fase 16](16-el-folio-sin-huecos.md) |
| 17 | III · La concurrencia | "una lectura larga infla la tabla que se escribe" | [Fase 17](17-mvcc-y-su-factura.md) |
| 18 | III · La concurrencia | "un ALTER rápido no bloquea a nadie" | [Fase 18](18-bloqueos-deadlocks-y-ddl.md) |
| 19 | IV · Lo NoSQL dentro del SQL | "un índice de documento acelera cualquier búsqueda por una clave" | [Fase 19](19-json-en-los-motores.md) |
| 20 | IV · Lo NoSQL dentro del SQL | "si el protocolo es un documento, todas las consultas se abaratan" | [Fase 20](20-la-propuesta-de-florencia.md) |
| 21 | IV · Lo NoSQL dentro del SQL | "un índice de texto completo busca nombres" | [Fase 21](21-hasta-donde-llega-el-motor.md) |
| 22 | V · La base en la red | "la marca de agua exporta todo lo nuevo" | [Fase 22](22-la-exportacion-de-las-9-40.md) |
| 23 | V · La base en la red | "si guardo el cambio, el mensaje sale" | [Fase 22](22-la-exportacion-de-las-9-40.md) |
| 24 | V · La base en la red | "un identificador imposible de adivinar protege el informe" | [Fase 23](23-la-base-como-producto.md) |
| 25 | V · La base en la red | "con un índice en la tabla de la política, la seguridad por fila es gratis" | [Fase 23](23-la-base-como-producto.md) |
| 26 | V · La base en la red | "un broker es más rápido que una tabla" | [Fase 23](23-la-base-como-producto.md) |
| 27 | VI · El árbitro | "si los conteos dan, la migración está bien" | [Fase 25](25-la-migracion-sin-parar.md) |
| 28 | VI · El árbitro | "un *upsert* hace idempotente la carga" | [Fase 25](25-la-migracion-sin-parar.md) |
| 29 | VI · El árbitro | "la planilla siempre da un número, así que está bien" | [Fase 26](26-el-comite.md) |
| 30 | Track SQL Server | "si la API me devuelve lo mío y no lo ajeno, la seguridad está bien" | [ss05](ss05-data-api-builder-y-json.md) |

---

## 🧱 Cómo se agrega una entrada

Cada fase que mide una apuesta 🪞 agrega aquí su instinto **al cerrarse**, con la misma forma:

- **El instinto, en tu voz:** la frase tal como la diría alguien de la historia o tú mismo, entre
  comillas.
- **Por qué es razonable:** dónde funcionó y por qué nadie lo cuestionó.
- **Dónde se rompe:** el volumen, la consulta o la concurrencia exacta en que deja de servir.
- **La medición:** el número, y el enlace a su entrada `M-NN` de la bitácora.
- **La pregunta que lo habría anticipado:** cuál de las cinco preguntas del instrumento, y cómo.

Una apuesta de Oracle o de SQL Server que quedó sin resolver (🪞🔒) **no entra** como instinto
demostrado: entra cuando un lector la resuelve en su máquina, y queda en su copia, no en esta.

---

## 🪞 Las entradas

### 1 · "`rollback` deshace todo desde el último `commit`"

- **El instinto, en tu voz:** *"Si algo falla a la mitad, hago `rollback` y la base queda como estaba."*
- **Por qué es razonable:** es la definición de transacción que cualquiera aprendió, y en Postgres es
  exactamente así, también para el DDL.
- **Dónde se rompe:** en MySQL y en Oracle, cada `CREATE`, `ALTER` o `DROP` confirma antes todo lo
  pendiente. Una migración de cinco pasos que falla en el tercero queda con dos aplicados.
- **La medición:** [M-02](bitacora-de-medicion.md#m-02--a06--un-ddl-en-medio-de-la-transacción-confirma-lo-pendiente):
  la fila sobrevive al `rollback` en MySQL y desaparece en Postgres.
- **La pregunta que lo habría anticipado:** *¿dónde está la frontera transaccional?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#42-dónde-está-la-frontera-transaccional)): si la
  migración es una frontera, el motor tiene que poder defenderla, y en dos de los tres no puede.

### 2 · "Sin `commit`, nada queda guardado"

- **El instinto, en tu voz:** *"Mientras no haga `commit`, puedo tirar todo."*
- **Por qué es razonable:** los tres drivers de Python del curso arrancan con *autocommit* apagado, como
  pide su especificación (PEP 249).
- **Dónde se rompe:** JDBC arranca con *autocommit* encendido. En Java, cada sentencia se confirma sola, y
  una excepción entre dos escrituras deja la primera guardada.
- **La medición:** [M-03](bitacora-de-medicion.md#m-03--a06--jdbc-confirma-cada-sentencia-y-los-drivers-de-python-no):
  el `UPDATE` quedó en Java con el *autocommit* de fábrica, y no con `setAutoCommit(false)`.
- **La pregunta que lo habría anticipado:** *¿dónde está la frontera transaccional?* Si dos escrituras
  van juntas, la primera línea es apagar el *autocommit*, no un detalle del final.

### 3 · "Un `JOIN` agrega columnas, no filas"

- **El instinto, en tu voz:** *"Junto los protocolos con los precios para traer el precio; si sobra algo,
  `DISTINCT` lo arregla."*
- **Por qué es razonable:** en un modelo con claves y sin `NULL`, es exactamente así, y nadie cuestionó la
  presentación a la obra social durante años.
- **Dónde se rompe:** cuando la tabla de precios repite un código en el mes y cuando falta un precio. El
  `JOIN` interno descarta lo que no encuentra y multiplica lo que encuentra dos veces, y `DISTINCT` borra
  filas legítimas.
- **La medición:** [M-05](bitacora-de-medicion.md#m-05--f03--la-presentación-de-rubén-pierde-más-de-lo-que-se-creía): para PAMI en diciembre de 2009, 88
  prácticas perdidas por la obra social vacía, 122 por falta de precio y 111 contadas dos veces.
- **La pregunta que lo habría anticipado:** *¿conoces tus consultas de antemano?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#43-conoces-tus-consultas-de-antemano)): la presentación era la consulta conocida, y nadie había declarado la
  clave de la tabla de precios que esa consulta necesitaba.

### 4 · "Si la función funciona, su copia también"

- **El instinto, en tu voz:** *"Copio el parser al SQL Server tal como está; si en VBA funciona, en T-SQL
  también."*
- **Por qué es razonable:** el día de la copia, las dos versiones daban lo mismo, y la del frontal acertaba el
  90 % de los documentos.
- **Dónde se rompe:** el día que una de las dos cambia. El parche de 2019 solo llegó a VBA, y la ventana del
  año de dos dígitos nunca fue la misma en los dos lenguajes.
- **La medición:** [M-07](bitacora-de-medicion.md#m-07--f04--el-90--del-parser-de-rubén): las dos aciertan el 90,1 %, y difieren en 3
  documentos y 115 fechas de nacimiento.
- **La pregunta que lo habría anticipado:** *¿cuál es la unidad de lectura?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#44-cuál-es-la-unidad-de-lectura)): el documento se leía por separado en el frontal, en los reportes y en la
  presentación; era un dato, no un pedazo del nombre, y merecía su columna.

### 5 · "Los duplicados son nombres mal escritos"

- **El instinto, en tu voz:** *"Con una buena función de similitud y un umbral bien elegido, encuentro a los
  pacientes repetidos."*
- **Por qué es razonable:** es lo que muestran los ejemplos que uno mira primero (`GIMENEZ` y `JIMENEZ`), y
  para ellos funciona: sin los recién nacidos, la regla medida encuentra el 99,0 %.
- **Dónde se rompe:** en el recién nacido, que entra como `RN` y dos apellidos y vuelve años después con su
  nombre y un apellido. No es una variante del nombre, es otro estado de la identidad.
- **La medición:** [M-08](bitacora-de-medicion.md#m-08--f05--el-matcher-de-trigramas-no-llega-al-90-): 85,7 % de exhaustividad con 0,89 % de
  falsos, y 6.116 de los 6.414 pares perdidos tienen una ficha `RN`.
- **La pregunta que lo habría anticipado:** *¿necesitas exactitud o parecido?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#46-necesitas-exactitud-o-parecido)): la respuesta era "parecido", y el parecido se mide contra una verdad antes
  de elegir el umbral.

### 6 · "Si los datos se reconstruyen, la descomposición es segura"

- **El instinto, en tu voz:** *"Partí la tabla de convenios en tres, la volví a armar con un join y dio las mismas
  filas. Está bien partida."*
- **Por qué es razonable:** es exactamente la prueba de una dependencia de join, y con la planilla de 2026 da
  cero filas de más.
- **Dónde se rompe:** el día que una obra social excluye una práctica en una sede aunque las tres partes digan
  que sí. La descomposición no avisa: inventa el convenio.
- **La medición:** [M-10](bitacora-de-medicion.md#m-10--f06--la-descomposición-en-tres-tablas-y-la-regla-cíclica): 0 espurios con la regla cíclica, 107 con
  un 10 % de excepciones.
- **La pregunta que lo habría anticipado:** *¿conoces tus consultas de antemano?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#43-conoces-tus-consultas-de-antemano)): la regla de los convenios es una consulta que hace facturación, y había que
  preguntarle a facturación, no a los datos.

### 7 · "Con rangos sin superposición, todo mes pasado tiene su precio"

- **El instinto, en tu voz:** *"Pasé los precios a rangos con `WITHOUT OVERLAPS`; ahora cualquier fecha tiene un
  solo precio."*
- **Por qué es razonable:** los rangos resuelven las 187 filas pegadas dos veces, y la restricción impide que
  vuelvan.
- **Dónde se rompe:** donde la copia mensual perdió la fila. Un solo precio no es lo mismo que algún precio: en
  425 pares de práctica y mes no hay ninguno.
- **La medición:** [M-11](bitacora-de-medicion.md#m-11--f07--la-consulta-as-of-sobre-los-precios-en-rangos): 20.367 correctos y 425 sin fila; con la UB
  del mes como hecho, 20.792 de 20.792.
- **La pregunta que lo habría anticipado:** *¿dónde está la frontera transaccional?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#42-dónde-está-la-frontera-transaccional)): cerrar una vigencia y abrir la siguiente van juntas, y la copia del día 1 las
  separaba.

### 8 · "El EAV es el peor de todos, por mucho"

- **El instinto, en tu voz:** *"Un modelo tipado le gana al EAV de Matías por un orden de magnitud en cualquier
  consulta."*
- **Por qué es razonable:** es lo que dice cualquier libro, y el EAV sí pierde: lee más, pesa más y estima peor.
- **Dónde se rompe:** en el "por mucho". Con los mismos índices, el EAV lee 1,5 veces lo del tipado, y la tabla
  ancha, el otro extremo del error, gana la consulta clínica.
- **La medición:** [M-13](bitacora-de-medicion.md#m-13--f08--el-eav-contra-el-modelo-tipado): 269.760, 176.902, 77.248 y 29.304 bloques.
- **La pregunta que lo habría anticipado:** *¿cuál es la unidad de lectura?* ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#44-cuál-es-la-unidad-de-lectura)): la
  consulta clínica lee dos determinaciones del mismo protocolo, y el modelo de una fila por protocolo tiene esa
  forma.

### 9 · "Reordenar las columnas achica la tabla"

- **El instinto, en tu voz:** *"Si pongo primero las columnas anchas y al final las chicas, me ahorro el relleno de
  alineación en cada fila."*
- **Por qué es razonable:** el relleno existe, y en una tabla con booleanos entre `bigint` reordenar ahorra un 21 %.
- **Dónde se rompe:** en `result`, que ya no tiene columnas mal ubicadas: el ahorro por fila se pierde en el redondeo a 8
  bytes, y la tabla ocupa los mismos 87.835 bloques.
- **La medición:** [M-14](bitacora-de-medicion.md#m-14--f09--reordenar-las-columnas-de-result): 54,8 contra 49,8 bytes promedio por fila, y
  los mismos 686 MB.
- **La pregunta que lo habría anticipado:** *¿cuál es la unidad de lectura?* ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#44-cuál-es-la-unidad-de-lectura)): el motor lee páginas, no bytes; un
  ahorro que no cambia cuántas filas entran en una página no se ve.

### 10 · "Un UUIDv7 cuesta casi lo mismo que un entero"

- **El instinto, en tu voz:** *"El problema del UUID era el desorden; con el v7, que crece en orden, la clave cuesta lo de
  un `bigint`."*
- **Por qué es razonable:** el v7 arregla el desorden, y el UUIDv4 sí es un desastre: un 93 % más grande.
- **Dónde se rompe:** en el ancho. Dieciséis bytes contra ocho siguen siendo el doble, en el índice primario y en cada
  índice secundario de InnoDB, que lleva la clave adentro: un 23 %, no menos del 10.
- **La medición:** [M-16](bitacora-de-medicion.md#m-16--f10--uuidv4-y-uuidv7-como-clave-primaria-en-innodb): 48,6, 93,8 y 59,6 MB.
- **La pregunta que lo habría anticipado:** *¿cuántos saltos tiene tu relación típica?* ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#45-cuántos-saltos-tiene-tu-relación-típica-y-los-conoces)): cada índice secundario
  es un salto a la clave, y la clave viaja en todos.

### 11 · "Un índice cuesta según lo que guarda"

- **El instinto, en tu voz:** *"Un índice sobre una columna de cuatro letras es casi gratis; los caros son los anchos."*
- **Por qué es razonable:** en disco, un índice angosto ocupa menos.
- **Dónde se rompe:** al escribir. Ocho índices multiplican por 4,6 los bytes de WAL de cada fila, y lo que agrega cada uno
  no sigue el ancho de su clave en ninguna de tres corridas; y lo que mata HOT no es la cantidad de índices sino el que cubre la columna que cambia.
- **La medición:** [M-18](bitacora-de-medicion.md#m-18--f11--el-wal-por-índice-y-lo-que-mata-hot): 146,8 bytes por fila sin índices y 672,4 con
  ocho; HOT al 100 % o al 0 % según cuál sea el cuarto índice.
- **La pregunta que lo habría anticipado:** *¿conoces tus consultas de antemano?* ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#43-conoces-tus-consultas-de-antemano)): un índice que ninguna consulta
  conocida pide se paga en cada escritura igual que uno que sí.

### 12 · "Corregir la estimación mejora el plan"

- **El instinto, en tu voz:** *"El optimizador se equivoca por 160 veces; le doy las estadísticas que le faltan y elige
  mejor."*
- **Por qué es razonable:** la estimación sí mejora, y el método de join sí cambia.
- **Dónde se rompe:** cuando quedaba un segundo error en sentido contrario. El plan nuevo, elegido con la estimación
  correcta, es cinco veces más lento, porque el estimador cree que cada protocolo tiene 60 resultados y la sede `E` tiene
  uno.
- **La medición:** [M-19](bitacora-de-medicion.md#m-19--f12--sede-y-prefijo-sin-estadísticas-extendidas): 165 contra 26.973 estimadas y reales;
  *nested loop* a *hash join*; 134 contra 697 ms.
- **La pregunta que lo habría anticipado:** *¿cuántos saltos tiene tu relación típica?* ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#45-cuántos-saltos-tiene-tu-relación-típica-y-los-conoces)): la estimación de un join
  depende de las dos tablas, y las estadísticas son de una.

### 13 · "El plan reutilizado castiga al caso grande"

- **El instinto, en tu voz:** *"Si Postgres reutiliza el plan, el central, que tiene la mitad de los protocolos, va a recibir
  un plan pensado para un centro chico."*
- **Por qué es razonable:** el plan genérico no mira el valor, y el central es el valor más distinto.
- **Dónde se rompe:** el genérico solo se acepta si no es más caro que lo que ya se vio. Si el día empieza en los centros,
  nunca se usa; si empieza en el central, es el centro chico el que hereda el plan caro.
- **La medición:** [M-21](bitacora-de-medicion.md#m-21--f13--el-plan-genérico-de-la-consulta-por-sede): 0 genéricos en un orden, 1 en el otro;
  la sede V con 87.945 contra 10.865 bloques.
- **La pregunta que lo habría anticipado:** *¿conoces tus consultas de antemano?* ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#43-conoces-tus-consultas-de-antemano)): una consulta conocida con
  valores de tamaños muy distintos se planifica por valor.

### 14 · "La base está lenta"

- **El instinto, en tu voz:** *"La pantalla tarda; el servidor no da abasto."*
- **Por qué es razonable:** lo único visible del otro lado del cable es el servidor.
- **Dónde se rompe:** en el cable. El formulario trae 17 MB de claves para mostrar 60 filas, y un servidor infinitamente
  rápido no baja los 35 s que esos bytes tardan en una VPN.
- **La medición:** [M-23](bitacora-de-medicion.md#m-23--f14--el-formulario-de-protocolos-del-frontal-de-2011): 1.327.682 filas para 60, 22.128
  veces.
- **La pregunta que lo habría anticipado:** *¿cuál es la unidad de lectura?* ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#44-cuál-es-la-unidad-de-lectura)): la de la pantalla es la fila
  mostrada, y todo lo demás es costo.


### 15 · "Un nivel alto protege la regla"

- **El instinto, en tu voz:** *"Si los técnicos corren en `REPEATABLE READ`, ninguno ve lo que el otro está haciendo, así que
  no pueden tomar la misma muestra; y en `SERIALIZABLE`, menos."*
- **Por qué es razonable:** el nivel promete que la transacción no ve cambios ajenos, y casi todas las anomalías de los libros son
  de lectura.
- **Dónde se rompe:** la regla "una muestra, un técnico" vive en una fila que todavía no existe. `REPEATABLE READ` la deja pasar
  en los dos motores; `SERIALIZABLE` la protege en Postgres con un error que la aplicación tiene que reintentar, y en MySQL con
  esperas y *deadlocks*. Sin el bucle, tres de cada cuatro tomas se pierden.
- **La medición:** [M-27](bitacora-de-medicion.md#m-27--f15--la-muestra-tomada-dos-veces-en-cuatro-niveles-y-dos-motores):
  dos tomas en `REPEATABLE READ`; 284–301 de 400 tomas perdidas en `SERIALIZABLE` sin bucle; 0 con `UNIQUE`.
- **La pregunta que lo habría anticipado:** *¿dónde está la frontera transaccional?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#42-dónde-está-la-frontera-transaccional)): la regla cruza dos
  transacciones, y lo que cruza transacciones se escribe en la base o se vigila.


### 16 · "Tomar un número es instantáneo"

- **El instinto, en tu voz:** *"El contador se incrementa en un microsegundo; que las cajas lo compartan no puede costar nada."*
- **Por qué es razonable:** el `UPDATE … RETURNING` tarda lo mismo con una caja que con tres.
- **Dónde se rompe:** el número queda tomado hasta el `COMMIT`, y la transacción incluye lo que se haga con él: armar el
  comprobante, esperar al organismo. Cada caja espera eso, entero, por cada una que va delante.
- **La medición:** [M-29](bitacora-de-medicion.md#m-29--f16--la-fila-contador-con-tres-cajas-y-diez-mil-comprobantes): de 5,5
  a 36,0 ms de espera con 0 y 10 ms de armado adentro; 1,2 ms con el armado afuera; 0,21 ms con un punto de venta por caja.
- **La pregunta que lo habría anticipado:** *¿dónde está la frontera transaccional?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#42-dónde-está-la-frontera-transaccional)): la del folio incluye al
  organismo, y todo lo que queda adentro lo paga la caja siguiente.


### 17 · "Una lectura larga infla la tabla que se escribe"

- **El instinto, en tu voz:** *"La exportación lee resultados toda la noche y el laboratorio los corrige a la mañana: la tabla de
  resultados se va a inflar."*
- **Por qué es razonable:** en un motor con versiones, cada corrección deja una versión vieja que la exportación todavía puede ver.
- **Dónde se rompe:** dos veces. La tabla de resultados casi no crece (1,10 veces la del día en la peor media hora, nada la tabla
  entera): se escribe poco en proporción a su tamaño. Y la que sí infla es otra, que la exportación ni lee: el contador de
  comprobantes, de 1 a 45 páginas cada diez mil, porque la foto retiene versiones de toda la base.
- **La medición:** [M-31](bitacora-de-medicion.md#m-31--f17--la-lectura-abierta-y-la-media-hora-más-cargada-de-la-caja).
- **La pregunta que lo habría anticipado:** *¿cuál es la unidad de lectura?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#44-cuál-es-la-unidad-de-lectura)), al revés: la de escritura. Lo que
  infla es cuántas veces se reescribe cada fila, no cuánto se escribe.


### 18 · "Un `ALTER` rápido no bloquea a nadie"

- **El instinto, en tu voz:** *"Agregar una columna con un valor constante no toca las filas: tarda dos milisegundos, y dos
  milisegundos no los nota nadie."*
- **Por qué es razonable:** el `ALTER` en sí tarda eso, medido.
- **Dónde se rompe:** antes de trabajar, el `ALTER` espera su bloqueo, y mientras espera, todo pedido nuevo sobre la tabla se pone en
  la fila detrás de él. Con una transacción abierta desde la noche, la tabla queda cerrada hasta que esa transacción termine.
- **La medición:** [M-33](bitacora-de-medicion.md#m-33--f18--la-cola-detrás-de-un-alter-de-dos-milisegundos): 30 de 30 lecturas
  en la cola mientras duró la exportación; 0 de 30 con `lock_timeout`.
- **La pregunta que lo habría anticipado:** *¿dónde está la frontera transaccional?*
  ([Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md#42-dónde-está-la-frontera-transaccional)): el `ALTER` necesita que no
  haya ninguna transacción abierta sobre la tabla, y eso depende de transacciones que no son suyas.

### 19 · "Un índice de documento acelera cualquier búsqueda por una clave"

- **El instinto, en tu voz:** *"Un índice GIN sobre el documento convierte cualquier búsqueda por cualquier clave en un acceso directo."*
- **Por qué es razonable:** Es lo que el motor promete al indexar un `jsonb`, y para una consulta muy selectiva lo cumple: 527 bloques en lugar de 4.686.
- **Dónde se rompe:** Cuando la consulta devuelve muchas filas repartidas por todo el heap, el índice lee casi todas las páginas (1.915 de 1.915 para la ciprofloxacina). Además, cada clave indexada cuesta WAL en cada escritura: el GIN casi duplica el WAL de insertar 1.000 cultivos.
- **La medición:** [M-35](bitacora-de-medicion.md#m-35--f19--el-antibiograma-como-documento-en-la-búsqueda-por-un-resultado): apuesta perdida; [M-36](bitacora-de-medicion.md#m-36--f19--el-wal-de-corregir-un-antibiótico-por-forma): el WAL de la corrección.
- **La pregunta que lo habría anticipado:** *¿cuántas páginas del heap toca el índice, y no solo cuántas entradas lee?*

### 20 · "Si el protocolo es un documento, todas las consultas se abaratan"

- **El instinto, en tu voz:** *"Si el protocolo es un documento, lo que se lee junto es barato, y lo que cruza protocolos, también."*
- **Por qué es razonable:** Para la operación que toca un protocolo, es verdad: corregir un resultado es 1,7 veces más rápido en Mongo que en el relacional.
- **Dónde se rompe:** Para cruzar protocolos, el documento pierde: el cruce de glucemia es 10 a 11 veces más lento que el relacional, y la auditoría, entre 115 y 143 veces, porque cada protocolo se abre para mirar sus resultados.
- **La medición:** [M-38](bitacora-de-medicion.md#m-38--f20--las-cinco-operaciones-en-tres-diseños): la apuesta de la lectura se gana; el documento pierde en lo que cruza.
- **La pregunta que lo habría anticipado:** *¿qué operación lee un protocolo entero, y cuál cuenta protocolos?*

### 21 · "Un índice de texto completo busca nombres"

- **El instinto, en tu voz:** *"Un índice de texto completo en español resuelve la búsqueda de nombres de la recepción."*
- **Por qué es razonable:** Resuelve la palabra: `PEREZ` aparece en 4.173 pacientes con el mismo resultado que `LIKE`, y en 2,9 ms.
- **Dónde se rompe:** No resuelve el prefijo (busca cualquier palabra que empiece así: 8.577 frente a 7.748) ni el error de tipeo (`RODRIGES` no encuentra a `RODRIGUEZ`). Los trigramas lo resuelven, con ruido que depende del umbral.
- **La medición:** [M-39](bitacora-de-medicion.md#m-39--f21--la-búsqueda-de-nombres-like-texto-completo-prefijo-y-trigramas): la búsqueda de nombres por herramienta.
- **La pregunta que lo habría anticipado:** *¿qué escribe la recepción: una palabra completa, un prefijo o un nombre con error?*

### 22 · "La marca de agua exporta todo lo nuevo"

- **El instinto, en tu voz:** *"Guardo la fecha del último resultado que envié, y la próxima vez envío lo que tiene una fecha posterior."*
- **Por qué es razonable:** Funciona en la prueba de un solo escritor: lo que se registra en orden, se confirma en orden.
- **Dónde se rompe:** Con transacciones concurrentes, el orden de confirmación no es el de registro: lo que confirma tarde queda detrás de la marca. Y con fechas al minuto, los empates hacen lo mismo. Medido: 36 % del día perdido en 10 de 10 corridas.
- **La medición:** [M-42](bitacora-de-medicion.md#m-42--f22--la-exportación-por-marca-de-agua-con-transacciones-concurrentes): apuesta ganada; la ventana de una hora deja la pérdida en cero.
- **La pregunta que lo habría anticipado:** *¿qué ve una consulta: lo registrado, o lo confirmado?*

### 23 · "Si guardo el cambio, el mensaje sale"

- **El instinto, en tu voz:** *"Confirmo el cambio en la base y después mando el mensaje: si se cae, lo reintento."*
- **Por qué es razonable:** El reintento cubre la caída del destino, que es la más común.
- **Dónde se rompe:** No cubre la caída entre el `COMMIT` y el envío: el cambio queda y el mensaje no sale. Medido: 19 de 1.000 mensajes perdidos con 2 % de caídas; 0 con el outbox.
- **La medición:** [M-45](bitacora-de-medicion.md#m-45--f22--el-outbox-frente-a-la-doble-escritura-y-las-correcciones-con-versión): el outbox contra la doble escritura.
- **La pregunta que lo habría anticipado:** *¿el cambio y su mensaje están en la misma transacción?*

### 24 · "Un identificador imposible de adivinar protege el informe"

- **El instinto, en tu voz:** *"Si la URL lleva un hash en lugar del número, nadie puede adivinar la del vecino."*
- **Por qué es razonable:** Funciona contra quien prueba números al azar.
- **Dónde se rompe:** No funciona contra quien conoce la forma del número: un espacio de un millón se recorre en segundos (1.305.942 URL revertidas en unos 3,5 s). Y aunque no se pudiera revertir, el portal entregaba el informe a quien tuviera la dirección: el problema era la autorización.
- **La medición:** [M-49](bitacora-de-medicion.md#m-49--f23--el-md5-del-portal-de-2018-revertido) y [M-47](bitacora-de-medicion.md#m-47--f23--lo-que-cuesta-la-seguridad-por-fila-y-dónde-va-el-índice).
- **La pregunta que lo habría anticipado:** *¿quién puede ver este objeto, y dónde se comprueba?*

### 25 · "Con un índice en la tabla de la política, la seguridad por fila es gratis"

- **El instinto, en tu voz:** *"Pongo un índice en la columna por la que filtra la política y RLS no cuesta nada."*
- **Por qué es razonable:** Es cierto cuando la columna está en la tabla protegida: el paciente paga 92 bloques sobre 600.
- **Dónde se rompe:** Si la política filtra por una subconsulta a otra tabla, el índice de esa otra tabla no evita recorrer la protegida: el médico paga 9.684 bloques con el índice, frente a 5 con la columna en la tabla protegida.
- **La medición:** [M-47](bitacora-de-medicion.md#m-47--f23--lo-que-cuesta-la-seguridad-por-fila-y-dónde-va-el-índice).
- **La pregunta que lo habría anticipado:** *¿en qué tabla está la columna que filtra la política?*

### 26 · "Un broker es más rápido que una tabla"

- **El instinto, en tu voz:** *"Para mover mensajes, un broker de mensajería le gana a una tabla de la base."*
- **Por qué es razonable:** El broker está hecho para eso, y en otras condiciones lo es.
- **Dónde se rompe:** En este laboratorio, con mensajes persistentes y el journal sobre el sistema de archivos de Docker Desktop, la cola en Postgres consume 6.651 mensajes 2,4 a 2,9 veces más rápido. El broker se gana su lugar por el contrato entre sistemas, no por la velocidad.
- **La medición:** [M-51](bitacora-de-medicion.md#m-51--f23--el-boss-del-puente-punto-de-partida-solución-y-hacía-falta-un-broker).
- **La pregunta que lo habría anticipado:** *¿el consumidor está en el mismo sistema que la base, o en otro?*

### 27 · "Si los conteos dan, la migración está bien"

- **El instinto, en tu voz:** *"Conté las filas de origen y de destino, y son las mismas: la migración salió."*
- **Por qué es razonable:** Una fila perdida es el error más común de una carga, y el conteo lo ve siempre.
- **Dónde se rompe:** En la Fase 25, la convivencia pisó 3.321 resultados migrados con valores de otro protocolo, y el modelo había perdido 32.866 unidades facturables. Las dos veces, el conteo de filas daba bien. Lo vieron las sumas de control y la reconciliación de unidades.
- **La medición:** [M-53](bitacora-de-medicion.md#m-53--f25--la-cantidad-que-el-modelo-de-la-fase-07-no-trajo) y [M-54](bitacora-de-medicion.md#m-54--f25--la-convivencia-por-cdc-con-el-frontal-escribiendo-y-el-aplicador-cayéndose).
- **La pregunta que lo habría anticipado:** *¿qué error deja el mismo número de filas?*

### 28 · "Un *upsert* hace idempotente la carga"

- **El instinto, en tu voz:** *"Con `INSERT … ON CONFLICT DO UPDATE` puedo reaplicar lo que sea, cuantas veces sea."*
- **Por qué es razonable:** Con una sola fuente que es dueña de sus claves, es exactamente eso.
- **Dónde se rompe:** Con dos fuentes que numeran en el mismo espacio, el *upsert* no da error: actualiza la fila de la otra. Los 3.321 resultados del día cayeron sobre resultados de 1999, y ninguno coincidió después con legacy.
- **La medición:** [M-54](bitacora-de-medicion.md#m-54--f25--la-convivencia-por-cdc-con-el-frontal-escribiendo-y-el-aplicador-cayéndose).
- **La pregunta que lo habría anticipado:** *¿quién más puede escribir una fila con esta clave?*

### 29 · "La planilla siempre da un número, así que está bien"

- **El instinto, en tu voz:** *"La planilla de los martes nunca falló: siempre da un total."*
- **Por qué es razonable:** Durante años, el total de la planilla fue lo que se cobró.
- **Dónde se rompe:** Da un número porque elige: cuando la tabla de precios tiene dos vigencias el mismo día, factura la última cargada. En la semana del 28/09, 17,96 millones de PAMI salen de precios que nadie decidió, y el modelo los manda a la cola en lugar de facturarlos. Lo que la obra social no reconoce vuelve como débito.
- **La medición:** [M-57](bitacora-de-medicion.md#m-57--f26--el-boss-global-un-martes-punto-de-partida-y-solución).
- **La pregunta que lo habría anticipado:** *¿qué hace mi cálculo cuando el dato es ambiguo: elige, o dice que no sabe?*

### 30 · "Si la API me devuelve lo mío y no lo ajeno, la seguridad está bien"

- **El instinto, en tu voz:** *"Probé con el paciente 39: ve sus resultados, y el protocolo de otro le da una lista vacía. La seguridad por fila funciona."*
- **Por qué es razonable:** las dos pruebas son las correctas para la **autorización**: el filtro está en la base, lo aplica a toda consulta, y la Fase 23 las usó para dar por buena la API de PostgREST.
- **Dónde se rompe:** en la **autenticación**, que esas pruebas dan por hecha. Con Data API builder y el proveedor `AppService`, la identidad es un JSON en base64 en un encabezado, sin firma; sin App Service delante, quien lo escribe es quien dice ser. La política filtró perfecto por el paciente que le llegó: el 12594, fabricado, con sus 115 resultados.
- **La medición:** [M-74](bitacora-de-medicion.md#m-74--ss05--el-contrato-de-la-fase-23-por-data-api-builder-y-la-identidad-fabricada).
- **La pregunta que lo habría anticipado:** la de la **operación**: *¿qué le prueba a la API que este usuario es quien dice ser, y quién puede fabricar esa prueba?*
