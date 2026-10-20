<?php
// server/public/index.php — el único punto de entrada. Todo pasa por aquí.

$app = require __DIR__ . '/../bootstrap/app.php';

$app->run();
