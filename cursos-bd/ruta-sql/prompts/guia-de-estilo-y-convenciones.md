# ✍️ Guía de estilo, tono y convenciones
## Ruta SQL — La base que nadie diseñó

Esta guía es la fuente de verdad editorial del curso. Cualquier sesión que produzca un `.md` de
este proyecto la sigue. Su objetivo es que las veintisiete fases, los diez apéndices y el track
de SQL Server se lean como escritos por la misma mano, y que todos apunten al mismo sitio: **que
el lector mire una base de datos como un problema de optimalidad con tradeoffs y pueda defender
cada decisión con una medición propia**.

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes tiene
que explicarle a su equipo por qué ese `UUID` como clave primaria en MySQL no fue gratis.

> **Precedencia.** Por encima de esta guía solo está
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que decide **qué** enseña el curso; esta
> decide **cómo** se escribe. Por debajo van las dos propuestas de alcance, las plantillas y los
> prompts, que se actualizan después y nunca al revés. El `CLAUDE.md` del repositorio aplica en
> todo lo que este curso no haya declarado como excepción (§17).
>
> **Derivada de** la guía de la Ruta NoSQL Lite (30/09/2026). Lo que se hereda sin cambios se
> hereda en silencio; lo que cambia está en §6 (la regla de publicación), §5 (el esquema `legacy`
> y el estilo de SQL), §9 (longitudes por horas) y §17.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio y lo pueda defender con números
propios.**

No enseñamos productos ni formamos DBA. Formamos la capacidad de mirar un esquema, reconocer qué
reglas defiende y cuáles deja en manos de un parser, qué cuesta cada índice y qué anomalía deja
pasar cada nivel de aislamiento, y medir la diferencia entre dos diseños.

El filtro para cada párrafo es este: **¿esto ayuda a modelar, a medir, a diagnosticar o a
decidir?** Si no, sobra, aunque esté muy bien escrito. Sobre todo si está muy bien escrito.

> 🧠 **Se mide la forma, no la velocidad.** Ningún veredicto de este curso se sostiene sobre un
> milisegundo.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien. Un colega que ya pagó esta factura y
te la explica con paciencia, sin solemnidad de manual y sin palmaditas en la espalda.

- **Tuteo latinoamericano, siempre.** *"Corre el `EXPLAIN` y mira cuántos bloques leyó"*. Nada de
  voseo (*"fijate"*, *"corré"*), nada de "usted" y nada de impersonal permanente. **Esto vale
  también para los personajes**: la historia pasa en Córdoba, pero Norma, Matías y Rubén hablan en
  el español neutro del curso. Lo que tienen de argentino es el vocabulario del negocio (obra
  social, protocolo, nomenclador, débito), que se conserva y se traduce en `a07`.
- **Semiformal.** Frases completas, puntuación correcta, cero abreviaturas de mensajería. Un "ojo
  con esto" sí; un "che" no.
- **Humor seco y con moderación**, máximo un chiste por sección. El que sale solo en este curso es
  el de los nombres de tabla (`Resultados NUEVA`, `Pacientes copia`). Úsalo con cariño: esas tablas
  sostuvieron un negocio.
- **Cálido sin condescendencia.** El lector es senior y sabe qué es un índice. Lo que se le explica
  con cero ambigüedad es lo que ese índice **cuesta**.
- **Honesto sobre lo feo.** Si el diseño que el curso propone pierde contra el de Florencia en la
  lectura del informe, se dice con esas palabras y con el número delante.

### 2.1 El tono de las autopsias, que es el punto más delicado del curso

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. En este curso el riesgo
es doble, porque **las decisiones tienen autor con nombre**: Rubén escribió el parser, Matías hizo
el EAV, la agencia puso el MD5. Si un párrafo suena a *"Rubén no sabía lo que hacía"*, pierdes al
lector que hizo exactamente lo mismo en 2009, y además traicionas la historia, que existe para
mostrar que cada tabla rara tuvo una razón correcta el año en que se creó.

La versión que funciona **defiende el argumento antes de desmontarlo**, en este orden:

1. La decisión, en la voz de quien la tomó y con su mejor argumento.
2. Por qué era razonable **en ese momento**, con esa información y con esas herramientas.
3. Qué pasó después, con número.
4. Cuánto costó salir, o cuánto va a costar, con número.
5. Cuál de las cinco preguntas, o qué restricción del modelo, habría cambiado el resultado.

Lo que nunca aparece: "obviamente", "cualquiera habría visto", "error de novato", "mala
práctica" a secas, ni ninguna variante de la misma superioridad.

**Las dos propuestas rivales se tratan igual.** Florencia y Verónica no son hombres de paja. Cada
fase que las toca presenta su mejor argumento antes que el del curso, y **les concede con número**
lo que tienen de razón.

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro**, técnico y claro, para todo lo que no sea código o salida de
  terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *page
  split*, *fillfactor*, *heap*, *clustered index*, *write skew*, *lost update*, *phantom read*,
  *deadlock*, *snapshot isolation*, *bloat*, *vacuum*, *undo*, *redo*, *outbox*, *upsert*,
  *keyset pagination*, *parameter sniffing*. Los que tienen traducción asentada (índice, consulta,
  plan, bloqueo, aislamiento, particionado, clave foránea) se usan en español. Lo importante es
  **no inventar vocabulario**.
- **Los términos del negocio se quedan en el español de Alameda**: protocolo, obra social,
  nomenclador, práctica, determinación, débito, convenio. El diccionario (`a07`) los mapea a sus
  equivalentes en otros países y a los nombres de entidad en inglés.
