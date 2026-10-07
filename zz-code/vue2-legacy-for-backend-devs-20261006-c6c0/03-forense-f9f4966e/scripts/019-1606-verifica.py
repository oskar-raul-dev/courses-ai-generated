# rescatado de la sesión f9f4966e, 2026-09-10T16:06:03Z · Recheck links and inspect duplicate style guide
import io,os,re,glob
bad=[]
for f in glob.glob('01-vue2-legacy/*.md')+glob.glob('02-complement-mongodb-backend/*.md')+glob.glob('prompts/*.md')+['README.md']:
    d=os.path.dirname(f); s=io.open(f,encoding='utf-8').read()
    for m in re.finditer(r'\]\(([^)#]+\.md)(#[^)]*)?\)', s):
        t=m.group(1)
        if t.startswith('http'): continue
        if not os.path.exists(os.path.normpath(os.path.join(d,t))): bad.append((f,t))
print("enlaces rotos:",len(bad), bad[:5])
