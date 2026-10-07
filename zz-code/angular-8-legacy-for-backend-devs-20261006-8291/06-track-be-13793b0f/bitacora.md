# Bitácora de ejecución · sesión 13793b0f-cc80-46c4-b71d-4f3ec9375796

Comandos que ejecutaron código, con el inicio de su salida.

### ⏱️ 2026-09-10T23:42:33Z · Check mongo image tags on Docker Hub

~~~~~~bash
for t in 4.4 6.0 7.0; do echo -n "$t -> "; curl -s --max-time 20 "https://hub.docker.com/v2/repositories/library/mongo/tags/$t" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('name'),d.get('last_updated'),[i['digest'][:19] for i in d.get('images',[])][:1])" 2>/dev/null || echo fallo; done
~~~~~~

~~~~~~text
4.4 -> 4.4 2025-12-29T21:01:21.309441Z ['sha256:7250955b2354']
6.0 -> 6.0 2026-05-15T22:00:28.309944Z ['sha256:268eb517abcb']
7.0 -> 7.0 2026-09-10T00:07:23.522758Z ['sha256:afef081f9a06']
~~~~~~

### ⏱️ 2026-09-10T23:42:41Z · List exact mongo patch tags

~~~~~~bash
for p in 4.4 6.0 7.0; do echo "== $p =="; curl -s --max-time 25 "https://hub.docker.com/v2/repositories/library/mongo/tags?page_size=100&name=$p." | python3 -c "
import sys,json,re
d=json.load(sys.stdin)
ns=[r['name'] for r in d.get('results',[]) if re.fullmatch(r'\d+\.\d+\.\d+', r['name'])]
def key(n): return tuple(int(x) for x in n.split('.'))
print(sorted(set(ns), key=key)[-4:])
"; done
~~~~~~

~~~~~~text
== 4.4 ==
['4.4.27', '4.4.28', '4.4.29', '4.4.30']
== 6.0 ==
['6.0.25', '6.0.26', '6.0.27', '6.0.28']
== 7.0 ==
['7.0.37', '7.0.39', '7.0.40', '7.0.41']
~~~~~~

### ⏱️ 2026-09-11T01:47:25Z · Check Cassandra image tags

~~~~~~bash
curl -s --max-time 20 "https://hub.docker.com/v2/repositories/library/cassandra/tags?page_size=60" | python3 -c "
import sys,json,re
d=json.load(sys.stdin)
ns=[r['name'] for r in d.get('results',[]) if re.fullmatch(r'\d+\.\d+(\.\d+)?', r['name'])]
def key(n):
    p=[int(x) for x in n.split('.')]
    return p+[0]*(3-len(p))
print(sorted(set(ns), key=key)[-8:])
" 2>/dev/null || echo fallo
~~~~~~

~~~~~~text
['4.1.11', '4.1.12', '5.0', '5.0.6', '5.0.7', '5.0.8', '5.0.9', '6.0']
~~~~~~

### ⏱️ 2026-09-11T03:39:41Z · Run the forensic verifier

~~~~~~bash
python3 prompts/verificar-forenses.py; echo "código de salida: $?"
~~~~~~

~~~~~~text
forense-fase-00.md
   ✗ paso sin marca de cierre: «Paso 5 — Cuando la consola está limpia y aun así algo falló»

forense-fase-05.md
   ✗ paso sin marca de cierre: «Paso 4 — Y ahora en producción, que es donde de verdad los v»

forense-fase-06.md
   ✗ paso sin marca de cierre: «Paso 4 — Si es `VALID` y aun así no guarda»

forense-fase-07.md
   ✗ paso sin marca de cierre: «Paso 6 — El otro incidente: "el sistema dice que hay dos pla»

forense-fase-08.md
   ✗ paso sin marca de cierre: «Paso 3 — El ciclo, dibujado, y las dos formas de romperlo»
   ✗ paso sin marca de cierre: «Paso 3 — Por qué el `FormRecord` se rehace y no se parchea»
   ✗ paso sin marca de cierre: «Paso 2 — El experimento que enseña la lección de verdad»

forense-fase-09.md
   ✗ paso sin marca de cierre: «Paso 3 — Dónde va el arreglo, que es la decisión de verdad»
   ✗ paso sin marca de cierre: «Paso 3 — La forma del arreglo, y por qué `undefined` vuelve »

forense-fase-10.md
   ✗ paso sin marca de cierre: «Paso 4 — Por qué el arreglo es una función y no un ajuste»
   ✗ paso sin marca de cierre: «Paso 2 — La comprobación en el código, que es una firma»

