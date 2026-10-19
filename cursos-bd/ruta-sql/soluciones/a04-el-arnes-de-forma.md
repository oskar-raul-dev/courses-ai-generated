# ✅ Soluciones — Apéndice a04: El arnés de forma

> **Curso:** Ruta SQL · Solucionario de [a04](../a04-el-arnes-de-forma.md)
> **Ejercicios:** 8 · **Motores:** PostgreSQL 18.6 y MySQL 9.7.2, los de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso), con el perfil M
> **Fecha de verificación ejecutada:** 18/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Los tiempos que aparecen en las salidas son de esta máquina ese día: contexto, no argumento.

---

## 🟢 Fácil (1–2)

### Ejercicio 1

```bash
uv run lab measure -c "SELECT count(*) FROM legacy.\"Pacientes\" WHERE \"Nombre\" LIKE '%PASAP%'"
uv run lab measure --engine mysql -c "SELECT count(*) FROM legacy.Pacientes WHERE Nombre LIKE '%PASAP%'"
```

```text
📐 lab measure · postgres · perfil m · caja 3e59292e9918 · pgvector/pgvector:0.8.7-pg18@sha256:2358fcba361e…
filas devueltas: 1 (estimadas: 1)
bloques: 4160 (en caché 4160, leídos 0)
filas examinadas en las hojas del plan: 242427
plan:
  …
        Seq Scan on Pacientes · estimadas 10 · reales 0 · descartadas 242427 · bloques 4160

📐 lab measure · mysql · perfil m · caja 3e59292e9918 · mysql:9.7.2@sha256:e2bde46db656…
contadores Handler_read: first 1 · key 29 · next 31 · rnd_next 242428
filas examinadas (suma de los contadores): 242489
```

Los dos miran **todas** las filas para contestar cero: 4.160 bloques y 242.427 filas en Postgres, 242.489
lecturas en MySQL. Un `LIKE` con `%` adelante no puede usar un índice B-tree, y "no está" solo se sabe
después de mirar todo. Que el resultado sea cero no ahorra nada; lo que ahorraría es un índice de
trigramas ([F05](../05-una-persona-no-es-su-documento.md), [F21](../21-hasta-donde-llega-el-motor.md)). Las
59 lecturas de más en MySQL (`key 29 · next 31`) son de índices que el plan no muestra, del orden de las
que el apéndice describe para el `LIKE '%DNI%'`: no cambian la magnitud.

### Ejercicio 2

```text
        Seq Scan on Pacientes · estimadas 7949 · reales 18936 · descartadas 223491 · bloques 4160
```

El `Seq Scan`: estimó **7.949** filas y salieron **18.936**, 2,4 veces más; el planificador se quedó corto.
Para un `LIKE '%DNI%'` no tiene un histograma que le sirva y usa una selectividad por defecto. No cambia el
plan porque **no hay alternativa**: sin un índice que sirva para ese patrón, el único camino es recorrer
la tabla, y estimar 8.000 o 19.000 da el mismo recorrido. Donde una estimación así sí importa es en lo que
viene arriba, como un *join* que elige *nested loop* porque cree que llegan pocas filas
([F12](../12-estadisticas-y-cardinalidad.md)).

---

## 🟡 Intermedio (3–5)

### Ejercicio 3

| | Postgres | MySQL |
|---|---|---|
| tabla | 33 MB · 4.160 bloques de 8 KB | 29,6 MB · 1.892 páginas de 16 KB |
| índices | 5.344 kB | 0 |
| filas | 242.427 (`pgstattuple`, exacto) | 240.606 (`table_rows`, estimado) |

Las dos guardan la misma caja en un tamaño parecido (en InnoDB la fila es un poco más compacta). MySQL
**cree** tener 240.606 filas: `table_rows` sale de una muestra de páginas, y cambia con cada `ANALYZE
TABLE`; el número exacto es el de `count(*)`. `index_length` da cero porque en InnoDB la clave primaria
**es** la tabla (`data_length` es el índice *clustered*) y `Pacientes` no tiene índices secundarios en
MySQL; en Postgres, los 5.344 kB son `Pacientes_pkey`, el índice de la clave primaria, que vive aparte de
la tabla.

### Ejercicio 4

```text
-- Postgres
 calls | rows | bloques | consulta
     2 |    2 |    8320 | SELECT count(*) FROM legacy."Pacientes" WHERE "Nombre" LIKE $1
-- MySQL
| calls | examinadas | enviadas | consulta                                                             |
|     2 |     484854 |        2 | SELECT COUNT ( * ) FROM `legacy` . `Pacientes` WHERE `Nombre` LIKE ? |
```

**Una fila en cada vista**, con el literal reemplazado (`$1`, `?`): las dos consultas solo cambian el
valor, y el motor las cuenta como la misma. `calls` es `count_star`; `rows` es `sum_rows_sent` (lo que
llegó al cliente, 1 por llamada); y lo que se corresponde con el trabajo son los **8.320 bloques**
(4.160 × 2) de Postgres y las **484.854 filas examinadas** (242.427 × 2) de MySQL, cada uno en su unidad.
Para encontrar la consulta que pesa, se ordena por esa columna, no por `calls`.

### Ejercicio 5

