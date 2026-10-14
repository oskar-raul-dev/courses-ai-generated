# 🗺️ Plan de la ruta — desechable
## Ruta NoSQL: once cursos, uno por familia

> **Qué es:** la hoja de ruta para llevar los once cursos de `ruta-no-sql/` al método de
> `zz-instrucciones/`: las decisiones que valen para todos y el checklist de preparación de cada uno.
> **Por qué existe fuera del framework:** `zz-instrucciones/` describe la producción de **un** curso;
> esto es una familia de once que comparten decisiones y orden. Es una excepción pedida por el autor
> el 06/10/2026, y por eso es desechable: no se cita desde ningún curso y se borra cuando el último
> tenga su propio plan de producción.
> **Creado:** 06/10/2026. **Al retomar:** leer §1, la fila del curso en §3 y su checklist en §4.

---

## 1. ⚖️ Decisiones de la ruta (valen para los once)

| ID | Decisión | Valor | Fecha |
|---|---|---|---|
| R-01 | Relación con Ruta NoSQL Lite | **Lite es prerrequisito.** Cada curso da por sabido lo que lite enseñó de su familia (las dos fases de la familia, el Bloque 0, el arnés, las cinco preguntas) y recorta ese alcance. Ningún curso repite el minicurso de lite: lo profundiza. | 06/10/2026 |
| R-02 | Historia | **Una empresa y un proyecto distintos por curso**, con su propio `00-historia-de-<empresa>.md`. Ninguno sigue con Cóndor, y ninguno usa las empresas que lite ya gastó: Cóndor, Voltaria, Cumbre Roja, Bengala, Barlovento, Nodo Sur, Rueda Viva. Usadas en la ruta: Mercado Ceibo (Proteo), Liga Pixel (Portalón), Pasaje (Cristalería), Valdivieso Abogados (Oráculo de Bolsillo), Quetzal Pay (Telaraña), Encomienda 305 (Rastro), Vacantia (Buscafino), La Cazuela (Comanda), Timbra (El Vigía), Kambio (Libro Mayor), Palco (El Árbitro). | 06/10/2026 |
| R-03 | Guía de estilo | **Una guía completa por curso**, desde la plantilla de `zz-instrucciones/` y la guía de lite como modelo; no una guía base con derivadas. | 06/10/2026 |
| R-04 | Documentos de agosto | Pasan al `prompts/` de su curso como `_desechable-semilla.md`, `_desechable-alcance-v1.md`, `_desechable-guia-de-estilo-v1.md` y `_desechable-prompts-v1.md`. **La semilla manda** como fuente de temario hasta que la propuesta de fases (E2) del curso se cierre; los otros tres son de consulta. | 06/10/2026 |
| R-05 | Orden de trabajo | Un curso por sesión, en el orden de §3. En cada uno: ficha de arranque (E0), alcance (E1) con **todas sus decisiones cerradas**, historia (primera versión) y guía, `prompts/README.md`. **Las propuestas de fases (E2) se discuten cuando los once tengan su `prompts/`**, curso por curso; con ellas se cierra la historia. | 06/10/2026 |
| R-06 | Valores por defecto heredados de lite | Curso completo; lector senior que ya hizo lite; TypeScript nativo en Node 24 para arnés y generador; pruebas en contenedor; código de las sesiones en `zz-code/` con README; Mermaid; 20–30 ejercicios por fase 🟢🟡🟠🔴 + 🔥. Cada curso puede cambiar cualquiera en su ficha. | 06/10/2026 |
| R-07 | Lite en lo publicado | Lo publicado nombra Ruta NoSQL Lite **solo como requisito de entrada** (README y primera fase): no usa su contenido, no remite a sus fases ni reutiliza sus ejemplos, datos o mediciones. `prompts/` sí puede citarla | 06/10/2026 |

**Abiertas para la ruta** (se deciden cuando aparezcan, no antes):

- **Qué pasa con los documentos de la raíz de la ruta:** `README.md`, `01-ruta-nosql.md` (la lista
  maestra), `02-ruta-nosql-fundamentos.md`, `guia-estilo-base-ruta-nosql.md` y `prompts-v1-deprecated/`.
  Con R-03 la guía base deja de ser madre: queda de consulta. Propuesta: moverlos a un
  `ruta-no-sql/_desechable-agosto/` cuando el tercer curso tenga su `prompts/`, y reescribir el README
  de la ruta al final (rehacerlo antes sería describir cursos que todavía no existen).
