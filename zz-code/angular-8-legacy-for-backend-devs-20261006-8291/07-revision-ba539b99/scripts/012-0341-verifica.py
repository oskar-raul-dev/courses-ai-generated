# rescatado de la sesión ba539b99, 2026-09-11T03:41:54Z · Debug slug function
import re
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()); h=h.replace('`','')
    h=re.sub(r'\*\*|\*|__|_','',h)
    s=h.lower(); out=[]
    for c in s:
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
print(slug('6. Locales y formatos: `LOCALE_ID`, fechas, números y zona horaria'))
