# Comandos Bash de la sesión 073aaed3-80c7-4a5a-b910-f2313b95f58a, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-10-06T00:03:26 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; ls zz-instrucciones; wc -l zz-instrucciones/*; ls cursos-legacy/react-16-legacy-for-backend-devs; ls -la cursos-legacy/react-16-legacy-for-backend-devs/prompts; cat /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/{track-be-react16-escrito,lineamientos-zz-instrucciones-y-zz-code,revision-cursos-lenguajes-zz-instrucciones,docker-legacy-complemento-geek}.md

# --- 2026-10-06T00:03:30 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/zz-instrucciones; cat README.md 04-usar-en-cada-repositorio.md 01-tipos-de-curso.md; ls -R herramientas plantillas

# --- 2026-10-06T00:03:31 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/zz-instrucciones; cat 00-workflow-de-un-curso.md 03-lecciones-de-produccion.md

# --- 2026-10-06T00:03:32 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/zz-instrucciones; cat herramientas/README.md; sed -n 1,200p herramientas/verificar-corpus.py; wc -l herramientas/*; ls plantillas; cat plantillas/README-de-prompts.md

# --- 2026-10-06T00:03:33 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/docker-container-legacy/prompts; ls; cat README.md; grep -n "^## \|^### " guia-de-estilo-y-convenciones.md | tail -30; cat verificar-corpus.py

# --- 2026-10-06T00:03:41 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; ls cursos-legacy cursos-contenedores-cloud-infra; find . -path ./zz-code -prune -o -name verificar-corpus.py -print

# --- 2026-10-06T00:03:44 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-contenedores-cloud-infra/docker-container-legacy/prompts; ls; cat README.md; cat verificar-corpus.py; grep -n "^## " guia-de-estilo-y-convenciones.md

# --- 2026-10-06T00:03:46 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-contenedores-cloud-infra/docker-container-legacy/prompts; sed -n 879,1000p guia-de-estilo-y-convenciones.md

# --- 2026-10-06T00:03:49 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; for f in prompts/*.md; do echo "=== $f ($(wc -l <$f))"; grep -n "^#\{1,3\} " $f | head -60; done

# --- 2026-10-06T00:03:57 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; cat zz-code/README.md | head -60; python3 zz-code/nuevo.py react-16-legacy-for-backend-devs

# --- 2026-10-06T00:04:01 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; Z=zz-code/react-16-legacy-for-backend-devs-20261005-cbd3; mkdir -p $Z/salidas; C=cursos-legacy/react-16-legacy-for-backend-devs; python3 zz-instrucciones/herramientas/verificador_base.py $C --perfil=courses-ia > $Z/salidas/courses-ia.txt 2>&1; tail -5 $Z/salidas/courses-ia.txt; awk '{print $1,$2}' $Z/salidas/courses-ia.txt | sort | uniq -c | sort -rn | head -30; python3 zz-instrucciones/herramientas/verificador_base.py $C --perfil=publicacion > $Z/salidas/publicacion.txt 2>&1; tail -3 $Z/salidas/publicacion.txt; awk '{print $1,$2}' $Z/salidas/publicacion.txt | sort | uniq -c | sort -rn | head -30

# --- 2026-10-06T00:04:05 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; Z=zz-code/react-16-legacy-for-backend-devs-20261005-cbd3/salidas; grep -E "ANCLA|CALLOUT" $Z/courses-ia.txt; grep RESTO $Z/publicacion.txt | awk '{print $3}' | sort | uniq -c | head; grep RESTO $Z/publicacion.txt | head -5; grep EMOJI $Z/courses-ia.txt | head -5; grep -oE "en ###: .*" $Z/courses-ia.txt | sort | uniq -c | sort -rn | head -20; grep ENCAB $Z/courses-ia.txt | head -3

# --- 2026-10-06T00:04:09 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; sed -n 1,200p zz-instrucciones/herramientas/verificador_base.py

# --- 2026-10-06T00:04:10 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; sed -n 200,620p zz-instrucciones/herramientas/verificador_base.py | grep -n "def \|EXCLUIR\|IGNORAR\|prompts\|NO_CAPITULO\|PLANTILLAS_LECTOR\|cuaderno" | head -60; diff zz-instrucciones/herramientas/verificador_base.py cursos-contenedores-cloud-infra/docker-container-legacy/prompts/verificador_base.py && echo same

# --- 2026-10-06T00:04:13 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; sed -n 200,265p zz-instrucciones/herramientas/verificador_base.py; sed -n 540,620p zz-instrucciones/herramientas/verificador_base.py

# --- 2026-10-06T00:04:17 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -c "prompts/" *.md | grep -v ":0"; grep -n "](prompts\|](\./prompts" *.md | head; grep -o "prompts/[a-z0-9-]*\.md" *.md | awk -F: '{print $2}' | sort | uniq -c

# --- 2026-10-06T00:04:23 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n "prompts/" README.md 00-alcance-del-proyecto.md 00-setup-hola-mundo-cra.md cuaderno-incidentes*.md A12*.md be02*.md | cut -c1-260; ls -a; cat .gitignore 2>/dev/null | head; ls src 2>/dev/null | head

# --- 2026-10-06T00:04:31 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -c '```mermaid' *.md prompts/*.md | grep -v ":0"; python3 - <<'EOF'
import re,glob
R=re.compile(r"[┌┐┘└▼↓▲→←│─]")
tot=0
for f in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")):
    t=open(f,encoding="utf-8").read().split("\n")
    blk=None
    for n,l in enumerate(t,1):
        m=re.match(r"^\s*```(\w*)",l)
        if m and blk is None: blk=(n,m.group(1),[]); continue
        if blk is not None and l.strip().startswith("```"):
            n0,lang,b=blk
            k=sum(1 for x in b if re.search(r"[┌┐┘▼↓]",x))
            k2=sum(1 for x in b if R.search(x))
            if k>=2 or (k2>=3 and lang in("","text")):
                tot+=1;print(f"{f}:{n0} [{lang}] box/vert={k} any={k2} :: {b[0][:70]!r}")
            blk=None; continue
        if blk is not None: blk[2].append(l)
print(tot)
EOF

# --- 2026-10-06T00:04:35 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; sed -n 50,62p 05-venta-de-numeros.md; sed -n 568,585p 05-venta-de-numeros.md; sed -n 2509,2525p cuaderno-incidentes.md; grep -n "^```\s*$" -A3 *.md | grep -E "→|──|=>|->" | head -30

# --- 2026-10-06T00:04:38 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; sed -n 50,62p 05-venta-de-numeros.md; echo ----; sed -n 568,585p 05-venta-de-numeros.md; echo ----; sed -n 2509,2525p cuaderno-incidentes.md

# --- 2026-10-06T00:04:43 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; python3 - <<'EOF'
import re,glob
for f in sorted(glob.glob("*.md")):
    t=open(f,encoding="utf-8").read().split("\n")
    blk=None
    for n,l in enumerate(t,1):
        m=re.match(r"^\s*```(\w*)",l)
        if m and blk is None: blk=(n,m.group(1),[]); continue
        if blk is not None and l.strip().startswith("```"):
            n0,lang,b=blk
            if lang in("","text","txt"):
                k=sum(1 for x in b if re.search(r"(-->|==>|\+--|--\+|\|\s{2,}\||►|▶|⟶|↳|^\s*\|\s*$|^\s*v\s*$)",x))
                if k>=2: print(f"{f}:{n0} [{lang}] {k} :: {b[0][:70]!r}")
            blk=None; continue
        if blk is not None: blk[2].append(l)
EOF

# --- 2026-10-06T00:04:48 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; python3 - <<'EOF'
import re,glob
for f in sorted(glob.glob("*.md")):
    t=open(f,encoding="utf-8").read().split("\n")
    blk=None
    for n,l in enumerate(t,1):
        m=re.match(r"^\s*```(\w*)",l)
        if m and blk is None: blk=(n,m.group(1),[]); continue
        if blk is not None and l.strip().startswith("```"):
            n0,lang,b=blk
            if lang in("","text","txt") and any(re.search(r"[→←↓↑►▼│┌└├]",x) for x in b):
                print(f"{f}:{n0} [{lang}] {len(b)}l :: {b[0][:60]!r} | {b[1][:50] if len(b)>1 else ''!r}")
            blk=None; continue
        if blk is not None: blk[2].append(l)
EOF

# --- 2026-10-06T00:05:02 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs/prompts; cat instrucciones-del-proyecto.md

# --- 2026-10-06T00:05:07 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -il playwright *.md prompts/*.md; grep -n -i "playwright" prompts/*.md | head; grep -n "^### D6" -A14 prompts/decisiones-y-versiones.md | head -20

# --- 2026-10-06T00:05:10 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n -i playwright 00-alcance-del-proyecto.md; grep -n -i "cypress" 10-testing-minimo.md | head -3; head -30 prompts/decisiones-y-versiones.md; head -20 prompts/propuesta-fases-backend.md; head -12 prompts/prompts-a-por-fase.md prompts/prompts-backend-apendice.md prompts/diccionario-codigo-ingles.md

# --- 2026-10-06T00:05:16 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs/prompts; sed -n 65,112p prompts-backend-apendice.md; grep -n "be-a-\|bea-" propuesta-fases-backend.md | head; grep -n -i "debian\|cgo\|etiqueta de compilación\|build tag\|-tags" ../be09*.md ../bea-02*.md | head

# --- 2026-10-06T00:05:23 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -H -m1 -E "^## .*Ejercicios" [0-9]*.md A*.md be*.md | sed 's/:.*Ejercicios/: /' | tr '\n' ' '; echo; grep -n "^#\|incidentes\|Estado" README.md | head -40; wc -l *.md | tail -1

# --- 2026-10-06T00:05:32 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; sed -n 330,420p zz-instrucciones/herramientas/verificador_base.py; sed -n 485,540p zz-instrucciones/herramientas/verificador_base.py

# --- 2026-10-06T00:05:49 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; head -12 04-rifas-crud.md; echo ----; head -10 be03-crud-y-el-reemplazo.md; echo ----; head -8 A10-aritmetica-de-dinero.md; python3 - <<'EOF'
import re,glob,unicodedata,collections
def es(c):
    cp=ord(c);return unicodedata.category(c)=="So" or 0x1F000<=cp<=0x1FAFF or 0x2600<=cp<=0x27BF
h=collections.Counter();co=collections.Counter()
for f in glob.glob("*.md"):
    fence=False
    for l in open(f,encoding="utf-8"):
        if l.lstrip().startswith("```"): fence=not fence;continue
        if fence: continue
        if l.startswith("### "):
            for c in l:
                if es(c): h[c]+=1
        m=re.match(r"^> (\S+) \*\*",l)
        if m: co[m.group(1)]+=1
print(sorted(h.items(),key=lambda x:-x[1]));print(sorted(co.items(),key=lambda x:-x[1]))
EOF

# --- 2026-10-06T00:05:58 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; cp zz-instrucciones/herramientas/verificador_base.py cursos-legacy/react-16-legacy-for-backend-devs/prompts/verificador_base.py; cd cursos-legacy/react-16-legacy-for-backend-devs; for f in 0*.md 1*.md; do head -4 $f | grep -c "horas" | sed "s/^/$f /"; done | grep " 0"

# --- 2026-10-06T00:06:28 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; Z=../../zz-code/react-16-legacy-for-backend-devs-20261005-cbd3/salidas; python3 prompts/verificar-corpus.py > $Z/curso.txt; cat $Z/curso.txt; python3 prompts/verificar-corpus.py --publicacion > $Z/curso-pub.txt; awk '{print $1,$2}' $Z/curso-pub.txt | sort | uniq -c; tail -1 $Z/curso-pub.txt

# --- 2026-10-06T00:06:36 · 
for u in https://docs.cypress.io/ https://docs.cypress.io/app/get-started/why-cypress https://mermaid.js.org/syntax/stateDiagram.html https://mermaid.js.org/syntax/flowchart.html; do echo "$u $(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' -m 15 $u)"; done; grep -rn "cypress.io" /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs/10-testing-minimo.md | head -3

# --- 2026-10-06T00:06:48 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs/prompts && python3 - <<'EOF'
p="guia-de-estilo-y-convenciones.md"
t=open(p,encoding="utf-8").read()
def rep(a,b):
    global t
    assert t.count(a)==1,a
    t=t.replace(a,b)
rep("""produzca un `.md` la sigue. Su objetivo es simple: que los ~30 documentos del
tutorial se lean como escritos por la misma mano,""","""produzca un `.md` la sigue. Su objetivo es simple: que los ~50 documentos del
tutorial —doce fases, trece apéndices, el track BE con sus veinte documentos, los
dos cuadernos de incidentes y el encuadre— se lean como escritos por la misma mano,""")
rep("""> escriben directamente con la convención.
""","""> escriben directamente con la convención.

> 🧾 **Lineamientos del repositorio (revisión del 05/10/2026):** el curso es
> anterior a los lineamientos de producción del repositorio. Lo que hace
> distinto de sus valores por defecto, la convención de diagramas en Mermaid
> (D-12), la verificación y lo que falta para cerrarlo están en §17, que se
> agregó después de §16 para no renumerar.
""")
rep("""- **Testing:** https://jestjs.io · https://testing-library.com ·
  https://playwright.dev""","""- **Testing:** https://jestjs.io · https://testing-library.com ·
  https://docs.cypress.io (el smoke de la Fase 10 es Cypress, D6; Playwright
  aparece solo como alternativa moderna 🔥)""")
rep("""- [ ] Lleva el bloque 🏷️ del tag al final, con el nombre correcto (`fase-` o
      `apendice-` + el slug del archivo) y el prefijo de commit correcto
      (§8.1). En los apéndices de consulta pura, el bloque dice que no llevan
      tag propio.
""","""- [ ] Lleva el bloque 🏷️ del tag al final, con el nombre correcto (`fase-` o
      `apendice-` + el slug del archivo) y el prefijo de commit correcto
      (§8.1). En los apéndices de consulta pura, el bloque dice que no llevan
      tag propio.
- [ ] Todo diagrama nuevo va en Mermaid (§17.1); árboles de archivos, salidas
      de terminal, registros de DevTools y anatomías se quedan en texto.
- [ ] `python3 prompts/verificar-corpus.py` sin errores ni avisos nuevos (§17.3).
""")
open(p,"w",encoding="utf-8").write(t)
EOF
grep -n "playwright" ../00-alcance-del-proyecto.md ../10-testing-minimo.md ../11*.md ../A8*.md | head