- **Laboratorio compartido o por curso.** Lite tiene un `compose.yaml` de diez motores; cada curso de la
  ruta tiene el suyo. Hoy cada uno decide en su alcance.
- **El orden de la §3**: es el de la lista maestra por progresión pedagógica, con Proteo primero porque
  ya estaba decidido. Se puede reordenar por mercado (Oráculo de Bolsillo y Bitácora de Campo primero).

---

## 2. 🧭 Cómo se prepara cada curso

1. **Mover lo viejo** (R-04) y crear `prompts/`.
2. **E0 · Ficha de arranque**, desde la semilla: la sesión propone los valores, pregunta lo que
   condiciona (empresa, profundidad, tamaño, rivales) y guarda `prompts/ficha-de-arranque.md`
   confirmada.
3. **Historia**: dos o tres empresas candidatas, el autor elige, y la sesión escribe la primera versión
   de `00-historia-de-<empresa>.md` en la raíz del curso. Los dolores van **por tema** de la semilla,
   no por número de fase: la numeración sale de E2.
4. **E1 · Alcance**: `prompts/alcance-del-proyecto.md` desde la plantilla, con el recorte de R-01 y las
   decisiones `D-xx`.
5. **Guía**: `prompts/guia-de-estilo-y-convenciones.md` completa (R-03), preliminar en lo que depende
   de E2 (plantilla de fase, longitudes), declarado en su sección de pendientes.
6. **`prompts/README.md`** con el estado.
7. **Después, en otras sesiones:** E2 (propuesta de fases y de apéndices), E3 (plan de producción, que
   reemplaza la fila del curso aquí), el resto de E4 (diccionario, contrato de nombres, plantillas de
   capítulo, verificador), E5 (prompts) y E6 (verificación previa).

---

## 3. 📋 Estado por curso

✅ hecho · 🟡 preliminar, a confirmar · ⬜ sin empezar

| # | Curso | Familia | Empresa | Ficha | Historia | Alcance | Guía | README de `prompts/` | E2 |
|---|---|---|---|---|---|---|---|---|---|
| 00 | Proteo | Documental | Mercado Ceibo | ✅ | 🟡 | ✅ | ✅ | ✅ | ⬜ |
| 01 | Portalón | Clave-valor | Liga Pixel | ✅ | 🟡 | ✅ | ✅ | ✅ | ⬜ |
| 02 | Cristalería | Analítico embebido | Pasaje | ✅ | 🟡 | ✅ | ✅ | ✅ | ⬜ |
| 03 | Oráculo de Bolsillo | Vectorial | Valdivieso Abogados | ✅ | 🟡 | ✅ | ✅ | ✅ | ⬜ |
| 04 | Telaraña | Grafos | Quetzal Pay | ✅ | 🟡 | ✅ | ✅ | ✅ | ⬜ |
| 05 | Rastro (antes Centinela de Flota) | Columnar ancha | Encomienda 305 | ✅ | 🟡 | ✅ | ✅ | ✅ | ⬜ |
| 06 | Buscafino | Búsqueda | Vacantia | ✅ | 🟡 | ✅ | ✅ | ✅ | ⬜ |
| 07 | Comanda (antes Bitácora de Campo) | Offline-first | La Cazuela | ✅ | 🟡 | ✅ | ✅ | ✅ | ⬜ |
| 08 | El Vigía | Series temporales | Timbra | ✅ | 🟡 | ✅ | ✅ | ✅ | ⬜ |
| 09 | Libro Mayor | NewSQL distribuido | Kambio | ✅ | 🟡 | ✅ | ✅ | ✅ | ⬜ |
| 10 | El Árbitro | Políglota (cierre) | Palco | ✅ | 🟡 | ✅ | ✅ | ✅ | ⬜ |

> ⚠️ **Nombres que chocan con lite o con otros cursos y hay que mirar al llegar:** «Centinela de Flota»
> ya se resolvió: el curso pasó a llamarse **Rastro** el 07/10/2026 (`05-rastro/`). «Bitácora de Campo» pasó a
> **Comanda** (`07-comanda/`) el mismo día, al cambiar el dominio a restaurantes (a confirmar por el autor).
> «Libro Mayor» se mantiene: su empresa es Kambio, no Barlovento. El Árbitro lleva empresa propia, Palco.
> **Todos resueltos.**

