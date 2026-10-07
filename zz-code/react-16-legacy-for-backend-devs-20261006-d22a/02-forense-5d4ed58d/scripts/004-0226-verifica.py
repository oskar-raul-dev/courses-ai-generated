# rescatado de la sesión 5d4ed58d, 2026-09-10T02:26:17Z · Cross-check incident index against headers and hermanos
import re, io
s = io.open("cuaderno-incidentes.md", encoding="utf-8").read()

# índice
rows = re.findall(r'^\| (\d{2}) \| ([\d\-]+) \| (.+?) \| (.+?) \| (.+?) \| (.+?) \|$', s, re.M)
idx = {r[0]: {'fase': r[1], 'titulo': r[2].strip(), 'cat': r[3].strip(), 'dif': r[4].strip()} for r in rows}
print(f"filas del índice: {len(idx)}")

# encabezados
heads = re.findall(r'^## Incidente (\d{2})( ⭐)? — (.+?)\n\n> \*\*Fase:\*\* (.+?) · \*\*Categoría:\*\* (.+?) · \*\*Dificultad:\*\* (.+?)\n', s, re.M)
print(f"encabezados parseados: {len(heads)}\n")

print("== 3. ÍNDICE vs ENCABEZADO ==")
prob = 0
for hid, star, htit, hfase, hcat, hdif in heads:
    i = idx.get(hid)
    if not i: print(f"  {hid}: no está en el índice"); prob+=1; continue
    tit_idx = i['titulo'].replace(' ⭐','')
    if tit_idx != htit:
        print(f"  {hid} TÍTULO difiere:\n      índice: {tit_idx}\n      cuerpo: {htit}"); prob+=1
    if i['dif'] != hdif.strip():
        print(f"  {hid} DIFICULTAD: índice {i['dif']} vs cuerpo {hdif}"); prob+=1
    ci, ch = i['cat'].lower(), hcat.lower()
    if ci.replace(' / ','-').replace(' ','') not in ch.replace(' / ','-').replace(' ','').replace('(store)','(store)'):
        print(f"  {hid} CATEGORÍA: índice '{i['cat']}' vs cuerpo '{hcat}'"); prob+=1
    fi = i['fase']; fh = hfase.strip()
    if not fh.startswith(fi.split('-')[0]):
        print(f"  {hid} FASE: índice '{fi}' vs cuerpo '{fh}'"); prob+=1
    if star and '⭐' not in i['titulo']:
        print(f"  {hid}: ⭐ en el cuerpo pero no en el índice"); prob+=1
    if '⭐' in i['titulo'] and not star:
        print(f"  {hid}: ⭐ en el índice pero no en el cuerpo"); prob+=1
print(f"  ({prob} discrepancias)" if prob else "  sin discrepancias")

print("\n== 4. HERMANOS ==")
tabla = re.findall(r'^\| (\d{2}) — .+? \| `?(be-\d\d)`? ?⭐? \| ', s, re.M)
print(f"  declarados en la tabla del índice: {sorted(t[0] for t in tabla)} -> {dict(tabla)}")
enc = re.findall(r'## Incidente (\d{2}).*?\n(?:.*?\n){0,8}?> · Hermano del incidente `(be-\d\d)`', s)
print(f"  marcados en encabezado:            {dict(enc)}")
falt = set(dict(tabla)) - set(dict(enc))
sob  = set(dict(enc)) - set(dict(tabla))
if falt: print(f"  ⚠️ en la tabla y NO en el encabezado: {sorted(falt)}")
if sob:  print(f"  ⚠️ en el encabezado y NO en la tabla: {sorted(sob)}")
for k in set(dict(tabla)) & set(dict(enc)):
    if dict(tabla)[k] != dict(enc)[k]: print(f"  ⚠️ {k}: tabla dice {dict(tabla)[k]}, encabezado dice {dict(enc)[k]}")
