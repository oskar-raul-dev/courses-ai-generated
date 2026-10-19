# 💀 Boss III · "Una tarde de julio" · la solución de referencia (D42: no se publica)

Punto de partida publicado: `src/18-bloqueos-deadlocks-y-ddl/boss/` (`01_july.sql`, `tills.py` roto y `afternoon.py`, el
arnés que no se edita). Esta solución: `tills.py` y `02_fix.sql`; `correr.sh` monta el `tills.py` de aquí sobre el de `src/` y
corre la tarde. Verificado el 14/10/2026.

## Los cinco síntomas, su comando y su arreglo

| Síntoma | Comando que lo diagnostica | Arreglo mínimo | Fase |
|---|---|---|---|
| rechazos 10016 (73 en la tarde rota) | `SELECT count(*) FROM fiscal.authorized` contra los comprobantes; los rechazos que cuenta el arnés; dos cajas con el mismo número en `lab race` (`races.py ultimo_numero`) | `UPDATE … RETURNING` en una transacción corta con la llamada al organismo; `FECompConsultar` ante una respuesta perdida | F16 |
| muestras tomadas dos veces (53) | `SELECT specimen_id FROM staging.july_specimen_take GROUP BY 1 HAVING count(*) > 1` | `UPDATE … WHERE specimen_id = (… FOR UPDATE SKIP LOCKED) RETURNING`, con el estado (`taken_by`) en la fila bloqueada; `UNIQUE (specimen_id)` en la toma como red | F15 |
| técnicos esperando 10 s | `pg_stat_activity` con `pg_blocking_pids(pid)`; `pg_locks` muestra el `RowExclusiveLock`/tuple lock del formulario | el formulario no bloquea mientras el usuario edita: escritura optimista con `version` | F18 |
| una transacción de 10 s (el formulario) | `pg_stat_activity` ordenada por `xact_start`, o por `age(backend_xmin)` | lo mismo: el formulario ya no abre transacción mientras el usuario está afuera | F17 |
| la corrección del formulario perdida sin aviso | `SELECT * FROM staging.july_hemogram WHERE loaded_by = 'formulario'` vacío aunque el formulario dijo "guardado" | `UPDATE … WHERE specimen_id = %s AND version = %s`; `rowcount = 0` es "conflicto" | F15, F18 |

## La medición

```text
                    rechazos  dobles  espera más larga  transacción más larga  formulario
tarde rota            73        53       10,00 s              10,0 s           guardado, perdido
solución (2 corridas)  0         0       0,17 s               0,2 s            conflicto, avisado
```

Salidas completas en `salidas/f18/boss-partida.txt` (dos corridas rotas: 102 y 71 rechazos, 50 dobles) y
`salidas/f18/boss-final.txt`.

## Decisiones y trampas

- **El criterio 4 se cambió al construir el boss.** Era "el contador en 2 páginas o menos" (la huella de F17). No discrimina: la
  solución deja el contador en 2 o 3 páginas igual que la tarde rota (3 o 4), porque la poda de página va detrás de las
  transacciones cortas que se superponen. Se reemplazó por "ninguna transacción abierta más de 2 s", que es la causa que F17 mide,
  muestreada en `pg_stat_activity` cada 100 ms.
- **`idle_in_transaction_session_timeout` por rol** era parte del primer `02_fix.sql`; se sacó porque persiste en el laboratorio
  y corta las exportaciones de `mvcc.py` (F17). Queda como recomendación comentada.
- **El formulario con "conflicto"**: en la solución el técnico carga el hemograma que el formulario tenía en pantalla mientras el
  usuario almorzaba, y el formulario avisa. Es el resultado correcto: la alternativa es pisar la carga del técnico.
- `afternoon.py` cuenta como error cualquier excepción que llegue a una caja o a un técnico: un arreglo con `SERIALIZABLE` sin
  bucle de reintento falla el criterio 5 aunque los otros pasen.
