# rescatado de la sesión ba539b99, 2026-09-11T03:41:46Z · Inspect raw lines for anchor mismatch
import unicodedata
def show(f,n):
    l=open(f,encoding='utf-8').read().split('\n')[n-1]
    print(f,n,repr(l))
show('a07-i18n.md',22); show('a07-i18n.md',275)
show('a13-docker-colima.md',38); show('a13-docker-colima.md',151)
