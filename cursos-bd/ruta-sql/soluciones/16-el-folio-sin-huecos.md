# ✅ Soluciones — Fase 16: El folio sin huecos

> **Curso:** Ruta SQL · Solucionario de la [Fase 16](../16-el-folio-sin-huecos.md)
> **Ejercicios:** 26 · **Perfil:** M · **Motores:** Postgres y MySQL de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 14/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todas las soluciones suponen `16-el-folio-sin-huecos/01_setup.sql` corrido en Postgres y `01_setup_mysql.sql` en MySQL. Los
scripts se corren desde `src/` con `uv run python`; los de las soluciones importan `fiscal.py` y `races.py` de
`16-el-folio-sin-huecos/`. `cajas.py` usa hilos de verdad: las esperas cambian entre corridas, los conteos de huecos y
repetidos no.

---

## 🟢 Fácil (1–8)

### Ejercicio 1

**Enunciado (resumen):** los rechazos de la caja.

**Solución.**

```sql
SELECT "PuntoVenta", count(*) FILTER (WHERE "Fecha" < '2015-08-01') AS julio_2015, count(*) AS total
FROM legacy."ComprobantesRechazados" GROUP BY 1 ORDER BY 1;
```

```text
 PuntoVenta | julio_2015 | total
------------+------------+-------
          1 |         15 |   384
          2 |          0 |   109
          3 |          6 |   120
          4 |          3 |   121
          5 |          1 |   108
          6 |          0 |    55
```

Por año: 31 en 2015, entre 16 y 21 de 2016 a 2019, y entre 67 y 157 desde 2020. En julio de 2015, 1.062 comprobantes, de los
cuales 533 son del punto de venta 1. Los rechazos siguen al volumen: el central emite la mitad y tiene más de la mitad de los
rechazos. El punto de venta 6, el autohisopado de la pandemia, no existía en 2015.

**Rúbrica.** Una respuesta correcta tiene que:
- dar los 25 de julio y los 15 del punto de venta 1;
- relacionar los rechazos con los comprobantes de cada punto de venta, no solo contarlos.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-1--los-rechazos-de-la-caja)

### Ejercicio 2

**Enunciado (resumen):** `DMax + 1`.

**Solución.** Las dos cajas leen 247.582 (`a1`, `b1`); las dos lo guardan; el organismo autoriza el de a y rechaza el de b con
`10016 (comp. 247582 no coincide con el próximo a autorizar)`. Al final, la caja tiene dos comprobantes 247.582, uno sin CAE.

**Rúbrica.** Una respuesta correcta tiene que:
- notar que la caja guarda el duplicado aunque el organismo lo rechace.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-2--dmax--1)

### Ejercicio 3

**Enunciado (resumen):** `UltimoNumero`.

**Solución.** Los dos `UPDATE` confirman solos (247.582 y 247.583), y los dos `SELECT` leen 247.583. El organismo espera el
247.582, que nadie pidió: rechaza los dos. En el organismo no queda nada autorizado (`en_el_organismo: NULL`).

**Rúbrica.** Una respuesta correcta tiene que:
- explicar que el primer `UPDATE` ya confirmó cuando el segundo incrementa.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-3--ultimonumero)

### Ejercicio 4

**Enunciado (resumen):** la secuencia trabada.

**Solución.** Primer motivo: **orden**. b tomó el 247.583 después de que a tomara el 247.582, pero llegó antes al organismo, que
espera el 247.582. Segundo motivo: **el `ROLLBACK` no devuelve el número**. Después del `ROLLBACK` de a, el 247.582 no lo va a dar
nadie, y c recibe el 247.584: rechazado, y así cada comprobante. Para destrabar: preguntar el último autorizado
(`FECompUltimoAutorizado`, 247.581) y mover la secuencia con `setval('staging.invoice_number_seq', 247581)`. Con más de una caja
pidiendo números, vuelve a pasar.

**Rúbrica.** Una respuesta correcta tiene que:
- separar los dos motivos;
- notar que el `setval` no arregla el diseño.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-4--la-secuencia-trabada)

### Ejercicio 5

**Enunciado (resumen):** la fila contador.

