<?php

declare(strict_types=1);

// Paginación compatible hacia atrás: un cliente que no pide _page recibe todo, como antes de be03.

class PaginationTest extends TestCase
{
    use DatabaseTransactions;

    /** @test */
    public function sin_page_devuelve_todo_y_manda_el_total(): void
    {
        $this->api('GET', '/clients');

        $this->assertCount(3, json_decode($this->response->getContent(), true));
        $this->assertSame('3', $this->response->headers->get('X-Total-Count'));
    }

    /** @test */
    public function con_page_limita_y_el_total_no_cambia(): void
    {
        $this->api('GET', '/clients?_page=2&_limit=2');

        $this->assertSame([3], array_column(json_decode($this->response->getContent(), true), 'id'));
        $this->assertSame('3', $this->response->headers->get('X-Total-Count'));
    }
}
