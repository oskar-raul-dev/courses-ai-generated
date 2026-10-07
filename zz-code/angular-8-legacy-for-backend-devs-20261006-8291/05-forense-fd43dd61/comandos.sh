# Comandos Bash de la sesión fd43dd61-45e4-4c68-a03a-349c75d31fa2, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-10T22:18:00 · List prompts and count lines of forensic files
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs && ls prompts/ && echo "--- WC forense ---" && wc -l forense-*.md && echo "--- cuaderno ---" && wc -l cuaderno-incidentes.md README.md

# --- 2026-09-10T22:18:06 · Check broken links and pending items in README
echo "=== ENLACES ROTOS ===" && grep -oh "(\./[^)]*\.md)" *.md prompts/*.md | tr -d '()' | sed 's|^\./||' | sort -u | while read f; do [ -f "$f" ] || [ -f "prompts/$f" ] || echo "ROTO: $f"; done; echo "=== README faltantes ==="; grep -n -i "falta\|pendiente\|todavía no\|aún no" README.md

# --- 2026-09-10T22:18:09 · Read README tail section
sed -n '140,210p' README.md

# --- 2026-09-10T22:18:14 · Inspect incident notebook structure
echo "=== cuaderno head ==="; sed -n '1,60p' cuaderno-incidentes.md; echo "=== IDs incidentes ==="; grep -n "^### \|^## " cuaderno-incidentes.md | head -60

# --- 2026-09-10T22:18:19 · Check block presence in each forensic piece
for f in forense-fase-*.md; do
 t=$(head -1 $f)
 b=""
 for e in "🎫" "🧭" "🩺" "⚰️" "🧨" "🧠"; do grep -q "$e" $f && b="$b$e" || b="$b·"; done
 printf "%-22s %s  %s\n" "$f" "$b" "$t"
done
echo "=== master ==="; grep -n "^## \|^### " forense-master.md

# --- 2026-09-10T22:18:29 · Check phase hooks and spec structure
echo "=== ganchos 📄 en fases ==="; for f in 0*-*.md 1*-*.md; do case $f in 00-convencion*|00-historia*) continue;; esac; n=$(grep -c "forense-fase" $f); printf "%-32s refs=%s\n" "$f" "$n"; done
echo; echo "=== spec divergencias ==="; grep -n "^## \|^### " prompts/formato-piezas-forenses.md; echo "--- cuarta pregunta master ---"; sed -n '12,32p' forense-master.md

# --- 2026-09-10T22:18:37 · Check 📄 hook lines and tag blocks
echo "=== linea 📄 por fase ==="; for f in 0[0-9]-*.md 1[0-4]-*.md; do case $f in 00-convencion*|00-historia*) continue;; esac; l=$(grep -n "📄.*forense-fase" $f | head -1); printf "%-32s %s\n" "$f" "${l:-SIN LINEA 📄}"; done
echo; echo "=== bloque 🏷️ en piezas ==="; for f in forense-fase-*.md forense-master.md; do grep -q "🏷️" $f && echo "ok  $f" || echo "FALTA 🏷️  $f"; done

# --- 2026-09-10T22:18:42 · Read spec sections 3,5,6,7,8
sed -n '71,100p;129,240p' prompts/formato-piezas-forenses.md

# --- 2026-09-10T22:18:47 · Show forensic references per phase
echo "=== forma del gancho en cada fase ==="; for f in 0[0-9]-*.md 1[0-4]-*.md; do case $f in 00-convencion*|00-historia*) continue;; esac; echo "--- $f"; grep -n "forense-fase" $f; done

# --- 2026-09-10T22:18:57 · Check incident references and phase 13 closing
echo "=== incidentes citados por pieza ==="; for f in forense-fase-*.md; do printf "%-22s %s\n" "$f" "$(grep -o "[Ii]ncidente[s]* [0-9][0-9]*" $f | sort -u | tr '\n' ' ')"; done
echo; echo "=== fase13: checklist? ==="; grep -n -i "checklist\|una página\|post-mortem\|HOTFIX" forense-fase-13.md forense-master.md | head -20

# --- 2026-09-10T22:19:04 · Inspect transferable pattern blocks
for f in forense-fase-00.md forense-fase-04.md forense-fase-05.md forense-fase-10.md; do echo "=== $f"; awk '/🧠/{p=1} p' $f | head -25; done

# --- 2026-09-10T22:19:13 · Cross-check incident ID coverage
echo "=== IDs de incidentes citados en piezas ==="; grep -oh "Incidentes del cuaderno[^\n]*" forense-fase-*.md | grep -o "\*\*[0-9][0-9]\*\*" | tr -d '*' | sort -u | tr '\n' ' '; echo; for f in forense-fase-*.md; do printf "%-22s %s\n" "$f" "$(grep "Incidentes del cuaderno" $f | grep -o '\*\*[0-9][0-9]\*\*' | tr -d '*' | tr '\n' ' ')"; done
echo "=== índice cuaderno (IDs reservados) ==="; sed -n '122,174p' cuaderno-incidentes.md

# --- 2026-09-10T22:19:20 · Check incident 16 and 21 assignment
grep -n "Incidentes del cuaderno" forense-fase-06.md; echo "---"; grep -n "incidente\|Incidente" 06-ordenes.md 07-muestras-custodia.md | head -20

# --- 2026-09-10T22:19:26 · Check image rule and link consistency
sed -n '50,70p' prompts/formato-piezas-forenses.md; echo "=== capturas en piezas ==="; grep -ln "captura" forense-*.md; echo "=== enlaces sin ./ ==="; grep -n "](forense-" *.md | head; echo "=== README menciona piezas en listado ==="; grep -n "forense" README.md

# --- 2026-09-10T22:19:33 · Check README line 50 context and prompts docs
sed -n '40,60p' README.md; echo "=== alcance ==="; grep -n -i "forense" prompts/alcance-del-proyecto.md prompts/guia-de-estilo-y-convenciones.md prompts/propuesta-fases-y-alcance.md prompts/plantillas-de-capitulo.md prompts/prompts-de-redaccion.md | head -40

# --- 2026-09-10T22:19:40 · Read stale statements in prompts docs
sed -n '315,335p' prompts/propuesta-fases-y-alcance.md; echo "=== 196-215 ==="; sed -n '196,215p' prompts/propuesta-fases-y-alcance.md; echo "=== alcance 165-175 ==="; sed -n '128,148p;165,175p' prompts/alcance-del-proyecto.md

# --- 2026-09-10T22:19:50 · Check forensic table completeness
sed -n '215,225p' prompts/propuesta-fases-y-alcance.md; echo "=== 265,280 ==="; sed -n '265,280p' prompts/propuesta-fases-y-alcance.md

# --- 2026-09-10T22:22:39 · Search repo-wide references to the disposable analysis doc
cd /Users/oskar/Developer/Learning/courses-ia-generated && grep -rn "analisis-forense-tutoriales" --include="*.md" . | grep -v "^./analisis-forense-tutoriales.md:"; echo "EXIT=$?"

# --- 2026-09-10T22:22:45 · Check any other reference forms
echo "=== otros formatos ==="; grep -rn "analisis-forense" . 2>/dev/null | grep -v "^./analisis-forense-tutoriales.md:" | grep -v "^./.git/"; echo "--- fin ---"; echo "=== prosa: 'track forense — análisis' o 'plan de acción' ==="; grep -rln "A8-P1\|A8-P3\|R16-P2" --include="*.md" . | grep -v analisis-forense

# --- 2026-09-10T22:22:49 · Read section 9 exact lines
cd angular-8-legacy-for-backend-devs && sed -n '320,327p' prompts/propuesta-fases-y-alcance.md

# --- 2026-09-10T22:22:56 · Apply changes 1 and 4 to the proposal document
python3 - <<'PY'
import io,re
p='prompts/propuesta-fases-y-alcance.md'
s=io.open(p,encoding='utf-8').read()
old="""Ya no queda ninguna respuesta bloqueante: i18n se resolvió por runtime y las
catorce fases obligatorias están escritas. Lo que sigue son las **piezas forenses**
`forense-fase-00.md` a `forense-fase-14.md` y los **veintiún enunciados** del
cuaderno de incidentes,
cuyos IDs ya están reservados en el índice de `cuaderno-incidentes.md`."""
new="""Ya no queda ninguna respuesta bloqueante: i18n se resolvió por runtime, las
catorce fases obligatorias están escritas y el track forense está cerrado
—`forense-master.md` más las quince piezas `forense-fase-00.md` a
`forense-fase-14.md`—. Lo único que sigue son los **veintiún enunciados** del
cuaderno de incidentes, cuyos IDs ya están reservados en el índice de
`cuaderno-incidentes.md`."""
assert old in s
s=s.replace(old,new)
# cambio 4: arbol de archivos omite forense-master.md
old4="forense-fase-00.md ... forense-fase-14.md\n"
assert old4 in s
s=s.replace(old4,"forense-master.md\nforense-fase-00.md ... forense-fase-14.md\n")
io.open(p,'w',encoding='utf-8').write(s)
print("ok")
PY

# --- 2026-09-10T22:23:00 · Show exact capture mentions
grep -n "captura" 09-entrega-pdf.md 13-build-despliegue.md 14-casi-prod-kind.md | sed 's/\(.\{280\}\).*/\1…/'

