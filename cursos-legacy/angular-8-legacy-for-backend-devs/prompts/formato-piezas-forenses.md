# 🕵️ Formato de las piezas forenses
## Tutorial Angular 8 — Laboratorio clínico

Este documento **no es** una pieza forense: es su especificación. Define cómo se
construyen `forense-master.md` y los quince `forense-fase-NN.md`, que son los
entregables del track forense de este curso.

> 🧭 **El track forense va embebido en las fases y desarrollado aparte.** Cada
> fase lleva su sección 6 —«⚠️ Errores comunes y pieza forense»— con el gancho que
> el estudiante lee de corrido, y termina prometiendo el recorrido completo en su
> archivo. **Esa promesa es un contrato**: la pieza entrega exactamente lo que la
> fase anunció, ni más ni menos. Las quince fases dejaron ese gancho escrito antes
> de que existiera una sola pieza, así que el contenido de cada una estaba
> especificado antes de empezar a redactarla.

**Presupuesto:** las horas del track forense **ya están dentro de las 108h de las
fases**. Estos archivos no añaden calendario: son el desarrollo de una sección que
cada fase ya cuenta.

**Fuentes de verdad de esta especificación**, en el orden de la §12 de la guía de
estilo: `prompts/alcance-del-proyecto.md`, `prompts/guia-de-estilo-y-convenciones.md`
—con `00-convencion-de-git-y-tags.md` como anexo para todo lo que toque git—, y las
fases ya publicadas, que son las que fijan el código, los nombres y las salidas.

---

## 1. Qué es y qué no es una pieza forense

**Es** el recorrido completo de una investigación: el ticket tal como llegó, cada
paso con su salida literal, y la decisión que cada paso permite tomar. Se lee con
el navegador abierto, el mock corriendo y el proyecto en `ng serve`.

**No es** ninguna de estas cuatro cosas, y las cuatro son la forma habitual de
arruinar el archivo:

- **No es un resumen de la fase.** La fase ya se leyó. Si un párrafo se puede
  copiar de la sección 6, sobra: enlázala.
- **No es un tutorial de DevTools.** Se usan las herramientas, no se explican. El
  lector es un dev senior de backend: sabe qué es una petición HTTP, un `401` y
  una zona horaria. Lo que no sabe es qué le miente cada panel.
- **No construye código nuevo del proyecto.** El código lo escriben las fases.
  Una pieza puede pedir romper algo a propósito, y entonces dice cómo deshacerlo.
- **No inventa salidas.** Todo bloque de salida tiene que ser reproducible con el
  proyecto del curso y su `db.json` semilla. Si un valor depende de la máquina —un
  puerto, un hash de bundle, una fecha, un `request-id`— se marca con `…` o con un
  marcador evidente.

---

## 2. La regla que reemplaza a las capturas

> 🧭 **Texto, nunca imágenes.** Una captura no se versiona, no se busca con
> `Ctrl+F`, no se puede pegar en un ticket, y envejece con cada versión de Chrome.
> Todo lo que en una investigación real mirarías en pantalla, aquí se transcribe:
> el mensaje de consola literal, la fila de Network en texto, la secuencia de
> acciones de Redux DevTools, la salida del comando.

Cuando lo que hay que transmitir es **dónde** mirar y no **qué** dice, se describe
la ruta con las palabras exactas de la interfaz: *"Network → filtro `XHR` → la
petición a `/samples/17` → pestaña Headers → sección Request Headers"*. Esa frase
sobrevive a un rediseño mejor que una captura, y se puede dictar por teléfono.

🪦 **Corregido al cerrar el track.** Tres fases publicadas —la **9**, la **13** y
la **14**— prometían "capturas" en su gancho o en sus referencias. Era un lapsus
del gancho, no un contrato: lo que la pieza entrega es esa misma evidencia
transcrita. Siguiendo el corolario de content lock de §5 —*se corrige la promesa,
no se reescribe la fase*—, esas cinco menciones se reemplazaron por la salida
transcrita. No queda ninguna promesa de imagen en el curso.

---

## 3. Estructura de un `forense-fase-NN.md`

Siete bloques, en este orden. Los bloques 5 y 6 pueden faltar si la fase no da
para ellos; los otros cinco son obligatorios.

1. **Encabezado** — fase de la que sale, herramientas que usa, tiempo estimado del
   recorrido, y **el síntoma en una línea**.
2. **🎫 El ticket** — el reporte literal, con su vaguedad incluida, y quién lo
   reportó: auxiliar de toma, analista, médico, coordinador de turno. Si la fase
   promete varios tickets, van todos, cada uno con su ruta.
