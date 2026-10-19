# 🔢 Fase 16 — El folio sin huecos: el número que exige el organismo, y cuándo no hace falta

> **Curso:** Ruta SQL · Fase 16 de 27 · Bloque III — La concurrencia · **10 h**
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · contraste MySQL `mysql@sha256:e2bde46db656…` · Oracle, solo con la documentación (🪞🔒)
> **Entorno de ejecución:** SQL y Python, con `uv run lab race` y un web service fiscal simulado
> **Perfil de volumen:** M (`uv run lab load --profile m`)
> **El dolor de Alameda:** `DMax + 1` en 2004, `UltimoNumero` en 2015 y el rechazo 10016 de una tarde de julio (historia §3)
> **Depende de:** Fase 15 · **Habilita:** Fase 17
> **Apéndices de apoyo:** a03, a04, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** reproducir cada forma en que Alameda numeró sus comprobantes y cómo falla contra el organismo, medir lo que
> cuesta la numeración sin huecos y dónde se asigna el número para que cueste poco, y decidir cuándo no exigirla.

---

## 🧭 1. Dónde estamos

La [Fase 15](15-aislamiento-comparado.md) midió qué ve una transacción mientras otra escribe. Esta fase toma la carrera más cara
de Alameda, la del número de comprobante, y le agrega lo que la anterior no tenía: **un tercero que no participa de la
transacción**. El organismo recaudador autoriza cada comprobante por su número y no sabe nada del `ROLLBACK` de la caja.

Es la fase que mejor muestra la idea del curso. La pregunta no es qué herramienta usar para numerar, sino **dónde está la frontera
transaccional del dominio**, y la respuesta tiene un número de error: el 10016.

---

## 🎯 2. Objetivos de esta fase

1. Reproducir con `lab race` los cuatro diseños de numeración de Alameda (`DMax + 1`, `UltimoNumero`, una secuencia y la fila
   contador) y ver cómo responde a cada uno un web service que se comporta como el real.
2. Explicar por qué una secuencia no sirve para un número sin huecos, aunque nunca repita.
3. Medir lo que serializa la fila contador y de qué depende la espera por comprobante.
4. Diseñar la numeración donde corresponde al dominio: el número se asigna al autorizar, no al crear el comprobante.
5. Manejar la falla que el manual del organismo describe: la autorización llega y la respuesta no.
6. Decidir cuándo **no** exigir numeración sin huecos.

---

## 🚫 3. Qué NO entra todavía

- **Quién espera a quién en `pg_locks`, y los *deadlocks* entre cajas** → [Fase 18](18-bloqueos-deadlocks-y-ddl.md).
- **El costo de las filas que el contador deja atrás con cada `UPDATE`** → [Fase 17](17-mvcc-y-su-factura.md).
- **El web service real**: certificados, *token* y SOAP. El simulado declara lo que simplifica (sección 5.1).
- **La facturación a obras sociales**, que no exige número correlativo → Bloque VI.

---

## 🏚️ 4. El dolor, en la caja

Desde el 1 de julio de 2015, Alameda autoriza cada comprobante contra el web service del organismo recaudador, que exige que el
número sea **exactamente el último autorizado más uno**, por punto de venta y tipo de comprobante. La caja trae los dos lados de
esa historia: `Comprobantes` (570.046 autorizados, desde julio de 2015) y `ComprobantesRechazados`, con el código y el mensaje del
organismo:

```sql
-- postgres
SELECT "Fecha"::date, "PuntoVenta", "Numero", "Codigo", "Mensaje"
FROM legacy."ComprobantesRechazados" ORDER BY "Fecha" LIMIT 3;
```

```text
   Fecha    | PuntoVenta | Numero | Codigo |                     Mensaje
------------+------------+--------+--------+-------------------------------------------------
 2015-07-01 |          1 |     12 | 10016  | comp. 12 no coincide con el próximo a autorizar
 2015-07-02 |          1 |     27 | 10016  | comp. 27 no coincide con el próximo a autorizar
 2015-07-03 |          1 |     39 | 10016  | comp. 39 no coincide con el próximo a autorizar
```

En julio de 2015, 25 rechazos sobre 1.062 comprobantes; 15 son del punto de venta 1, el laboratorio central, que emite la mitad
de los comprobantes del mes (533). Es el `DMax + 1` de 2004 corriendo en tres cajas contra el mismo SQL Server, la tarde de julio
de la historia. Esta fase supone que las cajas que chocan comparten un punto de venta, porque el organismo numera por punto de
venta: dos cajas con puntos de venta distintos no pueden pedir el mismo número. Desde agosto, con `UltimoNumero`, entre 16 y 21 rechazos por año hasta 2019; desde 2020, con el volumen de la pandemia,
entre 67 y 157. Bajaron, y nunca llegaron a cero.

La caja trae también el código: `vba/ModFolio.bas`, el módulo de Access que numera. El `DMax` sobre `Comprobantes` quedó
comentado, con la fecha ("2015-07, la primera semana, hasta que salió el error 10016"), y debajo, el arreglo:

