<?php
// server/app/Http/Middleware/CorsMiddleware.php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CorsMiddleware
{
    /**
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        $breakCors = in_array('cors', config('chaos.faults'), true);
        $isAuthRequest = strpos($request->path(), 'auth/') === 0;

        // El preflight se contesta aquí y se acaba: si lo dejas pasar, el caos
        // puede responderle un 500 y el navegador te va a contar un problema de
        // CORS que no existe.
        if ($request->getMethod() === 'OPTIONS') {
            $response = response('', 204);
        } else {
            $response = $next($request);
        }

        if (! $breakCors || $isAuthRequest) {
            // Las tres cabeceras son literalmente las del mock de la Fase 2.
            // X-Correlation-Id tiene que seguir en la lista: si desaparece, el
            // navegador rechaza la petición ANTES de enviarla y el error que
            // ves no menciona la cabecera.
            $response->headers->set('Access-Control-Allow-Origin', 'http://localhost:4200');
            $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Correlation-Id');
            $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
        }

        return $response;
    }
}