3. **🧭 La ruta** — los pasos numerados (§4). Es el cuerpo del archivo.
4. **🩺 Diagnóstico por síntoma** — la tabla de "esto veo, aquí miro". Es lo que se
   consulta seis meses después, cuando ya no recuerdas el recorrido. El marcador
   🩺 es el mismo de A12 y A13, y se usa con el mismo sentido.
5. **⚰️ Los callejones** — las hipótesis plausibles que no eran, con la evidencia
   que las tumba. Opcional pero muy recomendable: **saber qué descartar vale tanto
   como saber qué buscar**.
6. **🧨 Deshacer** — cómo devolver el proyecto a su estado, si el recorrido pidió
   romper algo. Obligatorio en cuanto haya un solo paso destructivo, y el marcador
   es el mismo 🧨 «Rompe a propósito» que ya usan las fases y los apéndices.
7. **🧠 El patrón transferible** — dos o tres frases con lo que se lleva al trabajo
   real, más los enlaces: incidentes del cuaderno que usan esta ruta y apéndices
   que amplían.

---

## 4. Cómo se escribe un paso de la ruta

Cada paso tiene tres partes y siempre en el mismo orden. Es lo que hace que el
archivo se pueda seguir con el teclado en la mano.

````markdown
### Paso N — {{la pregunta que contesta este paso}}

{{Qué haces. Una o dos frases, en imperativo, con la ruta exacta de la interfaz o
el comando completo.}}

```
{{La salida LITERAL. Consola, cuerpo de la respuesta, fila de Network, la
secuencia de acciones del log, stdout del mock.}}
```

**Qué descarta.** {{Qué hipótesis muere con esta salida, y a qué paso saltas según
lo que hayas visto. Un paso que no descarta nada no es un paso: es relleno.}}
````

Tres reglas sobre los pasos:

- **El orden es la lección.** Los pasos van del más barato al más caro, no del más
  probable al menos probable. Mirar una URL cuesta diez segundos; tomar un heap
  snapshot cuesta diez minutos. Ese orden **se dice explícitamente** al empezar la
  ruta, con el costo de cada tramo.
- **Un paso, una pregunta.** Si un paso contesta dos cosas, son dos pasos.
- **La ruta termina cuando se sabe dónde está el bug, no cuando está arreglado.**
  El fix es de la fase o del incidente; la pieza forense localiza.

---

## 5. Qué pone la fase y qué pone la pieza

La frontera es la misma regla anti-solapamiento de los apéndices, y aquí hay que
vigilarla más porque los dos textos hablan de lo mismo. En este curso el riesgo es
alto: varias secciones 6 son largas —la de i18n, la de Órdenes— y ya cuentan parte
del recorrido.

| Va en la sección 6 de la fase | Va en `forense-fase-NN.md` |
|---|---|
| El resumen de qué se rompe y por qué | El recorrido, paso a paso |
| La tabla corta de síntomas, si es lo central de la fase | La tabla completa, con las causas raras |
| El 🧨 «Rompe a propósito» del estudiante | Cómo se lee lo que ese 🧨 produce |
| El enunciado del problema | Las salidas literales y los callejones |

Si un párrafo cabe igual de bien en los dos sitios, va en la fase y la pieza lo
enlaza. La fase se lee siempre; la pieza, sólo cuando hace falta. **La pieza no
empieza repitiendo el gancho:** empieza en el 🎫 ticket.

Y el corolario de la regla de content lock: si al escribir una pieza se descubre
que su fase prometió algo que la fase no da, **se corrige la promesa, no se
reescribe la fase**.

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
4. **🧰 Las herramientas, y en qué miente cada una** — una línea por herramienta,
   con su mentira característica (§6.2).
5. **Cierre** — remite al **post-mortem de ocho puntos** de la §13 de la guía de
   estilo, que es el formato con el que se cierran los veintiún incidentes. El
   master **no lo duplica**: lo enlaza y dice cuándo se usa.

### 6.1 La cuarta pregunta del método

Las tres primeras preguntas son las de cualquier investigación. **La cuarta es la
propia de este curso**, y hay que fijarla acá porque es la que se presta a
copiarse mal. Una tentación frecuente es preguntar *"¿de qué generación es el
archivo que voy a tocar?"*, que funciona donde conviven varias épocas del
framework en el mismo repositorio; **acá no aplica**: LabCore es de una sola
época —2019 a 2021, Angular 8 de principio a fin— y esa pregunta no tendría nada
que separar. La que sí ordena el trabajo es la bifurcación que ya aparece en los
ganchos de las fases 7 y 11:

> 🧬 **¿Esto lo escribió el sistema, o llegó ya roto en el dato?** Si alguien
> transicionó ilegalmente *acá*, hay un intento en el log de acciones. Si no hay ni
> el intento, la muestra llegó rota del `db.json` o de una migración, y es otra
> investigación. Esa bifurcación se decide leyendo el log y ahorra medio día.

