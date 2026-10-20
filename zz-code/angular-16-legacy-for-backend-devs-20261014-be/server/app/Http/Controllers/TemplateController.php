<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\MapsDatabaseErrors;
use App\Http\Controllers\Concerns\PaginatesLikeJsonServer;
use App\Http\Serializers\TemplateSerializer;
use App\Models\Template;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

/**
 * Reemplaza al TemplateController de be02 (el estrato Symfony con repositorio que no se
 * ejecutaba). El fragmento de la lección es la base; lo que hay aquí es el contrato completo.
 */
class TemplateController extends BaseController
{
    use PaginatesLikeJsonServer;
    use MapsDatabaseErrors;

    public function index(Request $request)
    {
        $query = Template::query();

        // Filtros de igualdad exacta, combinados con AND (be00 §5.3).
        foreach (['templateId' => 'template_id', 'version' => 'version'] as $param => $column) {
            if ($request->has($param)) {
                $query->where($column, $request->query($param));
            }
        }

        // El orden que json-server no garantizaba y el frontend no ordena (trampa de be00).
        $query->orderBy('template_id')->orderBy('version');

        return $this->paginated($request, $query, [TemplateSerializer::class, 'toArray']);
    }

    public function show($id)
    {
        $template = $this->find($id);

        return $template === null ? $this->notFound() : response()->json(TemplateSerializer::toArray($template));
    }

    public function store(Request $request)
    {
        $template = new Template();
        $template->template_id = $request->input('templateId');
        $template->version = (int) $request->input('version');
        $template->valid_from = $request->input('validFrom');
        $template->valid_until = $request->input('validUntil');
        $template->items = $request->input('items', []);

        return $this->persist(
            fn () => $template->save(),
            fn () => response()->json(TemplateSerializer::toArray($template), 201)
        );
    }

    /**
     * PUT /templates/{id}: el cierre de una versión. El frontend manda la plantilla entera
     * con validUntil cambiado; sólo se cambian las columnas que el contrato permite tocar.
     */
    public function update(Request $request, $id)
    {
        $template = $this->find($id);

        if ($template === null) {
            return $this->notFound();
        }

        $template->valid_from = $request->input('validFrom', $template->valid_from);
        $template->valid_until = $request->input('validUntil', $template->valid_until);
        $template->items = $request->input('items', $template->items);

        return $this->persist(
            fn () => $template->save(),
            fn () => response()->json(TemplateSerializer::toArray($template))
        );
    }

    /**
     * El id compuesto "elevator-annual-v2" se descompone en (template_id, version). Un id que
     * no cuadra con ese patrón es un 404, no un 500.
     */
    private function find($id): ?Template
    {
        if (! preg_match('/^(.+)-v(\d+)$/', (string) $id, $parts)) {
            return null;
        }

        return Template::query()
            ->where('template_id', $parts[1])
            ->where('version', (int) $parts[2])
            ->first();
    }
}
