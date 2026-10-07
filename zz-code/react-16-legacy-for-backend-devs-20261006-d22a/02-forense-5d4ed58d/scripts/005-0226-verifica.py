# rescatado de la sesión 5d4ed58d, 2026-09-10T02:26:34Z · Check template compliance, tag blocks and appendices
import re, io, glob, os
base = sorted(glob.glob("0[0-9]-*.md")+glob.glob("1[01]-*.md"))
base = [f for f in base if not f.startswith(("00-alcance","00-historia","00-convencion"))]
be = sorted(glob.glob("be0*.md"))
apx = sorted(glob.glob("A[0-9]*.md")+glob.glob("be-a-*.md"))

print("== 5. PLANTILLA DE 9 SECCIONES ==")
need = ["1. Propósito","2. Qué queda listo","3. Qué queda fuera","4. Conceptos mínimos",
        "5. Implementación","6. Errores comunes y pieza forense","7. Ejercicios","8. Referencias","9. Cierre"]
for f in base+be:
    s = io.open(f,encoding="utf-8").read()
    h2 = re.findall(r'^## .*$', s, re.M)
    nums = [re.search(r'(\d)\.', h) for h in h2]
    got = [int(m.group(1)) for m in nums if m]
    missing = [n for n in range(1,10) if n not in got]
    forense = "ieza forense" in s
    ejer = re.search(r'## 🧪 \d\. Ejercicios \((\d+)\)', s)
    flag = []
    if missing: flag.append(f"faltan secciones {missing}")
    if not forense: flag.append("SIN pieza forense")
    if not ejer: flag.append("sin conteo de ejercicios en el título")
    elif not (25 <= int(ejer.group(1)) <= 35): flag.append(f"ejercicios={ejer.group(1)} fuera de 25-35")
    if flag: print(f"  {f}: {'; '.join(flag)}")
print("  (las fases no listadas cumplen)")

print("\n== 6. BLOQUE 🏷️ DEL TAG ==")
for f in base+be:
    s = io.open(f,encoding="utf-8").read()
    slug = f[:-3]
    m = re.search(r'git tag -a (fase-[a-z0-9-]+)', s)
    if not m: print(f"  {f}: SIN bloque de tag")
    elif m.group(1) != "fase-"+slug: print(f"  {f}: tag '{m.group(1)}' != 'fase-{slug}'")
print("  (las fases no listadas cumplen)")

print("\n== 7. APÉNDICES: ¿declaran que no llevan tag? ==")
for f in apx:
    s = io.open(f,encoding="utf-8").read()
    if "🏷️" not in s: print(f"  {f}: sin bloque 🏷️")
print("  (los apéndices no listados lo tienen)")
