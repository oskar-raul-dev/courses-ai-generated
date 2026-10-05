# 🧪 Prueba pendiente: Mermaid, anclas FE0F y deuda de los cursos

> **Qué es este documento:** el checklist de lo que quedó abierto al cerrar la primera versión de
> `zz-instrucciones/` (2026-10-04), para hacerlo **por grupo de cursos, en sesiones aparte**. Es
> desechable: no se cita desde ningún documento y se borra cuando todas las casillas estén marcadas.
> **Cómo se usa:** una sesión por grupo (§3 a §6). Cada sesión empieza leyendo este documento, marca
> sus casillas al cerrar y deja una línea en la bitácora (§8).
> **Vigencia:** 2026-10-04.

**Salto rápido:** [1](#1--instalar-mermaid-cli-lo-hace-oskar) · [2](#2--grupo-0-zz-instrucciones) · [3](#3--el-procedimiento-de-cada-curso) · [4](#4--grupo-a-repaso-entrevistas) · [5](#5-️-grupo-b-courses-ia-generated) · [6](#6--grupo-c-decisiones-y-limpieza) · [7](#7--reglas-de-estas-sesiones) · [8](#8--bitácora)

---

## 1. 🧰 Instalar `mermaid-cli` (lo hace Oskar)

`mermaid-cli` (`mmdc`) dibuja cada bloque Mermaid de un `.md` con un Chrome sin ventana; si un
diagrama tiene un error de sintaxis, falla y dice en qué bloque. Datos comprobados el 2026-10-04 en el
registro de npm: **`@mermaid-js/mermaid-cli` 12.0.0**, que pide **Node ≥ 22.13.0**, y trae
**Puppeteer 25** como dependencia, que descarga su propio Chrome a `~/.cache/puppeteer` la primera vez.
Tu Node es el 24.21.0 de nvm, así que cumple.

```bash
node --version                                   # tiene que decir v22.13 o más
npm install -g @mermaid-js/mermaid-cli@12.0.0
mmdc --version                                   # tiene que decir 12.0.0
```

- `node --version` confirma que la versión activa de nvm es la que cumple el mínimo; si dice otra,
  `nvm use 24` antes de instalar.
- `npm install -g … @12.0.0` instala `mmdc` en la versión fijada, dentro del Node activo de nvm (no
  toca el sistema). Puppeteer, que llega como dependencia, descarga Chrome para pruebas en
  `~/.cache/puppeteer`: es lo que más pesa de la instalación.
- `mmdc --version` confirma que el ejecutable quedó en el `PATH`.

**Prueba de humo**, con un diagrama mínimo en un directorio temporal:

```bash
mkdir -p /tmp/mmdc-humo-1 && cd /tmp/mmdc-humo-1
printf 'flowchart LR\n    A --> B\n' > humo.mmd
mmdc -i humo.mmd -o humo.svg && ls -l humo.svg
```

- `mkdir -p` crea un directorio nuevo para la prueba; si ya existe, usa otro sufijo en vez de borrarlo.
- `mmdc -i … -o humo.svg` dibuja el diagrama; si Chrome no arranca, el error sale aquí y no en medio
  de una verificación.
- `ls -l` muestra que el SVG existe y no pesa cero.

**Para desinstalar** cuando ya no haga falta: `npm uninstall -g @mermaid-js/mermaid-cli`, y borrar a
mano la carpeta del Chrome de Puppeteer en `~/.cache/puppeteer` si no la usa nada más.

> 📝 **El aviso de `allow-scripts` de npm 11.** Al instalar, npm 11.19 avisa que no ejecutó el
> `postinstall` de `puppeteer@25.12.0` (el que descarga Chrome) y propone
> `npm install -g --allow-scripts=puppeteer`. El 2026-10-04 no hizo falta: `~/.cache/puppeteer` ya tenía
> `chrome` y `chrome-headless-shell` en la 154.0.8037.57, la misma que exige la `puppeteer-core`
> instalada, y la prueba de humo pasó. Si en otra máquina `mmdc` falla con "Could not find Chrome", se
> repite la instalación con `--allow-scripts=puppeteer`.

- [x] `mmdc --version` dice 12.0.0 (2026-10-04)
- [x] La prueba de humo genera `humo.svg` (2026-10-04, en el scratchpad: `mmdc-humo-1/`)

---

## 2. 🧭 Grupo 0: `zz-instrucciones`

Validar que los diagramas de esta carpeta se dibujan. `mmdc` acepta un `.md` entero: busca sus bloques
Mermaid, genera un SVG por bloque y escribe una copia del `.md` que los referencia. Las copias van al
`salidas/` de un directorio de `zz-code/` creado para la sesión, nunca junto a los originales.

```bash
SALIDA="<ruta que imprime zz-code/nuevo.py>/salidas"   # python3 zz-code/nuevo.py zz-instrucciones
mkdir -p "$SALIDA"
cd /Users/oskar/Developer/job-interview-sept-2026/zz-instrucciones
for f in $(grep -rl '```mermaid' --include='*.md' .); do
  destino="$SALIDA/${f#./}"
  mkdir -p "$(dirname "$destino")"
  mmdc -i "$f" -o "$destino" > "$destino.log" 2>&1 || echo "FALLA  $f  (ver $destino.log)"
done
```

- `grep -rl '```mermaid'` lista solo los `.md` que tienen diagramas.
- `mmdc -i "$f" -o "$destino"` dibuja todos los bloques del archivo; el `.log` guarda el error si lo hay.
- `|| echo "FALLA …"` deja una línea por archivo con algún diagrama roto, para no leer los logs uno por
  uno.

> ⚠️ **Los diagramas de `plantillas/` tienen `{{placeholders}}` dentro.** Varios son válidos así
> (están entre comillas), pero algunos no lo serán hasta rellenarlos —por ejemplo el
> `sequenceDiagram` de la plantilla de fase, que es solo un hueco—. Un FALLA en `plantillas/` se mira a
> mano: si el diagrama es válido una vez rellenado, se deja; si no, se corrige.

- [ ] Ningún FALLA en `README.md`, `00-` a `04-`
- [ ] Los FALLA de `plantillas/` revisados: corregidos, o anotados como "válido al rellenar"
- [ ] El código intermedio (`$SALIDA`) listado para borrar en la bitácora

---

## 3. 🔁 El procedimiento de cada curso

Lo mismo para cada curso de los grupos A y B, en este orden. Las anclas `ANCLA-FE0F` son enlaces a
encabezados con ⚠️, ⚖️, ⚙️, 🏷️ o 🗂️ escritos sin el carácter invisible U+FE0F que GitHub conserva en
el ancla (lecciones §8).

1. **Mirar si el curso está en producción** (plan o bitácora con fecha reciente, archivos tocados hoy).
   Si otra sesión lo está escribiendo, se salta y se anota: no se corrige un curso a medio escribir.
2. **Primera pasada**, sin tocar nada:

   ```bash
   B=/Users/oskar/Developer/job-interview-sept-2026/zz-instrucciones/herramientas/verificador_base.py
   D=<ruta que imprime python3 zz-code/nuevo.py <curso>>/salidas; mkdir -p "$D"
   python3 -B "$B" <curso> --perfil=<repaso|courses-ia> > "$D/antes.log"
   ```

   - `-B` evita que Python deje un `__pycache__` en `herramientas/`.
   - El log de antes queda en `zz-code/<id>/salidas/` para comparar.

3. **Corregir las anclas FE0F** con la opción del verificador, y comparar:

   ```bash
   python3 -B "$B" <curso> --perfil=<…> --corregir-fe0f > "$D/despues.log"
   git -C <curso> diff --stat
   ```

   - `--corregir-fe0f` reescribe solo los `](enlace)` exactos que el verificador marcó, y vuelve a
     verificar.
   - `git diff --stat` (solo lectura) muestra qué archivos cambiaron; el commit lo hace Oskar.

4. **Actualizar el verificador propio del curso**, si tiene uno que calcula anclas (§4): con la regla
   vieja, las anclas recién corregidas le saldrán rotas. Se cambia su función de slug por la de
   `verificador_base.py` (`slug_github` con su tabla `_SLUG_QUITAR`), o el script pasa a heredar de la
   base. Se corre en verde.
5. **Revisar a mano los demás errores** (`ROTO`, `ANCLA`, `FUERA`): cada uno se corrige, o se anota
   como deuda del curso con su porqué.
6. **Marcar la casilla** y escribir la línea de bitácora.

> 🧠 **Probado el 2026-10-04 sobre una copia de `frameworks/01-spring-boot`:** 167 errores
> `ANCLA-FE0F` → 177 enlaces corregidos en 26 archivos, y el `prompts/verificar-anclas.py` del curso
> pasó a marcar 177 rotas hasta cambiar su slug. Por eso el paso 4 no es opcional.

---

## 4. 📚 Grupo A: `repaso-entrevistas`

Perfil `--perfil=repaso`. Las cifras son de la pasada del 2026-10-04 y pueden haber cambiado.

| Corpus | `ANCLA-FE0F` | Otros errores | Script propio que calcula anclas | Hecho |
|---|---|---|---|---|
| `frameworks/01-spring-boot` | 167 (+13 multilínea) | — | `prompts/verificar-corpus.py` (hereda de la base; sustituye a `verificar-anclas.py`) | [x] 2026-10-05 |
| `bases/02-algoritmos-estructuras-de-datos` | 64 | `ANCLA` 3 · **en producción** | `prompts/verificar-corpus.py` | [ ] |
| `bases/05-bases-datos` | 60 (+41 multilínea) | — | `prompts/controles-texto.py` | [x] 2026-10-04 |
| `bases/03-poo-y-patrones` | 56 | — | `prompts/verificar-corpus.py` | [ ] |
| `arquitectura/02-monolito` | 20 | — | `scripts/verificar_corpus.py` | [x] 2026-10-04 |
| `arquitectura/03-hexagonal` | 16 | — | — | [x] 2026-10-04 |
| `arquitectura/04-microservicios` | 16 | — | — | [x] 2026-10-04 |
| `arquitectura/01-bases` | 7 | — | — | [x] 2026-10-04 |
| `arquitectura/06-serverless` | 6 | — | `prompts/verificar-corpus.py` (hereda de la base) | [x] 2026-10-04 |
| `arquitectura/05-event-driven` | 5 | — | `prompts/verificar-corpus.py` (hereda de la base) | [x] 2026-10-04 |
| `bases/01-bases` | 3 | — | — | [x] 2026-10-04 |
| `cloud/03-azure` | 1 | — | `prompts/verificar-anclas.py` | [x] 2026-10-04 |
| `cloud/01-aws`, `cloud/02-gcp`, `bases/04-apis-protocolos` | 0 | — | — | [x] confirmado limpio 2026-10-04 |

- [ ] **`verificador_base.py` no ve los enlaces cuyo texto cruza un salto de línea**
  (`[Errores⏎frecuentes](#-errores-frecuentes)`): `LINK_RE` exige el `[` en la misma línea. En
  `bases/05-bases-datos` escondía 41 `ANCLA-FE0F` reales. Hay que buscar `](…)` sin exigir el `[` (como
  `controles-texto.py` de ese curso) o unir las líneas de cada párrafo antes, y repasar los cursos ya
  cerrados: `arquitectura/01`–`04`, `bases/01`, `04` y `cloud/` ya se repasaron y no tienen ninguno.
- [ ] **Regla de anclas del `CLAUDE.md` de este repositorio** actualizada con la excepción del U+FE0F
  (la sección "Enlaces: lo que más se rompe"), con permiso de Oskar.

---

## 5. 🗂️ Grupo B: `courses-ia-generated`

Perfil `--perfil=courses-ia`. Ningún curso de este repositorio tiene un script propio que calcule
anclas, así que el paso 4 no aplica.

| Curso | `ANCLA-FE0F` | Otros errores | Hecho |
|---|---|---|---|
| `cursos-contenedores-cloud-infra/lab-docker-kubernetes` | 25 | `ROTO` 2 (deuda: `18-logs.md`), `ANCLA` 1 (`INSTINTOS.md`), `FUERA` 1 (`../README.md`) · **en producción** | [ ] |
| `cursos-contenedores-cloud-infra/docker-container-legacy` | 15 | `ANCLA` 1 (`a09`, `#11--…` para un `### 1.1`) | [ ] |
| `cursos-bd/ruta-no-sql-lite` | 8 | `ROTO` 10 (deuda), `FUERA` 14 (enlaces a otros cursos), `PROMPTS` 5 · **en producción** | [ ] |
| `cursos-legacy/react-16-legacy-for-backend-devs` | 3 | — | [ ] |
| `cursos-legacy/vue2-legacy-for-backend-devs` | 1 | — | [ ] |
| `cursos-legacy/angular-8-legacy-for-backend-devs` | 0 | `FUERA` 6 | [ ] |
| `cursos-legacy/angular-16-legacy-for-backend-devs` | 0 | `FUERA` 1 | [ ] |
| `c-sharp`, `go`, `python-for-java-devs`, `ruta-sql` | 0 | — | [ ] confirmado limpio |

- [ ] Los `FUERA` revisados contra la regla de autocontención de cada curso: si el curso se declara
  autocontenido, el enlace se quita; si no, se ajusta su subclase (`AUTOCONTENIDO = False`).

---

## 6. 🧹 Grupo C: decisiones y limpieza

- [ ] **Diccionario de términos**: cerrar los 16 pares de `plantillas/diccionario-de-terminos.md` §6
  (librería/biblioteca, cluster/clúster, ambiente/entorno…).
- [ ] **`CLAUDE.md`**: agregar `zz-instrucciones/` a la tabla de familias (con permiso de Oskar).
- [ ] **`herramientas/__pycache__/`**: directorio vacío que dejó una corrida sin `-B`. No se borra
  desde una sesión (regla de no borrar directorios); lo borra Oskar.
- [ ] **Piloto**: usar las plantillas en un curso nuevo de punta a punta (E0 a E9) y subir lo aprendido
  a `03-lecciones-de-produccion.md`. Lo no probado todavía: el banco de examen y el plan que nace en E3.
- [ ] **Borrar este documento** cuando todo lo anterior esté marcado.

---

## 7. 📏 Reglas de estas sesiones

- **Una sesión por grupo**, secuencial y sin agentes, salvo que Oskar pida otra cosa.
- **Nada se instala** desde la sesión: `mmdc` lo instala Oskar con §1.
- **Git lo hace Oskar**: solo `git diff` y `git status` de lectura.
- **Nada se borra salvo archivos nombrados**; el código intermedio (logs, copias, SVG de prueba) va a
  `zz-code/<id>/salidas/` (desde el 2026-10-05; antes iba al scratchpad) y se libera con `limpiar.py`.
- **Un curso en producción por otra sesión no se toca**: se anota y se deja para después.

---

## 8. 📓 Bitácora

Una línea por sesión, la más reciente arriba: fecha, grupo, qué se cerró, qué quedó y por qué, y el
código intermedio para borrar.

- **2026-10-05 · grupo A, `frameworks/01-spring-boot`.** Hecho dentro del ajuste del curso a estos
  lineamientos (guía §13 nueva, decisiones de Oskar: labs como deuda declarada, sin documentos nuevos en
  `prompts/`, verificador reemplazado). `--corregir-fe0f`: 177 enlaces en 26 archivos, y otros **13 en
  `26-respuestas.md` cuyo texto cruza un salto de línea**, que la subclase nueva ve (reenvía los `](…)`
  sin `[` a la validación base). `verificar-anclas.py` y `verificar-preguntas.py` borrados; los sustituye
  `prompts/verificar-corpus.py` (formato `### NN → n`, claves `L01`/`A01`, URL sin versión, conteo de
  ejercicios), probado con cinco errores sembrados en una copia. Resultado: 0 errores, 0 avisos, 571
  preguntas sincronizadas. Código intermedio: `scratchpad/sb-ajuste-1/`, ya borrado (quedan tres carpetas
  vacías, que no se borran desde una sesión). Desde aquí, todas las pruebas en `zz-code/`.
- **2026-10-04 · grupo A, `arquitectura/05-event-driven` y `06-serverless`.** Hecho dentro del ajuste
  de los dos cursos a estos lineamientos (sus tandas `P9`–`P12`; ninguno tiene capítulos todavía).
  `--corregir-fe0f`: 05, 5 enlaces en 3 archivos de `prompts/`; 06, 6 en 3. Cada curso tiene ahora
  `prompts/verificador_base.py` (copia) y `prompts/verificar-corpus.py` (subclase de
  `PerfilRepasoEntrevistas` con sus validaciones propias), en 0 errores y 0 avisos. Enlaces cuyo texto
  cruza un salto de línea: ninguno en los dos. Mermaid no aplica: los dos fijaron ASCII obligatorio.
  Código intermedio para borrar: `scratchpad/ver-05-1/` y `scratchpad/ver-06-1/` (copias de prueba
  del verificador), y `scratchpad/plan05-checklist-T.md`.

- **2026-10-04 · grupo A, `cloud/`.** Ninguno en producción. `01-aws` y `02-gcp`: limpios, también en el
  barrido de enlaces multilínea. `03-azure`: 1 enlace en `a05-kql-de-supervivencia.md`; su
  `prompts/verificar-anclas.py` conserva ahora el U+FE0F (`[^\w\- \ufe0f]`) y da 0 problemas;
  `verificar-curso.sh` entero limpio, URLs externas incluidas.
  `03-oracle-cloud` está vacío (solo `.gitkeep`). Avisos sin tocar: `PENDIENTE` y `FORMATO` (perfil), y en
  GCP `CALLOUT` 🧭 ×10 y 🏁 ×2, a cotejar con su guía. Código intermedio para borrar:
  `scratchpad/cloud-validacion-1/`.
- **2026-10-04 · grupo A, `bases/01`, `04` y `05`.** Ninguno en producción. `bases/01-bases`: 3 enlaces
  en 3 archivos. `bases/04-apis-protocolos`: limpio, nada que corregir. `bases/05-bases-datos`: 60 enlaces
  en 44 archivos con `--corregir-fe0f`, y otros **41 que el verificador base no ve** porque el texto del
  enlace cruza un salto de línea (casilla nueva en §4); los encontró `controles-texto.py` y se corrigieron
  con un barrido aparte. En `controles-texto.py`, el slug deja de borrar el U+FE0F y el control de
  ancho no lo cuenta (4 líneas pasaban a 101). Los diffs de los `.md` solo insertan U+FE0F. Los tres dan
  0 errores y `verificar-corpus.sh` da «Los siete controles limpios». El mismo barrido en
  `arquitectura/01`–`04` no encontró nada del curso (solo 7 anclas en READMEs de `vendor/` de PHP en
  03-hexagonal, de terceros). Avisos sin tocar: `PENDIENTE` (falsos positivos), y en `bases/01` `CALLOUT`
  ⏱️ ×4 y `CAPAS` ×9. Código intermedio para borrar: `scratchpad/bases-validacion-1/` (logs y
  `fe0f_multilinea.py`).
- **2026-10-04 · grupo A, `arquitectura/01` a `04`.** Ninguno en producción (todo commiteado el
  03-10). `--corregir-fe0f`: 01-bases 7 enlaces en 6 archivos, 02-monolito 20 en 13, 03-hexagonal 16 en 13,
  04-microservicios 16 en 13; el diff solo inserta U+FE0F y los cuatro quedan con 0 errores. En
  `02-monolito/scripts/verificar_corpus.py` el slug pasa a conservar U+FE0F (`[^\w\- \ufe0f]`, cambio
  mínimo en vez de copiar `slug_github`): marcaba las 20 corregidas como rotas y vuelve a dar OK. Sin
  `ROTO`/`ANCLA`/`FUERA`. Avisos sin tocar: `PENDIENTE` son falsos positivos ("pagos pendientes",
  "independientes"); `FORMATO` y `ENCAB` en 02 y 03 son desajuste del perfil `repaso` con el formato de
  esos solucionarios y encabezados, no defectos. Mermaid no se validó (§3 no lo pide). Código intermedio
  para borrar: `scratchpad/arq-validacion-1/` (8 logs).
- **2026-10-04 · §1 cerrada.** Oskar instaló `@mermaid-js/mermaid-cli` 12.0.0 con Node 24.21.0 y npm
  11.19.0; Chrome 154.0.8037.57 presente en `~/.cache/puppeteer`; prueba de humo correcta. Código
  intermedio para borrar: `scratchpad/mmdc-humo-1/humo.mmd` y `humo.svg`. **Siguiente:** grupo 0.
- **2026-10-04 · creación.** Barrido inicial con `verificador_base.py`; cifras de §4 y §5. `--corregir-fe0f`
  probado sobre una copia de `frameworks/01-spring-boot` en el scratchpad (`prueba-fe0f-1/`), que
  queda para borrar.
