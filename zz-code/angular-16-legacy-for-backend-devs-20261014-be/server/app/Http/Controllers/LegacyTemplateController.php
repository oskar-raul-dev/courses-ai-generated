<?php
// server/app/Http/Controllers/LegacyTemplateController.php   ← procedencia: LARAVEL
// Sin declare(strict_types=1). Sin tipos de retorno. Helpers por todas partes.

namespace App\Http\Controllers;

use App\Models\Template;
use Laravel\Lumen\Routing\Controller as BaseController;

class LegacyTemplateController extends BaseController
{
    public function index()
    {
        // Service locator: la dependencia se pide donde se usa, no se declara.
        $cached = app('cache')->get('templates.all');

        if ($cached) {
            return $cached;
        }

        $rows = Template::active()->get();

        // response() y collect() son helpers globales de Illuminate: el reflejo
        // más reconocible de quien viene de Laravel.
        return response()->json(collect($rows)->values());
    }
}
