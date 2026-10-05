# ✍️ Guía de estilo, tono y convenciones
## El motor de motores — La teoría que todos los gestores SQL implementan

Esta guía es la fuente de verdad editorial del curso. Cualquier sesión que produzca un `.md` de este
proyecto la sigue. Su objetivo es que las treinta y ocho fases del camino base, las diez del bloque
A.C., los apéndices y los solucionarios se lean como escritos por la misma mano, con el mismo
criterio, y que todos apunten al mismo sitio: **que el lector entienda por qué funciona lo que usa
todos los días, y pueda demostrarlo**.

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien que estudia solo, un
domingo, con el libro de Navathe al lado y nadie a quien preguntarle.

> **Precedencia.** Por encima de esta guía solo está
> [`alcance-del-proyecto.md`](alcance-del-proyecto.md), que decide **qué** enseña el curso; esta
> decide **cómo** se escribe. Por debajo van las dos propuestas de alcance, las plantillas y los
> prompts, que se actualizan después y nunca al revés. El `CLAUDE.md` del repositorio aplica en todo
> lo que este curso no haya declarado como excepción (§16).

---

## 1. 🧭 Principio rector

**Todo lo que se escribe apunta a que el lector pueda definir, demostrar y verificar.**

No enseñamos un motor. No formamos administradores de un producto. Formamos la capacidad de mirar
un esquema, una consulta, un índice o un plan de transacciones y decir **qué es en el modelo**, qué
garantiza, qué cuesta y dónde se aparta SQL de la teoría.

El filtro para cada párrafo es este: **¿esto ayuda a definir, a demostrar, a calcular o a
verificar?** Si no, sobra. Aunque esté muy bien escrito. Sobre todo si está muy bien escrito.

Y el corolario, repetido tantas veces como haga falta:

> 🧠 **SQL es una aproximación al modelo, no el modelo.** Cada vez que una fase muestra SQL, dice si
> se comporta como la teoría o dónde se aparta.

---

## 2. 🎤 Tono

**Semiformal, cálido y directo**, de colega senior a colega senior. Piensa en el ayudante de cátedra
que te explica el ejercicio que no te salió, con paciencia, sin solemnidad de manual y sin
palmaditas en la espalda.

- **Tuteo latinoamericano, siempre.** *"Calcula primero la clausura de AB y después mira si contiene
  todos los atributos"*. Nada de voseo, nada de "usted", nada de impersonal permanente ("se debe
  calcular…") que enfría el texto. En las definiciones formales el impersonal está bien: es el
  registro del género.
- **Semiformal.** Frases completas, puntuación correcta, cero abreviaturas de mensajería. Un "ojo
  con esto" sí; un "che" no.
- **Humor seco y con moderación.** Un 😉 bien puesto, un chiste sobre el `NOT IN` que devolvió cero
  filas. **Máximo un chiste por sección**, y si no fluye solo, se borra.
- **Cálido sin condescendencia.** El lector es senior en su oficio y novato en la teoría. Se le
  explica todo con cero ambigüedad, sin infantilizarlo.
- **Honesto sobre los límites.** Si FNBC no preserva una dependencia, se dice con esas palabras. Si
  la 5FN casi nunca se aplica en la práctica, también. Cada técnica gana en algún sitio y pierde en
  otro, y las pérdidas van con el costo calculado.

### 2.1 El tono de los errores conceptuales

⚠️ Un error conceptual se escribe sobre una **idea**, jamás sobre una persona. La versión que
funciona **dice primero por qué la idea equivocada es tentadora** y después la desmonta con un
contraejemplo:

1. La afirmación equivocada, tal como la diría alguien razonable.
2. Por qué parece cierta (casi siempre: funciona en el caso típico).
3. El contraejemplo mínimo que la rompe.
4. La afirmación correcta.

Lo que nunca aparece: "obviamente", "es trivial", "cualquiera ve que", "como es evidente". Si fuera
evidente, no estaría en el curso.

---

## 3. 🗣️ Idioma y forma

- **Español latinoamericano neutro** para todo lo que no sea código, salida de terminal o
  identificador.
- **Los términos con traducción asentada se traducen**: dependencia funcional, clausura, clave
  candidata, forma normal, plan, bitácora, índice. **Los que el lector va a encontrar en inglés en
  la documentación y en los mensajes de error se dan una vez en inglés entre paréntesis** y se usan
  en español: *join sin pérdida (lossless join)*, *plan (schedule)*. Algunos se quedan en inglés
  porque así se dicen: *join*, *buffer pool*, *hash*, *pipelining*, *write skew*. Lo importante es
  **no inventar vocabulario**; el glosario de `a07` fija la elección y manda.
- **Markdown siempre.** Nada de HTML embebido.
- **Prosa antes que listas.** Un párrafo que explica *por qué* vale más que cinco viñetas que
  enumeran *qué*. Las listas son para lo que de verdad es una lista: pasos de un algoritmo, ítems
  paralelos, opciones.
