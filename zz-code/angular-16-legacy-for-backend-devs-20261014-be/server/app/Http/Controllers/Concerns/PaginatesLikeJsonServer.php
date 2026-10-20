<?php
// server/app/Http/Controllers/Concerns/PaginatesLikeJsonServer.php

declare(strict_types=1);

namespace App\Http\Controllers\Concerns;

use Illuminate\Http\Request;

trait PaginatesLikeJsonServer
{
    /**
     * Paginación en el dialecto de json-server 0.17.4:
     *   - _page y _limit como parámetros de consulta
     *   - cabecera X-Total-Count con el total
     *   - array DESNUDO en el cuerpo, nunca un sobre
     *
     * Y la regla que la hace compatible hacia atrás, que es la parte que
     * importa: un cliente que NO manda _page recibe todo, como siempre.
     * El frontend de CertCore no la manda. No tiene que enterarse de nada.
     */
    protected function paginated(Request $request, $query, callable $serialize)
    {
        $total = (clone $query)->count();

        if ($request->has('_page')) {
            $limit = (int) $request->query('_limit', '10');
            $page = max(1, (int) $request->query('_page', '1'));

            $query->limit($limit)->offset(($page - 1) * $limit);
        }

        $rows = array_map($serialize, $query->get()->all());

        // array_values porque array_map sobre una colección puede dejar claves
        // no consecutivas, y entonces json_encode emite un OBJETO en vez de un
        // array. Es el bug de bea-01, y aquí costaría la pantalla entera.
        return response()->json(array_values($rows))
            ->header('X-Total-Count', (string) $total);
    }
}
