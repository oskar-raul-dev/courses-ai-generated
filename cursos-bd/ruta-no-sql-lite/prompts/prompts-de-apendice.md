# 📎 Prompts iniciales por apéndice
## Ruta NoSQL Lite — 10 chats, 10 entregables

Cada sección es el prompt completo de un apéndice, listo para copiar. Los valores salen de
[`propuesta-apendices-y-alcance.md`](propuesta-apendices-y-alcance.md); si cambian allí, se
cambian aquí después y **nunca al revés**.

**Un chat, un archivo.**

> ⚠️ **El orden importa.** `a01`, `a02`, `a05` y `a06` se escriben **antes de la Fase 01**:
> sin ellos no hay laboratorio y ninguna fase puede ejecutarse. `a03`, `a04`, `a08` y `a09`
> se abren con su esqueleto y **crecen con el curso**; se cierran al final. `a07` va con
> F03–F04 y `a10` con F05.

---

## 🧱 El marco común a todos los apéndices

```markdown
## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en orden: `prompts/alcance-del-proyecto.md`,
`prompts/guia-de-estilo-y-convenciones.md`, `prompts/propuesta-apendices-y-alcance.md`,
`prompts/plantillas-de-capitulo.md` (plantilla de apéndice, la laxa),
`prompts/formato-bitacora-de-medicion.md`, y los apéndices ya escritos. Los documentos
desechables no cuentan y no se citan.

Reglas de apéndice:
- **Esto no se lee de corrido.** Índice de salto rápido, secciones cortas que responden a
  UNA pregunta, ejemplo mínimo ejecutable, tabla de "cuándo usar qué" al final.
- **Un apéndice no repite lo que explica una fase: enlaza.** Si dos documentos explican lo
  mismo, uno de los dos está mal.
- **Los de infraestructura no enseñan Docker.** Comandos y nada más; el mecanismo está en
  `docker-container-legacy/` y se enlaza. Si una sección necesita más de dos párrafos de
  explicación de contenedores, ese contenido no es de aquí.
- **Nada sin ejecutar.** Ningún comando, ninguna versión, ninguna salida inventada. Lo no
  verificado se declara con esas palabras.
- **Todo ejemplo usa el dominio de flota** con sus nombres fijos. Nunca `foo` ni `bar`.
- **Declara qué queda fuera** en el encabezado, y dónde está.
- Cierre con el bloque 🏷️ en su variante negativa, salvo `a02` y `a05`, que dejan archivos
  en el repositorio y llevan tag propio.
- Ejercicios: **5 a 10**, cortos y de consulta.
```

Y el **protocolo de tres pasos**: (1) preguntas bloqueantes numeradas y lectura del
alcance, sin redactar; (2) redacción cuando yo responda, parando a preguntar si aparece
una duda nueva; (3) autoverificación contra §15 de la guía, en lista corta.

---

## # a01 — Laboratorio contenerizado en tres plataformas

```markdown
Este es el chat del **Apéndice a01 — 🐳 Laboratorio contenerizado en tres plataformas**.
Entregable: `a01-laboratorio-contenerizado.md`. **3 h de consulta.**

{{marco común}}

## Alcance

- **Windows 11 + WSL2:** instalar, verificar, dónde viven de verdad los archivos y por qué
  el rendimiento se desploma si el proyecto está en `/mnt/c`.
- **macOS arm64:** Docker Desktop o Colima en una tabla de tres filas, más la advertencia
  de arquitectura — qué imágenes de este curso no tienen build `arm64` y qué hacer.
- **Linux:** el caso fácil, en media página, más el grupo `docker` y la alternativa
  rootless.
- **El ciclo en comandos:** `up`, `ps`, `logs`, `exec`, `down`, `down -v`. Una línea de qué
  hace cada uno y ni una más.
- **Podman en tabla de equivalencias**, y las tres diferencias que muerden: rootless por
  defecto, puertos por debajo de 1024, permisos de volumen.
- **Límites de memoria y CPU por servicio**, que aquí no son un detalle: deciden si puedes
  levantar dos motores a la vez.
- **Limpiar y recuperar disco**, que con diez motores se llena antes de lo que nadie
  espera.

## Qué NO entra — y es la mitad del valor de este apéndice

Qué es una imagen, qué es una capa, copy-on-write, redes de contenedores, `Dockerfile`,
multi-stage, registries, arquitecturas y emulación. **Todo eso está escrito y bien escrito
en `docker-container-legacy/`**; aquí solo se enlaza.

## Audiencia

Ingeniero senior que ya usa contenedores. No le expliques nada: dale la receta y el
comando de verificación.

## Ejercicios: 8, de consulta. Uno de ellos: puerto ocupado, reconocerlo y salir.

{{protocolo}} Si te descubres explicando qué hace `up` por dentro, corta y enlaza.
```