- **Nada de prosa telegrama.** Una frase aislada por sección, dos si la sección es larga.
- **Tablas solo para lo tabular y corto**: traducciones, comparaciones, tablas de verdad, estados de
  un algoritmo paso a paso. Cuatro columnas como máximo, salvo las tablas de traza de un algoritmo,
  que tienen las que el algoritmo necesita.

### 3.1 Notación: Unicode, nunca LaTeX

La notación matemática va en **Unicode**, en el texto y dentro de bloques de código. **Nunca LaTeX**,
ni `$…$` ni bloques `math`: no todos los visores lo renderizan, y el lector tiene que poder copiarla.

| Uso | Símbolos |
|---|---|
| Álgebra | σ π ρ ⋈ × ∪ ∩ − ÷ γ ⟕ ⟖ ⟗ ⋉ ⋊ ▷ ← |
| Lógica y cálculo | ∀ ∃ ¬ ∧ ∨ ⇒ ⇔ ∈ ∉ ⊆ ⊂ ∅ |
| Dependencias | → ↠ ⊨ ⊢ F⁺ X⁺ ⋈ |
| Subíndices y condiciones | `σ city = 'Lima' (supplier)`, `π name, city (supplier)` |

Las condiciones y listas de atributos van **después del operador y separadas por un espacio**, sin
subíndices tipográficos, que en Unicode son ilegibles. Junto a cada expresión ejecutable va su
equivalente en `radb` en un bloque de código propio. La tabla completa de símbolos y su equivalente
en `radb` está en `a07`.

### 3.2 Diagramas: ASCII, 75 columnas

**Diagramas ASCII en bloques `text`, de 75 columnas como máximo** siempre que se pueda: diagramas
ER y EER (en Chen, pata de gallo o min-max, según la fase), árboles de consulta, árboles B+ paso a
paso, grafos de precedencia, estados del buffer, bitácoras de ARIES. Si un diagrama no cabe en 75
columnas, primero se simplifica; solo si es imposible se acepta más ancho y se dice por qué.

```text
INSERCIÓN DE 23 EN UN B+ CON HOJAS DE HASTA 3 CLAVES (hoja llena)

antes                          después
─────                          ───────
      [17]                          [17 | 23]
     /    \                        /    |    \
[5|11]   [17|21|29]          [5|11]  [17|21]  [23|29]
```

Se usan **caracteres de dibujo de cajas** (`─ │ ┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼`) y flechas Unicode (`→ ← ↑ ↓`)
cuando aclaran, y ASCII plano cuando basta.

### 3.3 Salida literal

La salida de `radb`, de `sqlite3`, de los verificadores y del mini motor va **tal como sale**, en
bloque `text`, sin embellecer y sin recortar lo incómodo. Un error real enseña más que uno editado.

---

## 4. 🎓 Pedagogía: cómo se explica

### 4.1 La regla del andamio

Todo concepto nuevo se presenta en cinco tiempos, en este orden:

1. **El problema primero.** *"La planilla de notas repite el nombre del docente en cada fila. Si el
   docente se cambia el apellido, ¿cuántas filas tocas, y qué pasa si olvidas una?"*
2. **La definición formal**, en un callout 📏, con la notación del curso.
3. **La intuición**: qué dice la definición en palabras, y qué *no* dice.
4. **Un ejemplo resuelto** ✍️, con todos los pasos, sobre `school`, `supply` o relaciones abstractas.
5. **La verificación** 🔎, cuando el concepto es ejecutable: `radb`, SQLite o un verificador, con su
   salida literal.

Presentar la definición antes que el problema produce lectores que recitan "un atributo no primo no
depende transitivamente de la clave" y no reconocen una violación de 3FN cuando la tienen delante.

### 4.2 Definiciones, teoremas y demostraciones

- **Definiciones** en un callout 📏 **Definición**, numeradas por fase (`Definición 15.3`), para que
  los ejercicios y otras fases puedan citarlas.
- **Teoremas, lemas y propiedades** en un callout 📐 **Teorema** (o Lema, o Propiedad), también
  numerados.
- **Demostraciones** cuando enseñan algo: la solidez de los axiomas de Armstrong, que ÷ se escribe
  con π, × y −, que 2PL garantiza serializabilidad. Van completas, paso a paso, con la justificación
  de cada paso entre paréntesis. Cuando una demostración no enseña nada que el lector vaya a usar,
  se da el enunciado y la referencia al libro, y se dice.
- **Nunca "se deja como ejercicio"** una demostración que la fase necesita después.

### 4.3 Del instinto de desarrollador se parte, no se reniega

El lector llega con un modelo mental que funciona en el caso típico. Dos micro-secciones lo honran
antes de corregirlo:

- 🩻 **"Esto sí funciona igual"** — lo que la teoría confirma de lo que el lector ya hace: un índice
  sobre la clave sí acelera la búsqueda por clave; una transacción sí es atómica.
- 🪞 **"Tu instinto de desarrollador dice… y esta vez se equivoca"** — el punto exacto donde el
  modelo mental se rompe, con su contraejemplo o su cálculo. **Al menos uno por bloque**, y todos se
  acumulan en `INSTINTOS.md`.

