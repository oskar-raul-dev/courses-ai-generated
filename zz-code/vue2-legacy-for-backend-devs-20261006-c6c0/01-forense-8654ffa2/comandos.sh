# Comandos Bash de la sesión 8654ffa2-c3be-4e38-8c48-f270a0c7e8e8, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-09T02:35:47 · List course files
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs && find . -type f -not -path '*/node_modules/*' -not -name '.DS_Store' | sort && echo "---SIZES---" && find . -type f -name '*.md' -not -path '*/node_modules/*' -exec wc -l {} + | sort -k1 -n | tail -40

# --- 2026-09-09T02:35:52 · Read course README and style guide
cat README.md && echo "=====PROMPTS/GUIA=====" && cat prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-09T02:35:54 · Read rest of README
sed -n '1,200p' README.md | tail -n +45

# --- 2026-09-09T02:35:56 · Read the shared style guide
cat prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-09T02:35:58 · Style guide outline
grep -n '^#\{1,3\} ' /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/8654ffa2-c3be-4e38-8c48-f270a0c7e8e8/tool-results/bk4tnh360.txt

# --- 2026-09-09T02:36:03 · Read callouts, template, exercises sections
R=/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/8654ffa2-c3be-4e38-8c48-f270a0c7e8e8/tool-results/bk4tnh360.txt; sed -n '537,730p' $R

# --- 2026-09-09T02:36:09 · Read code-language and coherence sections
R=/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/8654ffa2-c3be-4e38-8c48-f270a0c7e8e8/tool-results/bk4tnh360.txt; sed -n '294,540p' $R; echo "=====13====="; sed -n '812,934p' $R

# --- 2026-09-09T02:36:13 · Outline key docs
for f in 01-vue2-legacy/README.md 02-complement-mongodb-backend/README.md 01-vue2-legacy/0-ESTRUCTURA-CURSO.md 02-complement-mongodb-backend/00-audit-contrato.md prompts/convencion-de-git-y-tags.md prompts/plantilla-de-fase.md; do echo "########## $f ($(wc -l < $f) líneas)"; grep -n '^#\{1,3\} ' "$f" | head -40; done

# --- 2026-09-09T02:37:28 · Inspect angular-16 forensic apparatus
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs && wc -l cuaderno-incidentes.md forense-master.md forense-fase-*.md | tail -25 && echo "=====CUADERNO OUTLINE=====" && grep -n '^#\{1,3\} ' cuaderno-incidentes.md && echo "=====MASTER OUTLINE=====" && grep -n '^#\{1,3\} ' forense-master.md && echo "=====FASE05 OUTLINE=====" && grep -n '^#\{1,3\} ' forense-fase-05.md

# --- 2026-09-09T02:37:34 · Read forense-master
sed -n '1,112p' forense-master.md

# --- 2026-09-09T02:37:35 · Read cuaderno-incidentes head
sed -n '1,145p' cuaderno-incidentes.md

# --- 2026-09-09T02:37:43 · Check angular-16 README and phase structure
echo "=== README menciones forense/cuaderno ===" && grep -n -i 'forense\|cuaderno\|incidente' README.md | head -40 && echo && echo "=== fase 05: tiene seccion forense inline? ===" && grep -n '^#\{2,3\} ' 05-standalone-convivencia.md | head -40

# --- 2026-09-09T02:37:45 · Check vue2 course 01 forensic sections
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs && echo "=== CURSO 01: secciones forenses inline ===" && for f in 01-vue2-legacy/[01]*.md 01-vue2-legacy/[qvn]*.md; do echo "--- $f"; grep -n -i 'pieza forense\|forense' "$f" | head -5; done

# --- 2026-09-09T02:37:54 · Check section 6 headers across both courses
echo "=== Curso 01: seccion 6 real ===" && for f in 01-vue2-legacy/0[0-9]*.md 01-vue2-legacy/1[01]*.md 01-vue2-legacy/[qvn][0-9x]*.md; do printf '%-42s ' "$(basename $f)"; grep -o '^## ⚠️.*' "$f" | head -1; done
echo; echo "=== Curso 02: seccion 6 real ===" && for f in 02-complement-mongodb-backend/[0-9]*.md; do printf '%-46s ' "$(basename $f)"; grep -o '^## ⚠️.*' "$f" | head -1; done
echo; echo "=== forense/incidente en curso 02 ===" && grep -rn -i 'forense\|cuaderno de incidentes' 02-complement-mongodb-backend/*.md | head -20

# --- 2026-09-09T02:38:08 · Check incident conventions and chaos support
echo "=== §14 git convention incidentes ===" && sed -n '172,210p' prompts/convencion-de-git-y-tags.md
echo; echo "=== plantilla-de-fase seccion 6 ===" && sed -n '99,118p' prompts/plantilla-de-fase.md
echo; echo "=== 03-mock-api-minima: caos? ===" && grep -n -i 'caos\|chaos\|latenc\|fallo simulado\|malformed\|timeout' 01-vue2-legacy/03-mock-api-minima.md | head -20
echo; echo "=== angular-16 prompts ===" && ls ../angular-16-legacy-for-backend-devs/prompts/

# --- 2026-09-09T02:38:11 · Check angular-8 forensic layout
ls ../angular-8-legacy-for-backend-devs/ 2>/dev/null | head -50; echo "---prompts---"; ls ../angular-8-legacy-for-backend-devs/prompts/ 2>/dev/null

# --- 2026-09-09T02:42:40 · Read forensic piece format doc
cd ../angular-16-legacy-for-backend-devs/prompts && wc -l formato-piezas-forenses.md formato-cuaderno-incidentes.md && echo "===PIEZAS===" && cat formato-piezas-forenses.md

# --- 2026-09-09T02:42:42 · Read incident notebook format doc
cat formato-cuaderno-incidentes.md

# --- 2026-09-09T02:42:48 · Read phase section 6 and reservations block
cd ../ && sed -n '591,660p' 05-standalone-convivencia.md && echo "=====PENDIENTES/RESERVAS=====" && sed -n '760,800p' 05-standalone-convivencia.md

# --- 2026-09-09T02:43:01 · Check hour budgets and declared debts
cd ../vue2-legacy-for-backend-devs && echo "=== horas? ===" && grep -rn 'h\b.*hora\|horas' 01-vue2-legacy/README.md 02-complement-mongodb-backend/README.md | head -10
echo; echo "=== DEUDAS 💸 curso 01 ===" && grep -rn '💸' 01-vue2-legacy/*.md | sed 's/\(.\{150\}\).*/\1…/' | head -30

# --- 2026-09-09T02:47:41 · Write the forensic content plan doc
cat > contenido_forense.md <<'DOCEOF'
# 🕵️ Contenido forense para el paquete Mini Jira — análisis y plan de acción

> ⚠️ **Documento desechable.** Es material de trabajo para decidir y arrancar. Una vez
> aprobado el plan y creados los documentos rectores (`prompts/formato-piezas-forenses.md`
> y `prompts/formato-cuaderno-incidentes.md`), **este archivo se borra**: todo lo que
> deba sobrevivir tiene que haber migrado a esos dos.
>
> Fecha: 2026-09-08 · Alcance: `vue2-legacy-for-backend-devs/` (Cursos 01 y 02)
> Referencia comparativa: `angular-16-legacy-for-backend-devs/` y `angular-8-legacy-for-backend-devs/`

---

## 1. 🔍 Qué hay hoy, con evidencia

### 1.1 El aparato forense de los cursos Angular

Los dos cursos de Angular tienen **el mismo aparato**, en tres piezas:

| Pieza | Angular 8 | Angular 16 | Qué hace |
|---|---|---|---|
| `forense-master.md` | ✅ | ✅ (112 líneas) | Puerta de entrada: el método de cuatro preguntas y el 🩺 **índice de síntomas transversal** |
| `forense-fase-NN.md` | ✅ ×15 | ✅ ×15 (~200 líneas c/u) | El recorrido completo de una investigación, paso a paso, con salidas literales |
| `cuaderno-incidentes.md` | ✅ | ✅ (3.916 líneas, 20 incidentes) | Tickets vagos con pistas plegadas, espacio para tu investigación y solución de referencia |
| `prompts/formato-piezas-forenses.md` | ✅ | ✅ | La **especificación** de las piezas |
| `prompts/formato-cuaderno-incidentes.md` | ❌ | ✅ | La **especificación** del cuaderno |

Y una cuarta pieza que no es un archivo sino un hábito: cada fase de Angular cierra con
un bloque **`### Reservas para el cuaderno de incidentes`** donde reserva los IDs que
saldrán de ella. Ese bloque es lo que evita que el cuaderno se escriba al final, de
memoria y desconectado de las fases.

### 1.2 El aparato forense del paquete Vue 2

| | Curso 01 · Vue 2 | Curso 02 · Mongo/Express |
|---|---|---|
| `forense-master.md` | ❌ | ❌ |
| `forense-fase-NN.md` | ❌ | ❌ |
| `cuaderno-incidentes.md` | ❌ | ❌ |
| Sección 6 con **pieza forense** inline | **0 de 17 fases** | **4 de 16 fases** |
| Bloque de reservas de IDs | ❌ | ❌ |

El detalle de la sección 6, fase por fase:

**Curso 01 — las 17 fases cortan en `## ⚠️ Errores comunes`**, sin pieza forense.
Ninguna excepción. (`00`…`11`, `q0`…`q4`, `vu0`…`vu4`, `nx0`…`nx4`; `02` usa
`## ⚠️ Consideraciones de seguridad`, `nx1` y `q1` variantes del mismo encabezado.)

**Curso 02 — cumplen 4 de 16:**

| Fase | Encabezado | Pieza |
|---|---|---|
| `02-consultar-tu-sql-traducido.md:346` | `## ⚠️ Errores comunes y pieza forense` | ✅ |
| `09-aggregation.md:444` | idem | ✅ `🩻 "mi GROUP BY devuelve UNA fila"` |
| `10-express-el-vehiculo.md:499` | idem | ✅ `🩻 el request que no vuelve` |
| `13-testing-de-api.md:345` | idem | ✅ `🩻 "verde en mi máquina, rojo en CI"` |
| `00-preliminares.md:483` | `## ⚠️ Errores comunes` | ⚠️ solo un callout `🔎 Pieza forense de la fase` |
| Las otras 11 | `## ⚠️ Errores comunes` | ❌ |

---

## 2. 🧨 El argumento: tres bucles que el paquete abrió y no cerró

Esto es lo que hace que la respuesta sea **sí** sin necesidad de invocar a Angular. El
paquete Vue 2 **ya prometió** el aparato forense en sus tres documentos rectores, y los
tres apuntan a la nada.

**Bucle 1 — la plantilla obligatoria.** `prompts/plantilla-de-fase.md:99-112` define
literalmente:

```
## ⚠️ Errores comunes y pieza forense
### Pieza forense de esta fase
{{Qué depurar, específico de esta fase: consola, Network, Vue DevTools, o
—en el Curso 02— logs, profiler y `explain()`. Incluir al menos un ejercicio
de "rompe a propósito y observa".}}
```

Y la guía de estilo §9 la declara **obligatoria**: *"Toda fase produce un `.md` con
exactamente estas nueve secciones, en orden."* **29 de 33 fases la incumplen.** El
checklist de cierre de §15 tampoco la audita, así que el incumplimiento nunca se detectó.

**Bucle 2 — el post-mortem de ocho puntos.** La guía de estilo §14 define una estructura
completa —síntoma, repro, evidencia, causa raíz, corrección, prueba de regresión,
prevención, análisis sin culpabilización— y dice: *"Cada incidente sigue esta estructura
de ocho puntos"*. **No existe ni un incidente en todo el paquete.** La estructura está
especificada y nunca se instancia.

**Bucle 3 — el que más duele.** `prompts/convencion-de-git-y-tags.md:172-208` dedica una
sección entera (`## 🚑 Incidentes: acá el tag sí es contenido`) al par
`inc/<fase>/<slug>-roto` / `-fix`, con ejemplos redactados, y remata:

> *"`git tag -n99 -l 'inc/*'` te devuelve **el cuaderno de incidentes** entero."*

**Ese cuaderno no existe.** El comando devuelve vacío. El documento nombra un entregable
que nadie escribió.

> 🧭 **La conclusión, en una línea:** no estaríamos importando el aparato de Angular al
> paquete Vue. Estaríamos **entregando lo que el paquete Vue ya facturó** — que es
> exactamente lo que la propia guía llama, en §4.5, *"cerrar los bucles"*.

Y hay un cuarto argumento, de fondo: la guía §10 exige que **al menos un tercio de los
ejercicios sean de diagnóstico** — *"es el músculo que este paquete entrena"*. Hoy ese
músculo se entrena disperso en ~30 bloques de ejercicios, sin un método común, sin índice
de síntomas y sin un solo recorrido completo que enseñe **el orden** en que se mira. El
track forense es el sitio donde ese método se escribe una vez.

---

## 3. ⚖️ Lo que NO se copia de Angular

Copiar el aparato tal cual sería un error, y conviene decir por qué antes de escribir el
primer prompt. Cinco diferencias reales entre los paquetes:

1. **El paquete Vue no cuenta horas.** Angular presupuesta *"108h de fases + 14h de
   cuaderno"*; ni el README ni la guía del paquete Vue mencionan horas en ningún sitio.
   **No se inventa un presupuesto horario**: el tamaño se expresa en número de incidentes
   y de piezas. Introducir horas ahora sería una divergencia sin motivo.

2. **Son dos cursos con dos repos.** `convencion-de-git-y-tags.md` §📦 fija *"un repo por
   curso"*. Un cuaderno único obligaría a incidentes que cruzan dos repositorios. → Ver
   decisión **D3**.

3. **Hay tres rutas excluyentes.** Angular tiene un tronco lineal de 15 fases. Aquí,
   `q0`…`q4`, `vu0`…`vu4` y `nx0`…`nx4` son **alternativas**: escribir 15 piezas de ruta
   significa que cada lector leerá 5 y descartará 10. → Ver decisión **D4**.

4. **El mock de Vue no tiene inyector de caos.** El cuaderno de Angular se apoya en
   `CHAOS=malformed npm run mock` (su fase `03-mock-api-caos.md`) como forma **preferida**
   de romper el sistema. La fase homóloga aquí, `03-mock-api-minima.md`, **solo simula
   latencia** (`setTimeout`, línea 402). Sin caos, dos tercios de los incidentes caerían en
   *"crea una rama"*, que es la preparación cara que el propio formato desaconseja. → Ver
   decisión **D2**.

5. **La costura entre cursos es contenido forense de primera.** Angular no tiene nada
   equivalente. El paquete Vue tiene su promesa central —*"se cambia el `baseURL` y la
   aplicación no se entera"*— y con ella el mejor incidente que este material puede
   escribir: *"apunté el front al Express y el dashboard salió vacío, pero `curl` devuelve
   los tickets"* (el `id` ↔ `_id` de `00-audit-contrato.md:105`). Eso hay que aprovecharlo.

---

## 4. 🗳️ Decisiones que necesito de ti

Seis. Cada una lleva mi recomendación; marca la que quieras o escribe otra cosa.

### D1 — ¿Piezas forenses en archivo aparte, o inline en la sección 6?

- **(a) Archivo aparte** — `forense-fase-NN.md`, como Angular. La sección 6 de la fase
  queda con el resumen y una línea 📄 que promete el recorrido completo.
- (b) Inline — se desarrolla la sección 6 dentro de cada fase y no nacen archivos nuevos.

> ✅ **Recomiendo (a).** Tres motivos: las piezas se consultan **fuera de orden** y meses
> después (un archivo se abre, una sección de una fase de 900 líneas no se encuentra); la
> fase ya pesa 500–1.900 líneas y una pieza bien hecha suma 200 más; y la relación
> *"la fase promete / la pieza entrega"* es un contrato verificable en el checklist.
> **Coste:** hay que declarar la divergencia en la guía de estilo §9, porque hoy la
> plantilla la pone dentro de la sección 6.

### D2 — ¿Se le añade inyector de caos a `03-mock-api-minima.md`?

- **(a) Sí, como sección 🔥 aditiva** — un middleware de json-server con
  `CHAOS=cors|timeout|malformed|500|slow npm run mock`. No cambia nada de lo escrito: se
  agrega.
- (b) No — el cuaderno usa solo `db.json` alternos y ramas de git.

