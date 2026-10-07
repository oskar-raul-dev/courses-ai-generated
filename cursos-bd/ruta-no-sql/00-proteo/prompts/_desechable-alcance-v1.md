# 🎯 Proyecto Proteo — Alcance

> Deriva de `00-proteo-semilla.md` y de las instrucciones de la Ruta NoSQL.
> Si algo entra en conflicto, gana la semilla; este documento no redefine
> stack, fases ni veredictos: los acota en una sola dirección — qué entra en
> el curso y qué explícitamente no.

---

## 1. Qué construye el curso

Proteo construye, de punta a punta, el backend de un **marketplace
multi-vertical con PIM propio**: catálogo con cuatro verticales de forma
deliberadamente heterogénea, reseñas que crecen sin techo, inventario
multi-almacén con concurrencia real, pedidos que congelan el producto al
comprar, búsqueda facetada, un carrito efímero y una capa de sincronización
en tiempo real entre el motor principal y sus derivados. No es una demo de
CRUD sobre Mongo: es un sistema con las fricciones reales que un PIM de
producción enfrenta — evolución de esquema sin coordinación central,
inmutabilidad de lo ya vendido, y el punto exacto donde el motor documental
dejó de bastar y hubo que sumar otro.

El curso construye, **en paralelo desde la Fase 0**, la misma solución de
catálogo en tres motores (MongoDB, Couchbase, PostgreSQL con EAV y con
JSONB), y arma el arnés (`scripts/vs.ts`) que mide cada duelo. El producto
final del curso no es "aprendiste MongoDB": es un lector que puede **decidir
y defender con números** cuándo un dominio vota documento, cuándo vota
relacional, y cuándo la respuesta correcta es "los dos, cada uno en lo suyo".

Concretamente, al cerrar las trece fases el lector tiene:

- Un catálogo de cuatro verticales modelado con `$jsonSchema` polimórfico,
  con costo de "vertical nueva" medido en las cuatro formas.
- Reseñas con bucket pattern y computed pattern, con el techo de 16 MB
  respetado por diseño, no por suerte.
- Inventario con `findOneAndUpdate` con precondición, sin sobreventa bajo
  concurrencia, medido contra la tabla puente relacional.
- Pedidos inmutables que congelan el producto comprado, comparados contra
  SCD Type 2.
- Búsqueda facetada con `$facet`, con el salto justificado a Meilisearch
  cuando el motor principal deja de alcanzar.
- Un carrito en Redis con TTL, con el diseño híbrido documentado (qué vive
  en Redis, qué persiste en Mongo al confirmar).
- Change Streams manteniendo los derivados (búsqueda, caché) sincronizados
  sin polling ni outbox manual.
- El villano (EAV) construido de verdad, medido de punta a punta, y
  convertido a documento con números antes/después en `BENCHMARKS.md`.
- Un veredicto final políglota: **documento gana el catálogo, relacional
  gana el libro mayor**, con `INSTINTOS.md` y `BENCHMARKS.md` como evidencia
  acumulada, no como opinión.

---

## 2. Qué queda fuera por diseño

Proteo tensiona el modelo documental, no lo agota. Lo siguiente queda
**explícitamente fuera** del alcance base (puede aparecer marcado 🔥 como
ampliación opcional, nunca en el camino principal):

- **Sharding y clustering de Mongo en producción.** El curso corre sobre un
  `replica set` de un nodo (necesario solo para habilitar Change Streams);
  particionar horizontalmente un catálogo es tema de un curso de escalado
  distribuido, no del modelo de acceso documental en sí.
- **Autenticación, autorización y multi-tenancy reales.** El backend expone
  la API del catálogo; no construye un sistema de roles, tenants ni
  facturación por uso. Donde haga falta un usuario, se simula sin ceremonia.
- **Frontend de ningún tipo.** El curso es 100% backend + arnés de
  benchmark; no hay UI de marketplace que consumir.
- **Motor de recomendación con machine learning.** La Fase 8 resuelve
  "quienes compraron X también compraron Y" con agregación sobre órdenes,
  no con un modelo entrenado. Es, a propósito, el puente honesto hacia un
  futuro curso de grafo — no una implementación de recsys.
- **Pagos y contabilidad como sistema completo.** La Fase 12 construye un
  **mini-servicio real mínimo** (un ledger de dos tablas con una
  transacción ACID) suficiente para que el veredicto relacional tenga
  números — no una pasarela de pagos ni un sistema contable completo.
- **Migraciones en caliente entre motores sin downtime.** La conversión de
  EAV a documento en la Fase 11 se mide con el sistema detenido; las
  técnicas de migración cero-downtime (doble escritura, backfill
  incremental) son mención, no implementación.
- **Optimización de infraestructura (memoria de Couchbase, tuning fino de
  índices Postgres) más allá de lo necesario para que el "vs" sea justo.**
  El arnés compara configuraciones razonables por defecto, no la
  configuración óptima teórica de cada motor.
- **CouchDB.** Ver la nota de precaución en `00-proteo-semilla.md`: es un
  curso distinto de la ruta (offline-first). Ningún archivo de Proteo lo
  menciona salvo para aclarar que no es Couchbase.

---

## 3. Contra qué mercado real se valida

