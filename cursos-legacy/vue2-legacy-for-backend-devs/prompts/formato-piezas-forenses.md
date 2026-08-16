# 🕵️ Formato de las piezas forenses
## Paquete Mini Jira — Curso 01 (Vue 2 legacy) + Curso 02 (MongoDB/Express)

Este documento **no es** una pieza forense: es su especificación. Define cómo se
construyen los `forense-master.md`, los `forense-fase-NN.md` y los
`forense-ruta-<código>.md` de los dos cursos, que son los entregables del track
forense.

Rige por igual a los dos cursos, como la
[guía de estilo](guia-de-estilo-y-convenciones.md), y se lee después de ella: todo lo
que la guía diga sobre tono, tuteo, idioma del código y forma del Markdown vale acá sin
repetirse.

> 🧭 **El track va embebido en las fases y desarrollado aparte.** Cada fase lleva su
> sección 6 —«⚠️ Errores comunes y pieza forense»— con el resumen que se lee de corrido,
> y termina prometiendo el recorrido completo en su archivo. **Esa promesa es un
> contrato:** la pieza entrega exactamente lo que la fase anunció, ni más ni menos.

> 📝 **Este paquete no cuenta horas.** Ni el README ni la guía presupuestan tiempo en
> ningún documento, y el track forense no introduce la costumbre. El tamaño se expresa en
> número de piezas, y el esfuerzo de cada recorrido, en el encabezado de la pieza.

---

## 1. Qué es y qué no es una pieza forense

**Es** el recorrido completo de una investigación: el ticket tal como llegó, cada paso con
su salida literal, y la decisión que ese paso permite tomar. Se lee con el navegador
abierto y el proyecto corriendo.

**No es** ninguna de estas cuatro cosas, y las cuatro son la forma habitual de arruinar el
archivo:

- **No es un resumen de la fase.** La fase ya se leyó. Si un párrafo se puede copiar de la
  sección 6, sobra: enlázala.
- **No es un tutorial de herramientas.** Se usan las herramientas, no se explican. El
  lector es un dev senior de backend: sabe qué es una petición HTTP, y en el Curso 02 sabe
  qué es un plan de consulta.
- **No construye código nuevo del proyecto.** El código lo escriben las fases. Una pieza
  puede pedir romper algo a propósito, y entonces dice cómo deshacerlo.
- **No inventa salidas.** Todo bloque de salida tiene que ser reproducible con el proyecto
  del curso y su semilla. Si un valor depende de la máquina —un puerto, un `ObjectId`, una
  fecha, un tiempo en milisegundos— se marca con `…` o con un marcador evidente.

---

## 2. La regla que reemplaza a las capturas

> 🧭 **Texto, nunca imágenes.** Una captura no se versiona, no se busca con `Ctrl+F`, no
> se puede pegar en un ticket, y envejece con cada versión de Chrome o de Compass. Todo lo
> que en una investigación real mirarías en pantalla, acá se transcribe: el warn literal
> de Vue, la fila de Network en texto, el `explain()` recortado a los campos que importan.

Cuando lo que hay que transmitir es **dónde** mirar y no **qué** dice, se describe la ruta
con las palabras exactas de la interfaz: *"Vue DevTools → pestaña Vuex → el módulo
`tickets` → `state.items` → el ticket 0347"*. Esa frase sobrevive a un rediseño mejor que
una captura, y se puede dictar por teléfono.

---

## 3. Estructura de un `forense-fase-NN.md`

Siete bloques, en este orden. Los bloques 5 y 6 pueden faltar si la fase no da para ellos;
los otros cinco son obligatorios.

1. **Encabezado** — de qué fase sale, qué herramientas usa, cuánto dura el recorrido, y
   **el síntoma en una línea**.
2. **🎫 El ticket** — el reporte literal, con su vaguedad incluida, y quién lo reportó. Si
   la fase promete varios tickets, van todos, cada uno con su ruta.
3. **🧭 La ruta** — los pasos numerados (§4). Es el cuerpo del archivo.
4. **🩺 Diagnóstico por síntoma** — la tabla de "esto veo, acá miro". Es lo que se consulta
   seis meses después, cuando ya no recuerdas el recorrido.
