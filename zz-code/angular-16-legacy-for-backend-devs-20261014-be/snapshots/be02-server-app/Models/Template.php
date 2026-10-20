<?php
// server/app/Models/Template.php — el modelo, tal como está desde 2018

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Template extends Model
{
    protected $table = 'templates';

    /**
     * Scope de Eloquent. Se DECLARA como scopeActive() y se INVOCA como
     * Template::active(). Buscar "active(" no lo encuentra nunca.
     */
    public function scopeActive($query)
    {
        return $query->whereNull('valid_until');
    }
}
