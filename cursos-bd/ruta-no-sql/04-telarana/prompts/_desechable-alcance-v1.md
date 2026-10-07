# 🎯 Telaraña — Alcance del proyecto

> Curso #4 de la Ruta NoSQL · Modelo: **Grafo** (Neo4j vs Memgraph vs Neptune,
> control relacional con PostgreSQL) · Dominio: detección de fraude sobre
> transacciones financieras sintéticas.
>
> Este documento fija **qué construye Telaraña, qué queda deliberadamente
> fuera, y contra qué mercado real se valida**. Es la referencia para no
> "inflar" el proyecto fase a fase ni prometer algo que el curso no entrega.
> Ante cualquier duda de alcance al redactar una fase, este documento manda
> después de `04-telarana-semilla.md`.

---

## 1. Qué construye el curso

Telaraña construye, de punta a punta, un **sistema de detección de fraude**
sobre un grafo de transacciones financieras sintéticas, con dos motores de
grafo (Neo4j, Memgraph), un control relacional (PostgreSQL con CTE
recursivos) y una referencia documentada de grafo gestionado (Neptune). El
entregable no es "una base de datos con datos": es un sistema que responde
preguntas de recorrido con evidencia medida.

Lo que el lector tiene al cerrar la Fase 11:

- Un **generador de datos sintéticos** que siembra, de forma controlada y
  verificable (recall conocido), anillos de transferencias circulares y
  señales de identidad compartida (mismo dispositivo, dirección o teléfono
  detrás de cuentas aparentemente distintas), en dos formas equivalentes:
  grafo (nodos y aristas) y relacional (tablas y tablas puente).
- Un **motor de detección de anillos** de longitud variable (`A → B → C → A`,
  con más saltos) implementado en Cypher, con su equivalente en CTE recursivo
  de Postgres para comparación honesta.
- Un **motor de identidad indirecta** que agrupa cuentas sin transferencia
  directa entre sí pero conectadas por un atributo compartido, vía vecindario
  de grafo vs `JOIN` múltiple + `GROUP BY`/`HAVING` en SQL.
- Una capa de **algoritmos de análisis de red** (PageRank para influencia,
  Louvain para comunidades) sobre GDS (Neo4j) y MAGE (Memgraph), para
  priorizar sospechosos más allá del recorrido punto a punto.
- Un **arnés de medición** (`scripts/vs.ts`) que cronometra cada "vs" —nunca
  se narra un resultado sin medirlo— y dos artefactos acumulativos:
  `INSTINTOS.md` (predicción vs veredicto medido) y `BENCHMARKS.md` (el
  registro crudo de tiempos, profundidad `k`, tamaño de dataset y fecha).
- La **curva de costo por profundidad** (Fase 4): el hallazgo central del
  curso, el punto exacto donde el CTE recursivo de Postgres deja de rendir y
  Neo4j despega, medido y no insinuado.
- La **autopsia del villano** (Fase 11): la misma base de fraude modelada
  "solo en grafo" para consultas que en el 90% de los casos son de un salto,
  medida contra Postgres para mostrar dónde el grafo pierde.

## 2. Qué queda fuera (y por qué)

Nombrar el límite es tan importante como nombrar el alcance: es lo que evita
que el curso prometa un producto de fraude real y entregue un juguete.

| Queda fuera | Por qué | Dónde se menciona si acaso |
|---|---|---|
| Cuentas y transacciones **reales** | El dataset es 100% sintético; no hay PII ni confidencialidad que proteger, y el control sobre el recall exige saber de antemano cuántos anillos se sembraron | Fase 0 (generador) |
| Un motor de reglas de compliance/AML de producción (KYC, listas de sanciones, reportes regulatorios) | Es un dominio de cumplimiento normativo completo, no de modelo de acceso; se saldría del eje del curso | No se aborda |
| Operar Amazon Neptune con cuenta cloud real | Ataría el curso a costo AWS de pago; Neptune se estudia por diseño y modelo de costos, no se ejecuta | Fase 10 (documental, sin cronómetro) |
| Un frontend o dashboard de investigación de fraude | El curso enseña el modelo de acceso y su medición, no UX de producto; toda interacción es vía arnés y consultas directas | Podría vivir como 🔥 opcional, no en el núcleo |
| Streaming de eventos en tiempo real (Kafka u otro bus) hacia Memgraph | Memgraph se usa por su perfil in-memory, no para montar una arquitectura de streaming completa; el "casi en vivo" se simula con ingesta controlada del arnés | Se nombra en Fase 9 como contexto, no se implementa |
| Machine learning de score de fraude (features engineering, modelos supervisados) | Es un curso de modelo de acceso a datos, no de ciencia de datos; PageRank/Louvain son algoritmos de grafo, no ML supervisado | Fuera de alcance explícito |
| Un lenguaje del arnés distinto de TypeScript/Node (incluida la vía JVM) | Decisión de stack ya cerrada en la semilla: un instinto a la vez, el arnés no debe competir por atención con el modelo de grafo | Vía JVM vive solo en el Apéndice F 🔥 |
| Sharding, clustering o alta disponibilidad de Neo4j/Memgraph en producción | Es Community Edition en contenedor único; escalado horizontal es tema de otro nivel de curso | Se documenta como límite conocido, no se opera |
| Seguridad, autenticación y autorización a nivel de API | El curso no expone una API pública protegida; el foco es el modelo de acceso a los datos, no el borde de un sistema | Fuera de alcance |

