# 🏗️ Fase 24 — El diseño: el documento que se defiende con la bitácora en la mano

> **Curso:** Ruta SQL · Fase 24 de 27 · Bloque VI — El árbitro · **12 h**
> **Motores:** los del laboratorio, sin mediciones nuevas: esta fase lee el catálogo y la bitácora
> **Entorno de ejecución:** SQL en `src/24-el-diseno/`, de solo lectura
> **Evidencia:** bitácora de medición, entradas M-05 a M-51
> **Depende de:** Fase 23 · **Habilita:** Fase 25
> **Fecha de verificación ejecutada:** 15/10/2026
> **Objetivo:** escribir el documento de diseño de la base nueva de Alameda, parte por parte, con las cinco preguntas de la Fase 02, el diseño elegido y la medición que lo sostiene, y saber dónde pierde cada decisión.

---

## 🧭 1. Dónde estamos

Pasaron veintitrés fases desde que Rubén apareció con su `DMax + 1`, y la dirección de Horizonte quiere una respuesta. Hay un año de plazo, hay presupuesto, y hay una condición: **el laboratorio no para ni un día**. Sobre la mesa siguen las tres propuestas de la historia. Verónica propone que el laboratorio sea un esquema más del Oracle corporativo, Florencia que los resultados sean documentos en MongoDB, y la tercera, la del lector, todavía no tiene dueño.

Lo que cambió desde la Fase 00 es la bitácora. Tiene 51 entradas, y en 13 de ellas Oracle quedó como apuesta sin resolver. Cada una mide una forma: bloques leídos, filas examinadas contra devueltas, estimadas contra reales, bytes de WAL, filas bloqueadas. **Esta fase no mide nada nuevo.** Lee lo que ya está medido, lo ordena por partes de Alameda, y escribe el documento que la dirección va a llevar al comité de la Fase 26.

Esta fase **no es una victoria de Postgres**. En la bitácora hay mediciones en las que el modelo tipado pierde, y el documento las tiene que decir antes que nadie. Un documento de diseño que solo trae las mediciones favorables no se defiende ante un comité: se descubre.

---

## 🎯 2. Objetivos de esta fase

1. Escribir un documento de diseño por partes de Alameda, no para el sistema entero.
2. Contestar las cinco preguntas de la [Fase 02](02-las-cinco-preguntas-desde-el-otro-lado.md) para cada parte, y que la respuesta decida el diseño.
3. Citar en cada decisión la entrada de la bitácora que la sostiene, y nombrar las que la contradicen.
4. Poner las tres propuestas lado a lado con lo que gana y lo que pierde cada una, con número.
5. Separar lo que el documento decide de lo que deja abierto, y decir quién lo decide.

---

## 🗂️ 3. La evidencia

La bitácora tiene tres clases de entradas, y el documento las usa distinto.

