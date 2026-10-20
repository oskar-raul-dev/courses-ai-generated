<?php
// server/routes/web.php — be03: el contrato entero, con la base detrás.
// La ruta de /templates con datos fijos de be01 se borra aquí: `git diff be-fase-01 be-fase-03` la enseña.

/** @var \Laravel\Lumen\Routing\Router $router */

$router->get('/health', 'HealthController@show');
$router->post('/auth/login', 'AuthController@login');

// Todo lo demás exige token. Es el requireToken() del mock.
$router->group(['middleware' => 'auth'], function ($router) {
    $router->get('/clients', 'ClientController@index');
    $router->get('/clients/{id}', 'ClientController@show');
    $router->post('/clients', 'ClientController@store');
    $router->put('/clients/{id}', 'ClientController@update');
    $router->delete('/clients/{id}', 'ClientController@destroy');

    $router->get('/assets', 'AssetController@index');
    $router->get('/assets/{id}', 'AssetController@show');
    $router->post('/assets', 'AssetController@store');
    $router->put('/assets/{id}', 'AssetController@update');

    $router->get('/templates', 'TemplateController@index');
    $router->get('/templates/{id}', 'TemplateController@show');
    $router->post('/templates', 'TemplateController@store');
    $router->put('/templates/{id}', 'TemplateController@update');

    $router->get('/inspections', 'InspectionController@index');
    $router->get('/inspections/{id}', 'InspectionController@show');
    $router->post('/inspections', 'InspectionController@store');
    $router->patch('/inspections/{id}', 'InspectionController@patch');
    $router->get('/inspections/{id}/findings', 'FindingController@byInspection');

    $router->get('/findings', 'FindingController@index');
    $router->post('/findings', 'FindingController@store');
    $router->patch('/findings/{id}', 'FindingController@patch');

    $router->get('/certificates', 'CertificateController@index');
    $router->get('/certificates/{id}', 'CertificateController@show');
    $router->post('/certificates', 'CertificateController@store');
    $router->patch('/certificates/{id}', 'CertificateController@patch');

    // ── Camino viejo, todavía vivo (be06: dos caminos). Ningún cliente nuevo lo usa;
    // el panel heredado y algún integrador sí. No se borra hasta que be07 decida.
    $router->get('/legacy/templates', 'LegacyTemplateController@index');

    // Parcela laravel, tal como estaba: sin validar, deja que la base decida.
    $router->post('/legacy/findings', function (\Illuminate\Http\Request $request) {
        return \App\Models\Finding::create($request->all());   // inspection_id inexistente → FK → 500
    });
});
