# ✍️ Guía de estilo, tono y convenciones
## Portalón — el modelo clave-valor a fondo

> **Qué es este documento:** la fuente de verdad editorial del curso: **cómo** se escribe. Cualquier
> sesión que produzca un `.md` de Portalón la sigue, para que todas las fases se lean como escritas por la
> misma mano y apunten al mismo sitio: **que el lector decida qué estado vive en memoria, en qué motor, y
> lo defienda con números propios.**
> **Vigencia:** 2026-10-06. **Cerrada salvo lo que depende de la propuesta de fases**: la plantilla rígida
> de fase (§6.2) y las longitudes (§9), que se fijan con ella (§15).
> **Herencia:** se escribió con la guía de Ruta NoSQL Lite y la de Proteo como modelo, porque es la misma
> ruta y el lector viene de lite. Diverge de lite en: un solo dominio y una sola familia, una sola
> plantilla de fase, Mermaid, tiempos permitidos con dispersión, y la profundidad full geek. La guía de
> agosto (`_desechable-guia-de-estilo-v1.md`) queda de consulta.
> **Precedencia.** Por encima solo está [`alcance-del-proyecto.md`](alcance-del-proyecto.md). Por debajo
> van el contrato de nombres, el diccionario, las propuestas, las plantillas y los prompts. El `CLAUDE.md`
> del repositorio aplica en todo lo que este curso no haya declarado como excepción (§13).

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes tiene que
explicarle a una junta por qué el ranking se queda en memoria y las monedas no.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio qué vive en memoria, y lo pueda
defender con números propios, incluido lo que pasa dentro del motor.**

No enseñamos Redis como producto ni formamos administradores. Formamos la capacidad de mirar un sistema,
reconocer qué estado es caliente, efímero o reconstruible, modelarlo con la estructura nativa que le
corresponde, medir lo que cuesta y saber qué hace el motor cuando lo aprietan.

El filtro para cada párrafo: **¿esto ayuda a modelar, a medir, a diagnosticar o a decidir?** Si no, sobra.

> 🧠 **Primero la forma, después el reloj.** En este modelo la latencia importa más que en ningún otro de
> la ruta, y justamente por eso nunca se publica sola: va con los viajes, los bytes y la dispersión.

### 1.1 Qué NO es este curso

No es un curso de Redis desde cero, ni una preparación de certificación, ni un curso de administración.
No repite Ruta NoSQL Lite: lo que lite enseñó de clave-valor se **usa** sin volver a explicarlo.

### 1.2 Requisitos y autocontención

Lo publicado nombra Ruta NoSQL Lite **solo como requisito de entrada**, en el README y en la primera
fase. **No usa su contenido**: no remite a sus fases, no reutiliza sus ejemplos, sus datos ni sus
mediciones; si el curso necesita algo que lite enseñó, lo da por sabido o lo dice con sus propias
palabras y con Liga Pixel (D-03). Ningún documento publicado cita otros cursos de la ruta ni el
`CLAUDE.md` del repositorio.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien: un colega que estuvo de guardia en la final
y te lo cuenta con paciencia.

- **Tuteo latinoamericano, siempre.** *"Provoca el failover y cuenta cuántos canjes sobrevivieron"*. Nada
  de voseo, nada de "usted", nada de impersonal permanente.
- **Semiformal.** Frases completas, cero abreviaturas de mensajería.
- **Humor seco y con moderación.** Máximo un chiste por sección; el blanco es la situación (el "ahorita"
  de Jorge), nunca una persona.
- **Cálido sin condescendencia.** El lector es senior y ya hizo lite.
- **Honesto sobre lo feo.** Si PostgreSQL gana, si Valkey en un hilo empata con el motor multihilo en la
  carga de Liga Pixel, se dice con esas palabras y con el número delante.

### 2.1 El tono de las autopsias

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. Las monedas en memoria las
puso Iván, con buenos argumentos, y el ranking en memoria —también suyo— fue la mejor decisión de la
casa. Si un párrafo suena a *"quien guardó el saldo en Redis no sabía"*, el curso pierde a su mejor
personaje y al lector que hizo algo parecido.

