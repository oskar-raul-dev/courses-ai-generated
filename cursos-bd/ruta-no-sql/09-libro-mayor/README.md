# ⚡ Libro Mayor — Modelo NewSQL Distribuido

Enseña el **modelo de acceso NewSQL distribuido ACID**: cuándo usar bases de datos distribuidas que preservan consistencia fuerte (CockroachDB, TiDB, YugabyteDB).

**Proyecto:** Ledger transaccional cross-región (transferencias de dinero entre regiones)

**Rivales:** CockroachDB vs TiDB vs YugabyteDB

**Veredicto:** Usa NewSQL distribuido cuando necesitas ACID sobre múltiples regiones. Evítalo si una única región es suficiente; Postgres es más simple.
