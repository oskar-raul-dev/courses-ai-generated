# 📎 Prompts iniciales por apéndice
## Ruta SQL — 10 sesiones, 10 entregables

Cada sección es el prompt de un apéndice. Como en los de fase, **el alcance no se copia aquí**: vive
en [`propuesta-apendices-y-alcance.md`](propuesta-apendices-y-alcance.md), y el prompt agrega lo que
esa ficha no dice. El apéndice del track está en
[`prompts-sqlserver-fase.md`](prompts-sqlserver-fase.md).

**Una sesión, un archivo.**

> ⚠️ **El orden importa.** `a01`, `a02`, `a05` y `a06` se escriben **antes de F01**, y los cuatro
> dependen de la verificación de laboratorio (P8). `a03`, `a04`, `a07` y `a08` se abren con su
> esqueleto y **crecen con el curso**. `a09` va antes de F03, porque la regla de publicación se usa
> desde ahí. `a10` va al final y es opcional.

---

## 🧱 El marco común a todos los apéndices

```markdown
## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en orden: `prompts/alcance-del-proyecto.md`,
`prompts/guia-de-estilo-y-convenciones.md`, `prompts/propuesta-apendices-y-alcance.md` con la ficha
de este apéndice, `prompts/plantillas-de-capitulo.md` (plantilla de apéndice, la laxa),
`prompts/contrato-de-nombres.md`, `prompts/diccionario-de-terminos.md`, `00-historia-de-alameda.md`
y los apéndices ya escritos. Los `_desechable-*` no cuentan y no se
citan.

Reglas de apéndice:
- **Esto no se lee de corrido.** Índice de salto rápido, secciones cortas que responden a UNA
  pregunta, ejemplo mínimo ejecutable, tabla de "cuándo usar qué" al final.
- **Un apéndice no repite lo que explica una fase: enlaza.**
- **Los de infraestructura no enseñan Docker.** Comandos y nada más; el mecanismo está en
  `cursos-contenedores-cloud-infra/docker-container-legacy/`, que se nombra sin enlace (D-03).
- **Nada sin ejecutar.** Ningún comando, ninguna versión, ninguna salida inventada.
- **Ningún número de Oracle ni de SQL Server** (guía §6.1). Los mensajes de error sí se publican.
- **Todo ejemplo usa el dominio de Alameda** con sus nombres fijos.
- **Declara qué queda fuera** en el encabezado, y dónde está.
- Cierre con el bloque 🏷️ en su variante negativa, salvo `a02`, `a05` y `a10`, que dejan archivos
  en el repositorio y llevan tag propio.
- **No toques ningún `README.md`**, tampoco los de `src/`, ni crees `0-ESTRUCTURA-CURSO.md`: se
  escriben en una tanda final y aparte.
- Ejercicios: los de la ficha, cortos y de consulta, con su solucionario en
  `soluciones/<mismo-nombre>.md`, en la misma sesión (D18, guía §10.3).
- **Nada publicado cita `prompts/` ni enlaza otro curso** (D-03): la regla se dice en el texto o
  se remite al apéndice que la publica; la NoSQL Lite y el curso de Docker, solo en prosa. Una fase
  que todavía no existe se nombra sin enlace y va a la deuda del plan §6.
- **Diagramas en Mermaid** (D-12, guía §19.1), dibujados con `mmdc`; las sesiones intercaladas, en
  `text`.
- **Sesión:** las pruebas van a `zz-code/` (`python3 zz-code/nuevo.py ruta-sql`), con contenedores
  etiquetados `curso=ruta-sql`, puertos aleatorios y borrado con sus volúmenes al cerrar; nada se
  instala sin pedirlo; sin commits; secuencial y sin agentes. Al cerrar,
  `python3 prompts/verificar-corpus.py` en cero.
```

Y el **protocolo de tres pasos**: (1) preguntas bloqueantes numeradas y lectura de la ficha, sin
redactar; (2) ejecución y redacción cuando yo responda, parando a preguntar si aparece una duda
nueva; (3) autoverificación contra la guía §16, en lista corta.

---

## # a01 — Laboratorio contenerizado

```markdown
Esta es la sesión del **Apéndice a01 — 🐳 Laboratorio contenerizado**. Entregable:
`a01-laboratorio-contenerizado.md`. **3 h · 8 ejercicios.**

{{marco común}}

## Alcance
La ficha a01, completa. Parte del `a01` de la NoSQL Lite, que ya resolvió la mitad del problema en
tres plataformas: hereda lo que sirve y reescribe solo lo que cambia.

## Qué vigilar
- **La tabla de emulación es lo nuevo** respecto de la Lite: qué corre nativo en arm64 y qué no,
  medido en P8. Si P8 no está hecha, para y dímelo.
- **Oracle y la memoria.** El límite por servicio decide si los tres motores entran a la vez en
  16 GB; el número sale de P8.
- Uno de los ejercicios: el contenedor de Oracle que no llega a *healthy* por falta de memoria,
  reconocerlo por sus logs y salir.

{{protocolo}} Si te descubres explicando qué hace `up` por dentro, corta y enlaza.
```