**Solución.** b espera en `b2`, su `UPDATE … RETURNING` sobre la fila del contador, desde que lo manda hasta el `COMMIT` de a
(`a5`). Entonces recibe 247.583, y los dos quedan autorizados sin hueco.

**Rúbrica.** Una respuesta correcta tiene que:
- ubicar la espera en el `UPDATE`, no en el `INSERT`.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-5--la-fila-contador)

### Ejercicio 6

**Enunciado (resumen):** el hueco de la secuencia.

**Solución.**

```text
 a2  1 fila  (247582)
 a3  ROLLBACK
 b1  1 fila  (247583)
```

La documentación de Postgres: *"the value obtained by nextval is not reclaimed for re-use if the calling transaction later
aborts … Thus, PostgreSQL sequence objects cannot be used to obtain 'gapless' sequences"*.

**Rúbrica.** Una respuesta correcta tiene que:
- dar 247.583 y la cita.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-6--el-hueco-de-la-secuencia)

### Ejercicio 7

**Enunciado (resumen):** el contador en MySQL.

**Solución.** b recibe 247.582: el `ROLLBACK` de a devolvió el contador. Su comprobante tiene `invoice_id` 2: el `INSERT`
deshecho de a consumió el 1 del `AUTO_INCREMENT`, que no vuelve. El contador se comporta como una fila; el `AUTO_INCREMENT`, como
una secuencia.

**Rúbrica.** Una respuesta correcta tiene que:
- dar 247.582 y el `invoice_id` 2.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-7--el-contador-en-mysql)

### Ejercicio 8

**Enunciado (resumen):** `GET_LOCK`.

**Solución.** Antes del `RELEASE_LOCK`, `GET_LOCK('pos_1_B', 0)` de b devuelve 0, aunque a ya confirmó su transacción. Después,
1. El lock es de la sesión: el `COMMIT` no lo suelta.

**Rúbrica.** Una respuesta correcta tiene que:
- dar 0 y 1;
- decir qué pasa con un *pool* de conexiones si la caja no lo suelta.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-8--get_lock)

---

## 🟡 Intermedio (9–15)

### Ejercicio 9

**Enunciado (resumen):** diez mil comprobantes.

**Solución.**

```text
| counter | 3 | 0 ms | 1 ms | 10000 | 0 | 0 | 0 | 0 | 5.4 ms | 11.4 ms | 27.2 s |
```

10.000 autorizados, del 247.582 al 257.581, 0 repetidos, 0 sin CAE, 0 huecos, 0 rechazos; espera media por el número 5,4 ms, el
percentil 99 11,4 ms.

**Rúbrica.** Una respuesta correcta tiene que:
- verificar los huecos contra el organismo (máximo menos mínimo más uno contra la cantidad), no solo contra la caja.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-9--diez-mil-comprobantes)

### Ejercicio 10

**Enunciado (resumen):** lo que retiene el número.

**Solución.**

| Armado | Fila contador (número al armar) | Número al autorizar |
|---|---|---|
| 0 ms | 5,5 ms | — |
| 2 ms | 11,9 ms | 2,0 ms |
| 5 ms | 22,8 ms | 0,8 ms |
| 10 ms | 36,0 ms (31,9 en otra corrida) | 1,2 ms (0,8) |

(sin armado, los dos diseños son el mismo: 5,2 y 4,1 ms en otra corrida de 3.000). Con el número al armar, cada milisegundo de
armado lo espera la caja siguiente; con el número al autorizar, el armado pasa fuera de la transacción y la espera no depende de
él.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar que una columna crece y la otra no.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-10--lo-que-retiene-el-número)

### Ejercicio 11

**Enunciado (resumen):** el organismo lento.

**Solución.** 900 comprobantes, sin armado:

| Organismo | Fila contador | Número al autorizar |
|---|---|---|
| 1 ms | 5,0 ms | 4,1 ms |
| 10 ms | 32,9 ms | 29,5 ms |
| 50 ms | 119,9 ms | 118,8 ms |

Los dos crecen igual: la llamada al organismo está dentro de la transacción que retiene el número en los dos diseños, porque el
número tiene que confirmarse junto con el CAE. Con tres cajas, cada una espera en promedio a algo más de dos llamadas ajenas.
Esta espera no la baja el diseño: la bajan los lotes (ejercicio 21) o un punto de venta por caja (ejercicio 14).