Un catálogo multi-vertical con PIM no es un ejercicio de laboratorio: es un
producto que se vende hoy. La validación de "esto es productizable" se
apoya en tres frentes concretos, cada uno con un análogo comercial real que
resuelve exactamente el mismo problema de forma de datos:

| Frente del curso | Análogo de mercado |
|---|---|
| Catálogo heterogéneo con PIM | Plataformas de e-commerce (Shopify, Salesforce Commerce Cloud) y sistemas PIM dedicados (Akeneo, PIMcore) que gobiernan atributos por categoría sin migración coordinada. |
| Reseñas a escala con bucket pattern | Cualquier marketplace grande (Amazon, MercadoLibre) donde el volumen de reseñas por producto exige exactamente esta decisión de modelado. |
| Búsqueda facetada como motor separado | Uso extendido en la industria de un motor de búsqueda dedicado (Algolia, Elasticsearch, Meilisearch) delante de la fuente de verdad transaccional. |
| Inmutabilidad del pedido | Requisito legal/contable estándar en cualquier plataforma de venta: lo que se facturó no puede reescribirse retroactivamente. |
| Persistencia políglota | Cualquier sistema de e-commerce de escala real, que nunca vive en un solo motor: transaccional, caché, búsqueda y analítica suelen estar en productos distintos. |

El veredicto final del curso no es "Mongo para todo": es la misma
conclusión a la que llega el mercado real — **documento para el catálogo,
relacional para el libro mayor, un motor de búsqueda dedicado cuando la
relevancia importa** — sostenida con las mediciones propias del curso, no
citada de un blog de vendor.

---

## 4. Árbol de decisión: cuándo NO usar documental

El curso enseña a decir que no. El árbol siguiente resume, en el vocabulario
del marco de 5 preguntas de la semilla, cuándo un dominio **no** vota
documento — y es, en rigor, el resumen ejecutable de la Fase 12.

1. **¿Las invariantes cruzan agregados con frecuencia?**
   Si actualizar una entidad exige garantizar consistencia inmediata con
   otras varias (débito y crédito que deben cuadrar siempre, inventario
   compartido entre múltiples líneas de un mismo pedido con reglas
   atómicas) → **no vota documento**. Ejemplo del propio curso: el libro
   mayor de la Fase 12.
2. **¿El patrón dominante es "combinar muchas entidades pequeñas", no "traer
   una entidad completa"?**
   Si la consulta típica arma una vista uniendo varias tablas normalizadas
   de tamaño similar (no un agregado con partes subordinadas) → el
   relacional sigue siendo la forma natural; forzar documento produce
   `$lookup` en cadena, que es el `JOIN` de siempre con peor tooling.
3. **¿La relación en sí es el dato, con profundidad variable y consultas de
   tipo "quién conoce a quién a N saltos"?**
   Si sí → ni documento ni relacional puro es la herramienta; el dominio
   vota grafo (ver Fase 8: co-ocurrencia a un salto es agregación, pero a
   varios saltos deja de serlo).
4. **¿La escritura exige ACID multi-fila con auditoría estricta y sin
   tolerancia a inconsistencia temporal?**
   Contabilidad, pagos, cualquier sistema donde "eventualmente consistente"
   no es una opción aceptable → relacional (o NewSQL si además hace falta
   escalado horizontal con esas mismas garantías).
5. **¿La forma del dato es estable, conocida de antemano, y no va a crecer
   nuevas variantes sin coordinación del equipo?**
   Si la forma no cambia, la ventaja principal del documental —evolución de
   esquema sin migración— no se cobra. Seguís pudiendo usarlo, pero no
   tenés la razón de fondo para preferirlo sobre una tabla bien
   normalizada.

Si la respuesta a **cualquiera** de 1, 2 o 4 es "sí" para el núcleo de
escritura del dominio, ese núcleo vota relacional (o grafo, si aplica 3),
aunque el resto del sistema siga viviendo cómodo en documentos. Esta es,
exactamente, la forma del veredicto que Proteo entrega en su Fase 12: el
catálogo vota documento, la contabilidad vota relacional, y ambos conviven
en el mismo sistema sin que eso sea una contradicción.

---

## 5. Fronteras con el resto de la ruta

- **Couchbase ≠ CouchDB.** Couchbase (rival de este curso) es memoria-first
  con N1QL/SQL++; CouchDB (offline-first, Erlang) pertenece a otro curso de
  la ruta (Bitácora de Campo). No se mezclan en ningún artefacto de Proteo.
- **La Fase 8 no es el curso de grafo.** Resuelve co-ocurrencia con
  agregación y deja explícito el puente hacia cuándo el mismo problema, a
  más saltos, sí necesitaría un motor de grafo — sin implementarlo.
- **La Fase 9 no es el curso de clave-valor.** Usa Redis en su hábitat
  natural (carrito con TTL) como caso de uso acotado, no como enseñanza
  exhaustiva del modelo clave-valor, que tiene su propio curso en la ruta.
- **La Fase 12 no es el curso de NewSQL.** El ledger mínimo demuestra por
  qué la contabilidad vota relacional; no explora escalado horizontal con
  ACID, que es el territorio de Libro Mayor (curso NewSQL) más adelante en
  la ruta.
