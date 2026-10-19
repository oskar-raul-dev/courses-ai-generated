### `db.incidente-21.json` — el activo fuera de UTC−5

**Para el incidente 21** (Fase 10).
**Qué cambia:** cinco colecciones ganan una fila cada una, y ninguna fila de la
semilla se toca. Es la hostería de Galápagos tal como quedó en la base el día de
su primera certificación: el cliente (creado desde la pantalla, después del
incidente 22), la caldera, la plantilla ecuatoriana, la inspección aprobada y el
certificado que `computeValidity` emitió con el `-05:00` de siempre.

```json
{
  "clients": [
    { "id": 4, "legalName": "Hostería Chiriboga Cía. Ltda.", "taxId": "2091748323001" }
  ],
  "assets": [
    { "id": "CAL-INN-GPS-01", "clientId": 4, "type": "boiler",
      "description": "Caldera de agua caliente, cuarto de máquinas, Puerto Ayora",
      "installedAt": "2016-04-18" }
  ],
  "templates": [
    {
      "id": "boiler-annual-ec-v1",
      "templateId": "boiler-annual-ec",
      "version": 1,
      "validFrom": "2022-06-01",
      "validUntil": null,
      "items": [
        { "id": "pressure-valve", "title": "Válvula de seguridad y alivio de presión",
          "criteria": ["ok", "leaking", "blocked"],
          "photoRequired": true, "nonComplianceSeverity": "critical" },
        { "id": "flue-gas", "title": "Análisis de gases de combustión",
          "criteria": ["within_range", "out_of_range"],
          "photoRequired": false, "nonComplianceSeverity": "major" }
      ]
    }
  ],
  "inspections": [
    { "id": 505, "assetId": "CAL-INN-GPS-01", "inspectorId": "INS-41",
      "templateId": "boiler-annual-ec", "templateVersion": 1, "status": "approved",
      "startedAt": "2025-03-12T14:10:00.000Z", "completedAt": "2025-03-12T16:30:00.000Z",
      "answers": [
        { "itemId": "pressure-valve", "answer": "ok",
          "evidenceUrl": "assets/evidence/505-pressure-valve.jpg", "note": null },
        { "itemId": "flue-gas", "answer": "within_range", "evidenceUrl": null, "note": null }
      ] }
  ],
  "certificates": [
    { "id": "CERT-2025-000505", "inspectionId": 505,
      "issuedAt": "2025-03-12T20:40:00.000Z",
      "validUntil": "2026-03-12T23:59:59-05:00",
      "status": "issued", "revokedAt": null }
  ]
}
```

**La caldera no trae `timeZone`.** Es el bug entero: el activo está en Puerto
Ayora y nada en la base lo dice. El fix se lo agrega; la preparación no.

**Las fechas de la inspección y del certificado van en `Z`**, a diferencia de la
semilla, que todo lo escribe con `-05:00`. Es deliberado: son las que la
aplicación escribe con `nowInstant()`, y delatan que estas filas no salieron de la
semilla sino del uso. El `validUntil`, en cambio, lleva `-05:00` porque así lo
cierra `endOfBusinessDay`.

**El RUC es ficticio y bien formado** —provincia 20 (Galápagos), tercer dígito 9
(sociedad privada), verificador por módulo 11 y establecimiento `001`—, para que
el incidente 22 lo pueda usar sin que su validador nuevo lo rechace.

**Qué se rompe.** El certificado vence a las `23:59:59-05:00`, que en Puerto
Ayora (`Pacific/Galapagos`, UTC−6 todo el año) son las 22:59:59. Entre las 23:00 y
las 23:59:59 del 12 de marzo de 2026, hora de la isla, la lista dice VENCIDO.

**Cómo comprobarlo.**

```bash
curl -s http://localhost:3000/certificates/CERT-2025-000505 | python3 -m json.tool
# "validUntil": "2026-03-12T23:59:59-05:00"   ← -05:00, para un activo en UTC−6
```

En la pantalla: con el reloj del sistema en el 12 de marzo de 2026 a las 23:15,
hora de Galápagos, la lista de certificados dice **Vencido** para
`CERT-2025-000505`; a las 22:45 del mismo día, **Por vencer**. Los certificados de
la semilla no cambian entre las dos horas.

> ⚠️ **No caduca, pero pide mover el reloj**, igual que el 15. Si alguien hace el
> curso después del 12 de marzo de 2026 y no lo mueve, el certificado sale vencido
> con toda la razón, y el síntoma no se ve.
