<?php

declare(strict_types=1);

/**
 * Envuelve cada prueba en una transacción y la deshace al terminar. Cuesta lo mismo tanto si la
 * prueba escribió una fila como mil. NO sirve para probar COMMIT (be06 §5.3).
 */
trait DatabaseTransactions
{
    public function setUp(): void
    {
        parent::setUp();
        $this->app->make('db')->beginTransaction();
    }

    public function tearDown(): void
    {
        $this->app->make('db')->rollBack();
        parent::tearDown();
    }
}