---

## # a02 — El `compose.yaml` de la ruta

```markdown
Este es el chat del **Apéndice a02 — 🧩 El `compose.yaml` de la ruta**. Entregable:
`a02-compose-de-la-ruta.md` **más el propio `compose.yaml`**. **2 h.**

{{marco común}}

## Alcance

- **Un perfil por familia** (`--profile documental`, `--profile busqueda`, …) más el perfil
  `base`, que es Postgres y siempre está arriba porque es la línea base de todas las
  mediciones.
- **Servicios nombrados por familia, no por producto** —`documental`, `vectorial`,
  `columnar`—, para que cambiar de motor no rompa comandos ya escritos.
- **Digests fijados** de las diez imágenes, con su tag legible en comentario y la fecha de
  verificación ejecutada. **Este apéndice es el único sitio del curso donde vive una
  versión**; todo lo demás apunta aquí.
- **Healthchecks**, para que `up` no devuelva antes de que el motor acepte conexiones — que
  es el primer error de la mitad de los lectores.
- **Volúmenes nombrados** con la convención del curso, y qué se pierde con `down -v`.
- **La tabla de RAM**, que es lo más consultado: qué combinaciones de perfiles caben en 8
  GB, cuáles en 16 y cuáles no, **con el número medido**.

## Qué NO entra

Orquestación, escalado, redes personalizadas, secretos, y cualquier cosa que se parezca a
un despliegue. Esto es un laboratorio en una máquina.

## Pendientes bloqueantes

**Este apéndice no se puede escribir sin la sesión de verificación de laboratorio.** Los
digests y la tabla de RAM salen de ejecutar, no de la documentación. Si no está hecha,
párate y dímelo.

## Ejercicios: 6.

{{protocolo}} Lleva tag propio: deja el `compose.yaml` en el repositorio.
```

---

## # a03 — CLIs de los diez motores

```markdown
Este es el chat del **Apéndice a03 — ⌨️ CLIs de los diez motores**. Entregable:
`a03-clis-de-los-motores.md`. **3 h.** Crece con el curso: se abre con el esqueleto y las
secciones de los motores ya vistos, y se cierra al final.

{{marco común}}

## Alcance

Una sección por motor, todas con la misma forma: conectar desde el contenedor y desde el
host · listar lo que haya · insertar un documento o fila del dominio de flota · consultarlo
· contar · borrar · salir. Motores: `mongosh`, `valkey-cli`, `duckdb`, `psql`, `cqlsh`,
`cypher-shell`, API HTTP de Qdrant, `curl` contra OpenSearch, `cockroach sql`, Fauxton/HTTP
de CouchDB.

Y las dos cosas que en este curso se consultan más que la sintaxis: **cómo se pide el plan
de ejecución** en cada uno, y **cómo se sale sin dejar el proceso colgado**.

## Qué NO entra

Administración, usuarios y permisos, backup, tuning. Ninguna comparación entre productos de
la misma familia — eso es materia de los cursos profundos de `ruta-no-sql/`.

## Ejercicios: 10, uno por motor: conectar y responder una pregunta del dominio.

{{protocolo}}
```

---

## # a04 — El arnés de medida

