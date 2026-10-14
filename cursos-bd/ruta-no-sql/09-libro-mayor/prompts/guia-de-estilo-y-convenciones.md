# ✍️ Guía de estilo, tono y convenciones
## Libro Mayor — el modelo NewSQL distribuido a fondo

> **Qué es este documento:** la fuente de verdad editorial del curso: **cómo** se escribe. Cualquier sesión que
> produzca un `.md` de Libro Mayor la sigue, para que todas las fases se lean como escritas por la misma mano y
> apunten al mismo sitio: **que el lector decida cuándo una invariante de dinero merece una transacción entre
> regiones, qué le cuesta, y lo defienda con números propios.**
> **Vigencia:** 2026-10-07. **Cerrada salvo lo que depende de la propuesta de fases**: la plantilla rígida de
> fase (§6.2) y las longitudes (§9), que se fijan con ella (§15).
> **Herencia:** se escribió con la guía de Ruta NoSQL Lite y las de los cursos anteriores de la ruta como
> modelo, porque es la misma ruta y el lector viene de lite. Diverge de lite en: un solo dominio y una sola
> familia, una sola plantilla de fase, Mermaid, la profundidad full geek, **el dinero contra el libro como
> primera medida**, y que aquí **el tiempo es argumento**, porque la distancia entre regiones es física. La guía
> de agosto (`_desechable-guia-de-estilo-v1.md`) queda de consulta.
> **Precedencia.** Por encima solo está [`alcance-del-proyecto.md`](alcance-del-proyecto.md). Por debajo van el
> contrato de nombres, el diccionario, las propuestas, las plantillas y los prompts. El `CLAUDE.md` del
> repositorio aplica en todo lo que este curso no haya declarado como excepción (§13).

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes tiene que explicarle a
un directorio por qué la próxima caída de una región no va a dejar dinero en ninguna parte.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio dónde vive cada fila de un libro, qué
invariantes se cumplen entre filas lejanas y a qué costo, y lo pueda defender con números propios, incluido lo que
hacen el consenso y el reloj por dentro.**

No enseñamos CockroachDB como producto ni formamos administradores de bases distribuidas. Formamos la capacidad de
mirar una invariante, preguntar entre qué filas y a qué distancia tiene que cumplirse, elegir entre cumplirla con
una transacción, coordinarla con mensajes o no distribuir, medir lo que cada opción pierde cuando algo falla, y
saber cuándo un nodo alcanzaba.

El filtro para cada párrafo: **¿esto ayuda a modelar, a medir, a diagnosticar o a decidir?** Si no, sobra.

> 🧠 **Primero el cuadre, después la latencia.** En este modelo el primer número es si el libro cuadra después de
> la falla; el segundo, cuánto tarda cada confirmación según la distancia. Por eso un tiempo nunca se publica sin
> las regiones, la latencia entre ellas, la meta de supervivencia y la contención al lado, y una falla nunca se
> publica sin el dinero contra el libro.

### 1.1 Qué NO es este curso

No es un curso de SQL distribuido desde cero, ni de CockroachDB como producto, ni de finanzas, ni de regulación. No
repite Ruta NoSQL Lite: lo que lite enseñó de NewSQL se **usa** sin volver a explicarlo.

### 1.2 Requisitos y autocontención

Lo publicado nombra Ruta NoSQL Lite **solo como requisito de entrada**, en el README y en la primera fase. **No usa
su contenido**: no remite a sus fases, no reutiliza sus ejemplos, sus datos ni sus mediciones; si el curso necesita
algo que lite enseñó, lo da por sabido o lo dice con sus propias palabras y con Kambio (D-03). Ningún documento
publicado cita otros cursos de la ruta ni el `CLAUDE.md` del repositorio.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien: un colega que estuvo de guardia el día que se cayó
Virginia y te lo cuenta con paciencia.

- **Tuteo latinoamericano, siempre.** *"Corta Virginia a mitad de cien cambios de moneda y cuadra el libro antes
  de volverla a encender"*. Nada de voseo, nada de "usted", nada de impersonal permanente.
- **Semiformal.** Frases completas, cero abreviaturas de mensajería.
- **Humor seco y con moderación.** Máximo un chiste por sección; el blanco es la situación (la wiki de 2021 con el
  servidor que ya no existía), nunca una persona.
