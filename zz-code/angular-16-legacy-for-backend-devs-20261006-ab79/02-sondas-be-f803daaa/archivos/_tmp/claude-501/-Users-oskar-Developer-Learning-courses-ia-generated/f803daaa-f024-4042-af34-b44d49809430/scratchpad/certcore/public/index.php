<?php
header('Content-Type: application/json');
$p = new PDO(getenv('DB_DSN'), 'postgres', 'certcore');
echo json_encode([
  'service'  => 'certcore-api (Lumen ira aqui)',
  'php'      => PHP_VERSION,
  'arch'     => php_uname('m'),
  'postgres' => $p->query('SHOW server_version')->fetchColumn(),
], JSON_PRETTY_PRINT), "\n";
