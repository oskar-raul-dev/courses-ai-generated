# ⚖️ Apéndice 5 — Mongo vs SQL: la conversación a fondo

## 🎯 Para qué sirve este apéndice

La Fase 15 te dio el **instrumento**: cinco preguntas, una tabla de olores, un
árbol de decisión. Este apéndice te da el **contexto** — la teoría, la
historia y los documentos del debate real, para que tu veredicto no sea una
opinión bien vestida sino una posición informada.

Es el único apéndice donde se lee más de lo que se teclea. Los ejercicios son
ensayos, debates y auditorías: **el músculo que entrena es el criterio**.

Y responde una pregunta que quizá te ronda desde la Fase 3: *¿por qué existe
`soporte_v1`?* No por estupidez de nadie. Existe porque en 2013 una industria
entera se convenció de algo, y los sistemas que heredas son el sedimento de esa
convicción. Entender por qué es el último paso para dejar de juzgar y empezar a
diagnosticar.

---

## 📜 Historia mínima del hype (2009–2021)

| Etapa | Qué pasaba | Qué dejó en tu legacy |
|---|---|---|
| **2009–2011 · La rebelión** | Web 2.0, escalado horizontal, "el RDBMS no escala". Nace el término NoSQL. Mongo 1.x: sin transacciones, sin joins, `w:0` por defecto (¡las escrituras no se confirmaban!) | la fama de "pierde datos" que persiguió a Mongo una década — merecida entonces, injusta después |
| **2012–2015 · El apogeo** | MEAN stack, "schemaless = velocidad", tutoriales de blog con posts y comments. Mongo se vende como base de propósito general | **el 90% de tu legacy nació aquí**: modelos traducidos, sin índices pensados, sin validación |
| **2013 · La resaca** | Sarah Mei publica "Why You Should Never Use MongoDB". Jepsen destroza la consistencia. Empiezan las migraciones de vuelta a Postgres | los post-mortems y el péndulo emocional del debate |
| **2016–2018 · La madurez** | WiredTiger, `$lookup` (3.2), validación de esquema (3.6), **transacciones (4.0)**. Mongo se vuelve aburrido — el mejor elogio para una base | el motor que tu curso usa: 4.4, capaz de casi todo |
| **2018–2021 · La síntesis** | Postgres con JSONB serio. Nadie sensato milita. "Polyglot persistence" y "elige por caso de uso" ganan el discurso | tu trabajo: heredar lo del apogeo y operarlo con el motor de la madurez |

**La lección meta:** casi todos los argumentos que oirás contra Mongo son
argumentos contra **Mongo 2.x** o contra el modelado de 2013. Y casi todos los
argumentos a favor que oirás son de folleto. Fechar el argumento es el primer
movimiento de cualquier debate serio.

---

## 🧠 CAP y PACELC con juicio (y sin misticismo)

CAP se cita constantemente y se entiende poco. La versión honesta:

> **CAP:** cuando la **red se parte** (P), un sistema distribuido debe elegir
> entre seguir respondiendo con datos posiblemente rancios (**A**vailability) o
> negarse a responder para no mentir (**C**onsistency).

Tres correcciones que hacen falta:

1. **La P no es opcional.** Las redes se parten. "Elegir CA" no es una opción
   de diseño: es una frase de marketing. La elección real es **C o A durante
   la partición**.
2. **No es un interruptor, es un dial.** Mongo lo demuestra: tú eliges por
   operación. `w:"majority"` + `readConcern:"majority"` = más C, menos A y más
   latencia. `w:1` + `readConcern:"local"` = más A, menos C. **Las perillas de
   la Fase 6 son CAP hecho parámetro** — por eso las aprendiste.
3. **PACELC completa la frase** (Abadi): *si hay Partición (P), eliges entre A
   y C; **Else** (E), en operación normal, eliges entre **L**atencia y
   **C**onsistencia.* Y esta segunda mitad es la que gobierna tu día a día,
   porque las particiones son raras y la latencia es todos los días.

