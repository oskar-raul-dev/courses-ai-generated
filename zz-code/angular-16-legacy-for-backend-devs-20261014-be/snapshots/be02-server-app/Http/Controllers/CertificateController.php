<?php
// server/app/Http/Controllers/CertificateController.php   ← procedencia: CAKEPHP

namespace App\Http\Controllers;

use App\Models\Certificate;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class CertificateController extends BaseController
{
    public function store(Request $request)
    {
        $certificate = new Certificate();

        // El modelo se rellena y se guarda a sí mismo, dentro del controlador.
        // Active Record llevado hasta el final: no hay repositorio, no hay
        // servicio, no hay transacción. Y funciona.
        $certificate->inspection_id = $request->input('inspectionId');
        $certificate->status = 'valid';        // ← el status guardado como dato (💸 2)
        $certificate->created = date('Y-m-d H:i:s');   // ← 'created', no 'created_at'

        $certificate->save();

        return $certificate;
    }
}
