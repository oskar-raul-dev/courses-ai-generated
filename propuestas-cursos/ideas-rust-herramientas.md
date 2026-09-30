# 🦀🔧 Rust para utilitarios y CLIs — donde Java pierde

> **Qué es esto:** una ruta corta de Rust situada en el terreno donde Rust le gana a Java con
> números, que son los utilitarios y las herramientas de línea de comandos. El hilo son varias
> utilidades que el autor quiere tener para uso propio y para sus otros proyectos. Complementa, no
> reemplaza, a [`ideas-rust.md`](ideas-rust.md), que explora un curso grande de Rust en su nicho
> de infraestructura.
> **Fecha:** 29 de septiembre de 2026
> **Panorama:** [`ideas-lenguajes-para-java-devs.md`](ideas-lenguajes-para-java-devs.md).
> **Estado:** borrador de ideas. Nada medido, ninguna versión fijada.

> 🧠 **El curso vive donde la JVM cobra algo que una herramienta no quiere pagar: el arranque, el
> runtime que hay que instalar y la memoria mientras espera.** Cada proyecto existe porque ahí Java
> pierde, y el proyecto lo mide. Que además reinventen una rueda (WireMock, `jq`, los *sandbox* de
> las pasarelas) está bien: da un competidor real contra el cual medirse, y el resultado es una
> herramienta que se usa de verdad.

---

## 1. 🧭 El criterio: por qué utilitarios y CLIs

Un CLI se invoca cientos de veces al día, dentro de scripts, en CI y en ganchos de git. Ahí los
costos fijos de la JVM, que en un servidor se pagan una vez y se olvidan, se pagan en cada
invocación:

- **Arranque.** Un proceso Rust responde en milisegundos; una JVM paga su arranque y su
  calentamiento cada vez. En un script que llama la herramienta mil veces, la diferencia deja de
  ser anecdótica.
- **Distribución.** Un binario estático que se copia y corre, frente a un JRE instalado o un
  `jlink` por plataforma. La compilación cruzada es parte del temario, no un extra.
- **Memoria en reposo.** Un utilitario que vive en segundo plano (el mock, el simulador) ocupa
  pocos MB de RSS, y se puede levantar en cualquier `docker compose` sin que pese.
- **Latencia sin ruido propio.** Un simulador que inyecta latencias no puede sumar pausas de GC y
  de JIT a la distribución que se le pidió.

> ⚖️ **Los competidores honestos son dos, y el veredicto tiene que enfrentarlos.** El primero es
> **GraalVM native-image**, la respuesta de Java al arranque: cierra buena parte de la brecha, y el
> curso tiene que medir cuánta y a qué costo (tiempo de build, configuración de reflexión). El
> segundo es **Go**, que ya tiene curso en el repositorio y escribiría casi todas estas
> herramientas más rápido. Si Rust solo gana en "aprender Rust", el curso lo dice.

### 1.1 La tensión con `ideas-rust.md`

`ideas-rust.md` es tajante: un curso de Rust con eje en APIs REST enseña el lenguaje en su peor
día. El mock y el simulador son servidores HTTP, pero no son CRUD. No hay dominio que modelar ni
base de datos que mapear: el trabajo está en interpretar reglas, evaluar predicados sobre JSON y
controlar el tiempo. Es el terreno de las herramientas de desarrollo (§2.3 de `ideas-rust.md`),
donde Rust ya ganó.

---

## 2. 🎭 Proyecto 1 — el servidor de mocks a medida

### 2.1 Qué hace

Un servidor que responde según reglas declaradas en un archivo (TOML o YAML) y que las recarga en
caliente al guardarlo. Cada regla tiene un *matcher* y una respuesta:

```yaml
# rules/customers.yaml
- name: missing-or-null-name
  match:
    method: POST
    path: /customers
    body:
      any:
        - absent: $.name
        - null: $.name
  respond:
    status: 400
    body: { error: "name is required" }

- name: create-ok
  match: { method: POST, path: /customers }
  respond:
    status: 201
    body: { id: "{{uuid}}", name: "{{body.name}}" }
    delay: { lognormal: { median_ms: 120, p99_ms: 900 } }
```

### 2.2 Lo que enseña de Rust

- **`serde_json::Value` y el modelo de un JSON sin tipo.** El predicado se evalúa sin
  deserializar a un `struct`. Aquí aparece el primer 🪞: *"tu instinto de Jackson dice que un
  campo que no viene y un campo en `null` son lo mismo, y aquí no lo son"*. `Option<Value>` y
  `Value::Null` son dos cosas distintas, y tu regla de 400 depende de distinguirlas.
- **Parseo parcial de verdad.** Primero con `Value` completo, que es lo simple. Después, para
  cuerpos grandes, con `serde_json::value::RawValue` o con un deserializador que solo materializa
  los campos que las reglas consultan. La medición compara asignaciones y latencia con un cuerpo
  de 10 KB y otro de 5 MB.