5. **⚰️ Los callejones** — las hipótesis plausibles que no eran, con la evidencia que las
   tumba. Opcional pero muy recomendable: **saber qué descartar vale tanto como saber qué
   buscar**.
6. **🧨 Deshacer** — cómo devolver el proyecto a su estado, si el recorrido pidió romper
   algo. Obligatorio en cuanto haya un solo paso destructivo.
7. **🧠 El patrón transferible** — dos o tres frases con lo que te llevas al trabajo real,
   más los enlaces: los incidentes del cuaderno que usan esta ruta y los apéndices que
   amplían.

---

## 4. Cómo se escribe un paso de la ruta

Cada paso tiene tres partes, siempre en el mismo orden. Es lo que hace que el archivo se
pueda seguir con el teclado en la mano.

````markdown
### Paso N — {{la pregunta que contesta este paso}}

{{Qué haces. Una o dos frases, en imperativo, con la ruta exacta de la interfaz o el
comando completo.}}

```
{{La salida LITERAL. Consola, cuerpo de la respuesta, fila de Network, stdout de mongosh.}}
```

**Qué descarta.** {{Qué hipótesis muere con esta salida, y a qué paso saltas según lo que
hayas visto. Un paso que no descarta nada no es un paso: es relleno.}}
````

Tres reglas sobre los pasos:

- **El orden es la lección.** Los pasos van del más barato al más caro, no del más probable
  al menos probable. Mirar una URL cuesta diez segundos; abrir el profiler de Mongo cuesta
  diez minutos. Ese orden **se dice explícitamente** al empezar la ruta.
- **Un paso, una pregunta.** Si un paso contesta dos cosas, son dos pasos.
- **La ruta termina cuando se sabe dónde está el bug, no cuando está arreglado.** El fix es
  de la fase o del incidente; la pieza forense localiza.

---

## 5. El método: las cuatro preguntas

Las mismas en los dos cursos, y siempre en este orden, porque cada una cuesta un orden de
magnitud más que la anterior.

**Pregunta 1 — ¿se reproduce, y con qué?** Antes de mirar una línea de código: ¿esto se
reproduce **con un flag** del inyector de caos del mock, **con un dato** distinto, o hace
falta **otro código**? Las tres respuestas llevan a investigaciones distintas, y averiguar
cuál es te ahorra la mitad del camino. Es la misma pregunta que ordena la preparación de
los incidentes del cuaderno.

**Pregunta 2 — ¿qué dice la evidencia observable, antes que el código?** La URL de una
petición, el cuerpo crudo de una respuesta, el estado de un módulo de Vuex, el
`docsExamined` de un `explain()`. Casi todas las rutas de este track se resuelven acá, y
ninguna requiere abrir un archivo. **El código es el paso 4, no el paso 1.**

**Pregunta 3 — ¿en qué capa está?** En el Curso 01: componente, store, servicio HTTP o
mock. En el Curso 02: ruta, controller, service o el propio Mongo. Localizar la capa es el
entregable de una investigación; el fix suele ser de tres líneas y viene después. La guía
§6 ya lo llama *"la distinción que salva al que depura"*, y en este track es la pregunta
que más veces cierra el caso.

**Pregunta 4 — ¿de qué lado de la frontera está?** La frontera es el contrato de
[`00-audit-contrato.md`](../02-complement-mongodb-backend/00-audit-contrato.md). Un mismo
síntoma tiene dos causas posibles según de qué lado caiga: el frontend que asumió algo que
el contrato no promete, o el backend que dejó de cumplir lo que sí. Contestar esto antes
de escribir evita el fix que arregla el síntoma en la capa equivocada.

> 🔑 **La frase para memorizar:** *"funciona en mi máquina", "a veces pasa" y "desde ayer"
> no son descripciones de un bug: son descripciones de una diferencia.* El trabajo es
> encontrar cuál.

---

## 6. Las herramientas, y en qué miente cada una

