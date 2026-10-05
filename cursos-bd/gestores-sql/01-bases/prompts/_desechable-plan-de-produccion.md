# 🗓️ Plan de producción: tandas, estado y checklist

Este documento dice **en qué orden se prepara y se escribe el curso, cuándo una tanda está terminada y
dónde va la producción**. Hay dos fases: la **preparación** (tandas `P1`–`P10`), que solo toca
`prompts/` y el laboratorio de verificación y no escribe ni una fase, y la **escritura** (tandas
`T0`–`T17`), que arranca cuando está cerrada la parte de la preparación que cada tanda necesita
(regla 7). Es operativo: se actualiza al cerrar cada sesión, y cualquier sesión que retome
`gestores-sql/01-bases/` empieza leyendo §3 (estado), §7 (bitácora) y §8 (checklist).

- La forma la manda [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md).
- El qué lo manda [`alcance-del-proyecto.md`](alcance-del-proyecto.md).
- Horas, ejercicios y fichas: [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) y
  [`propuesta-apendices-y-alcance.md`](propuesta-apendices-y-alcance.md).
- La entrada de cada tanda es su prompt: [`prompts-de-fase.md`](prompts-de-fase.md),
  [`prompts-ac-fase.md`](prompts-ac-fase.md) y [`prompts-de-apendice.md`](prompts-de-apendice.md).
- **El orden lo manda este documento.**

> **Caducidad:** es un documento de producción. Al cerrar T17, con permiso de Oskar, se borra junto
> con `_desechable-propuesta-temas.md` y `_desechable-modelos-legacy.md`, y se limpian sus menciones.
> **No se cita desde ninguna fase, apéndice, solucionario ni README.**
>
> **Vigencia:** 2026-10-03.