```vb
' 2015-07: el numero sale de UltimoNumero. Primero se suma, despues se lee.
Public Function ProximoComprobante(ByVal pv As Integer, ByVal tipo As String) As Long
    Dim db As DAO.Database
    Set db = CurrentDb
    db.Execute "UPDATE UltimoNumero SET Ultimo = Ultimo + 1 " & _
               "WHERE PuntoVenta = " & pv & " AND TipoComprobante = '" & tipo & "'", dbFailOnError + dbSeeChanges
    ProximoComprobante = DLookup("Ultimo", "UltimoNumero", _
                         "PuntoVenta = " & pv & " AND TipoComprobante = '" & tipo & "'")
End Function
```

Dos sentencias, cada una confirmada sola. Esta fase la reproduce sobre Postgres.

El manual del desarrollador del WSFEv1 describe así la validación 10016: *"El número de comprobante informado debe ser mayor en 1
al último informado para igual punto de venta y tipo de comprobante. Consultar método FECompUltimoAutorizado"*. Y en su ejemplo, el
mensaje que vuelve es `comp. 4 no coincide con el próximo a autorizar`.

---

## 🧩 5. Cuatro maneras de numerar, contra el organismo

### 5.1 El organismo, simulado

`src/16-el-folio-sin-huecos/fiscal.py` imita lo que del web service importa para numerar, con los nombres del manual:
`last_authorized` (`FECompUltimoAutorizado`), `request_cae` (`FECAESolicitar`, de a un comprobante) y `query`
(`FECompConsultar`). Guarda lo autorizado en el esquema `fiscal`, con su propia conexión: **la transacción de la caja no lo
alcanza**, igual que no alcanza a la base del organismo. Rechaza con 10016 todo número que no sea el último más uno, y su
latencia es configurable.

Lo que simplifica, dicho: no hay SOAP, ni certificado, ni fechas, ni importes, ni lotes de varios comprobantes; un pedido es un
comprobante. Lo que conserva es lo que importa: el organismo numera por punto de venta y tipo, atiende un pedido por vez, y lo que
autorizó no se deshace.