### 4.4 De la teoría a los motores

Cada fase tiene una sección que conecta lo que acaba de enseñar con SQL y con los motores reales:
qué se implementa tal cual, qué se implementa distinto y qué no se implementa. **Se remite en prosa
al curso de motor que lo mide** (*"el bloque VI del curso de PostgreSQL mide esto"*), sin enlace
mientras ese curso no exista. Las afirmaciones sobre un motor concreto se verifican en su
documentación oficial con fecha, o se declaran no verificadas.

### 4.5 Analogías, con fecha de caducidad

Se usan **una vez, para abrir la puerta**, y se abandonan diciendo dónde se rompen. Cuidado especial
con las dos más peligrosas del tema: **"una relación es una tabla"** (hasta que aparecen los
duplicados, el orden y los `NULL`) y **"normalizar es dividir tablas"** (hasta que la división pierde
información o una dependencia).

### 4.6 Densidad calibrada

- Un concepto nuevo por vez. Si un bloque introduce tres cosas desconocidas, se parte.
- **Repetir lo importante está bien**: los cinco primitivos del álgebra, la diferencia entre conjunto
  y multiconjunto, "una DF es del esquema, no del estado", reaparecen con otras palabras.
- Ninguna sección supera las dos pantallas sin un ejemplo resuelto, un diagrama o una verificación.

### 4.7 Cierra los bucles

Si abres un paréntesis —*"esto lo demostramos en F17"*, *"el costo lo calculamos en F26"*—, tiene que
cerrarse en algún documento del curso. Un pendiente que nunca se resuelve es ruido.

---

## 5. 💻 Código, comandos y archivos

> **Regla normativa:** todo lo que se ejecuta o se versiona va en inglés —nombres de archivo, rutas,
> identificadores, relaciones, atributos, funciones— y **todos los comentarios van en español con
> tildes** (excepción declarada en §16).

- **Identificadores en inglés en todas partes, también en el álgebra y en el cálculo** (D17):
  `π name (σ city = 'Lima' (supplier))`, jamás `π nombre (σ ciudad = 'Lima' (proveedor))`.
  Relaciones y atributos en `snake_case` y en singular.
- **Nombres de las bases de ejemplo, fijos en todo el curso.** `school`: `school_year`, `term`,
  `grade_level`, `section`, `subject`, `teacher`, `student`, `guardian`, `enrollment`,
  `teaching_assignment`, `assessment`, `score`, `classroom`. `supply`: `supplier`, `part`, `project`,
  `shipment`, `customer`, `sales_order`, `order_line`. **La palabra `grade` sola no se usa nunca.**
  Una fase no renombra una relación ni un atributo; si necesita uno nuevo, lo declara y se añade a
  `a04`.
- **Relaciones abstractas** `R(A, B, C, D, E)` con atributos de una letra mayúscula, conjuntos de
  atributos sin comas (`AB → C`), y planes de transacciones con la notación de Navathe
  (`r1(X); w2(X); c1`). La notación se fija en `a07`.
- **Nunca `foo`, `bar`, `test1` ni `tabla1`.** Todo ejemplo usa las bases del curso o relaciones
  abstractas declaradas como tales.
- **Bloques de código con su lenguaje declarado**: `sql`, `python`, `c`, `bash`, `powershell`,
  `text` para salida y diagramas. Las consultas de `radb` van en bloques `text` con la primera línea
  de comentario `// radb`. **Nunca `--`**: no es comentario en `radb`, y el bloque copiado a un `.ra`
  falla en la primera línea (P8, H4).
- **SQL portable por defecto.** Si una consulta usa algo propio de SQLite, se dice.
- **Un bloque, una idea.** Si el fragmento hace tres cosas, se parte en tres con prosa entre medias.

### 5.1 Versiones

- **Ninguna versión se escribe de memoria.** SQLite, Python, `radb`, Faker y cualquier herramienta
  se fijaron en la tanda de verificación (P8, `prompts/verificacion-de-laboratorio/hallazgos.md`) y
  viven en `a01`–`a03`; las fases apuntan allí. **SQLAlchemy va fijado en la 2.0**: con la 2.1, `radb`
  tipa las columnas `REAL` como `unknown` (H2).
- **Toda fase declara su fecha de verificación**: el día en que se ejecutó todo lo que muestra.
- **Si algo no se verificó, se dice con esas palabras**: *"esto no lo ejecuté; la documentación de
  SQLite 3.x lo describe así"*. Declarar lo que no se verificó es la marca de la casa.

### 5.2 Nombres de archivo del curso

Son **canónicos**: una fase no los cambia. Todo en minúsculas y con guiones.