# --- 2026-10-06T00:06:53 · 
python3 - <<'EOF'
p="guia-de-estilo-y-convenciones.md"
t=open(p,encoding="utf-8").read()
a="""  https://docs.cypress.io (el smoke de la Fase 10 es Cypress, D6; Playwright
  aparece solo como alternativa moderna 🔥)"""
b="""  https://docs.cypress.io (el smoke de la Fase 10 es Cypress, D6; el alcance
  nombra Playwright como alternativa, pero ninguna fase lo usa)"""
assert t.count(a)==1; t=t.replace(a,b); open(p,"w",encoding="utf-8").write(t)
EOF

# --- 2026-10-06T00:07:13 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n "be-fase\|fase-be" 00-convencion-de-git-y-tags.md | head -5; echo; for f in 04-rifas-crud.md be03-crud-y-el-reemplazo.md A10-aritmetica-de-dinero.md; do echo "$f details=$(grep -c '<details>' $f) rubrica=$(grep -ci 'rúbrica\|criterio' $f)"; done; grep -l "🪞" *.md | head; grep -l "⚰️" *.md | head; grep -n -i "cuándo no\|cuando no usar\|no uses" 11-cierre-puente-react-moderno.md A8-puente-a-react-moderno.md | head -5; grep -n -i "verificad\|ejecutad\|corrid" 00-alcance-del-proyecto.md README.md | head -8

# --- 2026-10-06T00:07:16 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n "🪞" 05-venta-de-numeros.md 11-cierre-puente-react-moderno.md | head -3; grep -n "⚰️" *.md | head -3; grep -n "^## \|^### " 11-cierre-puente-react-moderno.md | head -30; sed -n 125,140p 00-convencion-de-git-y-tags.md; grep -n "incidente\b\|solución de referencia" cuaderno-incidentes.md | head -3

# --- 2026-10-06T00:07:30 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n "^#### D\|^### D\|^\*\*D2[0-9]" prompts/decisiones-y-versiones.md | sed -n 13,40p; grep -n "D19" prompts/decisiones-y-versiones.md | head -5; grep -c "" README.md; sed -n 1,13p README.md; sed -n 165,215p README.md

# --- 2026-10-06T00:08:21 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs/prompts && cat >> guia-de-estilo-y-convenciones.md <<'EOF'

---

## 17. 🧾 Excepciones a los lineamientos del repositorio

> 📝 **Sección agregada el 05/10/2026**, en la revisión del curso contra los
> lineamientos de producción del repositorio. Va después de §16 para no
> renumerar: el resto de `prompts/` y varias fases citan esta guía por número
> de sección. El curso es anterior a esos lineamientos; casi todo lo que aquí
> se declara ya era su práctica, y desde ahora está escrito como decisión.

El `CLAUDE.md` del repositorio da **valores por defecto**, y esta guía los
reemplaza donde lo declara: la regla general, el valor de este curso y por qué.
Lo que esta sección no menciona se hereda tal cual.

| Regla general del repositorio | Lo que hace este curso | Por qué |
|---|---|---|
| Comentarios dentro del código en inglés | **En español** (§4); identificadores, rutas y tablas en inglés | El comentario es el canal del *porqué*, y el curso piensa en español |
| Forma de lección setup → conceptos → antipatrones → traducción → ejercicios → veredicto | **La plantilla de nueve secciones de §8**, cerrada con «La señal de que quedó bien» y el bloque 🏷️ | Es un curso de mantenimiento: el veredicto no es cuándo no usar React 16, sino cuándo no modernizar. Lo dan la Fase 11 (§4 y §5.5), A8 y A12 |
| 20–30 ejercicios por sección | **25 a 35 por fase** (§9) y 5–10 por apéndice. Publicado: 28–30 en el track base, 29–34 en el BE, 6–9 en los apéndices | Media jornada de práctica por fase; 35 es el techo, no la meta |
| Ejercicios con solución de referencia o rúbrica | **Sin solucionario en las fases**: cada enunciado es verificable por sí mismo (§9). La solución de referencia, colapsada, vive en los dos cuadernos de incidentes | El músculo que entrena el curso es el diagnóstico; los incidentes son donde una solución publicada enseña algo |
| `0-ESTRUCTURA-CURSO.md` antes de la primera lección | **`00-alcance-del-proyecto.md`** en la raíz, más el README | Se escribió con ese nombre y lo citan las fases, `instrucciones-del-proyecto.md` y §12; renombrarlo rompe el bloqueo de contenido |
| `BENCHMARKS.md` e `INSTINTOS.md` | **No existen.** Las mediciones van en su fase con sus condiciones (`be09` §8); los instintos del lector de backend, en las analogías de §5.2 y las 📝 Notas de época | El curso mide poco y en contexto; un documento aparte quedaría casi vacío |
| Diccionario de traducción en los dos sentidos | **Dos piezas**: `diccionario-codigo-ingles.md` (español → inglés del código) y las tablas de equivalencia vieja ↔ nueva de A5, A6, A7 y A8 | El paradigma de origen es el backend, y §5.2 limita la analogía a abrir la puerta y decir dónde se rompe |
| Recursos 🪞 ⚰️ 🩻 del `CLAUDE.md` | **🩻 sí; ⚰️ no**: la autopsia la hacen el par 💸 deuda → 💸 pago de deuda (§7.3) y los post-mortems de §13. 🪞 es la retrospectiva del mes, al final del cuaderno de incidentes | La deuda que se declara y se paga es la forma propia del curso de mostrar un antipatrón con su costo |
| Apéndices `a01-…` | **`A1-…` a `A13-…`** en el track base; `bea-NN-…` en el BE, como pide el `CLAUDE.md` | El `CLAUDE.md` admite el estilo viejo en cursos que ya lo usan; §12 explica por qué el BE lleva dos dígitos |
| Tags del track opcional en `be-fase-<slug>` | **`fase-beNN-<slug>`** (§8.1 y `00-convencion-de-git-y-tags.md`) | El curso decidió lo contrario a propósito: `git tag -l 'fase-*'` devuelve las veintidós fases en orden porque los dos tracks comparten repo y línea de tiempo. Cambiarlo rompe el bloqueo de contenido |
| Código ejecutable en `src/` del curso | **No hay `src/`**: el alumno construye la aplicación en su propio repo, fase a fase, y el curso publica los fragmentos | Es la tesis del curso: el código se escribe y se rompe a mano. Por lo mismo no hace falta `.gitignore` de curso para código (§17.4) |
| Fecha de vigencia en cada encabezado | **Sin fecha**: el encabezado de fase dice curso, número de fase y horas (§8) | Las versiones están congeladas en `decisiones-y-versiones.md`; la fecha no promete nada que la congelación no diga ya |
| Diagramas a criterio de quien escribe | **Mermaid**, con las excepciones de §17.1 (D-12) | Pedido explícito del autor en la revisión del 05/10/2026 |
| Callouts 📝 🧭 🧠 ⚠️ 💡 | **Esos, más los de §7** (📚 🪦 y los marcadores 💸 🔥 ⭐ 🏷️) y 🩻 🧪 📓 | 📓 señala, desde una fase, los incidentes que produce. Dos callouts de un solo uso (🔑, 🚀) quedan como están y no se usan en texto nuevo |

### 17.1 D-12 · Diagramas en Mermaid

**Decidido el 05/10/2026 por el autor, en la revisión del curso.** Todo
diagrama nuevo —flujo, estados, secuencia, capas, árbol de decisión— va en un
bloque `mermaid`. Se quedan en texto, porque no son diagramas y en
monoespaciado se leen mejor:

- los **árboles de archivos** (`src/`, `server/`, `mock/`);
- las **salidas de terminal y de logs** (`[req-id …]`, una sesión de `psql`);
- los **registros de acciones de Redux DevTools**, que son una salida que el
  lector tiene que reconocer en su pantalla (F05 §6, incidente 11);
- las **anatomías** de un hash o de un token (`be04`, `bea-04`);
- las **correspondencias** `a → b` (archivo → tag, en
  `00-convencion-de-git-y-tags.md`) y las **cadenas de una sola línea**
  (`borrador → abierta → …`, la cadena de middlewares de `cuaderno-incidentes-be.md`).

Criterios para los que vengan, en el orden en que se eligen:

- **`stateDiagram-v2`** para los ciclos de vida: los estados de un número
  (`available` → `reserved` → `sold`), los de una rifa (`draft` → `open` →
  `closed` → `resolved` → `settled`). Los nombres de estado van en inglés, como
  en el código (§4); las etiquetas de transición, con el nombre de la acción.
- **`sequenceDiagram`** para lo que pasa en el tiempo entre capas: componente →
  store → epic → mock, o navegador → backend Go → PostgreSQL en el track BE.
  Es el diagrama natural de una race condition y del cierre del círculo con
  `X-Request-Id` (§16.4).
- **`flowchart TD`** para cadenas y árboles de decisión; **`LR`** para lo que
  cruza el cable frontend ↔ backend; **`subgraph`** para las capas que §5.5
  pide distinguir (componente, store, epic, backend).
- **Texto de los nodos en español** y nombres de código en inglés, igual que la
  prosa. Caracteres que Mermaid interpreta: `<…>` se escribe `#lt;…#gt;`, `|`
  dentro de un nodo `#124;`, y las etiquetas con paréntesis, dos puntos o
  barras van entre comillas.
- **Cada diagrama se dibuja antes de publicarlo** (`mmdc`, o la vista previa de
  GitHub) y la prosa que lo rodea no lo repite: lo explica.

```mermaid
stateDiagram-v2
    [*] --> available
    available --> reserved: reserve
    reserved --> sold: sell
    reserved --> available: expire
    sold --> [*]
```

> 🧭 **El ejemplo de arriba es el diagrama que tiene que reemplazar** al ASCII de
> la Fase 5 §4 (`available ──reserve──► reserved …`), el único bloque del curso
> publicado que el verificador marca como `DIAGRAMA`. La conversión está en
> §17.4: esta revisión solo tocó `prompts/`.

### 17.2 Documentos de `prompts/` y lo que hace su papel

El curso es anterior a las plantillas de producción y está cerrado, así que no
se crean a posteriori. Esto es lo que cumple cada función:

- **Alcance:** `00-alcance-del-proyecto.md`, en la raíz, porque el lector
  también lo lee. Para el track BE, además, `propuesta-fases-backend.md`.
- **Propuesta de fases y de apéndices:** del track base no se conservó como
  documento aparte; su papel lo hacen el alcance §7 y los bloques de
  `prompts-a-por-fase.md` y `prompts-a-por-apendice.md`. Del BE,
  `propuesta-fases-backend.md` §7 y §8.
- **Plan de producción:** no hay. El curso se escribió antes de que existiera la
  plantilla; su estado vive en el README del curso y en §15.
- **Diccionario de términos:** §3 (qué se queda en inglés) y
  `diccionario-codigo-ingles.md` (el código del dominio).
- **Contrato de nombres:** `decisiones-y-versiones.md` (versiones, el
  `package.json` y el `go.mod` de referencia, puertos), §4.4 y
  `diccionario-codigo-ingles.md` §4 y §7bis (nombrado y rutas), y
  `00-convencion-de-git-y-tags.md` (ramas y tags).
- **Plantillas de capítulo:** `plantilla-de-fase.md`; el formato de apéndice, al
  final de §8.
- **Formatos propios:** `plantilla-de-incidente.md` y `plantilla-de-incidente-be.md`
  (el enunciado), y `preparaciones-de-incidentes.md` y
  `preparaciones-de-incidentes-be.md` (el estado roto de cada rama, que no se
  enlaza desde los cuadernos).
- **Prompts de sesión:** `instrucciones-del-proyecto.md` (el marco común),
  `prompts-a-*` y `prompts-b-*` (track base, en dos tiempos) y
  `prompts-backend-*` (track BE). Son **registro de cómo se escribió**: donde
  contradicen a una fase publicada, gana la fase. El caso conocido es el de
  `bea-02`, cuyo prompt pide runtime Debian por cgo; la fase `be09` resolvió
  D19 con una etiqueta de compilación, y el apéndice publicado recoge las dos
  versiones. Las decisiones D24–D28 nacieron al escribir el track y no están en
  sus prompts.
- **Manual de operación:** `prompts/README.md`.

### 17.3 Verificación

Desde la raíz del curso, y ninguna toca nada:

```bash
python3 prompts/verificar-corpus.py                 # validaciones base + aviso DIAGRAMA
python3 prompts/verificar-corpus.py --publicacion   # además, lo que exige el repositorio público
```

- `verificar-corpus.py` es la subclase del perfil `courses-ia` de
  `verificador_base.py` (copia de la base de los lineamientos), con los callouts
  y el emoji en `###` de esta guía y el encabezado de §8. Su aviso `DIAGRAMA`
  marca un bloque sin lenguaje o `text` con puntas de flecha o esquinas de caja
  en dos líneas; un diagrama dibujado solo con `├─` y `│` se le escapa, y se
  revisa a mano.
- `--publicacion` agrega los errores de la etapa de publicación: ningún enlace a
  `prompts/` ni mención de material privado, y el error propio `CITA-PROMPTS`,
  que marca cada documento publicado que **nombra** un archivo de `prompts/`
  aunque no lo enlace.
- **Línea base del 05/10/2026**: sin `--publicacion`, 3 errores `ANCLA-FE0F` y 1
  aviso `DIAGRAMA`; con `--publicacion`, además 56 `CITA-PROMPTS`. Todos son
  del curso publicado y están en §17.4.

### 17.4 Lo que falta para cerrar y publicar el curso

El contenido está completo: doce fases, trece apéndices, el track BE (diez fases
y diez apéndices) y los dos cuadernos de incidentes (veinte y dieciséis). Lo que
sigue es lo que la revisión del 05/10/2026 encontró y no corrigió, porque solo
tocó `prompts/`. Cada punto es una edición del curso, no de esta carpeta.

