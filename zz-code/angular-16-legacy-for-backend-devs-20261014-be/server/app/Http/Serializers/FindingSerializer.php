<?php

declare(strict_types=1);

namespace App\Http\Serializers;

use App\Models\Finding;

class FindingSerializer
{
    /** @return array<string, mixed> */
    public static function toArray(Finding $finding): array
    {
        return [
            'id' => (int) $finding->id,
            'inspectionId' => (int) $finding->inspection_id,
            'itemId' => $finding->item_id,
            'severity' => $finding->severity,
            'description' => $finding->description,
            'resolvedAt' => Instant::format($finding->resolved_at),
        ];
    }
}
