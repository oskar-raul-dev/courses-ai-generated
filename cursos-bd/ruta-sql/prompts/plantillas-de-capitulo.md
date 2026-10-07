# 🧩 Plantillas de capítulo
## Ruta SQL

Los seis esqueletos que se copian al abrir una sesión nueva: **fase de tema** (F03–F23), **fase del
Bloque 0** (F00–F02), **fase del árbitro** (F24–F26), **fase del track** (`ss01`–`ss05`),
**apéndice** y **solucionario** (agregado el 06/10/2026, D18). Las cuatro de fase y la de
solucionario son rígidas y se siguen literales; la de apéndice es laxa a propósito.

> **Nota de coherencia:** las horas y los conteos de ejercicios son los de
> [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) §11. Si cambian, se cambian **allí
> primero** y aquí después. Las longitudes son las de la [guía](guia-de-estilo-y-convenciones.md) §9.

---

# 🧩 Plantilla de fase de tema — F03 a F23

Copia el bloque, rellena los `{{placeholders}}` y borra las notas entre llaves antes de entregar.

````markdown
# {{emoji}} Fase {{NN}} — {{Tema}}: {{la promesa concreta del documento}}

> **Curso:** Ruta SQL · Fase {{NN}} de 26 · Bloque {{romano}} — {{nombre del bloque}} · **{{X}} h**
> **Motores:** PostgreSQL `postgres@sha256:{{digest}}` · contraste {{MySQL `mysql@sha256:…` | —}} · {{Oracle (apuesta sin resolver) | —}}
> **Entorno de ejecución:** {{SQL | SQL + Python | SQL + Python + Java}}
> **Perfil de volumen:** {{S para los ejemplos, M para las mediciones | … y L para la rotura}}
> **El dolor de Alameda:** {{una línea, con su año y la sección de la historia}}
> **Depende de:** Fase {{NN-1}} · **Habilita:** Fase {{NN+1}}
> **Apéndices de apoyo:** {{a02, a04, a05, …}}
> **Fecha de verificación ejecutada:** {{DD/MM/AAAA}}
> **Objetivo:** {{una frase, verificable}}

---

## 🧭 1. Dónde estamos

{{Qué dejó la fase anterior, qué falta, y la escena de Alameda que abre esta: quién tiene el
problema, qué día, con qué consecuencia. Prosa, tres o cuatro párrafos. Si el bloque acaba de
empezar, se presenta el bloque.}}

---

## 🎯 2. Objetivos de esta fase

