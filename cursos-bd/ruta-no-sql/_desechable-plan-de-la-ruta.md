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
| R-02 | Historia | **Una empresa y un proyecto distintos por curso**, con su propio `00-historia-de-<empresa>.md`. Ninguno sigue con Cóndor, y ninguno usa las empresas que lite ya gastó: Cóndor, Voltaria, Cumbre Roja, Bengala, Barlovento, Nodo Sur, Rueda Viva. Usadas en la ruta: Mercado Ceibo (Proteo), Liga Pixel (Portalón), Pasaje (Cristalería), Valdivieso Abogados (Oráculo de Bolsillo), Quetzal Pay (Telaraña). | 06/10/2026 |
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
| 05 | Centinela de Flota | Columnar ancha | — | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| 06 | Buscafino | Búsqueda | — | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| 07 | Bitácora de Campo | Offline-first | — | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| 08 | El Vigía | Series temporales | — | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| 09 | Libro Mayor | NewSQL distribuido | — | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| 10 | El Árbitro | Políglota (cierre) | — | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |

> ⚠️ **Nombres que chocan con lite o con otros cursos y hay que mirar al llegar:** «Centinela de Flota»
> (lite es de flota aeronáutica: el nombre sugiere continuidad que R-02 niega) y «Libro Mayor» (la
> empresa de NewSQL no puede ser Barlovento, que lite ya usó para ese miniproyecto). El Árbitro cierra la
> ruta y quizá no lleve empresa propia, sino las de los otros diez: decidir en su E0.

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

### Los otros seis

```text
[ ] prompts/ creado y los cuatro documentos de agosto movidos como _desechable
[ ] E0: ficha de arranque confirmada
[ ] Empresa elegida (fuera de las de R-02)
[ ] 00-historia-de-<empresa>.md, primera versión
[ ] prompts/alcance-del-proyecto.md, primera versión
[ ] prompts/guia-de-estilo-y-convenciones.md, primera versión
[ ] prompts/README.md
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
