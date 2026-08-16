# 📎 Apéndice bea-09 — Symfony como vara de medir

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **3 horas**
> Usado por: **be02**, **be06**, **be07** ⭐ · Versiones cubiertas: las LTS de Symfony (2.8, 3.4, 4.4, 5.4, 6.4, 7.4), verificadas el 11/09/2026
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

🧭 **Symfony es el grupo de control, no el paciente. Y aquí no se escribe una línea de Symfony.**

Ésa es la primera frase por una razón: este apéndice existe para **medir a Lumen contra algo**, no para enseñar otro framework. Si buscas un tutorial de Symfony, éste no lo es y no va a serlo en ningún párrafo.

**Esto no se lee de corrido.** Se entra buscando un argumento concreto —*"¿qué le faltaba a Lumen, exactamente?"*, *"¿cuánto cuesta de verdad una reescritura?"*— y se sale con él y con la cifra que lo respalda.

**Qué queda fuera:** enseñar Symfony, su sintaxis, su contenedor o su configuración; **Doctrine** más allá de nombrarlo como el monstruo que es; y cualquier recomendación de migrar a nada. La decisión es de [`be07`](be07-el-assessment-de-riesgo.md) y depende de la fecha de decomisión, no de este apéndice.

---

## Índice

- [Por qué Symfony perdió como candidato, y por qué eso lo vuelve útil](#por-qué-symfony-perdió-como-candidato-y-por-qué-eso-lo-vuelve-útil)
- [Papel 1 — Vara de medir: la disciplina que Lumen no tuvo](#papel-1--vara-de-medir-la-disciplina-que-lumen-no-tuvo)
- [Papel 2 — Origen: la huella del dev de Symfony](#papel-2--origen-la-huella-del-dev-de-symfony)
- [Papel 3 — Destino: la opción 2 del *assessment*](#papel-3--destino-la-opción-2-del-assessment)
- [Y dónde sí duele Symfony, para el registro](#y-dónde-sí-duele-symfony-para-el-registro)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-6)

---

## Por qué Symfony perdió como candidato, y por qué eso lo vuelve útil

Cuando se diseñó este track se consideraron cinco tecnologías para hacer de sistema enfermo. Symfony se descartó por una razón que suena a elogio y lo es:

> 🧭 **No tiene problemas suficientes.** Es enorme, está sano, y su disciplina de actualización es famosa y merecida. El veredicto honesto sobre un Symfony viejo sería *"súbelo, hay camino"* — y eso no sostiene ocho fases de nada.

Y justo por eso vale como **grupo de control**. Para poder decir con argumentos *"a Lumen le faltaba X"* hace falta un sistema comparable —mismo lenguaje, misma época, mismo tipo de empresa— donde **X sí existía**. Sin esa comparación, cualquier queja sobre Lumen es una opinión; con ella, es una diferencia medible.

---

## Papel 1 — Vara de medir: la disciplina que Lumen no tuvo

Aquí está el 80% del valor del apéndice. Tres mecanismos, y los tres tienen fecha.

### El calendario, que es la diferencia más grande

Symfony publica una versión menor cada **seis meses** (mayo y noviembre), una mayor cada **dos años**, y una **LTS cada dos años** que recibe **tres años de correcciones y cuatro de parches de seguridad** — siete años de cobertura por versión.

| LTS | Publicada | Fin de seguridad |
|---|---|---|
| 2.8 | Nov 2015 | Nov 2019 |
| 3.4 | Nov 2017 | Nov 2021 |
| 4.4 | Nov 2019 | Nov 2023 |
| 5.4 | Nov 2021 | Feb 2029 |
| 6.4 | Nov 2023 | Nov 2027 |
| 7.4 | Nov 2025 | Nov 2029 |

*(Verificado en `symfony.com/releases` el 11/09/2026.)*

Contrástalo con lo que sabes de CertCore: **Lumen 5.8.13 se publicó el 28/08/2019 y no tiene ninguna fila equivalente.** No hay fecha de fin de soporte porque nunca hubo una promesa de soporte. No hay LTS. No hay calendario.

> 🧠 **La diferencia no es la calidad del código: es que uno de los dos te dice cuándo vas a tener que moverte.** Un equipo que sabe que su versión pierde parches en noviembre de 2027 puede planificar. Un equipo sin esa fila planifica cuando se rompe algo — y eso, en CertCore, fue nunca.

### Los avisos de deprecación

Symfony marca lo que va a desaparecer **una versión mayor antes**, y lo emite en tiempo de ejecución: el código sigue funcionando y grita. Una versión menor no rompe nada; las roturas se acumulan para la mayor, y todo lo que va a romperse ya se avisó.

Eso convierte una migración mayor en **una lista de tareas**, no en una expedición. Y explica la frase honesta del track: *"súbelo, hay camino"*.

**Lumen 5.x no tenía nada de esto.** Ni avisos de deprecación consistentes, ni una guía de actualización por versión mayor, ni una herramienta que dijera qué te va a romper. Por eso la subida de 5.8 a 6.0 nunca se intentó: no era una lista de tareas, era una apuesta.

### El utillaje

Existe Rector —reescritura automática de código entre versiones—, existen los *upgrade guides* por versión, existe una herramienta que audita dependencias con vulnerabilidades conocidas. Nada de eso es magia, y nada de eso reemplaza el trabajo; lo que hace es **poner el trabajo en una barra de progreso**, que es exactamente lo que falta cuando le pides a alguien presupuesto para una migración.

> 🧭 **La frase que hay que poder defender en be07:** *"el problema no fue elegir Lumen. Fue elegir algo sin calendario de soporte para un servicio que iba a durar diez años, y no volver a mirarlo."* Esta sección es la evidencia de esa frase.

---

## Papel 2 — Origen: la huella del dev de Symfony

De aquí viene una de las cuatro parcelas de [`be02`](be02-estratos-por-procedencia.md). El dev que llega de Symfony trae reflejos concretos y reconocibles:

- **Inyección por constructor, siempre.** Nunca *service locator*. Las dependencias se declaran en la firma, no se buscan en el cuerpo.
- **Interfaces.** Depende de `TemplateRepositoryInterface`, no de la clase.
- **`declare(strict_types=1)`** en la primera línea, sin excepciones.
- **Objetos de respuesta explícitos** (`new JsonResponse(...)`), nunca un helper global.
- **Excepciones de dominio propias**, no `abort(404)`.
- **Namespaces profundos** que modelan el dominio (`App\Domain\Template\...`), no la infraestructura.

Nada de eso está mal — al contrario, es el código más fácil de probar del repositorio, y en [`be06`](be06-la-reescritura-a-medias.md) eso deja de ser una opinión. Lo que hay que entender es **por qué chirría**: llega a un proyecto donde el resto usa el estilo contrario, y sin una guía que decida, la parcela nueva se suma a las que ya había.

> 🧠 **Un buen reflejo aplicado sin una decisión de equipo produce un estrato más.** La calidad individual no compensa la ausencia de revisión — que es la tesis del track entero.

---

## Papel 3 — Destino: la opción 2 del *assessment*

En [`be07`](be07-el-assessment-de-riesgo.md), la opción 2 es *reescribir a algo aburrido y sostenido*. Symfony es el ejemplo canónico de "aburrido y sostenido", y este apéndice existe para que esa opción se pueda costear en vez de invocar.

Lo que se gana, y hay que decirlo completo:

- Un calendario de soporte con fechas, siete años por LTS.
- Un mercado laboral de verdad: se puede contratar gente que ya lo sabe, y lo que aprenda aquí le sirve fuera — lo cual **ataca directamente la deuda de plantilla de be02**, que es el argumento más fuerte de esta opción y el que casi nadie pone sobre la mesa.
- Deprecaciones avisadas y utillaje de actualización.

Lo que cuesta, y hay que decirlo igual de completo:

- **Reescribir, no migrar.** No hay camino de Lumen a Symfony: son contenedores distintos, arranque distinto, ORM distinto (Eloquent → Doctrine, que no es una traducción, es un cambio de modelo mental).
- **Mientras dura, dos sistemas.** El coste del estado intermedio es el tema de be06, y es el más caro de todos.
- **El equipo actual no sabe Symfony.** Formar o contratar, y las dos tienen factura.
- **Y la pregunta que decide:** ¿cuántos años le quedan a CertCore? Con dos, no se reescribe nada. Con diez, no reescribir es la decisión cara.

---

## Y dónde sí duele Symfony, para el registro

Si este apéndice pintara Symfony como el paraíso, sería propaganda y el track perdería su criterio. Duele, y en sitios concretos:

- **El salto de 2/3 a 4 con Flex** reestructuró el proyecto entero: la forma del directorio, la configuración y la gestión de *bundles* cambiaron a la vez. Fue lo más parecido a una reescritura que le ha pasado a un framework sano, y muchas empresas se quedaron en 3.4 hasta su EOL en noviembre de 2021 precisamente por eso.
- **Cuatro eras de configuración conviviendo:** XML, YAML, anotaciones y atributos. Un proyecto con ocho años tiene las cuatro, y cada persona escribe en la que aprendió — **exactamente el mismo fenómeno de be02, en un framework sano**. La disciplina de versiones no cura los estratos de estilo.
- **El contenedor compilado**, con su clásico *"funciona después de `cache:clear`"*. Es rapidísimo en producción y una fuente inagotable de desconcierto en desarrollo.
- **Doctrine, que duele más que Symfony mismo.** Es el monstruo real: migraciones que divergen de la base, *proxies* perezosos que explotan fuera de contexto, N+1 por todas partes, y un modelo de persistencia —*data mapper*, unidad de trabajo— que es conceptualmente correcto y muy incómodo para quien viene de Active Record. Comparado con Eloquent, Doctrine te obliga a tener razón antes de escribir.
- **El ecosistema de *bundles* de la era 2.x murió.** Paquetes de terceros que eran estándar de facto en 2015 no sobrevivieron a Flex, y sus reemplazos no eran equivalentes. **El framework tenía calendario; sus dependencias, no.** Ésa es la advertencia que hay que llevarse a be07: la disciplina del núcleo no se hereda al ecosistema.

> 🧠 **Un framework sano no es un framework sin dolor. Es uno donde el dolor tiene fecha, aviso y documentación.** Es toda la diferencia que este apéndice viene a medir.

---

## 🧭 Cuándo usar qué

| Necesitas… | Usa de aquí | Cuidado con |
|---|---|---|
| Argumentar qué le faltaba a Lumen | La tabla de LTS y las deprecaciones | No deslices "Lumen es malo": el pecado fue no revisar |
| Clasificar un archivo en be02 | La lista de reflejos del papel 2 | Un rasgo no clasifica; tres sí |
| Costear la opción 2 de be07 | Lo que se gana / lo que cuesta | El coste del estado intermedio es de be06, no lo dupliques |
| Defender que **no** hay que reescribir | La sección de dónde duele Symfony | Es honestidad, no munición: úsala completa |
| Explicar por qué hay cuatro estilos | Las cuatro eras de configuración | Pasa igual en frameworks sanos: no es culpa de Lumen |
| Decidir entre formar y contratar | El argumento de mercado del papel 3 | El número sale de be02 §5.5, no de aquí |

---

## ⚠️ Advertencias

**No conviertas este apéndice en una recomendación.** Dice que Symfony tiene disciplina de versiones y mercado; no dice que CertCore deba migrar. La respuesta correcta depende de la fecha de decomisión, y quien la decide es be07 con los números de las siete fases.

**Las fechas envejecen.** La tabla de LTS está verificada el 11/09/2026; consúltala en la fuente antes de citarla en un documento que alguien vaya a firmar. Y fíjate en el detalle que cambia argumentos: **5.4 tiene seguridad hasta febrero de 2029**, más allá de lo que marca la política estándar. Las excepciones existen y desmontan generalizaciones.

**El alumno no escribe Symfony en este track, y eso es deliberado.** Los seis ejercicios de abajo son de comparación argumentada, ninguno de código. Si acabas montando un proyecto de Symfony para "probar", te has salido del track: lo que se entrena aquí es defender una decisión, no aprender un framework.

---

## 📚 Referencias

- https://symfony.com/releases — la tabla de versiones con fechas de fin de correcciones y de seguridad. **Es la fuente de la tabla de arriba** y la que hay que citar.
- https://symfony.com/doc/current/contributing/community/releases.html — la política de publicación: menores cada seis meses, mayores cada dos años, LTS con tres años de correcciones y cuatro de seguridad.
- https://symfony.com/doc/current/setup/upgrade_major.html — cómo se sube una versión mayor, con los avisos de deprecación como mecanismo central. Léelo pensando en qué habría hecho falta para subir Lumen 5.8 a 6.0.
- https://getrector.com/ — Rector, la reescritura automática entre versiones. Existe también para Laravel; **no existió nunca para el salto que CertCore necesitaba**.
- https://www.doctrine-project.org/projects/orm.html — Doctrine, para entender por qué "reescribir a Symfony" incluye cambiar de modelo de persistencia y no sólo de framework.
- https://packagist.org/packages/laravel/lumen-framework — el contraste: el historial de versiones de Lumen, sin ninguna columna de soporte.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos, y **con las fechas de soporte hazlo siempre**: son el único dato de este apéndice que un lector podría llevarse a una reunión.

---

## 🧪 Ejercicios (6)

Ninguno es de código. Todos se entregan escritos, y todos se defienden.

1. Construye la tabla comparativa de soporte: Lumen 5.8.13 frente a la LTS de Symfony contemporánea (4.4). Columnas: fecha de publicación, fin de correcciones, fin de seguridad, guía de actualización, herramienta de migración. Las celdas vacías del lado de Lumen son el ejercicio.
2. **Comparación argumentada.** Escribe en una página qué habría pasado en CertCore si en 2016 se hubiera elegido Symfony 2.8. Incluye lo malo: el salto de Flex les habría caído encima en 2018. ¿Habría sido mejor, o sólo distinto? Da un criterio, no una preferencia.
3. Toma la parcela `symfony` de tu `ESTRATOS.md` (be02) y argumenta en tres párrafos si esos archivos son *mejores* que los de la parcela `laravel`. Obligatorio: al menos un párrafo tiene que defender los de Laravel, y tiene que ser convincente.
4. **Comparación argumentada.** Un equipo propone migrar a Symfony para "tener soporte". Escribe la objeción de dos párrafos que un arquitecto experimentado pondría, sabiendo lo del ecosistema de *bundles* de la era 2.x. Pista: la disciplina del núcleo no se hereda a las dependencias.
5. Estima la opción 2 del *assessment* con lo que sabes hasta ahora: reescribir `certcore-api` a Symfony. Escribe los supuestos primero y el número después, y marca **de qué fase del track sale cada dato**. Si algún dato no sale de ninguna, márcalo como estimación inventada — eso también es información.
6. **Comparación adversarial.** Alguien sostiene que el calendario de LTS es marketing y que *"en la práctica todo el mundo se queda en la versión que tiene igual"*. Desmóntalo con las fechas de la tabla, y después **concede la parte que es cierta**: muchas empresas se quedaron en 3.4 hasta su EOL. ¿Qué cambia entonces el calendario, si la gente igual no actualiza? Contesta eso y tendrás el argumento de be07.

---

> 🏷️ **Este apéndice no lleva tag propio.** No deja archivos versionados —no se escribe una línea de Symfony— y lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be02: …`, `be06: …`, `be07: …`). Las tablas comparativas de los ejercicios 1 y 5 conviene conservarlas: be07 las cita, y lo hace mejor si están fechadas en el mensaje de un tag anotado (`ej/bea-09/1`). La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
