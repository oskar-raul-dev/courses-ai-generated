# 🦆 Cristalería — Modelo Analítico Embebido

Enseña el **modelo de acceso analítico embebido**: cuándo usar motores de análisis compactos (DuckDB, Polars, SQLite) que caben en tu aplicación sin infraestructura separada.

**Proyecto:** Pipeline analítico sin servidor, dashboard WASM

**Rivales:** DuckDB vs pandas/Polars vs SQLite

**Veredicto:** Usa analítico embebido cuando el dataset es <10GB, cambia raramente, y los usuarios son decenas. Evítalo si necesitas actualización en vivo de petabytes.
