# ⏱️ El Vigía — Modelo de Series Temporales

Enseña el **modelo de acceso de series temporales** a fondo: el tiempo como eje físico, la cardinalidad como presupuesto, y agregados que no mienten (InfluxDB 3, TimescaleDB, Prometheus, MongoDB).

**Proyecto:** La observabilidad de un servicio de facturación electrónica de cinco países, con un nivel de servicio por cliente

**Rivales:** InfluxDB 3 Core vs TimescaleDB vs Prometheus vs colecciones de series de MongoDB, contra la tabla genérica de PostgreSQL

**Veredicto:** Usa un motor de series cuando el dato llega ordenado, no se corrige y se lee por ventana. Evítalo para la tabla que solo tiene una fecha.

> 📝 Curso en preparación; este README se reescribe al final (sus lineamientos están en `prompts/`).
