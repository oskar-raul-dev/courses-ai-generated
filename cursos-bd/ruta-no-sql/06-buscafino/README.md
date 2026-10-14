# 🔍 Buscafino — Modelo de Búsqueda

Enseña el **modelo de acceso de búsqueda** a fondo: relevancia, analizadores, facetas y tolerancia a errores sobre Lucene (OpenSearch), con el índice siempre derivado y reconstruible desde PostgreSQL.

**Proyecto:** El buscador de un portal de empleo multipaís con ofertas locales y trabajo remoto, en español, portugués e inglés

**Rivales:** OpenSearch vs Elasticsearch vs Meilisearch vs Typesense vs PostgreSQL (full-text y BM25 con ParadeDB)

**Veredicto:** Usa un motor de búsqueda cuando la relevancia multiseñal, los idiomas, las facetas a escala y el error de tecleo importan. Nunca como fuente de verdad: si no puedes tirarlo y reconstruirlo, no es un índice.

> 📝 Curso en preparación; este README se reescribe al final (sus lineamientos están en `prompts/`).