---

## 4. ✅ Checklist por curso

Se copia al empezar cada curso; se marca aquí mismo.

### 00 · Proteo

```text
[x] prompts/ creado y los cuatro documentos de agosto movidos como _desechable (06/10/2026)
[x] E0: ficha de arranque confirmada (06/10/2026)
[x] Empresa elegida: Mercado Ceibo (06/10/2026)
[x] 00-historia-de-mercado-ceibo.md, primera versión (06/10/2026)
[x] prompts/alcance-del-proyecto.md, primera versión (06/10/2026)
[x] prompts/guia-de-estilo-y-convenciones.md, primera versión (06/10/2026)
[x] prompts/README.md (06/10/2026)
[x] Alcance: las 25 decisiones cerradas por el autor (06/10/2026); guía cerrada salvo lo que depende de las fases
[ ] Historia: versión final, con cada dolor atado a su fase (con E2)
[ ] E2: propuesta de fases y de apéndices (cuando los once tengan prompts/)
[ ] E3: plan de producción; esta fila pasa a él
[ ] E4: diccionario, contrato de nombres, plantillas de capítulo, verificador
[ ] E5: prompts de fase y de apéndice
[ ] E6: verificación previa (versiones, libros, URL, laboratorio)
```

### 01 · Portalón

```text
[x] prompts/ creado y los cuatro documentos de agosto movidos como _desechable (06/10/2026)
[x] E0: ficha de arranque confirmada (06/10/2026)
[x] Empresa elegida: Liga Pixel (06/10/2026)
[x] 00-historia-de-liga-pixel.md, primera versión (06/10/2026)
[x] prompts/alcance-del-proyecto.md: 28 decisiones cerradas (06/10/2026)
[x] prompts/guia-de-estilo-y-convenciones.md, cerrada salvo lo que depende de las fases (06/10/2026)
[x] prompts/README.md (06/10/2026)
[ ] Historia: versión final, con cada dolor atado a su fase (con E2)
[ ] E2 a E6, como en Proteo
```

### 02 · Cristalería

```text
[x] prompts/ creado y los cuatro documentos de agosto movidos como _desechable (06/10/2026)
[x] E0: ficha de arranque confirmada (06/10/2026)
[x] Empresa elegida: Pasaje (06/10/2026)
[x] 00-historia-de-pasaje.md, primera versión (06/10/2026)
[x] prompts/alcance-del-proyecto.md: 30 decisiones cerradas (06/10/2026)
[x] prompts/guia-de-estilo-y-convenciones.md, cerrada salvo lo que depende de las fases (06/10/2026)
[x] prompts/README.md (06/10/2026)
[ ] Historia: versión final, con cada dolor atado a su fase (con E2)
[ ] Antes de E2: revisar el recorte contra las fases 07 y 08 de lite, si ya están escritas
[ ] E2 a E6, como en Proteo
```

### 03 · Oráculo de Bolsillo

```text
[x] prompts/ creado y los cuatro documentos de agosto movidos como _desechable (06/10/2026)
[x] E0: ficha de arranque confirmada (06/10/2026)
[x] Empresa elegida: Valdivieso Abogados (06/10/2026)
[x] 00-historia-de-valdivieso-abogados.md, primera versión (06/10/2026)
[x] prompts/alcance-del-proyecto.md: 32 decisiones cerradas (06/10/2026)
[x] prompts/guia-de-estilo-y-convenciones.md, cerrada salvo lo que depende de las fases (06/10/2026)
[x] prompts/README.md (06/10/2026)
[ ] Historia: versión final, con cada dolor atado a su fase (con E2)
[ ] E2 a E6, como en Proteo
```

### 04 · Telaraña

```text
[x] prompts/ creado y los cuatro documentos de agosto movidos como _desechable (06/10/2026)
[x] E0: ficha de arranque confirmada (06/10/2026)
[x] Empresa elegida: Quetzal Pay (06/10/2026)
[x] 00-historia-de-quetzal-pay.md, primera versión (06/10/2026)
[x] prompts/alcance-del-proyecto.md: 33 decisiones cerradas (06/10/2026)
[x] prompts/guia-de-estilo-y-convenciones.md, cerrada salvo lo que depende de las fases (06/10/2026)
[x] prompts/README.md (06/10/2026)
[ ] Historia: versión final, con cada dolor atado a su fase (con E2)
[ ] Antes de E2: revisar el recorte contra las fases 13 y 14 de lite, si ya están escritas
[ ] E2 a E6, como en Proteo
```

