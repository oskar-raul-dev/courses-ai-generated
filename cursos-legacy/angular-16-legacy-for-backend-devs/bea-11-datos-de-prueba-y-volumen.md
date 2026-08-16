# 📎 Apéndice bea-11 — Datos de prueba y volumen

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **3 horas**
> Usado por: **be05** · Versiones cubiertas: PHP 7.4, PostgreSQL 16
> 🔥 **Opcional dentro del track opcional.** be05 se puede hacer sin generar volumen; lo que se pierde es poder medir.

**Esto no se lee de corrido.** Se entra buscando cómo generar datos que sirvan —o por qué los que generaste no sirven— y se sale con el generador y con la regla que lo hace utilizable.

**Qué problema resuelve:** conseguir **cuatro mil inspecciones creíbles** para que las mediciones de [`be05`](be05-la-invariante-que-no-sostenia-nadie.md) digan algo, **sin que los datos generados arruinen las pruebas**.

**Qué queda fuera:** la **anonimización de datos reales de clientes**. Es un dominio regulado: tomar datos de producción y "quitarles los nombres" no es anonimizar, y este apéndice no da receta. Si te lo plantean, la respuesta correcta es hablar con cumplimiento antes de copiar la primera fila.

---

## Índice

- [La regla que justifica el apéndice entero](#la-regla-que-justifica-el-apéndice-entero)
- [Las dos fuentes de datos del track, y no hay una tercera](#las-dos-fuentes-de-datos-del-track-y-no-hay-una-tercera)
- [Determinismo: la semilla fija](#determinismo-la-semilla-fija)
- [El generador de volumen de be05](#el-generador-de-volumen-de-be05)
- [Coherencia con el dominio, que es lo que lo vuelve utilizable](#coherencia-con-el-dominio-que-es-lo-que-lo-vuelve-utilizable)
- [Las violaciones sembradas a propósito](#las-violaciones-sembradas-a-propósito)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-7)

---

## La regla que justifica el apéndice entero

> 🧭 **Un dataset aleatorio arruina una prueba de regresión.**

Una prueba afirma algo concreto: *"esta consulta devuelve 88 filas"*, *"este endpoint tarda menos de 200 ms"*. Si los datos cambian en cada ejecución, la afirmación deja de ser comprobable: la prueba pasa unos días y falla otros, y el equipo aprende a ignorarla — que es peor que no tenerla.

De ahí sale la distinción que ordena todo lo demás:

| | Datos de **aserción** | Datos de **carga y medición** |
|---|---|---|
| Para qué | Comprobar que algo vale exactamente X | Ver cómo se comporta el sistema con volumen |
| De dónde salen | **El `db.json` del propio alumno**, fijo | Generados |
| Cuántos | Cinco inspecciones. Las que conoces | Cuatro mil, o cuarenta mil |
| ¿Pueden cambiar? | **No.** Cambiarlos cambia el significado de las pruebas | Sí, mientras la semilla quede anotada |
| ¿Los audita el `smoke.sh`? | **Sí** | **Nunca** |

> ⚠️ **El faker es una herramienta de carga y de medición, no de aserción.** En cuanto una prueba afirma algo sobre un dato generado, esa prueba ya no prueba nada.

---

## Las dos fuentes de datos del track, y no hay una tercera

**Fuente 1 — tu propio `mock/db.json`.** Es la semilla por defecto de todo el track, y por eso be03 insiste en sembrar desde ahí y no desde un volcado que venga con el curso. Que la inspección 501 sea la que llevas viendo desde la Fase 3 es la mitad del efecto: cuando algo se rompa, vas a reconocer el dato.

**Fuente 2 — el volumen sintético de be05.** Es la **única vez** en todo el track que se entregan datos ajenos, y la fase lo declara explícitamente. El motivo es que con cinco inspecciones no se mide nada: todos los planes son un recorrido secuencial, todos los tiempos son cero, y no se puede argumentar con eso delante de nadie.

No hay tercera fuente. En particular, **no hay datos de producción**, ni siquiera "anonimizados".

---

## Determinismo: la semilla fija

Todo generador de este apéndice recibe una semilla y la imprime. Sin eso, un hallazgo no es reproducible y un informe no es defendible.

```php
// La semilla se PASA y se IMPRIME. Las dos cosas.
$seed = (int) ($options['seed'] ?? 20240915);
mt_srand($seed);

fwrite(STDERR, sprintf("semilla %d — reproducible con --seed=%d\n", $seed, $seed));
```

Y las tres reglas que hacen que sirva de verdad:

1. **Misma semilla, mismos datos.** Si dos ejecuciones con la misma semilla dan resultados distintos, hay una fuente de azar sin sembrar — casi siempre `uniqid()`, `random_bytes()` o **la fecha actual**.
2. **Nada de `now()` dentro del generador.** Es la fuente de no-determinismo más común y la más difícil de ver: el dataset de hoy y el de mañana se parecen, pero las consultas que filtran por fecha devuelven números distintos. Usa una **fecha de referencia fija**, pasada como parámetro.
3. **La semilla se anota junto al resultado.** *"88 violaciones"* no significa nada; *"88 violaciones con `--seed=20240915` y `--inspections=4000`"* sí, y se puede volver a comprobar dentro de un año.

---

## El generador de volumen de be05

```php
<?php
// server/database/seeds/volume.php
//
//   docker compose exec api php database/seeds/volume.php \
//       --inspections=4000 --seed=20240915 --violations=88
//
// Genera inspecciones sintéticas RESPETANDO EL DOMINIO, con un número exacto de
// violaciones de la invariante sembradas a propósito. No toca ninguna colección
// que audite el smoke.sh: sólo añade filas a `inspections` y `findings`.

declare(strict_types=1);

$app = require __DIR__ . '/../../bootstrap/app.php';

$options = getopt('', ['inspections::', 'seed::', 'violations::', 'reference-date::']);

$count = (int) ($options['inspections'] ?? 4000);
$seed = (int) ($options['seed'] ?? 20240915);
$violations = (int) ($options['violations'] ?? 88);
// Fecha de referencia FIJA: sin ella, el dataset cambia de significado cada día.
$reference = new DateTimeImmutable($options['reference-date'] ?? '2024-09-15 00:00:00');

mt_srand($seed);

// Los activos y las plantillas NO se generan: son los de tu db.json. Sólo se
// genera el hecho repetitivo —la inspección—, que es lo único que en la vida
// real crece a miles.
$assets = DB::table('assets')->pluck('id')->all();
$templates = DB::table('templates')->get()->all();

// … el cuerpo completo del generador, con las reglas de dominio de abajo …

fwrite(STDERR, sprintf(
    "sembradas %d inspecciones (%d válidas, %d violando la invariante)\nsemilla %d, fecha de referencia %s\n",
    $count, $count - $violations, $violations, $seed, $reference->format('Y-m-d')
));
```

**Detalles con intención**

- **Sólo se genera `inspections` (y sus `findings`).** Clientes, activos y plantillas siguen siendo los tuyos: son pocos, los conoces, y generarlos destruiría el reconocimiento que hace útil el laboratorio.
- **El número de violaciones es un parámetro, no un accidente.** Un dataset donde no sabes cuántas violaciones hay no sirve para comprobar una consulta que las cuenta: no tendrías con qué comparar.
- **La fecha de referencia se pasa.** Así el dataset se puede regenerar dentro de un año y significar exactamente lo mismo.

---

## Coherencia con el dominio, que es lo que lo vuelve utilizable

Un generador que respeta los tipos y viola las reglas del negocio produce un dataset **peor que ninguno**: las consultas de be05 encontrarían violaciones falsas, y la fase entera mentiría.

Las reglas que el generador tiene que respetar, todas sacadas del track base:

- Una inspección `approved` **no puede tener hallazgos `critical` sin resolver**. Un `critical` abierto bloquea la aprobación: es la regla de la Fase 9.
- Un certificado sólo existe **sobre una inspección aprobada**. Nada de certificados colgando de inspecciones rechazadas.
- `completed_at` es **nulo** mientras el estado no sea `completed` o posterior, y **posterior** a `started_at` cuando existe.
- `template_version` tiene que ser **una versión que existía** en la fecha de la inspección… **salvo en las filas que se siembran como violación a propósito**, que son las únicas excepciones y están contadas.
- Las respuestas (`answers`) sólo contienen `itemId` que existan en esa versión de la plantilla, y sus valores salen de los `criteria` del ítem.
- Las fechas se reparten en un rango plausible —dos o tres años hacia atrás desde la fecha de referencia—, no todas el mismo día.

> 🧠 **Un dataset sintético es un modelo del dominio escrito en código.** Si el generador no puede respetar una regla, has encontrado una regla que el sistema tampoco sostiene — y eso es un hallazgo, no un problema del generador. En CertCore pasa exactamente con la invariante de plantillas.

---

## Las violaciones sembradas a propósito

Las 88 filas rotas de be05 no son azar: son el ejercicio.

```php
// Las N últimas inspecciones apuntan a una versión de plantilla que NO existe.
// Se concentran en un rango de fechas estrecho a propósito: reproducen el
// patrón real de "alguien publicó una versión, se usó, y después se borró".
$brokenWindowStart = $reference->modify('-18 months');

for ($i = 0; $i < $violations; $i++) {
    $startedAt = $brokenWindowStart->modify(sprintf('+%d days', mt_rand(0, 21)));

    $rows[] = [
        'template_id' => 'elevator-annual',
        // Versión 3: existió durante tres semanas y ya no está.
        'template_version' => 3,
        'status' => 'approved',      // aprobadas: el caso que de verdad duele
        'started_at' => $startedAt->format('Y-m-d H:i:s'),
        // …
    ];
}
```

Que estén **concentradas en tres semanas** y que estén **aprobadas** no es decoración: es lo que permite que el ejercicio de investigación de be05 §6 funcione —el `ORDER BY started_at` revela el rango, y el rango revela el evento—. Un dataset con violaciones repartidas al azar haría esa investigación imposible y, sobre todo, **falsa**: en la realidad, los datos corruptos se agrupan alrededor de un suceso.

---

## 🧭 Cuándo usar qué

| Necesitas… | Usa | Nunca |
|---|---|---|
| Comprobar que una consulta devuelve X | El `db.json` propio | Datos generados |
| Medir un tiempo o leer un `EXPLAIN` | Volumen sintético con semilla | Cinco filas |
| Reproducir un hallazgo dentro de un año | Semilla **y** fecha de referencia anotadas | `now()` en el generador |
| Probar el contrato (`smoke.sh`) | El `db.json` propio, sembrado limpio | Datos generados, **jamás** |
| Un caso límite concreto | Una fila escrita a mano, con nombre | Buscarla entre cuatro mil generadas |
| Volumen mayor para un experimento | El mismo generador con otro `--inspections` | Copiar el dataset y editarlo |

---

## ⚠️ Advertencias

**Los datos generados nunca entran en una colección que el `smoke.sh` audite.** Si lo hacen, el contrato deja de ser verificable: las comprobaciones que cuentan elementos o comparan valores empezarán a fallar por motivos que no tienen que ver con el contrato. El generador de este apéndice sólo añade `inspections` y `findings`, y las comprobaciones del `smoke.sh` que las tocan se escribieron con eso en mente.

**Antes de medir, di contra qué mides.** Un tiempo de respuesta sin la línea base de cinco filas (be03, ejercicio 19) no se puede interpretar. Guarda las dos mediciones siempre.

**Y el límite del laboratorio:** cuatro mil inspecciones en un contenedor de tu portátil no son cuatro mil en producción. El caché está caliente, no hay concurrencia, y el disco es el tuyo. Sirve para comparar **entre sí** dos consultas o dos versiones, no para prometer un número a nadie. Cuando lleves una medición de aquí a una conversación de be07, **di en qué condiciones se tomó**.

---

## 📚 Referencias

- https://www.php.net/manual/es/function.mt-srand.php — el generador sembrado de PHP. Léete la nota sobre qué cambió en PHP 7.1: la secuencia **no** es comparable con la de versiones anteriores.
- https://www.postgresql.org/docs/16/sql-explain.html — `EXPLAIN ANALYZE`, que es para lo que existe el volumen.
- https://www.postgresql.org/docs/16/populate.html — cómo cargar datos rápido: `COPY` frente a `INSERT`, índices después de la carga, y por qué sembrar cuatro mil filas de una en una tarda lo que tarda.
- https://www.postgresql.org/docs/16/sql-analyze.html — `ANALYZE`, que hay que correr **después** de sembrar: sin estadísticas frescas, el planificador toma decisiones basadas en una tabla que ya no existe.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos. Y si buscas librerías de datos falsos, comprueba la versión de PHP que piden: las actuales exigen PHP 8 y aquí el runtime es 7.4 — razón de más para que el generador de este track sean cuarenta líneas propias y ninguna dependencia.

---

## 🧪 Ejercicios (7)

1. Genera cuatro mil inspecciones con `--seed=20240915` dos veces, sobre bases limpias, y comprueba que los datos son idénticos. Si no lo son, encuentra la fuente de azar sin sembrar.
2. **Diagnóstico.** Quita la fecha de referencia y sustitúyela por `now()`. Genera hoy, y vuelve a generar cambiando la fecha del contenedor. Documenta qué consulta de be05 cambia de resultado y por qué es un problema.
3. Corre `ANALYZE` después de sembrar y compara el `EXPLAIN` de la consulta de violaciones antes y después. Anota los dos planes.
4. **Diagnóstico.** Genera un dataset que **viole el dominio** a propósito: certificados sobre inspecciones rechazadas. Después corre las consultas de be05 y explica exactamente qué conclusión falsa sacarías.
5. Cambia `--violations` a 0 y después a 400. Corre el censo de be05 en los dos casos y comprueba que el número coincide con el parámetro. Si no coincide, tu consulta o tu generador tienen un defecto: averigua cuál.
6. **Diagnóstico.** Siembra cuarenta mil inspecciones y repite las mediciones de be05. ¿Cambia alguna recomendación de la fase? ¿Cambia algún plan? Anota los tiempos de las dos escalas.
7. **Diagnóstico.** Comprueba la advertencia principal: mete datos generados en una colección que el `smoke.sh` audite y corre el juez. Anota qué comprobaciones caen y por qué **ninguna de esas caídas significa que el contrato esté roto**. Después revierte.

---

> 🏷️ **Este apéndice no lleva tag propio.** El generador que describe lo escribe be05, así que se commitea con su prefijo (`be05: …`). Lo que sí conviene es que **la semilla, el número de inspecciones y la fecha de referencia queden en el mensaje del tag de be05**: es lo único que hace reproducibles las mediciones de esa fase dentro de un año. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
