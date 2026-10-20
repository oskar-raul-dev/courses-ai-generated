<?php
// server/app/Http/Controllers/AuthController.php

declare(strict_types=1);

namespace App\Http\Controllers;

use Firebase\JWT\JWT;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class AuthController extends BaseController
{
    // El mismo secreto de juguete que el mock, y por el mismo motivo: esto es
    // un laboratorio. Un secreto de verdad no vive en el repositorio — y esa
    // conversación, en serio, es de bea-08.
    public const SECRET = 'certcore-dev-secret';
    private const TTL_SECONDS = 3600;

    public function login(Request $request)
    {
        $user = \App\Models\User::where('email', $request->input('email'))->first();

        // password_verify contra el hash sembrado. El mock comparaba cadenas
        // en claro; ésta es la única mejora que esta fase se permite, y se
        // permite porque NO ES VISIBLE EN EL CONTRATO.
        if ($user === null || ! password_verify((string) $request->input('password'), $user->password_hash)) {
            // 401 CON cuerpo y con el mensaje en español, literal: la pantalla
            // de login lo muestra tal cual.
            return response()->json(['message' => 'Credenciales inválidas'], 401);
        }

        // El TTL negativo es el modo `expired` del inyector de caos: firma un
        // token que ya nació vencido. Vive aquí y no en el middleware, igual
        // que en el mock.
        $ttl = in_array('expired', config('chaos.faults'), true) ? -60 : self::TTL_SECONDS;

        $issuedAt = time();
        $payload = [
            'sub' => $user->id,
            'name' => $user->name,
            'role' => $user->role,
            'iat' => $issuedAt,
            'exp' => $issuedAt + $ttl,
        ];

        return response()->json([
            'accessToken' => JWT::encode($payload, self::SECRET, 'HS256'),
            // Redundante con el `exp` del token, y se manda igual porque el
            // mock lo mandaba y el cliente lo lee.
            'expiresIn' => $ttl,
        ]);
    }
}