### 05 · Rastro (antes Centinela de Flota)

```text
[x] prompts/ creado y los cuatro documentos de agosto movidos como _desechable (07/10/2026)
[x] Directorio renombrado de 05-centinela-de-flota/ a 05-rastro/ (07/10/2026)
[x] E0: ficha de arranque confirmada (07/10/2026)
[x] Empresa elegida: Encomienda 305 (07/10/2026; dominio del autor, nombre propuesto por la sesión)
[x] 00-historia-de-encomienda-305.md, primera versión (07/10/2026)
[x] prompts/alcance-del-proyecto.md: 36 decisiones cerradas (07/10/2026)
[x] prompts/guia-de-estilo-y-convenciones.md, cerrada salvo lo que depende de las fases (07/10/2026)
[x] prompts/README.md (07/10/2026)
[ ] Historia: versión final, con cada dolor atado a su fase (con E2); confirmar el nombre de la empresa
[ ] Antes de E2: revisar el recorte contra las fases 17 y 18 de lite, y la frontera con El Vigía
[ ] E2 a E6, como en Proteo
```

### 06 · Buscafino

```text
[x] prompts/ creado y los cuatro documentos de agosto movidos como _desechable (07/10/2026)
[x] E0: ficha de arranque confirmada (07/10/2026)
[x] Empresa elegida: Vacantia (07/10/2026; dominio del autor, nombre y sede propuestos por la sesión)
[x] 00-historia-de-vacantia.md, primera versión (07/10/2026)
[x] prompts/alcance-del-proyecto.md: 36 decisiones cerradas (07/10/2026)
[x] prompts/guia-de-estilo-y-convenciones.md, cerrada salvo lo que depende de las fases (07/10/2026)
[x] prompts/README.md (07/10/2026)
[ ] Historia: versión final, con cada dolor atado a su fase (con E2); confirmar nombre y sede de la empresa
[ ] Antes de E2: revisar el recorte contra las fases 11 y 12 de lite, si ya están escritas
[ ] E2 a E6, como en Proteo
```

### 07 · Comanda (antes Bitácora de Campo)

```text
[x] prompts/ creado y los cuatro documentos de agosto movidos como _desechable (07/10/2026)
[x] Directorio renombrado de 07-bitacora-de-campo/ a 07-comanda/ (07/10/2026), a confirmar por el autor
[x] E0: ficha de arranque confirmada (07/10/2026)
[x] Empresa elegida: La Cazuela (07/10/2026; dominio del autor, nombre y gente propuestos por la sesión)
[x] 00-historia-de-la-cazuela.md, primera versión (07/10/2026)
[x] prompts/alcance-del-proyecto.md: 36 decisiones cerradas (07/10/2026)
[x] prompts/guia-de-estilo-y-convenciones.md, cerrada salvo lo que depende de las fases (07/10/2026)
[x] prompts/README.md (07/10/2026)
[ ] Historia: versión final, con cada dolor atado a su fase (con E2); confirmar el nombre de la empresa
[ ] Antes de E2: revisar el recorte contra las fases 19 y 20 de lite, si ya están escritas
[ ] E2 a E6, como en Proteo
```

### 08 · El Vigía

```text
[x] prompts/ creado y los cuatro documentos de agosto movidos como _desechable (07/10/2026)
[x] E0: ficha de arranque confirmada (07/10/2026)
[x] Empresa elegida: Timbra (07/10/2026; dominio del autor, nombre y gente propuestos por la sesión)
[x] 00-historia-de-timbra.md, primera versión (07/10/2026)
[x] prompts/alcance-del-proyecto.md: 36 decisiones cerradas (07/10/2026)
[x] prompts/guia-de-estilo-y-convenciones.md, cerrada salvo lo que depende de las fases (07/10/2026)
[x] prompts/README.md (07/10/2026)
[ ] Historia: versión final, con cada dolor atado a su fase (con E2); confirmar el nombre de la empresa
[ ] Antes de E2: revisar el recorte contra las fases 09 y 10 de lite, si ya están escritas
[ ] E2 a E6, como en Proteo
```

### 09 · Libro Mayor

