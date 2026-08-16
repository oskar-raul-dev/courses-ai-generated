# 🧩 Plantillas de capítulo
## Ruta NoSQL Lite

Los tres esqueletos que se copian al abrir un chat nuevo: **fase A** (levantar y modelar),
**fase B** (romper, medir y decidir) y **apéndice**. Las dos primeras son rígidas y se
siguen literales; la de apéndice es deliberadamente laxa, porque un apéndice de
contenedores y uno de licencias no se parecen en nada.

Junto con [`alcance-del-proyecto.md`](alcance-del-proyecto.md), la
[guía de estilo](guia-de-estilo-y-convenciones.md) y las dos propuestas, forman el marco
para que veintiséis fases escritas en veintiséis chats se lean como un solo documento.

> **Nota de coherencia:** las horas y los conteos de ejercicios son los de
> [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) §9. Si alguna vez cambian,
> se cambian **allí primero** y aquí después.

---

# 📐 Plantilla de fase A — levantar y modelar

Copia el bloque, rellena los `{{placeholders}}` y borra las notas entre llaves antes de
entregar.

````markdown
# {{emoji}} Fase {{NN}} — {{Familia}}: {{la promesa concreta del documento}}

> **Curso:** Ruta NoSQL Lite · Fase {{NN}} de 25 · Bloque {{romano}} · **{{X}} h**
> **Familia:** {{familia}} · **Motor:** {{producto}} `{{imagen}}@sha256:{{digest}}`
> **Línea base:** PostgreSQL `postgres@sha256:{{digest}}`
> **Entorno de ejecución:** {{TypeScript | TypeScript + Python}}
> **Volumen:** 10 k para los ejemplos, 1 M para las mediciones
> **Depende de:** Fase {{NN-1}} · **Habilita:** Fase {{NN+1}}
> **Apéndices de apoyo:** {{a01, a02, a03, a05, a06}}
> **Fecha de verificación ejecutada:** {{DD/MM/AAAA}}
> **Objetivo:** {{una frase, verificable}}

---

## 🧭 1. Dónde estamos

{{Qué dejó la fase anterior, qué falta, y por qué esta familia entra justo aquí. Prosa,
tres o cuatro párrafos. Si el bloque acaba de empezar, se presenta el bloque.}}

---

## 🎯 2. Objetivos de esta fase

