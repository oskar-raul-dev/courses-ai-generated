# ⚰️ Fase 8 — La autopsia

## 🎯 Propósito

No hay teoría nueva. Hay un cadáver, un bisturí y tus cinco paradigmas.

`soporte_v1` — el "Postgres disfrazado" que conociste en la Fase 3, mediste
con `$lookup` en la Fase 5 e indexaste sin redención en la Fase 7 — recibe
hoy su rediseño completo: diagnóstico formal, modelo destino, migración con
todas las de la ley (dry-run, idempotencia, verificación) y la re-medición
final que cierra la tabla de la autopsia con el veredicto numérico
**antes/después**.

Esta fase es el examen práctico de las fases 3–7 y, no por casualidad,
**el ensayo general del trabajo real**: heredar una base traducida y tener
que decidir si se opera, cómo, y cómo se demuestra que valió la pena. Es
corto en lectura y largo en manos.

---

## ✅ Qué queda listo al terminar

- el diagnóstico formal de `soporte_v1` escrito con el vocabulario del curso
  (olores, cuadrantes, vetos);
- `soporte_v2`: el modelo destino diseñado y defendido decisión por decisión;
- la migración v1→v2 ejecutada: scripts numerados, idempotentes, con dry-run,
  verificación de conteos e integridad;
- la tabla de la autopsia **completa**: cada operación medida en v1 crudo /
  v1 indexado / v2 — el veredicto numérico del curso;
- `AUTOPSIA.md`: el informe que le entregarías a quien decide si se migra el
  sistema real.

## 🚫 Qué NO entra

- conceptos nuevos de Mongo — si algo te falta aquí, la fase de origen te
  espera;
- la migración "en caliente" con el sistema corriendo (estrategias en la
  Fase 14 — Operación; aquí migras con ventana);
- reescribir aplicación alguna: `soporte_v1` no tiene app — ese es su único
  acto de piedad contigo.

---

## 🧠 Conceptos mínimos

Ninguno nuevo, y es deliberado: esta fase no enseña, examina. Todo lo que
necesitas ya está en las Fases 3–7 (olores y cuadrantes en la 3, validators
en la 4, el costo del `$lookup` en la 5, atomicidad del documento en la 6,
plan de índices en la 7). Si algo se te resiste, la fase de origen te espera.
El método que sigue **es** la sección de implementación: un protocolo, no una
lección.

---

## 🔬 El método (el mismo de la vida real)

### 1. Diagnóstico — poner nombre a cada olor

Antes de tocar nada, el informe forense. Recorre `soporte_v1` con la lista de
la Fase 3 y documenta cada hallazgo con su evidencia:

| Olor | Evidencia en `soporte_v1` | Paradigma violado |
|---|---|---|
| Lookup-tables para enums | `statuses`, `priorities`, `roles` (≤10 docs, forma `{_id numérico, name}`) | #1 (modelado por normalización, no por acceso) |
| Cadenas de `*Id` | 5 referencias numéricas en `tickets` | #1, #3 (todo render une) |
| Historial en colección propia | `ticketHistory` separado de lo que "cambia junto" | #1, #4 (la transición pierde su atomicidad gratis) |
| Ningún documento se parece a su pantalla | el detalle requiere 6+ viajes o 4 lookups | #3 |
| Ids numéricos simulados | `_id: 1, 2, 3...` con la contención que la Fase 1 midió | #1 |

Tu `scripts/lookup-audit.js` (Fase 5, ej. 31) y el detector de "traducido,
no diseñado" (Fase 3, ej. 33) son las herramientas — esta vez sobre el
paciente definitivo.

### 2. El modelo destino — `soporte_v2`

Aplica las dos preguntas a cada relación, con los patrones de acceso que ya
conoces (dashboard, detalle, panel, búsqueda, transversal de auditoría). El
destino natural — que debes **derivar tú, no copiar** — se parece
sospechosamente a `minijira`: enums como strings validados (Fase 4),
usuario referenciado por username con la copia justificada si la hay
(referencia extendida, Fase 3/5), historial embebido con su atomicidad
(Fases 3/6), y el plan de índices derivado de las consultas (Fase 7).
Donde tu `soporte_v2` difiera de `minijira`, mejor: defiéndelo por escrito y
que ganen los números.

### 3. La migración — cirugía con protocolo

Scripts numerados en `scripts/autopsia/`, cada uno idempotente y con
`--dry`, en este orden lógico:

