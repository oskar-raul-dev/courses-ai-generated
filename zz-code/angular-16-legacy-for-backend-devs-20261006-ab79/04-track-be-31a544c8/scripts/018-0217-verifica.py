# rescatado de la sesión 31a544c8, 2026-09-12T02:17:47Z · Verify every debt block declares where it is paid
import re,glob
print("Deudas 💸 y su destino declarado")
tot=0; bad=[]
for f in sorted(glob.glob('[0-9][0-9]-*.md')+glob.glob('be0*.md')):
    s=open(f).read()
    blocks=re.findall(r'💸 DEUDA TÉCNICA INTENCIONAL.*?(?=```)', s, re.S)
    for b in blocks:
        tot+=1
        if not re.search(r'SE PAGA EN|NO SE PAGA|se paga en|Se paga en', b):
            bad.append((f,b.splitlines()[0][:70]))
print(f"  bloques 💸 encontrados: {tot}")
print("  sin destino:", bad or "✅ ninguno")
# marcas 💸 sueltas fuera de bloque
sueltas=[(f,l.strip()[:90]) for f in sorted(glob.glob('[0-9][0-9]-*.md')+glob.glob('be0*.md'))
         for l in open(f) if '💸' in l and 'DEUDA TÉCNICA' not in l and 'SE PAGA' not in l]
print(f"\n  menciones 💸 en prosa (referencias cruzadas, no bloques): {len(sueltas)}")
