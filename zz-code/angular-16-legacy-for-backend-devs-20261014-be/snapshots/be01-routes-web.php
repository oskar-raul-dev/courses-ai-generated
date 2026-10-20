<?php
// server/routes/web.php
// Ojo con el instinto: aquí NO existe Route::get(), ni Route::resource(),
// ni Route::middleware()->group(). El router es una variable, no un facade.

/** @var \Laravel\Lumen\Routing\Router $router */

$router->get('/health', 'HealthController@show');

// Datos fijos hasta be03. La forma sale de CONTRACT.md, no de la imaginación:
// array desnudo, id compuesto, version numérica, validUntil null cuando la
// plantilla sigue vigente.
$router->get('/templates', function () {
    return [
        ['id' => 'elevator-annual-v1', 'templateId' => 'elevator-annual', 'version' => 1,
         'validFrom' => '2021-01-01', 'validUntil' => '2023-12-31', 'items' => []],
        ['id' => 'elevator-annual-v2', 'templateId' => 'elevator-annual', 'version' => 2,
         'validFrom' => '2024-01-01', 'validUntil' => null, 'items' => []],
        ['id' => 'boiler-annual-v1', 'templateId' => 'boiler-annual', 'version' => 1,
         'validFrom' => '2022-01-01', 'validUntil' => null, 'items' => []],
    ];
});
