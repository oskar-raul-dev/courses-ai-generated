<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\MapsDatabaseErrors;
use App\Http\Controllers\Concerns\PaginatesLikeJsonServer;
use App\Http\Serializers\CertificateSerializer;
use App\Models\Certificate;
use App\Models\CertificateStatus;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

/**
 * Reemplaza al CertificateController de be02 (el estrato Cake con Active Record en el
 * controlador). El `status` se guarda y se devuelve tal cual: es la deuda 💸 2, y be05 la paga.
 */
class CertificateController extends BaseController
{
    use PaginatesLikeJsonServer;
    use MapsDatabaseErrors;

    public function index(Request $request)
    {
        // Lectura desde la vista: el estado se calcula al leer (be05 §5.4).
        $query = CertificateStatus::query();

        if ($request->has('inspectionId')) {
            $query->where('inspection_id', (int) $request->query('inspectionId'));
        }

        $query->orderBy('id');

        return $this->paginated($request, $query, [CertificateSerializer::class, 'toArray']);
    }

    public function show($id)
    {
        $certificate = CertificateStatus::find((string) $id);

        return $certificate === null ? $this->notFound() : response()->json(CertificateSerializer::toArray($certificate));
    }

    public function store(Request $request)
    {
        $certificate = new Certificate();
        $certificate->id = (string) $request->input('id');
        $certificate->inspection_id = (int) $request->input('inspectionId');
        $certificate->issued_at = $request->input('issuedAt');
        $certificate->valid_until = $request->input('validUntil');
        $certificate->status = $request->input('status', 'valid');
        $certificate->revoked_at = $request->input('revokedAt');

        return $this->persist(
            fn () => $certificate->save(),
            fn () => response()->json(CertificateSerializer::toArray($certificate), 201)
        );
    }

    public function patch(Request $request, $id)
    {
        $certificate = Certificate::find((string) $id);

        if ($certificate === null) {
            return $this->notFound();
        }

        // Revocar es poner una fecha (be00, CertificateApiService.revoke).
        $certificate->revoked_at = $request->input('revokedAt');
        $certificate->save();

        return response()->json(CertificateSerializer::toArray($certificate));
    }
}
