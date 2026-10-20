<?php

declare(strict_types=1);

// Regresión del incidente be-09: una inspección de 2023 con una versión que ya no coincide con ninguna
// fila de plantilla tiene que seguir saliendo entera (ítems y respuestas). Si no, auditoría no puede reimprimirla.

class RegressionTest extends TestCase
{
    use DatabaseTransactions;

    /** @test */
    public function una_inspeccion_huerfana_sigue_saliendo_con_sus_respuestas(): void
    {
        $huerfana = $this->app->make('db')->selectOne('
            SELECT i.id FROM inspections i
            LEFT JOIN templates t ON t.template_id = i.template_id AND t.version = i.template_version
            WHERE t.template_id IS NULL ORDER BY i.id LIMIT 1
        ');
        $this->assertNotNull($huerfana, 'No hay huérfanas: la prueba no mide nada sin el volumen de be05.');

        $this->api('GET', '/inspections/' . $huerfana->id);

        $this->assertResponseOk();
        $body = json_decode($this->response->getContent(), true);
        $this->assertIsArray($body['answers']);
        $this->assertNotEmpty($body['answers']);
    }
}
