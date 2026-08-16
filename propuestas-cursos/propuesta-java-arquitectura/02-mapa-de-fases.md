# 🗺️ Mapa de fases (tentativo)

> Propuesta: arquitectura para desarrolladores Java senior
> **Borrador para discutir, no para ejecutar.** Los números de horas son
> estimaciones y la partición puede cambiar entera.

Cada fase se define por **la decisión que enseña a tomar**, no por la tecnología que
usa. Y cada una produce **un artefacto** que sobrevive al curso.

---

## Los cuatro bloques

```text
Bloque A — Fases 00-03   La frontera interna     Dentro de un despliegue
Bloque B — Fases 04-07   La frontera externa     Entre despliegues
Bloque C — Fases 08-11   Las restricciones       Lo no funcional como diseño
Bloque D — Fases 12-15   La decisión             Defenderla, migrarla, medirla
```

La progresión tiene una intención: **empieza por dentro.** La mayoría de los cursos
de arquitectura arrancan repartiendo servicios en una pizarra; este empieza
preguntando si hacen falta, y no llega a la frontera de despliegue hasta el Bloque
B — con el argumento ya construido de que una frontera interna bien puesta resuelve
casi todo lo que la gente distribuye por reflejo.

---

## Bloque A — La frontera interna

### 🔍 Fase 00 — La auditoría del punto de partida · ~6 h

**Decisión:** ninguna todavía. Se aprende a **leer** una arquitectura antes de
tocarla.

Toma el `super-inventory` del laboratorio con su Anillo 0 cerrado y lo audita: el
grafo de dependencias real —no el del diagrama—, el camino crítico de la operación
más frecuente, los puntos de fallo, y las cinco decisiones discutibles que el
laboratorio sembró (documento de encaje §4).

Se establecen las **métricas de arquitectura** desde el día uno, porque todo lo que
viene se mide contra esta línea base: latencia p99 de la venta, acoplamiento entre
módulos, radio de impacto de un fallo, piezas desplegables, tiempo de un cambio de
punta a punta.

**Artefacto:** el modelo C4 del sistema **tal como está** —los cuatro niveles— y la
línea base medida.
**🪞 El instinto:** *"el diagrama de la wiki describe el sistema."* Casi nunca.

---

### 🧱 Fase 01 — Fronteras de módulo · ~8 h

**Decisión:** ¿por capas o por funcionalidad? ¿Qué puede importar qué?

El monolito modular en serio. Paquetes por *feature* frente a paquetes por capa —y
por qué la segunda opción, que es la que casi todo el mundo tiene, hace imposible
extraer nada después. Módulos de Java, visibilidad, y la frontera verificada con
**ArchUnit** en vez de con buena voluntad.

**Artefacto:** las primeras funciones de aptitud en CI, que a partir de aquí viven
en `main`.
**⚰️ Autopsia:** el paquete `service` con cuarenta clases y el `common` que todo el
mundo importa.
**🩻 Lo que se traslada:** todo tu criterio de cohesión y acoplamiento. Es el mismo.

---

### 💾 Fase 02 — Fronteras de transacción · ~9 h

**Decisión:** ¿dónde empieza y termina una unidad de consistencia?

El agregado como frontera transaccional. La regla de "una transacción, un agregado"
y qué pasa cuando se incumple. Las patologías de JPA que **son** decisiones de
arquitectura disfrazadas de detalle: el N+1, el *lazy loading* que fuerza el
contexto abierto hasta la vista, el caché de primer nivel que esconde una lectura
obsoleta, y `@Transactional` que no se aplica en una llamada interna del mismo bean.

Y el bloqueo: optimista, pesimista, y el coste de cada uno bajo contención real
—medido en el cluster.

**Artefacto:** el mapa de agregados de `inventory`, con las invariantes que cada uno
sostiene.
**🪞 El instinto:** *"pongo `@Transactional` en el servicio y ya."* La anotación no
decide la frontera: la esconde.

---

### 🗺️ Fase 03 — Fronteras de dominio · ~8 h

**Decisión:** ¿esto es un contexto o dos? Y si son dos, ¿qué relación tienen?