- **Cálido sin condescendencia.** El lector es senior y ya hizo lite.
- **Honesto sobre lo feo.** Si PostgreSQL gana un país, si una saga bien escrita alcanza, si un motor no cumple lo
  que promete su documentación, se dice con esas palabras y con el número delante.
- **Sobrio con el dinero.** El curso usa dinero sintético y nunca presenta su diseño como cumplimiento de una
  regulación real.

### 2.1 El tono de las autopsias

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. El nodo con réplica lo puso Federico, y
sostuvo Kambio cuatro años; las sagas las puso Thiago, con aval de Federico, y abrieron Europa y Brasil. Si un
párrafo suena a *"quien partió el libro en tres no sabía"*, el curso pierde a su mejor personaje y al lector que
hizo algo parecido.

Se escribe en este orden: la decisión con su mejor argumento; por qué era razonable entonces; qué pasó después, con
número; cuánto cuesta salir, con número; qué pregunta, hecha a tiempo, habría cambiado el resultado. Lo que nunca
aparece: "obviamente", "cualquiera habría visto", "error de novato".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro** para todo lo que no sea código o salida de terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *Raft*, *leader*,
  *leaseholder*, *lease transfer*, *closed timestamp*, *range*, *tablet*, *split*, *hybrid logical clock*,
  *uncertainty interval*, *max offset*, *parallel commits*, *write intent*, *transaction record*, *follower read*,
  *bounded staleness*, *`AS OF SYSTEM TIME`*, *`REGIONAL BY ROW`*, *global table*, *survival goal*,
  *hash-sharded index*, *hot range*, *saga*, *compensation*, *RPO*, *RTO*, *Percolator*, *TSO*, *DocDB*. Los que
  tienen traducción asentada —consenso, réplica, líder, arrendamiento, confirmación, reintento, aislamiento,
  conmutación, región, zona, asiento, partida doble— se alternan con naturalidad. **No se inventa vocabulario.**
- **"Confirmar"** es el `COMMIT`; **"confirmada"**, una transacción que el cliente vio como hecha.
- **Markdown siempre**, sin HTML embebido. **Prosa antes que listas.** Una frase aislada por sección, dos si es
  larga.
- **Tablas solo para lo tabular y corto**: comparación de motores, resultados por topología, la traducción del DDL
  entre motores.
- **Diagramas en Mermaid** (D-12): las tres regiones, la secuencia de una confirmación con sus idas y vueltas, la
  saga con su compensación, los rangos y sus líderes. Árboles de archivos y salidas en `text`.
- **Salida de terminal literal**, en `text`, sin recortar la parte incómoda (sobre todo el error de reintento de
  serialización, el de incertidumbre y el del nodo que no responde).
- **Encabezados con emoji, con moderación.**

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior, relacional de oficio y ya pasó por lite: **no explicar lo que ya sabe, y no dejar ambiguo nada
de lo que no.**

### 4.1 La regla del andamio

1. **El problema primero**, siempre en Kambio: *"Una diseñadora de Lisboa le paga a un desarrollador de Bogotá. Su
   cuenta vive en Fráncfort; la de él, en Virginia; la tesorería del par, en Virginia. ¿Cuántas idas y vueltas de
   80 ms va a costar la confirmación? Apúntalo antes de ejecutar."*
2. **El mecanismo después**: el nombre y la definición mínima.
3. **La consulta o el comando que corre**, con su salida real y la línea que importa señalada.

### 4.2 Del instinto se parte, no se reniega

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios del relacional: la partida doble dentro de una
  transacción, las restricciones declaradas, el plan se lee, la copia no es un respaldo hasta que se restaura.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"** — el relacional (*"un `COMMIT` cuesta lo mismo en cualquier
  fila"*), el de la conferencia (*"distribuido significa que no se cae"*) o el que lite dejó demasiado firme (*"si
  la fila vive en su región, la confirmación es local"*). **Una por fase como mínimo.**
- ⚖️ **"Y aquí el instinto SQL tenía razón"** — las preguntas donde el veredicto va en la otra dirección: el país
  que cabe en un nodo, la réplica síncrona en la misma región, la saga que de verdad cruza organizaciones. Sin este
  recuadro el curso sonaría a folleto.

### 4.3 Nada de cajas negras prematuras

