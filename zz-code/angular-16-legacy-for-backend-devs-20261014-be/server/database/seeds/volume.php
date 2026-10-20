<?php
// server/database/seeds/volume.php
//
//   docker compose exec api php database/seeds/volume.php \
//       --inspections=4000 --seed=20240915 --violations=88
//
// Genera inspecciones sintéticas RESPETANDO EL DOMINIO, con un número exacto de
// violaciones de la invariante sembradas a propósito. No toca ninguna colección
// que el smoke.sh audite por contenido: sólo añade filas a `inspections` y `findings`.

declare(strict_types=1);

$app = require __DIR__ . '/../../bootstrap/app.php';
$app->boot();

$options = getopt('', ['inspections::', 'seed::', 'violations::', 'reference-date::']);

$count = (int) ($options['inspections'] ?? 4000);
$seed = (int) ($options['seed'] ?? 20240915);
$violations = (int) ($options['violations'] ?? 88);
// Fecha de referencia FIJA: sin ella, el dataset cambia de significado cada día.
$reference = new DateTimeImmutable(($options['reference-date'] ?? '2024-09-15') . ' 00:00:00');

mt_srand($seed);

$db = $app->make('db');

// Los activos y las plantillas NO se generan: son los de tu db.json. Sólo se
// genera el hecho repetitivo —la inspección—, que es lo único que en la vida
// real crece a miles. Se leen con ORDER BY: sin orden fijo no hay determinismo.
$templates = [];
foreach ($db->table('templates')->orderBy('template_id')->orderBy('version')->get() as $row) {
    $templates[$row->template_id][] = [
        'version' => (int) $row->version,
        'from' => $row->valid_from,
        'until' => $row->valid_until,
        'items' => json_decode($row->items, true),
    ];
}

// Sólo los activos cuyo tipo tiene plantilla: un tanque no se inspecciona con la
// plantilla de ascensores.
$templateForType = ['elevator' => 'elevator-annual', 'boiler' => 'boiler-annual'];
$assets = [];
foreach ($db->table('assets')->orderBy('id')->get() as $asset) {
    if (isset($templateForType[$asset->type]) && isset($templates[$templateForType[$asset->type]])) {
        $assets[] = $asset;
    }
}

$statuses = ['scheduled', 'in_progress', 'completed', 'approved', 'rejected'];

// Fechas en los tres años anteriores a la referencia, nunca now().
$windowEnd = $reference->getTimestamp();
$windowStart = $reference->modify('-3 years')->getTimestamp();

// Las violaciones no son azar: son el ejercicio (bea-11, «Las violaciones sembradas»).
// Las N últimas inspecciones son de ascensor, están APROBADAS y apuntan a la versión 3
// de la plantilla, que existió tres semanas y ya no está. Se concentran en esas tres
// semanas porque los datos corruptos se agrupan alrededor de un suceso.
$firstViolation = $count - $violations;
$brokenWindowStart = $reference->modify('-17 months');
$elevators = array_values(array_filter($assets, function ($asset) { return $asset->type === 'elevator'; }));

$rows = [];
$findings = [];
$findingId = 2000;
$generated = 0;