```text
README.md                    (se escribe al final)
0-ESTRUCTURA-CURSO.md        (se escribe al final)
INSTINTOS.md

00-el-sistema-de-bases-de-datos.md
01-conceptos-y-arquitectura.md
02-modelo-entidad-relacion.md
03-er-extendido-y-notaciones.md
04-el-modelo-relacional.md
05-restricciones-y-actualizaciones.md
06-algebra-operaciones-unarias.md
07-algebra-conjuntos-joins-y-division.md
08-algebra-extendida.md
09-calculo-relacional.md
10-del-algebra-a-sql.md
11-null-y-multiconjuntos.md
12-vistas.md
13-del-er-al-relacional.md
14-guias-de-diseno-y-anomalias.md
15-dependencias-funcionales.md
16-formas-normales.md
17-propiedades-de-las-descomposiciones.md
18-algoritmos-de-diseno.md
19-mas-alla-de-fnbc.md
20-desnormalizacion-y-diseno-fisico.md
21-discos-y-archivos.md
22-hashing.md
23-indices-de-uno-y-varios-niveles.md
24-arboles-b-y-b-mas.md
25-otras-estructuras-de-indice.md
26-implementacion-de-operadores.md
27-optimizacion-heuristica.md
28-optimizacion-por-costo.md
29-transacciones-y-planes.md
30-control-de-concurrencia.md
31-niveles-de-aislamiento.md
32-recuperacion.md
33-el-dba.md
34-seguridad-y-autorizacion.md
35-respaldo-y-continuidad.md
36-bases-activas-triggers.md
37-mas-alla-del-nucleo.md

ac00-navegar-contra-declarar.md     ac05-los-herederos.md
ac01-archivos-registros-y-punteros.md
ac02-modelo-jerarquico.md           ac06-caso-git.md
ac03-modelo-de-red.md               ac07-caso-lmdb.md
ac04-el-gran-debate.md              ac08-caso-yottadb.md
                                    ac09-pedidos-en-c.md

a01-sqlite-nativo.md                a06-la-matematica-minima.md
a02-python-venv-y-faker.md          a07-notacion-y-glosario.md
a03-radb.md                         a08-mapa-de-bibliografia.md
a04-las-bases-de-ejemplo.md         a09-el-curso-en-un-contenedor.md
a05-verificadores-y-mini-motor.md
aca-01-herramientas-nativas.md      aca-02-contenedores.md

soluciones/NN-slug.md       uno por fase, mismo nombre que la fase
soluciones/acNN-slug.md     uno por fase del bloque A.C.
src/a04-las-bases-de-ejemplo/        DDL, datos chicos, generador
src/a05-verificadores-y-mini-motor/  verificadores y mini motor
src/acNN-slug/                       laboratorios del bloque A.C.
```

Si una fase deja código propio que no pertenece a los proyectos de `a04` o `a05`, va en
`src/NN-slug/`, con el mismo nombre que la fase.

---

## 6. 🔬 Cómo se presenta una verificación

Esta sección es normativa: una verificación mal presentada es peor que ninguna, porque parece
evidencia.

**Toda verificación se publica con cuatro datos:**

1. **Qué se verificó**: la expresión, la consulta o el paso del algoritmo.
2. **Con qué herramienta y versión**: `radb`, `sqlite3`, el verificador o el mini motor.
3. **Sobre qué base y con qué datos**: `school` o `supply`, chica (a mano) o generada (semilla).
4. **Cómo reproducirlo**: el comando exacto.

Formato recomendado, y suficiente:

```markdown
> 🔎 **Verificación — proveedores que suministran todas las partes rojas** · `radb` · `supply`
> (datos chicos) · verificado el 15/10/2026
>
> Reproducir: `radb supply.db -i 07/division-red-parts.ra`
```

Seguido del bloque `text` con la salida literal.

**Los costos se calculan, y se dice que son un modelo.** Un costo en accesos a bloque lleva sus
supuestos escritos (tamaño de bloque, registros por bloque, altura del índice, páginas de buffer) y
la fórmula de la que sale. Si una fase compara dos algoritmos, compara sus costos en el mismo
modelo, nunca un tiempo medido.

```markdown
> 🧮 **Costo — join por bloques, `order_line` ⋈ `part`** · modelo de F26 · b_R = 2 000,
> b_S = 50, n_B = 12
>
> costo = b_S + ⌈b_S / (n_B − 2)⌉ · b_R = 50 + 5 · 2 000 = **10 050 accesos a bloque**
```

---

## 7. 🧷 Marcadores, callouts y encabezado

### 7.1 Bloque de encabezado obligatorio

```markdown
# 🧮 Fase 15 — Dependencias funcionales: lo que el esquema sabe y la tabla no dice

> **Curso:** El motor de motores · Fase 15 de 37 · Bloque III · **12 h**
> **Lectura base:** Navathe 7.ª ed., cap. 14 · Date 8.ª ed., cap. 11
> **Herramientas:** papel · verificadores (`closure`, `min_cover`, `keys`)
> **Bases:** `school` (planilla de notas), `supply` (factura plana), relaciones abstractas
> **Depende de:** F14 · **Habilita:** F16, F17, F18
> **Apéndices de apoyo:** a04, a05, a06, a07
> **Fecha de verificación:** DD/MM/AAAA
> **Objetivo:** calcular clausuras, recubrimientos mínimos y todas las claves candidatas, y demostrar
> la solidez de los axiomas de Armstrong.
```

