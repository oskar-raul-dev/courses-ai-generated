<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\MapsDatabaseErrors;
use App\Http\Controllers\Concerns\PaginatesLikeJsonServer;
use App\Http\Serializers\InspectionSerializer;
use App\Models\Inspection;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class InspectionController extends BaseController
{
    use PaginatesLikeJsonServer;
    use MapsDatabaseErrors;

    public function index(Request $request)
    {
        // Sin filtros: el frontend no los manda. Las respuestas viajan embebidas (deuda de be03).
        $query = Inspection::query()->orderBy('id');

        return $this->paginated($request, $query, [InspectionSerializer::class, 'toArray']);
    }

    public function show($id)
    {
        $inspection = $this->isId($id) ? Inspection::find((int) $id) : null;

        return $inspection === null ? $this->notFound() : response()->json(InspectionSerializer::toArray($inspection));
    }

    public function store(Request $request)
    {
        $inspection = new Inspection();
        $inspection->asset_id = $request->input('assetId');
        $inspection->inspector_id = $request->input('inspectorId');
        $inspection->template_id = $request->input('templateId');
        $inspection->template_version = (int) $request->input('templateVersion');
        $inspection->status = $request->input('status', 'scheduled');
        $inspection->started_at = $request->input('startedAt');
        $inspection->completed_at = $request->input('completedAt');
        $inspection->answers = $request->input('answers', []);

        return $this->persist(
            fn () => $inspection->save(),
            fn () => response()->json(InspectionSerializer::toArray($inspection), 201)
        );
    }

    /**
     * PATCH: sólo las columnas que llegan. `templateVersion` no está en la lista a propósito:
     * es el invariante, y ninguna escritura del frontend lo toca (be00 §5.3).
     */
    public function patch(Request $request, $id)
    {
        $inspection = $this->isId($id) ? Inspection::find((int) $id) : null;

        if ($inspection === null) {
            return $this->notFound();
        }

        if ($request->has('answers')) {
            $inspection->answers = $request->input('answers');
        }
        if ($request->has('status')) {
            $inspection->status = $request->input('status');
        }
        if ($request->has('completedAt')) {
            $inspection->completed_at = $request->input('completedAt');
        }
        if ($request->has('startedAt')) {
            $inspection->started_at = $request->input('startedAt');
        }

        return $this->persist(
            fn () => $inspection->save(),
            fn () => response()->json(InspectionSerializer::toArray($inspection))
        );
    }
}
