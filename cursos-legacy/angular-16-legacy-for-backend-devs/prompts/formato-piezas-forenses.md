# 🕵️ Formato de las piezas forenses
## Tutorial Angular 16 — Inspecciones y certificaciones

Este documento **no es** una pieza forense: es su especificación. Define cómo se
construyen `forense-master.md` y los quince `forense-fase-NN.md`, que son los
entregables del track forense.

> 🧭 **El track forense va embebido en las fases y desarrollado aparte.** Cada
> fase lleva su sección 6 —«⚠️ Errores comunes y pieza forense»— con el resumen
> que el estudiante lee de corrido, y termina prometiendo el recorrido completo en
> su archivo. **Esa promesa es un contrato**: la pieza forense entrega exactamente
> lo que la fase anunció, ni más ni menos.

**Presupuesto:** las horas del track forense **ya están dentro de las 108h de las
fases**. Estos archivos no añaden calendario: son el desarrollo de una sección que
ya está contada.

---

## 1. Qué es y qué no es una pieza forense

**Es** el recorrido completo de una investigación: el ticket tal como llegó, cada
paso con su salida literal, y la decisión que cada paso permite tomar. Se lee con
el navegador abierto y el proyecto corriendo.

**No es** ninguna de estas cuatro cosas, y las cuatro son la forma habitual de
arruinar el archivo:

- **No es un resumen de la fase.** La fase ya se leyó. Si un párrafo se puede
  copiar de la sección 6, sobra: enlázala.
- **No es un tutorial de DevTools.** Se usan las herramientas, no se explican.
  El lector es un dev senior de backend: sabe qué es una petición HTTP.
- **No construye código nuevo del proyecto.** El código lo escriben las fases.
  Una pieza forense puede pedir romper algo a propósito, y entonces dice cómo
  deshacerlo.
- **No inventa salidas.** Todo bloque de salida tiene que ser reproducible con el
  proyecto del curso y su semilla. Si un valor depende de la máquina —un puerto,
  un hash, una fecha— se marca con `…` o con un marcador evidente.

---

## 2. La regla que reemplaza a las capturas

> 🧭 **Texto, nunca imágenes.** Una captura no se versiona, no se busca con
> `Ctrl+F`, no se puede copiar a un ticket, y envejece con cada versión de Chrome.
> Todo lo que en una investigación real mirarías en pantalla, aquí se transcribe:
> el mensaje de consola literal, la fila de Network en texto, la salida del
> comando.

Cuando lo que hay que transmitir es **dónde** mirar y no **qué** dice, se describe
la ruta con las palabras exactas de la interfaz: *"Network → filtro `Fetch/XHR` →
la petición a `/templates` → pestaña Headers → sección Request Headers"*. Esa
frase sobrevive a un rediseño mejor que una captura, y se puede dictar por
teléfono.

---

## 3. Estructura de un `forense-fase-NN.md`

Siete bloques, en este orden. Los bloques 5 y 6 pueden faltar si la fase no da
para ellos; los otros cinco son obligatorios.

1. **Encabezado** — fase de la que sale, herramientas que usa, tiempo estimado del
   recorrido, y **el síntoma en una línea**.
2. **🎫 El ticket** — el reporte literal, con su vaguedad incluida, y quién lo
   reportó. Si la fase promete varios tickets, van todos, cada uno con su ruta.
3. **🧭 La ruta** — los pasos numerados (§4). Es el cuerpo del archivo.
4. **🩺 Diagnóstico por síntoma** — la tabla de "esto veo, aquí miro". Es lo que
   se consulta seis meses después, cuando ya no recuerdas el recorrido.
5. **⚰️ Los callejones** — las hipótesis plausibles que no eran, con la evidencia
   que las tumba. Opcional pero muy recomendable: **saber qué descartar vale tanto
   como saber qué buscar**.
6. **🧨 Deshacer** — cómo devolver el proyecto a su estado, si el recorrido pidió
   romper algo. Obligatorio en cuanto haya un solo paso destructivo.
7. **🧠 El patrón transferible** — dos o tres frases con lo que se lleva al
   trabajo real, más los enlaces: incidentes del cuaderno que usan esta ruta, y
   apéndices que amplían.

---

## 4. Cómo se escribe un paso de la ruta

Cada paso tiene tres partes y siempre en el mismo orden. Es lo que hace que el
archivo se pueda seguir con el teclado en la mano.

```markdown
### Paso N — {{la pregunta que contesta este paso}}

{{Qué haces. Una o dos frases, en imperativo, con la ruta exacta de la interfaz o
el comando completo.}}

​```
{{La salida LITERAL. Consola, cuerpo de la respuesta, línea de Network, stdout.}}
​```

**Qué descarta.** {{Qué hipótesis muere con esta salida, y a qué paso saltas según
lo que hayas visto. Un paso que no descarta nada no es un paso: es relleno.}}
```

### Los dos cierres, y por qué hacen falta los dos

Un paso hace **una** de estas dos cosas, y siempre cierra con la marca que le
corresponde. Son las dos únicas terminaciones admitidas:

| Marca | Cuándo | Qué dice |
|---|---|---|
| **`**Qué descarta.**`** | El paso **elimina hipótesis** | Qué muere con esta salida y a qué paso saltas |
| **`**Aquí termina la ruta.**`** | El paso **localiza el bug** | Qué quedó demostrado, y que la pieza no va más allá |

