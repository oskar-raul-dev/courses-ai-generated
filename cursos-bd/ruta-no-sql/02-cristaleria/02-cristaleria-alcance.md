# 🦆 Cristalería — Alcance del proyecto

> Deriva de `02-cristaleria-semilla.md` y de las instrucciones de la Ruta
> NoSQL. Este documento fija **qué construye el curso, qué queda fuera a
> propósito, contra qué mercado real se valida, y cuándo la familia entera
> (analítico columnar embebido) no es la respuesta.** No repite la
> deliberación de la semilla; la traduce a límites operables para quien
> escriba las fases.

---

## 1. Qué construye el curso

Cristalería construye **un pipeline analítico de tres tramos**, todos sobre
datasets públicos reales en Parquet/CSV, sin proceso de carga previo:

1. **Consulta directa.** El motor (DuckDB) apunta al archivo donde está
   —local o remoto por HTTP/S3— y lo consulta en su formato de origen. Se
   mide cuánto del archivo se leyó de verdad frente a cuánto ocupa (el
   medidor de E/S). Es el gesto fundacional: nada de `CREATE TABLE` + `COPY`
   antes de poder preguntar algo.
2. **Transformación y materialización.** Cuando una consulta se repite, se
   proyecta, ordena y comprime un Parquet derivado, y se mide el
   antes/después en tamaño y latencia. Este tramo también cubre lo que pasa
   cuando el dato no entra en RAM (spilling/streaming).
3. **Publicación sin servidor.** El mismo motor, compilado a WebAssembly,
   corre **en la pestaña del usuario**. Un dashboard estático sirve los
   Parquet derivados como archivos planos; las consultas se ejecutan en el
   cliente. La prueba de fuego es publicarlo en un hosting estático y que un
   tercero lo use sin que exista servidor alguno.

Alrededor de los tres tramos, el curso construye el **arnés `vs`**
(`scripts/vs.ts` / `scripts/vs.py`) que mide cada duelo contra pandas,
Polars y SQLite con metodología reproducible (mismo dataset, misma máquina,
caché frío/caliente por separado), y los dos artefactos acumulativos
`INSTINTOS.md` y `BENCHMARKS.md`. La última fase disecciona el villano
—levantar un warehouse pesado o un clúster para lo que cabe en un
proceso— con la misma metodología, no con relato.

**Entregable final del estudiante:** un pipeline reproducible en contenedor
(datos → consulta directa → Parquet derivado → dashboard WASM publicado),
con su tabla de benchmarks propia y su veredicto escrito de cuándo el
modelo aplica y cuándo no.

---

## 2. Qué queda fuera a propósito

Cristalería es analítica embebida de un solo proceso, no una plataforma de
datos. Quedan explícitamente fuera del alcance del curso base (candidatos a
🔥 opcional cuando se marque así en una fase):

- **Orquestación de pipelines de datos** (Airflow, dbt, Dagster). El curso
  toca transformación y materialización, no scheduling ni linaje de datos
  como disciplina aparte.
- **Un data warehouse o clúster real en producción.** El villano se
  documenta con números defendibles y, si se levanta, es solo con una
  opción local sin costo cloud (ver decisión pendiente en la semilla). No es
  un curso de Spark, Snowflake, BigQuery ni Redshift.
- **Streaming e ingesta en tiempo real.** El dominio es de archivos
  inmutables (volcados que se reemplazan enteros), no de eventos continuos.
  CDC, Kafka o ingesta incremental no entran.
- **Concurrencia de escritura multi-usuario y control de acceso fino.** El
  modelo es de un proceso; no hay servidor multiusuario que administrar,
  y por lo tanto tampoco hay roles, permisos por fila ni locking
  transaccional que enseñar.
- **Machine learning y feature engineering avanzado.** DuckDB puede
  alimentar un pipeline de ML, pero el curso se detiene en la analítica
  descriptiva y el dashboard; no entra scikit-learn, entrenamiento de
  modelos ni feature stores.
- **Gobierno de datos, catálogo y linaje.** Nombrar "gestionar los archivos"
  como el costo operativo trasladado (ver semilla, §Costo operativo) es
  distinto de construir un catálogo de datos; el curso nombra el problema,
  no lo resuelve con tooling dedicado.
- **BI empresarial con UI de arrastrar-y-soltar.** El dashboard del curso es
  código (TS + DuckDB-Wasm), no una herramienta tipo Tableau/Power BI. El
  curso no enseña a operar una herramienta de terceros.
