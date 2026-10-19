<?php
// server/app/Http/Controllers/HealthLegacyController.php   ← procedencia: NINGUNA
// El fundador técnico, 2016. Venía de .NET: escribe PHP con hábitos de C#.

namespace App\Http\Controllers;

class HealthLegacyController
{
    public function ping()
    {
        // PDO a pelo, json_encode a mano, header() a mano. Funciona igual de
        // bien y no usa nada del framework que lo aloja.
        $pdo = new \PDO(getenv('DB_DSN'), 'postgres', 'certcore');
        $row = $pdo->query('SELECT 1')->fetch();

        header('Content-Type: application/json');
        echo json_encode(['db' => $row !== false]);
        exit;   // ← y corta el ciclo de Lumen por la mitad. Ver §6.
    }
}
