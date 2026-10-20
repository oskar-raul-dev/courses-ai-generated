<?php

declare(strict_types=1);

namespace App\Http\Serializers;

use App\Models\Asset;

class AssetSerializer
{
    /** @return array<string, mixed> */
    public static function toArray(Asset $asset): array
    {
        return [
            'id' => $asset->id,
            'clientId' => (int) $asset->client_id,
            'type' => $asset->type,
            'description' => $asset->description,
            'installedAt' => $asset->installed_at,
        ];
    }
}