Primero `psql` o el cliente SQL del motor, con la transacción a pelo; después la API. Primero el `EXPLAIN ANALYZE`
distribuido y las tablas internas de rangos y líderes; después el panel que los dibuja. Si se habla de una
confirmación, se muestran sus idas y vueltas.

### 4.4 Analogías, con fecha de caducidad

Una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del curso: **"es
PostgreSQL con más nodos"**. Se desmonta en el mismo párrafo: habla el mismo protocolo, pero cada confirmación pasa
por un consenso, cada lectura depende de un arrendamiento, y el reloj puede obligar a reintentar una transacción que
en PostgreSQL nunca chocaría.

### 4.5 Explica el porqué

Cada decisión lleva su porqué: por qué esta fila en esta región, por qué esta meta de supervivencia, por qué la
tesorería en diez filas, por qué este motor para este país.

### 4.6 Densidad calibrada

Un concepto nuevo por vez. Ninguna sección teórica supera las dos pantallas sin una consulta, una medición o un
diagrama. Reaparecen con otras palabras: la pregunta del curso, "el falso dilema", "el cuadre primero" y "la
distancia es física".

### 4.7 Cierra los bucles

Todo paréntesis abierto —*"esto lo pagamos en el bloque de las fallas"*, *"deuda 💸"*— se cierra.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —archivos, rutas, variables,
> identificadores, tablas, columnas, regiones— y **todos los comentarios van en español con tildes**. Lo que ve un
> cliente o tesorería va en español.

- **Código ejecutable y mínimo**, que corre de punta a punta con las versiones fijadas.
- **Comentarios que explican el porqué**: `// la tesorería se reparte en diez filas: una sola serializa todos los
  cambios` sí; `// actualiza saldo` no.
- **Bloques con su lenguaje declarado**: `ts`, `sql`, `bash`, `yaml`, `text`.
- **Un bloque, una idea.** **Nunca `foo`, `bar`, `acc1` ni `test1`**: todo usa Kambio.
- **SQL siempre con parámetros**, y **toda transacción con su bucle de reintento** escrito, nunca supuesto.
- **El dinero nunca en punto flotante**: `DECIMAL` en el esquema y enteros en unidades menores en TypeScript.

### 5.1 Versiones fijadas

**Digest para las imágenes y archivo de bloqueo para las librerías**, con la versión legible en un comentario.
**Ninguna versión se escribe de memoria**, y hasta la verificación previa ningún documento publica un número de
versión (§15). **Lo no verificado se dice con esas palabras**: si una imagen no corre nativa en arm64 y se midió
emulada, la medición lo dice; si una función de ubicación o de supervivencia no existe en uno de los motores, se
dice cuál y desde qué versión.

### 5.2 Los nombres del dominio

Fijos en todo el curso y en inglés. Hasta que exista el contrato de nombres, estos son los vigentes:

| En la narrativa | Tabla | Columnas clave |
|---|---|---|
| cliente | `customers` | `customer_id`, `home_region` |
| cuenta | `accounts` | `account_id`, `customer_id`, `currency`, `home_region`, `min_balance` |
| operación | `transfers` | `transfer_id`, `kind` (`payment`, `fx`, `withdrawal`, `fee`), `created_at` |
| asiento | `postings` | `posting_id`, `transfer_id`, `account_id`, `amount`, `currency` |
| tesorería, comisiones | `accounts` internas, con `kind` | `treasury_usd_eur`, `fees_us`… |
| tipo de cambio cotizado | `fx_quotes` | `quote_id`, `pair`, `rate`, `expires_at` |
| retiro | `withdrawals` | `withdrawal_id`, `transfer_id`, `bank_status` |
| saga (villano) | `saga_steps`, `outbox` | `saga_id`, `step`, `status` |
| región | `us`, `eu`, `br` | — |

**Tablas y columnas en `snake_case`** en todos los motores; tipos y variables de TypeScript en `camelCase` y
`PascalCase`. Una fase no renombra una tabla: si necesita una nueva, la declara y se agrega aquí y en la historia.

### 5.3 El villano también va en inglés

El código del villano se nombra como estaba en Kambio: la conmutación `failover-runbook.md` de la wiki, el
orquestador `sagaOrchestrator.ts` con `compensate()` y `retryStep()`, y la conciliación `nightlyReconcile.ts`. Su
olor es **de arquitectura**: una invariante de dinero coordinada con mensajes entre bases que no se ven, y una
confirmación al cliente que la réplica todavía no tiene.

