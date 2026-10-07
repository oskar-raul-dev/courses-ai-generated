# ✍️ Guía de estilo, tono y convenciones
## Telaraña — el modelo de grafos a fondo

> **Qué es este documento:** la fuente de verdad editorial del curso: **cómo** se escribe. Cualquier
> sesión que produzca un `.md` de Telaraña la sigue, para que todas las fases se lean como escritas por
> la misma mano y apunten al mismo sitio: **que el lector decida qué pregunta es un recorrido y cuál una
> tabla, dónde se evalúa cada una, y lo defienda con números propios.**
> **Vigencia:** 2026-10-06. **Cerrada salvo lo que depende de la propuesta de fases**: la plantilla rígida
> de fase (§6.2) y las longitudes (§9), que se fijan con ella (§15).
> **Herencia:** se escribió con la guía de Ruta NoSQL Lite y las de los cursos anteriores de la ruta como
> modelo, porque es la misma ruta y el lector viene de lite. Diverge de lite en: un solo dominio y una
> sola familia, una sola plantilla de fase, Mermaid, tiempos permitidos con dispersión, la profundidad
> full geek y **lo encontrado contra lo sembrado como primera medida**. La guía de agosto
> (`_desechable-guia-de-estilo-v1.md`) queda de consulta.
> **Precedencia.** Por encima solo está [`alcance-del-proyecto.md`](alcance-del-proyecto.md). Por debajo
> van el contrato de nombres, el diccionario, las propuestas, las plantillas y los prompts. El `CLAUDE.md`
> del repositorio aplica en todo lo que este curso no haya declarado como excepción (§13).

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que el lunes tiene que
explicarle a un banco aliado por qué las reglas del pago salen del grafo y los anillos se quedan.

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que alguien decida con criterio qué pregunta merece un grafo y dónde se
evalúa, y lo pueda defender con números propios, incluido lo que pasa dentro del motor.**

No enseñamos Neo4j como producto ni formamos analistas de fraude. Formamos la capacidad de mirar una
pregunta, contar sus saltos, ver si su profundidad es fija o variable, escribirla donde le corresponde,
medir lo que encuentra y lo que cuesta, y saber qué hace el motor cuando lo aprietan.

El filtro para cada párrafo: **¿esto ayuda a modelar, a medir, a diagnosticar o a decidir?** Si no,
sobra.

> 🧠 **Primero cuántos saltos, después qué motor.** En este modelo el veredicto depende de la
> profundidad y del tamaño del vecindario. Por eso un número nunca se publica sin `k` al lado, y una
> detección nunca se publica sin lo que encontró contra lo que se sembró.

### 1.1 Qué NO es este curso

No es un curso de Cypher desde cero, ni de Neo4j como producto, ni de prevención de fraude, ni de
aprendizaje automático sobre grafos. No repite Ruta NoSQL Lite: lo que lite enseñó de grafos se **usa**
sin volver a explicarlo.

### 1.2 Requisitos y autocontención

Lo publicado nombra Ruta NoSQL Lite **solo como requisito de entrada**, en el README y en la primera
fase. **No usa su contenido**: no remite a sus fases, no reutiliza sus ejemplos, sus datos ni sus
mediciones; si el curso necesita algo que lite enseñó, lo da por sabido o lo dice con sus propias
palabras y con Quetzal Pay (D-03). Ningún documento publicado cita otros cursos de la ruta ni el
`CLAUDE.md` del repositorio.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, con humor cuando cae bien: un colega que estuvo de guardia la quincena
de diciembre y te lo cuenta con paciencia.

- **Tuteo latinoamericano, siempre.** *"Provoca el atraso del conector y cuenta cuántos pagos pasan antes
  de que el grafo se entere"*. Nada de voseo, nada de "usted", nada de impersonal permanente.
- **Semiformal.** Frases completas, cero abreviaturas de mensajería.
- **Humor seco y con moderación.** Máximo un chiste por sección; el blanco es la situación (el "chilero"
  de Kevin hasta que no), nunca una persona.
- **Cálido sin condescendencia.** El lector es senior y ya hizo lite.
- **Honesto sobre lo feo.** Si PostgreSQL gana, si AGE alcanza, si un algoritmo marca más inocentes que
  mulas, se dice con esas palabras y con el número delante.
