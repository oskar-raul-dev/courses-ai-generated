# 📎 Propuesta de apéndices y alcance
## Ruta NoSQL Lite — diez apéndices transversales

> **Qué es este documento:** qué apéndices tiene el curso, qué entra en cada uno, cuántas
> horas de consulta representan y —sobre todo— **qué queda explícitamente fuera**.
> **Precedencia:** por encima, [`alcance-del-proyecto.md`](alcance-del-proyecto.md) y
> [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md); al lado,
> [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md).
> **Fecha:** 10 de septiembre de 2026

---

## 1. 🧭 Qué es un apéndice en este curso

**Los apéndices son transversales a la ruta, no a la familia.** Es una excepción declarada
al `CLAUDE.md` del repositorio, con su motivo escrito en §16 de la guía de estilo: el
laboratorio, el dominio y el arnés de medida son compartidos por definición, y un apéndice
por familia sería escribir diez veces la misma receta de contenedores.

**No se leen de corrido.** Se entra por el índice buscando algo concreto y se sale. De ahí
su forma: índice de salto rápido, secciones cortas que responden a una pregunta, ejemplo
mínimo ejecutable, tabla de "cuándo usar qué" al final, y de 5 a 10 ejercicios de consulta.

**Sus horas no cuentan** dentro de las 252 h del curso.

> 🧭 **La regla de oro de los apéndices de infraestructura: comandos y nada más.** Si una
> sección necesita más de dos párrafos para explicar qué hace un comando de contenedores,
> ese contenido pertenece a `docker-container-legacy/` y lo que va aquí es el enlace. Esta
> regla es lo único que impide que la Ruta NoSQL Lite se convierta en otro curso de Docker.

---

## 2. 📊 Los diez, de un vistazo

| # | Apéndice | Horas | Cuándo se escribe | Usado por |
|---|---|---|---|---|
| a01 | Laboratorio contenerizado en tres plataformas | 3 h | **antes de F01** | todas |
| a02 | El `compose.yaml` de la ruta | 2 h | **antes de F01** | todas |
| a03 | CLIs de los diez motores | 3 h | crece con el curso | todas las fases A |
| a04 | El arnés de medida | 3 h | crece con el curso | todas las fases B |
| a05 | El dominio de flota y sus datos | 2 h | **antes de F01** | todas |
| a06 | Lenguajes, drivers y frameworks | 4 h | **antes de F01** | todas |
| a07 | Postgres como línea base | 3 h | con F03–F04 | todas las fases B |
| a08 | Diccionario de traducción y glosario | 2 h | crece con el curso | todas las fases A |
| a09 | Catálogo de errores con mensaje literal | 3 h | crece con el curso | todas |
| a10 | Licencias y riesgo | 1 h | con F05 | F03, F05, F11 |

### 2.1 Los nombres de archivo, que son canónicos

```
a01-laboratorio-contenerizado.md   a06-lenguajes-y-drivers.md
a02-compose-de-la-ruta.md          a07-postgres-linea-base.md
a03-clis-de-los-motores.md         a08-diccionario-y-glosario.md
a04-el-arnes-de-medida.md          a09-catalogo-de-errores.md
a05-el-dominio-de-flota.md         a10-licencias-y-riesgo.md
```

Dos dígitos siempre, para que `a09` no quede después de `a10`. **`a09` es apéndice y
documento vivo a la vez**: el catálogo de errores no existe aparte del apéndice, y por eso
no hay ningún `catalogo-de-errores.md` suelto en la raíz. Los otros dos documentos vivos
—`INSTINTOS.md` y `bitacora-de-medicion.md`— sí viven en la raíz y no son apéndices.

**Cuatro se escriben antes de la primera fase** —a01, a02, a05 y a06— porque sin ellos no
hay laboratorio. **Cuatro crecen con el curso** —a03, a04, a08 y a09— y se cierran al
final; escribirlos completos por adelantado costaría semanas que no están en el
presupuesto, y además saldrían mal, porque lo que va en ellos lo decide la ejecución.

---

## 3. 🐳 a01 — Laboratorio contenerizado en tres plataformas (3 h)

**Qué resuelve:** que el lector tenga los diez motores levantables en su máquina sea cual
sea, en menos de media hora y sin haber aprendido nada de contenedores que no necesite.

