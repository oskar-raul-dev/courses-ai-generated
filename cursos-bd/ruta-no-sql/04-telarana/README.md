# 🕸️ Telaraña — Modelo de Grafos

Enseña el **modelo de acceso de grafos**: cuándo usar bases de datos de grafos (Neo4j, Amazon Neptune, Memgraph) para relaciones profundas y recorridos complejos.

**Proyecto:** Detección de fraude en anillos (transacciones circulares)

**Rivales:** Neo4j vs Amazon Neptune vs Memgraph

**Veredicto:** Usa grafos cuando necesitas recorrer relaciones a 3+ saltos y los joins SQL explotan. Evítalo para relaciones de 1–2 saltos; SQL gana.