Se escribe en este orden: la decisión con su mejor argumento; por qué era razonable entonces; qué pasó
después, con número; cuánto cuesta salir, con número; qué pregunta, hecha a tiempo, habría cambiado el
resultado. Lo que nunca aparece: "obviamente", "cualquiera habría visto", "error de novato".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro** para todo lo que no sea código o salida de terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *sorted set*,
  *hash*, *stream*, *pipeline*, *fork*, *copy-on-write*, *hash slot*, *hash tag*, *failover*, *replication
  backlog*, *eviction*, *listpack*, *client-side caching*, *hot key*, *token bucket*. Los que tienen
  traducción asentada —clave, valor, réplica, clúster, memoria, latencia, ventana— se alternan con
  naturalidad. **No se inventa vocabulario.**
- **Markdown siempre**, sin HTML embebido. **Prosa antes que listas.** Una frase aislada por sección, dos
  si es larga.
- **Tablas solo para lo tabular y corto**: comparación de motores, algoritmos de límite, memoria por
  codificación, resultados.
- **Diagramas en Mermaid** (D-12): el recorrido de un request por el gateway, la réplica y el failover,
  el reparto de slots, el ciclo del caché del cliente. Árboles y salidas en `text`.
- **Salida de terminal literal**, en `text`, sin recortar la parte incómoda (sobre todo la de `INFO`).
- **Encabezados con emoji, con moderación.**

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior, relacional de oficio y ya pasó por lite: **no explicar lo que ya sabe, y no dejar
ambiguo nada de lo que no.**

### 4.1 La regla del andamio

1. **El problema primero**, siempre en Liga Pixel: *"Ochenta mil espectadores, dos consultas por segundo
   cada uno, una sola clave. ¿Cuántos comandos por segundo recibe el nodo que la tiene? Apúntalo antes de
   ejecutar."*
2. **El mecanismo después**: el nombre y la definición mínima.
3. **El comando que corre**, con su salida real y el campo de `INFO` o de `MEMORY USAGE` señalado.

### 4.2 Del instinto se parte, no se reniega

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios del relacional: una operación
  atómica sigue siendo atómica, un índice sigue costando memoria, una réplica sigue pudiendo atrasarse.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"** — el relacional (*"lo arreglo con una transacción"*) o
  el que lite dejó demasiado firme (*"en memoria todo es instantáneo"*). **Una por fase como mínimo.**
- ⚖️ **"Y aquí el instinto SQL tenía razón"** — las preguntas donde el veredicto va en la otra dirección:
  el saldo de monedas, la consulta que nadie anticipó. Sin este recuadro el curso sonaría a folleto.

### 4.3 Nada de cajas negras prematuras

Primero `redis-cli`/`valkey-cli` y el comando a pelo; después el cliente. Primero `INFO memory` y
`MEMORY USAGE`; después la herramienta que los dibuja. Si se habla del fork, se muestra el campo que mide
cuánto tardó.

### 4.4 Analogías, con fecha de caducidad

Una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del curso:
**"`MULTI`/`EXEC` es una transacción"**. Se desmonta en el mismo párrafo: no hay rollback, y lo que
garantiza es aislamiento de ejecución, no durabilidad.

### 4.5 Explica el porqué

Cada decisión lleva su porqué: por qué este algoritmo de límite, por qué esta estructura, por qué esta
etiqueta de clave en el clúster, por qué esta política de evicción.

### 4.6 Densidad calibrada

Un concepto nuevo por vez. Ninguna sección teórica supera las dos pantallas sin un comando, una medición
o un diagrama. Reaparecen con otras palabras: la pregunta del curso, "caliente, efímero o reconstruible",
la réplica asíncrona y "PostgreSQL es la base de verdad".

### 4.7 Cierra los bucles

Todo paréntesis abierto —*"esto lo pagamos en el bloque del clúster"*, *"deuda 💸"*— se cierra.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —archivos, rutas, variables,
> identificadores, nombres de clave— y **todos los comentarios van en español con tildes**. Los mensajes
> que ve un jugador van en español: la clave en inglés, el valor en español.

- **Código ejecutable y mínimo**, que corre de punta a punta con las versiones fijadas.
- **Comentarios que explican el porqué**: `// el script lee y descuenta en un solo paso: nadie se mete en
  medio` sí; `// descuenta` no.
- **Bloques con su lenguaje declarado**: `ts`, `lua`, `bash` (para `valkey-cli`), `sql`, `yaml`, `text`.
- **Un bloque, una idea.** **Nunca `foo`, `bar` ni `test1`**: todo usa Liga Pixel.

### 5.1 Versiones fijadas