- **Markdown siempre.** Nada de HTML embebido salvo que no haya alternativa.
- **Prosa antes que listas.** Un párrafo que explica *por qué* vale más que cinco viñetas que
  enumeran *qué*.
- **Nada de prosa telegrama.** Una frase corta y aislada es un golpe de ritmo; tres seguidas son un
  telegrama. **Una frase aislada por sección, dos si la sección es larga.**
- **Tablas solo para lo tabular y corto**: traducción entre motores, matriz de anomalías por nivel
  de aislamiento, versiones fijadas, decisión. Tres o cuatro columnas como máximo.
- **Diagramas en Mermaid** (D-12, §19.1) cuando hay estructura que mostrar: una página que se
  parte, qué filas bloquea un `UPDATE`, el camino de un mensaje, un árbol de decisión. **Se quedan
  en `text` las sesiones intercaladas en el tiempo**, porque con las dos columnas alineadas y el SQL
  literal se leen mejor que en cualquier diagrama:

  ```text
  DOS RECEPCIONISTAS, UN FOLIO

  sesión A (caja 1)                  sesión B (caja 2)
  ─────────────────                  ─────────────────
  SELECT max(number) → 48212
                                     SELECT max(number) → 48212
  INSERT number = 48213
  COMMIT
                                     INSERT number = 48213   ← duplicado
                                     COMMIT
  ```

- **Salida de terminal literal**, en bloque `text`, sin embellecer y sin recortar la parte
  incómoda. El error real enseña más que el error editado, y es lo que alguien va a pegar en un
  buscador.
- **Encabezados con emoji, con moderación.** Uno por sección numerada, casi ninguno en
  subsecciones.

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior y usa SQL todos los días. La regla que lo cubre: **no explicar lo que ya
sabe, y no dejar ambiguo nada de lo que no**.

### 4.1 La regla del andamio

Todo concepto nuevo se presenta en tres tiempos, en este orden:

1. **El dolor primero**, y siempre en Alameda, reproducido sobre la caja. *"Matías corre la
   presentación a la obra social de marzo y le faltan 312 prácticas. La consulta es la de Rubén
   de 1999. ¿Cuántas filas debería devolver?"*
2. **El mecanismo después.** El nombre y la definición mínima: lo justo para usarlo hoy.
3. **El comando que corre**, con su salida real y el campo del plan señalado.

Presentar el mecanismo antes que el dolor produce lectores que saben recitar la BCNF pero no la
reconocen en `Pacientes.Nombre`.

### 4.2 Del instinto se parte, no se reniega

El lector llega con un modelo mental que funciona casi siempre. Dos micro-secciones lo honran antes
de corregirlo:

- 🩻 **"Esto sí funciona igual"**: lo que se transfiere sin cambios entre motores, o desde lo que
  el lector ya hace en su ORM. Tranquiliza y ahorra páginas.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"**: el punto exacto donde el modelo mental del
  desarrollador de aplicaciones se rompe, con la medición que lo prueba. *"Tu instinto dice que un
  UUID como clave es gratis"*, *"tu instinto dice que `REPEATABLE READ` significa lo mismo en los
  tres motores"*. **Uno por fase como mínimo**, y todos se acumulan en `INSTINTOS.md`.

### 4.3 Nada de cajas negras prematuras

Primero el SQL a mano, después el ORM, si alguna vez aparece. Primero `EXPLAIN` en texto, después
la herramienta que lo dibuja. Primero la restricción en el `CREATE TABLE`, después el framework de
migraciones. Esas capas no son malas: ocultan justo lo que el curso quiere enseñar.

### 4.4 Tres motores, sin tres manuales

**Un motor entra en una sección solo si su mecanismo cambia la decisión.** Si Postgres y MySQL se
comportan igual en algo, se dice en una línea con un 🩻 y se sigue. El contraste se escribe donde
diverge: InnoDB *clustered* contra el *heap* de Postgres, el `SERIALIZABLE` de Oracle contra el SSI
de Postgres, los *gap locks* de MySQL. Una sección que muestra el mismo comando en tres dialectos
sin que cambie nada es relleno.

### 4.5 Analogías, con fecha de caducidad

Se usan una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del
curso es **"una tabla es una planilla de Excel"**, que es exactamente el modelo mental de Rubén. Si
aparece, se desmonta en el mismo párrafo.

### 4.6 Explica el porqué

Cada decisión de diseño lleva su porqué, aunque sea media línea: por qué esta columna en este orden
del índice, por qué esta restricción y no un *trigger*, por qué `bigint` y no `uuid`.

### 4.7 Densidad calibrada

- Un concepto nuevo por vez.
- **Repetir lo importante está bien.** La frontera transaccional, "la base no estaba lenta" y "la
  regla vive en un solo sitio" reaparecen en todo el curso.
- Ninguna sección teórica supera las dos pantallas sin un comando, una medición o un diagrama.

### 4.8 Cierra los bucles

Si abres un paréntesis (*"esto lo medimos en la Fase 16"*, *"por ahora lo dejamos como deuda
💸"*), se cierra en algún documento del curso. Un pendiente que nunca se resuelve es ruido.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés (nombres de archivo,
> rutas, variables de entorno, identificadores, tablas, columnas, targets) y **todos los comentarios
> van en español con tildes**.

- **La convención de nombres (D10)** es la habitual del mundo SQL: `snake_case`, tablas en
  singular, y **palabras completas, sin abreviar** (`identity_document`, no `id_doc`;
  `reference_range`, no `ref_rng`). El techo es el límite del motor más restrictivo de los tres,
  que es Postgres con 63 bytes por identificador: por debajo de eso, nunca se abrevia para ahorrar
  letras. Las restricciones y los índices se nombran `<tabla>_<columnas>_<sufijo>`, con los sufijos
  que Postgres usa por defecto (`pkey`, `key`, `fkey`, `check`, `idx`, `excl`), para que el mensaje
  de error diga qué regla se violó.