---

## # a02 — El `compose.yaml` de la ruta

```markdown
Esta es la sesión del **Apéndice a02 — 🧩 El `compose.yaml` de la ruta**. Entregable:
`a02-compose-de-la-ruta.md` **más `src/lab/compose.yaml`**. **2 h · 6 ejercicios.**

{{marco común}}

## Alcance
La ficha a02, completa.

## Qué vigilar
- **Bloqueado por P8.** Los digests y la tabla de RAM salen de ejecutar.
- **Este es el único sitio del curso donde vive una versión.** Todo lo demás apunta aquí.
- **Los *healthchecks* de Oracle** tardan: el apéndice dice cuánto, medido, para que nadie crea
  que se colgó.
- Lleva tag propio: `apendice-a02-compose`.

{{protocolo}}
```

---

## # a03 — CLIs de los motores

```markdown
Esta es la sesión del **Apéndice a03 — ⌨️ CLIs de los motores**. Entregable:
`a03-clis-de-los-motores.md`. **2 h · 8 ejercicios.** Se abre con esqueleto antes de F01 y crece.

{{marco común}}

## Alcance
La ficha a03, completa.

## Qué vigilar
- **Solo lo que el curso usa.** Cada comando nuevo lo agrega la fase que lo necesita; el apéndice
  no es un manual de `psql`.
- **SQLcl contra `sqlplus`**: explica cuál usa el curso y por qué, en tres líneas.

{{protocolo}}
```

---

## # a04 — El arnés de forma

```markdown
Esta es la sesión del **Apéndice a04 — 📐 El arnés de forma**. Entregable:
`a04-el-arnes-de-forma.md`. **3 h · 8 ejercicios.** Se abre con esqueleto antes de F01 y crece.

{{marco común}}

## Alcance
La ficha a04, completa.

## Qué vigilar
- **Cada campo de cada salida se explica una vez aquí**, y las fases enlazan.
- **`lab race` (D14)** se diseña en este apéndice aunque se use a partir de F15. Su requisito es
  que una anomalía se reproduzca **siempre**: intercalado determinista por puntos de sincronización
  entre sesiones, no carreras al azar. Diséñalo en el paso 1 y muéstrame la interfaz antes de
  escribirlo.
- **Oracle:** el apéndice enseña a leer `DBMS_XPLAN` y a correr la apuesta; no publica ninguna
  salida con estadísticas de ejecución.
- Los ejercicios: medir lo mismo en Postgres y en MySQL y explicar la diferencia.

{{protocolo}}
```

---

## # a05 — La caja y el generador

```markdown
Esta es la sesión del **Apéndice a05 — 📦 La caja y el generador**. Entregable:
`a05-la-caja-y-el-generador.md` **más `src/lab/generator/`**. **3 h · 6 ejercicios.**

{{marco común}}

## Alcance
La ficha a05, completa.

## Qué vigilar
- **Es la pieza más importante del laboratorio**, y la que más cuesta: el generador tiene que
  producir la suciedad con las proporciones de la historia **y guardar la verdad** de forma
  consultable. Diseña en el paso 1 cómo se guarda esa verdad (un esquema `truth` aparte, con qué
  tablas) y muéstramelo.
- **Los perfiles S, M y L** se calibran en P8 y aquí se fijan (D4). `lab load` usa **S por
  defecto**; M se pide explícitamente para medir; L nunca es obligatorio. **M tiene que entrar en
  16 GB con los tres motores**: si no entra, se achica M.
- **`legacy` se carga donde hace falta** (D13): en Postgres entero; en MySQL y Oracle, por tablas
  (`lab load --engine mysql --tables …`).
- **Determinismo:** misma semilla, mismos bytes. Se comprueba por hash, como en la Lite.
- **Ningún dato real**: ningún DNI, nombre o número de afiliado de una persona existente. Los
  rangos de DNI son plausibles, no reales.
- Lleva tag propio: `apendice-a05-la-caja`.

{{protocolo}}
```

---

## # a06 — Python, Java y los drivers

