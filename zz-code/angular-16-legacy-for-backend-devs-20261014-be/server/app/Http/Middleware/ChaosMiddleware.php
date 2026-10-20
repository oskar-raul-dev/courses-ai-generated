<?php
// server/app/Http/Middleware/ChaosMiddleware.php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ChaosMiddleware
{
    /** @var string[] */
    private $faults;

    /** @var int */
    private $delayMs;

    /** @var bool */
    private $rolled;

    public function __construct()
    {
        $configured = config('chaos');

        $this->faults = $configured['faults'];
        $this->delayMs = $configured['delayMs'];
        // El dado se tira UNA vez por petición y se reutiliza, igual que en el
        // mock: si cada fallo tirara el suyo, con dos flags activos la mitad de
        // las peticiones saldría ilesa y el escenario dejaría de ser reproducible.
        $this->rolled = (mt_rand() / mt_getrandmax()) < $configured['rate'];
    }

    /**
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        // El caos no toca la autenticación. `expired` es la excepción y vive
        // donde se firma el token, no aquí.
        if (strpos($request->path(), 'auth/') === 0) {
            return $next($request);
        }

        if ($this->has('latency')) {
            // Incondicional, como en el mock: una latencia intermitente no se
            // distingue de un problema de red, y aquí queremos que se distinga.
            usleep($this->delayMs * 1000);
        }

        if ($this->has('timeout') && $this->rolled) {
            // Ni respondemos ni llamamos a $next. Lee la advertencia de abajo
            // antes de usar este modo: en PHP no sale gratis.
            while (true) {
                sleep(1);
            }
        }

        if ($this->has('error') && $this->rolled) {
            return response()->json(['message' => 'Fallo interno del servidor'], 500);
        }

        $response = $next($request);

        if ($this->has('malformed') && $this->rolled) {
            return $this->corrupt($response);
        }

        return $response;
    }

    private function has(string $fault): bool
    {
        return in_array($fault, $this->faults, true);
    }

    /**
     * Las dos mismas corrupciones del mock, y las dos son fallos reales de
     * despliegue: envolver un array en un objeto —el clásico cambio a respuesta
     * paginada que nadie avisó— y cambiar el tipo de un campo numérico.
     *
     * @param mixed $response
     * @return mixed
     */
    private function corrupt($response)
    {
        $body = json_decode($response->getContent(), true);

        if (is_array($body) && array_keys($body) === range(0, count($body) - 1)) {
            // Un array de lista, en el sentido de PHP: claves 0..n-1. La
            // comprobación es fea y es obligatoria, porque en PHP una lista y
            // un mapa son el mismo tipo (bea-01).
            return response()->json(['items' => $body, 'total' => count($body)]);
        }

        if (is_array($body) && isset($body['version']) && is_int($body['version'])) {
            $body['version'] = (string) $body['version'];

            return response()->json($body);
        }

        return $response;
    }
}