- **Nombres del dominio, fijos en todo el curso**, en inglés y en `snake_case` en los tres motores:
  `patient`, `identity_document`, `lab_order`, `order_item`, `practice`, `analyte`, `result`,
  `reference_range`, `specimen`, `payer`, `agreement`, `site`, `physician`, `invoice`,
  `appointment`. Qué es cada una está en el alcance §7. Una fase no renombra una entidad; si
  necesita una nueva, la declara y se agrega allí.
- **La excepción `legacy`.** El esquema heredado se carga en `legacy` y **conserva los nombres
  originales de la caja**, con comillas donde el motor las exija: `legacy."Pacientes"`,
  `legacy."ResultadoItem"`. Son datos de la historia, no identificadores del curso, y renombrarlos
  borraría la historia que cuentan. Nada nuevo se crea en `legacy`.
- **Estilo de SQL:** palabras clave en MAYÚSCULAS, identificadores en minúsculas, una cláusula por
  línea cuando la consulta pasa de una línea. Alias cortos y con sentido (`p` para `patient`,
  nunca `t1`).
- **Cuando un bloque de SQL es de un motor concreto, lo dice en su primera línea**: `-- postgres`,
  `-- mysql`, `-- oracle`, `-- sqlserver`. Si no lo dice, corre igual en los tres, y eso se
  comprobó.
- **Nunca `foo`, `bar` ni `test1`.** Todo ejemplo usa el dominio de Alameda con datos que parezcan
  reales. **Nunca un DNI, un nombre o un número de afiliado reales**: todo sale del generador.
- **Bloques de código con su lenguaje declarado**: `sql`, `python`, `java`, `bash`, `yaml`, `text`
  para salida de terminal.
- **Un bloque, una idea.**

### 5.1 Versiones e imágenes

- **Digest, no tag**, con el tag legible en un comentario al lado.
- **Ninguna versión se escribe de memoria.** Se copia de la ejecución real, y el documento declara
  su fecha de verificación.
- **Si algo no se verificó, se dice con esas palabras**: *"esto no lo ejecuté; la documentación de
  la versión X lo describe así"*. Declarar lo no verificado es la marca de la casa.

### 5.2 Nombres de archivo del curso

- **Fases:** `NN-slug.md`, dos dígitos (`00` a `26`).
- **Apéndices:** `aNN-slug.md`, dos dígitos.
- **Track de SQL Server:** fases `ssNN-slug.md`, apéndices `ssa-NN-slug.md`, prompts propios en
  `prompts/prompts-sqlserver-fase.md`. **Todo lo del track va en archivos nuevos, nunca como
  añadido a los del camino base.**
- **Documentos vivos**, en la raíz del curso: `INSTINTOS.md`, `bitacora-de-medicion.md` y
  `a08-catalogo-de-errores.md`, que es apéndice y documento vivo a la vez.
- **La historia:** `00-historia-de-alameda.md`.
- **Solucionarios:** `soluciones/<mismo-nombre-que-el-documento>.md`, uno por fase, apéndice o fase
  del track que tenga ejercicios (§10.3).
- **Código:** `src/NN-slug/` o `src/aNN-slug/`, con el mismo nombre que su documento, más
  `src/lab/` para lo compartido (el arnés, el generador, el compose). Las pruebas de
  preparación no viven en el curso: van a `zz-code/` (§19.5).

---

## 6. 📐 Cómo se presenta una medición

Una medición mal presentada es peor que ninguna, porque parece evidencia.

**Toda medición se publica con cinco datos:**

1. **Qué se midió**, en forma estructural: lecturas lógicas, filas examinadas contra devueltas,
   estimadas contra reales, tamaño, bytes de WAL, filas bloqueadas.
2. **Sobre qué perfil de volumen** (S, M o L).
3. **Con qué motor y digest.**
4. **En qué máquina**, si aparece algún tiempo.
5. **Cómo reproducirlo**: el comando exacto.

### 6.1 La regla de publicación por motor

Es la divergencia más importante respecto de la NoSQL Lite, y **no se negocia** (alcance §6.1):

- **PostgreSQL, MySQL y MongoDB:** se publica la apuesta y **su resultado**.
- **Oracle y SQL Server:** se publica la **apuesta falsable completa sin resolver**. El mecanismo se
  explica citando la documentación oficial, con enlace. **Nunca** aparece un número propio de estos
  dos motores: ni lecturas, ni filas reales, ni tiempos, ni tamaños medidos. De sus planes se
  publica solo la **estructura** (operaciones y orden, de `EXPLAIN PLAN` sin ejecutar).

Formato de una medición publicada:

```markdown
> 📐 **Medición: presentación a la obra social, marzo** · perfil M · `postgres@sha256:…` ·
> verificado el 12/11/2026
>
> | | filas estimadas | filas reales | lecturas (buffers) |
> |---|---|---|---|
> | consulta de Rubén (`NOT IN`) | 1.204 | 0 | 48.213 |
> | con `NOT EXISTS` | 1.204 | 1.516 | 3.104 |
>
> Reproducir: `uv run lab measure presentation --profile m`
```

Formato de una apuesta sin resolver:

