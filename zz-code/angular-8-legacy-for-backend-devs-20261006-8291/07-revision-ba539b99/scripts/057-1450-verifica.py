# rescatado de la sesión ba539b99, 2026-09-11T14:50:54Z · Validate every incident block structure
import re
t=open('cuaderno-incidentes.md',encoding='utf-8').read()
# fences
n=sum(1 for l in t.split('\n') if re.match(r'^\s*```(?!`)',l))
n4=sum(1 for l in t.split('\n') if re.match(r'^\s*````',l))
print('fences ``` :',n,'pares ok' if n%2==0 else 'IMPAR')
print('fences ````:',n4,'pares ok' if n4%2==0 else 'IMPAR')
# details
print('<details>:',t.count('<details>'),' </details>:',t.count('</details>'))
# por incidente
bloques=re.split(r'^## Incidente ',t,flags=re.M)[1:]
print('incidentes:',len(bloques))
faltan=[]
for b in bloques:
    nn=b[:2]
    for k in ['### 🎫 El ticket','### 🎯 Qué se te pide','### 🔧 Preparación','💡 <b>Pista 1</b>','💡 <b>Pista 2</b>','💡 <b>Pista 3</b>','### 📝 Tu investigación','✅ <b>Solución de referencia</b>','**Causa raíz**','**Parche mínimo**','**La refactorización correcta**','**Prueba de regresión**','**Prevención**','**Por qué llegó a producción**','**Si tu causa fue distinta a esta**','**Reportado por:**','**Ambiente:**','**Fase:**','**Categoría:**','**Dificultad:**','**Tiempo sugerido:**']:
        if k not in b: faltan.append((nn,k))
    if b.count('<details>')!=4: faltan.append((nn,'debe tener 4 <details>, tiene %d'%b.count('<details>')))
for f in faltan: print('FALTA',f)
print('OK: todos los bloques completos' if not faltan else 'revisar')