forense-fase-12.md
   ✗ paso sin marca de cierre: «Paso 3 — El fix, y el segundo tag»
   ✗ paso sin marca de cierre: «Paso final — Si nada de lo anterior: `git bisect`»

forense-fase-14.md
   ✗ paso sin marca de cierre: «Paso 4 — Lo mismo, en el cluster de tu empresa»
   ✗ paso sin marca de cierre: «Paso 4 — Cuando el pod ya se recicló y no queda nada»

15 piezas
~~~~~~

### ⏱️ 2026-09-11T03:40:41Z · Add closing markers to the fifteen final steps

~~~~~~bash
python3 - <<'PY'
import re,io,glob
cierres={
('forense-fase-00.md','Paso 5'):"**Aquí termina la ruta.** El síntoma ya es concreto: hay una línea de código, un archivo y un momento. Con eso el ticket deja de decir *«no pasó nada»* y pasa a decir algo que se puede arreglar — que es todo lo que una pieza forense promete.",
('forense-fase-05.md','Paso 4'):"**Aquí termina la ruta.** Sabes leer el mismo error en los dos sitios donde te lo vas a encontrar, y en producción sabes qué parte del mensaje sobrevive a la minificación y cuál no. El arreglo es de la rama por la que llegaste, el Paso 2 o el Paso 3.",
('forense-fase-06.md','Paso 4'):"**Aquí termina la ruta.** El bug está localizado: una bandera que sólo se repone por el camino feliz. Es la misma forma que el `PENDING` colgado del Paso 3, y reconocer esa forma —no este archivo— es lo que te llevas.",
('forense-fase-07.md','Paso 6'):"**Aquí termina la ruta.** Las tres versiones del síntoma están localizadas y comparten una raíz: alguien preguntó qué versión rige hoy donde tenía que leer la que quedó guardada. La pieza no va más allá; los fixes son de los incidentes 08, 09, 10 y 12.",
('forense-fase-08.md','Paso 3 — El ciclo'):"**Aquí termina la ruta A.** El bucle está localizado y tiene dos formas de romperse, las dos escritas arriba. Si tu síntoma no era la aplicación hablando sola sino un control que falta o sobra, la tuya es la **ruta B**.",
('forense-fase-08.md','Paso 3 — Por qué'):"**Aquí termina la ruta B.** El control huérfano está explicado y con él la regla que evita la familia entera. Si además veías un error rojo que desaparece al desplegar, queda la **ruta C**.",
('forense-fase-08.md','Paso 2 — El experimento'):"**Aquí termina la ruta C.** Y termina con la conclusión incómoda: el `NG0100` no se arregló, dejó de contarse. El bug que lo producía sigue ahí y ahora es silencioso, que es exactamente lo que la Fase 13 vuelve a enseñar con el build de producción.",
('forense-fase-09.md','Paso 3 — Dónde va'):"**Aquí termina la ruta A.** El bug está localizado —una comparación estricta contra un campo que no existe— y, más importante, está decidido **dónde** va el arreglo: en el borde, una sola vez. Si tu síntoma era un cambio que se deshace solo, la tuya es la **ruta B**.",
('forense-fase-09.md','Paso 3 — La forma'):"**Aquí termina la ruta B.** El bug está localizado y la regla del proyecto que lo evita, escrita. Lo que esta ruta **no** resuelve —que la anulación no quede registrada en ninguna parte— no es un bug: es una deuda, y va al post-mortem del incidente.",
('forense-fase-10.md','Paso 4 — Por qué'):"**Aquí termina la ruta A.** El bug está localizado en una conversión que usa el huso del navegador para una decisión de negocio, y el arreglo es una función con el huso dentro. Si tu síntoma era que el PDF no coincide con la pantalla, la tuya es la **ruta B**.",
('forense-fase-10.md','Paso 2 — La comprobación'):"**Aquí termina la ruta B.** El bug está localizado: el documento se arma con lo que el componente tenía a mano en vez de con el dato de la fuente. La pieza no escribe el fix — es del incidente 14 — pero deja la firma del tipo, que es por dónde empieza.",
('forense-fase-12.md','Paso 3 — El fix'):"**Aquí termina la ruta A.** El incidente queda cerrado con su par de tags y su `git diff` de dos líneas. Si lo que tienes no es un fallo reproducible sino uno que aparece y desaparece, la tuya es la **ruta B**.",
('forense-fase-12.md','Paso final'):"**Aquí termina la ruta B.** Si ninguno de los cuatro sospechosos era, la bisección localiza el commit y ahí se acaba el razonamiento: a partir de ese commit, el diagnóstico vuelve a ser de lectura. Es el único paso de la pieza que no descarta nada — busca.",
('forense-fase-14.md','Paso 4 — Lo mismo'):"**Aquí termina la ruta A.** En tu cluster de kind el bug está localizado en el Paso 2 o en el Paso 3; en el de tu empresa, lo que esta ruta te deja no es el fix sino **las tres preguntas con las que se abre el ticket bien**, que es lo máximo que puede darte una pieza sobre un cluster que no administras.",
('forense-fase-14.md','Paso 4 — Cuando el pod'):"**Aquí termina la ruta B.** O tienes los logs del arranque anterior, o sabes que no existen y por qué. Las dos son respuestas: la segunda convierte el ticket en una pregunta para plataforma —*¿qué agregador tenemos?*— en vez de en una búsqueda que no puede terminar.",
}
hechos=0
for f in sorted(set(k[0] for k in cierres)):
    s=io.open(f,encoding='utf-8').read()
    secs=re.split(r'^(## .+)$', s, flags=re.M)
    out=[]
    for idx,part in enumerate(secs):
        if idx%2==1 or idx==0:
            out.append(part); continue
        cab=secs[idx-1] if idx>0 else ''
        if '🧭' not in cab: out.append(part); continue
        trozos=re.split(r'(^### )', part, flags=re.M)
        nuevo=[]; k=0
        while k<len(trozos):
            if trozos[k]=='### ':
                cuerpo=trozos[k+1]
                titulo=cuerpo.split('\n')[0]
                if not re.search(r'\*\*Qué descarta|\*\*Aquí termina', cuerpo):
                    for (ff,pref),txt in cierres.items():
                        if ff==f and titulo.startswith(pref):
                            cuerpo=re.sub(r'\n---\s*$', '\n\n'+txt+'\n\n---\n', cuerpo.rstrip())+'\n'
                            hechos+=1; break
                nuevo.append('### '); nuevo.append(cuerpo); k+=2
            else:
                nuevo.append(trozos[k]); k+=1
        out.append(''.join(nuevo))
    io.open(f,'w',encoding='utf-8').write(''.join(out))