La segunda existe porque un paso que acaba de encontrar la causa **no tiene nada
que descartar**, y forzarle un «Qué descarta» produce exactamente el relleno que
la regla de arriba prohíbe. Su variante para rutas con ramas excluyentes es
**`**Aquí termina esta rama.**`**, que además dice cuál de las otras no vas a
recorrer.

> 🧭 **La propiedad que protegen las dos juntas:** que la ruta se pueda recorrer
> **saltando de marca en marca**, sin leer el resto. Un paso sin ninguna de las
> dos rompe esa propiedad aunque su contenido sea impecable, porque obliga a
> leerlo entero para saber si ya terminaste.

Tres reglas sobre los pasos:

- **El orden es la lección.** Los pasos van del más barato al más caro, no del más
  probable al menos probable. Mirar una URL cuesta diez segundos; abrir el
  perfilador de memoria cuesta diez minutos. Ese orden **se dice explícitamente**
  al empezar la ruta.
- **Un paso, una pregunta.** Si un paso contesta dos cosas, son dos pasos.
- **La ruta termina cuando se sabe dónde está el bug, no cuando está arreglado.**
  El fix es de la fase o del incidente; la pieza forense localiza.
- **Y si un bloque no hace ninguna de las dos cosas**, no es un paso: es una
  técnica o una nota, y va fuera de la numeración, en un bloque 💡.

---

## 5. Qué pone la fase y qué pone la pieza

La frontera es la misma regla anti-solapamiento de los apéndices, y aquí hay que
vigilarla más porque los dos textos hablan de lo mismo.

| Va en la sección 6 de la fase | Va en `forense-fase-NN.md` |
|---|---|
| El resumen de qué se rompe y por qué | El recorrido, paso a paso |
| La tabla corta de síntomas, si es lo central de la fase | La tabla completa, con las causas raras |
| El 🧨 «Rompe a propósito» del estudiante | Cómo se lee lo que ese 🧨 produce |
| El enunciado del problema | Las salidas literales y los callejones |

Si un párrafo cabe igual de bien en los dos sitios, va en la fase y la pieza lo
enlaza. La fase se lee siempre; la pieza, sólo cuando hace falta.

---

## 6. `forense-master.md`

Es el índice y el método del track, y **no repite ninguna de las quince piezas**.
Cinco bloques:

1. **El método** — las cuatro preguntas que ordenan cualquier investigación de
   este curso, y por qué siempre en ese orden.
2. **📇 Índice de las quince piezas** — una fila por fase: síntoma, herramienta
   principal, archivo.
3. **🩺 Índice de síntomas transversal** — la tabla que cruza *"esto es lo que
   veo"* con *"esta es la pieza que lo cubre"*. Es la puerta de entrada real del
   track: nadie llega sabiendo de qué fase es su problema.
4. **🧰 Las herramientas, y en qué miente cada una** — consola, Network, Angular
   DevTools, panel Memory, panel Performance, `kubectl`. Una línea por
   herramienta, con su mentira característica.
5. **Cierre** — remite al `HOTFIX.md` que escribe la **Fase 13 §5.9**, que es el
   entregable de una página que el estudiante se lleva al trabajo real. El master
   **no lo duplica**: lo enlaza y dice cuándo se usa.

---

## 7. Convención de commits y tags

Una pieza forense no produce código del proyecto, así que lo que salga de
recorrerla se commitea con el prefijo de su fase (`fase 07: …`). Cuando el
recorrido corresponde a un incidente del cuaderno, el par de tags
`inc/<ID>/<slug>-roto` e `inc/<ID>/<slug>-fix` es el mismo que ya reserva el
cuaderno: **no se inventa otro**. El detalle está en
[`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md) y no se
reexplica en ninguna pieza.

---

## 8. Checklist antes de dar por cerrada una pieza forense

- [ ] Entrega **exactamente** lo que la línea 📄 de su fase promete: los tickets
      que anuncia, y la salida de cada paso.
- [ ] Cero capturas. Todas las evidencias en texto (§2).
- [ ] **Cada paso cierra con una de las dos marcas de §4** —`**Qué descarta.**`
      si elimina hipótesis, `**Aquí termina la ruta.**` (o `…esta rama.`) si
      localiza el bug—. Se comprueba con `prompts/verificar-forenses.py`, que
      falla si algún bloque de una sección 🧭 se queda sin marca.
- [ ] Los pasos van del más barato al más caro, y eso se dice.
- [ ] Ninguna salida está inventada: todo se reproduce con el proyecto del curso
      y su semilla, y lo variable va marcado.
- [ ] Si algún paso rompe algo, hay bloque 🧨 «Deshacer».
- [ ] No repite la sección 6 de su fase (§5).
- [ ] Código en inglés, comentarios y mensajes en español con tildes; `strict`
      respetado; el estilo —nuevo o heredado— del archivo que se toca.
- [ ] Enlaza los incidentes del cuaderno que usan esta ruta, por su ID reservado.
- [ ] Cierra con el patrón transferible, que es lo único que el estudiante se
      lleva si no vuelve a abrir el archivo.