```markdown
> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: con `SERIALIZABLE`, las dos sesiones del
> §5 **terminan las dos con `COMMIT`** y la muestra queda asignada dos veces.
> Condiciones: perfil S, dos sesiones de `sqlplus`, el guion de `src/15-…/write_skew.sql`.
> Resuélvela: `uv run lab race write-skew --engine oracle`.
> El mecanismo, en la documentación oficial: {{enlace}}.
> 📝 No publicamos el resultado: la licencia de Oracle Database no permite divulgar
> resultados de pruebas de rendimiento sin permiso (`a09`).
```

**Los tiempos son contexto, nunca argumento.** Si un párrafo concluye algo y lo único que tiene
debajo es un milisegundo, está mal escrito.

**La apuesta falsable** se escribe **antes** de la medición y no se edita después. Si se pierde, la
pérdida se cuenta entera.

**El punto de rotura** se documenta con el volumen, la concurrencia o el dato exacto con que se
rompió, el **mensaje de error literal** y qué había que cambiar para salir. El mensaje entra
además en `a08-catalogo-de-errores.md`, siempre.

---

## 7. 📓 El formato de la bitácora

`bitacora-de-medicion.md` es el registro de todo lo medido. Cada entrada lleva un identificador
`M-NN` que no se reutiliza, y es de uno de dos tipos:

```markdown
### M-07 · F10 · Inserción con UUIDv4 contra bigint en InnoDB
**Tipo:** publicada · **Motor:** MySQL `mysql@sha256:…` · **Perfil:** M · **Fecha:** 14/11/2026
**Hipótesis:** {{la apuesta, tal como se escribió antes}}
**Resultado:** {{los números}} · **Apuesta:** ganada | perdida
**Reproducir:** `{{comando}}`
```

```markdown
### M-08 · F10 · La misma inserción en Oracle
**Tipo:** apuesta sin resolver · **Motor:** Oracle Free · **Perfil:** M
**Hipótesis:** {{…}} · **Resuélvela:** `{{comando}}`
```

Una entrada publicada nunca se edita. Si la medición se rehace con otra versión, se agrega una
entrada nueva que cita a la anterior.

---

## 8. 🧷 Marcadores, callouts y encabezado

### 8.1 Bloque de encabezado obligatorio

```markdown
# 🔢 Fase 16 — El folio sin huecos: numerar comprobantes con tres cajas y un web service que no perdona

> **Curso:** Ruta SQL · Fase 16 de 26 · Bloque III — La concurrencia · **10 h**
> **Motores:** PostgreSQL `postgres@sha256:…` · contraste MySQL `mysql@sha256:…` · Oracle (apuesta sin resolver)
> **Entorno de ejecución:** SQL + Python
> **Perfil de volumen:** S para los ejemplos, M para las mediciones
> **El dolor de Alameda:** `DMax + 1`, `UltimoNumero` y el error 10016 (historia §3, 2015)
> **Depende de:** Fase 15 · **Habilita:** Fase 17
> **Apéndices de apoyo:** a02, a04, a06
> **Fecha de verificación ejecutada:** {{DD/MM/AAAA}}
> **Objetivo:** …
```

El título es descriptivo y con carácter: `Fase NN — Tema: la promesa concreta del documento`.

### 8.2 Marcadores de estado

- 💸 **Deuda intencional**, con destino.
- 🔥 **Opcional o ampliación.**
- 💀 **Boss de bloque.** 🏆 **Boss global "Un martes".**
- 🟢🟡🟠🔴 **Dificultad de ejercicios.**
- 🚧 **Fuera de alcance por ahora**, siempre con destino.
- 🔒 **Resultado no publicable** (Oracle y SQL Server).
- ⭐ **Valoración bibliográfica**, solo en referencias y con su leyenda. **Nunca gradúa ejercicios.**

### 8.3 Callouts en blockquote

- 📐 **Medición.** El callout más importante del curso (§6).
- 🪞 **Apuesta falsable / instinto que falla.** 🪞🔒 si es una apuesta sin resolver.
- 💥 **Punto de rotura.**
- ⚰️ **Autopsia.** Con la estructura de §2.1.
- ⚖️ **Veredicto honesto.** Cuándo NO usar esto.
- 🩻 **Esto sí funciona igual.**
- 📖 **Traducción** entre motores, desde Access/T-SQL o desde la NoSQL Lite, y de vuelta.
- 🧠 **Modelo mental.** 🧭 **Principio.**
- ⚠️ **Advertencia.** 📝 **Nota de contexto.** 💡 **Truco.** 📚 **Referencia inline.**
- 🩺 **Diagnóstico.** El comando que confirma o descarta una hipótesis.
- 🏚️ **La caja.** Un fragmento literal del sistema heredado: una fila de `legacy`, una línea del
  `.bas`, el `LEEME.txt`.

### 8.4 Secciones narrativas recurrentes

- **Dónde estamos.** Qué dejó la fase anterior y qué falta.
- **Detalles con intención.** Las decisiones deliberadas de un bloque de código.
- **El patrón a memorizar.** Una o dos frases con la lección transferible.
- **Prueba de fuego.** Una verificación concreta dentro del flujo.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de cita.

---

## 9. 🧱 Las plantillas y la longitud

Los esqueletos completos están en [`plantillas-de-capitulo.md`](plantillas-de-capitulo.md): **fase
de tema** (F03–F23), **fase del Bloque 0** (F00–F02), **fase del árbitro** (F24–F26), **fase del
track** (`ss01`–`ss05`) y **apéndice**. Las de fase son rígidas y se siguen literales; la de
apéndice es laxa.

**Longitud del cuerpo**, medida cortando el documento por el encabezado de 🧪 Ejercicios y
escalada por horas:

| Horas | Fases | Palabras de cuerpo |
|---|---|---|
| 3–4 h | F00, F02 | 2.000–3.000 |
| 5 h | F01 | 3.000–4.000 |
| 8 h | F03–F08, `ss01`–`ss05` | 3.500–4.500 |
| 10 h | F09–F21, F25, F26 | 4.000–5.000 |
| 12 h | F24 | 4.000–5.000 (el resto es ejercicio de diseño) |
| 15 h | F22, F23 | 5.000–6.500 |

El aparato de ejercicios agrega entre 1.300 y 2.800 palabras encima, y eso está bien.

Después de la última sección, fuera de lo que lee el estudiante, cada fase puede cerrar con **📌
Pendientes sugeridos**, con destino explícito.

---

## 10. 🧪 Ejercicios

- **Cantidad: 20 mínimo y 30 máximo por fase**, con el número exacto fijado en la propuesta de
  fases §11. **Exención declarada:** F00 y F02 son de criterio y bajan a 12.

  > ⚠️ **La cantidad no arregla un aparato flojo.** Si al escribir el ejercicio 24 sale una
  > variante del 11, el número correcto era 23.

- **La escala:**

  | | Nivel | Qué pide |
  |---|---|---|
  | 🟢 | Fácil | Reproducir lo que la fase acaba de mostrar |
  | 🟡 | Intermedio | Aplicar el patrón a otra parte de Alameda |
  | 🟠 | Difícil | Combinar, diagnosticar, decidir entre alternativas |
  | 🔴 | Muy difícil | Abierto o adversarial: se entrega algo roto y hay que razonarlo |
  | 🔥 | Extra | Fuera del alcance base |
  | 💀 | Boss de bloque | Cruza las fases del bloque; va al final del bloque |

  **🔥 y 💀 no cuentan para el mínimo.**

- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con desviación deliberada según la fase.
- **Al menos un tercio son de diagnóstico o de medición**: se entrega un esquema sin restricción,
  un índice que no se usa, una transacción que deja pasar una anomalía, y se pide reproducir, medir
  y explicar.
- **Al menos uno por fase trabaja sobre `legacy`**: la caja es el material, y el lector tiene que
  volver a ella.
- **Predecir antes de ejecutar** en 🟠 y 🔴.
- **Cada ejercicio cierra con su criterio**: `**Objetivo:**` o `**Pregunta:**`. Nunca "crea la
  tabla" a secas; siempre *"…y demuestra que la carga de `legacy."Pacientes"` rechaza exactamente
  las filas con fecha de nacimiento futura"*.
- **Los ejercicios de Oracle** piden resolver la apuesta en la máquina del lector y **explicar** el
  resultado con la documentación; no piden comparar con un número del curso, porque no lo hay.
- **Agrupados por dificultad, con encabezado de rango y el conteo en el título**, como en la Lite,
  y con este formato exacto, que es el que cuenta el verificador (§19.4):

  ```markdown
  ## 🧪 14. Ejercicios (24)

  ## 🟢 Fácil — la caja tal cual (1–7)

  ### 🟢 Ejercicio 1 — Contar lo que trae la caja

  **Objetivo:** …

  [Solución](soluciones/01-la-caja-y-el-arnes.md#ejercicio-1)
  ```

  La numeración es continua de 1 al total, sin saltos; los 🔥 y 💀 no entran en la cuenta.
- **Cada ejercicio enlaza su solución** en la última línea, con el ancla `#ejercicio-N` (§10.3).

### 10.1 El boss de bloque

Uno por bloque del I al V, al cierre de su última fase, más el **boss del puente** (Java 21 y
Artemis), que va junto al del Bloque V. **Empieza con un sistema roto**, cruza al
menos dos fases del bloque y se entrega como artefacto: un esquema migrado, un informe con
mediciones, un diagnóstico con su comando. **Lo pide alguien de la historia**, con nombre, en su
voz y con una consecuencia si sale mal. La lista está en el alcance §13.

### 10.2 El boss global "Un martes"

Opcional, acumulativo y fuera de las horas del curso. Se referencia **al cierre de cada bloque**,
marcado como opcional, y termina en F26 con la facturación de un martes corriendo sobre la base
nueva.

### 10.3 El solucionario

Decidido por Oskar el 06/10/2026 (D-05, alcance §12.1): **todo ejercicio lleva solución, en un
archivo separado**, para que el lector intente antes de leerla.

- **Un archivo por documento con ejercicios**, con el mismo nombre que el documento, en
  `soluciones/`: `soluciones/16-el-folio-sin-huecos.md`, `soluciones/a04-el-arnes-de-forma.md`,
  `soluciones/ss02-pesimista-contra-rcsi.md`. Un encabezado `### Ejercicio N` por ejercicio, en el
  mismo orden y con la misma numeración que el documento; su ancla es `#ejercicio-n`.
- **Se escribe en la misma sesión que su documento**, con la plantilla de solucionario. Una fase sin
  su solucionario completo no está cerrada, y quien cambia un ejercicio cambia su solución en la
  misma edición.
- **Solución desarrollada, no resultado**: el SQL o el código completo, la salida literal y por qué
  esa es la respuesta. **Todo se ejecutó** sobre el perfil que dice el encabezado, con la fecha de
  verificación; los números salen de la ejecución, no de la fase.
- **🟢 y 🟡: la solución completa. 🟠 y 🔴: una solución de referencia y una rúbrica** —qué tiene que
  tener una respuesta correcta y qué la invalida—, porque admiten más de un diseño. Si el ejercicio
  pedía predecir antes de ejecutar, la solución da el número medido y la predicción razonable.