1. **⚖️ El curso remite al lector a `prompts/`, que no se publica.** 56 menciones
   en 32 documentos, todos en prosa o en código, ninguna como enlace: 40 a
   `decisiones-y-versiones.md` («Lo citan: todas las fases y apéndices»), 10 a
   `diccionario-codigo-ingles.md`, y las demás a esta guía,
   `propuesta-fases-backend.md` y `plantilla-de-incidente-be.md`. El README las
   presenta como fuentes de verdad del lector. Es el bloqueo de la etapa de
   publicación, y la decisión es del autor. **Propuesta:** subir
   `decisiones-y-versiones.md` a la raíz del curso como documento de consulta
   del lector (es lo que ya es) y reescribir las menciones a los otros cuatro
   como prosa o como cita al documento publicado que dice lo mismo
   (§4 → `README.md` §Convenciones, el diccionario → el glosario mínimo de §4.3
   llevado a la Fase 1). Mover un documento de referencia no es renombrar una
   fase, así que no rompe el bloqueo de contenido; sí obliga a actualizar §11,
   §12 y las fuentes de verdad de `instrucciones-del-proyecto.md` en la misma
   edición.
2. **Tres enlaces `ANCLA-FE0F`** en A4 (línea 35) y A5 (líneas 14 y 22):
   encabezados con ⚖️ o ⚠️ cuyo ancla se escribió sin el U+FE0F. Se corrigen
   con `python3 prompts/verificador_base.py . --perfil=courses-ia --corregir-fe0f`.
3. **El diagrama de la Fase 5 §4** pasa a Mermaid con el `stateDiagram-v2` de
   §17.1.
4. **No consta qué salidas se ejecutaron.** El curso no lleva fecha de
   verificación ni casillas de corrida; si el autor no las corrió todas, se
   declara en el README como en otros cursos del repositorio («salidas
   ilustrativas»), y si las corrió, se dice con fecha.
5. **Checklist de la etapa de publicación** que el curso todavía no cumple: un
   `.gitignore` mínimo en la raíz del curso (no hay código, pero sí un
   `.DS_Store` en el directorio), la licencia, y un README que se sostenga sin
   `prompts/` (consecuencia del punto 1).
6. **Fuera del curso:** el README raíz del repositorio describe un
   `react-16-legacy` que ya no existe con ese nombre ni con esa forma (habla de
   hooks y de un proyecto integrador). Se corrige allí, no aquí.
EOF

# --- 2026-10-06T00:08:31 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -l "prompts/[a-z0-9-]*\.md" *.md | wc -l; grep -o "prompts/[a-z0-9-]*\.md" *.md | wc -l; awk 'NR<=52 && /^## /{h=$0} NR==52{print "05:52 ->",h}' 05-venta-de-numeros.md; awk 'NR<=570 && /^## /{h=$0} NR==570{print "05:570 ->",h}' 05-venta-de-numeros.md; grep -n "^## " A4-cra-por-dentro.md | sed -n 8,9p; grep -n "^## " A5-class-components-vs-hooks.md | sed -n 3p; grep -n "^## " A5-class-components-vs-hooks.md | sed -n 11p; grep -n "^## " 00-alcance-del-proyecto.md; which mmdc npx docker 2>/dev/null

# --- 2026-10-06T00:08:35 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n "^## 3\.\|^## 11\." A5-class-components-vs-hooks.md; sed -n 137,156p 00-alcance-del-proyecto.md | head -8; grep -n "^## " 10-testing-minimo.md | head -3

# --- 2026-10-06T00:08:46 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs/prompts && python3 - <<'EOF'
p="guia-de-estilo-y-convenciones.md"
t=open(p,encoding="utf-8").read()
def rep(a,b):
    global t
    assert t.count(a)==1,a
    t=t.replace(a,b)
rep("encabezados con ⚖️ o ⚠️ cuyo ancla","encabezados con 🗺️ o ⚠️ cuyo ancla")
rep("56 menciones\n   en 32 documentos","56 menciones\n   en 33 documentos")
rep("""  documento aparte; su papel lo hacen el alcance §7 y los bloques de""","""  documento aparte; su papel lo hacen el alcance (§6 y §7) y los bloques de""")
rep("""   publicación, y la decisión es del autor. **Propuesta:** subir
   `decisiones-y-versiones.md` a la raíz del curso como documento de consulta
   del lector (es lo que ya es) y reescribir las menciones a los otros cuatro
   como prosa o como cita al documento publicado que dice lo mismo
   (§4 → `README.md` §Convenciones, el diccionario → el glosario mínimo de §4.3
   llevado a la Fase 1). Mover un documento de referencia no es renombrar una
   fase, así que no rompe el bloqueo de contenido; sí obliga a actualizar §11,
   §12 y las fuentes de verdad de `instrucciones-del-proyecto.md` en la misma
   edición.""","""   publicación, y la decisión es del autor. **Propuesta:** subir
   `decisiones-y-versiones.md` a la raíz del curso como documento de consulta
   del lector, que es lo que ya es, y reescribir las menciones a los otros
   cuatro en prosa, sin nombrar el archivo, donde el lector no los necesita.
   El diccionario es el caso dudoso: diez menciones, casi todas en el track BE;
   si el lector lo necesita, sube también. Mover un documento de referencia no
   es renombrar una fase, así que no rompe el bloqueo de contenido; sí obliga a
   actualizar §11, §12, §17.2 y las fuentes de verdad de
   `instrucciones-del-proyecto.md` en la misma edición.""")
open(p,"w",encoding="utf-8").write(t)
EOF
Z=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/react-16-legacy-for-backend-devs-20261005-cbd3/salidas
printf 'stateDiagram-v2\n    [*] --> available\n    available --> reserved: reserve\n    reserved --> sold: sell\n    reserved --> available: expire\n    sold --> [*]\n' > $Z/estados-numero.mmd
cd $Z && mmdc -i estados-numero.mmd -o estados-numero.svg 2>&1 | tail -2; ls -la $Z

# --- 2026-10-06T00:09:00 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs/prompts && python3 - <<'EOF'
p="instrucciones-del-proyecto.md"
t=open(p,encoding="utf-8").read()
def rep(a,b):
    global t
    assert t.count(a)==1,a
    t=t.replace(a,b)
rep("""suscripciones sin cancelar, hotfixes y pruebas de regresión. El curso tiene
15-20 incidentes simulados; al menos 4 sobre RxJS/epics. Cada incidente:""","""suscripciones sin cancelar, hotfixes y pruebas de regresión. El track base
tiene 20 incidentes simulados en cuaderno-incidentes.md (al menos 4 sobre
RxJS/epics) y el track BE 16 en cuaderno-incidentes-be.md. Cada incidente:""")
rep("""antes que tablas en comparativas extensas; tablas solo para lo corto y
genuinamente tabular, tres columnas como máximo. Código""","""antes que tablas en comparativas extensas; tablas solo para lo corto y
genuinamente tabular, cuatro columnas como máximo y ninguna celda de más de
una línea. Diagramas (flujo, estados, secuencia, capas) en Mermaid; árboles
de archivos, salidas de terminal, registros de DevTools y anatomías de un
token se quedan en texto (guía §17.1). Código""")
rep("""actuar siguiendo""","""actuar siguiendo""") if "actuar siguiendo" in t else None
rep("""instrucciones, (2) 00-alcance-del-proyecto.md, (3) prompts/decisiones-y-versiones.md
para cualquier versión o decisión técnica, (4)""","""instrucciones, (2) 00-alcance-del-proyecto.md, (3) prompts/decisiones-y-versiones.md
para cualquier versión o decisión técnica y 00-historia-del-sistema.md para
cualquier porqué del sistema, (4)""")
rep("""4. Si ya tienes fases escritas con identificadores en español, ajústalas
   primero (ver `prompts/guia-de-estilo-y-convenciones.md` §4.6) antes de que
   sirvan de referencia a fases nuevas.""","""4. Si ya tienes fases escritas con identificadores en español, ajústalas
   primero (ver `prompts/guia-de-estilo-y-convenciones.md` §4.6) antes de que
   sirvan de referencia a fases nuevas.
5. Al cerrar cualquier edición, corre `python3 prompts/verificar-corpus.py`
   desde la raíz del curso (guía §17.3).

> 📝 **Estado al 05/10/2026:** el curso está escrito entero y este bloque queda
> como registro de cómo se produjo y como marco para editarlo. Lo que el
> curso hace distinto de los lineamientos del repositorio, y lo que falta para
> cerrarlo, está en la guía §17; el manual de esta carpeta, en
> `prompts/README.md`.""")
open(p,"w",encoding="utf-8").write(t)
EOF
grep -n "Mermaid\|cuatro columnas\|historia-del-sistema.md para" instrucciones-del-proyecto.md

# --- 2026-10-06T00:09:04 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs/prompts; sed -n 150,179p plantilla-de-fase.md; echo ======; sed -n 220,246p plantilla-de-incidente.md; echo =====; sed -n 194,212p plantilla-de-incidente-be.md

# --- 2026-10-06T00:09:06 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs/prompts; tail -12 plantilla-de-incidente.md; echo; echo XXXXX; tail -12 plantilla-de-incidente-be.md

# --- 2026-10-06T00:09:14 · 
python3 - <<'EOF'
def app(p,a,b):
    t=open(p,encoding="utf-8").read()
    assert t.count(a)==1,(p,a); t=t.replace(a,a+b); open(p,"w",encoding="utf-8").write(t)
app("plantilla-de-fase.md","""- Autocontenido (guía §11): cada referencia cruzada resuelve a un archivo real,
  ninguna decisión queda "pendiente de confirmar", cero dependencias externas.
""","""- **Diagramas en Mermaid** (guía §17.1): `stateDiagram-v2` para ciclos de vida,
  `sequenceDiagram` para lo que pasa entre capas, `flowchart` para el resto. Los
  árboles de archivos, las salidas de terminal y los registros de DevTools se
  quedan en texto. Cada diagrama se dibuja antes de darlo por bueno.
- Al cerrar, `python3 prompts/verificar-corpus.py` desde la raíz del curso
  (guía §17.3).
""")
app("plantilla-de-incidente.md","""- **Nada de culpabilización** en el post-mortem, ni siquiera implícita (guía §13).
""","""- **Si el enunciado o la solución necesitan un diagrama**, va en Mermaid (guía §17.1):
  una race condition se dibuja como `sequenceDiagram` entre componente, store, epic y mock.
  La secuencia de acciones tal como la muestra Redux DevTools no es un diagrama: es la
  evidencia que el alumno tiene que reconocer en su pantalla, y se queda en texto.
""")
app("plantilla-de-incidente-be.md","""- **Nada de culpabilización** en el post-mortem, ni siquiera implícita (guía §13).
""","""- **Si el enunciado o la solución necesitan un diagrama**, va en Mermaid (guía
  §17.1): `sequenceDiagram` entre navegador, backend y PostgreSQL para lo que
  ocurre en el tiempo. Los logs con `X-Request-Id`, las salidas de `psql` y de
  `go test -race` son evidencia literal y se quedan en texto.
""")
EOF

# --- 2026-10-06T00:09:43 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; Z=../../zz-code/react-16-legacy-for-backend-devs-20261005-cbd3/salidas; awk '/^```mermaid/{f=1;next} /^```/{f=0} f' prompts/README.md > $Z/autoridad.mmd; (cd $Z && mmdc -i autoridad.mmd -o autoridad.svg 2>&1 | tail -1); python3 prompts/verificar-corpus.py | tail -3; python3 prompts/verificar-corpus.py --publicacion | tail -1; grep -rl "Ã\|â€" prompts/ ; python3 -c "import ast;ast.parse(open('prompts/verificar-corpus.py').read())" && echo ok

# --- 2026-10-06T00:09:49 · 
cat /Users/oskar/Developer/Learning/courses-ia-generated/zz-code/react-16-legacy-for-backend-devs-20261005-cbd3/MANIFIESTO.md

# --- 2026-10-06T00:09:56 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; git status --short cursos-legacy/react-16-legacy-for-backend-devs zz-code/react-16-legacy-for-backend-devs-20261005-cbd3; git diff --stat cursos-legacy/react-16-legacy-for-backend-devs

# --- 2026-10-06T00:10:05 · 
cd /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory && cat >> track-be-react16-escrito.md <<'EOF'

**Revisión contra `zz-instrucciones/` (05/10/2026, solo `prompts/`, sin commit: lo hace Oskar).**
Oskar pidió no tocar el curso. Se agregó la guía §17 (excepciones, D-12 Mermaid con
`stateDiagram-v2`/`sequenceDiagram`, papel de cada plantilla, verificación, lo que falta),
`prompts/README.md`, `verificar-corpus.py` + copia de `verificador_base.py` (error propio
`CITA-PROMPTS` con `--publicacion`), y ajustes en `instrucciones-del-proyecto.md` y las tres
plantillas. Línea base: 3 `ANCLA-FE0F` (A4, A5) + 1 `DIAGRAMA` (F05 §4); con `--publicacion`, 56
`CITA-PROMPTS`. **Para cerrar (guía §17.4), pendiente de decisión de Oskar:** el curso remite al
lector a `prompts/decisiones-y-versiones.md` (40 menciones) y otros de `prompts/`, que no se
publica; propuesta: subir `decisiones-y-versiones.md` a la raíz. Tampoco consta si las salidas se
ejecutaron. Ver [[docker-legacy-complemento-geek]] para el mismo patrón.
EOF
python3 - <<'EOF'
p="MEMORY.md"
t=open(p,encoding="utf-8").read()
a="- [Track BE de React 16 escrito](track-be-react16-escrito.md) — curso completo: track BE (10 fases + 10 apéndices) y los dos cuadernos de incidentes (20 base + 16 BE); decisiones D24–D28."
b="- [Track BE de React 16 escrito](track-be-react16-escrito.md) — contenido completo; prompts/ revisado contra zz-instrucciones el 05/10/2026 (guía §17, Mermaid); para cerrar falta sacar las citas a prompts/ del curso."
assert a in t; open(p,"w",encoding="utf-8").write(t.replace(a,b))
EOF

# --- 2026-10-06T00:21:12 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n "prompts/" *.md | cut -c1-400