**Las apuestas ganadas** sostienen una decisión: el folio sin huecos ([M-29](bitacora-de-medicion.md#m-29--f16--la-fila-contador-con-tres-cajas-y-diez-mil-comprobantes)), el `ALTER` con `lock_timeout` ([M-33](bitacora-de-medicion.md#m-33--f18--la-cola-detrás-de-un-alter-de-dos-milisegundos)), la cola dentro de la base ([M-44](bitacora-de-medicion.md#m-44--f22--la-cola-con-skip-locked-la-entrega-al-menos-una-vez-y-el-veneno)), la seguridad por fila con su índice ([M-47](bitacora-de-medicion.md#m-47--f23--lo-que-cuesta-la-seguridad-por-fila-y-dónde-va-el-índice)).

**Las apuestas perdidas** son las más valiosas, porque son las que un comité no espera que se digan. El EAV no lee diez veces más que el modelo tipado, sino 1,5 veces ([M-13](bitacora-de-medicion.md#m-13--f08--el-eav-contra-el-modelo-tipado)). Reordenar las columnas de `result` no ahorra un bloque ([M-14](bitacora-de-medicion.md#m-14--f09--reordenar-las-columnas-de-result)). El índice GIN sobre el antibiograma lee el 27 % de la tabla y no el 1 % ([M-35](bitacora-de-medicion.md#m-35--f19--el-antibiograma-como-documento-en-la-búsqueda-por-un-resultado)). Y el matcher de pacientes no llega al 90 % ([M-08](bitacora-de-medicion.md#m-08--f05--el-matcher-de-trigramas-no-llega-al-90-)).

**Las apuestas sin resolver de Oracle** (13 entradas con 🔒: M-04, M-06, M-09, M-12, M-15, M-17, M-20, M-22, M-24, M-28, M-30, M-32 y M-34) **no entran como número** en el documento, ni a favor ni en contra de Verónica. Entran como lo que son: el mecanismo que Oracle documenta para el mismo problema, y el comando con el que tú resolviste la apuesta en tu máquina. Un documento que va a un comité de Horizonte puede decir *"medimos la forma en Oracle con nuestra licencia y vimos tal cosa"*. Este curso no lo publica (D20, [a09](a09-licencias-publicacion-y-riesgo.md)), y tu documento sí puede tenerlo, si tu licencia lo permite.

---

## ⚔️ 4. Las propuestas, con su mejor argumento

Las tres propuestas no compiten en todo: compiten en cinco cosas que la bitácora sí midió.

| Lo que se decide | 🏛️ Verónica: un esquema del Oracle del SIH | 🍃 Florencia: documentos en MongoDB | 🐘 El lector: Postgres con el modelo tipado | Evidencia |
|---|---|---|---|---|
| Leer un informe entero | la forma relacional, como el lector (🔒) | **0,65 ms**, casi como `jsonb` (0,54) | 0,78 ms con `json_agg` | [M-38](bitacora-de-medicion.md#m-38--f20--las-cinco-operaciones-en-tres-diseños) |
| Corregir un resultado | la forma relacional (🔒) | **1,46 ms, gana** | 2,45 ms | [M-38](bitacora-de-medicion.md#m-38--f20--las-cinco-operaciones-en-tres-diseños) |
| La presentación a una obra social | la forma relacional (🔒) | 26,9 ms | **16,1 ms** | [M-38](bitacora-de-medicion.md#m-38--f20--las-cinco-operaciones-en-tres-diseños) |
| El cruce epidemiológico | la forma relacional (🔒) | 252 a 289 ms, examina los 50.000 documentos | **25,8 ms** | [M-38](bitacora-de-medicion.md#m-38--f20--las-cinco-operaciones-en-tres-diseños) |
| La auditoría de correcciones | `Flashback Query` (🔒, [M-12](bitacora-de-medicion.md#m-12--f07--flashback-query-en-oracle)) | 83 a 103 ms | **0,72 ms** | [M-38](bitacora-de-medicion.md#m-38--f20--las-cinco-operaciones-en-tres-diseños) |
| El maestro de pacientes con el SIH | **un solo motor, una sola base** | dos motores y una interfaz | dos motores, huellas por cubeta (Fase 25) | historia §6 |
| El costo | la licencia que ya se paga, más núcleos | Community sin costo de licencia | sin costo de licencia | Fase 26 |

**El mejor argumento de Florencia sobrevive a la bitácora:** el informe es una unidad de lectura evidente, y corregir un resultado dentro de un documento es más barato que en tres tablas. Gana en lo que dijo que iba a ganar. Pierde **10 a 11 veces en el cruce** y **115 a 143 veces en la auditoría**, porque esas lecturas no tienen la forma del documento. La [Fase 20](20-la-propuesta-de-florencia.md) lo midió con su propia propuesta, y no con una caricatura.

**El mejor argumento de Verónica no lo puede medir este curso con números publicados**, y el documento no lo esconde. Su fuerza no es de rendimiento: es **una sola fuente de verdad para pacientes y órdenes**, el fin de la interfaz de mensajes y un equipo de DBA que ya existe. La [Fase 25](25-la-migracion-sin-parar.md) mide lo que cuesta no tenerla: un cruce de pacientes entre dos bases que deja 12.364 fichas sin pareja, y 9.922 de ellas por suciedad del propio laboratorio, que en su propuesta entraría al SIH igual.

**El argumento del lector** es que el modelo relacional sostiene las cinco operaciones con una sola forma, sin ganar ninguna por mucho salvo las dos de lectura cruzada. Su punto débil está en la misma tabla: **corrige 1,7 veces más lento que el documento**, y el informe se arma en cada lectura.

---

## 🏗️ 5. El documento de diseño, parte por parte

El documento tiene una sección por parte de Alameda, y cada sección tiene la misma forma: **las cinco preguntas, el diseño, la medición que lo sostiene, lo que pierde y quién lo opera**. Esta sección es el esqueleto, con el contenido que el curso puede sostener. El ejercicio 19 es escribir el tuyo.

| Parte | Frontera transaccional | Consultas conocidas | Unidad de lectura | Saltos | Exactitud | Diseño |
|---|---|---|---|---|---|---|
| Pacientes | la fusión de dos fichas | sí | la persona y sus documentos | 1–2 | exacta en el documento, parecido en el nombre | `patient`, `identity_document`, `patient_merge` |
| Protocolos y resultados | el protocolo | sí | el informe | 1 | exacta | `lab_order` y `result` tipado; el informe, derivado |
| Precios y convenios | la vigencia | sí | la práctica con su precio a una fecha | 2–3 | exacta | rangos con `WITHOUT OVERLAPS`, convenio en quinta forma normal |
| Comprobantes | el número, las líneas y el protocolo | sí, y fijas | el comprobante | 1–2 | exacta | la fila contador, con el número al autorizar |
| La presentación | la semana emitida | **no: cambia con cada convenio** | muchas tablas | 3–4 | exacta al centavo | consultas sobre el modelo, emitida una vez (🏆) |
| El portal y la app | ninguna (lectura) | sí | el informe del paciente | 1 | exacta | API sobre vistas, seguridad por fila |
| La búsqueda | ninguna | sí | el paciente | 1 | **parecido** | trigramas sobre el nombre normalizado |
| El SIH | el mensaje | sí | el resultado | 1 | exacta | *broker* con su contrato, outbox del lado del laboratorio |

### 5.1 Pacientes: la persona no es su documento

**El diseño:** una persona (`patient`) con sus documentos aparte (`identity_document`), cada uno con su tipo y su país, y la fusión como un hecho registrado (`patient_merge`, con quién y cuándo) que nunca borra la ficha fusionada. Hay un trigger que prohíbe el `DELETE` y cuatro `CHECK` (ejercicio 2). El recién nacido apunta a su madre y no lleva su documento.

**La medición:** el parser de Rubén acierta el 90,1 % del DNI escondido en el nombre ([M-07](bitacora-de-medicion.md#m-07--f04--el-90--del-parser-de-rubén)). El matcher no llega al 90 % de los duplicados con menos del 1 % de falsos, y su mejor regla encuentra el 85,7 % con un 0,89 %. Pero el nivel automático (mismo documento, misma fecha y trigramas ≥ 0,8) encuentra 19.620 pares **con 0 falsos** ([M-08](bitacora-de-medicion.md#m-08--f05--el-matcher-de-trigramas-no-llega-al-90-)). Sobre 1,3 millones de protocolos, uno solo quedó en la persona equivocada.

**Lo que pierde:** el modelo deja **22.671 personas con más de una ficha viva**, porque la regla automática prefiere no fusionar a fusionar mal. Esa es una decisión de diseño, y tiene dueña: **Norma**, que revisa la bandeja. El documento la nombra, y dice cuántas fichas le esperan.

### 5.2 Protocolos y resultados: el modelo que no ganó ninguna medición

**El diseño:** `result` tipado, una fila por resultado, con el número como número, el calificador aparte, el texto de los cualitativos y la bandera de la muestra. Tres `CHECK` dicen qué combinaciones existen, y la unidad y el rango son del analito. La clave es la de la caja (`IdItem`), un entero, y hay **dos índices**: la clave y el protocolo.

**La medición, entera, incluida la que le juega en contra:**

- Con la misma consulta clínica, el EAV lee 269.760 bloques, el tipado 176.902, `jsonb` 77.248 y la tabla ancha 29.304 ([M-13](bitacora-de-medicion.md#m-13--f08--el-eav-contra-el-modelo-tipado)). **El modelo elegido lee más que dos de las alternativas.** Se elige igual, porque es el único en el que la base hace cumplir qué es un resultado, y en el que la reconciliación de la Fase 25 se puede contar.
- Reordenar las columnas no cambia un bloque ([M-14](bitacora-de-medicion.md#m-14--f09--reordenar-las-columnas-de-result)): el documento no promete ahorros de ese tipo.
- Cada índice agrega entre 48 y 89 bytes de WAL por fila ([M-18](bitacora-de-medicion.md#m-18--f11--el-wal-por-índice-y-lo-que-mata-hot)), y por eso `result` tiene dos.
- UUIDv7 en lugar de `bigint` agranda el índice primario un 23 % en InnoDB ([M-16](bitacora-de-medicion.md#m-16--f10--uuidv4-y-uuidv7-como-clave-primaria-en-innodb)). La clave interna sigue siendo un entero; lo que no se adivina es la URL, y lo protege la seguridad por fila, no el identificador ([M-49](bitacora-de-medicion.md#m-49--f23--el-md5-del-portal-de-2018-revertido)).

**Lo que pierde:** el informe se arma en cada lectura. La respuesta del diseño es la del boss IV ([M-41](bitacora-de-medicion.md#m-41--f21--el-boss-iv-el-informe-en-la-app-punto-de-partida-y-solución)): **la fuente es relacional y el documento se deriva**, en la misma transacción, para la app. Florencia tiene su documento, y el documento no es la fuente.

### 5.3 Precios, convenios y lo facturado

**El diseño:** los precios como rangos (`daterange`) con `PRIMARY KEY … WITHOUT OVERLAPS`, y lo facturado con una clave foránea con período hacia el precio vigente: una práctica no se puede facturar fuera de una vigencia. El convenio se guarda como **tres hechos binarios** (obra social cubre práctica, sede hace práctica, sede atiende obra social), porque la regla de Alameda es cíclica.

**La medición:** la consulta *as-of* sobre rangos resuelve los 187 pares de práctica y mes en que la unión de las tablas mensuales daba dos precios ([M-11](bitacora-de-medicion.md#m-11--f07--la-consulta-as-of-sobre-los-precios-en-rangos)). Las tres tablas binarias reconstruyen los 1.422 convenios con 0 espurios, y dos tablas binarias inventan 361 ([M-10](bitacora-de-medicion.md#m-10--f06--la-descomposición-en-tres-tablas-y-la-regla-cíclica)).

**Lo que pierde:** la clave foránea con período no deja facturar una práctica sin precio, y eso es lo correcto. Pero desde 2025 son **109.496 prácticas** (ejercicio 3) que quedan en la cola de rechazos, por los huecos y las vigencias duplicadas de la tabla de Matías. El diseño no las resuelve: las hace visibles, y el documento dice quién las resuelve, que es quien negocia los convenios.

### 5.4 Comprobantes y concurrencia

**El diseño:** una fila contador por punto de venta, con el número tomado **al autorizar** y no al empezar a armar el comprobante; las listas de trabajo con `FOR UPDATE SKIP LOCKED` y el estado en la misma fila; los formularios con versión; y el DDL siempre con `lock_timeout`.

**La medición:** tres cajas, diez mil comprobantes, **0 repetidos y 0 huecos**, y la espera por el número baja de 5,5 a 36 ms (según cuánto se tarde en armar) a entre 0,8 y 2,0 ms con el número al autorizar ([M-29](bitacora-de-medicion.md#m-29--f16--la-fila-contador-con-tres-cajas-y-diez-mil-comprobantes)). Un `ALTER` de 2 ms detrás de una lectura de 3 s retiene 30 lecturas, y con `lock_timeout`, ninguna más de 0,98 s ([M-33](bitacora-de-medicion.md#m-33--f18--la-cola-detrás-de-un-alter-de-dos-milisegundos)). En `SERIALIZABLE`, la muestra tomada dos veces se frena con `40001` ([M-27](bitacora-de-medicion.md#m-27--f15--la-muestra-tomada-dos-veces-en-cuatro-niveles-y-dos-motores)).

**Lo que pierde:** el `SERIALIZABLE` cuesta reintentos, y la aplicación tiene que saber reintentar. Y una lectura abierta media hora no infla la tabla del día tanto como se temía (1,10 veces), pero no deja que `VACUUM` limpie la fila contador ([M-31](bitacora-de-medicion.md#m-31--f17--la-lectura-abierta-y-la-media-hora-más-cargada-de-la-caja)). El documento le pone un límite de duración a las transacciones de exportación.

### 5.5 Los antibiogramas y lo que sí es documento

**El diseño:** el antibiograma de un cultivo en `jsonb`, validado con un `CHECK` de `jsonpath`, porque su forma varía de verdad. El resto de los resultados, tipado.

**La medición:** la apuesta de lectura **se perdió**. Con el mejor índice GIN, la búsqueda por un antibiótico resistente lee el 27 % de la tabla, no menos del 1 %. Con un btree sobre una columna derivada y la tabla agrupada, baja a 17 bloques ([M-35](bitacora-de-medicion.md#m-35--f19--el-antibiograma-como-documento-en-la-búsqueda-por-un-resultado)). Corregir un antibiótico en el documento del cultivo escribe 672 bytes de WAL contra 112 de la fila ([M-36](bitacora-de-medicion.md#m-36--f19--el-wal-de-corregir-un-antibiótico-por-forma)).

**Lo que pierde:** si la pregunta frecuente llega a ser *"¿qué cepas son resistentes a tal antibiótico?"*, el documento deja de ser la forma correcta, y el diseño dice cuál es la señal: esa consulta en `pg_stat_statements`.

### 5.6 La red: el portal, la exportación y el SIH

**El diseño:** el portal lee la base por una API generada con PostgREST sobre un esquema de vistas (`api`) con `security_invoker`, y la seguridad por fila decide quién ve qué. La exportación interna es una cola en la base con `SKIP LOCKED` y un outbox escrito en la misma transacción. La interfaz con el SIH va por un *broker*, por el contrato.

**La medición:** la marca de agua pierde filas en 10 de 10 corridas con transacciones concurrentes; con ventana y dedupe, 0 ([M-42](bitacora-de-medicion.md#m-42--f22--la-exportación-por-marca-de-agua-con-transacciones-concurrentes)). La cola procesa el día sin duplicados en 10 de 10 ([M-44](bitacora-de-medicion.md#m-44--f22--la-cola-con-skip-locked-la-entrega-al-menos-una-vez-y-el-veneno)), y el outbox no pierde ninguno de 1.000 mensajes contra 19 de la doble escritura ([M-45](bitacora-de-medicion.md#m-45--f22--el-outbox-frente-a-la-doble-escritura-y-las-correcciones-con-versión)). Con RLS, el portal del paciente lee 692 bloques contra 600 sin ella; la política del médico por subconsulta lee 9.684, y con la columna en la tabla protegida, 5 ([M-47](bitacora-de-medicion.md#m-47--f23--lo-que-cuesta-la-seguridad-por-fila-y-dónde-va-el-índice)). La cola en la base consume 2,4 a 2,9 veces más rápido que Artemis ([M-51](bitacora-de-medicion.md#m-51--f23--el-boss-del-puente-punto-de-partida-solución-y-hacía-falta-un-broker)).

**Lo que pierde:** el modelo actual todavía tiene la política del médico **por subconsulta** (ejercicio 1). El documento lo dice como deuda, con su costo medido, y con el cambio que la paga: llevar el médico a `lab_order`, con *expand*, en la Fase 25. Y el *broker* no se elige por velocidad. Se elige porque el SIH es otro sistema de otra empresa, y el contrato tiene que ser el mensaje y no el esquema de Alameda.

### 5.7 La búsqueda y la física

**El diseño:** la búsqueda de pacientes con trigramas sobre el nombre normalizado, separando el término corto (prefijo) del nombre completo. Estadísticas extendidas sobre sede y prefijo de protocolo. Listados con *keyset*, no con `OFFSET`.

**La medición:** el texto completo busca palabras y no tolera el error de tipeo (139 resultados para `RODRIGES`, contra 1.479 con trigramas a 0,3, [M-39](bitacora-de-medicion.md#m-39--f21--la-búsqueda-de-nombres-like-texto-completo-prefijo-y-trigramas)). Sin estadísticas extendidas, la estimación de sede y prefijo se equivoca 163 veces ([M-19](bitacora-de-medicion.md#m-19--f12--sede-y-prefijo-sin-estadísticas-extendidas)). El plan genérico hereda el método del central y hace leer 8,1 veces más a un centro chico ([M-21](bitacora-de-medicion.md#m-21--f13--el-plan-genérico-de-la-consulta-por-sede)). El formulario de 2011 traía 22.128 filas por fila mostrada ([M-23](bitacora-de-medicion.md#m-23--f14--el-formulario-de-protocolos-del-frontal-de-2011)).

**Lo que pierde:** los trigramas traen ruido según el umbral (6.682 resultados a 0,2; 43 a 0,5). El umbral es una decisión de producto, y el documento la deja anotada con quien la toma, que es recepción.

### 5.8 Una sección escrita entera: el comprobante

Las secciones anteriores son el esqueleto. Así se ve una entera, tal como la escribirías en tu documento. Es corta a propósito: un comité lee la primera página de cada sección, y la segunda solo si duda.

> **Comprobantes fiscales.**
>
> **Contexto.** Desde 2015 cada caja emite comprobantes electrónicos con número correlativo por punto de venta, y el organismo rechaza un número repetido o un salto. La base actual numera con `UltimoNumero`, sin transacción, y antes de 2015 con `DMax + 1`. Con el organismo respondiendo en 50 ms y 900 comprobantes, `UltimoNumero` generó 180 rechazos y `DMax + 1`, 2.404 ([M-29](bitacora-de-medicion.md#m-29--f16--la-fila-contador-con-tres-cajas-y-diez-mil-comprobantes)).
>
> **Las cinco preguntas.** La frontera transaccional cruza el número, las líneas y el protocolo. Las consultas son conocidas y fijas. La unidad de lectura es el comprobante. Tiene uno o dos saltos (el protocolo y el paciente). Y la exactitud es total: un número de más es un rechazo.
>
> **Decisión.** Una fila contador por punto de venta, actualizada en la misma transacción que autoriza el comprobante, y el número se toma **al autorizar**, no al empezar a armar. Un punto de venta por caja donde el volumen lo justifique.
>
> **La medición a favor.** Tres cajas y diez mil comprobantes, con 0 repetidos y 0 huecos. La espera por el número es de 0,8 a 2,0 ms con el número al autorizar, y de 0,21 ms con un punto de venta por caja.
>
> **La medición en contra.** Si alguien arma el comprobante mientras retiene el número, la espera crece con el armado: 36 ms con 10 ms de armado. La fila contador serializa, y eso es lo que se pide, pero tiene un costo que crece con lo que se haga dentro de la transacción.
>
> **En Oracle (🔒).** La apuesta de [M-30](bitacora-de-medicion.md#m-30--f16--la-secuencia-y-el-contador-en-oracle) es que una secuencia `NOCACHE ORDER` también deja el hueco del `ROLLBACK`, y que la fila contador con `UPDATE … RETURNING INTO` serializa las cajas igual que en Postgres. El mecanismo está documentado; el resultado lo tiene quien la resolvió en su máquina.
>
> **Quién lo opera.** Matías. Si un comprobante queda sin autorizar, la fila contador no avanzó, y no hay nada que corregir a mano. Lo que tiene que vigilar es la transacción larga que retenga el número, con `pg_stat_activity`.

Fíjate en lo que no tiene. No dice "Postgres es más rápido", porque la medición es de forma (cero huecos) y no de velocidad. No esconde la medición en contra. Y no le asigna a Oracle un número que no se puede publicar: le asigna su mecanismo.

### 5.9 Quién opera cada parte

La Fase 26 pone a Matías en la factura. El documento le tiene que adelantar a la dirección qué va a tener que saber, parte por parte, porque **un diseño que nadie de Alameda puede operar no es un diseño: es una dependencia de un proveedor**, que es lo que la red evitó desde 2010.

- **Pacientes:** la bandeja de revisión de fusiones (Norma) y la consulta que dice cuántas fichas esperan. Nada de esto es nuevo para Alameda, que ya tiene `Pacientes_Fusionar`.
- **Resultados y precios:** las cargas, la cola de rechazos y la reconciliación de la Fase 25. Son SQL, y Matías ya escribe SQL desde 2008.
- **Comprobantes y concurrencia:** las transacciones largas y las esperas, en dos consultas ([Fase 18](18-bloqueos-deadlocks-y-ddl.md)), y el `lock_timeout` de cada cambio de esquema.
- **La red:** el slot de la exportación, que no puede quedar sin consumidor ([M-46](bitacora-de-medicion.md#m-46--f22--la-decodificación-lógica-con-test_decoding)); PostgREST, que se reinicia o se recarga con un `NOTIFY`; y el *broker*, que es la única pieza que no es Postgres.
- **La física:** `ANALYZE` y las estadísticas extendidas, el `VACUUM` que no puede limpiar mientras haya una lectura abierta, y `pg_stat_statements` como el primer lugar donde mirar.

Cada línea tiene una fase del curso detrás, y eso es lo que la Fase 26 convierte en horas de formación. El documento solo dice qué, y la factura dice cuánto.

### 5.10 Lo que el documento no decide

Un documento honesto tiene una sección de lo abierto, con dueño y fecha:

- **Qué son los 177 analitos de texto de antes de 2008.** Lo decide bioquímica (Norma), y la Fase 25 los migra como texto mientras tanto.
- **Los precios de las 109.496 prácticas sin vigencia.** Lo decide quien negocia los convenios.
- **El umbral de los trigramas.** Lo decide recepción, con la lista de falsos delante.
- **El particionado de `result`.** No se midió con el volumen real (140 millones de filas): queda como diseño a medir antes de los cinco años, con la consulta que lo dispararía.
- **El motor del SIH.** No es de Alameda. El documento diseña la interfaz con ese motor, no su reemplazo.

---

## ⚖️ 6. Veredicto honesto: cuándo NO

- **Cuando el documento se escribe para ganar.** Si cada sección termina en "Postgres", el comité lo va a leer como una venta. Las secciones 5.2 y 5.5 empiezan por la medición que se perdió por una razón.
- **Cuando la evidencia es de otro volumen.** El perfil M es alrededor de la octava parte de Alameda en pacientes (242.427 fichas contra 1,9 millones) y la duodécima en resultados (12,1 contra 140 millones). La forma escala, pero el tiempo no: ninguna decisión del documento se apoya en un tiempo de este laboratorio, sino en una forma.
- **Cuando una parte no tiene consultas conocidas.** La presentación cambia con cada convenio, y por eso no tiene un modelo optimizado para ella: tiene consultas sobre el modelo general. Si Alameda tuviera muchas partes así, el documento debería decir que el modelo relacional es la opción por descarte, no por diseño.
- **Cuando la decisión ya está tomada por otra razón.** Si Horizonte decide por Verónica por la doctrina de la red, el documento sigue sirviendo: el diseño de cada parte sobrevive en Oracle casi entero (ejercicio 22), y el que se pierde es el costo, no el modelo.

---

## ⚠️ 7. Errores comunes

- **Defender una decisión con una sola medición.** El documento cita, para cada parte, al menos una medición a favor y una de las que la contradicen.
- **Citar tiempos en lugar de formas.** *"Tarda 16 ms"* no viaja a otra máquina; *"examina los 50.000 documentos"*, sí.
- **Poner un número de Oracle sin poder publicarlo.** En tu empresa, con tu licencia, puede ir. En un documento que va a circular, revisa qué dice el contrato (a09).
- **Un diseño para el sistema entero.** Las cinco preguntas se contestan por partes, y por eso una parte puede ser documento y otra no.
- **Una sección de "pendientes" sin dueño.** Un pendiente sin dueño es una decisión que va a tomar el que llegue primero.
- **Olvidar quién opera cada parte.** Matías va a operar esto a las dos de la mañana: el documento dice qué tiene que saber para cada parte (Fase 26).

---

## 📋 8. Checklist de validación

- [ ] `01_inventario.sql` corre y lista las tablas de `alameda` con sus restricciones y su RLS.
- [ ] Cada parte del documento contesta las cinco preguntas.
- [ ] Cada decisión cita al menos una entrada de la bitácora a favor y nombra las que la contradicen.
- [ ] Las entradas de Oracle aparecen como mecanismo y apuesta, sin números.
- [ ] La tabla de las tres propuestas tiene una fila en la que cada una gana.
- [ ] La sección de lo abierto tiene un dueño por punto.

---

## 🧪 9. Ejercicios (22)

Cada ejercicio tiene su solución en `soluciones/24-el-diseno.md`. Los 1 a 3 se corren con `02_ejercicios.sql`; los 4 a 12 se contestan con la bitácora y tienen solución completa; los 13 a 22 se resuelven con su rúbrica.

### 🟢 Ejercicio 1 — Lo que protege a `result`

¿Qué restricciones y qué políticas de seguridad por fila protegen a `alameda.result`?

*Solución:* [soluciones/24-el-diseno.md#ejercicio-1](soluciones/24-el-diseno.md#ejercicio-1)

### 🟢 Ejercicio 2 — Las reglas del paciente

¿Qué reglas hace cumplir la base sobre `alameda.patient`, sin ayuda de la aplicación?

*Solución:* [soluciones/24-el-diseno.md#ejercicio-2](soluciones/24-el-diseno.md#ejercicio-2)

### 🟢 Ejercicio 3 — La cola de rechazos

¿Qué regla de las Fases 04 a 07 rechaza más filas, y qué dice eso del diseño?

*Solución:* [soluciones/24-el-diseno.md#ejercicio-3](soluciones/24-el-diseno.md#ejercicio-3)

### 🟢 Ejercicio 4 — El folio

¿Qué entrada de la bitácora sostiene que el folio no tiene huecos con tres cajas, y qué número la resume?

*Solución:* [soluciones/24-el-diseno.md#ejercicio-4](soluciones/24-el-diseno.md#ejercicio-4)

### 🟢 Ejercicio 5 — El EAV

¿Cuántas veces más lee el EAV que el modelo tipado, y qué había apostado el curso?

*Solución:* [soluciones/24-el-diseno.md#ejercicio-5](soluciones/24-el-diseno.md#ejercicio-5)

### 🟢 Ejercicio 6 — Las cinco preguntas del comprobante

Contesta las cinco preguntas para el comprobante fiscal, y di qué diseño deciden.

*Solución:* [soluciones/24-el-diseno.md#ejercicio-6](soluciones/24-el-diseno.md#ejercicio-6)

### 🟡 Ejercicio 7 — Donde Florencia gana

¿En qué operación gana la propuesta de Florencia, por cuánto, y por qué eso no decide el diseño?

*Solución:* [soluciones/24-el-diseno.md#ejercicio-7](soluciones/24-el-diseno.md#ejercicio-7)

### 🟡 Ejercicio 8 — Donde el lector pierde

Lista tres mediciones en las que el diseño del lector pierde, con su número.

*Solución:* [soluciones/24-el-diseno.md#ejercicio-8](soluciones/24-el-diseno.md#ejercicio-8)

### 🟡 Ejercicio 9 — La búsqueda

Recepción pide "el buscador de Google" para pacientes. ¿Qué le ofrece el diseño y qué no?

*Solución:* [soluciones/24-el-diseno.md#ejercicio-9](soluciones/24-el-diseno.md#ejercicio-9)

### 🟡 Ejercicio 10 — La política del médico

¿Por qué la política del médico es una deuda, cuánto cuesta y cómo se paga?

*Solución:* [soluciones/24-el-diseno.md#ejercicio-10](soluciones/24-el-diseno.md#ejercicio-10)

### 🟡 Ejercicio 11 — La clave de `result`

Un integrante del comité propone UUID para todas las claves "por seguridad". Contesta con la bitácora.

*Solución:* [soluciones/24-el-diseno.md#ejercicio-11](soluciones/24-el-diseno.md#ejercicio-11)

### 🟡 Ejercicio 12 — ¿Un *broker* para todo?

Si el *broker* se usa para el SIH, ¿por qué no también para la exportación interna?

*Solución:* [soluciones/24-el-diseno.md#ejercicio-12](soluciones/24-el-diseno.md#ejercicio-12)

### 🟠 Ejercicio 13 — Una sola medición

Encuentra en tu documento una decisión que se sostiene en una sola medición, y propón la segunda.

*Solución:* [soluciones/24-el-diseno.md#ejercicio-13](soluciones/24-el-diseno.md#ejercicio-13)

**Rúbrica (sobre 3 puntos):** 1 punto por identificar la decisión y su única medición; 1 por una segunda medición que pueda contradecirla; 1 por decir qué cambiaría si la contradice.

### 🟠 Ejercicio 14 — La pregunta de Verónica

Verónica pregunta: *"¿por qué no un esquema en nuestro Oracle?"*. Contesta en media página, sin números de Oracle.

*Solución:* [soluciones/24-el-diseno.md#ejercicio-14](soluciones/24-el-diseno.md#ejercicio-14)

**Rúbrica (sobre 4 puntos):** 1 punto por reconocer su mejor argumento; 1 por lo que sí se midió (el cruce de pacientes, la suciedad que entraría al SIH); 1 por el mecanismo de Oracle sin números (D20); 1 por dejar el costo para el comité.

### 🟠 Ejercicio 15 — El informe como documento

Diseña cómo la app recibe el informe como documento sin que el documento sea la fuente.

*Solución:* [soluciones/24-el-diseno.md#ejercicio-15](soluciones/24-el-diseno.md#ejercicio-15)

**Rúbrica (sobre 4 puntos):** 1 punto por la fuente relacional; 1 por el documento derivado en la misma transacción o por outbox; 1 por la corrección que actualiza los dos; 1 por citar M-38 y M-41.

### 🟠 Ejercicio 16 — La sección de operación

Escribe la sección del documento que dice qué estadísticas, qué `VACUUM` y qué límites de transacción hay que programar.

*Solución:* [soluciones/24-el-diseno.md#ejercicio-16](soluciones/24-el-diseno.md#ejercicio-16)

**Rúbrica (sobre 4 puntos):** 1 punto por las estadísticas extendidas (M-19); 1 por el límite a las lecturas largas (M-31); 1 por `lock_timeout` en el DDL (M-33); 1 por los slots que se vigilan (M-46).

### 🟠 Ejercicio 17 — Lo abierto

Completa la sección de lo que el documento no decide con dos puntos más, cada uno con dueño y fecha.

*Solución:* [soluciones/24-el-diseno.md#ejercicio-17](soluciones/24-el-diseno.md#ejercicio-17)

**Rúbrica (sobre 3 puntos):** 1 punto por cada punto con dueño y fecha; 1 por no esconder uno incómodo.

### 🟠 Ejercicio 18 — El particionado

Decide qué tendrías que medir antes de particionar `result`, y qué resultado te haría no particionarla.

*Solución:* [soluciones/24-el-diseno.md#ejercicio-18](soluciones/24-el-diseno.md#ejercicio-18)

**Rúbrica (sobre 4 puntos):** 1 punto por la consulta que se beneficiaría (poda por fecha); 1 por lo que empeora (consultas por paciente sin fecha); 1 por el volumen al que se mide; 1 por el criterio de no hacerlo.

### 🔴 Ejercicio 19 — El documento

Escribe el documento de diseño de la base nueva de Alameda, con todas las secciones de la 5.

*Solución:* [soluciones/24-el-diseno.md#ejercicio-19](soluciones/24-el-diseno.md#ejercicio-19)

**Rúbrica (sobre 6 puntos):** 1 punto por las cinco preguntas en cada parte; 1 por una medición a favor y una en contra por parte; 1 por las tres propuestas con lo que gana cada una; 1 por Oracle sin números; 1 por la sección de lo abierto con dueños; 1 por quién opera cada parte.

### 🔴 Ejercicio 20 — El comité

Escribe las tres preguntas más difíciles que te haría el comité, y tus respuestas con la bitácora.

*Solución:* [soluciones/24-el-diseno.md#ejercicio-20](soluciones/24-el-diseno.md#ejercicio-20)

**Rúbrica (sobre 3 puntos):** 1 punto por pregunta difícil de verdad con una respuesta que cita una medición.

### 🔴 Ejercicio 21 — Diez veces Alameda

¿Qué partes del documento cambian si Alameda fuera diez veces más grande? ¿Cuáles no?

*Solución:* [soluciones/24-el-diseno.md#ejercicio-21](soluciones/24-el-diseno.md#ejercicio-21)

**Rúbrica (sobre 4 puntos):** 1 punto por separar formas que escalan de tiempos que no; 1 por el particionado; 1 por la búsqueda; 1 por lo que no cambia (el modelo).

### 🔴 Ejercicio 22 — Si gana Verónica

Horizonte decide por el Oracle del SIH. ¿Qué parte de tu documento sobrevive, y qué se pierde?

*Solución:* [soluciones/24-el-diseno.md#ejercicio-22](soluciones/24-el-diseno.md#ejercicio-22)

**Rúbrica (sobre 4 puntos):** 1 punto por el modelo que sobrevive casi entero; 1 por lo que cambia de mecanismo (rangos sin `WITHOUT OVERLAPS`, `jsonb`, RLS como VPD); 1 por la suciedad que entra al SIH; 1 por el costo.

---

## 📚 10. Referencias

**Documentación oficial**

- **Restricciones temporales de Postgres 18** (`WITHOUT OVERLAPS` y `PERIOD`) — https://www.postgresql.org/docs/18/sql-createtable.html
- **Oracle Virtual Private Database**, el equivalente de la seguridad por fila — https://docs.oracle.com/en/database/oracle/oracle-database/26/dbseg/using-oracle-vpd-to-control-data-access.html

**Ensayos y libros**

- **Michael Nygard, "Documenting Architecture Decisions"** — https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions — la forma corta de una decisión: contexto, decisión, consecuencias.
- **Martin Kleppmann, *Designing Data-Intensive Applications*, 2.ª ed., O'Reilly, 2026** — el capítulo de modelos de datos, para la tabla de las tres propuestas.

---

## 🏁 11. Resultado de la fase

- **El documento tiene una sección por parte**, con las cinco preguntas, el diseño, la medición y lo que pierde.
- **Cada propuesta gana en algo:** Florencia corrige 1,7 veces más rápido, Verónica tiene una sola fuente de verdad y el lector gana el cruce y la auditoría por un orden de magnitud.
- **El modelo elegido no ganó la medición clínica** (M-13), y el documento lo dice primero.
- **Lo de Oracle va como mecanismo y apuesta**, sin números.
- **Lo abierto tiene dueño:** Norma, quien negocia los convenios, recepción.

> **La señal de que quedó bien:** *"Para cada parte de Alameda puedo decir por qué la diseñé así, qué medición me da la razón, cuál me la quita, y quién va a vivir con la decisión."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-24-el-diseno -m "F24 cerrada: el documento de diseño por partes, con la bitácora en la mano"
> ```
>
> Commits de la fase con prefijo `f24:`, los de ejercicio `f24 ej22: …`.
