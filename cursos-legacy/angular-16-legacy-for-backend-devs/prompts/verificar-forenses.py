#!/usr/bin/env python3
"""Verificador de las piezas forenses — Tutorial Angular 16 (CertCore).

Comprueba lo que el checklist de `formato-piezas-forenses.md` §8 pide y que se
puede comprobar sin leer: la estructura de cada pieza y las dos marcas de cierre
de cada paso. Lo que exige criterio —que una salida sea literal, que un callejón
esté bien elegido— no se comprueba aquí y sigue siendo trabajo de quien revisa.

    python3 prompts/verificar-forenses.py

Devuelve 0 si todo está en verde y 1 si algo falla, para poder encadenarlo.
"""

import glob
import io
import os
import re
import sys

# Las dos marcas de cierre de §4. Un paso lleva una y sólo una.
DESCARTA = r'\*\*Qué descarta'
TERMINA = r'\*\*Aquí termina'

# Los bloques obligatorios de §3. Los opcionales —⚰️ callejones y 🧨 deshacer—
# se informan pero no hacen fallar la comprobación.
OBLIGATORIOS = {'🎫': 'ticket', '🧭': 'ruta', '🩺': 'diagnóstico por síntoma',
                '🧠': 'patrón transferible'}

# Alguna de estas expresiones tiene que aparecer en la entrada de la ruta: es el
# criterio de orden que §4 exige declarar explícitamente.
ORDEN = re.compile(
    r'barat|m[aá]s caro|cuesta un vistazo|cuesta un clic|cuesta segundos|'
    r'cuesta diez segundos|cuesta un comando|orden no es|lo decide el s[ií]ntoma|'
    r'regla que ordena|Empieza siempre|misma raz[oó]n|El orden es la lecci[oó]n',
    re.I)


def revisar(ruta):
    """Devuelve la lista de fallos de una pieza. Vacía si está bien."""
    texto = io.open(ruta, encoding='utf-8').read()
    fallos = []

    for emoji, nombre in OBLIGATORIOS.items():
        if emoji not in texto:
            fallos.append('falta el bloque %s (%s)' % (emoji, nombre))

    # El criterio de orden, en la entrada de la primera sección de ruta.
    inicio = texto.find('## 🧭')
    if inicio >= 0:
        primer_paso = texto.find('###', inicio)
        entrada = texto[max(0, inicio - 700):primer_paso]
        if not ORDEN.search(entrada):
            fallos.append('la ruta no declara su criterio de orden (§4)')

    # Cada paso de cada sección 🧭 cierra con una de las dos marcas.
    secciones = re.split(r'^(## .+)$', texto, flags=re.M)
    for i in range(1, len(secciones), 2):
        cabecera, cuerpo = secciones[i], secciones[i + 1]
        if '🧭' not in cabecera:
            continue
        for bloque in re.split(r'^### ', cuerpo, flags=re.M)[1:]:
            titulo = bloque.split('\n')[0].strip()
            tiene_descarta = re.search(DESCARTA, bloque)
            tiene_termina = re.search(TERMINA, bloque)
            if not tiene_descarta and not tiene_termina:
                fallos.append('paso sin marca de cierre: «%s»' % titulo[:60])
            elif tiene_descarta and tiene_termina:
                # No es un error de formato, pero casi siempre son dos pasos.
                fallos.append('paso con las DOS marcas —¿son dos pasos?—: «%s»'
                              % titulo[:60])

    return fallos


def main():
    os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
    piezas = sorted(glob.glob('forense-fase-*.md'))
    if not piezas:
        print('no encuentro ninguna pieza forense')
        return 1

    total = 0
    for pieza in piezas:
        fallos = revisar(pieza)
        total += len(fallos)
        if fallos:
            print('\n%s' % pieza)
            for f in fallos:
                print('   ✗ %s' % f)

    # El master no tiene pasos, pero sí tiene que indexarlas todas.
    master = io.open('forense-master.md', encoding='utf-8').read()
    sin_indexar = [p for p in piezas if p not in master]
    if sin_indexar:
        total += len(sin_indexar)
        print('\nforense-master.md')
        for p in sin_indexar:
            print('   ✗ no indexa %s' % p)

    print('\n%d piezas revisadas · %d fallos' % (len(piezas), total))
    return 1 if total else 0


if __name__ == '__main__':
    sys.exit(main())
