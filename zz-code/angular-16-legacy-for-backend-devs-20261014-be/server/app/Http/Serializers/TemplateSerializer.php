<?php
// server/app/Http/Serializers/TemplateSerializer.php

declare(strict_types=1);

namespace App\Http\Serializers;

use App\Models\Template;

class TemplateSerializer
{
    /**
     * La forma EXACTA de CONTRACT.md. Cada línea de este método es una ficha
     * de aquel documento, y el orden de las claves también: json-server las
     * emitía así y hay pantallas que iteran sobre Object.keys().
     *
     * @return array<string, mixed>
     */
    public static function toArray(Template $template): array
    {
        return [
            'id' => $template->id,                       // derivado
            'templateId' => $template->template_id,      // snake → camel, aquí
            // (int) explícito: sin él, el driver de PostgreSQL devuelve los
            // enteros como CADENA, y el frontend recibe "2" en vez de 2. Es
            // literalmente la pieza forense de esta fase (§6).
            'version' => (int) $template->version,
            'validFrom' => $template->valid_from,
            'validUntil' => $template->valid_until,      // null se emite como null
            'items' => $template->items,
        ];
    }
}