### 5.4 Nombres de archivo del curso

Fases `NN-slug.md`; apéndices `aNN-slug.md`; la historia `00-historia-de-kambio.md`; documentos vivos en la raíz
(§7). Minúsculas y guiones, salvo `README.md`, `INSTINTOS.md` y `BENCHMARKS.md`.

---

## 6. 🧱 La plantilla de los documentos

> 🚧 **Preliminar:** la plantilla rígida de fase se fija con la propuesta de fases. Punto de partida, el mismo de
> los cursos anteriores de la ruta: una sola plantilla que modela **y** mide.

### 6.1 Encabezado obligatorio de fase

```markdown
# 💱 Fase 08 — La cuenta de tesorería

> **Curso:** Libro Mayor · Fase 08 de NN · Bloque II · **10 h**
> **Motor:** CockroachDB `cockroach@sha256:…` · **Testigo:** PostgreSQL `postgres@sha256:…`
> **Rivales en esta fase:** {{YugabyteDB · TiDB · PostgreSQL con sagas · ninguno}}
> **Topología:** {{regiones, nodos por región, latencia, meta de supervivencia}}
> **Depende de:** Fase 07 · **Habilita:** Fase 09
> **Fecha de verificación ejecutada:** DD/MM/AAAA
> **Objetivo:** …
```

El título nombra el dolor de Kambio, no la función del motor.

### 6.2 Secciones de una fase (punto de partida)

1. Título y encabezado
2. 🧭 **Dónde estamos** — qué dejó la fase anterior, y el dolor de Kambio que abre esta
3. 🎯 **Objetivos**, verificables
4. 🚫 **Qué NO entra todavía**, con destino
5. 🧩 **El modelo** — la invariante, entre qué filas y a qué distancia, el esquema y la transacción en cada motor
6. 🪞 **La apuesta**, escrita antes de medir
7. 📐 **La medición**: el dinero contra el libro, la forma y el tiempo, por topología
8. 💥 **El punto de rotura**, con volumen y mensaje literal
9. ⚖️ **Veredicto honesto: cuándo NO hacer esto**
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable
12. 🧪 **Ejercicios** (§8)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

Después, fuera de lo que lee el estudiante, puede ir **📌 Pendientes sugeridos**.

### 6.3 Cómo se presenta una medición

**Toda medición se publica con cinco datos**: qué se midió (el dinero contra el libro y la forma primero), sobre qué
topología y qué carga, con qué motor, digest y configuración frente a qué alternativa, en qué máquina, y el comando
exacto para reproducirla. **Siempre con regiones, latencia, meta de supervivencia y contención.**

```markdown
> 📐 **Medición — la caída de Virginia** · 3 regiones (80/120/160 ms), 1 nodo por región, 1.000 operaciones en curso ·
> `cockroach@sha256:…` frente a PostgreSQL con réplica y a tres PostgreSQL con sagas · verificado el DD/MM/AAAA ·
> {{máquina}}
>
> | arquitectura | confirmadas perdidas | en el limbo (máx.) | dobles créditos | tiempo hasta volver | p50 | p95 | p99 |
> |---|---|---|---|---|---|---|---|
> | PostgreSQL + réplica asíncrona | … | — | … | … | … | … | … |
> | tres PostgreSQL + sagas | … | … | … | … | … | … | … |
> | CockroachDB, supervivencia de región | … | … | … | … | … | … | … |
>
> Reproducir: `node scripts/measure.ts region-loss --region us --ops 1000`
```

**Los tiempos van con su dispersión** (mediana, p95 y p99, repeticiones y calentamiento declarados) y la máquina;
aquí sostienen veredictos sobre la distancia, **nunca sobre la velocidad del hardware** (D-19). Los costos de los
gestionados llevan ☁️, la fuente y la fecha (D-22). La 🪞 apuesta se escribe antes y no se edita.

---

## 7. 📐 Los tipos de documento y su coherencia

- **Fases**, **apéndices** y la **historia**, documento del lector y fuente de verdad narrativa: ningún dato de
  Kambio se inventa en una fase.
- **Documentos vivos** en la raíz, que son producto: `INSTINTOS.md` (cada 🪞 con su medición), **`BENCHMARKS.md`**
  (toda medición publicada, con los cinco datos de §6.3) y el catálogo de errores con su mensaje literal (si es
  apéndice o documento aparte, lo dice la propuesta de apéndices).