**Y el matiz que casi nadie dice:** tu Mini Jira corre en **un nodo**. CAP no
te aplica. Un solo nodo no se parte de sí mismo. Toda la angustia CAP del
debate de la época pertenece a sistemas distribuidos — y la mayoría de los
sistemas internos que heredarás no lo son. Saber cuándo un argumento **no
aplica** es tan valioso como saber usarlo.

---

## 🔬 Jepsen: leer las críticas de la herramienta que dominas

Kyle Kingsbury (Jepsen) somete bases de datos a particiones y demuestra dónde
sus garantías se rompen. Analizó MongoDB tres veces (2013, 2015, 2020 — la
4.2.6), y la trayectoria misma es la lección:

- **2013:** hallazgos graves. Merecidos.
- **2015:** mejor, aún con problemas.
- **2020 (4.2.6):** encuentra que ciertas configuraciones no daban las
  garantías anunciadas (transacciones bajo read concern por defecto podían
  observar anomalías; el nivel documentado como "snapshot" no siempre lo era),
  y que **los defaults no eran los seguros**. MongoDB corrigió y ajustó su
  documentación.

**Qué significa para lo que construiste:** refuerza exactamente la disciplina
de la Fase 6 — las perillas importan, los defaults no son promesas, y si tu
invariante es dura, **declara** `w:"majority"` y `readConcern:"majority"`, no
lo asumas. Nada de lo que construiste se cae; sí se subraya por qué no
construiste sobre suposiciones.

**Y la lección de carácter:** el ingeniero que solo lee el marketing de su
herramienta es un usuario. El que lee sus análisis adversariales es un
profesional. Haz esto con cada tecnología que domines.

---

## 🧩 El debate, documento por documento

**Sarah Mei — "Why You Should Never Use MongoDB" (2013).** El caso Diaspora:
un dominio social (usuarios, posts, comentarios, likes) que empezó "obvio"
como documentos y terminó necesitando cruzar todo con todo. El título es un
clickbait que la propia autora matiza; el contenido es un **caso de modelado**
impecable. Tu lectura, tras 14 fases: Diaspora **falló la pregunta 1** (¿qué se
lee junto?) — su acceso era transversal e impredecible. No era la base: era el
ajuste modelo↔acceso. Y encima Mei escribía en la era pre-`$lookup`,
pre-transacciones, pre-validación.

**William Zola — "6 Rules of Thumb" (2014).** La respuesta implícita de
MongoDB: aquí está cómo se modela de verdad. Es la Fase 3 del curso, cinco
años antes.

**Michael Stonebraker — "The 'NoSQL' Discussion has Nothing to Do With SQL"
(2010).** El padre de Postgres argumenta que los problemas de rendimiento de
los RDBMS no venían de SQL ni del modelo relacional, sino de las **capas
heredadas** (buffer pool, locking, logging) — y que se pueden reescribir sin
tirar el modelo. Lectura incómoda y valiosa: separa "el paradigma" de "esta
implementación".

**Fowler & Sadalage — "NoSQL Distilled" (2012).** El libro sereno del pico del
hype. Introduce **polyglot persistence** — que es la rama 2 de tu árbol de la
Fase 15, con pedigrí académico y ocho años de antigüedad.

**Kleppmann — "Designing Data-Intensive Applications" (2017), cap. 2.** El
texto definitivo. Su tesis central es LA tesis de tu curso, dicha mejor: la
elección documento vs relacional depende del **acoplamiento entre la estructura
de tus datos y tus patrones de acceso** — los documentos ganan con relaciones
uno-a-muchos que se leen como un todo (localidad), y pierden cuando hay muchos
muchos-a-muchos (que fue el problema de Diaspora). Y observa el gran giro
histórico: **los dos modelos convergen** (SQL con JSON, documentales con
joins) — exactamente el 🪞 final de tu Fase 15.

---

## 📊 Migraciones reales: lo que enseñan los post-mortems

Los relatos públicos de la época (búscalos: son ejercicio 12) tienen un patrón
tan consistente que da vergüenza:

| Lo que dijeron | Lo que casi siempre había debajo |
|---|---|
| "Mongo no escaló" | ningún índice sobre las queries reales (tu Fase 7 en 20 minutos lo habría visto) |
| "Perdimos consistencia" | `w:0`/`w:1` sin entender qué compraron, o invariantes repartidas entre documentos que debieron ser uno |
| "Las queries eran imposibles" | modelo traducido: `$lookup` en cadena en cada pantalla (tu Fase 5) |
| "El esquema era un caos" | sin `schemaVersion`, sin validators, tres versiones conviviendo (tu Fase 4) |
| "Migramos a Postgres y todo mejoró" | **cierto** — y también habrían mejorado rediseñando en Mongo; la migración forzó, de paso, a **pensar el modelo por primera vez** |

Esa última fila es la más incómoda y la más importante: **muchas migraciones
exitosas lo fueron por el rediseño, no por el motor.** Es la rama 1 de tu
árbol, y es exactamente lo que demostraste con números en tu propia autopsia
(Fase 8). Cuando leas el próximo post-mortem triunfal, busca la evidencia de
que compararon *el sistema nuevo bien hecho* contra *el viejo bien hecho* —
casi nunca la hay.

---

## 🧭 El marco, con su teoría detrás

Las cinco preguntas de la Fase 15, ahora con su fundamento:

| Pregunta | Su nombre en la literatura |
|---|---|
| 1. ¿Qué se lee junto? | **Localidad** (Kleppmann) / los agregados de DDD (Evans, Vernon): el documento ES el agregado |
| 2. ¿Quién custodia la forma? | schema-on-write vs **schema-on-read** (el término honesto que la industria debió usar desde el principio) |
| 3. ¿Cuánto unes en caliente? | el coste del join, y la **desnormalización como caché materializada** (tu ensayo de la Fase 3) |
| 4. ¿Dónde viven tus invariantes? | **límites de consistencia**: el agregado como frontera transaccional (DDD otra vez — y es por qué Mongo y DDD congenian) |
| 5. ¿Qué pide la operación? | Conway en la práctica: la herramienta que tu equipo puede operar de verdad, un martes a las 3 am |

El descubrimiento agradable: **cuatro de las cinco preguntas son de diseño de
software, no de bases de datos.** Por eso el curso funcionó: no aprendiste
Mongo, aprendiste a interrogar un dominio — con Mongo como excusa.

---

## 🧩 Chuleta

```
HISTORIA: casi todo argumento anti-Mongo es contra 2.x o contra el modelado de 2013
          casi todo argumento pro-Mongo es de folleto → FECHA el argumento primero

CAP:      la P no se elige · es un dial, no un interruptor (= las perillas de la F6)
PACELC:   Else → Latencia vs Consistencia = tu día a día
          Un nodo NO se parte de sí mismo → CAP no aplica a tu Mini Jira

JEPSEN:   los defaults no son promesas · si la invariante es dura, DECLÁRALA

CANON:    Mei 2013 (caso de modelado, no de motor) · Zola 2014 (la F3, antes)
          Stonebraker 2010 (SQL ≠ la implementación) · Fowler/Sadalage (polyglot)
          Kleppmann cap.2 (localidad ↔ acceso; y los modelos CONVERGEN)

POST-MORTEMS: "migramos y mejoró" casi siempre = "rediseñamos por primera vez"

LAS 5 PREGUNTAS son 4 de diseño de software + 1 de operación.
```

---

## ⚠️ Errores comunes (en el debate, no en el código)

- Citar CAP para un sistema de un nodo.
- Argumentar con la versión equivocada (Mongo 2.x contra tu 4.4; o Postgres
  pre-JSONB contra el actual).
- Confundir "el motor falló" con "el modelo falló" — la confusión que fabricó
  la mitad de la literatura del hype (y de la anti-hype).
- Tomar el título de Mei como su tesis (ella misma la matizó; lee el cuerpo).
- Creer que polyglot persistence es gratis: son **dos operaciones** (dos F14),
  dos backups, dos guardias, y la consistencia entre ambas es tuya.
- Usar benchmarks de terceros como argumento: la única medición que vale es la
  de **tus** patrones de acceso — catorce fases insistiendo en eso.
- Militar. Es cómodo, es social, y te vuelve inútil para el diagnóstico.

---

## 🧪 Ejercicios (30) — lectura, análisis y criterio

