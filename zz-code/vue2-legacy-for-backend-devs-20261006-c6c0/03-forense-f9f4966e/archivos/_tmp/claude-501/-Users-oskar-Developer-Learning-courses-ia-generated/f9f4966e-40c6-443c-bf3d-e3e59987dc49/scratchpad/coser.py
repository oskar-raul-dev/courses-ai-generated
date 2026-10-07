# -*- coding: utf-8 -*-
import io, sys, re

def coser(path, pieza, resumen, romper, reservas):
    s = io.open(path, encoding='utf-8').read()
    head = "## ⚠️ Errores comunes\n"
    if "## ⚠️ Errores comunes y pieza forense" in s:
        print("YA COSIDO:", path); return
    if head not in s:
        print("!! sin encabezado esperado:", path); return
    i = s.index(head)
    s = s[:i] + "## ⚠️ Errores comunes y pieza forense\n\n### Errores comunes\n" + s[i+len(head):]
    # insertar bloque antes del siguiente separador de seccion
    j = s.index("\n---\n\n## ", i)
    bloque = "\n### Pieza forense de esta fase\n\n" + resumen.strip() + \
             "\n\n**\U0001f9e8 Rompe a propósito**\n\n" + romper.strip() + \
             "\n\n> \U0001f4c4 El recorrido completo, con las salidas literales, en\n> [`%s`](%s).\n" % (pieza, pieza)
    s = s[:j] + "\n" + bloque + s[j:]
    if not s.endswith("\n"): s += "\n"
    s += "\n---\n\n### \U0001f4cc Reservas para el cuaderno de incidentes\n\n" + reservas.strip() + "\n"
    io.open(path, 'w', encoding='utf-8').write(s)
    print("ok:", path)
