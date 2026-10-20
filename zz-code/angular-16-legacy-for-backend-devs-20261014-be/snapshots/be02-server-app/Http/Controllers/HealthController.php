<?php
// server/app/Http/Controllers/HealthController.php

declare(strict_types=1);

namespace App\Http\Controllers;

use Laravel\Lumen\Routing\Controller as BaseController;

class HealthController extends BaseController
{
    /**
     * Devuelve el estado del servicio. Es público a propósito: un endpoint de
     * salud que exige token no sirve para lo que sirve un endpoint de salud.
     *
     * @return array<string, string>
     */
    public function show(): array
    {
        // config() lee de config/chaos.php porque bootstrap/app.php lo registró
        // con $app->configure('chaos'). Sin esa línea, esto sería null.
        $faults = config('chaos.faults');

        return [
            'status' => 'ok',
            'php' => PHP_VERSION,
            // La constante la define el propio framework. Es la forma honesta
            // de responder "qué versión soy": la que reporta el código que corre,
            // no la que dice el composer.json.
            'lumen' => app()->version(),
            'chaos' => $faults === [] ? 'ninguno' : implode(',', $faults),
        ];
    }
}