```text
[x] prompts/ creado y los cuatro documentos de agosto movidos como _desechable (07/10/2026)
[x] E0: ficha de arranque confirmada (07/10/2026)
[x] Empresa elegida: Kambio (07/10/2026; dominio del autor, nombre y gente propuestos por la sesión)
[x] 00-historia-de-kambio.md, primera versión (07/10/2026)
[x] prompts/alcance-del-proyecto.md: 36 decisiones cerradas (07/10/2026)
[x] prompts/guia-de-estilo-y-convenciones.md, cerrada salvo lo que depende de las fases (07/10/2026)
[x] prompts/README.md (07/10/2026)
[ ] Historia: versión final, con cada dolor atado a su fase (con E2); confirmar el nombre de la empresa
[ ] Antes de E2: revisar el recorte contra las fases 21 y 22 de lite, si ya están escritas
[ ] E2 a E6, como en Proteo
```

### 10 · El Árbitro

```text
[x] prompts/ creado y los cuatro documentos de agosto movidos como _desechable (07/10/2026)
[x] E0: ficha de arranque confirmada (07/10/2026)
[x] Empresa elegida: Palco (07/10/2026; dominio del autor, nombre y gente propuestos por la sesión)
[x] 00-historia-de-palco.md, primera versión (07/10/2026)
[x] prompts/alcance-del-proyecto.md: 36 decisiones cerradas (07/10/2026)
[x] prompts/guia-de-estilo-y-convenciones.md, cerrada salvo lo que depende de las fases (07/10/2026)
[x] prompts/README.md (07/10/2026)
[ ] Historia: versión final, con cada dolor atado a su fase (con E2); confirmar el nombre de la empresa
[ ] Antes de E2: revisar el recorte contra las fases 23 a 25 de lite, si ya están escritas
[ ] E2 a E6, como en Proteo
```

---

## 5. 📓 Bitácora

**06/10/2026 · Arranque de la ruta y piloto con Proteo.** El autor fijó R-01 a R-05 (lite como
prerrequisito, una empresa por curso, guía completa por curso, lo viejo a `_desechable`, Proteo primero
y E2 en otra sesión). Proteo: empresa Mercado Ceibo; profundidad full geek (WiredTiger, oplog y replica
set, change streams reanudables, sharding medido); unas 100 h en 10–12 fases; rivales PostgreSQL (EAV y
JSONB), Couchbase y Amazon DocumentDB, este último solo desde documentación por costar dinero.
Ese mismo día el autor cerró las decisiones abiertas de Proteo: lite solo como requisito y sin usar su
contenido, que pasa a ser la regla R-07 de toda la ruta; Meilisearch; `BENCHMARKS.md` como documento vivo;
la liquidación como mini-servicio real; y el resto con el valor propuesto. En Proteo solo faltan la
propuesta de fases y la versión final de la historia.

**06/10/2026 · Portalón.** Empresa Liga Pixel (torneos de videojuegos, Ciudad de México y Bogotá; villano:
saldo de monedas e inventario en Redis; incidente: el failover de la final de la Copa Pixel Latam).
Full geek, ~100 h, rivales Redis 8, Dragonfly y Microsoft Garnet frente a Valkey, PostgreSQL de control;
**la coda en Java y Go queda fuera** (el autor no la marcó). Las decisiones que el autor no respondió se
cerraron con las reglas de ruta y los precedentes de Proteo, y se le listaron. **Siguiente:**
Cristalería (analítico embebido).

**06/10/2026 · Cristalería.** Empresa Pasaje (consultora de movilidad urbana de Quito; villano: el
warehouse gestionado y el Spark gestionado de 2021 respondiendo preguntas que caben en un proceso;
incidente: la semana del pasaje, con la plataforma suspendida por el tope de gasto, el tablero público
caído en la sesión del concejo y una muestra que subestimó los viajes estudiantiles). Full geek, ~100 h;
**Python con `uv` y TypeScript solo en el tablero**, primera divergencia de R-06 en la ruta; rivales
pandas 3, Polars, SQLite y PostgreSQL, y Spark de un nodo para el villano (el warehouse, solo
documentación ☁️). Decididas por defecto y listadas al autor: datos sintéticos en lugar de los datasets
públicos de la semilla, DuckLake para versionar, tablero de una vista, API mínima de comparación. El
recorte contra lite se hizo contra la propuesta de sus F07–F08, que aún no están escritas.
**Siguiente:** Oráculo de Bolsillo (vectorial).

