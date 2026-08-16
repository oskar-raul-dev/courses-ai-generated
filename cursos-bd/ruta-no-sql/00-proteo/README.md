# 🍃 Proteo — Modelo Documental

Enseña el **modelo de acceso documental**: cuándo usar bases de datos flexibles (MongoDB, Couchbase, Postgres/JSONB) que almacenan estructuras complejas sin esquema rígido.

**Proyecto:** Catálogo multi-vertical + PIM (Product Information Management)

**Rivales:** MongoDB vs **Couchbase** vs PostgreSQL JSONB

**Veredicto:** Usa documental cuando tus entidades son polimórficas dentro de la misma colección y los joins entre tipos son raros. Evítalo si tienes muchas relaciones N-to-M que requieran cruces frecuentes.
