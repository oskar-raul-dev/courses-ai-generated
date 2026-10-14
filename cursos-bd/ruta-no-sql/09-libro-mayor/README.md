# 💱 Libro Mayor — Modelo NewSQL Distribuido

Enseña el **modelo de acceso NewSQL distribuido** a fondo: SQL y ACID entre regiones contra el falso dilema entre corrección y escala (CockroachDB, YugabyteDB, TiDB).

**Proyecto:** El libro de partida doble de una fintech de cuentas multimoneda en tres regiones con residencia de datos

**Rivales:** CockroachDB vs YugabyteDB vs TiDB, contra PostgreSQL con réplica asíncrona y contra tres PostgreSQL unidos por sagas

**Veredicto:** Usa NewSQL cuando una invariante de dinero cruza regiones o la ley decide dónde vive cada fila. Si una región cabe en un nodo, PostgreSQL gana.

> 📝 Curso en preparación; este README se reescribe al final (sus lineamientos están en `prompts/`).