**06/10/2026 · Oráculo de Bolsillo.** Empresa Valdivieso Abogados (estudio jurídico de Lima con oficina en
Arequipa; villano: el motor vectorial dedicado de 2024 con los permisos copiados al payload por un cron
nocturno; incidente: la semana de la casación, con una cita textual atribuida a la resolución equivocada
tras un reprocesamiento y un fragmento que cruzó una muralla ética 4 h 30 min después de levantada).
Full geek, ~100 h; TypeScript con Python solo en la ingesta y los modelos. pgvector titular;
pgvectorscale (DiskANN) y Qdrant como rivales; Pinecone solo documentación ☁️; **Weaviate y las codas
Java/C++ fuera** (el autor no los marcó). Generación con un modelo local en contenedor; nada sale del
estudio. Decididas por defecto y listadas al autor: corpus jurídico sintético (normas públicas reales solo
si la verificación previa confirma uso libre), embeddings y reranker locales multilingües, híbrido con
full-text de PostgreSQL y vectores dispersos de Qdrant sin extensiones BM25, y la regla de las dos
calidades (recall del índice frente a calidad de la recuperación, siempre por separado). El recorte se
hizo contra las fases 15 y 16 de lite, ya publicadas. **Siguiente:** Telaraña (grafos).

**06/10/2026 · Telaraña.** Empresa Quetzal Pay (billetera digital de Ciudad de Guatemala; villano: todo el
antifraude llevado a Neo4j en 2023, incluidas las 34 reglas de un salto que corren en cada pago con 300 ms
de presupuesto; incidente: la quincena de diciembre, con la búsqueda nocturna de anillos saturando el
servidor, el 38 % de los pagos aprobados sin antifraude durante 5 h 10 min y una red de 1.140 cuentas que
cobra referidos y retira Q 2,3 M). Full geek, ~100 h, TypeScript; rivales Memgraph, Apache AGE y
PostgreSQL con `WITH RECURSIVE`/`CYCLE`; Neptune ☁️; SQL/PGQ y GQL nombrados y medidos solo si hay
implementación libre en contenedor; algoritmos: el catálogo de fraude; **el apéndice 🔥 de la JVM entra,
en Kotlin**. Decididas por defecto y listadas al autor: edición comunitaria de Neo4j, solo GDS, APOC Core
y MAGE como plugins, conector simulado sin Kafka, el modelo de aristas decidido por medición, y la verdad
sembrada como primera medida. El recorte se hizo contra la propuesta de las F13–F14 de lite, aún sin
escribir. **Siguiente:** Centinela de Flota (columnar ancha); mirar antes el aviso de nombre de §3.

**07/10/2026 · Rastro (antes Centinela de Flota).** El autor dio el dominio: un courier de Miami con casilleros
virtuales que recibe compras de Estados Unidos, China y Europa y entrega en México, Panamá, Venezuela,
Colombia, Ecuador, Perú y Chile; y pidió renombrar el curso según el dominio. La sesión propuso **Rastro** y la
empresa **Encomienda 305** (el código de área de Miami), a confirmar con la historia final; el directorio pasó a
`05-rastro/`. Se dejó la telemetría de la semilla porque se pisa con la flota de lite y con El Vigía. Villano: la
plataforma de marca blanca entera en el mismo Cassandra que el rastreo (tarifas en seis tablas con lote sin
registro, saldo con contadores, consecutivo con transacción ligera, reportes con `ALLOW FILTERING`); incidente:
el Black Friday de 2025, con el rastreo sobreviviendo a cuarenta minutos sin enlace entre Doral y Bogotá.
Full geek, ~100 h; Cassandra, ScyllaDB (licencia por verificar) y PostgreSQL particionado; Bigtable, Keyspaces
y Astra ☁️. Decididas por defecto y listadas al autor: dos centros de datos simulados en la misma máquina,
compactaciones medidas, Accord solo si la versión estable lo trae, vistas materializadas solo en la fase de
tarifas, el reporte de Diana a una copia en PostgreSQL, sin PostgreSQL distribuido y sin codas.

