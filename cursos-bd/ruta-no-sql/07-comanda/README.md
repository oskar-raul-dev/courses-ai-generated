# 🍲 Comanda — Modelo Offline-First

Enseña el **modelo de acceso offline-first** a fondo: qué se escribe en el dispositivo, cómo se juntan las escrituras de varios dispositivos que no se vieron, y qué no se puede juntar nunca (CouchDB y PouchDB, CRDT con Automerge, Firestore, ElectricSQL).

**Proyecto:** Las tablets de meseros, las pantallas de cocina y las cajas de una cadena de restaurantes que sigue vendiendo sin internet

**Rivales:** CouchDB+PouchDB vs Automerge vs Firestore (emulador) vs ElectricSQL, con PostgreSQL como base de verdad

**Veredicto:** Usa offline-first cuando varios dispositivos escriben sin conexión y el conflicto es el caso normal. Evítalo para el pago, la factura y lo que siempre tiene cable.

> 📝 Curso en preparación; este README se reescribe al final (sus lineamientos están en `prompts/`).
