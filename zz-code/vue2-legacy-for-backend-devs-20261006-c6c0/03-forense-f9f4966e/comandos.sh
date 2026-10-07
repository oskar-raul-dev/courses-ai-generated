# Comandos Bash de la sesión f9f4966e-40c6-443c-bf3d-e3e59987dc49, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-10T02:18:54 · List course tree and read README
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs && ls -R . | head -100 && echo "=== README ===" && cat README.md

# --- 2026-09-10T02:18:59 · Read forensic content doc and list prompts
echo "=== contenido_forense.md ===" && cat contenido_forense.md && echo && echo "=== ls prompts + 02/forense ===" && ls prompts 02-complement-mongodb-backend/prompts 2>/dev/null && echo "=== git status subset ===" && git status --short . 

# --- 2026-09-10T02:19:03 · Read decisions section of forensic plan
f=/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/tool-results/bk6apq4o2.txt; sed -n '/## 5/,$p' "$f" | head -220

# --- 2026-09-10T02:19:11 · Check git status and file sizes
git status --short . && echo "=== wc piezas ===" && wc -l 01-vue2-legacy/forense-*.md 01-vue2-legacy/cuaderno-incidentes.md 02-complement-mongodb-backend/forense-*.md 02-complement-mongodb-backend/cuaderno-incidentes.md prompts/*.md 2>/dev/null

# --- 2026-09-10T02:19:16 · Inspect incident lists and phase stitching
for f in 01-vue2-legacy/cuaderno-incidentes.md 02-complement-mongodb-backend/cuaderno-incidentes.md; do echo "== $f"; grep -nE '^## ' "$f" | head -30; done; echo "=== ¿fases con línea forense o reservas? ==="; grep -rl "forense-fase\|Reservas para el cuaderno" 01-vue2-legacy/*.md 02-complement-mongodb-backend/*.md | grep -v forense- | grep -v cuaderno

# --- 2026-09-10T02:19:23 · Check remaining incidents and pending sections
grep -nE '^## ' 02-complement-mongodb-backend/cuaderno-incidentes.md | tail -6; echo "=== pendientes C01 ==="; sed -n '/## 📌 Pendientes/,$p' 01-vue2-legacy/cuaderno-incidentes.md; echo "=== pendientes C02 ==="; sed -n '/## 📌 Pendientes/,$p' 02-complement-mongodb-backend/cuaderno-incidentes.md

# --- 2026-09-10T02:19:29 · Inspect end and index of course 02 notebook
tail -25 02-complement-mongodb-backend/cuaderno-incidentes.md; echo "=== índice C02 ==="; sed -n '82,101p' 02-complement-mongodb-backend/cuaderno-incidentes.md

# --- 2026-09-10T02:20:03 · Outline the forensic plan document
wc -l contenido_forense.md && grep -nE '^#{2,4} |^### P[0-9]' contenido_forense.md

# --- 2026-09-10T02:20:13 · Read prompts P5 through P8
sed -n '762,912p' contenido_forense.md

# --- 2026-09-10T02:20:25 · Read status section and verify rector edits
sed -n '1046,1076p' contenido_forense.md; echo "=== P2 aplicado? ==="; git diff --stat prompts/ 01-vue2-legacy/03-mock-api-minima.md; grep -n "forense\|§16\|incidente" prompts/guia-de-estilo-y-convenciones.md | head -20; echo "--- plantilla ---"; grep -n "forense\|Reservas" prompts/plantilla-de-fase.md | head

# --- 2026-09-10T02:20:38 · Get notebook index and phase file lists
sed -n '/## 📋 Índice/,/## 🧪/p' 01-vue2-legacy/cuaderno-incidentes.md; echo "=== fases C01 ==="; ls 01-vue2-legacy/*.md | grep -vE 'forense|cuaderno|README|0-'; echo "=== fases C02 ==="; ls 02-complement-mongodb-backend/*.md | grep -vE 'forense|cuaderno|README'

# --- 2026-09-10T02:20:53 · Check symptom index piece assignments
grep -n "forense-fase\|forense-ruta" 02-complement-mongodb-backend/forense-master.md | head -30; echo "=== C01 master ==="; grep -n "forense-fase\|forense-ruta" 01-vue2-legacy/forense-master.md | head -30

# --- 2026-09-10T02:21:23 · Count phases, pieces and incidents
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
echo "tronco C01:"; ls 01-vue2-legacy/[0-9][0-9]-*.md | wc -l
echo "ruta C01:"; ls 01-vue2-legacy/{q,vu,nx}[0-9]-*.md | wc -l
echo "fases C02:"; ls 02-complement-mongodb-backend/[0-9][0-9]-*.md | grep -v audit | wc -l
echo "piezas totales:"; ls 0*/forense-*.md | wc -l
grep -c "^## Incidente" 01-vue2-legacy/cuaderno-incidentes.md 02-complement-mongodb-backend/cuaderno-incidentes.md

# --- 2026-09-10T02:21:45 · Mark P5 and P6 state in the plan
python3 - <<'PY'
import io,re
p='contenido_forense.md'
s=io.open(p,encoding='utf-8').read()

# --- 1. Nota de estado en la cabecera de §8 ---
old_h8 = """## 8. 🎬 Los prompts

Todos asumen que el chat arranca en `vue2-legacy-for-backend-devs/`. Las decisiones D0–D6
ya están dentro: no hay que repetírselas al chat.
"""
new_h8 = """## 8. 🎬 Los prompts

Todos asumen que el chat arranca en `vue2-legacy-for-backend-devs/`. Las decisiones D0–D6
ya están dentro: no hay que repetírselas al chat.

> 🚦 **Estado, a 2026-09-09.** P0 a P5 están **ejecutados** (sin commitear todavía) y se
> conservan aquí como registro de lo que se pidió, no como trabajo por hacer. P6 está a
> medias. Lo que queda vivo son **P6-bis, P7-A, P7-B y P8**, que ya vienen cerrados: traen
> dentro las listas exactas de archivos, el mapeo 📄 y las tablas de reservas, así que se
> pegan y se ejecutan sin volver a inventariar nada. El checklist de §12 dice dónde estás.
"""
assert old_h8 in s; s = s.replace(old_h8, new_h8)

# --- 2. P5: marcar cerrado y anotar la deuda que dejó ---
old_p5 = "### P5 · Una tanda de piezas forenses\n"
new_p5 = """### P5 · Una tanda de piezas forenses ✅ **ejecutado — 29 piezas**

> ✅ **Cerrado.** Curso 01: `forense-master.md`, `forense-fase-00.md` … `forense-fase-11.md`
> (12) y las tres de ruta. Curso 02: `forense-master.md` y 12 piezas —F0, F1, F2, F4, F5,
> F6, F7, F8, F9, F10, F12, F13—, que es el piso de D5; **F3, F11, F14 y F15 se quedaron
> sin pieza a propósito** y así lo refleja el 🩺 índice de síntomas de su master.
>
> ⚠️ **La deuda que dejó.** El último bloque de este prompt pedía entregar, junto a cada
> pieza, el párrafo de la línea 📄, el bloque 🧨 y la tabla de reservas «para pegar en su
> fase». Esas entregas **no se persistieron en ningún archivo**: se quedaron en el chat. Por
> eso P7-A y P7-B traen las tablas de reservas ya reconstruidas desde el índice de cada
> cuaderno — no hay que volver a deducirlas, y no se recalculan.

"""
assert old_p5 in s; s = s.replace(old_p5, new_p5, 1)

# --- 3. P6: marcar parcial ---
old_p6 = "### P6 · Una tanda de incidentes\n"
new_p6 = """### P6 · Una tanda de incidentes ⏳ **ejecutado a medias — 23 de 24**

> ⏳ **Estado.** Curso 01: los 12 incidentes escritos, más 🪞 retrospectiva y 📌 pendientes.
> Curso 02: **11 de 12**, sin retrospectiva y sin pendientes. El índice del Curso 02 ya
> reserva la fila 12 en ⬜. Lo que falta lo cierra **P6-bis**, aquí abajo.

"""
assert old_p6 in s; s = s.replace(old_p6, new_p6, 1)
io.open(p,'w',encoding='utf-8').write(s)
print("ok")
PY

# --- 2026-09-10T02:21:51 · Read course 01 retrospective as model
sed -n '/## 🪞 Retrospectiva/,/## 📌 Pendientes/p' 01-vue2-legacy/cuaderno-incidentes.md | head -40

# --- 2026-09-10T02:22:56 · Insert P6-bis and rewrite P7 as two concrete prompts
python3 - <<'PY'
import io
p='contenido_forense.md'
s=io.open(p,encoding='utf-8').read()

p6bis = """### P6-bis · La última tanda del Curso 02 ⬅️ **cerrado, listo para pegar**

```
Lee prompts/formato-cuaderno-incidentes.md, prompts/guia-de-estilo-y-convenciones.md §14,
prompts/convencion-de-git-y-tags.md (§🚑 y §💸),
02-complement-mongodb-backend/cuaderno-incidentes.md COMPLETO (los 11 incidentes ya
escritos, para no repetir causa raíz ni tono),
02-complement-mongodb-backend/forense-fase-13.md y 13-testing-de-api.md.

Editas UN SOLO ARCHIVO: 02-complement-mongodb-backend/cuaderno-incidentes.md. Es una
edición ADITIVA al final: no toques los 11 incidentes existentes, ni el encabezado, ni
🧭 «Cómo se trabaja un incidente», ni las 12 filas del 📋 índice (ya están todas, incluida
la 12 en ⬜).

Añade tres cosas, en este orden, y nada más:

1) INCIDENTE 12 — "Verde en mi máquina, rojo en CI" · Fase 13 · Testing · 🔴
   Plantilla completa de §7 del formato, la misma que usan los 11 anteriores. El ticket
   viene de quien mira el pipeline, no de un usuario final: es el único del cuaderno que
   no lo reporta alguien de soporte, y eso se nota en la voz.
   La causa raíz tiene que ser PROPIA — ninguno de los 11 anteriores la toca — y tiene que
   ser de las que solo aparecen contra una base de verdad. Elige UNA y comprométete:
   estado que sobrevive entre tests porque la suite no limpia la colección y en local la
   base venía sucia de otra forma; o el orden de los tests, que en local es el del
   filesystem y en el runner no; o índices únicos que existen en tu máquina porque los
   creaste a mano en la Fase 7 y en CI nadie los creó.
   La ruta de diagnóstico es la de forense-fase-13.md: enlázala con la línea 📄, no la
   repitas. La prueba de regresión va EN CÓDIGO y es la parte central de la solución de
   referencia — en un incidente de testing, el fix ES un test que falla primero.
   Marca la fila 12 del 📋 índice como escrita si tu formato lo distingue del ⬜ reservado.

2) 🪞 RETROSPECTIVA, modelada sobre la del Curso 01 (léela): párrafo de encuadre, tabla
   vacía de 12 filas con las columnas | ID | Capa donde vivía | Pista que lo resolvió |
   Cuánto tardaste | Lo habrías visto antes si… |, y tres preguntas de cierre.
   Las preguntas NO se copian del Curso 01: allí apuntan al estado del frontend, aquí
   tienen que apuntar a lo de este curso — cuántos se resolvieron sin abrir código de
   aplicación, cuántos eran modelado disfrazado de rendimiento, y cuántos los habría
   evitado el contrato si alguien lo hubiera leído antes de escribir el endpoint.

3) 📌 PENDIENTES, con lo que salió de los 12 incidentes y NO se arregla en este curso, cada
   uno con su motivo. Candidatos que el material ya dejó abiertos: lo que 15-el-veredicto-
   honesto.md concede que Mongo no hace bien, lo que a04-seguridad.md deja anotado, y las
   deudas 💸 del Curso 01 que este curso paga solo a medias. Cierra con un 🧭 que diga qué
   tienen en común, como hace el del Curso 01.
   ⚠️ INDEPENDENCIA (D3): puedes nombrar una deuda que viene del frontend porque el propio
   curso la nombra, pero sin exigir haber hecho el Curso 01 para entender la frase.

Reglas del paquete: código en inglés, comentarios y narrativa en español con tuteo, driver
nativo antes de Mongoose, y nada que contradiga 00-audit-contrato.md.
```

---

"""

anchor = "### P7 · Coser el track a las fases"
i = s.index(anchor)
s = s[:i] + p6bis + s[i:]

# reemplazar el bloque P7 entero (hasta el separador previo a P8)
start = s.index("### P7 · Coser el track a las fases")
end = s.index("### P8 · Auditoría de cierre")

p7 = """### P7-A · Coser el track a las fases del Curso 01 ⬅️ **cerrado, listo para pegar**

```
Lee prompts/formato-piezas-forenses.md §5, prompts/plantilla-de-fase.md (secciones 6 y
📌 reservas), prompts/guia-de-estilo-y-convenciones.md §9.2, 01-vue2-legacy/forense-master.md
y 01-vue2-legacy/cuaderno-incidentes.md (el 📋 índice).
Antes de tocar cada fase, lee su pieza forense: el resumen que escribas tiene que ser el de
ESA pieza, no uno genérico.

Editas 27 archivos de 01-vue2-legacy/ y su README. En cada fase tocas SOLO la sección 6 y
el bloque de reservas antes del cierre. No reescribas los «Errores comunes» que ya existen,
no toques ejercicios, código, referencias ni el bloque 🏷️. Es costura.

En cada fase de tronco (00 … 11):
1. El encabezado de la sección 6 pasa a «## ⚠️ Errores comunes y pieza forense».
2. Debajo de «Errores comunes», «### Pieza forense de esta fase»: el resumen que se lee de
   corrido, el bloque 🧨 «Rompe a propósito» y la línea de forma fija
   «> 📄 El recorrido completo, con las salidas literales, en `forense-fase-NN.md`.»
   Tabla de frontera del §5 del formato: si un párrafo cabe igual en los dos sitios, va en
   la fase y la pieza lo enlaza.
3. Antes del cierre, «### 📌 Reservas para el cuaderno de incidentes» con SU fila, enlazada
   al cuaderno. Las reservas ya están decididas — NO las recalcules ni las reasignes:

   F0  → 01 "Clonaste el repo y no me arranca, a ti sí te funciona"      · Build       · 🟢
   F1  → (ninguna: esta fase no reserva incidente; NO inventes uno)
   F2  → 03 "Me sacó al login a mitad de la mañana, sin decir nada"      · Estado      · 🟡
   F3  → 02 "A veces carga y a veces se queda pensando"        · Integración (mock)    · 🟢
   F4  → 04 "Pongo el filtro y la tabla se queda con lo de antes"        · Estado      · 🟡
   F5  → 05 "Le puse la etiqueta y la tabla no se enteró"                · Reactividad · 🟡
   F6  → 06 "Volví atrás en el asistente y perdí la descripción"  · Formularios/wizard · 🟡
   F7  → 07 "A la media hora la laptop suena como un avión"              · Reactividad · 🟠
   F8  → 08 "Se me duplican los tickets cuando entra uno nuevo"          · Tiempo real · 🟠
   F9  → 09 "Tomé el ticket y a mi compañera le sigue apareciendo libre" · Estado      · 🟠
   F10 → 10 "El contador del menú dice una cosa y la tabla otra"    · Estado (Vuex)    · 🟠
         12 "En el servidor de pruebas se comporta distinto que en mi máquina" · Build · 🔴
   F11 → 11 "El test pasa solo cuando lo corro aislado"                  · Testing     · 🔴

En las 15 fases de ruta (q0…q4, vu0…vu4, nx0…nx4):
- Misma operación, pero la línea 📄 apunta a la pieza de SU ruta —forense-ruta-q.md,
  forense-ruta-vu.md, forense-ruta-nx.md—, que es una sola para las cinco fases.
- Respeta la numeración explícita §N donde la fase ya la use: hoy solo q1, q3, vu1 y vu3.
- Las fases de ruta NO reservan incidentes: ninguna lleva bloque 📌. El cuaderno del Curso
  01 no tiene ni una fila de ruta, y así se queda (las rutas son excluyentes: un incidente
  de ruta sería material que dos tercios de los lectores no pueden preparar).

En los 5 apéndices (a1…a5) NO se hace NADA: ni sección 6 renombrada, ni línea 📄, ni
reservas, ni tag. Guía §9.1.

Al final, 01-vue2-legacy/README.md: dos bloques nuevos modelados sobre los del README de
../angular-16-legacy-for-backend-devs/, «🕵️ Track forense» (tabla de las 12 piezas + las 3
de ruta con su síntoma, copiada del 🩺 índice del master) y «📓 Cuaderno de incidentes» (12
incidentes, el trato, y que se puede empezar en cualquier orden).
```

---

### P7-B · Coser el track a las fases del Curso 02 ⬅️ **cerrado, listo para pegar**

```
Igual que P7-A, con el mismo formato de sección 6 y el mismo bloque 📌, pero sobre
02-complement-mongodb-backend/ (16 fases: 00-preliminares … 15-el-veredicto-honesto).
Lee antes forense-master.md de ESE curso y su cuaderno-incidentes.md.

Dos particularidades que NO son erratas y que no debes «arreglar»:

1) CUATRO FASES NO TIENEN PIEZA — F3, F11, F14 y F15 (D5: 12 es el piso, y una pieza sin
   recorrido propio se convierte en resumen de la fase). En esas cuatro, la sección 6 se
   queda como está: encabezado «## ⚠️ Errores comunes» sin renombrar, sin bloque «Pieza
   forense de esta fase» y sin línea 📄. No inventes la pieza que falta y no enlaces la de
   otra fase. Las 12 restantes sí llevan las tres cosas.

2) F3 RESERVA UN INCIDENTE PERO NO TIENE PIEZA, y F4 tiene pieza pero no reserva ninguno.
   Es correcto: el incidente 04 nace del modelado de F3 y su ruta de diagnóstico es la de
   F5. En F3, el bloque 📌 va igual, y la fila enlaza al cuaderno directamente.

Reservas ya decididas — no las recalcules:

   F0  → 01 "El contenedor está arriba y nadie conecta"                  · Operación   · 🟢
   F1  → 02 "El ticket está en la base y mi script no lo encuentra"      · Consultas   · 🟡
   F2  → 03 "El reporte de sin asignar da dos números distintos"         · Consultas   · 🟡
   F3  → 04 "Hay tickets que tardan diez veces más que los demás"        · Modelado    · 🟡
   F4  → (ninguna)
   F5  → 05 "El tablero tarda cuatro segundos y antes iba bien"          · Modelado    · 🟠
   F6  → 06 "Dos agentes tomaron el mismo ticket"                        · Atomicidad  · 🟠
   F7  → 07 "Creamos el índice y sigue igual de lento"                   · Índices     · 🟠
   F8  → 08 "La migración pasó el conteo y los reportes salen mal"       · Modelado    · 🟠
   F9  → 09 "El reporte por estado devuelve una sola línea"              · Consultas   · 🟠
   F10 → 10 "Apunté el frontend al backend nuevo y no se ve nada"        · Contrato    · 🔴
   F11 → (ninguna)
   F12 → 11 "En vivo llega mal y al recargar se ve bien"                 · Contrato    · 🔴
   F13 → 12 "Verde en mi máquina, rojo en CI"                            · Testing     · 🔴
   F14, F15 → (ninguna)

En los 5 apéndices (a01…a05) NO se hace nada. Y 00-audit-contrato.md NO es una fase: no se
toca, no lleva sección 6 forense y no reserva nada.

Al final, 02-complement-mongodb-backend/README.md con los dos bloques 🕵️ y 📓, igual que
P7-A pero con las 12 piezas de este curso.

⚠️ P7-B depende de P6-bis: si el incidente 12 todavía no existe, la fila que F13 reserva
apunta a un ancla que no está. Ejecuta P6-bis primero.
```

---

"""
s = s[:start] + p7 + s[end:]
io.open(p,'w',encoding='utf-8').write(s)
print("ok")
PY

# --- 2026-09-10T02:23:15 · Pin P8 inventory and fix phase counts
python3 - <<'PY'
import io
p='contenido_forense.md'
s=io.open(p,encoding='utf-8').read()

# --- §7: actualizar la tabla de pasos con los prompts cerrados y el conteo real de fases ---
old = "| 6 | **Los cuadernos** | 2 × `cuaderno-incidentes.md`, en tandas de 4 incidentes | **P6** | uno por tanda |\n| 7 | **La costura** | Secciones 6 de las 33 fases + los dos README | **P7** | uno por curso |\n| 8 | **La auditoría** | Verificación cruzada de enlaces, IDs y contrato | **P8** | — |"
new = "| 6 | **Los cuadernos** | 2 × `cuaderno-incidentes.md`, en tandas de 4 incidentes | **P6** · **P6-bis** | uno por tanda |\n| 7 | **La costura** | Secciones 6 de las **43 fases** + los dos README | **P7-A** · **P7-B** | uno por curso |\n| 8 | **La auditoría** | Verificación cruzada de enlaces, IDs y contrato | **P8** | — |\n\n> 📐 **43, no 33.** El §6 contaba «17 fases» en el Curso 01 asumiendo que el estudiante
> hace una sola ruta. Para coser hay que tocarlas todas: **12 de tronco + 15 de ruta = 27**
> en el Curso 01, más **16** en el Curso 02. Los 10 apéndices no cuentan: no se tocan."
assert old in s; s = s.replace(old, new)

# --- P8: anclar el inventario concreto ---
old_p8 = "### P8 · Auditoría de cierre\n\n```\nAudita el track forense completo del paquete y entrega un informe, sin corregir nada\ntodavía. Comprueba:\n"
new_p8 = """### P8 · Auditoría de cierre ⬅️ **cerrado, se ejecuta al final**

```
Audita el track forense completo del paquete y entrega un informe, sin corregir nada
todavía. El inventario a auditar, para que no tengas que descubrirlo:

  01-vue2-legacy/    forense-master.md · forense-fase-00…11.md (12) · forense-ruta-q/-vu/-nx.md (3)
                     cuaderno-incidentes.md (12 incidentes) · 27 fases · 5 apéndices
  02-complement-…/   forense-master.md · 12 piezas (F0,1,2,4,5,6,7,8,9,10,12,13)
                     cuaderno-incidentes.md (12 incidentes) · 16 fases · 5 apéndices
  prompts/           formato-piezas-forenses.md · formato-cuaderno-incidentes.md ·
                     convencion-de-git-y-tags.md · guia-de-estilo-y-convenciones.md ·
                     plantilla-de-fase.md

Dos ausencias son DELIBERADAS y no se reportan como hallazgo: las piezas que no existen
para F3, F11, F14 y F15 del Curso 02 (D5), y las fases de ruta del Curso 01, que no
reservan ningún incidente. Repórtalas solo si la ausencia es INCONSISTENTE — una línea 📄
que apunte a una de esas cuatro, por ejemplo.

Comprueba:
"""
assert old_p8 in s; s = s.replace(old_p8, new_p8)

io.open(p,'w',encoding='utf-8').write(s)
print("ok")
PY

# --- 2026-09-10T02:23:29 · Pin P8 inventory and fix phase counts
python3 - <<'PY'
import io
p='contenido_forense.md'
s=io.open(p,encoding='utf-8').read()

old = "| 6 | **Los cuadernos** | 2 × `cuaderno-incidentes.md`, en tandas de 4 incidentes | **P6** | uno por tanda |\n| 7 | **La costura** | Secciones 6 de las 33 fases + los dos README | **P7** | uno por curso |\n| 8 | **La auditoría** | Verificación cruzada de enlaces, IDs y contrato | **P8** | — |"
new = """| 6 | **Los cuadernos** | 2 × `cuaderno-incidentes.md`, en tandas de 4 incidentes | **P6** · **P6-bis** | uno por tanda |
| 7 | **La costura** | Secciones 6 de las **43 fases** + los dos README | **P7-A** · **P7-B** | uno por curso |
| 8 | **La auditoría** | Verificación cruzada de enlaces, IDs y contrato | **P8** | — |

> 📐 **43, no 33.** El §6 contaba «17 fases» en el Curso 01 asumiendo que el estudiante hace
> una sola ruta. Para coser hay que tocarlas todas: **12 de tronco + 15 de ruta = 27** en el
> Curso 01, más **16** en el Curso 02. Los 10 apéndices no cuentan: no se tocan."""
assert old in s; s = s.replace(old, new)

old_p8 = """### P8 · Auditoría de cierre

```
Audita el track forense completo del paquete y entrega un informe, sin corregir nada
todavía. Comprueba:
"""
new_p8 = """### P8 · Auditoría de cierre ⬅️ **cerrado, se ejecuta al final**

```
Audita el track forense completo del paquete y entrega un informe, sin corregir nada
todavía. El inventario a auditar, para que no tengas que descubrirlo:

  01-vue2-legacy/    forense-master.md · forense-fase-00…11.md (12) · forense-ruta-q/-vu/-nx.md
                     cuaderno-incidentes.md (12 incidentes) · 27 fases · 5 apéndices
  02-complement-…/   forense-master.md · 12 piezas (F0,1,2,4,5,6,7,8,9,10,12,13)
                     cuaderno-incidentes.md (12 incidentes) · 16 fases · 5 apéndices
  prompts/           formato-piezas-forenses.md · formato-cuaderno-incidentes.md ·
                     convencion-de-git-y-tags.md · guia-de-estilo-y-convenciones.md ·
                     plantilla-de-fase.md

Dos ausencias son DELIBERADAS y no se reportan como hallazgo: las piezas que no existen
para F3, F11, F14 y F15 del Curso 02 (D5), y las fases de ruta del Curso 01, que no
reservan ningún incidente. Repórtalas solo si la ausencia es INCONSISTENTE — una línea 📄
que apunte a una de esas cuatro, por ejemplo.

Comprueba:
"""
assert old_p8 in s; s = s.replace(old_p8, new_p8)
io.open(p,'w',encoding='utf-8').write(s)
print("ok")
PY

# --- 2026-09-10T02:24:08 · Rewrite status section and append checklist
python3 - <<'PY'
import io
p='contenido_forense.md'
s=io.open(p,encoding='utf-8').read()

start = s.index("## 11. 🚦 Estado y siguiente paso")
nuevo = """## 11. 🚦 Estado y siguiente paso

**Decisiones cerradas:** D0 a D6, recogidas en §5 e incorporadas a los prompts.

**Los apéndices, cerrado:** la regla §9.1 se honra tal como está y el plan entero la
respeta (§3.5). Ningún `.md` de apéndice lleva bloque 🏷️ ni tag de fase, P0 tuvo prohibido
tocar §9.1, P2 lo repitió en su punto 5, P7-A y P7-B lo repiten en su última regla y P8 lo
audita apéndice por apéndice. Lo que P0 añadió es solo lo que faltaba —el prefijo de commit
(`a4:`, `a02:`) y el `ej/a01/3`—, más una línea que menciona `apendice-aNN` como opción del
estudiante. El material nunca se lo pide.

**Lo ejecutado, a 2026-09-09:** pasos 0 a 5 completos y el 6 a medias. En el árbol hay 29
archivos forenses nuevos, dos cuadernos (12 + 11 incidentes), los dos formatos, y cuatro
archivos rectores modificados. **Nada de esto está commiteado todavía.**

**Siguiente paso:** **P6-bis** — un archivo, tres bloques, cierra el cuaderno del Curso 02.
Después **P7-A**, **P7-B** y, al final de todo, **P8**. Los cuatro prompts están cerrados en
§8: traen las listas de archivos y las tablas de reservas dentro, así que se pegan tal cual.

> 🪦 **Recordatorio, corregido.** El encabezado dice que este archivo se borra cuando P0, P1
> y P2 estén cerrados. Ya lo están — y borrarlo hoy tiraría P6-bis, P7-A, P7-B y P8, que
> viven aquí y no en ningún otro sitio. **La condición real de borrado es que P8 pase.** Lo
> de §3 ya migró a `prompts/convencion-de-git-y-tags.md` y lo de §8/P1 a los dos formatos;
> lo único que quedará sin hogar el día del borrado son los prompts de costura, y para
> entonces la costura ya estará hecha.

---

## 12. ✅ Checklist — dónde estoy parado

Marca aquí y no en la cabeza. Estado verificado contra el árbol el **2026-09-09**.

### 12.1 Los ocho pasos

| Paso | Prompt | Estado | Evidencia en el árbol |
|---|---|---|---|
| 0 · La convención | P0 | ✅ | `prompts/convencion-de-git-y-tags.md`, 423 líneas (+194) |
| 1 · Los formatos | P1 | ✅ | `formato-piezas-forenses.md` (283) · `formato-cuaderno-incidentes.md` (483) |
| 2 · Los rectores | P2 | ✅ | guía §9.2 + §13.2 · plantilla con sección 6 y bloque 📌 |
| 3 · Las puertas | P3 | ✅ | los dos `forense-master.md` (193 y 187) con su 🩺 índice |
| 4 · El caos | P4 | ✅ | `03-mock-api-minima.md` (+190 líneas, sección 🔥) |
| 5 · Las piezas | P5 | ✅ | 15 en el Curso 01 · 12 en el Curso 02 · 29 con los masters |
| 6 · Los cuadernos | P6 / **P6-bis** | ⏳ | C01 completo · **C02: 11/12, sin 🪞 ni 📌** |
| 7 · La costura | **P7-A** · **P7-B** | ⬜ | ninguna fase tiene línea 📄 ni bloque 📌 todavía |
| 8 · La auditoría | **P8** | ⬜ | — |

### 12.2 Lo que falta, archivo por archivo

- ⏳ `02-complement-mongodb-backend/cuaderno-incidentes.md` — falta el **incidente 12**
  ("Verde en mi máquina, rojo en CI", F13, Testing, 🔴), la **🪞 retrospectiva** y los
  **📌 pendientes**. La fila 12 ya está reservada en ⬜ en el índice. → **P6-bis**
- ⬜ **27 fases** del Curso 01 (12 de tronco + 15 de ruta): sección 6 renombrada, resumen,
  bloque 🧨, línea 📄 y —solo el tronco— bloque 📌. → **P7-A**
- ⬜ **16 fases** del Curso 02, de las cuales 12 llevan línea 📄 y 4 (F3, F11, F14, F15) se
  quedan sin ella a propósito. → **P7-B**
- ⬜ **Los dos README de curso**: bloques «🕵️ Track forense» y «📓 Cuaderno de incidentes».
- ⬜ **La auditoría cruzada** de enlaces, IDs, síntomas, contrato y tuteo. → **P8**
- ⬜ **El README del paquete** (raíz) no menciona el track forense ni los cuadernos en su
  tabla «📂 Qué hay en la raíz» ni en el mapa 🗺️. Es media hora y se hace con P7.
- ⬜ **Nada está commiteado.** El orden de commits que el plan pide sigue siendo válido:
  la convención sola primero, después formatos, rectores, puertas, caos, piezas, cuadernos
  y costura.

### 12.3 Los cinco invariantes que P8 va a mirar

Si dudas mientras escribes, éstos son los que se rompen sin avisar:

1. **IDs por curso, nunca compartidos** (D3), y ninguno reasignado.
2. **Independencia**: el Curso 01 no cita al 02; los incidentes de costura del 02 son
   autocontenidos.
3. **Los apéndices no llevan nada**: ni 🏷️, ni 📄, ni 📌, ni tag (guía §9.1).
4. **Cero salidas inventadas.** P8 no puede detectarlo: corre F3, F5, F8 y F10 a mano.
5. **Código en inglés, narrativa en español con tuteo** — y el voseo se cuela en los
   tickets, que están escritos en voz de usuario.

### 12.4 Lo que este repaso encontró y no estaba anotado

- **P5 dejó una deuda**: los párrafos 📄, los bloques 🧨 y las tablas de reservas que
  entregó «para pegar en la fase» no se guardaron en ningún archivo. Reconstruidas desde el
  índice de cada cuaderno y **ya incrustadas en P7-A y P7-B**, que es donde se usan.
- **El conteo de fases estaba mal** en §6 y en el P7 original: 43, no 33 (§7).
- **La condición de borrado de este documento estaba mal**: no es «P0, P1 y P2 cerrados»
  sino «P8 en verde» (§11).
- **Asimetría deliberada en el Curso 02**: F3 reserva incidente y no tiene pieza; F4 tiene
  pieza y no reserva incidente. Documentado en P7-B y exento en P8 para que nadie lo
  «arregle» dos meses después.
"""
s = s[:start] + nuevo
io.open(p,'w',encoding='utf-8').write(s)
print(len(s.splitlines()))
PY

