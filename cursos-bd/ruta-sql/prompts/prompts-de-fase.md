# 🗺️ Prompts iniciales por fase
## Ruta SQL — 27 sesiones, 27 entregables

Cada sección es el prompt completo de una fase, listo para pegar en la sesión que la redacta. **El
alcance de cada fase no se copia aquí**: vive en su ficha de
[`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md), y el prompt la cita. Lo que el prompt
agrega es lo que la ficha no dice: qué vigilar, qué riesgo tiene la fase y qué tiene que estar hecho
antes. Así, si la ficha cambia, el prompt no queda desactualizado.

**Una sesión, un archivo.** Si una sesión no produce entregable, o sobra o se salió de alcance.

> ⚠️ **Antes de la primera sesión.** Tienen que estar a mano, en este orden:
> `prompts/alcance-del-proyecto.md`, `prompts/guia-de-estilo-y-convenciones.md`,
> `prompts/propuesta-fases-y-alcance.md`, `prompts/propuesta-apendices-y-alcance.md`,
> `prompts/plantillas-de-capitulo.md` y `00-historia-de-alameda.md`.
> **No se usa** ningún archivo `_desechable-*`: el curso no los cita.

> ⚠️ **Antes de F01.** Tienen que estar escritos y verificados `a01`, `a02`, `a05` y `a06`, y hecha
> la verificación de laboratorio (P8). Sin digests fijados, ninguna fase publica una versión.

---

## 🧱 El marco común

Va entero en el prompt de F00 y comprimido en los demás. **No lo repitas en el documento:
aplícalo.**

```markdown
## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: (1) `prompts/alcance-del-proyecto.md`,
(2) `prompts/guia-de-estilo-y-convenciones.md`, (3) `prompts/propuesta-fases-y-alcance.md`, con la
ficha de esta fase, (4) `prompts/propuesta-apendices-y-alcance.md`, (5)
`prompts/plantillas-de-capitulo.md`, (6) `00-historia-de-alameda.md`, que es la empresa del curso y
la fuente de todo lo narrativo, (7) las fases y apéndices ya escritos, (8) las decisiones de esta
sesión. Los documentos `_desechable-*` no cuentan y no se citan.

Reglas que no se negocian:
- **Nada se publica sin haberse ejecutado.** Ningún número, ninguna versión, ninguna salida
  inventada. Lo que no se verificó se declara con esas palabras.
- **Ningún número de Oracle ni de SQL Server.** Sus mediciones van como apuesta 🪞🔒 sin resolver,
  con el mecanismo citado de la documentación oficial (guía §6.1).
- **Se mide la forma, no la velocidad.** Lecturas lógicas, filas examinadas contra devueltas,
  estimadas contra reales, tamaño, WAL, filas bloqueadas.
- **El dolor de Alameda va primero, reproducido sobre `legacy`**, y después el mecanismo.
- **Cada motor aparece solo donde cambia la decisión.**
- **Autopsia, no juicio.** Rubén, Matías, Florencia y Verónica tienen su mejor argumento antes que
  el del curso.
- **Aquí no se enseña Docker.** Más de dos párrafos de contenedores: enlaza a `a01`/`a02`.
- **Código en inglés, comentarios en español con tildes.** Nombres del dominio fijos (alcance §7);
  `legacy` conserva los nombres de la caja.
- **Los datos de la historia no se inventan.** Si falta uno, se propone agregarlo a la historia.
- **No toques ningún `README.md`**, ni el del curso ni los de `src/`, **ni crees
  `0-ESTRUCTURA-CURSO.md`**. Se escriben en una tanda final y aparte. Si algo debería constar en
  ellos, déjalo en 📌 Pendientes sugeridos.
- La plantilla se sigue literal, sin secciones extra ni reordenadas, y el cierre lleva el bloque 🏷️.
```

Y el **protocolo de tres pasos**, que cierra todos los prompts:

```markdown
## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes. Devuélveme: (a) preguntas bloqueantes
numeradas, marcando cuáles puedes asumir con un valor por defecto; (b) tu lectura de la ficha y si
las horas cuadran; (c) la apuesta que propones, escrita ya en su forma final, y el punto de rotura
que esperas; (d) un esbozo de la sección más larga; (e) cualquier contradicción con lo ya escrito:
dímela, no la resuelvas.
**Paso 2 — Laboratorio y redacción**, cuando yo responda. Primero se ejecuta y se anota (errores
antes de arreglarlos); después se escribe. Si aparece una duda nueva, **para y pregunta**.
**Paso 3 — Autoverificación** contra el checklist de la guía §16, reportada en lista corta, más las
entradas nuevas de la bitácora, de `a08` y de `INSTINTOS.md`.
```

---

## # Fase 00 — La base que nadie diseñó

```markdown
Esta es la sesión de la **Fase 00 — 📜 La base que nadie diseñó**, del curso Ruta SQL. Su único
entregable es `00-la-base-que-nadie-diseno.md`.

## Marco (no lo repitas, aplícalo)

{{pega aquí el marco común completo}}

## Identidad

- Fase 00 de 26 · Bloque 0 · **4 h** · 12 ejercicios · plantilla del Bloque 0
- Depende de: nada · Habilita: F01 · **Esta fase se lee.**

## Alcance

El de la ficha F00 de la propuesta, completo.

## Qué vigilar

- **El tono es todo.** Es la primera vez que el lector conoce a Rubén, y tiene que salir queriéndolo.
  Si la autopsia de `DMax + 1` suena a burla, la fase está mal.
- **Alameda en una página, no en diez.** La historia existe y se enlaza; aquí van los tres o cuatro
  hitos que la fase necesita.
- **Las autopsias de la industria** sin caso real que se pueda sostener se escriben como **escenario
  declarado** ("un sistema de este tamaño, con esta forma"), y se dice.
- **Florencia y Verónica** aparecen con su mejor argumento. El lector no puede terminar F00
  sabiendo quién gana.

{{protocolo de tres pasos}}
```

---

## # Fase 01 — La caja y el arnés

```markdown
Esta es la sesión de la **Fase 01 — 📦 La caja y el arnés**. Entregable: `01-la-caja-y-el-arnes.md`.

## Marco
El de F00, más F00 cerrada y `a01`, `a02`, `a05`, `a06` escritos y verificados.

## Identidad
- Fase 01 de 26 · Bloque 0 · **5 h** · 22 ejercicios · plantilla del Bloque 0
- Motores: PostgreSQL, MySQL y Oracle · Entorno: SQL + Python
- Apéndices: a01, a02, a03, a04, a05, a06

## Alcance
El de la ficha F01, completo.

## Qué vigilar
- **La prueba de fuego es ejecutada, no estimada**, y su número coincide con el que declara el
  generador. Si no coincide, el arnés está mal, y hay que decirlo con esas palabras.
- **Nada se limpia.** La tentación de "arreglar" un CSV antes de cargarlo es justo lo que la fase
  tiene que resistir.
- **El recorrido de Oracle publica estructura, no números**: cuántas tablas cargó sí (es un conteo de
  la caja, no un resultado de rendimiento); lecturas o tiempos, no.
- **La salida del mensaje de Latin-1 es literal**, y entra a `a08` como su primera entrada o de las
  primeras.
- Al cerrar, se abren los esqueletos de `bitacora-de-medicion.md` e `INSTINTOS.md` si todavía no
  existen.

{{protocolo}}
```

---

## # Fase 02 — Las cinco preguntas, desde el otro lado

```markdown
Esta es la sesión de la **Fase 02 — ❓ Las cinco preguntas, desde el otro lado**. Entregable:
`02-las-cinco-preguntas-desde-el-otro-lado.md`.

## Marco
El de F00, más F01 cerrada. Lee también `cursos-bd/ruta-no-sql-lite/02-las-cinco-preguntas.md`:
esta fase es su contrapeso y la enlaza, pero no la repite.

## Identidad
- Fase 02 de 26 · Bloque 0 · **3 h** · 12 ejercicios · plantilla del Bloque 0 · se lee

## Alcance
El de la ficha F02, completo, con las respuestas del alcance §5.

## Qué vigilar
- **La frontera transaccional queda como la carta más fuerte de lo relacional**, con el comprobante
  fiscal como ejemplo, y **la pregunta 3 se le concede a Florencia** desde ya.
- **La pregunta 5 (exactitud o parecido)** anticipa F05: la deduplicación de pacientes es parecido.
- **El triaje "ya está en producción"** se escribe como si el lector lo fuera a usar el lunes.

{{protocolo}}
```

---

## # Fase 03 — Lo que SQL le hace al modelo relacional

```markdown
Esta es la sesión de la **Fase 03 — 🧮 Lo que SQL le hace al modelo relacional**. Entregable:
`03-lo-que-sql-le-hace-al-modelo.md`.

## Marco
El de F00, más el Bloque 0 cerrado y `a07` con su esqueleto.

## Identidad
- Fase 03 de 26 · Bloque I · **8 h** · 22 ejercicios · plantilla de tema
- Motores: Postgres, contraste MySQL y Oracle · Entorno: SQL + Python

## Alcance
El de la ficha F03, completo.

## Qué vigilar
- **Date y Darwen sin religión.** La crítica se presenta como herramienta para entender por qué la
  consulta dio mal, no como tesis a defender.
- **La cadena vacía de Oracle** es el contraste de la fase y cambia una migración real: dale el
  espacio que merece. Es comportamiento documentado; cítalo de la documentación, sin números.
- **La presentación a la obra social** tiene que salir de la caja tal cual la dejó Rubén, y el
  número de filas perdidas tiene que coincidir con la verdad del generador.

{{protocolo}}
```

---

## # Fase 04 — Un valor, un hecho

```markdown
Esta es la sesión de la **Fase 04 — 🧱 Un valor, un hecho: de la 1FN a la BCNF**. Entregable:
`04-un-valor-un-hecho.md`.

## Marco
El de F00, más F03 cerrada. Lee `taller/accdb-museo/` (o `src/a10-el-access-de-museo/` si ya se
movió): `ModParser.bas`, `parse_patients.py` y los resultados de `run_bas_tests.py`.

## Identidad
- Fase 04 de 26 · Bloque I · **8 h** · 24 ejercicios · plantilla de tema

## Alcance
El de la ficha F04, completo.

## Qué vigilar
- **Las dos diferencias del parser** (ventana de años y parche de 2019) se reproducen, no se cuentan.
  La del `.bas` en LibreOffice es opcional y va con un enlace a `a10`; la fase no depende de ella.
- **"La atomicidad depende del uso"** se discute con honestidad: `PEREZ PEDRO` en un solo campo no
  es una violación de la 1FN si nadie lo consulta por apellido. El problema es el DNI adentro.
- **La tabla de rechazos por regla** es la medición del bloque. Su formato lo fija esta fase, y las
  cuatro siguientes lo heredan: decídelo en el paso 1.
- **El 90 % de Rubén** es una cifra de la historia. Si la medición contra el generador da otra, se
  publica la medida y se propone ajustar el generador o la historia; no se fuerza el número.

{{protocolo}}
```

---

## # Fase 05 — Una persona no es su documento

```markdown
Esta es la sesión de la **Fase 05 — 🪪 Una persona no es su documento**. Entregable:
`05-una-persona-no-es-su-documento.md`.

## Marco
El de F00, más F04 cerrada.

## Identidad
- Fase 05 de 26 · Bloque I · **8 h** · 24 ejercicios · plantilla de tema

## Alcance
El de la ficha F05, completo.

## Qué vigilar
- **Precisión y exhaustividad contra la verdad del generador** son el corazón de la fase. Si `a05`
  no expone esa verdad de forma consultable, para y dímelo.
- **Los documentos de la historia marcados con 🔍** (rango de DNI de extranjeros, denominación del
  certificado de residencia precaria) no se usan como dato hasta verificarlos. Se puede modelar el
  tipo sin citar el rango.
- **La fusión nunca borra.** El paciente fusionado queda con su historia y con la marca de quién y
  cuándo lo fusionó; esto anticipa F07.
- **El veredicto en salud es asimétrico** y se dice con números: cuántos falsos positivos acepta un
  laboratorio que firma resultados con matrícula.

{{protocolo}}
```

---

## # Fase 06 — Cuarta y quinta forma normal

```markdown
Esta es la sesión de la **Fase 06 — 🔗 Cuarta y quinta forma normal, con dependencias de verdad**.
Entregable: `06-cuarta-y-quinta-forma-normal.md`.

## Marco
El de F00, más F05 cerrada.

## Identidad
- Fase 06 de 26 · Bloque I · **8 h** · 20 ejercicios · plantilla de tema
- Contraste: probablemente ninguno cambia la decisión. Si es así, la §6 lo dice en un párrafo.

## Alcance
El de la ficha F06, completo.

## Qué vigilar
- **La 5FN con un ejemplo que no sea de libro.** La regla de convenios tiene que ser plausible en
  Alameda en sus dos variantes (cíclica y no cíclica), y el generador tiene que poder producir las
  dos. Si no puede, dímelo en el paso 1.
- **Es la fase más corta en ejercicios (20)**, porque enseña un mecanismo a fondo y no tres.

{{protocolo}}
```

---

## # Fase 07 — El tiempo en el modelo

```markdown
Esta es la sesión de la **Fase 07 — ⏳ El tiempo en el modelo**. Entregable:
`07-el-tiempo-en-el-modelo.md`.

## Marco
El de F00, más F06 cerrada.

## Identidad
- Fase 07 de 26 · Bloque I · **8 h** · 24 ejercicios · plantilla de tema

## Alcance
El de la ficha F07, completo.

## Qué vigilar
- **`WITHOUT OVERLAPS` y las claves foráneas con período** solo se usan si la versión del curso las
  trae y se ejecutaron. Si no, la restricción de exclusión con `gist` es el camino, y se dice.
- **La 6FN y el *anchor modeling*** llevan su costo medido: cuántos joins y qué le pasa a la
  estimación de filas. La fase no los vende.
- **La pregunta de Norma** se contesta con una consulta, y la consulta se publica con su salida.

{{protocolo}}
```

---

## # Fase 08 — Los dos extremos del mismo error

```markdown
Esta es la sesión de la **Fase 08 — ⚖️ Los dos extremos del mismo error**. Entregable:
`08-los-dos-extremos-del-mismo-error.md`. **Cierra el Bloque I: lleva el boss.**

## Marco
El de F00, más F07 cerrada.

## Identidad
- Fase 08 de 26 · Bloque I · **8 h** · 26 ejercicios · plantilla de tema

## Alcance
El de la ficha F08, completo, más:
- 💀 **Boss del Bloque I — "La señora que es tres pacientes"**, pedido por Norma Castellani. Una
  paciente crónica repartida entre un DNI, una Libreta Cívica y el protocolo de su nieto recién
  nacido. Se entrega: la persona reconstruida con sus documentos, la fusión auditada y la historia
  de resultados unificada entre las tablas anchas y el EAV. Cruza F04, F05, F07 y F08.
- 🏆 La nota del boss global "Un martes", opcional.

## Qué vigilar
- **Los cuatro modelos se miden con la misma consulta y el mismo perfil.** Si uno gana porque tiene
  un índice que los otros no tienen, la medición no vale.
- **El EAV de Matías se trata con respeto**: él sabe que quedó mal terminado, y la fase lo dice en
  su voz.
- **El boss empieza con el sistema roto** y se escribe en la voz de Norma, no como un 🔴 largo.

{{protocolo}}
```

---

## # Fase 09 — El tamaño de las cosas

```markdown
Esta es la sesión de la **Fase 09 — 📦 El tamaño de las cosas**. Entregable:
`09-el-tamano-de-las-cosas.md`.

## Marco
El de F00, más el Bloque I cerrado y el modelo nuevo cargado en el perfil M.

## Identidad
- Fase 09 de 26 · Bloque II · **10 h** · 24 ejercicios · plantilla de tema

## Alcance
El de la ficha F09, completo.

## Qué vigilar
- **La operación queda fuera** (D2). El respaldo de seis horas se discute como tamaño de lo que hay
  que respaldar, no como herramienta de respaldo.
- **El terabyte no se genera.** Se razona desde el CSV de metadatos de la caja, con los tamaños.
- **El particionado entra como diseño** (*pruning*, desprender un mes), no como operación.

{{protocolo}}
```

---

## # Fase 10 — Identificadores

```markdown
Esta es la sesión de la **Fase 10 — 🔑 Identificadores**. Entregable: `10-identificadores.md`.

## Marco
El de F00, más F09 cerrada.

## Identidad
- Fase 10 de 26 · Bloque II · **10 h** · 26 ejercicios · plantilla de tema
- **MySQL es el caso central**, y es publicable.

## Alcance
El de la ficha F10, completo.

## Qué vigilar
- **"El ID opaco no arregla un IDOR"** queda escrito con esas palabras, y la corrección queda
  prometida para F23 (deuda 💸 con destino).
- **Qué filtra cada identificador** se demuestra: con el MD5, precalculando los hashes del rango de
  protocolos del perfil S; con el v7, extrayendo la fecha.
- **`uuidv7()`** solo si la versión del curso lo trae y se ejecutó.

{{protocolo}}
```

---

## # Fase 11 — Índices y lo que cuestan

```markdown
Esta es la sesión de la **Fase 11 — 🗂️ Índices y lo que cuestan**. Entregable:
`11-indices-y-lo-que-cuestan.md`.

## Marco
El de F00, más F10 cerrada.

## Identidad
- Fase 11 de 26 · Bloque II · **10 h** · **28 ejercicios**, la fase con más mecanismos
  independientes · plantilla de tema

## Alcance
El de la ficha F11, completo.

## Qué vigilar
- **El `AutoIndex` de Access** es comportamiento documentado del producto: cítalo con fuente, y si
  no la encuentras, dilo y escríbelo como "el comportamiento por defecto que describe la
  documentación de Access", sin la lista exacta.
- **El costo de escritura se mide en bytes de WAL**, no en tiempo.
- **El *skip scan*** solo si la versión lo trae y se ejecutó.

{{protocolo}}
```

---

## # Fase 12 — Estadísticas y cardinalidad

```markdown
Esta es la sesión de la **Fase 12 — 📊 Estadísticas y cardinalidad**. Entregable:
`12-estadisticas-y-cardinalidad.md`.

## Marco
El de F00, más F11 cerrada.

## Identidad
- Fase 12 de 26 · Bloque II · **10 h** · 24 ejercicios · plantilla de tema
- **El punto de rotura es un precipicio del plan** (D16).

## Alcance
El de la ficha F12, completo.

## Qué vigilar
- **Las estadísticas tienen muestreo**: dos corridas pueden dar planes distintos. Fija lo que haga
  falta (`default_statistics_target`, semilla del generador) para que la medición se reproduzca, y
  di qué fijaste.
- **El precipicio se busca con un barrido de volumen o de selectividad**, y se publica la tabla del
  barrido.

{{protocolo}}
```

---

## # Fase 13 — El optimizador en tres motores

```markdown
Esta es la sesión de la **Fase 13 — 🧠 El optimizador en tres motores**. Entregable:
`13-el-optimizador-en-tres-motores.md`.

## Marco
El de F00, más F12 cerrada.

## Identidad
- Fase 13 de 26 · Bloque II · **10 h** · 24 ejercicios · plantilla de tema
- **Es la fase con más Oracle del curso**, y por eso la más expuesta a la regla de publicación.

## Alcance
El de la ficha F13, completo.

## Qué vigilar
- **De Oracle se publica la estructura del plan, nunca sus estadísticas** (D6). *Bind peeking* y
  *baselines* se explican con la documentación oficial y se proponen como apuestas sin resolver.
- **`pg_hint_plan`** solo si está disponible en la imagen del curso; si no, la fase lo nombra y
  explica por qué Postgres no trae hints de serie.
- **El umbral de cinco ejecuciones** del plan genérico es comportamiento documentado de Postgres:
  verifícalo en la versión del curso antes de escribirlo.

{{protocolo}}
```

---

## # Fase 14 — La base no estaba lenta

```markdown
Esta es la sesión de la **Fase 14 — 🐢 La base no estaba lenta**. Entregable:
`14-la-base-no-estaba-lenta.md`. **Cierra el Bloque II: lleva el boss.**

## Marco
El de F00, más F13 cerrada.

## Identidad
- Fase 14 de 26 · Bloque II · **10 h** · 26 ejercicios · plantilla de tema

## Alcance
El de la ficha F14, completo, más:
- 💀 **Boss del Bloque II — "El portal de 2018"**, pedido por Verónica Colombo. El portal nuevo no
  puede ser enumerable, y la consulta del médico derivante no puede traerse la tabla entera. Se
  entrega: el esquema de identificadores, los índices, la paginación y la medición de cada consulta
  del portal. Cruza F10, F11, F13 y F14. La autorización queda fuera, para F23.
- 🏆 La nota del boss global, opcional.

## Qué vigilar
- **El frontal Access simulado en Python** tiene que reproducir el comportamiento de un formulario
  enlazado (traer la tabla, filtrar en el cliente), no una caricatura. Explica qué simula y qué no.
- **Se mide en viajes y filas transferidas contra mostradas.** El tiempo es contexto.

{{protocolo}}
```

---

## # Fase 15 — Aislamiento comparado

```markdown
Esta es la sesión de la **Fase 15 — 🔀 Aislamiento comparado**. Entregable:
`15-aislamiento-comparado.md`.

## Marco
El de F00, más el Bloque II cerrado y `lab race` descrito en `a04`.

## Identidad
- Fase 15 de 26 · Bloque III · **10 h** · 26 ejercicios · plantilla de tema

## Alcance
El de la ficha F15, completo.

## Qué vigilar
- **Toda anomalía se reproduce de forma determinista** con `lab race`, no "corriendo muchas veces
  hasta que salga". Si el arnés no lo permite para algún caso, para y dímelo.
- **La matriz anomalía × nivel × motor** se publica para Postgres y MySQL con lo observado, y para
  Oracle con lo que dice la documentación, marcada como tal.
- **El bucle de reintento** aparece en código, no solo nombrado.

{{protocolo}}
```

---

## # Fase 16 — El folio sin huecos

```markdown
Esta es la sesión de la **Fase 16 — 🔢 El folio sin huecos**. Entregable: `16-el-folio-sin-huecos.md`.

## Marco
El de F00, más F15 cerrada.

## Identidad
- Fase 16 de 26 · Bloque III · **10 h** · 26 ejercicios · plantilla de tema
- **La fase estrella del curso.** Se escribe pensando en que será el primer vídeo.

## Alcance
El de la ficha F16, completo.

## Qué vigilar
- **El web service fiscal simulado** tiene que responder como el real en lo que importa (el último
  autorizado más uno por punto de venta y tipo de comprobante, y el rechazo 10016). Lo que
  simplifica, lo declara.
- **El error 10016** está verificado en la historia (§8, manual de WSFEv1). Cítalo con esa fuente.
- **"Cuándo NO exigir numeración sin huecos"** es la mitad del valor de la fase. Que no quede como
  nota al pie.

{{protocolo}}
```

---

## # Fase 17 — MVCC y su factura

```markdown
Esta es la sesión de la **Fase 17 — ♻️ MVCC y su factura**. Entregable: `17-mvcc-y-su-factura.md`.

## Marco
El de F00, más F16 cerrada.

## Identidad
- Fase 17 de 26 · Bloque III · **10 h** · 24 ejercicios · plantilla de tema

## Alcance
El de la ficha F17, completo.

## Qué vigilar
- **`ORA-01555` se publica como mensaje** (entra a `a08`) y como apuesta sin resolver; la fase no
  dice en qué condiciones exactas salió en la máquina del autor.
- **El *wraparound*** es una advertencia, no un laboratorio: provocarlo exige volúmenes fuera del
  alcance.
- **El *bloat* se mide con `pgstattuple`** o con el tamaño de la relación, antes y después.

{{protocolo}}
```

---

## # Fase 18 — Bloqueos, deadlocks y DDL

```markdown
Esta es la sesión de la **Fase 18 — 🔐 Bloqueos, deadlocks y DDL**. Entregable:
`18-bloqueos-deadlocks-y-ddl.md`. **Cierra el Bloque III: lleva el boss.**

## Marco
El de F00, más F17 cerrada.

## Identidad
- Fase 18 de 26 · Bloque III · **10 h** · 26 ejercicios · plantilla de tema

## Alcance
El de la ficha F18, completo, más:
- 💀 **Boss del Bloque III — "Una tarde de julio"**, pedido por Matías Ledesma. Tres cajas, el web
  service que rechaza, una muestra asignada dos veces y un formulario que alguien dejó abierto.
  Se entrega: el diagnóstico de cada síntoma con su comando, el arreglo mínimo y la medición de que
  no vuelve a pasar. Cruza F15, F16, F17 y F18.
- 🏆 La nota del boss global, opcional.

## Qué vigilar
- **La cola de bloqueos detrás de un `ACCESS EXCLUSIVE`** se muestra con tres sesiones y
  `pg_locks`, no se describe.
- **La historia de "nos fuimos a Mongo"** es un escenario declarado, no un caso real con nombre.

{{protocolo}}
```

---

## # Fase 19 — JSON en los motores

```markdown
Esta es la sesión de la **Fase 19 — 🧾 JSON en los motores**. Entregable: `19-json-en-los-motores.md`.

## Marco
El de F00, más el Bloque III cerrado.

## Identidad
- Fase 19 de 26 · Bloque IV · **10 h** · 24 ejercicios · plantilla de tema

## Alcance
El de la ficha F19, completo.

## Qué vigilar
- **El antibiograma tiene que ser plausible** para un bioquímico: germen, antibióticos y
  sensibilidad (sensible, intermedio, resistente). Si el generador no lo produce, dímelo en el
  paso 1.
- **El JSON de MySQL** se muestra con las columnas generadas y los índices multivalor, que son su
  respuesta honesta a la falta de GIN.

{{protocolo}}
```

---

## # Fase 20 — La propuesta de Florencia, medida

```markdown
Esta es la sesión de la **Fase 20 — 🍃 La propuesta de Florencia, medida**. Entregable:
`20-la-propuesta-de-florencia.md`.

## Marco
El de F00, más F19 cerrada. Lee también las fases documentales de la NoSQL Lite
(`03-documental-levantar-y-modelar.md` y `04-documental-romper-y-medir.md`) y su compose: la
imagen de MongoDB debería ser la misma (D12).

## Identidad
- Fase 20 de 26 · Bloque IV · **10 h** · 26 ejercicios · plantilla de tema
- Motores: Postgres, **MongoDB** (publicable), Oracle Duality Views (sin resolver)

## Alcance
El de la ficha F20, completo.

## Qué vigilar
- **Florencia tiene que ganar en algo, con número**, y la fase lo concede sin letra chica. Si al
  medir no gana en nada, algo del planteo está mal: para y dímelo.
- **Su documento lo modela ella**, a la manera documental bien hecha, no como una tabla con
  llaves. Una versión mal modelada de Mongo no demuestra nada.
- **Las cinco operaciones se miden en los tres diseños**, con el mismo perfil.

{{protocolo}}
```

---

## # Fase 21 — Hasta dónde llega el motor

```markdown
Esta es la sesión de la **Fase 21 — 🔭 Hasta dónde llega el motor**. Entregable:
`21-hasta-donde-llega-el-motor.md`. **Cierra el Bloque IV: lleva el boss.**

## Marco
El de F00, más F20 cerrada. Ten a mano las fases de búsqueda, grafos y vectorial de la NoSQL Lite,
que esta fase enlaza en lugar de repetir.

## Identidad
- Fase 21 de 26 · Bloque IV · **10 h** · 24 ejercicios · plantilla de tema

## Alcance
El de la ficha F21, completo, más:
- 💀 **Boss del Bloque IV — "El informe en la app"**, pedido por Florencia Marchetti. Servir el
  informe a la app como documento, con búsqueda por paciente, sin perder la fuente relacional ni
  la auditoría. Se entrega: el diseño de la proyección, la medición de lectura y de corrección, y
  la decisión sobre Mongo. Cruza F19, F20 y F21.
- 🏆 La nota del boss global, opcional.

## Qué vigilar
- **Tres mecanismos en una fase** (búsqueda, recursión, vectores): cada uno con su rotura y su
  enlace a la Lite, sin convertirse en tres minifases.
- **`pgvector` es muestra breve**; si no aporta a Alameda, la fase lo dice y lo deja en una
  sección corta.

{{protocolo}}
```

---

## # Fase 22 — La exportación de las 9:40

```markdown
Esta es la sesión de la **Fase 22 — 🌙 La exportación de las 9:40**. Entregable:
`22-la-exportacion-de-las-9-40.md`. **La fase más larga del curso (15 h).**

## Marco
El de F00, más el Bloque IV cerrado.

## Identidad
- Fase 22 de 26 · Bloque V · **15 h** · 28 ejercicios · plantilla de tema
- Entorno: **SQL + Python**. El puente Java es el boss del bloque (D3), no esta fase.

## Alcance
El de la ficha F22, completo.

## Qué vigilar
- **Nada de broker aquí.** La fase mide hasta dónde llega la integración dentro de la base; el
  broker se mide en el boss del puente, contra la cola que esta fase deja escrita.
- **Los mensajes son filas**, con el identificador que después usará el puente. Si el formato del
  mensaje imita HL7 v2, se declara qué se simplifica.
- **La fila que pierde la marca de agua** se cuenta contra la verdad del generador, con dos
  transacciones concurrentes reproducibles.
- **El veredicto dice hasta dónde llega la cola en Postgres**, con número, y deja la pregunta del
  broker enlazada al boss del puente (deuda 💸 con destino en F23).

{{protocolo}}
```

---

## # Fase 23 — La base como producto

```markdown
Esta es la sesión de la **Fase 23 — 🔌 La base como producto**. Entregable:
`23-la-base-como-producto.md`. **Cierra el Bloque V: lleva el boss.**

## Marco
El de F00, más F22 cerrada. Perfiles `api` (PostgREST) y `puente` (Artemis y Java 21) del compose
verificados.

## Identidad
- Fase 23 de 26 · Bloque V · **15 h** · 26 ejercicios · plantilla de tema

## Alcance
El de la ficha F23, completo, más:
- 💀 **Boss del Bloque V — "Las 9:40"**, pedido por Verónica Colombo, en SQL y Python. La
  exportación nocturna y la notificación de doce horas pasadas a flujo, y el portal que tiene que
  dejar de ser un volcado nocturno. Se entrega: el flujo nuevo, la API con RLS y la medición de que
  ninguna fila se pierde ni se publica dos veces. Cruza F22 y F23.
- 💀☕ **Boss del puente — "El puente"**, pedido por Matías Ledesma, en **Java 21** con ActiveMQ
  Artemis (D3, D11). La interfaz con el SIH: órdenes que entran y resultados que vuelven, con
  mensajes que imitan HL7 v2 (`ORM` y `ORU`), duplicados, fuera de orden y un mensaje veneno. Se
  entrega: el servicio, la idempotencia hecha cumplir por la base y **la respuesta medida a
  "¿hacía falta un broker?"**, contra la cola de F22. Puede contestarse que sí.
- 🏆 La nota del boss global, opcional.

## Qué vigilar
- **Cierra la deuda de F10**: el IDOR se corrige aquí, con RLS, y la fase lo dice enlazando.
- **El boss del puente es el único Java del camino base.** Servicio chico, sin frameworks que
  oculten la transacción; el broker no es el tema, y si el texto empieza a explicar Artemis, corta
  y enlaza su documentación. Los mensajes imitan HL7 v2, no lo implementan: se declara qué se
  simplifica.
- **"Cuándo la lógica en la base es una cárcel"** usa el SIH como caso sin caricaturizarlo:
  Horizonte construyó eso por una buena razón (historia §3, 2022).

{{protocolo}}
```

---

## # Fases 24, 25 y 26 — El árbitro

```markdown
Esta es la sesión de la **Fase {{24|25|26}}**, del Bloque VI — El árbitro. Entregable:
`{{24-el-diseno.md | 25-la-migracion-sin-parar.md | 26-el-comite.md}}`.

## Marco
El de F00, más el Bloque V cerrado y **la bitácora completa**, que es la evidencia de este bloque.

## Identidad
- Fase {{NN}} de 26 · Bloque VI · **{{12|10|10}} h** · **{{22|24|20}} ejercicios** · plantilla del
  árbitro

## Alcance
El de la ficha F{{NN}}, completo. F26 cierra además el 🏆 boss global "Un martes".

## Qué vigilar
- **Ningún mecanismo nuevo.** Si la fase necesita enseñar algo que no se midió antes, falta en
  una fase anterior: dímelo, no lo metas aquí.
- **Cada argumento cita su entrada de la bitácora.** Lo de Oracle, como apuesta que el lector
  resolvió.
- **Verónica y Florencia pierden con dignidad**, o ganan donde ganan. El capstone no es una
  victoria de Postgres: es una decisión con su factura.
- **F26 cierra el curso**: el árbol de veredicto de cuándo **no** usar un motor relacional va
  entero, no resumido.

{{protocolo}}
```

---

## 🧾 Recordatorio de cierre del curso

Cuando F26 esté cerrada, y no antes: los README y `0-ESTRUCTURA-CURSO.md` en su propia tanda, y
después la verificación global, según el plan de producción. Los prompts del track están en
[`prompts-sqlserver-fase.md`](prompts-sqlserver-fase.md), y los de apéndices en
[`prompts-de-apendice.md`](prompts-de-apendice.md).