**Digest, no tag**, con el tag legible en un comentario. **Ninguna versión se escribe de memoria**, y
hasta la verificación previa ningún documento publica un número de versión (§15). **Lo no verificado se
dice con esas palabras**: si un motor no corre nativo en arm64 y se midió emulado, la medición lo dice.

### 5.2 Los nombres del dominio

Fijos en todo el curso y en inglés. Hasta que exista el contrato de nombres, estos son los vigentes:

| En la narrativa | En el código |
|---|---|
| jugador, cuenta | `player`, `account` |
| torneo, temporada | `tournament`, `season` |
| partida (ranked) | `match` |
| ranking | `leaderboard` |
| nivel | `rating` |
| cola de emparejamiento | `matchmaking` |
| sesión de partida | `matchSession` |
| límite | `rateLimit` |
| monedas Pixel, saldo | `coins`, `balance` |
| premio, inventario, canje | `prize`, `inventory`, `redemption` |
| editor, webhook | `publisher`, `matchReport` |
| overlay | `overlay` |

**Las claves llevan prefijo de dominio y separador `:`**, en inglés y en minúsculas:
`leaderboard:{tournamentId}`, `ratelimit:ip:{ip}`, `matchsession:{sessionId}`. Las tablas de PostgreSQL,
en `snake_case` y plural. Una fase no renombra una clave ni una entidad: si necesita una nueva, la declara
y se agrega aquí y en la historia.

### 5.3 El villano también va en inglés

Las claves del villano se nombran como estaban en Liga Pixel —`player:{id}` como hash con el campo
`coins`, `inventory:{prizeId}` con el campo `stock`—. Su olor es **de arquitectura**: un saldo con valor
de dinero en un motor con réplica asíncrona, sin consultas que no se anticiparon, sin conciliación.

### 5.4 Nombres de archivo del curso

Fases `NN-slug.md`; apéndices `aNN-slug.md`; la historia `00-historia-de-liga-pixel.md`; documentos vivos
en la raíz (§7). Minúsculas y guiones, salvo `README.md`, `INSTINTOS.md` y `BENCHMARKS.md`.

---

## 6. 🧱 La plantilla de los documentos

> 🚧 **Preliminar:** la plantilla rígida de fase se fija con la propuesta de fases. Punto de partida, el
> mismo de Proteo: una sola plantilla que modela **y** mide.

### 6.1 Encabezado obligatorio de fase

```markdown
# 🔑 Fase 02 — El ranking de la final: novecientos mil jugadores en una clave

> **Curso:** Portalón · Fase 02 de NN · Bloque I · **10 h**
> **Motor:** Valkey `valkey@sha256:…` · **Base de verdad:** PostgreSQL `postgres@sha256:…`
> **Rivales en esta fase:** {{Redis 8 · Dragonfly · Garnet · ninguno}}
> **Topología:** {{un nodo · primario y réplica · clúster}}
> **Volumen:** {{los del laboratorio}}
> **Depende de:** Fase 01 · **Habilita:** Fase 03
> **Fecha de verificación ejecutada:** DD/MM/AAAA
> **Objetivo:** …
```

El título nombra el dolor de Liga Pixel, no el comando.

### 6.2 Secciones de una fase (punto de partida)

1. Título y encabezado
2. 🧭 **Dónde estamos** — qué dejó la fase anterior, y el dolor de Liga Pixel que abre esta
3. 🎯 **Objetivos**, verificables
4. 🚫 **Qué NO entra todavía**, con destino
5. 🧩 **El modelo** — la estructura, la clave y el porqué
6. 🪞 **La apuesta**, escrita antes de medir
7. 📐 **La medición** contra PostgreSQL y, cuando toca, contra los rivales
8. 💥 **El punto de rotura**, con volumen y mensaje literal
9. ⚖️ **Veredicto honesto: cuándo NO hacer esto**
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable
12. 🧪 **Ejercicios** (§8)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

Después, fuera de lo que lee el estudiante, puede ir **📌 Pendientes sugeridos**.

### 6.3 Cómo se presenta una medición

**Toda medición se publica con cinco datos**: qué se midió (en forma estructural primero), sobre qué
volumen, con qué motor, digest y topología frente a qué alternativa, en qué máquina si hay tiempos, y el
comando exacto para reproducirla.