**Qué entra:**

- **Windows 11 + WSL2** — instalar, verificar, dónde viven de verdad los archivos y por
  qué el rendimiento se desploma si el proyecto está en `/mnt/c`.
- **macOS arm64** — Docker Desktop o Colima, la elección en una tabla de tres filas, y la
  advertencia de arquitectura: qué imágenes de este curso **no** tienen build `arm64` y qué
  hacer entonces.
- **Linux** — el caso fácil, en media página, más el grupo `docker` y la alternativa
  rootless.
- **El ciclo completo en comandos:** `up`, `ps`, `logs`, `exec`, `down`, `down -v`. Cada
  uno con una línea de qué hace y ni una más.
- **Podman al lado, en tabla de equivalencias**, y las tres diferencias que de verdad
  muerden: modo rootless por defecto, puertos por debajo de 1024 y permisos de volumen.
- **Límites de memoria y CPU** por servicio, que en este curso no son un detalle: son lo
  que decide si puedes levantar dos motores a la vez.
- **Limpiar:** cómo borrar volúmenes y recuperar disco, que con diez motores y tres
  volúmenes de datos se llena antes de lo que nadie espera.

**Qué NO entra, y es la mitad del valor del apéndice:** qué es una imagen, qué es una capa,
cómo funciona el copy-on-write, redes de contenedores, `Dockerfile`, multi-stage,
registries, arquitecturas y emulación. **Todo eso está escrito y bien escrito en
`docker-container-legacy/`**, y aquí solo se enlaza.

**Ejercicios: 8**, de consulta: levantar, verificar, romper un puerto ocupado y salir.

---

## 4. 🧩 a02 — El `compose.yaml` de la ruta (2 h)

**Qué resuelve:** un solo archivo para todo el curso, del que se levanta solo lo que hace
falta.

**Qué entra:**

- **Un perfil por familia** (`--profile documental`, `--profile busqueda`, …) más el perfil
  `base`, que es Postgres y siempre está arriba porque es la línea base de todas las
  mediciones.
- **Los servicios se nombran por familia y no por producto** —`documental`, `vectorial`,
  `columnar`— para que cambiar de motor no rompa media docena de comandos ya escritos.
- **Digests fijados** de las diez imágenes, con su tag legible en comentario y la **fecha
  de verificación ejecutada**. Este apéndice es el único sitio del curso donde vive una
  versión; todo lo demás apunta aquí.
- **Healthchecks**, para que `up` no devuelva antes de que el motor acepte conexiones —que
  es la causa del primer error de la mitad de los lectores—.
- **Volúmenes nombrados** con la convención del curso, y qué se pierde con `down -v`.
- **La advertencia de RAM**, que es lo más consultado del apéndice: qué combinaciones de
  perfiles caben en 8 GB, cuáles en 16 y cuáles directamente no, con el número medido.

**Qué NO entra:** orquestación, escalado, redes personalizadas, secretos, y cualquier cosa
que se parezca a un despliegue. Esto es un laboratorio en una máquina.

**Ejercicios: 6.**

---

## 5. ⌨️ a03 — CLIs de los diez motores (3 h)

**Qué resuelve:** entrar, mirar, escribir algo y salir, en un motor que tocaste por última
vez hace dos meses.

**Qué entra:** una sección por motor, todas con la misma forma —conectar desde el
contenedor y desde el host, listar lo que haya, insertar un documento o fila de ejemplo del
dominio de flota, consultarlo, contar, borrar, salir—: `mongosh`, `valkey-cli`, `duckdb`,
`psql`, `cqlsh`, `cypher-shell`, la API HTTP de Qdrant, `curl` contra OpenSearch,
`cockroach sql` y Fauxton/HTTP de CouchDB.

Y dos cosas que en este curso se consultan más que la sintaxis: **cómo se pide el plan de
ejecución** en cada uno, y **cómo se sale sin dejar el proceso colgado**.

**Qué NO entra:** administración, usuarios y permisos, backup, tuning. Y ninguna
comparación entre productos de la misma familia.

**Ejercicios: 10**, uno por motor: conectar y responder una pregunta concreta del dominio.

---