**Rúbrica.** Una respuesta correcta tiene que:
- explicar por qué el número al autorizar no ayuda aquí.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-11--el-organismo-lento)

### Ejercicio 12

**Enunciado (resumen):** la respuesta perdida.

**Solución.** `lost_response`: la caja tiene un comprobante 247.582 de b, sin CAE; el organismo tiene un 247.582 autorizado (el de
a, cuya respuesta se perdió) y nada más. Los dos dicen 247.582, y son ventas distintas. `reconcile`: la caja consultó con
`query` (`FECompConsultar`), encontró el CAE y confirmó el 247.582 de a; b recibió el 247.583. Caja y organismo coinciden: 247.582 y
247.583, los dos con CAE.

**Rúbrica.** Una respuesta correcta tiene que:
- describir el estado de los dos lados, no solo el error.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-12--la-respuesta-perdida)

### Ejercicio 13

**Enunciado (resumen):** el *advisory lock*.

**Solución.** Con 3.000 comprobantes y el organismo a 1 ms: `advisory` 5,4 ms de espera media, `counter` 5,2 ms. Serializan
igual. `advisory` calcula `max(number) + 1` dentro de la transacción, y necesita el índice `(point_of_sale, kind, number)` que
`cajas.py` crea: sin él, cada número lee la tabla entera de comprobantes, que crece con cada uno.

**Rúbrica.** Una respuesta correcta tiene que:
- nombrar el índice, y por qué el contador no lo necesita.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-13--el-advisory-lock)

### Ejercicio 14

**Enunciado (resumen):** un punto de venta por caja.

**Solución de referencia.** Cada caja con su fila del contador (puntos de venta 1, 2 y 3), 500 comprobantes, 10 ms de armado con
el número tomado:

```python
def till(pos):
    conn = connect("postgres")
    for _ in range(500):
        with conn.transaction():
            n = conn.execute(TAKE, (pos, KIND)).fetchone()[0]     # la fila de este punto de venta
            time.sleep(0.010)
            cae = ws.request_cae(pos, KIND, n)
            conn.execute("INSERT INTO staging.invoice (point_of_sale, kind, number, cae, till) VALUES (%s, %s, %s, %s, 'x')",
                         (pos, KIND, n, cae))
```

```text
ej14 · 3 puntos de venta, 1.500 comprobantes: espera media 0.21 ms, total 7.3 s
      autorizados por punto de venta: 1:500 2:500 3:500
```

0,21 ms contra 36 ms con un punto de venta compartido: nadie espera a nadie, y el total baja de 27,2 s a 7,3 s.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar que cada caja toca su propia fila.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-14--un-punto-de-venta-por-caja)

### Ejercicio 15

**Enunciado (resumen):** el protocolo no necesita esto.

**Solución.** 3.902 números de protocolo repetidos. La restricción que el protocolo necesita es `UNIQUE`, y hoy no se puede crear:

```text
ERROR:  could not create unique index "protocol_number_unique"
DETAIL:  Key (protocol_number)=(V-0016886) is duplicated.
```

El protocolo necesita **unicidad**, no orden ni ausencia de huecos. Para el sistema nuevo alcanza una identidad con prefijo de
sede y una restricción `UNIQUE`; los repetidos históricos se resuelven una vez, con la regla de la solución 6 de
[`a05`](a05-la-caja-y-el-generador.md).

**Rúbrica.** Una respuesta correcta tiene que:
- separar unicidad de numeración sin huecos.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-15--el-protocolo-no-necesita-esto)

---

## 🟠 Difícil (16–21)

### Ejercicio 16

**Enunciado (resumen):** el orden de las cajas.

**Solución de referencia.** Con el número al autorizar, a arma primero (`invoice_id` 62.116), b después (62.117), pero b autoriza
primero:

```text
 a1  1 fila  (62116)
 b1  1 fila  (62117)
 b2  autorizado 247582
 a2  autorizado 247583
```