# --- 2026-10-06T00:21:22 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; show(){ sed -n "$2,$3p" $1; echo "------ $1"; }; show 00-convencion-de-git-y-tags.md 25 31; show 00-alcance-del-proyecto.md 118 132; show 00-alcance-del-proyecto.md 148 153; show 00-alcance-del-proyecto.md 176 186; show 03-mock-api-express-caos.md 33 39; show 07-cierre-polling-resultado.md 62 63

# --- 2026-10-06T00:21:27 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n -i "date-fns\|luxon\|dayjs\|day.js\|dinero.js\|big.js\|librería de fechas\|librería de dinero" prompts/decisiones-y-versiones.md | head; show(){ sed -n "$2,$3p" $1; echo "------ $1"; }; show 07-cierre-polling-resultado.md 664 670; show 08-liquidacion-calculo-premio.md 855 862; show A10-aritmetica-de-dinero.md 343 349; show A12-mapa-de-deuda-tecnica.md 214 222; show A12-mapa-de-deuda-tecnica.md 334 342

# --- 2026-10-06T00:21:35 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; show(){ sed -n "$2,$3p" $1; echo "------ $1"; }; show be00-el-contrato-auditoria-del-mock.md 760 770; show be01-go-y-la-forma-del-monolito.md 1098 1108; show be02-la-costura-de-datos.md 1060 1078; show be03-crud-y-el-reemplazo.md 1004 1012; show be05-venta-concurrente.md 844 858; show be06-hora-dura-y-la-autoridad-del-reloj.md 760 767; show be07-liquidacion-dinero-entero-y-transaccional.md 722 730; show be09-empaquetado-ambientes-y-pipeline.md 770 777

# --- 2026-10-06T00:21:45 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n "CONTRACT.md\|smoke.sh\|evidence\|sqlStore\|Sale\b\|soldBy\|PrizePayout\|TotalCollected" prompts/diccionario-codigo-ingles.md | head; echo; grep -n "mock-retirado\|America/Bogota\|TZ=UTC" prompts/decisiones-y-versiones.md 00-convencion-de-git-y-tags.md | head

# --- 2026-10-06T00:21:50 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n "mock-retirado" *.md | cut -c1-200 | head; grep -n "pre-backend-go" 00-convencion-de-git-y-tags.md | head -3; grep -n "TZ=UTC\|America/Bogota" be06-hora-dura-y-la-autoridad-del-reloj.md | head -5; grep -n "^## " be06-hora-dura-y-la-autoridad-del-reloj.md

# --- 2026-10-06T00:21:56 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; sed -n 136,160p 00-convencion-de-git-y-tags.md; echo -----; sed -n 774,785p be09-empaquetado-ambientes-y-pipeline.md; echo ----; sed -n 136,146p be06-hora-dura-y-la-autoridad-del-reloj.md; sed -n 988,997p be03-crud-y-el-reemplazo.md

# --- 2026-10-06T00:21:58 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n "track-be-completo" *.md | cut -c1-220

# --- 2026-10-06T00:22:11 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; show(){ sed -n "$2,$3p" $1; echo "------ $1"; }; show be01-go-y-la-forma-del-monolito.md 29 34; show be02-la-costura-de-datos.md 164 170; show be02-la-costura-de-datos.md 222 226; show README.md 128 136; show cuaderno-incidentes-be.md 16 23; show cuaderno-incidentes.md 205 212

# --- 2026-10-06T00:22:14 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; awk 'NR<=188 && /^###? /{h=$0} NR==188{print h}' be01-go-y-la-forma-del-monolito.md; sed -n 405,428p prompts/diccionario-codigo-ingles.md; grep -n "^## \|^### " cuaderno-incidentes-be.md | head -8

# --- 2026-10-06T00:22:18 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; ls 00-decisiones-y-versiones.md 2>/dev/null; mv prompts/decisiones-y-versiones.md 00-decisiones-y-versiones.md && ls 00-*

# --- 2026-10-06T00:22:22 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; sed -n 343,370p A10-aritmetica-de-dinero.md; grep -n "Intl\|date-fns\|nativo" 07-cierre-polling-resultado.md | head -12

# --- 2026-10-06T00:22:43 · 
python3 - <<'EOF'
p="00-decisiones-y-versiones.md"
t=open(p,encoding="utf-8").read()
def rep(a,b):
    global t
    assert t.count(a)==1,a
    t=t.replace(a,b)
rep("""Antes de que existiera, las decisiones circulaban como códigos `D1`…`D13`
repartidos por diez archivos y una cita a un `DECISIONES-CONFIRMADAS.md` que
nunca se escribió. Eso convertía cada duda de versión en arqueología. Acá está
todo junto, con el porqué al lado.""","""En un sistema real, estas decisiones suelen estar repartidas entre un
`package.json`, tres hilos de correo y la memoria de alguien que ya no está.
Eso convierte cada duda de versión en arqueología. Acá está todo junto, con el
porqué al lado.""")
rep("""El detalle completo de entornos, contenedores y paridad con producción vive en
`A9-entornos-y-contenedores.md`.

---
""","""El detalle completo de entornos, contenedores y paridad con producción vive en
`A9-entornos-y-contenedores.md`.

---

### Lo que se decidió no adoptar: librería de fechas y librería de dinero

Dos dependencias que cualquiera esperaría encontrar y que el proyecto **no
tiene**, a propósito. Que no estén es una decisión, no un olvido, y por eso
vive acá.

**Fechas: sin `date-fns`, `luxon` ni `Day.js`.** La Fase 7 resuelve la hora
dura de cierre con `Date` nativo: para *comparar dos instantes* basta con
milisegundos desde epoch, y `a.getTime() > b.getTime()` es exacto. Una librería
recién gana cuando hay que *formatear* o *hacer aritmética de calendario* en una
zona horaria ("cierra en 2h 15m", "un día hábil"), y eso queda como ejercicio 🔥
de la Fase 7. **Qué la vuelve revisable:** que la presentación de fechas en
zona del usuario pase a ser parte del código principal.

**Dinero: sin `dinero.js`, `big.js` ni `decimal.js`.** Los montos van en enteros
de centavos (Fase 8 y `A10-aritmetica-de-dinero.md`): una sola moneda, montos
que caben de sobra en el entero seguro, y operaciones que son sumar,
multiplicar por un entero y dividir con resto. **Qué la vuelve revisable:**
varias monedas con subdivisiones distintas, conversión de divisas o montos que
puedan desbordar el entero seguro. A10 §7 cuenta el razonamiento completo.

---
""")
rep("""de nada de acá**. El encuadre completo —justificación, fases y horas— vive en
`prompts/propuesta-fases-backend.md`.""","""de nada de acá**. El encuadre —por qué existe el track, qué deuda cobra cada
fase y cuántas horas lleva— está en el README del curso (§Track BE) y en
`be00-el-contrato-auditoria-del-mock.md`.""")
rep("""**Qué la vuelve revisable.** Un segundo archivado sin sucesor claro. Verifica el
estado del repositorio al escribir la fase; no lo cites de memoria.""","""**Qué la vuelve revisable.** Un segundo archivado sin sucesor claro. Verifica el
estado del repositorio cuando lo leas; no lo cites de memoria.""")
rep("""⚠️ Cita el identificador del CVE y las fechas desde el aviso oficial. No los
escribas de memoria.""","""⚠️ El identificador del CVE y sus fechas salen del aviso oficial, que es lo que
cita `be04`. Si los necesitas para un post-mortem, cítalos desde ahí y no de
memoria.""")
rep("""**Qué la vuelve revisable.** Nada dentro del track. Volver al modelo de estado
implicaría renunciar al índice único, que es el punto.

---
""","""**Qué la vuelve revisable.** Nada dentro del track. Volver al modelo de estado
implicaría renunciar al índice único, que es el punto.

---

#### D29 — El proceso corre en UTC; la zona de Bogotá es solo de presentación

**Qué se fijó.** En `be06`: el proceso corre con `TZ=UTC`, todo instante se
guarda en `TIMESTAMPTZ` y toda comparación se hace entre instantes. La sesión de
base fija `TimeZone=America/Bogota` **solo** para que la serialización de salida
coincida con el contrato que el frontend ya consume. El borde del cierre es el
mismo que en el frontend: `now >= closesAt` significa cerrada, heredado de
`isPastClosing`.

📝 **Por qué con esa jerarquía.** La zona de presentación no participa en
ninguna decisión. Un servidor que compara en hora local depende del reloj y de
la configuración de la máquina donde corre, y eso es exactamente el incidente
que `be06` reproduce.

📎 **Consecuencias.** `be07` liquida comparando instantes, `be08` prueba el
borde del cierre contra PostgreSQL (la regla del motor de `D18`) y `be09` fija
`TZ=UTC` en la imagen y en el pipeline.

**Qué la vuelve revisable.** Que el contrato cambie a UTC explícito (`Z`) en la
salida. Ahí la sesión de base deja de necesitar la zona, y el frontend tiene que
aceptarlo primero.

---
""")
rep("## 7. Track BE (opcional) — decisiones D14–D23 🔥","## 7. Track BE (opcional) — decisiones D14–D29 🔥")
open(p,"w",encoding="utf-8").write(t)
EOF
grep -n "D14–D2\|D1–D13\|D1-D13" 00-decisiones-y-versiones.md *.md | cut -c1-200 | head -20

# --- 2026-10-06T00:22:50 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n "TZ=UTC\|TZ: UTC\|ENV TZ\|TZ=" be09*.md bea-02*.md | head; echo ---; grep -n -i "closesAt\|cierre\|instante" be08*.md | head -8; echo ---; grep -n -i "closesAt\|instante\|cerrada" be07*.md | head -6; grep -n "incidente\|UTC" be06-hora-dura-y-la-autoridad-del-reloj.md | sed -n 1,8p | cut -c1-160

# --- 2026-10-06T00:23:00 · 
python3 - <<'EOF'
p="00-decisiones-y-versiones.md"
t=open(p,encoding="utf-8").read()
a="""📝 **Por qué con esa jerarquía.** La zona de presentación no participa en
ninguna decisión. Un servidor que compara en hora local depende del reloj y de
la configuración de la máquina donde corre, y eso es exactamente el incidente
que `be06` reproduce.

📎 **Consecuencias.** `be07` liquida comparando instantes, `be08` prueba el
borde del cierre contra PostgreSQL (la regla del motor de `D18`) y `be09` fija
`TZ=UTC` en la imagen y en el pipeline."""
b="""📝 **Por qué con esa jerarquía.** La zona de presentación no participa en
ninguna decisión. Un servidor que compara en hora local depende de la
configuración de la máquina donde corre, y el mismo binario decide distinto en
tu laptop y en el contenedor.

📎 **Consecuencias.** `main.go` fija `TZ=UTC` al arrancar (`be06` §5), así que
la decisión no depende de la imagen ni del runner. `be08` prueba la comparación
de instantes contra PostgreSQL (la regla del motor de `D18`) y comprueba que
`closesAt` sale con offset y no con `Z`."""
assert t.count(a)==1; t=t.replace(a,b); open(p,"w",encoding="utf-8").write(t)
EOF

# --- 2026-10-06T00:23:05 · 
python3 - <<'EOF'
import glob
n=0
for f in glob.glob("*.md"):
    t=open(f,encoding="utf-8").read()
    c=t.count("prompts/decisiones-y-versiones.md")
    if c:
        n+=c; open(f,"w",encoding="utf-8").write(t.replace("prompts/decisiones-y-versiones.md","00-decisiones-y-versiones.md"))
print(n)
EOF
grep -n "prompts/" *.md | cut -c1-160

# --- 2026-10-06T00:23:13 · 
sed -n 205,214p README.md && sed -n 8,13p README.md && sed -n 172,178p README.md && grep -n "D14–D23\|D14-D23\|D1–D28\|D14–D28" *.md | cut -c1-150

# --- 2026-10-06T00:23:18 · 
sed -n 55,100p README.md

# --- 2026-10-06T00:23:36 · 
python3 - <<'EOF'
def ed(p,pairs):
    t=open(p,encoding="utf-8").read()
    for a,b in pairs:
        assert t.count(a)==1,(p,a); t=t.replace(a,b)
    open(p,"w",encoding="utf-8").write(t)

