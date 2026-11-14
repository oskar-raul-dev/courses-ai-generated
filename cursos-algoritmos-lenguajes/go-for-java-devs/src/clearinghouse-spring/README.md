# ☕ ClearingHouse, el gemelo Spring Boot

La implementación Java del servicio central de ClearingHouse, la que la Fase 16 mide
contra la tuya en Go. **Se entrega hecha**: ya sabes escribir Spring Boot, y lo que importa
aquí es que la comparación sea legítima. Cópiala a `reference/clearinghouse-spring/` de tu
repositorio (es la ruta que usan los comandos de la Fase 16).

| | |
|---|---|
| Spring Boot | 4.1.1 (Spring Framework 7, Spring Batch 6, Hibernate 7) |
| Java | 21 (LTS) |
| Base de datos | PostgreSQL 16, con el mismo esquema que la versión Go |
| Verificado | 14/11/2026: pasa la suite de contrato y produce los mismos asientos que la versión Go sobre un millón de movimientos |

## 🧭 Las tres reglas que lo mantienen honesto

1. **Mismo esquema, mismos endpoints, mismo cierre.** El SQL vive en
   `src/main/resources/db/migration/` y es **el mismo archivo** para las dos
   implementaciones: Flyway lo aplica aquí (`V1__…`, `V2__…`) y tu versión Go lo aplica
   con goose (la primera línea, `-- +goose Up`, es un comentario para Flyway).
2. **Escrito como lo escribiría un equipo Java competente.** Spring MVC con validación
   por anotaciones y un `@RestControllerAdvice`; Spring Data JPA donde encaja (leer y
   listar movimientos, con paginación por cursor); `JdbcTemplate` con
   `INSERT … ON CONFLICT DO NOTHING` en lote donde JPA estorba (la ingesta idempotente);
   Spring Batch para el cierre, con un step orientado a fragmentos; Flyway y Actuator.
3. **No se enseña a escribirlo.** Se lee, se compara y se mide.

## 🔌 El contrato

```http
GET  /health                    {"status":"ok"}
POST /sync/batches              {"store_id", "movements":[{external_ref, type, amount_minor, currency, occurred_at}]}
                                → 200 {"accepted", "duplicates"} · 400 validation_failed | bad_request · 404 not_found
GET  /movements/{id}            → 200 movimiento · 404 not_found
GET  /movements?store=&limit=&cursor=
                                → 200 {"items", "next_cursor"} · 400 validation_failed
POST /runs                      {"day":"AAAA-MM-DD", "chunk_size"} → 202 el cierre · 409 conflict · 400
GET  /runs/{id}                 → 200 {id, day, status, total_expected, processed, chunks_done} · 404
```

Los errores llevan siempre `{"error", "code"}`, y el JSON va en `snake_case`. La suite
que lo comprueba está en `contract/`, es Go, y se apunta a cualquiera de las dos
implementaciones:

```bash
cd contract
CLEARINGHOUSE_URL=http://localhost:8080 go test -v -count=1 .   # tu versión Go
CLEARINGHOUSE_URL=http://localhost:8081 go test -v -count=1 .   # el gemelo
```

Necesita la base recién migrada y sin cierre del día 2030-01-15, que es el que lanza.

## 🧾 El cierre y su regla contable

`POST /runs` (o `--batch --day=AAAA-MM-DD [--chunk-size=N]`, que cierra y termina) recorre
los movimientos `received` del día **en la zona horaria de cada tienda**, por fragmentos
ordenados por `id`. Cada fragmento es una transacción con sus asientos, el cambio de estado
de los movimientos y el punto de control de la tabla `batches`. La regla contable, la misma
que debe seguir tu versión Go para que los asientos salgan idénticos:

| Tipo | Estado | Asientos |
|---|---|---|
| `sale` | `matched` | `caja:<tienda>` +importe · `ventas` −importe |
| `refund` | `matched` | `caja:<tienda>` −importe · `ventas` +importe |
| `deposit` | `matched` | `caja:<tienda>` +importe · `bancos` −importe |
| `withdrawal` | `matched` | `caja:<tienda>` −importe · `bancos` +importe |
| `void` | `unmatched` | ninguno |

La idempotencia se confía al esquema (`ledger_entries_movement_uniq`), no a la lógica.

> ⚠️ **El lector del cierre es un cursor, y hay una medición detrás.** La primera
> versión usaba `JdbcPagingItemReader`, una consulta por página, que es lo que sale en
> casi todos los ejemplos. Con un millón de movimientos, el cierre tardaba **145 s**, y
> el proceso pasaba el 75% del tiempo esperando la consulta de página (780 ms cada una,
> cuando la misma consulta en `psql` tarda 190 ms). Ni `reWriteBatchedInserts` ni
> `prepareThreshold=0` lo cambiaron, y la causa exacta de la diferencia no se aisló. Con
> `JdbcCursorItemReader`, un solo recorrido ordenado desde el punto de control, el
> cierre baja a **44 s**, el mismo tiempo que la versión Go y con el mismo libro mayor.
> Es la lección de la Fase 16 en pequeño: antes de culpar a la JVM, mide qué está
> esperando el proceso.
Para comprobar que las dos implementaciones producen los mismos asientos:

```sql
SELECT count(*), md5(string_agg(movement_id||'|'||account||'|'||amount_minor||'|'||currency||'|'||batch_id,
                                ',' ORDER BY movement_id, account))
FROM ledger_entries;
```

> 📝 **Lo que Spring da hecho, y se ve en la base.** Spring Batch guarda su registro de
> ejecuciones en sus propias tablas (`batch_job_instance`, `batch_step_execution`…), que
> crea al arrancar. La versión Go no las tiene: el control de ejecuciones es tuyo, y vive
> en `batches`. Es justo la diferencia que la Fase 13 discute.

## ▶️ Compilar y correr

```bash
mvn -B package -DskipTests                       # target/clearinghouse.jar
DATABASE_URL=jdbc:postgresql://localhost:5432/meridian java -jar target/clearinghouse.jar
mvn -B -Pnative native:compile -DskipTests       # binario nativo: GraalVM CE 25 (la 21.0.2 no sirve con Boot 4.1)
docker build -t meridian/clearinghouse-spring:jvm .
```

Variables: `DATABASE_URL`, `DATABASE_USER`, `DATABASE_PASSWORD` (por defecto
`meridian`/`meridian`) y `PORT` (por defecto 8081). Contra una base que ya migró tu versión
Go, añade `SPRING_FLYWAY_BASELINE_ON_MIGRATE=true SPRING_FLYWAY_BASELINE_VERSION=2`.

> ⚠️ **En nativo, el modo `--batch` no funciona**: el procesamiento AOT fija el tipo de
> aplicación al compilar (servlet), y el modo lote lo cambia en tiempo de ejecución. El
> cierre en nativo se lanza con `POST /runs`.

Las cifras del duelo, con su máquina y sus condiciones, están en B-24 de `BENCHMARKS.md`.