# --- 2026-09-10T02:24:13 · Verify document outline
grep -nE '^#{2,3} ' contenido_forense.md | sed -n '1,40p'

# --- 2026-09-10T02:24:21 · Fix phase counts in inventory section
python3 - <<'PY'
import io
p='contenido_forense.md'
s=io.open(p,encoding='utf-8').read()
s=s.replace("│   ├── (las 17 fases)                      ✏️  sección 6 + línea 📄 + reservas de IDs",
            "│   ├── (las 27 fases: 12 tronco + 15 ruta) ✏️  sección 6 + línea 📄 + reservas de IDs")
s=s.replace("    ├── (las 16 fases)                      ✏️  sección 6 + línea 📄 + reservas",
            "    ├── (las 16 fases; 12 con línea 📄)      ✏️  sección 6 + línea 📄 + reservas")
io.open(p,'w',encoding='utf-8').write(s)
PY
sed -n '/(las 27 fases/p;/(las 16 fases/p' contenido_forense.md

# --- 2026-09-10T02:26:03 · Read incident template spec
sed -n '/^## 7/,/^## 8/p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-10T02:26:09 · Outline notebook format spec
grep -nE '^#{2,3} ' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-10T02:26:13 · Read incident template, retrospective and pending specs
sed -n '276,483p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-10T02:26:18 · Read forensic piece for phase 13
sed -n '1,90p' 02-complement-mongodb-backend/forense-fase-13.md

# --- 2026-09-10T02:26:27 · Read incident 11 as tone model
sed -n '/^## Incidente 11/,/^### 📝 Tu investigación/p' 02-complement-mongodb-backend/cuaderno-incidentes.md

# --- 2026-09-10T02:26:47 · Inspect testing phase setup
grep -nE 'memory-server|globalSetup|MONGO_URL|jest|createIndex|beforeEach|beforeAll|dropDatabase|CI' 02-complement-mongodb-backend/13-testing-de-api.md | head -40; echo ---; sed -n '90,200p' 02-complement-mongodb-backend/forense-fase-13.md

# --- 2026-09-10T02:27:01 · Find index definitions and test helpers
grep -nE 'createIndex|unique|scripts/|ensureIndexes' 02-complement-mongodb-backend/07-indices.md | head -30; echo "--- helpers 13 ---"; sed -n '140,270p' 02-complement-mongodb-backend/13-testing-de-api.md

