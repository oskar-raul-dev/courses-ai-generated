<?php
// server/app/Console/Commands/ArchiveInspections.php
// Cierre de mes. Escrito hace años, corre el primer día hábil del mes.

namespace App\Console\Commands;

use Illuminate\Console\Command;

class ArchiveInspections extends Command
{
    protected $signature = 'certcore:archive {--year=}';

    public function handle()
    {
        $year = $this->option('year');
        $db = app('db');

        // Archivar es MOVER la fila: se borra y se vuelve a insertar con status
        // 'archived'. Así lo exige el disparador de auditoría de 2017, que sólo
        // registra INSERT. Las que tienen certificado las archiva otro proceso.
        $rows = $db->table('inspections')
            ->whereYear('started_at', $year)
            ->where('status', 'approved')
            ->whereNotExists(function ($query) {
                $query->from('certificates')->whereColumn('certificates.inspection_id', 'inspections.id');
            })
            ->orderBy('id')
            ->get();

        $moved = 0;

        // Una sola transacción para todo el año: si una fila falla, falla el año entero
        // y el mes se queda a medias — que es exactamente el síntoma del ticket.
        $db->transaction(function () use ($db, $rows, &$moved) {
            foreach ($rows as $row) {
                $data = (array) $row;
                $data['status'] = 'archived';

                $db->table('inspections')->where('id', $row->id)->delete();
                $db->table('inspections')->insert($data);   // ← el INSERT sí revalida la FK
                $moved++;
            }
        });

        $this->info("archivadas: {$moved}");
    }
}
