<?php
// server/database/migrations/2026_10_14_000100_add_template_fk_not_valid.php
// Salida A de be05: la clave foránea compuesta, NOT VALID. Separa el futuro del pasado:
// las filas nuevas o modificadas tienen que cumplirla; las 88 viejas siguen ahí, intactas.
// VALIDATE CONSTRAINT no se ejecuta aquí: lo autoriza alguien (INVARIANTES.md §5).

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

class AddTemplateFkNotValid extends Migration
{
    public function up(): void
    {
        // Raw SQL a propósito: Lumen/Eloquent no expresa NOT VALID. Va a SQL-CRUDO.txt de be05.
        DB::statement(
            'ALTER TABLE inspections
               ADD CONSTRAINT inspections_template_fk
               FOREIGN KEY (template_id, template_version)
               REFERENCES templates (template_id, version)
               NOT VALID'
        );
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE inspections DROP CONSTRAINT IF EXISTS inspections_template_fk');
    }
}