{{3 a 5 objetivos verificables. "Entender el aislamiento" no es verificable; "reproducir el write
skew de la muestra en REPEATABLE READ y demostrar que SERIALIZABLE lo impide" sí lo es.}}

---

## 🚫 3. Qué NO entra todavía

- {{tema diferido}} → Fase {{M}}.
{{Sin destino, no se difiere: se corta.}}

---

## 🏚️ 4. El dolor, en la caja

{{El problema reproducido sobre `legacy`, con la consulta, la salida literal y el número de "antes".
Un callout 🏚️ con el fragmento de la caja (la fila, la línea del `.bas`, la tabla con nombre raro).
Aquí se honra la decisión original: por qué era razonable el año en que se tomó.}}

---

## 🧩 5. {{El mecanismo}}

{{El grueso de la fase, en Postgres. Regla del andamio en cada concepto: el dolor primero, el
mecanismo después y el comando con su salida real al final. Nombres del dominio fijos. Cada
decisión de diseño con su porqué.}}

> 🩻 **Esto sí funciona igual.** {{Lo que se transfiere sin cambios: desde el ORM del lector, entre
> motores, o desde Access.}}

> 📐 **Medición: {{qué}}** · perfil {{M}} · `postgres@sha256:…` · verificado el {{fecha}}
>
> {{tabla con la medida estructural}}
>
> Reproducir: `{{comando exacto}}`

**El patrón a memorizar.** {{Una o dos frases con la lección transferible.}}

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

{{Solo lo que cambia la decisión (guía §4.4). Si MySQL se comporta igual, una línea 🩻 y se sigue.
Oracle, siempre como apuesta 🪞🔒 sin resolver, con el mecanismo citado de la documentación oficial
y la nota de licencia la primera vez. Si en esta fase ningún otro motor cambia nada, la sección lo
dice en un párrafo y explica por qué.}}

---

## 🪞 7. Tu instinto dice… y la apuesta

{{El instinto del desarrollador que usa la base como pote, en su mejor versión. Después, la apuesta
falsable escrita ANTES de medir y nunca editada, la medición, y el resultado: ganada o perdida, con
el número delante. Se copia a INSTINTOS.md y a la bitácora.}}

> 🪞 **Apuesta antes de ejecutar.** {{predicción con número esperado}}
> **Resultado:** {{…}}

---

## 💥 8. El punto de rotura

{{El volumen, la concurrencia o el dato exacto con que se rompe, el mensaje de error literal (o, en
las fases de plan, la línea del plan que cambió), y qué hay que cambiar para salir. El mensaje entra
en a08-catalogo-de-errores.md aunque hoy no se use.}}

---

## ⚰️ 9. Autopsia: {{la decisión de Alameda}}

{{Estructura de la guía §2.1: la decisión en la voz de quien la tomó y con su mejor argumento; por
qué era razonable entonces; qué pasó después, con número; cuánto cuesta salir, con número; qué
restricción o qué pregunta lo habría cambiado. Nunca un juicio sobre la persona.}}

**Antes y después, con números:** {{la misma operación en el diseño heredado y en el nuevo, medida
con el arnés.}}

---

## 📖 10. Traducción

{{Tabla corta en las dos direcciones: desde Access/T-SQL, entre los tres motores y, si aplica, hacia
la NoSQL Lite. Enlace a a07 para el diccionario completo.}}

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

{{Las pérdidas con número. Las cinco preguntas, respondidas en una línea cada una para lo que la
fase enseñó. Lo que se le concede a la propuesta rival, si esta fase la toca.}}

---

## ⚠️ 12. Errores comunes y diagnóstico

{{2 a 5 errores: síntoma → mensaje literal → causa → comprobación 🩺 → salida. Todos a a08.}}

---

## 📋 13. Checklist de validación

```text
[ ] {{comprobación ejecutable}}
```

---

## 🧪 14. Ejercicios ({{total}})

{{Guía §10. Agrupados por dificultad con rango y conteo, un tercio de diagnóstico o medición, al
menos uno sobre `legacy`, cada uno con Objetivo o Pregunta y cerrado con
`[Solución](soluciones/{{NN-slug}}.md#ejercicio-N)`. Los de Oracle piden resolver la apuesta y
explicarla con la documentación.}}

## 🟢 Fácil — {{tema}} (1–{{a}})
## 🟡 Intermedio — {{tema}} ({{a+1}}–{{b}})
## 🟠 Difícil — {{tema}} ({{b+1}}–{{c}})
## 🔴 Muy difícil — {{tema}} ({{c+1}}–{{total}})
## 🔥 Opcionales

---

## 📚 15. Referencias

**Documentación oficial** {{de la versión del curso, por motor}}
**Papers y libros** {{por la edición fijada en la guía §11}}
**Orden de lectura sugerido:** {{antes de ejecutar → durante → después}}

> ⚠️ {{Las URL y los contenidos cambian; adviértelo si el enlace no es de la versión del curso.}}

---

## 🏁 16. Resultado de la fase

{{Qué queda construido y medido, como ficha de cierre en un bloque text (guía §19.1).}}

{{Si la fase cierra un bloque: el 💀 boss del bloque en su propio apartado, en voz de quien lo pide,
empezando con el sistema roto; y la nota del 🏆 boss global "Un martes", marcada como opcional.}}

> **La señal de que quedó bien:** {{criterio en forma de cita.}}

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-{{NN}}-{{slug}} -m "F{{NN}} cerrada: {{el checklist en una línea por ítem}}"
> ```
>
> Commits de la fase con prefijo `f{{NN}}:`, los de ejercicio `f{{NN}} ej17: …`.

---

## 📌 Pendientes sugeridos

{{Material de autoría. Lo que apareció al escribir y no cabía, con destino explícito.}}
````

---

## Recordatorios al rellenar una fase de tema

- **Horas y ejercicios de la propuesta §11**, longitud de la guía §9. No se improvisan.
- **Ningún número sin ejecutar.** **Ningún número de Oracle ni de SQL Server**, nunca.
- **El dolor va antes que el mecanismo**, y el dolor se reproduce sobre la caja, no se cuenta.
- **Cada motor aparece solo donde cambia la decisión.**
- **Postgres bien jugado**: si el diseño del curso gana, gana contra la mejor versión razonable del
  rival.
- **Los tres documentos vivos se alimentan al cerrar**: la bitácora, `a08` e `INSTINTOS.md`.
- **El solucionario se escribe en la misma sesión**, con la plantilla de solucionario: una fase sin
  `soluciones/{{NN-slug}}.md` completo y ejecutado no está cerrada.
- **Los datos de la historia no se inventan de nuevo**: si falta uno, se agrega primero a
  `00-historia-de-alameda.md`.
- **Ningún `README.md` se toca, ni se crea `0-ESTRUCTURA-CURSO.md`,** al cerrar una fase: se
  escriben en su tanda final y aparte.
- 🗑️ **No se cita nunca** un archivo `_desechable-*`.

---

# 🧭 Plantilla de fase del Bloque 0 — F00 a F02

No tienen un mecanismo propio ni el aparato de apuesta y rotura. Rígida igual: se sigue literal, y
solo la sección 4 cambia de contenido según la fase.

````markdown
# {{emoji}} Fase {{NN}} — {{la promesa concreta del documento}}

> **Curso:** Ruta SQL · Fase {{NN}} de 26 · Bloque 0 — El instrumento · **{{X}} h**
> **Motores:** {{ninguno: esta fase se lee | PostgreSQL, MySQL y Oracle, con sus digests}}
> **Entorno de ejecución:** {{ninguno | SQL + Python}}
> **Depende de:** {{nada | Fase NN-1}} · **Habilita:** Fase {{NN+1}}
> **Apéndices de apoyo:** {{ninguno | a01, a02, a03, a04, a05, a06}}
> **Fecha de verificación ejecutada:** {{DD/MM/AAAA | no aplica: esta fase no ejecuta nada}}
> **Objetivo:** {{una frase, verificable}}

---

## 🧭 1. Dónde estamos
{{En F00: por qué existe este curso, a quién le habla y el primer día en Alameda. En F01 y F02: qué
dejó la fase anterior.}}

## 🎯 2. Objetivos de esta fase
## 🚫 3. Qué NO entra todavía

## {{emoji}} 4. {{El grueso de la fase}}

{{F00: la tesis, el villano doble, Alameda en una página, las tres propuestas y las autopsias ⚰️,
con la central de `DMax + 1`. F01: el laboratorio, la caja cargada tal cual en `legacy`, el primer
recorrido del catálogo y cómo se mide la forma en cada motor, con su prueba de fuego. F02: las cinco
preguntas desde el lado relacional, aplicadas a las partes de Alameda, y el triaje de "ya está en
producción".}}

## 🐘 5. Lo que el motor relacional ya te daba
{{En F00 como aviso: el curso existe para ganarse "casi siempre gana Postgres". En F01, como lo que
la caja no usó nunca: ni una restricción, ni una clave foránea validada. En F02, como la respuesta
por defecto a las cinco preguntas, y dónde deja de serlo.}}

## ⚠️ 6. Errores comunes y diagnóstico
{{En F00 y F02, errores de criterio. En F01, errores de laboratorio con su mensaje literal.}}

## 📋 7. Checklist de validación
## 🧪 8. Ejercicios ({{total}})
{{12 en F00 y F02 (exención declarada), de lectura y decisión. 22 en F01, la mitad de cargar y leer
planes, con al menos tres de la carga sucia. Cada uno cierra con su enlace a `soluciones/`.}}

## 📚 9. Referencias
## 🏁 10. Resultado de la fase

> **La señal de que quedó bien:** {{criterio en forma de cita.}}

> 🏷️ **Tag:** `fase-{{NN}}-{{slug}}` · prefijo de commit `f{{NN}}:`
````

---

# ⚖️ Plantilla de fase del árbitro — F24 a F26

El capstone no introduce mecanismos: decide con los que ya se midieron. Su evidencia es la
bitácora, y su entregable es un documento que el lector escribe.

````markdown
# ⚖️ Fase {{NN}} — {{la promesa concreta}}

> **Curso:** Ruta SQL · Fase {{NN}} de 26 · Bloque VI — El árbitro · **{{X}} h**
> **Motores:** {{los que usa}} · **Entorno de ejecución:** {{…}}
> **Evidencia:** bitácora de medición, entradas {{M-NN…}}
> **Depende de:** {{F23 | Fase NN-1}} · **Habilita:** {{Fase NN+1 | el cierre del curso}}
> **Fecha de verificación ejecutada:** {{DD/MM/AAAA}}
> **Objetivo:** {{una frase, verificable}}

---

## 🧭 1. Dónde estamos
{{La reunión, el comité o el corte que esta fase prepara, en la voz de la historia.}}

## 🎯 2. Objetivos de esta fase
## 🗂️ 3. La evidencia
{{Qué entradas de la bitácora sostienen cada argumento, y cuáles faltan. Lo de Oracle, como apuestas
que el lector resolvió en su máquina.}}

## ⚔️ 4. Las propuestas, con su mejor argumento
{{Verónica, Florencia y la del lector, cada una con lo que gana y lo que pierde, con número.}}

## {{emoji}} 5. {{El trabajo de la fase}}
{{F24: el documento de diseño, parte por parte, con las cinco preguntas. F25: el plan de migración,
la convivencia, la reconciliación y el corte. F26: la factura, el árbol de veredicto y el martes.}}

## ⚖️ 6. Veredicto honesto: cuándo NO
## ⚠️ 7. Errores comunes
{{De criterio y de proceso: la decisión que se defiende con una sola medición, el plan de corte sin
vuelta atrás.}}

## 📋 8. Checklist de validación
## 🧪 9. Ejercicios ({{total}})
{{Preguntas de comité, planes que revisar, reconciliaciones que no cierran. Casi todos abiertos:
su solución es de referencia, con rúbrica. Cada uno cierra con su enlace a `soluciones/`.}}

## 📚 10. Referencias
## 🏁 11. Resultado de la fase
{{En F26: el cierre del boss global 🏆 "Un martes" y del curso.}}

> **La señal de que quedó bien:** {{criterio en forma de cita.}}

> 🏷️ **Tag:** `fase-{{NN}}-{{slug}}` · prefijo de commit `f{{NN}}:`
````

---

# 🪟 Plantilla de fase del track — `ss01` a `ss05`

Igual que la fase de tema, con tres cambios: el encabezado, **todo resultado va sin resolver** y el
tag vive en su propio espacio.

````markdown
# 🪟 SQL Server {{NN}} — {{Tema}}: {{la promesa concreta}}

> **Curso:** Ruta SQL · Track SQL Server · {{ssNN}} de ss05 · **8 h** · opcional
> **Motor:** SQL Server `{{imagen}}@sha256:{{digest}}` {{· emulado en Apple Silicon}}
> **Entorno de ejecución:** SQL (T-SQL) + Python
> **Requisito del camino base:** Fase {{NN}}
> **El dolor de Alameda:** {{…}}
> **Fecha de verificación ejecutada:** {{DD/MM/AAAA}}
> **Objetivo:** {{…}}
````

Las secciones son las de la fase de tema, con estas diferencias:

- **§5 El mecanismo** es de SQL Server, y **§6 El contraste** es contra Postgres, que es el que sí
  publica números.
- **Toda medición de SQL Server es 🪞🔒**, con el comando para resolverla. La nota de licencia va la
  primera vez en cada fase.
- **Cierre:** `git tag -a ss-fase-{{NN}}-{{slug}}`, prefijo de commit `ss{{NN}}:`.

---

# 📎 Plantilla de apéndice

Laxa a propósito. Lo que comparten todos: encabezado, índice, secciones cortas con ejemplo mínimo,
tabla de decisión o de referencia, referencias y ejercicios.

````markdown
# 📎 Apéndice {{aNN}} — {{Nombre}}

> **Curso:** Ruta SQL · Consulta rápida · **{{X}} h**
> **Usado por:** {{fases}} · **Versiones cubiertas:** {{…}}
> **Fecha de verificación ejecutada:** {{DD/MM/AAAA}}

**Esto no se lee de corrido.** Se entra por el índice buscando algo concreto y se sale.
{{Una línea sobre qué problema resuelve.}}

**Qué queda fuera:** {{lo que no cubre y dónde está.}}

---

## Índice
- [{{Sección 1}}](#)
- [Cuándo usar qué](#)
- [Referencias](#)

---

## {{Sección}}
{{Secciones cortas que responden a UNA pregunta, ejemplo mínimo ejecutable, nombres del dominio.}}

## 🧭 Cuándo usar qué
| {{Situación}} | {{Opción}} | {{Por qué}} |
|---|---|---|

## ⚠️ Advertencias
## 📚 Referencias
## 🧪 Ejercicios ({{5–10}})
{{Cada uno cierra con `[Solución](soluciones/{{aNN-slug}}.md#ejercicio-N)`.}}

---

> 🏷️ **Este apéndice no lleva tag propio.** {{Variante excepcional, solo para a02, a05 y a10, que
> dejan archivos en el repositorio: el commit se etiqueta `apendice-{{aNN}}-{{slug}}`.}}
````

## Recordatorios al rellenar un apéndice

- **Sus horas no cuentan** dentro de las 252.
- **Ningún `README.md` se toca**, tampoco los de `src/`: se escriben en su tanda final y aparte.
- **Sus ejercicios también llevan solucionario**, `soluciones/{{aNN-slug}}.md`, en la misma sesión.
- **No repite lo que explica una fase: enlaza.**
- **`a01` y `a02` tienen prohibido explicar Docker.**
- **La regla de publicación vale también aquí**: se enseña a leer un plan de Oracle, no se publican
  sus lecturas.
- **Antes de escribir, confirma tres cosas:** qué versiones exactas se cubren, qué convenciones ya
  son conocidas a esa altura del curso y qué queda fuera.

---

# ✅ Plantilla de solucionario

Un archivo por documento con ejercicios —fase, apéndice o fase del track—, `soluciones/<mismo
nombre>.md`, escrito en la misma sesión que su documento (guía §10.3, D18). Rígida.

````markdown
# ✅ Soluciones — {{Fase NN | Apéndice aNN | SQL Server NN}}: {{Tema}}

> **Curso:** Ruta SQL · Solucionario de [{{la Fase NN}}](../{{NN-slug}}.md)
> **Ejercicios:** {{total}} · **Perfil:** {{S | M}} · **Motores:** {{Postgres `postgres@sha256:…`,
> MySQL…}}
> **Fecha de verificación ejecutada:** {{DD/MM/AAAA}}

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–{{a}})

### Ejercicio 1

**Enunciado (resumen):** {{una o dos líneas, suficientes para no volver a la fase.}}

**Solución.** {{el porqué, en prosa corta}}

```sql
-- postgres
{{el SQL completo, el que se ejecutó}}
```

```text
{{salida literal}}
```

> ⚠️ **Error típico:** {{opcional: dónde se suele equivocar la gente en este ejercicio.}}

[← Volver al ejercicio](../{{NN-slug}}.md#{{ancla-del-ejercicio}})

## 🟠 Difícil ({{b+1}}–{{c}})

### Ejercicio {{N}}

**Enunciado (resumen):** {{…}}

**Solución de referencia.** {{un diseño correcto, ejecutado, con su medición si la pide}}

**Rúbrica.** Una respuesta correcta tiene que:
- {{criterio verificable}}

Y queda invalidada si:
- {{error que la invalida}}

### Ejercicio {{N}} (Oracle, 🪞🔒)

**Solución.** {{el mecanismo según la documentación oficial, la consulta y qué mirar en el
resultado; sin números, que el lector obtiene en su máquina}}

## 🔥 Opcionales

### Ejercicio 🔥 1

{{Solución si tiene respuesta verificable; rúbrica si es exploratorio.}}
````

## Recordatorios al rellenar un solucionario

- **Los mismos ejercicios, con la misma numeración y en el mismo orden** que el documento; el
  verificador los compara.
- **Nada sin ejecutar**: cada solución corrió sobre el perfil del encabezado, en la fecha del
  encabezado. Ningún número de Oracle ni de SQL Server.
- **Los boss no van aquí**: su solución de referencia queda fuera del repositorio publicado.
- **Si cambia un ejercicio, cambia su solución en la misma edición.**