print("cierres añadidos:",hechos)
PY
python3 prompts/verificar-forenses.py; echo "salida: $?"
~~~~~~

~~~~~~text
cierres añadidos: 15

15 piezas revisadas · 0 fallos
salida: 0
~~~~~~

### ⏱️ 2026-09-11T03:41:26Z · Final full audit of the course

~~~~~~bash
echo "── verificador de piezas ──"; python3 prompts/verificar-forenses.py | tail -2
echo; echo "── auditoría completa ──"; python3 - <<'PY'
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p))
# usado por
bad=sum(1 for a in sorted(glob.glob('a[0-9][0-9]-*.md'))
        if sorted(set(int(x) for x in re.findall(r'Fase\s+(\d+)', re.search(r'Usado por:\s*([^\n·]*)',r(a)).group(1))))
        != sorted(int(p[:2]) for p in fases if (lambda h: h and re.search(r'\b'+a[:3].upper()+r'\b',h.group(1)))(re.search(r'Apéndices de apoyo:([^\n]*)',r(p)))))
print("apéndices con 'Usado por' desajustado:",bad)
# estructura apéndices
falt=[a for a in glob.glob('a[0-9][0-9]-*.md') if not ('🏷️' in r(a) and 'Referencias' in r(a) and 'usar qué' in r(a))]
print("apéndices sin estructura completa:",falt or 0)
# enlaces
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=r(p); b=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.?\.?/?[^)#\s]+\.md)\)', s):
        if not os.path.exists(os.path.normpath(os.path.join(b,m.group(1)))): mal+=1
print("enlaces .md rotos:",mal)
# master indexa
m=r('forense-master.md'); print("piezas sin indexar en el master:",[f for f in glob.glob('forense-fase-*.md') if f not in m] or 0)
PY
~~~~~~

~~~~~~text
── verificador de piezas ──

15 piezas revisadas · 0 fallos

── auditoría completa ──
apéndices con 'Usado por' desajustado: 0
apéndices sin estructura completa: 0
enlaces .md rotos: 0
piezas sin indexar en el master: 0
~~~~~~

### ⏱️ 2026-09-11T03:55:51Z · Read one-line identity of the unlisted courses

