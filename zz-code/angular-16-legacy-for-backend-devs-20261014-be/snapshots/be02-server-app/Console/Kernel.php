<?php

declare(strict_types=1);

namespace App\Console;

use Laravel\Lumen\Console\Kernel as ConsoleKernel;

// Sin comandos Artisan propios en be01.
class Kernel extends ConsoleKernel
{
    protected $commands = [];
}
