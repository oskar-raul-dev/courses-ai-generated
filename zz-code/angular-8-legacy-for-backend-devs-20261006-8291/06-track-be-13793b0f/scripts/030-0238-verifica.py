# rescatado de la sesión 13793b0f, 2026-09-11T02:38:23Z · Fix relative links and re-verify
import re,io,glob,os
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=io.open(p,encoding='utf-8').read(); base=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.?\.?/?[^)#\s]+\.md)\)', s):
        if not os.path.exists(os.path.normpath(os.path.join(base,m.group(1)))):
            print("  ROTO",p,"->",m.group(1)); mal+=1
print("enlaces .md rotos ahora:",mal)