- **Oracle y SQL Server sin números** (§6.1): la solución explica el mecanismo con la documentación
  oficial, da la consulta y dice qué mirar en el resultado; la apuesta queda 🪞🔒 sin resolver.
- **Los 🔥** llevan solución cuando tienen una respuesta verificable, y una rúbrica cuando son
  exploratorios, bajo `### Ejercicio 🔥 N`.
- **Los boss no van en el solucionario**: el sistema roto de partida vive en `src/`, los criterios de
  aceptación en la fase, y la solución de referencia queda fuera del repositorio publicado (confirmado
  por Oskar el 06/10/2026). Es un
  encargo, no un ejercicio, y publicar su solución lo convierte en uno.
- **No cuenta para la longitud** de §9 ni para las horas: el tiempo de resolver ya está dentro de las
  horas de la fase.

---

## 11. 📚 Bibliografía y referencias

**Orden de prioridad:** documentación oficial de la versión que usamos, después estándares y papers
fundacionales (Codd 1970, Berenson et al. 1995 sobre niveles de aislamiento, Cahill et al. 2008
sobre SSI, Fagin sobre la 5FN), después libros, después blogs y vídeos. **Siempre se advierte
cuando un enlace apunta a otra versión.**

**Libros base del curso** (edición y año comprobados en la tanda P9, y citados por esa edición):

- C. J. Date, *SQL and Relational Theory*.
- Markus Winand, *SQL Performance Explained* y su sitio *Use The Index, Luke*.
- Bill Karwin, *SQL Antipatterns*.
- Martin Kleppmann, *Designing Data-Intensive Applications*.
- Richard T. Snodgrass, *Developing Time-Oriented Database Applications in SQL*.
- Thomas Kyte, *Expert Oracle Database Architecture*.

Formato: URL completa, título y una nota de qué versión cubre y por qué vale. Cada fase cierra sus
referencias con un **orden de lectura sugerido**.

> ⚠️ En todas las secciones de referencias va la advertencia de que las URL y los contenidos
> cambian.

---

## 12. 🐳🦭 Convención Docker / Podman

- **Docker Compose es el camino principal**, con el equivalente Podman al lado. Cuando el comando
  es idéntico, se dice y no se duplica.
- **Aquí no se enseña Docker.** Más de dos párrafos de contenedores pertenecen a
  `cursos-contenedores-cloud-infra/docker-container-legacy/`, que se nombra sin enlace (D-03).
- **Sin Kubernetes**, en ninguna forma.
- **Los servicios del `compose.yaml` se nombran por rol**: `postgres`, `mysql` y `oracle` (aquí el
  motor *es* el rol), más `mongo` (F20), `api` (F23), `broker` y `bridge` (boss del puente) y
  `sqlserver` (track).
- **La emulación se declara**: todo lo que corra bajo Rosetta o QEMU lo dice en el encabezado de la
  fase, porque cambia los tiempos (que igual no son argumento) y a veces el arranque.

---

## 13. 🤝 Honestidad: las reglas que no se negocian

1. **Nada se publica sin haberse ejecutado.**
2. **Lo que no se verificó se declara con esas palabras**, donde el lector lo necesita.
3. **Cada diseño gana en algún sitio y pierde en otro**, y las pérdidas van con número. Esto
   incluye al diseño que propone el curso.
4. **La apuesta perdida se publica igual que la ganada.**
5. **Ningún número de Oracle o de SQL Server se publica** (§6.1), y la razón se dice la primera
   vez que aparece en cada fase.
6. **"Esto no es relacional" se dice cuando es verdad**, con el mismo rigor que todo lo demás.

---

## 14. 🔗 Coherencia entre documentos

- **Los nombres del dominio no se renombran** entre fases.
- **Los apéndices no repiten lo que explica una fase, y viceversa: se enlazan.**
- **Una fase no cita el temario ni el plan de producción**: cita otra fase o un apéndice.
- **Las fechas, cifras y nombres de la historia no se inventan de nuevo.** Si una fase necesita un
  dato que la historia no tiene, se agrega primero a `00-historia-de-alameda.md`.
- **Los README y `0-ESTRUCTURA-CURSO.md` no se tocan al escribir una fase o un apéndice.** Se
  escriben en una tanda final y aparte, cuando todo el contenido existe. Una fase que querría agregar algo a un README lo deja
  anotado como pendiente, no lo agrega.
- 🗑️ **Los documentos desechables no se citan nunca.** Los archivos `_desechable-*` son andamio y
  van a desaparecer.
- **Git:** tags `fase-NN-<slug>` y prefijo de commit `fNN:`; ejercicios `fNN ejM: …`. El track usa
  su propio espacio, `ss-fase-NN-<slug>` y `ssNN:`, para que `git tag -l 'fase-*'` siga siendo el
  índice limpio del camino base. Los apéndices solo llevan tag si dejan archivos en el repositorio
  (`a02`, `a05`, `a10`).

---

## 15. 📓 Los tres documentos vivos

Crecen durante todo el curso y son producto, no apuntes.

- **`a08-catalogo-de-errores.md`**: todo error que aparezca al ejecutar entra **con su mensaje
  literal**, en el motor en que apareció: mensaje exacto, motor y versión, qué lo provocó, cómo se
  confirma y cómo se sale. Los mensajes de Oracle y SQL Server **sí se publican**: un mensaje de
  error no es un resultado de rendimiento.
- **`bitacora-de-medicion.md`**: toda medición, publicada o sin resolver, con el formato de §7.
- **`INSTINTOS.md`**: los 🪞 acumulados, con la medición que los demuestra y la fase donde
  aparecieron.

> 🧭 **Cuando estés ejecutando, anota el error antes de arreglarlo.** Reconstruir un mensaje de
> memoria produce mensajes que no existen.