`races.py` intercala dos cajas del punto de venta 1 con `lab race` ([`a04`](a04-el-arnes-de-forma.md#-uv-run-lab-race-sesiones-en-un-orden-fijo)),
con pasos que llaman al organismo en medio de la transacción. El organismo arranca en el último autorizado de la caja, 247.581.

### 5.2 `DMax + 1` y `UltimoNumero`

`DMax + 1` lee el máximo y le suma uno, sin transacción. Dos cajas leen a la vez:

```text
 a1  1 fila  (247582)
 b1  1 fila  (247582)
 a2  INSERT 1
 b2  INSERT 1
 a3  organismo: autorizado 247582
 b3  organismo: rechazado 10016 (comp. 247582 no coincide con el próximo a autorizar)
```

El segundo se rechaza. `UltimoNumero`, el arreglo de 2015, guarda el último número en una tabla y hace "un `UPDATE` y un `SELECT`,
en ese orden y sin transacción". Cada sentencia confirma sola, y la ventana entre las dos sigue abierta:

```text
 a1  UPDATE 1
 b1  UPDATE 1
 a2  1 fila  (247583)
 b2  1 fila  (247583)
 a4  organismo: rechazado 10016 (comp. 247583 no coincide con el próximo a autorizar)
 b4  organismo: rechazado 10016 (comp. 247583 no coincide con el próximo a autorizar)
```

Peor que `DMax + 1`: **las dos cajas se rechazan**. Ninguna pidió el 247.582, y el organismo espera exactamente ese. La ventana
es más corta (dos sentencias, no un formulario), y por eso los rechazos bajaron; el mecanismo es el mismo, y por eso no
desaparecieron.

### 5.3 La secuencia: nunca repite, y no sirve

Una secuencia (`nextval`) nunca da el mismo número dos veces, a nadie. Parece la respuesta, y falla de dos maneras
(`races.py sequence`):

```text
 a2  1 fila  (247582)                                   la caja a toma un número y sigue armando
 b2  1 fila  (247583)                                   la caja b toma el siguiente
 b3  organismo: rechazado 10016 (comp. 247583 …)       b llega primero al organismo: espera el 247.582
 a3  ROLLBACK                                           a se arrepiente: el 247.582 no vuelve
 c1  1 fila  (247584)
 c2  organismo: rechazado 10016 (comp. 247584 …)       y desde ahora, ninguno
```

La primera: la secuencia **no espera a nadie**, así que el orden en que se piden los números no es el orden en que llegan al
organismo. La segunda: la secuencia **no es transaccional**. Un `ROLLBACK` no devuelve el número, y la documentación de
Postgres lo dice sin vueltas: las secuencias no sirven para obtener una numeración sin huecos, porque un `nextval` nunca se deshace.
A eso se suma la caché (`CACHE n`): cada sesión reserva varios números a la vez, y los que no usa se pierden al cerrar.

Después de ese `ROLLBACK`, la caja queda **trabada**: el organismo espera el 247.582, que la secuencia ya no va a dar nunca.
Cada comprobante nuevo se rechaza hasta que alguien mueve la secuencia a mano. Es la caja de la tarde de julio, con cuarenta
pacientes en la sala.

### 5.4 La fila contador

El número se toma con una sola sentencia que incrementa y devuelve (`UPDATE … RETURNING`), **dentro de la transacción** que
autoriza y guarda el comprobante (`races.py counter`):

```text
 a2  1 fila  (247582)                      UPDATE … SET last_number = last_number + 1 … RETURNING
 a3  INSERT 1
 b2  ⏳ espera un bloqueo                  la caja b quiere el número: la fila está tomada
 a4  organismo: autorizado 247582
 a5  COMMIT
   ↳ b2  1 fila  (247583)
 b4  organismo: autorizado 247583
```

Sin huecos y sin repetidos, porque el número y el comprobante se confirman o se deshacen juntos, y porque **nadie toma un número
mientras otro lo tiene**. Lo que esto cuesta es exactamente eso: la fila contador serializa las cajas del punto de venta. Cada caja
espera a que la anterior termine su transacción entera, incluida la llamada al organismo. El *advisory lock*
(`pg_advisory_xact_lock(punto_de_venta)` y después `max() + 1`) hace lo mismo con otra herramienta: serializa por una clave que
no es una fila, y se suelta con la transacción.

### 5.5 El número se asigna al autorizar

Si la espera depende de cuánto dura la transacción que retiene el número, el diseño tiene que retenerlo lo menos posible. Un
comprobante tiene dos momentos: **se arma** (el paciente, las prácticas, el importe, la impresión de la orden) y **se autoriza**.
Solo el segundo necesita número. El diseño que corresponde al dominio:

```sql
-- 1. armar: sin número, fuera de toda transacción larga
INSERT INTO staging.invoice (point_of_sale, kind, till) VALUES (1, 'B', 'caja_1') RETURNING invoice_id;
-- 2. autorizar: una transacción corta que solo numera, pide el CAE y lo guarda
BEGIN;
UPDATE staging.invoice_counter SET last_number = last_number + 1
WHERE point_of_sale = 1 AND kind = 'B' RETURNING last_number;          -- el número, recién ahora
-- … FECAESolicitar con ese número …
UPDATE staging.invoice SET number = $1, cae = $2 WHERE invoice_id = $3;
COMMIT;
```

La columna `number` es `NULL` hasta que hay CAE. Un comprobante armado y no autorizado no tiene número, y no deja hueco.

### 5.6 Cuando el organismo autoriza y no responde

Queda un caso que ninguna transacción de la caja puede cubrir. El manual lo describe en "Operatoria con errores de
comunicación": el cliente pide el CAE y la respuesta no llega. *"El usuario no sabrá si la solicitud le llegó al WsfeV1"*; si la
autorizó y la caja vuelve a pedir el mismo número, el organismo *"devolvería un error de consecutividad puesto que en la base de
datos de AFIP esa factura ya figura como emitida"*. `fiscal.py` simula esa falla (`lose_next_response()`):

```text
 a3  1 fila  (247582)
 a5  organismo: sin respuesta; la caja deshace el 247582
 b2  1 fila  (247582)                       el contador volvió atrás con el ROLLBACK
 b4  organismo: rechazado 10016 (comp. 247582 …)
```

La caja deshizo su transacción y el contador volvió a 247.581; el organismo no deshizo nada. Ahora la caja tiene un 247.582 sin CAE
y el organismo tiene un 247.582 autorizado que la caja no conoce. La salida es la que el manual indica: ante una respuesta que no
llega, **preguntar** con `FECompConsultar` antes de deshacer (`races.py reconcile`):

```text
 a5  organismo: autorizado 247582 (confirmado después de consultar)
 b2  1 fila  (247583)
 b4  organismo: autorizado 247583
```

La transacción de la caja no puede abarcar al organismo. Lo que se puede hacer es que la caja **no decida sola** qué pasó cuando
no sabe.

> 🩻 **Esto sí funciona igual** en los tres motores: una secuencia no se deshace con la transacción, y una fila que se actualiza
> queda bloqueada hasta el `COMMIT`.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**MySQL no tiene `UPDATE … RETURNING`.** La fila contador se escribe con `LAST_INSERT_ID(expr)`, que asigna el valor y lo guarda
para esa conexión, y nadie más lo ve (`counter_mysql.race`):

```sql
UPDATE staging.invoice_counter SET last_number = LAST_INSERT_ID(last_number + 1) WHERE point_of_sale = 1 AND kind = 'B';
SELECT LAST_INSERT_ID();
```

```text
 a2  UPDATE 1
 b2  ⏳ espera un bloqueo
 a3  1 fila  (247582)
 a4  INSERT 1
 a5  ROLLBACK
   ↳ b2  UPDATE 1
 b3  1 fila  (247582)                       sin hueco: el contador volvió con el ROLLBACK
comprobación: 1 fila  (2, 247582, b)        pero el AUTO_INCREMENT de la tabla perdió el 1
```

El contador se comporta igual que en Postgres. El `AUTO_INCREMENT` de `invoice_id`, no: el `INSERT` deshecho de a consumió el 1,
y el comprobante de b es el 2. Es la secuencia de la sección 5.3 con otro nombre.

**El *advisory lock* de MySQL es de la sesión, no de la transacción.** `GET_LOCK('pos_1_B', 10)` se suelta con `RELEASE_LOCK` o al
cerrar la conexión; el `COMMIT` no lo suelta (`get_lock_mysql.race`):

```text
 a2  1 fila  (1)            a toma el lock dentro de una transacción
 a3  COMMIT
 b1  1 fila  (0)            b no lo consigue: el COMMIT no lo soltó
 a4  1 fila  (1)            RELEASE_LOCK
 b2  1 fila  (1)
```

Con un *pool* de conexiones, una caja que olvida el `RELEASE_LOCK` deja el punto de venta trabado para la siguiente que use esa
conexión. En Postgres, `pg_advisory_xact_lock` no tiene ese problema; `pg_advisory_lock`, sin `xact`, sí.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: una secuencia `NOCACHE ORDER` también deja el hueco del `ROLLBACK`, y la fila
> contador con `UPDATE … RETURNING last_number INTO :n` serializa las cajas igual que en Postgres. Condiciones: el contador y
> una secuencia `NOCACHE ORDER` creados en el esquema de la aplicación, y los pasos de `races.py sequence` y `races.py counter` a
> mano en dos sesiones de `sqlplus` ([`a03`](a03-clis-de-los-motores.md#️-oracle--sqlplus)). El mecanismo, en la documentación
> oficial de `CREATE SEQUENCE`: la secuencia se incrementa "independent of the transaction committing or rolling back", y un número
> puede parecer saltado porque se usó en una transacción que se deshizo. 📝 No publicamos números de Oracle; el porqué está en
> [`a09`](a09-licencias-publicacion-y-riesgo.md).

---

## 🪞 7. Tu instinto dice… y la apuesta

**Tu instinto dice** que un número sin huecos es un contador con un bloqueo, y que el bloqueo cuesta poco porque tomar un
número es instantáneo.

> 🪞 **Apuesta antes de ejecutar** (escrita el 30/09/2026, al diseñar esta fase). *"Con la fila contador, tres cajas concurrentes
> emiten 10.000 comprobantes con cero duplicados y cero huecos, y la espera por comprobante crece con la duración de la
> transacción que retiene el número."*
> **Resultado:** **ganada.** `cajas.py --design counter --invoices 10000`: 10.000 comprobantes autorizados, del 247.582 al
> 257.581, 0 repetidos, 0 sin CAE, 0 huecos y 0 rechazos, con una espera media por el número de 5,4 ms (11,4 ms el percentil 99). Y la espera sigue a la retención: con el comprobante
> armado mientras el número está tomado, pasa de 5,5 ms a 11,9, 22,8 y 36,0 ms cuando armar tarda 0, 2, 5 y 10 ms (en la validación del bloque, 31,9 ms con 10 ms de armado,
> contra 0,8 con el número al autorizar).

Tomar el número es instantáneo; **soltarlo, no**. La fila queda bloqueada desde el `UPDATE` hasta el `COMMIT`, y cada milisegundo
que la transacción pasa armando el comprobante o esperando al organismo lo espera también cada caja que viene detrás.

---

## 💥 8. El punto de rotura

**El rechazo 10016, reproducido con el diseño de 2015.** `cajas.py` pone tres cajas a emitir a la vez, con cada diseño, contra
el organismo simulado. Con un organismo de 50 ms y 20 ms para armar cada comprobante, 900 comprobantes:

> 📐 **Medición: tres cajas, 900 comprobantes, organismo de 50 ms** · Postgres · verificado el 14/10/2026
>
> | Diseño | Autorizados | Rechazos 10016 | Huecos | Espera media por el número | Total |
> |---|---|---|---|---|---|
> | `DMax + 1` (2004) | 900 | 2.404 | 0 | 1,3 ms | 64,7 s |
> | `UltimoNumero` (2015) | 900 | 180 | 0 | 2,6 ms | 31,5 s |
> | fila contador, número al armar | 900 | 0 | 0 | 161,5 ms | 73,5 s |
> | número al autorizar | 900 | 0 | 0 | 91,7 ms | 52,3 s |

Los dos diseños viejos no tienen huecos en el organismo, porque el organismo no los permite: **los convierte en rechazos**. Cada
rechazo es un comprobante que vuelve a la cola, y en la caja real, un cajero que no sabe qué pasó. Las cajas del laboratorio no
emiten sin pausa como las de esta medición, y por eso los rechazos reales fueron unos pocos por mes; lo que la medición muestra es
**el mecanismo**: cuanto más dura la ventana entre leer el número y autorizarlo, más rechazos.

La rotura del diseño correcto es otra: cuando el organismo tarda, la fila contador retiene el número el tiempo que tarda el
organismo, y las cajas hacen fila. Con el organismo a 50 ms, la espera media por el número es de 161,5 ms si el número se toma
al armar (los 20 ms de armado y los 50 del organismo, de las cajas que van delante) y de 91,7 ms si se toma al autorizar. Los
diseños correctos tardan más en total que `UltimoNumero` (73,5 y 52,3 s contra 31,5): **el precio de no rechazar es esperar**.

---

## ⚰️ 9. Autopsia: `UltimoNumero`, la tarde de julio y los cuarenta pacientes

**1. La decisión.** Julio de 2015: *"Que el número salga de una tabla, `UltimoNumero`, con un `UPDATE` y un `SELECT`."* Un
`UPDATE` primero, para que el número se reserve antes de leerlo.

**2. Por qué era razonable.** `DMax + 1` leía el máximo de una tabla de cientos de miles de comprobantes mientras el cajero armaba
el comprobante: una ventana de segundos. `UltimoNumero` la achicó a dos sentencias seguidas, y los rechazos bajaron de 25 en julio
de 2015 a entre 16 y 21 por año hasta 2019. Para un problema que aparecía cuando dos cajas emitían a la vez, achicar la ventana
pareció resolverlo.

**3. Qué pasó después.** Sin transacción, cada sentencia confirma sola: dos cajas pueden incrementar antes de que cualquiera lea,
las dos leen el mismo número y **las dos se rechazan**, y el número que se saltó nadie lo pide. Con la pandemia, más comprobantes
por minuto en las mismas tres cajas: entre 67 y 157 rechazos por año desde 2020, en la caja. En la medición, 180 rechazos en 900
comprobantes, contra 2.404 de `DMax + 1` y 0 de la fila contador.

**4. Cuánto cuesta salir.** Poco código: envolver el `UPDATE` y el `SELECT` en una transacción, o juntarlos en `UPDATE …
RETURNING`, y llamar al organismo antes del `COMMIT`. Lo que cuesta es lo que la sección 5.6 agrega: la caja tiene que preguntar al
organismo cuando no sabe, en lugar de deshacer.

**5. Qué lo habría cambiado.** Preguntar dónde está la frontera transaccional del comprobante. No estaba en la caja: estaba en el
organismo, que es el único que decide qué número es el próximo. La caja solo puede no adelantarse.

**Antes y después, con números:** 180 rechazos con `UltimoNumero` contra 0 con la fila contador, en 900 comprobantes; y la espera
por el número, de 161,5 ms con el número tomado al armar a 91,7 ms con el número tomado al autorizar.

---

## 📖 10. Traducción

| Concepto | Access / T-SQL | Postgres | MySQL | Oracle |
|---|---|---|---|---|
| numerar sin transacción | `DMax + 1` en el formulario | `SELECT max() + 1` | `SELECT MAX() + 1` | `SELECT MAX() + 1` |
| secuencia | `IDENTITY`, `SEQUENCE` | `SEQUENCE`, `IDENTITY` | `AUTO_INCREMENT` | `SEQUENCE`, `IDENTITY` |
| incrementar y devolver en una sentencia | `UPDATE … OUTPUT inserted.…` | `UPDATE … RETURNING` | `LAST_INSERT_ID(expr)` | `UPDATE … RETURNING … INTO` |
| lock con nombre, de la transacción | `sp_getapplock @LockOwner = 'Transaction'` | `pg_advisory_xact_lock` | — | `DBMS_LOCK.REQUEST(…, release_on_commit => TRUE)` |
| lock con nombre, de la sesión | `sp_getapplock @LockOwner = 'Session'` | `pg_advisory_lock` | `GET_LOCK` | `DBMS_LOCK.REQUEST` |

Hacia la NoSQL Lite: un contador en MongoDB es un `findOneAndUpdate` con `$inc` sobre un documento por punto de venta. Es la
fila contador de la sección 5.4, con la misma serialización; y la llamada al organismo sigue fuera de la transacción del
documento. El diccionario completo está en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO exigir numeración sin huecos

**Casi nunca.** Un número sin huecos es caro por diseño: serializa a todos los que numeran en el mismo ámbito, y obliga a
reconciliar con un tercero cuando lo hay. Antes de pagarlo, hay que preguntar quién **exige** que no haya huecos. En Alameda:

- **El protocolo no.** `NroProtocolo` identifica una orden, va impreso en el sobre del paciente, y nadie lo valida contra nadie.
  Que falte el 48.213 no le importa a ningún organismo. Una secuencia o una identidad alcanzan, y no serializan nada. Lo que el
  protocolo necesita es **no repetirse** (la caja trae 3.902 números repetidos, de `DMax + 1`), y eso es `UNIQUE`, no "sin huecos".
- **El turno, la muestra, la orden de compra de reactivos**: lo mismo. Un identificador, no un folio.
- **El comprobante fiscal sí**, por ley y por el web service. Y solo él: por punto de venta y tipo de comprobante.

**Cuando sí hace falta, el ámbito más chico que la ley permita.** El organismo numera por punto de venta. Tres cajas que comparten un
punto de venta se serializan entre ellas; tres cajas con un punto de venta cada una no se esperan nunca (ejercicio 14: de 36 ms de
espera a 0,21). Si las cajas del central comparten el punto de venta 1, como en esta fase, la decisión más barata para su
contención no es técnica: es dar de alta un punto de venta por caja.

**Y el número se asigna al autorizar.** Todo lo que se hace con el número tomado lo espera la caja siguiente: con 10 ms de armado
adentro, 36 ms de espera por el número; afuera, 1,2 ms (sección 7).

**Lo que no se mide aquí:** el organismo real, con su latencia y sus caídas; la autorización por lotes de varios comprobantes,
que el manual permite y cambia la cuenta; y el CAEA, el régimen en que el organismo da un código por período y los comprobantes
se informan después.

Las cinco preguntas, para lo que enseñó esta fase:

- **Frontera transaccional:** la del comprobante incluye al organismo, y ninguna transacción de la base lo abarca.
- **Consultas conocidas:** la única consulta que importa es "el próximo número", y su respuesta la tiene el organismo.
- **Unidad de lectura:** una fila por punto de venta y tipo; cuantas menos cajas compartan esa fila, menos espera.
- **Saltos:** ninguno; el problema no es de datos, es de orden.
- **Exactitud o parecido:** el folio fiscal exige exactitud; el protocolo, solo unicidad.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **`comp. N no coincide con el próximo a autorizar` (10016).** 🩺 El número no es el último autorizado más uno para ese punto de
  venta y tipo. Pregunta `FECompUltimoAutorizado` y compáralo con el contador de la caja: si el organismo va adelante, hubo una
  autorización cuya respuesta se perdió; si va atrás, la caja se adelantó.
- **Dos cajas rechazadas a la vez con el mismo número.** 🩺 `UltimoNumero` sin transacción (sección 5.2).
- **Una caja rechazada en cada comprobante desde cierto momento.** 🩺 Un número se perdió (una secuencia después de un
  `ROLLBACK`, o una respuesta perdida): el contador quedó adelante del organismo.
- **Las cajas del central tardan más cuanto más tarda el organismo.** 🩺 La fila contador retiene el número durante la
  llamada. Es lo esperado; se mitiga con un punto de venta por caja.
- **En MySQL, el punto de venta queda trabado aunque la caja confirmó.** 🩺 `GET_LOCK` sin `RELEASE_LOCK`: es de la sesión.
- **Huecos en `AUTO_INCREMENT` o en una identidad.** 🩺 No es un error: es como funcionan. Si molestan, la columna no era un
  folio.

---

## 📋 13. Checklist de validación

```text
[ ] races.py dmax: el segundo comprobante, rechazado con 10016
[ ] races.py ultimo_numero: los dos rechazados, y el 247.582 que nadie pidió
[ ] races.py sequence: rechazo por orden, y la caja trabada después del ROLLBACK
[ ] races.py counter: b espera a a, y los dos autorizados sin hueco
[ ] races.py lost_response y reconcile: el 10016 sin consultar, y la autorización con FECompConsultar
[ ] cajas.py --design counter --invoices 10000: 10.000 autorizados, 0 repetidos, 0 huecos, 0 rechazos
[ ] la espera por el número crece con --hold en counter y no en at_authorization
[ ] counter_mysql.race y get_lock_mysql.race: el contador sin hueco y el lock que sobrevive al COMMIT
```

---

## 🧪 14. Ejercicios (26)

Los escenarios se corren desde `src/` después de `16-el-folio-sin-huecos/01_setup.sql` (y `01_setup_mysql.sql` en MySQL):
`uv run python 16-el-folio-sin-huecos/races.py <escenario>` y `uv run python 16-el-folio-sin-huecos/cajas.py --design …`.

## 🟢 Fácil — reproducir (1–8)

### 🟢 Ejercicio 1 — Los rechazos de la caja

Cuenta los rechazos de `ComprobantesRechazados` por año y por punto de venta, y los comprobantes de julio de 2015.

**Objetivo:** los 25 de julio de 2015, y por qué casi todos son del punto de venta 1.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-1)

### 🟢 Ejercicio 2 — `DMax + 1`

Corre `races.py dmax`.

**Objetivo:** qué número piden las dos cajas y cuál se rechaza.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-2)

### 🟢 Ejercicio 3 — `UltimoNumero`

Corre `races.py ultimo_numero`.

**Objetivo:** por qué se rechazan las dos, y qué número espera el organismo.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-3)

### 🟢 Ejercicio 4 — La secuencia trabada

Corre `races.py sequence`.

**Objetivo:** los dos motivos de rechazo, y qué haría falta para destrabar la caja.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-4)

