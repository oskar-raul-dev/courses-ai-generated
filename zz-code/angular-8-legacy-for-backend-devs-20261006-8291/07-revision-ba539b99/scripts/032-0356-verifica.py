# rescatado de la sesión ba539b99, 2026-09-11T03:56:35Z · Final fence check and diff summary
import glob,re
for f in sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md')):
    n=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*```(?!`)',l))
    n4=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*````',l))
    if n%2 or n4%2: print('DESBALANCE',f,n,n4)
print('ok fences')