# --- 2026-09-10T02:27:33 · Check date bucketing usage in course
grep -nE 'dateToString|timezone|por día|TZ=|America/|reports\.service|dailyC|\$dateTrunc' 02-complement-mongodb-backend/*.md | head -30

# --- 2026-09-10T02:27:37 · Inspect API contract endpoints
grep -nE '^\|.*(GET|POST|PATCH|PUT|DELETE) |stats|metrics|summary' 02-complement-mongodb-backend/00-audit-contrato.md | head -40

# --- 2026-09-10T02:27:52 · Search timezone mentions in course 02
grep -rniE 'zona horaria|UTC|TZ|huso' 02-complement-mongodb-backend/*.md | grep -v forense | head -20

# --- 2026-09-10T02:27:57 · Read incident 02 root cause
sed -n '300,360p' 02-complement-mongodb-backend/cuaderno-incidentes.md

# --- 2026-09-10T02:28:16 · Read preparation forms and a sample incident header
sed -n '182,220p' prompts/formato-cuaderno-incidentes.md; echo "=== C02 prep de otro incidente ==="; sed -n '/^## Incidente 09/,/Pista 1/p' 02-complement-mongodb-backend/cuaderno-incidentes.md | sed -n '1,45p'

# --- 2026-09-10T02:28:23 · Scan verdict, security appendix and debt phase
grep -nE '^#{2,3} ' 02-complement-mongodb-backend/15-el-veredicto-honesto.md | head -20; echo ---; grep -nE '^#{2,3} ' 02-complement-mongodb-backend/a04-seguridad.md | head -15; echo "--- deudas 11 ---"; grep -nE '^#{2,3} |SECURITY-NOTES' 02-complement-mongodb-backend/11-auth-real-y-pago-de-deudas.md | head -20

# --- 2026-09-10T02:28:32 · Read states section and file ending
sed -n '264,276p' prompts/formato-cuaderno-incidentes.md; echo "=== fin del archivo C02 ==="; tail -4 02-complement-mongodb-backend/cuaderno-incidentes.md | cat -A | tail -4

# --- 2026-09-10T02:29:05 · Check phase tag and forensic links in notebook
grep -n "🏷️" -A4 02-complement-mongodb-backend/13-testing-de-api.md | head -12; echo ---; grep -n "📄\|forense-fase" 02-complement-mongodb-backend/cuaderno-incidentes.md | head

# --- 2026-09-10T02:30:02 · Append incident 12 to course 02 notebook
cat >> 02-complement-mongodb-backend/cuaderno-incidentes.md <<'EOF'
## Incidente 12 — "Verde en mi máquina, rojo en CI"

> **Fase:** 13 · **Categoría:** Testing · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "Monté el pipeline el viernes y desde entonces la suite falla allá y pasa acá.
> Siempre el mismo archivo, `test/lib/serializers.test.js`, y siempre el mismo
> assert: dice que esperaba una fecha y recibió otra, con unas horas de
> diferencia. En mi máquina pasa en verde en cada corrida, y en la de todo el
> equipo también. Ese código no lo toca nadie desde que se escribió."

**Reportado por:** el compañero que montó el pipeline · **Ambiente:** local y CI

### 🎯 Qué se te pide

Tres cosas, y la primera es la que de verdad se parece al trabajo:

1. **Reproducir el rojo en tu propia máquina.** No tienes acceso al runner para
   depurar dentro, y ése es el caso normal, no una limitación del ejercicio.
2. Causa raíz hasta el archivo, fix y prueba de regresión.
3. Una decisión de diseño: al final hay **dos arreglos posibles**, y solo uno de
   los dos arregla el sistema — el otro arregla el test. Di cuál es cuál, aplica
   los dos, y justifica el orden.

> ⚠️ La Fase 13 te enseñó una causa clásica para exactamente este síntoma, y la
> pieza forense la recorre entera. **Aquí no es ésa**, y descartarla con evidencia
> —no con un "no puede ser"— es el primer paso de la investigación.

### 🔧 Preparación

Forma 3, una rama de git: hace falta código distinto del que dejó la fase, y sale
del tag que ya tienes.

```bash
git switch -c incidente/12 fase-13-testing-de-api
# el commit de la rama toca DOS líneas: una fixture y un assert. Nada más.
npm ci
npx jest test/lib/serializers.test.js
```

```
PASS  test/lib/serializers.test.js
```

Sí: en tu máquina pasa. Ése es el problema, no la buena noticia.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No empieces por el serializer. Empieza por la pregunta del método: **qué es
distinto entre los dos entornos**, si el código es el mismo commit. La lista corta
es siempre la misma —motor, orden de ejecución, paralelismo, datos previos y
**reloj**— y se descarta de la más barata a la más cara.

La más barata de todas cuesta una línea y no toca la suite:

```bash
node -e "console.log(Intl.DateTimeFormat().resolvedOptions().timeZone, new Date().getTimezoneOffset())"
```

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Lee el assert que falla y hazte la pregunta incómoda: **la cadena literal con la
que compara, ¿de dónde salió?** Nadie la calculó a mano.

Después mira cómo construye su `createdAt` la fixture de ese test, en
`test/fixtures/index.js`, y vuelve a leer el ejercicio 25 de la
[Fase 1](01-mongo-en-30-min.md). Está advertido desde el primer capítulo del
curso, sobre el seed — y acabó pasando en los tests.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`new Date("2021-03-01 23:30")`, ¿qué instante produce en tu máquina? ¿Y el mismo
string en un contenedor configurado en UTC?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**En qué capa vivía**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El test tiene grabado el huso horario de quien lo escribió, en
dos mitades que por separado parecen inocentes:

```js
// test/fixtures/index.js
createdAt: new Date("2021-03-01 23:30")          // ← string SIN zona
```

```js
// test/lib/serializers.test.js
expect(out.createdAt).toBe("2021-03-02T04:30:00.000Z");   // ← salida copiada
```

Un string de fecha sin zona lo interpreta el motor de JavaScript **en la zona
local del proceso**. En una máquina en `America/Bogota` (UTC-5), esas 23:30 son
las 04:30 UTC del día siguiente; en el runner, configurado en UTC, son las 23:30
del mismo día. Dos entornos, dos instantes, dos ISO distintos — y el serializer
funciona perfectamente en los dos casos.

Por eso **no es un test inestable**: es determinista en cada sitio, y da resultados
distintos porque está midiendo dos relojes. Reproducirlo en tu máquina cuesta una
variable de entorno:

```bash
TZ=UTC npx jest test/lib/serializers.test.js
```

```
FAIL  test/lib/serializers.test.js
  ● serializeTicket (la frontera del contrato) › las fechas salen como ISO string

    Expected: "2021-03-02T04:30:00.000Z"
    Received: "2021-03-01T23:30:00.000Z"
```

**Parche mínimo.** El del viernes a las seis: que la fecha diga en qué zona está.

```js
// test/fixtures/index.js
// La zona va explícita: sin la Z, el instante depende de la máquina que corre.
createdAt: new Date("2021-03-01T23:30:00Z")
```

```js
// test/lib/serializers.test.js
expect(out.createdAt).toBe("2021-03-01T23:30:00.000Z");
```

**La refactorización correcta.** Son los dos arreglos que pedía el enunciado, y el
orden importa:

1. **Primero, fijar el reloj de la suite**, que es el arreglo del *sistema*: el
   `globalSetup` deja de depender de cómo esté configurada la máquina que corre
   los tests. Es la misma medicina que la fase aplicó al binario del motor —
   *lo que no está escrito en el repositorio, no existe*—, ahora aplicada al huso.

   ```js
   // test/globalSetup.js
   module.exports = async function () {
     process.env.TZ = "UTC";                 // la suite corre siempre en el mismo huso
     // …el memory-server con su binary.version fijado…
   };
   ```

2. **Después, quitar los literales dependientes de zona** de todas las fixtures,
   no solo de la que falló. Un `grep` los encuentra en un minuto:

   ```bash
   grep -rn 'new Date("' test/ | grep -v 'Z"'
   ```

Si haces solo el 1, el test se pone verde y las fixtures siguen mintiendo el día
que alguien corra la suite fuera del runner. Si haces solo el 2, arreglas este
test y el siguiente vuelve a nacer torcido. El 1 sin el 2 es tapar; el 2 sin el 1
es arreglar un caso.

**Prueba de regresión.** Dos, y la primera es la que impide la reincidencia:

```js
// test/lib/clock.test.js — el guardián, hermano del que fija la versión del motor
it("la suite corre en UTC", function () {
  expect(new Date().getTimezoneOffset()).toBe(0);
});
```

```js
// test/lib/serializers.test.js — el caso, ahora sin depender del reloj de nadie
test("una fecha con zona explícita se serializa igual en cualquier máquina", function () {
  const out = serializeTicket(makeTicket({ createdAt: new Date("2021-03-01T23:30:00Z") }));
  expect(out.createdAt).toBe("2021-03-01T23:30:00.000Z");
});
```

Y la comprobación que cierra el caso, porque reproduce el entorno del compañero
sin pedirle nada al runner:

```bash
TZ=America/Bogota npx jest && TZ=UTC npx jest      # verde las dos veces
```

**Prevención.** El `TZ` fijado en el `globalSetup` y el test guardián; el `grep`
de arriba como paso del checklist de revisión; y —esto es lo que se lleva uno al
sistema de verdad— **la zona del contenedor declarada en el compose de la
[Fase 14](14-operacion.md)**, por el mismo motivo. Un backend que calcula fechas
según cómo venga configurada la máquina anfitriona tiene el mismo bug, solo que
sin un test que lo delate.

**Por qué llegó a producción.** Por la práctica más natural del mundo: el assert
se escribió **copiando lo que salió**. Corres el test, ves el valor recibido, lo
pegas como esperado y queda verde. Es lo que hace todo el mundo cuando escribe el
test después del código, y funciona mientras el equipo entero comparta huso — que
es exactamente lo que pasaba. El pipeline fue el primer entorno del proyecto
configurado de otra forma, y por eso el síntoma llegó disfrazado de "problema de
CI": el pipeline no rompió nada, solo fue el primero en decir la verdad.

Nadie se equivocó al escribir el assert. El sistema permitía que un test dependiera
de configuración invisible, y el arreglo es que deje de permitirlo.

**Si tu causa fue distinta a ésta.** El síntoma "verde acá, rojo allá" tiene tres
sospechosos más, y los tres son plausibles:

- **La versión del binario sin fijar** — la causa que recorre la
  [pieza forense de la Fase 13](forense-fase-13.md). Se distingue por dos señas:
  falla **intermitentemente** (una de cada tres corridas, no siempre) y revienta
  en asserts de `$ne` o del upsert que colisiona, no en fechas.
- **Orden y paralelismo.** Si `npx jest --runInBand` pasa y en paralelo falla, no
  es el reloj: es aislamiento entre suites.
- **El presupuesto de tiempo.** El duelo de 20 rondas con dos núcleos y cuatro
  workers puede pasarse de los 5 s por defecto de Jest. Ahí el rojo dice
  `Exceeded timeout`, que es un mensaje honesto y conviene leerlo.

Si tu fix fue subir el timeout, marcar el test como flaky o forzar `--runInBand`
en el pipeline, tapaste el síntoma en una capa más arriba: los tres esconden el
rojo sin tocar la variable suelta.

> 📄 El recorrido completo de este síntoma, con las salidas literales y los
> callejones, en [`forense-fase-13.md`](forense-fase-13.md).

</details>

---

EOF
tail -3 02-complement-mongodb-backend/cuaderno-incidentes.md

# --- 2026-09-10T02:30:29 · Append retrospective and pending sections
cat >> 02-complement-mongodb-backend/cuaderno-incidentes.md <<'EOF'
## 🪞 Retrospectiva

Cuando cierres varios incidentes, vuelve acá y llénala. No es un formalismo: la
lista de causas raíz de un backend tiene forma, y verla es lo que convierte doce
casos sueltos en criterio.

| ID | Capa donde vivía | Pista que lo resolvió | Cuánto tardaste | Lo habrías visto antes si… |
|---|---|---|---|---|
| 01 | | | | |
| 02 | | | | |
| 03 | | | | |
| 04 | | | | |
| 05 | | | | |
| 06 | | | | |
| 07 | | | | |
| 08 | | | | |
| 09 | | | | |
| 10 | | | | |
| 11 | | | | |
| 12 | | | | |

Tres preguntas para cuando la tabla esté llena:

- **¿Cuántos resolviste sin abrir un archivo de la aplicación?** En este curso son
  más de la mitad: se resuelven en `mongosh`, en un `explain()` o leyendo un
  documento crudo. Ése es el número que justifica todo el track — el backend no se
  depura en el código, se depura en los datos.
- **¿Cuántos eran modelado disfrazado de rendimiento?** El síntoma llega siempre
  como "esto va lento" y la causa está en una decisión de forma que se tomó meses
  antes. Saber traducir uno en otro es la mitad de este curso.
- **¿Cuántos los habría evitado el contrato, si alguien lo hubiera leído antes de
  escribir el endpoint?** Los de la categoría Contrato, sí — pero mira también los
  otros: el contrato dice qué forma tiene un ticket, y varias causas raíz de acá
  son un documento que dejó de tener esa forma sin que nadie se enterara.

---

## 📌 Pendientes

Lo que salió de los incidentes y no se arregla en este curso, con el motivo.

- **La consistencia entre colecciones sigue siendo tuya** (incidentes 05 y 08). Sin
  claves foráneas, nada impide que un `assignee` apunte a un usuario que ya no
  está. El validator de la Fase 4 comprueba forma, no referencias; las
  transacciones de la Fase 6 protegen una operación, no el histórico. Es el precio
  del modelo, no un defecto de tu implementación, y así lo firma
  [el veredicto de la Fase 15](15-el-veredicto-honesto.md).
- **El `schemaVersion` sin migración de verdad** (incidente 08). El curso deja los
  documentos conviviendo en dos versiones y la aplicación tolerándolas. Es lo
  correcto para aprender, y es deuda para un sistema real: alguien tiene que
  decidir cuándo se termina la migración y quién apaga el código de compatibilidad.
- **La seguridad se paga a medias** (incidente 10 y toda la Fase 11). El curso pone
  bcrypt, JWT firmado y validación en la frontera, y `SECURITY-NOTES.md` cierra
  cuatro deudas. Lo que queda —rate limiting, autorización por recurso, cabeceras,
  uploads hostiles— vive en [`a04-seguridad.md`](a04-seguridad.md) como apéndice
  opcional, y opcional significa que si no lo haces, no está.
- **El anuncio en tiempo real sigue sin garantías de entrega** (incidente 11). El
  servidor emite después de escribir, que era la deuda que había que pagar; pero un
  cliente desconectado durante el emit se pierde el evento y solo se entera al
  recargar. La solución real es una cola o un `since` en el reconnect, y ninguna de
  las dos entra en un curso de Mongo.
- **El reloj y la zona horaria del proceso** (incidente 12). Se fija en la suite y
  se declara en el compose de la Fase 14, pero el sistema sigue calculando fechas
  con la zona del proceso. El día que un reporte tenga que agrupar "por día" para
  un negocio que no vive en UTC, eso es una decisión de producto y hay que tomarla
  a propósito.

> 🧭 Los cinco pendientes tienen algo en común, y conviene decirlo en voz alta:
> **ninguno es un bug.** Son los límites de hasta dónde llega este curso, cada uno
> con su nombre y su motivo. Un backend que sabe cuáles son sus límites es
> mantenible; uno que cree no tenerlos es el que produce los incidentes de este
> cuaderno.
EOF
wc -l 02-complement-mongodb-backend/cuaderno-incidentes.md; grep -c "^## Incidente" 02-complement-mongodb-backend/cuaderno-incidentes.md

# --- 2026-09-10T02:30:37 · Verify structure, tuteo and links
grep -nE '^## ' 02-complement-mongodb-backend/cuaderno-incidentes.md | tail -5; echo "=== voseo ==="; grep -nE '\b(tenés|podés|querés|sabés|mirá|fijate|hacés|vos|vosotros|ordenador|vale)\b' 02-complement-mongodb-backend/cuaderno-incidentes.md | tail -5; echo "=== enlaces ==="; for f in 01-mongo-en-30-min.md 14-operacion.md 15-el-veredicto-honesto.md a04-seguridad.md forense-fase-13.md; do [ -f 02-complement-mongodb-backend/$f ] && echo "ok $f" || echo "FALTA $f"; done

# --- 2026-09-10T02:30:58 · Update plan checklist after P6-bis
python3 - <<'PY'
import io
p='contenido_forense.md'
s=io.open(p,encoding='utf-8').read()
s=s.replace("| 6 · Los cuadernos | P6 / **P6-bis** | ⏳ | C01 completo · **C02: 11/12, sin 🪞 ni 📌** |",
            "| 6 · Los cuadernos | P6 · P6-bis | ✅ | C01 (2.272 líneas) y C02 (2.262) · 12 + 12 incidentes · 🪞 y 📌 en los dos |")
s=s.replace("""- ⏳ `02-complement-mongodb-backend/cuaderno-incidentes.md` — falta el **incidente 12**
  ("Verde en mi máquina, rojo en CI", F13, Testing, 🔴), la **🪞 retrospectiva** y los
  **📌 pendientes**. La fila 12 ya está reservada en ⬜ en el índice. → **P6-bis**
""","""- ✅ `02-complement-mongodb-backend/cuaderno-incidentes.md` — cerrado el 2026-09-09 con el
  **incidente 12** ("Verde en mi máquina, rojo en CI", F13, Testing, 🔴 · causa raíz propia:
  el huso horario grabado en la fixture y en el assert, distinta de la del binario que
  recorre la pieza), la **🪞 retrospectiva** y los **📌 pendientes** (cinco, con motivo).
""")
s=s.replace("""**Siguiente paso:** **P6-bis** — un archivo, tres bloques, cierra el cuaderno del Curso 02.
Después **P7-A**, **P7-B** y, al final de todo, **P8**.""",
"""**Siguiente paso:** **P7-A** — la costura del Curso 01. P6-bis quedó cerrado el 2026-09-09.
Después **P7-B** y, al final de todo, **P8**.""")
s=s.replace("**Lo ejecutado, a 2026-09-09:** pasos 0 a 5 completos y el 6 a medias.",
            "**Lo ejecutado, a 2026-09-09:** pasos 0 a 6 completos.")
s=s.replace("### P6-bis · La última tanda del Curso 02 ⬅️ **cerrado, listo para pegar**",
            "### P6-bis · La última tanda del Curso 02 ✅ **ejecutado — cuaderno del Curso 02 cerrado**")
s=s.replace("### P6 · Una tanda de incidentes ⏳ **ejecutado a medias — 23 de 24**",
            "### P6 · Una tanda de incidentes ✅ **ejecutado — 24 incidentes**")
s=s.replace("""> ⏳ **Estado.** Curso 01: los 12 incidentes escritos, más 🪞 retrospectiva y 📌 pendientes.
> Curso 02: **11 de 12**, sin retrospectiva y sin pendientes. El índice del Curso 02 ya
> reserva la fila 12 en ⬜. Lo que falta lo cierra **P6-bis**, aquí abajo.""",
"""> ✅ **Cerrado.** Los dos cuadernos con sus 12 incidentes, su 🪞 retrospectiva y sus
> 📌 pendientes. Los cuatro últimos entregables —incidente 12 del Curso 02, retrospectiva y
> pendientes— salieron de **P6-bis**, aquí abajo.""")
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY
grep -n "P7-A\|P6-bis" contenido_forense.md | head

# --- 2026-09-10T02:31:07 · Update prompt section state note
python3 - <<'PY'
import io
p='contenido_forense.md'
s=io.open(p,encoding='utf-8').read()
s=s.replace("""> 🚦 **Estado, a 2026-09-09.** P0 a P5 están **ejecutados** (sin commitear todavía) y se
> conservan aquí como registro de lo que se pidió, no como trabajo por hacer. P6 está a
> medias. Lo que queda vivo son **P6-bis, P7-A, P7-B y P8**, que ya vienen cerrados: traen
> dentro las listas exactas de archivos, el mapeo 📄 y las tablas de reservas, así que se
> pegan y se ejecutan sin volver a inventariar nada. El checklist de §12 dice dónde estás.""",
"""> 🚦 **Estado, a 2026-09-09.** P0 a P6 y P6-bis están **ejecutados** (sin commitear todavía)
> y se conservan aquí como registro de lo que se pidió, no como trabajo por hacer. Lo que
> queda vivo son **P7-A, P7-B y P8**, que ya vienen cerrados: traen dentro las listas
> exactas de archivos, el mapeo 📄 y las tablas de reservas, así que se pegan y se ejecutan
> sin volver a inventariar nada. El checklist de §12 dice dónde estás.""")
io.open(p,'w',encoding='utf-8').write(s)
PY
echo ok

# --- 2026-09-10T02:31:17 · Read phase template blocks
sed -n '95,130p' prompts/plantilla-de-fase.md; echo "=== bloque reservas ==="; sed -n '195,215p' prompts/plantilla-de-fase.md

# --- 2026-09-10T02:31:20 · Inspect phase 00 structure
grep -nE '^## ' 01-vue2-legacy/00-setup-hola-mundo.md; echo "=== errores comunes ==="; sed -n '/^## ⚠️ Errores comunes/,/^## /p' 01-vue2-legacy/00-setup-hola-mundo.md | head -40; echo "=== final ==="; tail -20 01-vue2-legacy/00-setup-hola-mundo.md

# --- 2026-09-10T02:31:28 · Read forensic pieces 00-03 headers and steps
for n in 00 01 02 03; do echo "########## $n"; sed -n '1,20p' 01-vue2-legacy/forense-fase-$n.md; echo "--- pasos ---"; grep -nE '^### Paso|^## ' 01-vue2-legacy/forense-fase-$n.md; done

# --- 2026-09-10T02:31:37 · Read undo sections of pieces
for n in 00 02 03; do echo "##### $n"; sed -n '/^## 🧨 Deshacer/,/^## 🧠/p' 01-vue2-legacy/forense-fase-$n.md; done

# --- 2026-09-10T02:32:00 · Read piece 01 route in detail
sed -n '28,110p' 01-vue2-legacy/forense-fase-01.md

# --- 2026-09-10T02:32:10 · Find chaos injector flags
grep -nE 'CHAOS=|CHAOS |chaos\.js' 01-vue2-legacy/03-mock-api-minima.md | head -20

# --- 2026-09-10T02:32:21 · Create stitching helper script
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad/coser.py <<'PY'
# -*- coding: utf-8 -*-
import io, sys, re

def coser(path, pieza, resumen, romper, reservas):
    s = io.open(path, encoding='utf-8').read()
    head = "## ⚠️ Errores comunes\n"
    if "## ⚠️ Errores comunes y pieza forense" in s:
        print("YA COSIDO:", path); return
    if head not in s:
        print("!! sin encabezado esperado:", path); return
    i = s.index(head)
    s = s[:i] + "## ⚠️ Errores comunes y pieza forense\n\n### Errores comunes\n" + s[i+len(head):]
    # insertar bloque antes del siguiente separador de seccion
    j = s.index("\n---\n\n## ", i)
    bloque = "\n### Pieza forense de esta fase\n\n" + resumen.strip() + \
             "\n\n**\U0001f9e8 Rompe a propósito**\n\n" + romper.strip() + \
             "\n\n> \U0001f4c4 El recorrido completo, con las salidas literales, en\n> [`%s`](%s).\n" % (pieza, pieza)
    s = s[:j] + "\n" + bloque + s[j:]
    if not s.endswith("\n"): s += "\n"
    s += "\n---\n\n### \U0001f4cc Reservas para el cuaderno de incidentes\n\n" + reservas.strip() + "\n"
    io.open(path, 'w', encoding='utf-8').write(s)
    print("ok:", path)
PY
echo listo

# --- 2026-09-10T02:32:56 · Stitch phases 00-03 of course 01
cd 01-vue2-legacy && python3 - <<'PY'
import sys, io
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser

RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("00-setup-hola-mundo.md", "forense-fase-00.md",
"""Lo que se rompe en esta fase casi nunca es tu código: es el entorno. Un
`Vue packages version mismatch`, un muro de `gyp ERR!` o un `EADDRINUSE` hablan
de versiones, de Node y de puertos, y ninguno de los tres se depura abriendo un
`.vue`. La señal está siempre en las **primeras líneas** de la salida de
`vue-cli-service` —no en las últimas, que es donde todo el mundo mira— y el
entorno entero se descarta en tres minutos con `node -v` y
`npm ls vue vue-template-compiler`. Si esas dos versiones no coinciden, ya
terminaste: no sigas leyendo el error.""",
"""Desalinea el compilador de plantillas a propósito y lee el error completo antes
de arreglarlo — es el que te vas a encontrar en la mitad de los proyectos Vue 2
ajenos:

```bash
npm install vue-template-compiler@2.6.10 --save-exact
npm run serve
```

Para volver: `npm install vue@2.6.14 vue-template-compiler@2.6.14 --save-exact`.""",
RES + '| 01 | "Clonaste el repo y no me arranca, a ti sí te funciona" | Build | 🟢 |')

coser("01-estructura-base-legacy.md", "forense-fase-01.md",
"""La investigación típica de esta fase no termina en un bug: termina en **una
decisión que nadie tomó**. Entras a `/tickets/999`, el router hace match, la
vista se monta y lo que se pinta es un hueco — sin error en consola, porque
nadie cometió ninguno. Se depura con Vue DevTools → **Components** junto a la
URL, en este orden: qué se montó, qué tiene adentro, y quién devolvió el hueco.
La señal que lo delata es un `data` con la propiedad en `undefined` y una
consola limpia: el servicio contestó bien —un `Array.find` que no encuentra
devuelve `undefined`, y eso es correcto— y la vista nunca preguntó si el ticket
no existe o todavía no llegó. Esa pregunta es de presentación, no de datos, y en
la Fase 3 se vuelve cara: el mismo `undefined` va a significar además "el
servidor no contestó".""",
"""Con la app corriendo, entra a mano a una URL con un `id` que no existe:

```
http://localhost:8080/tickets/999
```

Abre Vue DevTools → Components, selecciona la vista de detalle y mira su `data`.
Anota tres cosas: qué componente se montó, qué tipo tiene `$route.params.id`
(pista: no es un número) y cuántos errores hay en la consola. Las tres importan
más que el fix.""",
"""Esta fase no reserva incidentes. La estructura, el router y el layout se
prueban en cada fase posterior, así que sus fallos llegan al cuaderno
disfrazados de otra cosa: el arranque roto es de la Fase 0 y el hueco sin
mensaje se convierte en material de la Fase 3, cuando el mismo síntoma puede
tener tres causas distintas.""")

coser("02-autenticacion-minima.md", "forense-fase-02.md",
"""El fallo característico de esta fase es que **la aplicación toma una decisión
importante y no deja rastro**: te devuelve a `/login` sin mensaje, sin error en
consola y sin nada en Network. Esa ausencia de evidencia es la evidencia — si
nada se registró, el que te expulsó fue código tuyo que no consideró digno de
contarse lo que hizo. Se depura con DevTools → **Application → `localStorage`**
y Vue DevTools → **Vuex**, y la pregunta que ordena el recorrido es cuál de las
**dos copias del mismo dato** manda: la del storage o la del store. Cuando no
coinciden, el guard cree una cosa y la interfaz muestra otra. Y hay un límite
que esta fase no puede cruzar y conviene tener claro: el guard comprueba que el
token **esté**, no que **sirva** — sin un servidor que conteste 401, no hay
forma de saberlo desde acá.""",
"""Con la sesión abierta, borra el token a mano y navega **sin recargar**:

```js
> localStorage.removeItem("token")
```

Haz clic en otra vista protegida. ¿Te expulsa ahora, al recargar, o nunca?
La respuesta te dice cuál de las dos copias está mandando en cada momento.
Para volver: `localStorage.clear()` y entra de nuevo con `admin` / `1234`.""",
RES + '| 03 | "Me sacó al login a mitad de la mañana, sin decir nada" | Estado | 🟡 |')

coser("03-mock-api-minima.md", "forense-fase-03.md",
"""Ésta es la fase que más rinde del tronco, y no porque sus bugs sean difíciles:
es porque acá se aprende a leer **Network**, que sirve para todas las que
vienen. La lección central es incómoda: desde el código del cliente, *"el
servidor está apagado"*, *"el navegador me bloqueó la respuesta"* y *"el
servidor recibió el request y no contestó"* son **el mismo evento** — tu `catch`
no puede distinguirlos, y Network sí. El orden del recorrido es el barato
primero: ¿el request salió, volvió o se quedó a medias?, ¿el servidor está vivo
y solo no contesta esta ruta?, ¿contesta a `curl` y no al navegador? Y el caso
que más despista: el request volvió **en verde** y la pantalla igual está
vacía — ahí el problema ya no es de red, es de forma del dato.""",
"""El inyector de caos de este capítulo existe justo para esto. Levanta el mock
mintiendo y mira la lista de tickets:

```bash
CHAOS=timeout npm run mock      # el mock no contesta
CHAOS=malformed npm run mock    # el mock contesta cualquier cosa
```

Con cada uno, anota qué ve el usuario, qué dice la consola y qué dice Network.
Los tres son distintos, y ésa es la lección. Se apaga solo: `Ctrl+C` y
`npm run mock` sin variable.""",
RES + '| 02 | "A veces carga y a veces se queda pensando" | Integración (mock) | 🟢 |')
PY

# --- 2026-09-10T02:33:02 · Verify stitched phase 00
sed -n '/^## ⚠️ Errores comunes y pieza forense/,/^## 🧪/p' 00-setup-hola-mundo.md | head -60 && echo "=== cola ===" && tail -12 00-setup-hola-mundo.md

# --- 2026-09-10T02:33:12 · Fix blank line and update helper
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
python3 - <<'PY'
import io,glob
for f in glob.glob('01-vue2-legacy/*.md'):
    s=io.open(f,encoding='utf-8').read()
    if "\n\n\n### Pieza forense de esta fase" in s:
        io.open(f,'w',encoding='utf-8').write(s.replace("\n\n\n### Pieza forense de esta fase","\n\n### Pieza forense de esta fase"))
        print("fix",f)
PY
sed -i '' 's|s = s\[:j\] + "\\n" + bloque + s\[j:\]|s = s[:j] + bloque + s[j:]|' /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad/coser.py
grep -n "bloque + s" /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad/coser.py

# --- 2026-09-10T02:33:17 · Read pieces 04-07
cd 01-vue2-legacy; for n in 04 05 06 07; do echo "########## $n"; sed -n '1,16p' forense-fase-$n.md; grep -nE '^### Paso|^## 🧨' forense-fase-$n.md; sed -n '/^## 🧨 Deshacer/,/^## 🧠/p' forense-fase-$n.md | head -18; done

# --- 2026-09-10T02:33:23 · Check errores comunes headings across phases
grep -l "^## ⚠️ Errores comunes$" *.md | tr '\n' ' '; echo; echo "SIN:"; for f in 0*.md 1*.md q*.md vu*.md nx*.md; do grep -q "^## ⚠️ Errores comunes" $f || echo "  $f"; done

# --- 2026-09-10T02:34:03 · Stitch phases 04-07
python3 - <<'PY'
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser
RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("04-dashboard-tickets.md","forense-fase-04.md",
"""⭐ Una de las tres piezas estrella del curso, y la que más veces vas a
reencontrar en un legacy ajeno: **el control cambia, el estado cambia, y lo que
se pinta se quedó en la versión anterior.** El bug no es de Vue, es de
arquitectura de estado — alguien guardó un dato **derivado** como si fuera un
dato crudo, y desde entonces hay dos verdades que alguien tiene que sincronizar
a mano. La mano se olvida. Se depura con Vue DevTools → Components, y la
pregunta que parte el caso en dos es la del paso 2: **¿esto es un `computed` o
es un `data`?** Si es un `data`, ya sabes por qué se quedó atrás; si es un
`computed`, el problema está en lo que lee, no en él. Network aparece solo para
descartarla, y `git log -S` para averiguar cuándo dejó de ser derivado.""",
"""Convierte una lista derivada en una copia guardada y siente el bug en carne
propia. En `TicketsView.vue`, cambia el `computed` que filtra por un `data` que
se asigna una sola vez en `created()`:

```js
// antes: computed: { filteredTickets: function () { … } }
// ahora: data: function () { return { filteredTickets: [] }; }
//        created: function () { this.filteredTickets = this.filter(this.tickets); }
```

Cambia el filtro en la interfaz. La tabla se queda igual, y ahora sabes por qué.
Para volver: `git checkout -- src/views/TicketsView.vue`.""",
RES + '| 04 | "Pongo el filtro y la tabla se queda con lo de antes" | Estado | 🟡 |')

coser("05-crud-tickets.md","forense-fase-05.md",
"""El fallo típico de esta fase es **el silencio**: el clic en guardar no produce
ni request, ni error, ni mensaje. Y el silencio tiene causa concreta — el
formulario ya decidió que no envía, y esa decisión no se pinta en ninguna parte.
Vuelidate sabe perfectamente qué campo está mal; el usuario no, porque el bloque
que muestra los errores depende de una condición que nadie cumplió. El orden es
el de siempre, del más barato al más caro: ¿salió algún request? (Network),
¿llegó a ejecutarse el handler? (un `console.log` o un breakpoint), y solo
entonces ¿qué campo está mal y por qué no se pinta? La fase deja además dos
casos hermanos que conviene reconocer: el formulario que nace en rojo antes de
que el usuario escriba nada, y el ticket que se creó **dos veces** porque el
botón no se deshabilita mientras el request viaja.""",
"""Rompe el vínculo entre la validación y su mensaje: quita del `<template>` la
condición que muestra el error de un campo requerido —o cambia `$v.form.title.$error`
por `false`— y deja la validación intacta. Intenta guardar con el título vacío.

No pasa nada, y ese "nada" es exactamente lo que reporta el usuario. Mira en Vue
DevTools que `$v.form.$invalid` sí es `true`: el sistema lo sabía todo el tiempo.
Para volver: `git checkout -- src/views/TicketFormView.vue`.""",
RES + '| 05 | "Le puse la etiqueta y la tabla no se enteró" | Reactividad | 🟡 |')

coser("06-wizard-minimo.md","forense-fase-06.md",
"""Acá el sistema no pierde datos: **destruye componentes**, que es otra cosa y se
diagnostica distinto. Vuelves a un paso anterior del asistente y lo encuentras
vacío, aunque nadie borró nada. La investigación consiste en separar tres
estados que el usuario ve como uno solo —lo que está en el borrador, lo que está
en el formulario del paso, y lo que está en el estado de validación— y averiguar
cuál de los tres murió. Se depura con Vue DevTools → Components mirando el
**árbol** y los hooks del ciclo de vida: si el componente del paso vuelve a
aparecer con otra instancia, no volvió, **nació otra vez**. Lo que sobrevive es
lo que vive por encima de él; lo que se pierde es lo que vivía adentro.""",
"""Pon un `console.log` en `created()` y otro en `beforeDestroy()` del componente
de un paso, y navega adelante y atrás dos veces:

```js
created: function () { console.log("nace", this._uid); },
beforeDestroy: function () { console.log("muere", this._uid); }
```

Cuenta los `_uid` distintos. Si el mismo paso tiene tres identidades en dos
minutos, ya no estás depurando un bug de datos. Borra los `console.log` antes de
commitear.""",
RES + '| 06 | "Volví atrás en el asistente y perdí la descripción" | Formularios y wizard | 🟡 |')

coser("07-metricas-minimas.md","forense-fase-07.md",
"""La primera investigación del curso que **no tiene un momento de fallo**: no hay
un clic que rompa nada, ni una petición en rojo, ni excepción — hay una
aplicación que a los diez minutos va peor que a los dos. Los bugs de degradación
se diagnostican al revés que los demás: no se busca qué se rompió, se busca
**qué se acumula**. Las herramientas dejan de ser la consola y pasan a ser
**Performance y Memory** de Chrome, y la primera pregunta es si el síntoma es
acumulativo de verdad (navegar diez veces a la misma vista y comparar) antes de
sospechar de nadie. El sospechoso habitual de esta fase es un gráfico que se
crea en cada montaje y no se destruye al salir, más los `setInterval` y los
listeners que nadie dio de baja.""",
"""Comenta el `beforeDestroy()` donde el gráfico se destruye, navega diez veces
entre el dashboard y las métricas, y mira el heap en DevTools → Memory:

```js
// beforeDestroy: function () { this.chart.destroy(); }
```

Toma un snapshot al empezar y otro al terminar. La diferencia es el número que
convierte "va lento" en un reporte que alguien puede priorizar. Para volver:
`git checkout -- src/components/metrics/` y recarga con `Ctrl+Shift+R` — los
gráficos zombi viven en la memoria del navegador, no en tu código.""",
RES + '| 07 | "A la media hora la laptop suena como un avión" | Reactividad | 🟠 |')
PY

# --- 2026-09-10T02:34:09 · Read pieces 08-11
for n in 08 09 10 11; do echo "########## $n"; sed -n '1,16p' forense-fase-$n.md; grep -nE '^### Paso|^## 🧨' forense-fase-$n.md; sed -n '/^## 🧨 Deshacer/,/^## 🧠/p' forense-fase-$n.md | head -16; done

# --- 2026-09-10T02:34:48 · Stitch phases 08-11
python3 - <<'PY'
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser
RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("08-websockets-minimos.md","forense-fase-08.md",
"""⭐ La pieza estrella del curso, y no por dificultad técnica: es la única cuyo
recorrido termina **encontrando una deuda 💸 que este material te declaró cien
líneas antes** y que probablemente leíste sin entender del todo. Una pantalla se
enteró y la otra no, y las dos creen tener la verdad. Se depura con Network →
**WS** y dos navegadores abiertos, y el orden importa: primero si el evento se
propagó o simplemente no se pintó, después qué pasó por el socket, y solo
entonces **quién emite y qué emite**. Ahí llega la pregunta incómoda —*¿y quién
**debería** emitirlo?*— cuya respuesta no es un fix de esta fase: el cliente
está anunciando un hecho que él mismo decidió, y el servidor es un simple relé
que repite lo que le digan. Se paga cuando exista un backend que confirme la
escritura antes de anunciarla.""",
"""Miente por el socket, desde la consola de un navegador, sin tocar el `db.json`:

```js
> socket.emit("ticket:updated", { id: 1, status: "closed", assignee: "quien-sea" })
```

Mira la otra pestaña: se lo cree. Nadie escribió nada, y la interfaz ya cambió.
Recarga y desaparece — porque nunca existió. Ese experimento de veinte segundos
es toda la lección de la fase.""",
RES + '| 08 | "Se me duplican los tickets cuando entra uno nuevo" | Tiempo real | 🟠 |')

coser("09-panel-soporte.md","forense-fase-09.md",
"""Esta fase pone **dos vistas del mismo dato en la misma pantalla** —la cola y el
workspace— y ahí es donde los bugs de identidad dejan de ser teóricos. El PATCH
salió bien, la lista se actualizó, y el panel de al lado sigue mostrando lo de
antes. Todos los casos de la pieza son variantes de una sola pregunta: **¿los
dos paneles miran el mismo objeto, o cada uno tiene el suyo?** Se depura con Vue
DevTools → Components comparando lo que tiene cada panel, y la distinción que
resuelve el caso es la del paso 3: copia o referencia. Un `Object.assign` bien
intencionado en el sitio equivocado convierte una referencia compartida en dos
objetos que ya no se hablan. El paso 5 añade el hermano silencioso: la
propiedad que se agregó después y a la que Vue 2 nunca se suscribió.""",
"""Toma un ticket desde la cola con el workspace abierto en ese mismo ticket, y
compara los dos objetos en Vue DevTools antes y después:

```js
> $vm0.ticket === $vm1.ticket     // ¿el mismo objeto, o dos?
```

Después hazlo al revés: cambia el estado desde el workspace y mira la cola.
Si una de las dos direcciones funciona y la otra no, ya sabes de qué lado está
la copia. Si probaste tomando tickets, `npm run mock:reset` deja el mock limpio.""",
RES + '| 09 | "Tomé el ticket y a mi compañera le sigue apareciendo libre" | Estado | 🟠 |')

coser("10-vuex-a-fondo.md","forense-fase-10.md",
"""⭐ La tercera pieza estrella, y la que mejor resume por qué existe Vuex. Un dato
compartido cambia solo y el registro de mutations no tiene ninguna entrada que
lo explique: **el hueco en el registro es el bug.** La ceremonia del store
—mutations con nombre, actions que orquestan, plugins— no es burocracia: es lo
que convierte "el estado cambió" en *"la mutation `SET_TICKETS` lo cambió a las
10:42:07 con este payload"*. Se depura en Vue DevTools → pestaña **Vuex**, con
el registro y el time travel, y el recorrido va de si el testigo está encendido
(`strict`) a quién escribe fuera de una mutation, pasando por el módulo
equivocado. El paso 5 cubre el caso simétrico y más molesto: la mutation ocurrió,
el estado es correcto, y la vista nunca se enteró.""",
"""Escribe en el estado por la puerta de atrás, desde la consola, con el store en
modo `strict`:

```js
> this.$store.state.tickets.items.push({ id: 999, title: "fantasma" })
```

Mira dos cosas a la vez: el aviso que Vue lanza en consola, y el registro de
mutations, que sigue vacío. Después apaga `strict` y repítelo: el aviso
desaparece y el bug se queda. Para volver: `git checkout -- src/store/` y
recarga la aplicación.""",
RES + '| 10 | "El contador del menú dice una cosa y la tabla otra" | Estado (Vuex) | 🟠 |\n| 12 | "En el servidor de pruebas se comporta distinto que en mi máquina" | Build | 🔴 |')

coser("11-testing-minimo.md","forense-fase-11.md",
"""Un test que depende del orden no es un test: es un dado. Y hay un caso peor que
el de hoy —el test que **nunca** falla—, porque ése ni siquiera avisa. Las dos
patologías tienen la misma raíz: **estado que sobrevive de un test a otro**, o
promesas que nadie esperó. Se depura con la propia salida de Jest antes que con
el código: `-t` para correr uno solo, `--runInBand` para quitar el paralelismo,
y la comparación entre las dos corridas es la que dice si el orden importa.
Ojo con la conclusión cómoda: si `--runInBand` lo pone verde, eso **no** es el
arreglo — es el diagnóstico. El arreglo es que cada test monte lo suyo y lo
desmonte, y el mejor test de tu suite es el que rompes a propósito para
comprobar que sabe fallar.""",
"""Comprueba que tus tests saben fallar. Rompe la lógica que uno de ellos dice
proteger —invierte una condición en una mutation del store— y corre la suite:

```bash
npx vue-cli-service test:unit
```

Si sigue en verde, ese test no estaba probando lo que creías. Para volver:
`git checkout -- src/store/modules/tickets.js`. El experimento es material de
commit: el par `ej/f11/3-roto` / `ej/f11/3-fix` existe para eso.""",
RES + '| 11 | "El test pasa solo cuando lo corro aislado" | Testing | 🔴 |')
PY

# --- 2026-09-10T02:34:56 · Read Quasar route piece
sed -n '1,60p' forense-ruta-q.md; echo "=== headers ==="; grep -nE '^#{2,3} ' forense-ruta-q.md

# --- 2026-09-10T02:35:01 · Read Vuetify and Nuxt route pieces
for f in forense-ruta-vu.md forense-ruta-nx.md; do echo "#### $f"; sed -n '1,32p' $f; grep -nE '^### Paso' $f; done

# --- 2026-09-10T02:35:09 · Check errores comunes headings in route phases
grep -n "Errores comunes" q*.md vu*.md nx*.md

# --- 2026-09-10T02:35:12 · Inspect headings of q1, q3, nx1
for f in q1-leer-quasar.md q3-migrar-dashboard-qtable.md nx1-leer-nuxt.md; do echo "### $f"; grep -nE '^## ' $f | tail -8; done

# --- 2026-09-10T02:35:28 · Extend helper for variant headings
cat >> /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad/coser.py <<'PY'

def coser2(path, pieza, resumen, romper, old_head, new_head, sub_head, reservas=None):
    s = io.open(path, encoding='utf-8').read()
    if new_head in s:
        print("YA COSIDO:", path); return
    if old_head + "\n" not in s:
        print("!! sin encabezado:", path); return
    i = s.index(old_head + "\n")
    s = s[:i] + new_head + "\n\n" + sub_head + "\n" + s[i+len(old_head)+1:]
    j = s.index("\n---\n\n## ", i)
    bloque = "\n### Pieza forense de esta fase\n\n" + resumen.strip() + \
             "\n\n**\U0001f9e8 Rompe a propósito**\n\n" + romper.strip() + \
             "\n\n> \U0001f4c4 El recorrido completo, con las salidas literales, en\n> [`%s`](%s).\n" % (pieza, pieza)
    s = s[:j] + bloque + s[j:]
    if not s.endswith("\n"): s += "\n"
    if reservas:
        s += "\n---\n\n### \U0001f4cc Reservas para el cuaderno de incidentes\n\n" + reservas.strip() + "\n"
    io.open(path, 'w', encoding='utf-8').write(s)
    print("ok:", path)
PY
echo ok

# --- 2026-09-10T02:36:05 · Stitch Quasar route phases
python3 - <<'PY'
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser2
Q="forense-ruta-q.md"

coser2("q0-red-de-seguridad.md", Q,
"""Antes de migrar nada, la pieza de ruta se lee entera **una vez** — no para
resolver un bug de hoy, sino para saber qué forma tienen los bugs que vas a
provocar mañana. El eje de toda la ruta 🅠 es que **en Quasar casi nada grita**:
la mitad de los fallos no producen error, y la otra mitad produce uno que habla
de Vuex cuando el problema es de la tabla. La red de seguridad que montas en
esta fase existe justo por eso — con un framework silencioso, el test es el
único que avisa. Y hay una comprobación de esta fase que la pieza asume hecha:
que tus tests fallan cuando tienen que fallar.""",
"""Rompe a propósito una de las vistas que acabas de cubrir —quita el filtro,
invierte una condición— y corre la red de seguridad:

```bash
npx vue-cli-service test:unit
```

Si sigue verde, tu red tiene un agujero **hoy**, que es infinitamente más barato
que descubrirlo a mitad de la migración. Deshaz con `git checkout -- src/`.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("q1-leer-quasar.md", Q,
"""El síntoma característico de leer Quasar por primera vez es *"copié el template
y no se ve nada, y no sale ningún error"*. La causa está a diez segundos de
distancia y no está en tu código: un componente de Quasar 1 que **no está
declarado en `framework.components` de `quasar.conf.js` no renderiza y no
avisa** —y si tenía `<slot>`, se lleva por delante el contenido de adentro—. Eso
explica también el clásico "en la máquina de Ana funciona": copiaste el
template, no la configuración. Es el paso 1 de la pieza de ruta y conviene
tenerlo de reflejo antes de escribir una línea.""",
"""Quita un componente de la lista de `framework.components` en `quasar.conf.js`
—uno que estés usando, por ejemplo `QChip`— y recarga:

```bash
grep -n "components:" -A 12 quasar.conf.js
```

Mira la pantalla y mira la consola. Anota cuánto tarda en aparecer un mensaje
que te sirva de algo. Vuelve a ponerlo y recarga: en `quasar.conf.js` los
cambios exigen reiniciar el servidor de desarrollo.""",
"## ⚠️ 6. Errores clásicos","## ⚠️ 6. Errores clásicos y pieza forense","### Errores clásicos")

coser2("q2-migrar-crud-qform.md", Q,
"""El fallo propio de esta fase es un formulario que **guarda aunque dejes campos
vacíos**, cuando antes no dejaba. Es el paso 2 de la pieza de ruta: los métodos
del framework no devuelven lo que tu instinto espera. La validación de `QForm`
es asíncrona —`validate()` devuelve una **Promise**, y una Promise siempre es
"verdadera" en un `if`— así que la migración silencia la validación sin cambiar
una sola regla. El mismo cuidado vale para el valor que el componente guarda:
un `QSelect` con opciones de objeto no guarda el string que ves.""",
"""Escribe la trampa a propósito y míralas fallar a las dos:

```js
if (this.$refs.form.validate()) { this.save(); }   // ← siempre entra
```

Guarda con el título vacío: pasa. Ahora corrígelo con `await` o `.then()` y
repítelo. Dos líneas, dos comportamientos, cero errores en consola — que es
exactamente el modo en que esta ruta rompe las cosas.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("q3-migrar-dashboard-qtable.md", Q,
"""Aquí aparece el conflicto central de toda la ruta, y por eso la Fase 10 del
tronco no era opcional: **`QTable` quiere ser dueña del estado que tu store ya
controla.** El síntoma llega disfrazado —"dice 1-10 de 10 y hay 87 tickets", "al
pasar a la página 2 me muestra la 1"— y la causa es que la tabla está paginando
y ordenando por su cuenta un conjunto que tu store ya paginó. Es el paso 3 de la
pieza: la pregunta no es *"¿por qué falla la tabla?"* sino **"¿quién manda,
ella o mi store?"**, y las dos respuestas son válidas mientras elijas una.""",
"""Deja que manden los dos a la vez, que es el estado natural de una migración a
medias: conserva tu paginación en el store y no declares `:pagination.sync` ni
`server-side` en la tabla.

Navega a la página 2 y compara tres números: los que muestra la tabla, los que
tiene el store en Vue DevTools → Vuex, y los que pidió Network. Cuando los tres
no coinciden, el bug no está en ninguno de los tres: está en que hay tres.""",
"## 🐛 6. Errores clásicos","## 🐛 6. Errores clásicos y pieza forense","### Errores clásicos")

coser2("q4-timeline-actividad.md", Q,
"""La fase donde se juntan los dos fallos de la ruta: el componente que no está
declarado —`QTimeline` y sus hijos son los grandes olvidados de
`framework.components`— y el dato que llega con otra forma. Vale la pena releer
el 🩺 índice de síntomas de la pieza de ruta con la vista terminada delante: a
estas alturas ya reconoces los cuatro modos en que Quasar falla sin decir nada, y
ése es el verdadero entregable de la ruta.""",
"""Comprueba el silencio una última vez, ahora que ya lo esperas: quita
`QTimelineEntry` de `framework.components` y deja `QTimeline`.

La línea de tiempo se pinta **vacía**, con su marco y sin sus entradas. Ningún
error. Si esta vez lo diagnosticaste en menos de un minuto, la ruta cumplió.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")
PY

# --- 2026-09-10T02:36:44 · Stitch Vuetify route phases
python3 - <<'PY'
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser2
V="forense-ruta-vu.md"

coser2("vu0-red-de-seguridad.md", V,
"""La pieza de ruta se lee entera **una vez**, antes de migrar nada, para saber qué
forma tienen los fallos que vienen. El eje de la ruta 🅥 es que **Vuetify falla
sutilmente**: no desaparecen componentes enteros como en Quasar, se descoloca una
línea, un color no cambia con el tema, un diálogo no abre — y la consola, limpia.
Por eso la red de seguridad de esta fase es lo que te va a decir que rompiste
algo: con fallos que no gritan, el test es el único testigo. Y hay un
comprobante que la pieza da por hecho: que tus tests saben fallar.""",
"""Rompe a propósito una de las vistas que acabas de cubrir y corre la red:

```bash
npx vue-cli-service test:unit
```

Si sigue verde, el agujero está en tu red y hoy es barato taparlo. Deshaz con
`git checkout -- src/`.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("vu1-leer-vuetify.md", V,
"""Dos trampas concentran la mitad de los casos de esta ruta y las dos aparecen al
leer Vuetify por primera vez. La primera es estructural: **sin `<v-app>` en la
raíz, muchos componentes se pintan pero no funcionan** —los diálogos no abren,
los overlays no se posicionan— y no hay error que lo diga. La segunda es de
documentación: buscar "vuetify data table" en Google devuelve **Vuetify 3**, y
las props cambiaron de nombre; media hora peleando con un ejemplo que nunca fue
para tu versión. Las dos son el paso 1 y el paso 2 de la pieza de ruta.""",
"""Quita `<v-app>` de la raíz de la aplicación y recarga.

Mira lo que sigue funcionando —la mayoría de la pantalla, y ése es el problema—
y después abre un diálogo. Ni error, ni aviso, ni pista. Deshaz con
`git checkout -- src/App.vue` y anota el síntoma: lo vas a reconocer en un
proyecto ajeno dentro de dos años.""",
"## ⚠️ 6. Errores comunes","## ⚠️ 6. Errores comunes y pieza forense","### Errores comunes")

coser2("vu2-migrar-crud-vuetify.md", V,
"""El fallo propio de esta fase es el paso 3 de la pieza: **el valor que guarda el
componente no es el que ves.** Un `v-select` con `items` de objeto guarda el
objeto entero salvo que le digas lo contrario con `item-value`, así que la
prioridad de un ticket deja de ser `"high"` y pasa a ser `{ text: "Alta", value:
"high" }`. La migración no da error: guarda, y el `db.json` queda con un
documento de otra forma. El síntoma aparece **más tarde y en otra pantalla** —el
badge del dashboard en blanco para ese ticket—, que es lo que convierte un
cambio trivial en un caso de una hora.""",
"""Guarda un ticket con el `v-select` migrado y ve a mirar el dato crudo, que es
donde vive la verdad:

```bash
grep -n '"priority"' db.json | head
```

Compara con un ticket de la semilla. Si uno tiene un string y el otro un objeto,
ya sabes qué pantalla va a romperse después. Restaura con `npm run mock:reset`.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("vu3-migrar-dashboard-vdatatable.md", V,
"""Aquí llega el conflicto central de las tres rutas, y por eso la Fase 10 del
tronco no era opcional: **`v-data-table` quiere ser dueña del estado que tu store
ya controla.** El síntoma típico es que la tabla no ordena al hacer clic en la
cabecera y no pasa nada — ni error, ni movimiento. La causa suele ser que la
tabla está en modo servidor (`server-items-length`) esperando que **tú** ordenes,
mientras tu store espera que ordene ella. Es el paso 4 de la pieza, y la pregunta
que lo resuelve no es *"¿por qué no ordena?"* sino **"¿quién manda?"**.""",
"""Pon a los dos a mandar a la vez —conserva el orden en el store y deja también
que la tabla ordene— y haz clic en una cabecera.

Compara tres cosas: el orden que muestra la tabla, el que tiene el store en Vue
DevTools → Vuex, y el que pidió Network. Con tres verdades, cualquier arreglo
local solo mueve el síntoma de sitio.""",
"## ⚠️ 6. Errores comunes","## ⚠️ 6. Errores comunes y pieza forense","### Errores comunes")

coser2("vu4-timeline-vuetify.md", V,
"""La fase de cierre junta los dos hilos de la ruta: el **tema como estado global**
—en Vuetify los colores no son CSS, viven en `plugins/vuetify.js`, y un hex
escrito a mano en un `style` es exactamente lo que rompe el modo oscuro— y la
forma del dato que llega a la línea de tiempo. Con la vista terminada delante,
vale la pena releer el 🩺 índice de síntomas de la pieza de ruta: a estas alturas
ya reconoces las cuatro maneras en que Vuetify falla sin decir nada, y ése es el
entregable real de la ruta.""",
"""Escribe un color a mano donde debería ir un color del tema:

```html
<v-timeline-item color="#1976D2">   <!-- en vez de color="primary" -->
```

Cambia el tema a oscuro. El resto de la interfaz responde y ese punto no. Nadie
avisa, y el bug aparecerá el día que alguien cambie la paleta.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")
PY

# --- 2026-09-10T02:37:25 · Stitch Nuxt route phases
python3 - <<'PY'
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser2
N="forense-ruta-nx.md"

coser2("nx0-red-de-seguridad.md", N,
"""La pieza de ruta se lee entera **una vez** antes de migrar nada. El eje de la
ruta 🅝 no lo tiene ninguna otra: **tu código corre en dos sitios con capacidades
distintas**, y casi todos los fallos son un trozo de código ejecutándose donde no
debería. Eso cambia hasta dónde se mira primero — en Nuxt, la **terminal del
servidor** va antes que la consola del navegador, porque la mitad de los errores
ni siquiera llegan al navegador. La red de seguridad de esta fase es lo que te
permitirá distinguir "lo rompí yo" de "esto ya se comportaba así en el
servidor".""",
"""Rompe a propósito una vista cubierta y corre la red:

```bash
npx vue-cli-service test:unit
```

Y una comprobación propia de esta ruta: prueba cada pantalla **recargando con
F5**, no solo navegando desde el menú. Son dos caminos distintos —uno pinta en
el servidor y el otro no— y tu red debería cubrir los dos. Deshaz con
`git checkout -- src/`.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("nx1-leer-nuxt.md", N,
"""Leer Nuxt por primera vez tiene un síntoma clásico: *"si entro desde el menú
funciona, pero si recargo con F5 se cae"*. La causa es la que este capítulo
explica y la pieza de ruta convierte en reflejo: **el ciclo de vida se ejecuta
dos veces**, y `created()` corre también en el servidor, donde no hay `window` ni
`localStorage`. La primera pregunta de cualquier investigación en esta ruta es
por tanto *"¿dónde se ejecutó el código que falló?"*, y la respuesta está en la
terminal del servidor Nuxt, no en la consola del navegador.""",
"""Pon una línea que solo puede vivir en el navegador dentro de `created()` de
cualquier página:

```js
created: function () { console.log(window.innerWidth); }
```

Navega a esa página **desde el menú**: funciona. Ahora recarga con **F5**: se
cae, y el error sale en la terminal, no en la consola. Mueve la misma línea a
`mounted()` y repite las dos pruebas. Ésa es toda la ruta en un experimento.""",
"## ⚠️ Errores y confusiones típicas al leer Nuxt por primera vez",
"## ⚠️ Errores, confusiones típicas y pieza forense",
"### Errores y confusiones típicas al leer Nuxt por primera vez")

coser2("nx2-hidratacion-window-not-defined.md", N,
"""Esta fase cubre los dos primeros pasos de la pieza de ruta, que son el corazón
del track: **dónde se ejecutó el código que falló**, y **si el servidor y el
cliente pintaron lo mismo**. El primer síntoma —`window is not defined`— es
honesto y se arregla rápido. El segundo es el traicionero: *"aparece un parpadeo
raro y después la lista sale vacía, pero en el código fuente de la página sí
están los tickets"*. Eso es una **falta de coincidencia de hidratación**: el
servidor pintó una cosa, el cliente pintó otra, y Vue tiró lo primero. Se
diagnostica con "Ver código fuente de la página" —no con el inspector, que
muestra el DOM ya hidratado— y la causa casi siempre es un `Date.now()`, un
`Math.random()` o un dato que solo existe en un lado.""",
"""Provoca la falta de coincidencia a propósito: pinta algo que no puede coincidir
entre las dos ejecuciones.

```html
<p>Generado: {{ new Date().toLocaleTimeString() }}</p>
```

Recarga con F5 y mira dos sitios en este orden: el aviso de hidratación en la
consola, y "Ver código fuente de la página" comparado con lo que ves. Son dos
HTML distintos, y uno de los dos perdió.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("nx3-asyncdata-vs-vuex.md", N,
"""Aquí está el conflicto central de las tres rutas en su forma más pura, y por eso
la Fase 10 del tronco no era opcional: **`asyncData` quiere ser dueño de datos
que tu store ya controla.** Es el paso 3 de la pieza —*"¿de quién son los datos,
de la página o del store?"*— y en Nuxt duele más que en Quasar o Vuetify, porque
`asyncData` se ejecuta **antes de que el componente exista** y no tiene `this`:
lo que devuelve se fusiona con el `data` de la página y no pasa por ninguna
mutation. Resultado: dos copias del mismo dato, una de ellas invisible para el
registro de Vuex, que era justamente el testigo en el que aprendiste a
confiar.""",
"""Haz que las dos fuentes se contradigan y mira cuál gana:

```js
asyncData: function ({ $axios }) { return { tickets: [] }; }   // vacío a propósito
```

…con el store lleno. Recarga con F5 y navega después desde el menú: los dos
caminos dan resultados distintos, y el registro de mutations no menciona ninguno
de los dos. Deshaz y decide, con la pieza delante, cuál de las dos fuentes manda
en tu aplicación.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")

coser2("nx4-pagina-ssr-nueva.md", N,
"""La fase de cierre añade el cuarto paso de la pieza, el que solo aparece cuando
la aplicación sale de tu máquina: **¿esto depende de dónde esté corriendo el
proceso?** *"El login no funciona en el servidor de pruebas y en local va bien"*
es el ticket, y la causa vive en la frontera —variables de entorno que existen en
un lado y no en el otro, una URL de API relativa que el servidor no sabe
resolver, cookies contra `localStorage`—. Con la página nueva terminada, vale la
pena releer el 🩺 índice de síntomas de la pieza: ya reconoces los cuatro modos
de fallo de la ruta, y ése es el entregable real.""",
"""Comprueba la frontera con el experimento más barato que existe: apaga una
variable de entorno que tu página use y arranca en modo producción.

```bash
npm run build && npm run start
```

Compara el fallo con el que produce el mismo cambio en `npm run dev`. Si no se
parecen, ya sabes por qué "en local va bien" nunca fue un diagnóstico.""",
"## ⚠️ Errores comunes","## ⚠️ Errores comunes y pieza forense","### Errores comunes")
PY

# --- 2026-09-10T02:37:32 · Verify stitching coverage
echo "cosidas: $(grep -l 'Pieza forense de esta fase' *.md | wc -l)"; echo "con reservas: $(grep -l 'Reservas para el cuaderno de incidentes' *.md | wc -l)"; grep -l 'Reservas para el cuaderno' *.md | tr '\n' ' '; echo; echo "apéndices tocados:"; grep -l 'Pieza forense\|Reservas para' a[1-5]-*.md 2>/dev/null || echo "  ninguno ✅"

# --- 2026-09-10T02:37:39 · Inspect course README structures
grep -nE '^#{2,3} ' README.md; echo "=== modelo angular-16 ==="; grep -nE 'Track forense|Cuaderno de incidentes' ../../angular-16-legacy-for-backend-devs/README.md

# --- 2026-09-10T02:37:44 · Read model README blocks and target sections
sed -n '55,115p' ../../angular-16-legacy-for-backend-devs/README.md; echo "=== C01 README docs maestros + numeros ==="; sed -n '24,40p' README.md; sed -n '206,230p' README.md

# --- 2026-09-10T02:38:12 · Add forensic blocks to course 01 README
python3 - <<'PY'
import io
p='README.md'
s=io.open(p,encoding='utf-8').read()
bloque = """## 🕵️ Track forense

Quince recorridos de investigación —doce de tronco y uno por ruta—, con el
ticket literal, la salida de cada paso y qué descarta. **No se leen de corrido:
se entra por el síntoma.**

La puerta es [`forense-master.md`](forense-master.md), que trae el método de
cuatro preguntas y —lo que de verdad se consulta— **el índice de síntomas
transversal**: nadie llega sabiendo de qué fase es su problema, llega con *"la
pantalla se quedó igual"*.

| | Síntoma que cubre |
|---|---|
| [`forense-fase-00.md`](forense-fase-00.md) | "Instalé todo y no arranca", con errores que no hablan de lo que pasa |
| [`forense-fase-01.md`](forense-fase-01.md) | "Entré a un ticket que no existe y la pantalla no dice nada" |
| [`forense-fase-02.md`](forense-fase-02.md) | "Me saca al login sin decir nada" |
| [`forense-fase-03.md`](forense-fase-03.md) | "A veces carga y a veces se queda pensando" |
| [`forense-fase-04.md`](forense-fase-04.md) | "Cambié el filtro y la tabla se quedó igual" ⭐ |
| [`forense-fase-05.md`](forense-fase-05.md) | "Le di a guardar y no pasó nada" |
| [`forense-fase-06.md`](forense-fase-06.md) | "Volví atrás en el wizard y perdí lo que había escrito" |
| [`forense-fase-07.md`](forense-fase-07.md) | "La pestaña se va poniendo lenta y el ventilador se dispara" |
| [`forense-fase-08.md`](forense-fase-08.md) | "Tomé el ticket y a mi compañero le sigue apareciendo libre" ⭐ |
| [`forense-fase-09.md`](forense-fase-09.md) | "Cambié el estado y el detalle no se enteró" |
| [`forense-fase-10.md`](forense-fase-10.md) | "El estado cambió y nadie sabe quién lo cambió" ⭐ |
| [`forense-fase-11.md`](forense-fase-11.md) | "El test pasa solo cuando lo corro aislado" |
| [`forense-ruta-q.md`](forense-ruta-q.md) 🅠 | El componente que no renderiza y no avisa · la tabla que pagina dos veces |
| [`forense-ruta-vu.md`](forense-ruta-vu.md) 🅥 | El `v-app` ausente que rompe en silencio · el hex que mata el tema |
| [`forense-ruta-nx.md`](forense-ruta-nx.md) 🅝 | `window is not defined` · la hidratación que no cuadra |

Las tres piezas de ruta cubren las cinco fases de su ruta en un solo archivo, y
se leen solas: como las rutas son excluyentes, solo vas a abrir una.

Cada fase enlaza a la suya desde su sección **⚠️ Errores comunes y pieza
forense**, donde además hay un bloque 🧨 **Rompe a propósito** para provocar el
fallo en tu propia máquina. La especificación del formato vive en
[`../prompts/formato-piezas-forenses.md`](../prompts/formato-piezas-forenses.md).

---

## 📓 Cuaderno de incidentes

[`cuaderno-incidentes.md`](cuaderno-incidentes.md) — **12 incidentes** repartidos
por todo el curso, con su propia dificultad 🟢🟡🟠🔴. Cada uno trae el ticket
**como llegó** —vago, en palabras del usuario y sin lenguaje técnico—, la
preparación para tener el sistema roto en tu máquina, tres pistas plegadas, un
espacio en blanco para tu investigación, y la solución de referencia con causa
raíz, parche mínimo, refactorización correcta, **prueba de regresión en código**,
prevención y post-mortem.

Se puede empezar por cualquiera cuya fase ya hayas hecho: cada fase reserva sus
IDs en un bloque 📌 al final, y el índice del cuaderno los lista todos. Hay tres
formas de preparación y cada incidente usa **la más barata que sirva** —un flag
del inyector de caos, un `db.json` alterno o una rama de git—, porque una
preparación complicada es una excusa para saltarse el incidente.

Y una regla que es la mitad del ejercicio: **la solución viene incluida, y
abrirla antes de escribir la tuya no te ahorra tiempo — te ahorra el ejercicio.**

---

"""
anchor = "## 🗺️ El mapa de un vistazo"
i=s.index(anchor); s = s[:i] + bloque + s[i:]

s = s.replace("""- **12 fases de tronco** + **5 apéndices** + **15 fases de ruta** (3 × 5)""",
"""- **12 fases de tronco** + **5 apéndices** + **15 fases de ruta** (3 × 5)
- **15 piezas forenses** (12 de tronco + 3 de ruta) y **12 incidentes** en el
  cuaderno""")

s = s.replace("""| Ruta NX (nx0–nx4) | ✅ terminada |""",
"""| Ruta NX (nx0–nx4) | ✅ terminada |
| Track forense (`forense-*.md`) | ✅ terminado |
| `cuaderno-incidentes.md` | ✅ terminado |""")
io.open(p,'w',encoding='utf-8').write(s)
print("ok")
PY
grep -n "Track forense\|Cuaderno de incidentes\|piezas forenses" README.md | head

# --- 2026-09-10T02:38:21 · Check error headings in course 02 phases
cd ../02-complement-mongodb-backend && grep -n "Errores comunes\|Errores clásicos" [0-9]*.md | grep -v audit

# --- 2026-09-10T02:38:26 · Read section 6 of phase 13
sed -n '345,400p' 13-testing-de-api.md

# --- 2026-09-10T02:38:36 · Read inline forensic blocks in phases 02, 09, 10
for n in 02 09 10; do f=$(ls ${n}-*.md); echo "##### $f"; sed -n "/### 🩻 Pieza forense/,/^---/p" $f | head -30; done

# --- 2026-09-10T02:38:47 · Read section 6 of phase 02
sed -n '346,420p' 02-consultar-tu-sql-traducido.md

# --- 2026-09-10T02:38:58 · Read course 02 pieces 00-04
for n in 00 01 02 04; do echo "##### $n"; sed -n '1,14p' forense-fase-$n.md; grep -nE '^### Paso|^## 🧨' forense-fase-$n.md; done

# --- 2026-09-10T02:39:25 · Stitch course 02 phases 00, 01, 04
python3 - <<'PY'
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser
RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("00-preliminares.md","forense-fase-00.md",
"""Lo que se rompe en esta fase no es Mongo: es el entorno que lo rodea, y se
diagnostica sin abrir un archivo de la aplicación. El contenedor dice que está
arriba y nadie logra conectarse — un puerto ocupado por otro Mongo instalado a
mano hace años, un volumen que no es el que crees, credenciales que el compose
declara y el cliente no manda. El reflejo que instala la pieza vale para
cualquier servicio en contenedor: **lee el log del arranque antes de googlear el
mensaje de error del cliente**, porque el cliente casi nunca sabe por qué no lo
dejaron entrar.""",
"""Provoca el choque de puertos a propósito, que es el caso que más veces vas a
vivir:

```bash
docker compose up -d          # con otro Mongo ya escuchando en 27017
docker compose logs mongo | tail -20
lsof -i :27017                # ¿quién tiene el puerto?
```

Compara lo que dice el cliente ("connection refused", "authentication failed")
con lo que dice el log del contenedor. No hablan del mismo suceso, y ésa es la
lección.""",
RES + '| 01 | "El contenedor está arriba y nadie conecta" | Operación | 🟢 |')

coser("01-mongo-en-30-min.md","forense-fase-01.md",
"""El silencio es la firma de esta fase: ves el documento en Compass y tu `find`
devuelve vacío, **sin ningún error**. En SQL el motor te avisa si la tabla o la
columna no existen; en Mongo no hay ese aviso — una colección que no existe está
vacía, un campo que no existe es `null`, y una comparación entre tipos distintos
simplemente no coincide. Por eso el recorrido empieza por lo aburrido y barato:
en qué base estás, cómo se llama de verdad la colección, y **qué tipo tiene lo
que hay guardado** frente a lo que buscas. El caso estrella es el `_id`: un
`ObjectId` no es la cadena con la que se imprime, y `find({ _id: "5f8a…" })`
devuelve el conjunto vacío que corresponde.""",
"""Comprueba el silencio con tus propios ojos, en `mongosh`:

```js
db.tickets.findOne()                                  // copia su _id
db.tickets.find({ _id: "<pega aquí el id como string>" }).count()   // 0
db.tikets.find().count()                              // 0, y la colección ni existe
```

Ningún error, dos veces. Anota cuánto habrías tardado en sospechar del tipo si
el segundo caso te llega en un ticket a las seis de la tarde.""",
RES + '| 02 | "El ticket está en la base y mi script no lo encuentra" | Consultas | 🟡 |')

coser("04-el-esquema-que-no-esta-en-la-base.md","forense-fase-04.md",
"""Un validator es la primera pieza del curso que **dice que no**, y decir que no
es justo lo que querías. Por eso la investigación no va sobre si el validator
está roto, sino sobre **qué regla concreta se está violando** — que es
exactamente lo que el mensaje por defecto no cuenta. El recorrido va del
`db.getCollectionInfos()` que te muestra la regla puesta al `typeof` del valor
que mandas, y termina en la pregunta que más desconcierta: *¿por qué entonces sí
entró ese documento inválido?* La respuesta —`validationLevel` y los documentos
que ya estaban— es la mitad de lo que hay que saber sobre validators en un
sistema heredado.""",
"""Pide el error completo, que es lo que casi nadie hace:

```js
try {
  db.tickets.insertOne({ title: "sin estado" });
} catch (e) {
  printjson(e.errInfo);      // ← acá está la regla que falló, no en e.message
}
```

Compáralo con lo que imprime `e.message` a secas. Un `Document failed
validation` no es un diagnóstico; `errInfo` sí.""",
RES + '| 04 | "Hay tickets que tardan diez veces más que los demás" | Modelado | 🟡 |')
PY

# --- 2026-09-10T02:39:39 · Fix reservation ownership between phases 3 and 4
python3 - <<'PY'
import io
p='04-el-esquema-que-no-esta-en-la-base.md'
s=io.open(p,encoding='utf-8').read()
i=s.index("\n---\n\n### 📌 Reservas para el cuaderno de incidentes")
s = s[:i] + """
---

### 📌 Reservas para el cuaderno de incidentes

Esta fase no reserva incidentes. El caso que nace de su material —un documento
que entró antes de que existiera la regla— se investiga dentro de la propia
fase; el incidente vecino, el de la forma del documento que sale cara, lo
reserva la Fase 3, que es donde se toma la decisión de modelado.
"""
io.open(p,'w',encoding='utf-8').write(s)

p2='03-embeber-vs-referenciar.md'
t=io.open(p2,encoding='utf-8').read()
assert "Reservas para el cuaderno" not in t
if not t.endswith("\n"): t += "\n"
t += """
---

### 📌 Reservas para el cuaderno de incidentes

Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| 04 | "Hay tickets que tardan diez veces más que los demás" | Modelado | 🟡 |

> 📄 Esta fase **no tiene pieza forense propia**: el recorrido de diagnóstico de
> ese incidente es el de la [Fase 5](forense-fase-05.md), donde el costo de la
> decisión de modelado se vuelve medible.
"""
io.open(p2,'w',encoding='utf-8').write(t)
print("ok")
PY
tail -14 03-embeber-vs-referenciar.md

# --- 2026-09-10T02:39:45 · Read course 02 pieces 05-08
for n in 05 06 07 08; do echo "##### $n"; sed -n '1,14p' forense-fase-$n.md; grep -nE '^### Paso' forense-fase-$n.md; done

# --- 2026-09-10T02:40:23 · Stitch course 02 phases 05-08
python3 - <<'PY'
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser
RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("05-lookup-y-por-que-es-una-alarma.md","forense-fase-05.md",
"""⭐ Aquí es donde el instinto SQL más se equivoca, y no por ignorancia: por
**exceso de confianza**. El `$lookup` se parece tanto a un JOIN que se usa igual,
y usarlo igual es el síntoma de un modelo diseñado como si fuera un esquema
relacional. El síntoma que llega es *"la pantalla funciona y es lenta"*, con una
lentitud que **crece con los datos, no con el código** — la firma de un problema
de modelo. Se depura contando viajes primero (los logs de la API), después con
`explain()` sobre el pipeline, y la pregunta del último paso es la que la fase
te obliga a hacerte: *¿esto debió embeberse?* Un `$lookup` no es un error; es
una alarma que pide justificar una decisión de modelado.""",
"""Cuenta los viajes antes de optimizar nada. Enciende el log de consultas y carga
la pantalla del listado una sola vez:

```js
db.setProfilingLevel(2)
// …carga la pantalla…
db.system.profile.find({ ns: /minijira/ }).count()
db.setProfilingLevel(0)
```

Si el número crece cuando hay más tickets en la página, tienes un N+1, y el
`$lookup` que ibas a escribir lo va a esconder, no a resolver.""",
RES + '| 05 | "El tablero tarda cuatro segundos y antes iba bien" | Modelado | 🟠 |')

coser("06-atomicidad-transacciones-consistencia.md","forense-fase-06.md",
"""⭐ La pieza donde el instinto relacional falla por una razón muy concreta: en tu
motor de siempre la transacción era gratis y la mitad de los frameworks la
ponían por defecto. Acá **no hay nada puesto**, y el bug no se ve nunca en
desarrollo, donde eres un solo usuario haciendo una cosa a la vez. Dos
operaciones que deberían excluirse tuvieron éxito las dos y ninguna dio error.
El recorrido empieza por lo que casi nadie mira —**qué devolvió cada escritura**,
`matchedCount` y `modifiedCount`— y sigue por el patrón culpable: el código
**lee y después escribe**, con una ventana entre las dos. La corrección no es
una transacción: es meter la precondición **dentro del filtro** de la
escritura.""",
"""Reproduce la carrera a voluntad, con dos sesiones de `mongosh` abiertas y el
mismo ticket:

```js
// en las dos, casi a la vez:
db.tickets.updateOne({ _id: id }, { $set: { assignee: "ana" } })
db.tickets.updateOne({ _id: id }, { $set: { assignee: "beto" } })
```

Las dos contestan `matchedCount: 1, modifiedCount: 1`. Las dos "ganaron", y el
ticket tiene un solo dueño. Ahora repítelo con la precondición dentro del filtro
—`{ _id: id, assignee: null }`— y mira qué contesta la segunda.""",
RES + '| 06 | "Dos agentes tomaron el mismo ticket" | Atomicidad | 🟠 |')

coser("07-indices.md","forense-fase-07.md",
"""Todo lo que sabes de índices en tu motor relacional sigue valiendo: selectividad,
prefijo izquierdo, el coste en las escrituras. Lo que cambia es la **herramienta
de diagnóstico y su capacidad de mentir** — por eso esta pieza es, sobre todo,
un curso de lectura de `explain()`. El síntoma típico es el más frustrante: *"el
índice está creado y `explain()` sigue diciendo COLLSCAN"*. Las causas suelen ser
tres, y ninguna es Mongo portándose mal: el índice compuesto no está en el orden
que la consulta necesita, la consulta no puede usarlo (un regex sin anclar, una
comparación entre tipos), o el índice se usa y la lentitud viene de otro sitio.
El paso 5 cierra con la pregunta honesta: *¿el problema es la consulta o el
modelo?* — un índice no arregla una decisión de forma.""",
"""Mide antes y después, que es lo único que convierte una opinión en un dato:

```js
db.tickets.find({ title: /impresora/ }).explain("executionStats").executionStats
// mira totalDocsExamined y nReturned, y anótalos
db.tickets.createIndex({ title: 1 })
db.tickets.find({ title: /impresora/ }).explain("executionStats").executionStats
```

Sigue en COLLSCAN, y el índice existe. Ancla ahora el regex (`/^impresora/`) y
vuelve a medir. Los tres números juntos son la explicación entera.""",
RES + '| 07 | "Creamos el índice y sigue igual de lento" | Índices | 🟠 |')

coser("08-la-autopsia.md","forense-fase-08.md",
"""Una migración es el único trabajo de este curso donde **el error se descubre
tarde y ya no hay origen al que volver**. Por eso la pieza no va sobre arreglar:
va sobre **verificar**, que es lo que nadie hace hasta la segunda vez que le
pasa. El síntoma es el peor de todos porque parece un éxito: la migración
terminó, los totales cuadran, y los datos no significan lo que dicen. Un conteo
igual no prueba nada —los documentos están, con los campos vacíos, con el tipo
cambiado o con el valor por defecto de todos—, así que la verificación es
**muestreo campo a campo**, más las dos preguntas que deciden si puedes dormir:
en qué orden se migró, y si el script se puede volver a correr sin duplicar.""",
"""Comprueba que el conteo miente, con el ejemplo más barato:

```js
db.tickets.countDocuments()                        // igual que el origen ✅
db.tickets.countDocuments({ priority: { $exists: false } })   // ¿cuántos perdieron el campo?
db.tickets.countDocuments({ createdAt: { $type: "string" } }) // ¿cuántos cambiaron de tipo?
```

Dos consultas de diez segundos que el conteo total nunca te iba a contar. Ésa es
la lista que se pega en el post-mortem.""",
RES + '| 08 | "La migración pasó el conteo y los reportes salen mal" | Modelado | 🟠 |')
PY

# --- 2026-09-10T02:40:28 · Read piece 12 and phase 12 section
sed -n '1,14p' forense-fase-12.md; grep -nE '^### Paso' forense-fase-12.md; echo "=== seccion 6 de 12 ==="; sed -n '441,470p' 12-el-backend-habla.md

# --- 2026-09-10T02:40:42 · Stitch course 02 phase 12
python3 - <<'PY'
import sys
sys.path.insert(0,'/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f9f4966e-40c6-443c-bf3d-e3e59987dc49/scratchpad')
from coser import coser
RES = "Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"

coser("12-el-backend-habla.md","forense-fase-12.md",
"""Un backend que habla por dos canales tiene **dos fronteras**, y casi siempre solo
la primera está bien vigilada. Ésa es toda la pieza: el serializer que todo el
mundo aplica al responder un HTTP y nadie recuerda aplicar al emitir un evento.
El síntoma llega desde la interfaz —"en vivo se ve mal y al recargar se ve
bien"— y se diagnostica poniendo **los dos canales lado a lado**: pide el mismo
ticket con `curl` y escucha el evento por socket. Si las dos formas no coinciden,
ya sabes qué mitad del caso estás resolviendo. Después vienen las otras tres
preguntas de esta fase: dónde se emite, **si se emite antes o después de
escribir** —el orden es la deuda que este curso vino a pagar— y cuántos emisores
hay realmente, porque el relé tonto del sistema heredado puede seguir
encendido.""",
"""Compara las dos fronteras en treinta segundos. Con el backend arriba, en una
consola del navegador:

```js
socket.on("ticket:updated", function (t) { console.log("socket:", t); });
```

Y en la terminal, sobre el mismo ticket:

```bash
curl -s localhost:4000/tickets/<id> | head -c 300
```

Si uno trae `_id` y fechas crudas y el otro `id` y fechas ISO, acabas de
encontrar el bug que solo pasa "cuando llega en vivo".""",
RES + '| 11 | "En vivo llega mal y al recargar se ve bien" | Contrato | 🔴 |')
PY

# --- 2026-09-10T02:40:50 · Map section boundaries in phases 09 and 10
for f in 09-aggregation.md 10-express-el-vehiculo.md; do echo "##### $f"; awk '/^## ⚠️ Errores comunes y pieza forense/,/^## 🧪/' $f | grep -nE '^###|^---|^## ' ; done

# --- 2026-09-10T02:41:19 · Stitch course 02 phases 02, 09, 10
python3 - <<'PY'
import io

def sub_after_heading(s, heading, sub):
    i = s.index(heading + "\n")
    return s[:i] + heading + "\n\n" + sub + "\n" + s[i+len(heading)+1:]

def append_before_sep(s, from_idx, texto):
    j = s.index("\n---\n\n## ", from_idx)
    return s[:j] + texto + s[j:]

def link(p): return "\n> \U0001f4c4 El recorrido completo, con las salidas literales, en\n> [`%s`](%s).\n" % (p,p)
RES = "\n---\n\n### \U0001f4cc Reservas para el cuaderno de incidentes\n\nEsta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n"
H = "## ⚠️ Errores comunes y pieza forense"

# ---------- F02 ----------
p="02-consultar-tu-sql-traducido.md"; s=io.open(p,encoding='utf-8').read()
s = sub_after_heading(s, H, "### Errores comunes")
bloque = """
### Pieza forense de esta fase

⭐ La pieza que más rinde del Curso 02, porque cubre el sitio exacto donde el
instinto relacional contesta rápido y contesta mal: **la traducción literal casi
funciona.** Un `WHERE` mal traducido no revienta — devuelve un resultado
plausible, y un resultado plausible se cuela hasta producción. Por eso el método
de esta fase no es leer el filtro, es **comparar contra el conteo**: cuántos son
en total, cuántos devuelve tu versión, y a qué corresponde la diferencia. Los
tres sospechosos habituales son el `$ne` que se lleva por delante a los ausentes,
la comparación entre tipos que no coincide sin avisar, y la proyección que
mezcla `1` y `0`.

**🧨 Rompe a propósito**

Reproduce la trampa del negado con tres documentos y cuatro conteos:

```js
db.demo.insertMany([{ a: "x" }, { a: null }, { }])
db.demo.countDocuments({ a: { $ne: "x" } })       // ¿2?
db.demo.countDocuments({ a: { $exists: true, $ne: "x" } })
```

Escribe el resultado que esperabas **antes** de correrlo. La distancia entre lo
que esperabas y lo que salió es exactamente el tamaño del bug que este filtro
mete en producción.
""" + link("forense-fase-02.md")
s = append_before_sep(s, s.index(H), bloque)
if not s.endswith("\n"): s += "\n"
s += RES + '| 03 | "El reporte de sin asignar da dos números distintos" | Consultas | 🟡 |\n'
io.open(p,'w',encoding='utf-8').write(s); print("ok", p)

# ---------- F09 ----------
p="09-aggregation.md"; s=io.open(p,encoding='utf-8').read()
s = sub_after_heading(s, H, "### Errores comunes")
s = s.replace('### 🩻 Pieza forense: "mi GROUP BY devuelve UNA fila"',
              '### Pieza forense de esta fase\n\nEl fallo insignia de esta fase, con su huella dactilar incluida: **un `GROUP BY`\nque colapsa a una fila**. Se diagnostica corriendo el pipeline por etapas —una\nmás en cada corrida— y mirando dónde cambia el número de documentos.')
bloque = """
**🧨 Rompe a propósito**

Quita el `$` de un `$group` que hoy funciona y corre las dos versiones seguidas:

```js
db.tickets.aggregate([{ $group: { _id: "status",  total: { $sum: 1 } } }])
db.tickets.aggregate([{ $group: { _id: "$status", total: { $sum: 1 } } }])
```

Un carácter, dos reportes distintos, cero errores. Ahora hazlo al revés: parte
un pipeline largo por la mitad y corre solo las tres primeras etapas. Ése es el
método, y sirve para cualquier pipeline ajeno.
""" + link("forense-fase-09.md")
s = append_before_sep(s, s.index(H), bloque)
if not s.endswith("\n"): s += "\n"
s += RES + '| 09 | "El reporte por estado devuelve una sola línea" | Consultas | 🟠 |\n'
io.open(p,'w',encoding='utf-8').write(s); print("ok", p)

# ---------- F10 ----------
p="10-express-el-vehiculo.md"; s=io.open(p,encoding='utf-8').read()
s = sub_after_heading(s, H, "### Errores comunes")
s = s.replace('### 🩻 Pieza forense: el request que no vuelve',
              '### Pieza forense de esta fase\n\nEl bug marca de la casa de Express 4, y el primero que se diagnostica **desde el\nlado del servidor**: los logs de morgan y `curl`, no la consola del navegador.')
bloque = """
**🧨 Rompe a propósito**

Escribe un handler async que lance sin red y pídelo:

```js
app.get("/boom", async function (req, res) { throw new Error("sin captura"); });
```

```bash
curl -m 5 localhost:4000/boom     # se cuelga y el timeout lo corta
```

Mira las dos cosas a la vez: el navegador (o `curl`) esperando, y morgan **sin
imprimir la línea**. Añade ahora `try/catch` + `next(err)` y repítelo: aparece
el 500 y aparece la línea. Ese "no hay línea" es el diagnóstico entero.
""" + link("forense-fase-10.md")
s = append_before_sep(s, s.index(H), bloque)
if not s.endswith("\n"): s += "\n"
s += RES + '| 10 | "Apunté el frontend al backend nuevo y no se ve nada" | Contrato | 🔴 |\n'
io.open(p,'w',encoding='utf-8').write(s); print("ok", p)
PY

# --- 2026-09-10T02:41:39 · Stitch phase 13 replacing inline block
python3 - <<'PY'
import io,re
p="13-testing-de-api.md"; s=io.open(p,encoding='utf-8').read()
H = "## ⚠️ Errores comunes y pieza forense"
i = s.index(H+"\n"); s = s[:i] + H + "\n\n### Errores comunes\n" + s[i+len(H)+1:]

start = s.index('### 🩻 Pieza forense — "verde en mi máquina, rojo en CI"')
end = s.index("\n---\n\n## 🧪", start)
nuevo = """### Pieza forense de esta fase

El caso clásico de esta fase, y el que te va a perseguir en cualquier proyecto
con pipeline: **la misma suite, el mismo commit, dos resultados distintos según
dónde corra.** La conclusión cómoda —"es un test flaky"— es la que deja el bug
vivo; la pregunta correcta es *contra qué está corriendo cada entorno*, porque un
test que da resultados distintos en dos sitios no es inestable: **está midiendo
dos sistemas.** El sospechoso número uno acá es el binario de
`mongodb-memory-server` sin `binary.version` fijado —tu laptop tiene 4.4
cacheado desde la Fase 0 y el runner descarga lo último—, y el número dos es el
aislamiento entre suites. La regla que se lleva uno del recorrido: **lo que no
está escrito en el repositorio, no existe**; el binario cacheado en la máquina de
quien corrió la suite primero es configuración invisible, y la configuración
invisible es la causa raíz favorita de los bugs que "solo pasan en CI".

**🧨 Rompe a propósito**

Quita el binario cacheado y corre la suite en frío, que es lo que hace el runner
en cada arranque:

```bash
rm -rf ~/.cache/mongodb-binaries     # o la caché que use tu instalación
npx jest test/services
```

Mira el log del `globalSetup`: te dice qué versión está descargando. Después
comprueba lo contrario con el test que impide la reincidencia —un
`expect(info.version).toMatch(/^4\\.4/)`— y observa cuál de los dos rojos es más
fácil de leer: el que habla de versiones, o el que habla de negocio.
""" + "\n> \U0001f4c4 El recorrido completo, con las salidas literales, en\n> [`forense-fase-13.md`](forense-fase-13.md).\n"
s = s[:start] + nuevo + s[end:]
if not s.endswith("\n"): s += "\n"
s += "\n---\n\n### \U0001f4cc Reservas para el cuaderno de incidentes\n\nEsta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:\n\n| ID | Título propuesto | Categoría | Dif. |\n|---|---|---|---|\n| 12 | \"Verde en mi máquina, rojo en CI\" | Testing | 🔴 |\n"
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
sed -n '/^### Pieza forense de esta fase/,/forense-fase-13/p' 13-testing-de-api.md | head -8

# --- 2026-09-10T02:41:59 · Add no-reservation notes and verify coverage
python3 - <<'PY'
import io
notas = {
 "11-auth-real-y-pago-de-deudas.md":
"""Esta fase no reserva incidentes, y el motivo es deliberado: su material es el
**pago** de deudas ya declaradas, no la creación de casos nuevos. Lo que aquí se
arregla aparece en el cuaderno desde el otro lado — como la causa raíz de
incidentes que reservaron fases anteriores— y lo que queda pendiente se anota en
`SECURITY-NOTES.md`, que es su registro propio.""",
 "14-operacion.md":
"""Esta fase no reserva incidentes. Los fallos de operación del curso —el
contenedor que arranca y no deja entrar a nadie, el entorno que se comporta
distinto al tuyo— ya están cubiertos por los incidentes 01 y 12, que reservaron
la Fase 0 y la Fase 13. Duplicarlos aquí sería material nuevo sin causa raíz
propia, y el formato lo prohíbe.""",
 "15-el-veredicto-honesto.md":
"""Esta fase no reserva incidentes: es el cierre del curso y no introduce
mecanismos nuevos que puedan romperse. Lo que aporta al cuaderno es de otro
tipo — los 📌 pendientes finales, donde varias respuestas de este veredicto
explican por qué algo no se arregla en este curso.""",
}
for f,t in notas.items():
    s=io.open(f,encoding='utf-8').read()
    if "Reservas para el cuaderno" in s: print("ya:",f); continue
    if not s.endswith("\n"): s+="\n"
    s += "\n---\n\n### \U0001f4cc Reservas para el cuaderno de incidentes\n\n" + t + "\n"
    io.open(f,'w',encoding='utf-8').write(s); print("ok",f)
PY
echo "--- cobertura C02 ---"; echo "piezas enlazadas: $(grep -l 'Pieza forense de esta fase' [0-9]*.md | wc -l)"; grep -l 'Reservas para el cuaderno' [0-9]*.md | sort | tr '\n' ' '

# --- 2026-09-10T02:42:04 · Inspect course 02 README structure
grep -nE '^#{2,3} ' README.md | head -20

# --- 2026-09-10T02:42:26 · Add forensic blocks to course 02 README
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
bloque = """## 🕵️ Track forense

Doce recorridos de investigación con el ticket literal, la salida de cada paso y
qué descarta cada uno. **No se leen de corrido: se entra por el síntoma.**

La puerta es [`forense-master.md`](forense-master.md), con el método de cuatro
preguntas y el **índice de síntomas transversal** — porque nadie llega sabiendo
de qué fase es su problema, llega con *"esto va lento"*.

| | Síntoma que cubre |
|---|---|
| [`forense-fase-00.md`](forense-fase-00.md) | "Levanté todo y no conecta", con errores que no hablan de lo que pasa |
| [`forense-fase-01.md`](forense-fase-01.md) | "El dato está en la base y la consulta no lo encuentra" |
| [`forense-fase-02.md`](forense-fase-02.md) | "Traduje mi WHERE y devuelve de más" ⭐ |
| [`forense-fase-04.md`](forense-fase-04.md) | "El validator rechaza un documento que a mí me parece correcto" |
| [`forense-fase-05.md`](forense-fase-05.md) | "Esta pantalla hace seis viajes a la base" ⭐ |
| [`forense-fase-06.md`](forense-fase-06.md) | "Dos agentes tomaron el mismo ticket" ⭐ |
| [`forense-fase-07.md`](forense-fase-07.md) | "El índice está creado y `explain()` sigue diciendo COLLSCAN" |
| [`forense-fase-08.md`](forense-fase-08.md) | "La migración pasó el conteo y los datos son basura" |
| [`forense-fase-09.md`](forense-fase-09.md) | "Mi GROUP BY devuelve UNA fila" |
| [`forense-fase-10.md`](forense-fase-10.md) | "El request se queda girando para siempre" ⭐ |
| [`forense-fase-12.md`](forense-fase-12.md) | "Por socket llega distinto que por HTTP" |
| [`forense-fase-13.md`](forense-fase-13.md) | "Verde en mi máquina, rojo en CI" |

**Cuatro fases no tienen pieza, y es a propósito:** F3, F11, F14 y F15 no
producen un recorrido de diagnóstico propio —lo suyo son decisiones de modelado,
pago de deudas, operación y veredicto—, y una pieza sin recorrido propio no es
una pieza: es un resumen de la fase con otro nombre. Sus errores típicos siguen
en la sección **⚠️ Errores comunes** de cada una.

Cada fase con pieza la enlaza desde su sección **⚠️ Errores comunes y pieza
forense**, donde además hay un bloque 🧨 **Rompe a propósito** para provocar el
fallo en tu propia máquina. El formato está especificado en
[`../prompts/formato-piezas-forenses.md`](../prompts/formato-piezas-forenses.md).

---

## 📓 Cuaderno de incidentes

[`cuaderno-incidentes.md`](cuaderno-incidentes.md) — **12 incidentes** graduados
🟢🟡🟠🔴 y repartidos por todo el curso. Cada uno trae el ticket **como llegó**
—vago, en palabras de quien lo reporta—, la preparación para tener el sistema
roto en tu máquina, tres pistas plegadas, un espacio en blanco para tu
investigación, y la solución de referencia con causa raíz, parche mínimo,
refactorización correcta, **prueba de regresión en código**, prevención y
post-mortem sin culpabilización.

Los dos últimos son **incidentes de costura** —el frontend apuntando a tu
backend— y son **autocontenidos**: se entrega el frontend construido, así que se
resuelven sin haber hecho el Curso 01. Los IDs son propios de este curso y no se
comparten con el otro cuaderno.

Y la regla que es la mitad del ejercicio: **la solución viene incluida, y abrirla
antes de escribir la tuya no te ahorra tiempo — te ahorra el ejercicio.**

---

"""
i=s.index("## 🗺️ El arco del curso"); s=s[:i]+bloque+s[i:]
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
sed -n '222,245p' README.md

# --- 2026-09-10T02:42:32 · Read course 02 numbers section
sed -n '/^## 📊 El material en números/,/^## 🎓/p' README.md

# --- 2026-09-10T02:42:38 · Update numbers and check overall status
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""- **16 fases** + **5 apéndices**""",
"""- **16 fases** + **5 apéndices**
- **12 piezas forenses** y **12 incidentes** en el cuaderno""")
s=s.replace("""| `00-audit-contrato.md` | ✅ firmado |""",
"""| `00-audit-contrato.md` | ✅ firmado |
| Track forense (`forense-*.md`) | ✅ terminado |
| `cuaderno-incidentes.md` | ✅ terminado |""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
cd .. && git status --short . | head -50

# --- 2026-09-10T02:42:49 · Check for broken markdown links
python3 - <<'PY'
import io,os,re,glob
base='.'
bad=[]
for f in glob.glob('01-vue2-legacy/*.md')+glob.glob('02-complement-mongodb-backend/*.md')+glob.glob('prompts/*.md')+['README.md']:
    d=os.path.dirname(f)
    s=io.open(f,encoding='utf-8').read()
    for m in re.finditer(r'\]\(([^)#]+\.md)(#[^)]*)?\)', s):
        t=m.group(1)
        if t.startswith('http'): continue
        p=os.path.normpath(os.path.join(d,t))
        if not os.path.exists(p): bad.append((f,t))
print("enlaces rotos:", len(bad))
for b in bad[:20]: print("  ",b[0],"->",b[1])
PY

# --- 2026-09-10T02:42:58 · Cross-check reserved IDs against notebooks
python3 - <<'PY'
import io,re,glob,os
for curso in ['01-vue2-legacy','02-complement-mongodb-backend']:
    # IDs reservados por fases
    res={}
    for f in sorted(glob.glob(curso+'/*.md')):
        if os.path.basename(f).startswith(('forense','cuaderno','0-','README')): continue
        s=io.open(f,encoding='utf-8').read()
        m=re.search(r'### 📌 Reservas para el cuaderno de incidentes(.*)$', s, re.S)
        if not m: continue
        for r in re.finditer(r'^\| (\d{2}) \|', m.group(1), re.M):
            res.setdefault(r.group(1),[]).append(os.path.basename(f))
    # IDs en el indice del cuaderno
    c=io.open(curso+'/cuaderno-incidentes.md',encoding='utf-8').read()
    idx=set(re.findall(r'^\| (\d{2}) \| \d+ \|', c, re.M))
    inc=set(re.findall(r'^## Incidente (\d{2}) —', c, re.M))
    print(curso)
    print("  reservados:", sorted(res), len(res))
    print("  índice    :", sorted(idx), len(idx))
    print("  escritos  :", sorted(inc), len(inc))
    print("  huérfanos reserva->índice:", sorted(set(res)-idx))
    print("  huérfanos índice->reserva:", sorted(idx-set(res)))
    print("  duplicados:", {k:v for k,v in res.items() if len(v)>1})
PY

# --- 2026-09-10T02:43:11 · Verify phase-ID mapping, appendices and tag namespaces
python3 - <<'PY'
import io,re,glob,os
for curso,pre in [('01-vue2-legacy',''),('02-complement-mongodb-backend','')]:
    c=io.open(curso+'/cuaderno-incidentes.md',encoding='utf-8').read()
    idx={m.group(1):m.group(2) for m in re.finditer(r'^\| (\d{2}) \| (\d+) \|', c, re.M)}
    for f in sorted(glob.glob(curso+'/*.md')):
        b=os.path.basename(f)
        if b.startswith(('forense','cuaderno','0-','README')): continue
        s=io.open(f,encoding='utf-8').read()
        m=re.search(r'### 📌 Reservas para el cuaderno de incidentes(.*)$', s, re.S)
        if not m: continue
        for r in re.finditer(r'^\| (\d{2}) \|', m.group(1), re.M):
            i=r.group(1); fase=idx.get(i)
            num=re.match(r'(\d+)', b)
            n = str(int(num.group(1))) if num else '?'
            if fase != n: print("MISMATCH", curso, b, "id",i,"índice dice fase",fase)
print("fin")
PY
echo "=== apéndices C02 ==="; grep -l 'Pieza forense\|Reservas para\|🏷️' 02-complement-mongodb-backend/a0*.md 01-vue2-legacy/a[1-5]*.md 2>/dev/null || echo "  limpios ✅"
echo "=== namespaces de tags inventados ==="; grep -rhoE '\b(forense|incidente|pieza)/[a-z0-9/-]+' 01-vue2-legacy/*.md 02-complement-mongodb-backend/*.md | sort -u | head

# --- 2026-09-10T02:43:22 · Scan for voseo and invented tag namespaces
grep -rnoE '\b(tenés|podés|querés|sabés|hacés|mirá|fijate|escribí|andá|tomá|vosotros|ordenador|móvil|vale la pena que)\b' 01-vue2-legacy/*.md 02-complement-mongodb-backend/*.md | sort -u | head; echo "--- ok si vacío ---"; grep -rn 'forense/' 01-vue2-legacy/*.md 02-complement-mongodb-backend/*.md | head -3

# --- 2026-09-10T02:43:25 · Inspect voseo candidates in context
sed -n '524,528p' 01-vue2-legacy/06-wizard-minimo.md; sed -n '102,106p' 01-vue2-legacy/forense-fase-09.md

# --- 2026-09-10T02:43:55 · Update plan checklist after stitching and audit
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()

s=s.replace("| 7 · La costura | **P7-A** · **P7-B** | ⬜ | ninguna fase tiene línea 📄 ni bloque 📌 todavía |",
"| 7 · La costura | P7-A · P7-B | ✅ | 27 + 16 fases cosidas · 12 + 12 bloques 📌 · los dos README con 🕵️ y 📓 |")
s=s.replace("| 8 · La auditoría | **P8** | ⬜ | — |",
"| 8 · La auditoría | **P8** | ⏳ | mecánica en verde (ver §12.5); falta la lectura de contenido |")

s=s.replace("""- ⬜ **27 fases** del Curso 01 (12 de tronco + 15 de ruta): sección 6 renombrada, resumen,
  bloque 🧨, línea 📄 y —solo el tronco— bloque 📌. → **P7-A**
- ⬜ **16 fases** del Curso 02, de las cuales 12 llevan línea 📄 y 4 (F3, F11, F14, F15) se
  quedan sin ella a propósito. → **P7-B**
- ⬜ **Los dos README de curso**: bloques «🕵️ Track forense» y «📓 Cuaderno de incidentes».
- ⬜ **La auditoría cruzada** de enlaces, IDs, síntomas, contrato y tuteo. → **P8**
- ⬜ **El README del paquete** (raíz) no menciona el track forense ni los cuadernos en su
  tabla «📂 Qué hay en la raíz» ni en el mapa 🗺️. Es media hora y se hace con P7.""",
"""- ✅ **27 fases** del Curso 01 (12 de tronco + 15 de ruta) y **16** del Curso 02, cosidas el
  2026-09-09: sección 6 renombrada, resumen, bloque 🧨, línea 📄 y bloque 📌.
- ✅ **Los dos README de curso**, con «🕵️ Track forense» y «📓 Cuaderno de incidentes».
- ⏳ **La auditoría cruzada**: la parte mecánica está corrida y en verde (§12.5). Queda la
  que exige leer: que cada pieza entregue los tickets que su fase promete, que nada
  contradiga `00-audit-contrato.md`, y la lectura de las salidas contra el proyecto
  corriendo. → **P8**
- ⬜ **El README del paquete** (raíz) sigue sin mencionar el track forense ni los cuadernos
  en su tabla «📂 Qué hay en la raíz» ni en el mapa 🗺️. Media hora.""")

s=s.replace("""### 12.4 Lo que este repaso encontró y no estaba anotado""",
"""### 12.5 La auditoría mecánica, corrida el 2026-09-09

| Comprobación | Resultado |
|---|---|
| Enlaces `.md` relativos en fases, piezas, cuadernos, prompts y README | **0 rotos** |
| IDs reservados por las fases ↔ índice del cuaderno, en los dos sentidos | **12 + 12, sin huérfanos ni duplicados** |
| La fase que reserva cada ID coincide con la columna «Fase» del índice | **sin discrepancias** |
| Incidentes escritos frente a filas del índice | **12 + 12** |
| Apéndices (a1–a5 y a01–a05): sin 🏷️, sin 📄, sin 📌 | **limpios** |
| Namespaces de tags: solo `fase-`, `ej/`, `inc/`, `deuda/`, `apendice-` | **ninguno inventado** |
| Voseo y términos de España | **ninguno** (los `escribí` son primera persona) |

Lo que esta pasada **no** cubre y sigue siendo trabajo de lectura: que cada pieza entregue
los tickets que su fase promete, la coherencia con `00-audit-contrato.md`, y —lo que ningún
script puede— que las salidas literales se reproduzcan con el proyecto corriendo.

### 12.4 Lo que este repaso encontró y no estaba anotado""")

s=s.replace("""**Siguiente paso:** **P7-A** — la costura del Curso 01. P6-bis quedó cerrado el 2026-09-09.
Después **P7-B** y, al final de todo, **P8**.""",
"""**Siguiente paso:** **P8**, la auditoría de lectura. P6-bis, P7-A y P7-B quedaron cerrados
el 2026-09-09, y la parte mecánica de P8 ya está corrida y en verde (§12.5). Después,
commitear: el track completo sigue sin entrar a git.""")
s=s.replace("**Lo ejecutado, a 2026-09-09:** pasos 0 a 6 completos.",
            "**Lo ejecutado, a 2026-09-09:** pasos 0 a 7 completos.")
s=s.replace("""> 🚦 **Estado, a 2026-09-09.** P0 a P6 y P6-bis están **ejecutados** (sin commitear todavía)
> y se conservan aquí como registro de lo que se pidió, no como trabajo por hacer. Lo que
> queda vivo son **P7-A, P7-B y P8**, que ya vienen cerrados: traen dentro las listas
> exactas de archivos, el mapeo 📄 y las tablas de reservas, así que se pegan y se ejecutan
> sin volver a inventariar nada. El checklist de §12 dice dónde estás.""",
"""> 🚦 **Estado, a 2026-09-09.** P0 a P7-B están **ejecutados** (sin commitear todavía) y se
> conservan aquí como registro de lo que se pidió, no como trabajo por hacer. El único que
> queda vivo es **P8**, y su parte mecánica ya está corrida (§12.5). El checklist de §12
> dice dónde estás.""")
s=s.replace("### P7-A · Coser el track a las fases del Curso 01 ⬅️ **cerrado, listo para pegar**",
            "### P7-A · Coser el track a las fases del Curso 01 ✅ **ejecutado — 27 fases + README**")
s=s.replace("### P7-B · Coser el track a las fases del Curso 02 ⬅️ **cerrado, listo para pegar**",
            "### P7-B · Coser el track a las fases del Curso 02 ✅ **ejecutado — 16 fases + README**")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
grep -n "12.5\|12.4\|P8" contenido_forense.md | tail -6

# --- 2026-09-10T02:44:09 · Renumber checklist subsections
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("### 12.5 La auditoría mecánica, corrida el 2026-09-09","### 12.4 La auditoría mecánica, corrida el 2026-09-09")
s=s.replace("### 12.4 Lo que este repaso encontró y no estaba anotado","### 12.5 Lo que estos repasos encontraron y no estaba anotado")
s=s.replace("(§12.5)","(§12.4)")
s=s.replace("""- **Asimetría deliberada en el Curso 02**: F3 reserva incidente y no tiene pieza; F4 tiene
  pieza y no reserva incidente. Documentado en P7-B y exento en P8 para que nadie lo
  «arregle» dos meses después.""",
"""- **Asimetría deliberada en el Curso 02**: F3 reserva incidente y no tiene pieza; F4 tiene
  pieza y no reserva incidente. Documentado en P7-B y exento en P8 para que nadie lo
  «arregle» dos meses después. Al coser se cometió y se corrigió justo ese error —el
  incidente 04 acabó primero en F4—, que es exactamente el motivo de que la tabla de
  reservas viva dentro del prompt.
- **Cuatro fases del Curso 02 llevaban ya un bloque forense en línea** (F2, F9, F10, F13,
  con el encabezado «Errores comunes y pieza forense» desde antes del track). Los tres
  primeros se conservaron como resumen; el de F13, que eran los ocho puntos completos del
  post-mortem, se comprimió porque su pieza los promovió a archivo — es lo que D1 pide.""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
grep -n "^### 12" contenido_forense.md

# --- 2026-09-10T02:51:12 · Extract contract enums and event names
grep -nE 'status|priority|ticket:|comment:|activity:' 02-complement-mongodb-backend/00-audit-contrato.md | grep -iE 'enum|open|high|created|updated' | head -20

# --- 2026-09-10T02:51:17 · Check event names and enums against contract
echo "=== eventos citados en piezas/cuadernos ==="; grep -rhoE '"(ticket|comment|activity):[a-z]+"' 01-vue2-legacy/forense-*.md 01-vue2-legacy/cuaderno-incidentes.md 02-complement-mongodb-backend/forense-*.md 02-complement-mongodb-backend/cuaderno-incidentes.md | sort | uniq -c
echo "=== status/priority usados ==="; grep -rhoE 'status: "[a-z_]+"|priority: "[a-z]+"' 01-vue2-legacy/forense-*.md 02-complement-mongodb-backend/forense-*.md 0*/cuaderno-incidentes.md | sort | uniq -c
echo "=== enums del contrato ==="; grep -nE 'open/in_progress|"open"|resolved|closed' 02-complement-mongodb-backend/00-audit-contrato.md | head -5