### 🟢 Ejercicio 5 — La fila contador

Corre `races.py counter`.

**Objetivo:** en qué paso espera b, y hasta cuándo.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-5)

### 🟢 Ejercicio 6 — El hueco de la secuencia

En `psql`, dos sesiones: `BEGIN; SELECT nextval('staging.invoice_number_seq'); ROLLBACK;` en la primera, y `nextval` en la
segunda.

**Objetivo:** el número que recibe la segunda, y la frase de la documentación que lo explica.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-6)

### 🟢 Ejercicio 7 — El contador en MySQL

Corre `counter_mysql.race`.

**Objetivo:** el número de b después del `ROLLBACK` de a, y el `invoice_id` de su comprobante.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-7)

### 🟢 Ejercicio 8 — `GET_LOCK`

Corre `get_lock_mysql.race`.

**Objetivo:** qué devuelve el `GET_LOCK` de b antes y después del `RELEASE_LOCK` de a.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-8)

## 🟡 Intermedio — el costo de no tener huecos (9–15)

### 🟡 Ejercicio 9 — Diez mil comprobantes

Corre `cajas.py --design counter --invoices 10000`.

**Objetivo:** autorizados, repetidos, huecos y rechazos, y la espera media por el número.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-9)

### 🟡 Ejercicio 10 — Lo que retiene el número

