<?php
// server/bootstrap/app.php
// El arranque completo de la aplicación. Aquí se decide qué existe y qué no.

require_once __DIR__ . '/../vendor/autoload.php';

// Carga el .env. En Lumen esto es explícito: no hay magia que lo haga por ti.
(new Laravel\Lumen\Bootstrap\LoadEnvironmentVariables(
    dirname(__DIR__)
))->bootstrap();

$app = new Laravel\Lumen\Application(
    dirname(__DIR__)
);

// ── Las dos líneas más importantes del archivo ──────────────────────────────
// Con withFacades() encendido, Cache::get() y DB::table() existen. Apagado,
// lanzan "Class not found" — y ese es el bug 2 de §5.7.
// CertCore las tiene ASÍ desde 2016, y eso explica la mitad de las rarezas
// del código heredado: quien llegaba de Laravel se encontraba con que sus
// reflejos no compilaban, y resolvía cada uno a su manera.
// $app->withFacades();
// be03: Eloquent se enciende aquí. withFacades() sigue apagado (bea-03).
$app->withEloquent();

$app->singleton(
    Illuminate\Contracts\Debug\ExceptionHandler::class,
    App\Exceptions\Handler::class
);

$app->singleton(
    Illuminate\Contracts\Console\Kernel::class,
    App\Console\Kernel::class
);

// Sólo los archivos de config/ que registres aquí son legibles con config().
// Uno que exista en el directorio y no esté en esta lista devuelve null, sin
// advertencia. Es la primera trampa que se lleva a todo el mundo.
$app->configure('chaos');
$app->configure('database');

// Migraciones y seeds para `php artisan migrate` y `php artisan db:seed`.
$app->register(Illuminate\Database\MigrationServiceProvider::class);
// Lumen no enlaza la interfaz del repositorio de migraciones con su implementación; sin esto `migrate` no se construye.
$app->alias('migration.repository', Illuminate\Database\Migrations\MigrationRepositoryInterface::class);

// ── Middleware global: corre en TODA petición, en este orden ────────────────
$app->middleware([
    App\Http\Middleware\CorsMiddleware::class,
    App\Http\Middleware\ChaosMiddleware::class,
]);

// Middleware con nombre, que se aplica ruta por ruta. Vacío hasta be03, que es
// cuando vuelve a haber algo que proteger.
$app->routeMiddleware([
    'auth' => App\Http\Middleware\RequireToken::class,
]);

$app->router->group([
    'namespace' => 'App\Http\Controllers',
], function ($router) {
    require __DIR__ . '/../routes/web.php';
});

return $app;