# --- 2026-09-10T02:51:24 · Read root README table
grep -n "Qué hay en la raíz" -A 12 README.md

# --- 2026-09-10T02:51:40 · Add forensic section to package README
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()

s=s.replace("""| [`prompts/convencion-de-git-y-tags.md`](prompts/convencion-de-git-y-tags.md) | 🏷️ **Cómo versionas tu código mientras haces los cursos.** Dos repos, un tag por fase, tags de ejercicio y los comandos que te dicen dónde te quedaste |
""",
"""| [`prompts/convencion-de-git-y-tags.md`](prompts/convencion-de-git-y-tags.md) | 🏷️ **Cómo versionas tu código mientras haces los cursos.** Dos repos, un tag por fase, tags de ejercicio y los comandos que te dicen dónde te quedaste |
| [`prompts/formato-piezas-forenses.md`](prompts/formato-piezas-forenses.md) | 🕵️ La especificación de las piezas forenses: qué es un paso, qué descarta, y dónde está la frontera con la fase |
| [`prompts/formato-cuaderno-incidentes.md`](prompts/formato-cuaderno-incidentes.md) | 📓 La especificación del cuaderno de incidentes: la plantilla, las cuotas, las tres formas de preparación y la convención de commits de una investigación |
""")

bloque = """
---

## 🕵️ El track forense y los cuadernos

Los dos cursos traen, además de las fases, un aparato para lo que de verdad
haces en un sistema heredado: **investigar**. Son tres piezas por curso y se
usan fuera de orden.

| | Curso 01 | Curso 02 |
|---|---|---|
| `forense-master.md` — la puerta, con el 🩺 índice de síntomas | ✅ | ✅ |
| `forense-fase-NN.md` — el recorrido paso a paso, con salidas literales | 12 + 3 de ruta | 12 |
| `cuaderno-incidentes.md` — tickets vagos, pistas plegadas y solución de referencia | 12 incidentes | 12 incidentes |

**No se leen de corrido.** Una pieza forense se entra por el síntoma —"la tabla
se quedó igual", "esto va lento"— y por eso la puerta de cada curso es su índice
de síntomas y no un índice de fases. Un incidente se trabaja como un ticket real:
se reproduce, se investiga y solo al final se abre la solución.

> ⚠️ **Un cuaderno por curso, con IDs propios.** Los cursos son independientes:
> se puede hacer solo el frontend. Ningún incidente del Curso 01 cita al Curso
> 02, y los dos incidentes de costura del Curso 02 —el frontend apuntando a tu
> backend— entregan el frontend ya construido, así que se resuelven sin haberlo
> escrito.

Cada fase enlaza su pieza desde la sección **⚠️ Errores comunes y pieza
forense**, con un bloque 🧨 **Rompe a propósito** para provocar el fallo en tu
máquina, y reserva sus incidentes en un bloque 📌 al final. Los apéndices no
llevan nada de esto: explican lo que ya está ahí, y no producen código de fase.
"""
i=s.index("## 🧭 Cómo usar el paquete"); s=s[:i]+bloque.lstrip("\n")+"\n"+s[i:]
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
grep -n "^## " README.md