Ninguna herramienta miente por malicia: cada una contesta una pregunta muy concreta, y el
error es preguntarle otra. Esta lista vive completa en cada `forense-master.md`; acá está
el criterio para escribirla.

**Curso 01.** **Vue DevTools** miente por *timeline*: te muestra el estado del store
después de la mutation, no quién la lanzó ni con qué; para eso está el registro de
mutations, y hay que decir cuál de las dos vistas contesta cada pregunta. **La consola**
miente por omisión —un `catch` vacío se traga el fallo entero y deja la pantalla congelada
con la consola limpia— y también por build: los warns de reactividad de Vue 2 **solo salen
en desarrollo**, así que un bug que en `npm run serve` grita, en el build de producción es
mudo. **La pestaña Network** miente por status: un `201` significa que el mock contestó, no
que hizo lo que crees. **Y `git log -S`**, que no es una herramienta de depuración hasta
que lo es: encuentra el commit donde una línea apareció o desapareció.

**Curso 02.** **`explain()`** miente por plan cacheado: el plan que ves puede no ser el que
corrió la primera vez, y en 4.4 conviene decir cuándo hay que limpiarlo. **Compass** miente
por muestreo: lo que llama "el esquema" de una colección es una inferencia sobre una
muestra, no un contrato. **Los logs de Express** mienten por granularidad: un
`500` registrado no te dice si la promesa se rechazó antes o después del write. **Y el
profiler** no miente, pero contesta tarde: cuesta abrirlo, y muchas veces
`db.currentOp()` ya te había dado la respuesta.

---

## 7. Qué pone la fase y qué pone la pieza

La frontera hay que vigilarla, porque los dos textos hablan de lo mismo.

| Va en la sección 6 de la fase | Va en la pieza forense |
|---|---|
| El resumen de qué se rompe y por qué | El recorrido, paso a paso |
| La tabla corta de síntomas, si es lo central de la fase | La tabla completa, con las causas raras |
| El 🧨 «Rompe a propósito» que hace el estudiante | Cómo se lee lo que ese 🧨 produce |
| El enunciado del problema | Las salidas literales y los callejones |

Si un párrafo cabe igual de bien en los dos sitios, va en la fase y la pieza lo enlaza. La
fase se lee siempre; la pieza, solo cuando hace falta.

La fase cierra su sección 6 con una línea fija, que es el contrato entre las dos:

```markdown
> 📄 El recorrido completo, con las salidas literales, en `forense-fase-08.md`.
```

---

## 8. Cuántas piezas, y por qué

**Curso 01 — quince.** Doce de tronco, `forense-fase-00.md` a `forense-fase-11.md`, una por
fase. Y **tres de ruta**, no quince: `forense-ruta-q.md`, `forense-ruta-vu.md` y
`forense-ruta-nx.md`, de unas 120 líneas cada una, cubriendo las cinco fases de su ruta.

El motivo no es ahorrar trabajo. Las rutas son **excluyentes**: quien elige Quasar no va a
leer nunca las de Vuetify ni las de Nuxt. Escribir quince piezas de ruta garantiza que cada
lector descarte diez. Y el conflicto central de las tres es el mismo —*el framework quiere
el estado que tu store ya controla*, que es lo que estalla en Q3, VU3 y NX3—, así que
repartirlo en cinco archivos por ruta lo diluye en vez de concentrarlo. Cada pieza de ruta
**se lee sola**: no se apoya en sus hermanas, porque el lector solo va a abrir una.

**Curso 02 — doce como piso, hasta dieciséis.** Doce es el suelo, no el techo: si al
escribir una fase aparece un recorrido propio que se sostiene, se escribe su pieza. Lo que
**no** se hace es rellenar por simetría. Una pieza forense de una fase que no da para ella
se convierte en un resumen de la fase, que es exactamente lo que prohíbe §1.

Cuatro piezas ya existen dentro de sus fases y se **promueven** a archivo, no se
reescriben: las de `02-consultar-tu-sql-traducido.md`, `09-aggregation.md`,
`10-express-el-vehiculo.md` y `13-testing-de-api.md`.

