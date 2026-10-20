<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\MapsDatabaseErrors;
use App\Http\Controllers\Concerns\PaginatesLikeJsonServer;
use App\Http\Serializers\FindingSerializer;
use App\Models\Finding;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class FindingController extends BaseController
{
    use PaginatesLikeJsonServer;
    use MapsDatabaseErrors;

    public function index(Request $request)
    {
        // ?inspectionId= es lo que el frontend usa (FindingApiService.getByInspection).
        $query = Finding::query();

        if ($request->has('inspectionId')) {
            $query->where('inspection_id', (int) $request->query('inspectionId'));
        }

        $query->orderBy('id');

        return $this->paginated($request, $query, [FindingSerializer::class, 'toArray']);
    }

    /**
     * GET /inspections/{id}/findings. El frontend no la llama (InspectionApiService.getFindings
     * la define y no tiene llamador), pero smoke.sh la comprueba y el contrato la documenta.
     */
    public function byInspection($id)
    {
        if (! $this->isId($id)) {
            return response()->json([]);
        }

        $rows = Finding::query()->where('inspection_id', (int) $id)->orderBy('id')->get();

        return response()->json(array_values(array_map([FindingSerializer::class, 'toArray'], $rows->all())));
    }

    /**
     * POST /findings — camino nuevo (be06 §5.5). Valida antes de escribir y contesta 422
     * con el detalle. El mismo dato por /legacy/findings da 500: ése es el incidente be-11.
     */
    public function store(Request $request)
    {
        $this->validate($request, [
            'inspection_id' => 'required|exists:inspections,id',
            'item_id' => 'required',
            'severity' => 'required|in:critical,major,minor',
        ]);

        $finding = new Finding();
        $finding->inspection_id = (int) $request->input('inspection_id');
        $finding->item_id = $request->input('item_id');
        $finding->severity = $request->input('severity');
        $finding->description = (string) $request->input('description', '');

        return $this->persist(
            fn () => $finding->save(),
            fn () => response()->json(FindingSerializer::toArray($finding), 201)
        );
    }

    public function patch(Request $request, $id)
    {
        $finding = $this->isId($id) ? Finding::find((int) $id) : null;

        if ($finding === null) {
            return $this->notFound();
        }

        // Marcar resuelto es poner una fecha; deshacer es null (be00, FindingApiService).
        $finding->resolved_at = $request->input('resolvedAt');
        $finding->save();

        return response()->json(FindingSerializer::toArray($finding));
    }
}
