<?php

declare(strict_types=1);

// El contrato de un endpoint por el camino oficial. Es la misma aserción que be00 CONTRACT.md documenta.

class ContractTest extends TestCase
{
    use DatabaseTransactions;

    /** @test */
    public function templates_devuelve_un_array_desnudo_con_id_compuesto(): void
    {
        $this->api('GET', '/templates');

        $this->assertResponseOk();
        $body = json_decode($this->response->getContent(), true);
        $this->assertIsArray($body);
        $v2 = collect($body)->firstWhere('id', 'elevator-annual-v2');
        $this->assertNotNull($v2);
        $this->assertNull($v2['validUntil'], 'validUntil null = vigente indefinidamente');
    }

    /** @test */
    public function la_inspeccion_501_declara_templateVersion_1_y_tres_respuestas(): void
    {
        $this->api('GET', '/inspections/501');

        $this->assertResponseOk();
        $body = json_decode($this->response->getContent(), true);
        $this->assertSame(1, $body['templateVersion']);
        $this->assertCount(3, $body['answers']);
    }

    /** @test */
    public function un_id_inexistente_devuelve_404_con_cuerpo_vacio(): void
    {
        $this->api('GET', '/clients/NO-EXISTE');

        $this->assertEquals(404, $this->response->status());
        $this->assertSame('{}', $this->response->getContent());
    }
}