# --- 2026-09-10T22:23:04 · Extract capture phrases
grep -n -o "con capturas[^,.—]*\|capturas de[^,.—]*\|capturas del[^,.—]*" 09-entrega-pdf.md 13-build-despliegue.md 14-casi-prod-kind.md

# --- 2026-09-10T22:23:10 · Replace capture promises across three phases
python3 - <<'PY'
import io
reps = {
 '09-entrega-pdf.md': [("con capturas de DevTools","con la salida de DevTools transcrita")],
 '13-build-despliegue.md': [
   ("con capturas del diff y el árbol de decisión del hotfix","con el diff transcrito y el árbol de decisión del hotfix"),
   ("capturas del `config.json` comparado","el `config.json` comparado, transcrito"),
 ],
 '14-casi-prod-kind.md': [
   ("con capturas y el árbol de decisión para pods que no arrancan","con la salida transcrita y el árbol de decisión para pods que no arrancan"),
   ("con capturas de `describe` y `logs --previous` en cada rama","con la salida de `describe` y de `logs --previous` transcrita en cada rama"),
 ],
}
for p,rs in reps.items():
    s=io.open(p,encoding='utf-8').read()
    for o,n in rs:
        assert o in s, (p,o)
        s=s.replace(o,n)
    io.open(p,'w',encoding='utf-8').write(s)