ed("00-alcance-del-proyecto.md",[
("""- **Editorial**, en `prompts/`: `decisiones-y-versiones.md` (versiones y
  decisiones D1-D13), `guia-de-estilo-y-convenciones.md`,
  `diccionario-codigo-ingles.md`, `plantilla-de-fase.md` y los `prompts-*.md`
  de redacción.""","""- **De consulta**, en la raíz: `00-decisiones-y-versiones.md` (versiones,
  `package.json` y `go.mod` de referencia, puertos y las decisiones D1–D29) y
  `00-convencion-de-git-y-tags.md` (ramas, tags y commits)."""),
("""  encuadre completo está en `prompts/propuesta-fases-backend.md`.""","""  encuadre completo está en el README del curso (§Track BE) y en `be00`."""),
("""D14–D23, su `go.mod` y su cuarto puerto, en la §7 de ese archivo.""","""D14–D29, su `go.mod` y su cuarto puerto, en la §7 de ese archivo."""),
])
ed("00-convencion-de-git-y-tags.md",[
("""(`prompts/propuesta-fases-backend.md` §9). Un repo, dos mundos, una raya en la
arena entre ellos.""","""(`be01-go-y-la-forma-del-monolito.md` §5.1). Un repo, dos mundos, una raya en la
arena entre ellos."""),
("""El segundo importa más de lo que parece.""","""El segundo importa más de lo que parece."""),
])
ed("03-mock-api-express-caos.md",[
("""> mensaje al usuario. El detalle está en `prompts/diccionario-codigo-ingles.md`.""",
"""> mensaje al usuario. Los términos del dominio y su nombre en código están en
> el README del curso (§Convenciones)."""),
])
ed("07-cierre-polling-resultado.md",[
("""Los nombres heredados están congelados por la nota de continuidad Fase 6 → Fase 7 y el `prompts/diccionario-codigo-ingles.md`: código en inglés, comentarios y UI en español.""",
"""Los nombres heredados están congelados por la nota de continuidad Fase 6 → Fase 7 y la convención del README (§Convenciones): código en inglés, comentarios y UI en español."""),
])
ed("be01-go-y-la-forma-del-monolito.md",[
("""      dependencia; el layout de `server/` creado según
      `prompts/diccionario-codigo-ingles.md` §7bis.3.""","""      dependencia; el layout de `server/` creado según el árbol de §5.1."""),
])
ed("be02-la-costura-de-datos.md",[
("""como fija `prompts/diccionario-codigo-ingles.md` §7bis.1. No es capricho ni""","""como fija la convención de nombres del backend (README, §Convenciones). No es capricho ni"""),
("""-- Convenciones (prompts/diccionario-codigo-ingles.md §7bis.2):""","""-- Convenciones de nombres del backend:"""),
])
ed("README.md",[
("""Se puede empezar **en cuanto termines la Fase 8**. El encuadre completo
—justificación, alcance y programa— está en
`prompts/propuesta-fases-backend.md`.""","""Se puede empezar **en cuanto termines la Fase 8**. Las versiones y las decisiones
propias del track (D14–D29) están en la §7 de `00-decisiones-y-versiones.md`."""),
("""latinoamericano con tuteo**. El detalle está en
`prompts/guia-de-estilo-y-convenciones.md`, que es la fuente de verdad
editorial, y el diccionario de términos del dominio en
`prompts/diccionario-codigo-ingles.md`.""","""latinoamericano con tuteo**. Para no dudar al nombrar algo, estos son los
términos del dominio y su nombre en código:

| En el curso | En el código | En la base (track BE) |
|---|---|---|
| rifa | `raffle` | `raffles` |
| número | `number` | `raffle_numbers` |
| venta | `Sale`, `sellNumber` | `sales` |
| participante | `participant` | `participants` |
| resultado | `result` | — |
| liquidación | `settlement` | `settlements` |
| pago del premio | `PrizePayout` | `prize_payouts` |
| hora de cierre | `closesAt` | `closes_at` |

Los estados de una rifa son `draft` → `open` → `closed` → `resolved` →
`settled`, y los de un número, `available` → `reserved` → `sold`. Los nombres
se arman con esos términos y verbos en inglés: `fetchRaffles`, `sellNumber`,
`raffleSlice`, `pollingEpic`, `selectOpenRaffles`. En el backend, las tablas van
en plural y `snake_case`, las etiquetas JSON en `camelCase` como las consume el
frontend, y la columna puede llamarse distinto que la etiqueta
(`raffle_numbers` frente a `numbers`): la etiqueta es el contrato, la columna
no."""),
])
EOF
grep -n "^| \|closes_at\|participants\|settlements\b" prompts/diccionario-codigo-ingles.md | sed -n 1,60p | grep -i "raffle\|number\|sale\|particip\|result\|settle\|prize\|clos" | head -20

# --- 2026-10-06T00:23:40 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; sed -n 366,400p prompts/diccionario-codigo-ingles.md; grep -n "closesAt\|closingTime" prompts/diccionario-codigo-ingles.md | head -4; grep -c "closesAt" 0*.md 1*.md | grep -v ":0" | head -3; grep -c "closingTime" 0*.md 1*.md | grep -v ":0" | head -3

# --- 2026-10-06T00:23:58 · 
python3 - <<'EOF'
def ed(p,pairs):
    t=open(p,encoding="utf-8").read()
    for a,b in pairs:
        assert t.count(a)==1,(p,a); t=t.replace(a,b)
    open(p,"w",encoding="utf-8").write(t)
ed("be00-el-contrato-auditoria-del-mock.md",[(
"""- **Registrar en `prompts/diccionario-codigo-ingles.md` §7bis.3** las dos rutas
  nuevas que introduce esta fase: `server/CONTRACT.md` y `server/smoke.sh`, más
  el directorio `server/evidence/`. Hecho al escribir la fase; verificar que
  sobrevive a futuras ediciones del diccionario.""",
"""- ✅ **Resuelto: las rutas nuevas que introduce esta fase** —`server/CONTRACT.md`,
  `server/smoke.sh` y el directorio `server/evidence/`— quedaron fijadas como
  rutas canónicas del backend, y `be01` §5.1 las incluye en el árbol de
  `server/`.""")])
ed("be01-go-y-la-forma-del-monolito.md",[(
"""- **Registrar en `00-decisiones-y-versiones.md` §7.4** la variable `PORT` y
  la convención del puerto de transición""",
"""- ✅ **Registrado en `00-decisiones-y-versiones.md` como `D24`:** la variable `PORT` y
  la convención del puerto de transición""")])
ed("be02-la-costura-de-datos.md",[(
"""- **Registrar en `prompts/diccionario-codigo-ingles.md` §7bis.2** la aclaración de
  nombres de store:""",
"""- ✅ **Resuelto: la aclaración de
  nombres de store** quedó como convención del backend:"""),(
"""- **Registrar en `00-decisiones-y-versiones.md` §7** dos decisiones que esta
  fase cierra y que estaban abiertas:""",
"""- ✅ **Registradas en `00-decisiones-y-versiones.md` como `D25` y `D26`** las dos
  decisiones que esta fase cierra y que estaban abiertas:""")])
ed("be03-crud-y-el-reemplazo.md",[(
"""- **Registrar en `00-decisiones-y-versiones.md` §7** el tag `mock-retirado`
  y, si se quiere, en `00-convencion-de-git-y-tags.md` como tag de hito del track
  BE.""",
"""- ✅ **Registrado en `00-convencion-de-git-y-tags.md`** (§Los tags de hito del
  track BE) el tag `mock-retirado`, como tag de hito del track BE.""")])
ed("be05-venta-concurrente.md",[(
"""- **Registrar en `00-decisiones-y-versiones.md` §7** la decisión de esta
  fase:""",
"""- ✅ **Registrada en `00-decisiones-y-versiones.md` como `D28`** la decisión de esta
  fase:"""),(
"""- **Registrar en `prompts/diccionario-codigo-ingles.md` §7bis.1** la entidad
  nueva:""",
"""- ✅ **Resuelto: la entidad
  nueva** quedó entre los términos del dominio del README (§Convenciones):""")])
ed("be06-hora-dura-y-la-autoridad-del-reloj.md",[(
"""- **Registrar en `00-decisiones-y-versiones.md` §7** la política de tiempo:""",
"""- ✅ **Registrada en `00-decisiones-y-versiones.md` como `D29`** la política de tiempo:""")])
ed("be07-liquidacion-dinero-entero-y-transaccional.md",[(
"""- **Registrar en `prompts/diccionario-codigo-ingles.md` §7bis.1** la entidad
  `PrizePayout` / `prize_payouts`, y en §7bis.2 los nombres de la aritmética""",
"""- ✅ **Resuelto: la entidad
  `PrizePayout` / `prize_payouts`** quedó entre los términos del dominio del
  README (§Convenciones), y los nombres de la aritmética""")])
ed("be09-empaquetado-ambientes-y-pipeline.md",[(
"""- **Registrar en `00-decisiones-y-versiones.md` §7** el cierre de `D19`,""",
"""- ✅ **Registrado en `00-decisiones-y-versiones.md`** el cierre de `D19`,"""),(
"""- **Registrar también el tag de hito `track-be-completo`**, junto con
  `mock-retirado` de `be03`, en `00-convencion-de-git-y-tags.md` como los dos
  únicos tags del track que no siguen el patrón `fase-…`.""",
"""- ✅ **Registrado el tag de hito `track-be-completo`**, junto con
  `mock-retirado` de `be03`, en `00-convencion-de-git-y-tags.md` como los dos
  únicos tags del track que no siguen el patrón `fase-…`.""")])
EOF
for f in be02-la-costura-de-datos.md be05-venta-concurrente.md be07-liquidacion-dinero-entero-y-transaccional.md; do grep -n -A5 "✅ \*\*Resuelto" $f; echo ---; done

# --- 2026-10-06T00:24:09 · 
python3 - <<'EOF'
def ed(p,a,b):
    t=open(p,encoding="utf-8").read(); assert t.count(a)==1,(p,a); open(p,"w",encoding="utf-8").write(t.replace(a,b))
ed("be02-la-costura-de-datos.md","""- ✅ **Resuelto: la aclaración de
  nombres de store** quedó como convención del backend: `sqlStore` cuando una implementación sirve a los dos motores
  (el caso de esta fase) y `<motor><Dominio>Store` cuando es específica de uno
  (el caso que llega en `be05` con `FOR UPDATE`). Hecho al escribir la fase.""",
"""- ✅ **Resuelto: los nombres de store** quedaron como convención del backend:
  `sqlStore` cuando una implementación sirve a los dos motores (el caso de esta
  fase) y `<motor><Dominio>Store` cuando es específica de uno (el caso que llega
  en `be05` con `FOR UPDATE`).""")
ed("be05-venta-concurrente.md","""- ✅ **Resuelto: la entidad
  nueva** quedó entre los términos del dominio del README (§Convenciones): `Sale` / `sales`, y el campo `soldBy`. Es un término del dominio que
  antes no existía y que `be07` va a usar.""",
"""- ✅ **Resuelto: la entidad nueva `Sale` / `sales`** quedó entre los términos
  del dominio del README (§Convenciones), con su campo `soldBy`. Es un término
  que antes no existía y que `be07` usa.""")
ed("be07-liquidacion-dinero-entero-y-transaccional.md","""- ✅ **Resuelto: la entidad
  `PrizePayout` / `prize_payouts`** quedó entre los términos del dominio del
  README (§Convenciones), y los nombres de la aritmética
  (`TotalCollected`, `PrizeAmount`, `Margin`, `PrizeShare`), que son la
  traducción literal de los de `settlementMath.js` y **tienen que seguir
  siéndolo**.""",
"""- ✅ **Resuelto: la entidad `PrizePayout` / `prize_payouts`** quedó entre los
  términos del dominio del README (§Convenciones). Los nombres de la aritmética
  (`TotalCollected`, `PrizeAmount`, `Margin`, `PrizeShare`) son la traducción
  literal de los de `settlementMath.js` y **tienen que seguir siéndolo**.""")
EOF
sed -n 1069,1075p be02-la-costura-de-datos.md; sed -n 1103,1110p be01-go-y-la-forma-del-monolito.md

# --- 2026-10-06T00:24:16 · 
python3 - <<'EOF'
def ed(p,a,b):
    t=open(p,encoding="utf-8").read(); assert t.count(a)==1,(p,a); open(p,"w",encoding="utf-8").write(t.replace(a,b))
ed("be02-la-costura-de-datos.md","""- ✅ **Registradas en `00-decisiones-y-versiones.md` como `D25` y `D26`** las dos
  decisiones que esta fase cierra y que estaban abiertas: **DDL por dialecto** (que `D20` dejaba a
  criterio de `be02`) y **`/health` responde `503`** (que `be01` dejó al
  ejercicio 31). Las dos afectan a `be09` y conviene que estén en la fuente de
  verdad, no solo en la fase.""","""- ✅ **Registradas en `00-decisiones-y-versiones.md` como `D25` y `D26`** las dos
  decisiones que esta fase cierra y que estaban abiertas: **DDL por dialecto**
  (que `D20` dejaba a criterio de `be02`) y **`/health` responde `503`** (que
  `be01` dejó al ejercicio 31). Las dos afectan a `be09`.""")
ed("be01-go-y-la-forma-del-monolito.md","""  binario arranca en `3011`; desde `be03` toma el `3001` por defecto. Hoy está
  decidido en el código de esta fase y comentado en `main.go`, pero la fuente de
  verdad de puertos debería recogerlo.""","""  binario arranca en `3011`; desde `be03` toma el `3001` por defecto.""")
EOF
sed -n 1006,1010p be03-crud-y-el-reemplazo.md; sed -n 762,768p be06-hora-dura-y-la-autoridad-del-reloj.md; sed -n 773,778p be09-empaquetado-ambientes-y-pipeline.md; sed -n 846,852p be05-venta-concurrente.md

# --- 2026-10-06T00:24:27 · 
python3 - <<'EOF'
def ed(p,a,b):
    t=open(p,encoding="utf-8").read(); assert t.count(a)==1,(p,a); open(p,"w",encoding="utf-8").write(t.replace(a,b))
ed("be03-crud-y-el-reemplazo.md","""- ✅ **Registrado en `00-convencion-de-git-y-tags.md`** (§Los tags de hito del
  track BE) el tag `mock-retirado`, como tag de hito del track BE. Es el único tag del curso que no sigue el patrón `fase-…`, y está
  justificado: marca un evento, no un cierre de fase.""","""- ✅ **Registrado en `00-convencion-de-git-y-tags.md`** (§Los tags de hito del
  track BE) el tag `mock-retirado`. Con `track-be-completo` de `be09`, son los
  únicos del curso que no siguen el patrón `fase-…`, y está justificado: marcan
  un evento, no un cierre de fase.""")
ed("be09-empaquetado-ambientes-y-pipeline.md","""  descarta. Y anotar el giro: la pregunta de `D19` estaba mal planteada.""","""  descarta. El registro anota también el giro: la pregunta de `D19` estaba mal
  planteada.""")
ed("00-convencion-de-git-y-tags.md","""El segundo importa más de lo que parece. La Fase 11 te propone migrar cosas
—Router 6, RTK Query, RxJS 7— en ejercicios marcados 🔥 que **no** pertenecen al
código principal. Con `pre-modernizacion` puesto, experimentar deja de ser un
riesgo: pruebas la migración, mides lo que cuesta, y si no cierra vuelves al
código de 2022 con un comando.
""","""El segundo importa más de lo que parece. La Fase 11 te propone migrar cosas
—Router 6, RTK Query, RxJS 7— en ejercicios marcados 🔥 que **no** pertenecen al
código principal. Con `pre-modernizacion` puesto, experimentar deja de ser un
riesgo: pruebas la migración, mides lo que cuesta, y si no cierra vuelves al
código de 2022 con un comando.

### Los tags de hito del track BE

El track BE opcional suma dos tags anotados que no cierran una fase sino que
marcan un **evento**, y por eso son los únicos del curso que no siguen el patrón
`fase-…`:

```bash
git tag -a mock-retirado -m "🪦 json-server fuera del sistema"        # en be03
git tag -a track-be-completo -m "🔥 Track BE terminado: 10 fases, 84 horas, frontend intacto"   # en be09
```

`mock-retirado` es el punto al que vuelves si necesitas comparar el sistema con
y sin el mock: antes de él, el `3001` lo sirve `json-server`; después, el binario
de Go. `track-be-completo` cierra el track entero, y junto con `pre-backend-go`
deja el diff completo del backend a un comando:
`git diff pre-backend-go..track-be-completo`.
""")
EOF
grep -n "^#\|^###" 00-convencion-de-git-y-tags.md | head -30

