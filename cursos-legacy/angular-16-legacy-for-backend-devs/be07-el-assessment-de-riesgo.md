# 📊 Fase be07 — El *assessment* de riesgo tecnológico

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be07 de be07 · **10 horas**
> Depende de: **be00 a be06 cerradas** — esta fase consume los números que todas produjeron · Habilita: nada. Es el cierre del track
> Apéndices de apoyo: [`bea-09`](bea-09-symfony-como-vara-de-medir.md) · [`bea-10`](bea-10-mapa-de-deuda-del-track-be.md) · [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) · Incidentes asociados: **be-12**
> Estilo de esta fase: **no se escribe código.** Se escribe un documento y se defiende

> 🔥 **Esta fase pertenece al track opcional de backend.** El track base se completa sin abrirla.

---

## 🎯 1. Propósito

Escribir y defender el documento que ningún tutorial de internet enseña a producir, porque todos terminan en el *happy path* del rewrite.

Siete fases produjeron números. Esta los convierte en una decisión que alguien puede firmar — y, sobre todo, en una decisión que se puede **discutir con datos** delante de gente que prefiere otra.

> 🧭 **La regla que gobierna la fase:** *la respuesta correcta depende de la fecha de decomisión, no de la calidad del código.* Un sistema con dos años de vida por delante y uno con diez no reciben la misma respuesta aunque el código sea idéntico.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `ASSESSMENT.md` existe, tiene el índice de §5.1 completo, y **cada cifra dice de qué fase sale**. Ninguna estimación sin fuente o, si la hay, está marcada como inventada.
- [ ] Las **cuatro opciones** están costeadas con el mismo formato: coste, plazo, qué se rompe mientras, qué riesgo elimina, qué riesgo deja.
- [ ] La **recomendación** está escrita, con su criterio, y **depende explícitamente de la fecha de decomisión**. Hay al menos dos escenarios de fecha con respuestas distintas.
- [ ] El **cierre honesto** está: dónde Lumen de verdad ganó, **con el número de las dos columnas**.
- [ ] La ficha de riesgo del runtime EOL (`R-01` de [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md)) está incorporada, con dueño y fecha de revisión.
- [ ] Defendiste el documento ante alguien —una persona, o tú mismo por escrito— que **prefiere el rewrite**, y las objeciones están respondidas dentro del documento, no aparte.
- [ ] Desmontaste el *assessment* adversarial del incidente **be-12**.

---

## 🚫 3. Qué NO entra

- **Ejecutar la decisión.** El track termina con el documento. Lo que venga después no cabe en diez horas y, sobre todo, no es lo que este track entrena.
- **Código.** Ni una línea. Si acabas programando, te saliste.
- **Inventar números.** Si una cifra no sale de una fase, se marca como estimación y se dice en qué se apoya. **Es literalmente lo que la fase enseña.**

---

## 🧠 4. Concepto mínimo

### Qué es un *assessment* y qué no es

No es una propuesta técnica ni un plan de migración. Es **un documento de decisión**: describe el estado, cuantifica el riesgo, presenta opciones costeadas, recomienda una, y deja claro **quién tiene que decidir y con qué información**.

Tres propiedades lo separan de lo que la mayoría de la gente escribe:

1. **Las opciones son de verdad.** Si tres de las cuatro son de paja, es una propuesta disfrazada y el lector lo nota en dos minutos.
2. **Los números tienen origen.** Cada cifra dice de dónde sale. Las que no salen de ningún sitio se marcan como lo que son.
3. **La recomendación es condicional.** *"Depende de X"* no es tibieza: es la forma honesta cuando X de verdad cambia la respuesta — y aquí X es la fecha de decomisión.

🪞 **Tu instinto dice "hay que reescribir esto"… y esta vez puede que se equivoque.** Después de siete fases mirando lo que está mal, la conclusión emocional es evidente. Y la respuesta correcta depende de un dato que **no está en el código**: cuántos años le quedan al sistema. Éste es el momento del track en que hay que separar *"tengo razón sobre el código"* de *"tengo razón sobre qué hacer"*.

### El estado, en una página

Lo que las siete fases establecieron, y es el resumen que abre el documento:

