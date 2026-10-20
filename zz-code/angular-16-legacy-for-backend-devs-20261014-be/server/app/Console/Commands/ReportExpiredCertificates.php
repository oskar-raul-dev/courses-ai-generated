<?php
// server/app/Console/Commands/ReportExpiredCertificates.php — `php artisan certcore:report:expired`

namespace App\Console\Commands;

use App\Reports\ExpiredCertificatesReport;
use Illuminate\Console\Command;

class ReportExpiredCertificates extends Command
{
    protected $signature = 'certcore:report:expired';

    protected $description = 'Informe mensual de certificados vencidos';

    public function handle()
    {
        $report = (new ExpiredCertificatesReport())->run();

        $this->info(sprintf('vencidos: %d · reglas: %d', count($report['expired']), count($report['rules'])));
    }
}
