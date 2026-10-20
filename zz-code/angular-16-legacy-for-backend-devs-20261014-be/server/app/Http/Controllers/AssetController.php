<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\MapsDatabaseErrors;
use App\Http\Controllers\Concerns\PaginatesLikeJsonServer;
use App\Http\Serializers\AssetSerializer;
use App\Models\Asset;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class AssetController extends BaseController
{
    use PaginatesLikeJsonServer;
    use MapsDatabaseErrors;

    public function index(Request $request)
    {
        $query = Asset::query();

        // ?clientId= es igualdad exacta (be00 §5.3).
        if ($request->has('clientId')) {
            $query->where('client_id', (int) $request->query('clientId'));
        }

        $query->orderBy('id');

        return $this->paginated($request, $query, [AssetSerializer::class, 'toArray']);
    }

    public function show($id)
    {
        $asset = Asset::find((string) $id);

        return $asset === null ? $this->notFound() : response()->json(AssetSerializer::toArray($asset));
    }

    public function store(Request $request)
    {
        $asset = new Asset();
        // El id lo escribe el usuario ("ASC-CENTRAL-03"); no es serial.
        $asset->id = (string) $request->input('id');
        $asset->client_id = (int) $request->input('clientId');
        $asset->type = $request->input('type');
        $asset->description = $request->input('description');
        $asset->installed_at = $request->input('installedAt');

        return $this->persist(
            fn () => $asset->save(),
            fn () => response()->json(AssetSerializer::toArray($asset), 201)
        );
    }

    public function update(Request $request, $id)
    {
        $asset = Asset::find((string) $id);

        if ($asset === null) {
            return $this->notFound();
        }

        $asset->client_id = (int) $request->input('clientId', $asset->client_id);
        $asset->type = $request->input('type', $asset->type);
        $asset->description = $request->input('description', $asset->description);
        $asset->installed_at = $request->input('installedAt', $asset->installed_at);

        return $this->persist(
            fn () => $asset->save(),
            fn () => response()->json(AssetSerializer::toArray($asset))
        );
    }
}
