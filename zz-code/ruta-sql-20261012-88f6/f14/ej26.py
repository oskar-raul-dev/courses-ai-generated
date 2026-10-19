"""Ejercicio 26 de la Fase 14: el formulario como Access sobre legacy.Protocolos, la tabla de la caja."""
import importlib.util
import sys

spec = importlib.util.spec_from_file_location("front", "/src/14-la-base-no-estaba-lenta/front.py")
front = importlib.util.module_from_spec(spec)
spec.loader.exec_module(front)


def form_legacy(w):
    keys = [r[0] for r in w.query("SELECT IdProtocolo FROM legacy.Protocolos ORDER BY IdProtocolo DESC")]
    for i in range(0, front.SHOWN, front.BATCH):
        batch = keys[i:i + front.BATCH]
        w.query(f"SELECT * FROM legacy.Protocolos WHERE IdProtocolo IN ({', '.join(['%s'] * len(batch))})", batch)


w = front.Wire()
for name, screen in [("staging.protocolos", front.form_access), ("legacy.Protocolos", form_legacy)]:
    r = w.measure(name, front.SHOWN, screen)
    print(f"{name:20} viajes={r['trips']} filas={r['rows']} bytes={r['bytes']} ms={r['ms']:.1f}")
