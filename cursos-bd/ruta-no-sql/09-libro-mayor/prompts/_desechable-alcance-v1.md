# 🗺️ Alcance — Proyecto Libro Mayor (NewSQL / distribuido con ACID)

> Deriva de `09-libro-mayor-semilla.md`. Ante cualquier conflicto, gana la
> semilla; este documento solo despliega su alcance en forma consultable.

## 1. Qué construye el curso

Un **ledger de contabilidad por partida doble multi-región** para una
plataforma de pagos ficticia con presencia en América del Norte, Europa y
América del Sur, junto con el **arnés de medición** que sostiene cada
afirmación del curso. Concretamente, al final del curso existe:

- Un esquema de partida doble (`accounts`, `transfers`, `postings`) con dinero
  en enteros de unidad mínima, invariantes declarativas (suma de `postings` =
  0, saldo ≥ límite) e inmutabilidad de asientos, corriendo **igual** —con las
  diferencias de dialecto documentadas— en CockroachDB, TiDB, YugabyteDB y
  Postgres.
- Una API HTTP delgada (Fastify) que expone transferencias, consulta de saldo
  y extracto histórico, y que existe solo para tener un cliente real contra el
  que medir, no como producto en sí mismo.
- Geo-partición real de las cuentas por `homeRegion`, con residencia de datos
  verificable (las cuentas europeas no salen de Europa) declarada en el
  esquema, no en la infraestructura.
- Un arnés (`scripts/vs.ts`) que ejecuta escenarios semánticos idénticos
  contra los cuatro motores y produce siempre las mismas métricas: p50/p95/p99,
  throughput, tasa de aborto, reintentos, errores por categoría.
- Un laboratorio de fallos con Toxiproxy: latencia inter-región inyectada,
  particiones de red limpias, muerte de nodos y de zonas completas, con
  medición de RPO/RTO reales.
- El patrón de mitigación de la **cuenta caliente** (saldo particionado,
  batching, cola con consolidación) medido antes y después.
- DDL en línea bajo carga (moneda nueva, columna nueva con backfill) con la
  disciplina de migración expandir-contraer.
- Dos artefactos acumulativos transversales: `INSTINTOS.md` (instintos
  relacionales puestos a prueba, con predicción numérica previa y veredicto) y
  `BENCHMARKS.md` (registro reproducible de todos los duelos).
- La autopsia medida del villano en sus tres caras (saga a mano, monolito con
  réplica asíncrona, CRUD de una región sobre un clúster de tres nodos) y un
  árbol de decisión final de cuándo **no** usar esta familia.

El resultado no es un producto de ledger listo para producción: es un
**laboratorio de decisión de arquitectura**, construido sobre un dominio lo
bastante real como para que las mediciones importen.

## 2. Qué queda fuera, y por qué

| Fuera de alcance | Por qué |
|---|---|
| Procesamiento de pagos real (redes de tarjeta, rieles bancarios, PCI-DSS) | El curso enseña el modelo de acceso de un ledger, no cómo integrar una pasarela de pagos. El dominio es un ledger *interno*, no un procesador. |
| Certificación regulatoria de residencia de datos (GDPR formal, auditoría externa) | Se implementa y se mide el mecanismo técnico de residencia; la conformidad legal real es responsabilidad de un equipo de cumplimiento, no un contenido enseñable con código. |
| UI de usuario final | La API es el único cliente. Una interfaz visual no aporta al patrón de acceso que el curso enseña y distraería presupuesto de las fases que sí importan (Fases 3–9). |
| Otros motores NewSQL (Vitess/PlanetScale, Google Spanner gestionado, Amazon Aurora DSQL) | Se nombran donde aporte contexto (Spanner en la Fase 6, como origen del linaje), pero no se implementan. Tres motores ya exigen ~16 GB de RAM en el laboratorio; un cuarto motor distribuido no añade una arquitectura nueva, añade peso. |
| Transacciones distribuidas *entre* motores heterogéneos (Postgres + Mongo + Redis a la vez) | Es exactamente el tema del curso 10, **El Árbitro**, que factura el costo de la persistencia políglota. Libro Mayor se queda dentro de la familia relacional distribuida. |
| Sharding manual sobre Postgres vanilla (Citus, particionado declarativo + FDW) como alternativa completa | Aparece mencionado como comparación conceptual donde ayude a entender el "porqué" de NewSQL, pero no se construye: es una arquitectura distinta con sus propios trade-offs, y mezclarla diluiría el eje del curso. |
| ORMs (Prisma, Drizzle, TypeORM) | El curso quiere que el lector vea el SQL y el plan distribuido sin una capa que los oculte. Los clientes son `pg` y `mysql2` directos. |
| Alta disponibilidad del *lado de la API* (múltiples réplicas de Fastify, balanceo, colas de mensajería) | Es infraestructura de aplicación estándar, no específica de este modelo de acceso; se asume una instancia de API por región y no se profundiza. |
| Optimización fina de costos de nube (dimensionamiento de instancias, reserva de capacidad) | El laboratorio corre en contenedores locales; el costo que importa aquí es el de *consenso*, medido en milisegundos y abortos, no en factura de proveedor. |

