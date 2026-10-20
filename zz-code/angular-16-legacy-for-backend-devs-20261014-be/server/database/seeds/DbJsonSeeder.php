<?php
// server/database/seeds/DbJsonSeeder.php
// Versión completa: la de be03 §5.4 más assets, findings, certificates y users (de mock/auth.js).

declare(strict_types=1);

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DbJsonSeeder extends Seeder
{
    public function run(): void
    {
        // El db.json del PROPIO alumno (mock/db.json de la Fase 3), montado en /app. No un volcado que
        // venga con el curso: el tuyo, con lo que hayas hecho.
        $db = json_decode((string) file_get_contents('/app/mock/db.json'), true, 512, JSON_THROW_ON_ERROR);

        DB::transaction(function () use ($db) {
            foreach ($db['clients'] as $client) {
                DB::table('clients')->insert([
                    'id' => $client['id'],
                    'legal_name' => $client['legalName'],
                    'tax_id' => $client['taxId'],
                ]);
            }

            foreach ($db['assets'] as $asset) {
                DB::table('assets')->insert([
                    'id' => $asset['id'],
                    'client_id' => $asset['clientId'],
                    'type' => $asset['type'],
                    'description' => $asset['description'],
                    'installed_at' => $asset['installedAt'],
                ]);
            }

            foreach ($db['templates'] as $template) {
                DB::table('templates')->insert([
                    // El id compuesto del JSON NO se guarda: se descompone. Si no cuadra con
                    // templateId + version, el dato está corrupto y conviene enterarse ahora.
                    'template_id' => $template['templateId'],
                    'version' => $template['version'],
                    'valid_from' => $template['validFrom'],
                    'valid_until' => $template['validUntil'],
                    'items' => json_encode($template['items']),
                ]);
            }

            foreach ($db['inspections'] as $inspection) {
                DB::table('inspections')->insert([
                    'id' => $inspection['id'],
                    'asset_id' => $inspection['assetId'],
                    'inspector_id' => $inspection['inspectorId'],
                    'template_id' => $inspection['templateId'],
                    'template_version' => $inspection['templateVersion'],
                    'status' => $inspection['status'],
                    // La cadena entra con su offset -05:00 y la columna es `timestamp` SIN zona:
                    // PostgreSQL se queda con la hora local y tira el offset en silencio (💸 4).
                    'started_at' => $inspection['startedAt'],
                    'completed_at' => $inspection['completedAt'],
                    'answers' => json_encode($inspection['answers']),
                ]);
            }

            foreach ($db['findings'] as $finding) {
                DB::table('findings')->insert([
                    'id' => $finding['id'],
                    'inspection_id' => $finding['inspectionId'],
                    'item_id' => $finding['itemId'],
                    'severity' => $finding['severity'],
                    'description' => $finding['description'],
                    'resolved_at' => $finding['resolvedAt'],
                ]);
            }

            foreach ($db['certificates'] as $certificate) {
                DB::table('certificates')->insert([
                    'id' => $certificate['id'],
                    'inspection_id' => $certificate['inspectionId'],
                    'issued_at' => $certificate['issuedAt'],
                    'valid_until' => $certificate['validUntil'],
                    'status' => $certificate['status'],
                    'revoked_at' => $certificate['revokedAt'],
                ]);
            }

            // Los dos usuarios del mock. Las contraseñas en claro del mock pasan a hash: es la única
            // mejora que esta fase se permite, porque no es visible en el contrato.
            $users = [
                ['INS-15', 'inspector@certcore.co', 'Ana Restrepo', 'inspector'],
                ['SUP-02', 'supervisor@certcore.co', 'Diego Marín', 'supervisor'],
            ];

            foreach ($users as [$id, $email, $name, $role]) {
                DB::table('users')->insert([
                    'id' => $id,
                    'email' => $email,
                    'password_hash' => password_hash('certcore123', PASSWORD_BCRYPT),
                    'name' => $name,
                    'role' => $role,
                ]);
            }

            // Las secuencias de las tablas con `serial` hay que reajustarlas a mano después de
            // insertar ids explícitos, o el primer INSERT nuevo choca con la clave duplicada.
            DB::statement("SELECT setval('clients_id_seq', (SELECT MAX(id) FROM clients))");
            DB::statement("SELECT setval('inspections_id_seq', (SELECT MAX(id) FROM inspections))");
            DB::statement("SELECT setval('findings_id_seq', (SELECT MAX(id) FROM findings))");
        });
    }
}
