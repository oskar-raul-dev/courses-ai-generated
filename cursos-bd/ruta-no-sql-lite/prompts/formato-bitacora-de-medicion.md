# 📐 Formato de la bitácora de medición
## Ruta NoSQL Lite — el aparato que convierte afirmaciones en evidencia

> **Qué es este documento:** la forma exacta de las tres cosas que hacen real a este curso
> —la **medición**, la **apuesta falsable** y el **punto de rotura**— y de los tres
> documentos vivos donde se acumulan.
> **Precedencia:** por debajo de [`alcance-del-proyecto.md`](alcance-del-proyecto.md) y de
> la [guía de estilo](guia-de-estilo-y-convenciones.md), cuyo §6 es la versión corta de
> todo esto.
> **Fecha:** 10 de septiembre de 2026

---

## 1. 🧭 Por qué existe este documento

Un curso que compara diez motores puede fallar de dos maneras, y las dos son fatales.

Puede **degenerar en resumen de documentación**: repetir lo que dice la web del producto,
con mejores palabras. Y puede **degenerar en propaganda**: publicar números que parecen
evidencia y no lo son, porque no se sabe con qué se midieron, ni contra qué, ni si el
rival estaba bien configurado.

Este documento cierra las dos puertas con una regla y un formato:

> 🧭 **Una afirmación comparativa sin su ficha de medición al lado no se publica.** Y una
> ficha de medición sin sus cinco datos no es una ficha: es una anécdota con tabla.

---

## 2. 📐 La ficha de medición

### 2.1 Los cinco datos obligatorios

1. **Qué se midió, en forma estructural.** Viajes de ida y vuelta, documentos/filas/columnas
   examinados contra devueltos, particiones o segmentos tocados, fan-out de una escritura,
   amplificación de escritura o de espacio.
2. **Sobre qué volumen** de los tres del curso: `10k`, `1m` o `rotura`.
3. **Con qué motor y digest**, y con qué versión de la línea base al lado.
4. **En qué máquina**, obligatorio solo si aparece algún tiempo.
5. **Cómo reproducirlo:** el comando exacto, no su descripción.

### 2.2 La forma canónica

```markdown
> 📐 **Medición — {{qué operación del dominio}}** · {{10k|1m|rotura}} ·
> `{{imagen}}@sha256:{{12 primeros caracteres}}` · línea base `postgres@sha256:{{…}}` ·
> verificado el {{DD/MM/AAAA}}
>
> | modelo | examinados | devueltos | viajes | particiones |
> |---|---|---|---|---|
> | {{opción A}} | | | | |
> | {{opción B}} | | | | |
>
> Reproducir: `{{comando exacto}}`
```

Las columnas de la tabla **cambian según lo que se mida** —no todas las familias tienen
particiones, ni todas las operaciones tienen fan-out—. Lo que no cambia es que **cada
columna sea una magnitud estructural**, no un tiempo.

### 2.3 Qué se mide en cada motor

El detalle operativo —qué campo mirar y cuál ignorar— vive en el apéndice `a04`. Aquí solo
la correspondencia, para que nadie invente una métrica nueva por familia:

| Motor | De dónde sale la medida |
|---|---|
| MongoDB | `explain("executionStats")`: `totalDocsExamined`, `nReturned`, `totalKeysExamined` |
| PostgreSQL | `EXPLAIN (ANALYZE, BUFFERS)`: filas, buffers, tipo de scan |
| Valkey | comandos ejecutados por operación, contados en el cliente; `INFO memory` |
| DuckDB | `EXPLAIN`: columnas leídas contra filas de la tabla |
| TimescaleDB | chunks tocados, tamaño antes y después de comprimir |
| OpenSearch | `profile: true`, segmentos consultados, tiempo de reindexado |
| Neo4j | `PROFILE`: `db hits` y filas por operador |
| Qdrant | recall medido contra fuerza bruta, y memoria del índice |
| Cassandra | `TRACING ON`: particiones tocadas, SSTables leídas, tombstones |
| CockroachDB | `EXPLAIN ANALYZE`: rangos tocados y saltos de red |
| CouchDB | documentos replicados, tamaño del historial de revisiones |

**Los viajes de ida y vuelta no los reporta ningún motor.** Se cuentan en el cliente, y el
arnés del curso trae el contador. Es la métrica más importante del curso y la única que
hay que instrumentar a mano.