- **Sobrio con el fraude.** El curso enseña a detectar patrones sembrados en datos sintéticos; nunca
  describe cómo cometer un fraude más allá de lo que el patrón necesita para ser detectado.

### 2.1 El tono de las autopsias

⚰️ Una autopsia se escribe sobre una **decisión**, jamás sobre una persona. Las reglas en el grafo las puso
Esteban, con buenos argumentos, y el grafo —también suyo— le dio a Lucía lo que el papel no podía; "aprobar
todo" lo decidió producto para no dejar a un comerciante esperando. Si un párrafo suena a *"quien metió las
reglas en el grafo no sabía"*, el curso pierde a su mejor personaje y al lector que hizo algo parecido.

Se escribe en este orden: la decisión con su mejor argumento; por qué era razonable entonces; qué pasó
después, con número; cuánto cuesta salir, con número; qué pregunta, hecha a tiempo, habría cambiado el
resultado. Lo que nunca aparece: "obviamente", "cualquiera habría visto", "error de novato".

---

## 3. 🗣️ Idioma y forma de la narrativa

- **Español latinoamericano neutro** para todo lo que no sea código o salida de terminal.
- **Los términos del oficio se quedan en inglés** cuando son el nombre real de la cosa: *index-free
  adjacency*, *page cache*, *db hits*, *eager*, *quantified path pattern*, *supernode*, *dense node*,
  *shortest path*, *PageRank*, *Louvain*, *weakly connected components*, *node similarity*,
  *betweenness*, *projection*. Los que tienen traducción asentada —nodo, relación, arista, camino, ciclo,
  salto, vecindario, componente, comunidad, centralidad— se alternan con naturalidad. **No se inventa
  vocabulario.**
- **"Relación" en el sentido del grafo** se escribe *relación* o *arista*; cuando haga falta hablar de la
  relación del modelo relacional, se dice *tabla*.
- **Markdown siempre**, sin HTML embebido. **Prosa antes que listas.** Una frase aislada por sección, dos
  si es larga.
- **Tablas solo para lo tabular y corto**: comparación de motores, resultados por profundidad, la
  traducción SQL ↔ Cypher.
- **Diagramas en Mermaid** (D-12): grafos de ejemplo pequeños, el recorrido de un pago por el antifraude,
  el conector y su atraso, la forma de un anillo. Árboles de archivos y salidas en `text`.
- **Salida de terminal literal**, en `text`, sin recortar la parte incómoda (sobre todo la del perfil y la
  de una consulta que no termina).
- **Encabezados con emoji, con moderación.**

---

## 4. 🎓 Pedagogía: cómo se explica

El público es senior, relacional de oficio y ya pasó por lite: **no explicar lo que ya sabe, y no dejar
ambiguo nada de lo que no.**

### 4.1 La regla del andamio

1. **El problema primero**, siempre en Quetzal Pay: *"La tablet de un agente de Huehuetenango tiene tres mil
   ochocientas cuentas. La regla pide las cuentas a dos saltos de una sospechosa por dispositivo. ¿Cuántas
   filas intermedias va a tocar? Apúntalo antes de ejecutar."*
2. **El mecanismo después**: el nombre y la definición mínima.
3. **La consulta que corre**, con su salida real y la línea del perfil señalada.

### 4.2 Del instinto se parte, no se reniega

- 🩻 **"Esto sí funciona igual"** — lo que se transfiere sin cambios del relacional: el índice decide el
  punto de partida, la selectividad manda, el plan se lee, la transacción protege lo mismo.