~~~~~~bash
for d in angular-8-legacy-for-backend-devs angular-16-legacy-for-backend-devs react-16-legacy-for-backend-devs docker-container-legacy repaso-aws-entrevistas ruta-no-sql-lite; do printf "%-40s " "$d"; head -3 "$d/README.md" 2>/dev/null | tr '\n' ' ' | cut -c1-110; echo; done
~~~~~~

~~~~~~text
angular-8-legacy-for-backend-devs        # 🩺 Angular 8 legacy para devs de backend  > Tutorial de **122 horas** · Dominio: laboratorio clínico · Españo

angular-16-legacy-for-backend-devs       # 🏗️ Angular 16 legacy para devs de backend  > Tutorial de **122 horas** · Dominio: inspecciones y certificaci

react-16-legacy-for-backend-devs         # ⚛️ React 16 Legacy — para devs de backend  Tutorial práctico y **autocontenido** de **96 horas** para desarr

docker-container-legacy                  # 🐳 Docker Legacy Node  > Un laboratorio de contenedores para resucitar proyectos JavaScript de 2018. 
repaso-aws-entrevistas                   # AWS Core Refresh — repaso para entrevistas y laboratorio práctico  > **Objetivo:** refrescar AWS para entrev

ruta-no-sql-lite                         # ⚡ Ruta NoSQL Lite  **Diez motores, un dominio, cinco preguntas.** Un curso corto para decidir con criterio q
~~~~~~

### ⏱️ 2026-09-11T03:56:54Z · Final verification of both angular courses

~~~~~~bash
cd ../angular-16-legacy-for-backend-devs && python3 prompts/verificar-forenses.py | tail -2 && cd ../angular-8-legacy-for-backend-devs && python3 - <<'PY'
import re,io,glob
print("═══ 7. ANGULAR-8: verificación final ═══")
# ejercicios de apéndices BE
tot=0
for a in sorted(glob.glob('bea-*.md')):
    s=io.open(a,encoding='utf-8').read()
    m=re.search(r'Ejercicios \((\d+)\)',s)
    n=len(re.findall(r'^\d+\. ', s.split('## 🧪')[1] if '## 🧪' in s else '', re.M))
    if m and int(m.group(1))!=n: print(f"  ⚠ {a[:6]}: declara {m.group(1)}, hay {n}")
    tot+= int(m.group(1)) if m else 0
print(f"  ejercicios de los 12 apéndices BE: {tot} · conteos declarados = reales")
# cuaderno BE
cu=io.open('cuaderno-incidentes-be.md',encoding='utf-8').read()
idx=len(re.findall(r'^\| be-\d\d', cu, re.M))
ent=len(re.findall(r'^## Incidente be-\d\d', cu, re.M))
sol=len(re.findall(r'Solución de referencia', cu))
print(f"  cuaderno BE: {idx} filas de índice · {ent} entradas · {sol} soluciones")
# forenses del track base intactos
print(f"  piezas forenses del track base: {len(glob.glob('forense-fase-*.md'))} + master")
PY
~~~~~~

~~~~~~text
15 piezas revisadas · 0 fallos
═══ 7. ANGULAR-8: verificación final ═══
  ejercicios de los 12 apéndices BE: 94 · conteos declarados = reales
  cuaderno BE: 12 filas de índice · 12 entradas · 12 soluciones
  piezas forenses del track base: 15 + master
~~~~~~

### ⏱️ 2026-09-11T04:04:04Z · Final link and anchor verification

~~~~~~bash
python3 prompts/verificar-forenses.py | tail -2; python3 - <<'PY'
import re,io,glob,os
print("═══ ENLACES Y ANCLAS ═══")
def slug(t):
    t=t.strip().lower(); t=re.sub(r'`|\*\*|\*|__','',t)
    t=''.join(c if (c.isalnum() or c in ' -_') else '' for c in t)
    return t.replace(' ','-')
rel=anc=0; tot_r=tot_a=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=io.open(p,encoding='utf-8').read(); b=os.path.dirname(p)
    heads={slug(h) for h in re.findall(r'^#{2,4}\s*(.+?)\s*$', s, re.M)}
    for m in re.finditer(r'\]\((\.{0,2}/?[^)#\s]+\.md)\)', s):
        tot_r+=1
        if not os.path.exists(os.path.normpath(os.path.join(b,m.group(1)))): rel+=1; print("  ROTO",p,m.group(1))
    for m in re.finditer(r'\]\(#([^)]+)\)', s):
        tot_a+=1
        if m.group(1) not in heads and '️' not in m.group(1): anc+=1; print("  ANCLA",p,'#'+m.group(1))
