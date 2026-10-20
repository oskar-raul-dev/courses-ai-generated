<?php
// server/app/Support/ChaosConfig.php

declare(strict_types=1);

namespace App\Support;

use RuntimeException;

class ChaosConfig
{
    /** Los seis modos válidos. Cualquier otro mata el arranque. */
    public const KNOWN_FAULTS = ['latency', 'error', 'malformed', 'cors', 'expired', 'timeout'];

    private const DEFAULT_DELAY_MS = 2500;
    private const DEFAULT_RATE = 0.3;

    /**
     * Lee la configuración del entorno y valida. Devuelve un array asociativo
     * porque config/chaos.php espera exactamente esa forma.
     *
     * @param array<string, string> $env
     * @return array{faults: string[], delayMs: int, rate: float}
     */
    public static function fromEnvironment(array $env): array
    {
        $raw = trim($env['CHAOS'] ?? '');
        // array_filter sin callback elimina las cadenas vacías, que es lo que
        // deja un CHAOS=latency, con coma colgando.
        $faults = $raw === '' ? [] : array_values(array_filter(array_map('trim', explode(',', $raw))));

        $unknown = array_diff($faults, self::KNOWN_FAULTS);

        if ($unknown !== []) {
            // Igual que en el mock: fallar al arrancar, no en silencio. Un
            // CHAOS=latencia mal escrito que simplemente no hace nada te cuesta
            // veinte minutos buscando un bug que no existe.
            throw new RuntimeException(sprintf(
                'Fallos de caos desconocidos: %s. Los válidos son: %s.',
                implode(', ', $unknown),
                implode(', ', self::KNOWN_FAULTS)
            ));
        }

        return [
            'faults' => $faults,
            'delayMs' => (int) ($env['CHAOS_DELAY_MS'] ?? self::DEFAULT_DELAY_MS),
            'rate' => (float) ($env['CHAOS_RATE'] ?? self::DEFAULT_RATE),
        ];
    }
}
