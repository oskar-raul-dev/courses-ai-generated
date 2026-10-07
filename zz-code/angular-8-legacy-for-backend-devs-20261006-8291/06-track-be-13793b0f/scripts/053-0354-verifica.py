# rescatado de la sesión 13793b0f, 2026-09-11T03:54:57Z · Fix the BE cross-reference mismatches and verify
import re,io,glob
fases=sorted(glob.glob('be0*.md')); bad=0
for a in sorted(glob.glob('bea-*.md')):
    code=a[:6]; m=re.search(r'Usado por:\s*([^\n·]*)', io.open(a,encoding='utf-8').read())
    linea=m.group(1)
    # sólo las fases citadas SIN matiz ("de consulta", "sobre todo")
    principal=re.split(r'; de consulta|; de |sobre todo', linea)[0]
    dec=sorted(set(re.findall(r'be0\d', principal)))
    cab=sorted(f[:4] for f in fases if code in (re.search(r'Apéndices de apoyo:([^\n]*)', io.open(f,encoding='utf-8').read()) or type('x',(),{'group':lambda s,n:''})()).group(1))
    if dec!=cab: bad+=1; print(f"  ⚠ {code}: declara {dec} · cabeceras {cab}")
print("apéndices BE con desajuste real:",bad)
