# 🧩 Plantillas de capítulo
## El motor de motores

Los seis esqueletos que se copian al abrir una sesión nueva: **fase del camino base**, **fase de
panorama** (F00 y F37), **fase del bloque A.C.**, **caso de estudio A.C.** (AC06–AC08),
**solucionario** y **apéndice**. Las cuatro de fase y la de solucionario son rígidas y se siguen
literales; la de apéndice es deliberadamente laxa, porque un apéndice de instalación y uno de
notación no se parecen en nada.

Junto con [`alcance-del-proyecto.md`](alcance-del-proyecto.md), la
[guía de estilo](guia-de-estilo-y-convenciones.md) y las dos propuestas, forman el marco para que
cuarenta y ocho fases escritas en cuarenta y ocho sesiones se lean como un solo libro.

> **Nota de coherencia:** las horas, los conteos de ejercicios, las lecturas base y las dependencias
> de cada fase viven en [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md). Si alguna
> vez cambian, se cambian **allí primero** y aquí después. Lo normativo de la forma está en la guía
> §7, §8, §9 y §10; si esta plantilla y la guía discrepan, gana la guía.

---

# 📐 Plantilla 1 — Fase del camino base

Copia el bloque, rellena los `{{placeholders}}` y borra las notas entre llaves antes de entregar.

````markdown
# {{emoji}} Fase {{NN}} — {{Tema}}: {{la promesa concreta del documento}}

> **Curso:** El motor de motores · Fase {{NN}} de 37 · Bloque {{romano}} · **{{X}} h**
> **Lectura base:** Navathe 7.ª ed., cap. {{N}} · {{Date 8.ª ed., cap. M | otro de los cinco textos}}
> **Herramientas:** {{papel · radb · sqlite3 · verificadores (`closure`, …) · mini motor}}
> **Bases:** {{`school` (…) · `supply` (…) · relaciones abstractas}}
> **Depende de:** F{{NN-1}} · **Habilita:** F{{…}}
> **Apéndices de apoyo:** {{a01, a03, a04, a07}}
> **Fecha de verificación:** {{DD/MM/AAAA}}
> **Objetivo:** {{una frase, verificable: "calcular…", "demostrar…", "escribir…"}}

---

## 🧭 1. Dónde estamos

{{Qué dejó la fase anterior, qué hay que traer (definiciones por número, herramientas instaladas) y
por qué este tema entra justo aquí. Prosa, dos a cuatro párrafos. Si la fase abre un bloque, se
presenta el bloque. Si la fase es parte del hilo 🧵, se dice en qué punto del hilo estamos.}}

---

## 🎯 2. Objetivos de esta fase

