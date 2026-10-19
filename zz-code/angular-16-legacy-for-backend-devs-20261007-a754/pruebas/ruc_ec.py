#!/usr/bin/env python3
"""Dígito verificador del RUC de una sociedad privada ecuatoriana (tercer dígito 9):
módulo 11 con coeficientes 4,3,2,7,6,5,4,3,2 sobre los nueve primeros dígitos; el
décimo es el verificador y le siguen tres del establecimiento (001). La fuente oficial
se verifica en T4; aquí solo se arma un RUC ficticio bien formado para el incidente 21."""
import sys

def verificador(nueve: str) -> int:
    s = sum(int(d) * c for d, c in zip(nueve, (4, 3, 2, 7, 6, 5, 4, 3, 2)))
    r = 11 - s % 11
    return 0 if r == 11 else r   # r == 10 no es válido: hay que cambiar la secuencia

base = sys.argv[1] if len(sys.argv) > 1 else "209174832"   # 20 = Galápagos, 9 = sociedad privada
d = verificador(base)
print(f"{base}{d}001" if d != 10 else "secuencia inválida (verificador 10)")
