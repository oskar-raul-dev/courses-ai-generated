# ⚖️ Fase 15 — El veredicto honesto: ¿debías haber usado Mongo?

## 🎯 Propósito

La conversación que ningún tutorial tiene, porque los tutoriales venden y
este curso entrena. Catorce fases te dieron el oficio; esta te da el
**criterio**: distinguir cuándo Mongo fue una decisión de ingeniería y cuándo
fue la moda de 2015 con el MEAN stack de uniforme — y, sobre todo, **qué
hacer con el legacy que te toque** cuando el diagnóstico dé "moda".

No es un capítulo de opiniones: es un capítulo de **herramientas de
diagnóstico** construidas con todo lo que mediste. Y cierra con los dos
entregables que materializan la promesa del curso: `INSTINTOS.md` completo
como checklist de auditoría, y `MODERNIZATION.md` — el plan honesto para un
sistema que quizá nunca debió existir así.

> 📝 **Sobre la forma de esta fase.** Es la única que no sigue la plantilla al
> pie: donde otras fases ponen "🧠 Conceptos mínimos" e "💻 Implementación",
> esta pone **el marco de diagnóstico** (las 5 preguntas, la tabla de olores,
> el árbol post-diagnóstico) como su cuerpo. No hay código nuevo que correr:
> hay criterio que construir. Es un capítulo-ensayo a propósito, y el
> Apéndice 5 profundiza el debate histórico que aquí solo se instrumenta.

---

## ✅ Qué queda listo al terminar

- el marco de decisión: las preguntas que responden "¿Mongo era la elección?"
  ANTES de escribir una línea — y su versión forense para sistemas ya
  escritos;
- la **tabla de olores** consolidada (fases 3, 5, 7, 8) como instrumento de
  auditoría de 5 minutos;
- el diagnóstico aplicado tres veces: a `soporte_v1` (el villano), al
  `minijira` que construiste, y a un repo ajeno real;
- el árbol de decisión post-diagnóstico: quedarse y reformar (la autopsia de
  la Fase 8 como precedente), estrangular por subdominios, migrar — con costos
  reales de cada rama;
- `MODERNIZATION.md`: el plan escrito para el peor de tus diagnósticos;
- `INSTINTOS.md` cerrado: cada 🪞 del curso con su veredicto medido — la
  promesa del curso, firmada por ti;
- el epílogo con fechas: qué cambió después de 2021 y qué reevaluarías hoy.

## 🚫 Qué NO entra (por diseño)

- una guerra de bandos: el curso no milita — te entrena para no militar
- benchmarks universales SQL vs Mongo (no existen: existen TUS patrones de
  acceso medidos — catorce fases insistiendo en eso)
- la migración ejecutada (el plan sí; moverlo es un proyecto, no una fase)

---

## 🧠 El marco en 60 segundos: la pregunta nunca fue "¿cuál es mejor?"

Fue siempre: **¿la forma de mis datos-en-uso se parece a documentos o a
relaciones?** Con lo aprendido, se descompone en cinco preguntas medibles —
una por paradigma:

| # | La pregunta (por paradigma) | Vota Mongo si… | Vota relacional si… |
|---|---|---|---|
| 1 | ¿Qué se lee junto? (F3) | las lecturas calientes caben en agregados naturales (el documento SE PARECE a la pantalla) | todo se cruza con todo; el acceso es transversal e impredecible (reporting-first) |
| 2 | ¿Quién custodia la forma? (F4) | esquema que evoluciona seguido, versiones conviviendo es ventaja real, validación por invariantes basta | integridad declarativa densa: FKs en cascada, constraints cruzadas, el motor como legislador |
| 3 | ¿Cuánto unes en caliente? (F5) | casi nada: el modelo pre-pagó las uniones | el negocio ES la unión: N entidades chicas combinándose sin patrón dominante |
| 4 | ¿Dónde viven tus invariantes? (F6) | dentro del agregado (documento): atomicidad gratis | entre entidades, todo el tiempo: transacciones multi-tabla como pan de cada día |
| 5 | ¿Qué te pide la operación? (F14) | scale-out, esquema ágil, y tu equipo asume la disciplina que el motor no impone | el equipo QUIERE que el motor imponga; DBA-cultura fuerte; herramienta SQL en toda la empresa |

