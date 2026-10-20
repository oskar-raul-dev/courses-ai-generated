<?php
// server/database/migrations/2016_09_20_000100_create_core_tables.php
//
// La fecha del nombre es de 2016 a propósito: estas migraciones reconstruyen el
// esquema tal como quedó entonces, no como lo haríamos hoy. Lo que hoy haríamos
// distinto va marcado 💸 y tiene fase de cobro.

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCoreTables extends Migration
{
    public function up(): void
    {
        // ── clients ────────────────────────────────────────────────────────
        Schema::create('clients', function (Blueprint $table) {
            $table->increments('id');
            $table->string('legal_name');
            // El NIT es la clave del negocio: siempre presente y único.
            $table->string('tax_id')->unique();
        });

        // ── assets ─────────────────────────────────────────────────────────
        Schema::create('assets', function (Blueprint $table) {
            // Clave de texto, no serial: "ASC-CENTRAL-03" es el identificador
            // que está pintado en el equipo. Inventar un id numérico al lado
            // habría sido la decisión de CakePHP, y aquí no se tomó.
            $table->string('id')->primary();
            $table->unsignedInteger('client_id');
            $table->string('type');   // elevator | boiler | tank | fire_system
            $table->string('description');
            // Día de calendario, no instante: una fecha de instalación no tiene hora.
            $table->date('installed_at');

            $table->foreign('client_id')->references('id')->on('clients');
        });

        // ── templates ──────────────────────────────────────────────────────
        Schema::create('templates', function (Blueprint $table) {
            $table->string('template_id');
            $table->unsignedInteger('version');
            $table->date('valid_from');
            // null = vigente indefinidamente. NO es "sin datos", y de esa
            // lectura depende resolveTemplateVersion en el frontend.
            $table->date('valid_until')->nullable();
            // Los ítems del checklist, anidados. El contrato los entrega
            // siempre dentro de la plantilla y nadie filtra por ítem.
            $table->jsonb('items');

            // LA clave primaria compuesta. El "id" de texto que ve el
            // frontend ("elevator-annual-v2") se DERIVA de estas dos columnas
            // al serializar: ver el modelo en §5.2.
            $table->primary(['template_id', 'version']);
        });

        // ── inspections ────────────────────────────────────────────────────
        Schema::create('inspections', function (Blueprint $table) {
            $table->increments('id');
            $table->string('asset_id');
            $table->string('inspector_id');

            // Las dos columnas que este track existe para mirar.
            $table->string('template_id');
            $table->unsignedInteger('template_version');

            $table->string('status');
            // 💸 sin zona: ver el bloque de deuda de abajo.
            $table->timestamp('started_at');
            $table->timestamp('completed_at')->nullable();
            $table->jsonb('answers');

            $table->foreign('asset_id')->references('id')->on('assets');

            // ⚠️ Y AQUÍ NO HAY NADA MÁS. No hay foreign compuesta contra
            // templates. No es un olvido de esta migración: es el estado real
            // del sistema desde 2016, y es el tema entero de be05.
        });

        // ── findings ───────────────────────────────────────────────────────
        Schema::create('findings', function (Blueprint $table) {
            $table->increments('id');
            $table->unsignedInteger('inspection_id');
            $table->string('item_id');
            $table->string('severity');   // critical | major | minor
            $table->string('description');
            // null = sin resolver. Un critical sin resolver bloquea el certificado.
            $table->timestamp('resolved_at')->nullable();

            $table->foreign('inspection_id')->references('id')->on('inspections');
            // Índice explícito: la ruta anidada /inspections/:id/findings es el
            // acceso más frecuente de todo el sistema.
            $table->index('inspection_id');
        });

        // ── certificates ───────────────────────────────────────────────────
        Schema::create('certificates', function (Blueprint $table) {
            $table->string('id')->primary();   // "CERT-2024-0087"
            $table->unsignedInteger('inspection_id');
            $table->timestamp('issued_at');
            $table->timestamp('valid_until');
            // 💸 status ALMACENADO. Ver el bloque de deuda: esta columna es la
            // protagonista del hallazgo incómodo de §5.6.
            $table->string('status');
            $table->timestamp('revoked_at')->nullable();

            $table->foreign('inspection_id')->references('id')->on('inspections');
        });

        // ── users ──────────────────────────────────────────────────────────
        Schema::create('users', function (Blueprint $table) {
            // "INS-15", "SUP-02": los mismos sub del token del mock.
            $table->string('id')->primary();
            $table->string('email')->unique();
            $table->string('password_hash');
            $table->string('name');
            $table->string('role');   // inspector | supervisor
        });
    }

    public function down(): void
    {
        // Orden inverso al de creación: las foráneas mandan.
        Schema::dropIfExists('users');
        Schema::dropIfExists('certificates');
        Schema::dropIfExists('findings');
        Schema::dropIfExists('inspections');
        Schema::dropIfExists('templates');
        Schema::dropIfExists('assets');
        Schema::dropIfExists('clients');
    }
}
