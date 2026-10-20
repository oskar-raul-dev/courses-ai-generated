<?php

declare(strict_types=1);

namespace App\Http\Serializers;

use Illuminate\Database\Eloquent\Model;

class CertificateSerializer
{
    /**
     * `status` sale tal cual está guardado. No se deriva aquí: el contrato es así (be00, §5.2)
     * y la derivación es de be05.
     *
     * @return array<string, mixed>
     */
    public static function toArray(Model $certificate): array
    {
        return [
            'id' => $certificate->id,
            'inspectionId' => (int) $certificate->inspection_id,
            'issuedAt' => Instant::format($certificate->issued_at),
            'validUntil' => Instant::format($certificate->valid_until),
            'status' => $certificate->status,
            'revokedAt' => Instant::format($certificate->revoked_at),
        ];
    }
}
