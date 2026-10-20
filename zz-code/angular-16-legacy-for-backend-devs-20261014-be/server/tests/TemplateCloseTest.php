<?php

declare(strict_types=1);

// Regresión del bug de la clave compuesta (be03 §5.2): cerrar una versión no puede tocar las demás.

class TemplateCloseTest extends TestCase
{
    use DatabaseTransactions;

    /** @test */
    public function cerrar_la_v2_no_toca_la_v1_ni_la_de_calderas(): void
    {
        $this->api('PUT', '/templates/elevator-annual-v2', ['validUntil' => '2026-05-31']);
        $this->assertResponseOk();

        $db = $this->app->make('db');
        $this->assertSame('2026-05-31', $db->table('templates')->where('template_id', 'elevator-annual')->where('version', 2)->value('valid_until'));
        $this->assertSame('2023-12-31', $db->table('templates')->where('template_id', 'elevator-annual')->where('version', 1)->value('valid_until'));
        $this->assertNull($db->table('templates')->where('template_id', 'boiler-annual')->value('valid_until'));
    }
}