Estas exclusiones se declaran explícitamente en la Fase 0 del curso (sección
"Qué queda fuera por ahora" de la plantilla de fase) para que ningún lector
llegue esperando un producto de pagos terminado.

## 3. Contra qué mercado real se valida

**Productizable: media** (heredado tal cual de la semilla; no se infla el
veredicto).

Libro Mayor no es un producto B2C ni un SaaS que el curso termine publicando.
Su validación es indirecta pero concreta, apoyada en una categoría de mercado
real y activa:

- **Ledger-as-a-service y núcleos de contabilidad para fintech** —productos
  como Modern Treasury, TigerBeetle (motor de ledger open-source de propósito
  específico) o los núcleos internos de procesadores de pagos grandes— existen
  precisamente porque este problema (partida doble, corrección no negociable,
  latencia geográfica) es recurrente y caro de resolver mal.
- **Toda plataforma con dinero en custodia** —wallets, marketplaces con
  pagos diferidos a vendedores, plataformas de suscripción con prorrateo—
  termina construyendo *algo* con esta forma tarde o temprano, aunque no lo
  llame "ledger" el primer año.
- **Los tres motores del curso son productos reales con clientes reales en
  producción**, no proyectos de laboratorio: CockroachDB, TiDB y YugabyteDB
  tienen casos de uso publicados en banca, fintech y retail a escala. El
  curso no inventa un mercado; mide contra motores que ese mercado ya eligió.

El valor profesional que el curso entrega no es "publica tu propio ledger":
es que el lector pueda **auditar** un ledger ajeno con criterio técnico y
**defender con números** una decisión de arquitectura distribuida ante un
comité que hasta ahora solo escuchó argumentos sin medir —ni el de "distribuir
es peligroso" ni el contrario, igual de vacío.

## 4. Árbol de decisión: cuándo NO usar esta familia

Este árbol es el que el curso construye con sus propias mediciones en la
Fase 12 (`BENCHMARKS.md` + `INSTINTOS.md`), y se reproduce aquí para consulta
rápida antes de recomendar la tecnología en cualquier contexto:

1. **¿El negocio vive hoy, y previsiblemente durante los próximos 2–3 años,
   en una sola región geográfica y por debajo de lo que un nodo grande
   aguanta?**
   → **Sí:** usa Postgres (o el motor relacional que ya domines) en un nodo
   bien afinado, con réplicas de lectura si hace falta. NewSQL es
   sobre-ingeniería: pagas latencia de consenso en cada commit a cambio de
   nada. Este es el voto disidente 4-1 de la semilla, y se respeta.
   → **No, o "probablemente no" en el horizonte de planeación:** sigue.

2. **¿Las invariantes de negocio cruzan múltiples filas y deben sostenerse de
   forma atómica (no "eventual con reconciliación nocturna")?**
   → **No** (el dato es mayormente independiente fila a fila, tolera
   consistencia eventual real): considera un modelo NoSQL con transacciones de
   un solo documento o una arquitectura basada en eventos; probablemente no
   necesitas SQL distribuido con transacciones multi-fila.
   → **Sí:** sigue.

3. **¿Hay un requisito real —regulatorio o de latencia— de que ciertos datos
   vivan físicamente en una región concreta?**
   → **No:** un único clúster relacional con réplicas asíncronas bien
   monitoreadas y un runbook de failover probado puede alcanzar sin pagar la
   complejidad operativa de un clúster distribuido con consenso por fila.
   → **Sí:** el domicilio del dato es un requisito de producto, no un
   detalle de despliegue. NewSQL es un candidato serio.

4. **¿El equipo puede absorber el costo operativo de un clúster de tres o
   más nodos por motor (actualizaciones ordenadas, observabilidad de rangos
   calientes, backups y restauración distribuidos, guardia de una topología
   nueva)?**
   → **No, y no hay presupuesto para adquirir esa capacidad en el corto
   plazo:** documenta el riesgo y reconsidera el nodo único con
   particionamiento manual como paso intermedio, sabiendo que es una solución
   parcial.
   → **Sí:** NewSQL responde a las tres preguntas anteriores y el equipo
   puede operarlo. Es el terreno donde este curso mide una ventaja real.

5. **Pregunta de cierre, la más incómoda, y la que el curso no deja para el
   final por casualidad:** *¿de verdad no te alcanza con un Postgres bien
   afinado?* Si en algún punto de este árbol la respuesta honesta es "sí,
   alcanza", el veredicto correcto es usar Postgres y el curso lo dice sin que
   duela. El día que ese veredicto avergüence al curso, el curso se convirtió
   en aquello contra lo que fue escrito.