## 6. 📐 a04 — El arnés de medida (3 h)

Es el apéndice más importante del curso, porque es el que hace que las afirmaciones sean
evidencia y no opinión.

**Qué entra:**

- **Qué campo mirar en cada motor y cuál ignorar**, que es donde casi todo el mundo se
  equivoca: `explain("executionStats")` y `totalDocsExamined` contra `nReturned` en Mongo;
  `EXPLAIN (ANALYZE, BUFFERS)` y `pg_stat_statements` en Postgres; `PROFILE` y sus
  `db hits` en Neo4j; `TRACING ON` y las particiones tocadas en Cassandra; el `EXPLAIN` de
  DuckDB y las columnas leídas; el `profile` de OpenSearch; el recall medido a mano en
  Qdrant.
- **Cómo se cuentan los viajes** de ida y vuelta, que ningún motor te dice: se cuentan en
  el cliente, y el arnés del curso trae el contador.
- **Cómo se mide el fan-out y la amplificación de escritura** sin herramientas externas.
- **La ficha de medición** con sus cinco datos obligatorios (§6 de la guía) y el script que
  la imprime ya formateada para pegar en un documento.
- **El protocolo de la apuesta falsable**: se escribe antes, no se edita después.

**Qué NO entra:** benchmarking de rendimiento, generadores de carga sintética, percentiles
de latencia. Este curso **mide la forma, no la velocidad**, y esa decisión está declarada
en §6 del alcance.

**Ejercicios: 8**, todos de medir lo mismo en dos motores y explicar la diferencia.

---

## 7. 🚚 a05 — El dominio de flota y sus datos (2 h)

**Qué entra:** el modelo conceptual completo con sus nueve entidades y sus relaciones; el
generador en TypeScript con **semilla determinista**, para que la medición sea la misma en
tu máquina y en la mía; los tres volúmenes del curso (10 k, 1 M y el de rotura, que cada
familia calibra); y los cargadores por motor, que son lo que se ejecuta al empezar cada
fase A.

**La decisión que sostiene el curso entero y va escrita aquí:** los datos son los mismos
en las diez familias. Si cada minicurso trajera su propio ejemplo, no habría comparación
posible y el curso sería diez tutoriales en fila.

**Qué NO entra:** datos reales de nadie, ni datasets descargados que puedan desaparecer.
Todo se genera.

**Ejercicios: 6.**

---

## 8. 🧰 a06 — Lenguajes, drivers y frameworks (4 h)

**Qué entra:** los dos entornos del laboratorio y la regla que decide cuál se usa.

- **TypeScript / Node — el entorno por defecto.** El arnés de medida y el generador de
  datos son TypeScript **siempre**: un instrumento con dos implementaciones deja de ser un
  instrumento. Driver por motor con su versión, cómo se conecta, cómo se cierra la conexión
  —que es la causa del proceso que no termina— y el mínimo de `async/await` para quien no
  vive en Node.
- **Python — solo donde el ecosistema de la familia vive ahí de verdad:** vectorial
  (embeddings) y analítico embebido (DuckDB). En ninguna otra parte del curso.
- **La tabla de equivalencias** entre los dos, para que nadie se quede parado en una fase
  por no escribir Python a diario.
- **Cómo se ejecuta**: script local contra el motor en contenedor, y cuándo conviene
  `docker compose exec` en su lugar.

**Qué NO entra:** ORMs, ODMs, frameworks de aplicación, patrones de repositorio. Este curso
habla con los motores directamente, y esa es una decisión pedagógica: los clientes de alto
nivel esconden justo lo que queremos medir.

**Ejercicios: 8.**

---

## 9. 🐘 a07 — Postgres como línea base (3 h)

**Qué resuelve:** que el rival permanente esté bien jugado. Si la línea base está mal
configurada, todas las mediciones del curso son propaganda.

**Qué entra:** JSONB con índices GIN y cuándo `jsonb_path_ops` cambia el resultado;
full-text con `tsvector`, diccionarios y ranking; `pgvector` con HNSW e IVFFlat; `WITH
RECURSIVE` bien escrito, con corte de ciclos; particionado declarativo por rango; tablas
`UNLOGGED`; y `EXPLAIN (ANALYZE, BUFFERS)` leído de verdad.