Tres votos claros de una columna deciden. Empates dispersos gritan otra cosa:
**el dominio tiene subdominios con formas distintas** — y esa es la respuesta
adulta que 2015 no quería oír: la pregunta se responde por subdominio, no por
empresa.

> ### 🪞 Tu instinto dice… "al final, todo cabía en Postgres"
>
> **Predicción falsable (la última del curso):** "con JSONB, índices GIN y
> disciplina, Postgres hace todo lo que hicimos en catorce fases".
>
> Técnicamente… casi cierto. Y simétricamente: Mongo 4.4 con validators,
> transacciones y buen modelado hizo todo lo que este proyecto necesitó.
> **Cuando dos herramientas maduras pueden, la pregunta deja de ser "puede"
> y pasa a ser "¿cuál te deja caer hacia el lado correcto por defecto?"** —
> porque los equipos, bajo presión, hacen lo que la herramienta hace fácil.
> Mongo te empuja a modelar por acceso y te deja solo en la integridad;
> Postgres te empuja a normalizar y te deja remar contra el esquema cuando
> el dominio es documental. El costo real de cada elección no está en el
> benchmark: está en **qué error vas a cometer por gravedad** dentro de dos
> años. **Veredicto: el instinto confunde capacidad con pendiente.** 📓 La
> entrada final de `INSTINTOS.md`.

### 🩻 Esto SÍ funciona igual (el balance final)

La lista completa de lo que viajó intacto, cerrada tras catorce fases: índices y
selectividad, `EXPLAIN`, la paranoia N+1, el análisis de concurrencia, la
liturgia de operación, las invariantes de negocio, la disciplina de tipos, y
el hábito madre — **entender el acceso antes de decidir la estructura**. No
era un curso de olvidar: era un curso de recalibrar.

---

## 👃 La tabla de olores: el diagnóstico de 5 minutos

Todo lo que aprendiste a oler, consolidado. Frente a un Mongo ajeno, abre
Compass y busca:

| Olor | Dónde lo aprendiste | Qué delata |
|---|---|---|
| Lookup-tables para enums (`statuses`, `roles` con 4 docs) | F3 | traducción tabla-por-tabla; nadie preguntó qué se lee junto |
| `*_id` numéricos + colección `counters` | F1 | añoranza del AUTO_INCREMENT; contención autoinfligida |
| Ningún documento se parece a una pantalla | F3 | modelado "de los datos" en abstracto, no del acceso |
| `$lookup` en cadena en endpoints calientes | F5 | pagando JOIN sin el motor que lo hacía barato |
| Transacciones envolviendo updates de UN documento | F6 | miedo importado; costo sin garantía extra |
| Read-modify-write donde había `$inc`/`$push` | F6 | carreras dormidas esperando tráfico |
| 3+ formas de documento sin `schemaVersion` ni validator | F4 | evolución sin disciplina; el salvaje oeste realizado |
| Arrays sin techo creciendo con el negocio | F3 | la bomba de 16 MB con mecha encendida |
| Índices calcados de las "FKs" + ninguno compuesto por query real | F7 | se indexó el modelo imaginado, no el acceso medido |
| `count()` deprecado, `w:0`, `background: true` fosilizados | F2/F6/F14 | código congelado en 2018 sin auditoría posterior |
| El fixture: ObjectIds contaminados como strings | F0/F2 | pipelines de datos sin respeto por los tipos |

**El veredicto en una frase** (la promesa del curso): si la mayoría de la
tabla enciende, el sistema fue **traducido**; si el documento se parece a la
pantalla, las uniones calientes no existen y las invariantes viven en el
agregado, fue **diseñado**. Cinco minutos, Compass, y esta tabla.

