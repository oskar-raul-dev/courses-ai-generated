<?php

declare(strict_types=1);

// Afirma la invariante de be05. Si esta falla, el sistema emite certificados contra normas inexistentes.

class InvariantTest extends TestCase
{
    use DatabaseTransactions;

    /** @test */
    public function una_inspeccion_no_puede_apuntar_a_una_version_inexistente(): void
    {
        // La restricción NOT VALID de be05 la impide EN LA BASE. Escribe directo para no probar el servicio.
        $this->expectException(\Illuminate\Database\QueryException::class);

        $this->app->make('db')->table('inspections')->insert([
            'asset_id' => 'ASC-CENTRAL-03',
            'inspector_id' => 'INS-15',
            'template_id' => 'elevator-annual',
            'template_version' => 99,
            'status' => 'scheduled',
            'started_at' => '2026-01-15 09:00:00',
            'answers' => '[]',
        ]);
    }

    /** @test */
    public function las_filas_historicas_que_la_violan_siguen_siendo_legibles(): void
    {
        // Contener no es corregir. Si esta prueba falla, alguien limpió el histórico.
        $huerfanas = $this->app->make('db')->select('
            SELECT count(*) AS total FROM inspections i
            LEFT JOIN templates t
              ON t.template_id = i.template_id AND t.version = i.template_version
            WHERE t.template_id IS NULL
        ');

        $this->assertGreaterThan(0, (int) $huerfanas[0]->total,
            'El histórico sucio desapareció: alguien reescribió datos que no se tocan.');
    }
}