# --- 2026-09-10T02:51:48 · Fix separators in package README
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("Fase 2. Ese cobro es buena parte del contenido del Curso 02.\n\n---\n\n---\n\n## 🕵️",
            "Fase 2. Ese cobro es buena parte del contenido del Curso 02.\n\n---\n\n## 🕵️")
s=s.replace("llevan nada de esto: explican lo que ya está ahí, y no producen código de fase.\n\n## 🧭 Cómo usar el paquete",
            "llevan nada de esto: explican lo que ya está ahí, y no producen código de fase.\n\n---\n\n## 🧭 Cómo usar el paquete")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
sed -n '86,94p' README.md; sed -n '117,124p' README.md

# --- 2026-09-10T02:51:55 · Read quota rules for notebooks
sed -n '110,172p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-10T02:52:15 · Check root causes of course 01 incidents 04 and 09
cd 01-vue2-legacy && sed -n '/^## Incidente 04/,/^## Incidente 05/p' cuaderno-incidentes.md | grep -A8 "Causa raíz" | head -20; echo "=== inc 09 ==="; sed -n '/^## Incidente 09/,/^## Incidente 10/p' cuaderno-incidentes.md | grep -A8 "Causa raíz" | head -20

# --- 2026-09-10T02:52:30 · Check concurrency coverage in notebooks
sed -n '/^## Incidente 12/,/^## 🪞/p' cuaderno-incidentes.md | grep -A6 "Causa raíz" | head -12; echo "=== C02: menciones de concurrencia/carrera fuera del 06 ==="; cd ../02-complement-mongodb-backend && python3 - <<'PY'
import io,re
s=io.open('cuaderno-incidentes.md',encoding='utf-8').read()
partes=re.split(r'^## Incidente (\d\d)', s, flags=re.M)
for i in range(1,len(partes),2):
    n=partes[i]; t=partes[i+1]
    hits=len(re.findall(r'concurren|carrera|race|atómic|findOneAndUpdate|precondición', t, re.I))
    if hits: print(" inc",n,"->",hits,"menciones")