Corre `cajas.py` con `--design counter` y con `--design at_authorization`, con `--hold` de 0, 2, 5 y 10 ms y 1.500
comprobantes.

**Objetivo:** la espera media de cada diseño en cada caso.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-10)

### 🟡 Ejercicio 11 — El organismo lento

Repite la fila contador y el número al autorizar con `--latency` de 1, 10 y 50 ms, sin `--hold`.

**Objetivo:** cómo crece la espera con la latencia en los dos diseños, y por qué.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-11)

### 🟡 Ejercicio 12 — La respuesta perdida

Corre `races.py lost_response` y `races.py reconcile`.

**Objetivo:** qué tiene la caja y qué tiene el organismo al final de cada uno.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-12)

### 🟡 Ejercicio 13 — El *advisory lock*

Corre `cajas.py --design advisory` con 3.000 comprobantes y compáralo con `counter`.

**Objetivo:** la espera media de los dos, y qué índice necesita `advisory` para no leer la tabla entera en cada número.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-13)

### 🟡 Ejercicio 14 — Un punto de venta por caja

Cambia `cajas.py` para que cada caja use su propio punto de venta, y mide la espera con `--design counter --hold 0.010`.

**Objetivo:** la espera media contra los 36 ms de un punto de venta compartido.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-14)