El número fiscal sigue el orden de autorización, no el de llegada del paciente. Con la fila contador tomada al armar, sería el
orden de armado, al precio de la espera de la sección 7. Si alguien necesita el orden de llegada, lo da `created_at`, no el
número fiscal. (Los `invoice_id` vienen de la identidad de `staging.invoice`, que no se reinicia con `TRUNCATE`.)

**Rúbrica.**
- **Aprobado:** la permutación.
- **Bien:** explica qué orden garantiza cada diseño.
- **Excelente:** nota que el organismo no exige orden de llegada, solo correlatividad.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-16--el-orden-de-las-cajas)

### Ejercicio 17

**Enunciado (resumen):** la reconciliación del arranque.

**Solución de referencia.**

```python
def open_till():
    local = admin.execute("SELECT last_number FROM staging.invoice_counter WHERE point_of_sale = 1 AND kind = 'B'").fetchone()[0]
    remote = ws.last_authorized(POS, KIND)
    if local == remote:
        return "abre"
    if remote > local:
        # El organismo autorizó números que la caja no registró: respuestas perdidas. Se traen y se adelanta el contador.
        got = [(n, ws.query(POS, KIND, n)) for n in range(local + 1, remote + 1)]
        admin.execute("UPDATE staging.invoice_counter SET last_number = %s WHERE point_of_sale = 1 AND kind = 'B'", (remote,))
        return f"recupera {len(got)} CAE"
    return "la caja tomó números que el organismo no autorizó: no abre hasta revisarlos"
```

```text
ej17 · iguales: caja 247581 = organismo 247581: abre
ej17 · organismo adelante: caja 247581 < organismo 247583: recupera 2 CAE (247582, 247583) y adelanta el contador
ej17 · caja adelante: caja 247582 > organismo 247581: la caja tomó números que el organismo no autorizó; no abre hasta revisarlos
```

El tercer caso no pasa con el diseño correcto (el número se deshace con la transacción), y por eso no se arregla solo: alguien
cambió el contador a mano o hay otro sistema numerando.

**Rúbrica.**
- **Aprobado:** los tres casos.
- **Bien:** recupera los CAE con `FECompConsultar` en lugar de solo adelantar el contador.
- **Excelente:** el tercer caso no se arregla en automático, y explica por qué.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-17--la-reconciliación-del-arranque)

### Ejercicio 18

**Enunciado (resumen):** el contador y `SERIALIZABLE`.

**Solución de referencia.** Si b ya tomó su foto antes de que a confirme (aquí, con un `SELECT 1` en `b2`), su `UPDATE` espera a a y
después falla:

```text
 b3  ⏳ espera un bloqueo
 a3  COMMIT
   ↳ b3  ✗ 40001 could not serialize access due to concurrent update
```

En `READ COMMITTED`, b habría esperado y seguido con el número siguiente. El contador no gana nada con `SERIALIZABLE` y suma un
error que hay que reintentar. `DMax + 1` en `SERIALIZABLE`, en cambio, se vuelve correcto: las dos cajas leen el máximo e
insertan; el SSI aborta a una (la Fase 15, sección 5.3), y con el bucle de reintento no hay repetidos. Sigue sin resolver la
llamada al organismo, que no se deshace.

**Rúbrica.**
- **Aprobado:** el `40001` del contador.
- **Bien:** por qué en `READ COMMITTED` no falla.
- **Excelente:** `DMax + 1` en `SERIALIZABLE`, y lo que sigue sin resolver.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-18--el-contador-y-serializable)

### Ejercicio 19

**Enunciado (resumen):** la caja que se cae con el número tomado.

**Solución de referencia.** Con `pg_terminate_backend` sobre la conexión de a entre su `UPDATE` y su `COMMIT`:

```text
 a3  1 fila  (247582)
 b2  ⏳ espera un bloqueo
 c1  1 fila  (True)
   ↳ b2  1 fila  (247582)
```

El servidor deshace la transacción de a al cortarse la conexión, y b recibe el 247.582 en el acto: no hay hueco. Si el proceso de
la caja muere pero la conexión no se cierra (la red se cortó, la PC quedó colgada), el servidor no se entera hasta que el
sistema operativo da la conexión por muerta, y b espera todo ese tiempo. `idle_in_transaction_session_timeout` lo acota del lado
del servidor ([Fase 18](../18-bloqueos-deadlocks-y-ddl.md)).