```
101-migrate-users.js       users: roleId → role string (resuelve la lookup-table)
102-migrate-tickets.js     tickets: 4 ids → valores/usernames; ids → ObjectId
                           (mapas de traducción como en el seed de la Fase 1,
                            ahora a escala 100k — cursor, lotes, watermark)
103-embed-history.js       ticketHistory → history embebido por ticket
                           (agrupar 300k entradas por ticket: tu primer uso
                            serio del $group que la Fase 9 formalizará — o
                            hazlo en Node con cursor + Map, decisión tuya)
104-migrate-comments.js    comments: ticketId/authorId retraducidos
105-verify.js              conteos cruzados, huérfanos, muestreo aleatorio
                           comparando N documentos v1 vs v2 campo a campo
106-indexes.js             el plan de índices de v2, con explain de verificación
```

Reglas del quirófano (todas ya tuyas): backup antes (Fase 0), dry-run
siempre (Fase 4), lotes con pausa para no ahogar (Fase 4, ej. 28),
verificación que falla ruidosamente (Fase 1), y el framework de migraciones
si hiciste el ej. 29 de la Fase 4 — este es su momento de gloria.

### 4. La re-medición — el veredicto

La tabla final de la autopsia, misma metodología de las Fases 5 y 7 (100
ejecuciones, promedio y p95):

| Operación | v1 crudo | v1 indexado (F7) | **v2** |
|---|---|---|---|
| Dashboard (20 legibles) | … | … | … |
| Detalle completo | … | … | … |
| Búsqueda `?q=` | … | … | … |
| Transversal (actividad de un agente) | … | … | … |
| Transición de estado (escritura + auditoría) | … | … | … |
| Tamaño total en disco + índices | … | … | … |

La última fila importa: v2 puede **pesar más** (denormalización, history
embebido). Si pasa, no lo escondas — es el precio pagado y el informe lo
declara junto a lo comprado.

### 5. El informe — `AUTOPSIA.md`

Una página ejecutiva + anexos. Estructura: qué estaba mal (olores con
evidencia) → qué se hizo (decisiones con alternativas) → qué costó
(horas-persona estimadas, ventana, disco) → qué se ganó (LA TABLA) → qué
riesgos quedan. Es el documento por el que un jefe aprueba o rechaza una
migración real — escríbelo para ese lector.

---

## 🧩 Chuleta de la fase

```
Diagnóstico → Destino → Migración → Verificación → Re-medición → Informe

El orden de los scripts sigue las DEPENDENCIAS de traducción:
  users primero (todos lo referencian) → tickets → embebidos → hijos

Toda migración: idempotente · --dry · lotes · verify que explota · backup

El veredicto es una TABLA, no un adjetivo.
Y si v2 pierde en algo (disco, transversal): se declara. La honestidad
del informe vale más que el marcador perfecto.
```

---

## ⚠️ Errores comunes

- Empezar a escribir scripts antes de terminar el diagnóstico y el destino
  (migrar sin saber a dónde: el pecado original de v1, reincidente).
- Migrar en orden equivocado y quedarte sin mapa de traducción para las
  referencias (users va primero por algo).
- Verificar solo conteos: 100k tickets migrados con el `status` corrido una
  posición pasan el conteo y son basura — el muestreo campo a campo existe
  por esto.
- Cargar los 300k historiales en memoria para agruparlos (el cursor y los
  lotes de la Fase 1/4 no eran decorativos).
- Re-medir con caché caliente en un caso y fría en otro: mismas condiciones
  o los números mienten.
- El informe triunfalista que omite lo que empeoró.

---

## 🧪 Ejercicios (30) — la autopsia ES los ejercicios

**🟢 El diagnóstico (1–7)**

1. Corre tus dos detectores (F3 ej. 33, F5 ej. 31) sobre `soporte_v1` y anexa sus salidas crudas a `AUTOPSIA.md`.
2. Completa la tabla de olores con evidencia verificable (consultas que cualquiera pueda re-ejecutar).
3. Censa las formas: ¿todos los documentos de cada colección tienen la misma estructura? (Ironía a documentar: el modelo traducido suele ser el ÚNICO consistente — rigidez sin motor que la aproveche.)
4. Cuantifica la lookup-table más absurda: bytes de `statuses` + su índice vs bytes que ocuparían los strings inline en 100k tickets. ¿La "normalización que ahorra espacio" ahorró espacio?
5. Lista los patrones de acceso reales (las 5 operaciones de la tabla final) y clasifica cada relación de v1 en los 4 cuadrantes. Este es el documento que v1 nunca tuvo.
6. Encuentra los huérfanos que v1 seguramente tiene (el generador los siembra): comentarios de tickets inexistentes, historial de tickets borrados. Conteo exacto. La "integridad" del modelo relacional sin motor relacional, fotografiada.
7. Estima la ventana: con tus números de la Fase 4 (ej. 28, lotes), proyecta cuánto tardará la migración completa. Escríbelo ANTES de migrar; compararás al final (ej. 27).

