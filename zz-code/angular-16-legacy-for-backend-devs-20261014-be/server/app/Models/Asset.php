<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Asset extends Model
{
    protected $table = 'assets';

    // Clave de texto ("ASC-CENTRAL-03"), no serial. Ver la migración.
    public $incrementing = false;
    protected $keyType = 'string';

    public $timestamps = false;
}