```markdown
> 📐 **Medición — posición de un jugador en el ranking de la final** · 900 k miembros ·
> `valkey@sha256:…` en un nodo frente a `postgres@sha256:…` · verificado el DD/MM/AAAA · {{máquina}}
>
> | | viajes | memoria de la estructura | p50 | p95 | p99 |
> |---|---|---|---|---|---|
> | sorted set | 1 | … | … | … | … |
> | PostgreSQL con índice | 1 | … | … | … | … |
>
> Reproducir: `node scripts/measure.ts leaderboard-rank --members 900k`
```

**Los tiempos van con su dispersión** (mediana, p95 y p99, repeticiones y calentamiento declarados) y la
máquina, **y nunca sostienen solos un veredicto** (D-20). En una comparación de motores, la medición
declara además la configuración de hilos de cada uno (D-25). La 🪞 apuesta se escribe antes y no se edita.

---

## 7. 📐 Los tipos de documento y su coherencia

- **Fases**, **apéndices** y la **historia**, documento del lector y fuente de verdad narrativa: ningún
  dato de Liga Pixel se inventa en una fase.
- **Documentos vivos** en la raíz, que son producto: `INSTINTOS.md` (cada 🪞 con su medición),
  **`BENCHMARKS.md`** (toda medición publicada, con los cinco datos de §6.3) y el catálogo de errores con
  su mensaje literal (si es apéndice o documento aparte, lo dice la propuesta de apéndices).
- **Los apéndices no repiten una fase, y viceversa: se enlazan.** **Una fase no cita el temario ni el
  plan.** 🗑️ **Los `_desechable-*` no se citan nunca.**
- **Git:** tags `fase-NN-<slug>`, prefijo de commit `fNN:`, ejercicios `fNN ejM: …` (D-09).

---

## 8. 🧪 Evaluación: ejercicios

- **Cantidad: 20 mínimo y 30 máximo por fase**, calibrada con *"¿cuántas cosas distintas enseña esta fase
  que se puedan comprobar por separado?"*.
- **La escala:** 🟢 reproducir · 🟡 aplicar el patrón a otra parte de Liga Pixel · 🟠 combinar,
  diagnosticar, decidir · 🔴 abierto o adversarial · 🔥 extra, fuera del mínimo.
- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen; el bloque del motor por dentro carga
  hacia 🟠 y 🔴.
- **Al menos un tercio de diagnóstico o medición**: un límite que se burla por el borde, una clave que
  cambió de codificación, un nodo con el backlog corto, un hot key, y se pide reproducir, medir y explicar.
- **Predecir antes de ejecutar** en 🟠 y 🔴. **Cada ejercicio cierra con su criterio** (`Objetivo` o
  `Pregunta`). **Agrupados por dificultad**, con el conteo en el título.
- **Sin solución publicada** (D-05). **Taller global:** el gateway de Liga Pixel en `src/`.
- **💀 Boss de bloque**, cuando el bloque lo admita: un sistema roto o un encargo completo de alguien de
  Liga Pixel (con nombre, de la historia §2), que cruza al menos dos fases y se entrega como artefacto.

---

## 9. 📏 Longitud y densidad

> 🚧 **Preliminar**, a fijar con la propuesta de fases. Punto de partida para una fase de 10 h: **4.000–5.000
> palabras de cuerpo**, contadas hasta el encabezado de 🧪 Ejercicios. Los apéndices son cortos, con
> índice de salto rápido, una tabla de "cuándo usar qué" y de 5 a 10 ejercicios de consulta.

---

## 10. 📚 Referencias y enlaces

### 10.1 Enlaces externos

**Orden de prioridad:** documentación oficial de la versión que usamos (Valkey, Redis, Dragonfly, Garnet,
PostgreSQL, `iovalkey`); después especificaciones (RESP3, la especificación del clúster) y papers o
documentos de arquitectura de cada motor; después libros; después blogs y videos. **Siempre se advierte
cuando un enlace apunta a otra versión**, y con las licencias se cita la fecha de la consulta. Cada URL se
comprueba por código de estado en la sesión que la escribe.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: antes de ejecutar, durante y
después.

### 10.2 Enlaces internos y anclas

Rutas relativas; anclas comprobadas; **ningún enlace a un documento que todavía no existe**.

### 10.3 Vigencia

Las secciones de referencias advierten que las URL y los contenidos cambian, y que estos proyectos cambian
de licencia y de gobernanza: se cita la fecha.

---

## 11. 🧷 Vocabulario visual

**Marcadores de estado:** 💸 deuda intencional (con fase de pago) · 🔥 opcional · 🚧 fuera de alcance por
ahora, con destino · 🟢🟡🟠🔴 dificultad · ⭐ valoración bibliográfica, solo en referencias.

