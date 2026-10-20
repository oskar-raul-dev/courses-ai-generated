<?php
// server/app/Http/Controllers/LegacyTemplateController.php
// Código heredado tal como lo describe be01 §5.7 (bugs 1 y 3). Sin declare(strict_types=1).
// La lección no publica el archivo completo: esto reproduce sus dos líneas clave.
// Las líneas reales están en FALSA-FAMILIARIDAD.md (be01 cita 28 y 31; aquí son otras).

namespace App\Http\Controllers;

use Laravel\Lumen\Routing\Controller as BaseController;

/**
 * Plantillas vigentes. Se cacheó el resultado y nadie pensó en invalidarlo
 * al publicar una versión nueva.
 */
class LegacyTemplateController extends BaseController
{
    public function index()
    {
        $cached = Cache::get('templates.all');

        if ($cached) {
            return $cached;
        }

        $rows = Template::active()->get();

        return response()->json(collect($rows)->values());
    }
}