**🟢 Fácil (1–8)**

1. Lee el ensayo de Sarah Mei completo. Escribe media página: ¿cuál de las 5 preguntas del marco falló Diaspora, y con qué evidencia del propio texto?
2. Fecha el ensayo: lista qué features que Mongo NO tenía en 2013 habrían cambiado el caso (o no). Sé riguroso: ¿`$lookup` habría salvado a Diaspora, o solo habría maquillado el problema? (Pista: tu Fase 5.)
3. Lee las "6 Rules of Thumb" de Zola con ojos post-Fase 3. ¿Qué regla NO habrías sabido justificar antes del curso? ¿Alguna que hoy matizarías?
4. Lee el resumen del Jepsen de 4.2.6. Lista 3 hallazgos y, para cada uno, qué configuración del curso lo evita o lo hace irrelevante.
5. CAP aplicado (o no) al Mini Jira: escribe 5 líneas explicando por qué el teorema no gobierna tu sistema, y qué gobernaría en su lugar (PACELC-Else: latencia vs consistencia).
6. Traduce las perillas de la Fase 6 a lenguaje CAP: ¿qué combinación es "más C"? ¿Cuál "más A"? ¿Cuál elegiste tú y por qué?
7. Busca 3 artículos "Por qué migramos de MongoDB a PostgreSQL". Para cada uno, aplica la tabla de post-mortems: ¿cuál era el problema real bajo la queja declarada?
8. Y ahora los contrarios: busca 2 "Por qué migramos de PostgreSQL a MongoDB". ¿Son más escasos? ¿Por qué crees que sí? (Ojo con la conclusión fácil: piensa en el sesgo de publicación y en quién escribe post-mortems.)

**🟡 Intermedio (9–18)**

9. Lee el cap. 2 de Kleppmann. Mapea cada concepto (localidad, modelo relacional/documento/grafo, el "impedance mismatch", la convergencia) a la fase del curso que lo encarnó. ¿Qué concepto del capítulo el curso NO cubrió?
10. El modelo de grafos: Kleppmann dedica media sección a él. ¿Existe en el Mini Jira algún subdominio que sería natural en grafo (dependencias entre tickets, jerarquías de asignación)? Diséñalo mentalmente en las tres formas (relacional, documento, grafo) y elige con las 5 preguntas.
11. Stonebraker vs el hype: lee su artículo de 2010 y escribe la refutación desde la perspectiva de 2021 — ¿qué acertó? ¿En qué el mundo no le hizo caso y le fue bien igual?
12. Recopila 5 post-mortems de migraciones (en ambas direcciones) y arma una tabla comparativa: motivo declarado / problema real inferido / ¿rediseñaron o solo movieron? / ¿publicaron números? Es la evidencia empírica del capítulo, reunida por ti.
13. El sesgo del superviviente: los sistemas Mongo que funcionaron bien no escriben post-mortems. ¿Cómo buscarías evidencia de esos? (Casos de estudio de MongoDB — sesgados; charlas técnicas de empresas; repos abiertos.) Encuentra DOS y evalúalos con la tabla de olores de la F15.
14. Polyglot persistence con costos: para el Mini Jira crecido (facturación + reporting corporativo), calcula el costo REAL de la rama 2 — dos motores operados (dos F14 completas), la sincronización, y el equipo que necesita saber ambos. ¿A partir de qué tamaño de sistema se justifica?
15. Postgres JSONB, honestamente: implementa el Mini Jira mínimo (tickets con history embebido, búsqueda por status y texto) en Postgres con JSONB e índices GIN. Compara: modelado, consultas, y qué te obligó a hacer el motor. Ahora responde el 🪞 final de la F15 con las manos, no con la opinión.
16. La convergencia, medida: lista 5 cosas que Mongo tomó del mundo SQL (transacciones, joins, validación, agregaciones ricas, ACID por documento→multi-doc) y 5 que Postgres tomó del documental (JSONB, índices GIN, operadores de path, generated columns, jsonb_agg). ¿Hacia dónde va la convergencia? ¿Queda algo irreductiblemente distinto? (Sí: piensa en scale-out y en la pendiente por defecto.)
17. Reescribe el 🪞 final de la Fase 15 con lo que sabes ahora: ¿sigue en pie el concepto de "pendiente vs capacidad"? Refínalo con ejemplos concretos de los dos motores.
18. El argumento fechado: encuentra en internet 3 argumentos contra Mongo que estén técnicamente obsoletos (contra 2.x/3.x) y que sigan circulando hoy. Escribe la refutación con versión y fecha. Es exactamente lo que harás en tu próxima reunión de arquitectura.