```markdown
Esta es la sesión del **Apéndice a06 — 🐍 Python, Java y los drivers**. Entregable:
`a06-python-java-y-drivers.md`. **2 h · 6 ejercicios.**

{{marco común}}

## Alcance
La ficha a06, completa.

## Qué vigilar
- **Transacciones y *autocommit*** en cada driver, con un ejemplo que muestre la diferencia: el
  Bloque III depende de que el lector sepa en qué transacción está.
- **El driver de MySQL** se elige en P8 (propuesta de apéndices §14): documenta la elección y su
  porqué.
- **Java es mínimo**: Java 21, lo justo para correr el boss del puente y el museo de `a10`.

{{protocolo}}
```

---

## # a07 — Diccionario de traducción y glosario

```markdown
Esta es la sesión del **Apéndice a07 — 📖 Diccionario de traducción y glosario**. Entregable:
`a07-diccionario-y-glosario.md`. **2 h · 6 ejercicios.** Esqueleto antes de F03, y crece.

{{marco común}}

## Alcance
La ficha a07, completa.

## Qué vigilar
- **Las dos direcciones, siempre.** Una tabla que traduce solo de Access a Postgres está a medias.
- **Los niveles de aislamiento** se traducen por comportamiento, no por nombre: `REPEATABLE READ`
  no significa lo mismo en los tres motores.
- **El glosario de Alameda** usa las definiciones de la historia §1 y se amplía con las
  equivalencias de otros países (EPS en Colombia, ISAPRE en Chile…), verificadas.
- Ejercicios: dada una consulta de Access o de T-SQL, escribir su equivalente en los tres motores.

{{protocolo}}
```

---

## # a08 — Catálogo de errores

```markdown
Esta es la sesión del **Apéndice a08 — 🧯 Catálogo de errores**. Entregable:
`a08-catalogo-de-errores.md`. **3 h · 10 ejercicios.** Esqueleto en F01; crece con cada fase.

{{marco común}}

## Alcance
La ficha a08, completa.

## La regla operativa
Cada entrada: mensaje exacto (copiado de la ejecución, nunca de memoria), motor y versión, qué lo
provocó, cómo se confirma y cómo se sale, y la fase donde apareció. Numeración `E-NN` que no se
reutiliza.

## Qué vigilar
- **Los mensajes de Oracle y SQL Server se publican**: no son resultados de rendimiento.
- La meta son cincuenta entradas al cierre, repartidas entre los tres motores.
- Ejercicios: provocar un error a propósito y reconocerlo por su mensaje.

{{protocolo}}
```

---

## # a09 — Licencias, publicación y riesgo

```markdown
Esta es la sesión del **Apéndice a09 — ⚖️ Licencias, publicación y riesgo**. Entregable:
`a09-licencias-publicacion-y-riesgo.md`. **1 h · 5 ejercicios.** Antes de F03.

{{marco común}}

## Alcance
La ficha a09, completa.

## Qué vigilar
- **El texto de la cláusula** se cita de la licencia vigente de Oracle Database Free y de SQL
  Server, con enlace y fecha de consulta. **No de memoria, y no de un blog.**
- **No es asesoramiento legal**, y se dice en la primera línea.
- **El riesgo de MySQL** se escribe con fuentes fechadas y sin dramatismo: la pregunta no es si el
  motor está bien, es quién lo mantiene dentro de cinco años.
- **D6 manda aquí**: si Oskar decidió otra cosa sobre la publicación de planes, este apéndice la
  refleja.

{{protocolo}}
```

---

## # a10 — El Access de museo

```markdown
Esta es la sesión del **Apéndice a10 — 🏛️ El Access de museo** (opcional). Entregable:
`a10-el-access-de-museo.md` **más `src/a10-el-access-de-museo/`**. **2 h · 6 ejercicios.**

{{marco común}}

## Alcance
La ficha a10, completa. El material de partida es la prueba de concepto de
`zz-code/ruta-sql-20261006-fc2f/accdb-museo/`, comprobada el 29/09/2026:
léelo entero, `README.md` incluido.

## Qué vigilar
- **Mover, no reescribir.** El código de la prueba pasa a `src/a10-el-access-de-museo/` (D15), sin
  `lib/` ni `out/`, que se regeneran. Su `README.md` se mueve **sin editarlo**: se reescribe en la
  tanda de los README. Si hay que cambiar algo para que corra, se dice qué y por qué.
- **Se vuelve a ejecutar todo** en la fecha del apéndice: generar, exportar, consultar y las tres
  corridas de `run_bas_tests.py`. Los números de la prueba (40/40, 31/40, 39/40) se publican solo si
  se reproducen.
- **Nadie lo necesita para hacer el curso**, y el apéndice lo dice arriba.
- Al cerrar, el directorio de `zz-code/` pasa a *extraído* en el plan §9, y su `MANIFIESTO.md` dice
  qué se llevó `a10`. No se borra.
- Lleva tag propio: `apendice-a10-access-de-museo`.

{{protocolo}}
```
