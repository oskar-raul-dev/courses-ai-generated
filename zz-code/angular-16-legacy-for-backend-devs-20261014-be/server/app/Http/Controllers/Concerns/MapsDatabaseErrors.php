<?php

declare(strict_types=1);

namespace App\Http\Controllers\Concerns;

use Illuminate\Database\QueryException;
use Illuminate\Http\JsonResponse;

/**
 * Traduce los dos errores de integridad que json-server no conocía a un 409.
 *
 * DECISIÓN DE be03: json-server, al borrar un cliente, borraba en cascada sus activos,
 * las plantillas y las inspecciones (medido en be00, CONTRACT.md §Trampas). PostgreSQL
 * no hace eso: rechaza el borrado si hay activos (clave foránea). Es un cambio de
 * comportamiento deliberado y se anota.
 */
trait MapsDatabaseErrors
{
    /**
     * Escribe dentro de una transacción (savepoint si ya hay una abierta) y responde. Así un
     * error de integridad deshace SÓLO la escritura y no envenena la transacción externa de las pruebas.
     */
    protected function persist(callable $write, callable $respond)
    {
        try {
            app('db')->transaction($write);
        } catch (QueryException $error) {
            return $this->integrityConflict($error);
        }

        return $respond();
    }

    protected function integrityConflict(QueryException $error): JsonResponse
    {
        $code = $error->errorInfo[0] ?? '';

        // El detalle de la base va al log del contenedor, no al cliente (bea-08): ahí
        // es donde se diagnostica (be-05), y en la respuesta sería información de más.
        error_log('integridad: ' . $error->getMessage());

        if ($code === '23505') {
            return response()->json(['message' => 'Ya existe un registro con esa clave'], 409);
        }

        if ($code === '23503') {
            return response()->json(['message' => 'La operación choca con una referencia a otro registro'], 409);
        }

        throw $error;
    }

    protected function notFound(): JsonResponse
    {
        // json-server devolvía {} con 404; el contrato lo documenta así.
        return response()->json(new \stdClass(), 404);
    }

    protected function isId($id): bool
    {
        return ctype_digit((string) $id);
    }
}