Diseño estratégico: contexto acotado, lenguaje ubicuo y —lo que casi nunca se
enseña— el **mapa de contextos** con sus patrones de relación: núcleo compartido,
cliente-proveedor, conformista, capa anticorrupción, caminos separados.

El caso de estudio es del propio juguete: `catalog` dice **qué** productos existen
e `inventory` dice **cuántos hay**. ¿Es un contexto o dos? ¿Y el `Product` de cada
uno es el mismo concepto?

**Artefacto:** el mapa de contextos del sistema, con el patrón de cada relación
justificado.
**⚖️ El veredicto:** los tres casos en que el DDD táctico es exceso de ceremonia, y
por qué el estratégico casi nunca lo es.

---

## Bloque B — La frontera externa

### 📜 Fase 04 — El contrato · ~7 h

**Decisión:** ¿qué prometes, a quién, y por cuánto tiempo?

Compatibilidad hacia adelante y hacia atrás, versionado, y el ciclo de retirada de
una versión. Pruebas de contrato dirigidas por el consumidor con Pact o Spring Cloud
Contract, contra la alternativa que el curso de Go usó —definición compartida más
prueba de integración— y con el criterio de cuándo cada una.

**Artefacto:** el contrato versionado de los tres servicios y su suite que impide
romperlo.
**🧨 Rompe a propósito:** un cambio compatible según el equipo que lo hizo, e
incompatible para el que lo consume.

---

### 🔀 Fase 05 — El eje de comunicación · ~8 h

**Decisión:** ¿REST, gRPC o eventos? Y la pregunta de verdad: **¿síncrono o
asíncrono?**

El eje real no es el protocolo: es el **acoplamiento temporal**. Una llamada
síncrona acopla la disponibilidad de los dos extremos; un evento la desacopla y
acopla otra cosa —el esquema, el orden, la semántica de entrega—.

El caso de estudio es la llamada de `inventory` a `catalog` en cada venta: síncrona,
en el camino crítico, y acoplando la disponibilidad de la venta a la del catálogo.
Cuatro opciones, medidas.

**Artefacto:** el ADR de la comunicación entre servicios, con las cuatro opciones y
sus números.
**📐 Medición:** latencia y disponibilidad efectiva del flujo de venta con cada
opción.

---

### ⚖️ Fase 06 — Consistencia distribuida ⭐ · ~12 h

**La fase estrella del bloque.**

**Decisión:** cuando una operación abarca dos servicios, ¿qué garantía das?

Por qué no hay transacciones distribuidas (y por qué 2PC no es la respuesta).
Sagas orquestadas frente a coreografiadas, con el criterio de cuándo cada una y qué
se pierde. Compensaciones —y la pregunta que casi nadie hace: **¿qué pasa cuando la
compensación falla?**. El patrón **outbox** como solución al defecto sembrado del
laboratorio. Idempotencia en el consumidor, "al menos una vez" frente a "exactamente
una vez", y por qué lo segundo no existe entre dos sistemas.

**Artefacto:** el ADR de la consistencia del flujo venta → reposición, y la ventana
de inconsistencia declarada como contrato.
**⚰️ Autopsia:** la saga que se diseñó para un proceso que cabía en una transacción.
**⚖️ El veredicto:** el 80% de las sagas que existen son la cicatriz de una frontera
mal puesta en la fase 03.

---

### 🛡️ Fase 07 — La frontera de fallo · ~7 h

**Decisión:** cuando esto falle —que va a fallar—, ¿qué se lleva por delante?

Dominios de fallo, mamparos, degradación funcional, y el cortacircuitos con la
pregunta incómoda: ¿qué devuelve tu sistema cuando el circuito está abierto?
Resilience4j en Spring Boot 3, y la trampa de las capas dobles de reintento cuando
hay una malla de servicios debajo.

**Artefacto:** la matriz de modos de fallo — qué falla, qué se degrada, qué se cae.
**🧨 Rompe a propósito:** mata `catalog` con carga y mide cuántas ventas se pierden.

---

## Bloque C — Las restricciones no funcionales