**🟡 El destino (8–13)**

8. Diseña `soporte_v2` colección por colección con el formato de decisión de `DATA-MODEL.md` (Fase 3): las dos preguntas, el veto físico, la alternativa considerada.
9. Decide el historial: ¿embebido completo, subset + colección, bucket? Los datos mandan: mide la distribución real de entradas por ticket en v1 (`$group` prestado o Node) y decide con el p99 en la mano.
10. Decide los huérfanos del ej. 6: ¿se migran (¿a dónde apuntan?), se archivan en una colección `_orphans`, se descartan con log? Política por escrito — en la vida real esta decisión tiene dueño de negocio; nómbralo.
11. Escribe los validators de v2 (Fase 4) ANTES de migrar: la migración debe producir documentos que pasen `strict` desde el primer insert. El validator como red del cirujano.
12. Diseña el plan de índices de v2 (Fase 7) a partir de las 5 operaciones — en papel, con la justificación ESR de cada uno. Se crean al final (script 106): ¿por qué no antes de la carga masiva? (Pista: tu instinto de DBA de cargas masivas ya lo sabe. 🩻)
13. Documenta las diferencias entre tu `soporte_v2` y `minijira` (si las hay) y defiéndelas. Si no las hay, defiende eso: ¿por qué dos análisis independientes convergen?

**🟠 La cirugía (14–22)**

14. `101-migrate-users.js`: roleId → string, ids → ObjectId, mapa persistido (¡a disco o colección `_maps`! — los scripts siguientes lo necesitan entre procesos).
15. `102-migrate-tickets.js` a escala: cursor + lotes de 1.000 + watermark reanudable (si muere a la mitad, retoma sin duplicar). Las 4 traducciones de ids en un solo paso.
16. `103-embed-history.js`: las 300k entradas agrupadas por ticket y embebidas ordenadas por fecha. Implementa las DOS variantes (aggregation con `$group`+`$push` / Node con cursor+Map), mide ambas, quédate con una y justifica.
17. `104-migrate-comments.js` con la política de huérfanos del ej. 10 aplicada y contada.
18. `105-verify.js` completo: conteos cruzados por colección, cero referencias rotas en v2, y muestreo aleatorio de 200 documentos comparados campo a campo contra su origen v1 (con las traducciones aplicadas). Debe salir con código ≠ 0 ante cualquier discrepancia.
19. Sabotea y demuestra: corrompe un mapa de traducción a propósito, re-corre 104 y confirma que 105 explota con un mensaje útil. La verificación que no has visto fallar no verifica nada.
20. Idempotencia bajo fuego: mata 102 a la mitad (`Ctrl+C`), re-lánzalo, y demuestra con 105 que el resultado es idéntico a una corrida limpia.
21. `106-indexes.js` con verificación explain integrada: el script falla si alguna de las 5 consultas no pega en su índice previsto.
22. El ensayo completo: `npm run autopsia` que encadena backup → 101…106 → verify, sobre una v1 recién regenerada. De cero a v2 verificada en un comando. Cronométralo y compara contra tu estimación del ej. 7.

**🔴 El veredicto (23–30)**