El título es descriptivo y con carácter: `Fase NN — Tema: la promesa concreta del documento`. Nada
de `Fase 15 — Dependencias funcionales` a secas. En el bloque A.C., `Fase AC03 — …` y `Bloque A.C.`.

### 7.2 Marcadores

- 🧵 **El hilo de π y −.** Marca en el título de sección y en el índice las partes del hilo (§5 del
  alcance).
- 🏛️ **Antes de Codd.** Recuadro opcional de tres o cuatro líneas que invita al bloque A.C. Solo en
  F01, F03, F05, F07, F13, F24 y F37. Nunca con contenido del que dependa el camino base.
- 🔥 **Opcional o ampliación.** En ejercicios, el escalón por encima de 🔴.
- 🟢🟡🟠🔴 **Dificultad de ejercicios** (§9).
- ✍️ 🔎 🧮 🧩 📖 **Tipo de ejercicio** (§9).
- 🚧 **Fuera de alcance por ahora**, siempre con destino explícito.
- 💲 **De pago**, en la bibliografía.
- ⭐ **Valoración bibliográfica**, de una a cinco, solo en bibliografía y con su leyenda visible.

### 7.3 Callouts en blockquote

- 📏 **Definición** — numerada.
- 📐 **Teorema, lema o propiedad** — numerado.
- ✍️ **Ejemplo resuelto** — con todos los pasos.
- 🔎 **Verificación** — el formato de §6.
- 🧮 **Costo** — el formato de §6.
- 🪞 **Tu instinto de desarrollador dice… y esta vez se equivoca.**
- 🩻 **Esto sí funciona igual.**
- 📖 **Traducción** — de notación entre libros, o de vocabulario español ↔ inglés.
- 🧠 **Modelo mental** — la frase que hay que llevarse.
- ⚠️ **Advertencia** — algo que rompe si lo ignoras.
- 📝 **Nota de contexto** — historia, origen de un término, por qué un libro lo llama distinto.
- 💡 **Truco** que ahorra trabajo en papel.
- 📚 **Referencia rápida inline**, justo donde nace la duda.
- ⚖️ **Hasta dónde llega la teoría.**

No hace falta usarlos todos en cada documento. Se usan cuando aportan.

### 7.4 Secciones recurrentes

- **Dónde estamos.** Apertura: qué dejó la fase anterior y qué se necesita traer.
- **El patrón a memorizar.** Una o dos frases con la lección transferible.
- **Prueba de fuego.** Verificación concreta incrustada en el flujo: *"corre el verificador y
  confirma que la clausura de AB es ABCDE"*.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de cita.

---

## 8. 🧱 Plantilla obligatoria de fase

Los esqueletos completos, con placeholders, están en
[`plantillas-de-capitulo.md`](plantillas-de-capitulo.md). Lo normativo es esto.

**Las fases del camino base llevan estas secciones, en este orden:**

1. Título y bloque de metadatos (§7.1)
2. 🧭 **Dónde estamos** — qué deja la fase anterior y qué hay que traer
3. 🎯 **Objetivos de esta fase**, verificables: "calcular", "demostrar", "escribir", nunca "entender"
4. 🚫 **Qué NO entra todavía**, con destino exacto
5. 📐 **Teoría** — el grueso de la fase, en subsecciones numeradas (`15.1`, `15.2`…), cada una con la
   regla del andamio (§4.1)
6. 🔀 **De la teoría a los motores** — 🩻 lo que funciona igual, dónde SQL y los motores se apartan,
   y a qué curso de motor ir (§4.4)
7. 🪞 **Tu instinto de desarrollador dice…** — cuando la fase tenga uno; al menos uno por bloque
8. ⚠️ **Errores conceptuales comunes** — de tres a seis, con el formato de §2.1
9. 📖 **Traducción de notación y vocabulario** — cómo lo llaman y lo escriben Navathe, Date y los
   demás textos, y el español ↔ inglés, **en las dos direcciones**
10. ⚖️ **Hasta dónde llega la teoría** — cuándo no conviene aplicar lo de esta fase, con su costo
11. 🧭 **Resumen** — prosa corta y el patrón a memorizar
12. 🧪 **Ejercicios** (§9), con el enlace a su solucionario
13. 📚 **Bibliografía y recursos** (§10)
14. 🏁 **Cierre** — la señal de que quedó bien

Después de la última sección, fuera de lo que lee el estudiante, cada fase puede cerrar con
**📌 Pendientes sugeridos**: lo que apareció al escribirla y no cabía, con destino explícito.

**Longitud del cuerpo**, medido cortando el documento por el encabezado de 🧪 Ejercicios:

| Horas de la fase | Palabras de cuerpo | Fases |
|---|---|---|
| 3–4 h y panorama | 2.000–3.000 | F00, F37, AC00 |
| 6–8 h | 3.000–4.500 | F01, F12, F14, F23, F31, F33 y AC01–AC09 |
| 10–12 h | 4.500–6.500 | el resto del camino base, incluida F32 (11 h) |
| 14–16 h | 5.500–7.500 | F07, F10, F15, F26, F28, F30 |