> ⚰️ El caso de estudio que cose las fases 3 a 8 —`soporte_v1`, el villano—
> ya recibió esta tabla entera en su autopsia (Fase 8). Aquí la tabla deja de
> ser sobre *él* y pasa a ser tu instrumento para cualquier base ajena.

---

## 🌳 El árbol post-diagnóstico: ¿y ahora qué?

Diagnóstico: "fue moda". Cuatro ramas, con sus costos reales — y sí, una de
ellas es no hacer nada:

### Rama 0 — No tocar (la que nadie defiende por vergüenza)

La rama incómoda: el diagnóstico dice "está mal hecho", pero el **dolor
medido** —horas de guardia, incidentes, features frenadas— no amortiza ni la
reforma más barata. Estéticamente duele; en la hoja de cálculo, gana. Es una
elección legítima cuando el sistema es feo pero **estable y periférico**, y tu
tiempo rinde más en otra parte. El ejercicio 21 te hace defenderla en serio:
¿qué números tendrían que ser ciertos para que ganara? A veces lo son. Costo:
la deuda sigue viva y declarada (no oculta), y te obligas a **re-medir** cuando
el dolor crezca — porque "no tocar hoy" no es "no tocar nunca".

### Rama 1 — Quedarse y reformar (la autopsia como precedente)

Ya lo hiciste una vez: la Fase 8 tomó `soporte_v1` y lo re-modeló **dentro de
Mongo**, con mediciones antes/después. Es la rama correcta cuando el dominio
sí era documental y el crimen fue solo la traducción — el caso más común de
la época. Costo: migraciones (F4), doble lectura temporal, y la reforma
compite con las features en el backlog. Precedente medido: tus números de la
autopsia son el business case.

### Rama 2 — Estrangular por subdominios

El empate del marco hecho estrategia: el subdominio documental se queda
(tickets, adjuntos, actividad); el subdominio relacional que siempre sufrió
(facturación con sus invariantes cruzadas, el reporting transversal) migra a
un relacional **detrás de la misma API** — la Fase 10 te dio la frontera que
lo hace posible sin que el frontend se entere (otra vez el contrato como
seguro de vida). Costo: dos motores operados (¡doble Fase 14!), consistencia
entre ambos (tus outbox/reconciliaciones de F5–F6 se vuelven
infraestructura), y la tentación eterna de nunca terminar la estrangulación.

### Rama 3 — Migrar del todo

La rama cara y a veces correcta: cuando la tabla de olores enciende entera,
el equipo es SQL-nativo, y el dominio vota relacional 5-0. Costo real y
brutalmente subestimado en la época: reescribir la capa de datos completa,
el doble-run con sincronización durante la transición, re-entrenar la
operación, y el año de features congeladas. La pregunta de control antes de
elegirla: **¿el dolor actual, en horas/mes medidas, amortiza ese costo?**
Muchos legacies "de moda" duelen menos que su migración — y entonces la
respuesta madura es la rama 1 más un buen `SETUP.md`.

> 📝 **La regla que ordena el árbol:** el diagnóstico se hace con la tabla;
> la rama se elige con **números de dolor** (horas de guardia, incidentes,
> velocidad de features, la tabla de la autopsia) contra números de costo.
> "Está mal hecho" no es un business case; "nos cuesta 40 h/mes y la reforma
> cuesta 200" sí lo es.

---

## 📜 Los dos entregables finales

### `MODERNIZATION.md` — el plan para el peor diagnóstico

La estructura (el ejercicio 24 lo escribe completo para `soporte_v1`):

```markdown
1. Diagnóstico       — tabla de olores aplicada, con evidencia (capturas, conteos)
2. Dolor medido      — horas/mes, incidentes, p95 de los endpoints calientes
3. Rama elegida      — y por qué las otras dos NO (costos comparados)
4. Plan por etapas   — cada etapa entrega valor sola y es abortable
5. Riesgos           — y el rollback de cada etapa (F14 te enseñó a ensayarlos)
6. Métricas de éxito — los números que dirán "funcionó" (antes/después, como la Fase 8)
```

### `INSTINTOS.md` — la promesa, firmada

