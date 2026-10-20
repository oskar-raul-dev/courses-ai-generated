<?php

declare(strict_types=1);

namespace App\Http\Serializers;

/**
 * Convierte un `timestamp` SIN zona de PostgreSQL al formato del contrato.
 *
 * DECISIÓN DE be03, y es la trampa más fina de la fase: la base no guarda el offset.
 * El 2016 escribió todo en hora local de Colombia (-05:00) en columnas sin zona, así
 * que el offset es fijo y se vuelve a poner aquí. Eso mantiene la forma del contrato
 * (smoke.sh: "los instantes llevan offset -05:00") y OCULTA la deuda 💸 4: un cliente
 * fuera de esa zona vería la misma hora. Se paga en be04 con TIMESTAMPTZ.
 */
class Instant
{
    private const OFFSET = '-05:00';

    public static function format($value): ?string
    {
        if ($value === null) {
            return null;
        }

        // El driver devuelve "2024-03-15 09:00:00"; el contrato quiere "2024-03-15T09:00:00-05:00".
        return str_replace(' ', 'T', substr((string) $value, 0, 19)) . self::OFFSET;
    }
}
