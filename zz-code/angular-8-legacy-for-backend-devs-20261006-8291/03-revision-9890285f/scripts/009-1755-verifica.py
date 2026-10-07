# rescatado de la sesión 9890285f, 2026-09-10T17:55:21Z · Check README coverage and orphan documents
import re,glob,os
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
r=open('README.md',encoding='utf-8').read()
falt=[f for f in sorted(glob.glob('*.md')) if f!='README.md' and f not in r]
print("archivos NO nombrados en README.md:")
for f in falt: print("   -",f)
print()
print("¿README enlaza (markdown) algo?:",len(re.findall(r'\]\((?!http)',r)))
print()
# quién enlaza analisis-forense-tutoriales
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    if 'analisis-forense-tutoriales' in open(f,encoding='utf-8').read() and 'analisis' not in f:
        print("cita analisis-forense-tutoriales:",f)