```text
   WAL: records=200 bytes=15995
   WAL: records=174 fpi=1 bytes=22754
   WAL: records=102 bytes=10161
```

La segunda corrida tuvo `fpi=1`: escribió una página entera (8 KB) la primera vez que tocó esa página
después de un *checkpoint*, y por eso escribió más bytes con menos registros. La primera y la tercera no
tuvieron `fpi`, y aun así difieren: la primera escribió dos registros por fila; la tercera, uno y poco, en
páginas a las que la poda de las corridas anteriores (los `records=1` y `records=2` que aparecen en el
`Seq Scan`) les dejó lugar para que la versión nueva quede en la misma página (HOT,
[F11](../11-indices-y-lo-que-cuestan.md)). **"Bytes de WAL por fila" depende de en qué estado está la
tabla**: de 160 a 100 bytes en tres corridas, y 228 con la página entera. Lo honesto es dar el de régimen
(unos 100 B, la tercera), decir cuántas corridas hubo y cuáles tuvieron `fpi`, que es lo que hace la
[Fase 19](../19-json-en-los-motores.md).

---

## 🟠 Difícil (6–7)

### Ejercicio 6

```text
🏁 lab race · postgres · permutación a1 a2 b1 b2 a3 b3 a4 b4 · repeatable read
 a3  UPDATE 1
 b3  ⏳ espera un bloqueo
 a4  COMMIT
   ↳ b3  ✗ 40001 could not serialize access due to concurrent update
comprobación: 1 fila  (18.00)

🏁 lab race · mysql · permutación a1 a2 a3 b1 b2 b3 a4 b4 a5 b5 · repeatable read
 a4  UPDATE 1
 b4  ⏳ espera un bloqueo
 a5  COMMIT
   ↳ b4  UPDATE 1
comprobación: 1 fila  (23.00)
```

En Postgres queda **18,00**: la segunda caja falla, la aplicación reintenta y, al releer, cobra sobre lo
confirmado. En MySQL queda **23,00**: la segunda caja escribe el saldo que calculó sobre la foto vieja, y
el cobro de 10 de la primera se pierde. La línea que lo explica es la misma en los dos, la de `↳`: el
`UPDATE` que esperaba termina con un `40001` en Postgres y con `UPDATE 1` en MySQL. El nivel se llama
igual y hace otra cosa ([`a07`](../a07-diccionario-y-glosario.md#-los-niveles-de-aislamiento-por-comportamiento)).

### Ejercicio 7

```sql
CREATE TABLE lab.a04_muertas AS SELECT * FROM legacy."Pacientes";
ALTER TABLE lab.a04_muertas SET (autovacuum_enabled = off);
UPDATE lab.a04_muertas SET "Telefono" = "Telefono" WHERE "IdPaciente" % 2 = 0;
SELECT * FROM pgstattuple('lab.a04_muertas');
VACUUM lab.a04_muertas;
DROP TABLE lab.a04_muertas;
```

| Momento | Bloques | Filas vivas | Muertas | Libre |
|---|---|---|---|---|
| después del `CREATE` | 4.160 | 242.427 | 0 | — |
| después del `UPDATE` (121.213 filas) | 6.198 | 242.427 | 121.213 (31,8 %) | 0,6 % |
| después del `VACUUM` | 6.198 | 242.427 | 0 | 32,4 % |

El `UPDATE` que no cambia nada escribe igual una versión nueva de cada fila, y como las páginas estaban
llenas, las nuevas fueron al final: la tabla creció un 49 %. El `VACUUM` marca como libre el espacio de
las 121.213 muertas (`libre` pasa a 32,4 %) pero **no achica el archivo**: el espacio queda para las
próximas escrituras de esta tabla. Para devolverlo al sistema hace falta `VACUUM FULL` o `pg_repack`, que
reescriben la tabla ([F17](../17-mvcc-y-su-factura.md)). `pg_stat_user_tables.n_dead_tup` dio las mismas
121.213 antes del `VACUUM`.

---

## 🔴 Muy difícil (8)

### Ejercicio 8

**Rúbrica (sobre 4 puntos):**

- **1 punto: las unidades.** 4.160 son **bloques de 8 KB**; 242.489 son **filas examinadas**. Comparar uno
  con otro es comparar kilos con metros: la frase no dice nada.
- **1 punto: la misma unidad.** En filas, los dos examinan la tabla entera: 242.427 en Postgres (la línea
  `filas examinadas` de su salida) contra 242.489 en MySQL. En bytes leídos, 33 MB contra 29,6 MB (el
  ejercicio 3). Ninguno lee sesenta veces más: hacen el mismo trabajo, un recorrido completo.
- **1 punto: los cinco datos** de la medición que sostendría una comparación: qué se midió, en forma
  estructural (filas examinadas contra devueltas, en los dos); sobre qué perfil (M, con el hash de la
  caja); con qué motor y digest (las dos primeras líneas de `lab measure`); en qué máquina, solo si se
  cita el tiempo; y el comando exacto para reproducirlo.
- **1 punto: el veredicto bien dicho.** *"Para esta consulta, sin índice de trigramas, los dos recorren
  las 242.427 filas; la diferencia de tamaño de la tabla (33 contra 29,6 MB) es la única que se mide, y
  no cambia la decisión."*
