# 📖 Diccionario de términos
## Ruta NoSQL Lite

> **Qué es este documento:** qué palabra se usa para cada concepto en la prosa del curso, qué se
> queda en inglés y cómo se nombra el código del dominio. Es la herramienta de quien escribe; para
> el lector, el diccionario se publica en [`a08`](../a08-diccionario-y-glosario.md), que crece con
> cada familia.
> **Origen:** agregado el 06/10/2026, en la revisión contra los lineamientos de producción del
> repositorio. El curso ya tenía estas reglas repartidas en la guía §3 y §5, en `a08` y en la
> historia §6; aquí quedan juntas. **No las cambia**: si algo de aquí contradice a la guía, manda la
> guía y se corrige este documento.
> **Precedencia:** por debajo del [alcance](alcance-del-proyecto.md) y de la
> [guía](guia-de-estilo-y-convenciones.md); al lado del [contrato de nombres](contrato-de-nombres.md),
> que fija los identificadores del laboratorio.
> **Vigencia:** 2026-10-06.

---

## 1. 🧭 Cómo se decide

Tres reglas, de la guía §3, en este orden:

1. **El término del oficio se queda en inglés cuando es el nombre real de la cosa**: el que el lector
   va a leer en la documentación y en los mensajes de error. Traducirlo a la fuerza confunde.
2. **Lo que ya tiene traducción asentada se escribe en español** y se alterna con naturalidad.
3. **No se inventa vocabulario.** Si una palabra no está aquí ni en la guía, se busca cómo la escribe
   la documentación oficial del motor y se agrega aquí antes de usarla.

En la prosa, el término en inglés va en cursiva la primera vez de cada documento (*partition key*);
los identificadores, comandos y nombres de campo, siempre entre comillas invertidas (`workOrder`).

---

## 2. ✍️ Lo que se queda en inglés y lo que se traduce

**Se quedan en inglés:** *shard* y *sharding*, *partition key*, *clustering key*, *replica set*,
*write amplification*, *fan-out*, *embedding*, *inverted index*, *compaction*, *tombstone*,
*LSM tree*, *CRDT*, *upsert*, *primary key*, *healthcheck*, *digest*, *tag* y *recall* (en vectorial).

**Se escriben en español:** índice, consulta, colección, partición, particionado declarativo,
agregación, réplica, replicación, contenedor, volumen, perfil (de Compose), punto de rotura, línea
base, apuesta falsable, veredicto, viaje y clúster.

- **"Viaje"** es la unidad de costo del curso: una ida y vuelta entre el proceso y el motor. Se mide
  con el arnés de `a04` y no se reemplaza por *round trip* en la prosa.
- **"Clúster"** se escribe con tilde cuando es el grupo de nodos; `CLUSTER` y *clustering key*, tal
  cual, cuando son la palabra del motor.
- **"Familia"** es el modelo de acceso (documental, clave-valor, analítico embebido, series
  temporales, búsqueda, grafos, vectorial, columnar ancha, offline-first, NewSQL); **"motor"** es el
  producto que la representa. Una fase no dice "MongoDB" donde quiere decir "documental".

---

## 3. 🚫 Calcos y falsos amigos

| No | Sí | Por qué |
|---|---|---|
| ordenador, vale, vosotros | computadora, de acuerdo, ustedes | español latinoamericano neutro (`CLAUDE.md`) |
| *performance* en la prosa | rendimiento | hay traducción asentada |
| "escalar" como sinónimo de "ir rápido" | decir qué crece: datos, escrituras, lectores | el curso mide la forma, no la velocidad |
| "librería" para un paquete de código | biblioteca o *driver*, según el caso | ⚖️ hoy el curso usa "librería" 5 veces y "biblioteca" 1; se unifica en "biblioteca" al cerrar la Tanda 6, sin tocar lo publicado antes |

---

## 4. 💻 El código del dominio

### 4.1 Las diez entidades

Fijas en todo el curso, en inglés, y **ninguna fase las renombra** (guía §5). Qué es cada una está en
la historia §6.

| Entidad | En la prosa |
|---|---|
| `aircraft` | aeronave |
| `part` | pieza (con número de serie e historia propia) |
| `partCatalog` | catálogo de partes |
| `assembly` | conjunto (motor, tren, hélice) |
| `workOrder` | orden de trabajo |
| `reading` | lectura (parámetro de vuelo, horas, ciclos) |
| `pirep` | reporte del piloto, o *pirep* |
| `technician` | técnico |
| `hangar` | base o taller |
| `supplier` | proveedor (de partes, o taller aliado) |

### 4.2 Convenciones por motor

`camelCase` en MongoDB, Valkey, OpenSearch, Neo4j, Qdrant, CouchDB y el dataset canónico de `a05`;
`snake_case` en PostgreSQL, TimescaleDB, DuckDB, Cassandra y CockroachDB. La incoherencia es
deliberada y se explica una vez, en `a08`. El cargador de cada fase hace la conversión.

### 4.3 Comentarios

En español con tildes (guía §5 y §16, excepción 5). Los identificadores y los nombres de archivo,
en inglés.

---

## 5. ➕ Cómo se agrega un término

1. Se busca aquí, en la guía §3 y en `a08`.
2. Si no está, se mira cómo lo escribe la documentación oficial del motor de la fase.
3. Se agrega aquí, con la fase que lo estrena, y la fase A de su familia lo publica en `a08`.
