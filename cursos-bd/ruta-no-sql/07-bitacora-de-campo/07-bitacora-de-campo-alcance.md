# 🗺️ Alcance del proyecto — Bitácora de Campo

> Deriva de `07-bitacora-de-campo-semilla.md` y de `RUTA-NOSQL-FUNDAMENTOS.md`.
> Si algo entra en conflicto, gana la semilla.

---

## 1. Qué construye el curso

Bitácora de Campo construye, de punta a punta, **el núcleo técnico de una
plataforma de inspecciones de campo offline-first**: la app de un inspector
que se va sin señal durante horas, trabaja localmente y sincroniza al volver
a cobertura, incluyendo el caso normal (no la excepción) de que dos
dispositivos hayan escrito lo mismo sin poder coordinarse.

Concretamente, lo que queda en pie al cerrar el curso es:

- **Un servidor de replicación** (CouchDB) con la topología de sincronización
  del dominio: cada inspector sincroniza solo los sitios que tiene asignados,
  vía filtros de replicación, y `validate_doc_update` como última línea de
  validación que ningún cliente puede saltarse.
- **Un cliente local-first** (PouchDB) que escribe siempre al dispositivo
  primero, sin esperar red, con UI optimista real y validación de esquema
  (Zod) contra el `schema` del `inspectionType`, hecha **sin conexión**.
- **El modelo de datos documental** de la inspección como agregado
  autocontenido —formulario, hallazgos, adjuntos, geolocalización,
  metadatos de sincronización— que se crea, edita y replica como una sola
  pieza.
- **Un protocolo de conflicto de primera clase**: detección de revisiones
  divergentes (`_rev` como árbol, no como contador), y las tres estrategias
  reales de resolución —last-write-wins honesto con reloj lógico, merge
  campo-a-campo, e intervención humana— aplicadas al caso peliagudo del
  borrado-contra-edición.
- **Replicación de binarios** (fotos, firmas) como un problema aparte del
  JSON: checksums, deduplicación, y el bug clásico del adjunto huérfano.
- **Un arnés de medición** (`scripts/vs.ts`) que corre el mismo escenario de
  desconexión/reconexión contra los tres motores del "vs" y acumula números
  en `BENCHMARKS.md`, para que ningún veredicto del curso sea anecdótico.
- **Dos reconstrucciones comparativas completas** de la misma app: una sobre
  Firebase/Firestore (el rival gestionado) y otra sobre ElectricSQL +
  Postgres (el rival "no cambies de paradigma"), cada una medida en su propio
  terreno.
- **La autopsia medida del villano** (`campo_v1`, sync casero atornillado
  sobre Postgres) y el veredicto honesto de cuándo el modelo completo se
  justifica y cuándo no.

Lo que el estudiante se lleva no es "saber usar CouchDB": es el **instinto
recalibrado** para reconocer, en la fase de diseño, cuándo el conflicto de
escritura concurrente sin coordinación es parte del dominio —y no un caso
límite que se resuelve con una columna `version` y buenas intenciones.

---

## 2. Qué queda fuera por ahora

El curso traza un perímetro deliberado. Lo que sigue **no** se construye ni
se enseña aquí, salvo mención comparativa breve o como ejercicio 🔥 opcional:

| Queda fuera | Por qué |
|---|---|
| Apps móviles nativas de verdad (React Native, Flutter, Swift/Kotlin) | El laboratorio corre headless en Node con PouchDB `nodesqlite`; una demo de navegador es 🔥 opcional, un shell nativo no entra en el perímetro. El modelo de sync es el mismo con cualquier cliente. |
| Autenticación y autorización como sistema completo (OAuth, SSO, RBAC granular) | Se usa lo mínimo (Express + `validate_doc_update`) para que el filtro de replicación tenga sentido; no es un curso de auth. |
| UI/UX de producción, diseño visual, accesibilidad | El foco es el modelo de acceso y sincronización, no el frontend. Las pantallas del laboratorio son funcionales, no pulidas. |
| Operación de clúster CouchDB multi-nodo en producción (sharding, `mem3`, `_dbs` avanzado) | Es un curso de modelo de sincronización cliente↔servidor, no de topología de clúster distribuido a gran escala. Se menciona como límite del alcance en la Fase 8. |
| CRDTs como teoría general (más allá de lo que el curso necesita para explicar `_rev` y las estrategias de merge) | El curso enseña a *usar* resolución de conflictos con criterio, no a diseñar algoritmos CRDT desde cero. |
| Reglas de seguridad de Firestore como lenguaje completo, ni el resto del ecosistema Firebase (Auth, Functions, Hosting) | Firestore entra solo como rival medido del "vs" de sync; se usa lo justo para reconstruir la app y medir su comportamiento offline y su resolución por defecto. |
| ElectricSQL en su versión histórica bidireccional con CRDTs en cliente | Ya no es lo que el producto es en 2026; el curso mide **lo que ElectricSQL es hoy** (sync read-path unidireccional), no una versión retirada. |
| Analítica / BI sobre los datos sincronizados (dashboards, reportes agregados a gran escala) | Es consumo del dato ya sincronizado, un problema distinto del que enseña el curso. |
| Otras bases documentales offline-first del mercado (Realm/Atlas Device Sync, WatermelonDB, RxDB) | Se pueden nombrar en un aparte comparativo, pero no entran al arnés medido: el "vs" del curso se fija a los tres motores de la semilla para no diluir la medición. |
| Facturación, planes de precio o comparación económica detallada de servicios gestionados | Se discute el eje operar-vs-pagar de forma cualitativa (Fase 9), no un análisis de costos con cifras de mercado que quedarían desactualizadas. |

