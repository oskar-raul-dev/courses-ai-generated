<?php
// server/app/Http/Controllers/TemplateController.php (fragmento)

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Template;
use App\Http\Serializers\TemplateSerializer;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class TemplateController extends BaseController
{
    public function index(Request $request)
    {
        $query = Template::query();

        // Filtros de igualdad exacta, combinados con AND. Son los cuatro
        // parámetros que el frontend usa de verdad; todo lo demás del
        // dialecto de json-server NO se implementa (be00 §5.3).
        foreach (['templateId' => 'template_id', 'version' => 'version'] as $param => $column) {
            if ($request->has($param)) {
                $query->where($column, $request->query($param));
            }
        }

        // El orden. json-server devolvía el de inserción del db.json y el
        // frontend no ordena; un SELECT sin ORDER BY no garantiza NADA, y
        // PostgreSQL lo demuestra en cuanto la tabla recibe UPDATEs. La
        // trampa estaba anotada en CONTRACT.md y aquí se paga con una línea.
        $query->orderBy('template_id')->orderBy('version');

        return $this->paginated($request, $query, function (Template $row) {
            return TemplateSerializer::toArray($row);
        });
    }
}