> ✅ **Recomiendo (a).** Es lo que hace baratos los incidentes de integración, que son la
> mitad del Curso 01. **Es la única decisión que toca una fase publicada** (el "content
> lock" del `CLAUDE.md`), pero es puramente aditiva: ninguna línea existente cambia, no se
> renumeran ejercicios y el `db.json` sigue igual. Si prefieres (b), el cuaderno se puede
> escribir igual, con más ramas y menos elegancia.

### D3 — ¿Un cuaderno por curso, o uno compartido?

- **(a) Uno por curso** — `01-vue2-legacy/cuaderno-incidentes.md` y
  `02-complement-mongodb-backend/cuaderno-incidentes.md`. IDs independientes por curso.
  Los incidentes de **costura** viven en el Curso 02, que es el único momento en que las
  dos mitades corren a la vez.
- (b) Uno solo en la raíz del paquete, con IDs globales.

> ✅ **Recomiendo (a).** Lo manda la propia convención de git: un repo por curso, y un
> incidente se prepara con `git switch -c incidente/07 fase-04` — un comando que no existe
> si el tag está en el otro repositorio.

### D4 — ¿Cuántas piezas para las rutas Q / VU / NX?

- **(a) Tres piezas compactas** — `forense-ruta-q.md`, `forense-ruta-vu.md`,
  `forense-ruta-nx.md`, de ~120 líneas, cubriendo las 5 fases de cada ruta.
- (b) Quince, una por fase de ruta.
- (c) Una sola, `forense-rutas.md`, con las tres columnas comparadas.

> ✅ **Recomiendo (a).** El 80 % del síntoma de ruta es el mismo en las tres —*"el
> framework quiere el estado que tu store ya controla"*, el conflicto central de
> Q3/VU3/NX3—, y el 20 % restante es genuinamente distinto (NX suma hidratación y SSR, que
> ya tiene fase propia en `nx2`). Quince piezas garantizan que cada lector descarte diez.

### D5 — ¿Cuántas piezas en el Curso 02?

- **(a) Doce**, para las fases con peso forense real, y se dice explícitamente cuáles
  quedan fuera y por qué (`00-audit-contrato` no es una fase; `15-el-veredicto-honesto` es
  cierre y decisión, no depuración; `03` y `04` son diseño de esquema).
- (b) Las dieciséis, por simetría.

> ✅ **Recomiendo (a).** Una pieza forense de una fase que no da para ella se convierte en
> resumen de la fase, que es justamente lo que el formato de Angular prohíbe en su §1. Y
> las 4 piezas que ya existen inline se **promueven** a archivo, no se reescriben.

### D6 — ¿Cuántos incidentes por cuaderno?

- **(a) 12 + 12** (24 en total, el paquete es dos cursos).
- (b) 20 + 20, como Angular.
- (c) 15 + 10.

> ✅ **Recomiendo (a).** Cada incidente bien escrito son ~150 líneas con solución de
> referencia, test de regresión en código y post-mortem. 24 incidentes ya son ~3.600
> líneas por cuaderno. El límite real no es la ambición, es que cada uno tenga **una causa
> raíz distinta**: el propio formato de Angular documenta (§1) que bajaron de 4 a 3 los
> incidentes de una categoría *"el día que se escribió el cuaderno"*, porque el cuarto
> salía forzado.

---

## 5. 📦 Inventario de entregables (con D1–D6 en su valor recomendado)

```
vue2-legacy-for-backend-devs/
├── prompts/
│   ├── formato-piezas-forenses.md          🆕  ~180 líneas  · rige los DOS cursos
│   └── formato-cuaderno-incidentes.md      🆕  ~380 líneas  · rige los DOS cursos
│   └── guia-de-estilo-y-convenciones.md    ✏️  §9, §13.2, §15 + nueva §16
│   └── plantilla-de-fase.md                ✏️  sección 6: línea 📄 + bloque de reservas
│
├── 01-vue2-legacy/
│   ├── forense-master.md                   🆕  ~130 líneas
│   ├── forense-fase-00.md … forense-fase-11.md   🆕  12 piezas × ~200 líneas
│   ├── forense-ruta-q.md / -vu.md / -nx.md 🆕  3 piezas × ~120 líneas
│   ├── cuaderno-incidentes.md              🆕  12 incidentes · ~1.900 líneas
│   ├── 03-mock-api-minima.md               ✏️  + sección 🔥 inyector de caos  (D2)
│   ├── (las 17 fases)                      ✏️  sección 6 + línea 📄 + reservas de IDs
│   └── README.md                           ✏️  + bloques 🕵️ Track forense y 📓 Cuaderno
│
└── 02-complement-mongodb-backend/
    ├── forense-master.md                   🆕  ~130 líneas
    ├── forense-fase-NN.md                  🆕  12 piezas (4 promovidas + 8 nuevas)
    ├── cuaderno-incidentes.md              🆕  12 incidentes · ~1.900 líneas
    ├── (las 16 fases)                      ✏️  sección 6 + línea 📄 + reservas
    └── README.md                           ✏️  idem
```

**Nombres:** se respeta la nomenclatura de Angular (`forense-master.md`,
`forense-fase-NN.md`, `cuaderno-incidentes.md`) porque no colisiona con nada y hace que
los tres paquetes se lean igual. Las piezas de ruta usan `forense-ruta-<código>.md`, que
es nuevo y hay que **declararlo en §13.2** de la guía junto al resto.

---

## 6. 🗺️ Plan de acción — seis tandas

El orden no es negociable en los tres primeros pasos: la especificación antes que el
entregable, y el índice de síntomas antes que las piezas.

| # | Tanda | Entregable | Prompt | Depende de |
|---|---|---|---|---|
| 1 | **Los formatos** | `prompts/formato-piezas-forenses.md` + `formato-cuaderno-incidentes.md` | **P1** | D1, D3, D4, D5, D6 |
| 2 | **Los rectores** | Parches a `guia-de-estilo-y-convenciones.md` y `plantilla-de-fase.md` | **P2** | Tanda 1 |
| 3 | **Las puertas** | Los dos `forense-master.md` | **P3** | Tanda 1 |
| 4 | **El caos** | Sección 🔥 en `03-mock-api-minima.md` | **P4** | D2 |
| 5 | **Las piezas** | 15 + 12 `forense-fase-*.md`, en tandas de 3–4 | **P5** | Tandas 2 y 3 |
| 6 | **Los cuadernos** | 2 × `cuaderno-incidentes.md`, en tandas de 4 incidentes | **P6** | Tandas 4 y 5 |
| — | **Cierre** | Parches a las secciones 6 de las 33 fases + los dos README | **P7** | Tandas 5 y 6 |
| — | **Auditoría** | Verificación cruzada de enlaces, IDs y contrato | **P8** | todo |

> 🧭 **Por qué las puertas (tanda 3) van antes que las piezas (tanda 5).** El
> `forense-master.md` obliga a decidir **el índice de síntomas completo** de un curso de
> una sentada. Ese índice es el que reparte qué síntoma cubre cada pieza — y escribirlo
> después significa descubrir en la pieza 9 que la 3 y la 7 cubren lo mismo. Es la pieza
> de más valor por línea escrita de todo el track.

**Regla de trabajo para las tandas 5 y 6:** un chat por tanda, nunca más de 4 archivos, y
cada chat empieza leyendo los dos formatos y la guía de estilo. Las piezas se escriben
**contra el proyecto corriendo**: si una salida no se puede reproducir, no se inventa —
se marca con `…` o se cambia el paso.

---

## 7. 🎬 Los prompts

Todos asumen que el chat arranca en `vue2-legacy-for-backend-devs/`.

---

### P1 · Los dos documentos de formato

```
Lee, en este orden y completos:
- prompts/guia-de-estilo-y-convenciones.md
- prompts/plantilla-de-fase.md
- prompts/convencion-de-git-y-tags.md (sobre todo §🚑 Incidentes)
- 02-complement-mongodb-backend/00-audit-contrato.md
- ../angular-16-legacy-for-backend-devs/prompts/formato-piezas-forenses.md
- ../angular-16-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md

Crea DOS documentos en prompts/, que rigen los dos cursos del paquete:
prompts/formato-piezas-forenses.md y prompts/formato-cuaderno-incidentes.md

Son ESPECIFICACIONES, no entregables: definen cómo se escriben forense-master.md,
forense-fase-NN.md, forense-ruta-<código>.md y cuaderno-incidentes.md. Toman la
estructura de los dos documentos homólogos de Angular 16 y la adaptan al paquete Mini
Jira. Adaptar significa: mismo esqueleto, ejemplos y vocabulario propios.

Decisiones ya tomadas, que los formatos deben recoger explícitamente:
- Las piezas van en archivo aparte. La sección 6 de cada fase queda con el resumen y una
  línea «📄 El recorrido completo, en `forense-fase-NN.md`». La frontera fase/pieza se
  especifica con una tabla, como el §5 del formato de Angular.
- Un cuaderno por curso, IDs independientes por curso, nunca reasignados. Los incidentes
  de costura entre cursos viven en el cuaderno del Curso 02.
- 12 incidentes por cuaderno. 15 piezas en el Curso 01 (12 de tronco + 3 de ruta) y 12 en
  el Curso 02.
- Las tres rutas comparten tres piezas compactas, no quince.
- NO hay presupuesto horario. Este paquete no cuenta horas en ningún documento; no se
  introduce ahora. El tamaño se expresa en número de piezas e incidentes.

Lo que el formato de piezas debe fijar, propio de este paquete:
- Herramientas del Curso 01 y su mentira característica: Vue DevTools (miente por
  *timeline* — muestra el estado después de la mutation, no quién la lanzó), la consola
  (miente por omisión: un catch vacío y un warn de reactividad que solo sale en dev),
  Network, y `git log -S`. Curso 02: mongosh, Compass, `explain()` (miente por caché de
  plan), los logs de Express, el profiler.
- La cuarta pregunta del método, propia de este paquete y equivalente al 🧬 de Angular:
  **«¿en qué capa vive esto?»** — componente / store / servicio HTTP / mock, y en el
  Curso 02 ruta / controller / service / Mongo. Es la distinción que la guía §6 ya llama
  "la que salva al que depura".
- Texto, nunca capturas (§2 del formato de Angular, se conserva tal cual).
- Los pasos van del más barato al más caro, cada paso dice qué descarta, y la ruta
  termina cuando se sabe dónde está el bug, no cuando está arreglado.

Lo que el formato de cuaderno debe fijar, propio de este paquete:
- Las tres formas de tener el sistema roto, en orden de preferencia: flag del inyector de
  caos del mock, `db.json` alterno (`db.incidente-NN.json`), rama de git
  (`git switch -c incidente/07 fase-04`, que sale del tag de la fase).
- Categorías del Curso 01: reactividad · estado (Vuex) · integración (mock) · formularios
  y wizard · tiempo real (sockets) · convivencia con framework de ruta · UI · testing ·
  build.
- Categorías del Curso 02: modelado (embeber/referenciar) · consultas y explain ·
  atomicidad y concurrencia · índices · contrato · auth · operación · testing.
- Cuotas mínimas, para que el cuaderno cubra el corazón de cada curso:
  · Curso 01 — al menos 2 de reactividad de Vue 2, 2 de Vuex y 2 de deudas 💸 declaradas.
  · Curso 02 — al menos 2 de atomicidad/concurrencia, 2 del anti-patrón `soporte_v1` y
    **2 de costura** (el frontend del Curso 01 hablándole al backend del Curso 02).
- La plantilla del incidente, con `<details>` para pistas y solución, declarada como la
  única excepción a "Markdown sin HTML" de la guía §3.
- La convención de commits `incidente(NN): abre|repro|hipótesis|hipótesis descartada|causa|fix|cierre`
  y el par de tags `inc/<fase>/<slug>-roto` / `-fix`, que NO se reinventa: ya está en
  prompts/convencion-de-git-y-tags.md y solo se enlaza.

Reglas de forma, no negociables: español latinoamericano con tuteo, cero voseo, código en
inglés y comentarios en español, Options API en el Curso 01, driver nativo antes de
Mongoose en el Curso 02. Cada documento cierra con su checklist de "antes de dar por
cerrado".
```

---

### P2 · Parchear los documentos rectores

```
Lee prompts/formato-piezas-forenses.md, prompts/formato-cuaderno-incidentes.md,
prompts/guia-de-estilo-y-convenciones.md y prompts/plantilla-de-fase.md.

Aplica estos cambios. Son quirúrgicos: no reescribas secciones enteras.

1. guia-de-estilo-y-convenciones.md §9 — la sección 6 de la plantilla pasa a ser
   «⚠️ Errores comunes y pieza forense», con el resumen en la fase y el recorrido
   completo en su archivo. Declara la divergencia respecto de cómo estaba escrita
   —el CLAUDE.md del repositorio exige que toda divergencia sea explícita— y di por qué:
   la pieza se consulta fuera de orden y meses después.

2. guia-de-estilo-y-convenciones.md §13.2 — añade a la nomenclatura vigente:
   forense-master.md, forense-fase-NN.md, forense-ruta-<código>.md y
   cuaderno-incidentes.md, uno de cada por curso.

3. guia-de-estilo-y-convenciones.md — nueva §16 «El track forense y el cuaderno», de
   media página: qué son, dónde viven, y que su especificación está en los dos formatos.
   No dupliques los formatos: enlázalos. Ajusta §13.1 para que los dos formatos entren en
   la lista de fuentes de verdad, en el nivel 5 junto a esta guía.

4. guia-de-estilo-y-convenciones.md §15 — añade tres ítems al checklist:
   - [ ] La sección 6 lleva su pieza forense (resumen + línea 📄), o dice por qué no.
   - [ ] Lleva el bloque «📌 Reservas para el cuaderno de incidentes», o declara que no
         reserva ninguno.
   - [ ] Cada ID reservado existe en el índice del cuaderno de su curso.

5. plantilla-de-fase.md — la sección 6 incorpora la línea 📄 y el bloque
   «🧨 Rompe a propósito»; y al final de la plantilla, después del cierre, un bloque
   «### Reservas para el cuaderno de incidentes» con la tabla
   | ID | Título propuesto | Categoría | Dif. |. Di que los apéndices no lo llevan, igual
   que no llevan el bloque 🏷️.

6. convencion-de-git-y-tags.md — en §🚑, sustituye la frase que dice que
   `git tag -n99 -l 'inc/*'` «te devuelve el cuaderno de incidentes entero» por una que
   enlace al cuaderno real de cada curso y explique la relación: el archivo es el
   enunciado y tu investigación; los tags son tu bitácora ejecutable.

No toques nada más. Al terminar, lista los archivos modificados y, por cada uno, las
secciones tocadas en una línea.
```

---

### P3 · Los dos `forense-master.md`

```
Lee prompts/formato-piezas-forenses.md §6, prompts/guia-de-estilo-y-convenciones.md, y
—completos— los README y los documentos maestros del curso que vayas a cubrir.

Crea 01-vue2-legacy/forense-master.md   [o 02-complement-mongodb-backend/forense-master.md]

Cinco bloques, según §6 del formato:
1. El método de cuatro preguntas, con el orden justificado por coste.
2. 📇 Índice de las piezas: una fila por fase con síntoma, herramienta principal, archivo.
3. 🩺 Índice de síntomas transversal — LA TABLA QUE IMPORTA. A la izquierda, lo que el
   usuario dice o lo que ves; a la derecha, dónde empezar. Mínimo 25 filas. Tiene que
   cubrir los síntomas que ya viven dispersos en las secciones «⚠️ Errores comunes» de
   todas las fases del curso: recórrelas y recógelos, no los inventes.
4. 🧰 Las herramientas y en qué miente cada una.
5. Cierre con el criterio de éxito del track.

Para el Curso 01, el índice de síntomas tiene que incluir al menos estos, con la fase
donde se empieza:
- "le di a guardar y no pasó nada", sin nada en consola
- cambié un campo del ticket y la tabla no se enteró, pero si recargo sí está
- la lista se pinta con los datos de antes del filtro
- tomé el ticket y a mi compañero le sigue apareciendo libre
- cierro sesión en una pestaña y en la otra sigo dentro
- el wizard me deja avanzar con el paso 2 vacío
- la métrica del dashboard no cuadra con el número de filas de la tabla
- se me duplican los tickets en la lista cuando llega un evento del socket
- "this is undefined" dentro de un método
- el mock devuelve 404 en /tickets/1/comments y en Postman funciona
- el filtro cambia la URL pero no la tabla
- la app va bien y al rato el ventilador se dispara
- el test pasa solo cuando lo corro aislado
- en el build de producción se ve distinto que en `npm run serve`
- (rutas) el componente del framework ignora lo que le pone el store
- (Nuxt) `window is not defined` al recargar una página que en navegación funciona

Para el Curso 02:
- la consulta que en SQL era un JOIN ahora tarda 40 veces más
- el dashboard hace seis viajes a la base por pantalla
- dos agentes tomaron el mismo ticket
- el índice está creado y `explain()` sigue diciendo COLLSCAN
- el GROUP BY me devuelve una fila
- guardé el ticket y al releerlo falta un campo
- la fecha se guarda bien y se lee con un día menos
- el front no muestra nada y `curl` sí devuelve los tickets  ← el id ↔ _id del contrato
- el evento de socket llega dos veces
- la suite pasa en local y falla en CI

Reglas: texto, nunca capturas. El master NO repite ninguna pieza: enlaza. Español con
tuteo, código en inglés. Y no inventes síntomas que el curso no produce: si un síntoma no
tiene fase que lo cubra, sácalo y anótalo al final como pendiente.
```

---

### P4 · El inyector de caos (solo si apruebas D2)

```
Lee 01-vue2-legacy/03-mock-api-minima.md completo, prompts/guia-de-estilo-y-convenciones.md
y ../angular-16-legacy-for-backend-devs/03-mock-api-caos.md (solo como referencia de qué
fallos merecen existir).

Añade a 03-mock-api-minima.md una sección 🔥 opcional, «El inyector de caos», entre el
código y los errores comunes. Es ADITIVA: no toques una línea de lo que ya está, no
renumeres ejercicios, no cambies el db.json.

Qué tiene que traer:
- Un middleware de json-server, en un archivo nuevo, que lee la variable de entorno CHAOS
  y aplica uno de estos fallos a las respuestas: `cors`, `timeout`, `malformed`, `500`,
  `slow`, `empty`. Código en inglés, comentarios en español, sintaxis de Node 14.
- El script de npm que lo enciende: `CHAOS=malformed npm run mock`.
- Por qué cada fallo enseña algo distinto, en prosa breve: `cors`, servidor caído y red
  ausente son INDISTINGUIBLES desde el código del cliente, y ésa es la lección; `malformed`
  es el que miente, porque llega con 200 en verde; `timeout` es el spinner eterno.
- Una tabla «lo que ves / lo que es», que se enlazará desde forense-master.md.
- 4 ejercicios 🔥 al final del bloque de ejercicios, con la numeración que sigue a los que
  ya existen, sin tocar los anteriores.
- Una frase que diga que este inyector es la forma preferida de preparación de los
  incidentes del cuaderno, y enlace a cuaderno-incidentes.md.

No añadas el bloque 🏷️ (la fase ya lo tiene) ni toques el cierre.
```

---

### P5 · Una tanda de piezas forenses

```
Lee prompts/formato-piezas-forenses.md, prompts/guia-de-estilo-y-convenciones.md,
<curso>/forense-master.md, y COMPLETAS las fases que vas a cubrir en esta tanda.

Crea: <curso>/forense-fase-04.md, forense-fase-05.md, forense-fase-06.md
      [ajusta la lista — máximo 4 por tanda]

Siete bloques por pieza, según §3 del formato: encabezado · 🎫 el ticket · 🧭 la ruta ·
🩺 diagnóstico por síntoma · ⚰️ los callejones · 🧨 deshacer · 🧠 el patrón transferible.

Innegociable:
- Cada paso: qué haces (imperativo, con la ruta exacta de la interfaz o el comando
  completo) → la salida LITERAL en un bloque de código → «Qué descarta» y a qué paso
  saltas. Un paso que no descarta nada es relleno: bórralo.
- Del más barato al más caro, y dilo al empezar la ruta.
- CERO capturas. Todo en texto.
- Cero salidas inventadas: todo tiene que reproducirse con el proyecto de la fase y su
  semilla. Lo variable (puertos, hashes, fechas, ids) va con `…` o con marcador evidente.
- La ruta termina cuando sabes DÓNDE está el bug. El fix es de la fase o del incidente.
- No repitas la sección 6 de la fase: enlázala.
- El síntoma que cubre cada pieza es EXACTAMENTE el que forense-master.md le asignó en su
  índice. Si al escribirla ves que el reparto está mal, dilo y para: se corrige el master
  primero.

Al terminar cada pieza, entrega también, para pegar en su fase (no la edites todavía):
- El párrafo de la línea 📄 que la fase debe llevar en su sección 6.
- El bloque 🧨 «Rompe a propósito» si sale de la pieza.
- La tabla de «📌 Reservas para el cuaderno de incidentes» con los IDs que esta fase
  reserva: | ID | Título propuesto (en palabras del usuario) | Categoría | Dif. |
  Los IDs son correlativos por curso y no se reasignan nunca.
```

---

### P6 · Una tanda de incidentes

```
Lee prompts/formato-cuaderno-incidentes.md, prompts/guia-de-estilo-y-convenciones.md §14,
prompts/convencion-de-git-y-tags.md §🚑, <curso>/forense-master.md, las piezas forenses de
las fases implicadas, y COMPLETAS esas fases.

Si <curso>/cuaderno-incidentes.md no existe, créalo con: encabezado y el trato · 🧭 cómo
se trabaja un incidente · 📋 índice con las 12 filas (todas, aunque el enunciado aún no
esté redactado: el ⬜ significa "reservado, no escrito") · 🧪 incidentes · 🪞 retrospectiva ·
📌 pendientes.

Redacta los incidentes NN a NN+3 con la plantilla completa de §7 del formato. Cada uno:
- 🎫 El ticket en palabras del usuario, con su vaguedad incluida y quién lo reportó. El
  título es el ticket, no la respuesta: «tomé el ticket y a mi compañero le sigue
  apareciendo libre» sí; «race condition en takeTicket» no.
- 🎯 Qué se te pide. No todos terminan en fix: alguno termina en «demuestra que no es un
  bug», que es un entregable legítimo y de los más formativos.
- 🔧 Preparación con la forma MÁS BARATA que sirva, de las tres, y por qué esa.
- Tres pistas plegadas en `<details>`: dónde mirar → qué mirar → la pregunta cuya
  respuesta es la causa.
- 📝 Tu investigación, en blanco, con los subtítulos.
- Solución de referencia plegada: causa raíz hasta el archivo · parche mínimo (el del
  viernes a las seis, en el estilo del archivo que toca) · la refactorización correcta ·
  prueba de regresión EN CÓDIGO · prevención · por qué llegó a producción (post-mortem
  sereno, sin culpabilización, aquí el humor baja un punto) · «si tu causa fue distinta».

Reglas del paquete: código en inglés y comentarios en español; Options API y
`function () {}` en el Curso 01; driver nativo antes de Mongoose en el Curso 02; nada
contradice el contrato de 02-complement-mongodb-backend/00-audit-contrato.md.

Actualiza el 📋 índice en el mismo pase. Si un incidente que reservó una fase resulta
imposible de escribir con una causa raíz propia, NO lo fuerces: retíralo, documenta por
qué en 📌 pendientes, y deja el ID retirado sin reasignar.
```

---

### P7 · Coser el track a las fases

```
Lee prompts/formato-piezas-forenses.md §5, <curso>/forense-master.md, todas las piezas
forenses del curso y su cuaderno-incidentes.md.

Para CADA fase del curso, edita solo su sección 6 y su cierre:
1. El encabezado pasa a «## ⚠️ Errores comunes y pieza forense» (respeta la numeración
   explícita §N donde la fase ya la use — hoy solo q1, q3, vu1 y vu3).
2. Debajo de «Errores comunes», añade «### Pieza forense de esta fase»: el resumen que se
   lee de corrido, el bloque 🧨 «Rompe a propósito», y la línea
   «> 📄 El recorrido completo, con las salidas literales, en `forense-fase-NN.md`.»
   Aplica la tabla de frontera del §5 del formato: si un párrafo cabe igual en los dos
   sitios, va en la fase y la pieza lo enlaza.
3. Antes del cierre, el bloque «### Reservas para el cuaderno de incidentes» con los IDs
   que esta fase reserva, enlazados al cuaderno.
4. En los apéndices NO se hace nada de esto.

Después, actualiza <curso>/README.md con dos bloques nuevos, modelados sobre los del
README de angular-16: «🕵️ Track forense» (con la tabla de piezas y sus síntomas) y
«📓 Cuaderno de incidentes».

Regla dura: no reescribas los «Errores comunes» que ya existen, ni toques ejercicios,
código, referencias ni el bloque 🏷️. Es una operación de costura.
```

---

### P8 · Auditoría de cierre

```
Audita el track forense completo del paquete y entrega un informe, sin corregir nada
todavía. Comprueba:

1. Cada .md citado existe con ese nombre exacto (guía §13.2). Lista los enlaces rotos.
2. Cada línea 📄 de una sección 6 apunta a una pieza que existe, y esa pieza entrega
   exactamente los tickets que la fase promete.
3. Cada ID reservado por una fase tiene fila en el índice del cuaderno de su curso, y
   viceversa. Ningún ID reasignado. Lista los huérfanos en ambos sentidos.
4. Ningún síntoma del 🩺 índice de síntomas se queda sin pieza, y ninguna pieza cubre un
   síntoma que el índice no lista.
5. Ninguna pieza ni incidente contradice 00-audit-contrato.md: forma del ticket, enums
   `status`/`priority`, nombres de evento de socket, mapeo id ↔ _id.
6. Pasada de tuteo con la tabla de §4.7 sobre todos los archivos nuevos, homógrafos
   revisados a mano.
7. Todo el código en inglés y todos los comentarios en español, incluidos los parches
   mínimos de las soluciones de referencia.
8. Cero capturas de pantalla. Cero salidas que no se puedan reproducir con el proyecto.
9. Los cuadernos cumplen sus cuotas de categoría (§ del formato de cuaderno).
10. El checklist de §15 de la guía pasa en todos los archivos nuevos.

Entrega una tabla | Archivo | Hallazgo | Severidad | Arreglo propuesto | y, al final, la
lista de correcciones en el orden en que conviene aplicarlas.
```

---

## 8. 🧪 Ejemplos concretos, para que juzgues el tono

### 8.1 Muestra de incidente (Curso 01) — versión abreviada

> Un incidente real ocupa ~150 líneas. Esto es el esqueleto con las tres o cuatro frases
> que definen la voz, para que apruebes el registro antes de que se escriban 24.

````markdown
## Incidente 05 — "Le puse la etiqueta 'facturación' al ticket y la tabla no se enteró"

> **Fase:** 5 · **Categoría:** Reactividad · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Tiempo sugerido:** 40–60 min

### 🎫 El ticket

"Abro el ticket #0347, le agrego la etiqueta desde el detalle, le doy guardar y me dice
que se guardó. Pero en la tabla el ticket sigue sin etiqueta. Si recargo la página con F5
ahí sí aparece. A veces me pasa y a veces no, no sé de qué depende."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Reproducirlo, decir en qué **capa** vive —componente, store, servicio o mock— y aplicar el
parche mínimo. El "a veces sí y a veces no" es un dato, no ruido del reporte: averigua de
qué depende antes de tocar nada.

### 🔧 Preparación

Un `db.json` alterno: el bug solo se ve con tickets que **no traen** el campo `tags`
desde el mock, y la semilla actual se lo pone a todos.

```bash
cp mock/db.incidente-05.json mock/db.json    # guarda el tuyo antes, o corre npm run seed después
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El store ya tiene el dato correcto. Compara, en Vue DevTools, lo que dice el objeto del
ticket en Vuex con lo que pinta la fila. No es un problema de red: Network no tiene nada
que contarte aquí.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

De los tickets de la tabla, unos se actualizan y otros no. Mira qué tienen en común los
que **sí**. Fíjate en la respuesta del mock, no en el objeto que arma el formulario.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿En qué momento exacto de la vida de ese objeto apareció la propiedad `tags`?

</details>

---

### 📝 Tu investigación

**Reproducción** · **Evidencia observable** · **Hipótesis (❌ descartada / ✅ confirmada)** ·
**Tu causa raíz** · **Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** `store/modules/tickets.js`, en la mutation `UPSERT_TICKET`. Vue 2 hace
reactivas las propiedades que existen **en el momento en que el objeto entra en `data` o
en el store**. Los tickets que el mock devuelve sin `tags` entran sin esa propiedad, y el
`ticket.tags = […]` posterior crea una propiedad que ningún getter/setter vigila. El dato
está en el store —por eso DevTools lo muestra— y la tabla nunca se entera. Con F5 el
ticket vuelve a entrar, esta vez con `tags`, y todo funciona: de ahí el "a veces".

**Parche mínimo** — el del viernes a las seis:

```js
// store/modules/tickets.js
UPSERT_TICKET: function (state, ticket) {
  var index = state.items.findIndex(function (t) { return t.id === ticket.id; });
  // Vue.set y no state.items[index] = ticket: la asignación por índice en un array
  // tampoco es reactiva en Vue 2. Son las dos caras de la misma limitación.
  if (index === -1) { state.items.push(ticket); } else { Vue.set(state.items, index, ticket); }
}
```

**La refactorización correcta.** El problema de fondo no es el `Vue.set`: es que el
frontend acepta del mock tickets con forma incompleta. La forma canónica del ticket la fija
`02-complement-mongodb-backend/00-audit-contrato.md`, y **normalizar en el servicio HTTP**
—un `tags: ticket.tags || []` en la frontera— hace que la limitación de reactividad no
pueda dispararse nunca. Se paga en la Fase 3 del Curso 02, cuando el backend real deja de
devolver campos ausentes.

**Prueba de regresión** · **Prevención** · **Por qué llegó a producción** ·
**Si tu causa fue distinta a esta** …

</details>
````

### 8.2 Muestra de pieza forense (Curso 01, F8) — solo el esqueleto

```markdown
# 🕵️ Forense Fase 08 — "Tomé el ticket y a mi compañero le sigue apareciendo libre"

> Sale de: Fase 8 (WebSockets mínimos) · Herramientas: Network → WS, Vue DevTools, dos
> navegadores · Recorrido: ~25 min

## 🎫 El ticket
## 🧭 La ruta
  Paso 1 — ¿lo ve el otro navegador tras recargar?   → separa "no se emitió" de "no se pintó"
  Paso 2 — el frame en la pestaña WS de Network      → ¿salió el evento, y de quién salió?
  Paso 3 — quién emite: el cliente o el servidor     → 💸 aquí aparece el cliente mentiroso
  Paso 4 — el store del otro cliente                 → ¿llegó y no se aplicó, o no llegó?
## 🩺 Diagnóstico por síntoma
## ⚰️ Los callejones     ← "es que el socket se desconecta": Network dice que no
## 🧨 Deshacer
## 🧠 El patrón transferible
```

> 🧠 **Por qué ésta es la pieza estrella del Curso 01.** El recorrido termina localizando
> una **deuda 💸 declarada** —el cliente mentiroso de `08-websockets-minimos.md:231`, que
> emite el evento que debería emitir el servidor— y la deuda se paga en el **Curso 02,
> Fase 12** (`12-el-backend-habla.md`). Es el único sitio del paquete donde el estudiante
> *descubre depurando* algo que el material le había advertido cien líneas antes y él leyó
> sin entender del todo. Eso no lo puede hacer un ejercicio.

---

## 9. ⚠️ Riesgos, y cómo se mitigan

| Riesgo | Mitigación |
|---|---|
| **Salidas inventadas.** Nadie corre el proyecto y las piezas transcriben salidas plausibles pero falsas. Es el fallo más probable y el que destruye la credibilidad del track. | El formato lo prohíbe (§1) y el checklist lo audita. Aun así: **P8 no lo puede detectar**. La única defensa real es correr al menos las piezas de F3, F5, F8 y F10 contra el proyecto. Es trabajo tuyo, no del chat. |
| **La pieza se vuelve un resumen de la fase.** El fallo estructural típico. | Tabla de frontera obligatoria (§5 del formato) y el ítem de checklist "no repite la sección 6". |
| **IDs de incidente descoordinados** entre las reservas de las fases y el índice del cuaderno. | Las reservas se escriben en P5 (junto a la pieza), el índice se crea completo en el primer pase de P6, y P8 los cruza en los dos sentidos. |
| **Se rompe el contrato** al escribir un incidente de costura. | Ítem 5 de P8, y `00-audit-contrato.md` en la lista de lectura obligatoria de P6. |
| **Deriva de tono** a lo largo de 27 archivos escritos en ~10 chats. | Cada chat arranca leyendo los dos formatos y la guía. Y la pasada de tuteo de §4.7 al final, que en este material es más peligrosa que de costumbre: los tickets están escritos en voz de usuario y ahí es donde se cuela el voseo. |
| **Tocar `03-mock-api-minima.md`**, que está publicada. | Solo si apruebas D2. La edición es estrictamente aditiva: sección nueva + ejercicios 🔥 al final. Ninguna línea existente cambia, ningún ejercicio se renumera. |

---

## 10. ✅ Checklist para tu aprobación

- [ ] **D1** — piezas en archivo aparte (recomendado) / inline
- [ ] **D2** — inyector de caos en `03-mock-api-minima.md`: sí (recomendado) / no
- [ ] **D3** — un cuaderno por curso (recomendado) / uno compartido
- [ ] **D4** — 3 piezas de ruta (recomendado) / 15 / 1
- [ ] **D5** — 12 piezas en el Curso 02 (recomendado) / 16
- [ ] **D6** — 12 + 12 incidentes (recomendado) / 20 + 20 / 15 + 10
- [ ] El tono de la muestra §8.1 es el correcto
- [ ] El orden de las seis tandas se aprueba tal cual
- [ ] ¿Arrancamos por **P1** (los dos formatos), o prefieres ver antes un `forense-master.md`
      completo para juzgar el track con una pieza real en la mano?

> 🪦 **Recordatorio:** cuando P1 y P2 estén cerrados, este archivo se borra.
DOCEOF
wc -l contenido_forense.md

# --- 2026-09-09T02:59:19 · Check tag blocks in all phases
echo "=== ¿Las fases llevan el bloque 🏷️? (guía §9.1) ==="
for f in 01-vue2-legacy/0[0-9]*.md 01-vue2-legacy/1[01]*.md 01-vue2-legacy/[qvn][0-9x]*.md 02-complement-mongodb-backend/[0-9]*.md; do
  n=$(grep -c '🏷️' "$f"); t=$(grep -o 'git tag -a [a-z0-9-]*' "$f" | head -1)
  printf '%-46s 🏷️:%-3s %s\n' "$(basename $f)" "$n" "$t"
done

# --- 2026-09-09T02:59:28 · Outline angular-16 git convention
cd ../angular-16-legacy-for-backend-devs && wc -l 00-convencion-de-git-y-tags.md && grep -n '^#\{1,3\} ' 00-convencion-de-git-y-tags.md && echo "=== namespaces de tag usados ===" && grep -o 'git tag -a [a-z0-9/<>-]*' 00-convencion-de-git-y-tags.md | sort -u

# --- 2026-09-09T02:59:30 · Outline vue2 git convention
cd ../vue2-legacy-for-backend-devs && grep -n '^#\{1,3\} ' prompts/convencion-de-git-y-tags.md && echo "=== namespaces ===" && grep -oE '(git tag -a|git switch -c|git branch) [a-zA-Z0-9/<>._-]*' prompts/convencion-de-git-y-tags.md | sort -u

# --- 2026-09-09T02:59:42 · Read the three missing sections
cd ../angular-16-legacy-for-backend-devs && sed -n '297,382p' 00-convencion-de-git-y-tags.md

# --- 2026-09-09T02:59:45 · Check appendices and debt tags
cd ../vue2-legacy-for-backend-devs && echo "=== apéndices con 🏷️ (no deberían) ===" && for f in 01-vue2-legacy/a[0-9]*.md 02-complement-mongodb-backend/a[0-9]*.md; do printf '%-40s %s\n' "$(basename $f)" "$(grep -c '🏷️' $f)"; done && echo "=== ¿existe algún tag deuda/ o pago de deuda en git? ===" && grep -rn 'deuda/' --include=*.md . | head

# --- 2026-09-09T02:59:59 · Check debt ledger and db.json handling
grep -rn 'SECURITY-NOTES\|deuda.md\|DEUDAS' 01-vue2-legacy/*.md 02-complement-mongodb-backend/*.md prompts/*.md README.md 2>/dev/null | head -15; echo "=== db.json en curso 01 ==="; grep -rn 'db.json' 01-vue2-legacy/03-mock-api-minima.md | head -6; echo "=== seed ==="; grep -rn 'npm run seed\|seed.js' 01-vue2-legacy/*.md 02-complement-mongodb-backend/*.md | head -6

# --- 2026-09-09T03:01:14 · Insert new section 3 and renumber
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/8654ffa2-c3be-4e38-8c48-f270a0c7e8e8/scratchpad/sec3.md <<'SECEOF'
## 3. 🏷️ Corrección previa: la convención de git y tags

Antes de tocar nada forense hay que cerrar esto, por una razón práctica: **el cuaderno de
incidentes y las piezas forenses se apoyan en tags que hoy no están definidos.** Un
incidente se prepara con `git switch -c incidente/07 fase-04`, se cierra con el par
`inc/…-roto` / `-fix`, y su solución de referencia dice "esta deuda se paga en la Fase N"
— tres cosas que necesitan una convención completa antes de escribirse.

### 3.1 Lo que ya está bien, y conviene decirlo

Revisé las 38 fases y los 10 apéndices, uno a uno:

- **Las 38 fases llevan su bloque 🏷️**, con el tag correcto (`fase-` + el slug exacto del
  archivo): `fase-04-dashboard-tickets`, `fase-q2-migrar-crud-qform`,
  `fase-12-el-backend-habla`. Sin una sola excepción.
- **Los 10 apéndices no lo llevan**, exactamente como manda §9.1 de la guía.
- Ya están definidos: un repo por curso, los prefijos de commit (`f04:`, `q2:`, `nx0:`),
  los tags de ejercicio `ej/f07/22`, el par de incidente `inc/<fase>/<slug>-roto|-fix` y
  los puntos de retorno de las rutas.

> 🧭 **Esto no es un adorno del informe.** En el aparato forense el paquete Vue va por
> detrás de Angular; en la convención de tags va **por delante**, porque Angular la
> aplica en su documento y aquí además está instanciada en las 38 fases. La corrección
> que sigue es aditiva: no se toca ni un bloque 🏷️ existente.

### 3.2 Lo que falta: tres secciones y dos comandos

`prompts/convencion-de-git-y-tags.md` tiene **243 líneas**; el homólogo de Angular 16
(`00-convencion-de-git-y-tags.md`) tiene **427**. La diferencia no es verborrea: son tres
secciones completas y dos comandos.

| Falta aquí | Qué es en Angular | ¿Aplica al paquete Vue? |
|---|---|---|
| **§💸 La deuda que sí se paga (y cómo se lee la factura)** | El namespace `deuda/<slug>-pagada` y el `git diff <tag-origen> <tag-pago> -- <ruta>` como material de repaso | **Sí, y más que en Angular.** Ver §3.3 |
| **§🧹 El `db.json` que se ensucia** | La diferencia entre `git checkout -- db.json` y `npm run seed`, y el hábito de commitear escenarios | **Sí, y es prerrequisito del cuaderno.** Ver §3.4 |
| **§🐳 Etiquetar la imagen con el tag de git** | Que la imagen no se llame `:latest`, para poder saber qué código corre dentro | **Sí**, en el Curso 02 (`14-operacion.md`, `a01-docker.md`) |
| `git checkout <tag> -- <ruta>` | Recuperar un archivo de una fase anterior sin moverte de sitio | Sí |
| `git switch -c incidente/NN fase-NN` | Arrancar un incidente desde la fase que lo produce | **Sí — el cuaderno lo necesita literalmente** |

### 3.3 La sección de deuda es la que más falta aquí — y no se puede copiar tal cual

**Por qué falta más aquí.** En Angular la deuda es un tema; en el paquete Mini Jira es
**el mecanismo que une los dos cursos**. El README lo dice sin rodeos: *"El Curso 01 deja
deudas declaradas 💸 que el Curso 02 paga […] Ese cobro es buena parte del contenido del
Curso 02."* Hay 💸 declaradas en F0 (Stubby), F2 (login síncrono y `localStorage`), F6
(validador duplicado), F8 (el cliente mentiroso), NX1, NX4 y varias más — y una fase
entera del Curso 02, `11-auth-real-y-pago-de-deudas.md`, dedicada a cobrarlas.

**Por qué no se copia tal cual.** Angular resuelve el pago con
`git diff fase-01 fase-05 -- src/app/shared`, y eso funciona porque **tiene un solo
repositorio**. Aquí la deuda estrella —el cliente mentiroso de
`08-websockets-minimos.md:231`— se declara en el repo del Curso 01 y se paga en el repo
del Curso 02 (`12-el-backend-habla.md`). **Ese `git diff` no existe**, y Angular nunca
tuvo que resolver el problema.

**Propuesta.** Dos tags hermanos, uno en cada repo, que se nombran mutuamente en el
mensaje:

```bash
# Repo del Curso 01, cuando la deuda se declara (o al cerrar la fase que la declara):
git tag -a deuda/cliente-mentiroso-declarada -m "F8: el cliente emite ticket:updated
que debería emitir el servidor. Se paga en el repo mini-jira-api, Curso 02 Fase 12."

# Repo del Curso 02, en el commit que la salda:
git tag -a deuda/cliente-mentiroso-pagada -m "F12: io.emit sale del servidor tras el
write. Cierra deuda/cliente-mentiroso-declarada del repo mini-jira-front (F8)."
```

Con eso, `git tag -n99 -l 'deuda/*'` en cada repo devuelve **su mitad del libro mayor**, y
los dos mensajes juntos son la factura completa. Donde la deuda sí nace y muere en el
mismo repo —el login síncrono de F2, que se paga en F3— el `git diff` de Angular funciona
igual y se conserva.

Y engancha con algo que **ya existe y hoy no tiene mecánica**: `SECURITY-NOTES.md`, el
documento vivo que el Curso 01 acumula desde la Fase 2 y que el Curso 02 manda tachar en
`11-auth-real-y-pago-de-deudas.md` (ejercicio 7: *"tacha la primera deuda con el commit
que la resolvió referenciado. El ritual importa."*). El tag `deuda/…-pagada` es
exactamente ese commit, con nombre y localizable. Hoy el ejercicio pide referenciar un
commit que hay que buscar a mano.

### 3.4 El `db.json` ya está medio resuelto, y en el sitio equivocado

`db.seed.json` y el script `mock:reset` existen: los crea el **ejercicio 14 de la Fase 3**
(`03-mock-api-minima.md:706`) y reaparecen en una línea de `a3-npm.md:108`. Pero la
distinción que de verdad importa no está escrita en ninguna parte del paquete:

- `git checkout -- db.json` → te devuelve el archivo **como lo commiteaste**, con tus
  escenarios dentro.
- `npm run mock:reset` → lo **pisa entero**, y se lleva por delante cualquier caso de
  prueba que hubieras construido a mano.

Que eso viva en un ejercicio y no en la convención tiene una consecuencia concreta: **la
forma de preparación nº 2 del cuaderno de incidentes** (`db.incidente-NN.json`) es
precisamente "un escenario guardado con nombre". Sin el hábito de commitear escenarios, el
estudiante llega al cuaderno reconstruyéndolos a mano cada vez.

### 3.5 Decisión

Ver **D0** en §5.

---
SECEOF
python3 - <<'PY'
import io,re
p='contenido_forense.md'
s=open(p,encoding='utf-8').read()
new=open('/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/8654ffa2-c3be-4e38-8c48-f270a0c7e8e8/scratchpad/sec3.md',encoding='utf-8').read()
# renumerar 3..10 -> 4..11 (de mayor a menor)
ren=[("## 10. ✅ Checklist para tu aprobación","## 11. ✅ Checklist para tu aprobación"),
     ("## 9. ⚠️ Riesgos, y cómo se mitigan","## 10. ⚠️ Riesgos, y cómo se mitigan"),
     ("## 8. 🧪 Ejemplos concretos, para que juzgues el tono","## 9. 🧪 Ejemplos concretos, para que juzgues el tono"),
     ("### 8.1 Muestra de incidente","### 9.1 Muestra de incidente"),
     ("### 8.2 Muestra de pieza forense","### 9.2 Muestra de pieza forense"),
     ("## 7. 🎬 Los prompts","## 8. 🎬 Los prompts"),
     ("## 6. 🗺️ Plan de acción — seis tandas","## 7. 🗺️ Plan de acción — siete tandas"),
     ("## 5. 📦 Inventario de entregables (con D1–D6 en su valor recomendado)","## 6. 📦 Inventario de entregables (con D0–D6 en su valor recomendado)"),
     ("## 4. 🗳️ Decisiones que necesito de ti","## 5. 🗳️ Decisiones que necesito de ti"),
     ("## 3. ⚖️ Lo que NO se copia de Angular","## 4. ⚖️ Lo que NO se copia de Angular")]
for a,b in ren:
    assert s.count(a)==1,(a,s.count(a))
    s=s.replace(a,b)
# insertar la nueva sección 3
anchor="## 4. ⚖️ Lo que NO se copia de Angular"
s=s.replace(anchor,new+"\n"+anchor,1)
# referencias internas al tono de la muestra
s=s.replace("El tono de la muestra §8.1","El tono de la muestra §9.1")
s=s.replace("la muestra §8.1","la muestra §9.1")
open(p,'w',encoding='utf-8').write(s)
print("ok")
PY

# --- 2026-09-09T03:01:46 · Add D0, tanda 0, inventory and checklist updates
python3 - <<'PY'
p='contenido_forense.md'
s=open(p,encoding='utf-8').read()

# --- 1. intro de decisiones + D0
old="Seis. Cada una lleva mi recomendación; marca la que quieras o escribe otra cosa.\n\n### D1"
new="""Siete. Cada una lleva mi recomendación; marca la que quieras o escribe otra cosa.

### D0 — ¿Se completa antes `prompts/convencion-de-git-y-tags.md`?

- **(a) Sí, y primero** — se le añaden las tres secciones que faltan (§💸 deuda pagada con
  el mecanismo de dos repos, §🧹 el `db.json` que se ensucia, §🐳 la imagen etiquetada) y
  los dos comandos, antes de escribir una línea de material forense.
- (b) Solo la parte que el cuaderno necesita (`git switch -c incidente/NN fase-NN` y el
  `db.json`), y la deuda se deja para después.
- (c) No se toca; el cuaderno se escribe con lo que hay.

> ✅ **Recomiendo (a).** No es una mejora cosmética: el cuaderno **se apoya** en tags que
> hoy no están definidos, y la sección de deuda es la que convierte la promesa central del
> paquete —*"el Curso 02 paga las deudas del Curso 01"*— en algo que el estudiante puede
> **verificar con un comando** en vez de creerse. Además es la corrección más barata de
> todo el plan: un archivo, ~120 líneas nuevas, cero riesgo de contradecir nada.

### D1"""
assert s.count(old)==1
s=s.replace(old,new)

# --- 2. inventario: añadir la línea de la convención
old="""│   └── plantilla-de-fase.md                ✏️  sección 6: línea 📄 + bloque de reservas"""
new="""│   └── plantilla-de-fase.md                ✏️  sección 6: línea 📄 + bloque de reservas
│   └── convencion-de-git-y-tags.md         ✏️  +3 secciones y 2 comandos  (D0, va PRIMERO)"""
assert s.count(old)==1
s=s.replace(old,new)

# --- 3. tabla de tandas
old="""| # | Tanda | Entregable | Prompt | Depende de |
|---|---|---|---|---|
| 1 | **Los formatos**"""
new="""| # | Tanda | Entregable | Prompt | Depende de |
|---|---|---|---|---|
| 0 | **La convención** | `prompts/convencion-de-git-y-tags.md` completado | **P0** | D0 |
| 1 | **Los formatos**"""
assert s.count(old)==1
s=s.replace(old,new)

old="""El orden no es negociable en los tres primeros pasos: la especificación antes que el
entregable, y el índice de síntomas antes que las piezas."""
new="""El orden no es negociable en los cuatro primeros pasos: **la convención de git antes que
todo**, porque los otros entregables la citan; después la especificación antes que el
entregable, y el índice de síntomas antes que las piezas."""
assert s.count(old)==1
s=s.replace(old,new)

# --- 4. nota tras la tabla
old="""> 🧭 **Por qué las puertas (tanda 3) van antes que las piezas (tanda 5).**"""
new="""> 🧭 **Por qué la convención (tanda 0) va antes que todo.** El cuaderno prepara sus
> incidentes con `git switch -c incidente/07 fase-04`, los cierra con
> `inc/<fase>/<slug>-roto|-fix`, y sus soluciones de referencia dicen *"esta deuda se paga
> en la Fase N"*. Si esos tres mecanismos no están definidos cuando se escribe el formato
> del cuaderno (tanda 1), el formato los inventa a su manera y hay que rehacerlo. Es la
> tanda más barata del plan y la que evita más retrabajo.

> 🧭 **Por qué las puertas (tanda 3) van antes que las piezas (tanda 5).**"""
assert s.count(old)==1
s=s.replace(old,new)

# --- 5. checklist
old="- [ ] **D1** — piezas en archivo aparte (recomendado) / inline"
new="""- [ ] **D0** — completar `convencion-de-git-y-tags.md` primero (recomendado) / solo lo
      mínimo / no tocarla
- [ ] El mecanismo de deuda a dos repos de §3.3 (`deuda/<slug>-declarada` + `-pagada`) es
      correcto, o prefieres otro
- [ ] **D1** — piezas en archivo aparte (recomendado) / inline"""
assert s.count(old)==1
s=s.replace(old,new)

old="""- [ ] ¿Arrancamos por **P1** (los dos formatos), o prefieres ver antes un `forense-master.md`
      completo para juzgar el track con una pieza real en la mano?"""
new="""- [ ] ¿Arrancamos por **P0** (la convención de git, recomendado), o prefieres ver antes un
      `forense-master.md` completo para juzgar el track con una pieza real en la mano?"""
assert s.count(old)==1
s=s.replace(old,new)

# --- 6. cabecera: la §3 sobrevive en otro archivo
old="""> y `prompts/formato-cuaderno-incidentes.md`), **este archivo se borra**: todo lo que
> deba sobrevivir tiene que haber migrado a esos dos."""
new="""> y `prompts/formato-cuaderno-incidentes.md`), **este archivo se borra**: todo lo que
> deba sobrevivir tiene que haber migrado a esos dos — y lo de §3, a
> `prompts/convencion-de-git-y-tags.md`."""
assert s.count(old)==1
s=s.replace(old,new)

open(p,'w',encoding='utf-8').write(s)
print("ok")
PY

# --- 2026-09-09T03:02:42 · Insert P0 prompt and verify structure
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/8654ffa2-c3be-4e38-8c48-f270a0c7e8e8/scratchpad/p0.md <<'P0EOF'
### P0 · Completar la convención de git y tags  ⬅️ **la primera corrección, antes de forense**

```
Lee completos:
- prompts/convencion-de-git-y-tags.md          ← el archivo que vas a editar
- prompts/guia-de-estilo-y-convenciones.md     ← §9.1 (el bloque 🏷️) y §14 (post-mortem)
- README.md (raíz del paquete)                 ← las deudas 💸 que un curso le pasa al otro
- 01-vue2-legacy/03-mock-api-minima.md         ← db.json, db.seed.json y el script mock:reset
- 02-complement-mongodb-backend/11-auth-real-y-pago-de-deudas.md  ← el ritual de SECURITY-NOTES.md
- ../angular-16-legacy-for-backend-devs/00-convencion-de-git-y-tags.md
  ← SOLO como referencia de qué secciones merecen existir. NO se copia: aquel curso tiene
    UN repositorio y este paquete tiene DOS, y esa diferencia cambia el mecanismo.

Amplía prompts/convencion-de-git-y-tags.md. Es una edición ADITIVA: no reescribas ni
reordenes las secciones que ya están (📦 un repo por curso · 💬 mensajes de commit ·
🏷️ un tag por fase · puntos de retorno de las rutas · 🧪 tags de ejercicios ·
🚑 incidentes · 📈 comandos · ✅ checklist). Las 38 fases ya llevan su bloque 🏷️ con el
tag correcto: NO cambies el formato del bloque ni el esquema de nombres `fase-` + slug.

Añade TRES secciones nuevas y DOS comandos.

────────────────────────────────────────────────────────────────────────
1) «## 💸 La deuda que sí se paga (y cómo se lee la factura)»
   Va después de «🚑 Incidentes» y antes de «📈 Los comandos».

   Es la sección más importante de esta ampliación, porque la deuda declarada es el
   mecanismo que une los dos cursos de este paquete. Tiene que cubrir DOS casos, y la
   distinción entre ambos es el contenido:

   a) Deuda que nace y muere en el MISMO repo — el login síncrono de la Fase 2, que se
      paga en la Fase 3 del Curso 01. Aquí el diff entre los dos tags de fase es el
      material de repaso, tal cual:
         git diff fase-02-autenticacion-minima fase-03-mock-api-minima -- src/store
      Explica que no es una métrica: es la respuesta a «¿cuánto costó de verdad arreglar
      esto?», que es la pregunta que te harán la próxima vez que propongas pagar una deuda
      en un sistema real.

   b) Deuda que CRUZA los dos repos — el caso propio de este paquete y el que ningún
      curso de Angular tuvo que resolver. La deuda estrella: el «cliente mentiroso» de
      08-websockets-minimos.md (el cliente emite el evento de socket que debería emitir el
      servidor), declarado en el repo del Curso 01 y pagado en el repo del Curso 02, en
      12-el-backend-habla.md. `git diff` NO puede cruzar repositorios: dilo explícitamente,
      porque el lector va a intentarlo.
      La solución son dos tags hermanos que se nombran mutuamente en el mensaje:

         # Repo del Curso 01, al cerrar la fase que declara la deuda:
         git tag -a deuda/cliente-mentiroso-declarada -m "F8: el cliente emite
         ticket:updated, que debería emitir el servidor. Se paga en el repo del Curso 02,
         Fase 12."

         # Repo del Curso 02, en el commit que la salda:
         git tag -a deuda/cliente-mentiroso-pagada -m "F12: el io.emit sale del servidor
         después del write. Cierra deuda/cliente-mentiroso-declarada del repo del Curso 01
         (F8)."

      Y el comando que devuelve cada mitad del libro mayor:
         git tag -n99 -l 'deuda/*'
      Los dos mensajes juntos son la factura completa: el que declara dice qué se debe y
      dónde se paga; el que paga dice qué cerró y de dónde venía.

   c) El enganche con SECURITY-NOTES.md, que YA EXISTE en el paquete y hoy no tiene
      mecánica. El Curso 01 lo acumula desde la Fase 2, y el ejercicio 7 de
      11-auth-real-y-pago-de-deudas.md pide «tachar la deuda con el commit que la resolvió
      referenciado». El tag `deuda/…-pagada` ES ese commit, con nombre y localizable: hoy
      el ejercicio manda buscar un commit a mano. Dilo en dos frases y enlaza la fase.

   d) Cierra con el reflejo transferible: `git log -S "<identificador>"` para preguntarle
      a la historia del repo cuándo entró o desapareció una línea, con dos ejemplos del
      dominio (por ejemplo `git log --oneline -S "socket.emit"` y
      `git log --oneline -S "Vue.set"`). Sirve tal cual en cualquier sistema heredado.

