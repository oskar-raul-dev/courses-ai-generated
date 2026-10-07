# rescatado de la sesión ba539b99, 2026-09-11T03:55:48Z · Final integrity validation
import glob,re
for f in sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md')):
    n=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*```(?!`)',l))
    n4=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*````',l))
    if n%2: print('fences impares (```):',f,n)
    if n4%2: print('fences impares (````):',f,n4)
print('chequeo de fences hecho')
