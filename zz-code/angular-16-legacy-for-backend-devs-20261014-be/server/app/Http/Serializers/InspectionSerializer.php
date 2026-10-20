<?php

declare(strict_types=1);

namespace App\Http\Serializers;

use App\Models\Inspection;

class InspectionSerializer
{
    /**
     * Las respuestas van embebidas: así lo devuelve el contrato y así lo espera el frontend.
     *
     * @return array<string, mixed>
     */
    public static function toArray(Inspection $inspection): array
    {
        return [
            'id' => (int) $inspection->id,
            'assetId' => $inspection->asset_id,
            'inspectorId' => $inspection->inspector_id,
            'templateId' => $inspection->template_id,
            'templateVersion' => (int) $inspection->template_version,
            'status' => $inspection->status,
            'startedAt' => Instant::format($inspection->started_at),
            'completedAt' => Instant::format($inspection->completed_at),
            'answers' => $inspection->answers ?? [],
        ];
    }
}
