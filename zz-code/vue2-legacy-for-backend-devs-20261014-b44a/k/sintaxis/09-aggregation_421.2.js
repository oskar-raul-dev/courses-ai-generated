var __o = {
// El esqueleto mental
[ $match(WHERE) → $group(GROUP BY) → $match(HAVING) → $sort → $limit ]

$group: { _id: "$campo" | {a:"$a",b:"$b"} | null,
          x: { $sum: 1 | "$campo" }, $avg, $min, $max,
          $push (array), $addToSet (DISTINCT), $first, $last }

$project / $addFields    // SELECT de expresiones / añadir sin quitar
$cond                    // CASE WHEN
$unwind                  // UNNEST del array embebido (la analítica de F3)
$facet                   // N análisis, 1 pasada (¡sin índices adentro!)
$count                   // azúcar de { $group: {_id:null, n:{$sum:1}} }
$bucket / $bucketAuto    // histogramas por rangos
$out / $merge            // materializar (replace / upsert incremental)

// Fechas: $subtract de dos dates → ms · $divide para unidades
// Reglas: $match/$sort primero (índices) · $ referencia, sin $ literal
//         100 MB/etapa → allowDiskUse · window functions: 5.0 (emular en 4.4)
};