{{3 a 5 objetivos verificables. "Entender X" no es verificable; "modelar la ficha de
vehículo de forma que una lectura completa cueste un solo viaje, y demostrarlo con
explain" sí lo es.}}

---

## 🚫 3. Qué NO entra todavía

- {{tema diferido}} → Fase {{M}}.
{{Todo lo que se difiere lleva destino exacto. Sin destino, no se difiere: se corta.}}

---

## 🏗️ 4. Levantar el motor

{{La receta mínima: el perfil de compose, el healthcheck, la conexión, la comprobación de
que está vivo. Enlaza a a01 y a02; NO expliques contenedores. Si esta sección pasa de dos
pantallas, algo pertenece a un apéndice.}}

```bash
docker compose --profile {{familia}} up -d
# Podman: podman compose --profile {{familia}} up -d
```

---

## 📖 5. El diccionario de esta familia

{{Cómo se dice aquí lo que en relacional se decía de otra forma. Tabla corta de traducción
en las dos direcciones, y enlace a a08 para el diccionario completo.}}

> 🩻 **Esto sí funciona igual.** {{Lo que se transfiere del relacional sin cambios: un
> índice sigue siendo un índice, un plan sigue siendo un plan, escribir sin índice sigue
> siendo caro. Honra el conocimiento previo del lector y ahorra páginas.}}

---

## 🧩 6. Modelar el dominio a la manera de esta familia

{{El grueso de la fase. Regla del andamio en cada concepto: problema del dominio de flota
primero, mecanismo después, comando con salida real al final. Nombres de entidad fijos:
vehicle, part, partCatalog, assembly, workOrder, reading, failureReport, technician,
workshop, supplier.}}

{{Cada decisión de modelado lleva su porqué, aunque sea media línea entre paréntesis.}}

> 📐 **Medición — {{qué}}** · {{volumen}} · `{{imagen}}@sha256:…` · verificado el {{fecha}}
>
> {{tabla con la medida estructural: examinados / devueltos / viajes / particiones}}
>
> Reproducir: `{{comando exacto}}`

**El patrón a memorizar.** {{Una o dos frases con la lección transferible.}}

---

## 🪞 7. Tu instinto relacional dice… y esta vez se equivoca

{{El punto exacto donde el modelo mental del lector se rompe, con la medición que lo
prueba. Obligatorio: al menos uno por fase A. Se copia después a INSTINTOS.md.}}

---

## ⚰️ 8. La situación 3: elegiste bien la familia y la modelaste como relacional

{{El anti-patrón de esta familia. Estructura de autopsia: la decisión con su mejor
argumento, por qué era razonable, qué pasó después con número, cuánto costó salir, y cuál
de las cinco preguntas lo habría evitado. Tono de autopsia y no de juicio: en la mesa está
la decisión, nunca la persona.}}

**Antes y después, con números:** {{la misma operación en el modelo mal planteado y en el
correcto, medida con el arnés.}}

---

## ⚠️ 9. Errores comunes y diagnóstico

{{2 a 5 errores, en formato síntoma → mensaje literal → causa → comprobación que lo
confirma → salida. Todos los mensajes literales se copian a a09-catalogo-de-errores.md.}}

---

## 📋 10. Checklist de validación

```text
[ ] {{comprobación ejecutable}}
[ ] {{…}}
```

---

## 🧪 11. Ejercicios ({{total}})

{{Ver §9 de la guía. Agrupados por dificultad con encabezado de rango, conteo en el
título, al menos un tercio de diagnóstico o medición, cada uno con Objetivo o Pregunta,
todos anclados al dominio de flota.}}

## 🟢 Fácil — {{tema}} (1–{{a}})
## 🟡 Intermedio — {{tema}} ({{a+1}}–{{b}})
## 🟠 Difícil — {{tema}} ({{b+1}}–{{c}})
## 🔴 Muy difícil — {{tema}} ({{c+1}}–{{total}})
## 🔥 Opcionales

---

## 📚 12. Referencias

**Documentación oficial**
- {{URL completa}} — {{qué versión cubre}}

**Papers y especificaciones** {{si aplican}}

**Orden de lectura sugerido:** {{antes de ejecutar → durante → después}}

> ⚠️ {{Las URLs y los contenidos cambian; la documentación de estos productos suele cubrir
> solo la última versión. Adviértelo siempre que el enlace no sea de la versión del curso.}}

---

## 🏁 13. Resultado de la fase

{{Qué queda modelado y cargado, en diagrama o bloque text.}}

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

{{Material de autoría, no de lectura. Lo que apareció al escribir y no cabía adentro, con
destino explícito.}}
````

---

# 📊 Plantilla de fase B — romper, medir y decidir

Mismo bloque de metadatos. Cambian las secciones del cuerpo.

````markdown
## 🧭 1. Dónde estamos
## 🎯 2. Objetivos de esta fase

## 🪞 3. La apuesta

> 🪞 **Apuesta antes de ejecutar.** {{La predicción con su número esperado, escrita ANTES
> de medir. No se edita después. Si se pierde, se dice que se perdió y se cuenta entera:
> es el contenido de mayor confianza que produce este curso.}}

## 📐 4. La medición contra la línea base

{{El grueso de la fase. Tres o cuatro mediciones del mismo caso en el motor y en Postgres,
todas con los cinco datos obligatorios y su comando de reproducción. Medida estructural,
no latencia: viajes, examinados contra devueltos, particiones tocadas, fan-out,
amplificación.}}

{{Y el veredicto de la apuesta, ganada o perdida, con el número delante.}}

## 💥 5. El punto de rotura

{{A qué volumen exacto rompe, con qué mensaje de error literal, y qué hay que cambiar para
salir. El mensaje entra en a09-catalogo-de-errores.md aunque hoy no se use.}}

## 🚑 6. Salir de aquí

{{Qué se cambia cuando ya te pasó, en orden de coste creciente: índice → modelo → motor →
arquitectura. Es la sección que más se agradece en el trabajo real.}}

## ❓ 7. Las cinco preguntas, respondidas para esta familia

{{Frontera transaccional · estabilidad de las consultas · unidad de lectura · saltos de la
relación típica · exactitud contra parecido. Una respuesta corta y honesta por pregunta.}}

## ⚖️ 8. Veredicto honesto: cuándo NO usar esto

{{Las pérdidas con número. Un minicurso que solo trae ventajas está mal escrito. Aquí
también va, si corresponde, el "esto lo resuelve Postgres y así lo medimos".}}

## ⚠️ 9. Errores comunes y diagnóstico
## 📋 10. Checklist de validación
## 🧪 11. Ejercicios ({{total}})
## 📚 12. Referencias
## 🏁 13. Resultado de la fase

{{Si esta fase cierra un bloque, aquí va además el 💀 boss de bloque en su propio apartado,
y la nota del 🏆 boss global —siempre marcada como opcional—.}}
````

---

## Recordatorios al rellenar una fase

- **Las horas y el conteo de ejercicios salen de `propuesta-fases-y-alcance.md` §9.** No se
  improvisan.
- **Cuerpo de 4.000 a 5.000 palabras**, medido cortando por el encabezado de 🧪 Ejercicios.
  El aparato de ejercicios añade 1.300–2.800 encima, y eso está bien.
- **Ningún número sin ejecutar.** Lo no verificado se declara con esas palabras, donde el
  lector lo necesita.
- **Ninguna explicación de contenedores pasa de dos párrafos.** Lo demás enlaza a `a01`,
  `a02` o a `docker-container-legacy/`.
- **Postgres aparece siempre**, y en las fases B con su mejor configuración razonable
  (`a07`). Ganarle a una línea base mal puesta no demuestra nada.
- **Los nombres del dominio no se renombran.** Ante la duda, se revisa la fase anterior.
- **Los tres documentos vivos se alimentan al cerrar la fase**: mediciones a
  `bitacora-de-medicion.md`, errores literales a `a09-catalogo-de-errores.md`, el 🪞 a
  `INSTINTOS.md`.
- 🗑️ **No se cita nunca** `nuevas-ideas.md` ni `plan-accion-creacion-docs-base.md`.

---

# 📎 Plantilla de apéndice

Laxa a propósito. Lo único que comparten los diez: encabezado, índice, secciones cortas
con ejemplo mínimo, tabla de decisión, referencias y ejercicios.

````markdown
# 📎 Apéndice {{aNN}} — {{Nombre}}

> **Curso:** Ruta NoSQL Lite · Consulta rápida · **{{X}} h**
> **Usado por:** {{fases}} · **Versiones cubiertas:** {{…}}
> **Fecha de verificación ejecutada:** {{DD/MM/AAAA}}

**Esto no se lee de corrido.** Se entra por el índice buscando algo concreto y se sale.
{{Una línea sobre qué problema resuelve.}}

**Qué queda fuera:** {{lo que el apéndice explícitamente no cubre y dónde está — en los
de infraestructura, casi siempre `docker-container-legacy/`.}}

---

## Índice
- [{{Sección 1}}](#)
- [Cuándo usar qué](#)
- [Referencias](#)

---

## {{Sección}}

{{Formato libre. Lo que sí se mantiene: secciones cortas que responden a UNA pregunta,
ejemplo mínimo ejecutable —no ejemplo completo—, y los nombres del dominio de flota
siempre que haya datos.}}

---

## 🧭 Cuándo usar qué

| {{Situación}} | {{Opción}} | {{Por qué}} |
|---|---|---|

{{Tabla de decisión al final: es lo que más se consulta. Si el apéndice no compara
opciones, sustitúyela por una tabla de referencia rápida o por un checklist.}}

---

## ⚠️ Advertencias
## 📚 Referencias
## 🧪 Ejercicios (5–10)

{{Cortos y de consulta: buscar algo, cambiar un valor y observar, provocar un error típico
del tema y reconocerlo por su mensaje.}}

---

> 🏷️ **Este apéndice no lleva tag propio.** {{Variante normal: es consulta rápida y el
> código que explica lo escriben las fases; lo que salga de leerlo se commitea con el
> prefijo de la fase desde la que se llegó.}}
> {{Variante excepcional —solo si el apéndice deja archivos en el repositorio, como a02
> con el `compose.yaml` o a05 con el generador—: el commit se etiqueta
> `apendice-{{aNN}}-{{slug}}`.}}
````

---

## Recordatorios al rellenar un apéndice

- **Las horas del apéndice no cuentan** dentro de las 252 h del curso.
- **Un apéndice no repite lo que explica una fase: enlaza.** Si dos documentos explican lo
  mismo, uno de los dos está mal.
- **`a01` y `a02` tienen prohibido explicar Docker.** Comandos y nada más; el mecanismo
  está en `docker-container-legacy/`.
- **`a02` y `a05` dejan archivos en el repositorio** (`compose.yaml`, generador de datos) y
  por eso son los únicos con tag propio.
- **Antes de escribir, confirma tres cosas:** qué versiones exactas se cubren, qué
  convenciones del curso ya son conocidas a esa altura, y qué queda explícitamente fuera.