# --- 2026-10-06T00:24:32 · 
sed -n 150,184p 00-convencion-de-git-y-tags.md

# --- 2026-10-06T00:24:38 · 
python3 - <<'EOF'
p="00-convencion-de-git-y-tags.md"
t=open(p,encoding="utf-8").read()
i=t.index("### Los tags de hito del track BE"); j=t.index("> ⚠️ **Volver a un tag te deja en `detached HEAD`.**")
sec=t[i:j]
t=t[:i]+t[j:]
k=t.index("> `git checkout master`.\n")+len("> `git checkout master`.\n")
sec=sec.replace("deja el diff completo del backend a un comando:","deja el diff completo del track a un comando:").rstrip("\n")+"\n"
t=t[:k]+"\n"+sec+t[k:]
open(p,"w",encoding="utf-8").write(t)
EOF
sed -n 148,182p 00-convencion-de-git-y-tags.md

# --- 2026-10-06T00:24:45 · 
python3 - <<'EOF'
def ed(p,a,b):
    t=open(p,encoding="utf-8").read(); assert t.count(a)==1,(p,a); open(p,"w",encoding="utf-8").write(t.replace(a,b))
ed("cuaderno-incidentes-be.md","""> La estructura, las reglas y el tono son **exactamente los mismos**. Lo que
> cambia son las herramientas, y está registrado en
> `prompts/plantilla-de-incidente-be.md`.""","""> La estructura, las reglas y el tono son **exactamente los mismos**. Lo que
> cambia son las herramientas —logs, `psql`, `pg_stat_activity`, `EXPLAIN`,
> `go test -race`, `docker`— y una pregunta que encabeza cada enunciado: **de
> qué lado del cable está la causa**.""")
ed("cuaderno-incidentes.md","""IDs no colisionan. Su plantilla —igual a esta, con las herramientas del backend en
vez de las del navegador— está en `prompts/plantilla-de-incidente-be.md`.""","""IDs no colisionan. Sus enunciados siguen la misma estructura que estos, con las
herramientas del backend en vez de las del navegador.""")
EOF
grep -n "prompts/\|prompts-\|plantilla-de-fase\|guia-de-estilo\|diccionario-codigo" *.md | cut -c1-180

# --- 2026-10-06T00:24:51 · 
grep -n -i "propuesta-fases\|instrucciones-del-proyecto\|preparaciones-de\|plantilla-de-incidente\|guía de estilo\|guia de estilo\|project knowledge\|[^0-]decisiones-y-versiones\|prompt de redacción\|chat de redacción" *.md | cut -c1-200

# --- 2026-10-06T00:24:56 · 
grep -n -i "ocho puntos\|8 puntos\|sin culpab\|blameless" cuaderno-incidentes.md | head -5; sed -n 23,52p cuaderno-incidentes.md; sed -n 236,243p 00-convencion-de-git-y-tags.md; sed -n 392,400p A2-mini-design-system.md; sed -n 370,376p A8-puente-a-react-moderno.md

# --- 2026-10-06T00:25:02 · 
sed -n 325,365p cuaderno-incidentes.md; sed -n 553p 06-redux-observable-a-fondo.md; sed -n 594p 07-cierre-polling-resultado.md

# --- 2026-10-06T00:25:08 · 
grep -n -i "thunk basta\|basta un thunk\|bastaba un thunk\|sobreusar\|cuándo no usar un epic\|cuándo NO" 06-redux-observable-a-fondo.md A7*.md | head -5

# --- 2026-10-06T00:25:09 · 
grep -n -i "thunk" 06-redux-observable-a-fondo.md | head -8; grep -n "^## " A7-redux-observable-epica-por-epica.md | head -12

# --- 2026-10-06T00:25:14 · 
grep -n -i "de la guía\|la guía §\|guía §\|guia §\|de la Guía\|(guía\|la guía del\|la guía,\|esta guía" *.md | cut -c1-220