### 🧵 Fase 08 — El modelo de ejecución · ~8 h

**Decisión:** ¿hebras de plataforma, hebras virtuales o reactivo?

**La comparación más actual y peor entendida del mundo Java.** WebFlux se diseñó
para un problema —muchas conexiones bloqueadas en E/S con hilos caros— que las
hebras virtuales de Java 21 resuelven sin cambiar el modelo de programación. La
pregunta honesta es qué queda del argumento reactivo, y hay que responderla
midiendo, con el *pinning* dentro de `synchronized` incluido como límite real.

Y la compilación nativa con GraalVM: qué gana, qué pierde —el JIT— y cuándo compensa.

**Artefacto:** el banco de pruebas de los tres modelos sobre `inventory`, y el
veredicto.
**📐 Medición:** rendimiento, latencia p99, memoria y arranque en los tres.

---

### 📊 Fase 09 — Datos a escala · ~9 h

**Decisión:** ¿un modelo o dos? ¿Estado o historia?

CQRS con su veredicto honesto —es dos modelos, no dos bases de datos, y la mayoría
de la gente lo implementa al revés—. Modelos de lectura y su desfase. *Event
sourcing* con la pregunta que lo decide: ¿el negocio necesita la historia, o solo el
estado? La tabla `stock_movements` del juguete **ya es** una fuente de eventos, y
eso hace el caso concreto.

**Artefacto:** el ADR del modelo de lectura del dashboard, con su desfase aceptado.
**⚖️ El veredicto:** los cuatro casos donde *event sourcing* es la respuesta, y por
qué tu sistema probablemente no es ninguno.

---

### 🔐 Fase 10 — Seguridad como arquitectura · ~7 h

**Decisión:** ¿dónde está el límite de confianza?

No es la fase de OAuth: es la de **dónde poner la frontera de confianza y qué
asumes dentro de ella**. Confianza cero frente al perímetro, mTLS entre servicios y
qué problema resuelve de verdad, gestión de secretos, y la superficie de ataque como
propiedad medible del diseño.

Se apoya en los anillos C1–C4 del laboratorio, que ya montaron los certificados: aquí
se decide **si hacían falta**.

**Artefacto:** el modelo de amenazas del sistema, con los límites de confianza
dibujados.

---

### 👁️ Fase 11 — Observabilidad como requisito de diseño · ~6 h

**Decisión:** ¿qué tiene que poder responderse sin abrir el código?

La diferencia entre instrumentar y diseñar para ser observable. Métricas de negocio
frente a métricas técnicas —y el punto ciego que eso produce—. Correlación entre
servicios. Y las **funciones de aptitud** como observabilidad de la arquitectura:
verificar en CI que el acoplamiento no subió, que la latencia no se degradó, que
nadie importó lo que no debía.

**Artefacto:** el conjunto completo de funciones de aptitud, y el catálogo de
preguntas que el sistema sabe responder.

---

## Bloque D — La decisión

### 🔄 Fase 12 — Migración y modernización · ~9 h

**Decisión:** ¿cómo se lleva un sistema de A a B sin parar el negocio?

*Strangler fig*, expansión y contracción, doble escritura, banderas de
funcionalidad, y —lo que más falta hace— **el plan de reversión de cada paso**. El
caso concreto es doble: la migración de Java 17 a 25 del Anillo 5, y la extracción
o reunificación de un servicio.

**Artefacto:** el plan de migración por pasos, cada uno reversible y desplegable
solo.
**⚰️ Autopsia:** la migración que se convirtió en reescritura. *(Sí, es la misma
lección que la Fase 08 del curso de Go, y se cita — porque el reflejo es humano, no
del lenguaje.)*

---

### 💰 Fase 13 — El coste y la organización · ~7 h

**Decisión:** ¿quién mantiene esto, y cuánto cuesta que exista?

Coste por petición traducido a factura. Coste operativo: piezas que mantener,
rotaciones de guardia, pipelines. Y la ley de Conway tomada en serio: **la
arquitectura que puedes sostener depende del equipo que tienes**, y separar cuatro
servicios con tres personas es una decisión sobre personas, no sobre software.