print(f"  enlaces relativos: {tot_r} · rotos {rel}")
print(f"  anclas internas: {tot_a} · rotas {anc} (se excluyen las que llevan selector de variación, comprobadas y consistentes)")
PY
~~~~~~

~~~~~~text
15 piezas revisadas · 0 fallos
═══ ENLACES Y ANCLAS ═══
  enlaces relativos: 94 · rotos 0
  anclas internas: 163 · rotas 0 (se excluyen las que llevan selector de variación, comprobadas y consistentes)
~~~~~~

### ⏱️ 2026-09-11T04:04:30Z · Verify the Node base image pin across the course

~~~~~~bash
grep -n 'node:18' 13-build-despliegue.md 14-casi-prod-kind.md a09-docker-kubernetes.md a12-arm64-m1.md README.md 2>/dev/null | head -12
~~~~~~

~~~~~~text
a12-arm64-m1.md:43:docker image inspect node:18.18.2-alpine --format '{{.Architecture}}'
a12-arm64-m1.md:113:**El caso normal no requiere hacer nada.** `docker build` produce una imagen de la arquitectura de tu máquina, y las dos imágenes base de la **Fase 13** —`node:18.18.2-alpine` y `nginx:1.25-alpine`— publican variantes arm64 oficiales. En tu Mac construyes arm64, en tu Mac corre arm64, y en el kind de la Fase 14 también, porque el nodo hereda tu arquitectura.
a12-arm64-m1.md:222:2. 🟢 Comprueba que las dos imágenes base de la Fase 13 tienen variante arm64: `docker image inspect node:18.18.2-alpine --format '{{.Architecture}}'` y lo mismo con `nginx:1.25-alpine`. Explica en una línea por qué eso hace que el Dockerfile del curso no necesite ningún ajuste especial.
14-casi-prod-kind.md:172:FROM node:18.18.2-alpine
13-build-despliegue.md:392:# La versión EXACTA, con los tres números. `node:18-alpine` traería el npm que
13-build-despliegue.md:395:FROM node:18.18.2-alpine AS build
13-build-despliegue.md:586:  node:18.18.2-alpine node mock/server.js
README.md:156:Angular y Angular CLI **16.2.12** · TypeScript **5.1.6** con `strict: true` · RxJS **7.8.1** · Angular Material y CDK **16.2.14** (MDC) · zone.js **0.13.3** · Node **18.18.2** con npm **9.8.1** · jsPDF **2.5.1** · ng2-charts **4.1.1** con Chart.js **4.4.x** · Jasmine **4.6.x** y Karma **6.4.x** · json-server **0.17.4**, Express **4.18.2** y jsonwebtoken **9.0.2** para el mock · `node:18.18.2-alpine` y `nginx:1.25-alpin
~~~~~~

### ⏱️ 2026-09-11T04:05:49Z · Final consolidated verification

~~~~~~bash
echo "══ VERIFICACIÓN FINAL — angular-16 ══"; python3 prompts/verificar-forenses.py | tail -2; python3 - <<'PY'
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()
mal=sum(1 for p in glob.glob('*.md')+glob.glob('prompts/*.md') for m in re.finditer(r'\]\((\.{0,2}/?[^)#\s]+\.md)\)', r(p)) if not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(p),m.group(1)))))
print(f"enlaces .md rotos: {mal}")
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p) and 'convencion' not in p and 'historia' not in p)
bad=0
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3].upper(); m=re.search(r'Usado por:\s*([^\n·]*)', r(a))
    dec=sorted(set(int(x) for x in re.findall(r'Fase\s+(\d+)', m.group(1))))
    cab=sorted(int(p[:2]) for p in fases if (lambda h: h and re.search(r'\b'+base+r'\b',h.group(1)))(re.search(r'Apéndices de apoyo:([^\n]*)', r(p))))
    if dec!=cab: bad+=1
print(f"apéndices con 'Usado por' desajustado: {bad}")
print(f"incidentes: {len(re.findall(r'^## Incidente ', r('cuaderno-incidentes.md'), re.M))} · índice: {len(re.findall(r'^\| \[', r('cuaderno-incidentes.md'), re.M))}")
print(f"⚠️ sin cerrar en la propuesta BE: {len(re.findall(r'### 10.2 ⚠️', r('prompts/propuesta-fases-backend.md')))}")
PY
~~~~~~

~~~~~~text
══ VERIFICACIÓN FINAL — angular-16 ══

15 piezas revisadas · 0 fallos
enlaces .md rotos: 0
apéndices con 'Usado por' desajustado: 0
incidentes: 20 · índice: 20
⚠️ sin cerrar en la propuesta BE: 0
~~~~~~