────────────────────────────────────────────────────────────────────────
2) «## 🧹 El `db.json` que se ensucia (el truco que más vas a usar)»
   Va después de la sección de deuda.

   json-server escribe de verdad: después de media hora de ejercicios el `db.json` es un
   campo de batalla y ya no se puede reproducir el caso limpio del enunciado. Hay dos
   formas de volver y NO son la misma — ésta es toda la sección:

      git checkout -- db.json     # te devuelve el archivo como lo commiteaste, CON tus escenarios
      npm run mock:reset          # lo pisa entero desde db.seed.json, y se los lleva por delante

   `db.seed.json` y el script `mock:reset` ya existen: los crea el ejercicio 14 de la
   Fase 3 y reaparecen en a3-npm.md. No los reinventes: cítalos.

   El corolario es el hábito: cuando un ejercicio pida un dato particular —un ticket sin
   el campo `tags`, dos agentes con el mismo ticket asignado, un comentario huérfano cuyo
   ticket ya no existe—, cárgalo, commitéalo como escenario
   (`git commit -m "f05 ej22: escenario de ticket sin tags"`) y etiquétalo si vas a
   volver. Reconstruir a mano un escenario que ya tuviste es el peor uso posible de tu
   tiempo. Y añade la frase que lo conecta con el cuaderno: los `db.incidente-NN.json`
   del cuaderno de incidentes son exactamente eso, guardados con nombre.

   Menciona en una línea el equivalente del Curso 02: ahí el estado sucio no está en un
   archivo sino en la base, y se vuelve con `npm run seed` (02-consultar-tu-sql-traducido)
   o levantando el contenedor de cero (a01-docker).

────────────────────────────────────────────────────────────────────────
3) «## 🐳 Una cosa más, para cuando llegues a la Fase 14 del Curso 02»
   Corta, media página.

   La imagen que se construye en 14-operacion.md no debe quedarse en `:latest`: con
   `:latest` no sabes qué código estás corriendo. Etiquétala con el mismo nombre del tag
   de git que la produjo, y podrás empezar cualquier diagnóstico de «en mi máquina
   funciona» sabiendo QUÉ HAY ADENTRO — que es la mitad barata del diagnóstico, y la que
   casi nadie tiene. Enlaza a a01-docker.md y a 14-operacion.md; no reexpliques Docker.

────────────────────────────────────────────────────────────────────────
4) Dos comandos nuevos en «## 📈 Los comandos que hacen que esto sirva», con su
   comentario en español, en el estilo de los que ya están:

      # Recuperar un archivo de una fase anterior sin moverte de sitio
      git checkout fase-05-crud-tickets -- src/components/tickets/TicketForm.vue

      # Arrancar un incidente desde la fase que lo produce
      git switch -c incidente/07 fase-04-dashboard-tickets

   El segundo es el que va a usar el cuaderno de incidentes en cada preparación: déjalo
   escrito con el nombre completo del tag, no con un placeholder.

────────────────────────────────────────────────────────────────────────
5) Añade al «## ✅ Checklist de cierre de fase» dos ítems, sin tocar los que ya están:
   - [ ] Si la fase DECLARA una deuda 💸, tiene su tag `deuda/<slug>-declarada` y el
         mensaje dice en qué curso y fase se paga.
   - [ ] Si la fase PAGA una deuda, tiene su tag `deuda/<slug>-pagada`, el mensaje nombra
         al tag hermano, y SECURITY-NOTES.md quedó tachado.

────────────────────────────────────────────────────────────────────────
Reglas de forma: español latinoamericano con tuteo y cero voseo; código y nombres de tag
en inglés cuando el identificador lo es, pero los SLUGS de los tags siguen el patrón que
ya usa el archivo; comentarios de los bloques bash en español. Prosa antes que listas.
Cada sección explica el PORQUÉ antes del comando. No inventes rutas de archivo: cita solo
las que existen — verifica cada `.md` que menciones (guía §13.2).

Al terminar, dime en tres líneas: qué secciones añadiste, cuántas líneas tiene ahora el
archivo, y si encontraste alguna contradicción con lo que ya estaba escrito.
```

---

P0EOF
python3 - <<'PY'
p='contenido_forense.md'
s=open(p,encoding='utf-8').read()
new=open('/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/8654ffa2-c3be-4e38-8c48-f270a0c7e8e8/scratchpad/p0.md',encoding='utf-8').read()
a="### P1 · Los dos documentos de formato"
assert s.count(a)==1
s=s.replace(a,new+a,1)
open(p,'w',encoding='utf-8').write(s)
PY
wc -l contenido_forense.md && grep -n '^## [0-9]\|^### P[0-9]\|^### D[0-9]' contenido_forense.md

# --- 2026-09-09T03:02:57 · Patch P1, P2 and add risk row
python3 - <<'PY'
p='contenido_forense.md'
s=open(p,encoding='utf-8').read()

old="- prompts/convencion-de-git-y-tags.md (sobre todo §🚑 Incidentes)"
new="""- prompts/convencion-de-git-y-tags.md, YA COMPLETADO POR P0 (sobre todo §🚑 Incidentes,
  §💸 la deuda que sí se paga y §🧹 el db.json que se ensucia)"""
assert s.count(old)==1
s=s.replace(old,new)

old="""6. convencion-de-git-y-tags.md — en §🚑, sustituye la frase que dice que
   `git tag -n99 -l 'inc/*'` «te devuelve el cuaderno de incidentes entero» por una que
   enlace al cuaderno real de cada curso y explique la relación: el archivo es el
   enunciado y tu investigación; los tags son tu bitácora ejecutable."""
new="""6. convencion-de-git-y-tags.md — este archivo ya lo amplió P0; aquí solo se toca UNA
   frase. En §🚑, sustituye la que dice que `git tag -n99 -l 'inc/*'` «te devuelve el
   cuaderno de incidentes entero» por una que enlace al cuaderno real de cada curso y
   explique la relación: el archivo es el enunciado y tu investigación; los tags son tu
   bitácora ejecutable. No toques las secciones que añadió P0."""
assert s.count(old)==1
s=s.replace(old,new)

# riesgo nuevo
old="""| **Tocar `03-mock-api-minima.md`**, que está publicada."""
new="""| **P0 y P2 tocan el mismo archivo.** `convencion-de-git-y-tags.md` lo amplía P0 y le cambia una frase P2. | El orden de las tandas lo resuelve (P0 va primero) y P2 lleva escrito «no toques las secciones que añadió P0». Si inviertes el orden, P0 pisa el cambio de P2. |
| **Tocar `03-mock-api-minima.md`**, que está publicada."""
assert s.count(old)==1
s=s.replace(old,new)
open(p,'w',encoding='utf-8').write(s)
print('ok')
PY
grep -c '' contenido_forense.md

# --- 2026-09-09T03:13:30 · Check appendix tags and exercise tag section
cd ../angular-16-legacy-for-backend-devs && echo "=== A16: apéndices en la convención ===" && grep -n -i 'apéndice\|apendice\|a09\|a12' 00-convencion-de-git-y-tags.md | head -10
echo; echo "=== A16 §🧪 tags de ejercicios ===" && sed -n '195,249p' 00-convencion-de-git-y-tags.md
echo; echo "=== A8 outline ===" && grep -n '^#\{1,3\} ' ../angular-8-legacy-for-backend-devs/00-convencion-de-git-y-tags.md

# --- 2026-09-09T03:13:44 · Read vue exercise tag section and check gaps
cd ../vue2-legacy-for-backend-devs && sed -n '124,175p' prompts/convencion-de-git-y-tags.md && echo "=== prefijo apéndice / apendice- / refs ===" && grep -n -i 'apéndice\|apendice\|refs/tags\|-roto' prompts/convencion-de-git-y-tags.md | head

# --- 2026-09-09T03:15:36 · Rewrite doc part 1
cat > contenido_forense.md <<'PART1'
# 🕵️ Contenido forense para el paquete Mini Jira — plan de ejecución

> ⚠️ **Documento desechable.** Es material de trabajo. Cuando P0, P1 y P2 estén cerrados,
> **este archivo se borra**: lo de §3 tiene que haber migrado a
> `prompts/convencion-de-git-y-tags.md`, y el resto a `prompts/formato-piezas-forenses.md`
> y `prompts/formato-cuaderno-incidentes.md`.
>
> Fecha: 2026-09-08 · Alcance: `vue2-legacy-for-backend-devs/` (Cursos 01 y 02)
> Referencia comparativa: `angular-16-legacy-for-backend-devs/` y `angular-8-legacy-for-backend-devs/`
>
> **Estado: decisiones D0–D6 cerradas** (§5). Este documento ya no propone: ejecuta.

---

## 1. 🔍 Qué hay hoy, con evidencia

### 1.1 El aparato forense de los cursos Angular

Los dos cursos de Angular tienen **el mismo aparato**, en tres piezas:

| Pieza | Angular 8 | Angular 16 | Qué hace |
|---|---|---|---|
| `forense-master.md` | ✅ | ✅ (112 líneas) | Puerta de entrada: el método de cuatro preguntas y el 🩺 **índice de síntomas transversal** |
| `forense-fase-NN.md` | ✅ ×15 | ✅ ×15 (~200 líneas c/u) | El recorrido completo de una investigación, paso a paso, con salidas literales |
| `cuaderno-incidentes.md` | ✅ | ✅ (3.916 líneas, 20 incidentes) | Tickets vagos con pistas plegadas, espacio para tu investigación y solución de referencia |
| `prompts/formato-piezas-forenses.md` | ✅ | ✅ | La **especificación** de las piezas |
| `prompts/formato-cuaderno-incidentes.md` | ❌ | ✅ | La **especificación** del cuaderno |

Y una cuarta pieza que no es un archivo sino un hábito: cada fase de Angular cierra con
un bloque **`### Reservas para el cuaderno de incidentes`** donde reserva los IDs que
saldrán de ella. Ese bloque es lo que evita que el cuaderno se escriba al final, de
memoria y desconectado de las fases.

### 1.2 El aparato forense del paquete Vue 2

| | Curso 01 · Vue 2 | Curso 02 · Mongo/Express |
|---|---|---|
| `forense-master.md` | ❌ | ❌ |
| `forense-fase-NN.md` | ❌ | ❌ |
| `cuaderno-incidentes.md` | ❌ | ❌ |
| Sección 6 con **pieza forense** inline | **0 de 17 fases** | **4 de 16 fases** |
| Bloque de reservas de IDs | ❌ | ❌ |

El detalle de la sección 6, fase por fase:

**Curso 01 — las 17 fases cortan en `## ⚠️ Errores comunes`**, sin pieza forense.
Ninguna excepción. (`00`…`11`, `q0`…`q4`, `vu0`…`vu4`, `nx0`…`nx4`; `02` usa
`## ⚠️ Consideraciones de seguridad`, `nx1` y `q1` variantes del mismo encabezado.)

**Curso 02 — cumplen 4 de 16:**

| Fase | Encabezado | Pieza |
|---|---|---|
| `02-consultar-tu-sql-traducido.md:346` | `## ⚠️ Errores comunes y pieza forense` | ✅ |
| `09-aggregation.md:444` | idem | ✅ `🩻 "mi GROUP BY devuelve UNA fila"` |
| `10-express-el-vehiculo.md:499` | idem | ✅ `🩻 el request que no vuelve` |
| `13-testing-de-api.md:345` | idem | ✅ `🩻 "verde en mi máquina, rojo en CI"` |
| `00-preliminares.md:483` | `## ⚠️ Errores comunes` | ⚠️ solo un callout `🔎 Pieza forense de la fase` |
| Las otras 11 | `## ⚠️ Errores comunes` | ❌ |

---

## 2. 🧨 El argumento: tres bucles que el paquete abrió y no cerró

El paquete Vue 2 **ya prometió** el aparato forense en sus tres documentos rectores, y los
tres apuntan a la nada. No estamos importando una idea de Angular: estamos entregando lo
que este paquete ya facturó.

**Bucle 1 — la plantilla obligatoria.** `prompts/plantilla-de-fase.md:99-112` define
literalmente:

```
## ⚠️ Errores comunes y pieza forense
### Pieza forense de esta fase
{{Qué depurar, específico de esta fase: consola, Network, Vue DevTools, o
—en el Curso 02— logs, profiler y `explain()`. Incluir al menos un ejercicio
de "rompe a propósito y observa".}}
```

Y la guía de estilo §9 la declara **obligatoria**: *"Toda fase produce un `.md` con
exactamente estas nueve secciones, en orden."* **29 de 33 fases la incumplen.** El
checklist de cierre de §15 tampoco la audita, así que el incumplimiento nunca se detectó.

**Bucle 2 — el post-mortem de ocho puntos.** La guía de estilo §14 define una estructura
completa —síntoma, repro, evidencia, causa raíz, corrección, prueba de regresión,
prevención, análisis sin culpabilización— y dice: *"Cada incidente sigue esta estructura
de ocho puntos"*. **No existe ni un incidente en todo el paquete.**

**Bucle 3 — el que más duele.** `prompts/convencion-de-git-y-tags.md:172-208` dedica una
sección entera (`## 🚑 Incidentes: acá el tag sí es contenido`) al par
`inc/<fase>/<slug>-roto` / `-fix`, con ejemplos redactados, y remata:

> *"`git tag -n99 -l 'inc/*'` te devuelve **el cuaderno de incidentes** entero."*

**Ese cuaderno no existe.** El comando devuelve vacío.

Y un cuarto argumento, de fondo: la guía §10 exige que **al menos un tercio de los
ejercicios sean de diagnóstico** — *"es el músculo que este paquete entrena"*. Hoy ese
músculo se entrena disperso en ~30 bloques de ejercicios, sin método común, sin índice de
síntomas y sin un solo recorrido completo que enseñe **el orden** en que se mira.

---

## 3. 🏷️ Paso 0: completar la convención de git y tags

Va primero, y **en su propio commit, tocando un solo archivo**:
`prompts/convencion-de-git-y-tags.md`. Motivo práctico: el cuaderno de incidentes prepara
sus casos con `git switch -c incidente/07 fase-04-dashboard-tickets`, los cierra con
`inc/<fase>/<slug>-roto|-fix` y sus soluciones dicen *"esta deuda se paga en la Fase N"* —
tres mecanismos que tienen que estar definidos antes de que se escriba el formato del
cuaderno, o el formato los inventa a su manera y hay que rehacerlo.

### 3.1 Lo que ya está bien, y conviene decirlo

Revisé las 38 fases y los 10 apéndices, uno a uno:

- **Las 38 fases llevan su bloque 🏷️**, con el tag correcto (`fase-` + el slug exacto del
  archivo): `fase-04-dashboard-tickets`, `fase-q2-migrar-crud-qform`,
  `fase-12-el-backend-habla`. Sin una sola excepción.
- **Los 10 apéndices no lo llevan**, exactamente como manda §9.1 de la guía.
- La sección **🧪 Tags de ejercicios ya es buena**: tiene el namespace `ej/`, el par
  `-roto`/`-fix` para los ejercicios de diagnóstico, los tags de medición con el número en
  el mensaje, y hasta la advertencia de `refs/tags`. No hay que reescribirla.

> 🧭 En el aparato forense este paquete va por detrás de Angular; en la convención de tags
> va **por delante**, porque aquí además está instanciada en las 38 fases. Por eso el
> Paso 0 es **aditivo**: no se toca ni un bloque 🏷️ existente, ni el esquema de nombres,
> ni la sección de ejercicios salvo para añadirle los apéndices.

### 3.2 Lo que falta

`prompts/convencion-de-git-y-tags.md` tiene **243 líneas**; el homólogo de Angular 16
tiene **427**. La diferencia son cuatro huecos y dos comandos:

| Hueco | En Angular | Por qué aplica aquí |
|---|---|---|
| **Apéndices** | Prefijo de commit `a05:`, tag opcional `apendice-aNN` si el apéndice deja archivos versionados, y `ej/a06/3` en los ejemplos | El paquete tiene 10 apéndices y **ninguno aparece en su convención**: no se dice con qué prefijo se commitea lo que sale de leerlos |
| **§💸 La deuda que sí se paga** | El namespace `deuda/<slug>-pagada` y el `git diff <tag-origen> <tag-pago>` como material de repaso | **Aplica más que en Angular**, y no se puede copiar. Ver §3.3 |
| **§🧹 El `db.json` que se ensucia** | La diferencia entre `git checkout -- db.json` y regenerar la semilla | Ya medio resuelto, y en el sitio equivocado. Ver §3.4 |
| **§🐳 La imagen etiquetada** | Que la imagen no se llame `:latest` | Curso 02, `14-operacion.md` y `a01-docker.md` |
| `git checkout <tag> -- <ruta>` | Recuperar un archivo de una fase anterior sin moverte de sitio | Sí |
| `git switch -c incidente/NN fase-NN-slug` | Arrancar un incidente desde la fase que lo produce | **El cuaderno lo usa en cada preparación** |

Y una cosa que no está en Angular y aquí hace falta: **qué se commitea al recorrer una
pieza forense.** Respuesta corta —y por eso es corta la sección—: una pieza forense no
produce código del proyecto, así que lo que salga de recorrerla lleva el prefijo de su
fase (`f08: …`), y si el recorrido corresponde a un incidente del cuaderno se usa el par
`inc/…` que el cuaderno ya reservó. **No se inventa un namespace `forense/`.**

### 3.3 La deuda: por qué falta más aquí, y por qué no se copia

**Por qué falta más.** En Angular la deuda es un tema; en Mini Jira es **el mecanismo que
une los dos cursos**. El README lo dice: *"El Curso 01 deja deudas declaradas 💸 que el
Curso 02 paga […] Ese cobro es buena parte del contenido del Curso 02."* Hay 💸 en F0
(Stubby), F2 (login síncrono y `localStorage`), F6 (validador duplicado), F8 (el cliente
mentiroso), NX1, NX4 — y una fase entera del Curso 02 dedicada a cobrarlas,
`11-auth-real-y-pago-de-deudas.md`.

**Por qué no se copia.** Angular lee el pago con
`git diff fase-01 fase-05 -- src/app/shared`, y eso funciona porque tiene **un solo
repositorio**. Aquí la deuda estrella —el cliente mentiroso de
`08-websockets-minimos.md:231`— se declara en el repo del Curso 01 y se paga en el del
Curso 02 (`12-el-backend-habla.md`). **Ese `git diff` no existe**, y hay que decirlo
porque el lector va a intentarlo.

**La solución: dos tags hermanos que se nombran mutuamente.**

```bash
# Repo del Curso 01, al cerrar la fase que declara la deuda:
git tag -a deuda/cliente-mentiroso-declarada -m "F8: el cliente emite ticket:updated,
que debería emitir el servidor. Se paga en el repo del Curso 02, Fase 12."

# Repo del Curso 02, en el commit que la salda:
git tag -a deuda/cliente-mentiroso-pagada -m "F12: el io.emit sale del servidor después
del write. Cierra deuda/cliente-mentiroso-declarada del repo del Curso 01 (F8)."
```

`git tag -n99 -l 'deuda/*'` devuelve en cada repo su mitad del libro mayor, y los dos
mensajes juntos son la factura completa. Donde la deuda nace y muere en el mismo repo —el
login síncrono de F2, que se paga en F3— el `git diff` de Angular funciona igual y se
conserva.

Y engancha con algo que **ya existe y hoy no tiene mecánica**: `SECURITY-NOTES.md`. El
ejercicio 7 de `11-auth-real-y-pago-de-deudas.md` pide *"tachar la deuda con el commit que
la resolvió referenciado"* — hoy ese commit hay que buscarlo a mano; el tag
`deuda/…-pagada` **es** ese commit, con nombre.

### 3.4 El `db.json` ya está medio resuelto, y en el sitio equivocado

`db.seed.json` y el script `mock:reset` existen: los crea el **ejercicio 14 de la Fase 3**
(`03-mock-api-minima.md:706`) y reaparecen en una línea de `a3-npm.md:108`. Pero la
distinción que importa no está escrita en ninguna parte del paquete:

- `git checkout -- db.json` → te devuelve el archivo **como lo commiteaste**, con tus
  escenarios dentro.
- `npm run mock:reset` → lo **pisa entero**, y se lleva por delante cualquier caso de
  prueba que hubieras construido a mano.

Que eso viva en un ejercicio y no en la convención tiene una consecuencia concreta: la
**forma de preparación nº 2 del cuaderno** (`db.incidente-NN.json`) es precisamente "un
escenario guardado con nombre". Sin el hábito de commitear escenarios, el estudiante llega
al cuaderno reconstruyéndolos a mano cada vez.

---

## 4. ⚖️ Lo que NO se copia de Angular

Cinco diferencias reales entre los paquetes, que condicionan todo lo que sigue:

1. **El paquete Vue no cuenta horas.** Angular presupuesta *"108h de fases + 14h de
   cuaderno"*; ni el README ni la guía del paquete Vue mencionan horas en ningún sitio.
   **No se inventa un presupuesto horario**: el tamaño se expresa en número de incidentes
   y de piezas.

2. **Son dos cursos independientes, con dos repos.** Y no solo por git: un estudiante
   puede hacer **solo el Curso 01** y no tocar Mongo jamás. Consecuencia dura, que se
   arrastra a los prompts: el cuaderno del Curso 01 **no puede depender** de nada del
   Curso 02, y los incidentes de costura del Curso 02 tienen que ser **autocontenidos** —
   traer el frontend ya construido como punto de partida, no exigir haberlo escrito.

3. **Las tres rutas son opcionales y excluyentes.** `q0`…`q4`, `vu0`…`vu4` y `nx0`…`nx4`
   son alternativas: material opcional sobre material opcional. Por eso su cobertura
   forense es compacta (D4).

4. **El mock de Vue no tiene inyector de caos.** El cuaderno de Angular se apoya en
   `CHAOS=malformed npm run mock` (su fase `03-mock-api-caos.md`) como forma **preferida**
   de romper el sistema. La fase homóloga aquí, `03-mock-api-minima.md`, **solo simula
   latencia** (`setTimeout`, línea 402). Se corrige en el Paso 4 (D2).

5. **La costura entre cursos es contenido forense de primera.** El paquete tiene su
   promesa central —*"se cambia el `baseURL` y la aplicación no se entera"*— y con ella el
   mejor incidente que este material puede escribir: *"apunté el front al Express y el
   dashboard salió vacío, pero `curl` devuelve los tickets"* (el `id` ↔ `_id` de
   `00-audit-contrato.md:105`).

---

## 5. ✅ Decisiones tomadas

Cerradas. Los prompts de §8 ya las traen dentro; esta tabla es la referencia.

