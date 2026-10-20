<?php
// server/database/migrations/2026_10_14_000200_create_certificates_with_status_view.php
// be05 §5.4: el estado de un certificado es una consulta, no una columna. La vista lo calcula al leer.
// La columna certificates.status se conserva: hay código heredado que la escribe (be02, CakePHP).

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

class CreateCertificatesWithStatusView extends Migration
{
    public function up(): void
    {
        // La vigencia termina al final del día de negocio en America/Bogota (bea-07).
        DB::statement(<<<'SQL'
CREATE VIEW certificates_with_status AS
SELECT
  c.id,
  c.inspection_id,
  c.issued_at,
  c.valid_until,
  c.revoked_at,
  CASE
    WHEN c.revoked_at IS NOT NULL THEN 'revoked'
    WHEN (c.valid_until AT TIME ZONE 'America/Bogota') < now() THEN 'expired'
    WHEN (c.valid_until AT TIME ZONE 'America/Bogota') < now() + interval '30 days' THEN 'expiring'
    ELSE 'valid'
  END AS status,
  c.status AS status_almacenado
FROM certificates c
SQL
        );
    }

    public function down(): void
    {
        DB::statement('DROP VIEW IF EXISTS certificates_with_status');
    }
}