- **Los apéndices no repiten una fase, y viceversa: se enlazan.** **Una fase no cita el temario ni el plan.** 🗑️ **Los
  `_desechable-*` no se citan nunca.**
- **Git:** tags `fase-NN-<slug>`, prefijo de commit `fNN:`, ejercicios `fNN ejM: …` (D-09).

---

## 8. 🧪 Evaluación: ejercicios

- **Cantidad: 20 mínimo y 30 máximo por fase**, calibrada con *"¿cuántas cosas distintas enseña esta fase que se
  puedan comprobar por separado?"*.
- **La escala:** 🟢 reproducir · 🟡 aplicar el patrón a otra operación de Kambio · 🟠 combinar, diagnosticar,
  decidir · 🔴 abierto o adversarial · 🔥 extra, fuera del mínimo.
- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen; los bloques de fallas y de motores cargan hacia
  🟠 y 🔴.
- **Al menos un tercio de diagnóstico o medición**: una transacción sin bucle de reintento, una clave secuencial
  caliente, una fila fuera de su región, una compensación que se cruza con un reintento, un reloj que se va; se pide
  reproducir, medir y explicar.
- **Predecir antes de ejecutar** en 🟠 y 🔴. **Cada ejercicio cierra con su criterio** (`Objetivo` o `Pregunta`), y
  si toca dinero, con el libro cuadrado. **Agrupados por dificultad**, con el conteo en el título.
- **Sin solución publicada** (D-05). **Taller global:** el libro en `src/`.
- **💀 Boss de bloque**, cuando el bloque lo admita: un libro descuadrado o un encargo completo de alguien de Kambio
  (con nombre, de la historia §2), que cruza al menos dos fases y se entrega como artefacto.

---

## 9. 📏 Longitud y densidad

> 🚧 **Preliminar**, a fijar con la propuesta de fases. Punto de partida para una fase de 10 h: **4.000–5.000
> palabras de cuerpo**, contadas hasta el encabezado de 🧪 Ejercicios. Los apéndices son cortos, con índice de salto
> rápido, una tabla de "cuándo usar qué" y de 5 a 10 ejercicios de consulta.

---

## 10. 📚 Referencias y enlaces

### 10.1 Enlaces externos

**Orden de prioridad:** documentación oficial de la versión que usamos (CockroachDB, YugabyteDB, TiDB, PostgreSQL,
Toxiproxy); después los papers de base (Raft, Spanner, Percolator, relojes lógicos híbridos, sagas) y los textos de
arquitectura de cada motor; después libros; después blogs y videos, con escepticismo explícito ante las
comparativas de parte interesada. **Siempre se advierte cuando un enlace apunta a otra versión**, y con las
licencias y los precios se cita la fecha. Cada URL se comprueba por código de estado en la sesión que la escribe.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: antes de ejecutar, durante y después.

### 10.2 Enlaces internos y anclas

Rutas relativas; anclas comprobadas; **ningún enlace a un documento que todavía no existe**.

### 10.3 Vigencia

Las secciones de referencias advierten que las URL y los contenidos cambian, que esta familia publica versiones
mayores a menudo, y que las licencias y los precios cambian: se cita la fecha.

---

## 11. 🧷 Vocabulario visual

**Marcadores de estado:** 💸 deuda intencional (con fase de pago) · 🔥 opcional · 🚧 fuera de alcance por ahora, con
destino · ☁️ tomado de documentación, no medido · 🟢🟡🟠🔴 dificultad · ⭐ valoración bibliográfica, solo en
referencias.

**Callouts en blockquote:** 📐 **Medición** (§6.3) · 🪞 **Apuesta / instinto que falla** · 💥 **Punto de rotura** · ⚰️
**Autopsia** · ⚖️ **Veredicto honesto** y **"Y aquí el instinto SQL tenía razón"** · 🩻 **Esto sí funciona igual** ·
📖 **Traducción** del DDL y del SQL entre motores, en tabla · 🧠 **Modelo mental** · ⚠️ **Advertencia** · 📝 **Nota de
contexto** (licencias, papers, historia de un proyecto) · 💡 **Truco** · 🩺 **Diagnóstico**, la consulta o la tabla
interna que confirma o descarta una hipótesis.

