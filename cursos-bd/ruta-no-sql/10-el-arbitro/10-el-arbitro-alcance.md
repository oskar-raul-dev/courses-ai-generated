# 🗺️ El Árbitro — Alcance del proyecto

> Curso 10 de la Ruta NoSQL. Cierre de ruta, no modelo número once: este
> documento fija qué construye Ágora, qué queda deliberadamente fuera, contra
> qué mercado real se valida el criterio que deja, y cuándo la arquitectura
> políglota que enseña **no** es la respuesta.

---

## 1. Qué construye el curso

Ágora es una plataforma de venta de entradas para eventos en vivo —conciertos,
teatro, deporte amateur, conferencias, ferias— construida como backend en
TypeScript sobre Node, contenerizada de punta a punta, con **una fuente de
verdad transaccional única** (PostgreSQL) y varios almacenes derivados
alimentados por una costura explícita (outbox → CDC con Debezium → Redpanda).

El curso entrega, al final de las trece fases:

- Un sistema funcional con siete patrones de acceso reales conviviendo:
  ficha de evento, aforo y reserva temporal, búsqueda facetada, ledger y
  liquidación, analítica, telemetría de puerta, afinidad entre asistentes.
- Un arnés de medición propio (`scripts/vs.ts`) que no se toca para
  alimentar cada "vs" del curso, y que produce `BENCHMARKS.md` con fecha,
  versión de motor y máquina en cada entrada.
- Una arquitectura final de **tres motores** (PostgreSQL, MongoDB, Valkey,
  más Meilisearch como índice derivado cuando la búsqueda lo justifica),
  defendida con números contra la alternativa de seis motores y contra el
  monolito Postgres.
- `INSTINTOS.md`, `BENCHMARKS.md` y `FACTURA.md` como artefactos
  acumulativos y reutilizables fuera del curso.
- Un árbol de decisión de cuándo sumar un motor y cuándo no, con la regla
  única que resume el curso: un motor nuevo entra solo si gana un orden de
  magnitud en un patrón que importa o elimina una clase entera de fallo —y
  solo después de nombrar por escrito quién lo opera, cuánto tarda su
  restore y cómo se detecta que se desincronizó.

### Lo que el curso enseña de verdad

No enseña a operar Mongo, ni a operar Valkey, ni a operar Meilisearch en
profundidad. Enseña a **decidir si un motor entra**, a construir la costura
que lo mantiene coherente con la fuente de verdad, y a medir la factura
operativa completa de esa decisión: backup, restore cronometrado, modos de
fallo, observabilidad, runbook, curva de aprendizaje del equipo. El objeto de
estudio real es la costura entre almacenes, no cada almacén por separado.

---

## 2. Qué queda fuera

Fuera del alcance de El Árbitro, explícitamente:

- **Profundidad operativa de cada motor individual.** Replicación avanzada
  de MongoDB, clustering de Valkey, tuning fino de Meilisearch: cada uno se
  toca lo justo para que la decisión de sumarlo o no esté bien fundada, no
  lo suficiente para certificar a nadie como administrador de ese motor.
  Quien busque eso tiene los cursos 1 a 9 de la ruta.
- **Nuevos modelos de acceso.** El curso no introduce grafo, series
  temporales ni ningún modelo que no haya aparecido ya en la ruta, salvo
  para construir y desmontar la arquitectura del villano en la Fase 11. Ahí
  aparecen solo para ser medidos y retirados, nunca para enseñarse en
  profundidad.
- **Sharding y multi-región.** Ágora se diseña para un solo nodo por motor
  (con réplicas de lectura donde aplique). Escalar horizontalmente cada
  motor es un problema real pero distinto del que el curso enseña, que es
  la coherencia *entre* motores, no la escala *dentro* de uno.
- **Seguridad, cumplimiento normativo y facturación fiscal reales.** El
  ledger de Ágora resiste una auditoría interna con invariantes duras, pero
  el curso no cubre PCI-DSS, retención fiscal por jurisdicción, ni
  integración con pasarelas de pago reales. Los pagos se simulan.
- **Frontend.** Ágora es un backend. No hay panel de organizador ni app de
  escaneo de puerta más allá de lo necesario para generar tráfico realista
  contra la API.
- **Un producto desplegable.** Ver §3: la salida de este curso es criterio
  con evidencia propia, no una plataforma de venta de entradas lista para
  vender.

---

## 3. Contra qué mercado real se valida (productizable ⚠️)

A diferencia del resto de la ruta, El Árbitro es honestamente ⚠️ **no
productizable como sistema**, y esa es una decisión de diseño, no una
debilidad disimulada. Vender Ágora como plataforma de ticketing sería
precisamente el tipo de decisión que el curso enseña a cuestionar: una
arquitectura construida para enseñar, no para operar en producción con
soporte real.

Lo que sí se valida contra el mercado real es la **decisión** que el curso
enseña a tomar, y ahí la validación es fuerte:

- Plataformas de venta de entradas reales (Ticketmaster, Eventbrite y
  similares) resuelven en producción exactamente la heterogeneidad de
  patrones que Ágora modela: catálogo con forma variable, contadores de
  aforo bajo contención extrema en la salida a la venta, búsqueda facetada,
  contabilidad con invariantes duras, analítica de negocio. Ninguna de esas
  plataformas resuelve todo eso en un solo motor, y ninguna suma motores sin
  medir el costo — o al menos ninguna que siga viva después del segundo
  incidente de guardia a las tres de la mañana.
- La arquitectura de outbox → CDC → consumidores idempotentes es el patrón
  de facto en sistemas de mediana y gran escala con más de un almacén de
  datos: es exactamente lo que resuelven herramientas como Debezium,
  Redpanda/Kafka Connect y los frameworks de *saga* en la industria.
- La tabla de factura operativa (`FACTURA.md`) es directamente reutilizable
  en el trabajo real: es la plantilla que alguien pone sobre la mesa la
  próxima vez que un equipo propone sumar un motor nuevo a un sistema que
  ya tiene dos o tres.

El curso no vende un producto. Vende el **criterio** para no comprar el
producto equivocado, y ese criterio sí tiene mercado: es el trabajo real de
cualquier arquitecto o ingeniero senior en un sistema de tamaño medio o
grande.

---

## 4. Árbol de decisión: cuándo NO usar esta familia (persistencia políglota)

Este árbol es un adelanto operativo del veredicto que la Fase 12 construye
con números; aquí se fija su forma para que el resto de los artefactos del
curso lo referencien sin contradecirlo.

**No sumes un motor nuevo si...**

1. **No mediste la alternativa de no sumarlo.** Si no existe un número de
   la implementación en el motor que ya tienes (aunque sea la línea base de
   la Fase 2), no hay decisión: hay preferencia. Medí primero.
2. **La ganancia es marginal.** Si el motor nuevo gana menos de un orden de
   magnitud en el patrón que te importa, la mejora casi nunca compensa la
   superficie operativa nueva. Un 30% más rápido no paga un backup nuevo,
   una guardia nueva y un modo de fallo nuevo.
3. **No sabés quién lo opera.** Si al proponer el motor no podés nombrar,
   por escrito, quién hace el backup, cuánto tarda el restore y cómo se
   entera el equipo de que el derivado se desincronizó, todavía no está
   listo para producción, sin importar cuán bien se vea en el benchmark.
4. **El dato que guardaría no es reconstruible.** Si el motor nuevo
   terminaría guardando información que no existe en ningún otro lado, dejó
   de ser un derivado: se convirtió en una segunda fuente de verdad sin que
   nadie lo haya decidido conscientemente. Esa es la señal más peligrosa del
   árbol, y la que el curso repite hasta que duele.
5. **El problema es de volumen, no de forma.** Si lo que te duele es que una
   tabla creció mucho, la respuesta casi siempre es particionar, indexar
   mejor o archivar — no sumar un motor. Un motor nuevo resuelve una
   *forma* de acceso distinta, no una tabla grande.
6. **Ya tenés tres motores y estás por sumar el cuarto "solo para esto".**
   Cada motor adicional multiplica combinatoriamente los pares que pueden
   desincronizarse entre sí. La pregunta en el cuarto motor no es "¿esto lo
   necesita?" sino "¿el sistema completo sigue siendo operable por el equipo
   que lo tiene hoy?".

**Sumá el motor si...** gana un orden de magnitud en un patrón que
verdaderamente importa al negocio, **o** elimina una clase entera de fallo
que hoy es recurrente — y en ambos casos, solo después de responder con
evidencia las cinco columnas de la ficha de factura (imagen y versión,
backup, restore cronometrado, modos de fallo, observabilidad, runbook,
consistencia, curva de aprendizaje).

Este árbol se aplica igual en las dos direcciones: contra quien suma motores
por moda sin nombrar la factura, y contra quien se niega a sumar el segundo
motor cuando la evidencia ya lo pide y tampoco puso número a nada. Ambos
pecados —crédulo y terco— se juzgan con la misma vara.

---

## 5. Relación con el resto de la ruta

El Árbitro no reemplaza ni compite con los cursos 0 a 9: los presupone.
Todos los patrones de acceso que aparecen en Ágora se explican desde cero,
sin asumir que el lector hizo la ruta completa, pero se explican **al
servicio de la decisión de integración**, no de la maestría en cada motor.
Alguien que llegue a este curso sin haber hecho el resto de la ruta puede
seguirlo; alguien que sí la hizo va a reconocer cada motor y va a poder
concentrarse enteramente en la costura, que es la novedad real.

⚠️ **Precaución heredada de la lista maestra:** en la Fase 4, "MongoDB" se
refiere siempre al motor documental del curso 0 (Proteo). Si en algún punto
del curso aparece cualquier motor de la familia Couch, se trata de
**CouchDB** (offline-first, curso 7) y nunca de Couchbase (rival documental
del curso 0). Esta distinción no aplica de forma directa a Ágora —que usa
MongoDB, no Couchbase ni CouchDB— pero se mantiene la alerta porque el error
de confundirlos es tentador y recurrente en toda la ruta.