El cierre del documento que arrancó en la Fase 1: reordena tus entradas como
**checklist de auditoría** (cada 🪞 es ahora una pregunta que le haces a un
sistema ajeno) y agrégale el índice por fase. Releerlo completo es releer tu
propio cambio de paradigma — con mediciones, no con eslóganes. Ese documento
ES la prueba de la promesa:

> "Puedo mirar un esquema Mongo ajeno y decir en cinco minutos si fue
> diseñado o traducido. Y si es lo segundo, sé qué duele, por qué, y qué
> haría distinto."

---

## 🔭 Epílogo con fechas: el fantasma de 2021 mira adelante

El curso vivió a propósito en 2018–2021. Lo que pasó después, en una tabla —
porque heredar legacy también es saber qué mejoró desde que lo escribieron:

| Después de 4.4 | Qué cambia del curso |
|---|---|
| Mongo 5.0–7.x: time series nativas, `$lookup` mejorado, transacciones más baratas, Queryable Encryption | el bucket a mano (F3/F6) tiene alternativa nativa; la regla "lookup caliente = síntoma" **sigue viva** — mejoró el motor, no la física del modelo |
| mongosh reemplaza a `mongo`; drivers 4.x+ (`returnDocument`, promesas nativas) | tus notas legacy honestas son el mapa de traducción exacto |
| Postgres 14+: JSONB cada vez más serio | el 🪞 final de esta fase, más vigente cada año |
| Atlas se vuelve el default comercial | la Fase 14 sigue siendo el conocimiento que te deja evaluar qué te venden |

La lección meta: **las versiones cambian las respuestas; las cinco preguntas
del marco no cambian.** Por eso el curso enseñó preguntas.

---

## 🧩 Chuleta de la fase (y del curso)

```
Las 5 preguntas del marco (una por paradigma):
  1 ¿qué se lee junto?   2 ¿quién custodia la forma?   3 ¿cuánto unes en caliente?
  4 ¿dónde viven las invariantes?   5 ¿qué pide la operación?
  → 3 votos claros deciden · empates = subdominios = la respuesta es "ambos"

Diagnóstico forense: la tabla de olores (5 min + Compass)
Árbol post-diagnóstico: no tocar (si el dolor no amortiza) · reformar (autopsia) · estrangular (el contrato es el seguro) · migrar (con números)
Regla de oro: "está mal" no es business case; horas/mes sí

La pendiente > la capacidad: elige el motor por el error que cometerás por gravedad
```

---

## ⚠️ Errores comunes

- Militarizar el veredicto ("Mongo malo"/"SQL viejo"): acabas de pasar 14
  fases aprendiendo que la respuesta es un análisis, no una bandera.
- Diagnosticar el motor cuando el crimen fue el modelado (el 90% de los
  "Mongo nos falló" de la época era `soporte_v1` con otro logo).
- Elegir la rama 3 por asco estético sin la cuenta de dolor vs costo.
- El plan de modernización sin etapas abortables: o entrega valor por etapa
  o es una apuesta, no un plan.
- Olvidar el epílogo: auditar un Mongo 7 con reglas de 4.4 (o al revés) —
  fecha el sistema antes de juzgarlo.
- No escribir el veredicto: el análisis que no queda en `MODERNIZATION.md` /
  `DATA-MODEL.md` se re-discute cada seis meses desde cero.

---

## 🧪 Ejercicios (30)

**🟢 Fácil (1–8)**