El emoji 🧬 queda reservado para eso: marcar la pregunta propia del track, la que
no se hereda de ningún manual de depuración general.

### 6.2 El elenco de herramientas

Cambia con el stack, y por eso se fija acá: **Redux DevTools sobre NgRx 8**
(pestañas Actions, Diff y time-travel, que son las tres que este curso usa),
**consola y Network** de Chrome o Firefox, **el log del mock** con su `chaos:`,
**source maps** de un bundle de producción, **panel Memory y panel
Performance**, **Karma y Jasmine**, y **`kubectl`** en la Fase 14 🔥. Angular
DevTools **no entra**: la extensión oficial no soporta Angular 8, y decirlo evita
media hora de instalación inútil.

Los dos apéndices de Apple Silicon —[**A12**](../a12-arm64-m1.md) (arm64) y [**A13**](../a13-docker-colima.md) (Colima)— son la
causa raíz de una familia entera de fallos de contenedor y se enlazan desde el
master, no se resumen.

### 6.3 Cómo cierra el master

El cierre natural de un track forense es un artefacto de una página —un
`HOTFIX.md` con el procedimiento destilado— que el curso escribiría en alguna
fase tardía. **Este curso no lo tiene** —su Fase 13 termina en la prueba de fuego
del contenedor— y **no se inventa uno**, porque crearlo obligaría a tocar una
fase publicada y eso choca con la regla de content lock. El equivalente ya existe
y ya está en uso: el **post-mortem de ocho puntos** de la §13 de la guía
de estilo, que es el molde de los veintiún incidentes y el cierre de la
retrospectiva del cuaderno. El master cierra ahí.

---

## 7. Git: commits, tags y el bloque 🏷️

Una pieza forense no produce código del proyecto, así que lo que salga de
recorrerla se commitea con el prefijo de su fase (`f07: …`). Cuando el recorrido
corresponde a un incidente del cuaderno, el par de tags `inc/<ID>/<slug>-roto` e
`inc/<ID>/<slug>-fix` es el mismo que ya reserva el cuaderno: **no se inventa
otro**, y el `<ID>` sale del índice de `cuaderno-incidentes.md`, que es la fuente
de verdad de qué incidente pertenece a qué fase. El detalle está en
[`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md) y no se
reexplica en ninguna pieza.

> 🪦 **Divergencia declarada — las piezas no llevan bloque 🏷️.** La §8.1 de la guía
> de estilo obliga a cerrar con él a fases y apéndices. Una pieza forense no es
> ninguna de las dos cosas: no abre progreso que etiquetar —el tag de la fase ya
> existe cuando se lee la pieza— y un tag que no apunta a un cambio no marca nada,
> que es el mismo argumento con el que la §8.1 se lo quita a los apéndices. Lo que
> sí lleva cada pieza es el enlace a la convención desde su 🧠 patrón transferible
> cuando el recorrido produce commits.

---

## 8. Checklist antes de dar por cerrada una pieza forense

- [ ] Entrega **exactamente** lo que el gancho de la sección 6 de su fase promete:
      los tickets que anuncia, y la salida de cada paso.
- [ ] Cero capturas. Todas las evidencias en texto (§2).
- [ ] Cada paso dice qué descarta y a dónde saltar (§4).
- [ ] Los pasos van del más barato al más caro, y eso se dice.
- [ ] Ninguna salida está inventada: todo se reproduce con el proyecto del curso y
      su `db.json` semilla, y lo variable va marcado.
- [ ] Si algún paso rompe algo, hay bloque 🧨 «Deshacer».
- [ ] No repite la sección 6 de su fase (§5), y no la contradice.
- [ ] Respeta la coherencia de la ficción (§11 de la guía): todo archivo, acción o
      selector que nombra está escrito en alguna fase y se puede abrir.
- [ ] Código en inglés, narrativa y comentarios en español con tuteo
      latinoamericano; el TS-0 heredado —`strict: false`, `any` tolerado— se
      respeta en cualquier fragmento que se muestre, porque así está el proyecto.
- [ ] Enlaza los incidentes del cuaderno que usan esta ruta, por el ID que ya les
      reserva el índice de `cuaderno-incidentes.md`.
- [ ] Cierra con el patrón transferible, que es lo único que el estudiante se lleva
      si no vuelve a abrir el archivo.
- [ ] **Tamaño: cuatro a seis pasos de ruta, cada uno con su salida literal y su
      "qué descarta".** En líneas eso cae entre 150 y 260 según cuánto se envuelva
      la prosa, y el número es un indicador, no el criterio: una pieza de 350 casi
      siempre está repitiendo su sección 6, y una de 90 no entregó lo que el gancho
      prometió. Lo que se cuenta son los pasos, no las líneas.
