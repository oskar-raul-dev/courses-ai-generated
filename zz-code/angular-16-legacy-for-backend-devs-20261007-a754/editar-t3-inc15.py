#!/usr/bin/env python3
"""T3 (D31): el incidente 15 contra el código de F10. Reemplazos exactos de una
aparición en cuaderno-incidentes.md y prompts/preparaciones-de-incidentes.md.
Aborta sin escribir si algo no cuadra. Uso: python3 editar-t3-inc15.py [CURSO]."""
import sys
from pathlib import Path

CURSO = Path(sys.argv[1]) if len(sys.argv) > 1 else (
    Path(__file__).resolve().parents[2] / "cursos-legacy/angular-16-legacy-for-backend-devs")

CAUSA_VIEJA = """```ts
// src/app/core/domain/certificate-status.ts
const expired = certificate.validUntil.slice(0, 10) < new Date().toISOString().slice(0, 10);
```"""
CAUSA_NUEVA = """```ts
// src/app/core/domain/certificate-status.ts — la línea que cambió
  if (certificate.validUntil.slice(0, 10) < new Date().toISOString().slice(0, 10)) {
    return 'expired';
  }
```"""

PARCHE_VIEJO = """No lo hay que sea honesto, y hay que decirlo: los tres arreglos de una línea que aparecen en cualquier revisión **mueven el síntoma a otra hora o a otro huso**."""
PARCHE_NUEVO = """Hay uno honesto, y es volver a la línea que la Fase 10 dejó escrita: comparar **instantes**, con el `now` que entra por parámetro.

```ts
// src/app/core/domain/certificate-status.ts — dentro de deriveCertificateStatus
  if (isPast(certificate.validUntil, now)) {
    return 'expired';
  }
```

Lo que no hay es un arreglo honesto **distinto** de ése. Los tres de una línea que aparecen en cualquier revisión **mueven el síntoma a otra hora o a otro huso**:"""

REFACTOR_INICIO = "Una decisión, con nombre, en un archivo, llamada desde todas partes:"
REFACTOR_FIN = "> 🧭 **La regla del proyecto: la zona horaria de una decisión de negocio es un dato del negocio, no del entorno.**"
REFACTOR_NUEVO = """Ya está hecha, y es la de la Fase 10: una decisión, con nombre, en un archivo, llamada desde todas partes. `isPast` compara instantes y no días; `toBusinessDay` es el **único** sitio del proyecto donde un instante se convierte en día, con la zona de `business-day.ts`; y ninguna función de dominio pregunta la hora, porque el `now` le llega de fuera. La rama rompió las tres cosas en una línea: comparó días en vez de instantes, los sacó con dos husos distintos y le preguntó la hora a `new Date()`.

Lo que falta no es código: es que nadie pueda volver a escribir esa línea sin que algo se ponga rojo. Eso es la prevención, abajo.

"""

TESTS_VIEJOS = """```ts
// src/app/core/domain/certificate-status.spec.ts
it('no depende del huso del navegador', () => {
  const certificate = { validUntil: '2025-02-10T23:59:59-05:00' } as Certificate;

  // Las 20:00 de Bogotá del día en que vence: en UTC ya es el día 11.
  // Antes del fix, este caso devolvía 'expired'.
  const bogotaEvening = '2025-02-11T01:00:00.000Z';

  expect(buildCertificateView(certificate, bogotaEvening).status).toBe('valid');
});

it('vence al terminar el día del negocio, no antes', () => {
  const certificate = { validUntil: '2025-02-10T23:59:59-05:00' } as Certificate;

  expect(buildCertificateView(certificate, '2025-02-10T04:00:00.000Z').status).toBe('valid');
  expect(buildCertificateView(certificate, '2025-02-11T06:00:00.000Z').status).toBe('expired');
});
```"""
TESTS_NUEVOS = """```ts
// src/app/core/domain/certificate-status.spec.ts — el caso del incidente 15
import { Certificate } from '../models/certificate.model';
import { buildCertificateView } from './certificate-status';

function certificate(validUntil: string): Certificate {
  return {
    id: 'CERT-2024-000502',
    inspectionId: 502,
    issuedAt: '2024-02-10T10:00:00-05:00',
    validUntil,
    // El campo guardado que la Fase 10 dejó de leer, puesto mal a propósito.
    status: 'valid',
    revokedAt: null,
  };
}

describe('incidente 15: el vencimiento no depende del huso de nadie', () => {
  const certificate502 = certificate('2025-02-10T23:59:59-05:00');

  it('sigue vigente a las 20:00 de Bogotá del día en que vence', () => {
    // En UTC ya es el día 11. Antes del fix, este caso devolvía 'expired'.
    // Es `expiring` y no `valid` porque le quedan cero días (Fase 10 §5.3).
    const bogotaEvening = '2025-02-11T01:00:00.000Z';

    expect(buildCertificateView(certificate502, bogotaEvening).status).toBe('expiring');
  });

  it('vence al terminar el día del negocio, no antes', () => {
    expect(buildCertificateView(certificate502, '2025-02-10T04:00:00.000Z').status).toBe('expiring');
    expect(buildCertificateView(certificate502, '2025-02-11T06:00:00.000Z').status).toBe('expired');
  });
});
```"""

PREP_VIEJO = """```diff
-  const expired = isAfterBusinessDay(nowInstant(), certificate.validUntil);
+  // Dos slice(0, 10) que parecen la misma operación y no lo son: el primero
+  // recorta el día LOCAL del dato, el segundo el día en UTC.
+  const expired = certificate.validUntil.slice(0, 10) < new Date().toISOString().slice(0, 10);
```"""
PREP_NUEVO = """```diff
-  if (isPast(certificate.validUntil, now)) {
+  // Dos slice(0, 10) que parecen la misma operación y no lo son: el primero
+  // recorta el día LOCAL del dato, el segundo el día en UTC.
+  if (certificate.validUntil.slice(0, 10) < new Date().toISOString().slice(0, 10)) {
     return 'expired';
   }
```"""

def cambia(nombre, pares):
    ruta = CURSO / nombre
    texto = ruta.read_text(encoding="utf-8")
    for viejo, nuevo in pares:
        n = texto.count(viejo)
        if n != 1:
            sys.exit(f"{nombre}: {n} apariciones de {viejo[:70]!r}; no se escribe nada")
        texto = texto.replace(viejo, nuevo)
    return ruta, texto

cuaderno = (CURSO / "cuaderno-incidentes.md").read_text(encoding="utf-8")
i = cuaderno.index(REFACTOR_INICIO)
j = cuaderno.index(REFACTOR_FIN, i)
refactor_viejo = cuaderno[i:j]

escrituras = [
    cambia("cuaderno-incidentes.md", [
        (CAUSA_VIEJA, CAUSA_NUEVA),
        (PARCHE_VIEJO, PARCHE_NUEVO),
        (refactor_viejo, REFACTOR_NUEVO),
        (TESTS_VIEJOS, TESTS_NUEVOS),
    ]),
    cambia("prompts/preparaciones-de-incidentes.md", [(PREP_VIEJO, PREP_NUEVO)]),
]
for ruta, texto in escrituras:
    ruta.write_text(texto, encoding="utf-8")
    print("editado", ruta.name)