1. Aplica las 5 preguntas del marco al Mini Jira como si no lo hubieras construido. ¿Cuántos votos por columna? ¿El veredicto coincide con lo que el curso decidió por ti?
2. Aplícalas a `soporte_v1`. Ojo: la trampa del ejercicio es que el DOMINIO es el mismo — ¿qué te dice que el mismo dominio dé veredictos distintos según el modelado? (Escríbelo: es la tesis del curso en una frase.)
3. Aplica la tabla de olores completa a `soporte_v1` con Compass y capturas: tu primer informe forense formal, 1 página.
4. Aplícala al `minijira` final. ¿Encendió algo? (Sé duro: ¿el `assigneeName` sin usar? ¿algún índice de la F7 que ningún query del profiler justificó?) La auditoría honesta incluye lo propio.
5. Cierra `INSTINTOS.md`: reordena todas las entradas como checklist de auditoría, numéralas por fase, y escribe el prólogo de 5 líneas para un colega SQL que lo lea sin haber hecho el curso.
6. Tres sistemas de tu pasado real: pásalos por las 5 preguntas (de memoria, con honestidad). ¿Cuál habría sido Mongo legítimo? ¿Alguno fue SQL por inercia?
7. El caso de época: un blog MEAN de tutorial (posts, comments, users, tags). Diagnostícalo con el marco. ¿Por qué era el ejemplo perfecto para vender Mongo… y qué le pasaba al crecer?
8. Fecha un sistema: te dan pistas (`count()` por doquier, `background: true`, callbacks del driver, sin transacciones). ¿Qué rango de versiones/años? Arma tu tabla de "fósiles datadores" con 6 pistas del curso.

**🟡 Intermedio (9–16)**

9. El diagnóstico ajeno: elige un repo Node+Mongo real de GitHub (2017–2021, con modelos y queries visibles). Informe forense completo: tabla de olores con evidencia, 5 preguntas, veredicto. (La promesa del curso: cronométrate — ¿cuánto más de 5 minutos te tomó?)
10. Repite con un repo que sospeches BIEN diseñado (busca proyectos con DATA-MODEL o ADRs). ¿Qué olores NO encendieron? Documentar la ausencia también entrena el olfato.
11. El dominio hostil de la F3 (turnos médicos, ej. 28) pasado por el marco formal: ¿5-0 relacional o hay subdominios? Diseña la partición si la hay.
12. Escribe el "abogado del diablo" doble: 1 página defendiendo Mongo para el Mini Jira ante un CTO SQL-fundamentalista, y 1 página defendiendo Postgres para el MISMO sistema ante un CTO MEAN-fundamentalista. Ambas con tus mediciones. (Si una te salió más fácil, ahí está tu sesgo: anótalo.)
13. La cuenta de la rama 3: estima la migración completa de `soporte_v1` a Postgres — entidades, queries a reescribir, doble-run, y conviértelo a semanas-persona con supuestos explícitos. Compárala contra el costo real de tu autopsia de la Fase 8 (que ya hiciste y mediste). El árbol, con números.
14. El estrangulamiento diseñado: para un Mini Jira que creció (facturación de SLAs con invariantes duras + reporting corporativo), diseña la rama 2: qué subdominio migra, qué API lo esconde, cómo se sincronizan (tus outbox de F6), y el orden de etapas abortables.
15. El olor que falta: propón y justifica UN olor nuevo para la tabla, salido de tu experiencia del curso (algo que oliste en los ejercicios y la tabla no nombra). Redáctalo en el formato de la tabla con su "dónde lo aprendiste".
16. Audita el epílogo: verifica en las release notes oficiales 3 afirmaciones de la tabla "después de 4.4" (¿cuándo llegaron exactamente las time series? ¿qué mejoró de `$lookup` y en qué versión?). Fechar afirmaciones es el hábito; hazlo con las del propio curso.

**🟠 Difícil (17–24)**