Los ejercicios añaden lo que añadan: la banda vigila la densidad de la prosa, no el peso del
archivo.

**Las fases del bloque A.C.** siguen la misma plantilla con dos cambios, definidos en
`plantillas-de-capitulo.md`: la sección 6 pasa a ser 🔀 **De entonces a ahora** (dónde vive hoy ese
modelo) y las fases de caso de estudio (AC06–AC08) reemplazan la sección 5 por 🔬 **El caso**.

**Los solucionarios** tienen su propia plantilla: por ejercicio, el enunciado resumido, la solución
desarrollada en pasos numerados, la verificación cuando la hubo y, en los abiertos, la rúbrica.

**Los apéndices no siguen la plantilla de fase.** Usan índice de salto rápido, secciones cortas, una
tabla de "cuándo usar qué" al final y de 5 a 10 ejercicios de consulta.

---

## 9. 🧪 Ejercicios

- **Cantidad: 30 mínimo y 45 máximo por fase**; 18–20 en F00 y F37; en el bloque A.C., la que fija
  su propuesta. Se calibra con la pregunta *"¿cuántas cosas distintas enseña esta fase que se puedan
  comprobar por separado?"*.

  > ⚠️ **La cantidad no arregla una batería floja.** Subir de 30 a 40 solo tiene sentido si los diez
  > nuevos comprueban **algo que ninguno de los treinta comprobaba**: otro caso del algoritmo, otro
  > contraejemplo, otra combinación. Diez variantes del mismo cálculo con otros números son relleno.

- **La escala:**

  | | Nivel | Qué pide |
  |---|---|---|
  | 🟢 | Fácil | Aplicar la definición o el algoritmo tal como la fase lo mostró |
  | 🟡 | Intermedio | Aplicarlo a otra relación o base, con algún caso que la fase no mostró |
  | 🟠 | Difícil | Combinar varios resultados, decidir entre alternativas, detectar el error |
  | 🔴 | Muy difícil | Demostrar, refutar con contraejemplo, o resolver un caso abierto |
  | 🔥 | Extra | Ampliaciones fuera del alcance base; no cuentan para el mínimo |

- **Distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴**, con margen según la fase. Las fases de
  cálculo (F15, F17, F22, F24, F29) cargan hacia 🟢 y 🟡 porque el músculo se hace repitiendo; las de
  diseño y teoría (F09, F16, F19) cargan hacia 🟠 y 🔴. Dos fases seguidas con el mismo reparto son
  señal de que se copió.

- **Cinco tipos, marcados en el título** con su emoji: ✍️ cálculo en papel, 🔎 verificación en
  herramienta, 🧮 demostración o refutación, 🧩 modelado, 📖 lectura guiada de una fuente. **Al menos
  una cuarta parte son 🔎** en las fases con herramienta, y **al menos tres 🧮** en las de los bloques
  II y III.

- **Predecir antes de ejecutar.** En los 🔎 de 🟠 y 🔴 se pide escribir el resultado esperado antes de
  correr la herramienta, y explicar la diferencia si la hay.

- **Cada ejercicio cierra con su criterio**: una línea `**Criterio de éxito:**` con lo que hay que
  obtener o demostrar. Nunca "normaliza la relación" a secas, siempre *"…hasta FNBC, demostrando que
  la descomposición es sin pérdida con el chase"*.

- **Originales.** Ningún enunciado ni conjunto de datos se copia de un libro. La bibliografía puede
  remitir a los ejercicios del libro por su número para práctica adicional.

- **Cada ejercicio enlaza su solución**: `[Solución](soluciones/15-dependencias-funcionales.md#ejercicio-12)`.

- **Agrupados por dificultad, con encabezado de rango y el conteo en el título:**

  ```markdown
  # 🧪 Ejercicios de la Fase 15 (45)

  ## 🟢 Fácil — clausuras y reglas (1–14)
  ### 🟢 Ejercicio 1 · ✍️ — La clausura de AB
  …
  **Criterio de éxito:** …
  [Solución](soluciones/15-dependencias-funcionales.md#ejercicio-1)
  ## 🟡 Intermedio — recubrimientos y equivalencia (15–28)
  ## 🟠 Difícil — todas las claves candidatas (29–39)
  ## 🔴 Muy difícil — demostraciones y contraejemplos (40–45)
  ## 🔥 Opcionales
  ```

### 9.1 El solucionario

- **Un archivo por fase**, `soluciones/NN-slug.md`, con un ancla por ejercicio (`#ejercicio-N`).
- **Solución desarrollada, no resultado.** Los pasos numerados, con la regla o el teorema que
  justifica cada uno.
- **Verificación cuando la hubo**, con el formato de §6 y la salida literal.
- **En los abiertos (🔴 de diseño), una rúbrica**: qué tiene que tener una respuesta correcta y qué
  errores la invalidan, más una solución de referencia.
- **Errores típicos**, opcionales: el paso donde la gente suele equivocarse en ese ejercicio.
- **Ninguna solución se publica sin contrastar** con el verificador, la herramienta o una segunda
  resolución independiente.