PY

# --- 2026-09-10T02:52:47 · Check independence, screenshots and id conventions
cd ..; echo "=== C01 cita al Curso 02? ==="; grep -rniE 'curso 02|mongo|express|02-complement' 01-vue2-legacy/cuaderno-incidentes.md 01-vue2-legacy/forense-*.md | head; echo "=== imágenes ==="; grep -rn '!\[' 01-vue2-legacy/*.md 02-complement-mongodb-backend/*.md | head -3; echo "  (vacío = sin capturas)"; echo "=== id vs _id en piezas C01 ==="; grep -rn '_id' 01-vue2-legacy/forense-*.md 01-vue2-legacy/cuaderno-incidentes.md | head -3

# --- 2026-09-10T02:52:50 · Inspect cross-course references
sed -n '74,82p' 01-vue2-legacy/forense-fase-03.md; echo "=== C02 exige haber hecho C01? ==="; grep -rniE 'curso 01|si hiciste el curso|haber hecho' 02-complement-mongodb-backend/cuaderno-incidentes.md | head

# --- 2026-09-10T02:53:02 · Read style guide final checklist
sed -n '/^## 15/,/^## 16/p' prompts/guia-de-estilo-y-convenciones.md | head -45

# --- 2026-09-10T02:53:21 · Add no-piece notes to section 6 of four phases
cd 02-complement-mongodb-backend && python3 - <<'PY'
import io
notas = {
 "03-embeber-vs-referenciar.md":
"""> 📄 **Esta fase no tiene pieza forense propia**, y es deliberado: lo suyo son
> decisiones de modelado, no un recorrido de diagnóstico. Su costo se vuelve
> medible —y por tanto investigable— en la [Fase 5](forense-fase-05.md), que es
> donde vive el recorrido del incidente que esta fase reserva.""",
 "11-auth-real-y-pago-de-deudas.md":
"""> 📄 **Esta fase no tiene pieza forense propia**, y es deliberado: aquí no se
> investiga nada, se **paga** lo que otras fases dejaron declarado. Los
> recorridos de los fallos que se cierran acá viven en las piezas de las fases
> que los produjeron; lo que queda abierto se anota en `SECURITY-NOTES.md`.""",
 "14-operacion.md":
"""> 📄 **Esta fase no tiene pieza forense propia**, y es deliberado: los dos
> síntomas de operación del curso ya tienen recorrido — el contenedor que no
> deja entrar a nadie, en [`forense-fase-00.md`](forense-fase-00.md), y el
> entorno que se comporta distinto al tuyo, en
> [`forense-fase-13.md`](forense-fase-13.md).""",
 "15-el-veredicto-honesto.md":
"""> 📄 **Esta fase no tiene pieza forense propia**, y es deliberado: es el cierre
> del curso y no introduce mecanismos nuevos que puedan romperse. El índice de
> síntomas completo, por si lo que buscas es dónde investigar, está en
> [`forense-master.md`](forense-master.md).""",
}
for f,t in notas.items():
    s=io.open(f,encoding='utf-8').read()
    if "no tiene pieza forense propia**" in s: print("ya:",f); continue
    h = "## ⚠️ Errores comunes"
    i = s.index(h+"\n")
    j = s.index("\n---\n\n## ", i)
    s = s[:j] + "\n" + t + "\n" + s[j:]
    io.open(f,'w',encoding='utf-8').write(s); print("ok",f)
PY

# --- 2026-09-10T02:53:31 · Add note to phase 3 section 6
python3 - <<'PY'
import io
f="03-embeber-vs-referenciar.md"
s=io.open(f,encoding='utf-8').read()
h="## ⚠️ Errores comunes"
i=s.index(h+"\n"); j=s.index("\n---\n\n## ", i)
if "no tiene pieza forense propia**, y es deliberado: lo suyo son" in s[i:j]:
    print("ya en sección 6")
else:
    t = """> 📄 **Esta fase no tiene pieza forense propia**, y es deliberado: lo suyo son
> decisiones de modelado, no un recorrido de diagnóstico. El costo de esas
> decisiones se vuelve medible —y por tanto investigable— en la
> [Fase 5](forense-fase-05.md), que es donde vive el recorrido del incidente que
> esta fase reserva."""
    s = s[:j] + "\n" + t + "\n" + s[j:]
    io.open(f,'w',encoding='utf-8').write(s); print("ok")
PY
grep -c "no tiene pieza forense propia" 0*.md 1*.md | grep -v ':0'

# --- 2026-09-10T02:54:10 · Write P8 audit report into plan document
cd .. && python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()

informe = """
---

## 13. 🔎 P8 — el informe de auditoría

Corrida el **2026-09-09**, sobre el paquete completo. La parte mecánica está en §12.4 y
salió en verde; esto es lo que salió de **leer**.

### 13.1 Hallazgos

| Archivo | Hallazgo | Severidad | Arreglo propuesto |
|---|---|---|---|
| `02-…/cuaderno-incidentes.md` | **La cuota «2 de atomicidad o concurrencia» no se cumple:** solo el incidente 06 la cubre. Ninguno de los otros once toca una carrera (verificado por búsqueda de causa raíz, no por etiqueta). | **Media** | Tres salidas, y es decisión de autor: (a) reescribir el incidente 07 —el índice que `explain()` ignora— para que la lentitud venga de una escritura concurrente; (b) declarar la divergencia en `formato-cuaderno-incidentes.md` §4 con su motivo; (c) un incidente 13, que rompe los cuatro tramos de tres. **Recomendada: (b)** — la cuota se escribió antes que el material, y el Curso 02 concentra su concurrencia en la Fase 6 por diseño. |
| `01-…/cuaderno-incidentes.md` | **La cuota «2 de Vuex» se cumple en sustancia y no en la etiqueta:** el incidente 10 está etiquetado Estado (Vuex) y el 12 está etiquetado Build, pero su causa raíz vive en `store/index.js` (el `strict` que solo corre en desarrollo). | **Baja** | Ninguno. La etiqueta describe el **síntoma** —que es de build— y así debe seguir: el estudiante busca por lo que ve, no por lo que resultó ser. Queda anotado aquí para que P8 no lo vuelva a levantar. |
| `01-…/forense-fase-03.md` | Menciona al Curso 02 ("el request colgado que el Curso 02 investiga en su Fase 10"). | **Informativo** | Ninguno. La regla D3 prohíbe **depender**, no mencionar: es un puntero de una línea, se entiende sin abrir nada del otro curso, y el cuaderno del Curso 01 —que es donde la regla muerde— está limpio. |
| `13-testing-de-api.md` | Traía los ocho puntos completos del post-mortem en su sección 6, duplicando entera su pieza. | **Resuelto** | Comprimido a resumen + 🧨 + línea 📄, que es lo que pide D1. Los otros tres bloques en línea (F2, F9, F10) eran ya del tamaño de un resumen y se conservaron. |
| `03`, `11`, `14`, `15` del Curso 02 | La sección 6 no decía por qué no tienen pieza, y el checklist §15 de la guía lo exige ("o dice por qué no"). | **Resuelto** | Añadida en las cuatro una línea 📄 que declara la ausencia y remite a la pieza donde sí vive ese recorrido. |
| `README.md` (raíz del paquete) | No mencionaba el track ni los cuadernos. | **Resuelto** | Sección «🕵️ El track forense y los cuadernos» y dos filas nuevas en la tabla de la raíz. |

### 13.2 Lo que P8 no puede firmar

**Las salidas literales.** Ningún script comprueba que un bloque de código de una pieza
sea lo que de verdad imprime el proyecto. El riesgo está declarado en §10 y la única
defensa es correr a mano, contra el proyecto de la fase, al menos:

- Curso 01 — **F3** (Network y el inyector de caos), **F5** (el silencio del formulario),
  **F8** (dos navegadores y el socket) y **F10** (el registro de mutations).
- Curso 02 — **F5** (`explain()` sobre el pipeline), **F7** (`executionStats`) y **F13**
  (el arranque del `globalSetup`).

Es trabajo de autor, no de chat, y hasta que se haga el track está **escrito pero no
verificado**.

### 13.3 Veredicto

El aparato está completo y es coherente: 29 piezas, 24 incidentes, 43 fases cosidas, dos
cuadernos con sus retrospectivas y sus pendientes, y cero enlaces rotos o IDs huérfanos.
De los seis hallazgos, cuatro quedaron resueltos en la misma pasada, uno es una nota para
el futuro y **uno pide una decisión de autor** — la cuota de concurrencia del Curso 02.

Lo que falta ya no es escribir: es **verificar contra el proyecto** y **commitear**.
"""
s = s.rstrip("\n") + "\n" + informe
s = s.replace("| 8 · La auditoría | **P8** | ⏳ | mecánica en verde (ver §12.4); falta la lectura de contenido |",
              "| 8 · La auditoría | P8 | ✅ | mecánica en verde (§12.4) · informe de lectura en **§13** |")
s = s.replace("""- ⏳ **La auditoría cruzada**: la parte mecánica está corrida y en verde (§12.4). Queda la
  que exige leer: que cada pieza entregue los tickets que su fase promete, que nada
  contradiga `00-audit-contrato.md`, y la lectura de las salidas contra el proyecto
  corriendo. → **P8**
- ⬜ **El README del paquete** (raíz) sigue sin mencionar el track forense ni los cuadernos
  en su tabla «📂 Qué hay en la raíz» ni en el mapa 🗺️. Media hora.""",
"""- ✅ **La auditoría cruzada**, mecánica (§12.4) y de lectura (§13). Un hallazgo sigue
  abierto y pide decisión de autor: la cuota de concurrencia del Curso 02.
- ✅ **El README del paquete** (raíz), con la sección «🕵️ El track forense y los cuadernos».
- ⬜ **Verificar las salidas literales** corriendo el proyecto: F3, F5, F8 y F10 del Curso
  01; F5, F7 y F13 del Curso 02 (§13.2). Es lo único que ningún script puede firmar.
- ⬜ **Commitear.** Nada del track ha entrado a git todavía.""")
s = s.replace("""**Siguiente paso:** **P8**, la auditoría de lectura. P6-bis, P7-A y P7-B quedaron cerrados
el 2026-09-09, y la parte mecánica de P8 ya está corrida y en verde (§12.4). Después,
commitear: el track completo sigue sin entrar a git.""",
"""**Siguiente paso:** los ocho pasos están cerrados. Quedan dos cosas, y ninguna es escribir:
**verificar las salidas contra el proyecto corriendo** (§13.2) y **commitear** — el track
completo sigue sin entrar a git. Y una decisión de autor: la cuota de concurrencia del
Curso 02 (§13.1).""")
s = s.replace("**Lo ejecutado, a 2026-09-09:** pasos 0 a 7 completos.",
              "**Lo ejecutado, a 2026-09-09:** los ocho pasos completos.")
s = s.replace("### P8 · Auditoría de cierre ⬅️ **cerrado, se ejecuta al final**",
              "### P8 · Auditoría de cierre ✅ **ejecutado — informe en §13**")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
grep -n "^## 13\|^### 13" contenido_forense.md; wc -l contenido_forense.md

# --- 2026-09-10T02:54:26 · Verify formatting of inserted blocks
sed -n '/^## ⚠️ Errores comunes/,/^## 🧪/p' 02-complement-mongodb-backend/14-operacion.md | tail -12; echo "=== dobles separadores ==="; grep -rn -B1 '^---$' 01-vue2-legacy/*.md 02-complement-mongodb-backend/*.md 2>/dev/null | grep -A1 -- '---$' | grep -c '^\-\-$' ; python3 - <<'PY'
import io,glob,re
n=0
for f in glob.glob('0*/*.md')+['README.md']:
    s=io.open(f,encoding='utf-8').read()
    if re.search(r'\n---\n\s*\n---\n', s): print("doble separador:",f); n+=1
print("archivos con doble separador:",n)
PY

# --- 2026-09-10T15:39:47 · Read inventory section of plan
sed -n '278,315p' contenido_forense.md

# --- 2026-09-10T15:39:49 · Read current checklist section
sed -n '/^## 12/,/^### 12.4/p' contenido_forense.md

# --- 2026-09-10T15:40:12 · Update section 12 checklists
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()

# --- §12.1 paso 8 ---
s=s.replace("| 8 · La auditoría | **P8** | ⏳ | mecánica en verde (ver §12.5); falta la lectura de contenido |",
            "| 8 · La auditoría | P8 | ✅ | mecánica en verde (§12.4) · informe de lectura en **§13** |")

# --- §12.2 duplicado ---
s=s.replace("""- ⬜ **Commitear.** Nada del track ha entrado a git todavía.
- ⬜ **Nada está commiteado.** El orden de commits que el plan pide sigue siendo válido:
  la convención sola primero, después formatos, rectores, puertas, caos, piezas, cuadernos
  y costura.""",
"""- ⬜ **Commitear.** Nada del track ha entrado a git todavía: 52 archivos modificados y 34
  nuevos, todos dentro de `vue2-legacy-for-backend-devs/`. El orden de commits que pide el
  plan sigue siendo válido — la convención sola primero, después formatos, rectores,
  puertas, caos, piezas, cuadernos y costura— y falta decidir si van sobre `master` o sobre
  una rama.
- ⬜ **Decidir la cuota de concurrencia del Curso 02** (§13.1). Es el único hallazgo abierto
  de la auditoría y es decisión de autor, no de ejecución.""")

# --- §12.3 titulo (ya se miró) ---
s=s.replace("### 12.3 Los cinco invariantes que P8 va a mirar\n\nSi dudas mientras escribes, éstos son los que se rompen sin avisar:",
            "### 12.3 Los cinco invariantes, y cómo salieron\n\nSon los que se rompen sin avisar. P8 los miró uno por uno el 2026-09-09:")
s=s.replace("""1. **IDs por curso, nunca compartidos** (D3), y ninguno reasignado.
2. **Independencia**: el Curso 01 no cita al 02; los incidentes de costura del 02 son
   autocontenidos.
3. **Los apéndices no llevan nada**: ni 🏷️, ni 📄, ni 📌, ni tag (guía §9.1).
4. **Cero salidas inventadas.** P8 no puede detectarlo: corre F3, F5, F8 y F10 a mano.
5. **Código en inglés, narrativa en español con tuteo** — y el voseo se cuela en los
   tickets, que están escritos en voz de usuario.""",
"""1. ✅ **IDs por curso, nunca compartidos** (D3), y ninguno reasignado. 12 + 12, cruzados en
   los dos sentidos, sin huérfanos ni duplicados.
2. ✅ **Independencia**: el cuaderno del Curso 01 no cita al 02, y los dos incidentes de
   costura del 02 entregan el frontend construido. La única mención cruzada —una línea en
   `forense-fase-03.md`— es un puntero, no una dependencia (§13.1).
3. ✅ **Los apéndices no llevan nada**: ni 🏷️, ni 📄, ni 📌, ni tag (guía §9.1). Los diez
   revisados, limpios.
4. ⬜ **Cero salidas inventadas.** Es el único invariante que ningún script puede firmar:
   hay que correr a mano F3, F5, F8 y F10 del Curso 01, y F5, F7 y F13 del Curso 02.
5. ✅ **Código en inglés, narrativa en español con tuteo.** Pasada de voseo en verde; los
   tres `escribí` que aparecen son primera persona del pasado, no imperativo voseante.""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY

# --- 2026-09-10T15:40:36 · Rewrite inventory with real state
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()

# --- cabecera del documento ---
s=s.replace("""> Fecha: 2026-09-08 · Alcance: `vue2-legacy-for-backend-devs/` (Cursos 01 y 02)""",
            """> Fecha: 2026-09-08 · Última actualización: **2026-09-10** · Alcance:
> `vue2-legacy-for-backend-devs/` (Cursos 01 y 02)""")
s=s.replace("""> **Estado: decisiones D0–D6 cerradas** (§5). Este documento ya no propone: ejecuta.""",
"""> **Estado: los ocho pasos ejecutados** (§14). Decisiones D0–D6 cerradas (§5), prompts
> cerrados y ejecutados (§8), auditoría corrida (§12.4 y §13). Lo que queda no es escribir:
> **verificar contra el proyecto corriendo, commitear, y una decisión de autor.**""")
s=s.replace("""> ⚠️ **Documento desechable.** Es material de trabajo. Cuando P0, P1 y P2 estén cerrados,
> **este archivo se borra**: lo de §3 tiene que haber migrado a
> `prompts/convencion-de-git-y-tags.md`, y el resto a `prompts/formato-piezas-forenses.md`
> y `prompts/formato-cuaderno-incidentes.md`.""",
"""> ⚠️ **Documento desechable, pero todavía no.** Es material de trabajo. Se borra **cuando el
> checklist maestro de §14 esté entero en ✅**, no antes: lo de §3 ya migró a
> `prompts/convencion-de-git-y-tags.md` y lo de §8/P1 a los dos formatos, pero los prompts
> de costura y el informe de auditoría solo viven aquí.""")

# --- §6 inventario, con estado real ---
viejo_ini = s.index("## 6. 📦 Inventario de entregables")
viejo_fin = s.index("**Nombres:** se respeta la nomenclatura de Angular")
nuevo = """## 6. 📦 Inventario de entregables

Estado verificado contra el árbol el **2026-09-10**. ✅ = escrito · ⬜ = pendiente.

```
vue2-legacy-for-backend-devs/
├── README.md                               ✅ + sección 🕵️ track forense y cuadernos
├── prompts/
│   ├── convencion-de-git-y-tags.md         ✅ 423 líneas (+194)          · P0
│   ├── formato-piezas-forenses.md          ✅ 283 líneas · rige los DOS cursos
│   ├── formato-cuaderno-incidentes.md      ✅ 483 líneas · rige los DOS cursos
│   ├── guia-de-estilo-y-convenciones.md    ✅ §9.2, §13.2, §15 + nueva §16
│   └── plantilla-de-fase.md                ✅ sección 6 + bloque 📌 de reservas
│
├── 01-vue2-legacy/
│   ├── forense-master.md                   ✅ 193 líneas, con 🩺 índice de síntomas
│   ├── forense-fase-00 … -11.md            ✅ 12 piezas · 161–227 líneas
│   ├── forense-ruta-q / -vu / -nx.md       ✅ 3 piezas · ~205 líneas c/u      (D4)
│   ├── cuaderno-incidentes.md              ✅ 12 incidentes · 2.272 líneas    (D6)
│   ├── 03-mock-api-minima.md               ✅ + sección 🔥 inyector de caos   (D2)
│   ├── 27 fases (12 tronco + 15 ruta)      ✅ sección 6 + 🧨 + línea 📄; 📌 en el tronco
│   ├── 5 apéndices (a1–a5)                 ✅ intactos, por diseño (guía §9.1)
│   └── README.md                           ✅ + bloques 🕵️ y 📓
│
└── 02-complement-mongodb-backend/
    ├── forense-master.md                   ✅ 187 líneas, con 🩺 índice de síntomas
    ├── forense-fase-NN.md                  ✅ 12 piezas: F0,1,2,4,5,6,7,8,9,10,12,13 (D5)
    ├── cuaderno-incidentes.md              ✅ 12 incidentes · 2.262 líneas    (D6)
    ├── 16 fases                            ✅ 12 con línea 📄; F3/F11/F14/F15 declaran por qué no
    ├── 5 apéndices (a01–a05)               ✅ intactos, por diseño
    └── README.md                           ✅ + bloques 🕵️ y 📓

⬜ Lo único que falta en el árbol: NADA. Lo que falta es fuera del árbol —
   verificar las salidas corriendo el proyecto (§13.2) y commitear (§14).
```

"""
s = s[:viejo_ini] + nuevo + s[viejo_fin:]
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
sed -n '/^## 6/,/^## 7/p' contenido_forense.md | tail -12

# --- 2026-09-10T15:40:57 · Update execution plan table with status
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""⬜ Lo único que falta en el árbol: NADA. Lo que falta es fuera del árbol —
   verificar las salidas corriendo el proyecto (§13.2) y commitear (§14).""",
"""✅ El árbol está completo: no falta ningún archivo. Lo que falta es fuera de él
   — verificar las salidas corriendo el proyecto (§13.2) y commitear (§14).""")
s=s.replace("""Las piezas de ruta usan `forense-ruta-<código>.md`, que es
nuevo y hay que **declararlo en §13.2** de la guía (P2).""",
"""Las piezas de ruta usan `forense-ruta-<código>.md`, que era
nuevo y quedó **declarado en §13.2** de la guía (P2). ✅""")

