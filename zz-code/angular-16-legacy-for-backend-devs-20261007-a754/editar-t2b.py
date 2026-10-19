#!/usr/bin/env python3
"""T2b: F11 y F12 contra la API de F10 (D26: mandan los nombres de F10 y F10 exporta
`daysUntilExpiry`; D27: F12 prueba el recorte de `addMonths` por `computeValidity`).
Reemplazos exactos de una aparición, más dos renombres por palabra en F11 y F12.
Aborta sin escribir si algo no cuadra. Uso: python3 editar-t2b.py [CURSO]."""
import re
import sys
from pathlib import Path

CURSO = Path(sys.argv[1]) if len(sys.argv) > 1 else (
    Path(__file__).resolve().parents[2] / "cursos-legacy/angular-16-legacy-for-backend-devs")

F10_NUEVA = '''/**
 * Días de calendario hasta el vencimiento, contados en días de negocio.
 * Negativo si ya venció, y no se recorta a cero: "venció hace 40 días" es
 * información, y la lista de cobertura de la Fase 11 la usa.
 */
export function daysUntilExpiry(certificate: Certificate, now: Instant): number {
  return daysBetween(toBusinessDay(now), toBusinessDay(certificate.validUntil));
}

/**
 * ⭐ La regla de negocio central de la fase, y son cuatro líneas.'''

CAMBIOS = {
    "10-certificados-vigencia.md": [
        ("/**\n * ⭐ La regla de negocio central de la fase, y son cuatro líneas.", F10_NUEVA),
        ("  const remaining = daysBetween(toBusinessDay(now), toBusinessDay(certificate.validUntil));\n\n  return remaining <= EXPIRING_WINDOW_DAYS",
         "  const remaining = daysUntilExpiry(certificate, now);\n\n  return remaining <= EXPIRING_WINDOW_DAYS"),
        ("    daysUntilExpiry: daysBetween(toBusinessDay(now), toBusinessDay(certificate.validUntil)),\n",
         "    daysUntilExpiry: daysUntilExpiry(certificate, now),\n"),
        ("- **`diverges` tiene una excepción y está justificada en el código.**",
         "- **`daysUntilExpiry` es pública, y el estado y la vista la reutilizan.** La cuenta de días se escribe una vez: el estado, la vista y el panel de la Fase 11 preguntan lo mismo, y tres `daysBetween` en tres sitios son tres lugares donde alguien invierte los argumentos.\n- **`diverges` tiene una excepción y está justificada en el código.**"),
    ],
    "11-dashboard-alertas.md": [
        ("""import { BusinessInstant, toBusinessDay } from '../time/business-day';
import {
  CERTIFICATE_EXPIRING_DAYS,
  certificateStatus,
  daysUntilExpiry,
} from './certificate-status';""",
         """import { Instant, toBusinessDay } from '../time/business-day';
import {
  EXPIRING_WINDOW_DAYS,
  daysUntilExpiry,
  deriveCertificateStatus,
} from './certificate-status';"""),
    ],
    "12-testing-coverage.md": [
        # `expectedVersion` es `number | null` y `toBe` de @types/jasmine 4.6 no lo acepta
        # contra un `number`: el genérico explícito lo dice sin un `as`.
        ("        expect(resolution.template.version).toBe(testCase.expectedVersion);",
         "        expect<number | null>(resolution.template.version).toBe(testCase.expectedVersion);"),
        ("import { certificateStatus, daysUntilExpiry } from './certificate-status';",
         "import { daysUntilExpiry, deriveCertificateStatus } from './certificate-status';"),
        ("""// src/app/core/time/business-day.spec.ts — los dos casos que valen por diez
describe('addMonths', () => {
  it('recorta al último día del mes cuando el día no existe allí', () => {
    // 29 de febrero de un año bisiesto, más doce meses. La aritmética ingenua
    // da el 1 de marzo y REGALA un día de vigencia; la correcta recorta al 28.
    // Es un caso que llega una vez cada cuatro años y que ningún QA prueba.
    expect(addMonths('2024-02-29', 12)).toBe('2025-02-28');
  });

  it('recorta también hacia el mes corto', () => {
    expect(addMonths('2024-01-31', 1)).toBe('2024-02-29');
  });
});

describe('todayInBusinessZone', () => {""",
         """// src/app/core/domain/certificate-validity.spec.ts — los dos casos que valen por diez
import { computeValidity } from './certificate-validity';

describe('computeValidity', () => {
  // `addMonths` es privada a propósito (Fase 10 §5.2), así que el recorte se
  // prueba por la única puerta que lo usa. Un test que la importara fijaría un
  // detalle de implementación que la Fase 10 decidió no publicar.

  it('recorta al último día del mes cuando el día no existe allí', () => {
    // 29 de febrero de un año bisiesto, más doce meses. La aritmética ingenua
    // da el 1 de marzo y REGALA un día de vigencia; la correcta recorta al 28.
    // Es un caso que llega una vez cada cuatro años y que ningún QA prueba.
    expect(computeValidity('2024-02-29T09:00:00-05:00').until).toBe('2025-02-28T23:59:59-05:00');
  });

  it('cuenta desde el día del negocio, no desde el de UTC', () => {
    // Emitido a las 23:30 del 15 de marzo en Bogotá, que en UTC ya es el 16.
    // Vence el 15: es el mismo borde que `todayInBusinessZone`, abajo, pero
    // sin andamio, porque aquí el instante entra por parámetro.
    expect(computeValidity('2024-03-15T23:30:00-05:00').until).toBe('2025-03-15T23:59:59-05:00');
  });
});
```

```ts
// src/app/core/time/business-day.spec.ts — el único que necesita andamio
import { todayInBusinessZone } from './business-day';

describe('todayInBusinessZone', () => {"""),
        ("   * Compáralo con `certificateStatus`, arriba, que hace lo mismo y recibe el",
         "   * Compáralo con `deriveCertificateStatus`, más arriba, que hace lo mismo y recibe el"),
        ("5. Escribe los dos tests de `addMonths`: el 29 de febrero más doce meses y el 31 de enero más uno. Explica en tres frases por qué el recorte va hacia abajo.",
         "5. Escribe los dos tests de `computeValidity`: la emisión del 29 de febrero de 2024 y la de las 23:30. Explica en tres frases por qué el recorte va hacia abajo, y en una por qué se prueba sin exportar `addMonths`."),
    ],
}

