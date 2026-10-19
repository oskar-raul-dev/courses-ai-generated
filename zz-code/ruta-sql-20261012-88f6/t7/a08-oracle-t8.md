### E-51 · La foto que el undo ya no tiene
<!-- motor: oracle -->

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3 · **Apareció en:** la corrida privada de la apuesta de la
[Fase 17](17-mvcc-y-su-factura.md), 14/10/2026

```text
ORA-01555: snapshot too old: rollback segment number 13 with name
"_SYSSMU13_4038408623$" too small
Help: https://docs.oracle.com/error-help/db/ora-01555/
```

- **Qué lo provocó:** una transacción `READ ONLY` que releyó filas que otra sesión había cambiado muchas veces mientras tanto; los
  registros de *undo* que necesitaba para reconstruir su foto ya se habían reutilizado. Las condiciones exactas y el resultado de la
  apuesta no se publican ([`a09`](a09-licencias-publicacion-y-riesgo.md)).
- **Cómo se confirma:** `V$UNDOSTAT` muestra las consultas más largas y los errores de "snapshot too old" por intervalo.
- **Cómo se sale:** subir `UNDO_RETENTION` (y el tamaño del *undo* para que la retención se pueda cumplir), acortar la lectura, o no
  reescribir las filas que la lectura recorre mientras dura.

### E-52 · `SERIALIZABLE` en Oracle, al escribir una fila que otra cambió
<!-- motor: oracle -->

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3 · **Apareció en:** la corrida privada de la apuesta de la
[Fase 15](15-aislamiento-comparado.md), 14/10/2026

```text
ORA-08177: can't serialize access for this transaction
Help: https://docs.oracle.com/error-help/db/ora-08177/
```

- **Qué lo provocó:** una transacción `SERIALIZABLE` que quiso actualizar una fila que otra sesión había cambiado y confirmado
  después de que la primera empezó: la actualización perdida de la Fase 15, en Oracle.
- **Cómo se confirma:** la documentación lo describe como el error de una transacción serializable que encuentra datos cambiados
  después de su comienzo.
- **Cómo se sale:** reintentar la transacción entera, como el `40001` de Postgres (E-42).

### E-53 · El *deadlock* en Oracle
<!-- motor: oracle -->

**Motor y versión:** Oracle AI Database 26ai Free 23.26.3 · **Apareció en:** la corrida privada de la apuesta de la
[Fase 18](18-bloqueos-deadlocks-y-ddl.md), 14/10/2026

```text
ORA-00060: deadlock detected while waiting for resource
Help: https://docs.oracle.com/error-help/db/ora-00060/
```

- **Qué lo provocó:** dos sesiones que actualizan las mismas dos filas en orden contrario.
- **Cómo se confirma:** el archivo de traza que Oracle escribe con cada *deadlock* (lo indica el registro de alertas) tiene el grafo
  de esperas.
- **Cómo se sale:** según la documentación, Oracle deshace la sentencia que detectó el *deadlock*, no la transacción: la sesión tiene
  que decidir si deshace el resto. Para que no vuelva, el mismo orden de filas en todas las transacciones (E-45).
