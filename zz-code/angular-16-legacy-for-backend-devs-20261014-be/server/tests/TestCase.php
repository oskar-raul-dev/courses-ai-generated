<?php

declare(strict_types=1);

use Laravel\Lumen\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    /** Arranca la MISMA aplicación que sirve las peticiones reales. */
    public function createApplication()
    {
        return require __DIR__ . '/../bootstrap/app.php';
    }

    /** Cabecera de autorización con un token firmado con el secreto de la app. */
    protected function authHeaders(): array
    {
        $now = time();
        $token = \Firebase\JWT\JWT::encode(
            ['sub' => 'INS-15', 'name' => 'Ana Restrepo', 'role' => 'inspector', 'iat' => $now, 'exp' => $now + 3600],
            \App\Http\Controllers\AuthController::SECRET,
            'HS256'
        );

        return ['HTTP_AUTHORIZATION' => 'Bearer ' . $token];
    }

    /** Petición JSON contra la aplicación real, con token. */
    protected function api(string $method, string $uri, array $body = [])
    {
        return $this->call($method, $uri, $body, [], [], $this->authHeaders() + ['CONTENT_TYPE' => 'application/json'], json_encode($body));
    }
}