for ($n = 0; $generated < $count; $n++) {
    $isViolation = $generated >= $firstViolation;
    $asset = $isViolation
        ? $elevators[mt_rand(0, count($elevators) - 1)]
        : $assets[mt_rand(0, count($assets) - 1)];
    $templateId = $templateForType[$asset->type];

    $startTs = $isViolation
        ? $brokenWindowStart->modify(sprintf('+%d days +%d minutes', mt_rand(0, 21), mt_rand(0, 600)))->getTimestamp()
        : mt_rand($windowStart, $windowEnd);
    $started = (new DateTimeImmutable('@' . $startTs))->format('Y-m-d H:i:s');
    $day = substr($started, 0, 10);

    // La versión vigente ese día. Si no hay ninguna (una caldera antes de 2022),
    // esa inspección no podía existir: se descarta y se tira otra vez.
    $version = null;
    foreach ($templates[$templateId] as $candidate) {
        if ($day >= $candidate['from'] && ($candidate['until'] === null || $day <= $candidate['until'])) {
            $version = $candidate;
        }
    }
    if ($version === null) {
        continue;
    }

    // Ids desde 10000: dejan libres los de la semilla y el 3117 que fija el incidente be-09.
    $id = 10000 + $generated;
    $status = $isViolation ? 'approved' : $statuses[mt_rand(0, count($statuses) - 1)];

    // completed_at nulo mientras no esté completada, y posterior al inicio cuando existe.
    $completedAt = in_array($status, ['completed', 'approved', 'rejected'], true)
        ? (new DateTimeImmutable($started))->modify('+' . mt_rand(1, 4) . ' hours')->format('Y-m-d H:i:s')
        : null;

    // Las respuestas sólo usan ítems de ESA versión, con valores de sus criterios.
    // Una aprobada no puede tener la peor respuesta en un ítem crítico (Fase 9):
    // se le da la primera opción de cada ítem.
    $answers = [];
    foreach ($version['items'] as $item) {
        $criteria = $item['criteria'];
        $answer = $status === 'approved' ? $criteria[0] : $criteria[mt_rand(0, count($criteria) - 1)];
        $answers[] = [
            'itemId' => $item['id'],
            'answer' => $answer,
            'evidenceUrl' => sprintf('assets/evidence/%d-%s.jpg', $id, $item['id']),
            'note' => null,
        ];
    }

    // Un rechazo lleva un hallazgo crítico sin resolver sobre el primer ítem crítico.
    if ($status === 'rejected') {
        $critical = null;
        foreach ($version['items'] as $item) {
            if (($item['nonComplianceSeverity'] ?? null) === 'critical') {
                $critical = $item['id'];
                break;
            }
        }
        $findings[] = [
            'id' => $findingId++,
            'inspection_id' => $id,
            'item_id' => $critical ?? $version['items'][0]['id'],
            'severity' => 'critical',
            'description' => 'Hallazgo sintético',
            'resolved_at' => null,
        ];
    }

    // La violación sembrada: la versión 3, que ya no existe. Las únicas excepciones, y contadas.
    $templateVersion = $isViolation ? 3 : $version['version'];

    $rows[] = [
        'id' => $id,
        'asset_id' => $asset->id,
        'inspector_id' => 'INS-15',
        'template_id' => $templateId,
        'template_version' => $templateVersion,
        'status' => $status,
        'started_at' => $started,
        'completed_at' => $completedAt,
        'answers' => json_encode($answers),
    ];
    $generated++;
}

$db->transaction(function () use ($db, $rows, $findings) {
    // Las violaciones son HISTÓRICO: se cargan como se carga un volcado, con las
    // comprobaciones de claves foráneas suspendidas sólo dentro de esta transacción.
    // Sin esto, a partir de be05 la FK `NOT VALID` rechazaría las 88 (con razón: es
    // justo lo que impide a las filas NUEVAS). Requiere el usuario `postgres` del laboratorio.
    $db->statement('SET LOCAL session_replication_role = replica');

    foreach (array_chunk($rows, 500) as $chunk) {
        $db->table('inspections')->insert($chunk);
    }
    foreach (array_chunk($findings, 500) as $chunk) {
        $db->table('findings')->insert($chunk);
    }
    // Ids explícitos: las secuencias se reajustan o el primer INSERT nuevo choca (be-05).
    $db->statement("SELECT setval('inspections_id_seq', (SELECT MAX(id) FROM inspections))");
    $db->statement("SELECT setval('findings_id_seq', (SELECT MAX(id) FROM findings))");
});

fwrite(STDERR, sprintf(
    "sembradas %d inspecciones (%d válidas, %d violando la invariante)\nsemilla %d, fecha de referencia %s\n",
    $count, $count - $violations, $violations, $seed, $reference->format('Y-m-d')
));