**Salto rápido:** [1](#1--las-reglas-de-orden) · [2](#2--qué-es-una-tanda) · [3](#3--estado) ·
[4](#4--las-verificaciones) · [5](#5--las-tandas-una-por-una) · [6](#6--deuda-de-enlaces-abierta) ·
[7](#7--bitácora) · [8](#8--checklist-final)

---

## 1. 🧭 Las reglas de orden

Son treinta y ocho fases del camino base, diez del bloque A.C., cuarenta y ocho solucionarios, once
apéndices y tres documentos vivos. Escritos en orden de carpeta, F15 usaría verificadores que
todavía no existen, el bloque A.C. no tendría el contador de bloques del mini motor de F26, y `a07`
iría siempre atrasado. Las tandas van por **dependencia**, y cada una deja el curso coherente y
publicable hasta donde llega. Diez reglas:

1. **Ninguna tanda se cierra con un documento vivo atrasado.** Los símbolos y términos nuevos entran
   en `a07-notacion-y-glosario.md`, los recursos verificados en `a08-mapa-de-bibliografia.md` y los
   🪞 en `INSTINTOS.md`, en la misma tanda.
2. **Ninguna fase se cierra sin su solucionario.** Fase y `soluciones/NN-slug.md` son una sola
   entrega, y cada solución está contrastada con el verificador, la herramienta o una segunda
   resolución independiente.
3. **Ningún enlace interno apunta a un documento que no existe.** La referencia va en prosa y se
   anota en la deuda de enlaces (§6); la tanda que escribe el destino la convierte en enlace.
4. **Los README y `0-ESTRUCTURA-CURSO.md` se escriben en una tanda final y aparte (T16), y ninguna
   otra tanda los toca.** Ni el `README.md` del curso, ni los de `src/`, ni la sección `01-bases` del
   `README.md` de `gestores-sql/`. Lo que una tanda querría decir en uno de ellos se anota en §6 como
   deuda de T16. **Mientras tanto, el mapa son los desechables**: §3 de este plan para el estado y la
   propuesta de fases §13 para el temario.
5. **Nada se nombra sin comprobarlo en la misma sesión**: versión de una herramienta, función de
   SQLite o de `radb`, libro con edición y capítulo, URL por código de estado, y en el bloque A.C. el
   motor que usa hoy cada producto real.
6. **Una fase no se cierra sin haberse ejecutado entera**: cada salida de `radb`, `sqlite3`, un
   verificador, el mini motor o un laboratorio, corrida en la sesión y copiada literal, con fecha.
7. **Ninguna tanda de escritura empieza con su preparación abierta.** Cada una exige lo suyo:
   - **T0** exige P7: las decisiones cerradas. ✅ desde el 2026-10-02.
   - **T1** exige además **P8** (laboratorio de producción y verificación de herramientas) y **P10**
     (lo verificado, trasladado): sin versiones fijadas ni el comportamiento de `radb` con `STRICT`
     no hay `a01`–`a04`. ✅ desde el 2026-10-03.
   - **T2** exige además **P9**: F00 cita los libros base y `a08` los inventaría. ✅ desde el
     2026-10-03.
   - **T14 y T15** exigen la parte de P8 y P9 del bloque A.C. (§5, P8 y P9). ✅ desde el
     2026-10-03.
8. **El bloque A.C. no bloquea al camino base, y el camino base no espera por él.** T14 y T15 se
   pueden correr en cualquier momento después de T10, porque reutilizan el mini motor de F26.
9. **Toda prueba se ejecuta dentro de un contenedor**, nunca en la máquina de Oskar: cualquier motor,
   comando, script, verificador, compilación o laboratorio. Los contenedores **no usan los puertos por
   defecto de ningún producto** (Oskar tiene otros contenedores corriendo), llevan la etiqueta
   `curso=01-bases`, se registran en §2.4 y **se detienen todos al final de la producción (T17)**.
   Las reglas completas están en §2.4.
10. **Sin commits**: git lo hace Oskar. Se borra con `rm`, nunca con `git rm`. Las sesiones no crean
    ni mueven tags.

**Prioridad si el tiempo aprieta:** T1 → T2 → T3 → **T4 a T8** (los bloques II y III, el énfasis del
curso: con ellos ya es un curso utilizable por sí solo), después T9 → T10 (F26 cierra el hilo de π y
− y deja el mini motor). Lo que falte de las tandas saltadas va en prosa y a la deuda de enlaces.

---

## 2. 📦 Qué es una tanda

### 2.0 Una tanda de preparación

Un documento de `prompts/`, o un paso que lo deja coherente con los demás: una decisión, una
verificación, un traslado. **No crea nada fuera de `prompts/`**, salvo P8, que trabaja en
`prompts/verificacion-de-laboratorio/`. Terminada cuando sus enlaces pasan §4 y los documentos que la
citan están al día.

### 2.1 Una tanda de escritura

Un grupo de fases o apéndices que se enlazan entre sí, con su laboratorio corrido. La rutina, igual
en todas:

1. Pegar el prompt de cada documento y seguir su protocolo de tres pasos.
2. Tener delante el checklist de la guía §15, que se recorre **al cerrar cada archivo**.
3. Releer la ficha de la propuesta: el "Qué entra" es el piso; el 🪞 y el ⚖️ son candidatos.
4. Comprobar versiones, funciones de las herramientas, URLs y libros **antes** de escribirlos.
5. Levantar el laboratorio de producción (§2.4), ejecutar y anotar —el error antes de arreglarlo— y
   después escribir.
6. Escribir la fase **y su solucionario**, y contrastar cada solución.
7. Alimentar los documentos vivos y, si la tanda lo pide, `a05` (verificadores y mini motor).
8. Resolver la deuda de enlaces que la tanda cierra.
9. Correr las verificaciones de §4, incluida la de que ningún `README.md` cambió y
   `0-ESTRUCTURA-CURSO.md` no existe todavía.
10. Registrar en §2.4 cualquier contenedor nuevo, y actualizar §3, §6, §7 y §8 de este documento,
    que es el mapa hasta T16.

### 2.2 Peso de cada tanda

```text
ligera   T0 · T3 · T13 · T16 · T17
normal   T2 · T6 · T8 · T9 · T11 · T12 · T14
densa    T1 · T4 · T5 · T7 · T10 · T15
```

Las **densas** introducen infraestructura (los cuatro apéndices de T1, los verificadores de T7, el
mini motor de T10, los laboratorios y el código en C de T15) o las fases más largas del curso (F07,
F10, F15), y llevan su verificación anotada con fecha antes de escribir una línea.

### 2.3 Qué se ejecuta y qué se publica

El lector del curso usa **SQLite nativo** (D12); la producción, en cambio, **verifica todo dentro de
contenedores** (regla 9). No es una contradicción: lo que se publica es la receta nativa, y lo que se
ejecuta para escribirla corre aislado. Las recetas de instalación nativa tienen tres casos:

- **Linux** (`apt`, `dnf`, `pacman`): se verifican en contenedores de Debian o Ubuntu, Fedora y Arch,
  porque ahí la receta es exactamente la misma.
- **macOS** (`brew`) y **Windows** (`winget`, Chocolatey, Scoop, PowerShell, Visual C++): **no se
  pueden contenerizar**. Las verifica Oskar en su máquina si quiere (con `! comando` en la sesión,
  para que la salida quede en el registro), o el apéndice las declara "no verificadas en esta
  plataforma", con esas palabras.
- **Podman** no está instalado en la máquina de producción (comprobado el 2026-10-02): los
  equivalentes Podman de `a09` y `aca-02` se escriben desde la documentación y se declaran no
  verificados.

### 2.4 El laboratorio de producción

**Dónde vive:** `prompts/verificacion-de-laboratorio/`, con su `Dockerfile`, su `compose.yaml` y su
`hallazgos.md`. Es herramienta de producción, no material del curso: el contenedor del lector es
`a09`, que puede reutilizar lo que aquí funcione.

**Las reglas:**

- **Todo dentro de un contenedor.** `sqlite3`, `radb`, Python y sus scripts, los verificadores, el
  mini motor, el `git` del caso AC06, LMDB, ZODB, YottaDB, PostgreSQL, GnuCOBOL, Harbour y la
  compilación con GCC de AC09. En la máquina de Oskar solo se editan archivos y se corre `docker`.
- **El curso se monta como volumen** en `/curso`, así los `.db`, los scripts y las salidas quedan en
  el repositorio y no dentro del contenedor.
- **Nombres y etiqueta.** Todo contenedor, imagen, red y volumen se llama `mdm-<algo>` (*motor de
  motores*) y lleva la etiqueta `curso=01-bases`. Lo que no tenga esa etiqueta no es de este curso y
  **no se toca**: ni se detiene, ni se reinicia, ni se inspecciona.
- **Puertos.** Por defecto **no se publica ningún puerto**: se trabaja con `docker exec` y
  `docker compose exec`. Si hace falta publicar uno (por ejemplo, el PostgreSQL de F34 para un cliente
  gráfico), va **en el rango `56000–56099`**, ligado a `127.0.0.1`, **nunca en el puerto por defecto
  del producto** (5432, 3306, 1433, 1521, 27017, 6379, 8080…), y antes se comprueba que está libre:

  ```bash
  lsof -nP -iTCP:56032 -sTCP:LISTEN; docker ps --format '{{.Names}} {{.Ports}}'
  ```

  Al 2026-10-02, en la máquina de producción hay contenedores ajenos publicando `127.0.0.1:8083` y
  `127.0.0.1:27029`.
- **Arquitectura.** La máquina de producción es macOS arm64 con Docker 29.8. Lo que solo existe para
  x86-64 —los wheels del paquete `yottadb`, por ejemplo— corre con `--platform linux/amd64` bajo
  emulación, y el hallazgo lo dice.
- **Registro.** Cada contenedor que se crea se anota en la tabla de abajo en la misma sesión. Un
  contenedor que no está en la tabla no debería existir.
- **Ciclo de vida.** Pueden quedar corriendo entre sesiones mientras dure la producción. **En T17 se
  detienen todos** los que llevan la etiqueta. Borrar contenedores, imágenes o volúmenes es aparte y
  **solo con permiso de Oskar**.

  ```bash
  docker ps -a --filter label=curso=01-bases                   # inventario
  docker stop $(docker ps -q --filter label=curso=01-bases)    # T17
  ```

**Inventario de contenedores de producción:**

| Contenedor | Imagen | Para qué | Puertos | Creado en | Estado |
|---|---|---|---|---|---|
| `mdm-lab` | `mdm-lab:p8` (de `python:3.14.8-slim-trixie`) | SQLite, Python, `radb`, Faker; verificadores y mini motor desde T7 | ninguno | P8, 2026-10-03 | corriendo, red `mdm-net` |
| `mdm-linux-debian-13`, `mdm-linux-ubuntu-24-04`, `mdm-linux-ubuntu-26-04`, `mdm-linux-fedora`, `mdm-linux-arch` | `debian:13`, `ubuntu:24.04`, `ubuntu:26.04`, `fedora:latest`, `archlinux:latest` (amd64) | recetas Linux de `a01` y `a02` | ninguno | P8, 2026-10-03 | efímeros (`--rm`), ya no existen |
| `mdm-faker-amd64`, `mdm-py310` | `python:3.14.8-slim-trixie` (amd64), `python:3.10-slim` | Faker en x86-64; Python mínimo | ninguno | P8, 2026-10-03 | efímeros, ya no existen |
| `mdm-ac-probe`, `mdm-yottadb-probe` | `debian:13`, `yottadb/yottadb:r2.06` | GnuCOBOL, Harbour, GCC; YottaDB y `yottadb` | ninguno | P8, 2026-10-03 | efímeros, ya no existen |

**Red:** `mdm-net`, con la etiqueta, creada por el `compose.yaml` de P8. **Imágenes de Docker Hub
descargadas en P8** (sin la etiqueta, porque no son nuestras): las nueve que lista el final de
`verificacion-de-laboratorio/hallazgos.md`; se borran en T17 solo con permiso de Oskar.

**Previstos:** `mdm-pg` (PostgreSQL para F34 y `a09`; T12); `mdm-ac` (GnuCOBOL, Harbour, GCC, LMDB y
ZODB; T14); y `mdm-yottadb` (AC08; T15). Las recetas de los dos últimos ya están probadas en los
contenedores efímeros de P8.

---

## 3. 📊 Estado

Leyenda: ⬜ pendiente · 🟡 en curso · ✅ terminada y verificada.

| Tanda | Entrega | Docs nuevos | Peso | Estado |
|---|---|---|---|---|
| **P1** | Guía de estilo y convenciones, derivada de las de la NoSQL Lite y la Ruta SQL | 1 | — | ✅ |
| **P2** | Alcance del proyecto | 1 | — | ✅ |
| **P3** | Propuestas de fases y de apéndices | 2 | — | ✅ |
| **P4** | Plantillas (fase, panorama, fase A.C., caso de estudio, solucionario, apéndice) | 1 | — | ✅ |
| **P5** | Prompts de fase, del bloque A.C. y de apéndice | 3 | — | ✅ |
| **P6** | Este plan | 1 | — | ✅ |
| **P7** | Decisiones D1–D18 y A–E cerradas por Oskar | — | — | ✅ |
| **P8** | Laboratorio de producción y verificación de herramientas, en contenedores | — | densa | ✅ |
| **P9** | Fuentes: los cinco textos y sus capítulos, cursos, videos, papers; productos del bloque A.C. | 1 | — | ✅ |
| **P10** | Traslado de lo verificado en P8 y P9 a `prompts/` | — | — | ✅ |
| **T0** | Arranque: `INSTINTOS.md`, carpetas `soluciones/` y `src/` | 1 | ligera | ⬜ |
| **T1** | Laboratorio: a01, a02, a03, a04 (+ `src/a04-…` y `src/requirements.txt`) | 4 | densa | ⬜ |
| **T2** | Esqueleto de a08 y Bloque 0: F00, F01 | 3 + 2 sol. | normal | ⬜ |
| **T3** | Bloque I: F02, F03 | 2 + 2 sol. | ligera | ⬜ |
| **T4** | a06, esqueleto de a07 y Bloque II (1): F04, F05, F06 | 5 + 3 sol. | densa | ⬜ |
| **T5** | Bloque II (2): F07, F08, F09 | 3 + 3 sol. | densa | ⬜ |
| **T6** | Bloque II (3): F10, F11, F12, F13 | 4 + 4 sol. | normal | ⬜ |
| **T7** | a05 (primeros verificadores) y Bloque III (1): F14, F15, F16 | 4 + 3 sol. | densa | ⬜ |
| **T8** | Bloque III (2): F17, F18, F19, F20 | 4 + 4 sol. | normal | ⬜ |
| **T9** | Bloque IV: F21–F25 (`bplus` y, si se aprueba, el verificador de hashing) | 5 + 5 sol. | normal | ⬜ |
| **T10** | Bloque V: F26 (mini motor), F27, F28 | 3 + 3 sol. | densa | ⬜ |
| **T11** | Bloque VI: F29–F32 (`conflict_serializable`) | 4 + 4 sol. | normal | ⬜ |
| **T12** | a09 (+ `mdm-pg`) y Bloque VII: F33–F36 | 5 + 4 sol. | normal | ⬜ |
| **T13** | Bloque VIII: F37, y cierre de a05, a07, a08 e `INSTINTOS.md` | 1 + 1 sol. | ligera | ⬜ |
| **T14** | aca-01 y bloque A.C. (1): AC00–AC05 (L1–L5, ZODB) | 7 + 6 sol. | normal | ⬜ |
| **T15** | aca-02 y bloque A.C. (2): AC06–AC09 (Git, LMDB, YottaDB, C) | 5 + 4 sol. | densa | ⬜ |
| **T16** | Los README y la estructura, aparte: README del curso, los de `src/`, `0-ESTRUCTURA-CURSO.md` y la sección `01-bases` del README de la familia | 2 | ligera | ⬜ |
| **T17** | Cierre: verificación global, contenedores detenidos, borrar desechables | — | ligera | ⬜ |

**Dónde estamos (2026-10-03) y cómo retomar.** **La preparación está cerrada: P1–P10 ✅.** Lo
verificado vive en `verificacion-de-laboratorio/hallazgos.md` (P8) e `inventario-de-fuentes.md` (P9),
y ya está trasladado a la guía, las propuestas y los prompts. `mdm-lab` queda corriendo. Las tandas de
escritura que siguen, en orden:

- **T0** — su prompt es la ficha de §5 (T0); no depende de nada.
- **T1** — desbloqueada. Entrada: los prompts de `a01`–`a04` en `prompts-de-apendice.md`. Antes de
  escribir `a01` y `a02` conviene que Oskar corra las comprobaciones de macOS y Windows que lista
  `hallazgos.md` (H11); si no, esas recetas salen "no verificadas en esta plataforma".
- **T2** — desbloqueada; abre `a08` desde `inventario-de-fuentes.md`.

Desde T1, la entrada de cada documento es su prompt en `prompts-de-apendice.md`, `prompts-de-fase.md`
o `prompts-ac-fase.md`.

**Total: 123 documentos** (38 fases, 10 fases del bloque A.C., 48 solucionarios, 11 apéndices,
`INSTINTOS.md`, los 2 que se escriben en T16 —`0-ESTRUCTURA-CURSO.md` y el README—, y los 13 de
`prompts/` que existen durante la producción, 3 de ellos desechables, contando
`inventario-de-fuentes.md` y `verificacion-de-laboratorio/hallazgos.md`), más el código de `src/` y los
README de `src/` que T16 decida.

**Por qué el bloque A.C. va después del Bloque VIII:** es opcional y compara contra los bloques II, IV
y V (reutiliza el contador del mini motor de F26). Se puede adelantar a después de T10 sin tocar
ninguna otra tanda.

**Por qué a08 abre en T2 y no en T1:** no bloquea el laboratorio, pero F00 ya cita libros, y la regla
5 exige que el recurso esté verificado e inventariado antes de citarlo.

**Por qué a05 nace en T7:** su primer verificador lo pide F15; escribirlo antes sería fijar un formato
de entrada sin la fase que lo justifica.

---

## 4. 🔍 Las verificaciones

Se corren al cerrar cada tanda, y todas en T17. **Se corren dentro de `mdm-lab`** (regla 9), con el
curso montado en `/curso`, desde `/curso/cursos-bd/gestores-sql/01-bases/`. Solo `git status` y
`docker ps` se corren en la máquina de Oskar, porque son de solo lectura.

**Enlaces y anclas**, desde la raíz de `01-bases/`:

```bash
python3 - <<'EOF'
import re, os, glob
def slug(h): return re.sub(r'[^\w\- ]', '', h.strip().lower()).replace(' ', '-')
def strip_code(t):
    t = re.sub(r'````.*?````', '', t, flags=re.S)
    return re.sub(r'```.*?```', '', t, flags=re.S)
def anchors(path):
    body = strip_code(open(path, encoding='utf-8').read())
    return {slug(h) for h in re.findall(r'^#{1,6} (.+)$', body, re.M)}
for f in glob.glob('**/*.md', recursive=True):
    body = re.sub(r'`[^`]*`', '', strip_code(open(f, encoding='utf-8').read()))
    for link in re.findall(r'\]\(([^)]+)\)', body):
        if link.startswith('http') or link == '#': continue
        path, _, anc = link.partition('#')
        target = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else f
        if path and not os.path.exists(target): print('ROTO', f, link)
        elif anc and target.endswith('.md') and anc not in anchors(target): print('ANCLA', f, link)
EOF
```

- Ignora lo que hay dentro de bloques y de código en línea, porque las plantillas y la guía llevan
  enlaces de ejemplo.
- `slug` calcula el ancla como GitHub. Con esto se comprueba también que cada
  `soluciones/NN-slug.md#ejercicio-N` existe.

**Ningún documento del curso cita un desechable**, desde la raíz de `01-bases/`:

```bash
grep -rln "_desechable-" --include='*.md' . | grep -v '^./prompts/'   # no debe devolver nada
```

**Ningún README cambió fuera de T16**, en la máquina de Oskar y desde la raíz de `01-bases/` (solo
lectura: git lo maneja Oskar):

```bash
git status --short -- ':(glob)**/README.md' ../README.md    # fuera de T16 no debe devolver nada
ls 0-ESTRUCTURA-CURSO.md 2>/dev/null                         # antes de T16 no debe existir
```

**Ejercicios contra la propuesta**, desde la raíz de `01-bases/`:

```bash
for f in [0-9][0-9]-*.md ac[0-9][0-9]-*.md; do
  [ -f "$f" ] || continue
  n=$(grep -cE '^### (🟢|🟡|🟠|🔴) Ejercicio [0-9]+' "$f")
  s=$(grep -cE '^### Ejercicio [0-9]+' "soluciones/$f" 2>/dev/null || echo 0)
  printf '%-48s %4s ejercicios %4s soluciones\n' "$f" "$n" "$s"
done
```

- Cuenta los ejercicios numerados de cada fase (sin 🔥) y las soluciones de su solucionario, para
  comparar a mano con la columna de la propuesta §13. Los dos números tienen que coincidir.

**Longitud del cuerpo**, cortando por el encabezado de 🧪, para comparar con la tabla de la guía §8:

```bash
for f in [0-9][0-9]-*.md ac[0-9][0-9]-*.md; do
  [ -f "$f" ] || continue
  n=$(sed '/^## 🧪/,$d' "$f" | wc -w)
  printf '%-48s %6s\n' "$f" "$n"
done
```

**Bloques `text` de más de 75 columnas y LaTeX**, contando caracteres y no bytes:

```bash
python3 - <<'EOF'
import glob, re
for f in sorted(glob.glob('*.md') + glob.glob('soluciones/*.md')):
    inb = False
    for i, l in enumerate(open(f, encoding='utf-8'), 1):
        l = l.rstrip('\n')
        if re.match(r'^\s*```text', l): inb = True; continue
        if re.match(r'^\s*```', l): inb = False; continue
        if inb and len(l) > 75: print('ANCHO', f, i, len(l))
        if re.search(r'\$[^$\s][^$]*\$|```math|\\\(', l): print('LATEX?', f, i)
EOF
```

- `LATEX?` se revisa a mano: en AC08 aparecen funciones de MUMPS como `$ORDER`.

**Identificadores prohibidos**, desde la raíz de `01-bases/`:

```bash
grep -rnwE 'grade|foo|bar|tabla1' [0-9][0-9]-*.md ac[0-9][0-9]-*.md soluciones src
```

- Revisión a mano: `grade_level` no aparece, porque `-w` busca la palabra sola.

**Contenedores del curso**, en la máquina de Oskar:

```bash
docker ps -a --filter label=curso=01-bases --format '{{.Names}}\t{{.Status}}\t{{.Ports}}'
```

- Cada uno tiene que estar en el inventario de §2.4, y ninguno publica un puerto fuera del rango
  `56000–56099`.

**URL externas**, por código de estado y sin seguir a ciegas las redirecciones: aterrizar en la
portada de un sitio cuenta como roto.

---

## 5. 📦 Las tandas, una por una

Lo que cada documento escribe, pesa y arriesga está en su ficha y en su prompt. Aquí va solo lo que no
cubren: por qué la tanda va en ese lugar y cuándo está terminada.

### P1 a P6 — Los documentos de `prompts/`

Escritos el 2026-10-02, después de cerrar el temario en `_desechable-propuesta-temas.md`, en este
orden: el alcance primero, porque decide el qué; la guía, porque todo lo demás la cita y fija los
nombres de archivo; las propuestas, que fijan horas, ejercicios y fichas; las plantillas; los prompts,
que **citan las fichas en lugar de copiarlas**; y este plan. Si uno cambia, se corrigen después los
que cuelgan de él, **nunca al revés**.

### P7 — Decisiones

Cerradas por Oskar el 2026-10-02 durante la discusión del temario: D1–D18 y A–E, registradas en el
alcance §13. Las que más pesan en la producción: **D12** (SQLite nativo para el lector, que obliga a
las recetas por plataforma de §2.3), **D15** (`radb` en lugar de RelaX), **D17** (identificadores en
inglés también en el álgebra) y **E** (bloque A.C. con Git, LMDB, YottaDB y C).

### P8 — Laboratorio de producción y verificación de herramientas

**Entrega:** `prompts/verificacion-de-laboratorio/` con `Dockerfile`, `compose.yaml`,
`requirements.txt`, `hallazgos.md` (formato de la Lite: `H1`, `H2`…) y las pruebas en
`comprobaciones/`, y el inventario de §2.4 al día. ✅ el 2026-10-03. **Qué se verifica**, todo dentro de
contenedores:

- **`mdm-lab`**: la imagen del laboratorio, con las versiones de Python, `sqlite3` (con `STRICT`),
  `radb` y Faker que se fijan aquí, con fecha;
- **`radb`**: instalación en un `venv`, sintaxis de invocación y de configuración, comportamiento con
  tablas `STRICT` y con `NULL`, y el SQL que genera;
- **SQLite**: `foreign_keys` por defecto, `INTERSECT ALL` y `EXCEPT ALL`, actualización de vistas e
  `INSTEAD OF`, `WITH CHECK OPTION`, triggers de sentencia, `dbstat` y `sqlite3_analyzer`, y el
  síntoma literal de una copia hecha con el `-wal` pendiente;
- **Faker**: la misma salida con la semilla y la versión fijadas, en `mdm-lab` en arm64 y bajo
  `--platform linux/amd64`;
- **las recetas Linux** de `a01` y `a02` en `mdm-linux-debian`, `mdm-linux-fedora` y `mdm-linux-arch`:
  la versión de SQLite y de Python que trae cada gestor;
- **las recetas de macOS y Windows** se anotan como pendientes de Oskar (§2.3);
- **bloque A.C.**: `lmdb` (si trae LMDB incluido), ZODB, GnuCOBOL y Harbour, los *flags* de ANSI C en
  GCC, la imagen de YottaDB y su arquitectura, y el paquete `yottadb` dentro del contenedor (sus
  wheels son solo x86-64).

**Si `radb` no funciona con `STRICT`, la tanda para** y se decide con Oskar (guía §17), porque afecta
a `a01`, `a03`, `a04` y la guía §6 a la vez. **Terminada cuando** cada punto tiene un hallazgo con
fecha, lo que no funciona tiene alternativa decidida y ningún contenedor publica un puerto por
defecto. La parte del bloque A.C. puede cerrarse después, antes de T14.

### P9 — Fuentes

Edición vigente, año, editorial y traducción al español de los cinco textos (alcance §9), comprobadas
en páginas de la editorial o del autor; **el mapa de capítulos de Navathe 7.ª contra las 38 fases**,
que corrige las fichas de la propuesta (hoy de memoria); los capítulos de los otros cuatro textos; la
terminología de las ediciones en español, para `a07`; los cursos de YouTube (CMU 15-445/645, Berkeley
CS186, la serie de Jennifer Widom) con su clase por fase; los cursos de Coursera y Udemy de teoría por
bloque, con idioma, precio y fecha; los papers fundacionales; y la afirmación sobre MySQL y `EXCEPT`
(F10). **Del bloque A.C.**: qué motor usa hoy cada producto de AC00 (Active Directory, OpenLDAP,
Subversion, RPM, VistA, Epic…) y desde cuándo, sus papers y libros, y las implementaciones open
source de la propuesta §12.2. **Terminada cuando** todo eso está en un inventario fechado, listo
para `a08`: es `prompts/inventario-de-fuentes.md`, ✅ el 2026-10-03.

### P10 — Traslado de lo verificado

Lo que salga de P8 y P9 pasa a su sitio: los capítulos, a las fichas de la propuesta de fases (y su
§15 se vacía); las verificaciones pendientes, a la propuesta de apéndices §14; las versiones y `radb`
con `STRICT`, a la guía §17; y los prompts que citaban un pendiente ya resuelto. **Si una verificación
contradice una decisión cerrada del alcance, no se traslada**: se lleva a Oskar. **Terminada cuando**
ningún documento de `prompts/` dice "por confirmar" o "se fija en P8" sobre algo ya verificado, y §4
sale limpia sobre `prompts/`.

### T0 — Arranque

**Entrega:** `INSTINTOS.md` con su encabezado, su formato de entrada (el 🪞, el contraejemplo o el
cálculo, y la fase de origen) y la nota "crece con el curso", **sin enlaces** a fases que todavía no
existen; y las carpetas `soluciones/` y `src/`. `0-ESTRUCTURA-CURSO.md` **no** se crea aquí (regla 4).
Puede correr antes de P8.

### T1 — Laboratorio

`a01` → `a02` → `a03` → `a04`, en ese orden, más `src/requirements.txt` y
`src/a04-las-bases-de-ejemplo/`. **Terminada cuando**, dentro de `mdm-lab`, se recrean `school` y
`supply` desde cero, se consultan con `radb` y con `sqlite3`, y los conteos coinciden con los de
`a04`; y las recetas Linux están verificadas en sus contenedores.

### T2 a T13 — El camino base

Una tanda por bloque o por tramo de bloque, en orden. Lo particular de cada una:

- **T2** abre `a08` con lo que P9 dejó verificado, y su prueba de fuego es la de F01, que valida T1.
- **T3**: F02 fija la convención de diagramas ER en ASCII; si `a07` no existe todavía, va a §6 y
  entra en T4.
- **T4**: `a06` y el esqueleto de `a07` antes de F04. F06 abre el hilo de π y − y fija la convención
  de archivos de `radb`.
- **T5**: F07 es una de las fases más largas del curso (14 h); conviene una sesión solo para ella.
- **T6**: F10 es el corazón del hilo y la otra fase larga del bloque. F13 cierra el Bloque II y su
  esquema se contrasta con `a04`.
- **T7**: F14 primero; después F15, cuya sesión hace nacer `a05` con `closure`, `min_cover` y `keys`
  y fija el formato de entrada de relaciones y DF; cierra F16, con `normal_form`.
- **T8**: F17 (`njb`, `chase`, `preserves`) y F18 (`synth_3nf`, `bcnf_decompose`) amplían `a05`.
- **T9**: F21 fija el modelo de costo del resto del curso; F22 decide el verificador de hashing; F24
  escribe `bplus` y fija la definición de orden.
- **T10**: F26 escribe el mini motor y cierra el hilo; su diseño lo reutiliza el bloque A.C.
- **T11**: F29 escribe `conflict_serializable` y fija la notación de planes.
- **T12**: `a09` antes de F34, con `mdm-pg` registrado en §2.4. F36 cierra los pendientes que F02,
  F05, F17 y F20 le difirieron.
- **T13**: F37 y el cierre de `a05`, `a07`, `a08` e `INSTINTOS.md` (al menos un 🪞 por bloque).

**Terminadas cuando** sus fases y solucionarios pasan la guía §15, los documentos vivos están al día y
§4 sale limpia.

### T14 y T15 — El bloque A.C.

T14 es normal: `aca-01` con AC01, y AC00–AC05 con los laboratorios L1–L5 (sobre el contador del mini
motor) y ZODB, todo en `mdm-ac`. T15 es densa: AC06 (Git), AC07 (LMDB), `aca-02` con AC08 (YottaDB en
`mdm-yottadb`, emulado si hace falta) y AC09, cuyo código en C se genera con asistencia de IA, se
revisa y **se compila sin advertencias** con GCC en contenedor; la compilación con Visual C++ queda
como pendiente de Oskar en Windows (§2.3). **Si AC08 no puede correr** por lo que encontró P8, entra el
caso de reserva (el `.dbf`) y se anota en §7.

### T16 — Los README y la estructura

Una tanda propia, **después de que todo el contenido exista**, porque un README o un temario escritos
a medias describen un curso que no es el que se publica. Escribe:

- `0-ESTRUCTURA-CURSO.md`: el temario en una página, con horas, ejercicios, estado real y enlace a
  cada fase, solucionario y apéndice. Sale de la propuesta de fases §13 y de §3 de este plan, que dejan
  de ser el mapa;
- el `README.md` de la raíz del curso (qué es, para quién, cómo se sigue, el bloque A.C. y los
  apéndices);
- los README de `src/` que hagan falta;
- la sección `01-bases` del `README.md` de `gestores-sql/`, que hoy describe el plan tentativo.

Salda toda la deuda de §6 dirigida a T16. **Terminada cuando** los cuatro describen lo que existe y
sus enlaces pasan §4.

### T17 — Cierre

**Terminada cuando** §4 sale limpia en todo el curso; las URL externas están verificadas; **todos los
contenedores con la etiqueta `curso=01-bases` están detenidos** y el inventario de §2.4 lo dice; y
—con permiso de Oskar— los tres desechables y el `.gitkeep` de `01-bases/` están borrados sin
menciones, y, si él lo pide, también los contenedores, imágenes y volúmenes `mdm-*`.

---

## 6. 🧾 Deuda de enlaces abierta

Cada mención en prosa que espera a que exista su destino. Formato: origen → destino → tanda que la
cierra.

| Origen | Destino pendiente | La cierra |
|---|---|---|
| — | — | — |

**Deuda de T16** (lo que irá en los README y la estructura):

- (vacía al 2026-10-02)

---

## 7. 📓 Bitácora

Una entrada por sesión, la más reciente arriba: qué se cerró, qué quedó a medias y por qué, qué se
comprobó y cómo, y las trampas que la próxima sesión debe conocer.

**2026-10-03 · P8, P9 y P10: la preparación, cerrada.** Todo en una sesión y en secuencia, sin
subagentes. **P8**: `mdm-lab` construido (Python 3.14.8, SQLite 3.46.1, `radb` 3.0.5, Faker 40.40.0)
y doce hallazgos en `verificacion-de-laboratorio/hallazgos.md`. Los que cambian algo: **`radb`
funciona sobre `STRICT`** (una sola variante de las bases); **SQLAlchemy 2.1 rompe los tipos de
`radb`** y queda fijado en 2.0.54; **`-- radb` no es comentario** en `radb` (la guía y la plantilla
pasan a `// radb`); la invocación es `radb base.db -i archivo.ra`; Faker da los mismos datos en arm64
y x86-64, pero **`date_of_birth` depende de la fecha de hoy**; SQLite no tiene `INTERSECT ALL`,
`EXCEPT ALL`, `WITH CHECK OPTION` ni triggers de sentencia, y `foreign_keys` vale `0` por defecto; la
copia sin el `-wal` **pasa `integrity_check`** y pierde filas en silencio; Python mínimo 3.10. Recetas
Linux verificadas en Debian 13, Ubuntu 24.04 y 26.04, Fedora 44 y Arch. Bloque A.C., también cerrado:
`lmdb` trae LMDB, GnuCOBOL 3.2 corre, **Harbour 3.2.0 se compila desde el fuente** (no hay paquete en
Linux), **YottaDB r2.06 corre nativo en arm64** con el paquete `yottadb` compilado dentro. **P9**:
`inventario-de-fuentes.md`; los capítulos de Navathe de las fichas eran correctos, **las secciones no
se pudieron verificar** (solo había índices completos en copias no autorizadas, que no se usaron) y
se quitaron; la ficha de F10 citaba mal *SQL and Relational Theory* (caps. 6–7, no 1–4); veinte papers
por DOI; MySQL `EXCEPT` desde la 8.0.31, confirmado. **P10**: trasladado a la guía (§5, §5.1, §6, §17),
al alcance, a las dos propuestas y a los tres archivos de prompts; ninguna verificación contradijo
una decisión cerrada. **Queda para Oskar:** las comprobaciones de macOS y Windows (H11), el mensaje de
PowerShell, los *flags* de Visual C++ y los cursos de Udemy (403 a toda consulta automática).
**Trampas:** `docker exec` sin `-i` se traga el *heredoc* en silencio; Arch emulado necesita
`pacman --disable-sandbox`. **Siguiente:** T0, después T1.

**2026-10-02 · El laboratorio de producción.** Por pedido de Oskar, **toda prueba se ejecuta dentro de
un contenedor** (regla 9 y §2.4): sin puertos por defecto, con la etiqueta `curso=01-bases` y el
prefijo `mdm-`, registrados en el inventario y **detenidos en T17**. Comprobado ese día en la máquina
de producción: Docker 29.8 en arm64, Podman no instalado, y dos contenedores ajenos publicando
`127.0.0.1:8083` y `127.0.0.1:27029`. Consecuencia: las recetas nativas de macOS y Windows no se
pueden verificar en contenedor y quedan para Oskar o declaradas (§2.3); las de Linux sí, en
contenedores de cada distribución. El plan se reescribió con el formato del de la Ruta SQL, y la
regla se agregó a la guía §11 y a los marcos de los prompts.

**2026-10-02 · P1–P7.** Discutido el temario con Oskar en `_desechable-propuesta-temas.md`, que fue la
fuente de verdad mientras duró y absorbió `_desechable-modelos-legacy.md` como bloque opcional A.C.
Decisiones D1–D18 y A–E cerradas (alcance §13); la más visible es **D15**, `radb` en lugar de RelaX,
verificado en PyPI y en su hoja de referencia: no tiene ÷, outer join, ⋉ ni ▷, y el curso lo
aprovecha. Consultado en PyPI: `lmdb` 3.0.0 con wheels para las tres plataformas, ZODB 6.3 (abril de
2026), `yottadb` 2.0.1 con wheels solo para Linux x86-64, upscaledb inactivo desde 2017. Escritos los
ocho documentos de `prompts/` que no son desechables, más este plan: alcance, guía, propuestas de
fases (38 + 10 fases, 403 + 67 h, 1 345 + 221 ejercicios, sumas comprobadas) y de apéndices (9 + 2),
plantillas (seis), prompts de fase, del bloque A.C. y de apéndice. **Trampa conocida:** los capítulos
de Navathe de las fichas están de memoria; P9 los corrige. **Siguiente:** P8 y P9, en sus propias
sesiones; T0 ya puede empezar.

---

## 8. ✅ Checklist final

Se marca `[x]` al cerrar cada punto. Una tanda se marca terminada solo cuando todos sus puntos lo
están, y entonces se cambia su estado en §3.

### Preparación (`prompts/`)

- [x] P1 · `prompts/guia-de-estilo-y-convenciones.md`
- [x] P2 · `prompts/alcance-del-proyecto.md`
- [x] P3 · `prompts/propuesta-fases-y-alcance.md` y `prompts/propuesta-apendices-y-alcance.md`
- [x] P4 · `prompts/plantillas-de-capitulo.md`
- [x] P5 · `prompts/prompts-de-fase.md`, `prompts/prompts-ac-fase.md` y `prompts/prompts-de-apendice.md`
- [x] P6 · `prompts/_desechable-plan-de-produccion.md`
- [x] P7 · D1–D18 cerradas
- [x] P7 · A–E cerradas
- [x] P8 · `prompts/verificacion-de-laboratorio/` con `Dockerfile`, `compose.yaml` y `hallazgos.md`
- [x] P8 · `mdm-lab` construido y registrado en §2.4, sin puertos publicados
- [x] P8 · Versiones fijadas de Python, SQLite, `radb` y Faker, con fecha
- [x] P8 · `radb`: `venv`, invocación, `STRICT`, `NULL`, SQL generado
- [x] P8 · SQLite: `foreign_keys`, operadores `ALL`, vistas, `WITH CHECK OPTION`, triggers, `dbstat`, copia con `-wal`
- [x] P8 · Faker: misma salida en arm64 y en amd64 con semilla y versión fijadas
- [x] P8 · Recetas Linux en Debian, Fedora y Arch (y Ubuntu 24.04 y 26.04)
- [x] P8 · Recetas de macOS y Windows: declaradas pendientes de Oskar (H11), con los comandos a correr
- [x] P8 · Bloque A.C.: `lmdb`, ZODB, GnuCOBOL, Harbour, GCC con ANSI C, YottaDB y `yottadb`
- [x] P9 · Los cinco textos: edición, año, editorial y traducción
- [x] P9 · Mapa de capítulos de Navathe 7.ª contra las 38 fases (secciones: no verificables)
- [x] P9 · Capítulos de Date, *SQL and Relational Theory*, Petrov y *SQL Cookbook*
- [x] P9 · Terminología de las ediciones en español: declarada no verificable; decisión para `a07`
- [x] P9 · YouTube, Coursera y Udemy por bloque, con idioma, precio y fecha (Udemy y precios de Coursera, pendientes)
- [x] P9 · Papers fundacionales por fase
- [x] P9 · MySQL y `EXCEPT` (F10)
- [x] P9 · Bloque A.C.: motores de los productos reales, papers, libros, implementaciones
- [x] P10 · Lo verificado trasladado; nada "por confirmar" que ya esté verificado; §4 limpia sobre `prompts/`

### T0 — Arranque

- [ ] `INSTINTOS.md`, sin enlaces a fases inexistentes
- [ ] Carpetas `soluciones/` y `src/`

### T1 — Laboratorio

- [ ] a01 · SQLite nativo y el archivo físico
- [ ] a02 · Python, `venv` y Faker, con `src/requirements.txt`
- [ ] a03 · `radb` en tres plataformas
- [ ] a04 · Las bases de ejemplo y su generador, con `src/a04-las-bases-de-ejemplo/`
- [ ] Prueba de fuego en `mdm-lab`: `school` y `supply` recreadas, conteos de `a04` en `radb` y `sqlite3`

### T2 — Bloque 0

- [ ] Esqueleto de a08 con lo verificado en P9
- [ ] F00 · El sistema de bases de datos y sus actores, con solucionario
- [ ] F01 · Conceptos y arquitectura, con solucionario y la prueba de fuego corrida
- [ ] Documentos vivos al día · §4 limpia

### T3 — Bloque I

- [ ] F02 · Modelo entidad-relación, con solucionario (fija la convención de diagramas)
- [ ] F03 · ER extendido y notaciones, con solucionario
- [ ] Documentos vivos al día · §4 limpia

### T4 — Bloque II (1)

- [ ] a06 · La matemática mínima
- [ ] Esqueleto de a07, con la convención de diagramas de F02
- [ ] F04 · El modelo relacional, formalmente, con solucionario
- [ ] F05 · Restricciones y operaciones de actualización, con solucionario
- [ ] F06 · Álgebra I: operaciones unarias, con solucionario (abre el hilo 🧵)
- [ ] Documentos vivos al día · §4 limpia

### T5 — Bloque II (2)

- [ ] F07 · Álgebra II: conjuntos, joins y división, con solucionario
- [ ] F08 · Álgebra III: operaciones extendidas, con solucionario
- [ ] F09 · Cálculo relacional, con solucionario
- [ ] Documentos vivos al día · §4 limpia

### T6 — Bloque II (3)

- [ ] F10 · Del álgebra a SQL, con solucionario
- [ ] F11 · `NULL`, lógica de tres valores y multiconjuntos, con solucionario
- [ ] F12 · Vistas, con solucionario
- [ ] F13 · Del ER/EER al modelo relacional, con solucionario (esquema contrastado con a04)
- [ ] Documentos vivos al día · §4 limpia

### T7 — Bloque III (1)

- [ ] F14 · Guías informales de diseño y anomalías, con solucionario
- [ ] a05 · Nace con `closure`, `min_cover` y `keys`; formato de entrada fijado
- [ ] F15 · Dependencias funcionales, con solucionario
- [ ] F16 · Formas normales, con solucionario y `normal_form`
- [ ] Documentos vivos al día · §4 limpia

### T8 — Bloque III (2)

- [ ] F17 · Propiedades de las descomposiciones, con solucionario (`njb`, `chase`, `preserves`)
- [ ] F18 · Algoritmos de diseño, con solucionario (`synth_3nf`, `bcnf_decompose`)
- [ ] F19 · Más allá de FNBC, con solucionario
- [ ] F20 · Desnormalización y diseño físico, con solucionario
- [ ] Documentos vivos al día · §4 limpia

### T9 — Bloque IV

- [ ] F21 · Discos y archivos, con solucionario (modelo de costo fijado)
- [ ] F22 · Hashing, con solucionario (verificador decidido)
- [ ] F23 · Índices de uno y varios niveles, con solucionario
- [ ] F24 · Árboles B y B+, con solucionario (`bplus`, definición de orden)
- [ ] F25 · Otras estructuras de índice, con solucionario
- [ ] Documentos vivos al día · §4 limpia

### T10 — Bloque V

- [ ] F26 · Cómo se implementa cada operador, con solucionario y el mini motor (cierra el hilo 🧵)
- [ ] F27 · Optimización heurística, con solucionario
- [ ] F28 · Optimización basada en costo, con solucionario
- [ ] Documentos vivos al día · §4 limpia

### T11 — Bloque VI

- [ ] F29 · Transacciones y planes, con solucionario (`conflict_serializable`, notación de planes)
- [ ] F30 · Control de concurrencia, con solucionario
- [ ] F31 · Niveles de aislamiento, con solucionario
- [ ] F32 · Recuperación, con solucionario
- [ ] Documentos vivos al día · §4 limpia

### T12 — Bloque VII

- [ ] a09 · El curso en un contenedor, con `src/a09-…` y `mdm-pg` registrado (puerto en `56000–56099` si se publica)
- [ ] F33 · El DBA y su trabajo, con solucionario
- [ ] F34 · Seguridad y autorización, con solucionario
- [ ] F35 · Respaldo y continuidad, con solucionario
- [ ] F36 · Bases activas: triggers, con solucionario (pendientes de F02, F05, F17 y F20 cerrados)
- [ ] Documentos vivos al día · §4 limpia

### T13 — Bloque VIII y cierre del camino base

- [ ] F37 · Más allá del núcleo, con solucionario
- [ ] a05, a07 y a08 cerrados
- [ ] `INSTINTOS.md` con al menos un 🪞 por bloque
- [ ] §4 limpia

### T14 — Bloque A.C. (1)

- [ ] `mdm-ac` construido y registrado
- [ ] aca-01 · Herramientas nativas
- [ ] AC00 · Navegar contra declarar, con solucionario
- [ ] AC01 · Archivos, registros y punteros, con solucionario (L1, L5)
- [ ] AC02 · El modelo jerárquico, con solucionario (L3)
- [ ] AC03 · El modelo de red, con solucionario (L2)
- [ ] AC04 · El Gran Debate, con solucionario (L4)
- [ ] AC05 · Los herederos, con solucionario (ZODB)
- [ ] Documentos vivos al día · §4 limpia

### T15 — Bloque A.C. (2)

- [ ] AC06 · Caso de estudio: Git, con solucionario
- [ ] AC07 · Caso de estudio: LMDB, con solucionario
- [ ] aca-02 · Contenedores, con `src/aca-02-contenedores/` y `mdm-yottadb` registrado
- [ ] AC08 · Caso de estudio: YottaDB, con solucionario (o el caso de reserva, anotado en §7)
- [ ] AC09 · Pedidos en C, con solucionario y `src/ac09-pedidos-en-c/` compilado sin advertencias con GCC
- [ ] AC09 · Compilación con Visual C++: verificada por Oskar o declarada
- [ ] Documentos vivos al día · §4 limpia

### T16 — Los README y la estructura

- [ ] `0-ESTRUCTURA-CURSO.md`, con el estado real
- [ ] `README.md` del curso
- [ ] README de `src/`, los que hagan falta
- [ ] Sección `01-bases` del `README.md` de `gestores-sql/`
- [ ] Deuda de §6 dirigida a T16, saldada

### T17 — Cierre

- [ ] §4 limpia en todo el curso; URL externas verificadas
- [ ] Todos los contenedores `curso=01-bases` detenidos; inventario de §2.4 al día
- [ ] Con permiso de Oskar: los tres desechables y el `.gitkeep` borrados, menciones limpias
- [ ] Con permiso de Oskar: contenedores, imágenes y volúmenes `mdm-*` borrados, si él lo pide
