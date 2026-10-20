<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Certificate extends Model
{
    protected $table = 'certificates';

    // "CERT-2024-000502": clave de texto.
    public $incrementing = false;
    protected $keyType = 'string';

    public $timestamps = false;
}