**Rúbrica.**
- **Aprobado:** b recibe el mismo número.
- **Bien:** distingue el proceso muerto de la conexión colgada.
- **Excelente:** propone el límite del servidor.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-19--la-caja-que-se-cae-con-el-número-tomado)

### Ejercicio 20

**Enunciado (resumen):** el reintento ante 10016.

**Solución de referencia.** Con el organismo un número adelante (otro sistema autorizó el 247.582):

```python
except Rejected as e:
    remote = ws.last_authorized(POS, KIND)
    known = ws.query(POS, KIND, remote)          # ¿de quién es? queda registrado para revisarlo
    admin.execute("UPDATE staging.invoice_counter SET last_number = %s WHERE point_of_sale = 1 AND kind = 'B'", (remote,))
```

```text
ej20 · intento 1: 10016 comp. 247582 no coincide con el próximo a autorizar; el organismo va en 247582 (CAE 2083…), el contador se pone al día
ej20 · intento 2: autorizado 247583
```

El reintento tiene tope (tres intentos) y deja registro del número que el organismo tenía y la caja no: es un comprobante que
alguien tiene que explicar.

**Rúbrica.**
- **Aprobado:** se pone al día y reintenta.
- **Bien:** con tope y con registro.
- **Excelente:** no adelanta el contador si el organismo va **atrás** (sería el tercer caso del ejercicio 17).

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-20--el-reintento-ante-10016)

### Ejercicio 21

**Enunciado (resumen):** lotes.

**Solución de referencia.** Una subclase de `FiscalService` con un pedido de varios comprobantes que, como describe el manual,
rechaza el que falla y no procesa los siguientes:

```text
ej21 · lotes de 1: 57.0 ms por comprobante
ej21 · lotes de 10: 6.3 ms por comprobante
ej21 · lote de 10 con el quinto rechazado: 582:autorizado 583:autorizado 584:autorizado 585:autorizado 586:rechazado 587:no procesado …
```

Con el organismo a 50 ms, el lote de diez baja el costo por comprobante de 57 a 6,3 ms: la latencia se paga una vez por pedido.
El precio: si el quinto se rechaza, del sexto al décimo no se procesan, y la caja tiene que retenerlos y volver a pedirlos. Un lote
retiene cinco números en el aire, que es exactamente lo que la sección 5.5 quiere evitar; conviene para comprobantes que se
emiten juntos (la facturación de fin de mes), no para la caja del mostrador.

**Rúbrica.**
- **Aprobado:** los dos costos por comprobante.
- **Bien:** el comportamiento del rechazo parcial.
- **Excelente:** dónde conviene el lote y dónde no.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-21--lotes)

---

## 🔴 Muy difícil (22–26)

### Ejercicio 22

**Enunciado (resumen):** Oracle.

**Solución de referencia.** No se publica resultado (la regla está en [`a09`](../a09-licencias-publicacion-y-riesgo.md)).

**Rúbrica.**
- **Aprobado:** la secuencia `NOCACHE ORDER` y el contador creados, y los dos escenarios corridos en el orden de `races.py`.
- **Bien:** el hueco del `ROLLBACK` explicado con la frase de la documentación ("independent of the transaction committing or
  rolling back"), y la espera del contador con `UPDATE … RETURNING INTO`.
- **Excelente:** explica qué cambia `ORDER` (el orden de pedido, no la ausencia de huecos) y qué cambiaría en un RAC.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-22--oracle)

### Ejercicio 23

**Enunciado (resumen):** ¿qué números necesitan no tener huecos?

**Solución de referencia.**

| Número | Unicidad | Sin huecos | Orden | Quién lo exige |
|---|---|---|---|---|
| comprobante fiscal (por punto de venta y tipo) | sí | sí | correlativo | el organismo (validación 10016) |
| número de protocolo | sí | no | no | el paciente y el médico, que lo leen impreso |
| `invoice_id`, `lab_order_id` y demás claves | sí | no | no | nadie fuera de la base |
| número de afiliado | lo da la obra social | — | — | la obra social |
| número de turno del día | sí, por día | no | deseable | la sala de espera |
| lote de la presentación a una obra social | sí | según el convenio | — | cada obra social (a verificar en cada convenio) |