- **Multi-nodo o particionado distribuido de DuckDB.** DuckDB es
  fundamentalmente de un proceso; extensiones o forks distribuidos quedan
  fuera del alcance base y, si se mencionan, es solo para nombrar que
  existen y por qué el curso no los usa.

---

## 3. Contra qué mercado real se valida (productizable)

**Veredicto de la semilla: ✅ media-fuerte.** Cristalería no es un ejercicio
académico: cada tramo del pipeline compite con una categoría de producto
real y con un reflejo de arquitectura concreto.

| Tramo del curso | Compite de verdad contra | Por qué es una validación honesta |
|---|---|---|
| Consulta directa sobre Parquet/CSV | El reflejo de "primero cargo a un warehouse gestionado" (BigQuery, Snowflake, Redshift) para volúmenes que no lo necesitan | Es exactamente el error de arquitectura que el villano autopsia: pagar puesta en marcha, costo por consulta y latencia de red por algo que un proceso resuelve en segundos |
| Materialización de Parquet derivado | Herramientas de BI ligeras y ETL locales | Mismo problema (acelerar consultas repetidas) resuelto sin infraestructura adicional, con compresión y proyección como palancas explícitas |
| Dashboard WASM sin servidor | Dashboards que hoy exigen un backend de datos (API + base + hosting de servidor) | Es la pieza **más productizable** del curso: analítica publicada como sitio estático, con costo de operación cercano a cero — un diferenciador real frente a soluciones que cobran por consulta o por servidor encendido |
| El "vs" contra pandas/Polars | La decisión diaria de un equipo de datos: ¿SQL sobre archivos o pipeline de dataframe? | No es un duelo de marketing "base de datos contra base de datos": es la pregunta que un equipo real se hace cada vez que escribe una transformación |

**El techo honesto del rótulo "media" (no "fuerte").** Como producto
horizontal, analítica embebida es más una **capacidad** que un SaaS
vendible por sí solo: su valor se maximiza embebida dentro de un vertical
concreto (un panel dentro de una app, no una empresa de BI genérica). El
curso no promete que "montar esto" sea un negocio por sí mismo; promete que
es la pieza correcta para un problema de arquitectura concreto y frecuente.

---

## 4. Árbol de decisión: cuándo NO usar analítico columnar embebido

Este árbol es el contenido literal del ⚖️ veredicto honesto de la Fase 11 y
debe poder copiarse casi tal cual al cierre del curso. Se recorre en orden;
la primera rama que aplica gana.

1. **¿La carga de trabajo dominante es transaccional (muchas escrituras
   pequeñas, lecturas puntuales por fila)?**
   → Sí: no uses este modelo como base primaria. Es un motor por filas
   (relacional u OLTP) el que corresponde; DuckDB puede convivir como
   analítica secundaria sobre un export, no como sistema de registro.
2. **¿Necesitas concurrencia de escritura de muchos clientes al mismo
   tiempo, con control de acceso fino por fila o por columna?**
   → Sí: necesitas un servidor central compartido con su propio modelo de
   permisos. El modelo embebido es de un proceso; no hay noción de
   "conexión concurrente" que administrar del lado del servidor porque no
   hay servidor.
3. **¿El dataset no cabe, ni ordenado ni comprimido, en el disco de un solo
   nodo razonable?**
   → Sí: ahí sí hace falta un motor distribuido de verdad (Spark, un
   warehouse en la nube con particionado). El curso mide el límite de
   spilling/streaming en un proceso (Fase 7) precisamente para que esta
   frontera sea un número, no una sensación.
4. **¿La organización ya tiene decenas de analistas escribiendo SQL contra
   un warehouse gestionado, con gobierno de datos, linaje y SLA
   corporativos?**
   → Sí: reemplazar esa plataforma por procesos embebidos dispersos cambia
   un problema técnico por un problema organizacional (cada quien con su
   copia, sin catálogo, sin control de acceso central). El modelo embebido
   gana en el análisis exploratorio y en el borde de la aplicación, no
   necesariamente como reemplazo de la plataforma central.
5. **Ninguna de las anteriores, y la pregunta es agregación/analítica sobre
   archivos que caben en un proceso, con lectura que domina sobre
   escritura.**
   → Analítico columnar embebido gana, y probablemente gana con margen
   grande frente a levantar infraestructura pesada. Este es el terreno de
   Cristalería.

> ⚖️ El matiz que el curso mide en vez de afirmar: el **cruce en caliente
> entre datasets** (Fase 5) es donde un relacional bien indexado compite de
> verdad incluso dentro del terreno "ganador" de arriba. El árbol no
> reemplaza al arnés `vs`: lo resume.