# Renombres por palabra, después de los reemplazos: (archivo, viejo, nuevo, apariciones esperadas).
RENOMBRES = [
    ("11-dashboard-alertas.md", "BusinessInstant", "Instant", 3),
    ("11-dashboard-alertas.md", "CERTIFICATE_EXPIRING_DAYS", "EXPIRING_WINDOW_DAYS", 5),
    ("11-dashboard-alertas.md", "certificateStatus", "deriveCertificateStatus", 4),
    ("12-testing-coverage.md", "certificateStatus", "deriveCertificateStatus", 9),
]

nuevos = {}
for nombre, pares in CAMBIOS.items():
    texto = (CURSO / nombre).read_text(encoding="utf-8")
    for viejo, nuevo in pares:
        n = texto.count(viejo)
        if n != 1:
            sys.exit(f"{nombre}: {n} apariciones de {viejo[:60]!r}; no se escribe nada")
        texto = texto.replace(viejo, nuevo)
    nuevos[nombre] = texto
for nombre, viejo, nuevo, esperadas in RENOMBRES:
    patron = re.compile(rf"(?<![A-Za-z_]){viejo}(?![A-Za-z_])")
    texto, n = patron.subn(nuevo, nuevos[nombre])
    if n != esperadas:
        sys.exit(f"{nombre}: {n} apariciones de {viejo}, se esperaban {esperadas}; no se escribe nada")
    nuevos[nombre] = texto
for nombre, texto in nuevos.items():
    (CURSO / nombre).write_text(texto, encoding="utf-8")
    print("editado", nombre)