| Hecho | De dónde sale |
|---|---|
| El runtime está **EOL desde el 28/11/2022**; la imagen se congeló el 15/11/2022 | be01, `bea-08` |
| El framework es **Lumen 5.8.13** (28/08/2019), última de su línea. Su restricción `php ^7.1.3` **excluye PHP 8** | be01 |
| El primer Lumen con PHP 8 es **9.0.0** (15/02/2022): cuatro versiones mayores más arriba | be01 |
| **Lumen no tiene calendario de soporte** ni LTS ni avisos de deprecación | `bea-09` |
| El código tiene **cuatro procedencias** conviviendo, medidas archivo por archivo | be02 |
| **Tres rotaciones en ocho años**, permanencia media 18 meses, aprendizaje no transferible | be02 |
| La base subió **cuatro veces** y la aplicación ninguna | be04 |
| La invariante central **no la sostenía ninguna restricción**; 88 filas la violan | be05 |
| Hay una **reescritura a medias** con dos caminos vivos, medida en tres números | be06 |
| **No había una sola prueba** hasta be06 | be06 |

Y la cita que hay que poner textual, porque es la posición oficial del producto:

> *"In the years since releasing Lumen, PHP has made a variety of wonderful performance improvements. For this reason, along with the availability of Laravel Octane, we no longer recommend that you begin new projects with Lumen. Instead, we recommend always beginning new projects with Laravel."*
> — Documentación oficial de Lumen, sección *Installation*

Léela con cuidado, porque **no dice lo que a todo el mundo le gustaría que dijera**: no dice que Lumen esté muerto, ni que haya que migrar, ni da una ruta. Dice *"no empieces proyectos nuevos"*. Y eso, para un sistema que ya existe y factura, significa exactamente una cosa: **estás en un producto sin recomendación oficial y sin camino de salida declarado**. Ésa es la frase que va en el documento, no *"Lumen está abandonado"*.

---

## 💻 5. El documento

### 5.1 El índice, que es el entregable

```markdown
# ASSESSMENT — certcore-api · <fecha>

1. Resumen ejecutivo · una página, y se escribe al final
2. Estado actual · la tabla de §4, con fuente por fila
3. Riesgos · cada uno con probabilidad, alcance y compensación actual
   3.1 R-01 · Runtime sin parches ← la deuda insignia (bea-08)
   3.2 R-02 · Framework sin calendario de soporte
   3.3 R-03 · Deuda de plantilla · el conocimiento no se amortiza
   3.4 R-04 · Reescritura a medias · dos caminos vivos
   3.5 R-05 · Invariantes contenidas pero no validadas
4. Opciones
   4.1 Quedarse y formar
   4.2 Reescribir a algo aburrido y sostenido
   4.3 Estrangular por endpoint
   4.4 No hacer nada y documentar el riesgo
5. Recomendación · condicional a la fecha de decomisión
6. Qué NO recomendamos, y por qué
7. Qué hace falta para decidir · quién, con qué dato, para cuándo
8. Anexo · dónde Lumen de verdad ganó
```

**Detalles con intención**

- **El resumen ejecutivo se escribe al final y va primero.** Es lo único que va a leer quien decide. Una página, sin jerga, y con la recomendación en el primer párrafo.
- **La sección 6 —"qué NO recomendamos"— no es relleno.** Es donde se desactivan de antemano las propuestas que van a aparecer en la reunión: *"reescribirlo en Node"*, *"subir sólo el PHP"*, *"meterle microservicios"*. Anticiparlas con un párrafo cada una ahorra la reunión entera.
- **La sección 7 es la que convierte un informe en una decisión.** Nombre de quien decide, dato que le falta, fecha. Sin ella, el documento se archiva.

### 5.2 Las cuatro opciones, y de dónde sale cada número

Todas con el mismo formato, porque comparar es el ejercicio.

#### Opción 1 — Quedarse y formar

**Qué es.** Contratar o formar gente para mantener `certcore-api` tal como está, con las contenciones puestas.

| Dato que necesita | De qué fase sale |
|---|---|
| Tiempo hasta que alguien nuevo entrega sin supervisión | **be02** §5.5, calibrado con tu propia experiencia de be01 |
| Coste de una rotación, y cuántas hubo | **be02** §5.5 (tres en ocho años) |
| Qué porcentaje del aprendizaje es transferible | **be02** — cercano a cero, y **ése es el problema** |
| Cuánto tarda alguien en caer en los cuatro bugs de familiaridad falsa | **be01** §5.9, el experimento de los diez minutos |