```markdown
Este es el chat del **Apéndice a04 — 📐 El arnés de medida**. Entregable:
`a04-el-arnes-de-medida.md`. **3 h.** Es el apéndice más importante del curso: es el que
hace que las afirmaciones sean evidencia y no opinión.

{{marco común}}

## Alcance

- **Qué campo mirar en cada motor y cuál ignorar**, que es donde casi todo el mundo se
  equivoca. La tabla de correspondencia está en §2.3 de
  `prompts/formato-bitacora-de-medicion.md`: desarróllala con el comando exacto y una
  salida real por motor.
- **Cómo se cuentan los viajes de ida y vuelta**, que ningún motor reporta: se cuentan en
  el cliente y el arnés trae el contador. **Es la métrica más importante del curso y la
  única que hay que instrumentar a mano.**
- **Cómo se mide el fan-out y la amplificación de escritura** sin herramientas externas.
- **La ficha de medición** con sus cinco datos y el script que la imprime ya formateada
  para pegar en un documento.
- **El protocolo de la apuesta falsable:** se escribe antes, no se edita después.

## Qué NO entra

Benchmarking de rendimiento, generadores de carga sintética, percentiles de latencia. Este
curso **mide la forma, no la velocidad**, y esa decisión está declarada en §6 del alcance.

## Ejercicios: 8, todos de medir lo mismo en dos motores y explicar la diferencia.

{{protocolo}}
```

---

## # a05 — El dominio de flota y sus datos

```markdown
Este es el chat del **Apéndice a05 — 🚚 El dominio de flota y sus datos**. Entregable:
`a05-el-dominio-de-flota.md` **más el generador**. **2 h.**

{{marco común}}

## Alcance

- El modelo conceptual completo con las nueve entidades y sus relaciones.
- El generador en **TypeScript**, con **semilla determinista**: la misma medición en tu
  máquina y en la mía.
- Los tres volúmenes del curso —10 k, 1 M y el de rotura, que cada familia calibra— y qué
  se usa para qué.
- Los cargadores por motor, que son lo que se ejecuta al empezar cada fase A.
- **La decisión que sostiene el curso entero, escrita aquí:** los datos son los mismos en
  las diez familias. Si cada minicurso trajera su propio ejemplo, no habría comparación
  posible y esto serían diez tutoriales en fila.

## Qué NO entra

Datos reales de nadie, ni datasets descargados que puedan desaparecer. Todo se genera.

## Ejercicios: 6.

{{protocolo}} Lleva tag propio: deja el generador en el repositorio.
```

---

## # a06 — Lenguajes, drivers y frameworks

```markdown
Este es el chat del **Apéndice a06 — 🧰 Lenguajes, drivers y frameworks**. Entregable:
`a06-lenguajes-y-drivers.md`. **4 h.**

{{marco común}}

## Alcance

- **TypeScript / Node, el entorno por defecto.** El arnés y el generador son TypeScript
  **siempre**: un instrumento con dos implementaciones deja de ser un instrumento. Driver
  por motor con su versión, cómo se conecta, **cómo se cierra la conexión** —que es la
  causa del proceso que no termina— y el mínimo de `async/await` para quien no vive en Node.
- **Python, solo donde el ecosistema de la familia vive ahí de verdad:** vectorial
  (embeddings) y analítico embebido (DuckDB). En ninguna otra parte del curso.
- **La tabla de equivalencias** entre los dos, para que nadie se quede parado en una fase
  por no escribir Python a diario.
- **Cómo se ejecuta:** script local contra el motor en contenedor, y cuándo conviene
  `docker compose exec` en su lugar.

## Qué NO entra

ORMs, ODMs, frameworks de aplicación, patrones de repositorio. Este curso habla con los
motores directamente, **y es una decisión pedagógica**: los clientes de alto nivel esconden
justo lo que queremos medir. Dilo así en el apéndice.

## Pendientes bloqueantes

El modelo de embeddings de F15/F16 está sin elegir y condiciona la sección de Python.

## Ejercicios: 8.

{{protocolo}}
```

---

## # a07 — Postgres como línea base

```markdown
Este es el chat del **Apéndice a07 — 🐘 Postgres como línea base**. Entregable:
`a07-postgres-linea-base.md`. **3 h.** Se escribe con F03–F04.

{{marco común}}

## Alcance

JSONB con índices GIN y cuándo `jsonb_path_ops` cambia el resultado · full-text con
`tsvector`, diccionarios y ranking · `pgvector` con HNSW e IVFFlat · `WITH RECURSIVE` bien
escrito, con corte de ciclos · particionado declarativo por rango · tablas `UNLOGGED` ·
`EXPLAIN (ANALYZE, BUFFERS)` leído de verdad.

## La regla que va en la primera línea del apéndice

**Cuando el curso mide contra Postgres, Postgres va con su mejor configuración razonable**,
no con la de fábrica. Ganarle a una línea base mal puesta no demuestra nada, y el lector
que sabe lo nota en tres segundos. Y el corolario para quien escribe: si no sabes cuál es
la mejor forma relacional de resolver algo, **todavía no puedes escribir esa comparación**.

## Qué NO entra

Administración de Postgres, replicación, tuning de producción.

## Ejercicios: 8.

{{protocolo}}
```

