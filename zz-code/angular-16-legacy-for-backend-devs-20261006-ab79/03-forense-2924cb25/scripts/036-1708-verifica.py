# rescatado de la sesión 2924cb25, 2026-09-11T17:08:10Z · Final verification of the BE prompt files
import re,glob,os
bad=total=0
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    d=os.path.dirname(f) or '.'
    for m in re.finditer(r'\]\(([^)#\s]+\.md)(#[^)]*)?\)', open(f).read()):
        total+=1
        if not os.path.exists(os.path.join(d,m.group(1))): print('ROTO:',f,'->',m.group(1)); bad+=1
print(total,'enlaces ·',bad,'rotos')