**Lo que casi nadie pone, y es lo que la hunde o la salva:** esta opción **ya se intentó tres veces**. Las tres funcionaron durante dieciocho meses. No es una hipótesis: es un experimento con tres repeticiones y resultado conocido.

#### Opción 2 — Reescribir a algo aburrido y sostenido

**Qué es.** Rehacer el servicio en un stack con calendario de soporte y mercado laboral. [`bea-09`](bea-09-symfony-como-vara-de-medir.md) usa Symfony como vara porque es el contraste exacto: LTS cada dos años, siete años de cobertura por versión, deprecaciones avisadas.

| Dato que necesita | De qué fase sale |
|---|---|
| Tamaño real del sistema: endpoints, tablas, reglas | **be03** (siete tablas) y **be06** (los tres números) |
| Qué se salva al cruzar y qué se reescribe | **be06** §4, el diccionario de traducción |
| Coste medido de cruzar **un** controlador | **be06**, ejercicio 27 — y por qué multiplicarlo es optimista |
| Qué se rompe mientras | **be06** §4: el estado intermedio es el más caro |
| Qué riesgos elimina | R-01 y R-02 completos; R-03 en gran parte |

**El argumento fuerte de esta opción no es técnico**: es que **ataca la deuda de plantilla**. En un stack con mercado, lo que alguien aprende le sirve fuera, así que se queda más y el siguiente llega sabiendo.

#### Opción 3 — Estrangular por endpoint

**Qué es.** Un proxy delante, se migra la ruta más dolorosa a un servicio nuevo, se mide, se repite. El sistema viejo va adelgazando.

| Dato que necesita | De qué fase sale |
|---|---|
| Qué endpoints hay y cuáles usa el frontend | **be00** (`CONTRACT.md`) y **be06** §5.1 |
| Cuál duele más | **be04** (`SQL-CRUDO.txt`) y **be05** (la invariante) |
| Con qué se verifica cada paso | **be00**: `smoke.sh`, que ya es el juez |
| Coste por endpoint | **be06**, extrapolado del ejercicio 27 |

**Probablemente la respuesta correcta y la más aburrida.** Tiene una ventaja que las otras no: **se puede parar en cualquier momento** y lo hecho sigue sirviendo. En una empresa que no ha decidido la fecha de decomisión, esa propiedad vale más que cualquier ganancia técnica.

Y una condición previa que este track dejó lista sin proponérselo: **estrangular exige un contrato verificable**, y `smoke.sh` lo es desde be00.

#### Opción 4 — No hacer nada y documentar el riesgo

**Qué es.** Congelar el sistema, mantener las contenciones, documentar los riesgos con dueño y fecha de revisión, y dedicar el presupuesto a otra cosa.

| Dato que necesita | De qué fase sale |
|---|---|
| Los riesgos, con compensación actual | **`bea-08`**, la ficha `R-01` |
| Qué contenciones ya están puestas | **be05** (la restricción), **be06** (las pruebas) |
| Cuánto cuesta mantenerlo un año más | **be02** (rotación) + incidentes del cuaderno |

**A veces gana, y saber cuándo gana es seniority.** Gana si la fecha de decomisión está cerca, si el sistema no crece, si el riesgo está compensado y documentado, y **si hay alguien que lo acepta con nombre y fecha**. Sin esa firma no es la opción 4: es no decidir, que es otra cosa y siempre sale peor.

### 5.3 La tabla comparativa

Va en el documento, y es lo que más se mira después del resumen:

| | 1 · Formar | 2 · Reescribir | 3 · Estrangular | 4 · No hacer nada |
|---|---|---|---|---|
| Coste inicial | Bajo | **Alto** | Medio, repartido | ~Cero |
| Coste recurrente | **Alto y repetido** | Bajo tras terminar | Decreciente | Constante, y creciendo |
| Plazo hasta ver algo | Semanas | **Meses o años** | Semanas por endpoint | Inmediato |
| Se puede parar a medias | — | **No, sin perderlo todo** | **Sí** ⭐ | — |
| Elimina R-01 (runtime EOL) | ❌ | ✅ | Parcial, creciente | ❌ |
| Elimina R-03 (plantilla) | ❌ **al contrario** | ✅ | Parcial | ❌ |
| Riesgo de la propia opción | Que se vaya el formado | **Que no termine** — ya pasó una vez (be06) | Vivir con dos sistemas | Que nadie la firme |
| Gana si la decomisión es… | Indiferente | **> 5 años** | 2–5 años, o sin decidir | **< 2 años** |