---

## 16. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El bloque de metadatos está completo, con motores, digests, el dolor y la fecha de verificación
[ ] Todo número del documento salió de una ejecución real
[ ] Ningún número de Oracle ni de SQL Server; sus apuestas van con 🪞🔒 y sin resolver
[ ] Lo no verificado está declarado con esas palabras
[ ] Toda medición trae los cinco datos de §6 y su comando de reproducción
[ ] La apuesta se escribió antes de la medición y no se editó después
[ ] El punto de rotura trae el dato exacto y el mensaje de error literal
[ ] Errores nuevos en a08, mediciones en la bitácora, el 🪞 en INSTINTOS.md
[ ] Hay al menos un ⚖️ veredicto honesto, con la pérdida cuantificada
[ ] Ninguna autopsia juzga a una persona; las propuestas rivales tienen su mejor argumento
[ ] Cada motor aparece solo donde cambia la decisión (§4.4)
[ ] Ejercicios en la cantidad de la propuesta §11, agrupados, un tercio de diagnóstico, uno sobre legacy
[ ] Cada ejercicio tiene Objetivo o Pregunta, usa nombres del dominio y enlaza su solución
[ ] soluciones/<documento>.md completo: un ### Ejercicio N por ejercicio, ejecutado, rúbrica en 🟠🔴
[ ] Ninguna explicación de Docker pasa de dos párrafos
[ ] Cuerpo en la banda de §9 para sus horas
[ ] Todo pendiente abierto tiene destino explícito
[ ] Tuteo en todo el documento, personajes incluidos; cero voseo, cero "usted"
[ ] Código en inglés, comentarios en español con tildes; SQL con su motor en la primera línea si no es portable
[ ] grep -ln "_desechable-" *.md en la raíz del curso no devuelve nada
[ ] Ningún README.md modificado ni 0-ESTRUCTURA-CURSO.md creado: van en su tanda final y aparte
```

---

## 17. ⚖️ Excepciones declaradas al `CLAUDE.md` del repositorio

El `CLAUDE.md` permite apartarse de los defaults si se nombra la regla y se dice por qué. Si no
estuvieran escritas aquí, cada sesión futura las "arreglaría" de vuelta.

1. **`BENCHMARKS.md` se sustituye por `bitacora-de-medicion.md`.** Motivos: el curso mide la forma
   y no la velocidad, y **la mitad de las entradas no pueden llevar resultado** por licencia (§6.1).
2. **"Verificar todo 'mejor que' contra `BENCHMARKS.md`" no aplica a Oracle ni a SQL Server.** Allí
   la comparación se sostiene con la documentación oficial y con la apuesta sin resolver, y el texto
   lo dice.
3. **Los apéndices son transversales al curso**, diez para veintisiete fases, más uno del track.
4. **Ejercicios: 20–30 por fase**, con la exención de F00 y F02 (12).
5. **Los identificadores del esquema `legacy` no están en inglés** (§5): son datos de la historia.
6. **`INSTINTOS.md` se mantiene y es central.**
7. **`0-ESTRUCTURA-CURSO.md` se escribe al final, no antes de la primera fase.** El `CLAUDE.md` lo
   pide antes de cualquier lección, como documento de alcance y estructura. Aquí ese papel lo
   cumplen el [alcance](alcance-del-proyecto.md) y la
   [propuesta de fases](propuesta-fases-y-alcance.md), escritos antes de la primera fase.
   `0-ESTRUCTURA-CURSO.md` se reserva para el temario publicado, con el estado real, y se escribe
   junto con los README cuando todo el contenido existe, para no mantener dos mapas durante la
   escritura.

Agregadas el 06/10/2026, al revisar el curso contra los lineamientos de producción (§19). Ya eran la
regla del curso, heredada de la NoSQL Lite; lo que faltaba era declararlas:

8. **Los comentarios de código van en español con tildes** (§5), no en inglés como pide el
   `CLAUDE.md`. Motivo: en este curso el comentario es la parte pedagógica del código y se lee como
   prosa. Los identificadores siguen en inglés, salvo el esquema `legacy` (excepción 5).
9. *(Retirada el 06/10/2026.)* Se había declarado, por defecto, que los ejercicios no traían
   solución. Oskar decidió lo contrario: **solución en archivo separado** (§10.3), que es lo que pide
   el `CLAUDE.md`, así que ya no es una excepción. Se conserva el número para no renumerar. Lo único
   que sigue apartándose es que **los boss no publican su solución** (§10.3).

Todo lo demás del `CLAUDE.md` aplica tal cual.

---

## 18. 📌 Pendientes que afectan a esta guía

- **Versiones y digests sin fijar** hasta la verificación de laboratorio (tanda P8). Cuando se
  fijen, viven en `a02` y esta guía solo apunta allí. P8 trabaja en `zz-code/` (§19.5).
- **Ediciones de los libros base** sin comprobar (tanda P9).
- ✅ **D6 cerrada el 30/09/2026**: el repositorio se trata como público, y de los planes de Oracle
  y SQL Server se publica solo la estructura.

---

## 19. 🧰 Correspondencia con los lineamientos de producción

Agregada el 06/10/2026, al revisar el curso contra los lineamientos de producción del repositorio
(`zz-instrucciones/`), antes de T0. **Va al final y no renumera nada**, porque las secciones de esta
guía ya las citan el alcance, las propuestas, las plantillas, los prompts y el plan. Las decisiones de
la plantilla general (D-01–D-13) están mapeadas en el [alcance](alcance-del-proyecto.md) §12.1.

### 19.1 D-12 · Diagramas en Mermaid

Todo diagrama estructural o conceptual —un esquema y sus relaciones, una página que se parte, el
camino de un mensaje, un árbol de decisión— va en un bloque `mermaid` y se dibuja con `mmdc` antes de
publicarlo. Para los esquemas, `erDiagram` con la notación de pata de gallo; para flujos y caminos,
`flowchart LR`. Se quedan en `text`:

- **las sesiones intercaladas en el tiempo** (§3), porque dos columnas alineadas con el SQL literal se
  leen mejor que un `sequenceDiagram`, y son el material del Bloque III;
- las **salidas de terminal** y los **planes de ejecución**, literales;
- los **árboles de archivos** y las **fichas de cierre de fase**.

### 19.2 Numeración

Las plantillas generales citan "guía §12" para el checklist y "guía §13" para las excepciones. En este
curso son **§16** (checklist) y **§17** (excepciones). Todos los documentos de `prompts/` citan los
números de esta guía, nunca los de la plantilla.

### 19.3 Qué documento hace cada papel

| Papel en los lineamientos | En este curso |
|---|---|
| Alcance | [`alcance-del-proyecto.md`](alcance-del-proyecto.md); D-01–D-13 en su §12.1 |
| Propuesta de fases y de apéndices | [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) (resumen en §11, registro de decisiones en §12) y [`propuesta-apendices-y-alcance.md`](propuesta-apendices-y-alcance.md) |
| Plan de producción | `_desechable-plan-de-produccion.md`: desechable a propósito, para que nada lo cite |
| Guía | este documento |
| Diccionario de términos | [`diccionario-de-terminos.md`](diccionario-de-terminos.md); `a07` lo publica para el lector |
| Contrato de nombres | [`contrato-de-nombres.md`](contrato-de-nombres.md), con ⏳ hasta T1 |
| Plantillas de capítulo | [`plantillas-de-capitulo.md`](plantillas-de-capitulo.md): fase de tema, Bloque 0, árbitro, track y apéndice |
| Formato de mediciones | §6 y §7 de esta guía |
| Solucionario | `soluciones/<documento>.md`, con la forma de §10.3 y la plantilla de solucionario |
| Prompts de fase y de apéndice | [`prompts-de-fase.md`](prompts-de-fase.md), [`prompts-de-apendice.md`](prompts-de-apendice.md) y, para el track, [`prompts-sqlserver-fase.md`](prompts-sqlserver-fase.md) |
| Historia de la empresa | `00-historia-de-alameda.md`, publicada |
| Verificación previa (E6) | P8 y P9, pendientes: `verificacion-de-laboratorio/hallazgos.md` (formato `H1`, `H2`…) |
| Manual de `prompts/` | [`README.md`](README.md) |
| Verificador | `verificar-corpus.py` sobre `verificador_base.py` (§19.4) |
| Documentos vivos | `INSTINTOS.md`, `bitacora-de-medicion.md` (en lugar de `BENCHMARKS.md`, §17) y `a08` |

### 19.4 Verificación

Desde la raíz del curso, al cerrar cada tanda:

```bash
python3 prompts/verificar-corpus.py                 # validaciones base + las propias del curso
python3 prompts/verificar-corpus.py --publicacion   # además, lo que exige el repositorio público
```

- `verificar-corpus.py` hereda de `verificador_base.py` (copia sin cambios de la base de los
  lineamientos) los enlaces y anclas —con el U+FE0F que GitHub conserva—, los enlaces que salen del
  curso, los restos de plantilla, la codificación rota, el emoji en `###` y los callouts. Agrega lo
  propio: ejercicios contra el resumen de la propuesta §11 (también los del track), numeración sin
  saltos, **el solucionario de cada documento con ejercicios** (que exista y tenga los mismos
  ejercicios) y el enlace de cada ejercicio a su solución, la banda de palabras de §9 por horas, el
  aviso `DIAGRAMA` y el aviso `README`, si un README o `0-ESTRUCTURA-CURSO.md` aparece antes de T15.