# --- §7: columna de estado ---
s=s.replace("""| # | Paso | Entregable | Prompt | Commit |
|---|---|---|---|---|
| 0 | **La convención** | `prompts/convencion-de-git-y-tags.md` completado | **P0** | **propio y solo** |
| 1 | **Los formatos** | `formato-piezas-forenses.md` + `formato-cuaderno-incidentes.md` | **P1** | uno |
| 2 | **Los rectores** | Parches a `guia-de-estilo-y-convenciones.md` y `plantilla-de-fase.md` | **P2** | uno |
| 3 | **Las puertas** | Los dos `forense-master.md` | **P3** | uno por curso |
| 4 | **El caos** | Sección 🔥 en `03-mock-api-minima.md` | **P4** | uno |
| 5 | **Las piezas** | 15 + 12…16 `forense-*.md`, en tandas de 3–4 | **P5** | uno por tanda |
| 6 | **Los cuadernos** | 2 × `cuaderno-incidentes.md`, en tandas de 4 incidentes | **P6** · **P6-bis** | uno por tanda |
| 7 | **La costura** | Secciones 6 de las **43 fases** + los dos README | **P7-A** · **P7-B** | uno por curso |
| 8 | **La auditoría** | Verificación cruzada de enlaces, IDs y contrato | **P8** | — |""",
"""| # | Paso | Entregable | Prompt | Estado | Commit |
|---|---|---|---|---|---|
| 0 | **La convención** | `prompts/convencion-de-git-y-tags.md` completado | P0 | ✅ escrito | ⬜ **propio y solo** |
| 1 | **Los formatos** | `formato-piezas-forenses.md` + `formato-cuaderno-incidentes.md` | P1 | ✅ escrito | ⬜ uno |
| 2 | **Los rectores** | Parches a `guia-de-estilo-y-convenciones.md` y `plantilla-de-fase.md` | P2 | ✅ escrito | ⬜ uno |
| 3 | **Las puertas** | Los dos `forense-master.md` | P3 | ✅ escrito | ⬜ uno por curso |
| 4 | **El caos** | Sección 🔥 en `03-mock-api-minima.md` | P4 | ✅ escrito | ⬜ uno |
| 5 | **Las piezas** | 15 + 12 `forense-*.md` | P5 | ✅ escrito | ⬜ uno por tanda |
| 6 | **Los cuadernos** | 2 × `cuaderno-incidentes.md` | P6 · P6-bis | ✅ escrito | ⬜ uno por tanda |
| 7 | **La costura** | Secciones 6 de las **43 fases** + los tres README | P7-A · P7-B | ✅ escrito | ⬜ uno por curso |
| 8 | **La auditoría** | Verificación cruzada de enlaces, IDs y contrato | P8 | ✅ corrida (§13) | — |

> 🚦 **Escrito no es commiteado.** Las ocho filas están en ✅ de contenido y en ⬜ de git:
> el track completo sigue en el working tree. El checklist maestro de §14 lleva las dos
> columnas separadas justo por esto.""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
sed -n '/^## 7/,/^> 🧭 \*\*Por qué el Paso 0/p' contenido_forense.md | tail -18

# --- 2026-09-10T15:41:31 · Add master checklist section
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()

s=s.replace("## 12. ✅ Checklist — dónde estoy parado\n\nMarca aquí y no en la cabeza. Estado verificado contra el árbol el **2026-09-09**.",
"## 12. ✅ Checklist de ejecución — dónde estoy parado\n\nMarca aquí y no en la cabeza. Estado verificado contra el árbol el **2026-09-10**.\nEl resumen de una sola tabla, con sección y estado, está en **§14**.")

s=s.replace("""**Siguiente paso:** los ocho pasos están cerrados. Quedan dos cosas, y ninguna es escribir:
**verificar las salidas contra el proyecto corriendo** (§13.2) y **commitear** — el track
completo sigue sin entrar a git. Y una decisión de autor: la cuota de concurrencia del
Curso 02 (§13.1).""",
"""**Siguiente paso:** los ocho pasos están cerrados y no queda nada por escribir. Las tres
cosas vivas están en el checklist maestro de §14: **verificar las salidas contra el
proyecto corriendo** (§13.2), **commitear** el track entero, y **decidir la cuota de
concurrencia del Curso 02** (§13.1).""")

maestro = """
---

## 14. 🧾 Checklist maestro

Una fila por tarea, con la sección donde vive el detalle. **Cerrado** significa que no hay
nada más que hacer con eso; **abierto**, que sí.

### 14.1 Escribir — cerrado entero

| § | Tarea | Estado |
|---|---|---|
| §3 · §8/P0 | Completar `convencion-de-git-y-tags.md`: apéndices, forense, deuda, `db.json` | ✅ cerrado |
| §8/P1 | `formato-piezas-forenses.md` (283 líneas) | ✅ cerrado |
| §8/P1 | `formato-cuaderno-incidentes.md` (483 líneas) | ✅ cerrado |
| §8/P2 | Parchear `guia-de-estilo-y-convenciones.md` (§9.2, §13.2, §15, §16) | ✅ cerrado |
| §8/P2 | Parchear `plantilla-de-fase.md` (sección 6 + bloque 📌) | ✅ cerrado |
| §8/P3 | `forense-master.md` del Curso 01, con su 🩺 índice | ✅ cerrado |
| §8/P3 | `forense-master.md` del Curso 02, con su 🩺 índice | ✅ cerrado |
| §8/P4 | Inyector de caos en `03-mock-api-minima.md` (+190 líneas) | ✅ cerrado |
| §8/P5 | 12 piezas de tronco del Curso 01 | ✅ cerrado |
| §8/P5 | 3 piezas de ruta (🅠 🅥 🅝) | ✅ cerrado |
| §8/P5 | 12 piezas del Curso 02 (F3, F11, F14 y F15 sin pieza, por D5) | ✅ cerrado |
| §8/P6 | `cuaderno-incidentes.md` del Curso 01 · 12 incidentes + 🪞 + 📌 | ✅ cerrado |
| §8/P6 · P6-bis | `cuaderno-incidentes.md` del Curso 02 · 12 incidentes + 🪞 + 📌 | ✅ cerrado |
| §8/P7-A | Coser 27 fases del Curso 01 + su README | ✅ cerrado |
| §8/P7-B | Coser 16 fases del Curso 02 + su README | ✅ cerrado |
| §8/P7 | README de la raíz del paquete | ✅ cerrado |
| §8/P8 | Auditoría mecánica (enlaces, IDs, apéndices, tags, tuteo) | ✅ cerrado — §12.4 |
| §8/P8 | Auditoría de lectura y su informe | ✅ cerrado — §13 |

### 14.2 Lo que queda abierto

| # | § | Tarea | De quién | Estado |
|---|---|---|---|---|
| 1 | §13.2 | **Verificar las salidas literales** corriendo el proyecto: F3, F5, F8 y F10 del Curso 01; F5, F7 y F13 del Curso 02. Hasta que se haga, el track está *escrito pero no verificado*. | Autor, a mano | ⬜ abierto |
| 2 | §13.1 | **Decidir la cuota de concurrencia del Curso 02**: solo el incidente 06 la cubre y el formato pide dos. Recomendado: declarar la divergencia en `formato-cuaderno-incidentes.md` §4. | Decisión de autor | ⬜ abierto |
| 3 | §7 · §14.3 | **Commitear el track completo** — 52 archivos modificados y 34 nuevos, ninguno en git. Falta decidir `master` o rama. | Ejecución | ⬜ abierto |
| 4 | cabecera | **Borrar este documento** cuando 1, 2 y 3 estén cerrados. Antes no: los prompts de costura y el informe de §13 solo viven aquí. | Ejecución | ⬜ abierto |

### 14.3 Los commits que faltan, en orden

Ninguno está hecho. El orden lo fija §7 y el primero va **solo**:

| # | Commit | Alcance | Estado |
|---|---|---|---|
| 1 | `vue2: completa la convención de git y tags (apéndices, deuda, db.json, forense)` | `prompts/convencion-de-git-y-tags.md` y nada más | ⬜ |
| 2 | `vue2: formatos de piezas forenses y cuaderno de incidentes` | los dos `prompts/formato-*.md` | ⬜ |
| 3 | `vue2: guía de estilo y plantilla de fase con el track forense` | guía + plantilla | ⬜ |
| 4 | `vue2: las dos puertas del track forense` | los dos `forense-master.md` | ⬜ |
| 5 | `vue2: inyector de caos en la fase 3 del Curso 01` | `03-mock-api-minima.md` | ⬜ |
| 6 | `vue2: 29 piezas forenses (15 del Curso 01, 14 del Curso 02)` | todos los `forense-fase-*` y `forense-ruta-*` | ⬜ |
| 7 | `vue2: los dos cuadernos de incidentes (12 + 12)` | los dos `cuaderno-incidentes.md` | ⬜ |
| 8 | `vue2: cose el track a las 43 fases y a los tres README` | fases y README de los dos cursos + raíz | ⬜ |

> 📐 **La cuenta del commit 6:** 29 archivos `forense-*.md` en total, de los que 2 son los
> masters del commit 4. Ajusta el mensaje al armarlo si prefieres decir 27.
"""
s = s.rstrip("\n") + "\n" + maestro
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
grep -n "^## 1[0-4]\|^### 14" contenido_forense.md; wc -l contenido_forense.md

# --- 2026-09-10T15:41:38 · Count modified and new files
git status --short . | grep -c '^ M'; git status --short . | grep -c '^??'

# --- 2026-09-10T15:41:47 · Fix counts in master checklist
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("| 6 | `vue2: 29 piezas forenses (15 del Curso 01, 14 del Curso 02)` | todos los `forense-fase-*` y `forense-ruta-*` | ⬜ |",
            "| 6 | `vue2: 27 piezas forenses (15 del Curso 01, 12 del Curso 02)` | todos los `forense-fase-*` y `forense-ruta-*` | ⬜ |")
s=s.replace("""> 📐 **La cuenta del commit 6:** 29 archivos `forense-*.md` en total, de los que 2 son los
> masters del commit 4. Ajusta el mensaje al armarlo si prefieres decir 27.""",
"""> 📐 **La cuenta:** 29 archivos `forense-*.md` en el árbol; 2 son los masters y viajan en el
> commit 4, así que al commit 6 le quedan 27 — 15 del Curso 01 (12 de fase + 3 de ruta) y
> 12 del Curso 02.""")
s=s.replace("| 3 | §7 · §14.3 | **Commitear el track completo** — 52 archivos modificados y 34 nuevos, ninguno en git.",
            "| 3 | §7 · §14.3 | **Commitear el track completo** — 49 archivos modificados y 34 nuevos, ninguno en git.")
s=s.replace("""- ⬜ **Commitear.** Nada del track ha entrado a git todavía: 52 archivos modificados y 34
  nuevos, todos dentro de `vue2-legacy-for-backend-devs/`.""",
"""- ⬜ **Commitear.** Nada del track ha entrado a git todavía: 49 archivos modificados y 34
  nuevos, todos dentro de `vue2-legacy-for-backend-devs/`.""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
sed -n '/^## 14/,$p' contenido_forense.md | head -30

# --- 2026-09-10T15:41:54 · Read status section
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()
i=s.index("## 11. 🚦 Estado y siguiente paso")
j=s.index("## 12. ✅ Checklist de ejecución")
print(s[i:j])
PY

# --- 2026-09-10T15:42:18 · Update status and risks sections
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""**Lo ejecutado, a 2026-09-09:** los ocho pasos completos. En el árbol hay 29
archivos forenses nuevos, dos cuadernos (12 + 11 incidentes), los dos formatos, y cuatro
archivos rectores modificados. **Nada de esto está commiteado todavía.**""",
"""**Lo ejecutado, a 2026-09-10:** los ocho pasos completos. En el árbol hay **29 archivos
forenses** nuevos, **dos cuadernos de 12 incidentes cada uno**, los dos formatos, cuatro
archivos rectores parcheados, **43 fases cosidas** y **tres README** con sus bloques 🕵️ y
📓. **Nada de esto está commiteado todavía.**""")
s=s.replace("""cosas vivas están en el checklist maestro de §14: **verificar las salidas contra el
proyecto corriendo** (§13.2), **commitear** el track entero, y **decidir la cuota de
concurrencia del Curso 02** (§13.1). Los cuatro prompts están cerrados en
§8: traen las listas de archivos y las tablas de reservas dentro, así que se pegan tal cual.""",
"""cosas vivas están en el checklist maestro de §14: **verificar las salidas contra el
proyecto corriendo** (§13.2), **commitear** el track entero (§14.3 trae los ocho commits en
orden), y **decidir la cuota de concurrencia del Curso 02** (§13.1).""")
s=s.replace("""> 🪦 **Recordatorio, corregido.** El encabezado dice que este archivo se borra cuando P0, P1
> y P2 estén cerrados. Ya lo están — y borrarlo hoy tiraría P6-bis, P7-A, P7-B y P8, que
> viven aquí y no en ningún otro sitio. **La condición real de borrado es que P8 pase.** Lo
> de §3 ya migró a `prompts/convencion-de-git-y-tags.md` y lo de §8/P1 a los dos formatos;
> lo único que quedará sin hogar el día del borrado son los prompts de costura, y para
> entonces la costura ya estará hecha.""",
"""> 🪦 **Recordatorio, corregido dos veces.** El encabezado decía que este archivo se borra
> cuando P0, P1 y P2 estén cerrados; después se corrigió a "cuando P8 pase". P8 ya pasó, y
> aun así **no se borra todavía**: el informe de auditoría (§13) tiene un hallazgo abierto y
> los commits no están hechos. **La condición definitiva es §14 entero en ✅.** Lo de §3 ya
> migró a `prompts/convencion-de-git-y-tags.md` y lo de §8/P1 a los dos formatos; lo único
> que quedará sin hogar el día del borrado son los prompts de costura —y para entonces la
> costura llevará meses hecha.""")

# §10: cierre con lo que pasó de verdad
s=s.replace("""| **Tocar `03-mock-api-minima.md`**, que está publicada. | La edición es estrictamente aditiva: sección nueva + ejercicios 🔥 al final. Ninguna línea existente cambia, ningún ejercicio se renumera. |""",
"""| **Tocar `03-mock-api-minima.md`**, que está publicada. | La edición es estrictamente aditiva: sección nueva + ejercicios 🔥 al final. Ninguna línea existente cambia, ningún ejercicio se renumera. |

**Cómo salieron, al cerrar (2026-09-10):**

| Riesgo | Resultado |
|---|---|
| Salidas inventadas | ⬜ **Sigue vivo.** Es la tarea 1 de §14.2: nadie ha corrido el proyecto contra las piezas. |
| La pieza se vuelve resumen de la fase | ✅ Contenido. Solo pasó al revés —F13 traía la pieza entera en su sección 6— y se comprimió (§13.1). |
| Se rompe la independencia entre cursos | ✅ Auditado. Una mención cruzada de una línea, sin dependencia (§13.1). |
| IDs descoordinados | ✅ Cruzados en los dos sentidos, sin huérfanos. El único error real —el incidente 04 en la fase equivocada— se detectó y corrigió al coser. |
| Se rompe el contrato | ✅ Eventos y enums verificados contra `00-audit-contrato.md`. |
| Deriva de tono | ✅ Pasada de voseo en verde sobre todos los archivos nuevos. |
| P0 y P2 sobre el mismo archivo | ✅ El orden se respetó: P0 primero, P2 después. |
| Tocar `03-mock-api-minima.md` | ✅ Aditivo: +190 líneas, ningún ejercicio renumerado. |""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
grep -c "" contenido_forense.md

# --- 2026-09-10T15:42:23 · Verify document outline and pending markers
grep -nE '^#{2,3} ' contenido_forense.md | sed -n '1,10p;28,60p'; echo "=== pendientes ⬜ en el doc ==="; grep -c '⬜' contenido_forense.md

# --- 2026-09-10T15:42:29 · Read section 1.2
sed -n '37,60p' contenido_forense.md

# --- 2026-09-10T15:42:36 · Annotate historical snapshot and print master checklist
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""### 1.2 El aparato forense del paquete Vue 2

| | Curso 01 · Vue 2 | Curso 02 · Mongo/Express |""",
"""### 1.2 El aparato forense del paquete Vue 2

> 📸 **Foto del 2026-09-08, antes de ejecutar nada.** Se conserva tal cual porque es la
> evidencia que justificó el plan; **hoy todas esas casillas están en ✅** — el inventario
> con el estado real está en §6 y el checklist maestro en §14. Un detalle de esta tabla
> resultó importante al coser: las cuatro fases del Curso 02 que ya traían pieza en línea
> son las que en P7-B hubo que tratar aparte (§13.1).

| | Curso 01 · Vue 2 | Curso 02 · Mongo/Express |""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
sed -n '/^### 14.2/,$p' contenido_forense.md

# --- 2026-09-10T15:58:35 · Read minimum quota section
sed -n '/^### Cuotas mínimas/,/^### Categorías/p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-10T15:58:43 · Check soporte_v1 coverage in course 02 incidents
python3 - <<'PY'
import io,re
s=io.open('02-complement-mongodb-backend/cuaderno-incidentes.md',encoding='utf-8').read()
partes=re.split(r'^## Incidente (\d\d)', s, flags=re.M)
for i in range(1,len(partes),2):
    n=partes[i]; t=partes[i+1]
    h=len(re.findall(r'soporte_v1', t))
    if h: print("inc",n,"->",h,"menciones de soporte_v1")
PY

# --- 2026-09-10T15:58:49 · Read incident 05 root cause
sed -n '/^## Incidente 05/,/^## Incidente 06/p' 02-complement-mongodb-backend/cuaderno-incidentes.md | grep -A10 "Causa raíz" | head -16

# --- 2026-09-10T15:59:20 · Declare the quota divergence in the format spec
python3 - <<'PY'
import io
p='prompts/formato-cuaderno-incidentes.md'; s=io.open(p,encoding='utf-8').read()
viejo = """Si al escribir un incidente resulta que no tiene una causa raíz propia —que es la única
razón válida para que un incidente exista—, **no se fuerza**: se retira, se documenta por
qué en 📌 Pendientes, y su ID **no se reasigna**.
"""
nuevo = """Si al escribir un incidente resulta que no tiene una causa raíz propia —que es la única
razón válida para que un incidente exista—, **no se fuerza**: se retira, se documenta por
qué en 📌 Pendientes, y su ID **no se reasigna**.

**Las cuotas se cuentan por causa raíz, no por etiqueta.** La categoría del índice nombra
el **síntoma**, porque es por donde el estudiante entra a buscar; la cuota mide de qué va
el incidente por dentro. Dos ejemplos reales de este paquete, para que nadie los "corrija"
más adelante:

- El incidente 12 del Curso 01 está etiquetado **Build** —"en el servidor de pruebas se
  comporta distinto que en mi máquina"— y su causa raíz vive en `store/index.js`: el
  `strict` del store que solo corre en desarrollo. **Cuenta para la cuota de Vuex**, y su
  etiqueta se queda como está.
- El incidente 05 del Curso 02 está etiquetado **Modelado** y es el anti-patrón
  `soporte_v1` en estado puro, aunque solo el 08 lo llame por su nombre. **Cuenta para esa
  cuota.**

> ⚖️ **Divergencia declarada — la cuota de concurrencia del Curso 02.** La regla de arriba
> pide **2 de atomicidad o concurrencia** y el cuaderno del Curso 02 entrega **1**: el
> incidente 06, el doble "tomar". Se declara aquí en vez de cumplirse, y el motivo es el
> propio material: **este curso concentra la concurrencia en la Fase 6 por diseño**, y
> ninguna otra fase produce una segunda causa raíz de carrera que sea suya. Las candidatas
> se revisaron una por una y todas fallaban por lo mismo — el índice que `explain()` ignora
> (F7) es de plan de consulta, la migración (F8) es de verificación, el CI (F13) es de
> configuración invisible—: convertir cualquiera de ellas en un caso de concurrencia
> exigiría **inventarle** una carrera al sistema, que es exactamente lo que el párrafo
> anterior prohíbe. Entre una cuota cumplida con un incidente forzado y una cuota declarada
> con su motivo, este paquete elige lo segundo.
>
> Lo que la cuota quería garantizar —que el estudiante salga sabiendo diagnosticar una
> carrera— **sí se cumple**, y por tres vías fuera del cuaderno: la
> [pieza forense de la Fase 6](../02-complement-mongodb-backend/forense-fase-06.md), que
> recorre la reproducción con dos sesiones de `mongosh`; el **duelo de 20 rondas** de la
> Fase 13, que la convierte en un test que se repite; y el `409` de punta a punta del
> ejercicio 22 de esa misma fase. La cuota se escribió antes que el material y midió el
> sitio equivocado.
>
> **Alcance:** esta divergencia vale solo para la cuota de concurrencia del Curso 02. Las
> otras cinco —las tres del Curso 01 y las dos restantes del 02— se cumplen y siguen siendo
> obligatorias.
"""
assert viejo in s
s=s.replace(viejo,nuevo)
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
sed -n '/^### Cuotas mínimas/,/^### Categorías/p' prompts/formato-cuaderno-incidentes.md | tail -20

# --- 2026-09-10T15:59:57 · Close the quota finding in the plan document
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()

s=s.replace("""| `02-…/cuaderno-incidentes.md` | **La cuota «2 de atomicidad o concurrencia» no se cumple:** solo el incidente 06 la cubre. Ninguno de los otros once toca una carrera (verificado por búsqueda de causa raíz, no por etiqueta). | **Media** | Tres salidas, y es decisión de autor: (a) reescribir el incidente 07 —el índice que `explain()` ignora— para que la lentitud venga de una escritura concurrente; (b) declarar la divergencia en `formato-cuaderno-incidentes.md` §4 con su motivo; (c) un incidente 13, que rompe los cuatro tramos de tres. **Recomendada: (b)** — la cuota se escribió antes que el material, y el Curso 02 concentra su concurrencia en la Fase 6 por diseño. |""",
"""| `02-…/cuaderno-incidentes.md` | **La cuota «2 de atomicidad o concurrencia» no se cumplía:** solo el incidente 06 la cubre. Ninguno de los otros once toca una carrera (verificado por causa raíz, no por etiqueta). | Media | **Resuelto el 2026-09-10** por la vía (b): divergencia declarada en `formato-cuaderno-incidentes.md` §4, con su motivo, sus candidatas descartadas una por una, y las tres vías fuera del cuaderno por las que el objetivo de la cuota **sí** se cumple (la pieza de la F6, el duelo de 20 rondas de la F13 y el 409 de punta a punta del ejercicio 22). Se descartaron (a) reescribir el incidente 07 y (c) un incidente 13: la primera le inventa una carrera al sistema —lo único que el formato prohíbe— y la segunda rompe los cuatro tramos de tres. |""")

s=s.replace("""| `01-…/cuaderno-incidentes.md` | **La cuota «2 de Vuex» se cumple en sustancia y no en la etiqueta:** el incidente 10 está etiquetado Estado (Vuex) y el 12 está etiquetado Build, pero su causa raíz vive en `store/index.js` (el `strict` que solo corre en desarrollo). | **Baja** | Ninguno. La etiqueta describe el **síntoma** —que es de build— y así debe seguir: el estudiante busca por lo que ve, no por lo que resultó ser. Queda anotado aquí para que P8 no lo vuelva a levantar. |""",
"""| `01-…/cuaderno-incidentes.md` | **La cuota «2 de Vuex» se cumple en sustancia y no en la etiqueta:** el incidente 10 está etiquetado Estado (Vuex) y el 12 está etiquetado Build, pero su causa raíz vive en `store/index.js` (el `strict` que solo corre en desarrollo). Lo mismo pasa en el Curso 02 con `soporte_v1`: el 08 lo nombra y el 05 lo es. | Baja | **Resuelto el 2026-09-10.** Las etiquetas se quedan como están —nombran el síntoma, que es por donde el estudiante busca— y el formato ahora dice explícitamente que **las cuotas se cuentan por causa raíz, no por etiqueta**, con estos dos casos escritos con nombre para que nadie los "corrija" dentro de un año. |""")

s=s.replace("""De los seis hallazgos, cuatro quedaron resueltos en la misma pasada, uno es una nota para
el futuro y **uno pide una decisión de autor** — la cuota de concurrencia del Curso 02.

Lo que falta ya no es escribir: es **verificar contra el proyecto** y **commitear**.""",
"""De los seis hallazgos, **cinco quedaron resueltos en la misma pasada** y el sexto —la cuota
de concurrencia del Curso 02, el único que pedía decisión de autor— se cerró el 2026-09-10
declarando la divergencia en el formato, que es donde una regla que ya no aplica tiene que
decir por qué.

Lo que falta ya no es escribir ni decidir: es **verificar contra el proyecto** y
**commitear**.""")

s=s.replace("""| §8/P8 | Auditoría de lectura y su informe | ✅ cerrado — §13 |""",
"""| §8/P8 | Auditoría de lectura y su informe | ✅ cerrado — §13 |
| §13.1 | Cerrar el hallazgo de la cuota de concurrencia: divergencia declarada en `formato-cuaderno-incidentes.md` §4 | ✅ cerrado |""")

s=s.replace("""| 2 | §13.1 | **Decidir la cuota de concurrencia del Curso 02**: solo el incidente 06 la cubre y el formato pide dos. Recomendado: declarar la divergencia en `formato-cuaderno-incidentes.md` §4. | Decisión de autor | ⬜ abierto |
| 3 | §7 · §14.3 | **Commitear el track completo** — 49 archivos modificados y 34 nuevos, ninguno en git. Falta decidir `master` o rama. | Ejecución | ⬜ abierto |
| 4 | cabecera | **Borrar este documento** cuando 1, 2 y 3 estén cerrados. Antes no: los prompts de costura y el informe de §13 solo viven aquí. | Ejecución | ⬜ abierto |""",
"""| ~~2~~ | §13.1 | ~~Decidir la cuota de concurrencia del Curso 02~~ | Decisión de autor | ✅ **cerrado el 2026-09-10** — divergencia declarada en el formato |
| 2 | §7 · §14.3 | **Commitear el track completo** — 50 archivos modificados y 34 nuevos, ninguno en git. Falta decidir `master` o rama. | Ejecución | ⬜ abierto |
| 3 | cabecera | **Borrar este documento** cuando 1 y 2 estén cerrados. Antes no: los prompts de costura y el informe de §13 solo viven aquí. | Ejecución | ⬜ abierto |""")

s=s.replace("""- ⬜ **Decidir la cuota de concurrencia del Curso 02** (§13.1). Es el único hallazgo abierto
  de la auditoría y es decisión de autor, no de ejecución.""",
"""- ✅ **La cuota de concurrencia del Curso 02** (§13.1), cerrada el 2026-09-10: divergencia
  declarada en `formato-cuaderno-incidentes.md` §4, con su motivo y las candidatas
  descartadas. Era el único hallazgo abierto de la auditoría.""")

s=s.replace("""cosas vivas están en el checklist maestro de §14: **verificar las salidas contra el
proyecto corriendo** (§13.2), **commitear** el track entero (§14.3 trae los ocho commits en
orden), y **decidir la cuota de concurrencia del Curso 02** (§13.1).""",
"""dos cosas vivas están en el checklist maestro de §14: **verificar las salidas contra el
proyecto corriendo** (§13.2) y **commitear** el track entero (§14.3 trae los ocho commits
en orden). La tercera —la cuota de concurrencia del Curso 02— se cerró el 2026-09-10.""")

s=s.replace("| 3 | `vue2: guía de estilo y plantilla de fase con el track forense` | guía + plantilla | ⬜ |",
            "| 3 | `vue2: guía de estilo y plantilla de fase con el track forense` | guía + plantilla | ⬜ |")
s=s.replace("| 2 | `vue2: formatos de piezas forenses y cuaderno de incidentes` | los dos `prompts/formato-*.md` | ⬜ |",
            "| 2 | `vue2: formatos de piezas forenses y cuaderno de incidentes` | los dos `prompts/formato-*.md`, con la divergencia de la cuota de concurrencia declarada | ⬜ |")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
sed -n '/^### 14.2/,/^### 14.3/p' contenido_forense.md

# --- 2026-09-10T16:00:10 · Clean up open-items table and verify counts
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""| 1 | §13.2 | **Verificar las salidas literales** corriendo el proyecto: F3, F5, F8 y F10 del Curso 01; F5, F7 y F13 del Curso 02. Hasta que se haga, el track está *escrito pero no verificado*. | Autor, a mano | ⬜ abierto |
| ~~2~~ | §13.1 | ~~Decidir la cuota de concurrencia del Curso 02~~ | Decisión de autor | ✅ **cerrado el 2026-09-10** — divergencia declarada en el formato |
| 2 | §7 · §14.3 | **Commitear el track completo** — 50 archivos modificados y 34 nuevos, ninguno en git. Falta decidir `master` o rama. | Ejecución | ⬜ abierto |
| 3 | cabecera | **Borrar este documento** cuando 1 y 2 estén cerrados. Antes no: los prompts de costura y el informe de §13 solo viven aquí. | Ejecución | ⬜ abierto |""",
"""| 1 | §13.2 | **Verificar las salidas literales** corriendo el proyecto: F3, F5, F8 y F10 del Curso 01; F5, F7 y F13 del Curso 02. Hasta que se haga, el track está *escrito pero no verificado*. | Autor, a mano | ⬜ abierto |
| 2 | §7 · §14.3 | **Commitear el track completo** — 50 archivos modificados y 34 nuevos, ninguno en git. Falta decidir `master` o rama. | Ejecución | ⬜ abierto |
| 3 | cabecera | **Borrar este documento** cuando 1 y 2 estén cerrados. Antes no: los prompts de costura y el informe de §13 solo viven aquí. | Ejecución | ⬜ abierto |
| — | §13.1 | Decidir la cuota de concurrencia del Curso 02 | Decisión de autor | ✅ **cerrado el 2026-09-10**: divergencia declarada en `formato-cuaderno-incidentes.md` §4 |""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
git status --short . | grep -c '^ M'; grep -c '⬜' contenido_forense.md

# --- 2026-09-10T16:00:15 · Correct file count in checklist
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("**Commitear el track completo** — 50 archivos modificados y 34 nuevos",
            "**Commitear el track completo** — 49 archivos modificados y 34 nuevos")
io.open(p,'w',encoding='utf-8').write(s)
PY
grep -rn "50 archivos\|52 archivos" contenido_forense.md | head

# --- 2026-09-10T16:04:25 · Check course structure docs for forensic mentions
cd 01-vue2-legacy && grep -ni "forense\|incidente" 0-ESTRUCTURA-CURSO.md 0-plan-del-curso.md | head -20; echo "--- secciones de la plantilla en 0-ESTRUCTURA ---"; grep -n "Errores comunes\|nueve secciones\|9 secciones" 0-ESTRUCTURA-CURSO.md 0-plan-del-curso.md | head

# --- 2026-09-10T16:04:32 · Read plan template section and structure doc outline
sed -n '265,300p' 0-plan-del-curso.md; echo "=== estructura: encabezados ==="; grep -nE '^#{2,3} ' 0-ESTRUCTURA-CURSO.md | head -25

# --- 2026-09-10T16:04:39 · Read file convention and status sections
sed -n '233,300p' 0-ESTRUCTURA-CURSO.md

# --- 2026-09-10T16:04:48 · Outline plan doc and README master table
grep -nE '^#{2,3} ' 0-plan-del-curso.md | head -25; echo "=== README docs maestros ==="; sed -n '/^## 🧭 Documentos maestros/,/^---/p' README.md | head -14

# --- 2026-09-10T16:05:08 · Update course plan document
python3 - <<'PY'
import io
# ---------- 0-plan-del-curso.md ----------
p='0-plan-del-curso.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""6. ⚠️ Errores comunes
7. 🧪 Ejercicios (20–30, de fácil a muy difícil)
8. 📚 Referencias (oficiales primero)
9. 🚀 Cierre""",
"""6. ⚠️ Errores comunes **y pieza forense**
7. 🧪 Ejercicios (20–30, de fácil a muy difícil)
8. 📚 Referencias (oficiales primero)
9. 🚀 Cierre

Dos bloques de servicio acompañan a la plantilla desde que existe el track
forense, y conviene saber qué son antes de tropezarte con ellos:

- **Dentro del punto 6**, cada fase trae el resumen de su pieza forense, un
  bloque 🧨 **"Rompe a propósito"** para provocar el fallo en tu máquina, y una
  línea 📄 hacia el recorrido completo (`forense-fase-NN.md`, o
  `forense-ruta-q/-vu/-nx.md` si estás en una ruta).
- **Después del cierre**, un bloque 📌 **"Reservas para el cuaderno de
  incidentes"** con los IDs que esa fase aporta al `cuaderno-incidentes.md`. No
  es narrativa: es un bloque de servicio para que los IDs cuadren. Las fases de
  ruta no reservan incidentes, y los apéndices no llevan ninguno de los dos
  bloques.""")

s=s.replace("""## 🧭 Convenciones del curso""",
"""## 🕵️ El track forense y el cuaderno de incidentes

Además de las fases, el curso trae un aparato para lo que de verdad haces en un
sistema heredado: **investigar**. Se usa fuera de orden y se entra por el
síntoma, no por la fase.

- **[`forense-master.md`](forense-master.md)** — la puerta. El método de cuatro
  preguntas y el 🩺 índice de síntomas, que es lo que se consulta de verdad:
  nadie llega sabiendo de qué fase es su problema.
- **`forense-fase-00.md` … `forense-fase-11.md`** — un recorrido por fase, paso a
  paso, con la salida literal de cada uno y qué descarta. Más **una pieza por
  ruta** (`forense-ruta-q.md`, `-vu.md`, `-nx.md`), que cubre sus cinco fases:
  como las rutas son excluyentes, solo vas a abrir una.
- **[`cuaderno-incidentes.md`](cuaderno-incidentes.md)** — 12 incidentes con el
  ticket como llegó, la preparación para tener el sistema roto, tres pistas
  plegadas, sitio para tu investigación y la solución de referencia.

> 🧭 **La regla del cuaderno, que es media lección:** la solución viene incluida,
> y abrirla antes de escribir la tuya no te ahorra tiempo — te ahorra el
> ejercicio.

---

## 🧭 Convenciones del curso""")
io.open(p,'w',encoding='utf-8').write(s); print("ok", p)
PY

# --- 2026-09-10T16:05:27 · Update course structure document
python3 - <<'PY'
import io
p='0-ESTRUCTURA-CURSO.md'; s=io.open(p,encoding='utf-8').read()

s=s.replace("""nx4-pagina-ssr-nueva.md
```""",
"""nx4-pagina-ssr-nueva.md

# Track forense (uno por fase, y uno por ruta)
forense-master.md
forense-fase-00.md  …  forense-fase-11.md
forense-ruta-q.md · forense-ruta-vu.md · forense-ruta-nx.md

# Cuaderno de incidentes (uno por curso, IDs propios)
cuaderno-incidentes.md
```

> 📐 **Los nombres del track no son libres.** Se comparten con los cursos de
> Angular del repositorio para que los tres paquetes se lean igual:
> `forense-master.md`, `forense-fase-NN.md` y `cuaderno-incidentes.md`. Lo único
> propio de este curso es `forense-ruta-<código>.md`, que nace de que las rutas
> son excluyentes y cinco fases comparten una sola pieza.""")