**Artefacto:** el análisis de coste total de las dos arquitecturas candidatas.
**🪞 El instinto:** *"esto lo decide la tecnología."* Lo decide el organigrama, y lo
sabemos desde 1967.

---

### 📋 Fase 14 — Evaluar y documentar · ~7 h

**Decisión:** cómo se justifica una arquitectura ante alguien que no la escribió.

Escribir ADRs que sirvan —con contexto, opciones descartadas y consecuencias, no
solo la decisión—. Un ATAM ligero: escenarios de calidad, puntos de sensibilidad y
compromisos explícitos. El modelo C4 como herramienta de comunicación por audiencia.
Y la revisión de arquitectura como práctica de equipo.

**Artefacto:** la colección de ADRs completa, revisada, con las decisiones del curso
justificadas.

---

### 🏁 Fase 15 — El veredicto ⭐ · ~10 h

**La fase por la que existe el curso.**

**Decisión:** para `super-inventory`, ¿monolito modular o microservicios?

Se construye la rama `arq/experimento-monolito` del documento de encaje §7 —los tres
backends en un despliegue Java modular, con fronteras verificadas y una sola base de
datos con esquemas separados— y **se mide contra la versión distribuida** en el mismo
cluster, con la misma carga.

Y se responde la pregunta en las dos direcciones: cuál gana aquí, y **qué tendría
que ser verdad de este sistema para que la otra fuera correcta**.

**Artefacto:** `docs/veredicto.md` — la recomendación con sus números, sus
condiciones y su plan de ejecución.
**⚖️ El veredicto honesto** tiene que doler en las dos direcciones. Si tu conclusión
es "microservicios siempre" o "monolito siempre", falta una medición.

---

## Resumen

| Bloque | Fases | Horas | Entregable del bloque |
|---|---|---|---|
| A · frontera interna | 00–03 | ~31 | C4, funciones de aptitud, mapa de contextos |
| B · frontera externa | 04–07 | ~34 | Contratos, ADR de consistencia, matriz de fallos |
| C · restricciones | 08–11 | ~30 | Banco de pruebas, modelo de amenazas, observabilidad |
| D · la decisión | 12–15 | ~33 | Plan de migración, ADRs, **el veredicto** |
| | **16 fases** | **~128 h** | |

Unas 26 semanas a 5 h/semana, o 13 a 10 h/semana.

---

## La versión intensiva

Si hay prisa —y en búsqueda de empleo la hay—, el subconjunto que concentra los
artefactos de entrevista en las primeras semanas:

**00 → 01 → 02 → 03 → 06 → 08 → 13 → 15.**

Ocho fases, unas 70 horas, y produce: el C4, las funciones de aptitud, el mapa de
contextos, el ADR de consistencia, el banco de pruebas del modelo de ejecución, el
análisis de coste y **el veredicto**. Es prácticamente todo lo que se enseña en una
entrevista de arquitecto.

Lo que se deja fuera —contratos, fallo, datos a escala, seguridad, observabilidad,
migración, evaluación formal— es material excelente y es el que menos se pregunta en
una primera entrevista.

> ⚠️ **Y la advertencia de siempre:** la fase 06 asume la 03, y la 15 asume la 01.
> El subconjunto respeta las dependencias; reordenarlo a gusto, no.

---

## Lo que falta decidir aquí

1. **¿16 fases o la intensiva de 8?** Depende de la respuesta a la pregunta 4 del
   README.
2. **¿La fase 08 (hebras virtuales frente a reactivo) es una fase o un apéndice?**
   Es la más "de Java" de todas y la menos "de arquitectura" — y a la vez es la que
   más se pregunta hoy en una entrevista.
3. **¿Falta una fase de pruebas de arquitectura?** Ahora están repartidas entre la
   01 (ArchUnit), la 04 (contratos) y la 11 (funciones de aptitud). Podría ser una
   fase propia, o está bien repartida.
4. **¿Y una de coste real en la nube?** Ahora es media fase 13, y estimada. Medirla
   de verdad exige una cuenta de pago, que está fuera del alcance declarado.
