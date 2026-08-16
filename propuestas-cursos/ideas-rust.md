# 🦀 Ideas para un curso de Rust — notas de exploración

> **Qué es esto:** el registro de una conversación exploratoria sobre qué forma tendría un
> curso *"Rust para desarrolladores Java senior"* en este repositorio. No es una propuesta
> aprobada ni un plan: es material para no perder, con las decisiones provisionales marcadas
> como tales.
> **Fecha:** 12 de septiembre de 2026
> **Contexto:** existe `cursos-algoritmos-lenguajes/go-for-java-devs/` (18 fases, 4 servicios,
> 46 mini proyectos), y la pregunta que abrió la conversación fue si se puede calcar esa forma
> para Rust.
> **Estado:** borrador de discusión. Nada de aquí está verificado con benchmarks propios.

Hay una idea que ordena todo el documento y conviene ponerla primero:

> 🧠 **El curso de Go se sostiene porque el backend web es un nicho natural de Go. Un curso de
> Rust solo se sostiene si el proyecto vive en el nicho natural de Rust — y ese nicho no son
> las APIs REST.** Todo lo que sigue es consecuencia de eso.

---

## 1. 🧭 El criterio: por qué no calcar el curso de Go

El curso de Go se estructuró alrededor de cuatro familias de backend porque Go, ahí, está en
casa: el lenguaje resuelve el problema con menos ceremonia que la alternativa, y el alumno lo
siente en la primera hora.

Con Rust ese calco falla, y falla de forma predecible. Si el curso construye cuatro servicios
REST, el alumno pasa el curso entero peleando con el *borrow checker* para conseguir lo que
Spring Boot le daba gratis, y llega a una conclusión perfectamente razonable: **que Rust no
valía la pena**. El problema no es del alumno ni del lenguaje; es que el proyecto está eligiendo
el peor día de Rust como escenario.

El eje de un curso de Rust para gente que viene de Java tiene que ser otro, y es bastante
concreto: **dónde la JVM te cobra algo que no quieres pagar.** Son cuatro cosas, y cada una
justifica un tipo de proyecto distinto:

- **El recolector de basura** — la latencia de cola. Todo lo que tenga un p99 con requisitos.
- **El arranque** — *cold start*. Serverless, CLIs, funciones en el borde.
- **La memoria por instancia** — densidad de despliegue. Sidecars, agentes, flotas grandes.
- **La frontera nativa** — todo lo que en Java significa JNI, `ByteBuffer` directos o
  `sun.misc.Unsafe`.

> 🧭 **La regla que mantiene honesto al curso:** cada proyecto existe porque Java *ahí* pierde,
> y el proyecto lo mide. Si no hay número, el proyecto sobra o está mal planteado.

---

## 2. 📊 Dónde se trabaja de verdad en Rust

Ranking por volumen de empleo real y por estabilidad del nicho, no por entusiasmo de la
comunidad. Todo esto es **apreciación de mercado sin verificar**: si el curso se promueve, hay
que contrastarlo con datos de ofertas antes de escribirlo en un README.

### 2.1 Infraestructura cloud y red — el plano de datos

El nicho más grande y el más estable. Proxies, virtualización, almacenamiento, agentes: el
software que corre *debajo* de las aplicaciones y se despliega en millones de instancias, donde
una pausa de GC o 300 MB de RSS por proceso se multiplican por toda la flota. Los ejemplos
conocidos son Firecracker, Pingora y buena parte de la capa de red de los grandes proveedores.

Aquí Rust **no compite con Java**: compite con C++, y gana por seguridad de memoria sin ceder
rendimiento. Que Java ni siquiera esté en la conversación es precisamente lo que lo hace buen
material didáctico — es territorio nuevo para el alumno, no una reescritura de lo que ya sabe.

### 2.2 Motores de datos y bases de datos

TiKV, InfluxDB, Neon, Materialize, Qdrant, y sobre todo el ecosistema **Arrow / DataFusion /
Polars**. Creciendo rápido porque casi toda startup de datos fundada en los últimos años eligió
Rust por defecto.