> 🧭 **La última fila es el documento entero.** Si te llevas una sola cosa de este track, que sea que esa fila existe y que **el dato que la rellena no está en el código**: está en la estrategia de la empresa, y hay que ir a preguntarlo.

### 5.4 El cierre honesto obligatorio: dónde Lumen de verdad ganó

Sin esta sección el *assessment* no es creíble, y el track no habría entendido su propio criterio.

En 2016, para una empresa mediana latinoamericana con gente de PHP de la intranet vieja, **Lumen era la decisión sensata**: aprovechaba el equipo que ya existía, la sintaxis que ya conocían, y encima era moderno y rápido. Y el beneficio **se cobró de verdad durante años**.

Las dos columnas, y hay que poner número en las dos:

| Lo que Lumen ahorró (2016–2019) | Lo que costó (2019–2026) |
|---|---|
| No hubo que contratar un equipo nuevo: el de la intranet escribió la API | Tres ciclos de onboarding no amortizados (be02 §5.5) |
| Salió a producción en semanas, no en trimestres | Ocho años sin subir de versión, y ahora el salto son cuatro mayores |
| Sintaxis conocida: los primeros endpoints se escribieron sin formación | Familiaridad falsa: cuatro familias de bugs, medidas en be01 §5.9 |
| Un framework ligero para una API pequeña: sin sobrecoste de arranque | Sin calendario de soporte, sin deprecaciones avisadas, sin utillaje |
| **Cuantifícalo tú** con la fecha de salida a producción | **Cuantifícalo tú** con los números de be02, be04 y be06 |

> 🧭 **El pecado no fue elegirlo. Fue elegirlo para *un servicio*, acertar, y que nadie volviera a decidir nunca.** Si el documento presenta la elección original como una estupidez, quien lo lea —y que probablemente estuvo ahí en 2016— deja de escucharte en el primer párrafo. Y además sería falso: **los errores caros no se parecen a estupideces. Se parecen a esto.**

**El patrón a memorizar**

> Un *assessment* que sólo tiene la columna del coste no es un análisis: es una acusación. La columna del beneficio es la que te da autoridad para escribir la otra.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Escribir cuatro opciones y que tres sean de paja.**
*Síntoma:* la opción 4 ocupa dos líneas y termina en *"obviamente inaceptable"*.
*Causa:* ya habías decidido antes de escribir.
*Fix mínimo:* escribe **la mejor versión de cada opción**, incluida la que no te gusta. Si no puedes defender la 4 en un párrafo convincente, no la entiendes — y alguien en la reunión sí.

**Inventar números para rellenar la tabla.**
*Síntoma:* "reescribirlo son unos seis meses".
*Causa:* la tabla pedía una celda.
*Fix mínimo:* marca la celda como estimación, escribe en qué se apoya, y da un rango con el supuesto. **Un rango honesto se defiende; un número inventado se desmonta en una pregunta.**

**Confundir el coste de la migración con el del estado intermedio.**
*Síntoma:* la opción 2 sale barata porque cuentas sólo el desarrollo.
*Causa:* el estado intermedio no aparece en ninguna estimación estándar.
*Fix mínimo:* be06 ya lo midió. Súmalo: cada mes de migración es un mes de sistema a medias, que es el estado más caro.

**Recomendar sin condición.**
*Síntoma:* "recomendamos reescribir".
*Causa:* parecía más firme.
*Fix mínimo:* *"recomendamos X si la decomisión es posterior a AAAA; si es anterior, recomendamos Y"*. Es más firme, no menos: **estás diciendo exactamente qué dato cambia la respuesta**, y eso es lo que quien decide necesita.

### Pieza forense de esta fase

**El *assessment* que recomienda el rewrite sin datos** (incidente `be-12`).

Te llega un documento de tres páginas. Está bien escrito, tiene diagramas, y recomienda reescribir en un stack moderno en seis meses. Tu trabajo es desmontarlo — y no es fácil, porque **casi todo lo que afirma sobre el código es cierto**.

El método, que es el mismo que usarías con un ticket vago:

1. **Separa las afirmaciones verificables de las de valor.** *"El runtime está EOL"* se verifica. *"El código es inmantenible"* no significa nada hasta que alguien diga qué mide.
2. **Para cada cifra, pregunta de dónde sale.** Las que no tengan fuente son el hallazgo. **No hace falta discutirlas: basta con pedir su origen.**
3. **Busca la opción que falta.** Casi siempre falta la 3, estrangular — la aburrida —, y casi siempre falta la 4. Un documento con una sola opción real no es un *assessment*.
4. **Busca el coste del estado intermedio.** Si la estimación de seis meses no incluye los seis meses de dos sistemas vivos, está incompleta por un factor que no es pequeño.
5. **Busca la fecha de decomisión.** Si no aparece, el documento no puede recomendar nada, **por buena que sea su descripción del problema**.
6. **Y concede lo que tiene razón.** Ése es el paso que convierte una objeción en una conversación: *"el diagnóstico es correcto, y por eso mismo la recomendación necesita dos datos que no están"*.

> 🧠 **Un documento con un diagnóstico correcto y una recomendación sin sustento es más peligroso que uno malo entero**, porque el diagnóstico correcto le presta credibilidad a lo demás. El paso 1 —separar lo verificable de lo valorativo— existe exactamente para eso.

> 🧨 **Rompe a propósito y observa.** Coge tu propio `ASSESSMENT.md` y **quítale la fecha de decomisión**: borra la condición de la recomendación y déjala afirmativa. Léelo entero otra vez. ¿Sigue siendo defendible? Después haz lo contrario: cambia la fecha de decomisión de tres años a diez y mira **cuántas secciones tienes que reescribir**. Si son pocas, tus opciones no eran de verdad.

---

## 🧪 7. Ejercicios (27)

**🟢 Fácil (1–6)**

1. Recopila de las siete fases todos los números producidos y ponlos en una sola tabla, con la fase de origen. Si alguno no existe, márcalo como hueco.
2. Escribe la sección 2 (estado actual) con la tabla de §4, verificando cada fila contra su fase.
3. **Diagnóstico.** Busca la cita oficial de Lumen en su documentación y cópiala literal con la URL. Después escribe en dos líneas qué dice **y qué no dice**.
4. Escribe la ficha `R-01` completa con los siete campos de [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md).
5. Rellena la tabla comparativa de §5.3 con lo que ya sabes. Marca en rojo las celdas que no puedas justificar.
6. **Diagnóstico.** Para cada una de las cuatro opciones, escribe **de qué fase** sale su número principal. Si alguna no tiene fuente, es que falta contenido: dilo.

**🟡 Intermedio (7–16)**

7. Costea la opción 1 con el cálculo de be02 §5.5 y los supuestos escritos al lado.
8. **Diagnóstico.** Costea la opción 2 a partir del ejercicio 27 de be06 —el coste real de cruzar un controlador— y explica por qué multiplicar es optimista. Da un rango, no un número.
9. Diseña la opción 3 en detalle: en qué orden, con qué criterio, y qué se mide después de cada endpoint.
10. Costea la opción 4: cuánto cuesta un año más de sistema congelado, contando incidentes, rotación y riesgo.
11. **Diagnóstico.** Escribe la sección 6 —"qué NO recomendamos"— con tres propuestas que sabes que van a aparecer en la reunión, y un párrafo para cada una.
12. Escribe el resumen ejecutivo de una página. Dáselo a leer a alguien que no conozca el sistema y pídele que te diga cuál es la recomendación. Si no la encuentra en treinta segundos, reescríbelo.
13. **Diagnóstico.** Rellena las dos columnas del anexo "dónde Lumen de verdad ganó" **con números**, no con adjetivos.
14. Escribe la sección 7: quién decide, qué dato le falta, para cuándo. Con nombres de rol, no genéricos.
15. **Diagnóstico.** Toma los cinco riesgos del índice y ordénalos por *probabilidad × alcance*. Documenta el criterio de ordenación antes de ordenar.
16. Compara tu recomendación con la de [`bea-09`](bea-09-symfony-como-vara-de-medir.md) sobre reescribir a Symfony. ¿Coinciden? Si no, explica qué dato tuyo cambia el resultado.

**🟠 Difícil (17–22)**