| # | Decisión | Consecuencia operativa |
|---|---|---|
| **D0** | **La convención de tags va primero**, como paso 1 y en **un commit limpio que solo la toque**. Alcance **mínimo**: tag de fase y de apéndice, tags sugeridos de ejercicio y de forense, y lo equivalente de Angular 8/16, en el estilo del curso Vue. | P0 toca **un solo archivo**: `prompts/convencion-de-git-y-tags.md`. Nada de guía de estilo, nada de fases. |
| **D1** | **Piezas forenses en archivo aparte**, siguiendo el estilo de los cursos de Angular. | Nacen `forense-master.md` y `forense-fase-NN.md`. La sección 6 de cada fase queda con el resumen y una línea 📄. Hay que declarar la divergencia en la guía §9 (P2). |
| **D2** | **Sí al inyector de caos** en `03-mock-api-minima.md`. | Edición aditiva, sección 🔥 + ejercicios 🔥 al final. Habilita la forma de preparación nº 1 del cuaderno. |
| **D3** | **Un cuaderno por curso.** Los cursos son independientes: el estudiante puede tomar solo el frontend. | IDs por curso, nunca compartidos. El cuaderno del Curso 01 no cita nada del 02. Los incidentes de costura viven en el 02 y son **autocontenidos**. |
| **D4** | **Cobertura de rutas compacta**, porque las rutas ya son opcionales. | Tres piezas: `forense-ruta-q.md`, `forense-ruta-vu.md`, `forense-ruta-nx.md`, ~120 líneas cada una, cubriendo las 5 fases de su ruta. |
| **D5** | **12 piezas en el Curso 02, o todas las necesarias.** | 12 es el **piso**, no el techo. Si una fase se gana la suya al escribirla, se escribe: hasta 16. Lo que no se hace es rellenar por simetría — una pieza sin recorrido propio se convierte en resumen de la fase. |
| **D6** | **24 incidentes**, 12 por cuaderno. | Con las cuotas de categoría de §8/P1. Si uno no consigue causa raíz propia, se retira y su ID no se reasigna. |

---

## 6. 📦 Inventario de entregables

```
vue2-legacy-for-backend-devs/
├── prompts/
│   ├── convencion-de-git-y-tags.md         ✏️  PASO 0 · commit propio, archivo único
│   ├── formato-piezas-forenses.md          🆕  ~180 líneas  · rige los DOS cursos
│   ├── formato-cuaderno-incidentes.md      🆕  ~380 líneas  · rige los DOS cursos
│   ├── guia-de-estilo-y-convenciones.md    ✏️  §9, §13.1, §13.2, §15 + nueva §16
│   └── plantilla-de-fase.md                ✏️  sección 6: línea 📄 + bloque de reservas
│
├── 01-vue2-legacy/
│   ├── forense-master.md                   🆕  ~130 líneas
│   ├── forense-fase-00.md … forense-fase-11.md   🆕  12 piezas × ~200 líneas
│   ├── forense-ruta-q.md / -vu.md / -nx.md 🆕  3 piezas × ~120 líneas        (D4)
│   ├── cuaderno-incidentes.md              🆕  12 incidentes · ~1.900 líneas (D6)
│   ├── 03-mock-api-minima.md               ✏️  + sección 🔥 inyector de caos (D2)
│   ├── (las 17 fases)                      ✏️  sección 6 + línea 📄 + reservas de IDs
│   └── README.md                           ✏️  + bloques 🕵️ Track forense y 📓 Cuaderno
│
└── 02-complement-mongodb-backend/
    ├── forense-master.md                   🆕  ~130 líneas
    ├── forense-fase-NN.md                  🆕  12–16 piezas (4 promovidas)   (D5)
    ├── cuaderno-incidentes.md              🆕  12 incidentes · ~1.900 líneas (D6)
    ├── (las 16 fases)                      ✏️  sección 6 + línea 📄 + reservas
    └── README.md                           ✏️  idem
```

**Nombres:** se respeta la nomenclatura de Angular (`forense-master.md`,
`forense-fase-NN.md`, `cuaderno-incidentes.md`), que no colisiona con nada y hace que los
tres paquetes se lean igual. Las piezas de ruta usan `forense-ruta-<código>.md`, que es
nuevo y hay que **declararlo en §13.2** de la guía (P2).

---

## 7. 🗺️ Plan de ejecución — ocho pasos

El orden no es negociable en los cuatro primeros: **la convención antes que todo**, porque
los demás entregables la citan; después la especificación antes que el entregable, y el
índice de síntomas antes que las piezas.

| # | Paso | Entregable | Prompt | Commit |
|---|---|---|---|---|
| 0 | **La convención** | `prompts/convencion-de-git-y-tags.md` completado | **P0** | **propio y solo** |
| 1 | **Los formatos** | `formato-piezas-forenses.md` + `formato-cuaderno-incidentes.md` | **P1** | uno |
| 2 | **Los rectores** | Parches a `guia-de-estilo-y-convenciones.md` y `plantilla-de-fase.md` | **P2** | uno |
| 3 | **Las puertas** | Los dos `forense-master.md` | **P3** | uno por curso |
| 4 | **El caos** | Sección 🔥 en `03-mock-api-minima.md` | **P4** | uno |
| 5 | **Las piezas** | 15 + 12…16 `forense-*.md`, en tandas de 3–4 | **P5** | uno por tanda |
| 6 | **Los cuadernos** | 2 × `cuaderno-incidentes.md`, en tandas de 4 incidentes | **P6** | uno por tanda |
| 7 | **La costura** | Secciones 6 de las 33 fases + los dos README | **P7** | uno por curso |
| 8 | **La auditoría** | Verificación cruzada de enlaces, IDs y contrato | **P8** | — |

> 🧭 **Por qué el Paso 0 va solo y primero.** Aparte de que los otros entregables lo citan,
> es la única corrección del plan que **no depende de nada** y que tiene valor por sí sola:
> aunque el track forense no se escribiera nunca, la convención completa sigue mejorando el
> paquete. Por eso merece su propio commit — `vue2: completa la convención de git y tags` —
> y no ir mezclada con el material forense.

> 🧭 **Por qué las puertas (paso 3) van antes que las piezas (paso 5).** El
> `forense-master.md` obliga a decidir **el índice de síntomas completo** de un curso de una
> sentada, y ese índice es el que reparte qué síntoma cubre cada pieza. Escribirlo después
> significa descubrir en la pieza 9 que la 3 y la 7 cubren lo mismo.

**Regla de trabajo para los pasos 5 y 6:** un chat por tanda, nunca más de 4 archivos, y
cada chat empieza leyendo los dos formatos y la guía de estilo. Las piezas se escriben
**contra el proyecto corriendo**: si una salida no se puede reproducir, no se inventa — se
marca con `…` o se cambia el paso.

---
PART1
wc -l contenido_forense.md

# --- 2026-09-09T03:18:54 · Write doc part 2 and verify
cat >> contenido_forense.md <<'PART2'

## 8. 🎬 Los prompts

Todos asumen que el chat arranca en `vue2-legacy-for-backend-devs/`. Las decisiones D0–D6
ya están dentro: no hay que repetírselas al chat.

---

### P0 · Completar la convención de git y tags ⬅️ **paso 1, commit propio**

```
Lee completos:
- prompts/convencion-de-git-y-tags.md          ← el ÚNICO archivo que vas a editar
- prompts/guia-de-estilo-y-convenciones.md     ← §9.1 (el bloque 🏷️) y §14 (post-mortem)
- README.md (raíz del paquete)                 ← las deudas 💸 que un curso le pasa al otro
- 01-vue2-legacy/03-mock-api-minima.md         ← db.json, db.seed.json y el script mock:reset
- 02-complement-mongodb-backend/11-auth-real-y-pago-de-deudas.md  ← el ritual de SECURITY-NOTES.md
- ../angular-16-legacy-for-backend-devs/00-convencion-de-git-y-tags.md
- ../angular-8-legacy-for-backend-devs/00-convencion-de-git-y-tags.md
  ← los dos SOLO como referencia de qué secciones merecen existir y con qué voz. NO se
    copian: aquellos cursos tienen UN repositorio y este paquete tiene DOS, y esa
    diferencia cambia el mecanismo de la deuda.

REGLA DURA DE ESTE PROMPT: editas UN SOLO ARCHIVO, prompts/convencion-de-git-y-tags.md.
Nada de guía de estilo, nada de fases, nada de apéndices, nada de README. El resultado
tiene que poder commitearse solo, con el mensaje
«vue2: completa la convención de git y tags (apéndices, deuda, db.json, forense)».

Es una edición ADITIVA y de alcance MÍNIMO. No reescribas ni reordenes lo que ya está
(📦 un repo por curso · 💬 mensajes de commit · 🏷️ un tag por fase · puntos de retorno de
las rutas · 🧪 tags de ejercicios · 🚑 incidentes · 📈 comandos · ✅ checklist). Las 38
fases ya llevan su bloque 🏷️ con el tag correcto: NO cambies el formato del bloque ni el
esquema de nombres `fase-` + slug. La sección de ejercicios ya es buena —tiene el par
-roto/-fix, los tags de medición y la advertencia de refs/tags—: solo se le añaden los
apéndices.

Añade lo siguiente, y nada más.

────────────────────────────────────────────────────────────────────────
1) LOS APÉNDICES, que hoy no aparecen en ninguna parte de este archivo.

   Va donde encaje mejor entre «💬 Los mensajes de commit» y «🏷️ Un tag por fase
   cerrada». Tres cosas, breves:

   - Prefijo de commit de lo que sale de leer un apéndice: su código —`a4:` en el Curso 01,
     `a02:` en el Curso 02—, siguiendo el mismo criterio que ya usan los prefijos de fase.
   - Los apéndices normalmente NO llevan tag propio, y el archivo tiene que decir por qué:
     son consulta, no producen código de fase. Es coherente con §9.1 de la guía, que ya
     dice que los apéndices no llevan bloque 🏷️, y esa regla NO se cambia.
   - La excepción, en una línea: si un apéndice llega a dejar archivos versionados —el
     docker-compose de a01, el .eslintrc de a3—, se marca con `apendice-a01` / `apendice-a3`,
     respetando el número de dígitos que usa cada curso (un dígito en el Curso 01, dos en
     el Curso 02).
   - Y en «🧪 Tags de ejercicios», añade una línea a los ejemplos que ya están:
        git tag ej/a01/3     # Curso 02, apéndice A01, ejercicio 3
     Aprovecha y aclara ahí mismo, en media línea, algo que hoy confunde: `ej/f07/22`
     aparece en los ejemplos etiquetado como Curso 02, y `ej/f04/17` como Curso 01. No hay
     colisión porque son repos distintos, pero dilo, porque leído del tirón parece un error.

────────────────────────────────────────────────────────────────────────
2) «## 🕵️ Lo que se commitea al recorrer una pieza forense» — CORTA, media página.

   Va después de «🚑 Incidentes». Es corta a propósito, y la brevedad es el mensaje:

   - Una pieza forense NO produce código del proyecto: el código lo escriben las fases.
     Lo que salga de recorrerla se commitea con el prefijo de su fase (`f08: …`).
   - Si el recorrido corresponde a un incidente del cuaderno, se usa el par
     `inc/<fase>/<slug>-roto` / `-fix` que el cuaderno ya reservó. NO se inventa un
     namespace `forense/`: un tag que no marca un cambio no marca nada.
   - Los ejercicios de «rompe a propósito» que salen de una pieza son ejercicios normales:
     `ej/f08/25-roto` y `ej/f08/25-fix`, que ya están definidos más arriba en este archivo.
   - Cierra enlazando a los dos formatos que van a existir
     (prompts/formato-piezas-forenses.md y prompts/formato-cuaderno-incidentes.md) y di que
     el detalle vive ahí, no aquí.

────────────────────────────────────────────────────────────────────────
3) «## 💸 La deuda que sí se paga (y cómo se lee la factura)»

   Va después de la sección forense y antes de «📈 Los comandos». Es la sección con más
   contenido de esta ampliación, porque la deuda declarada es lo que une los dos cursos.
   Compacta: una página, dos casos.

   a) Deuda que nace y muere en el MISMO repo — el login síncrono de la Fase 2, que se paga
      en la Fase 3 del Curso 01. El diff entre los dos tags de fase es el material de
      repaso, tal cual:
         git diff fase-02-autenticacion-minima fase-03-mock-api-minima -- src/store
      Y la frase que le da sentido: no es una métrica, es la respuesta a «¿cuánto costó de
      verdad arreglar esto?», que es la pregunta que te van a hacer la próxima vez que
      propongas pagar una deuda en un sistema real.

   b) Deuda que CRUZA los dos repos — el caso propio de este paquete, que ningún curso de
      Angular tuvo que resolver. La deuda estrella: el «cliente mentiroso» de
      08-websockets-minimos.md (el cliente emite el evento de socket que debería emitir el
      servidor), declarado en el repo del Curso 01 y pagado en el del Curso 02, en
      12-el-backend-habla.md. Di EXPLÍCITAMENTE que `git diff` no cruza repositorios,
      porque el lector va a intentarlo. La solución son dos tags hermanos que se nombran
      mutuamente en el mensaje:

         # Repo del Curso 01, al cerrar la fase que declara la deuda:
         git tag -a deuda/cliente-mentiroso-declarada -m "F8: el cliente emite
         ticket:updated, que debería emitir el servidor. Se paga en el repo del Curso 02,
         Fase 12."

         # Repo del Curso 02, en el commit que la salda:
         git tag -a deuda/cliente-mentiroso-pagada -m "F12: el io.emit sale del servidor
         después del write. Cierra deuda/cliente-mentiroso-declarada del repo del Curso 01
         (F8)."

      Más el comando que devuelve cada mitad del libro mayor: `git tag -n99 -l 'deuda/*'`.
      El que declara dice qué se debe y dónde se paga; el que paga dice qué cerró y de
      dónde venía.

   c) El enganche con SECURITY-NOTES.md, en dos frases. Ya existe en el paquete y hoy no
      tiene mecánica: el ejercicio 7 de 11-auth-real-y-pago-de-deudas.md pide «tachar la
      deuda con el commit que la resolvió referenciado», y hoy ese commit hay que buscarlo
      a mano. El tag `deuda/…-pagada` ES ese commit, con nombre. Enlaza la fase.

   NO añadas una digresión sobre `git log -S`: el archivo ya es largo y esto es alcance
   mínimo.

────────────────────────────────────────────────────────────────────────
4) «## 🧹 El `db.json` que se ensucia (el truco que más vas a usar)» — media página.

   json-server escribe de verdad: después de media hora de ejercicios el db.json es un
   campo de batalla y ya no se puede reproducir el caso limpio del enunciado. Hay dos
   formas de volver y NO son la misma — ésa es toda la sección:

      git checkout -- db.json     # te devuelve el archivo como lo commiteaste, CON tus escenarios
      npm run mock:reset          # lo pisa entero desde db.seed.json, y se los lleva por delante

   db.seed.json y el script mock:reset YA EXISTEN: los crea el ejercicio 14 de la Fase 3 y
   reaparecen en a3-npm.md. No los reinventes: cítalos.

   El corolario es el hábito: cuando un ejercicio pida un dato particular —un ticket sin el
   campo `tags`, dos agentes con el mismo ticket asignado, un comentario huérfano cuyo
   ticket ya no existe—, cárgalo, commitéalo como escenario
   (`git commit -m "f05 ej22: escenario de ticket sin tags"`) y etiquétalo si vas a volver.
   Reconstruir a mano un escenario que ya tuviste es el peor uso posible de tu tiempo. Y la
   frase que lo conecta con lo que viene: los `db.incidente-NN.json` del cuaderno de
   incidentes son exactamente eso, guardados con nombre.

   Una línea para el Curso 02: ahí el estado sucio no está en un archivo sino en la base, y
   se vuelve con `npm run seed` o levantando el contenedor de cero (a01-docker.md).

────────────────────────────────────────────────────────────────────────
5) «## 🐳 Una cosa más, para la Fase 14 del Curso 02» — tres o cuatro frases, no más.

   La imagen que se construye en 14-operacion.md no debe quedarse en `:latest`: con
   `:latest` no sabes qué código estás corriendo. Etiquétala con el mismo nombre del tag de
   git que la produjo y podrás empezar cualquier diagnóstico de «en mi máquina funciona»
   sabiendo QUÉ HAY ADENTRO — la mitad barata del diagnóstico, y la que casi nadie tiene.
   Enlaza a a01-docker.md y a 14-operacion.md; no reexpliques Docker.

────────────────────────────────────────────────────────────────────────
6) Dos comandos nuevos en «## 📈 Los comandos que hacen que esto sirva», con su comentario
   en español y en el estilo de los que ya están:

      # Recuperar un archivo de una fase anterior sin moverte de sitio
      git checkout fase-05-crud-tickets -- src/components/tickets/TicketForm.vue

      # Arrancar un incidente desde la fase que lo produce
      git switch -c incidente/07 fase-04-dashboard-tickets

   El segundo lo va a usar el cuaderno en cada preparación: déjalo con el nombre completo
   del tag, no con un placeholder.

────────────────────────────────────────────────────────────────────────
7) Dos ítems al «## ✅ Checklist de cierre de fase», sin tocar los que ya están:
   - [ ] Si la fase DECLARA una deuda 💸, tiene su tag `deuda/<slug>-declarada` y el
         mensaje dice en qué curso y fase se paga.
   - [ ] Si la fase PAGA una deuda, tiene su tag `deuda/<slug>-pagada`, el mensaje nombra
         al tag hermano, y SECURITY-NOTES.md quedó tachado.

────────────────────────────────────────────────────────────────────────
Reglas de forma: español latinoamericano con tuteo y cero voseo; los slugs de tag siguen el
patrón que ya usa el archivo; comentarios de los bloques bash en español. Prosa antes que
listas. Cada sección explica el PORQUÉ antes del comando. No inventes rutas: verifica que
cada .md que menciones exista con ese nombre exacto (guía §13.2).

Al terminar, dime en tres líneas: qué secciones añadiste, cuántas líneas tiene ahora el
archivo, y si encontraste alguna contradicción con lo que ya estaba escrito.
```

---

### P1 · Los dos documentos de formato

```
Lee, en este orden y completos:
- prompts/guia-de-estilo-y-convenciones.md
- prompts/plantilla-de-fase.md
- prompts/convencion-de-git-y-tags.md, YA COMPLETADO POR P0 (sobre todo §🚑 Incidentes,
  §🕵️ lo que se commitea al recorrer una pieza, §💸 la deuda y §🧹 el db.json)
- 02-complement-mongodb-backend/00-audit-contrato.md
- ../angular-16-legacy-for-backend-devs/prompts/formato-piezas-forenses.md
- ../angular-16-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md

Crea DOS documentos en prompts/, que rigen los dos cursos del paquete:
prompts/formato-piezas-forenses.md y prompts/formato-cuaderno-incidentes.md

Son ESPECIFICACIONES, no entregables: definen cómo se escriben forense-master.md,
forense-fase-NN.md, forense-ruta-<código>.md y cuaderno-incidentes.md. Toman la estructura
de los dos documentos homólogos de Angular 16 y la adaptan al paquete Mini Jira. Adaptar
significa: mismo esqueleto, ejemplos y vocabulario propios.

Decisiones YA TOMADAS, que los formatos recogen explícitamente:
- Las piezas van en archivo aparte, al estilo de los cursos de Angular. La sección 6 de
  cada fase queda con el resumen y una línea «📄 El recorrido completo, en
  `forense-fase-NN.md`». La frontera fase/pieza se especifica con una tabla, como el §5 del
  formato de Angular.
- UN CUADERNO POR CURSO, IDs independientes, nunca reasignados. Y la razón, que tiene
  consecuencias en el contenido: los dos cursos son independientes y hay estudiantes que
  harán SOLO el Curso 01. Por eso el cuaderno del Curso 01 no puede citar nada del Curso 02,
  y los incidentes de costura —que viven en el cuaderno del Curso 02— tienen que ser
  AUTOCONTENIDOS: parten de un frontend ya construido que se entrega, no exigen haberlo
  escrito.
- 12 incidentes por cuaderno, 24 en total.
- Curso 01: 15 piezas — 12 de tronco (F0–F11) y 3 de ruta compactas
  (forense-ruta-q.md, -vu.md, -nx.md, ~120 líneas, cada una cubre las 5 fases de su ruta).
  Las rutas son material opcional sobre material opcional: no llevan una pieza por fase.
- Curso 02: 12 piezas como PISO, hasta 16 si alguna fase se gana la suya al escribirla.
  Lo que no se hace es rellenar por simetría: una pieza sin recorrido propio se convierte en
  resumen de la fase, que es exactamente lo que el §1 del formato prohíbe. Las 4 que ya
  existen inline (fases 02, 09, 10 y 13) se PROMUEVEN a archivo, no se reescriben.
- NO hay presupuesto horario. Este paquete no cuenta horas en ningún documento; no se
  introduce ahora. El tamaño se expresa en número de piezas e incidentes.

Lo que el formato de piezas debe fijar, propio de este paquete:
- Herramientas del Curso 01 y su mentira característica: Vue DevTools (miente por
  *timeline* — muestra el estado después de la mutation, no quién la lanzó), la consola
  (miente por omisión: un catch vacío, y un warn de reactividad que solo sale en dev),
  Network, y `git log -S`. Curso 02: mongosh, Compass, `explain()` (miente por caché de
  plan), los logs de Express, el profiler.
- La cuarta pregunta del método, propia de este paquete y equivalente al 🧬 de Angular:
  «¿en qué capa vive esto?» — componente / store / servicio HTTP / mock, y en el Curso 02
  ruta / controller / service / Mongo. Es la distinción que la guía §6 ya llama «la que
  salva al que depura».
- Texto, nunca capturas (§2 del formato de Angular, se conserva tal cual).
- Los pasos van del más barato al más caro, cada paso dice qué descarta, y la ruta termina
  cuando se sabe dónde está el bug, no cuando está arreglado.

Lo que el formato de cuaderno debe fijar, propio de este paquete:
- Las tres formas de tener el sistema roto, en orden de preferencia: flag del inyector de
  caos del mock, `db.json` alterno (`db.incidente-NN.json`), rama de git
  (`git switch -c incidente/07 fase-04-dashboard-tickets`, que sale del tag de la fase).
- Categorías del Curso 01: reactividad · estado (Vuex) · integración (mock) · formularios y
  wizard · tiempo real (sockets) · convivencia con framework de ruta · UI · testing · build.
- Categorías del Curso 02: modelado (embeber/referenciar) · consultas y explain ·
  atomicidad y concurrencia · índices · contrato · auth · operación · testing.
- Cuotas mínimas, para que cada cuaderno cubra el corazón de su curso:
  · Curso 01 — al menos 2 de reactividad de Vue 2, 2 de Vuex y 2 de deudas 💸 declaradas.
  · Curso 02 — al menos 2 de atomicidad/concurrencia, 2 del anti-patrón `soporte_v1` y
    2 de costura (el frontend hablándole al backend), estos últimos autocontenidos.
- La plantilla del incidente, con `<details>` para pistas y solución, declarada como la
  única excepción a «Markdown sin HTML» de la guía §3.
- La convención de commits `incidente(NN): abre|repro|hipótesis|hipótesis descartada|causa|fix|cierre`
  y el par de tags `inc/<fase>/<slug>-roto` / `-fix`, que NO se reinventa: ya está en
  prompts/convencion-de-git-y-tags.md y solo se enlaza.

Reglas de forma, no negociables: español latinoamericano con tuteo, cero voseo, código en
inglés y comentarios en español, Options API en el Curso 01, driver nativo antes de
Mongoose en el Curso 02. Cada documento cierra con su checklist de «antes de dar por
cerrado».
```

---

### P2 · Parchear los documentos rectores

```
Lee prompts/formato-piezas-forenses.md, prompts/formato-cuaderno-incidentes.md,
prompts/guia-de-estilo-y-convenciones.md y prompts/plantilla-de-fase.md.

Aplica estos cambios. Son quirúrgicos: no reescribas secciones enteras.

1. guia-de-estilo-y-convenciones.md §9 — la sección 6 de la plantilla pasa a ser
   «⚠️ Errores comunes y pieza forense», con el resumen en la fase y el recorrido completo
   en su archivo. Declara la divergencia respecto de cómo estaba escrita —el CLAUDE.md del
   repositorio exige que toda divergencia sea explícita— y di por qué: la pieza se consulta
   fuera de orden y meses después, y una sección enterrada en una fase de 900 líneas no se
   encuentra.

2. guia-de-estilo-y-convenciones.md §13.2 — añade a la nomenclatura vigente:
   forense-master.md, forense-fase-NN.md, forense-ruta-<código>.md y cuaderno-incidentes.md,
   uno de cada por curso.

3. guia-de-estilo-y-convenciones.md — nueva §16 «El track forense y el cuaderno», de media
   página: qué son, dónde viven, y que su especificación está en los dos formatos. No
   dupliques los formatos: enlázalos. Ajusta §13.1 para que los dos formatos entren en la
   lista de fuentes de verdad, en el nivel 5 junto a esta guía.

4. guia-de-estilo-y-convenciones.md §15 — añade tres ítems al checklist:
   - [ ] La sección 6 lleva su pieza forense (resumen + línea 📄), o dice por qué no.
   - [ ] Lleva el bloque «📌 Reservas para el cuaderno de incidentes», o declara que no
         reserva ninguno.
   - [ ] Cada ID reservado existe en el índice del cuaderno de su curso.

5. plantilla-de-fase.md — la sección 6 incorpora la línea 📄 y el bloque «🧨 Rompe a
   propósito»; y al final de la plantilla, después del cierre, un bloque
   «### Reservas para el cuaderno de incidentes» con la tabla
   | ID | Título propuesto | Categoría | Dif. |. Di que los apéndices no lo llevan, igual
   que no llevan el bloque 🏷️.

6. convencion-de-git-y-tags.md — este archivo ya lo amplió P0 y aquí se toca UNA sola
   frase. En §🚑, sustituye la que dice que `git tag -n99 -l 'inc/*'` «te devuelve el
   cuaderno de incidentes entero» por una que enlace al cuaderno real de cada curso y
   explique la relación: el archivo es el enunciado y tu investigación; los tags son tu
   bitácora ejecutable. No toques nada de lo que añadió P0.

No toques nada más. Al terminar, lista los archivos modificados y, por cada uno, las
secciones tocadas en una línea.
```

---

### P3 · Los dos `forense-master.md`

```
Lee prompts/formato-piezas-forenses.md §6, prompts/guia-de-estilo-y-convenciones.md, y
—completos— el README y los documentos maestros del curso que vayas a cubrir.

Crea 01-vue2-legacy/forense-master.md   [o 02-complement-mongodb-backend/forense-master.md]

Cinco bloques, según §6 del formato:
1. El método de cuatro preguntas, con el orden justificado por coste.
2. 📇 Índice de las piezas: una fila por fase con síntoma, herramienta principal, archivo.
   En el Curso 01, las tres piezas de ruta van en su propia sub-tabla, marcadas como
   opcionales y excluyentes entre sí.
3. 🩺 Índice de síntomas transversal — LA TABLA QUE IMPORTA. A la izquierda, lo que el
   usuario dice o lo que ves; a la derecha, dónde empezar. Mínimo 25 filas. Tiene que
   cubrir los síntomas que ya viven dispersos en las secciones «⚠️ Errores comunes» de
   todas las fases del curso: recórrelas y recógelos, no los inventes.
4. 🧰 Las herramientas y en qué miente cada una.
5. Cierre con el criterio de éxito del track.

Para el Curso 01, el índice de síntomas tiene que incluir al menos estos, con la fase donde
se empieza:
- "le di a guardar y no pasó nada", sin nada en consola
- cambié un campo del ticket y la tabla no se enteró, pero si recargo sí está
- la lista se pinta con los datos de antes del filtro
- tomé el ticket y a mi compañero le sigue apareciendo libre
- cierro sesión en una pestaña y en la otra sigo dentro
- el wizard me deja avanzar con el paso 2 vacío
- la métrica del dashboard no cuadra con el número de filas de la tabla
- se me duplican los tickets en la lista cuando llega un evento del socket
- "this is undefined" dentro de un método
- el mock devuelve 404 en /tickets/1/comments y en Postman funciona
- el filtro cambia la URL pero no la tabla
- la app va bien y al rato el ventilador se dispara
- el test pasa solo cuando lo corro aislado
- en el build de producción se ve distinto que en `npm run serve`
- (rutas) el componente del framework ignora lo que le pone el store
- (Nuxt) `window is not defined` al recargar una página que en navegación funciona

Para el Curso 02:
- la consulta que en SQL era un JOIN ahora tarda 40 veces más
- el dashboard hace seis viajes a la base por pantalla
- dos agentes tomaron el mismo ticket
- el índice está creado y `explain()` sigue diciendo COLLSCAN
- el GROUP BY me devuelve una fila
- guardé el ticket y al releerlo falta un campo
- la fecha se guarda bien y se lee con un día menos
- el front no muestra nada y `curl` sí devuelve los tickets  ← el id ↔ _id del contrato
- el evento de socket llega dos veces
- la suite pasa en local y falla en CI

IMPORTANTE — los cursos son independientes: el master del Curso 01 no cita nada del
Curso 02, y el del Curso 02 solo cita al 01 en las filas de costura, y de forma que se
entiendan sin haber hecho el Curso 01.

Reglas: texto, nunca capturas. El master NO repite ninguna pieza: enlaza. Español con
tuteo, código en inglés. Y no inventes síntomas que el curso no produce: si un síntoma no
tiene fase que lo cubra, sácalo y anótalo al final como pendiente.
```

---

### P4 · El inyector de caos

```
Lee 01-vue2-legacy/03-mock-api-minima.md completo, prompts/guia-de-estilo-y-convenciones.md
y ../angular-16-legacy-for-backend-devs/03-mock-api-caos.md (solo como referencia de qué
fallos merecen existir).

Añade a 03-mock-api-minima.md una sección 🔥 opcional, «El inyector de caos», entre el
código y los errores comunes. Es ADITIVA: no toques una línea de lo que ya está, no
renumeres ejercicios, no cambies el db.json.

Qué tiene que traer:
- Un middleware de json-server, en un archivo nuevo, que lee la variable de entorno CHAOS y
  aplica uno de estos fallos a las respuestas: `cors`, `timeout`, `malformed`, `500`,
  `slow`, `empty`. Código en inglés, comentarios en español, sintaxis de Node 14.
- El script de npm que lo enciende: `CHAOS=malformed npm run mock`.
- Por qué cada fallo enseña algo distinto, en prosa breve: `cors`, servidor caído y red
  ausente son INDISTINGUIBLES desde el código del cliente, y ésa es la lección; `malformed`
  es el que miente, porque llega con 200 en verde; `timeout` es el spinner eterno.
- Una tabla «lo que ves / lo que es», que se enlazará desde forense-master.md.
- 4 ejercicios 🔥 al final del bloque de ejercicios, con la numeración que sigue a los que
  ya existen, sin tocar los anteriores.
- Una frase que diga que este inyector es la forma preferida de preparación de los
  incidentes del cuaderno, y enlace a cuaderno-incidentes.md.

No añadas el bloque 🏷️ (la fase ya lo tiene) ni toques el cierre.
```

---

### P5 · Una tanda de piezas forenses