Didácticamente es excelente: obliga a pensar en disposición de memoria, copia cero y
concurrencia real, que son exactamente los tres sitios donde la intuición de un Java senior
necesita recalibrarse.

### 2.3 Herramientas de desarrollo — donde Rust ya ganó del todo

`uv`, `ruff`, `biome`, `swc`, `turbopack`, `rust-analyzer`, `deno`, Zed. Son menos plazas en
términos absolutos —es un puñado de empresas— pero es el nicho **más visible y más imitable**:
parsers, ASTs, servidores LSP, cachés incrementales. Si el objetivo es que el alumno construya
algo que reconozca de su día a día, se construye aquí.

### 2.4 Extensiones nativas para otros lenguajes — el nicho silencioso

`pydantic-core`, `tokenizers`, el motor de Polars, el backend de bastantes paquetes de npm.
Casi nadie lo llama "trabajo de Rust" y sin embargo es enorme y sigue creciendo.

Para el público de este curso es **el nicho más relevante de todos**, porque es la vía de
adopción realista en una empresa con un monolito Java o Python: no reescribes el sistema,
reemplazas el 3 % que duele.

### 2.5 Embebido, automoción y crítico de seguridad

`no_std`, fabricantes de coches, aeroespacial. Nicho sólido y bien pagado, pero exige un público
distinto: un Java senior ahí está muy lejos de casa y el curso tendría que enseñar el dominio
además del lenguaje.

### 2.6 Blockchain

Solana, Polkadot, Foundry. Por volumen de ofertas compite con el primer puesto, pero es volátil
y arrastra un dominio que a buena parte de la audiencia no le interesa. **Recomendación
provisional: dejarlo fuera del curso.**

### 2.7 La conclusión provisional

> 📝 El ancla natural para este repositorio es **2.1 + 2.2** (plano de datos y motores de
> datos), con **2.4** (extensiones nativas) como cierre del curso. Ahí el lenguaje trabaja en
> casa, y el contraste con Java es genuino en lugar de forzado: el mismo problema en la JVM se
> resuelve peleando con el GC y la memoria fuera del heap —Netty, `ByteBuffer` directos,
> Chronicle, Epsilon GC—, que es justamente la parte de Java donde el senior ya sufrió.

---

## 3. 🏗️ Constelación propuesta — los cuatro proyectos ancla

Equivalente a los cuatro servicios de Meridian en el curso de Go.

| # | Proyecto | Qué es | Por qué Rust y no Java | Concepto que fuerza |
|---|---|---|---|---|
| 1 | **Motor de ingesta con copia cero** | Lee NDJSON o líneas de log a gran caudal, extrae campos, agrega por ventanas | Cada `String.split()` en Java es basura para el GC; aquí el parser no asigna | *Ownership*, `&str` frente a `String`, *lifetimes*, *slices*, `Cow` |
| 2 | **Proxy / sidecar HTTP con contrapresión** | Reverse proxy con reintentos, límite de tasa, cortocircuito, sondas de salud | p99 sin pausas de GC; decenas de MB de RSS frente a centenares | `async` y Tokio, `Send + Sync`, `Arc<Mutex>` frente a canales, cancelación |
| 3 | **Motor de almacenamiento embebido** | Log estructurado (LSM o WAL + índice) con compactación, recuperación tras caída y `mmap` | Control del *layout* de memoria y `unsafe` acotado que la JVM no concede | `unsafe` disciplinado, `Drop`, `mmap`, serialización binaria, invariantes por tipos |
| 4 | **Extensión nativa para la JVM** | La ruta caliente de un servicio Java reimplementada en Rust vía JNI | Es *el* caso de adopción real: no reescribes el monolito, reescribes lo que duele | FFI, ABI, errores a través de la frontera, `panic = abort`, memoria cruzada |

El proyecto 4 es el que permite cerrar con honestidad, y es la razón de que esté al final: **el
veredicto del curso no es "migra a Rust", es "convive con Rust"**, y el alumno llega a esa
conclusión con sus propias mediciones en la mano, no porque se la cuenten.