# --- 2026-10-06T00:25:25 · 
for x in 02-autenticacion-minima.md:668 10-testing-minimo.md:45 05-venta-de-numeros.md:85 be01-go-y-la-forma-del-monolito.md:1015 be02-la-costura-de-datos.md:981 be03-crud-y-el-reemplazo.md:917 be00-el-contrato-auditoria-del-mock.md:681; do f=${x%%:*}; n=${x##*:}; echo "== $x"; sed -n ${n}p $f | grep -o -i ".\{120\}guía.\{80\}"; done; sed -n 236,262p 00-convencion-de-git-y-tags.md

# --- 2026-10-06T00:25:31 · 
python3 - <<'EOF'
import re,glob
for f in sorted(glob.glob("*.md")):
    for n,l in enumerate(open(f,encoding="utf-8"),1):
        for m in re.finditer(r"(?i)gu[ií]a",l):
            s=l[max(0,m.start()-90):m.end()+70].strip()
            if re.search(r"(?i)(la|esta|de) gu[ií]a|gu[ií]a §|\(gu[ií]a|Gu[ií]a de Estilo",s):
                print(f"{f}:{n}: …{s}…")
EOF

# --- 2026-10-06T00:25:44 · 
sed -n 560,564p 00-setup-hola-mundo-cra.md; echo ---; sed -n 893,897p 03-mock-api-express-caos.md; echo ---; sed -n 697,701p 05-venta-de-numeros.md; echo ---; sed -n 497,500p 11-cierre-puente-react-moderno.md; echo ---; sed -n 400,404p A2-mini-design-system.md; echo ---; sed -n 176,181p A13-depurar-el-build-de-produccion.md; sed -n 733,750p prompts/guia-de-estilo-y-convenciones.md

# --- 2026-10-06T00:26:02 · 
python3 - <<'EOF'
import re
def ed(p,pairs):
    t=open(p,encoding="utf-8").read()
    for a,b in pairs:
        assert t.count(a)==1,(p,a); t=t.replace(a,b)
    open(p,"w",encoding="utf-8").write(t)

ed("cuaderno-incidentes.md",[("""> es la lección más transferible del curso, y es lo primero que te van a pedir en
> un equipo de mantenimiento real.
""","""> es la lección más transferible del curso, y es lo primero que te van a pedir en
> un equipo de mantenimiento real.

### El post-mortem en ocho puntos

Cada incidente se cierra con un post-mortem, y es la misma estructura que piden
los ejercicios de post-mortem de las fases:

1. **Síntoma**, en palabras del usuario.
2. **Pasos de reproducción** exactos.
3. **Evidencia observable**: consola, Network, DevTools, logs.
4. **Causa raíz**, hasta la línea o el commit.
5. **Corrección** aplicada.
6. **Prueba de regresión** que falla antes del fix y pasa después.
7. **Prevención**: un test, un feature flag o una alerta.
8. **Análisis sin culpabilización** (*blameless*): se mira el sistema y el
   proceso, no a la persona.

Los puntos 1 a 6 tienen traducción exacta a git —el par de tags `-roto` / `-fix`
de `00-convencion-de-git-y-tags.md`—, y el tono baja un punto de humor: un
post-mortem es sereno y analítico.
""")])
PM="los ocho puntos del post-mortem de `cuaderno-incidentes.md`"
ed("00-convencion-de-git-y-tags.md",[("""post-mortem de ocho puntos de la guía de estilo (§13): síntoma, repro,""","""post-mortem de ocho puntos que el propio cuaderno explica: síntoma, repro,""")])
ed("06-redux-observable-a-fondo.md",[("(plantilla de la Guía de Estilo §12: síntoma,",f"({PM}: síntoma,")])
ed("07-cierre-polling-resultado.md",[("Escribe el post-mortem (plantilla Guía de Estilo §12)",f"Escribe el post-mortem (con {PM})"),
  ("**Post-mortem completo** (plantilla Guía de Estilo §12)",f"**Post-mortem completo** (con {PM})")])
ed("be00-el-contrato-auditoria-del-mock.md",[("Sin culpabilización, según la guía §13.",f"Sin culpabilización, según {PM}.")])
ed("be01-go-y-la-forma-del-monolito.md",[("según la guía §13:",f"según {PM}:")])
ed("be02-la-costura-de-datos.md",[("Según la guía §13:",f"Según {PM}:")])
ed("be03-crud-y-el-reemplazo.md",[("Según la guía §13, sin culpabilización.",f"Según {PM}, sin culpabilización.")])
for f in ["be04-identidad-real-jwt-y-un-cve.md","be05-venta-concurrente.md","be06-hora-dura-y-la-autoridad-del-reloj.md","be07-liquidacion-dinero-entero-y-transaccional.md","be08-pruebas-y-la-regla-del-motor.md"]:
    ed(f,[("según la guía §13",f"según {PM}")])
ed("00-setup-hola-mundo-cra.md",[("""  columnas, como manda §3 de la guía.""","""  columnas, como pide la regla de tablas cortas del curso.""")])
ed("03-mock-api-express-caos.md",[("""la señal exacta que §3 de la guía da
  para dejar de usar tabla.""","""la señal exacta
  para dejar de usar tabla.""")])
ed("05-venta-de-numeros.md",[("Recuerda el caso mixto de la §4 de la guía:","Recuerda el caso mixto de la convención de idioma del curso:"),
  ("""  verificable como pide §9 de la guía.""","""  verificable, que es lo que se le pide a todo ejercicio.""")])
ed("11-cierre-puente-react-moderno.md",[("""  misma extracción:** en el A12 el inventario es una lista con subtítulos, como
  manda §3 de la guía, y cada entrada""","""  misma extracción:** en el A12 el inventario es una lista con subtítulos, como
  pide la regla de tablas cortas del curso, y cada entrada""")])
ed("02-autenticacion-minima.md",[("Esto estrena la convivencia `connect()` + `useSelector()` que pide la guía.","Esto estrena la convivencia `connect()` + `useSelector()` que vas a encontrar en cualquier base de esta época.")])
ed("10-testing-minimo.md",[("""el argumento de "testear comportamiento, no implementación" (guía §5):""","""el argumento de "testear comportamiento, no implementación":""")])
ed("A13-depurar-el-build-de-produccion.md",[("""> textos de interfaz van en español y las claves en inglés (guía §4). En un""","""> textos de interfaz van en español y las claves en inglés (README,
> §Convenciones). En un""")])
ed("A2-mini-design-system.md",[("Coherentes con la guía de estilo del proyecto y el diccionario código-inglés:","Coherentes con la convención de idioma del curso (README, §Convenciones):"),
  ("UI (ver A5 y la guía), no en el Sass.","UI (ver A5), no en el Sass.")])
ed("A8-puente-a-react-moderno.md",[("""y qué usarías en su lugar. La propia guía de estilo del curso lo dice: a veces
un thunk basta, y sobreusar RxJS es un antipatrón.""","""y qué usarías en su lugar. La Fase 6 ya lo decía al presentar los epics: a
veces un thunk basta, y sobreusar RxJS es un antipatrón.""")])
EOF
grep -n "^## \|^### " cuaderno-incidentes.md | sed -n 1,8p

# --- 2026-10-06T00:26:09 · 
python3 - <<'EOF'
import re,glob
for f in sorted(glob.glob("*.md")):
    t=open(f,encoding="utf-8").read()
    for m in re.finditer(r"(?i)(§\s?\d+(\.\d+)?\s+de\s+la\s*\n?\s*>?\s*gu[ií]a|gu[ií]a\s*\n?\s*>?\s*(de estilo|§)|de la\s*\n\s*>?\s*gu[ií]a)",t):
        n=t.count("\n",0,m.start())+1
        print(f,n,repr(t[m.start()-80:m.end()+40]))
EOF

# --- 2026-10-06T00:26:11 · 
sed -n 619,628p 06-redux-observable-a-fondo.md

# --- 2026-10-06T00:26:16 · 
python3 - <<'EOF'
p="06-redux-observable-a-fondo.md"; t=open(p,encoding="utf-8").read()
a="""  `SCREAMING_SNAKE_CASE` junto a los thunks de RTK es coherente con §4.4 de la
  guía, pero se lee como inconsistencia si no se explica."""
b="""  `SCREAMING_SNAKE_CASE` junto a los thunks de RTK es coherente con la
  convención del curso (los *types* a mano en mayúsculas, los de RTK generados),
  pero se lee como inconsistencia si no se explica."""
assert t.count(a)==1; open(p,"w",encoding="utf-8").write(t.replace(a,b))
EOF
grep -n -i "§[0-9]* de la\b" *.md | grep -v "Fase\|be0\|A[0-9]" | head

# --- 2026-10-06T00:26:20 · 
python3 prompts/verificador_base.py . --perfil=courses-ia --corregir-fe0f 2>&1 | grep -v "aviso" | tail -5

# --- 2026-10-06T00:26:26 · 
python3 - <<'EOF'
p="05-venta-de-numeros.md"; t=open(p,encoding="utf-8").read()
a="""```
available ──reserve──► reserved ──sell──► sold
    ▲                      │
    └──────expire──────────┘
```"""
b="""```mermaid
stateDiagram-v2
    direction LR
    [*] --> available
    available --> reserved: reserve
    reserved --> sold: sell
    reserved --> available: expire
    sold --> [*]
```"""
assert t.count(a)==1; open(p,"w",encoding="utf-8").write(t.replace(a,b))
EOF
Z=../../zz-code/react-16-legacy-for-backend-devs-20261005-cbd3/salidas; awk '/^```mermaid/{f=1;next} /^```/{f=0} f' 05-venta-de-numeros.md > $Z/f05-estados.mmd; (cd $Z && mmdc -i f05-estados.mmd -o f05-estados.svg 2>&1 | tail -1)

# --- 2026-10-06T00:26:31 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/zz-code/react-16-legacy-for-backend-devs-20261005-cbd3/salidas && mmdc -i f05-estados.mmd -o f05-estados.png -s 2 >/dev/null 2>&1; ls -la f05-estados.png

# --- 2026-10-06T00:26:40 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated; git ls-files cursos-legacy/react-16-legacy-for-backend-devs | grep -i "ds_store\|gitignore"; cat .gitignore | head -30; ls cursos-contenedores-cloud-infra/docker-container-legacy/.gitignore && head -20 cursos-contenedores-cloud-infra/docker-container-legacy/.gitignore

# --- 2026-10-06T00:26:48 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs && grep -n "gitignore" be0*.md 00-setup*.md | cut -c1-160 | head

# --- 2026-10-06T00:26:52 · 
python3 - <<'EOF'
p=".gitignore"; t=open(p,encoding="utf-8").read()
a="""# backend del track BE los construye el lector en su propio repositorio, con el
# .gitignore que le deja CRA (Fase 0) y el de server/ (be01). Este solo cubre lo que
# el sistema operativo y los editores dejan al leer y editar el curso."""
b="""# backend del track BE los construye el lector en su propio repositorio, con el
# .gitignore que le deja CRA (Fase 0). Este solo cubre lo que el sistema operativo
# y los editores dejan al leer y editar el curso."""
assert t.count(a)==1; open(p,"w",encoding="utf-8").write(t.replace(a,b))
EOF

# --- 2026-10-06T00:26:57 · 
grep -n "00-\|licen" README.md | cut -c1-150; sed -n 100,118p README.md; sed -n 150,170p README.md

# --- 2026-10-06T00:27:02 · 
python3 - <<'EOF'
p="README.md"; t=open(p,encoding="utf-8").read()
a="""`-roto` / `-fix` que convierten cada incidente resuelto en un `git diff` que se
entiende dentro de seis meses.
"""
b=a+"""
**Y dos documentos de consulta**, que no se leen de corrido:
`00-decisiones-y-versiones.md`, con cada versión congelada, el `package.json` y el
`go.mod` de referencia, los puertos y las decisiones D1–D29 con su porqué; y
`00-alcance-del-proyecto.md`, con qué cubre el curso, qué deja fuera y cómo se
reparten las horas.
"""
assert t.count(a)==1; open(p,"w",encoding="utf-8").write(t.replace(a,b))
EOF
grep -n "horas\|## " 00-alcance-del-proyecto.md | head -12

# --- 2026-10-06T00:27:06 · 
sed -i '' 's/`00-alcance-del-proyecto.md`, con qué cubre el curso, qué deja fuera y cómo se$/`00-alcance-del-proyecto.md`, con qué cubre el curso, qué deja fuera y cuántas/; s/^reparten las horas\.$/horas lleva cada track./' README.md && sed -n 117,124p README.md && python3 prompts/verificar-corpus.py | tail -3; python3 prompts/verificar-corpus.py --publicacion | tail -4

# --- 2026-10-06T00:27:17 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs/prompts && python3 - <<'EOF'
import re,glob
p="verificar-corpus.py"; t=open(p,encoding="utf-8").read()
a="""    # 00-alcance, 00-convencion y 00-historia llevan número pero son encuadre, no fases.
    NO_CAPITULO = PerfilCoursesIA.NO_CAPITULO + ("alcance", "convencion", "historia")"""
b="""    # 00-alcance, 00-convencion, 00-decisiones y 00-historia llevan número pero son encuadre o
    # consulta, no fases.
    NO_CAPITULO = PerfilCoursesIA.NO_CAPITULO + ("alcance", "convencion", "decisiones", "historia")"""
assert t.count(a)==1; open(p,"w",encoding="utf-8").write(t.replace(a,b))
tot=0
for f in glob.glob("*.md"):
    t=open(f,encoding="utf-8").read(); o=t
    t=t.replace("prompts/decisiones-y-versiones.md","00-decisiones-y-versiones.md")
    t=re.sub(r"(?<![0-9a-z/-])decisiones-y-versiones\.md","00-decisiones-y-versiones.md",t)
    t=t.replace("00-00-","00-")
    if t!=o:
        tot+=1; open(f,"w",encoding="utf-8").write(t)
print(tot)
EOF
grep -n "decisiones-y-versiones" *.md | grep -v "00-decisiones-y-versiones" ; grep -n "D1–D28\|D14–D28\|D14–D23\|D14-D23\|D1-D13" *.md | cut -c1-140

# --- 2026-10-06T00:27:22 · 
grep -n "](00-" *.md; sed -n 48,58p instrucciones-del-proyecto.md; sed -n 84,96p instrucciones-del-proyecto.md; sed -n 136,150p instrucciones-del-proyecto.md; sed -n 160,185p instrucciones-del-proyecto.md

# --- 2026-10-06T00:27:29 · 
python3 - <<'EOF'
def ed(p,pairs):
    t=open(p,encoding="utf-8").read()
    for a,b in pairs:
        assert t.count(a)==1,(p,a); t=t.replace(a,b)
    open(p,"w",encoding="utf-8").write(t)
ed("README.md",[("| [`00-decisiones-y-versiones.md`](00-decisiones-y-versiones.md) | las versiones congeladas y las decisiones D1–D28 con su porqué |",
"| [`../00-decisiones-y-versiones.md`](../00-decisiones-y-versiones.md) | **publicado**, en la raíz del curso desde el 05/10/2026: las versiones congeladas y las decisiones D1–D29 con su porqué |")])
ed("instrucciones-del-proyecto.md",[
("package.json completo, las decisiones D1-D13 con su porqué, qué instala cada","package.json completo, las decisiones D1-D13 con su porqué, qué instala cada"),
("prompts/propuesta-fases-backend.md, sus versiones y decisiones D14-D23 en","prompts/propuesta-fases-backend.md, sus versiones y decisiones D14-D29 en"),
("""se registra en 00-historia-del-sistema.md o 00-decisiones-y-versiones.md, y se cita
desde ahí. Toda referencia cruzada tiene que resolver a un archivo real.""","""se registra en 00-historia-del-sistema.md o 00-decisiones-y-versiones.md, y se cita
desde ahí. Toda referencia cruzada tiene que resolver a un archivo real. Ningún
documento publicado nombra ni enlaza nada de prompts/: es material de
elaboración y no viaja con el curso; lo que el lector necesita de aquí se dice
en prosa o se sube a un documento publicado."""),
])
EOF
grep -n "se registra en 00-historia" -A6 instrucciones-del-proyecto.md | head -8

# --- 2026-10-06T00:27:37 · 
grep -n "^## 17\|^### 17" guia-de-estilo-y-convenciones.md; sed -n '/^- \*\*No dependas de material/,/^📝 \*\*De dónde viene/p' guia-de-estilo-y-convenciones.md; grep -n "00-decisiones-y-versiones" guia-de-estilo-y-convenciones.md | cut -c1-140

# --- 2026-10-06T00:27:40 · 
sed -n 690,700p guia-de-estilo-y-convenciones.md; sed -n 1054,1175p guia-de-estilo-y-convenciones.md

# --- 2026-10-06T00:28:07 · 
python3 - <<'EOF'
p="guia-de-estilo-y-convenciones.md"
t=open(p,encoding="utf-8").read()
def rep(a,b):
    global t
    assert t.count(a)==1,a
    t=t.replace(a,b)
# §11
rep("""- **No dependas de material que el estudiante no pueda conseguir.** Un video de
  YouTube que puede desaparecer es una sugerencia, no un requisito; el contenido
  necesario para completar una fase está siempre en la fase.
""","""- **No dependas de material que el estudiante no pueda conseguir.** Un video de
  YouTube que puede desaparecer es una sugerencia, no un requisito; el contenido
  necesario para completar una fase está siempre en la fase.
- **No cites `prompts/`.** Nada de esta carpeta viaja con el curso cuando se
  publica: ni esta guía, ni el diccionario, ni las plantillas, ni los prompts.
  Un documento publicado no la nombra ni la enlaza, tampoco en los 📌
  Pendientes. Si el lector necesita algo de aquí, se dice en prosa o se sube a
  un documento publicado, como se hizo con `00-decisiones-y-versiones.md` y con
  los ocho puntos del post-mortem (§13). `verificar-corpus.py --publicacion` lo
  comprueba (§17.3).
""")
# §13
rep("""El tono acá baja un punto de humor. Un post-mortem es sereno y analítico —no
acartonado, pero tampoco el lugar para el chiste.""","""El tono acá baja un punto de humor. Un post-mortem es sereno y analítico —no
acartonado, pero tampoco el lugar para el chiste.

La lista de arriba está publicada para el lector en `cuaderno-incidentes.md`
(§El post-mortem en ocho puntos). Un ejercicio de post-mortem cita **esa**
sección —«según los ocho puntos del post-mortem de `cuaderno-incidentes.md`»—,
nunca esta guía (§11).""")
# checklist
rep("""- [ ] `python3 prompts/verificar-corpus.py` sin errores ni avisos nuevos (§17.3).""","""- [ ] Ninguna mención a `prompts/` ni a esta guía (§11).
- [ ] `python3 prompts/verificar-corpus.py` y su `--publicacion` en cero (§17.3).""")
# 17.1 nota
rep("""> 🧭 **El ejemplo de arriba es el diagrama que tiene que reemplazar** al ASCII de
> la Fase 5 §4 (`available ──reserve──► reserved …`), el único bloque del curso
> publicado que el verificador marca como `DIAGRAMA`. La conversión está en
> §17.4: esta revisión solo tocó `prompts/`.""","""> 🧭 **El ejemplo de arriba es el diagrama que reemplazó** al ASCII de la Fase 5
> §4 (`available ──reserve──► reserved …`), el único bloque del curso que el
> verificador marcaba como `DIAGRAMA`. Se convirtió el 05/10/2026, con
> `direction LR` para que se lea de izquierda a derecha como el original.""")
# 17.2
rep("""- **Contrato de nombres:** `00-decisiones-y-versiones.md` (versiones, el
  `package.json` y el `go.mod` de referencia, puertos), §4.4 y""","""- **Contrato de nombres:** `00-decisiones-y-versiones.md`, **publicado** en la
  raíz del curso (versiones, el `package.json` y el `go.mod` de referencia,
  puertos, D1–D29), §4.4 y""")
rep("""  versiones. Las decisiones D24–D28 nacieron al escribir el track y no están en
  sus prompts.""","""  versiones. Las decisiones D24–D29 nacieron al escribir el track y no están en
  sus prompts.""")
# 17.3
rep("""- **Línea base del 05/10/2026**: sin `--publicacion`, 3 errores `ANCLA-FE0F` y 1
  aviso `DIAGRAMA`; con `--publicacion`, además 56 `CITA-PROMPTS`. Todos son
  del curso publicado y están en §17.4.""","""- **Línea base:** los dos comandos salen en **0 errores y 0 avisos** desde el
  05/10/2026. Antes de la limpieza de ese día había 3 `ANCLA-FE0F`, 1 `DIAGRAMA`
  y 56 `CITA-PROMPTS` (§17.4).
- `CITA-PROMPTS` solo ve nombres de archivo. Una cita a «la guía» o a «la guía
  §13» sin nombre de archivo se le escapa: se busca a mano con
  `grep -rn -i "gu[ií]a §\\|de la gu[ií]a" *.md`, y en el curso publicado solo
  pueden salir guías externas (la de `sqlx`, la de Redux).""")
# 17.4
i=t.index("### 17.4 Lo que falta para cerrar y publicar el curso")
t=t[:i]+"""### 17.4 El cierre del 05/10/2026 y lo que queda

El contenido está completo: doce fases, trece apéndices, el track BE (diez fases
y diez apéndices) y los dos cuadernos de incidentes (veinte y dieciséis). La
revisión del 05/10/2026 encontró lo que impedía publicarlo y lo corrigió en el
mismo día, en dos pasos: primero `prompts/`, después el curso.

**Lo que se corrigió en el curso:**

1. **El curso remitía al lector a `prompts/`**: 56 menciones en 33 documentos,
   más 21 citas a «la guía» sin nombre de archivo. Decisión del autor: el curso
   no cita `prompts/` porque es material de elaboración.
   - `decisiones-y-versiones.md` **subió a la raíz** como
     `00-decisiones-y-versiones.md`, porque es material del lector: el
     `package.json` y el `go.mod` de referencia, qué instala cada fase y los
     puertos. Se redactó para el lector (fuera la historia de su escritura y
     las instrucciones al redactor) y ganó lo que las fases decían que tenía y
     no tenía: la decisión de **no adoptar librería de fechas ni de dinero**
     (F07, F08 y A10 la daban por registrada) y **D29**, la política de tiempo
     de `be06`, que su 📌 Pendiente pedía registrar.
   - Las diez menciones al diccionario se reescribieron en prosa, y el README
     (§Convenciones) ganó la tabla mínima de términos del dominio en las tres
     capas, que es lo que el lector necesitaba de él.
   - Los ocho puntos del post-mortem se publicaron en `cuaderno-incidentes.md`
     (§El post-mortem en ocho puntos), y los catorce ejercicios que decían
     «según la guía §13» (o «§12», que además era un número equivocado) citan
     ahora esa sección.
   - `00-convencion-de-git-y-tags.md` ganó §Los tags de hito del track BE
     (`mock-retirado`, `track-be-completo`), que `be03` y `be09` pedían
     registrar.
   - Los 📌 Pendientes que decían «Registrar en `prompts/…`» se marcaron ✅
     con su destino real.
2. **Tres enlaces `ANCLA-FE0F`** en A4 y A5, corregidos con `--corregir-fe0f`.
3. **El diagrama de la Fase 5 §4**, a Mermaid (§17.1).
4. **`.gitignore` mínimo** en la raíz del curso: no hay código que ignorar,
   solo lo del sistema operativo y los editores.

**Lo que queda:**

- **Validar el curso ejecutándolo de nuevo.** Las salidas se ejecutaron al
  escribirlo, pero el curso es anterior al método de tandas con casillas de
  *escrita* y *corrida*, y no quedó registro. La revalidación está planificada
  en `_desechable-plan-de-validacion.md`, para hacerse en una sesión futura.
- **La licencia** del repositorio público: la elige el autor en la etapa de
  publicación.
"""
open(p,"w",encoding="utf-8").write(t)
EOF
tail -5 guia-de-estilo-y-convenciones.md

# --- 2026-10-06T00:28:15 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs && grep -c "los ocho puntos del post-mortem" *.md | grep -v ":0"; cd prompts && sed -i '' 's/más 21 citas a «la guía» sin nombre de archivo/más 25 citas a «la guía» sin nombre de archivo/; s/(§El post-mortem en ocho puntos), y los catorce ejercicios que decían/(§El post-mortem en ocho puntos), y los doce ejercicios que decían/' guia-de-estilo-y-convenciones.md && grep -n "25 citas\|doce ejercicios" guia-de-estilo-y-convenciones.md

# --- 2026-10-06T00:28:35 · 
python3 - <<'EOF'
p="README.md"; t=open(p,encoding="utf-8").read()
def rep(a,b):
    global t
    assert t.count(a)==1,a
    t=t.replace(a,b)
rep("""> **Estado:** contenido completo: 12 fases, 13 apéndices, el track BE opcional (10 fases y 10
> apéndices) y los dos cuadernos de incidentes (20 y 16). Revisado el 05/10/2026 contra los
> lineamientos de producción del repositorio: excepciones y convención de Mermaid declaradas en la
> guía §17, verificador agregado. **Falta para cerrarlo** lo de la guía §17.4, que son ediciones del
> curso y no de esta carpeta; la principal, que el curso remite al lector a archivos de aquí.""",
"""> **Estado:** contenido completo y cerrado el 05/10/2026: 12 fases, 13 apéndices, el track BE
> opcional (10 fases y 10 apéndices) y los dos cuadernos de incidentes (20 y 16). Revisado ese día
> contra los lineamientos de producción del repositorio (guía §17): el curso ya no cita esta
> carpeta y los dos verificadores salen en cero. **Queda** revalidarlo ejecutándolo, según
> [`_desechable-plan-de-validacion.md`](_desechable-plan-de-validacion.md), y elegir la licencia
> antes de publicarlo.""")
rep("""| `prompts-a-*.md`, `prompts-b-*.md`, `prompts-backend-*.md` | los prompts con que se escribió cada fase y cada apéndice | solo como registro: si contradicen a una fase publicada, gana la fase |""",
"""| `prompts-a-*.md`, `prompts-b-*.md`, `prompts-backend-*.md` | los prompts con que se escribió cada fase y cada apéndice | solo como registro: si contradicen a una fase publicada, gana la fase |
| [`_desechable-plan-de-validacion.md`](_desechable-plan-de-validacion.md) | las tandas de ejecución para revalidar el curso | en la sesión de revalidación; se borra cuando termine |""")
rep("""- **El segundo agrega lo que exige el repositorio público: nada que enlace ni nombre `prompts/`, ni
     que cite material privado. Hoy falla a propósito: es el punto 1 de la guía §17.4.""","""X""") if "Hoy falla a propósito" in t and False else None
rep("""   - El segundo agrega lo que exige el repositorio público: nada que enlace ni nombre `prompts/`, ni
     que cite material privado. Hoy falla a propósito: es el punto 1 de la guía §17.4.""","""   - El segundo agrega lo que exige el repositorio público: nada que enlace ni nombre `prompts/`, ni
     que cite material privado. Las citas a «la guía» sin nombre de archivo no las ve: se buscan a
     mano (guía §17.3).""")
rep("""   - El primero no puede sumar nada a la línea base de la guía §17.3; un aviso `DIAGRAMA` es un
     bloque de texto que dibuja algo que va en Mermaid.""","""   - Los dos salen en **0 errores y 0 avisos**; un aviso `DIAGRAMA` es un bloque de texto que
     dibuja algo que va en Mermaid.""")
rep("""  guía §12. Las tres plantillas ganaron la regla de diagramas. Se agregaron este README y el
  verificador.""","""  guía §12. Las tres plantillas ganaron la regla de diagramas. Se agregaron este README y el
  verificador.
- **05/10/2026, segunda parte: el curso.** Por decisión del autor el curso no cita `prompts/`.
  `decisiones-y-versiones.md` salió de esta carpeta y es ahora `../00-decisiones-y-versiones.md`,
  con D29 y las dos librerías que no se adoptan; los ocho puntos del post-mortem se publicaron en el
  cuaderno de incidentes; el README del curso ganó la tabla de términos del dominio; se corrigieron
  tres anclas, el diagrama de F05 pasó a Mermaid y el curso tiene `.gitignore`. El detalle, en la
  guía §17.4.""")
rep("""- **Contradecir una versión congelada.** Una versión, un puerto o una librería que no coincide con
  `00-decisiones-y-versiones.md` rompe""","""- **Citar `prompts/` desde el curso.** Pasó 81 veces, casi siempre en los 📌 Pendientes y en los
  ejercicios de post-mortem («según la guía §13»). Esta carpeta no se publica (guía §11).
- **Contradecir una versión congelada.** Una versión, un puerto o una librería que no coincide con
  `00-decisiones-y-versiones.md` rompe""")
rep("## ⚠️ Las tres cosas que más se rompen al editar","## ⚠️ Las cuatro cosas que más se rompen al editar")
open(p,"w",encoding="utf-8").write(t)
EOF
grep -n "decisiones-y-versiones\|propuesta-fases-backend" README.md | cut -c1-150

# --- 2026-10-06T00:28:49 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs && grep -n "^## \|^### " 00-setup-hola-mundo-cra.md | head -20; grep -n -i "colima\|windows\|apple silicon\|arm64" 00-setup-hola-mundo-cra.md | head -5; grep -n "^## " preparaciones 2>/dev/null; sed -n 646,664p prompts/preparaciones-de-incidentes-be.md; sed -n 930,950p prompts/preparaciones-de-incidentes.md

# --- 2026-10-06T00:29:33 · 
grep -n "create-react-app\|react-scripts@4" 00-setup-hola-mundo-cra.md | head -4; grep -h -m1 -E "^## .*Ejercicios" *.md | grep -oE "\(([0-9]+)\)|cortos \(([0-9]+)\)|reflexión \(([0-9]+)\)" | grep -oE "[0-9]+" | paste -sd+ | bc

# --- 2026-10-06T00:29:37 · 
grep -h -m1 -E "^## .*Ejercicios" *.md | grep -oE "[0-9]+\)" | tr -d ')' | paste -s -d+ - | bc; cd prompts && python3 - <<'EOF'
p="_desechable-plan-de-validacion.md"; t=open(p,encoding="utf-8").read()
for a,b in [("""- **CRA 4 sin `create-react-app` global.** F00 §5.5 crea el proyecto con `npx create-react-app@4.0.3`
  (comprobar el comando exacto en la fase): dentro del contenedor, con npm 6.""","""- **CRA 4 sin `create-react-app` global.** F00 §5.5 crea el proyecto con
  `npx create-react-app@4.0.3 raffles-app --use-npm`: dentro del contenedor, con npm 6, y comprobando
  que lo que baja hoy sigue siendo React 16.14.0 tras fijar las versiones de la fase.""")]:
    assert t.count(a)==1; t=t.replace(a,b)
open(p,"w",encoding="utf-8").write(t)
EOF

# --- 2026-10-06T00:29:41 · 
sed -i '' 's/6\. \*\*Ejercicios:\*\* no se resuelven los 600;/6. **Ejercicios:** no se resuelven los 855;/' _desechable-plan-de-validacion.md && grep -n "855" _desechable-plan-de-validacion.md

# --- 2026-10-06T00:29:50 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated && python3 - <<'EOF'
p="README.md"; t=open(p,encoding="utf-8").read()
a="""### ⚛️ react-16-legacy
**React 16 Legacy** — Curso práctico de React 16 para ingenieros de otros paradigmas. Cubre fundamentos hasta patrones avanzados: componentes, ciclo de vida, estado, props, hooks. Proyecto integrador: aplicación real con manejo de estado y efectos sin recargar."""
b="""### ⚛️ react-16-legacy-for-backend-devs
**React 16 Legacy para devs de backend** — Curso práctico de 96 horas para mantener una aplicación React 16 heredada (Rifas y Chances S.A.S., una empresa ficticia): clases y hooks conviviendo, Redux Toolkit con Redux clásico, redux-observable, race conditions, hora dura y dinero en enteros. 12 fases, 13 apéndices y un cuaderno de 20 incidentes. Track opcional de 84 horas que reemplaza el mock por un backend en Go 1.19 contra PostgreSQL 13 sin tocar el frontend, con su propio cuaderno de 16 incidentes. Vive en `cursos-legacy/`."""
assert t.count(a)==1; open(p,"w",encoding="utf-8").write(t.replace(a,b))
EOF
cd cursos-legacy/react-16-legacy-for-backend-devs; python3 prompts/verificar-corpus.py | tail -3; python3 prompts/verificar-corpus.py --publicacion | tail -3; grep -rn "prompts/" --include=*.md . | grep -v "^./prompts/" | head; grep -rl "Ã\|â€" *.md; python3 - <<'EOF'
import re,glob
for f in sorted(glob.glob("*.md")):
    for n,l in enumerate(open(f,encoding="utf-8"),1):
        if re.search(r"(?i)(la|esta) gu[ií]a( de estilo)?( §|\b(?! oficial| de `?sqlx| de Redux))",l) and "oficial" not in l:
            print(f,n,l.strip()[:120])
EOF

# --- 2026-10-06T00:29:55 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n "prompts/" *.md | head; grep -l "Ã\|â€" *.md; python3 - <<'EOF'
import re,glob
for f in sorted(glob.glob("*.md")):
    for n,l in enumerate(open(f,encoding="utf-8"),1):
        if re.search(r"(?i)gu[ií]a",l) and re.search(r"(?i)(la|esta|de) gu[ií]a|gu[ií]a §",l):
            print(f,n,l.strip()[:130])
EOF

# --- 2026-10-06T00:30:01 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; grep -n -i "\bprompts\?\b\|project knowledge\|este chat\|el chat\b\|diccionario-codigo\|propuesta-fases" *.md | cut -c1-170 | head -20

# --- 2026-10-06T00:30:03 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/react-16-legacy-for-backend-devs; sed -n 440,450p 03-mock-api-express-caos.md; sed -n 862,869p be05-venta-concurrente.md

# --- 2026-10-06T00:30:08 · 
python3 - <<'EOF'
def ed(p,a,b):
    t=open(p,encoding="utf-8").read(); assert t.count(a)==1,(p,a); open(p,"w",encoding="utf-8").write(t.replace(a,b))
ed("03-mock-api-express-caos.md","""// y Fase 7. La decisión se tomó explícitamente en el chat de esta fase
// para que Fase 6-7 hereden un mock ya inestable y se concentren en el""","""// y Fase 7. Se decidió así a propósito, para que las Fases 6 y 7
// hereden un mock ya inestable y se concentren en el""")
ed("be05-venta-concurrente.md","""- **`be07` hereda `sales` como registro inmutable**, que es exactamente lo que su
  prompt pide para la trazabilidad, y el `WithTx` ya montado.""","""- **`be07` hereda `sales` como registro inmutable**, que es exactamente lo que
  necesita para la trazabilidad, y el `WithTx` ya montado.""")
EOF
python3 prompts/verificar-corpus.py --publicacion | tail -1

# --- 2026-10-06T00:30:22 · 
cd /Users/oskar/Developer/Learning/courses-ia-generated && python3 - <<'EOF'
p="zz-code/react-16-legacy-for-backend-devs-20261005-cbd3/MANIFIESTO.md"; t=open(p,encoding="utf-8").read()
t=t.replace("""- `salidas/estados-numero.*` y `salidas/autoridad.*` — los dos Mermaid, dibujados con `mmdc`.""","""- `salidas/estados-numero.*` y `salidas/autoridad.*` — los dos Mermaid, dibujados con `mmdc`.
- `salidas/f05-estados.*` — el `stateDiagram-v2` que reemplazó al ASCII de F05 §4.""")
t=t.replace("""La subclase quedó en `prompts/verificar-corpus.py` del curso; los hallazgos, en la guía §17.3 y
§17.4. No hay código que conservar.""","""La subclase quedó en `prompts/verificar-corpus.py` del curso; los hallazgos y su corrección, en la
guía §17.3 y §17.4. No hay código que conservar. La revalidación por ejecución abrirá su propio
directorio (ver `prompts/_desechable-plan-de-validacion.md` del curso).""")
open(p,"w",encoding="utf-8").write(t)
EOF
cd /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory && python3 - <<'EOF'
p="track-be-react16-escrito.md"; t=open(p,encoding="utf-8").read()
i=t.index("**Revisión contra `zz-instrucciones/` (05/10/2026")
t=t[:i]+"""**Revisión contra `zz-instrucciones/` y cierre (05/10/2026, sin commit: lo hace Oskar).**
Guía §17 (excepciones, D-12 Mermaid, verificación, cierre), `prompts/README.md`,
`verificar-corpus.py` (+ `verificador_base.py`; error propio `CITA-PROMPTS` con `--publicacion`).
Decisión de Oskar: **el curso no cita `prompts/`** (material de elaboración). Se subió
`decisiones-y-versiones.md` a la raíz como `00-decisiones-y-versiones.md` (con D29 y la no-adopción de
librerías de fechas/dinero), los ocho puntos del post-mortem pasaron a `cuaderno-incidentes.md`, el
README del curso ganó la tabla de términos del dominio; anclas, Mermaid F05 y `.gitignore` hechos.
Los dos verificadores en 0/0. Oskar confirmó que **las salidas se ejecutaron** al escribirlo, sin
registro: la revalidación está en `prompts/_desechable-plan-de-validacion.md` (tandas V0–V13), para
una sesión futura. Falta la licencia. Mismo patrón que [[docker-legacy-complemento-geek]].
"""
open(p,"w",encoding="utf-8").write(t)
p="MEMORY.md"; t=open(p,encoding="utf-8").read()
a=[l for l in t.splitlines() if l.startswith("- [Track BE de React 16 escrito]")][0]
t=t.replace(a,"- [Track BE de React 16 escrito](track-be-react16-escrito.md) — cerrado el 05/10/2026 (sin citas a prompts/, verificadores 0/0); queda revalidar por ejecución (plan desechable V0–V13) y la licencia.")
open(p,"w",encoding="utf-8").write(t)
EOF
cd /Users/oskar/Developer/Learning/courses-ia-generated; git status --short README.md cursos-legacy/react-16-legacy-for-backend-devs | head -60

