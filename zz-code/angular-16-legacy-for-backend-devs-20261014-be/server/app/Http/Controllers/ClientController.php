<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\MapsDatabaseErrors;
use App\Http\Controllers\Concerns\PaginatesLikeJsonServer;
use App\Http\Serializers\ClientSerializer;
use App\Models\Client;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class ClientController extends BaseController
{
    use PaginatesLikeJsonServer;
    use MapsDatabaseErrors;

    public function index(Request $request)
    {
        $query = Client::query();

        // ?q= busca en todos los campos, como el full-text de json-server (be00 §5.3).
        if ($request->has('q')) {
            $term = '%' . $request->query('q') . '%';

            $query->where(function ($inner) use ($term) {
                $inner->where('legal_name', 'ILIKE', $term)->orWhere('tax_id', 'ILIKE', $term);
            });
        }

        // ?taxId= es la comprobación de NIT repetido del formulario.
        if ($request->has('taxId')) {
            $query->where('tax_id', $request->query('taxId'));
        }

        $query->orderBy('id');

        return $this->paginated($request, $query, [ClientSerializer::class, 'toArray']);
    }

    public function show($id)
    {
        $client = $this->isId($id) ? Client::find((int) $id) : null;

        return $client === null ? $this->notFound() : response()->json(ClientSerializer::toArray($client));
    }

    public function store(Request $request)
    {
        $client = new Client();
        $client->legal_name = $request->input('legalName');
        $client->tax_id = $request->input('taxId');

        return $this->persist(
            fn () => $client->save(),
            fn () => response()->json(ClientSerializer::toArray($client), 201)
        );
    }

    public function update(Request $request, $id)
    {
        $client = $this->isId($id) ? Client::find((int) $id) : null;

        if ($client === null) {
            return $this->notFound();
        }

        $client->legal_name = $request->input('legalName', $client->legal_name);
        $client->tax_id = $request->input('taxId', $client->tax_id);

        return $this->persist(
            fn () => $client->save(),
            fn () => response()->json(ClientSerializer::toArray($client))
        );
    }

    public function destroy($id)
    {
        $client = $this->isId($id) ? Client::find((int) $id) : null;

        if ($client === null) {
            return $this->notFound();
        }

        return $this->persist(
            fn () => $client->delete(),
            fn () => response()->json(new \stdClass())
        );
    }
}
