<?php

declare(strict_types=1);

namespace App\Exceptions;

use Laravel\Lumen\Exceptions\Handler as ExceptionHandler;

// Manejador por defecto de Lumen. Sin personalizar: el reporte de errores va
// al log del contenedor, que es donde se mira en este track (bea-02).
class Handler extends ExceptionHandler
{
    protected $dontReport = [];
}