### 🟡 Ejercicio 15 — El protocolo no necesita esto

Muestra en la caja que `NroProtocolo` tiene repetidos, y escribe la restricción que el protocolo sí necesita.

**Objetivo:** los repetidos, y la restricción sobre una copia en `staging`.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-15)

## 🟠 Difícil — diseñar la numeración (16–21)

### 🟠 Ejercicio 16 — El orden de las cajas

Con la fila contador, ¿el orden de los números es el orden en que las cajas empezaron a armar? Diséñalo con `lab race` y
compruébalo.

**Objetivo:** una permutación donde el comprobante que empezó primero recibe el número mayor.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-16)

### 🟠 Ejercicio 17 — La reconciliación del arranque

Escribe la rutina que corre al abrir la caja: compara el contador con `last_authorized` y decide qué hacer en cada caso.

**Objetivo:** los tres casos (iguales, el organismo adelante, la caja adelante), cada uno probado con `fiscal.py`.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-17)

### 🟠 Ejercicio 18 — El contador y `SERIALIZABLE`

Corre `races.py counter` con las dos transacciones en `SERIALIZABLE`.

**Objetivo:** si cambia algo, y qué le pasaría al diseño `DMax + 1` en `SERIALIZABLE`.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-18)

### 🟠 Ejercicio 19 — La caja que se cae con el número tomado