### 2.4 Los tiempos

Pueden aparecer. Son legítimos, son el gancho natural de un vídeo y a veces son la única
forma de explicar una diferencia. Pero:

- **jamás sostienen solos un veredicto**;
- van siempre con máquina, versión y digest al lado;
- y nunca se comparan entre máquinas distintas.

> ⚠️ **La única excepción declarada del curso** es la latencia de commit entre regiones en
> NewSQL (F22). Ahí el tiempo **sí** es el argumento, porque es física —la velocidad de la
> luz entre dos centros de datos— y no hardware. Se dice explícitamente cuando aparece.

### 2.5 Cuando la línea base es Postgres

Regla que blinda al curso y que va repetida en `a07`: **cuando se mide contra Postgres,
Postgres va con su mejor configuración razonable.** El índice correcto, la extensión
correcta, la consulta bien escrita. Ganarle a una línea base mal puesta no demuestra nada
y el lector que sabe lo nota en tres segundos.

Si no sabes cuál es la mejor forma relacional de resolver algo, **esa es la señal de que
todavía no puedes escribir esa comparación**.

---

## 3. 🪞 La apuesta falsable

Una por minicurso, en la fase B, **escrita antes de ejecutar**.

### 3.1 Las reglas

1. **Se escribe antes.** No después, no "reconstruida". Si la escribiste después, no es una
   apuesta: es un resumen.
2. **Tiene que poder perderse.** *"Creo que Mongo será más rápido"* no es apuesta: es
   humo. *"Creo que gana por un factor de al menos 5× en documentos examinados a partir del
   cuarto nivel de anidación"* sí lo es, porque un número la refuta.
3. **No se edita después de medir.** Se añade el resultado debajo; el texto original queda.
4. **Si se pierde, se cuenta entera y sin pedir perdón.** Es el contenido de mayor
   confianza que produce este curso: admitir que tu instinto falló vale más que diez
   mediciones favorables, y te inmuniza contra la acusación de estar vendiendo motores.

### 3.2 La forma

```markdown
> 🪞 **Apuesta antes de ejecutar** — Fase {{NN}}, {{familia}}
>
> **Predigo:** {{qué, con número y condición de refutación}}
> **Porque:** {{el razonamiento, en una o dos frases}}
> **Me refutaría:** {{el resultado concreto que me haría estar equivocado}}
>
> ---
>
> **Resultado: {{la gané | la perdí}}.** {{Qué salió, con el número.}}
> {{Si se perdió: qué es lo que sí rompe, que es donde está la lección de verdad.}}
```

### 3.3 La apuesta que el curso espera perder

Está declarada de antemano y es parte del diseño: **grafos contra `WITH RECURSIVE`**
(F14). Se predice que el grafo gana a partir del cuarto salto, se mide, y Postgres
aguanta. Se reconoce la derrota **y ahí** se sube la apuesta: lo que rompe no es descender
un árbol, es buscar un patrón de profundidad desconocida.

Si esa fase se escribe y la apuesta se gana, hay que sospechar de la medición antes que
del instinto.

---

## 4. 💥 El punto de rotura

Uno por minicurso. Levantar y modelar lo hace cualquiera; **llevar el motor hasta que se
rompe y decir cuánto costó, no.**

### 4.1 Qué cuenta como punto de rotura

- El volumen o la forma de dato a la que el motor **falla**, no a la que se pone lento.
- O el punto donde la operación **deja de ser viable** aunque técnicamente funcione: el
  reindexado que dura seis horas, la sincronización que no converge, la partición que ya no
  cabe en un nodo.

Que algo tarde el doble no es una rotura. Que algo devuelva `BSONObjectTooLarge`, que el
índice pase a solo-lectura o que la consulta exija `ALLOW FILTERING` para siquiera
ejecutarse, sí.

### 4.2 La forma

```markdown
> 💥 **Punto de rotura — {{qué operación}}**
>
> **Rompe a:** {{volumen o condición exacta}}
> **Con:** {{mensaje de error literal, en bloque text si es largo}}
> **Por qué:** {{el mecanismo, no la queja}}
> **Para salir:** {{índice | modelo | motor | arquitectura}} — {{qué hay que cambiar y qué
> cuesta}}
```

### 4.3 La escalera de salida, que se respeta siempre