```
Lee prompts/formato-piezas-forenses.md, prompts/guia-de-estilo-y-convenciones.md,
<curso>/forense-master.md, y COMPLETAS las fases que vas a cubrir en esta tanda.

Crea: <curso>/forense-fase-04.md, forense-fase-05.md, forense-fase-06.md
      [ajusta la lista — máximo 4 por tanda]

Siete bloques por pieza, según §3 del formato: encabezado · 🎫 el ticket · 🧭 la ruta ·
🩺 diagnóstico por síntoma · ⚰️ los callejones · 🧨 deshacer · 🧠 el patrón transferible.

Innegociable:
- Cada paso: qué haces (imperativo, con la ruta exacta de la interfaz o el comando
  completo) → la salida LITERAL en un bloque de código → «Qué descarta» y a qué paso saltas.
  Un paso que no descarta nada es relleno: bórralo.
- Del más barato al más caro, y dilo al empezar la ruta.
- CERO capturas. Todo en texto.
- Cero salidas inventadas: todo tiene que reproducirse con el proyecto de la fase y su
  semilla. Lo variable (puertos, hashes, fechas, ids) va con `…` o con marcador evidente.
- La ruta termina cuando sabes DÓNDE está el bug. El fix es de la fase o del incidente.
- No repitas la sección 6 de la fase: enlázala.
- El síntoma que cubre cada pieza es EXACTAMENTE el que forense-master.md le asignó en su
  índice. Si al escribirla ves que el reparto está mal, dilo y para: se corrige el master
  primero.

Si la tanda es de piezas de ruta (forense-ruta-q.md, -vu.md, -nx.md): una sola pieza por
ruta, ~120 líneas, cubriendo las cinco fases de esa ruta. El eje es el conflicto central
—el framework quiere el estado que tu store ya controla— y cada ruta añade lo suyo; en NX,
la hidratación. No repitas tres veces la misma explicación: cada pieza se lee sola, porque
el lector solo va a leer una.

Al terminar cada pieza, entrega también, para pegar en su fase (no la edites todavía):
- El párrafo de la línea 📄 que la fase debe llevar en su sección 6.
- El bloque 🧨 «Rompe a propósito» si sale de la pieza.
- La tabla de «📌 Reservas para el cuaderno de incidentes» con los IDs que esta fase
  reserva: | ID | Título propuesto (en palabras del usuario) | Categoría | Dif. |
  Los IDs son correlativos POR CURSO y no se reasignan nunca.
```

---

### P6 · Una tanda de incidentes

```
Lee prompts/formato-cuaderno-incidentes.md, prompts/guia-de-estilo-y-convenciones.md §14,
prompts/convencion-de-git-y-tags.md (§🚑 y §💸), <curso>/forense-master.md, las piezas
forenses de las fases implicadas, y COMPLETAS esas fases.

Si <curso>/cuaderno-incidentes.md no existe, créalo con: encabezado y el trato · 🧭 cómo se
trabaja un incidente · 📋 índice con las 12 filas (todas, aunque el enunciado aún no esté
redactado: el ⬜ significa «reservado, no escrito») · 🧪 incidentes · 🪞 retrospectiva ·
📌 pendientes.

Redacta los incidentes NN a NN+3 con la plantilla completa de §7 del formato. Cada uno:
- 🎫 El ticket en palabras del usuario, con su vaguedad incluida y quién lo reportó. El
  título es el ticket, no la respuesta: «tomé el ticket y a mi compañero le sigue
  apareciendo libre» sí; «race condition en takeTicket» no.
- 🎯 Qué se te pide. No todos terminan en fix: alguno termina en «demuestra que no es un
  bug», que es un entregable legítimo y de los más formativos.
- 🔧 Preparación con la forma MÁS BARATA que sirva, de las tres, y por qué esa.
- Tres pistas plegadas en `<details>`: dónde mirar → qué mirar → la pregunta cuya respuesta
  es la causa.
- 📝 Tu investigación, en blanco, con los subtítulos.
- Solución de referencia plegada: causa raíz hasta el archivo · parche mínimo (el del
  viernes a las seis, en el estilo del archivo que toca) · la refactorización correcta ·
  prueba de regresión EN CÓDIGO · prevención · por qué llegó a producción (post-mortem
  sereno, sin culpabilización, aquí el humor baja un punto) · «si tu causa fue distinta».

INDEPENDENCIA ENTRE CURSOS: el cuaderno del Curso 01 no cita ni una fase del Curso 02. Los
incidentes de costura del Curso 02 son autocontenidos: entregan el frontend ya construido
como punto de partida y se pueden resolver sin haber hecho el Curso 01.

Cuando la solución de un incidente salde una deuda 💸 declarada, dilo y nombra el tag
`deuda/<slug>-pagada` de la convención: es el mismo mecanismo, no uno paralelo.

Reglas del paquete: código en inglés y comentarios en español; Options API y
`function () {}` en el Curso 01; driver nativo antes de Mongoose en el Curso 02; nada
contradice el contrato de 02-complement-mongodb-backend/00-audit-contrato.md.

Actualiza el 📋 índice en el mismo pase. Si un incidente que reservó una fase resulta
imposible de escribir con una causa raíz propia, NO lo fuerces: retíralo, documenta por qué
en 📌 pendientes, y deja el ID retirado sin reasignar.
```

---

### P7 · Coser el track a las fases

```
Lee prompts/formato-piezas-forenses.md §5, <curso>/forense-master.md, todas las piezas
forenses del curso y su cuaderno-incidentes.md.

Para CADA fase del curso, edita solo su sección 6 y su cierre:
1. El encabezado pasa a «## ⚠️ Errores comunes y pieza forense» (respeta la numeración
   explícita §N donde la fase ya la use — hoy solo q1, q3, vu1 y vu3).
2. Debajo de «Errores comunes», añade «### Pieza forense de esta fase»: el resumen que se
   lee de corrido, el bloque 🧨 «Rompe a propósito», y la línea
   «> 📄 El recorrido completo, con las salidas literales, en `forense-fase-NN.md`.»
   Aplica la tabla de frontera del §5 del formato: si un párrafo cabe igual en los dos
   sitios, va en la fase y la pieza lo enlaza.
   En las fases de ruta, la línea 📄 apunta a la pieza de SU ruta (forense-ruta-q.md, etc.).
3. Antes del cierre, el bloque «### Reservas para el cuaderno de incidentes» con los IDs que
   esta fase reserva, enlazados al cuaderno.
4. En los apéndices NO se hace nada de esto.

Después, actualiza <curso>/README.md con dos bloques nuevos, modelados sobre los del README
de angular-16: «🕵️ Track forense» (con la tabla de piezas y sus síntomas) y «📓 Cuaderno de
incidentes».

Regla dura: no reescribas los «Errores comunes» que ya existen, ni toques ejercicios,
código, referencias ni el bloque 🏷️. Es una operación de costura.
```

---

### P8 · Auditoría de cierre

```
Audita el track forense completo del paquete y entrega un informe, sin corregir nada
todavía. Comprueba:

1. Cada .md citado existe con ese nombre exacto (guía §13.2). Lista los enlaces rotos.
2. Cada línea 📄 de una sección 6 apunta a una pieza que existe, y esa pieza entrega
   exactamente los tickets que la fase promete.
3. Cada ID reservado por una fase tiene fila en el índice del cuaderno de su curso, y
   viceversa. Ningún ID reasignado. Lista los huérfanos en ambos sentidos.
4. Ningún síntoma del 🩺 índice de síntomas se queda sin pieza, y ninguna pieza cubre un
   síntoma que el índice no lista.
5. INDEPENDENCIA: ningún archivo del Curso 01 depende del Curso 02, y los incidentes de
   costura del Curso 02 se pueden resolver sin haber hecho el Curso 01.
6. Ninguna pieza ni incidente contradice 00-audit-contrato.md: forma del ticket, enums
   `status`/`priority`, nombres de evento de socket, mapeo id ↔ _id.
7. Los tags que se citan existen en la convención (P0): `fase-`, `ej/`, `inc/`, `deuda/`,
   `apendice-`. Ninguna pieza ni incidente inventa un namespace nuevo.
8. Pasada de tuteo con la tabla de §4.7 sobre todos los archivos nuevos, homógrafos
   revisados a mano.
9. Todo el código en inglés y todos los comentarios en español, incluidos los parches
   mínimos de las soluciones de referencia.
10. Cero capturas de pantalla. Cero salidas que no se puedan reproducir con el proyecto.
11. Los cuadernos cumplen sus cuotas de categoría, y el checklist de §15 de la guía pasa en
    todos los archivos nuevos.

Entrega una tabla | Archivo | Hallazgo | Severidad | Arreglo propuesto | y, al final, la
lista de correcciones en el orden en que conviene aplicarlas.
```

---

## 9. 🧪 Ejemplos concretos, para calibrar el tono

### 9.1 Muestra de incidente (Curso 01) — versión abreviada

> Un incidente real ocupa ~150 líneas. Esto es el esqueleto con las frases que definen la
> voz.

````markdown
## Incidente 05 — "Le puse la etiqueta 'facturación' al ticket y la tabla no se enteró"

> **Fase:** 5 · **Categoría:** Reactividad · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Tiempo sugerido:** 40–60 min

### 🎫 El ticket

"Abro el ticket #0347, le agrego la etiqueta desde el detalle, le doy guardar y me dice que
se guardó. Pero en la tabla el ticket sigue sin etiqueta. Si recargo la página con F5 ahí sí
aparece. A veces me pasa y a veces no, no sé de qué depende."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Reproducirlo, decir en qué **capa** vive —componente, store, servicio o mock— y aplicar el
parche mínimo. El "a veces sí y a veces no" es un dato, no ruido del reporte: averigua de
qué depende antes de tocar nada.

### 🔧 Preparación

Un `db.json` alterno: el bug solo se ve con tickets que **no traen** el campo `tags` desde
el mock, y la semilla actual se lo pone a todos.

```bash
cp mock/db.incidente-05.json db.json    # guarda el tuyo antes, o corre npm run mock:reset después
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El store ya tiene el dato correcto. Compara, en Vue DevTools, lo que dice el objeto del
ticket en Vuex con lo que pinta la fila. No es un problema de red: Network no tiene nada que
contarte aquí.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

De los tickets de la tabla, unos se actualizan y otros no. Mira qué tienen en común los que
**sí**. Fíjate en la respuesta del mock, no en el objeto que arma el formulario.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿En qué momento exacto de la vida de ese objeto apareció la propiedad `tags`?

</details>

---

### 📝 Tu investigación

**Reproducción** · **Evidencia observable** · **Hipótesis (❌ descartada / ✅ confirmada)** ·
**Tu causa raíz** · **Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** `store/modules/tickets.js`, en la mutation `UPSERT_TICKET`. Vue 2 hace
reactivas las propiedades que existen **en el momento en que el objeto entra en `data` o en
el store**. Los tickets que el mock devuelve sin `tags` entran sin esa propiedad, y el
`ticket.tags = […]` posterior crea una propiedad que ningún getter/setter vigila. El dato
está en el store —por eso DevTools lo muestra— y la tabla nunca se entera. Con F5 el ticket
vuelve a entrar, esta vez con `tags`, y todo funciona: de ahí el "a veces".

**Parche mínimo** — el del viernes a las seis:

```js
// store/modules/tickets.js
UPSERT_TICKET: function (state, ticket) {
  var index = state.items.findIndex(function (t) { return t.id === ticket.id; });
  // Vue.set y no state.items[index] = ticket: la asignación por índice en un array
  // tampoco es reactiva en Vue 2. Son las dos caras de la misma limitación.
  if (index === -1) { state.items.push(ticket); } else { Vue.set(state.items, index, ticket); }
}
```

**La refactorización correcta.** El problema de fondo no es el `Vue.set`: es que el frontend
acepta del mock tickets con forma incompleta. **Normalizar en el servicio HTTP** —un
`tags: ticket.tags || []` en la frontera— hace que la limitación de reactividad no pueda
dispararse nunca.

**Prueba de regresión** · **Prevención** · **Por qué llegó a producción** ·
**Si tu causa fue distinta a esta** …

</details>
````

### 9.2 Muestra de pieza forense (Curso 01, F8) — solo el esqueleto

```markdown
# 🕵️ Forense Fase 08 — "Tomé el ticket y a mi compañero le sigue apareciendo libre"

> Sale de: Fase 8 (WebSockets mínimos) · Herramientas: Network → WS, Vue DevTools, dos
> navegadores · Recorrido: ~25 min

## 🎫 El ticket
## 🧭 La ruta
  Paso 1 — ¿lo ve el otro navegador tras recargar?   → separa "no se emitió" de "no se pintó"
  Paso 2 — el frame en la pestaña WS de Network      → ¿salió el evento, y de quién salió?
  Paso 3 — quién emite: el cliente o el servidor     → 💸 aquí aparece el cliente mentiroso
  Paso 4 — el store del otro cliente                 → ¿llegó y no se aplicó, o no llegó?
## 🩺 Diagnóstico por síntoma
## ⚰️ Los callejones     ← "es que el socket se desconecta": Network dice que no
## 🧨 Deshacer
## 🧠 El patrón transferible
```

> 🧠 **Por qué ésta es la pieza estrella del Curso 01.** El recorrido termina localizando
> una **deuda 💸 declarada** —el cliente mentiroso de `08-websockets-minimos.md:231`, que
> emite el evento que debería emitir el servidor—, la misma que el tag
> `deuda/cliente-mentiroso-declarada` marca en el repo. Es el único sitio del paquete donde
> el estudiante *descubre depurando* algo que el material le había advertido cien líneas
> antes y él leyó sin entender del todo. Eso no lo puede hacer un ejercicio.
>
> Y como los cursos son independientes, la pieza **cierra ahí**: dice que la deuda existe y
> por qué es correcta hoy. Quien siga con el Curso 02 la verá pagada en su Fase 12; quien no
> lo haga, se lleva igual la lección completa.

---

## 10. ⚠️ Riesgos, y cómo se mitigan

| Riesgo | Mitigación |
|---|---|
| **Salidas inventadas.** Nadie corre el proyecto y las piezas transcriben salidas plausibles pero falsas. Es el fallo más probable y el que destruye la credibilidad del track. | El formato lo prohíbe (§1) y el checklist lo audita. Aun así: **P8 no lo puede detectar**. La única defensa real es correr al menos las piezas de F3, F5, F8 y F10 contra el proyecto. Es trabajo tuyo, no del chat. |
| **La pieza se vuelve un resumen de la fase.** El fallo estructural típico, y el motivo de que D5 ponga 12 como piso y no 16 por simetría. | Tabla de frontera obligatoria (§5 del formato) y el ítem de checklist "no repite la sección 6". |
| **Se rompe la independencia entre cursos** (D3): un incidente del Curso 01 que cita una fase del Curso 02, o uno de costura que exige haber escrito el frontend. | Está escrito en P1, P3, P6 y auditado en el ítem 5 de P8. Es la regla más fácil de olvidar, porque el paquete se lee como una unidad. |
| **IDs de incidente descoordinados** entre las reservas de las fases y el índice del cuaderno. | Las reservas se escriben en P5 (junto a la pieza), el índice se crea completo en el primer pase de P6, y P8 los cruza en los dos sentidos. |
| **Se rompe el contrato** al escribir un incidente de costura. | Ítem 6 de P8, y `00-audit-contrato.md` en la lista de lectura obligatoria de P6. |
| **Deriva de tono** a lo largo de ~30 archivos escritos en ~10 chats. | Cada chat arranca leyendo los dos formatos y la guía. Y la pasada de tuteo de §4.7 al final, que aquí es más peligrosa que de costumbre: los tickets están escritos en voz de usuario, y ahí es donde se cuela el voseo. |
| **P0 y P2 tocan el mismo archivo.** `convencion-de-git-y-tags.md` lo amplía P0 y le cambia una frase P2. | El orden lo resuelve (P0 va primero) y P2 lleva escrito «no toques nada de lo que añadió P0». Si inviertes el orden, P0 pisa el cambio de P2. |
| **Tocar `03-mock-api-minima.md`**, que está publicada. | La edición es estrictamente aditiva: sección nueva + ejercicios 🔥 al final. Ninguna línea existente cambia, ningún ejercicio se renumera. |

---

## 11. 🚦 Estado y siguiente paso

**Decisiones cerradas:** D0 a D6, recogidas en §5 y ya incorporadas a los ocho prompts.

**Un detalle de forma que resolví por mi cuenta al escribir P0**, y que conviene que veas
porque toca una regla existente: pediste tag de apéndice, y la guía §9.1 dice hoy que *"los
apéndices no llevan este bloque, porque no producen código de fase"*. P0 **no cambia esa
regla**: los `.md` de apéndice siguen sin bloque 🏷️. Lo que añade es lo que faltaba en la
convención —el prefijo de commit (`a4:`, `a02:`), el `ej/a01/3` para sus ejercicios, y el
tag `apendice-aNN` **solo** para el caso en que un apéndice deje archivos versionados, como
el `docker-compose` de `a01`—. Si querías que los apéndices lleven tag siempre, dilo y
ajusto P0 y el punto 5 de P2 (que tendría entonces que tocar también la guía §9.1, y el
commit del Paso 0 dejaría de ser de un solo archivo).

**Siguiente paso:** ejecutar **P0**. Es un archivo, ~120 líneas nuevas, cero riesgo de
contradecir nada, y su commit —`vue2: completa la convención de git y tags`— cierra por sí
solo. Después, P1.

> 🪦 **Recordatorio:** cuando P0, P1 y P2 estén cerrados, este archivo se borra.
PART2
wc -l contenido_forense.md && grep -n '^## [0-9]\|^### P[0-9]' contenido_forense.md

# --- 2026-09-09T03:27:10 · Honor the appendix rule across the doc
python3 - <<'PY'
p='contenido_forense.md'
s=open(p,encoding='utf-8').read()
def rep(old,new):
    global s
    assert s.count(old)==1, (old[:70], s.count(old))
    s=s.replace(old,new)

# 1. §3.2 tabla: fila de apéndices reescrita
rep("""| **Apéndices** | Prefijo de commit `a05:`, tag opcional `apendice-aNN` si el apéndice deja archivos versionados, y `ej/a06/3` en los ejemplos | El paquete tiene 10 apéndices y **ninguno aparece en su convención**: no se dice con qué prefijo se commitea lo que sale de leerlos |""",
"""| **Apéndices** | Prefijo de commit `a05:` y `ej/a06/3` en los ejemplos de tags de ejercicio | El paquete tiene 10 apéndices y **ninguno aparece en su convención**: no se dice con qué prefijo se commitea lo que sale de leerlos. Ver §3.5 — **el apéndice no gana un tag de fase** |""")

# 2. nueva §3.5 antes de §4
rep("""---

## 4. ⚖️ Lo que NO se copia de Angular""",
"""### 3.5 Los apéndices: la regla se honra tal como está

La guía §9.1 dice, y **no se toca**: *"Los apéndices **no** llevan este bloque, porque no
producen código de fase."* La convención tiene que reflejar esa regla, no erosionarla. Con
lo que hoy falta pasa justo lo contrario de lo que parece: el hueco no es que a los
apéndices les falte un tag, es que **no se dice con qué prefijo se commitea lo que sale de
leerlos**, y el vacío invita a inventarse uno.

Lo que P0 añade, entonces, es lo mínimo para cerrar el vacío sin abrir la puerta:

| Sí | No |
|---|---|
| Prefijo de commit del apéndice: `a4:` en el Curso 01, `a02:` en el Curso 02 | Un bloque 🏷️ al final de ningún `.md` de apéndice |
| `git tag ej/a01/3` para sus ejercicios, dentro del namespace `ej/` que ya existe | Un tag `fase-a01-docker` ni nada que se le parezca |
| Una nota de por qué no llevan tag: son consulta, no producen código de fase | Cambiar §9.1 de la guía |

> 🧭 **El criterio, que es el mismo de Angular y el mismo de este paquete:** un tag marca un
> cambio en el repositorio. Un apéndice explica lo que ya está ahí, así que un tag de
> apéndice no marcaría nada. La única excepción —y es del estudiante, no del material— es el
> apéndice que sí deja archivos versionados: el `docker-compose` de `a01`, el `.eslintrc` de
> `a3`. Para ese caso la convención **menciona** `apendice-a01` como opción, en una línea, y
> ningún documento de apéndice se lo pide al lector. El material nunca manda poner ese tag;
> la convención solo dice que existe si te sirve.

---

## 4. ⚖️ Lo que NO se copia de Angular""")

# 3. D0 en la tabla de decisiones
rep("""| **D0** | **La convención de tags va primero**, como paso 1 y en **un commit limpio que solo la toque**. Alcance **mínimo**: tag de fase y de apéndice, tags sugeridos de ejercicio y de forense, y lo equivalente de Angular 8/16, en el estilo del curso Vue. | P0 toca **un solo archivo**: `prompts/convencion-de-git-y-tags.md`. Nada de guía de estilo, nada de fases. |""",
"""| **D0** | **La convención de tags va primero**, como paso 1 y en **un commit limpio que solo la toque**. Alcance **mínimo**: tag de fase, tratamiento de los apéndices, tags sugeridos de ejercicio y de forense, y lo equivalente de Angular 8/16, en el estilo del curso Vue. | P0 toca **un solo archivo**: `prompts/convencion-de-git-y-tags.md`. Nada de guía de estilo, nada de fases, nada de apéndices. **La regla §9.1 se honra tal como está** (§3.5): los apéndices no llevan bloque 🏷️ ni tag de fase; solo ganan prefijo de commit y `ej/aNN/N`. |""")

# 4. P0 bloque 1
rep("""1) LOS APÉNDICES, que hoy no aparecen en ninguna parte de este archivo.

   Va donde encaje mejor entre «💬 Los mensajes de commit» y «🏷️ Un tag por fase
   cerrada». Tres cosas, breves:

   - Prefijo de commit de lo que sale de leer un apéndice: su código —`a4:` en el Curso 01,
     `a02:` en el Curso 02—, siguiendo el mismo criterio que ya usan los prefijos de fase.
   - Los apéndices normalmente NO llevan tag propio, y el archivo tiene que decir por qué:
     son consulta, no producen código de fase. Es coherente con §9.1 de la guía, que ya
     dice que los apéndices no llevan bloque 🏷️, y esa regla NO se cambia.
   - La excepción, en una línea: si un apéndice llega a dejar archivos versionados —el
     docker-compose de a01, el .eslintrc de a3—, se marca con `apendice-a01` / `apendice-a3`,
     respetando el número de dígitos que usa cada curso (un dígito en el Curso 01, dos en
     el Curso 02).
   - Y en «🧪 Tags de ejercicios», añade una línea a los ejemplos que ya están:
        git tag ej/a01/3     # Curso 02, apéndice A01, ejercicio 3
     Aprovecha y aclara ahí mismo, en media línea, algo que hoy confunde: `ej/f07/22`
     aparece en los ejemplos etiquetado como Curso 02, y `ej/f04/17` como Curso 01. No hay
     colisión porque son repos distintos, pero dilo, porque leído del tirón parece un error.""",
"""1) LOS APÉNDICES, que hoy no aparecen en ninguna parte de este archivo.

   REGLA QUE SE HONRA Y NO SE TOCA: la guía §9.1 dice que «los apéndices NO llevan este
   bloque, porque no producen código de fase», y esta ampliación NO la cambia ni la
   matiza. Los apéndices no llevan bloque 🏷️, no cierran con tag y no existe ningún
   `fase-a01-…`. Lo que falta no es un tag: es decir con qué prefijo se commitea lo que
   sale de leerlos, y ese vacío es lo que se cierra aquí.

   Va donde encaje mejor entre «💬 Los mensajes de commit» y «🏷️ Un tag por fase cerrada»,
   y son cuatro frases, no una sección:

   - Prefijo de commit de lo que sale de leer un apéndice: su código —`a4:` en el Curso 01,
     `a02:` en el Curso 02—, siguiendo el mismo criterio que ya usan los prefijos de fase.
   - Por qué NO llevan tag, dicho con el criterio y no como excepción arbitraria: un tag
     marca un cambio en el repositorio, y un apéndice explica lo que ya está ahí. Un tag que
     no marca un cambio no marca nada. Enlaza a §9.1 de la guía en vez de reexplicarla.
   - La única excepción, en UNA línea y en voz de opción del estudiante, nunca de mandato:
     si un apéndice te deja archivos versionados —el docker-compose de a01, el .eslintrc de
     a3— y quieres poder volver, `apendice-a01` / `apendice-a3` existe, respetando el número
     de dígitos de cada curso (uno en el Curso 01, dos en el Curso 02). Deja claro que
     ningún documento de apéndice le va a pedir ese tag al lector.
   - Y en «🧪 Tags de ejercicios», añade una línea a los ejemplos que ya están:
        git tag ej/a01/3     # Curso 02, apéndice A01, ejercicio 3
     Aprovecha y aclara ahí mismo, en media línea, algo que hoy confunde: `ej/f07/22`
     aparece en los ejemplos etiquetado como Curso 02, y `ej/f04/17` como Curso 01. No hay
     colisión porque son repos distintos, pero dilo, porque leído del tirón parece un error.""")

# 5. P0 regla dura: añadir apéndices
rep("""REGLA DURA DE ESTE PROMPT: editas UN SOLO ARCHIVO, prompts/convencion-de-git-y-tags.md.
Nada de guía de estilo, nada de fases, nada de apéndices, nada de README.""",
"""REGLA DURA DE ESTE PROMPT: editas UN SOLO ARCHIVO, prompts/convencion-de-git-y-tags.md.
Nada de guía de estilo —§9.1 incluida—, nada de fases, nada de apéndices, nada de README.""")

# 6. P8: nuevo ítem de auditoría
rep("""7. Los tags que se citan existen en la convención (P0): `fase-`, `ej/`, `inc/`, `deuda/`,
   `apendice-`. Ninguna pieza ni incidente inventa un namespace nuevo.""",
"""7. Los tags que se citan existen en la convención (P0): `fase-`, `ej/`, `inc/`, `deuda/`,
   `apendice-`. Ninguna pieza ni incidente inventa un namespace nuevo.
8. LA REGLA DE LOS APÉNDICES: ningún `.md` de apéndice lleva bloque 🏷️, ni tag de fase, ni
   se le pide al lector ningún tag. Los 10 apéndices se revisan uno a uno (guía §9.1).""")
s=s.replace("""8. Pasada de tuteo con la tabla de §4.7 sobre todos los archivos nuevos, homógrafos
   revisados a mano.
9. Todo el código en inglés y todos los comentarios en español, incluidos los parches
   mínimos de las soluciones de referencia.
10. Cero capturas de pantalla. Cero salidas que no se puedan reproducir con el proyecto.
11. Los cuadernos cumplen sus cuotas de categoría, y el checklist de §15 de la guía pasa en
    todos los archivos nuevos.""",
"""9. Pasada de tuteo con la tabla de §4.7 sobre todos los archivos nuevos, homógrafos
   revisados a mano.
10. Todo el código en inglés y todos los comentarios en español, incluidos los parches
    mínimos de las soluciones de referencia.
11. Cero capturas de pantalla. Cero salidas que no se puedan reproducir con el proyecto.
12. Los cuadernos cumplen sus cuotas de categoría, y el checklist de §15 de la guía pasa en
    todos los archivos nuevos.""")

# 7. §11 estado: cerrar la pregunta abierta
rep("""**Un detalle de forma que resolví por mi cuenta al escribir P0**, y que conviene que veas
porque toca una regla existente: pediste tag de apéndice, y la guía §9.1 dice hoy que *"los
apéndices no llevan este bloque, porque no producen código de fase"*. P0 **no cambia esa
regla**: los `.md` de apéndice siguen sin bloque 🏷️. Lo que añade es lo que faltaba en la
convención —el prefijo de commit (`a4:`, `a02:`), el `ej/a01/3` para sus ejercicios, y el
tag `apendice-aNN` **solo** para el caso en que un apéndice deje archivos versionados, como
el `docker-compose` de `a01`—. Si querías que los apéndices lleven tag siempre, dilo y
ajusto P0 y el punto 5 de P2 (que tendría entonces que tocar también la guía §9.1, y el
commit del Paso 0 dejaría de ser de un solo archivo).""",
"""**Los apéndices, cerrado:** la regla §9.1 se honra tal como está y el plan entero la
respeta (§3.5). Ningún `.md` de apéndice lleva bloque 🏷️ ni tag de fase, P0 tiene prohibido
tocar §9.1, P2 lo repite en su punto 5 y P8 lo audita en su ítem 8, apéndice por apéndice.
Lo que P0 añade es solo lo que faltaba —el prefijo de commit (`a4:`, `a02:`) y el
`ej/a01/3`—, más una línea que menciona `apendice-aNN` como opción del estudiante para el
caso en que un apéndice deje archivos versionados. El material nunca se lo pide.""")

open(p,'w',encoding='utf-8').write(s)
print("ok")
PY
wc -l contenido_forense.md

# --- 2026-09-09T04:05:11 · Read the full git convention document
cat -n prompts/convencion-de-git-y-tags.md

# --- 2026-09-09T04:05:25 · Verify paths and scripts before writing
echo "=== store path curso 01 ===" && grep -rhoE 'src/store[a-zA-Z0-9/._-]*' 01-vue2-legacy/*.md | sort | uniq -c | sort -rn | head -8
echo "=== services path ===" && grep -rhoE 'src/services[a-zA-Z0-9/._-]*' 01-vue2-legacy/*.md | sort | uniq -c | sort -rn | head -5
echo "=== scripts npm curso 02 (seed) ===" && grep -rn '"seed"\|npm run seed\|scripts/seed' 02-complement-mongodb-backend/*.md | head -5
echo "=== 14-operacion: imagen docker ===" && grep -n -i 'docker build\|:latest\|image:' 02-complement-mongodb-backend/14-operacion.md | head -8
echo "=== a01-docker nombre ===" && head -3 02-complement-mongodb-backend/a01-docker.md

# --- 2026-09-09T04:05:30 · Check phase 14 and docker usage
grep -n '^#\{2,3\} ' 02-complement-mongodb-backend/14-operacion.md && echo "=== Dockerfile/build en curso 02 ===" && grep -rn 'Dockerfile\|docker build\|docker compose up\|MONGO_VERSION' 02-complement-mongodb-backend/*.md | head -12

# --- 2026-09-09T04:06:57 · Apply P0 edits to the git convention
python3 - <<'PY'
# -*- coding: utf-8 -*-
p='prompts/convencion-de-git-y-tags.md'
s=open(p,encoding='utf-8').read()
def rep(old,new):
    global s
    assert s.count(old)==1,(old[:60],s.count(old))
    s=s.replace(old,new)

# A) intro: coherencia — ahora son tres usos opcionales
rep("""estrategia de ramas elaborada acá sobraría. Son tres cosas — un repo por curso,
commits con un prefijo, y un tag por fase cerrada. Más dos usos opcionales de
los tags que rinden mucho por lo poco que cuestan: los ejercicios y los
incidentes.""",
"""estrategia de ramas elaborada acá sobraría. Son tres cosas — un repo por curso,
commits con un prefijo, y un tag por fase cerrada. Más tres usos de los tags que
rinden mucho por lo poco que cuestan: los ejercicios, los incidentes y las
deudas 💸 que un curso le deja al otro.""")

# B) apéndices, al final de §💬
rep("""Commitea seguido y con mensajes cortos. Nadie va a revisar tu historia, pero tú
vas a volver a ella cuando el ejercicio 22 te deje el proyecto irreconocible.

---

## 🏷️ Un tag por fase cerrada""",
"""Commitea seguido y con mensajes cortos. Nadie va a revisar tu historia, pero tú
vas a volver a ella cuando el ejercicio 22 te deje el proyecto irreconocible.

### Los apéndices

Lo que sale de leer un apéndice también se commitea, y lleva su propio código de
prefijo: `a4` en el Curso 01, `a02` en el Curso 02 —un dígito y dos dígitos,
respetando cómo se llama cada archivo.

```bash
git commit -m "a4: interceptor de axios con reintento"
git commit -m "a02: pipeline de agregación probado en Compass"
```

**Los apéndices no cierran con tag**, y no es un olvido: un tag marca un cambio
en el repositorio, y un apéndice explica lo que ya está ahí. Un tag que no marca
un cambio no marca nada. Por eso ningún apéndice trae el bloque 🏷️ de cierre que
sí traen las fases — está dicho en la
[guía de estilo §9.1](guia-de-estilo-y-convenciones.md).

> 💡 **Si un apéndice te deja archivos versionados** —el `docker-compose.yml` de
> A01, la configuración de linter de A3— y quieres poder volver a ese punto,
> `apendice-a01` / `apendice-a3` existe como opción tuya. Ningún apéndice te lo
> va a pedir: es un atajo disponible, no un paso del curso.

---

## 🏷️ Un tag por fase cerrada""")

# C) ejercicios: apéndices + aclaración de f07
rep("""```bash
git tag ej/f04/17     # Curso 01 tronco, Fase 4, ejercicio 17
git tag ej/q3/22      # Curso 01 ruta Q, fase Q3, ejercicio 22
git tag ej/f07/22     # Curso 02, Fase 7, ejercicio 22
```

Y entonces `git tag -l 'ej/f04/*'` te lista lo que hiciste de esa fase.""",
"""```bash
git tag ej/f04/17     # Curso 01 tronco, Fase 4, ejercicio 17
git tag ej/q3/22      # Curso 01 ruta Q, fase Q3, ejercicio 22
git tag ej/f07/22     # Curso 02, Fase 7, ejercicio 22
git tag ej/a01/3      # Curso 02, apéndice A01, ejercicio 3
```

Y entonces `git tag -l 'ej/f04/*'` te lista lo que hiciste de esa fase.

> 📝 Los dos cursos numeran sus fases desde cero, así que `ej/f07/…` significa
> una cosa en un repo y otra en el otro. No colisionan porque **son repos
> distintos**; leído del tirón, arriba, parece un error y no lo es.""")

# D+E+F+G) cuatro secciones nuevas, después de §🚑 y antes de §📈
rep("""`git tag -n99 -l 'inc/*'` te devuelve el cuaderno de incidentes entero. Y esa
es la parte transferible: es exactamente lo que vas a querer tener el día que
el incidente no sea de juguete.

---

## 📈 Los comandos que hacen que esto sirva""",
"""`git tag -n99 -l 'inc/*'` te devuelve el cuaderno de incidentes entero. Y esa
es la parte transferible: es exactamente lo que vas a querer tener el día que
el incidente no sea de juguete.

---

## 🕵️ Lo que se commitea al recorrer una pieza forense

Poco, y por eso esta sección es corta. Una pieza forense **no produce código del
proyecto**: el código lo escriben las fases, y la pieza te enseña a encontrar
dónde está el problema. Lo que salga de recorrerla —una nota, un script de
diagnóstico, un `console.count` que dejaste puesto— se commitea con el prefijo
de su fase, `f08:`, como cualquier otra cosa de esa fase.

Los dos casos que sí dejan marca ya tienen su namespace más arriba y **no se
inventa uno nuevo**:

- Si el recorrido corresponde a un incidente del cuaderno, va el par
  `inc/<fase>/<slug>-roto` / `-fix` que el cuaderno ya reservó.
- Si sale de un ejercicio de "rompe a propósito", va el par
  `ej/f08/25-roto` / `ej/f08/25-fix`.

No existe un namespace `forense/`, y no debería: un tag marca un cambio, y
mirar no cambia nada. El detalle de cómo se escriben las piezas y el cuaderno
vive en `formato-piezas-forenses.md` y `formato-cuaderno-incidentes.md`, no acá.

---

## 💸 La deuda que sí se paga (y cómo se lee la factura)

Los dos cursos declaran deuda técnica a propósito, la marcan 💸 y dicen en qué
fase se salda. Eso convierte a los tags en algo más que marcadores de progreso:
en los dos extremos de una comparación. Y hay dos casos, que se leen distinto.

**Cuando la deuda nace y muere en el mismo repo.** La Fase 2 del Curso 01 deja
el `login` como una action síncrona porque todavía no hay red, y la Fase 3 lo
paga cuando llega json-server. El diff entre los dos tags de fase, acotado a la
carpeta que cambió, **es** el material del repaso:

```bash
git diff fase-02-autenticacion-minima fase-03-mock-api-minima -- src/store
```

No es una métrica. Es la respuesta a *"¿cuánto costó de verdad arreglar esto?"*,
que es la pregunta que te van a hacer la próxima vez que propongas pagar una
deuda en un sistema real.

**Cuando la deuda cruza los dos repos.** Acá está la deuda estrella del paquete,
y `git diff` no te sirve: la Fase 8 del Curso 01 deja al cliente emitiendo el
evento de socket que debería emitir el servidor —el *cliente mentiroso*— y eso
se paga en la Fase 12 del **otro** curso, en otro repositorio. `git diff` no
cruza repos, así que la comparación hay que armarla a mano… o dejar escritas las
dos mitades donde no se pierden:

```bash
# Repo del Curso 01, al cerrar la fase que declara la deuda:
git tag -a deuda/cliente-mentiroso-declarada -m "F8: el cliente emite
ticket:updated, que debería emitir el servidor. Se paga en el repo del Curso 02,
Fase 12."

