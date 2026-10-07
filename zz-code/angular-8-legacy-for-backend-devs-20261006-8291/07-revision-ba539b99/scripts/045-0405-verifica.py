# rescatado de la sesión ba539b99, 2026-09-11T04:05:03Z · Locate incident mentions in phases 0-4
import re
m={'00-setup-hola-mundo.md':['01','02'],'01-estructura-base-ngrx.md':['03'],
   '02-i18n.md':['04'],'03-autenticacion.md':['05'],'04-mock-api-caos.md':['06','08']}
for f,ids in m.items():
    t=open(f,encoding='utf-8').read()
    print('===',f)
    for i in ids:
        hits=[l.strip()[:120] for l in t.split('\n') if re.search(rf'\b{i}\b',l) and ('ncidente' in l)]
        print(f'  {i}: {len(hits)} menciones ->', hits[:2])