- **Enums como lenguaje de reglas.** El *matcher* es un árbol (`All`, `Any`, `Not`, `Absent`,
  `Null`, `Eq`, `Regex`) evaluado con `match`. Es el sitio natural para aprender *pattern matching*
  exhaustivo, y la diferencia con una jerarquía de clases de Java se ve de inmediato.
- **Estado compartido que se recarga.** Las reglas se reemplazan sin reiniciar: `Arc` con
  `arc-swap` o `RwLock`, y la discusión de por qué `Arc<Mutex<T>>` no es un campo `synchronized`.
- **Plantillas en la respuesta** (`minijinja` o similar) con acceso al cuerpo, los encabezados y
  los parámetros de la ruta.

### 2.3 Evolución natural

Primero reglas estáticas, después plantillas, después estado entre peticiones ("el segundo `GET`
devuelve lo que creó el `POST`"), después validación contra un contrato OpenAPI. El modo de
grabación y reproducción ya está pensado como idea en Go (`ideas-proyectos-go.md`, idea 22); aquí
queda como extensión opcional.

### 2.4 El competidor

**WireMock**, que ya permite coincidencias con JSONPath (`matchesJsonPath`) y respuestas con
plantillas. La regla de "400 si `name` es nulo o no viene" se puede escribir hoy en WireMock. El
diferencial es tuyo: un formato de reglas a tu medida, un binario sin JVM y la fidelidad de la
latencia. La medición del proyecto: la misma batería de reglas en los dos, con arranque, RSS y la
desviación de la latencia configurada.

---

## 3. 💳 Proyecto 2 — el simulador de pasarela de pago

### 3.1 Qué hace

Una pasarela falsa pero **estadísticamente creíble** y **genérica**: no imita la API de ninguna
pasarela concreta. Sirve de contraparte en proyectos de prueba que necesiten "una pasarela"
sin depender de un *sandbox* real, que además suele ser demasiado amable.

- **Autorización, captura, anulación y reembolso**, con claves de idempotencia. Si se reintenta con
  la misma clave, la respuesta tiene que ser la misma, y ese es el error que más cuesta en
  producción.
- **Probabilidad de fallo configurable** por tipo: rechazo del emisor, fondos insuficientes, tarjeta
  vencida, emisor no disponible, *timeout*. Los códigos siguen la convención de respuesta de ISO
  8583 (`05`, `51`, `54`, `91`…), que es la que el alumno va a ver en una pasarela real.
- **Escenarios deterministas por dato mágico**, al estilo de las tarjetas de prueba: un PAN o un
  monto concreto fuerza un resultado, para que las pruebas automáticas no dependan del azar.
- **Fraude.** Un puntaje por transacción con reglas simples (velocidad por tarjeta, país del BIN
  distinto al de la IP, montos redondos) y una tasa base configurable.
- **Consulta de BIN.** Validación de Luhn local, y marca, tipo y país del emisor a partir de los
  primeros 6 u 8 dígitos. Primero contra una tabla local de rangos; después, opcionalmente,
  contra un servidor de BIN externo con caché y *circuit breaker*, porque un servicio externo que
  se cae es justo lo que la pasarela real te va a hacer.
- **Tiempos de respuesta con distribución elegida:** fija, uniforme, normal, **log-normal** (la
  más realista para latencias de red) y colas pesadas (Pareto), con picos ocasionales. Todo con
  **semilla**, para que una corrida se pueda reproducir.
- **Webhooks asíncronos** con retraso, reintentos y, a propósito, entregas duplicadas y fuera de
  orden.

### 3.2 Lo que enseña de Rust

- `rand` y `rand_distr`, y el tipado de una configuración de distribuciones como `enum`.
- Tokio de verdad: temporizadores, tareas en segundo plano para los webhooks, cancelación, y el
  🪞 de *"`sleep` en un handler bloquea el hilo"*, que en Tokio es cierto solo si usas el `sleep`
  equivocado.
- Un cliente HTTP con *timeout*, reintento y caché para el servidor de BIN.
- Una máquina de estados de la transacción (`Authorized → Captured → Refunded`) con *typestate* o
  con un `enum`, según se decida. Capturar dos veces **no compila** o devuelve un error explícito.

### 3.3 El competidor

Los *sandbox* de las pasarelas reales y el propio servidor de mocks del proyecto 1. La medición:
¿la distribución observada desde un cliente bajo carga se parece a la configurada? Histograma
contra histograma, con un umbral de desviación declarado de antemano.

> ⚠️ **Nada de datos reales de tarjetas.** Solo PAN de prueba y rangos BIN públicos. El simulador
> no debe aceptar nunca un número que parezca real sin marcarlo, y eso va en los criterios de
> aceptación.

---

## 4. ⌨️ Los CLIs que acompañan a los dos servicios

Los dos servicios se prueban y se alimentan con herramientas de línea de comandos, y esas
herramientas son las que más directamente muestran dónde gana Rust:

**`cardgen` — generador de datos de prueba** 🟢. PAN de prueba válidos por Luhn, por marca y por
rango BIN, más clientes y montos, en CSV o JSON. Es el primer CLI del curso: `clap`, iteradores,
salida con *streaming*, y la primera medición de arranque contra el mismo programa en Java y en
native-image.

**`logq` — filtro de logs en JSON por líneas** 🟡. Consulta archivos de varios GB con el **mismo
árbol de predicados que usa el mock** (`absent`, `null`, `eq`, `regex`), sin cargar el archivo en
memoria. Es el sitio natural para `&str` frente a `String`, lectura con búfer y `mmap`, con `jq`
como competidor.

**`loadgen` — generador de carga con histograma** 🟠. Dispara peticiones contra el mock o la
pasarela con una concurrencia fija y dibuja el histograma de latencia observada (HdrHistogram). Es
la herramienta que **verifica la hipótesis del curso**: sin ella no hay forma de saber si la
distribución que devuelve el simulador se parece a la configurada.

Además, los propios servicios tienen su cara de CLI: `mockd check rules/` valida las reglas sin
levantar el servidor y devuelve un código de salida útil en CI.

---

## 5. 🏗️ Cómo se relacionan: un workspace, cinco binarios

La propuesta es un **workspace de Cargo** con un núcleo compartido:

```
tools/
├── toolcore/        # predicados sobre JSON, plantillas, distribuciones de latencia, Luhn y BIN
├── cardgen/         # CLI: datos de prueba
├── logq/            # CLI: filtro de logs con los mismos predicados
├── mockd/           # servicio: el servidor de mocks genérico
├── paysim/          # servicio: el simulador de pasarela, sobre toolcore
└── loadgen/         # CLI: carga e histograma, el que verifica a los otros dos
```

El orden recomendado va de lo simple a lo concurrente: primero un CLI sin estado (`cardgen`),
después uno que procesa volumen (`logq`), después el mock, la pasarela, y al final `loadgen`, que
necesita a los dos para tener sentido. El núcleo compartido evita que la lógica genérica quede
enterrada en código de pagos.

---

## 6. 📐 Forma: ¿apéndice, ruta corta o bloque?

Hay tres opciones, y la recomendación es la segunda:

1. **Apéndice de otro curso.** No hay dónde colgarlo: no existe un curso de Rust, y ponerlo en el
   de Go obligaría a justificar dos lenguajes en un solo curso.
2. **Ruta corta propia (recomendada)**: *"Rust para utilitarios y CLIs"*, de 12 a 13 fases, con
   las cinco herramientas como hilo. Rust aprendido en su terreno cómodo, con resultado utilizable desde la
   primera mitad.
3. **Bloque del curso grande** de `ideas-rust.md`, como el bloque de herramientas. Tiene sentido si
   ese curso llega a promoverse; la ruta corta puede convertirse en ese bloque sin reescribirse.

Esbozo de la ruta corta:

| Fase | Contenido | Proyecto |
|---|---|---|
| 00 | Ambiente, Cargo, workspace, arnés de medición | — |
| 01 | El primer CLI: `clap`, propiedad sin sufrirla, códigos de salida | cardgen |
| 02 | 🥊 Primer duelo: arranque contra Java y native-image | cardgen |
| 03 | Volumen: iteradores, `&str` frente a `String`, lectura con búfer | logq |
| 04 | Enums, `match` y el árbol de predicados | toolcore, logq |
| 05 | `serde` y `Value`: ausente frente a `null` | toolcore |
| 06 | Axum y Tokio: el servidor mínimo | mock |
| 07 | Estado compartido y recarga en caliente | mock |
| 08 | Distribuciones, semillas y control del tiempo | toolcore |
| 09 | Máquina de estados, idempotencia y BIN externo | pasarela |
| 10 | Webhooks, reintentos y el caos a propósito | pasarela |
| 11 | Concurrencia medida: carga e histograma | loadgen |
| 12 | Distribución: compilación cruzada, binario estático, *releases* | todos |
| 13 | 🥊 Duelo con WireMock, `jq`, native-image y Go, y ⚖️ veredicto | todos |

---

## 7. 🧵 Preguntas abiertas

1. ¿El formato de reglas es YAML, TOML o un DSL propio? Un DSL es más divertido y más caro.
2. ¿El servidor de BIN externo es uno público, o un tercer binario mínimo del propio workspace?
   El segundo evita depender de una API ajena en los ejercicios.
3. ¿Se exponen métricas (Prometheus) desde el principio, o basta con el histograma de `loadgen`?
4. ¿El duelo contra Go usa el código del curso de Go, o se escribe aparte? Reutilizar abarata, pero
   ata esta ruta a aquel curso.