# Repo del Curso 02, en el commit que la salda:
git tag -a deuda/cliente-mentiroso-pagada -m "F12: el io.emit sale del servidor
después del write. Cierra deuda/cliente-mentiroso-declarada del repo del
Curso 01 (F8)."
```

El que declara dice qué se debe y dónde se paga; el que paga dice qué cerró y de
dónde venía. Con eso, `git tag -n99 -l 'deuda/*'` te devuelve en cada repo su
mitad del libro mayor, y las dos juntas son la factura completa.

> 💡 **Y esto le da mecánica a algo que ya venías escribiendo.**
> `SECURITY-NOTES.md` acumula desde la Fase 2 del Curso 01 todo lo que "lo
> debería hacer el backend", y la
> [Fase 11 del Curso 02](../02-complement-mongodb-backend/11-auth-real-y-pago-de-deudas.md)
> te pide tachar cada deuda **referenciando el commit que la resolvió**. Ese
> commit es exactamente el que lleva el tag `deuda/…-pagada`: en vez de buscarlo
> en el log, lo nombras.

---

## 🧹 El `db.json` que se ensucia (el truco que más vas a usar)

json-server escribe de verdad. Creas tickets, tomas otros, dejas comentarios — y
todo eso se guarda en `db.json`, que está versionado porque es dato del curso.
Después de media hora de ejercicios tu base de pruebas es un campo de batalla y
ya no puedes reproducir el caso limpio del enunciado.

Tienes dos formas de volver, y **no son la misma**:

```bash
git checkout -- db.json     # te devuelve el archivo como lo commiteaste
npm run mock:reset          # lo pisa entero desde db.seed.json
```

La primera te deja el archivo tal como estaba en tu último commit, con los
escenarios que hubieras construido dentro. La segunda lo regenera desde la
semilla y se los lleva por delante. `db.seed.json` y el script `mock:reset` los
creas tú en el ejercicio 14 de la
[Fase 3](../01-vue2-legacy/03-mock-api-minima.md), y ésa es la razón por la que
ese ejercicio no es opcional.

De ahí sale el hábito que más te va a servir: cuando un ejercicio te pida un dato
particular —un ticket que llega sin el campo `tags`, dos agentes con el mismo
ticket asignado, un comentario cuyo ticket ya no existe—, cárgalo, **commitéalo
como escenario** y etiquétalo si vas a volver:

```bash
git commit -m "f05 ej22: escenario de ticket sin tags"
```

Reconstruir a mano un escenario que ya tuviste es el peor uso posible de tu
tiempo.

> 📝 **En el Curso 02 el estado sucio no está en un archivo, está en la base.**
> Se vuelve con `npm run seed`, o levantando el contenedor de cero cuando la
> cosa se puso fea de verdad
> ([A01](../02-complement-mongodb-backend/a01-docker.md)).

---

## 🐳 Una cosa más, para la Fase 14 del Curso 02

El compose final de la Fase 14 empaqueta el sistema entero, y el Dockerfile de
la API aparece ahí. Cuando llegues, **no dejes esa imagen en `:latest`**:
etiquétala con el mismo nombre del tag de git que la produjo.

```bash
docker build -t minijira-api:fase-14-operacion .
```

Es el mismo reflejo que ya practicaste sin darte cuenta al fijar
`MONGO_VERSION` en vez de aceptar `mongo:latest` — solo que ahora la imagen sin
versionar es la tuya. El día que algo se comporte distinto de como se comportaba
ayer, la primera pregunta es *"¿qué código hay adentro?"*, y con `:latest` no
tienes cómo contestarla. Es la mitad barata del diagnóstico, y es la que casi
nadie tiene.

---

## 📈 Los comandos que hacen que esto sirva""")

# H) comandos nuevos
rep("""# Volver a un estado sano
git checkout fase-05-crud-tickets

# Los ejercicios de una fase, y el cuaderno de incidentes completo
git tag -n99 -l 'ej/f07/*'
git tag -n99 -l 'inc/*'
```""",
"""# Volver a un estado sano
git checkout fase-05-crud-tickets

# Recuperar un archivo de una fase anterior sin moverte de sitio
git checkout fase-05-crud-tickets -- src/components/tickets/TicketForm.vue

# Arrancar un incidente desde la fase que lo produce
git switch -c incidente/07 fase-04-dashboard-tickets

# Los ejercicios de una fase, el cuaderno de incidentes, y el libro de deudas
git tag -n99 -l 'ej/f07/*'
git tag -n99 -l 'inc/*'
git tag -n99 -l 'deuda/*'
```""")

# I) checklist
rep("""- [ ] Si la fase dejó un incidente resuelto, su par `inc/…-roto` / `inc/…-fix`
      existe y sus mensajes cuentan síntoma, causa raíz y fix.""",
"""- [ ] Si la fase dejó un incidente resuelto, su par `inc/…-roto` / `inc/…-fix`
      existe y sus mensajes cuentan síntoma, causa raíz y fix.
- [ ] Si la fase **declara** una deuda 💸, tiene su tag `deuda/<slug>-declarada`
      y el mensaje dice en qué curso y en qué fase se paga.
- [ ] Si la fase **paga** una deuda, tiene su tag `deuda/<slug>-pagada`, el
      mensaje nombra al tag hermano, y `SECURITY-NOTES.md` quedó tachado.""")

open(p,'w',encoding='utf-8').write(s)
print("ok")
PY
wc -l prompts/convencion-de-git-y-tags.md && grep -n '^#\{2,3\} ' prompts/convencion-de-git-y-tags.md

# --- 2026-09-09T04:07:12 · Verify claims, git status, tuteo and links
echo "=== a3-npm: eslint/config? ===" && grep -n -i 'eslint\|lint\|\.npmrc\|config' 01-vue2-legacy/a3-npm.md | head -8
echo; echo "=== git status ===" && git status --short
echo; echo "=== voseo check ===" && grep -nE '\b(tenés|querés|podés|hacés|sabés|debés|mirá|fijate|andá|poné|dale que|vos)\b' prompts/convencion-de-git-y-tags.md | head
echo; echo "=== enlaces relativos ===" && grep -oE '\]\(\.\./?[^)]*\)|\]\([a-z0-9-]+\.md[^)]*\)' prompts/convencion-de-git-y-tags.md | sort -u

# --- 2026-09-09T04:07:26 · Fix A3 claim and spot-check new section
python3 - <<'PY'
p='prompts/convencion-de-git-y-tags.md'
s=open(p,encoding='utf-8').read()
old="""> 💡 **Si un apéndice te deja archivos versionados** —el `docker-compose.yml` de
> A01, la configuración de linter de A3— y quieres poder volver a ese punto,
> `apendice-a01` / `apendice-a3` existe como opción tuya. Ningún apéndice te lo
> va a pedir: es un atajo disponible, no un paso del curso."""
new="""> 💡 **Si un apéndice te deja archivos versionados** —el `docker-compose.yml`
> de A01, los scripts de `package.json` que arma A3— y quieres poder volver a
> ese punto, `apendice-a01` / `apendice-a3` existe como opción tuya. Ningún
> apéndice te lo va a pedir: es un atajo disponible, no un paso del curso."""
assert s.count(old)==1
open(p,'w',encoding='utf-8').write(s.replace(old,new))
print("ok")
PY
sed -n '236,270p' prompts/convencion-de-git-y-tags.md

# --- 2026-09-09T04:11:18 · Read style guide tone and markdown sections
R=/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/8654ffa2-c3be-4e38-8c48-f270a0c7e8e8/tool-results/bk4tnh360.txt
echo "=== §2 TONO + §3 IDIOMA/FORMA ===" && sed -n '60,160p' $R

# --- 2026-09-09T04:11:27 · Read the phase template in full
cat prompts/plantilla-de-fase.md

# --- 2026-09-09T04:11:30 · Read contract id/_id and sockets
sed -n '105,160p' 02-complement-mongodb-backend/00-audit-contrato.md && echo "=== ENUMS/seed ===" && sed -n '45,75p' 02-complement-mongodb-backend/00-audit-contrato.md

# --- 2026-09-09T04:13:02 · Create the forensic pieces format spec
cat > prompts/formato-piezas-forenses.md <<'DOCEOF'
# 🕵️ Formato de las piezas forenses
## Paquete Mini Jira — Curso 01 (Vue 2 legacy) + Curso 02 (MongoDB/Express)

Este documento **no es** una pieza forense: es su especificación. Define cómo se
construyen los `forense-master.md`, los `forense-fase-NN.md` y los
`forense-ruta-<código>.md` de los dos cursos, que son los entregables del track
forense.

Rige por igual a los dos cursos, como la
[guía de estilo](guia-de-estilo-y-convenciones.md), y se lee después de ella: todo lo
que la guía diga sobre tono, tuteo, idioma del código y forma del Markdown vale acá sin
repetirse.

> 🧭 **El track va embebido en las fases y desarrollado aparte.** Cada fase lleva su
> sección 6 —«⚠️ Errores comunes y pieza forense»— con el resumen que se lee de corrido,
> y termina prometiendo el recorrido completo en su archivo. **Esa promesa es un
> contrato:** la pieza entrega exactamente lo que la fase anunció, ni más ni menos.

> 📝 **Este paquete no cuenta horas.** Ni el README ni la guía presupuestan tiempo en
> ningún documento, y el track forense no introduce la costumbre. El tamaño se expresa en
> número de piezas, y el esfuerzo de cada recorrido, en el encabezado de la pieza.

---

## 1. Qué es y qué no es una pieza forense

**Es** el recorrido completo de una investigación: el ticket tal como llegó, cada paso con
su salida literal, y la decisión que ese paso permite tomar. Se lee con el navegador
abierto y el proyecto corriendo.

**No es** ninguna de estas cuatro cosas, y las cuatro son la forma habitual de arruinar el
archivo:

- **No es un resumen de la fase.** La fase ya se leyó. Si un párrafo se puede copiar de la
  sección 6, sobra: enlázala.
- **No es un tutorial de herramientas.** Se usan las herramientas, no se explican. El
  lector es un dev senior de backend: sabe qué es una petición HTTP, y en el Curso 02 sabe
  qué es un plan de consulta.
- **No construye código nuevo del proyecto.** El código lo escriben las fases. Una pieza
  puede pedir romper algo a propósito, y entonces dice cómo deshacerlo.
- **No inventa salidas.** Todo bloque de salida tiene que ser reproducible con el proyecto
  del curso y su semilla. Si un valor depende de la máquina —un puerto, un `ObjectId`, una
  fecha, un tiempo en milisegundos— se marca con `…` o con un marcador evidente.

---

## 2. La regla que reemplaza a las capturas

> 🧭 **Texto, nunca imágenes.** Una captura no se versiona, no se busca con `Ctrl+F`, no
> se puede pegar en un ticket, y envejece con cada versión de Chrome o de Compass. Todo lo
> que en una investigación real mirarías en pantalla, acá se transcribe: el warn literal
> de Vue, la fila de Network en texto, el `explain()` recortado a los campos que importan.

Cuando lo que hay que transmitir es **dónde** mirar y no **qué** dice, se describe la ruta
con las palabras exactas de la interfaz: *"Vue DevTools → pestaña Vuex → el módulo
`tickets` → `state.items` → el ticket 0347"*. Esa frase sobrevive a un rediseño mejor que
una captura, y se puede dictar por teléfono.

---

## 3. Estructura de un `forense-fase-NN.md`

Siete bloques, en este orden. Los bloques 5 y 6 pueden faltar si la fase no da para ellos;
los otros cinco son obligatorios.

1. **Encabezado** — de qué fase sale, qué herramientas usa, cuánto dura el recorrido, y
   **el síntoma en una línea**.
2. **🎫 El ticket** — el reporte literal, con su vaguedad incluida, y quién lo reportó. Si
   la fase promete varios tickets, van todos, cada uno con su ruta.
3. **🧭 La ruta** — los pasos numerados (§4). Es el cuerpo del archivo.
4. **🩺 Diagnóstico por síntoma** — la tabla de "esto veo, acá miro". Es lo que se consulta
   seis meses después, cuando ya no recuerdas el recorrido.
5. **⚰️ Los callejones** — las hipótesis plausibles que no eran, con la evidencia que las
   tumba. Opcional pero muy recomendable: **saber qué descartar vale tanto como saber qué
   buscar**.
6. **🧨 Deshacer** — cómo devolver el proyecto a su estado, si el recorrido pidió romper
   algo. Obligatorio en cuanto haya un solo paso destructivo.
7. **🧠 El patrón transferible** — dos o tres frases con lo que te llevas al trabajo real,
   más los enlaces: los incidentes del cuaderno que usan esta ruta y los apéndices que
   amplían.

---

## 4. Cómo se escribe un paso de la ruta

Cada paso tiene tres partes, siempre en el mismo orden. Es lo que hace que el archivo se
pueda seguir con el teclado en la mano.

````markdown
### Paso N — {{la pregunta que contesta este paso}}

{{Qué haces. Una o dos frases, en imperativo, con la ruta exacta de la interfaz o el
comando completo.}}

```
{{La salida LITERAL. Consola, cuerpo de la respuesta, fila de Network, stdout de mongosh.}}
```

**Qué descarta.** {{Qué hipótesis muere con esta salida, y a qué paso saltas según lo que
hayas visto. Un paso que no descarta nada no es un paso: es relleno.}}
````

Tres reglas sobre los pasos:

- **El orden es la lección.** Los pasos van del más barato al más caro, no del más probable
  al menos probable. Mirar una URL cuesta diez segundos; abrir el profiler de Mongo cuesta
  diez minutos. Ese orden **se dice explícitamente** al empezar la ruta.
- **Un paso, una pregunta.** Si un paso contesta dos cosas, son dos pasos.
- **La ruta termina cuando se sabe dónde está el bug, no cuando está arreglado.** El fix es
  de la fase o del incidente; la pieza forense localiza.

---

## 5. El método: las cuatro preguntas

Las mismas en los dos cursos, y siempre en este orden, porque cada una cuesta un orden de
magnitud más que la anterior.

**Pregunta 1 — ¿se reproduce, y con qué?** Antes de mirar una línea de código: ¿esto se
reproduce **con un flag** del inyector de caos del mock, **con un dato** distinto, o hace
falta **otro código**? Las tres respuestas llevan a investigaciones distintas, y averiguar
cuál es te ahorra la mitad del camino. Es la misma pregunta que ordena la preparación de
los incidentes del cuaderno.

**Pregunta 2 — ¿qué dice la evidencia observable, antes que el código?** La URL de una
petición, el cuerpo crudo de una respuesta, el estado de un módulo de Vuex, el
`docsExamined` de un `explain()`. Casi todas las rutas de este track se resuelven acá, y
ninguna requiere abrir un archivo. **El código es el paso 4, no el paso 1.**

**Pregunta 3 — ¿en qué capa está?** En el Curso 01: componente, store, servicio HTTP o
mock. En el Curso 02: ruta, controller, service o el propio Mongo. Localizar la capa es el
entregable de una investigación; el fix suele ser de tres líneas y viene después. La guía
§6 ya lo llama *"la distinción que salva al que depura"*, y en este track es la pregunta
que más veces cierra el caso.

**Pregunta 4 — ¿de qué lado de la frontera está?** La frontera es el contrato de
[`00-audit-contrato.md`](../02-complement-mongodb-backend/00-audit-contrato.md). Un mismo
síntoma tiene dos causas posibles según de qué lado caiga: el frontend que asumió algo que
el contrato no promete, o el backend que dejó de cumplir lo que sí. Contestar esto antes
de escribir evita el fix que arregla el síntoma en la capa equivocada.

> 🔑 **La frase para memorizar:** *"funciona en mi máquina", "a veces pasa" y "desde ayer"
> no son descripciones de un bug: son descripciones de una diferencia.* El trabajo es
> encontrar cuál.

---

## 6. Las herramientas, y en qué miente cada una

Ninguna herramienta miente por malicia: cada una contesta una pregunta muy concreta, y el
error es preguntarle otra. Esta lista vive completa en cada `forense-master.md`; acá está
el criterio para escribirla.

**Curso 01.** **Vue DevTools** miente por *timeline*: te muestra el estado del store
después de la mutation, no quién la lanzó ni con qué; para eso está el registro de
mutations, y hay que decir cuál de las dos vistas contesta cada pregunta. **La consola**
miente por omisión —un `catch` vacío se traga el fallo entero y deja la pantalla congelada
con la consola limpia— y también por build: los warns de reactividad de Vue 2 **solo salen
en desarrollo**, así que un bug que en `npm run serve` grita, en el build de producción es
mudo. **La pestaña Network** miente por status: un `201` significa que el mock contestó, no
que hizo lo que crees. **Y `git log -S`**, que no es una herramienta de depuración hasta
que lo es: encuentra el commit donde una línea apareció o desapareció.

**Curso 02.** **`explain()`** miente por plan cacheado: el plan que ves puede no ser el que
corrió la primera vez, y en 4.4 conviene decir cuándo hay que limpiarlo. **Compass** miente
por muestreo: lo que llama "el esquema" de una colección es una inferencia sobre una
muestra, no un contrato. **Los logs de Express** mienten por granularidad: un
`500` registrado no te dice si la promesa se rechazó antes o después del write. **Y el
profiler** no miente, pero contesta tarde: cuesta abrirlo, y muchas veces
`db.currentOp()` ya te había dado la respuesta.

---

## 7. Qué pone la fase y qué pone la pieza

La frontera hay que vigilarla, porque los dos textos hablan de lo mismo.

| Va en la sección 6 de la fase | Va en la pieza forense |
|---|---|
| El resumen de qué se rompe y por qué | El recorrido, paso a paso |
| La tabla corta de síntomas, si es lo central de la fase | La tabla completa, con las causas raras |
| El 🧨 «Rompe a propósito» que hace el estudiante | Cómo se lee lo que ese 🧨 produce |
| El enunciado del problema | Las salidas literales y los callejones |

Si un párrafo cabe igual de bien en los dos sitios, va en la fase y la pieza lo enlaza. La
fase se lee siempre; la pieza, solo cuando hace falta.

La fase cierra su sección 6 con una línea fija, que es el contrato entre las dos:

```markdown
> 📄 El recorrido completo, con las salidas literales, en `forense-fase-08.md`.
```

---

## 8. Cuántas piezas, y por qué

**Curso 01 — quince.** Doce de tronco, `forense-fase-00.md` a `forense-fase-11.md`, una por
fase. Y **tres de ruta**, no quince: `forense-ruta-q.md`, `forense-ruta-vu.md` y
`forense-ruta-nx.md`, de unas 120 líneas cada una, cubriendo las cinco fases de su ruta.

El motivo no es ahorrar trabajo. Las rutas son **excluyentes**: quien elige Quasar no va a
leer nunca las de Vuetify ni las de Nuxt. Escribir quince piezas de ruta garantiza que cada
lector descarte diez. Y el conflicto central de las tres es el mismo —*el framework quiere
el estado que tu store ya controla*, que es lo que estalla en Q3, VU3 y NX3—, así que
repartirlo en cinco archivos por ruta lo diluye en vez de concentrarlo. Cada pieza de ruta
**se lee sola**: no se apoya en sus hermanas, porque el lector solo va a abrir una.

**Curso 02 — doce como piso, hasta dieciséis.** Doce es el suelo, no el techo: si al
escribir una fase aparece un recorrido propio que se sostiene, se escribe su pieza. Lo que
**no** se hace es rellenar por simetría. Una pieza forense de una fase que no da para ella
se convierte en un resumen de la fase, que es exactamente lo que prohíbe §1.

Cuatro piezas ya existen dentro de sus fases y se **promueven** a archivo, no se
reescriben: las de `02-consultar-tu-sql-traducido.md`, `09-aggregation.md`,
`10-express-el-vehiculo.md` y `13-testing-de-api.md`.

> ⚠️ **Los dos cursos son independientes.** Hay estudiantes que harán solo el Curso 01 y no
> tocarán Mongo nunca. Ninguna pieza del Curso 01 puede depender de material del Curso 02:
> puede **nombrar** una deuda 💸 y decir que se paga en el otro curso —eso es información
> honesta y cierra el bucle—, pero el recorrido tiene que terminar y enseñar su lección
> sin que el lector cruce de curso. En el Curso 02, las piezas que tocan la costura se
> escriben para alguien que recibe el frontend ya construido.

---

## 9. `forense-master.md`

Es la puerta de entrada y el método del track, uno por curso, y **no repite ninguna
pieza**. Cinco bloques:

1. **El método** — las cuatro preguntas de §5, con el orden justificado por coste.
2. **📇 Índice de las piezas** — una fila por fase: síntoma, herramienta principal,
   archivo. En el Curso 01, las tres piezas de ruta van en su propia sub-tabla, marcadas
   como opcionales y excluyentes entre sí.
3. **🩺 Índice de síntomas transversal** — la tabla que cruza *"esto es lo que veo"* con
   *"acá empiezo"*. **Es la puerta de entrada real:** nadie llega sabiendo de qué fase es
   su problema, llega con *"la pantalla se quedó en blanco"*. Mínimo 25 filas, y se
   construye recorriendo las secciones «⚠️ Errores comunes» de todas las fases del curso y
   recogiendo lo que ya está escrito, no inventando síntomas nuevos.
4. **🧰 Las herramientas y en qué miente cada una** — §6, en una línea por herramienta.
5. **Cierre** — el criterio para saber si el track hizo su trabajo.

Si al escribir el master aparece un síntoma que ninguna fase produce, **no se inventa la
fase**: se saca del índice y se anota al final como pendiente.

---

## 10. Commits y tags

Una pieza forense no produce código del proyecto, así que lo que salga de recorrerla se
commitea con el prefijo de su fase (`f08: …`). Cuando el recorrido corresponde a un
incidente del cuaderno, se usa el par `inc/<fase>/<slug>-roto` / `-fix` que el cuaderno ya
reservó, y cuando sale de un ejercicio de "rompe a propósito", el par
`ej/f08/25-roto` / `-fix`. **No existe un namespace `forense/` y no se inventa uno.**

Todo eso está en [`convencion-de-git-y-tags.md`](convencion-de-git-y-tags.md) §🕵️, y no se
reexplica en ninguna pieza: se enlaza.

---

## 11. Checklist antes de dar por cerrada una pieza forense

- [ ] Entrega **exactamente** lo que la línea 📄 de su fase promete: los tickets que
      anuncia y la salida de cada paso.
- [ ] Cero capturas. Todas las evidencias en texto (§2).
- [ ] Cada paso dice qué descarta y a dónde saltar (§4).
- [ ] Los pasos van del más barato al más caro, y eso se dice al empezar.
- [ ] Ninguna salida está inventada: todo se reproduce con el proyecto del curso y su
      semilla, y lo variable va marcado.
- [ ] Si algún paso rompe algo, hay bloque 🧨 «Deshacer».
- [ ] No repite la sección 6 de su fase (§7).
- [ ] No depende del otro curso (§8), y si nombra una deuda 💸 dice dónde se paga.
- [ ] Nada contradice el contrato: forma de las respuestas, enums `status` y `priority`,
      nombres de evento de socket, mapeo `id` ↔ `_id`.
- [ ] Código en inglés y comentarios en español; Options API en el Curso 01, driver nativo
      antes de Mongoose en el Curso 02.
- [ ] Español latinoamericano con tuteo, cero voseo — pasada de `grep` de la guía §4.7
      hecha.
- [ ] Cada `.md` citado existe con ese nombre exacto (guía §13.2).
- [ ] Enlaza los incidentes del cuaderno que usan esta ruta, por su ID reservado.
- [ ] Cierra con el patrón transferible, que es lo único que el lector se lleva si no
      vuelve a abrir el archivo.
DOCEOF
wc -l prompts/formato-piezas-forenses.md

# --- 2026-09-09T04:14:54 · Create the incident notebook format spec
cat > prompts/formato-cuaderno-incidentes.md <<'DOCEOF'
# 📓 Formato del cuaderno de incidentes
## Paquete Mini Jira — Curso 01 (Vue 2 legacy) + Curso 02 (MongoDB/Express)

Este documento **no es** un cuaderno: es su especificación. Define cómo se construyen los
dos `cuaderno-incidentes.md` del paquete —uno en `01-vue2-legacy/`, otro en
`02-complement-mongodb-backend/`—, que son el entregable de los chats correspondientes.

Se lee después de la [guía de estilo](guia-de-estilo-y-convenciones.md) y del
[formato de las piezas forenses](formato-piezas-forenses.md), y no repite nada de los dos.

> 🧭 **Un solo archivo por curso, sin excepción.** Nada de `incidente-NN.md` sueltos: el
> estudiante trabaja sin instructor y necesita índice, enunciado, pistas, solución y su
> propia bitácora a un scroll de distancia. **Los IDs son globales dentro de su curso y
> nunca se reasignan**, aunque un incidente se retire.

> 📝 **Este paquete no cuenta horas.** El presupuesto es **12 incidentes por cuaderno, 24
> en total**. Cada incidente lleva su propio tiempo sugerido, que es otra cosa: sirve para
> que sepas cuándo estás atascado de verdad, no para llenar un calendario.

---

## 1. Los dos cuadernos son independientes

Es la decisión que más condiciona el contenido, y no es administrativa.

**Los cursos se pueden tomar por separado.** Hay estudiantes que harán solo el Curso 01,
porque van a mantener un frontend Vue 2 y Mongo no les toca. Y el Curso 02 se puede
empezar directo, sin haber escrito una línea del frontend. Los dos cuadernos tienen que
funcionar en ese escenario.

De ahí salen tres reglas duras:

- **El cuaderno del Curso 01 no cita ni una fase del Curso 02.** Puede nombrar una deuda 💸
  y decir que se paga "cuando exista un backend de verdad" —eso es honesto y cierra el
  bucle—, pero ningún incidente se resuelve leyendo el otro curso.
- **Los incidentes de costura viven en el Curso 02 y son autocontenidos.** Entregan el
  frontend ya construido como punto de partida —una rama, un repo clonado, lo que el
  incidente diga— y se resuelven sin haber hecho el Curso 01.
- **Los IDs no se comparten.** Cada curso numera desde `01`. El incidente 05 del Curso 01 y
  el 05 del Curso 02 no tienen nada que ver, igual que sus tags `inc/…` viven en repos
  distintos.

Y hay una razón operativa además de la pedagógica: los incidentes se preparan con
`git switch -c incidente/07 fase-04-dashboard-tickets`, un comando que no existe si el tag
está en el otro repositorio.

---

## 2. Qué hace distinto a cada cuaderno

**El del Curso 01** entrena algo que ningún otro curso del repositorio entrena: **la
reactividad de Vue 2 como fuente de bugs silenciosos**. La propiedad añadida a un objeto
que ya vive en el store, la asignación por índice en un array, el warn que solo sale en
desarrollo. Son bugs donde el dato es correcto, la petición es correcta, y la pantalla
miente — y no se parecen a nada de lo que el lector vio en backend.

**El del Curso 02** entrena lo contrario: bugs donde la pantalla dice la verdad y el
problema está en el modelo. El `$lookup` que parecía gratis, los dos agentes que tomaron el
mismo ticket, el índice creado que nadie usa. Su hilo conductor es `soporte_v1`, el
anti-patrón medido de las fases 3 a 8.

**Y los dos comparten la costura**, que es material exclusivo de este paquete: el momento
en que un frontend escrito contra json-server se enfrenta a un backend real. El `id`
numérico que ahora es un string hex, el evento de socket que cambió de emisor, el `DELETE`
que devolvía `{}`. Nada de eso es un bug de nadie: es un contrato mal leído, que es el
incidente más común en la vida real y el que menos se enseña.

---

## 3. Estructura del archivo

En este orden, y solo en este:

1. **Encabezado** — título, el presupuesto de 12 incidentes, y la frase que fija el trato:
   la solución viene incluida, y abrirla antes de tiempo solo te perjudica a ti.
2. **🧭 Cómo se trabaja un incidente** — el método, las tres formas de llegar al sistema
   roto (§6), la convención de commits (§7) y la tabla de estados (§8).
3. **📋 Índice** — la tabla de los 12 IDs (§4).
4. **🧪 Incidentes** — una entrada por incidente, con el bloque completo de §9. Se repite
   entero cada vez: nada de "ver incidente 03". Se leen salteados y con semanas de
   diferencia.
5. **🪞 Retrospectiva** — §10.
6. **📌 Pendientes que salieron de los incidentes** — §11.

---

## 4. El índice y la reserva de IDs

El índice se actualiza en el mismo commit que abre o cierra un incidente. Un ⬜ significa
que el enunciado todavía no está redactado abajo — **la fila existe desde el momento en que
una fase reserva el ID**, en su bloque `### Reservas para el cuaderno de incidentes`.