Todo lo anterior puede mencionarse como nota o como ejercicio 🔥, nunca como
núcleo de una fase.

---

## 3. Contra qué mercado real se valida (productizable: ✅ muy fuerte)

El dominio no es un ejercicio de vitrina: es reconocible como el núcleo
técnico de una categoría de producto que existe y se vende hoy. El curso se
ancla, sin inventar cifras ni nombres que deban verificarse en el momento de
publicar, a esta categoría:

- **Software de inspección de construcción y obra** (listas de verificación,
  hallazgos con severidad, fotos con geolocalización, firma en sitio).
- **Auditoría de seguridad industrial y cumplimiento normativo** en plantas,
  bodegas y sitios remotos sin cobertura confiable.
- **Gestión de activos en terreno** (mantenimiento, censos de equipos,
  relevamiento de infraestructura).
- **Censos y encuestas offline** para trabajo social, agropecuario o
  electoral en zonas sin red.
- **Ventas y logística de última milla** en rutas con cobertura intermitente.

> ⚠️ Al redactar las fases, cualquier nombre de producto comercial concreto
> de esta categoría que se use como referencia debe verificarse antes de
> publicarse (vigencia, si sigue en el mercado, si sigue usando el stack que
> se le atribuye). La categoría es estable; los nombres de marca no se fijan
> aquí para no arriesgar una afirmación desactualizada.

Lo que hace fuerte esta validación es que **la necesidad de negocio no es
"úsese CouchDB"**: es "este software tiene que funcionar sin señal, y el
conflicto de dos personas editando lo mismo offline tiene que resolverse sin
perder datos". Esa necesidad existe independientemente del motor elegido, y
es la misma pregunta que un equipo de producto real se hace antes de
evaluar CouchDB, Firestore o ElectricSQL. El graduado del curso sale con el
vocabulario y el instinto para participar en esa conversación, no solo con
la sintaxis de un SDK.

---

## 4. Árbol de decisión: cuándo NO usar esta familia

Este árbol es la mitad más importante del veredicto de la Fase 11: existe
para vacunar contra el riesgo pedagógico central del curso —salir
enamorado del modelo y llevarlo a todas partes, que es el villano en su
dirección inversa.

```
¿El dispositivo necesita seguir siendo útil y escribible
durante períodos sostenidos sin red (minutos-horas, como
jornada laboral normal, no como degradación ocasional)?
│
├── NO → no uses offline-first con conflicto de primera clase.
│        │
│        ├── ¿Solo necesitas lecturas siempre frescas sobre
│        │    una red mala, con las escrituras yendo directo
│        │    al backend? → considera ElectricSQL (sync
│        │    read-path) o un simple caché con revalidación.
│        │
│        └── ¿La red cae rara vez y por segundos, no por horas?
│             → un optimistic-UI con reintento y backoff
│             sobre tu backend relacional de siempre resuelve
│             el problema real sin montar un motor de
│             replicación multi-primaria.
│
└── SÍ → ¿el conflicto de escritura concurrente (dos nodos
         editando lo mismo sin coordinación) es real y
         frecuente en el dominio, no un caso de una vez al año?
         │
         ├── NO, es rarísimo y tolerable → una columna
         │    `version` con detección optimista y "el último
         │    en guardar avisa y pisa con confirmación humana"
         │    puede bastar. No pagues el costo operativo
         │    completo de un motor de replicación por un
         │    evento que casi no ocurre.
         │
         └── SÍ, el conflicto es esperable y frecuente →
              offline-first con resolución de conflicto de
              primera clase es la familia correcta. Ahora
              decide el motor con el "vs" medido:
              │
              ├── ¿Quieres operar tú mismo el motor de sync
              │    y necesitas ver el conflicto explícito
              │    (revisiones, no fusión mágica opaca)?
              │    → CouchDB + PouchDB.
              │
              ├── ¿Prefieres no operar el motor y aceptas su
              │    resolución por defecto y su costo
              │    tercerizado, sobre todo en móvil?
              │    → Firebase/Firestore.
              │
              └── ¿Tu equipo ya vive en Postgres y solo
                   necesita lecturas locales siempre frescas,
                   dejando las escrituras al backend de
                   siempre? → ElectricSQL — pero entiende que
                   esto NO resuelve el conflicto de escritura
                   offline concurrente por sí solo.
```

**Lectura honesta del árbol.** La rama de la izquierda es la más
subestimada de la ruta: la mayoría de los productos que "creen" necesitar
offline-first en realidad necesitan tolerancia a redes intermitentes de
segundos, no desconexión sostenida con conflicto real. Meter un motor de
replicación multi-primaria ahí es el mismo error que el villano de todo el
curso, en su versión inversa: usar el motor donde no toca, esta vez por
exceso de entusiasmo en lugar de por descuido.