**Callouts en blockquote:** 📐 **Medición** (§6.3) · 🪞 **Apuesta / instinto que falla** · 💥 **Punto de
rotura** · ⚰️ **Autopsia** · ⚖️ **Veredicto honesto** y **"Y aquí el instinto SQL tenía razón"** · 🩻
**Esto sí funciona igual** · 📖 **Traducción** SQL ↔ comandos del motor, en tabla · 🧠 **Modelo mental** ·
⚠️ **Advertencia** · 📝 **Nota de contexto** (licencias, gobernanza, historia de un proyecto) · 💡
**Truco** · 🩺 **Diagnóstico**, el comando que confirma o descarta una hipótesis.

**Secciones narrativas recurrentes:** *Dónde estamos* · *Detalles con intención* · *El patrón a
memorizar* · *Prueba de fuego* · *La señal de que quedó bien*.

---

## 12. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El encabezado está completo, con motor, digest, topología y fecha de verificación
[ ] La fase abre con un dolor de Liga Pixel que está en la historia
[ ] Ningún dato de la empresa se inventó en la fase (si hacía falta, se agregó a la historia)
[ ] Nada de lo que Ruta NoSQL Lite ya enseñó se explicó de nuevo; ninguna remisión a sus fases
[ ] Todo número salió de una ejecución real; lo emulado o no verificado está declarado
[ ] Toda medición trae los cinco datos de §6.3; los tiempos, con mediana, p95 y p99
[ ] En una comparación de motores, la configuración de hilos de cada uno está declarada
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] PostgreSQL aparece como base de verdad seria, no como adorno
[ ] Hay un ⚖️ veredicto con la pérdida cuantificada
[ ] Ninguna autopsia juzga a una persona
[ ] Las mediciones, los errores y el 🪞 entraron en sus documentos vivos
[ ] Ejercicios: 20–30, agrupados, con conteo, un tercio de diagnóstico, cada uno con Objetivo o Pregunta
[ ] Los diagramas están en Mermaid; los árboles y salidas, en text
[ ] Tuteo en todo el documento; cero voseo, cero "usted"
[ ] Código en inglés, comentarios en español con tildes
[ ] Ningún enlace a un documento que no existe; grep -ln "_desechable-" *.md no devuelve nada
```

---

## 13. ⚖️ Excepciones declaradas

1. **Ruta NoSQL Lite como prerrequisito** (D-14) → no se explican los fundamentos de clave-valor → los da
   lite, y repetirlos sería el curso que el lector ya hizo.
2. **Los ejercicios no traen solución publicada** (D-05) → el método del curso es apostar y medir antes de
   mirar, y cada ejercicio trae su criterio.

Todo lo demás del `CLAUDE.md` aplica tal cual.

---

## 14. 🧪 Laboratorio

- **Docker Compose es el camino principal**; cada receta trae su equivalente en Podman. **Aquí no se enseña
  Docker. Sin Kubernetes.**
- **Perfiles de Compose** para no pasar de 16 GB: Valkey, PostgreSQL y el arnés siempre; **un rival a la
  vez** cuando la fase compara; el clúster solo en su bloque (D-21, D-22).
- **Los rivales con su configuración documentada**, nunca con la de otro motor (D-25). Si uno no corre
  nativo en arm64, se declara (D-27).
- **Servicios nombrados por papel** (`memoria`, `memoria-rival`, `relacional`), para que cambiar de motor no
  rompa los comandos escritos.
- **Datos sintéticos con semilla fija** y los simuladores de editores, bots y overlay (D-24, D-28).
- **Las pruebas de la producción** corren en contenedores etiquetados con el curso y en puertos altos
  aleatorios; el código de las sesiones va a `zz-code/` con su README.

---

## 15. 📌 Pendientes que afectan a esta guía

- **La plantilla rígida de fase (§6.2) y las longitudes (§9)** se fijan con la propuesta de fases. Todas
  las decisiones del alcance están cerradas (06/10/2026).
- **El diccionario de términos y el contrato de nombres** se escriben después de la propuesta de fases;
  hasta entonces mandan §3 y §5.2.
- **Versiones, digests y licencias sin fijar** hasta la verificación previa.
- **El verificador del curso** se copia de `zz-instrucciones/herramientas/` y se ajusta cuando la plantilla
  de fase esté fijada.
