<?php
// server/database/seeds/DatabaseSeeder.php
// El que llama `artisan migrate --seed` y `migrate:fresh --seed`. Sólo delega.

declare(strict_types=1);

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call(DbJsonSeeder::class);
    }
}