**🟠 Difícil (19–25)**

19. El debate estructurado: consigue un interlocutor (colega, o tú mismo por escrito en dos columnas). Tema: "El Mini Jira debió construirse en Postgres". 20 minutos por lado, con evidencia. Al final, ambos deben escribir **el mejor argumento del contrario**. Si no puedes hacerlo, no entendiste su posición.
20. Reconstruye Diaspora: diseña el modelo social de Diaspora en Mongo 4.4 (con todo lo que aprendiste: agregados, referencias extendidas, bucket, `$lookup` solo en frío). ¿Es viable hoy? ¿En qué punto te rindes y admites que Mei tenía razón? Ese punto exacto es tu criterio de la pregunta 1, calibrado.
21. El caso del dominio hostil: retoma el sistema de turnos médicos (F3 ej. 28) — invariantes cruzadas duras, sin solapes, transaccional puro. Diséñalo en Mongo con todo el arsenal (transacciones, precondiciones, índices únicos parciales). Documenta cada punto donde el motor te hace remar. ¿Es imposible, o solo cuesta más? La diferencia entre "no se puede" y "no conviene" es el nivel de madurez de un arquitecto.
22. Escribe el ADR (Architecture Decision Record) que el equipo original del Mini Jira debió escribir en 2018: contexto, opciones consideradas, decisión, consecuencias — con la información que tenían ENTONCES (sin transacciones multi-doc; sin validación madura). ¿La decisión fue defendible con la información de la época? Este ejercicio te cura del juicio fácil al legacy ajeno.
23. El curso espejo (F15, ej. 20, en serio): escribe el capítulo completo (concepto + ejercicios) de "Fase 3 invertida: normalizar para cerebros Mongo" — los instintos documentales que traicionan en Postgres (embeber donde debiste referenciar, el JSONB como excusa para no modelar, la ausencia de constraints como costumbre). Enseñar el camino inverso demuestra que dominas el mapa completo.
24. Análisis de sensibilidad del marco: toma el Mini Jira y ve cambiando UNA condición por vez (10× más lecturas; el reporting se vuelve el 80% del uso; entran 3 equipos con SQL-cultura; el negocio exige auditoría transaccional total). ¿En qué punto el veredicto se invierte? Grafica/tabula el punto de quiebre de cada variable. Acabas de convertir el marco en un instrumento cuantitativo.
25. Lee el análisis Jepsen COMPLETO (no el resumen) de 4.2.6, incluida la respuesta de MongoDB. Escribe 1 página: ¿la respuesta del vendor fue honesta? ¿Qué harías tú distinto en tu sistema tras leerlo? ¿Qué pregunta le harías a Kingsbury? (Leer una crítica técnica dura, entenderla, y no ponerte defensivo ni fanático: es la habilidad final.)

**🔴 Muy difícil (26–30)**