Con la fila contador, simula una caja cuyo proceso muere entre el `UPDATE` y el `COMMIT`.

**Objetivo:** qué pasa con el número y con la caja siguiente, y cuánto tarda en destrabarse.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-19)

### 🟠 Ejercicio 20 — El reintento ante 10016

Diseña qué hace la caja del diseño correcto cuando, aun así, recibe un 10016.

**Objetivo:** el código, probado con un organismo que va un número adelante de la caja.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-20)

### 🟠 Ejercicio 21 — Lotes

El manual permite autorizar varios comprobantes en un pedido. Mide con `fiscal.py` cuánto baja la espera por comprobante si una
caja autoriza de a diez.

**Objetivo:** la espera por comprobante con lotes de 1 y de 10, y qué pasa si el quinto se rechaza.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-21)

## 🔴 Muy difícil — decidir (22–26)

### 🔴 Ejercicio 22 — Oracle

Resuelve en tu máquina la apuesta 🪞🔒 de la sección 6.

**Objetivo:** el resultado explicado con la documentación de `CREATE SEQUENCE`, sin publicar ningún número.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-22)

### 🔴 Ejercicio 23 — ¿Qué números necesitan no tener huecos?

Haz el inventario de los números que asigna el sistema de Alameda y decide, para cada uno, si necesita unicidad, orden o ninguno
de los dos.