- 🪞 **"Tu instinto dice… y esta vez se equivoca"** — el relacional (*"un ciclo con condiciones no se
  puede escribir en SQL"*), el de la conferencia (*"si es fraude, es grafo"*) o el que lite dejó demasiado
  firme (*"la adyacencia sin índice hace todo salto barato"*). **Una por fase como mínimo.**
- ⚖️ **"Y aquí el instinto SQL tenía razón"** — las preguntas donde el veredicto va en la otra dirección:
  las reglas de un salto, el conteo por cuenta, la consulta que el conector hace llegar tarde. Sin este
  recuadro el curso sonaría a folleto.

### 4.3 Nada de cajas negras prematuras

Primero `cypher-shell`, `mgconsole` y `psql` con la consulta a pelo; después el driver y el servicio.
Primero `PROFILE` y `EXPLAIN ANALYZE`; después la herramienta que los dibuja. Si se habla del supernodo, se
muestra su grado y los accesos que cuesta atravesarlo.

### 4.4 Analogías, con fecha de caducidad

Una vez, para abrir la puerta, y se abandonan diciendo dónde se rompen. La más peligrosa del curso:
**"un algoritmo de comunidades encuentra los anillos"**. Se desmonta en el mismo párrafo: encuentra
grupos densos; que un grupo denso sea un anillo de fraude lo decide la regla de negocio y lo mide la verdad
sembrada.

### 4.5 Explica el porqué

Cada decisión lleva su porqué: por qué este límite de profundidad, por qué esta dirección de la relación,
por qué agregar o no las aristas, por qué esta regla dentro del pago y esa fuera.

### 4.6 Densidad calibrada

Un concepto nuevo por vez. Ninguna sección teórica supera las dos pantallas sin una consulta, una medición
o un diagrama. Reaparecen con otras palabras: la pregunta del curso, "cuántos saltos", "el grafo es un
derivado" y "lo encontrado contra lo sembrado".

### 4.7 Cierra los bucles

Todo paréntesis abierto —*"esto lo pagamos en el bloque de los motores"*, *"deuda 💸"*— se cierra.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —archivos, rutas, variables,
> identificadores, etiquetas, tipos de relación, propiedades, tablas— y **todos los comentarios van en
> español con tildes**. Lo que ve un usuario de la billetera o Lucía en una alerta va en español.

- **Código ejecutable y mínimo**, que corre de punta a punta con las versiones fijadas.
- **Comentarios que explican el porqué**: `// se corta en la tablet del agente: pasar por ella no dice nada
  de la cuenta` sí; `// filtra agentes` no.
- **Bloques con su lenguaje declarado**: `ts`, `cypher`, `sql`, `bash`, `kotlin` (solo en el apéndice),
  `yaml`, `text`.
- **Un bloque, una idea.** **Nunca `foo`, `bar`, `n1` ni `test1`**: todo usa Quetzal Pay.
- **Cypher siempre con parámetros**, nunca con valores concatenados.

### 5.1 Versiones fijadas

**Digest para las imágenes y archivo de bloqueo para las librerías y los plugins**, con la versión legible
en un comentario. **Ninguna versión se escribe de memoria**, y hasta la verificación previa ningún
documento publica un número de versión (§15). **Lo no verificado se dice con esas palabras**: si una
imagen no corre nativa en arm64 y se midió emulada, la medición lo dice; si una función de Cypher no
existe en uno de los motores, se dice cuál y desde qué versión.

### 5.2 Los nombres del dominio

Fijos en todo el curso y en inglés. Hasta que exista el contrato de nombres, estos son los vigentes:

| En la narrativa | En el grafo | En PostgreSQL |
|---|---|---|
| cuenta, nivel de verificación | `Account` (`kycLevel`) | `accounts` |
| transferencia | `TRANSFERRED_TO` (`amount`, `at`, `transferId`) | `transfers` |
| comercio, pago a comercio | `Merchant`, `PAID` | `merchants`, `payments` |
| remesa | `REMITTANCE_TO` | `remittances` |
| agente, retiro | `Agent`, `WITHDREW_AT` | `agents`, `withdrawals` |
| dispositivo, teléfono, dirección | `Device`, `Phone`, `Address`; `USED_DEVICE`, `HAS_PHONE`, `REGISTERED_AT` | `devices`, `phones`, `addresses` y sus tablas puente |
| referido | `REFERRED` | `referrals` |
| regla, alerta | — | `rules`, `alerts` |

**En el grafo, etiquetas en `PascalCase`, tipos de relación en `UPPER_SNAKE_CASE` y propiedades en
`camelCase`; en PostgreSQL, tablas en `snake_case` y plural.** La misma entidad lleva el mismo nombre de
identificador en los dos mundos (`accountId` ↔ `account_id`). Una fase no renombra una etiqueta ni una
tabla: si necesita una nueva, la declara y se agrega aquí y en la historia.

### 5.3 El villano también va en inglés

El código del villano se nombra como estaba en Quetzal Pay: `paymentRules.cypher` con las cuarenta reglas,
`nightlyRingSearch.ts`, el conector `pgToGraphSync.ts` y la bandera `APPROVE_ON_TIMEOUT`. Su olor es **de
arquitectura**: un recorrido de un salto lejos del dato, un trabajo pesado en el mismo servidor que el
pago, un grafo tratado como fuente de verdad.

### 5.4 Nombres de archivo del curso

Fases `NN-slug.md`; apéndices `aNN-slug.md`; la historia `00-historia-de-quetzal-pay.md`; documentos vivos
en la raíz (§7). Minúsculas y guiones, salvo `README.md`, `INSTINTOS.md` y `BENCHMARKS.md`.

---

## 6. 🧱 La plantilla de los documentos

> 🚧 **Preliminar:** la plantilla rígida de fase se fija con la propuesta de fases. Punto de partida, el
> mismo de los cursos anteriores de la ruta: una sola plantilla que modela **y** mide.

### 6.1 Encabezado obligatorio de fase

```markdown
# 🕸️ Fase 04 — El anillo con reloj

> **Curso:** Telaraña · Fase 04 de NN · Bloque II · **10 h**
> **Motor:** Neo4j `neo4j@sha256:…` · **Base de verdad:** PostgreSQL `postgres@sha256:…`
> **Rivales en esta fase:** {{Memgraph · Apache AGE · PostgreSQL con WITH RECURSIVE · ninguno}}
> **Volumen y redes sembradas:** {{los del laboratorio}}
> **Depende de:** Fase 03 · **Habilita:** Fase 05
> **Fecha de verificación ejecutada:** DD/MM/AAAA
> **Objetivo:** …
```

El título nombra el dolor de Quetzal Pay, no la cláusula de Cypher.

### 6.2 Secciones de una fase (punto de partida)

1. Título y encabezado
2. 🧭 **Dónde estamos** — qué dejó la fase anterior, y el dolor de Quetzal Pay que abre esta
3. 🎯 **Objetivos**, verificables
4. 🚫 **Qué NO entra todavía**, con destino
5. 🧩 **El patrón** — la pregunta, sus saltos, el modelo y la consulta en los dos mundos
6. 🪞 **La apuesta**, escrita antes de medir
7. 📐 **La medición**: lo encontrado, la forma y el tiempo, por profundidad
8. 💥 **El punto de rotura**, con volumen y mensaje literal
9. ⚖️ **Veredicto honesto: cuándo NO hacer esto**
10. ⚠️ **Errores comunes y diagnóstico**, con mensaje literal
11. 📋 **Checklist de validación**, ejecutable
12. 🧪 **Ejercicios** (§8)
13. 📚 **Referencias** (§10)
14. 🏁 **Resultado de la fase** y La señal de que quedó bien

Después, fuera de lo que lee el estudiante, puede ir **📌 Pendientes sugeridos**.

### 6.3 Cómo se presenta una medición

**Toda medición se publica con cinco datos**: qué se midió (lo encontrado y la forma primero), sobre qué
volumen y qué redes sembradas, con qué motor, digest y configuración frente a qué alternativa, en qué
máquina si hay tiempos, y el comando exacto para reproducirla. **Siempre con `k`.**

```markdown
> 📐 **Medición — anillos de 4 a 7 cuentas en 72 horas** · 1,9 M cuentas, 120 anillos sembrados ·
> `neo4j@sha256:…` frente a `postgres@sha256:…` con `CYCLE` · verificado el DD/MM/AAAA · {{máquina}}
>
> | `k` | motor | encontrados / sembrados | falsos positivos | accesos o filas | p50 | p95 | p99 |
> |---|---|---|---|---|---|---|---|
> | 4 | Neo4j | … | … | … | … | … | … |
> | 4 | PostgreSQL | … | … | … | … | … | … |
>
> Reproducir: `node scripts/measure.ts rings --k 4..7 --window 72h`
```

**Los tiempos van con su dispersión** (mediana, p95 y p99, repeticiones y calentamiento declarados) y la
máquina, **y nunca sostienen solos un veredicto** (D-19). Los costos de Neptune llevan ☁️, la fuente y la
fecha (D-22). La 🪞 apuesta se escribe antes y no se edita.

---

## 7. 📐 Los tipos de documento y su coherencia

- **Fases**, **apéndices** y la **historia**, documento del lector y fuente de verdad narrativa: ningún
  dato de Quetzal Pay se inventa en una fase.
- **Documentos vivos** en la raíz, que son producto: `INSTINTOS.md` (cada 🪞 con su medición),
  **`BENCHMARKS.md`** (toda medición publicada, con los cinco datos de §6.3) y el catálogo de errores con
  su mensaje literal (si es apéndice o documento aparte, lo dice la propuesta de apéndices).
- **El apéndice 🔥 de la JVM** no entra a `BENCHMARKS.md` ni lo cita ninguna fase como requisito (D-28).
- **Los apéndices no repiten una fase, y viceversa: se enlazan.** **Una fase no cita el temario ni el
  plan.** 🗑️ **Los `_desechable-*` no se citan nunca.**
- **Git:** tags `fase-NN-<slug>`, prefijo de commit `fNN:`, ejercicios `fNN ejM: …` (D-09).

---

## 8. 🧪 Evaluación: ejercicios

- **Cantidad: 20 mínimo y 30 máximo por fase**, calibrada con *"¿cuántas cosas distintas enseña esta fase
  que se puedan comprobar por separado?"*.
- **La escala:** 🟢 reproducir · 🟡 aplicar el patrón a otra pregunta de Quetzal Pay · 🟠 combinar,
  diagnosticar, decidir · 🔴 abierto o adversarial · 🔥 extra, fuera del mínimo.
- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen; el bloque de los motores carga hacia
  🟠 y 🔴.
- **Al menos un tercio de diagnóstico o medición**: una consulta que atraviesa la tablet del agente, un
  ciclo sin control de visitados, un operador ansioso, una comunidad llena de inocentes, un conector con
  atraso; se pide reproducir, medir y explicar.
- **Predecir antes de ejecutar** en 🟠 y 🔴. **Cada ejercicio cierra con su criterio** (`Objetivo` o
  `Pregunta`). **Agrupados por dificultad**, con el conteo en el título.
- **Sin solución publicada** (D-05). **Taller global:** el antifraude en `src/`.
- **💀 Boss de bloque**, cuando el bloque lo admita: un antifraude roto o un encargo completo de alguien de
  Quetzal Pay (con nombre, de la historia §2), que cruza al menos dos fases y se entrega como artefacto.

---

## 9. 📏 Longitud y densidad

> 🚧 **Preliminar**, a fijar con la propuesta de fases. Punto de partida para una fase de 10 h: **4.000–5.000
> palabras de cuerpo**, contadas hasta el encabezado de 🧪 Ejercicios. Los apéndices son cortos, con
> índice de salto rápido, una tabla de "cuándo usar qué" y de 5 a 10 ejercicios de consulta.

---

## 10. 📚 Referencias y enlaces

### 10.1 Enlaces externos

**Orden de prioridad:** documentación oficial de la versión que usamos (Neo4j, Cypher, GDS, APOC,
Memgraph, MAGE, Apache AGE, PostgreSQL, Neptune); después los estándares (GQL, SQL/PGQ, openCypher) y los
papers de los algoritmos (PageRank, Louvain); después libros; después blogs y videos. **Siempre se
advierte cuando un enlace apunta a otra versión**, y con las licencias y los precios se cita la fecha.
Cada URL se comprueba por código de estado en la sesión que la escribe.

Cada fase cierra sus referencias con un **orden de lectura sugerido**: antes de ejecutar, durante y
después.

### 10.2 Enlaces internos y anclas

Rutas relativas; anclas comprobadas; **ningún enlace a un documento que todavía no existe**.

### 10.3 Vigencia

Las secciones de referencias advierten que las URL y los contenidos cambian, que Cypher evoluciona con
cada versión de Neo4j, y que las licencias y los precios cambian: se cita la fecha.

---

## 11. 🧷 Vocabulario visual

**Marcadores de estado:** 💸 deuda intencional (con fase de pago) · 🔥 opcional · 🚧 fuera de alcance por
ahora, con destino · ☁️ tomado de documentación, no medido · 🟢🟡🟠🔴 dificultad · ⭐ valoración
bibliográfica, solo en referencias.

**Callouts en blockquote:** 📐 **Medición** (§6.3) · 🪞 **Apuesta / instinto que falla** · 💥 **Punto de
rotura** · ⚰️ **Autopsia** · ⚖️ **Veredicto honesto** y **"Y aquí el instinto SQL tenía razón"** · 🩻
**Esto sí funciona igual** · 📖 **Traducción** SQL ↔ Cypher, en tabla · 🧠 **Modelo mental** · ⚠️
**Advertencia** · 📝 **Nota de contexto** (licencias, estándares, historia de un proyecto) · 💡 **Truco** ·
🩺 **Diagnóstico**, la consulta o el perfil que confirma o descarta una hipótesis.

**Secciones narrativas recurrentes:** *Dónde estamos* · *Detalles con intención* · *El patrón a
memorizar* · *Prueba de fuego* · *La señal de que quedó bien*.

---

## 12. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El encabezado está completo, con motor, digest, rivales, redes sembradas y fecha de verificación
[ ] La fase abre con un dolor de Quetzal Pay que está en la historia
[ ] Ningún dato de la empresa se inventó en la fase (si hacía falta, se agregó a la historia)
[ ] Nada de lo que Ruta NoSQL Lite ya enseñó se explicó de nuevo; ninguna remisión a sus fases
[ ] Todo número salió de una ejecución real; lo emulado o no verificado está declarado
[ ] Toda medición trae los cinco datos de §6.3, con k; los tiempos, con mediana, p95 y p99
[ ] Toda detección trae lo encontrado contra lo sembrado y los falsos positivos
[ ] PostgreSQL jugó con lo mejor que tiene (índices, CYCLE, SEARCH), no como adorno
[ ] Los costos de la nube llevan ☁️, fuente y fecha
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] Hay un ⚖️ veredicto con la pérdida cuantificada
[ ] Ninguna autopsia juzga a una persona; ningún párrafo enseña a cometer fraude
[ ] Las mediciones, los errores y el 🪞 entraron en sus documentos vivos
[ ] Ejercicios: 20–30, agrupados, con conteo, un tercio de diagnóstico, cada uno con Objetivo o Pregunta
[ ] Los diagramas están en Mermaid; los árboles y salidas, en text
[ ] Tuteo en todo el documento; cero voseo, cero "usted"
[ ] Código en inglés, comentarios en español con tildes; Cypher con parámetros
[ ] Ningún enlace a un documento que no existe; grep -ln "_desechable-" *.md no devuelve nada
```

---

## 13. ⚖️ Excepciones declaradas

1. **Ruta NoSQL Lite como prerrequisito** (D-14) → no se explican los fundamentos de grafos → los da lite,
   y repetirlos sería el curso que el lector ya hizo.
2. **Los ejercicios no traen solución publicada** (D-05) → el método del curso es apostar y medir antes de
   mirar, y cada ejercicio trae su criterio.

Todo lo demás del `CLAUDE.md` aplica tal cual.

---

## 14. 🧪 Laboratorio

- **Docker Compose es el camino principal**; cada receta trae su equivalente en Podman. **Aquí no se enseña
  Docker. Sin Kubernetes.**
- **Perfiles de Compose** para no pasar de 16 GB: PostgreSQL con AGE, el servicio y el arnés siempre; **un
  motor de grafo a la vez** (D-20).
- **Cada motor con su configuración documentada** (caché de páginas y memoria de Neo4j, modo de
  almacenamiento de Memgraph), nunca con la de otro. Si una imagen no corre nativa en arm64, se declara
  (D-29).
- **Servicios nombrados por papel** (`relacional`, `grafo`, `grafo-rival`), para que cambiar de motor no
  rompa los comandos escritos.
- **Los plugins vienen instalados en la imagen** (D-33).
- **Datos sintéticos con semilla fija** y la verdad sembrada, el conector simulado y el simulador de pagos
  (D-21, D-30, D-31).
- **Las pruebas de la producción** corren en contenedores etiquetados con el curso y en puertos altos
  aleatorios; el código de las sesiones va a `zz-code/` con su README.

---

## 15. 📌 Pendientes que afectan a esta guía

- **La plantilla rígida de fase (§6.2) y las longitudes (§9)** se fijan con la propuesta de fases. Todas
  las decisiones del alcance están cerradas (06/10/2026).
- **El diccionario de términos y el contrato de nombres** se escriben después de la propuesta de fases;
  hasta entonces mandan §3 y §5.2.
- **Versiones, digests, plugins y licencias sin fijar** hasta la verificación previa; lo mismo los precios
  de Neptune y la existencia de una implementación libre de SQL/PGQ o GQL (D-26).
- **El recorte contra lite** se revisa cuando sus fases 13 y 14 estén escritas.
- **El verificador del curso** se copia de `zz-instrucciones/herramientas/` y se ajusta cuando la plantilla
  de fase esté fijada.