print("ok")
PY
grep -rn "captura" 0*-*.md 1*-*.md a*.md | grep -o "captura[a-z]*" | sort | uniq -c

# --- 2026-09-10T22:23:14 · Check remaining singular capture mentions
grep -rn -o ".\{60\}captura\b.\{60\}" 0*-*.md 1*-*.md a*.md

# --- 2026-09-10T22:23:21 · Update spec note about captures
python3 - <<'PY'
import io
p='prompts/formato-piezas-forenses.md'
s=io.open(p,encoding='utf-8').read()
old="""⚠️ Tres fases publicadas prometen "capturas" en su gancho o en sus referencias
—la **9**, la **13** y la **14**—. **Esa palabra es un lapsus del gancho, no un
contrato**: lo que la pieza entrega es esa misma evidencia transcrita. Es el único
punto donde la pieza no sigue la fase al pie de la letra, y se resuelve dando más,
no menos."""
new="""🪦 **Corregido al cerrar el track.** Tres fases publicadas —la **9**, la **13** y
la **14**— prometían "capturas" en su gancho o en sus referencias. Era un lapsus
del gancho, no un contrato: lo que la pieza entrega es esa misma evidencia
transcrita. Siguiendo el corolario de content lock de §5 —*se corrige la promesa,
no se reescribe la fase*—, esas cinco menciones se reemplazaron por la salida
transcrita. No queda ninguna promesa de imagen en el curso."""
assert old in s
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print("ok")
PY

# --- 2026-09-10T22:23:32 · Apply changes 3 and 5
python3 - <<'PY'
import io
# Cambio 3 — "embebido, no aparte"
old="El track forense va embebido en cada fase, no aparte."
new="Las horas del track forense van dentro de las de cada fase, no aparte."
p='README.md'
s=io.open(p,encoding='utf-8').read(); assert old in s
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))

p='prompts/alcance-del-proyecto.md'
s=io.open(p,encoding='utf-8').read()
old2="""margen que dio la ampliación. El track forense va **embebido** en cada fase, no
aparte."""
new2="""margen que dio la ampliación. Las **horas** del track forense van dentro de las de
cada fase, no aparte —el track sí tiene archivos propios: `forense-master.md` y las
quince piezas `forense-fase-NN.md`—."""
assert old2 in s
io.open(p,'w',encoding='utf-8').write(s.replace(old2,new2))

p='prompts/propuesta-fases-y-alcance.md'
s=io.open(p,encoding='utf-8').read()
old3="**108h de fases (track forense embebido) + 14h de cuaderno de incidentes.**"
new3="**108h de fases (horas del track forense incluidas) + 14h de cuaderno de incidentes.**"
assert old3 in s
s=s.replace(old3,new3)
old3b="## \U0001f575️ 5. Track forense\n\nEmbebido, repartido en las 14 fases obligatorias."
new3b="## \U0001f575️ 5. Track forense\n\nSus horas van repartidas en las 14 fases obligatorias; sus archivos son propios:\n`forense-master.md` y una pieza `forense-fase-NN.md` por fase."
assert old3b in s
io.open(p,'w',encoding='utf-8').write(s.replace(old3b,new3b))

# Cambio 5 — enlace sin ./
p='10-dashboard.md'
s=io.open(p,encoding='utf-8').read()
old5="[`forense-fase-10.md`](forense-fase-10.md)"
assert old5 in s
io.open(p,'w',encoding='utf-8').write(s.replace(old5,"[`forense-fase-10.md`](./forense-fase-10.md)"))
print("ok")
PY

# --- 2026-09-10T22:23:39 · Verify links and show diff summary
echo "=== enlaces rotos ==="; grep -oh "(\./[^)]*\.md)" *.md prompts/*.md | tr -d '()' | sed 's|^\./||' | sort -u | while read f; do [ -f "$f" ] || [ -f "prompts/$f" ] || echo "ROTO: $f"; done
echo "=== enlaces relativos de prompts/ ==="; grep -oh "(\.\./[^)]*\.md)" prompts/*.md | tr -d '()' | sed 's|^\.\./||' | sort -u | while read f; do [ -f "$f" ] || echo "ROTO: $f"; done
echo "=== fases: forma del enlace ==="; grep -c "](\./forense-fase" 10-dashboard.md
echo "=== diff ==="; cd .. && git diff --stat

# --- 2026-09-10T22:23:45 · Check tracking status of analysis doc
git ls-files --error-unmatch analisis-forense-tutoriales.md >/dev/null 2>&1 && echo "TRACKED (committed) — habrá que git rm cuando se elimine" || echo "untracked — basta con borrarlo"