---

## # a08 — Diccionario de traducción y glosario

```markdown
Este es el chat del **Apéndice a08 — 📖 Diccionario de traducción y glosario**. Entregable:
`a08-diccionario-y-glosario.md`. **2 h.** Crece con el curso.

{{marco común}}

## Alcance

El diccionario en **las dos direcciones**, como pide el `CLAUDE.md` del repositorio: de
relacional a cada familia y de vuelta. Qué reemplaza a un `JOIN` en cada modelo · qué
significa exactamente "índice" en documental, búsqueda, vectorial y columnar ancha, que no
es lo mismo en ninguno · partición contra sharding contra particionado declarativo ·
consistencia eventual sin misticismo · qué es una transacción en cada familia, si es que lo
es.

Más el glosario del curso: qué términos se dejan en inglés y por qué, y las convenciones de
nombrado —`camelCase` en los documentales, `snake_case` en los que hablan SQL— con el
porqué de la incoherencia deliberada.

## Ejercicios: 6. Dada una consulta SQL, escribir la equivalente en tres familias y decir
en cuál no hay equivalente honesta.

{{protocolo}}
```

---

## # a09 — Catálogo de errores con mensaje literal

```markdown
Este es el chat del **Apéndice a09 — 🧯 Catálogo de errores con mensaje literal**.
Entregable: `a09-catalogo-de-errores.md`. **3 h.** Es apéndice **y** documento vivo a la
vez: no hay un catálogo aparte del apéndice. Se abre con su esqueleto y crece con el
curso; se cierra al final.

{{marco común}}

## Alcance

El formato de entrada está en §6 de `prompts/formato-bitacora-de-medicion.md` y se sigue
literal: mensaje literal en bloque `text` · motor y versión con digest · en qué fase
apareció y ejecutando qué · qué lo provoca · cómo confirmas que es este y no otro · cómo se
sale · **y si la salida correcta es no salir, sino rediseñar**.

Las primeras entradas ya se conocen: `E11000 duplicate key error`,
`Transaction numbers are only allowed on a replica set member or mongos`,
`OOM command not allowed when used memory > 'maxmemory'`,
`cluster_block_exception … read-only-allow-delete`, `BSONObjectTooLarge`, el de
`ALLOW FILTERING`, el aviso de producto cartesiano de Cypher y los conflictos de CouchDB.

## La regla operativa

Todo error que aparezca al ejecutar entra **con su mensaje literal**, aunque ese día no se
use. Y se anota **antes** de arreglarlo: un mensaje reconstruido de memoria es un mensaje
que no existe, y un mensaje que no existe no lo encuentra nadie en un buscador.

**Meta declarada: cincuenta entradas al cerrar el curso.**

## Ejercicios: 10, todos de provocar un error a propósito y reconocerlo por su mensaje.

{{protocolo}}
```

---

## # a10 — Licencias y riesgo

```markdown
Este es el chat del **Apéndice a10 — ⚖️ Licencias y riesgo**. Entregable:
`a10-licencias-y-riesgo.md`. **1 h.** Se escribe con F05.

{{marco común}}

## Alcance

SSPL, BSL y la Elastic License explicadas en lo que le importa a un ingeniero que tiene que
meter esto en una empresa: qué puedes hacer, qué no, y **a partir de qué momento el
problema deja de ser técnico**. Por qué este curso usa **Valkey** y no Redis, y
**OpenSearch** y no Elasticsearch. Los forks, quién los mantiene y qué tan verosímil es su
continuidad. Y qué preguntar —y a quién— antes de proponer un motor.

## Qué NO entra

Asesoría legal. Dilo explícitamente: esto orienta la conversación con quien sí sabe, no la
sustituye.

## Ejercicios: 5.

{{protocolo}} Cuidado con el tono: aquí es fácil sonar a activista. El apéndice informa,
no milita.
```
