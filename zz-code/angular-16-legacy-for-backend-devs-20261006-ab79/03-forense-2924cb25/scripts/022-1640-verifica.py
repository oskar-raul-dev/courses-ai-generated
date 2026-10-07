# rescatado de la sesión 2924cb25, 2026-09-11T16:40:48Z · Final link validation and diffstat
import re,glob,os
bad=0; total=0
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    d=os.path.dirname(f) or '.'
    for m in re.finditer(r'\]\(([^)#\s]+\.md)(#[^)]*)?\)', open(f).read()):
        t=m.group(1); total+=1
        if not os.path.exists(os.path.join(d,t)): print('ROTO:',f,'->',t); bad+=1
print(total,'enlaces .md ·',bad,'rotos')
