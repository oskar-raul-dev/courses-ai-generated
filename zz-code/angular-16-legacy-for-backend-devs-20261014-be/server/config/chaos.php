<?php
// server/config/chaos.php
// Este archivo sólo es legible porque bootstrap/app.php hace
// $app->configure('chaos'). Bórrale esa línea y config('chaos.faults') pasa a
// devolver null sin una sola advertencia.

return App\Support\ChaosConfig::fromEnvironment($_ENV + $_SERVER);