---

## 4. 🕰️ La frontera del curso

En el curso de Go la frontera es una versión (1.13 → moderno). En Rust el corte natural no es
una versión sino un **modelo de ejecución**:

```text
Bloque A — Rust síncrono, std pura, hilos y canales    El lenguaje sin escondites
Bloque B — La migración a async / Tokio ⭐               Dos proyectos cruzan
Bloque C — Rust con ecosistema (axum, sqlx, serde…)    El Rust que vas a escribir
```

Empezar sin `async` tiene exactamente la misma virtud que empezar en Go 1.13: sin `.await` que
disimule, el *borrow checker* se enfrenta de cara, y cuando más adelante aparece
`Send + Sync + 'static` en un `spawn`, el alumno ya sabe por qué está ahí cada palabra.

Y la migración duele lo justo para sostener una fase entera: las funciones se vuelven
"coloreadas", el `Mutex` de la biblioteca estándar deja de servir donde había un `await`, y
`Drop` ya no se ejecuta donde uno creía.

---

## 5. 💡 Diez ideas de proyecto para el curso

Más allá de los cuatro anclas, estas son las candidatas que sobrevivieron al criterio de la
sección 1. Cada una indica qué instinto de Java rompe, que es lo que decide si merece una fase.

**1. Motor de consultas columnar sobre Parquet/Arrow.** Un DataFusion en miniatura: leer,
proyectar, filtrar y agregar sin materializar filas. Rompe el instinto de que "una fila es un
objeto"; aquí una fila no existe como entidad.

**2. Agente de observabilidad tipo Vector.** Colas, búfer en disco, contrapresión y entrega
*at-least-once*. Rompe el instinto de la cola ilimitada: en Java `LinkedBlockingQueue` sin
límite es un descuido común; en Rust el canal te obliga a decidir la capacidad.

**3. Broker de mensajes con log de solo-anexado.** Particiones, *offsets* por consumidor,
retención. Rompe el instinto de que la durabilidad es cosa del framework: aquí `fsync` es una
línea que tú escribes y cuyo coste mides.

**4. Cliente de Postgres con protocolo binario a mano.** Implementar el *wire protocol* y un
pool propio. Rompe el instinto de JDBC como caja negra, y enseña máquinas de estado tipadas.

**5. Servidor DNS autoritativo o resolver con caché.** Parsing de un formato binario compacto,
UDP, expiración por TTL. Rompe el instinto de "un mensaje es un objeto JSON".

**6. Túnel cifrado sobre UDP.** Excelente para *typestate*: `Handshake<Pending>` →
`Handshake<Established>` como tipos distintos, de forma que enviar datos antes de negociar **no
compila**. Rompe el instinto de validar estados en tiempo de ejecución con `if` y excepciones.

**7. Un servidor LSP completo para un DSL pequeño.** Parser incremental, concurrencia y latencia
por debajo de 100 ms. Es el proyecto que más se parece a las herramientas que el alumno ya usa.

**8. Anfitrión de plugins con sandbox WASM.** Tu servicio ejecuta extensiones de terceros sin
confiar en ellas. Rompe el instinto del `SecurityManager` y del *classloader* aislado, que en
Java nunca terminó de funcionar.

**9. Parser de un formato binario hostil (PDF, ELF, PCAP) con fuzzing.** `cargo-fuzz` como parte
del temario, no como extra. Rompe el instinto de que las pruebas cubren lógica: aquí cubren
además invariantes de memoria.

**10. El mismo dominio compilado a `wasm32-wasi` para el borde.** Midiendo el arranque en frío
contra la misma lógica en GraalVM native-image. Rompe el instinto de que "arrancar tarda" es una
constante de la naturaleza.

**11. Motor de reglas o WAF con evaluación compilada.** Reglas que se compilan a una
representación evaluable en vez de interpretarse en cada petición.