El apartado 🚑 *"salir de aquí"* de cada fase B ordena las salidas **por coste creciente**,
y ese orden es doctrina del curso:

1. **Un índice** — minutos, reversible.
2. **El modelo** — días, y hay que migrar datos.
3. **El motor** — meses, y hay que convivir con los dos durante el proceso.
4. **La arquitectura** — trimestres, y toca a más de un equipo.

La mayoría de los problemas que la gente resuelve cambiando de motor se resolvían en el
escalón 1 o 2. Decirlo es parte del trabajo.

---

## 5. 📓 `bitacora-de-medicion.md`

El documento vivo donde se acumulan **todas** las mediciones publicadas del curso.

**Estructura del archivo:**

1. **Encabezado** con la máquina de referencia —CPU, RAM, disco, sistema— y la advertencia
   de que los tiempos no son comparables fuera de ella.
2. **Índice por familia**, con enlace a cada entrada.
3. **Las entradas**, en orden cronológico de ejecución y con ID `M-NN`.
4. **Las apuestas**, con su resultado, en una tabla-resumen al final: es la página más
   citable del curso.

**Cada entrada lleva:** ID, fecha de ejecución, fase que la usa, la ficha completa de §2.2,
y una línea de **interpretación** —qué significa ese número— separada del dato. El dato y
su lectura nunca se mezclan en el mismo párrafo.

> 🧭 **Esta bitácora sustituye al `BENCHMARKS.md` del repositorio**, y el motivo está
> declarado en §16 de la guía: un archivo de latencias sería exactamente el artefacto que
> envejece mal en un curso que mide la forma y no la velocidad.

---

## 6. 🧯 `a09-catalogo-de-errores.md`

El activo más buscable del curso: lo que alguien encuentra un martes por la tarde cuando
pega su error en un buscador.

**La regla operativa, que sale gratis y vale mucho:** todo error que aparezca al ejecutar
entra aquí **con su mensaje literal**, aunque ese día no se use y aunque no pertenezca a la
fase que estás escribiendo. Y se anota **antes** de arreglarlo — un mensaje reconstruido de
memoria es un mensaje que no existe, y un mensaje que no existe no lo encuentra nadie.

**Formato de entrada:**

```markdown
### E-{{NN}} — {{título en las palabras de quien lo sufre}}

```text
{{mensaje literal, completo, sin recortar la parte incómoda}}
```

- **Motor y versión:** {{…}} `@sha256:{{…}}`
- **Apareció en:** Fase {{NN}} / ejecutando {{qué}}
- **Qué lo provoca:** {{el mecanismo}}
- **Cómo confirmas que es este y no otro:** {{el comando de diagnóstico}}
- **Cómo se sale:** {{…}}
- **Si la salida correcta es no salir:** {{cuándo el error está diciéndote que rediseñes}}
```

**Meta declarada:** cincuenta entradas al cerrar el curso.

---

## 7. 🪞 `INSTINTOS.md`

Los 🪞 acumulados de las diez familias: cada punto donde el instinto relacional falla, con
la medición que lo demuestra.

**Formato de entrada:** el instinto en la voz del lector *("normalizo, que para eso
aprendí")* · por qué es razonable · dónde se rompe · la medición que lo prueba, con enlace
a su entrada de la bitácora · y **la pregunta del instrumento** que lo habría anticipado.

Es el documento que mejor resume el curso entero, y el que más sentido tiene leer solo.

---

## 8. ✅ Checklist del aparato de medición

```text
[ ] Toda afirmación comparativa tiene su ficha de medición al lado
[ ] Toda ficha tiene los cinco datos y su comando de reproducción
[ ] Ningún veredicto se sostiene sobre un tiempo
[ ] La línea base Postgres está bien jugada, con su índice y su extensión
[ ] La apuesta se escribió antes de medir y no se editó después
[ ] El resultado de la apuesta está publicado, se ganara o se perdiera
[ ] El punto de rotura trae volumen exacto y mensaje literal
[ ] La escalera de salida va en orden de coste creciente
[ ] Los errores nuevos están en a09-catalogo-de-errores.md con su mensaje literal
[ ] Las mediciones están en bitacora-de-medicion.md con su ID
[ ] El 🪞 está en INSTINTOS.md, con la pregunta del instrumento que lo anticipaba
[ ] Nada de lo publicado se escribió sin ejecutarlo; lo no ejecutado está declarado
```