**Secciones narrativas recurrentes:** *Dónde estamos* · *Detalles con intención* · *El patrón a memorizar* · *Prueba
de fuego* · *La señal de que quedó bien*.

---

## 12. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El encabezado está completo, con motor, digest, rivales, topología y fecha de verificación
[ ] La fase abre con un dolor de Kambio que está en la historia
[ ] Ningún dato de la empresa se inventó en la fase (si hacía falta, se agregó a la historia)
[ ] Nada de lo que Ruta NoSQL Lite ya enseñó se explicó de nuevo; ninguna remisión a sus fases
[ ] Todo número salió de una ejecución real; lo emulado o no verificado está declarado
[ ] Toda medición trae los cinco datos de §6.3, con regiones, latencia, supervivencia y contención
[ ] Toda falla trae el dinero contra el libro: confirmadas perdidas, limbo, dobles créditos
[ ] PostgreSQL y las sagas jugaron bien escritos, no como hombres de paja
[ ] Toda transacción del código tiene su bucle de reintento; el dinero nunca va en punto flotante
[ ] Las licencias y los costos de la nube llevan fecha, y los costos, ☁️ y fuente
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] Hay un ⚖️ veredicto con la pérdida cuantificada
[ ] Ninguna autopsia juzga a una persona; nada se presenta como cumplimiento regulatorio real
[ ] Las mediciones, los errores y el 🪞 entraron en sus documentos vivos
[ ] Ejercicios: 20–30, agrupados, con conteo, un tercio de diagnóstico, cada uno con Objetivo o Pregunta
[ ] Los diagramas están en Mermaid; los árboles y salidas, en text
[ ] Tuteo en todo el documento; cero voseo, cero "usted"
[ ] Código en inglés, comentarios en español con tildes; SQL con parámetros
[ ] Ningún enlace a un documento que no existe; grep -ln "_desechable-" *.md no devuelve nada
```

---

## 13. ⚖️ Excepciones declaradas

1. **Ruta NoSQL Lite como prerrequisito** (D-14) → no se explican los fundamentos de NewSQL → los da lite, y
   repetirlos sería el curso que el lector ya hizo.
2. **Los ejercicios no traen solución publicada** (D-05) → el método del curso es apostar y medir antes de mirar, y
   cada ejercicio trae su criterio.

Todo lo demás del `CLAUDE.md` aplica tal cual.

---

## 14. 🧪 Laboratorio

- **Docker Compose es el camino principal**; cada receta trae su equivalente en Podman. **Aquí no se enseña Docker.
  Sin Kubernetes.**
- **Perfiles de Compose** para no pasar de 16 GB: **una arquitectura a la vez**; un nodo por región por defecto
  (D-20).
- **La topología canónica** (D-26) se fija en el apéndice del laboratorio y todas las mediciones la usan, salvo que
  la fase diga lo contrario.
- **Cada motor con su configuración documentada**, nunca con la de otro. Si una imagen no corre nativa en arm64, se
  declara (D-29).
- **Servicios nombrados por región** (`us-1`, `eu-1`, `br-1`), para que cambiar de motor no rompa los comandos
  escritos.
- **Las regiones, sus latencias y sus caídas son una simulación**, y se dice (D-27).
- **Datos sintéticos con semilla fija** y el saldo verdadero de cada cuenta (D-21, D-31).
- **Las pruebas de la producción** corren en contenedores etiquetados con el curso y en puertos altos aleatorios; el
  código de las sesiones va a `zz-code/` con su README.

---

## 15. 📌 Pendientes que afectan a esta guía

- **La plantilla rígida de fase (§6.2) y las longitudes (§9)** se fijan con la propuesta de fases. Todas las
  decisiones del alcance están cerradas (07/10/2026).
- **El diccionario de términos y el contrato de nombres** se escriben después de la propuesta de fases; hasta
  entonces mandan §3 y §5.2.
- **Versiones, digests y licencias sin fijar** hasta la verificación previa (D-24); lo mismo si TiDB cabe con su
  topología mínima (D-20) y si cada motor permite provocar el desfase de reloj en contenedor (D-36).
- **El recorte contra lite** se revisa cuando sus fases 21 y 22 estén escritas.
- **El verificador del curso** se copia de `zz-instrucciones/herramientas/` y se ajusta cuando la plantilla de fase
  esté fijada.
