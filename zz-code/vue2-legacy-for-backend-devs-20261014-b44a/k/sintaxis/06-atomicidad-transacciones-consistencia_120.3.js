var __a = [
$push:     { history: {...} }                  // append al array
$push:     { recent: { $each: [x], $slice: -3 } }  // append + poda (subset F3)
$pull:     { tags: "obsoleto" }                // remover por valor/condición
$addToSet: { tags: "hardware" }                // push sin duplicar
"history.0.by"                                  // dot-notation a un índice
$ /  $[]  /  $[elem]                            // el matcheado / todos / filtrados
];