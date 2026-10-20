<?php
// server/app/Models/Template.php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class Template extends Model
{
    protected $table = 'templates';

    // Clave compuesta. Eloquent NO la soporta de fábrica: da por hecho una
    // columna `id` incremental. Se desactiva el incremental y se le dice que
    // no hay clave simple; todo lo que necesite buscar por clave va explícito
    // con where(). Es una limitación real del ORM y bea-04 la desarrolla.
    public $incrementing = false;
    protected $primaryKey = null;

    /**
     * ⚠️ Sin este método, `$template->save()` sobre una fila existente actualiza
     * TODAS las plantillas: con `$primaryKey = null` Eloquent no sabe qué fila es y
     * el UPDATE sale sin WHERE. Se le da la clave compuesta, con los valores
     * ORIGINALES (por si el UPDATE cambia la versión). Medido en el laboratorio:
     * cerrar la v2 sin esto le ponía fecha de fin a la v1 y a la de calderas.
     */
    protected function setKeysForSaveQuery(Builder $query)
    {
        return $query
            ->where('template_id', $this->getOriginal('template_id', $this->template_id))
            ->where('version', $this->getOriginal('version', $this->version));
    }

    // Las columnas de la parcela CakePHP se llaman `created`/`modified`, y
    // estas tablas ni siquiera las tienen. Sin esta línea, Eloquent añade
    // created_at/updated_at a cada INSERT y revienta.
    public $timestamps = false;

    protected $casts = [
        'version' => 'integer',
        'items' => 'array',
    ];

    /**
     * El id compuesto que ve el frontend: "elevator-annual-v2".
     * Se DERIVA, no se guarda. La base sostiene la unicidad con la clave
     * primaria compuesta; el contrato recibe la cadena que siempre recibió.
     */
    public function getIdAttribute(): string
    {
        return sprintf('%s-v%d', $this->template_id, $this->version);
    }

    /** Scope heredado. Se invoca como Template::active() — ver bea-03. */
    public function scopeActive($query)
    {
        return $query->whereNull('valid_until');
    }
}
