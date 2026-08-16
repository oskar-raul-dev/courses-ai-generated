# 🧭 Oráculo de Bolsillo — Alcance del proyecto

> Deriva de `03-oraculo-de-bolsillo-semilla.md` (fuente de verdad) y de
> `RUTA-NOSQL-FUNDAMENTOS.md`. Ante cualquier conflicto, gana la semilla.

## 1. Qué construye el curso

Oráculo de Bolsillo es un **sistema de preguntas y respuestas sobre un
corpus de documentos propios, con citas verificables**. En términos de
alcance funcional, al terminar el curso existe:

- Un **pipeline de ingesta** (Python) que convierte documentos en `chunk`s
  con su texto, su procedencia (documento, página o sección) y su
  `embedding`.
- Un **servicio de consulta** (TypeScript / Node) que recibe una pregunta en
  lenguaje natural, la convierte en embedding, recupera los `k` fragmentos
  más cercanos, construye contexto para un modelo de lenguaje y devuelve una
  respuesta con **cita exacta por afirmación**.
- Una **capa relacional en Postgres** que custodia lo que no es vectorial:
  documentos, versiones, permisos y el registro de qué se citó en qué
  respuesta.
- Cuatro **motores de búsqueda por similitud** puestos a competir con el
  mismo arnés sobre el mismo corpus: pgvector (punto de partida obligado),
  Qdrant y Weaviate (dedicados auto-hospedados) y Pinecone (referencia
  gestionada) — cada uno entra en el curso solo cuando la evidencia medida
  de la fase anterior lo justifica.
- El **arnés `scripts/vs.ts`** y sus dos artefactos acumulativos,
  `INSTINTOS.md` y `BENCHMARKS.md`, que son el producto pedagógico central
  tanto como el sistema mismo: sin ellos, el curso degrada a "tutorial de
  RAG".
- Un **generador de corpus sintético** parametrizable, para poder correr los
  duelos a distintas escalas (10k / 100k / 1M chunks) sin depender de un
  dataset externo.

El foco del curso no es "cómo se construye un RAG": es **cómo se decide,
con números propios, cuándo un índice de similitud alcanza y cuándo hace
falta un motor dedicado**. El RAG es el vehículo del dominio; el modelo de
acceso vectorial y su costo de adopción son la lección.

## 2. Qué queda fuera por ahora (fuera del alcance base)

Prosa, no lista de deseos: cada exclusión existe para que el curso no se
diluya en un tutorial genérico de aplicaciones con IA.

- **No es un curso de prompt engineering ni de fine-tuning.** El modelo de
  lenguaje que genera la respuesta final es una pieza intercambiable detrás
  de una interfaz; el curso no entra en la ingeniería de prompts más allá
  de lo mínimo para producir una respuesta atribuible.
- **No es un curso de frontend.** No hay UI más allá de lo estrictamente
  necesario para demostrar el flujo (una CLI o un cliente HTTP mínimo
  bastan); no se construye una interfaz de usuario pulida.
- **No cubre autenticación ni autorización de grado productivo.** Los
  permisos de documento se modelan como dato relacional para que el marco
  de 5 preguntas tenga sentido, pero no se implementa un sistema de
  identidad completo (OAuth, SSO, RBAC granular); es una simplificación
  deliberada.
- **No es un curso de arquitectura multi-tenant a escala.** El corpus es de
  una sola organización o persona; la multi-tenencia real (aislar miles de
  corpus de clientes distintos) queda fuera y se menciona solo como
  extensión posible en el veredicto final.
- **No entra en el entrenamiento ni ajuste de modelos de embeddings.** Se
  **usa** un modelo de embeddings ya entrenado (local o vía API); entrenar
  uno propio, o hacer *fine-tuning* de uno existente, queda fuera.
- **No cubre bases de datos de grafos para relacionar chunks entre sí**
  (GraphRAG y variantes) — eso pertenece al modelo de acceso de grafo
  (curso 6 de la ruta), no a este.
- **Java y C++ no forman parte del alcance base.** Existen como codas 🔥
  opcionales (ver semilla, §Consideraciones adicionales) para quien ya
  terminó una fase y quiere sentir la fricción de salir del ecosistema
  TypeScript/Python; no son una vía alternativa del curso.
- **El motor dedicado no se adopta por adelantado.** Qdrant, Weaviate y
  Pinecone están *declarados* en el laboratorio desde la Fase 0, pero no se
  usan de verdad hasta que la Fase 6 mide el techo de pgvector. Adelantar
  un dedicado "porque es lo interesante" rompe la lección central del
  curso y queda explícitamente fuera de cómo se redactan las fases.

## 3. Contra qué mercado real se valida (productizable)

**Veredicto de partida: ✅ Muy fuerte** (heredado de la semilla, §Validación
contra un mercado real).