26. La biblioteca comentada: escribe la reseña crítica (media página cada una) de las 4 fuentes canónicas (Mei, Zola, Stonebraker, Kleppmann cap. 2) — qué aporta, qué envejeció, para quién es, y qué fase del curso la encarna. Es la guía de lectura que le darías a tu equipo. Publícala si te atreves.
27. El paper que falta: identifica una pregunta del debate que NADIE responde bien con evidencia (candidatas: ¿cuánto cuesta REALMENTE una migración de motor?; ¿los equipos que rediseñaron sin migrar obtuvieron los mismos beneficios?). Diseña el estudio que la respondería: qué datos, de dónde, qué controles. No hace falta ejecutarlo — diseñarlo te enseña por qué nadie lo hizo.
28. Tu propio manifiesto (2 páginas): "Cómo elijo una base de datos". Las preguntas, el orden, los datos que exiges antes de opinar, las señales de que la decisión ya fue tomada por política y solo buscan tu bendición técnica, y qué haces en ese caso. Fírmalo con fecha. Es el documento que te define profesionalmente — y que revisarás en cinco años con vergüenza o con orgullo, ambas cosas útiles.
29. El siguiente paradigma: cuando llegue (bases vectoriales, event sourcing como default, lo que sea), ¿qué método usarás para desaprender con criterio? Escribe el **protocolo**, generalizado desde este curso: predicción falsable + medición + veredicto escrito + la pregunta "¿este instinto era sobre la herramienta o sobre la ingeniería?". Es la transferencia real: el curso no era sobre Mongo, era sobre cómo cambiar de paradigma sin perder el juicio ni la humildad.
30. **La charla final** (la de la F15 ej. 29, en su versión completa): prepárala y **dala** — a tu equipo, a un meetup, a quien sea. 30 minutos: la promesa, los cinco paradigmas con TUS mediciones, la autopsia con sus números, y el veredicto honesto sin militancia. Al recibir la primera pregunta hostil del público y responderla con datos en vez de con fe, el curso habrá terminado de verdad.

---

## 📚 Referencias

**El canon del debate (léelo en este orden)**

- Sarah Mei — *Why You Should Never Use MongoDB* (2013): http://www.sarahmei.com/blog/2013/11/11/why-you-should-never-use-mongodb/
- William Zola — *6 Rules of Thumb for MongoDB Schema Design*: https://www.mongodb.com/blog/post/6-rules-of-thumb-for-mongodb-schema-design
- Michael Stonebraker — *The "NoSQL" Discussion has Nothing to Do With SQL* (2010, blog de CACM): https://cacm.acm.org/blogs/blog-cacm/50678-the-nosql-discussion-has-nothing-to-do-with-sql/fulltext
- Jepsen — *MongoDB 4.2.6* (2020): https://jepsen.io/analyses/mongodb-4.2.6
- Jepsen — el índice completo de análisis (lee también el de Postgres: nadie sale ileso): https://jepsen.io/analyses

**Teoría**

- Martin Kleppmann — *Designing Data-Intensive Applications* (2017): cap. 2
  (modelos de datos — **el capítulo que este apéndice orbita**), cap. 5
  (replicación), cap. 7 (transacciones), cap. 9 (consistencia y consenso).
- Sadalage & Fowler — *NoSQL Distilled* (2012): corto; el cap. de polyglot
  persistence es la rama 2 de tu árbol.
- Eric Brewer — *CAP Twelve Years Later: How the "Rules" Have Changed* (2012):
  https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed/
- Daniel Abadi — PACELC (el paper y su blog: "Consistency Tradeoffs in Modern
  Distributed Database System Design"): busca "PACELC Abadi"
- Martin Fowler — bliki: NoSQL, PolyglotPersistence, AggregateOrientedDatabase:
  https://martinfowler.com/nosql.html

**El otro lado**

- PostgreSQL — JSONB y índices GIN (para el ejercicio 15): https://www.postgresql.org/docs/current/datatype-json.html
- Release notes de MongoDB 5/6/7 (para fechar tus argumentos): https://www.mongodb.com/docs/manual/release-notes/

**Video (YouTube)**

- Martin Kleppmann — *Transactions: myths, surprises and opportunities* (Strange Loop 2015): el cap. 7 de DDIA en 40 minutos
- Kyle Kingsbury (aphyr) — cualquiera de sus charlas de Jepsen: técnicas, mordaces y educativas
- Martin Fowler — *Introduction to NoSQL* (GOTO 2012): el marco sereno, en el ojo del huracán del hype

**Orden de lectura sugerido:**
la historia mínima de este apéndice (para situarte) → Mei (y tu refutación
matizada) → Zola → Kleppmann cap. 2 (**el corazón: si solo lees uno, es este**)
→ Jepsen 4.2.6 → Brewer sobre CAP doce años después → el resto según te pique
la curiosidad. Y luego el ejercicio 28: tu manifiesto. Escribirlo es la
graduación.