17. **Diagnóstico.** Escribe el *assessment* completo, las ocho secciones. Es el entregable de la fase.
18. Escribe la **misma recomendación** para dos fechas de decomisión distintas —dos años y diez— y compara qué secciones cambian. Si cambian pocas, tus opciones no eran reales.
19. **Diagnóstico.** Desmonta el *assessment* adversarial del incidente `be-12` con los seis pasos de §6. Entrega la refutación por escrito, incluida la parte donde concedes lo que tiene razón.
20. Defiende tu documento ante alguien que prefiere el rewrite —una persona real, o tú mismo escribiendo las objeciones más duras que se te ocurran—. Incorpora las objeciones **dentro** del documento, no en un anexo.
21. **Diagnóstico.** Encuentra la cifra más débil de tu propio *assessment* y atácala hasta romperla. Después decide: ¿se puede medir mejor, o hay que marcarla como estimación? Documenta cuál de las dos.
22. Escribe el correo de dos párrafos con el que mandarías este documento a la dirección. Es el ejercicio más corto y el que más veces se hace mal.

**🔴 Muy difícil (23–27)**

23. **Diagnóstico.** Consigue —o construye con supuestos explícitos— la fecha de decomisión de CertCore. Después escribe la recomendación definitiva y **defiende el supuesto**, que es la parte difícil: ¿en qué te apoyas para decir cuántos años le quedan a un sistema?
24. Escribe el *assessment* que un consultor externo escribiría en tres días sin haber hecho este track, y compáralo con el tuyo. ¿En qué se parecen? **¿En qué acierta él y tú no?** Sé honesto: la ventaja de la mirada externa es real.
25. **Diagnóstico.** Aplica el método de este documento a un sistema que conozcas de verdad, fuera de CertCore. Escribe la versión de una página. **Éste es el ejercicio que justifica las ochenta horas del track.**
26. Escribe la sección que este *assessment* no tiene y probablemente debería: **qué pasa si no se decide nada durante dos años más**. Con números, y sin dramatismo — el no-decidir también tiene coste y casi nunca se calcula.
27. **Diagnóstico adversarial.** Un directivo lee tu documento y responde: *"todo esto está muy bien, pero el sistema funciona y no ha fallado nunca; ¿por qué gastaría un peso?"*. Escribe la respuesta de dos párrafos. **No puedes usar la palabra "deuda técnica"**, y tiene que ser honesta: parte de lo que dice es cierto.

**🔥 Opcionales**

- 🔥 Calcula el coste total de propiedad de las cuatro opciones a cinco años, con una hoja de cálculo y los supuestos a la vista. Después haz un análisis de sensibilidad: ¿qué supuesto, al moverse un 20%, cambia la recomendación?
- 🔥 Escribe la versión de este documento para un sistema **sano**, con calendario y mercado. Compárala con ésta y anota cuántas secciones desaparecen. Esa diferencia es, exactamente, lo que cuesta el pasivo tecnológico.

---

## 📚 8. Referencias

**Documentación oficial**
- https://lumen.laravel.com/docs/10.x — la cita oficial del apartado *Installation*, que es la posición del producto y hay que citar textual.
- https://www.php.net/supported-versions.php — el calendario de soporte de PHP; la fila de 7.4 es la premisa del documento.
- https://symfony.com/releases — el contraste: fechas de fin de correcciones y de seguridad por versión. Es lo que Lumen no tiene.
- https://packagist.org/packages/laravel/lumen-framework — el historial de versiones sin ninguna columna de soporte.