s=s.replace("""6. **Tono**: informal, directo, sin condescendencia. Audiencia senior.
7. **Código de época.** Versiones exactas, sin features modernas.""",
"""6. **Tono**: informal, directo, sin condescendencia. Audiencia senior.
7. **Código de época.** Versiones exactas, sin features modernas.
8. **Pieza forense en el punto 6**: resumen, bloque 🧨 "Rompe a propósito" y la
   línea 📄 hacia `forense-ruta-q.md` / `-vu.md` / `-nx.md` — la de **su** ruta,
   que es una sola para las cinco fases. Las fases de ruta **no** reservan
   incidentes: el cuaderno no tiene ni una fila de ruta, porque un incidente de
   ruta sería material que dos tercios de los lectores no pueden preparar.""")

s=s.replace("""- [x] `11-testing-minimo.md` — el cierre ya bifurca ("Aquí el curso se bifurca")
      y puentea hacia X0""",
"""- [x] `11-testing-minimo.md` — el cierre ya bifurca ("Aquí el curso se bifurca")
      y puentea hacia X0

Y al cerrar el **track forense** había que volver a tocar el tronco. También está
hecho:

- [x] Las **27 fases** (12 de tronco + 15 de ruta) — punto 6 con su pieza, y
      bloque 📌 de reservas en las de tronco
- [x] `README.md` — bloques "🕵️ Track forense" y "📓 Cuaderno de incidentes"
- [x] `0-plan-del-curso.md` — plantilla de capítulo actualizada y sección propia
      del track
- [x] Los **5 apéndices** — sin tocar, y es la decisión: explican lo que ya está
      ahí, no producen código de fase (guía §9.1)""")

s=s.replace("""| `0-ESTRUCTURA-CURSO.md` | ✅ este documento |
| `README.md` (índice del curso, con las tres rutas) | ✅ terminado |""",
"""| `0-ESTRUCTURA-CURSO.md` | ✅ este documento |
| `README.md` (índice del curso, con las tres rutas) | ✅ terminado |
| `forense-master.md` + 12 piezas de fase + 3 de ruta | ✅ terminado |
| `cuaderno-incidentes.md` (12 incidentes) | ✅ terminado |""")
io.open(p,'w',encoding='utf-8').write(s); print("ok",p)
PY
grep -n "forense\|cuaderno" 0-ESTRUCTURA-CURSO.md | head

# --- 2026-09-10T16:05:36 · Add track rows to course 01 README and check course 02
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""| [`../prompts/guia-de-estilo-y-convenciones.md`](../prompts/guia-de-estilo-y-convenciones.md) | ✍️ Guía editorial compartida con el Curso 02 |""",
"""| [`../prompts/guia-de-estilo-y-convenciones.md`](../prompts/guia-de-estilo-y-convenciones.md) | ✍️ Guía editorial compartida con el Curso 02 |
| [`forense-master.md`](forense-master.md) | 🕵️ **La puerta del track forense**: el método de cuatro preguntas y el 🩺 índice de síntomas. Se entra por lo que ves, no por la fase |
| [`cuaderno-incidentes.md`](cuaderno-incidentes.md) | 📓 **12 incidentes** con el ticket como llegó, pistas plegadas y solución de referencia |""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
cd ../02-complement-mongodb-backend && sed -n '/^## 🧭 Documentos maestros/,/^---/p' README.md | head -12

# --- 2026-09-10T16:05:45 · Add rows to course 02 README and list prompt dirs
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""| [`../prompts/guia-de-estilo-y-convenciones.md`](../prompts/guia-de-estilo-y-convenciones.md) | ✍️ Guía editorial compartida con el Curso 01 |""",
"""| [`../prompts/guia-de-estilo-y-convenciones.md`](../prompts/guia-de-estilo-y-convenciones.md) | ✍️ Guía editorial compartida con el Curso 01 |
| [`forense-master.md`](forense-master.md) | 🕵️ **La puerta del track forense**: el método de cuatro preguntas y el 🩺 índice de síntomas. Se entra por lo que ves, no por la fase |
| [`cuaderno-incidentes.md`](cuaderno-incidentes.md) | 📓 **12 incidentes** con el ticket como llegó, pistas plegadas y solución de referencia |""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
cd .. && grep -rn "instrucciones-proyecto-track-b" 02-complement-mongodb-backend/prompts/ 2>/dev/null | head -2; ls 02-complement-mongodb-backend/prompts/ 01-vue2-legacy/prompts/

# --- 2026-09-10T16:05:56 · Inspect course 02 prompt duplicates
cd 02-complement-mongodb-backend/prompts && wc -l *.md && diff -q "guia-de-estilo-y-convenciones.md" ../../prompts/guia-de-estilo-y-convenciones.md && echo "IGUAL al de la raíz" || echo "DISTINTO al de la raíz"; grep -ni "forense\|incidente\|realidad en disco" instrucciones-proyecto-track-b.md | head -5

# --- 2026-09-10T16:06:03 · Recheck links and inspect duplicate style guide
cd ../.. && python3 - <<'PY'
import io,os,re,glob
bad=[]
for f in glob.glob('01-vue2-legacy/*.md')+glob.glob('02-complement-mongodb-backend/*.md')+glob.glob('prompts/*.md')+['README.md']:
    d=os.path.dirname(f); s=io.open(f,encoding='utf-8').read()
    for m in re.finditer(r'\]\(([^)#]+\.md)(#[^)]*)?\)', s):
        t=m.group(1)
        if t.startswith('http'): continue
        if not os.path.exists(os.path.normpath(os.path.join(d,t))): bad.append((f,t))
print("enlaces rotos:",len(bad), bad[:5])
PY
head -3 02-complement-mongodb-backend/prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-10T16:06:36 · Record reconciliation and leftovers in master checklist
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()

s=s.replace("""| §13.1 | Cerrar el hallazgo de la cuota de concurrencia: divergencia declarada en `formato-cuaderno-incidentes.md` §4 | ✅ cerrado |""",
"""| §13.1 | Cerrar el hallazgo de la cuota de concurrencia: divergencia declarada en `formato-cuaderno-incidentes.md` §4 | ✅ cerrado |
| §14.4 | Reconciliar los rectores del Curso 01 (`0-plan-del-curso.md` y `0-ESTRUCTURA-CURSO.md`) con el track, y añadir el track a los «Documentos maestros» de los dos README de curso | ✅ cerrado |""")

s=s.replace("""| 1 | §13.2 | **Verificar las salidas literales** corriendo el proyecto: F3, F5, F8 y F10 del Curso 01; F5, F7 y F13 del Curso 02. Hasta que se haga, el track está *escrito pero no verificado*. | Autor, a mano | ⬜ abierto |
| 2 | §7 · §14.3 | **Commitear el track completo** — 49 archivos modificados y 34 nuevos, ninguno en git. Falta decidir `master` o rama. | Ejecución | ⬜ abierto |
| 3 | cabecera | **Borrar este documento** cuando 1 y 2 estén cerrados. Antes no: los prompts de costura y el informe de §13 solo viven aquí. | Ejecución | ⬜ abierto |""",
"""| 1 | §13.2 | **Verificar las salidas literales** corriendo el proyecto: F3, F5, F8 y F10 del Curso 01; F5, F7 y F13 del Curso 02. | Autor, **a medida que avance el curso y se hagan los casos prácticos** | 🔵 en curso, sin fecha |
| 2 | §7 · §14.3 | **Commitear el track completo** — 49 archivos modificados y 34 nuevos. | **El autor, a mano** | 🔵 asumido fuera de este documento |
| 3 | §14.5 | **Dos herencias del Curso 02 que este track no tocó** y conviene decidir: la segunda guía de estilo y los tres archivos ` copy.md`. | Decisión de autor | ⬜ abierto |
| 4 | cabecera | **Borrar este documento** cuando 2 esté hecho. La verificación (1) **no es condición**: es un proceso largo, y lo que hay que verificar está listado en §13.2, que se puede mover a un `TODO` de una línea el día del borrado. | Ejecución | ⬜ abierto |""")

s=s.rstrip("\n") + """

---

### 14.4 La reconciliación de los rectores (cerrada el 2026-09-10)

P7 cosió las 43 fases y los tres README, pero **se dejó los documentos rectores del Curso
01**, que son los que declaran la estructura. El propio README del curso avisa de que "si
algo del `0-ESTRUCTURA-CURSO.md` contradice a este índice o al plan, hay que
reconciliarlo", así que era una contradicción declarada, no una omisión menor.

| Archivo | Qué estaba desactualizado | Arreglo |
|---|---|---|
| `01-…/0-plan-del-curso.md` | La plantilla de capítulo llamaba al punto 6 «⚠️ Errores comunes», sin la pieza ni el bloque 📌. Y el track no aparecía en ninguna parte. | Punto 6 renombrado, los dos bloques de servicio explicados, y sección propia «🕵️ El track forense y el cuaderno de incidentes» |
| `01-…/0-ESTRUCTURA-CURSO.md` | La «Convención de archivos» no listaba ningún `forense-*.md` ni el cuaderno; las «Reglas que toda fase de ruta debe cumplir» eran siete; el «Estado» y la «Deuda del propio curso» no mencionaban el track. | Bloque de archivos del track con su nota de nomenclatura, **regla 8** (línea 📄 a la pieza de su ruta, y las fases de ruta no reservan incidentes), y dos filas nuevas en Estado |
| Los dos `README.md` de curso | El track estaba en su propia sección pero no en la tabla de «Documentos maestros», que es por donde se entra. | Dos filas en cada uno: `forense-master.md` y `cuaderno-incidentes.md` |

El Curso 02 no necesitó nada equivalente: no tiene documentos rectores propios — su
`00-audit-contrato.md` es el contrato, no la estructura, y no le afecta el track.

### 14.5 Dos herencias del Curso 02 que este track no tocó

Ninguna la produjo el track forense; las dos aparecieron al auditar y se dejan escritas
para que no se pierdan. **Ninguna bloquea nada.**

| Qué | Por qué importa | Sugerencia |
|---|---|---|
| `02-…/prompts/guia-de-estilo-y-convenciones.md` (461 líneas) **coexiste** con la guía del paquete (1.024 líneas), que el README de la raíz declara «fuente de verdad editorial de los dos cursos». | Dos guías para el mismo curso es exactamente el problema que el orden de autoridad del `CLAUDE.md` del repositorio quiere evitar: si divergen, nadie sabe cuál gana. | Borrar la del curso, o dejar una de tres líneas que diga «la guía es la del paquete» y liste **solo** lo que este curso diverge. |
| Tres archivos ` copy.md` en `02-…/prompts/`: `diccionario-codigo copy.md`, `guia-de-estilo-y-convenciones copy.md`, `plan-formacion-nosql-mongodb copy.md`. | Son duplicados de guardado, no versiones. Ocupan sitio en el índice mental de quien abra la carpeta. | Borrarlos. El historial de git ya guarda lo que hacía falta guardar. |
"""
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
grep -n "^### 14" contenido_forense.md

# --- 2026-09-10T16:09:20 · Check tracking and diff the copy files
cd 02-complement-mongodb-backend/prompts && git ls-files . | sed 's/.*prompts\///' && echo "=== diffs de las copias ===" && for f in "diccionario-codigo" "guia-de-estilo-y-convenciones" "plan-formacion-nosql-mongodb"; do echo "--- $f"; diff -q "$f copy.md" "$f.md" || diff "$f copy.md" "$f.md" | head -12; done

# --- 2026-09-10T16:09:33 · Check inbound references before deleting copies
cd ../.. && grep -rn "copy\.md" --include=*.md . | head; echo "--- referencias al plan descartado y a la guía del curso ---"; grep -rn "prompts/guia-de-estilo-y-convenciones.md\|plan-formacion-nosql" 02-complement-mongodb-backend/*.md | head; echo "--- banner del plan ---"; head -12 02-complement-mongodb-backend/prompts/plan-formacion-nosql-mongodb.md | tail -8

# --- 2026-09-10T16:09:36 · Confirm copies are unreferenced and tracked
grep -rn "copy\.md" . --include='*.md' 2>/dev/null | head; echo "(vacío = nadie los enlaza)"; git log --oneline -1 -- "02-complement-mongodb-backend/prompts/diccionario-codigo copy.md"

# --- 2026-09-10T16:09:40 · Read the two mentions of copy files
sed -n '38,46p' 02-complement-mongodb-backend/README.md; echo "=== guía §13.2 ==="; sed -n '888,900p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-10T16:09:43 · Delete the three backup copy files
cd 02-complement-mongodb-backend/prompts && git rm -q "diccionario-codigo copy.md" "guia-de-estilo-y-convenciones copy.md" "plan-formacion-nosql-mongodb copy.md" && ls

# --- 2026-09-10T16:09:56 · Update references to deleted copies
cd ../.. && python3 - <<'PY'
import io
# README del Curso 02
p='02-complement-mongodb-backend/README.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""> 🚫 `prompts/plan-formacion-nosql-mongodb.md` está **descartado**: su
> numeración no corresponde a los archivos reales. No se usa como fuente de
> verdad. Los archivos `* copy.md` de `prompts/` son duplicados de respaldo,
> sin autoridad editorial.""",
"""> 🚫 `prompts/plan-formacion-nosql-mongodb.md` está **descartado**: su
> numeración no corresponde a los archivos reales. No se usa como fuente de
> verdad. Y `prompts/guia-de-estilo-y-convenciones.md` es la guía **superada**
> del Track B: se conserva como referencia histórica y lleva su aviso 🪦 dentro
> — la vigente es la del paquete, enlazada arriba.""")
io.open(p,'w',encoding='utf-8').write(s); print("ok",p)

# Guía del paquete §13
p='prompts/guia-de-estilo-y-convenciones.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""> 🚫 **Documentos deprecados que no cuentan como fuente:**
> `02-complement-mongodb-backend/prompts/plan-formacion-nosql-mongodb.md`
> (descartado y así declarado en las instrucciones del Curso 02), y cualquier
> archivo `* copy.md` del directorio `prompts/`, que son duplicados de
> respaldo sin autoridad editorial.""",
"""> 🚫 **Documentos deprecados que no cuentan como fuente:**
> `02-complement-mongodb-backend/prompts/plan-formacion-nosql-mongodb.md`
> (descartado y así declarado en las instrucciones del Curso 02) y
> `02-complement-mongodb-backend/prompts/guia-de-estilo-y-convenciones.md`
> (la guía del Track B, superada por ésta y con su aviso 🪦 dentro).
>
> Los duplicados de respaldo `* copy.md` que vivían en ese `prompts/` **se
> borraron el 2026-09-10**: eran copias exactas, el historial de git las
> conserva, y un duplicado sin autoridad editorial es una fuente de verdad
> esperando a que alguien lo abra por error.""")
io.open(p,'w',encoding='utf-8').write(s); print("ok",p)
PY

# --- 2026-09-10T16:10:25 · Close the leftovers item in master checklist
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()

s=s.replace("""| 3 | §14.5 | **Dos herencias del Curso 02 que este track no tocó** y conviene decidir: la segunda guía de estilo y los tres archivos ` copy.md`. | Decisión de autor | ⬜ abierto |
| 4 | cabecera | **Borrar este documento** cuando 2 esté hecho.""",
"""| 3 | cabecera | **Borrar este documento** cuando 2 esté hecho.""")
s=s.replace("""La verificación (1) **no es condición**: es un proceso largo, y lo que hay que verificar está listado en §13.2, que se puede mover a un `TODO` de una línea el día del borrado. | Ejecución | ⬜ abierto |""",
"""La verificación (1) **no es condición**: es un proceso largo, y lo que hay que verificar está listado en §13.2, que se puede mover a un `TODO` de una línea el día del borrado. | Ejecución | ⬜ abierto |
| — | §14.5 | Las dos herencias del Curso 02 | Decisión de autor | ✅ **cerrado el 2026-09-10** |""")

s=s.replace("""### 14.5 Dos herencias del Curso 02 que este track no tocó

Ninguna la produjo el track forense; las dos aparecieron al auditar y se dejan escritas
para que no se pierdan. **Ninguna bloquea nada.**

| Qué | Por qué importa | Sugerencia |
|---|---|---|
| `02-…/prompts/guia-de-estilo-y-convenciones.md` (461 líneas) **coexiste** con la guía del paquete (1.024 líneas), que el README de la raíz declara «fuente de verdad editorial de los dos cursos». | Dos guías para el mismo curso es exactamente el problema que el orden de autoridad del `CLAUDE.md` del repositorio quiere evitar: si divergen, nadie sabe cuál gana. | Borrar la del curso, o dejar una de tres líneas que diga «la guía es la del paquete» y liste **solo** lo que este curso diverge. |
| Tres archivos ` copy.md` en `02-…/prompts/`: `diccionario-codigo copy.md`, `guia-de-estilo-y-convenciones copy.md`, `plan-formacion-nosql-mongodb copy.md`. | Son duplicados de guardado, no versiones. Ocupan sitio en el índice mental de quien abra la carpeta. | Borrarlos. El historial de git ya guarda lo que hacía falta guardar. |""",
"""### 14.5 Dos herencias del Curso 02 (cerradas el 2026-09-10)

Ninguna la produjo el track forense; las dos aparecieron al auditar.

| Qué | Cómo quedó |
|---|---|
| `02-…/prompts/guia-de-estilo-y-convenciones.md` (461 líneas) coexiste con la del paquete (1.024), que el README de la raíz declara «fuente de verdad editorial de los dos cursos». | **No era una contradicción: ya estaba resuelta y yo la reporté mal.** El archivo del curso lleva dentro, desde antes de este track, un aviso 🪦 «Documento superado» que remite a la guía del paquete y dice que ante cualquier discrepancia **gana la del paquete** — que es exactamente el puntero que yo iba a proponer. Se conserva como referencia histórica del Track B. Lo único que faltaba era decirlo **fuera** del archivo: ahora el README del Curso 02 lo declara junto al plan descartado, y §13 de la guía lo lista entre los documentos que no cuentan como fuente. |
| Tres ` copy.md` en `02-…/prompts/`. | **Borrados.** Se verificó antes: `diccionario-codigo copy.md` y `plan-formacion-nosql-mongodb copy.md` eran **byte a byte** idénticos a su original, y `guia-de-estilo-y-convenciones copy.md` era la versión previa al aviso 🪦 — es decir, lo mismo con menos información. Nadie los enlazaba, y el commit `cf5cc28` los conserva en el historial. La mención genérica a `* copy.md` en §13 de la guía se sustituyó por la nota de qué pasó con ellos. |

> 🧭 **La lección, que vale más que los tres archivos:** un duplicado sin autoridad editorial
> no es inofensivo — es una fuente de verdad esperando a que alguien la abra por error. Y el
> sitio donde se declara que un documento está superado no puede ser solo el documento
> superado: quien va a equivocarse no lo ha abierto todavía.""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
sed -n '/^### 14.2/,/^### 14.3/p' contenido_forense.md

# --- 2026-09-10T16:10:33 · Verify links and staged deletions
python3 - <<'PY'
import io,os,re,glob
bad=[]
for f in glob.glob('01-vue2-legacy/*.md')+glob.glob('02-complement-mongodb-backend/*.md')+glob.glob('02-complement-mongodb-backend/prompts/*.md')+glob.glob('prompts/*.md')+['README.md','contenido_forense.md']:
    d=os.path.dirname(f); s=io.open(f,encoding='utf-8').read()
    for m in re.finditer(r'\]\(([^)#]+\.md)(#[^)]*)?\)', s):
        t=m.group(1)
        if t.startswith('http'): continue
        if not os.path.exists(os.path.normpath(os.path.join(d,t))): bad.append((f,t))
print("enlaces rotos:",len(bad),bad[:5])
PY
git status --short . | grep -E '^(D|R| D)' ; echo "--- resumen ---"; git status --short . | awk '{print $1}' | sort | uniq -c

# --- 2026-09-10T16:28:48 · Read style guide section 16 on the forensic track
sed -n '/^## 16/,$p' prompts/guia-de-estilo-y-convenciones.md | head -40

# --- 2026-09-10T16:28:56 · Sweep for TODOs and unfilled placeholders
grep -rniE '\bTODO\b|\bTBD\b|pendiente de escribir|por escribir|falta escribir|\(pendiente\)' 01-vue2-legacy/*.md 02-complement-mongodb-backend/*.md prompts/*.md README.md 2>/dev/null | grep -v cuaderno-incidentes | head; echo "--- placeholders sin rellenar ---"; grep -rn '{{' 01-vue2-legacy/*.md 02-complement-mongodb-backend/*.md 2>/dev/null | head -3; echo "--- ⬜/❌ en material del curso ---"; grep -rn '❌' 01-vue2-legacy/*.md 02-complement-mongodb-backend/*.md | grep -v forense | head -5

# --- 2026-09-10T16:29:04 · Check course 02 scope doc for stale file inventory
grep -n "realidad en disco" -A 25 02-complement-mongodb-backend/prompts/instrucciones-proyecto-track-b.md | head -35

# --- 2026-09-10T16:29:08 · Outline course 02 scope document
grep -nE '^#{2,3} ' 02-complement-mongodb-backend/prompts/instrucciones-proyecto-track-b.md; echo "=== menciones forenses ==="; grep -n "forense\|cuaderno\|incidente" 02-complement-mongodb-backend/prompts/instrucciones-proyecto-track-b.md | head

# --- 2026-09-10T16:29:13 · Read disk reality and pending work sections
sed -n '29,76p' 02-complement-mongodb-backend/prompts/instrucciones-proyecto-track-b.md; echo "===== qué falta hacer ====="; sed -n '256,300p' 02-complement-mongodb-backend/prompts/instrucciones-proyecto-track-b.md

# --- 2026-09-10T16:29:22 · Check remaining prompt docs for stale structure claims
grep -ln "realidad\|estructura\|fuente de verdad" 01-vue2-legacy/prompts/*.md; echo "--- 02 prompts-revision ---"; grep -n "Errores comunes\|pieza forense\|📌" 02-complement-mongodb-backend/prompts/prompts-revision-track-b.md | head

# --- 2026-09-10T16:29:25 · Inspect translation docs and revision prompts
grep -n "fuente de verdad\|estructura" 01-vue2-legacy/prompts/README-TRADUCCION.md | head -5; echo "--- prompts-revision headings ---"; grep -nE '^#{2,3} ' 02-complement-mongodb-backend/prompts/prompts-revision-track-b.md | head -12

# --- 2026-09-10T16:29:46 · Update course 02 scope document
python3 - <<'PY'
import io
p='02-complement-mongodb-backend/prompts/instrucciones-proyecto-track-b.md'; s=io.open(p,encoding='utf-8').read()

s=s.replace("""**Apéndices (prefijo `aNN-`):** `a01-docker.md`, `a02-mongosh-compass.md`,
`a03-express.md`, `a04-seguridad.md`, `a05-mongo-vs-sql.md`.

**Maestros y guías (fuentes de verdad):** `../00-audit-contrato.md`,
`../../prompts/guia-de-estilo-y-convenciones.md` (compartida con Track A),
`diccionario-codigo.md` (compartido con Track A), `README.md`.""",
"""**Apéndices (prefijo `aNN-`):** `a01-docker.md`, `a02-mongosh-compass.md`,
`a03-express.md`, `a04-seguridad.md`, `a05-mongo-vs-sql.md`.

**Track forense y cuaderno (añadidos en 2026-09):** `../forense-master.md` —la
puerta, con el 🩺 índice de síntomas— y **doce** `../forense-fase-NN.md`, una por
cada fase que tiene un recorrido de diagnóstico propio: 0, 1, 2, 4, 5, 6, 7, 8,
9, 10, 12 y 13. **Las fases 3, 11, 14 y 15 no llevan pieza y es deliberado** —lo
suyo son decisiones de modelado, pago de deudas, operación y veredicto—, y cada
una lo declara en su sección 6. Más `../cuaderno-incidentes.md`, con doce
incidentes de IDs propios de este curso.

**Maestros y guías (fuentes de verdad):** `../00-audit-contrato.md`,
`../../prompts/guia-de-estilo-y-convenciones.md` (compartida con Track A),
`../../prompts/formato-piezas-forenses.md` y
`../../prompts/formato-cuaderno-incidentes.md` (anexos de la guía, mandan sobre
el track forense y el cuaderno), `diccionario-codigo.md` (compartido con Track
A), `README.md`.

> ⚠️ **`guia-de-estilo-y-convenciones.md` de este mismo directorio está
> superada.** Es la guía vieja del Track B, lleva su aviso 🪦 dentro y se conserva
> como referencia histórica: la vigente es la del paquete, la de arriba. Los
> duplicados `* copy.md` que había aquí se borraron el 2026-09-10.""")

s=s.replace("""- [ ] Numeración de fase coherente con el esquema unificado (0–15)
- [ ] Cierre con puente a la siguiente fase y "la señal de que quedó bien\"""",
"""- [ ] Numeración de fase coherente con el esquema unificado (0–15)
- [ ] **Sección 6 con su pieza forense** —resumen, bloque 🧨 "Rompe a propósito" y
      la línea 📄 hacia `forense-fase-NN.md`— **o la declaración de por qué esta
      fase no tiene pieza** (guía §15)
- [ ] **Bloque 📌 "Reservas para el cuaderno de incidentes"** al final, con los
      IDs que la fase aporta, o la declaración de que no reserva ninguno. Cada ID
      existe en el índice de `../cuaderno-incidentes.md` y no se reasigna
- [ ] Cierre con puente a la siguiente fase y "la señal de que quedó bien\"""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
grep -n "forense" 02-complement-mongodb-backend/prompts/instrucciones-proyecto-track-b.md | head

# --- 2026-09-10T16:29:52 · Inspect translation README file tree
sed -n '145,175p' 01-vue2-legacy/prompts/README-TRADUCCION.md; echo "=== 210-225 ==="; sed -n '210,225p' 01-vue2-legacy/prompts/README-TRADUCCION.md

# --- 2026-09-10T16:30:14 · Stamp translation doc and record reconciliations
python3 - <<'PY'
import io
p='01-vue2-legacy/prompts/README-TRADUCCION.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""## 📊 Estructura del Proyecto (30 Archivos)""",
"""## 📊 Estructura del Proyecto (30 Archivos)

> 📸 **Inventario de la etapa de traducción, no del curso de hoy.** No incluye el
> track forense —`forense-master.md`, las 12 piezas de fase, las 3 de ruta— ni
> `cuaderno-incidentes.md`, que se escribieron después. Para el inventario
> vigente, `0-ESTRUCTURA-CURSO.md`. Aquí sigue tal cual porque describe **qué se
> tradujo**, y eso no cambia.""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
python3 - <<'PY'
import io
p='contenido_forense.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("""| Los dos `README.md` de curso | El track estaba en su propia sección pero no en la tabla de «Documentos maestros», que es por donde se entra. | Dos filas en cada uno: `forense-master.md` y `cuaderno-incidentes.md` |""",
"""| Los dos `README.md` de curso | El track estaba en su propia sección pero no en la tabla de «Documentos maestros», que es por donde se entra. | Dos filas en cada uno: `forense-master.md` y `cuaderno-incidentes.md` |
| `02-…/prompts/instrucciones-proyecto-track-b.md` | Se declara «fuente de verdad de estructura» y su inventario en disco no tenía ni un archivo del track; sus «fuentes de verdad» no listaban los dos formatos; y su checklist de calidad por fase no pedía ni la pieza ni el bloque 📌. | Bloque del track con las doce piezas y las cuatro fases que no la llevan, los dos formatos añadidos a las fuentes, la guía superada del Track B declarada, y dos ítems nuevos de checklist |
| `01-…/prompts/README-TRADUCCION.md` | Su árbol de «30 archivos» es de la etapa de traducción y alguien podría usarlo como inventario. | Nota 📸 que lo fecha como foto de esa etapa y remite a `0-ESTRUCTURA-CURSO.md` |""")
s=s.replace("""El Curso 02 no necesitó nada equivalente: no tiene documentos rectores propios — su
`00-audit-contrato.md` es el contrato, no la estructura, y no le afecta el track.""",
"""El Curso 02 no tiene rectores del mismo tipo —`00-audit-contrato.md` es el contrato, no la
estructura—, pero sí tenía un documento de alcance que se declara fuente de verdad de
estructura, y ése sí hubo que reconciliarlo.

> 🧭 **El patrón, por si vuelve a pasar:** la costura no termina en las fases. Termina en
> **todo documento que declare estructura o inventario**, y en este paquete eran cinco, no
> dos. Se encuentran con un `grep` de "fuente de verdad" y "realidad en disco".""")
io.open(p,'w',encoding='utf-8').write(s); print("ok")
PY
git status --short . | awk '{print $1}' | sort | uniq -c

# --- 2026-09-10T16:30:23 · Final link check and source-of-truth sweep
python3 - <<'PY'
import io,os,re,glob
bad=[]
for f in glob.glob('*/*.md')+glob.glob('*/prompts/*.md')+glob.glob('prompts/*.md')+['README.md','contenido_forense.md']:
    d=os.path.dirname(f); s=io.open(f,encoding='utf-8').read()
    for m in re.finditer(r'\]\(([^)#]+\.md)(#[^)]*)?\)', s):
        t=m.group(1)
        if t.startswith('http'): continue
        if not os.path.exists(os.path.normpath(os.path.join(d,t))): bad.append((f,t))
print("enlaces rotos:",len(bad),bad[:6])
PY
grep -rn "fuente de verdad" --include='*.md' . 2>/dev/null | grep -iv "contrato\|guia-de-estilo\|guía\|contenido_forense" | head