Uno solo de la lista exige no tener huecos, y lo exige un tercero.

**Rúbrica.**
- **Aprobado:** separa unicidad de huecos.
- **Bien:** cada exigencia con quién la impone.
- **Excelente:** marca lo que no está verificado (los convenios) en lugar de suponerlo.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-23--qué-números-necesitan-no-tener-huecos)

### Ejercicio 24

**Enunciado (resumen):** el diseño de la facturación nueva.

**Solución de referencia.**

```sql
CREATE TABLE alameda.invoice_counter (
    point_of_sale integer NOT NULL,
    kind          char(1) NOT NULL,
    last_number   integer NOT NULL,
    PRIMARY KEY (point_of_sale, kind)
);
CREATE TABLE alameda.invoice (
    invoice_id    integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    point_of_sale integer     NOT NULL,
    kind          char(1)     NOT NULL,
    number        integer,                 -- NULL hasta que el organismo lo autoriza
    cae           char(14),
    created_at    timestamptz NOT NULL DEFAULT now(),
    authorized_at timestamptz,
    CHECK ((number IS NULL) = (cae IS NULL) AND (cae IS NULL) = (authorized_at IS NULL)),
    UNIQUE (point_of_sale, kind, number)
);
```

El flujo: el comprobante se arma sin número; la autorización es una transacción corta (contador, organismo, número y CAE juntos,
sección 5.5); una respuesta que no llega se consulta antes de deshacer (sección 5.6); al abrir la caja, la reconciliación del
ejercicio 17. La medición: la espera por el número no depende del armado (1,2 ms con 10 ms de armado, contra 36 ms con la fila
tomada al armar).

**Rúbrica.**
- **Aprobado:** número `NULL` hasta autorizar, y el contador por punto de venta y tipo.
- **Bien:** el `CHECK` y el `UNIQUE`, y la consulta ante la respuesta perdida.
- **Excelente:** la reconciliación del arranque, y un punto de venta por caja.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-24--el-diseño-de-la-facturación-nueva)

### Ejercicio 25

**Enunciado (resumen):** tres cajas, tres puntos de venta.

**Solución de referencia.** El argumento: con un punto de venta compartido, cada caja espera las transacciones de las otras. Con 10
ms de armado, 36 ms por comprobante (ejercicio 10); con el organismo a 50 ms, unos 120 ms aunque el armado esté afuera (ejercicio
11). Con un punto de venta por caja, 0,21 ms (ejercicio 14): la espera desaparece, y además un rechazo o una respuesta perdida en
una caja no traba a las otras. Lo que cuesta: dar de alta los puntos de venta ante el organismo, y que la numeración del central ya
no sea una sola. Lo que no resuelve: la latencia del organismo dentro de cada caja (cada comprobante sigue esperando su
autorización), y el caso de una caja que emite más rápido de lo que el organismo responde.

**Rúbrica.**
- **Aprobado:** el argumento con un número.
- **Bien:** con los tres números y lo que cuesta.
- **Excelente:** lo que no resuelve.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-25--tres-cajas-tres-puntos-de-venta)

### Ejercicio 26

**Enunciado (resumen):** la caja sin conexión.

**Solución de referencia.** La caja sigue cobrando y **arma** comprobantes sin número (sección 5.5): el paciente se va con el
recibo de lo que pagó y el comprobante queda pendiente. Cuando el organismo vuelve, la reconciliación del arranque (ejercicio 17)
y después las autorizaciones pendientes, en orden de `created_at`. Nada de esto rompe la numeración, porque ningún número se tomó
sin el organismo.

Lo que depende de una regla que el curso no verificó: si el comprobante puede entregarse después al cliente, y en qué plazo; y si
corresponde el régimen de CAEA (el código anticipado por período que el manual describe en `FECAEASolicitar`), que permite emitir
sin consultar en cada comprobante y obliga a informar después.

**Rúbrica.**
- **Aprobado:** armar sin número y autorizar después.
- **Bien:** el orden y la reconciliación.
- **Excelente:** dice qué no está verificado y dónde se verificaría.

[← Volver al ejercicio](../16-el-folio-sin-huecos.md#-ejercicio-26--la-caja-sin-conexión)
