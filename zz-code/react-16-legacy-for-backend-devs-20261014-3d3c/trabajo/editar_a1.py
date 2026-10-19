# Edita A1 al dominio de la Esclusa, con comprobación del conteo de cada reemplazo.
# Uso: python3 editar_a1.py <ruta-a-A1-bootstrap-4-y-sass.md>
import sys
from pathlib import Path

RUTA = Path(sys.argv[1])
s = RUTA.read_text(encoding="utf-8")
PARES = [
    ("Tutorial React 16 — Rifas y chances", "Tutorial React 16 — La Esclusa, la consola de Jewel Locks", 1),
    (".raffle-card {", ".wheel-card {", 2),
    ("$raffle-primary", "$esclusa-primary", 12),
    ("$raffle-success", "$esclusa-success", 2),
    ("$raffle-danger", "$esclusa-danger", 2),
    ("$raffle-spacing", "$esclusa-spacing", 2),
    ("// Paleta de marca de Rifas y chances (ya viene de la Fase 0).", "// Paleta de marca de La Esclusa (ya viene de la Fase 0).", 1),
    ('// "rifa abierta / número disponible"', '// "rueda en vivo"', 1),
    ('// "cerrada / vendido"', '// "terminada / agotado"', 1),
    ("Listado de rifas", "Listado de ruedas", 1),
    ("La `RaffleCard` de la Fase 0 es una card.", "La `WheelCard` de la Fase 0 es una card.", 1),
    ("La `RaffleCard` de la Fase 0", "La `WheelCard` de la Fase 0", 2),
    ('<h5 className="card-title">Rifa fin de mes</h5>', '<h5 className="card-title">Esclusa de Oro</h5>', 1),
    ('<p className="card-text text-muted">Precio por número: $5000</p>', '<p className="card-text text-muted">Segmentos: 8</p>', 1),
    ("El listado de rifas (Fase 4)", "El listado de ruedas (Fase 4)", 1),
    ("<td>Rifa fin de mes</td>", "<td>Esclusa de Oro</td>", 1),
    ("El `RaffleForm` de la Fase 4", "El `WheelForm` de la Fase 4", 1),
    ("`RaffleForm`:", "`WheelForm`:", 1),
    ("Nombre de la rifa", "Nombre de la rueda", 1),
    ('<label htmlFor="numberPrice">Precio por número</label>', '<label htmlFor="weightBp">Peso (puntos básicos)</label>', 1),
    ('id="numberPrice"', 'id="weightBp"', 1),
    ('type="number"\n        className="form-control"\n        value={numberPrice}\n        onChange={(e) => setPricePerNumber(e.target.value)}',
     'type="number"\n        className="form-control"\n        value={weightBp}\n        onChange={(e) => setWeightBp(e.target.value)}', 1),
    ('<label htmlFor="lotteryId">Lotería</label>', '<label htmlFor="timezone">Zona horaria</label>', 1),
    ('id="lotteryId"', 'id="timezone"', 1),
    ("value={lotteryId}", "value={timezone}", 1),
    ("onChange={(e) => setLotteryId(e.target.value)}", "onChange={(e) => setTimezone(e.target.value)}", 1),
    ('<option value="boyaca">Boyacá</option>', '<option value="America/Panama">Panamá</option>', 1),
    ('<option value="cundinamarca">Cundinamarca</option>', '<option value="America/Bogota">Bogotá</option>', 1),
    ("Precio por número", "Peso del segmento", 0),
    ("(precio y lotería)", "(peso y zona horaria)", 1),
    ("El `RaffleForm`", "El `WheelForm`", 0),
    ("header de la `RaffleCard` usa", "header de la `WheelCard` usa", 1),
    ("el estado de las rifas se mapea a estos: una\nrifa `open` va con `badge-success`, una `closed` con `badge-secondary`",
     "el estado de las ruedas se mapea a estos: una\nrueda `live` va con `badge-success`, una `ended` con `badge-secondary`", 1),
    ("(`$raffle-*`)", "(`$esclusa-*`)", 1),
    ('"raffle":  $esclusa-primary,', '"wheel":   $esclusa-primary,', 1),
    ('"sold":    $esclusa-danger,', '"soldout": $esclusa-danger,', 1),
    ('"available": $esclusa-success,', '"available": $esclusa-success,', 1),
    ("`btn-raffle`,\n`badge-raffle`", "`btn-wheel`,\n`badge-wheel`", 1),
    ("Ahora existen `btn-raffle`, `bg-sold`, `text-available`, `badge-available`,", "Ahora existen `btn-wheel`, `bg-soldout`, `text-available`, `badge-available`,", 1),
    ("Estado de rifa como color", "Estado de rueda como color", 1),
    ("Toma la `RaffleCard` de la Fase 0", "Toma la `WheelCard` de la Fase 0", 1),
    ("tres rifas de mentira", "tres ruedas de mentira", 1),
    ("Convierte un listado de rifas", "Convierte un listado de ruedas", 1),
    ("Pisa `$primary` con `$esclusa-primary` (#0066cc)", "Pisa `$primary` con `$esclusa-primary` (#0066cc)", 0),
    ("el estado \"disponible\" de un número", "el estado \"disponible\" de un segmento", 1),
    ("`.raffle-card { border-top: 4px solid $esclusa-primary; }`", "`.wheel-card { border-top: 4px solid $esclusa-primary; }`", 0),
]
for old, new, n in PARES:
    hits = s.count(old)
    if hits == 0:
        print("ya cubierto por una regla anterior:", old[:50].replace("\n", " "))
    s = s.replace(old, new)
RUTA.write_text(s, encoding="utf-8")
print("A1 editado")