> ⚠️ **Los dos cursos son independientes.** Hay estudiantes que harán solo el Curso 01 y no
> tocarán Mongo nunca. Ninguna pieza del Curso 01 puede depender de material del Curso 02:
> puede **nombrar** una deuda 💸 y decir que se paga en el otro curso —eso es información
> honesta y cierra el bucle—, pero el recorrido tiene que terminar y enseñar su lección
> sin que el lector cruce de curso. En el Curso 02, las piezas que tocan la costura se
> escriben para alguien que recibe el frontend ya construido.

---

## 9. `forense-master.md`

Es la puerta de entrada y el método del track, uno por curso, y **no repite ninguna
pieza**. Cinco bloques:

1. **El método** — las cuatro preguntas de §5, con el orden justificado por coste.
2. **📇 Índice de las piezas** — una fila por fase: síntoma, herramienta principal,
   archivo. En el Curso 01, las tres piezas de ruta van en su propia sub-tabla, marcadas
   como opcionales y excluyentes entre sí.
3. **🩺 Índice de síntomas transversal** — la tabla que cruza *"esto es lo que veo"* con
   *"acá empiezo"*. **Es la puerta de entrada real:** nadie llega sabiendo de qué fase es
   su problema, llega con *"la pantalla se quedó en blanco"*. Mínimo 25 filas, y se
   construye recorriendo las secciones «⚠️ Errores comunes» de todas las fases del curso y
   recogiendo lo que ya está escrito, no inventando síntomas nuevos.
4. **🧰 Las herramientas y en qué miente cada una** — §6, en una línea por herramienta.
5. **Cierre** — el criterio para saber si el track hizo su trabajo.

Si al escribir el master aparece un síntoma que ninguna fase produce, **no se inventa la
fase**: se saca del índice y se anota al final como pendiente.

---

## 10. Commits y tags

Una pieza forense no produce código del proyecto, así que lo que salga de recorrerla se
commitea con el prefijo de su fase (`f08: …`). Cuando el recorrido corresponde a un
incidente del cuaderno, se usa el par `inc/<fase>/<slug>-roto` / `-fix` que el cuaderno ya
reservó, y cuando sale de un ejercicio de "rompe a propósito", el par
`ej/f08/25-roto` / `-fix`. **No existe un namespace `forense/` y no se inventa uno.**

Todo eso está en [`convencion-de-git-y-tags.md`](convencion-de-git-y-tags.md) §🕵️, y no se
reexplica en ninguna pieza: se enlaza.

---

## 11. Checklist antes de dar por cerrada una pieza forense

- [ ] Entrega **exactamente** lo que la línea 📄 de su fase promete: los tickets que
      anuncia y la salida de cada paso.
- [ ] Cero capturas. Todas las evidencias en texto (§2).
- [ ] Cada paso dice qué descarta y a dónde saltar (§4).
- [ ] Los pasos van del más barato al más caro, y eso se dice al empezar.
- [ ] Ninguna salida está inventada: todo se reproduce con el proyecto del curso y su
      semilla, y lo variable va marcado.
- [ ] Si algún paso rompe algo, hay bloque 🧨 «Deshacer».
- [ ] No repite la sección 6 de su fase (§7).
- [ ] No depende del otro curso (§8), y si nombra una deuda 💸 dice dónde se paga.
- [ ] Nada contradice el contrato: forma de las respuestas, enums `status` y `priority`,
      nombres de evento de socket, mapeo `id` ↔ `_id`.
- [ ] Código en inglés y comentarios en español; Options API en el Curso 01, driver nativo
      antes de Mongoose en el Curso 02.
- [ ] Español latinoamericano con tuteo, cero voseo — pasada de `grep` de la guía §4.7
      hecha.
- [ ] Cada `.md` citado existe con ese nombre exacto (guía §13.2).
- [ ] Enlaza los incidentes del cuaderno que usan esta ruta, por su ID reservado.
- [ ] Cierra con el patrón transferible, que es lo único que el lector se lleva si no
      vuelve a abrir el archivo.