---

## 10. 📚 Bibliografía y recursos

Cada fase cierra con su bibliografía en cuatro grupos, en este orden:

1. **Libros** — de los cinco textos del camino base, con edición y capítulo (o sección) exactos. La
   lectura base va primero; las complementarias después, con una línea de qué aporta cada una.
2. **Cursos** — Udemy y Coursera, con idioma, si son de pago 💲 y la fecha de verificación.
3. **Videos** — cursos completos en YouTube (la clase concreta, no solo la lista), con su duración.
4. **Otros** — papers fundacionales, notas de curso, herramientas como RelaX, y los ejercicios del
   libro recomendados para práctica adicional, por número.

**Formato:** título, autor o institución, URL completa, y una línea de por qué vale la pena y qué
cubre. **A igual calidad, gana el gratuito y el que está en español.**

Cierra con un **orden de lectura sugerido**: qué leer antes de la fase, qué consultar durante y a
qué volver después.

> ⚠️ En todas las secciones de bibliografía va una advertencia de que las URLs y los cursos cambian,
> con la fecha de verificación de la sección.

**Ningún recurso se cita sin comprobarlo en la misma sesión.** El inventario verificado vive en
`a08`, y las fases toman de allí.

---

## 11. 🐳 Contenedores

- **El camino base no usa contenedores.** Todo corre nativo: SQLite, Python, `radb`.
- **`a09`** es un contenedor opcional con todo el camino base, y `aca-02` el del bloque A.C. Se citan
  como alternativa; ninguna fase los exige, salvo AC08 fuera de Linux.
- **Docker es el camino principal y cada receta trae su equivalente Podman al lado.** Cuando el
  comando es idéntico, se dice y no se duplica.
- **Aquí no se enseña Docker.** Si una explicación pasa de dos párrafos, pertenece a
  `docker-container-legacy/` y se enlaza.

### 11.1 Dónde se ejecuta lo que se escribe

**El lector ejecuta nativo; la producción del curso ejecuta en contenedores.** Toda prueba que hace
una sesión de escritura —un motor, un comando, un script, un verificador, una compilación, un
laboratorio— corre dentro de un contenedor del laboratorio de producción, nunca en la máquina del
autor. Esos contenedores se nombran `mdm-<algo>`, llevan la etiqueta `curso=01-bases`, **no publican
puertos** (se trabaja con `docker exec`) y, si hace falta publicar uno, va en `127.0.0.1` dentro del
rango `56000–56099`, **nunca en el puerto por defecto del producto**. Al terminar la producción del
curso se detienen todos. Lo que no se puede contenerizar (las recetas de macOS y Windows) se verifica
en la máquina del autor a pedido suyo, o se declara no verificado.

---

## 12. 🤝 Honestidad: las reglas que no se negocian

1. **Nada se publica sin haberse ejecutado o verificado.** Ninguna salida reconstruida de memoria,
   ningún paso de una solución sin contrastar, ninguna versión inventada.
2. **Lo que no se verificó se declara con esas palabras**, donde el lector lo necesita.
3. **Cada técnica gana en algún sitio y pierde en otro**, y las pérdidas van con su costo calculado.
4. **Los costos son un modelo y se dice.** Nunca se presenta un costo calculado como si fuera una
   medición.
5. **Donde SQL se aparta de la teoría, se dice en la misma fase**, no en una nota al final.

---

## 13. 🔗 Coherencia entre documentos

- **Los nombres de las bases de ejemplo no se renombran.** Ante la duda, se revisa `a04`.
- **Las definiciones y teoremas se citan por número** (`Definición 15.3`) y no se redefinen en otra
  fase con otras palabras. Si una fase necesita una variante, la declara como variante.
- **Los apéndices no repiten lo que explica una fase, y viceversa: se enlazan.**
- **Una fase no cita el plan de producción ni las propuestas**: cita a otra fase o a un apéndice.
- **Ningún enlace interno apunta a un documento que no existe todavía**: la referencia va en prosa y
  se anota en la deuda de enlaces del plan.
- 🗑️ **Los documentos desechables no se citan nunca.** Ningún archivo publicado del curso puede
  enlazar un `_desechable-*`. La comprobación está en §15.
- **Git:** lo maneja Oskar. Las convenciones, para cuando él commitee: prefijo de commit
  `01-bases fNN:` (ejercicios `01-bases fNN ejM:`), tags `fase-NN-<slug>`; en el bloque A.C., prefijo
  `01-bases acNN:` y tags `ac-fase-<slug>`, para que `git tag -l 'fase-*'` siga siendo el índice
  limpio del camino base.

---

## 14. 📓 Los documentos vivos

Crecen durante todo el curso y son producto, no apuntes.

- **`INSTINTOS.md`** — los 🪞 acumulados: cada punto donde el instinto de desarrollador falla, con su
  contraejemplo o su cálculo y la fase donde apareció. Al menos uno por bloque.
- **`a07-notacion-y-glosario.md`** — cada símbolo y cada término nuevo entra aquí en la misma fase
  que lo introduce, con su traducción en las dos direcciones.