```markdown
| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| 05 | 5 | "Le puse etiqueta al ticket y la tabla no se enteró" | Reactividad | 🟡 | ⬜ |
```

> ⚖️ **Divergencia declarada respecto de la guía §3.** La guía limita las tablas a tres
> columnas, porque su regla apunta a las **comparativas**, donde una celda necesita
> explicación y una lista se lee mejor. Ésta no es una comparativa: es una tabla de
> control, seis campos atómicos que se escanean de un vistazo y se ordenan mentalmente por
> cualquiera de ellos. Una lista con subtítulos aquí sería ilegible. La divergencia se
> limita a **este índice y al de la retrospectiva**; el resto del cuaderno sigue la regla.

El título va **en palabras del usuario**, no en lenguaje técnico. *"Tomé el ticket y a mi
compañero le sigue apareciendo libre"* es un buen título; *"race condition en `takeTicket`"*
es la respuesta, y va dentro de la solución.

### Cómo se reparten los 12

Las fases exactas las fijan las reservas de cada fase, pero el reparto no se negocia. La
progresión sigue el arco del curso: los primeros son de una capa, los últimos cruzan
varias.

**Curso 01** — cuatro tramos de tres:

- **Fases 0–3 · tres incidentes 🟢🟢🟡.** Setup y arranque, el endpoint mal escrito, el
  mock caído que parece un bug del frontend, la sesión que sobrevive a lo que no debería.
- **Fases 4–6 · tres incidentes 🟡.** La lista que se pinta con los datos de antes, la
  propiedad que el store tiene y la tabla no muestra, el wizard que deja avanzar con un
  paso vacío.
- **Fases 7–9 · tres incidentes 🟠.** La métrica que no cuadra con la tabla, el evento de
  socket que duplica filas, el doble "tomar" que ninguno de los dos agentes ve.
- **Fases 10–11 · tres incidentes 🟠🔴🔴.** El módulo de Vuex que se pisa a sí mismo, el
  test que pasa solo cuando corre aislado, y el bug que solo existe en el build de
  producción.

**Curso 02** — cuatro tramos de tres:

- **Fases 0–2 · tres incidentes 🟢🟡.** El contenedor que arranca y no responde, la
  consulta traducida literalmente desde SQL, el filtro que devuelve de más.
- **Fases 3–6 · tres incidentes 🟡🟠.** El documento que crece sin techo, el `$lookup` que
  parecía gratis, y los dos agentes que tomaron el mismo ticket.
- **Fases 7–9 · tres incidentes 🟠.** El índice creado que `explain()` ignora, el arco de
  `soporte_v1` con números, el pipeline que colapsa a una sola fila.
- **Fases 10–13 · tres incidentes 🔴, dos de ellos de costura.** El frontend que no muestra
  nada mientras `curl` sí devuelve los tickets, el evento de socket que ahora llega dos
  veces, y la suite que pasa en local y falla en CI.

### Cuotas mínimas

Para que cada cuaderno cubra de verdad el corazón de su curso:

- **Curso 01** — al menos **2 de reactividad de Vue 2**, **2 de Vuex** y **2 que aterricen
  una deuda 💸 declarada** en alguna fase.
- **Curso 02** — al menos **2 de atomicidad o concurrencia**, **2 del anti-patrón
  `soporte_v1`** y **2 de costura**, estos últimos autocontenidos según §1.

Si al escribir un incidente resulta que no tiene una causa raíz propia —que es la única
razón válida para que un incidente exista—, **no se fuerza**: se retira, se documenta por
qué en 📌 Pendientes, y su ID **no se reasigna**.

### Categorías

**Curso 01:** reactividad · estado (Vuex) · integración (mock) · formularios y wizard ·
tiempo real (sockets) · convivencia con framework de ruta · UI · testing · build.

**Curso 02:** modelado (embeber/referenciar) · consultas y `explain()` · atomicidad y
concurrencia · índices · contrato · auth · operación · testing.

### Dificultad

🟢 fácil · 🟡 intermedio · 🟠 difícil · 🔴 muy difícil. Cada incidente lleva además un
**tiempo sugerido** —de 20-40 min los 🟢 hasta un par de horas los 🔴—, porque sin él el
estudiante no sabe cuándo está atascado de verdad y cuándo simplemente le está costando lo
que tiene que costar.

---

## 5. Los cursos son independientes, también acá

Ya está dicho en §1 y se repite en el checklist, porque es la regla que más fácil se olvida:
el paquete se lee como una unidad y la tentación de encadenar los dos cuadernos es
constante. Antes de dar por bueno un incidente, la pregunta es: **¿se puede resolver sin
abrir el otro curso?** Si la respuesta es no, o el incidente cambia o cambia de cuaderno.

---

## 6. Cómo llega el sistema roto a tu máquina

Cada incidente lo dice en su bloque **🔧 Preparación**, y hay exactamente tres formas. El
orden no es casual: **se usa siempre la más barata que sirva**, porque una preparación
complicada es una excusa para saltarse el incidente.

**1 · Un flag del inyector de caos** (Curso 01, Fase 3), cuando el fallo es de red o de
respuesta. Es la preferida: no toca tu código, no toca tus datos, y se apaga sola al
reiniciar el mock.

```bash
CHAOS=malformed npm run mock
```

**2 · Un `db.json` alterno**, cuando el bug está en el dato y no en el código: un ticket que
llega sin el campo `tags`, un comentario cuyo ticket ya no existe. Se llaman
`db.incidente-NN.json`, viven junto al `db.json`, y se activan copiando. En el Curso 02 el
equivalente es un seed alterno, `scripts/seed.incidente-NN.js`.

```bash
cp db.incidente-05.json db.json    # guarda el tuyo antes, o corre npm run mock:reset después
```

**3 · Una rama de git**, y solo cuando haya que romper código. Sale del tag de la fase
correspondiente, así que se crea sin buscar nada:

```bash
git switch -c incidente/07 fase-04-dashboard-tickets
# …y el commit de la rama trae el cambio mínimo que produce el síntoma
```

> 🔑 **La regla, y sirve mucho más allá de este cuaderno:** cuando alguien te pida
> reproducir un bug, la primera pregunta es *"¿esto se reproduce con un flag, con un dato,
> o hace falta otro código?"*. Averiguarlo te ahorra la mitad del camino antes de leer una
> línea.

---

## 7. La convención de commits

El asunto sigue este formato, para que `git log --oneline` se lea como la línea de tiempo
de la investigación:

```
incidente(05): abre — la etiqueta no aparece en la tabla
incidente(05): repro — solo pasa con tickets que vienen sin el campo tags
incidente(05): hipótesis descartada — no es el mock, el PATCH devuelve el ticket completo
incidente(05): causa — la propiedad se agrega después de que el objeto entró al store
incidente(05): fix — Vue.set en la mutation UPSERT_TICKET
incidente(05): cierre — test de regresión y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`, `causa`, `fix`,
`cierre`.

**Commitea también los callejones sin salida.** Un `git log` con seis commits de
investigación y uno de fix es un registro honesto; uno que muestra solo el fix no le sirve
a nadie, y menos a ti dentro de seis meses.

Y como el fix de casi todos estos incidentes es de una o dos líneas, márcalo además con el
par de tags de [`convencion-de-git-y-tags.md`](convencion-de-git-y-tags.md) §🚑:

```bash
git tag -a inc/f05/etiqueta-invisible-roto -m "Síntoma, repro y la prueba en rojo."
# …el fix…
git tag -a inc/f05/etiqueta-invisible-fix  -m "Causa raíz, fix, y la prueba en verde."

git diff inc/f05/etiqueta-invisible-roto inc/f05/etiqueta-invisible-fix
git tag -n99 -l 'inc/*'
```

Cuando la solución de un incidente **salda una deuda 💸 declarada**, se dice y se usa el tag
`deuda/<slug>-pagada` de la misma convención: es el mismo mecanismo, no uno paralelo.

> 💡 Para releer la historia de un incidente:
> `git log --oneline --grep "incidente(05)"`

**Regla del archivo: se agrega, no se corrige.** Una hipótesis que resultó falsa no se
borra: se marca como descartada, con la evidencia que la tumbó.

---

## 8. Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y prueba de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 9. La plantilla de un incidente

Se copia entera para cada entrada.

> ⚖️ **Divergencia declarada respecto de la guía §3.** La guía dice *"Markdown siempre.
> Nada de HTML embebido salvo que no haya alternativa"*, y acá no la hay: las pistas y la
> solución tienen que **poder ocultarse**, o el ejercicio se arruina con solo bajar la
> vista. Los `<details>` son la única excepción del paquete, y se limitan a este uso.

````markdown
## Incidente {{NN}} — {{Título en palabras del usuario}}

> **Fase:** {{N}} · **Categoría:** {{categoría}} · **Dificultad:** {{🟢🟡🟠🔴}}
> **Estado:** ⬜ Sin empezar · **Abierto:** {{—}} · **Cerrado:** {{—}}
> **Tiempo sugerido:** {{20-40 min}}

### 🎫 El ticket