17. **El informe ejecutivo:** convierte tu forense de `soporte_v1` (ej. 3) + los números de la autopsia de la Fase 8 en 2 páginas para un director no técnico: dolor en horas y riesgo, opciones con costo, recomendación. Sin jerga: "lookup" no aparece; "cada pantalla hace 6 viajes a la base" sí.
18. La entrevista inversa: escribe las 10 preguntas que le harías al equipo que mantiene un Mongo legacy ANTES de mirar el código (sobre pantallas calientes, incidentes, quién escribe qué, la guardia). El diagnóstico social que la tabla técnica no ve.
19. Cronometra la promesa formalmente: consigue 3 esquemas Mongo que no hayas visto (repos, un colega, generados). 5 minutos por reloj cada uno: veredicto + 3 evidencias. Revisa después con calma: ¿aciertos? Calibra tu tabla con lo que se te escapó.
20. El anti-curso: escribe el índice comentado (solo títulos + 2 líneas por fase) del curso espejo — "SQL para cerebros Mongo": ¿qué instintos NoSQL traicionan en Postgres? (Normalizar le costará al que embebía; el esquema-ceremonia al que versionaba…) Entender la ida y la vuelta es dominar ambos paradigmas.
21. Defiende la rama impopular: para `soporte_v1`, escribe el caso de "no tocar nada" (rama 0: el dolor medido NO amortiza ni la reforma) con la misma seriedad que las otras. ¿Qué números tendrían que ser ciertos para que ganara? A veces gana — y nadie la defiende por vergüenza.
22. La deuda del curso: revisa `SECURITY-NOTES.md`, `DATA-MODEL.md` y el `AUDIT-CONTRATO.md` buscando lo que quedó SIN pagar (sockets anónimos en modo compatible, URLs hardcodeadas si no hiciste el proxy, decisiones "revisar si el contrato cambia"). Lista final de deudas vivas con dueño y disparador — el sistema se entrega con sus deudas declaradas, como se recibió.
23. **`MODERNIZATION.md` completo para `soporte_v1`** (el entregable mayor): las 6 secciones de la plantilla, la rama elegida con la cuenta del ej. 13, etapas abortables, rollbacks ensayables (F14), métricas de éxito. Es el documento que convierte catorce fases en un artefacto profesional que mostrarías en una entrevista.
24. El comité: presenta (en voz alta, a alguien, o grabándote 10 min) tu `MODERNIZATION.md` y defiéndelo contra las 3 objeciones más duras que se te ocurran (presupuesto, riesgo, "mejor migrar todo"). Las respuestas que balbucees son las secciones a reescribir.

**🔴 Muy difícil (25–30)**

25. El caso Sarah Mei: lee "Why You Should Never Use MongoDB" (2013, el ensayo crítico más famoso de la era) y escríbele la respuesta que el curso te permite: dónde tiene razón (y qué fase lo demuestra), dónde su caso era un problema de modelado (¿qué olor era Diaspora?), y qué cambió desde 2013 que afecta (y qué no afecta) sus argumentos.
26. Lee el análisis Jepsen de MongoDB 4.2.6 (Kyle Kingsbury, 2020) — o su resumen honesto — y tradúcelo al curso: ¿qué significa para las promesas de la F6 (write concern, transacciones)? ¿Cambia tu confianza en algo que construiste? ¿Qué configuración del curso queda reforzada por sus hallazgos? (Leer críticas duras de la herramienta que dominas es el último nivel de no-militancia.)
27. Kleppmann como examen final: lee el cap. 2 de *Designing Data-Intensive Applications* (modelos de datos) y mapea cada concepto a la fase del curso que lo encarnó. ¿Qué dice DDIA que el curso no cubrió? Esa lista es tu syllabus de posgrado personal.
28. El dataset traidor: diseña (en papel, con esquemas y 3 queries clave) el sistema donde AMBOS veredictos son defendibles al 50% — el peor caso del marco. Documenta qué información adicional (métricas de acceso reales, roadmap del producto) rompería el empate, y hacia dónde caerías con información incompleta y por qué (la pendiente del 🪞 final como desempate).
29. La charla: prepara los slides (10–12, pueden ser markdown) de "Mongo para cerebros SQL: lo que desaprendí midiendo" — tu versión del curso en 20 minutos, con TUS números como evidencia (el duelo de la F6, la autopsia, las tres uniones de la F5). Materializar el aprendizaje para otros es la prueba final de tenerlo.
30. **El ensayo de cierre** (2 páginas, el final de `INSTINTOS.md`): "Desaprender con criterio". Tesis libre, pero debe responder: ¿cuáles de tus instintos SQL resultaron ser sobre SQL, y cuáles eran sobre ingeniería de datos y solo vestían sintaxis SQL? Usa tu propio `INSTINTOS.md` como corpus — cita tus entradas, incluye la que más te costó ceder y la que el curso te confirmó. Fírmalo con fecha: es el documento que releerás cuando te toque el próximo paradigma.