**Libros / artículos de referencia**
- *Technical Debt* (Philippe Kruchten, Robert Nord, Ipek Ozkaya, Addison-Wesley, 2019) — la distinción entre deuda que se paga y deuda que se documenta, y cómo se presenta a quien decide. Es el marco de la sección 3 del documento.
- *Escaping the Build Trap* (Melissa Perri, O'Reilly, 2018) — por qué la fecha de decomisión es una decisión de producto y no de ingeniería, y cómo se pregunta.
- *Accelerate* (Forsgren, Humble, Kim, IT Revolution, 2018) — para el argumento de la opción 3: entregas pequeñas y medibles frente a proyectos grandes y binarios.

**Video / apoyo**
- https://www.youtube.com/results?search_query=legacy+system+modernization+strangler+vs+rewrite — busca charlas de gente que eligió **no** reescribir y cuenta por qué. Son minoría y son las útiles.

**Orden de lectura sugerido:** [`bea-10`](bea-10-mapa-de-deuda-del-track-be.md) **antes de nada**, porque es el inventario consolidado de todo lo que este documento tiene que cubrir → tus propios entregables de las siete fases **mientras** rellenas la tabla de números → [`bea-09`](bea-09-symfony-como-vara-de-medir.md) **al costear la opción 2** → [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) **al costear la opción 4**, que es donde el riesgo aceptado necesita dueño → Kruchten **después**, si tienes que defenderlo ante alguien que no es técnico.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Y con la cita oficial de Lumen en particular: **cópiala con la fecha de consulta**, porque es el tipo de párrafo que un proyecto reescribe sin avisar y tu documento la va a citar como prueba.

---

## 🚀 9. Cierre del track

Aquí termina el track BE, y termina como empezó: con un documento y ninguna promesa.

Ochenta horas atrás, `certcore-api` era una caja negra detrás de `npm run mock`. Ahora es un sistema que levantaste tú, con su historia reconstruida, su código clasificado por procedencia, su invariante contenida, sus primeras pruebas y su riesgo escrito con nombre y fecha. Y tienes un documento que recomienda algo **y dice de qué depende**.

Lo que te llevas al trabajo real no es Lumen —nadie va a buscar trabajo de Lumen, y conviene decirlo—. Es el método: **cómo se diagnostica un sistema cuya tecnología se volvió un pasivo, cómo se le pone número, y cómo se defiende una decisión ante alguien que prefiere otra.** Eso sirve igual en Rails 4, en Spring 3, en .NET Framework, o en el Angular 8 del curso hermano.

Y la última frase del track es la misma con la que empezó:

> 🧠 **El backend no viene a redimir nada. El backend es la escena del crimen.** Lo que aprendiste no es cómo se hace bien: es **qué haces el lunes cuando lo que está mal es una decisión de arquitectura de hace ocho años, el sistema factura, y no hay presupuesto para deshacerla.**

> **La señal de que quedó bien:** *"defendí no reescribir delante de alguien que quería reescribir, con números, y salimos los dos con la misma pregunta pendiente: cuántos años le quedan a este sistema."*

> 🏷️ **No cierres el track sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-07-el-assessment-de-riesgo \
>   -m "be07 cerrada y track BE completo: ASSESSMENT.md con las ocho secciones;
> cuatro opciones costeadas con la fase de origen de cada cifra;
> recomendación condicional a la fecha de decomisión;
> anexo honesto con las dos columnas de Lumen"
> ```
>
> Los commits de esta fase llevan `be07: …`. Y una última comprobación, la misma de las siete fases anteriores y la que define el track entero:
>
> ```bash
> git diff fase-10-certificados-vigencia..HEAD -- src/
> ```
>
> **Tiene que devolver vacío.** Ochenta horas de backend, un reemplazo completo de servidor, una restricción nueva y un cambio de motor de datos — y el frontend no cambió ni una línea. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.

---

## 📌 Pendientes sugeridos

- **El *assessment* no se ejecuta**, y ésa es la frontera del track. Lo que venga después —migrar, estrangular, congelar— es otro curso y probablemente otro oficio. → **Declarado como límite del track** en el README.
- **La fecha de decomisión es un supuesto del alumno** (ejercicio 23) y no un dato de la ficción. Es deliberado: en la vida real tampoco te la dan, hay que ir a buscarla. Si alguna vez el track gana una fase de comunicación con negocio, ahí es donde vive. → **📌 de autoría**, para el chat de cierre.
- **El ejercicio 25 —aplicar el método a un sistema real— es el que justifica el track** y es el único que no se puede evaluar desde aquí. → Si el curso llega a tener tutoría, es el entregable que se revisa.
- **`bea-10` tiene que cuadrar con este documento**: cada 💸 de las ocho fases aparece en los dos, o hay un error. → **Comprobación de cierre**, antes de dar el track por cerrado.
- **El cuaderno `cuaderno-incidentes-be.md`** consume los doce IDs reservados (`be-01` … `be-12`) y se escribe después de las ocho fases. → **Siguiente y último documento del track.**

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| **be-12** | "Tenemos un assessment que recomienda reescribir en seis meses" | Adversarial · decisión sin datos | 🔴 |