**Objetivo:** la tabla, con la fuente de cada exigencia.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-23)

### 🔴 Ejercicio 24 — El diseño de la facturación nueva

Diseña las tablas del comprobante para el modelo `alameda`: dónde vive el número, qué pasa con un comprobante sin autorizar, y
cómo se reconcilia con el organismo.

**Objetivo:** el DDL y el flujo, con la medición de la sección 7.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-24)

### 🔴 Ejercicio 25 — Tres cajas, tres puntos de venta

Argumenta ante Matías por qué el central debería tener un punto de venta por caja, con lo que cuesta y lo que no resuelve.

**Objetivo:** el argumento, con las mediciones de los ejercicios 10, 11 y 14.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-25)

### 🔴 Ejercicio 26 — La caja sin conexión

Si el organismo no responde durante una hora, ¿la caja deja de cobrar? Diseña qué hace, sin romper la numeración.

**Objetivo:** el diseño, y qué parte de él depende de una regla del organismo que el curso no verificó.

[Solución](soluciones/16-el-folio-sin-huecos.md#ejercicio-26)

---

## 📚 15. Referencias

**Documentación oficial**

- **Manual del desarrollador del WSFEv1**, versión 3.1 (01/01/2023) — https://www.afip.gob.ar/fe/ayuda/documentos/wsfev1-COMPG.pdf
  — la validación 10016, `FECompUltimoAutorizado`, `FECompConsultar` y la operatoria ante errores de comunicación.
- **Secuencias en Postgres 18** — https://www.postgresql.org/docs/18/functions-sequence.html — por qué un `nextval` nunca se
  deshace.
- **`UPDATE … RETURNING`** — https://www.postgresql.org/docs/18/sql-update.html
- **Advisory locks** — https://www.postgresql.org/docs/18/explicit-locking.html#ADVISORY-LOCKS
- **`LAST_INSERT_ID(expr)` en MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/information-functions.html#function_last-insert-id
  — el contador de una sentencia.
- **`GET_LOCK` en MySQL 9.7** — https://dev.mysql.com/doc/refman/9.7/en/locking-functions.html
- **`CREATE SEQUENCE` en Oracle** — https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/CREATE-SEQUENCE.html

**Papers y libros**

- **Martin Kleppmann y Chris Riccomini, *Designing Data-Intensive Applications*, 2.ª ed., O'Reilly, 2026** — el capítulo de
  transacciones, y lo que cambia cuando una operación sale del sistema.
- **Bill Karwin, *SQL Antipatterns, Volume 1*, Pragmatic Bookshelf, 2022** — el antipatrón de "ordenar las claves" (*Pseudokey
  Neat-Freak*): querer identificadores sin huecos donde no hacen falta.

**Orden de lectura sugerido:** la sección 2.2.5 del manual del WSFEv1 antes de la sección 5.6; la página de secuencias de
Postgres antes de la 5.3; Karwin antes del veredicto.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 14/10/2026.

---

## 🏁 16. Resultado de la fase

```text
LOS CUATRO DISEÑOS, CONTRA EL ORGANISMO
  DMax + 1                el segundo, rechazado con 10016
  UltimoNumero            los dos rechazados; el número intermedio nadie lo pide
  secuencia               rechazo por orden; después de un ROLLBACK, la caja trabada
  fila contador           sin huecos ni repetidos; b espera a que a confirme
LA APUESTA · 3 cajas
  10.000 comprobantes     0 repetidos · 0 huecos · 0 rechazos · espera media 5,4 ms
  armar con el número     espera 5,5 · 11,9 · 22,8 · 36,0 ms con 0, 2, 5 y 10 ms de armado
  número al autorizar     espera 0,8 a 2,0 ms, con cualquier armado
LA RESPUESTA PERDIDA
  sin consultar           10016 para la caja siguiente
  con FECompConsultar     el número se confirma y la caja sigue
```

> **La señal de que quedó bien:** *"Puedo decir qué número de mi sistema necesita no tener huecos y por qué, asignarlo donde
> cuesta menos esperar, y qué hace la caja cuando no sabe si el organismo autorizó."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-16-el-folio-sin-huecos -m "F16 cerrada: los cuatro diseños de numeración contra el organismo simulado, la fila contador medida, el número al autorizar y la respuesta perdida"
> ```
>
> Commits de la fase con prefijo `f16:`, los de ejercicio `f16 ej26: …`.
