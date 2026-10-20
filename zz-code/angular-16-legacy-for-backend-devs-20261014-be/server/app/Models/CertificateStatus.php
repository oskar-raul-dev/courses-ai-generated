<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Lectura de certificados con el estado DERIVADO (be05 §5.4). Sólo se lee de aquí; las escrituras van
 * a Certificate, la tabla. El contrato no cambia: `status` sale con los mismos valores.
 */
class CertificateStatus extends Model
{
    protected $table = 'certificates_with_status';

    public $incrementing = false;
    protected $keyType = 'string';

    public $timestamps = false;
}