**La regla que va escrita en la primera línea del apéndice:** cuando el curso mide contra
Postgres, **Postgres va con su mejor configuración razonable**, no con la de fábrica.
Ganarle a una línea base mal puesta no demuestra nada, y el lector que sabe lo va a notar.

**Qué NO entra:** administración de Postgres, replicación, tuning de producción.

**Ejercicios: 8.**

---

## 10. 📖 a08 — Diccionario de traducción y glosario (2 h)

**Qué entra:** el diccionario en **las dos direcciones**, como pide el `CLAUDE.md` del
repositorio — de relacional a cada familia y de vuelta. Qué reemplaza a un `JOIN` en cada
modelo; qué significa exactamente "índice" en documental, en búsqueda, en vectorial y en
columnar ancha, que no es lo mismo en ninguno; partición contra sharding contra
particionado declarativo; consistencia eventual sin misticismo; qué es una transacción en
cada familia, si es que lo es.

Más el glosario del curso: los términos que se dejan en inglés y por qué, y las
convenciones de nombrado —`camelCase` en los motores documentales, `snake_case` en los que
hablan SQL— con el porqué de la incoherencia deliberada.

**Ejercicios: 6**, de traducción: dada una consulta SQL, escribir la equivalente en tres
familias y decir cuál no tiene equivalente honesta.

---

## 11. 🧯 a09 — Catálogo de errores con mensaje literal (3 h)

**Qué es:** el activo más buscable del curso, y el único apéndice que además es documento
vivo — no hay un catálogo separado de él. Todo error que aparezca al ejecutar entra aquí
**con su mensaje exacto**, aunque ese día no se use y aunque no pertenezca a la fase que se
esté escribiendo.

**Formato de cada entrada:** mensaje literal en bloque `text` · motor y versión · qué lo
provocó · cómo se confirma que es ese y no otro · cómo se sale · si la salida correcta es
no salir, sino rediseñar.

**Las primeras entradas, que ya se conocen:**

```text
E11000 duplicate key error collection: …
Transaction numbers are only allowed on a replica set member or mongos
OOM command not allowed when used memory > 'maxmemory'
cluster_block_exception … index read-only-allow-delete
BSONObjectTooLarge
Cannot execute this query as it might involve data filtering … ALLOW FILTERING
```

más el aviso de producto cartesiano de Cypher y los de conflicto de replicación de CouchDB.

> 🧭 **Regla operativa que sale gratis y vale mucho:** anota el error **antes** de
> arreglarlo. Un mensaje reconstruido de memoria es un mensaje que no existe, y un mensaje
> que no existe no lo encuentra nadie.

**Meta declarada:** cincuenta entradas al cerrar el curso.

**Ejercicios: 10**, todos de provocar un error a propósito y reconocerlo por su mensaje.

---

## 12. ⚖️ a10 — Licencias y riesgo (1 h)

**Qué entra:** SSPL, BSL y la Elastic License explicadas en lo que le importa a un
ingeniero que tiene que meter esto en una empresa: qué puedes hacer, qué no, y **a partir
de qué momento el problema deja de ser técnico**. Por qué este curso usa **Valkey** y no
Redis, y **OpenSearch** y no Elasticsearch. Los forks, quién los mantiene y qué tan
verosímil es su continuidad. Y qué preguntar —y a quién— antes de proponer un motor.

**Qué NO entra:** asesoría legal. Se dice explícitamente: esto orienta la conversación con
quien sí sabe, no la sustituye.

**Ejercicios: 5.**

---

## 13. 📌 Pendientes de este documento

- **`a02` no se puede cerrar** hasta la sesión de verificación de laboratorio: los digests
  y la tabla de RAM salen de ejecutar, no de la documentación.
- **`a06` depende del modelo de embeddings** que se elija para F15/F16.
- **`a03` y `a09` se cierran al final del curso** por construcción, aunque su esqueleto se
  cree con la primera fase que los alimente.
- **Si aparece un undécimo apéndice**, el candidato más probable es uno de observabilidad
  mínima —cómo mirar qué está haciendo un motor mientras corre—. Hoy está repartido entre
  `a03` y `a04` a propósito, y solo se saca si esas dos secciones se vuelven inmanejables.
