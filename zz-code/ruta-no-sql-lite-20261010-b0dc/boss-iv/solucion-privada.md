# Boss IV — "La estación del Coca" · solución privada (no se publica, D-05)

Medido el 11/10/2026 en macOS arm64 con los guiones del curso, una familia a la vez (H13). Salidas en
`../salidas/f22-boss-*.txt` y `../salidas/f22-contention-global-split-3.txt`.

## El reparto

| Dato del operador peruano | Dónde | Por qué |
|---|---|---|
| Parámetros de vuelo, 1 Hz | Cassandra, `PRIMARY KEY ((aircraft, day), ts)`; nodos en Perú | escritura sin coordinador, consulta siempre por aeronave y rango; el bucket diario evita la partición sin cota |
| Lo que registra el técnico en el Coca sin señal | PouchDB en la tableta + CouchDB en Perú, forma CRDT de F19, **un solo resolvedor (el servidor)** | sin señal la mitad del día; el conflicto es el caso normal |
| Expediente (aeronave, órdenes, firmas, movimientos) | Postgres por país (Perú para el operador peruano) | casi todo es local: 1 de 5 sentencias del expediente cruzaba en F21, y era la pieza |
| La firma que libera la aeronave al servicio, cuando se hace fuera de Perú | **la única operación distribuida**: CockroachDB con la autoridad en la clave y super región de Perú, o una transacción en el Postgres de Perú desde el cliente de Bogotá | es la frontera real; en `workOrder-10k`, 0 de 10 000 órdenes fueron fuera del país, así que en el negocio actual es la excepción |

## Las tres roturas, provocadas

1. **Partición sin cota** (`unbounded.ts --steps 1,2`): a 1 M y a 2 M de filas, leer la partición entera falla a los
   120 s (`OperationTimedOutError: The host 127.0.0.1:19042 did not reply before timeout 120000 ms`); Cassandra deja un
   volcado de heap (`cassandra-1791779733-pid1.hprof`, borrado). La última hora sigue en 6–28 ms. **La evita:** el bucket
   diario (F18: 86 400 filas, ~1,5 MiB por partición) y paginar.
2. **Sincronización que no converge** (`pingpong.ts --rounds 3`): servidor y tableta resolviendo lo mismo (B), y
   cualquier resolución firmada (D, E): 89 conflictos en cada ronda, 2 hojas, archivo de 1740 a 3480 KiB. **La evita:**
   un solo resolvedor (A: 89 → 0 en una ronda) o resolución sin firma entre tabletas (C).
3. **La fila que pelean tres países** (`contention.ts --kind rmw --steps 16`): 48 trabajadores, 154,8/s, 1,53
   reintentos por confirmada, 35 se rindieron, p50 Colombia 13 ms, Ecuador 12,6 s, Perú 9,6 s, `WriteTooOldError` 4759
   veces. **La evita:** la fila partida por país (`--kind split`): 1296,5/s a 48, 0 reintentos, p50 28–30 ms en los tres.

## Las decisiones que firma otro

- **Residencia contra supervivencia** (E-74): con el expediente peruano solo en Perú, si Perú cae no hay expediente
  peruano; nadie lo lee mal, nadie lo lee. Lo firma Lucía con el operador, no el DBA.
- **Lo único atómico entre países:** la firma de liberación fuera del país de matrícula.
- **La disputa en el Coca:** la forma CRDT deja la posición con dos seriales; la decide el inspector que libera
  (Hernán), y la tableta no libera mientras haya disputa.

## Costo

Cassandra 3 nodos en Perú; CouchDB 1 nodo en Perú; Postgres 2 nodos por país (primario y réplica dentro del país);
NewSQL: si se usa solo para la firma, 9 nodos (3 por región) con ≥ 4 vCPU cada uno (36 vCPU); si la firma va como
transacción al Postgres de Perú, cero nodos más y ~70 ms por firma desde Bogotá (M-67).