**12. El CRUD deliberadamente "malo".** Un servicio con `axum` + `sqlx` + migraciones, hecho
bien, comparado contra el mismo servicio en Spring Boot. Gana en RSS y p99; pierde en velocidad
de desarrollo, coste de refactor y talento disponible. Es el gemelo directo de la fase 16 del
curso de Go, y **el curso lo necesita precisamente para poder decir "no uses Rust aquí"**.

---

## 6. 🔬 Miniproyectos para curiosear

Lo que se haría en una tarde, antes de decidir si hay curso. No alimentan a ningún proyecto
grande: sirven para tocar el lenguaje en su terreno y ver si la idea aguanta.

**Para sentir el *ownership* sin sufrirlo**

- `wc` de verdad: contar líneas, palabras y bytes de un archivo grande sin asignar nada por
  línea, y cronometrarlo contra el `wc` del sistema.
- Un `grep` de subcadena fija sobre un archivo con `mmap`, midiendo contra `ripgrep`.
- Contador de frecuencia de palabras sobre un corpus, primero con `String`, luego con `&str`, y
  comparar asignaciones.

**Para sentir la concurrencia**

- Descargador paralelo de una lista de URLs con límite de concurrencia, primero con hilos y
  canales, luego con Tokio. El mismo programa dos veces es la mejor lección del curso.
- Un contador compartido escrito de tres formas —`Mutex`, `AtomicU64` y canal con propietario
  único— y medido bajo contención.

**Para sentir la frontera nativa**

- Una función de Rust llamada desde Python con PyO3 (es el camino más corto para ver el
  beneficio) o desde Java con JNI.
- Compilar cualquiera de lo anterior a WASM y ejecutarlo en el navegador.

**Para sentir el dominio real**

- Parsear un `.pcap` y sacar las diez IPs más habladoras.
- Un cliente de Redis mínimo (el protocolo RESP es sorprendentemente pequeño) contra un
  servidor real.
- Un intérprete de un lenguaje de juguete —el clásico *Crafting Interpreters* en Rust— que es
  la puerta de entrada natural al nicho de herramientas.

---

## 7. ⚖️ Veredicto provisional y avisos

**Lo que no haría.** Un curso de Rust con eje en APIs REST. `axum` es excelente, pero un CRUD en
Rust es un CRUD donde el *borrow checker* cobra peaje sin devolver nada a cambio; enseña el
lenguaje en su peor día y produce alumnos que concluyen, razonablemente, que no valía la pena.

**El instinto equivocado más rentable para un Java senior.** Creer que `Arc<Mutex<T>>` es el
equivalente de un campo `synchronized`. Sintácticamente lo parece; en diseño no lo es en
absoluto. Rust está diciendo que el estado compartido es **la excepción**, no el punto de
partida. Ese es el 🪞 de la fase de concurrencia y probablemente el mejor de todo el curso.

**Lo que hay que verificar antes de promover esto.**

- El ranking de nichos de la sección 2 es apreciación, no dato. Hace falta contrastarlo.
- Todos los "gana en p99" y "gana en RSS" de este documento están sin medir. En este repositorio
  eso significa que **no se pueden escribir en una fase** hasta que existan en un `BENCHMARKS.md`
  con su arnés.
- Falta decidir si el curso vive en `cursos-algoritmos-lenguajes/` junto al de Go, o si abre
  familia propia.
- Falta decidir el tamaño. Cuatro proyectos ancla con la densidad del curso de Go son fácilmente
  más de 130 horas, y Rust tiene una curva inicial que Go no tiene.

---

## 8. 🧵 Preguntas abiertas

1. ¿El público es el mismo Java senior del curso de Go, o uno que ya pasó por él?
2. ¿El proyecto 4 (JNI) debería ser el capstone, o una fase intermedia que reencuadre todo el
   resto?
3. ¿Merece la pena un bloque de `no_std` aunque el público no sea de embebido, solo para que se
   vea qué hace el runtime por ti?
4. ¿El curso enseña `unsafe` de verdad o lo deja en un apéndice? El proyecto 3 lo necesita; casi
   ningún alumno lo escribirá en producción.
