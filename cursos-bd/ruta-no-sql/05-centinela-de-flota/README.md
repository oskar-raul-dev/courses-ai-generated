# 🏛️ Centinela de Flota — Modelo Columnar Ancho

Enseña el **modelo de acceso columnar ancho**: cuándo usar bases de datos de series de tiempo y columnar (Cassandra, ScyllaDB, Bigtable) para telemetría masiva con agregaciones horizontales.

**Proyecto:** Telemetría IoT con roll-ups (sensores → metricas horarias → diarias)

**Rivales:** Cassandra vs ScyllaDB vs Bigtable

**Veredicto:** Usa columnar cuando tienes millones de escrituras/segundo de datos que nunca se actualizan. Evítalo para datos que cambian frecuentemente.