---

## 📚 Referencias

**Los ensayos del debate (léelos en este orden)**

- Sarah Mei — *Why You Should Never Use MongoDB* (2013, el clásico crítico): http://www.sarahmei.com/blog/2013/11/11/why-you-should-never-use-mongodb/
- William Zola — *6 Rules of Thumb* (la respuesta implícita: era el modelado): https://www.mongodb.com/blog/post/6-rules-of-thumb-for-mongodb-schema-design
- Jepsen — MongoDB 4.2.6 (2020, el análisis duro de consistencia): https://jepsen.io/analyses/mongodb-4.2.6
- Martin Fowler — *NosqlDistilled* / bliki NoSQL (el marco sereno de la época): https://martinfowler.com/books/nosql.html

> ⚠️ Títulos y URLs de esta sección pueden haberse movido o renombrado desde la
> época: verifícalos antes de citarlos. El año y el autor son la pista estable.

**Libros**

- Martin Kleppmann — *Designing Data-Intensive Applications* (2017), cap. 2
  y 7: el contexto teórico de TODO el curso, escrito justo en la época.
- Sadalage & Fowler — *NoSQL Distilled* (2012): corto, honesto, pre-hype
  tardío; el cap. de "polyglot persistence" es la rama 2 con pedigrí.
- *MongoDB: The Definitive Guide*, 3.ª ed. — despedida al compañero de curso.

**Documentación (para fechar el epílogo)**

- Release notes 5.0 / 6.0 / 7.0: https://www.mongodb.com/docs/manual/release-notes/
  ⚠️ **Apuntan a versiones posteriores a la fijada (4.4):** son el epílogo, no
  el stack del curso. Léelas como "qué vino después", no como algo que debas
  usar en el código de las fases.
- Postgres — JSONB: https://www.postgresql.org/docs/current/datatype-json.html

**Video (YouTube)**

- Martin Kleppmann — talks sobre modelos de datos y consistencia (cualquiera
  de 2017–2019: son el cap. 2/7 de DDIA en persona)
- GOTO/InfoQ — busca "polyglot persistence" (Fowler y derivados): la rama 2
  del árbol, defendida en escenario

**Orden de lectura sugerido para perfil senior:**
las 5 preguntas + la tabla de olores (arriba — memorízalas: SON el curso) →
ejercicios 1–4 (el marco sobre lo que construiste) → Sarah Mei + tu respuesta
(ej. 25) → Jepsen (ej. 26) → Kleppmann cap. 2 → los entregables finales
(23–24, 30).

---

## 🚀 Cierre del curso

Empezaste con un mock que mentía y una década de instintos calibrados para
otro motor. Terminas con: un backend real que el frontend nunca notó
(`git diff`: una línea), cinco paradigmas invertidos con mediciones y no con
fe, un villano diagnosticado, operado y documentado, un runbook que sobrevive
a las 4 am, una suite que custodia el contrato, y dos documentos —
`INSTINTOS.md` y `MODERNIZATION.md` — que son tu criterio hecho artefacto.

La promesa, a tu firma:

> "Puedo mirar un esquema Mongo ajeno y decir en cinco minutos si fue
> **diseñado** o **traducido de un modelo relacional por alguien que no quiso
> pensarlo**. Y si es lo segundo, sé qué duele, por qué, y qué haría
> distinto."

Y la lección que te llevas al próximo paradigma, el que sea: los instintos no
se abandonan ni se obedecen — **se auditan**. Con predicciones falsables, con
cronómetro, y por escrito.

La señal de que quedó bien:

> "Me ponen delante un Mongo ajeno que nunca vi, abro Compass, y en cinco
> minutos digo si fue diseñado o traducido — y si hay que hacer algo, sé qué
> rama del árbol proponer y con qué números la defiendo."

🍃 Fin del curso. Los apéndices quedan de guardia para cuando los necesites.
