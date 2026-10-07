# rescatado de la sesión 13793b0f, 2026-09-11T03:56:10Z · Compare declared vs real state per course
import re,io,glob,os
print("═══ 6. ESTADO DECLARADO vs REAL, curso por curso ═══")
for c,pat in [('angular-8-legacy-for-backend-devs','be'),('angular-16-legacy-for-backend-devs','be'),('react-16-legacy-for-backend-devs','be')]:
    rd=io.open(os.path.join(c,'README.md'),encoding='utf-8').read()
    n_fase=len(glob.glob(os.path.join(c,'[0-9][0-9]-*.md')))
    n_ap=len(glob.glob(os.path.join(c,'a[0-9][0-9]-*.md')))
    n_be=len(glob.glob(os.path.join(c,'be0*.md')))
    n_bea=len(glob.glob(os.path.join(c,'bea-*.md')))
    n_for=len(glob.glob(os.path.join(c,'forense-*.md')))
    n_cu=len(glob.glob(os.path.join(c,'cuaderno-*.md')))
    print(f"\n  {c}")
    print(f"    en disco: {n_fase} fases · {n_ap} apéndices · {n_be} fases BE · {n_bea} apéndices BE · {n_for} forenses · {n_cu} cuadernos")
    for frase in ['aún sin escribir','sin escribir todavía','Ninguna fase está escrita','pendiente','propuesto']:
        if frase in rd: print(f"    ⚠ el README dice «{frase}»")