{{3 a 6 objetivos verificables. "Entender las DF" no es verificable; "calcular todas las claves
candidatas de una relación de seis atributos y comprobarlo con el verificador `keys`" sí lo es.}}

---

## 🚫 3. Qué NO entra todavía

- {{tema diferido}} → F{{M}}.
{{Todo lo que se difiere lleva destino exacto. Sin destino, no se difiere: se corta.}}

---

## 📐 4. Teoría

{{El grueso de la fase, en subsecciones numeradas NN.1, NN.2… Cada concepto con la regla del
andamio (guía §4.1): problema → definición → intuición → ejemplo resuelto → verificación. Un
concepto nuevo por subsección. Ninguna subsección pasa dos pantallas sin ejemplo, diagrama o
verificación.}}

### {{NN}}.1 {{Concepto}}

{{El problema primero, sobre `school`, `supply` o una relación abstracta declarada.}}

> 📏 **Definición {{NN}}.{{M}} — {{Nombre}}.** {{Enunciado formal en Unicode, sin LaTeX. Ejemplo de
> forma: una dependencia funcional X → Y se cumple en el esquema R si para todo par de tuplas t₁,
> t₂ de cualquier estado válido de R, t₁[X] = t₂[X] ⇒ t₁[Y] = t₂[Y].}}

{{La intuición: qué dice la definición en palabras, y qué *no* dice.}}

> 📐 **Teorema {{NN}}.{{M}} — {{Nombre}}.** {{Enunciado.}}
>
> **Demostración.** {{Paso a paso, con la justificación de cada paso entre paréntesis. Si la
> demostración no enseña nada que el lector vaya a usar, enunciado y referencia al libro, y se dice.
> Nunca "se deja como ejercicio" algo que la fase necesita después.}} ∎

> ✍️ **Ejemplo resuelto {{NN}}.{{M}} — {{qué se resuelve}}.** {{Sobre una relación concreta, por
> ejemplo R(A, B, C, D, E) con F = {A → B, BC → D, D → E}. Todos los pasos numerados, con la regla
> que justifica cada uno.}}
>
> 1. {{paso}} ({{regla}})
> 2. {{paso}} ({{regla}})
>
> **Resultado:** {{…}}

> 🔎 **Verificación — {{qué se verificó}}** · {{`radb` | `sqlite3` | verificador `x` | mini motor}}
> · {{`school` | `supply`}} ({{datos chicos | generados, semilla N}}) · verificado el {{DD/MM/AAAA}}
>
> Reproducir: `{{comando exacto}}`

```text
-- radb
{{la expresión, con identificadores en inglés, p. ej.:}}
\project_{name} \select_{city = 'Lima'} supplier;
```

```text
{{salida literal, sin embellecer ni recortar}}
```

> 🧮 **Costo — {{operación}}** · modelo de F{{NN}} · {{supuestos: b_R = …, b_S = …, n_B = …, bfr = …}}
>
> costo = {{fórmula}} = **{{número}} accesos a bloque**

{{Diagramas ASCII en bloques `text`, 75 columnas como máximo.}}

**El patrón a memorizar.** {{Una o dos frases con la lección transferible.}}

**Prueba de fuego.** {{Una verificación concreta incrustada en el flujo: "corre el verificador y
confirma que la clausura de AB es ABCDE".}}

### {{NN}}.2 {{Concepto}}

{{…}}

---

## 🔀 5. De la teoría a los motores

> 🩻 **Esto sí funciona igual.** {{Lo que la teoría confirma de lo que el lector ya hace.}}

{{Qué implementan SQL y los motores tal cual, qué implementan distinto y qué no implementan. Donde
SQL se aparta del modelo (multiconjuntos, NULL, orden), se dice aquí y con un ejemplo en SQLite.
Remisión en prosa, sin enlace, al curso de motor que lo mide: "el bloque VI del curso de PostgreSQL
mide esto". Toda afirmación sobre un motor concreto, verificada en su documentación oficial con
fecha, o declarada no verificada. Si la fase lleva recuadro 🏛️ (F01, F03, F05, F07, F13, F24),
va aquí, en tres o cuatro líneas, sin contenido del que dependa el camino base.}}

> 🏛️ **Antes de Codd.** {{Cómo se resolvía esto en el modelo jerárquico o de red, en dos líneas, y la
> invitación al bloque A.C. en prosa mientras el bloque no exista.}}

---

## 🪞 6. Tu instinto de desarrollador dice… y esta vez se equivoca

{{Opcional por fase, obligatorio al menos uno por bloque. El punto exacto donde el modelo mental del
lector se rompe, con su contraejemplo o su cálculo. Se copia a INSTINTOS.md en la misma sesión. Si
la fase no tiene uno honesto, la sección se borra.}}

---

## ⚠️ 7. Errores conceptuales comunes

{{3 a 6, cada uno con el formato de la guía §2.1:}}

**{{N}}. "{{La afirmación equivocada, tal como la diría alguien razonable}}."**
{{Por qué parece cierta. El contraejemplo mínimo que la rompe, sobre una relación concreta. La
afirmación correcta.}}

---

## 📖 8. Traducción de notación y vocabulario

{{Cómo escriben y llaman esto Navathe, Date y los demás textos cuando difieren, y el español ↔
inglés en las DOS direcciones. Tabla corta; cada término nuevo entra a a07 en la misma sesión.}}

| Este curso | Navathe | Date | Inglés |
|---|---|---|---|
| {{…}} | {{…}} | {{…}} | {{…}} |

---

## ⚖️ 9. Hasta dónde llega la teoría

{{Cuándo NO conviene aplicar lo de esta fase, con su costo calculado y declarado como modelo:
normalizar más allá de lo que paga, un índice que no se justifica, una garantía que cuesta más de lo
que protege. Cada técnica gana en algún sitio y pierde en otro.}}

---

## 🧭 10. Resumen

{{Prosa corta, dos o tres párrafos, sin viñetas.}}

> 🧠 **El patrón a memorizar de la fase:** {{una frase.}}

---

## 🧪 11. Ejercicios ({{total}})

{{Guía §9. 30–45. Agrupados por dificultad con rango y conteo. Cada uno con tipo (✍️ 🔎 🧮 🧩 📖),
Criterio de éxito y enlace a su solución. Al menos un cuarto 🔎 si la fase tiene herramienta; al
menos tres 🧮 en los bloques II y III. En 🔎 de 🟠 y 🔴, predecir antes de ejecutar. Originales:
nada copiado de un libro.}}

> Las soluciones desarrolladas están en
> [`soluciones/{{NN-slug}}.md`](soluciones/{{NN-slug}}.md). Intenta cada ejercicio antes de abrirla.

## 🟢 Fácil — {{tema}} (1–{{a}})

### 🟢 Ejercicio 1 · {{✍️}} — {{título corto}}

{{Enunciado, sobre `school`, `supply` o una relación abstracta declarada.}}

**Criterio de éxito:** {{lo que hay que obtener o demostrar, comprobable.}}
[Solución](soluciones/{{NN-slug}}.md#ejercicio-1)

## 🟡 Intermedio — {{tema}} ({{a+1}}–{{b}})
## 🟠 Difícil — {{tema}} ({{b+1}}–{{c}})
## 🔴 Muy difícil — {{tema}} ({{c+1}}–{{total}})
## 🔥 Opcionales

---

## 📚 12. Bibliografía y recursos

> ⚠️ Las URLs, los cursos y sus precios cambian. Todo lo de esta sección se verificó el
> {{DD/MM/AAAA}}; el inventario vivo está en `a08`.

**Libros**
- {{Autor, *Título*, edición, cap. / sección}} — {{lectura base: qué cubre}}
- {{…}} — {{complementaria: qué aporta que la base no tiene}}

**Cursos**
- {{Título}} · {{Udemy | Coursera}} · {{idioma}} · {{💲 si es de pago}} · {{URL completa}} —
  {{por qué vale la pena y qué módulo corresponde a esta fase}}

**Videos**
- {{Curso completo en YouTube, clase concreta}} · {{duración}} · {{URL}} — {{qué cubre}}

**Otros**
- {{Paper fundacional, notas de curso, herramienta}} · {{URL}} — {{…}}
- Práctica adicional: {{Navathe 7.ª ed., ejercicios N.x, N.y}}

**Orden de lectura sugerido:** {{antes de la fase → durante → después}}

---

## 🏁 13. Cierre

{{Qué sabe hacer ahora el lector, en dos o tres frases; qué abre la fase siguiente.}}

> **La señal de que quedó bien:** {{criterio en forma de cita: "resuelves el ejercicio 30 sin abrir
> el solucionario y el verificador te da la razón".}}

> 🏷️ **Git lo maneja Oskar.** Cuando cierre la fase, el tag es `fase-{{NN}}-{{slug}}` y el prefijo de
> commit `01-bases f{{NN}}:` (ejercicios `01-bases f{{NN}} ej{{M}}:`).

---

## 📌 Pendientes sugeridos

{{Material de autoría, no de lectura. Lo que apareció al escribir y no cabía, con destino explícito.
Se borra si no hay nada.}}
````

## Recordatorios al rellenar una fase del camino base

- **Longitud de cuerpo** (cortando por 🧪 Ejercicios): **4.500–6.500 palabras** en fases de
  10–12 h; **5.500–7.500** en las de 14–16 h; **3.000–4.500** en las de 6–8 h (tabla de la guía §8).
  Los ejercicios no cuentan.
- **Ejercicios: 30–45**, distribución ≈ 30 % 🟢, 30 % 🟡, 25 % 🟠, 15 % 🔴, calibrada por fase (las
  de cálculo cargan hacia 🟢🟡, las de diseño y teoría hacia 🟠🔴). 🔥 no cuenta.
- **El solucionario se escribe en la misma sesión** que la fase, con la Plantilla 5. Una fase sin
  solucionario completo y contrastado no está terminada.
- **Unicode, nunca LaTeX.** Condiciones y atributos después del operador, separados por un espacio.
- **ASCII de 75 columnas como máximo** en diagramas; si no cabe, primero se simplifica.
- **Identificadores en inglés**, también en el álgebra. Nunca `grade` solo, nunca `foo`, `bar` ni
  `tabla1`.
- **Nada sin verificar**: toda salida, real; todo costo, con supuestos y fórmula; lo no verificado,
  declarado con esas palabras.
- **Ningún enlace a un documento que todavía no existe**: va en prosa y a la deuda de enlaces.
- **Definiciones y teoremas numerados por fase**, y citados por número; nunca redefinidos.
- **Documentos vivos en la misma sesión**: términos a `a07`, recursos a `a08`, 🪞 a `INSTINTOS.md`.
- Al cerrar, el checklist de la guía §15.

---

# 🌐 Plantilla 2 — Fase de panorama (F00 y F37)

Las dos fases de panorama abren y cierran el camino base. Son de orientación y de criterio, no de
cálculo: menos teoría formal, más mapa. Misma plantilla que la 1, con estos cambios.

````markdown
# {{emoji}} Fase {{00 | 37}} — {{Tema}}: {{la promesa concreta}}

> **Curso:** El motor de motores · Fase {{NN}} de 37 · Bloque {{0 | VIII}} · **{{X}} h**
> **Lectura base:** Navathe 7.ª ed., cap. {{N}}
> **Herramientas:** {{papel | sqlite3}}
> **Depende de:** {{nada | F36}} · **Habilita:** {{F01 | el bloque A.C. y los cursos de motor}}
> **Apéndices de apoyo:** {{…}}
> **Fecha de verificación:** {{DD/MM/AAAA}}
> **Objetivo:** {{una frase, verificable}}

---

## 🧭 1. Dónde estamos
## 🎯 2. Objetivos de esta fase
## 🚫 3. Qué NO entra todavía

## 🗺️ 4. {{El mapa}}

{{F00: qué resuelve un DBMS, sus actores, cuándo NO usar uno, y el mapa del curso por bloques.
F37: bases distribuidas, 2PC, CAP, por qué existen las familias NoSQL, DW y OLAP en una página,
y la remisión a la Ruta NoSQL Lite (solo referencias de concepto: la documental es jerárquica en el
fondo, la de grafos es una red). Definiciones 📏 solo donde hagan falta; menos demostraciones.}}

## 🔀 5. De la teoría a los motores
{{F37 lleva aquí su recuadro 🏛️.}}

## ⚠️ 6. Errores conceptuales comunes
## 📖 7. Traducción de notación y vocabulario
## ⚖️ 8. Hasta dónde llega la teoría
## 🧭 9. Resumen

## 🧪 10. Ejercicios ({{18–20}})

{{De lectura, clasificación y decisión más que de cálculo: "aquí tienes la descripción de un
sistema; di qué nivel ANSI/SPARC cambia si…". Mismo formato de tipo, Criterio de éxito y enlace al
solucionario.}}

## 📚 11. Bibliografía y recursos
## 🏁 12. Cierre
````

## Recordatorios al rellenar una fase de panorama

- **Longitud: 2.000–3.000 palabras de cuerpo.**
- **Ejercicios: 18–20**, con solucionario igual que las demás.
- **F00 no usa herramientas**; si muestra SQL, es para ilustrar y va verificado igual.
- **F37 no profundiza**: si una sección pide más de dos pantallas, pertenece a otro curso y se
  remite.
- El 🪞 es opcional aquí; el del Bloque 0 puede estar en F01.
- Todo lo demás, como en la Plantilla 1.

---

# 🏛️ Plantilla 3 — Fase del bloque A.C. — Antes de Codd

El bloque es opcional y autocontenido: **nada del camino base depende de él, y él puede depender del
camino base** (cita definiciones por número). Misma plantilla que la 1 con dos cambios: el
encabezado y la sección 5.

````markdown
# 🏛️ Fase AC{{NN}} — {{Tema}}: {{la promesa concreta}}

> **Curso:** El motor de motores · Bloque A.C. — Antes de Codd (opcional) · Fase AC{{NN}} de AC09 ·
> **{{X}} h**
> **Lectura base:** {{paper o libro de la bibliografía del bloque, con sección}}
> **Herramientas:** {{papel · Python (`venv`) · laboratorio L{{N}} · radb · contenedor de aca-02}}
> **Bases:** {{`school` en jerárquico | `supply` con pedidos en red}}
> **Depende de:** {{AC{{NN-1}} · F{{…}} del camino base}} · **Habilita:** AC{{NN+1}}
> **Apéndices de apoyo:** {{aca-01, aca-02, a02, a04}}
> **Fecha de verificación:** {{DD/MM/AAAA}}
> **Objetivo:** {{una frase, verificable}}

---

## 🧭 1. Dónde estamos
## 🎯 2. Objetivos de esta fase
## 🚫 3. Qué NO entra todavía

## 📐 4. Teoría

{{Igual que en la Plantilla 1. El modelo navegacional se explica con su propio vocabulario
(segmento, set, currency, database key) y se contrasta con el relacional citando definiciones del
camino base por número. Los laboratorios L1–L5 aparecen aquí, con su salida literal y el contador de
bloques. Lo que no se puede ejecutar (DL/I, DML de CODASYL reales) se enseña en papel y con los mini
DML, y se dice: "no hay IMS ni IDMS que correr en una laptop".}}

## 🔀 5. De entonces a ahora

{{Dónde vive hoy este modelo o esta idea: productos y tecnologías actuales, con la versión y el
motor verificados en la sesión o declarados no verificados. Qué gana el ingeniero que lo reconoce.
Con la Ruta NoSQL Lite, solo referencias de concepto, en prosa.}}

## 🪞 6. Tu instinto de desarrollador dice… y esta vez se equivoca
## ⚠️ 7. Errores conceptuales comunes
## 📖 8. Traducción de notación y vocabulario
{{Aquí la traducción es entre modelos: segmento ↔ tupla, set ↔ clave foránea, currency ↔ cursor,
en las dos direcciones.}}
## ⚖️ 9. Hasta dónde llega la teoría
{{Dónde el modelo navegacional gana de verdad (localidad física, un solo patrón de acceso conocido)
y dónde pierde, con el contador de bloques o líneas de código que cambian.}}
## 🧭 10. Resumen
## 🧪 11. Ejercicios ({{total}})
## 📚 12. Bibliografía y recursos
{{De la bibliografía propia del bloque; no cuenta contra el tope de cinco textos del camino base.}}

## 🏁 13. Cierre

> **La señal de que quedó bien:** {{…}}

> 🏷️ **Git lo maneja Oskar.** Tag `ac-fase-{{slug}}`, prefijo de commit `01-bases ac{{NN}}:`.
````

## Recordatorios al rellenar una fase del bloque A.C.

- **Prefijo de track**: archivo `ac{{NN}}-slug.md`, solucionario `soluciones/ac{{NN}}-slug.md`,
  código en `src/ac{{NN}}-slug/`, tags `ac-fase-<slug>`. Nunca se añade nada a archivos del camino
  base.
- **Ejercicios**: los que fija la propuesta para esa fase (15–30), con la misma escala y el mismo
  solucionario.
- **Longitud**: la banda de la guía §8 según las horas (3.000–4.500 palabras en fases de 6–8 h,
  2.000–3.000 en AC00).
- **Nada de productos de memoria**: qué motor usa hoy un producto, desde qué versión y con qué
  licencia, se verifica en la sesión o se declara no verificado.
- **AC09 (C)**: ANSI C por línea de comandos, sin dependencias, compilado con GCC y con Visual C++
  antes de publicar, con los comandos de compilación literales de ambos.
- Todo lo demás, como en la Plantilla 1.

---

# 🔬 Plantilla 4 — Caso de estudio A.C. (AC06–AC08)

Variante de la Plantilla 3 para los tres casos con productos reales: **Git (AC06), LMDB (AC07) y
YottaDB (AC08)**. Todos tienen la misma forma, para que se puedan comparar entre sí. La sección 4
se reemplaza por 🔬 El caso.

````markdown
# 🔬 Fase AC{{NN}} — Caso de estudio: {{producto}}, {{la promesa concreta}}

> **Curso:** El motor de motores · Bloque A.C. — Antes de Codd (opcional) · Fase AC{{NN}} de AC09 ·
> **{{X}} h**
> **Producto:** {{nombre}} {{versión verificada}} · **Licencia:** {{…}} · **Instalación:**
> {{nativa en … | contenedor de aca-02 en …}}
> **Herramientas:** {{CLI del producto · Python (`venv`) · radb · sqlite3 · contador de L1}}
> **Bases:** {{`school` | `supply` con pedidos}}
> **Depende de:** AC01–AC03 {{y F… del camino base}} · **Habilita:** {{…}}
> **Apéndices de apoyo:** {{aca-01 | aca-02}}, a02, a04
> **Fecha de verificación:** {{DD/MM/AAAA}}
> **Objetivo:** {{una frase, verificable}}

---

## 🧭 1. Dónde estamos
## 🎯 2. Objetivos de esta fase
## 🚫 3. Qué NO entra todavía

## 🔬 4. El caso

### 4.1 El producto

{{Qué es, quién lo usa hoy y para qué, verificado con fecha. Cómo se instala: enlace al apéndice,
nunca la receta completa aquí.}}

### 4.2 Su modelo, con el vocabulario del bloque

{{Qué es en términos de AC01–AC03: gestor de registros, jerárquico, red. Qué es un "registro", un
"puntero", un "set" o un "segmento" en este producto. Diagrama ASCII de 75 columnas como máximo.}}

### 4.3 La pregunta navegacional, con saltos contados

{{Una pregunta que el producto responde bien porque su estructura la previó. Se ejecuta con su CLI o
desde Python y se cuentan los saltos o accesos con el contador de L1. Salida literal.}}

> 🔎 **Verificación — {{pregunta}}** · {{producto y versión}} · {{base}} · verificado el {{fecha}}
>
> Reproducir: `{{comando exacto}}`

### 4.4 La misma pregunta, en relacional

{{Se exporta o se carga lo mismo en SQLite y la pregunta se escribe en SQL y en álgebra con radb.
Se comparan accesos (en el modelo de costo del camino base) y líneas de código.}}

### 4.5 La pregunta que el modelo no previó

{{La pregunta que cruza la estructura (Git: en qué commits cambió un archivo; LMDB: el set inverso;
YottaDB: todas las secciones de un alumno). Cuánto cuesta en el producto, cómo se resuelve ahí
(índice a mano, global inverso, recorrido completo) y cuánto en relacional.}}

**El patrón a memorizar.** {{…}}

---

## 🔀 5. De entonces a ahora
{{Qué otros productos actuales comparten este modelo o este motor.}}
## 🪞 6. Tu instinto de desarrollador dice… y esta vez se equivoca
## ⚠️ 7. Errores conceptuales comunes
## 📖 8. Traducción de notación y vocabulario
## ⚖️ 9. Hasta dónde llega la teoría
## 🧭 10. Resumen
## 🧪 11. Ejercicios ({{total}})
## 📚 12. Bibliografía y recursos
## 🏁 13. Cierre

> 🏷️ **Git lo maneja Oskar.** Tag `ac-fase-{{slug}}`, prefijo de commit `01-bases ac{{NN}}:`.
````

## Recordatorios al rellenar un caso de estudio

- **Las cinco subsecciones de 🔬 El caso van siempre, en ese orden.** Es lo que hace comparables
  los tres casos.
- **El producto se instala y se ejecuta en la sesión.** Versión, licencia y plataformas, con fecha.
  YottaDB fuera de Linux corre en el contenedor de `aca-02`, y se dice.
- **Los conteos de saltos salen del contador de L1**, no de una estimación.
- **Ejercicios: 20–22**, la mitad de ellos 🔎 sobre el producto real.
- Todo lo demás, como en las Plantillas 1 y 3.

---

# ✅ Plantilla 5 — Solucionario

Un archivo por fase, `soluciones/NN-slug.md` (o `soluciones/acNN-slug.md`), con el mismo nombre que
la fase. Se escribe en la misma sesión que la fase.

````markdown
# ✅ Soluciones — Fase {{NN}}: {{Tema}}

> **Curso:** El motor de motores · Solucionario de la [Fase {{NN}}](../{{NN-slug}}.md)
> **Ejercicios:** {{total}} · **Verificado el:** {{DD/MM/AAAA}} con {{radb x.y · sqlite3 x.y ·
> verificadores}}

> ⚠️ **Intenta el ejercicio antes de leer su solución.** La solución te enseña el paso que te
> faltó; leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–{{a}})

### Ejercicio 1

**Enunciado (resumen):** {{una o dos líneas, suficientes para saber de qué se trata sin volver a la
fase.}}

**Solución.**

1. {{paso}} ({{justificación: Definición NN.M, regla de Armstrong, paso del algoritmo}})
2. {{paso}} ({{justificación}})
3. {{…}}

**Resultado:** {{…}}

> 🔎 **Verificación** · {{herramienta y versión}} · {{base y datos}}
>
> Reproducir: `{{comando exacto}}`

```text
{{salida literal}}
```

> ⚠️ **Error típico:** {{opcional: el paso donde la gente suele equivocarse en este ejercicio.}}

[← Volver al ejercicio](../{{NN-slug}}.md#ejercicio-1)

### Ejercicio {{N}} (🔴, abierto)

**Enunciado (resumen):** {{…}}

**Rúbrica.** Una respuesta correcta tiene que:
- {{criterio}}
- {{criterio}}

Y queda invalidada si:
- {{error que la invalida}}

**Solución de referencia.** {{desarrollada, con sus pasos.}}

## 🟡 Intermedio ({{a+1}}–{{b}})
## 🟠 Difícil ({{b+1}}–{{c}})
## 🔴 Muy difícil ({{c+1}}–{{total}})
## 🔥 Opcionales
````

## Recordatorios al rellenar un solucionario

- **Un ancla por ejercicio** (`### Ejercicio N` genera `#ejercicio-n`); los enlaces de la fase
  apuntan ahí. Comprobar que resuelven.
- **Solución desarrollada, nunca solo el resultado.** Cada paso con su justificación.
- **Ninguna solución sin contrastar**: verificador, herramienta o una segunda resolución
  independiente. Si se contrastó a mano, se dice.
- **Rúbrica en todos los abiertos**, con una solución de referencia.
- **Salida literal** de toda herramienta; mismas reglas de Unicode, ASCII e identificadores que la
  fase.
- El solucionario **no añade teoría nueva**: si una solución necesita un concepto que la fase no
  dio, el problema está en la fase.

---

# 📎 Plantilla 6 — Apéndice

Laxa a propósito. Lo único que comparten: encabezado, índice, secciones cortas con ejemplo mínimo,
tabla de decisión, advertencias, referencias y ejercicios.

````markdown
# 📎 Apéndice {{aNN | aca-NN}} — {{Nombre}}

> **Curso:** El motor de motores · Consulta rápida · **{{X}} h**
> **Usado por:** {{fases}} · **Versiones cubiertas:** {{SQLite x.y · Python x.y · radb x.y · …}}
> **Plataformas verificadas:** {{Windows 11 · macOS (arm64) · Linux}}
> **Fecha de verificación:** {{DD/MM/AAAA}}

**Esto no se lee de corrido.** Se entra por el índice buscando algo concreto y se sale.
{{Una línea sobre qué problema resuelve.}}

**Qué queda fuera:** {{lo que el apéndice no cubre y dónde está: la fase que lo explica, o
`docker-container-legacy/` en los de contenedores.}}

---

## Índice
- [{{Sección 1}}](#)
- [Cuándo usar qué](#)
- [Referencias](#)

---

## {{Sección}}

{{Formato libre. Secciones cortas que responden a UNA pregunta, ejemplo mínimo ejecutable con su
salida literal, y los nombres de las bases del curso siempre que haya datos. En los de instalación,
una subsección por plataforma (Windows: winget, Chocolatey o Scoop y PowerShell; macOS: brew; Linux:
apt, dnf o pacman) y la comprobación de que quedó bien.}}

---

## 🧭 Cuándo usar qué

| {{Situación}} | {{Opción}} | {{Por qué}} |
|---|---|---|

{{Si el apéndice no compara opciones, una tabla de referencia rápida o un checklist.}}

---

## ⚠️ Advertencias
## 📚 Referencias
{{Documentación oficial primero, con versión y fecha de verificación.}}
## 🧪 Ejercicios (5–10)

{{Cortos y de consulta: instalar y comprobar, cambiar un valor y observar, provocar un error típico
y reconocerlo por su mensaje literal.}}
````

## Recordatorios al rellenar un apéndice

- **Las horas del apéndice no cuentan** dentro de las del curso.
- **Un apéndice no repite lo que explica una fase: enlaza.**
- **Todo comando, ejecutado en las plataformas que el apéndice declara**; la que no se verificó, se
  declara con esas palabras.
- **Los de contenedores (`a09`, `aca-02`) no explican Docker**: comandos, su equivalente Podman y
  nada más; el mecanismo, en `docker-container-legacy/`.
- **`a07` y `a08` son documentos vivos**: crecen con cada fase y su encabezado lleva la fecha de la
  última entrada.
- **Los del bloque A.C. llevan el prefijo `aca-`** y no se mezclan con los del camino base.
- **Antes de escribir, confirma tres cosas:** qué versiones exactas se cubren, qué fases lo usan a
  esa altura del curso, y qué queda explícitamente fuera.