| Eje de validación | Cómo lo cumple Oráculo de Bolsillo |
|---|---|
| **Categoría de producto existente** | RAG sobre documentos propios es hoy una categoría con múltiples actores reales: asistentes de documentación, Q&A sobre bases de conocimiento internas, buscadores semánticos empresariales. |
| **Diferenciador técnico defendible** | La **cita verificable** por afirmación — exactamente lo que separa un RAG confiable de uno que alucina con apariencia de fundamento, y lo que un comprador empresarial exige antes de confiar el sistema. |
| **Criterio de arquitectura transferible** | "Empieza por la opción barata, mide, escala solo con evidencia" es el mismo criterio que un equipo de producto real necesita para no quemar presupuesto en infraestructura vectorial prematura. |
| **Volumen realista** | El corpus objetivo (miles a cientos de miles de chunks, un wiki interno o una base documental de equipo) es el tamaño real de la mayoría de los RAG empresariales que se despliegan hoy — no un caso de laboratorio artificialmente pequeño ni un caso de escala de buscador web. |

El sistema no se valida contra un caso de uso inventado para que el modelo
"quede bien": se valida contra el problema que resuelven hoy productos como
los asistentes de documentación interna y los buscadores semánticos de
soporte — con el mismo requisito no negociable (citas verificables) que
esos productos reales exponen a sus clientes.

## 4. Árbol de decisión: cuándo NO usar la familia vectorial

Este árbol es el que Fase 11 formaliza con números propios de
`BENCHMARKS.md`; aquí queda como guía de alcance para no prometer de más.

1. **¿La consulta dominante es "encuéntrame lo más parecido a esto" en un
   espacio de decenas o cientos de dimensiones?**
   - **No** → no es un problema vectorial. Si la consulta es por clave
     exacta, usa clave-valor o el índice primario relacional; si es por
     coincidencia de texto o facetas, usa un motor de búsqueda de texto
     (curso 7 de la ruta, `El Vigía`) antes que forzar embeddings sobre
     texto corto o estructurado.
   - **Sí** → seguí al punto 2.
2. **¿El volumen del corpus y la latencia exigida caben en la extensión
   vectorial de la base relacional que ya operas?**
   - **Sí** → **no** montes un motor dedicado. Empieza (y probablemente
     termina) en pgvector. Este es el caso por defecto del curso.
   - **No** (medido con `vs.ts`, no supuesto) → seguí al punto 3.
3. **¿La necesidad es de rendimiento crudo, de filtrado combinado con
   vecindad a gran escala, o de búsqueda híbrida nativa?**
   - Rendimiento crudo / control fino → motor dedicado tipo Qdrant.
   - Búsqueda híbrida (léxica + vectorial) de fábrica → motor tipo Weaviate.
   - Cero apetito por operar infraestructura propia, y el costo por
     consulta de un *managed* es aceptable → Pinecone u otro *managed*.
4. **¿El equipo puede sostener la superficie operativa nueva** (backup,
   monitoreo, guardia, re-sincronización del índice contra la fuente de
   verdad relacional) **que un motor dedicado agrega**?
   - **No** → el número de la Fase 7/8 puede ganar en el papel y perder en
     la operación real; el curso enseña a nombrar ese costo, no solo el
     número de latencia.

El árbol es simétrico a propósito: el villano del curso —montar un motor
dedicado prematuro— tiene un gemelo igual de real —quedarse en pgvector
cuando el volumen o el filtrado ya lo piden a gritos, por pereza u orgullo
relacional. El alcance del curso es enseñar a reconocer ambos lados.

## 5. Fronteras con otros cursos de la ruta

- **Curso 0 (documental, Proteo)** usa **Couchbase** como rival, no
  CouchDB. Oráculo de Bolsillo no toca ninguno de los dos; se menciona solo
  para que no se confunda la costura relacional↔documental del curso 0 con
  la costura relacional↔vectorial de este curso.
- **Curso 6 (grafo)** es el lugar de la ruta para relacionar entidades
  entre sí (GraphRAG, redes de citas cruzadas); Oráculo de Bolsillo no
  modela relaciones entre chunks más allá de la procedencia documento↔chunk.
- **Curso 7 (búsqueda, El Vigía)** es el lugar para relevancia léxica y
  facetas a escala; la búsqueda híbrida que aparece en la Fase 8 de este
  curso es una demostración acotada del cruce, no una cobertura completa
  del modelo de búsqueda.
- **Curso 10 (El Árbitro)** es donde se discute la factura de operar varios
  motores a la vez (el propio Postgres + un dedicado, en este caso); este
  curso mide el costo de *adoptar* un dedicado, El Árbitro mide el costo de
  *sostener* la persistencia políglota resultante en el tiempo.

## 6. Decisiones de alcance pendientes de confirmar

Estas decisiones viven también en la semilla (§Decisiones pendientes) y
condicionan el alcance exacto: el dataset semilla (sintético vs. real
pequeño), el modelo de embeddings (local vs. API), la dimensión del vector,
si Pinecone se implementa de verdad o se documenta, y el proveedor de LLM
para la generación. Ninguna bloquea el arranque de la Fase 0: todas tienen
una propuesta por defecto documentada en la semilla.