{{El reporte tal como llegó, con su vaguedad incluida. Dos o tres frases en lenguaje de
negocio, escritas por alguien que no sabe qué es una mutation ni un índice compuesto. "A
veces pasa" es un dato legítimo, no un defecto del reporte.}}

**Reportado por:** {{rol — agente de soporte, coordinador, reportador, alguien de sistemas}}
**Ambiente:** {{desarrollo / UAT / ambos}}

### 🎯 Qué se te pide

{{Una o dos líneas con el entregable concreto: reproducir y localizar la capa, o reproducir
y aplicar el hotfix mínimo, o explicar por qué NO se reproduce. No todos los incidentes
terminan en fix, y el que termina en "esto no es un bug, y acá está la evidencia" es de los
más formativos.}}

### 🔧 Preparación

{{Cuál de las tres formas de §6, y por qué esa.}}

```bash
{{CHAOS=malformed npm run mock | cp db.incidente-NN.json db.json | git switch -c incidente/NN fase-NN-slug}}
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

{{Señala la capa y la herramienta, sin decir qué vas a encontrar: "esto se ve en Network
antes que en la consola", "el store ya tiene el dato correcto; compara lo que guarda con lo
que pinta la tabla".}}

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

{{Acota al archivo o al momento exacto, todavía sin nombrar la causa.}}

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

{{La pregunta cuya respuesta es la causa raíz.}}

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución. Es la parte que se versiona y la que vas
a releer en la retrospectiva.}}

**Reproducción**
{{Pasos numerados y exactos, con datos concretos: qué ticket, qué agente, qué estado, qué
hora y en qué zona horaria. Si no lo lograste, escribe qué intentaste — no reproducir
también es un resultado.}}

**Evidencia observable**
{{Lo que viste, no lo que supones: consola, Network, Vue DevTools, logs del mock, mongosh,
`explain()`. Texto, no capturas: el texto se versiona.}}

```
{{payload, error o traza}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea, o la decisión de diseño culpable.}}

**En qué capa vivía**
{{Componente / store / servicio HTTP / mock — o ruta / controller / service / Mongo. Es la
pregunta 3 del método, y anotarla es lo que después hace útil la retrospectiva.}}

**Tu fix**
{{El parche mínimo que aplicarías un viernes a las seis, escrito en el estilo del archivo
que tocaste. Aparte, en una línea, la refactorización correcta que harías con calma.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

{{Hasta el archivo y la línea. Si la causa es una decisión de diseño, se nombra la decisión
y se explica en qué momento de la vida de Mini Jira tenía sentido.}}

**Parche mínimo**

```js
{{el hotfix, con comentarios en español, identificadores en inglés, y en el estilo del
archivo que se toca: Options API y function () {} en el Curso 01, driver nativo en el 02}}
```

**La refactorización correcta**

{{Qué haría alguien con tiempo y pruebas. Si la deuda que originó el bug está marcada 💸 en
alguna fase, decir en cuál se paga — y si es del otro curso, decirlo sin exigir haberlo
hecho.}}

**Prueba de regresión**

{{El test que falla antes del fix y pasa después. Código, no descripción.}}

```js
{{spec}}
```

**Prevención**

{{Test, validación en la frontera del servicio, normalización del payload, índice, feature
flag o alerta.}}

**Por qué llegó a producción**

{{Post-mortem sereno: qué del sistema o del proceso lo permitió. Se analiza el sistema,
nunca a la persona. Acá el humor baja un punto — un post-mortem no es el lugar del chiste.}}

**Si tu causa fue distinta a ésta**

{{Los diagnósticos alternativos plausibles y por qué el síntoma también encaja con ellos.
Que tu fix funcione y tu causa no coincida es información: casi siempre significa que
tapaste el síntoma en una capa más arriba.}}

</details>
````

---

## 10. La retrospectiva

Cierra el archivo. Se llena al terminar, de una sola vez, releyendo tu propio `git log`:

- **Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪.**
- **Cuántas veces tu causa raíz coincidió con la de referencia**, y en cuáles no. El patrón
  importa más que el número.
- **En qué capa te costó más.** Es la métrica propia de este paquete, y sale directamente
  del campo "en qué capa vivía" de cada incidente: si el 70 % de tu tiempo se fue buscando
  en el componente lo que estaba en el store, eso es un dato sobre cómo lees código, no
  sobre estos doce bugs.
- **Cuántas veces el síntoma estaba en una capa y la causa en otra.** Es la definición
  práctica de un bug difícil.
- **Qué pista abriste antes de tiempo y por qué.** Sin culpa: es un dato sobre dónde te
  falta confianza, no sobre tu disciplina.
- **Tu checklist de hotfix**, de una página, reescrita con lo que aprendiste. Es lo único
  de este archivo que te llevas a un sistema que no es Mini Jira.

---

## 11. Pendientes que salieron de los incidentes

Lo que apareció investigando y no cabía en el fix, con el ID que lo originó:

```markdown
- **[05]** {{pendiente}} → sugerido para {{apéndice / fase / ejercicio 🔥}}.
```

Acá van también los incidentes retirados, con el motivo, para que su ID quede
explícitamente muerto y nadie lo reutilice.

---

## 12. Checklist antes de dar por cerrado un cuaderno

- [ ] 12 incidentes, con el reparto por tramos y dificultad de §4.
- [ ] Las cuotas mínimas de categoría se cumplen (§4).
- [ ] **Independencia:** ningún incidente del Curso 01 cita el Curso 02, y los de costura
      del Curso 02 se resuelven sin haber hecho el Curso 01 (§1).
- [ ] Todos los IDs del índice tienen entrada abajo, y ninguno se reasignó. Los retirados
      están en 📌 Pendientes con su motivo.
- [ ] Cada incidente dice cuál de las tres formas de preparación usa, y usa la más barata
      que sirve (§6).
- [ ] Cada solución trae parche mínimo, refactorización correcta, prueba de regresión **en
      código**, prevención y post-mortem sin culpabilización.
- [ ] Los títulos están en palabras del usuario, no en lenguaje técnico.
- [ ] Nada contradice el contrato de
      [`00-audit-contrato.md`](../02-complement-mongodb-backend/00-audit-contrato.md):
      forma de las respuestas, enums `status` y `priority`, nombres de evento de socket,
      mapeo `id` ↔ `_id`.
- [ ] Todo el código en inglés, comentarios en español, y el parche escrito en el estilo del
      archivo que toca.
- [ ] Español latinoamericano con tuteo, cero voseo — y ojo con los tickets, que están
      escritos en voz de usuario y son donde más se cuela (guía §4.7).
- [ ] Cada `.md` citado existe con ese nombre exacto (guía §13.2).
- [ ] La retrospectiva y los pendientes están al final, en ese orden.
DOCEOF
wc -l prompts/formato-cuaderno-incidentes.md
echo "=== voseo ===" && grep -nE '\b(tenés|querés|podés|hacés|sabés|debés|mirá|fijate|andá|poné|agregá|vos)\b' prompts/formato-*.md | head
echo "=== enlaces ===" && grep -ohE '\]\([^)h][^)]*\)' prompts/formato-*.md | tr -d '])(' | sort -u

# --- 2026-09-09T04:15:04 · Verify links and package git status
for f in prompts/guia-de-estilo-y-convenciones.md prompts/convencion-de-git-y-tags.md prompts/formato-piezas-forenses.md 02-complement-mongodb-backend/00-audit-contrato.md; do [ -f "$f" ] && echo "OK  $f" || echo "FALTA $f"; done
echo; echo "=== git status del paquete ===" && git status --short . 
echo; echo "=== secciones ===" && grep -c '^## ' prompts/formato-piezas-forenses.md prompts/formato-cuaderno-incidentes.md

# --- 2026-09-09T04:22:26 · Read guide section 9
sed -n '613,660p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-09T04:22:28 · Read guide sections 13.1, 13.2 and 15
sed -n '826,875p' prompts/guia-de-estilo-y-convenciones.md; echo "=====FIN====="; sed -n '895,934p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-09T04:22:38 · Read guide 9.1 tail and locate convention sentence
sed -n '665,682p' prompts/guia-de-estilo-y-convenciones.md; echo "=== §🚑 frase en convención ==="; grep -n "te devuelve el cuaderno de incidentes entero" prompts/convencion-de-git-y-tags.md

# --- 2026-09-09T04:23:14 · Patch the style guide
python3 - <<'PY'
# -*- coding: utf-8 -*-
g='prompts/guia-de-estilo-y-convenciones.md'
s=open(g,encoding='utf-8').read()
def rep(old,new):
    global s
    assert s.count(old)==1,(old[:70],s.count(old))
    s=s.replace(old,new)

# --- 1. §9 punto 6
rep("""6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente y cómo se
   depura.""",
"""6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente y cómo se
   depura. El **resumen** va en la fase; el **recorrido completo** vive en su
   propio archivo (§9.2).""")

# --- 2. nueva §9.2
rep("""Los apéndices **no** siguen esta plantilla: usan índice de salto rápido,
secciones cortas, una guía final de "cuándo usar qué" y 5–10 ejercicios
cortos.

---

## 10. Ejercicios""",
"""Los apéndices **no** siguen esta plantilla: usan índice de salto rápido,
secciones cortas, una guía final de "cuándo usar qué" y 5–10 ejercicios
cortos.

### 9.2 La pieza forense va en su archivo

La sección 6 se reparte entre dos documentos, y conviene decir por qué, porque
esta guía antes la daba por entera dentro de la fase.

**En la fase** queda lo que se lee de corrido: los errores comunes con su
síntoma → causa → fix mínimo, el resumen de qué depurar y con qué, y el bloque
🧨 **Rompe a propósito** que el estudiante ejecuta. **En el archivo** queda el
recorrido paso a paso, con las salidas literales, los callejones que hay que
descartar y el diagnóstico por síntoma completo.

La fase cierra su sección 6 con una línea de forma fija, que es el contrato
entre las dos:

```markdown
> 📄 El recorrido completo, con las salidas literales, en `forense-fase-08.md`.
```

**Por qué se separan.** La fase se lee una vez, en orden y de principio a fin.
La pieza forense se consulta **fuera de orden y meses después**, cuando llega
un ticket vago y no sabes ni de qué fase es tu problema: un archivo se abre por
su nombre, y una sección enterrada en una fase de novecientas líneas no se
encuentra. Además, una pieza bien hecha son doscientas líneas más sobre fases
que ya pesan entre quinientas y mil novecientas.

**La regla anti-solapamiento:** si un párrafo cabe igual de bien en los dos
sitios, va en la fase y la pieza lo enlaza. La fase se lee siempre; la pieza,
solo cuando hace falta. La especificación completa —estructura de la pieza,
cómo se escribe un paso, y la tabla de frontera— está en
`prompts/formato-piezas-forenses.md`, y no se reexplica en ninguna fase.

Los apéndices tampoco llevan pieza forense, por lo mismo que no llevan bloque
🏷️: no producen código de fase.

---

## 10. Ejercicios""")

# --- 3. §13.1: los dos formatos como fuente de verdad
rep("""5. Esta guía y `prompts/convencion-de-git-y-tags.md`, que es su anexo para
   todo lo que toque git, repos y tags.""",
"""5. Esta guía y sus tres anexos: `prompts/convencion-de-git-y-tags.md` para
   todo lo que toque git, repos y tags; `prompts/formato-piezas-forenses.md` y
   `prompts/formato-cuaderno-incidentes.md` para el track forense y el
   cuaderno de incidentes.""")

# --- 4. §13.2 nomenclatura
rep("""- **Documentos maestros:** `0-plan-del-curso.md`, `0-ESTRUCTURA-CURSO.md`,
  `README.md` (que hace de índice de cada curso).""",
"""- **Track forense (uno de cada por curso):** `forense-master.md`,
  `forense-fase-00.md` … `forense-fase-NN.md`, y —solo en el Curso 01—
  `forense-ruta-q.md`, `forense-ruta-vu.md` y `forense-ruta-nx.md`, una por
  ruta y no una por fase de ruta.
- **Cuaderno de incidentes:** `cuaderno-incidentes.md`, uno por curso.
- **Documentos maestros:** `0-plan-del-curso.md`, `0-ESTRUCTURA-CURSO.md`,
  `README.md` (que hace de índice de cada curso).""")

# --- 5. nueva §16, después de §15 (al final del archivo)
s = s.rstrip('\n') + """

---

## 16. El track forense y el cuaderno de incidentes

Dos entregables por curso, además de las fases. No son material extra: son el
desarrollo de una sección que la plantilla ya cuenta (§9.2) y de una estructura
que esta guía ya define (§14).

**El track forense** son las piezas de recorrido, más su puerta de entrada. Cada
`forense-fase-NN.md` lleva una investigación completa —el ticket como llegó,
cada paso con su salida literal, y qué descarta cada paso—, y `forense-master.md`
trae el método de cuatro preguntas y el 🩺 índice de síntomas transversal, que es
lo que de verdad se consulta: nadie llega sabiendo de qué fase es su problema,
llega con *"la pantalla se quedó en blanco"*. En el Curso 01 son doce piezas de
tronco más tres de ruta —una por ruta, porque son excluyentes y quien elige
Quasar no leerá nunca las de Vuetify—; en el Curso 02, doce como piso.

**El cuaderno de incidentes** es un archivo por curso con doce tickets vagos, de
los que llegan de verdad, cada uno con su preparación, tres pistas plegadas,
espacio para tu investigación y una solución de referencia con parche mínimo,
prueba de regresión en código y post-mortem. Es donde la estructura de ocho
puntos de §14 deja de ser una especificación y se instancia.

> ⚠️ **Los dos cursos son independientes, y el material forense lo respeta.** Hay
> quien hará solo el Curso 01 y no tocará Mongo nunca. Ninguna pieza ni incidente
> del Curso 01 puede depender del Curso 02 —puede nombrar una deuda 💸 y decir
> dónde se paga, pero el recorrido cierra solo—, y los incidentes de costura del
> Curso 02 se resuelven partiendo de un frontend que se entrega ya construido.

La especificación completa vive en `prompts/formato-piezas-forenses.md` y
`prompts/formato-cuaderno-incidentes.md`, que son anexos de esta guía (§13.1) y
mandan sobre todo lo que se escriba en esos archivos. Esta sección no los
duplica: dice que existen y para qué.
"""

# --- 6. §15 checklist (va antes de la nueva §16; se inserta en el último ítem)
rep("""- [ ] Lleva el bloque 🏷️ del tag de la fase, con el nombre correcto
      (`fase-` + slug del archivo) y el prefijo de commit correcto (§9.1). Los
      apéndices no lo llevan.""",
"""- [ ] Lleva el bloque 🏷️ del tag de la fase, con el nombre correcto
      (`fase-` + slug del archivo) y el prefijo de commit correcto (§9.1). Los
      apéndices no lo llevan.
- [ ] La sección 6 lleva su pieza forense —resumen, 🧨 «Rompe a propósito» y la
      línea 📄 hacia el archivo del recorrido (§9.2)—, o dice por qué no.
- [ ] Lleva el bloque «📌 Reservas para el cuaderno de incidentes», o declara
      que esta fase no reserva ninguno. Los apéndices no lo llevan.
- [ ] Cada ID reservado existe en el índice del `cuaderno-incidentes.md` de su
      curso, y ninguno se reasignó.""")

open(g,'w',encoding='utf-8').write(s)
print("guía ok")
PY
wc -l prompts/guia-de-estilo-y-convenciones.md && grep -n '^## 1[3-6]\|^### 9\.' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-09T04:24:02 · Patch template and convention
python3 - <<'PY'
# -*- coding: utf-8 -*-
t='prompts/plantilla-de-fase.md'
s=open(t,encoding='utf-8').read()
def rep(old,new):
    global s
    assert s.count(old)==1,(old[:70],s.count(old))
    s=s.replace(old,new)

# --- sección 6: pieza forense con 🧨 y la línea 📄
rep("""### Pieza forense de esta fase

{{Qué depurar, específico de esta fase: consola, Network, Vue DevTools, o
—en el Curso 02— logs, profiler y `explain()`. Incluir al menos un ejercicio
de "rompe a propósito y observa".}}

---""",
"""### Pieza forense de esta fase

{{El RESUMEN que se lee de corrido: qué se rompe en esta fase, con qué se
depura —consola, Network, Vue DevTools, o en el Curso 02 logs, profiler y
`explain()`— y cuál es la señal que lo delata. El recorrido paso a paso NO va
acá: va en su archivo (guía §9.2).}}

**🧨 Rompe a propósito**

{{Una rotura concreta que el estudiante ejecuta y observa. Qué tocar, qué
esperar, y —si hace falta— cómo deshacerlo. Es lo que convierte la teoría de
esta sección en un reflejo.}}

> 📄 El recorrido completo, con las salidas literales, en
> `forense-fase-{{NN}}.md`.

{{Si un párrafo cabe igual de bien en la fase y en la pieza, va en la fase y la
pieza lo enlaza. La especificación está en
`prompts/formato-piezas-forenses.md`.}}

---""")

# --- bloque de reservas, al final del esqueleto
rep("""**Siguiente parada:** {{emoji}} Fase {{N+1}} — {{una o dos líneas de puente}}
```""",
"""**Siguiente parada:** {{emoji}} Fase {{N+1}} — {{una o dos líneas de puente}}

---

### 📌 Reservas para el cuaderno de incidentes

{{Los IDs que esta fase reserva para el `cuaderno-incidentes.md` de su curso.
Título en palabras del usuario, no en lenguaje técnico. Si la fase no reserva
ninguno, se escribe "Esta fase no reserva incidentes" y se dice por qué.}}

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| {{NN}} | {{"tomé el ticket y a mi compañero le sigue apareciendo libre"}} | {{categoría}} | {{🟡}} |
```

> 📐 **Sobre el bloque de reservas y "Siguiente parada".** El bloque 📌 va
> físicamente al final, después de "Siguiente parada", y eso no contradice
> §9.1 de la guía: aquel dice que "Siguiente parada" es lo último **de la
> fase**, y el 📌 no es narrativa de la fase — es un bloque de servicio,
> dirigido a quien escribe el cuaderno y a quien audita que los IDs cuadren.
> Los IDs son correlativos **por curso** y no se reasignan nunca, ni siquiera
> cuando un incidente se retira. La especificación está en
> `prompts/formato-cuaderno-incidentes.md`.""")

# --- recordatorios al final
rep("""- **Los apéndices no usan esta plantilla:** índice de salto rápido, secciones
  cortas, guía final de "cuándo usar qué" y 5–10 ejercicios cortos.""",
"""- **La sección 6 se reparte** (guía §9.2): el resumen y el 🧨 en la fase, el
  recorrido en `forense-fase-NN.md`. La línea 📄 que las une es de forma fija y
  tiene que apuntar a un archivo que exista. En las fases de ruta apunta a la
  pieza de **su** ruta (`forense-ruta-q.md`, `-vu.md`, `-nx.md`), que es una
  por ruta y no una por fase.
- **Los apéndices no usan esta plantilla:** índice de salto rápido, secciones
  cortas, guía final de "cuándo usar qué" y 5–10 ejercicios cortos. Tampoco
  llevan pieza forense, ni bloque 📌 de reservas, ni bloque 🏷️ de tag.""")

open(t,'w',encoding='utf-8').write(s)
print("plantilla ok")

# --- convención: la frase del §🚑
c='prompts/convencion-de-git-y-tags.md'
s=open(c,encoding='utf-8').read()
old="""`git tag -n99 -l 'inc/*'` te devuelve el cuaderno de incidentes entero. Y esa
es la parte transferible: es exactamente lo que vas a querer tener el día que
el incidente no sea de juguete."""
new="""`git tag -n99 -l 'inc/*'` te devuelve tu bitácora entera sin abrir un archivo, y
ésa es la parte transferible: es exactamente lo que vas a querer tener el día
que el incidente no sea de juguete.

Los enunciados viven en el `cuaderno-incidentes.md` de tu curso —doce por
cuaderno, con su preparación, sus pistas y su solución de referencia— y el
reparto es claro: **el archivo es el enunciado y tu investigación escrita; los
tags son la misma investigación, ejecutable.** El `git diff` entre el par
`-roto` y `-fix` es lo único que no se puede falsificar."""
assert s.count(old)==1
open(c,'w',encoding='utf-8').write(s.replace(old,new))
print("convención ok")
PY
echo "=== status ===" && git status --short . && echo && wc -l prompts/plantilla-de-fase.md prompts/convencion-de-git-y-tags.md

# --- 2026-09-09T04:24:12 · Final verification of P2
echo "=== voseo en los 5 archivos ===" && grep -nE '\b(tenés|querés|podés|hacés|sabés|debés|mirá|fijate|andá|poné|agregá|vos)\b' prompts/guia-de-estilo-y-convenciones.md prompts/plantilla-de-fase.md prompts/convencion-de-git-y-tags.md prompts/formato-*.md | head
echo "=== archivos citados en lo nuevo de la guía ==="
for f in prompts/formato-piezas-forenses.md prompts/formato-cuaderno-incidentes.md prompts/convencion-de-git-y-tags.md; do [ -f "$f" ] && echo "OK  $f"; done
echo "=== §16 y §9.2 presentes ===" && grep -n '9.2 La pieza forense\|## 16. El track forense' prompts/guia-de-estilo-y-convenciones.md
echo "=== checklist §15: items nuevos ===" && sed -n '/Lleva el bloque 🏷️ del tag/,/ninguno se reasignó/p' prompts/guia-de-estilo-y-convenciones.md
echo "=== diff resumido ===" && git diff --stat .

# --- 2026-09-09T13:26:38 · Extract common errors from course 01 phases 0-5
cd 01-vue2-legacy && for f in 00-setup-hola-mundo.md 01-estructura-base-legacy.md 02-autenticacion-minima.md 03-mock-api-minima.md 04-dashboard-tickets.md 05-crud-tickets.md; do echo "########## $f"; awk '/^## ⚠️/{p=1} p&&/^## /&&!/^## ⚠️/&&NR>1{if(seen){exit}} /^## ⚠️/{seen=1} p{print}' "$f" | head -70; done

# --- 2026-09-09T13:26:52 · Extract common errors from course 01 phases 6-11
for f in 06-wizard-minimo.md 07-metricas-minimas.md 08-websockets-minimos.md 09-panel-soporte.md 10-vuex-a-fondo.md 11-testing-minimo.md; do echo "########## $f"; awk '/^## ⚠️/{p=1} p&&/^## /&&!/^## ⚠️/&&NR>1{if(seen){exit}} /^## ⚠️/{seen=1} p{print}' "$f" | head -60; done

# --- 2026-09-09T13:27:01 · Extract route Q common errors
for f in q0-red-de-seguridad.md q1-leer-quasar.md q2-migrar-crud-qform.md q3-migrar-dashboard-qtable.md q4-timeline-actividad.md; do echo "##### $f"; awk '/^## ⚠️/{p=1} p&&/^## /&&!/^## ⚠️/{if(seen){exit}} /^## ⚠️/{seen=1} p{print}' "$f" | head -32; done

# --- 2026-09-09T13:27:03 · Extract routes VU and NX common errors
for f in vu0-red-de-seguridad.md vu1-leer-vuetify.md vu2-migrar-crud-vuetify.md vu3-migrar-dashboard-vdatatable.md vu4-timeline-vuetify.md nx0-red-de-seguridad.md nx1-leer-nuxt.md nx2-hidratacion-window-not-defined.md nx3-asyncdata-vs-vuex.md nx4-pagina-ssr-nueva.md; do echo "##### $f"; awk '/^## ⚠️/{p=1} p&&/^## /&&!/^## ⚠️/{if(seen){exit}} /^## ⚠️/{seen=1} p{print}' "$f" | head -26; done

# --- 2026-09-09T13:27:13 · Check q3 errors section
grep -n '^## ' q3-migrar-dashboard-qtable.md | head -20; echo "---"; awk '/^## ⚠️ 6/{p=1} p&&/^## /&&!/^## ⚠️ 6/{if(seen)exit} /^## ⚠️ 6/{seen=1} p{print}' q3-migrar-dashboard-qtable.md | head -30

# --- 2026-09-09T13:27:21 · Read q3 classic errors
sed -n '1422,1445p' q3-migrar-dashboard-qtable.md

# --- 2026-09-09T13:28:52 · Create course 01 forensic master
cat > forense-master.md <<'DOCEOF'
# 🕵️ Track forense — índice y método
## Curso 01 · Vue 2 Legacy — Mini Jira

> Puerta de entrada del track. Cubre las doce piezas de tronco,
> `forense-fase-00.md` … `forense-fase-11.md`, y las tres de ruta.

Ésta es la puerta. Nadie llega a una investigación sabiendo de qué fase es su problema:
llega con un síntoma, y casi siempre con uno mal descrito. Por eso el índice que de verdad
importa acá no es el de fases (§2), sino el de **síntomas** (§3).

El track no es material adicional: es el desarrollo de la sección 6 que cada fase ya trae.
La fase te dice **qué** se rompe; la pieza te enseña **en qué orden mirar**.

---

## 1. El método: cuatro preguntas, siempre en este orden

El orden no es una preferencia. Es que cada pregunta cuesta un orden de magnitud más que
la anterior, y contestar la barata primero descarta la mitad de las caras.

**Pregunta 1 — ¿se reproduce, y con qué?** Antes de mirar una línea de código: ¿esto se
reproduce **con un flag** del inyector de caos del mock, **con un dato** distinto en
`db.json`, o hace falta **otro código**? Las tres respuestas llevan a investigaciones
distintas, y averiguar cuál es te ahorra la mitad del camino. Es la misma pregunta que
ordena la preparación de los incidentes del cuaderno.

**Pregunta 2 — ¿qué dice la evidencia observable, antes que el código?** La URL de una
petición, el cuerpo crudo de la respuesta, el `state` de un módulo en Vue DevTools, el
frame que pasó por el socket. Casi todas las rutas de este track se resuelven acá, y
ninguna requiere abrir un archivo. **El código es el paso 4, no el paso 1.**

**Pregunta 3 — ¿en qué capa está?** Componente, store, servicio HTTP o mock. Son cuatro, y
casi todo el curso consiste en aprender a distinguirlas rápido. Localizar la capa es el
entregable de una investigación; el fix suele ser de tres líneas y viene después.

**Pregunta 4 — ¿de qué lado de la frontera está?** La frontera es lo que el mock promete y
lo que tu código asume. Un ticket que llega sin un campo, un `id` que es número donde
esperabas string, un evento de socket que emitió otro navegador: el síntoma es tuyo, la
causa está en el contrato. Contestar esto antes de escribir evita el fix que tapa el
problema en la capa equivocada.

> 🔑 **La frase para memorizar:** *"funciona en mi máquina", "a veces pasa" y "desde ayer"
> no son descripciones de un bug: son descripciones de una diferencia.* El trabajo es
> encontrar cuál.

---

## 2. 📇 Índice de las piezas

**Tronco — doce piezas, una por fase.**

| Fase | El síntoma que cubre | Archivo |
|---|---|---|
| 0 | "Instalé todo y no arranca", con errores que no hablan de lo que pasa | `forense-fase-00.md` |
| 1 | "La ruta cambia, la URL cambia, y la pantalla no" | `forense-fase-01.md` |
| 2 | "Me saca al login sin decir nada" | `forense-fase-02.md` |
| 3 | "A veces carga y a veces se queda pensando" | `forense-fase-03.md` |
| 4 | "Cambié el filtro y la tabla se quedó igual" ⭐ | `forense-fase-04.md` |
| 5 | "Le di a guardar y no pasó nada" | `forense-fase-05.md` |
| 6 | "Volví atrás en el wizard y perdí lo que había escrito" | `forense-fase-06.md` |
| 7 | "La pestaña se va poniendo lenta y el ventilador se dispara" | `forense-fase-07.md` |
| 8 | "Tomé el ticket y a mi compañero le sigue apareciendo libre" ⭐ | `forense-fase-08.md` |
| 9 | "Cambié el estado y el detalle no se enteró" | `forense-fase-09.md` |
| 10 | "El estado cambió y nadie sabe quién lo cambió" ⭐ | `forense-fase-10.md` |
| 11 | "El test pasa solo cuando lo corro aislado" | `forense-fase-11.md` |

**Rutas — tres piezas, una por ruta.** Son **opcionales y excluyentes**: cada una cubre
las cinco fases de su ruta y se lee sola. Si elegiste Quasar, las otras dos no te
incumben.

| Ruta | Lo que investiga | Archivo |
|---|---|---|
| 🅠 Quasar 1 | El componente que no renderiza y no avisa · la tabla que pagina dos veces | `forense-ruta-q.md` |
| 🅥 Vuetify 2 | El `v-app` ausente que rompe en silencio · el hex que mata el tema | `forense-ruta-vu.md` |
| 🅝 Nuxt 2 | `window is not defined` · la hidratación que no cuadra | `forense-ruta-nx.md` |

---

## 3. 🩺 Índice de síntomas transversal

La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la
derecha, dónde empezar. Todo lo que está acá sale de las secciones «⚠️ Errores comunes» de
las fases: no hay ningún síntoma inventado.

| Lo que ves o te cuentan | Empieza en |
|---|---|
| `Vue packages version mismatch` al compilar | Fase 0 — `vue` y `vue-template-compiler` desalineados |
| `EADDRINUSE` al levantar algo | Fase 0 — un proceso zombi de otra terminal |
| El editor "baila" al guardar, o el `.vue` no tiene resaltado | Fase 0 — dos formateadores compitiendo, o Volar (que es de Vue **3**) junto a Vetur |
| "Le di a guardar y no pasó nada", consola limpia | Fase 5 — el formulario contesta antes que el código: `$error` frente a `$invalid`, y el `$touch()` que falta |
| Se crearon dos tickets iguales de un solo clic | Fase 5 — botón sin `disabled` durante el request |
| El formulario sale en rojo antes de escribir una letra | Fase 5 — `$invalid` en vez de `$error` |
| "Perdí 20 minutos depurando y el mock estaba apagado" | Fase 3 — por eso el mensaje de error pregunta por la Mock API 😉 |
| El error de una petición no aparece por ningún lado | Fase 3 — la action no devuelve la Promise, o hay un `try/catch` síncrono sobre código asíncrono |
| Editaste `db.json` a mano y tus cambios desaparecieron | Fase 3 — json-server con `--watch` pisándote |
| "Cambié el filtro y la tabla se quedó igual" | Fase 4 — estado duplicado: `filteredTickets` en `data` sincronizado con watchers |
| Cambiaste un campo del ticket y la tabla no se enteró, pero con F5 sí aparece | Fase 4 → Fase 9 — reactividad de Vue 2: la propiedad no existía cuando el objeto entró |
| Las filas se mezclan o conservan estado al reordenar | Fase 4 — falta `:key` en el `v-for`, o es el índice |
| Una tabla vacía sin mensaje, que parece rota y no lo está | Fase 4 — falta el estado vacío; **no es un bug**, y hay que demostrarlo |
| Vue grita en consola que estás mutando una prop | Fase 4 → Fase 9 — el hijo muta lo que debería emitir |
| "Volví atrás y el paso salió vacío" | Fase 6 — falta `keep-alive` en el wizard |
| "Me dejó avanzar con el paso 2 sin llenar" | Fase 6 — se validó todo al final en vez de por paso |
| La pestaña se arrastra y el ventilador se dispara | Fase 7 — la instancia del chart guardada en `data`: reactividad recursiva sobre un objeto gigante |
| `Canvas is already in use` al volver a una vista | Fase 7 — falta `chart.destroy()` en `beforeDestroy` |
| El gráfico no se ve, o mide treinta mil píxeles de alto | Fase 7 — canvas dentro de un contenedor sin dimensiones, con `responsive: true` |
| `this.$refs.canvas` es `undefined` | Fase 7 — lo pediste en `created`, y ahí todavía no hay DOM |
| Al navegar y volver, el evento del socket se aplica dos, tres veces | Fase 8 — listeners sin `off`, o `.bind(this)` distinto en el alta y en la baja |
| "Tomé el ticket y a mi compañero le sigue apareciendo libre" | Fase 8 ⭐ — quién emite el evento, y si el otro cliente lo recibió o no lo aplicó |
| El socket conecta y nada llega, con errores que no mencionan versiones | Fase 8 — cliente y servidor de socket.io desparejados |
| "Cambié el estado del ticket y el detalle siguió mostrando lo de antes" | Fase 9 — se guardó el **objeto** seleccionado en `data` en vez del `id` |
| Ves medio segundo los comentarios del ticket anterior, o texto ajeno en el textarea | Fase 9 — falta `:key`: instancia reutilizada sin reset |
| Asignaste `tickets[i] = updated` y no pasó nada | Fase 9 — asignación por índice en un array: Vue 2 no la ve |
| "El estado cambió y no sé quién lo cambió" | Fase 10 ⭐ — mutación fuera de una mutation; `strict` existe para cazarla |
| Un getter o una action responde a otro módulo, o a ninguno | Fase 10 — falta `namespaced: true` y los nombres colisionan en silencio |
| La vista no puede encadenar nada después de despachar | Fase 10 → Fase 3 — la action no devuelve la Promise. Es la misma trampa, por tercera vez |
| El test pasa solo, falla en conjunto | Fase 11 — mocks sin `clearAllMocks`: llamadas fantasma del test anterior |
| Un test que nunca falla, aunque rompas lo que prueba | Fase 11 — verde falso: `async` sin `return` de la Promise |
| Un cambio de maquetación tumbó media suite | Fase 11 — selectores acoplados al DOM en vez de `data-testid` |
| En el build de producción se comporta distinto que en `npm run serve` | Fase 10 → ruta Q — `strict` está apagado en producción: Vuex muta en silencio |
| 🅠 Copiaste un template y no se ve nada, sin error en consola | `forense-ruta-q.md` — el componente no está en `framework.components` |
| 🅥 Los colores del tema no aplican y los diálogos no abren, consola limpia | `forense-ruta-vu.md` — falta `<v-app>` en la raíz |
| 🅝 `window is not defined` al recargar una página que en navegación funciona | `forense-ruta-nx.md` — `created()` corre en el servidor |
| 🅝 El HTML del servidor y el del cliente no coinciden | `forense-ruta-nx.md` — `Date.now()`, `Math.random()` o `new Date()` en el render |
| El header `X-Total-Count` llega `undefined` y en Network se ve | rutas Q y VU — axios normaliza los headers a minúsculas; y si en minúsculas tampoco, es CORS |

---

## 4. 🧰 Las herramientas, y en qué miente cada una

Ninguna miente por malicia: cada una contesta una pregunta muy concreta, y el error es
preguntarle otra.

**Vue DevTools** miente por *timeline*. La pestaña de componentes te muestra el estado
**después** de la mutation, no quién la lanzó ni con qué payload; para eso está el registro
de mutations, que es otra vista. Cuando el dato en el store es correcto y la pantalla no,
DevTools te va a dar la razón y no la respuesta.

**La consola** miente de dos formas. Por **omisión**, cuando un `catch` vacío se traga el
fallo entero y te deja la pantalla congelada con la consola limpia. Y por **build**: los
warns de reactividad de Vue 2 solo salen en desarrollo, así que un bug que en
`npm run serve` grita, en el build de producción es mudo — y el bug sigue ahí.

**La pestaña Network** miente por status. Un `201` significa que el mock contestó, no que
hizo lo que crees. Y para los sockets hay que acordarse de que los frames están en su
propia pestaña, **WS**, no entre las peticiones.

**El `db.json`** miente por escritura. json-server guarda de verdad, así que después de
media hora de ejercicios el "caso limpio del enunciado" ya no existe. Antes de dar por
bueno un síntoma raro, mira si el dato es el que crees
([convención de git §🧹](../prompts/convencion-de-git-y-tags.md)).

**Y `git log -S`**, que no es una herramienta de depuración hasta que lo es:
`git log --oneline -S "socket.emit"` encuentra el commit donde una línea apareció o
desapareció, y contesta el *"esto antes funcionaba"* sin discutirlo.

---

## 5. Cómo se cierra el track

Este archivo te dice **dónde empezar**. Las piezas te dicen **cómo recorrer** cada camino.
Y lo que te llevas al trabajo real no está en ninguno de los dos: está en el hábito de
contestar las cuatro preguntas de §1 en orden, sobre un sistema que no es Mini Jira.

Las piezas que más rinden son las de las fases 4, 8 y 10 ⭐, por el mismo motivo: las tres
terminan en algo que no se ve en la pantalla —una propiedad que no es reactiva, un evento
que emitió el cliente equivocado, una mutación que nadie registró— y las tres se
diagnostican mirando, no leyendo código.

> 🧭 **El criterio para saber si el track hizo su trabajo:** que ante un ticket vago, tu
> primer movimiento ya no sea abrir el editor.
DOCEOF
wc -l forense-master.md && grep -c '^|' forense-master.md

# --- 2026-09-09T13:29:01 · Extract course 02 errors phases 0-7
cd ../02-complement-mongodb-backend && for f in 00-preliminares.md 01-mongo-en-30-min.md 02-consultar-tu-sql-traducido.md 03-embeber-vs-referenciar.md 04-el-esquema-que-no-esta-en-la-base.md 05-lookup-y-por-que-es-una-alarma.md 06-atomicidad-transacciones-consistencia.md 07-indices.md; do echo "##### $f"; awk '/^## ⚠️/{p=1} p&&/^## /&&!/^## ⚠️/{if(seen)exit} /^## ⚠️/{seen=1} p{print}' "$f" | head -34; done

# --- 2026-09-09T13:29:07 · Extract course 02 errors phases 8-15
for f in 08-la-autopsia.md 09-aggregation.md 10-express-el-vehiculo.md 11-auth-real-y-pago-de-deudas.md 12-el-backend-habla.md 13-testing-de-api.md 14-operacion.md 15-el-veredicto-honesto.md; do echo "##### $f"; awk '/^## ⚠️/{p=1} p&&/^## /&&!/^## ⚠️/{if(seen)exit} /^## ⚠️/{seen=1} p{print}' "$f" | head -34; done

# --- 2026-09-09T13:30:44 · Create course 02 forensic master
cat > forense-master.md <<'DOCEOF'
# 🕵️ Track forense — índice y método
## Curso 02 · MongoDB para cerebros SQL — el backend de Mini Jira

> Puerta de entrada del track. Cubre las doce piezas escritas,
> más las candidatas que §2 nombra.

Ésta es la puerta. Nadie llega a una investigación sabiendo de qué fase es su problema:
llega con un síntoma, y en este curso además llega con un instinto —el relacional— que a
veces acierta y a veces lo manda al sitio equivocado. Por eso el índice que de verdad
importa acá no es el de fases (§2), sino el de **síntomas** (§3).

El track no es material adicional: es el desarrollo de la sección 6 que cada fase ya trae.
La fase te dice **qué** se rompe; la pieza te enseña **en qué orden mirar**.

---

## 1. El método: cuatro preguntas, siempre en este orden

El orden no es una preferencia. Es que cada pregunta cuesta un orden de magnitud más que
la anterior, y contestar la barata primero descarta la mitad de las caras.

**Pregunta 1 — ¿se reproduce, y con qué?** ¿Con **otro dato** —un seed alterno, un
documento sin el campo—, con **más volumen** —porque a 50 documentos todo es rápido—, o
hace falta **otro código**? En este curso la variante de volumen es propia y decisiva: la
mitad de los bugs del modelado no existen hasta que hay datos de verdad.

**Pregunta 2 — ¿qué dice la evidencia observable, antes que el código?** El documento
crudo en mongosh, el `explain()` con su `totalDocsExamined`, la línea de morgan que no
apareció, el `matchedCount` de un update. Casi todas las rutas se resuelven acá, y ninguna
requiere abrir un archivo del proyecto. **El código es el paso 4, no el paso 1.**

**Pregunta 3 — ¿en qué capa está?** Ruta, controller, service o el propio Mongo. Y una
distinción que este curso agrega y que no existe en un backend relacional: ¿el problema
está en la **consulta** o en el **modelo**? Afinar índices sobre un modelo mal diseñado es
la forma más cara de no arreglar nada, y la Fase 7 lo dice con todas las letras.

**Pregunta 4 — ¿de qué lado de la frontera está?** La frontera es
[`00-audit-contrato.md`](00-audit-contrato.md). El `_id` que la base guarda como `ObjectId`
y la API sirve como `id` string, la fecha que es `Date` adentro e ISO afuera, el evento de
socket que tiene que llevar la misma forma que la respuesta HTTP. Un síntoma que aparece
solo cuando mira el frontend casi siempre vive en esa costura, no en Mongo.

> 🔑 **La frase para memorizar:** *"en SQL esto funcionaba"* no es un diagnóstico: es el
> punto de partida de uno. La pregunta que sigue es **qué** funcionaba — el motor, el
> modelo, o la costumbre.

---

## 2. 📇 Índice de las piezas

| Fase | El síntoma que cubre | Archivo |
|---|---|---|
| 0 | "Levanté todo y no conecta", con errores que no hablan de lo que pasa | `forense-fase-00.md` |
| 1 | "El dato está en la base y la consulta no lo encuentra" | `forense-fase-01.md` |
| 2 | "Traduje mi WHERE y devuelve de más" ⭐ | `forense-fase-02.md` |
| 4 | "El validator rechaza un documento que a mí me parece correcto" | `forense-fase-04.md` |
| 5 | "Esta pantalla hace seis viajes a la base" ⭐ | `forense-fase-05.md` |
| 6 | "Dos agentes tomaron el mismo ticket" ⭐ | `forense-fase-06.md` |
| 7 | "El índice está creado y `explain()` sigue diciendo COLLSCAN" | `forense-fase-07.md` |
| 8 | "La migración pasó el conteo y los datos son basura" | `forense-fase-08.md` |
| 9 | "Mi GROUP BY devuelve UNA fila" | `forense-fase-09.md` |
| 10 | "El request se queda girando para siempre" ⭐ | `forense-fase-10.md` |
| 12 | "Por socket llega distinto que por HTTP" | `forense-fase-12.md` |
| 13 | "Verde en mi máquina, rojo en CI" | `forense-fase-13.md` |

**Las cuatro fases sin pieza, y por qué.** La 3 (embeber vs. referenciar) y la 15 (el
veredicto) son de **decisión**, no de depuración: su material es un árbol de criterios, y
forzarles un recorrido las convertiría en un resumen de sí mismas. La 11 (auth) y la 14
(operación) sí tienen recorrido propio —el orden de los middlewares que deja `req.user`
sin poblar, la guardia con `currentOp` y `killOp`— y son las **candidatas naturales a las
piezas 13 y 14** del track: se escriben el día que se sostengan solas, no por simetría.

---

## 3. 🩺 Índice de síntomas transversal

La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la
derecha, dónde empezar. Todo lo que está acá sale de las secciones «⚠️ Errores comunes» de
las fases: no hay ningún síntoma inventado.

| Lo que ves o te cuentan | Empieza en |
|---|---|
| El contenedor levanta y nadie conecta al 27017 | Fase 0 — hay dos `mongod` peleando; el log del arranque lo dice |
| Cambiaste la ruta de datos y "se perdió todo" | Fase 0 — los datos viejos siguen en la ruta vieja: `down` → cambiar → `up` |
| `mongoexport` no existe | Fase 0 — desde 4.4 las Database Tools se instalan aparte |
| `find({ _id: "5f8a…" })` no encuentra nada y el documento está ahí | Fase 1 → Fase 2 — un `_id` es `ObjectId`, no string. Es la traducción de la que vive la capa API |
| "Se borraron los datos" y la colección está intacta | Fase 1 — el typo-colección: no hay error de "tabla no existe", hay colecciones fantasma |
| Un rango de fechas devuelve cualquier cosa | Fase 1 → Fase 2 — fechas guardadas como string; a veces "funciona" por el orden lexicográfico del ISO, hasta que no |
| Un filtro `$ne` trae documentos que no esperabas | Fase 2 — `$ne` incluye a los **ausentes**; no significa "tiene otro valor" |
| La proyección devuelve campos que no pediste, o falla | Fase 2 — se mezclaron `1` y `0`; solo `_id` va a contracorriente |
| Paginar la página 400 tarda un mundo | Fase 2 — `skip` gigante: el mismo pecado que `OFFSET`, la misma penitencia |
| El seed de la Fase 1 dejó de entrar | Fase 4 — el validator también aplica a tus scripts; si no pasa, acaba de encontrarle un bug al seed |
| El validator rechaza un número que es obviamente entero | Fase 4 — el driver manda `double`; `bsonType: "int"` exige `NumberInt()`. Hora y media perdida, clásica |
| Otro servicio escribió un documento inválido y el validator no dijo nada | Fase 4 — el schema de Mongoose valida en tu proceso Node; el del motor aplica a todos |
| Una pantalla hace seis viajes a la base | Fase 5 ⭐ — el N+1 de siempre, con otro collar |
| El `$lookup` devuelve arrays donde esperabas filas planas | Fase 5 — agrupa; y `$unwind` sin `preserveNullAndEmptyArrays` convirtió tu LEFT en INNER sin avisar |
| Los tickets sin comentarios desaparecieron del listado | Fase 5 — exactamente ese `$unwind` |
| Un `$lookup` que iba rápido se volvió lentísimo al crecer | Fase 5 — falta el `$match` previo, o el pipeline interno con `let` corre por cada documento izquierdo |
| Dos agentes tomaron el mismo ticket | Fase 6 ⭐ — `findOne` + `updateOne` son dos operaciones; la precondición va **en el filtro** |
| Un contador quedó corto tras un pico de tráfico | Fase 6 — `doc.n++; save()` es una carrera con disfraz |
| La transacción "funcionó" y una de las escrituras quedó fuera | Fase 6 — falta `{ session }` en una operación: corre fuera, sin error. El más traicionero del curso |
| Un update devuelve `matchedCount: 0` y el documento existe | Fase 6 — tu filtro llevaba precondición: existe y no la cumple. Son 404 y 409, no lo mismo |
| Creaste el índice y `explain()` sigue en COLLSCAN | Fase 7 — regex flotante, tipos que no coinciden, o el índice no cubre esa consulta |
| `explain()` dice IXSCAN y sigue lento | Fase 7 — mira `totalDocsExamined`: examinar 90.000 para devolver 20 es un COLLSCAN con corbata |
| El índice se usa pero aparece una etapa SORT | Fase 7 — el compuesto está al revés: prefijo izquierdo desperdiciado |
| El TTL no borra nada y no avisa | Fase 7 — está sobre fechas guardadas como string |
| Los inserts se volvieron lentos y nadie tocó el código | Fase 7 — índices nuevos en una colección de escritura intensa |
| La migración pasó el conteo y los datos están corridos | Fase 8 — verificar solo conteos; el muestreo campo a campo existe por esto |
| El proceso de migración se queda sin memoria | Fase 8 — se cargó todo en memoria en vez de usar cursor y lotes |
| Dos mediciones del mismo caso dan números distintos | Fase 8 — una con caché caliente y otra fría; mismas condiciones o los números mienten |
| Un `GROUP BY` colapsa a una sola fila | Fase 9 — el dólar ausente: `_id: "status"` agrupa por el literal |
| El pipeline muere con un error de 100 MB | Fase 9 — `$sort` gigante sin `allowDiskUse`… y si lo pones en un endpoint caliente, acabas de confesar que eso era un batch |
| El request se queda en `pending` para siempre, sin 404 ni 500 | Fase 10 ⭐ — async sin `next(err)`: el handler entró y no salió. Morgan no imprime la línea |
| El frontend no muestra nada y `curl` sí devuelve los tickets | Fase 10 → contrato — el envelope reflejo, o el `_id` sin serializar a `id` |
| Se agotan las conexiones a los pocos minutos | Fase 10 — un `MongoClient.connect` por request |
| El `?q=` revienta con ciertos textos | Fase 10 — regex sin escapar; funciona hasta el primer `(` |
| Por socket llega `_id` y por HTTP llega `id` | Fase 12 — falta el serializer en el emit: bugs fantasma que solo pasan "cuando llega en vivo" |
| El socket conecta y no llega nada, sin errores claros | Fase 12 — servidor 3.x/4.x contra el cliente 2.4 |
| El mismo evento llega dos veces | Fase 12 — el relé tonto del Curso 01 sigue encendido junto al emisor nuevo |
| La suite pasa en local y falla intermitente en CI | Fase 13 — la versión del binario no está fijada: Mongo 7 en CI, 4.4 en tu equipo |
| Un test falla solo cuando corre con los demás | Fase 13 — base compartida y `deleteMany` en `afterEach`: depende del orden |
| Un test de concurrencia pasa y el bug sigue ahí | Fase 13 — una sola ronda: la carrera es probabilística, y el verde fue suerte |

---

## 4. 🧰 Las herramientas, y en qué miente cada una

Ninguna miente por malicia: cada una contesta una pregunta muy concreta, y el error es
preguntarle otra.

**`explain()`** miente por **plan cacheado**. El plan que te enseña puede ser el que el
planificador eligió en otra corrida, con otros datos; y miente por **verbosidad**, porque
el `queryPlanner` por defecto no trae los números que importan. Pídele
`executionStats` y mira `totalDocsExamined` frente a `nReturned`: esa razón es el
diagnóstico, no la etapa que aparece arriba.

**Compass** miente por **muestreo**. Lo que llama "el esquema" de una colección es una
inferencia sobre una muestra, no un contrato: un campo que aparece en el 99 % de los
documentos se ve idéntico a uno que aparece en el 100 %, y esa diferencia es justo la que
te rompe la aplicación. Para saber la verdad, cuenta.

**Los logs de Express** mienten por **momento**. La línea de `morgan("dev")` se imprime
cuando la respuesta se **cierra**, así que su ausencia no significa que el request no llegó:
significa que nunca se contestó. Es la primera pista del request colgado de la Fase 10, y
se lee al revés de como el instinto sugiere.

**El profiler** no miente, pero **cuesta**. Nivel 2 encendido en un sistema con tráfico es
un problema nuevo, no una herramienta. Para "algo está lento ahora mismo",
`db.currentOp()` contesta en un segundo lo que el profiler te dirá en diez minutos.

**Y el `mongosh` crudo**, que es la herramienta más honesta del curso: el documento tal
como está, sin el ODM traduciendo, sin el serializer maquillando. Cuando la API dice una
cosa y la pantalla otra, el desempate se hace acá.

---

## 5. Cómo se cierra el track

Este archivo te dice **dónde empezar**. Las piezas te dicen **cómo recorrer** cada camino.
Y lo que te llevas al trabajo real es la tabla de olores de la Fase 15: cinco minutos con
Compass delante de una base ajena y un veredicto con evidencia. Todo lo anterior es el
entrenamiento para poder emitirlo.

Las piezas que más rinden son las de las fases 2, 5, 6 y 10 ⭐, y no por casualidad: las
cuatro son sitios donde **el instinto SQL contesta rápido y contesta mal**. La 2 porque la
traducción literal casi funciona; la 5 porque el `$lookup` se parece demasiado a un JOIN;
la 6 porque en tu motor de siempre la transacción era gratis; y la 10 porque en Express 4
una promesa rechazada no es un 500, es un silencio.

> 🧭 **El criterio para saber si el track hizo su trabajo:** que ante *"Mongo va lento"*, tu
> primer movimiento sea pedir la consulta y el `explain()`, y no proponer un índice.
DOCEOF
wc -l forense-master.md && grep -c '^| ' forense-master.md && echo "=== voseo ===" && grep -nE '\b(tenés|querés|podés|hacés|sabés|mirá|fijate|poné|agregá|vos)\b' forense-master.md ../01-vue2-legacy/forense-master.md

# --- 2026-09-09T13:31:00 · Verify master links and status
echo "=== enlaces markdown en los dos masters ==="
grep -ohE '\]\([^)]+\)' forense-master.md ../01-vue2-legacy/forense-master.md | tr -d '])(' | sort -u | while read l; do
  d=$(dirname "$l"); b=$(basename "$l")
  if [ -f "$l" ] || [ -f "../01-vue2-legacy/$l" ]; then echo "OK   $l"; else echo "REVISAR $l"; fi
done
echo; echo "=== comprobación explícita ==="
ls ../prompts/convencion-de-git-y-tags.md 00-audit-contrato.md
echo; echo "=== git status paquete ==="; git status --short ..

