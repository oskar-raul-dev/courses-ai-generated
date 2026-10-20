<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Inspection extends Model
{
    protected $table = 'inspections';

    public $timestamps = false;

    protected $casts = [
        'answers' => 'array',
    ];
}
