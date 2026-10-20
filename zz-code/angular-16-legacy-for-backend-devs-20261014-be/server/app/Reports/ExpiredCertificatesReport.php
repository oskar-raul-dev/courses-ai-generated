<?php
// server/app/Reports/ExpiredCertificatesReport.php
// Informe mensual de certificados vencidos. Escrito en 2017, con PostgreSQL 9.6 delante,
// y no tocado desde entonces. SQL a mano: es una de las entradas de SQL-CRUDO.txt (bea-04).

namespace App\Reports;

class ExpiredCertificatesReport
{
    public function run()
    {
        // Las reglas de la tabla, para etiquetar en el informe por qué se excluye cada fila.
        // pg_constraint.consrc existe hasta PostgreSQL 11 inclusive (be04 §5.3).
        $rules = app('db')->select("
            SELECT c.conname, c.consrc AS definition
            FROM pg_constraint c
            WHERE c.conrelid = 'certificates'::regclass
        ");

        $expired = app('db')->select('
            SELECT id, inspection_id, valid_until
            FROM certificates
            WHERE valid_until < now()
            ORDER BY valid_until
        ');

        return ['rules' => $rules, 'expired' => $expired];
    }
}
