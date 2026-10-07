# rescatado de la sesión f9f4966e, 2026-09-10T16:30:23Z · Final link check and source-of-truth sweep
import io,os,re,glob
bad=[]
for f in glob.glob('*/*.md')+glob.glob('*/prompts/*.md')+glob.glob('prompts/*.md')+['README.md','contenido_forense.md']:
    d=os.path.dirname(f); s=io.open(f,encoding='utf-8').read()
    for m in re.finditer(r'\]\(([^)#]+\.md)(#[^)]*)?\)', s):
        t=m.group(1)
        if t.startswith('http'): continue
        if not os.path.exists(os.path.normpath(os.path.join(d,t))): bad.append((f,t))
print("enlaces rotos:",len(bad),bad[:6])