**07/10/2026 · Buscafino.** El autor dio el dominio —un portal de empleo con ofertas por país y trabajo remoto de
otros países, al estilo de LinkedIn o Indeed— y eligió **OpenSearch como titular**. La sesión propuso
**Vacantia** (San José de Costa Rica, nueve países), a confirmar con la historia final. Se dejó el marketplace de
la semilla porque se pisa con Mercado Ceibo, con el catálogo de partes de lite y con Bengala. Villano: las
ofertas remotas de los feeds escritas directo al índice, y los destacados y el contador de postulaciones como
campos del documento; incidente: la cuesta de enero de 2026, con la reconstrucción "desde PostgreSQL" que pierde
lo que nunca estuvo ahí y una instantánea restaurada que devuelve currículos suprimidos. Full geek, ~100 h;
Elasticsearch solo donde difiere, Meilisearch y Typesense, PostgreSQL con ParadeDB; gestionados ☁️. Decididas
por defecto y listadas al autor: relevancia medida con juicios sembrados (nDCG@10, exhaustividad@100, MRR),
tres idiomas, búsqueda semántica y vectorial fuera, seguridad solo en la fase de currículos, supresión medida
hasta las instantáneas. Como lite ya cierra con "índice, no fuente de verdad", Buscafino lo da por sabido y mide
lo que viene después. **Pendiente de ruta:** `01-ruta-nosql.md` y `02-ruta-nosql-fundamentos.md` todavía dicen
«Centinela de Flota» y describen los dominios de agosto; se resuelve con la abierta de los documentos de la
raíz. **Siguiente:** Bitácora de Campo (offline-first), que en la sesión siguiente pasó a ser Comanda.

**07/10/2026 · Comanda (antes Bitácora de Campo), El Vigía, Libro Mayor y El Árbitro.** El autor eligió los
cuatro dominios en una sola ronda; la sesión propuso nombres, ciudades y gente, a confirmar con las historias
finales, y cerró el resto de las decisiones por defecto (36 por curso).
**Comanda:** restaurantes y comandas en lugar de las inspecciones de la semilla, que se pisaban con el técnico de
Cóndor y con los extensionistas de Cumbre Roja. La Cazuela (cadena costeña de Barranquilla, 38 locales); villano: la
cola de cada tablet con el reloj de la tablet como árbitro y la cuenta reescrita entera; incidente: el sábado de
Carnaval de 2026. CouchDB y PouchDB, Automerge (agregado), Firestore en su emulador y ElectricSQL. **El curso se
renombró a Comanda** con el precedente de Rastro: lo confirma el autor.
**El Vigía:** observabilidad, como la semilla, en Timbra (facturación electrónica de Guadalajara, cinco países);
villano: una fila por petición en PostgreSQL, escrita dentro de la petición; incidente: el cierre de marzo de 2026.
InfluxDB 3 Core como principal si la verificación lo permite (si no, TimescaleDB), TimescaleDB, **Prometheus
agregado** por el dominio y MongoDB; el percentil del mes contra el exacto como medida central.
**Libro Mayor:** cuentas multimoneda para freelancers en Kambio (Montevideo; EE. UU., UE y Brasil con residencia);
villano: el falso dilema con sus dos caras construidas (PostgreSQL con réplica asíncrona y tres libros con sagas);
incidente: la caída de Virginia del 4 de junio de 2026. CockroachDB, YugabyteDB, TiDB; API con Express 5 en lugar del
Fastify de la semilla.
**El Árbitro:** empresa propia, Palco (boletería de Santiago; Chile, Perú y Colombia), en lugar de reutilizar las de
la ruta; villano: la arquitectura de seis motores de 2022; incidente: la preventa de Los Tiburones del Sur del 21 de
abril de 2026. El "vs" es de tres arquitecturas; la profundidad vive en la costura (captura de cambios real, tubería,
restore coherente, factura con método) y no en cada motor, porque el bloque V de lite ya es un cierre políglota. Lo
publicado puede decir que cierra la Ruta NoSQL sin citar los otros cursos (D-34).
**Con esto los once cursos tienen su `prompts/`**: según R-05, ya se pueden discutir las propuestas de fases (E2),
curso por curso. **Pendientes de ruta:** la abierta de los documentos de la raíz (`01-ruta-nosql.md` y
`02-ruta-nosql-fundamentos.md` todavía describen los nombres y los dominios de agosto), el orden de las E2, y
confirmar los dos renombres (Rastro y Comanda) y los nombres de empresa que propuso la sesión.
