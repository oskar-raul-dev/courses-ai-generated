# 📦 Rastro — Modelo Columnar Ancho

Enseña el **modelo de acceso de columnar ancha** a fondo: cuándo un dato es un río que se escribe una vez y se lee siempre por la misma puerta (Cassandra, ScyllaDB) y cuándo es un libro que nunca debió salir de PostgreSQL.

**Proyecto:** El rastreo de paquetes y la plataforma de marca blanca de un courier de casilleros virtuales de Miami, con dos centros de datos

**Rivales:** Cassandra vs ScyllaDB vs PostgreSQL particionado (Bigtable y Keyspaces, solo desde documentación)

**Veredicto:** Usa columnar ancha para eventos inmutables con consultas conocidas, caudal alto y disponibilidad entre centros de datos. Evítala para saldos, consecutivos, tarifas que cambian y preguntas que nadie previó.

> 📝 Curso en preparación; este README se reescribe al final (sus lineamientos están en `prompts/`).
