<?php

declare(strict_types=1);

// Regresión de be-08: el informe de vencidos no puede depender de la zona de la sesión.

use App\Reports\ExpiredCertificatesReport;

class ExpiredReportTimezoneTest extends TestCase
{
    use DatabaseTransactions;

    /** @test */
    public function el_informe_cuenta_lo_mismo_en_cualquier_zona_de_la_sesion(): void
    {
        $db = $this->app->make('db');

        // Un certificado dentro de la franja: ya pasó si se lee en UTC, todavía no si se lee en Bogotá.
        $db->statement("
            INSERT INTO certificates (id, inspection_id, issued_at, valid_until, status, revoked_at)
            VALUES ('CERT-PRUEBA-FRANJA', 502, now() - interval '1 year',
                    (now() AT TIME ZONE 'America/Bogota') + interval '2 hours', 'valid', NULL)
        ");

        $counts = [];
        foreach (['UTC', 'America/Bogota', 'Pacific/Auckland'] as $timezone) {
            $db->statement("SET TIME ZONE '{$timezone}'");
            $counts[$timezone] = count((new ExpiredCertificatesReport())->run()['expired']);
        }
        $db->statement('SET TIME ZONE DEFAULT');

        // Si falla, la vigencia depende de dónde corra la sesión: el bug del ticket.
        $this->assertCount(1, array_unique($counts), json_encode($counts));
    }
}
