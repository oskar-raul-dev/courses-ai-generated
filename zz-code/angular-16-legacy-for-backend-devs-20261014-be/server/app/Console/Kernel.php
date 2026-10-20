<?php

declare(strict_types=1);

namespace App\Console;

use Laravel\Lumen\Console\Kernel as ConsoleKernel;

// be03: migrate y db:seed. Son los comandos de illuminate/database, no propios.
class Kernel extends ConsoleKernel
{
    protected $commands = [
        \Illuminate\Database\Console\Migrations\MigrateCommand::class,
        \Illuminate\Database\Console\Migrations\FreshCommand::class,
        \Illuminate\Database\Console\Seeds\SeedCommand::class,
        \App\Console\Commands\ReportExpiredCertificates::class,
    ];
}
