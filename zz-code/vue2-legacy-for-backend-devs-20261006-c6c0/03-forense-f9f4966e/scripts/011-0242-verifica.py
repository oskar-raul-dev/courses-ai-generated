# rescatado de la sesión f9f4966e, 2026-09-10T02:42:49Z · Check for broken markdown links
import io,os,re,glob
base='.'
bad=[]
for f in glob.glob('01-vue2-legacy/*.md')+glob.glob('02-complement-mongodb-backend/*.md')+glob.glob('prompts/*.md')+['README.md']:
    d=os.path.dirname(f)
    s=io.open(f,encoding='utf-8').read()
    for m in re.finditer(r'\]\(([^)#]+\.md)(#[^)]*)?\)', s):
        t=m.group(1)
        if t.startswith('http'): continue
        p=os.path.normpath(os.path.join(d,t))
        if not os.path.exists(p): bad.append((f,t))
print("enlaces rotos:", len(bad))
for b in bad[:20]: print("  ",b[0],"->",b[1])
