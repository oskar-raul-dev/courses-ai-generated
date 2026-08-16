# ⏱️ El Vigía — Modelo de Series Temporales

Enseña el **modelo de acceso de series temporales**: cuándo usar bases de datos especializadas (InfluxDB, TimescaleDB, Mongo Time Series) para observabilidad y monitoreo.

**Proyecto:** Monitoreo de infraestructura (métricas de CPU, memoria, latencia)

**Rivales:** InfluxDB vs TimescaleDB vs MongoDB Time Series

**Veredicto:** Usa series temporales cuando tus datos tienen timestamp y se escriben en orden. Evítalo para datos que necesitan re-escribirse o borrarse frecuentemente.