23. La tabla final: las 5 operaciones × 3 configuraciones (v1 crudo / v1 indexado / v2), 100 ejecuciones, promedio y p95, mismas condiciones de caché. La pieza central de `AUTOPSIA.md`.
24. La fila de disco: `db.stats()` de ambas bases, desglosado datos vs índices. Si v2 pesa más, calcula el precio por milisegundo ganado y escríbelo así de crudo.
25. La operación de escritura: transición de estado + auditoría en v1 (dos colecciones, carrera incluida — demuéstrala una vez más con el duelo de la Fase 6) vs v2 (un `updateOne` atómico). Mide latencia Y corrección bajo concurrencia. La fila que los benchmarks de lectura siempre olvidan.
26. Busca la victoria de v1: diseña la consulta donde el modelo normalizado GANA o empata (candidatas: actualizar el nombre de un estado global, una analítica rara sobre historial completo). Si la encuentras, a la tabla con honores; el informe honesto necesita saber qué se sacrificó.
27. Post-mortem de la estimación: tu proyección del ej. 7 vs la realidad del ej. 22. ¿Factor de error? Es el número que te hará creíble la próxima vez que estimes una migración delante de un jefe.
28. `AUTOPSIA.md` final: página ejecutiva + anexos, para el lector que decide. Prueba de fuego: dáselo a alguien (o léelo tú en frío mañana) y que pueda responder "¿migramos o no, y cuánto cuesta?" sin abrir otro archivo.
29. El giro final: te "informan" que el sistema real detrás de v1 NO puede tener ventana de migración (24/7). Esboza en una página la estrategia sin ventana con lo que ya sabes (doble escritura temporal + migración perezosa de la Fase 4 + reconciliación de la Fase 5 + corte final), y qué fase del curso cubre cada pieza. No la implementes: dimensiónala.
30. **La entrada de `INSTINTOS.md` que cierra el arco ⚰️:** relee tu entrada de la Fase 3 (la de la normalización) y escribe su epílogo con la tabla del ej. 23 delante: ¿qué le dirías hoy al autor de `soporte_v1`? Regla del ejercicio: sin sarcasmo — ese autor eras tú, hace cinco fases, haciendo lo que su motor anterior premiaba.

---

## 📚 Referencias

Sin lecturas nuevas: esta fase se hace con las referencias de las fases
3–7 abiertas. Dos relecturas rinden especialmente:

- 6 Rules of Thumb for MongoDB Schema Design — releída DESPUÉS de tu
  autopsia, es otra lectura: https://www.mongodb.com/blog/post/6-rules-of-thumb-for-mongodb-schema-design
- Building with Patterns: A Summary — ahora como checklist de lo que tu v2
  aplicó: https://www.mongodb.com/blog/post/building-with-patterns-a-summary

> ℹ️ **Nota de versión:** los dos artículos de blog son atemporales (no atan a
> una versión de Mongo); el resto del stack de esta fase sigue fijado en Mongo
> 4.4 / driver 3.6, como en las Fases 3–7.

**Orden de lectura sugerido:** releer *6 Rules of Thumb* ANTES de diseñar
`soporte_v2` (ej. 8) → usar *Building with Patterns* como checklist al cerrar
el destino (ej. 13) → *Schema Versioning* solo si encaras el ej. 29.

Y una pieza nueva solo si haces el ej. 29:

- Data Modeling — Schema Versioning + el patrón de migración incremental
  (Fase 4 del curso, y la Fase 14 — Operación para la migración sin ventana):
  https://www.mongodb.com/docs/v4.4/tutorial/model-data-for-schema-versioning/

---

## 🚀 Cierre

El villano está enterrado y documentado. Tienes el arco completo que la vida
real te pedirá: oler el modelo traducido (F3), medir su dolor (F5), agotarle
las excusas con índices (F7), rediseñarlo con criterio, migrarlo con
protocolo y **demostrar con una tabla** que la cirugía valió lo que costó —
incluida la honestidad de lo que empeoró.

La señal de que quedó bien:

> "me entregan mañana una base Mongo heredada y sé exactamente qué hacer las
> primeras dos semanas — y puedo defender el presupuesto de las siguientes
> ocho delante de quien firma".

**Siguiente parada:** 🧮 Fase 9 — Aggregation: tu GROUP BY con esteroides.
Llevas tres fases pidiendo prestadas etapas del pipeline (`$match`,
`$lookup`, el `$group` de la migración). Se acabó el préstamo: el arsenal
completo, en formato espejo contra tu SQL analítico — y con él, la lógica
del `GET /stats` que pagará la deuda de las métricas calculadas en el
navegador.

> 📝 **Nota de continuidad:** la deuda de `GET /stats` **no se paga aquí**. La
> autopsia no toca métricas: su entregable es `soporte_v2` migrada y medida.
> La lógica de `/stats` se escribe en la **Fase 9** (aggregation) y se expone
> como endpoint en la **Fase 10**. Si algún documento del curso fecha esta
> deuda en la Fase 8, es un error de ese documento, no de esta fase.