> ⚠️ **Regla de oro del alcance.** Si una fase tienta con sumar algo de esta
> lista "porque quedaría bien", la respuesta por defecto es no: cada fase
> nueva de alcance es una fase menos dedicada a medir la curva de profundidad,
> que es la promesa central del curso.

## 3. Contra qué mercado real se valida (productizable: ✅ fuerte)

La detección de fraude por grafos no es un ejercicio de laboratorio inventado
para que el curso tenga tema: es un mercado activo y maduro. Plataformas
comerciales de *fraud analytics* (Neo4j mismo vende su caso de uso de fraude
como bandera comercial), equipos de riesgo en fintech y banca, y soluciones
de resolución de identidad usan exactamente los dos patrones que Telaraña
enseña —anillos de transferencias y señales indirectas de identidad
compartida— en producción, todos los días, sobre volúmenes bastante mayores
que el dataset sintético del curso.

Esto le da al proyecto dos propiedades que un ejercicio de juguete no tiene:

- **Contraparte de mercado verificable.** Lo que el lector construye —un
  detector de anillos y de identidades encubiertas, medido y defendido con
  números— es la versión pedagógica reducida de un producto que empresas
  reales venden hoy. El portafolio resultante tiene con qué compararse.
- **El villano también es real.** El error de modelar en grafo lo que un
  `JOIN` de dos tablas resuelve no es un caso inventado para completar la
  ruta: es exactamente el patrón que analistas de la industria señalan como
  el motivo #1 por el que un proyecto de "grafo para fraude" termina costando
  más de lo que aporta. Medirlo con el mismo rigor que el caso favorable es
  lo que separa a este curso del marketing de un vendor.

## 4. Árbol de decisión: cuándo NO usar esta familia (grafo)

Este árbol es el resumen operativo de la Fase 11 y debe poder citarse solo,
fuera de contexto, como una tarjeta de referencia rápida.

```
¿La pregunta central es "dado este nodo, qué alcanzo a profundidad
variable y desconocida" (caminos, ciclos, vecindarios, comunidades)?
│
├── NO — la pregunta es tabular: "cuántos", "cuál es el total",
│         "lista ordenada por columna", o un salto fijo de 1-2 niveles.
│         → NO uses grafo. Un relacional bien indexado (o incluso un
│           documento) resuelve esto más barato y sin sumar un motor
│           nuevo a la guardia. Este es exactamente el villano del curso.
│
└── SÍ — la profundidad del recorrido es variable y alta, o el patrón
    de la consulta ES el recorrido (ciclos, caminos, vecindarios densos).
    │
    ├── ¿El volumen y la latencia exigida caben en un CTE recursivo
    │    de Postgres bien indexado, medido?
    │   │
    │   ├── SÍ (profundidad baja, dataset chico, tolerancia de latencia
    │   │      alta) → el relacional sigue ganando; no pagues el peaje
    │   │      operativo de un motor de grafo todavía. Vuelve a medir
    │   │      cuando el dataset o la profundidad crezcan.
    │   │
    │   └── NO (la curva de la Fase 4 muestra que SQL colapsa a partir
    │        de cierto `k`, o el CTE se vuelve imposible de mantener)
    │        → aquí el grafo gana con evidencia. Sigue al siguiente nodo.
    │
    └── ¿Tu equipo puede sumar la guardia operativa de un motor de
         grafo (backup propio, monitoreo específico, curva de
         aprendizaje de Cypher)?
        │
        ├── NO → documenta el costo (como la Fase 10 con Neptune) y
        │        considera un motor de grafo **gestionado** para
        │        externalizar esa guardia, aceptando el costo monetario
        │        a cambio del operativo.
        │
        └── SÍ → usa grafo. Elige Neo4j si la persistencia en disco y
             el ecosistema (GDS, comunidad) importan más que la
             latencia mínima; elige un motor in-memory tipo Memgraph si
             la detección casi en tiempo real es el requisito duro y el
             dataset cabe en memoria con margen.
```

> 🩻 **Nota de honestidad.** Este árbol no tiene una rama de "el grafo
> siempre gana": esa rama no existe en el curso ni en la realidad. La
> ventaja del grafo es condicional a la profundidad del recorrido, y el
> curso entero está diseñado para que el lector aprenda a medir esa
> condición en vez de asumirla.

---

## 5. Relación con el resto de la ruta

Telaraña es el curso #4 de la Ruta NoSQL y no depende en lo técnico de los
cursos anteriores (Proteo/documental, Portalón, Cristalería), pero comparte
con todos ellos el mismo villano de fondo —usar el motor donde no toca— y el
mismo método de "vs" medido, nunca narrado. El curso #10 (El Árbitro), cierre
de la ruta, retoma a Telaraña como uno de los motores de la factura de
persistencia políglota; ninguna decisión de esta semilla debe asumirse
"aislada": el vocabulario de nodos, aristas y el dataset sintético de fraude
pueden reaparecer como referencia en ese cierre.
