<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Firebase\JWT\JWT;
use Illuminate\Http\Request;

/**
 * El equivalente de requireToken() del mock. Todo lo que no es /auth/ ni /health exige
 * un token firmado con el mismo secreto. El mensaje es el del mock, literal, porque el
 * frontend lo muestra.
 */
class RequireToken
{
    public function handle(Request $request, Closure $next)
    {
        $header = (string) $request->header('Authorization', '');

        if (strpos($header, 'Bearer ') !== 0) {
            return response()->json(['message' => 'Falta el token de acceso'], 401);
        }

        try {
            $request->attributes->set('user', JWT::decode(substr($header, 7), \App\Http\Controllers\AuthController::SECRET, ['HS256']));
        } catch (\Exception $error) {
            return response()->json(['message' => 'Token inválido o expirado'], 401);
        }

        return $next($request);
    }
}
