<?php
// server/app/Http/Controllers/TemplateController.php   ← procedencia: SYMFONY

declare(strict_types=1);   // ← la primera huella, y está en la línea 3

namespace App\Http\Controllers;

use App\Domain\Template\TemplateRepositoryInterface;   // ← una interfaz. Aquí no hay más
use Illuminate\Http\JsonResponse;
use Laravel\Lumen\Routing\Controller as BaseController;

class TemplateController extends BaseController
{
    /** @var TemplateRepositoryInterface */
    private $templates;

    // Inyección por constructor, contra una interfaz, con el binding declarado
    // aparte. Es más código y es más fácil de probar; en be06 eso deja de ser
    // una opinión.
    public function __construct(TemplateRepositoryInterface $templates)
    {
        $this->templates = $templates;
    }

    public function index(): JsonResponse
    {
        // Objeto de respuesta explícito, nunca el helper. Y tipo de retorno
        // declarado en la firma: quien viene de Symfony no se lo salta nunca.
        return new JsonResponse($this->templates->findActive());
    }
}
