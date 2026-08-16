# 🔑 Portalón — Modelo Clave-Valor

Enseña el **modelo de acceso clave-valor**: cuándo usar cachés y stores ultra-rápidos (Redis, Dragonfly, Valkey) para lecturas/escrituras de sub-milisegundo en datos volátiles.

**Proyecto:** Gateway: rate limiting, sesiones, colas, leaderboard

**Rivales:** Redis vs Dragonfly vs Valkey

**Veredicto:** Usa clave-valor cuando necesitas latencias <5ms y tu dato cabe en memoria. Evítalo como base primaria; es un efecto, no una causa.
