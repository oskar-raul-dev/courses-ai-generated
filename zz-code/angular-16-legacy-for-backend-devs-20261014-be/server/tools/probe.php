<?php
// server/tools/probe.php — arranca la aplicación y evalúa una expresión.
//
//   docker compose exec api php tools/probe.php "get_class(app('cache'))"
//
// Existe porque en una capa con resolución dinámica la pregunta útil casi
// nunca es "qué dice el código", es "qué objeto hay aquí AHORA MISMO".

$app = require __DIR__ . '/../bootstrap/app.php';

// Sin una petición, Lumen no arranca sus proveedores de servicios. boot() los
// arranca a mano: sin esta línea, Eloquent no tiene resolutor de conexiones ni
// siquiera con withEloquent() encendido.
$app->boot();

$expression = $argv[1] ?? null;

if ($expression === null) {
    fwrite(STDERR, "Uso: php tools/probe.php \"<expresión PHP>\"\n");
    exit(1);
}

// eval() en una herramienta de laboratorio, que no se despliega y que sólo
// corre quien ya tiene una terminal dentro del contenedor. En cualquier otro
// sitio del proyecto esto sería una vulnerabilidad; bea-08 vuelve sobre la
// diferencia entre "peligroso" y "peligroso aquí".
$result = eval("return {$expression};");

var_dump($result);