- `--publicacion` agrega los errores de la etapa de publicación: enlaces a `prompts/` y menciones a
  material privado (`zz-code/`, desechables).
- Reemplaza el script de enlaces y anclas que traía el plan §4, que calculaba mal las anclas de los
  encabezados con ⚠️, ⚖️ o 🗂️. Al 06/10/2026, con solo la historia escrita, los dos modos salen en
  **0 errores y 0 avisos**.

### 19.5 Código, `zz-code/` y `.gitignore`

- **El código del curso vive en `src/`** (D-09), con **un solo `.gitignore`, en `src/`**, que nace en
  T0 y se sostiene sin el de la raíz del repositorio: `.venv/`, `__pycache__/`, la caja generada por
  `a05`, el `.env` del laboratorio y, para el boss del puente, `target/`. Ninguna carpeta de `src/`
  lleva el suyo.
- **Las pruebas de las sesiones van a `zz-code/ruta-sql-<fecha>-<hash>/`**, nunca al scratchpad, a
  `/tmp` ni a una carpeta del curso. P8 (la verificación de laboratorio) también: sus scripts y
  registros en `zz-code/`, y solo `hallazgos.md` en `prompts/verificacion-de-laboratorio/`. El plan
  registra cada directorio (§9 del plan). El curso no cita `zz-code/`.
- **La prueba de concepto del Access de museo** estaba en `taller/accdb-museo/`; el 06/10/2026 pasó
  a `zz-code/ruta-sql-20261006-fc2f/accdb-museo/`, y `a10` la extrae a
  `src/a10-el-access-de-museo/` en T14. `taller/` ya no existe.