- **`a08-mapa-de-bibliografia.md`** — cada recurso verificado, con fecha. Las fases toman de aquí.

---

## 15. ✅ Checklist antes de dar por cerrado un `.md`

```text
[ ] El bloque de metadatos está completo, con lectura base y fecha de
    verificación
[ ] Toda salida de radb, sqlite3, verificador o mini motor salió de una
    ejecución real
[ ] Toda verificación trae los cuatro datos de §6 y su comando de
    reproducción
[ ] Todo costo trae sus supuestos y su fórmula, y se presenta como modelo
[ ] Lo no verificado está declarado con esas palabras
[ ] Definiciones y teoremas numerados; ninguno redefinido de otra fase
[ ] La sección "De la teoría a los motores" dice dónde se aparta SQL
[ ] Hay un ⚖️ "Hasta dónde llega la teoría" con su costo
[ ] Errores conceptuales con contraejemplo; ninguno juzga a una persona
[ ] Traducción de notación y vocabulario en las dos direcciones
[ ] Términos nuevos en a07; 🪞 nuevos en INSTINTOS.md; recursos nuevos en
    a08
[ ] Ejercicios: 30–45 (18–20 en F00 y F37), agrupados, con conteo en el
    título
[ ] Cada ejercicio con tipo, Criterio de éxito y enlace a su solución
[ ] Al menos un cuarto 🔎 (si la fase tiene herramienta); al menos tres 🧮 en
    bloques II y III
[ ] El solucionario existe, completo, y cada solución está contrastada
[ ] Identificadores en inglés, también en el álgebra; nunca grade, foo ni
    tabla1
[ ] Notación en Unicode, cero LaTeX; diagramas ASCII de 75 columnas o menos
[ ] Bibliografía en cuatro grupos, verificada en la sesión, con fecha y 💲
    donde aplica
[ ] Ningún enlace a un documento que todavía no existe
[ ] Cuerpo dentro de la banda de §8, sin contar ejercicios
[ ] Tuteo en todo el documento; cero voseo, cero "usted"
[ ] Todo lo ejecutado corrió en un contenedor mdm-*, sin puertos por
    defecto
[ ] Código en inglés, comentarios en español con tildes
[ ] grep -ln "_desechable-" *.md soluciones/*.md en la raíz del curso no
    devuelve nada
```

---

## 16. ⚖️ Excepciones declaradas al `CLAUDE.md` del repositorio

El `CLAUDE.md` permite que un curso se aparte de los defaults **si nombra la regla y dice por qué**.
Estas son las de este curso, las mismas de §13.3 del alcance. Si no estuvieran escritas aquí, cada
sesión futura las "arreglaría" de vuelta.

1. **Sin `BENCHMARKS.md`.** Las comparaciones se sostienen con el modelo de costo de la fase, porque
   el curso es de teoría y no tiene motor que medir.
2. **Forma de fase de libro de texto** (§8), con la ⚰️ autopsia reemplazada por **errores
   conceptuales con contraejemplo** y el ⚖️ veredicto por **hasta dónde llega la teoría**.
3. **Ejercicios: 30–45 por fase**, por encima de la banda del repositorio, con solucionario aparte.
4. **Se explica desde la definición lo que el lector ya usa.**
5. **Sin historia narrativa.**
6. **"Modelos de acceso, no productos" no aplica en su forma habitual**: aquí no hay productos.
7. **Comentarios de código en español con tildes**, como en los cursos hermanos de `cursos-bd/`.

Todo lo demás del `CLAUDE.md` aplica tal cual: idioma, tono, estructuras recurrentes reinterpretadas
donde se dijo, convenciones de markdown, nombres de archivo, prefijo de track y flujo de git.

---

## 17. 📌 Lo que la tanda de verificación resolvió para esta guía

Cerrado en P8 el 03/10/2026; el detalle, con las salidas literales, está en
`prompts/verificacion-de-laboratorio/hallazgos.md`.

- **Versiones fijadas** (tabla inicial de los hallazgos): Python 3.10 como mínimo, SQLite 3.37.0 como
  mínimo por `STRICT`, `radb` 3.0.5, SQLAlchemy 2.0.54 y Faker 40.40.0, fijados en el
  `requirements.txt` del curso. Las fases siguen sin publicar números: apuntan a `a01`–`a03`.
- **`radb` funciona sobre tablas `STRICT`** (H3). Las bases se crean en una sola variante, `STRICT`,
  y §6 queda como está. Dos consecuencias para `a04`: las fechas van en `TEXT` con formato ISO 8601,
  porque `STRICT` no admite `DATE`, y las bases no usan `ANY` ni `BLOB`, que `radb` tipa mal.
- **La invocación de `radb`** es `radb base.db -i archivo.ra` (H4), y es la que usa §6. El SQL
  generado se ve con `-d` (H5).
- **`NULL` en `radb`** se imprime como `None`; σ sigue la lógica de tres valores, y ∪, ∩ y − tratan dos
  `NULL` como iguales (H5). Es material de F11, no una regla de esta guía.

