<?php

declare(strict_types=1);

// Lo que el frontend ve cuando la base dice que no. Decisión de be03: integridad = 409, nunca 500.

class ErrorContractTest extends TestCase
{
    use DatabaseTransactions;

    /** @test */
    public function un_nit_repetido_es_409_y_no_500(): void
    {
        $this->api('POST', '/clients', ['legalName' => 'Repetido S.A.S.', 'taxId' => '900123456']);

        $this->assertEquals(409, $this->response->status());
    }

    /** @test */
    public function borrar_un_cliente_con_activos_es_409(): void
    {
        // El cliente 1 tiene dos activos. json-server lo habría borrado en cascada (be00).
        $this->api('DELETE', '/clients/1');

        $this->assertEquals(409, $this->response->status());
        $this->assertCount(2, $this->app->make('db')->table('assets')->where('client_id', 1)->get());
    }

    /** @test */
    public function un_activo_con_cliente_inexistente_es_409(): void
    {
        $this->api('POST', '/assets', [
            'id' => 'ASC-TEST-99', 'clientId' => 999999, 'type' => 'elevator',
            'description' => 'prueba', 'installedAt' => '2024-01-01',
        ]);

        $this->assertEquals(409, $this->response->status());
    }
}
