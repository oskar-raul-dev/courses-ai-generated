<?php

declare(strict_types=1);

namespace App\Http\Serializers;

use App\Models\Client;

class ClientSerializer
{
    /** @return array<string, mixed> */
    public static function toArray(Client $client): array
    {
        return [
            // (int) explícito: el driver de PostgreSQL devuelve los enteros como cadena.
            'id' => (int) $client->id,
            'legalName' => $client->legal_name,
            'taxId' => $client->tax_id,
        ];
    }
}
