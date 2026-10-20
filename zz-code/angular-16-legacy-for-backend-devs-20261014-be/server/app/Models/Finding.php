<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Finding extends Model
{
    protected $table = 'findings';

    public $timestamps = false;

    // El camino viejo crea con create($request->all()); sin esta lista, Eloquent lo rechaza.
    protected $fillable = ['inspection_id', 'item_id', 'severity', 'description', 'resolved_at'];
}
