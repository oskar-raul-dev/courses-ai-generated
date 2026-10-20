#!/usr/bin/env python3
"""be00: el purchaseToken de las filas pagas, en el documento y en server/CONTRACT.md. Idempotente."""
import os, sys
pairs = [
("`GET /spinLog` sin paginar no es un descuido de la auditoría:",
 "Las filas de los giros pagos traen un campo más, `purchaseToken`: la compra de la que salió el giro. La consola no lo muestra, pero la conciliación de la Fase 8 agrupa por él para prorratear el precio de cada paquete entre sus giros, así que es tan contrato como los demás. No aparece en ninguna petición: está en las respuestas, y solo lo ves si lees el **contenido** del HAR, no la lista de URLs.\n\n`GET /spinLog` sin paginar no es un descuido de la auditoría:"),
("Las filas que trae `mock/db.json` desde la Fase 8 llevan `wheelId`, `origin` y `deliveredPrize`;",
 "Las filas que trae `mock/db.json` desde la Fase 8 llevan `wheelId`, `origin` y `deliveredPrize` (y `purchaseToken` las pagas);"),
]
for path in sys.argv[1:]:
    if not os.path.exists(path): continue
    s = open(path, encoding="utf-8").read(); orig = s
    for old, new in pairs:
        if new.split("\n")[0] in s and old != new.split("\n")[0]:  # ya aplicado
            continue
        s = s.replace(old, new, 1)
    if s != orig: open(path, "w", encoding="utf-8").write(s)
