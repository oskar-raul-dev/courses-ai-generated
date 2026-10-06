# 🏷️ Convención de git y tags
## Laboratorio de contenedores y Kubernetes local

Documento de consulta. Todas las fases lo enlazan desde su bloque 🏷️ de cierre y ninguna lo vuelve a
explicar. No enseña git: fija cómo lo usa este curso, que tiene una particularidad que conviene
entender antes de la primera fase. **Aquí hay dos repositorios y no uno**: el tuyo, donde construyes,
y el del curso, que es la referencia contra la que te comparas y de donde salen los incidentes.

> 📝 **Fecha de verificación:** 03/10/2026, en macOS arm64, sobre un repositorio de prueba. Los
> comandos son de git y no cambian entre plataformas.

**Salto rápido:** [Dos repositorios](#️-dos-repositorios-dos-papeles) · [Commits](#️-commits) · [Tags de fase](#-tags-de-fase) · [Incidentes](#-los-incidentes-en-git) · [Apéndices](#-los-apéndices-que-dejan-archivos) · [Qué no entra](#-qué-no-entra-al-repositorio)

---

## 🗂️ Dos repositorios, dos papeles

El curso construye **un solo proyecto**, `src/lab/`, que crece fase a fase: el Taskfile, los
archivos de kind, los contratos, los cinco servicios, los manifiestos, el chart, el patrimonio de
La Vecina. Tú lo construyes en **tu propio repositorio**, generando el código con los prompts del
curso y escribiendo a mano los manifiestos que las fases te piden escribir a mano.

```text
tu repositorio (mi-lab/)                 el repositorio del curso
├── src/lab/ … lo que construyes         ├── las fases, los apéndices, el cuaderno
├── tus commits  fNN: …                  ├── src/lab/ … la versión del autor
└── tus tags     fase-NN-<slug>          ├── sus tags  fase-NN-<slug>
                                         └── los pares inc/<ID>/<slug>-roto · -fix
```

**Por qué dos y no uno.** Si trabajaras dentro de un clon del curso, cada `git tag -a fase-08-…` que
te pide el cierre de una fase chocaría con el tag que el autor ya publicó con ese nombre, y cada
`git pull` te mezclaría su código con el tuyo. Separados, los nombres son los mismos en los dos
lados —y eso es lo útil—, pero cada repositorio tiene los suyos.

El del curso lo clonas una vez, en otra carpeta, y no escribes en él. Sirve para tres cosas:
comparar tu fase con la del autor, levantar el estado roto de un incidente, y leer la corrección de
un incidente como un `diff`.

> 🧭 **Tu repositorio es tu bitácora; el del curso es la regla contra la que te mides.** Ninguno de
> los dos sustituye al otro.

---

## ✍️ Commits

Con el prefijo de la fase, siempre, y el mensaje en español, como el resto de la prosa del curso:

```text
f08: despliega pricing en default con su Service
f08 ej17: provoca el selector que no coincide y lo diagnostica con describe
f08 inc05: El pod espera una imagen que el cluster nunca vio
```

Un commit por unidad de trabajo con sentido —una sección, un ejercicio, un incidente—, no uno por
archivo ni uno por fase entera. Y el mensaje dice **qué decidiste**, no qué archivo tocaste: cuando en
la [Fase 16](16-escalado-y-rollout.md) vuelvas a preguntarte por qué `inventory` tiene ese `limit`, `git log --oneline` tiene que
contestarte.

---

## 🏁 Tags de fase

**`fase-NN-<slug>`**, anotado, cuando la fase cierra: su checklist de validación en verde, la suite
de conformidad del paso pasando y `git status` limpio. El slug es el del nombre del archivo de la
fase, sin el número. El mensaje lleva el checklist, una línea por ítem:

```bash
git tag -a fase-08-el-primer-despliegue -m "F08 cerrada:
- pricing en default con su Deployment y su Service
- task conformance -- G0 pasando contra el cluster
- incidentes 05 y 06 provocados y diagnosticados"
```

`git tag -l 'fase-*' -n1` es el índice de tu avance, y `git show fase-08-el-primer-despliegue` te
devuelve, semanas después, qué diste por cerrado y cuándo.

**Compararte con el autor.** El repositorio del curso tiene un tag con el mismo nombre al final de
cada fase. Para ver en qué se parece y en qué no tu `src/lab/` al suyo:

```bash
git diff --no-index --stat <curso>/src/lab/deploy <mi-lab>/src/lab/deploy
```

Que no coincidan no significa que el tuyo esté mal: el código generado varía de una corrida a otra,
y lo que manda es que la suite de conformidad pase. Lo que sí debe coincidir son los nombres del
contrato: servicios, puertos, rutas, labels y tareas.

---

## 🩺 Los incidentes en git

Cada incidente de plataforma y de certificados tiene en el repositorio del curso un par de tags:

```text
inc/<ID>/<slug>-roto    el laboratorio en el estado que produce el síntoma
inc/<ID>/<slug>-fix     el mismo estado con la corrección mínima
```

El ID es el que el cuaderno ya reservó y el slug es el título, corto y en inglés:
`inc/05/image-never-loaded-roto`. Los incidentes de ambiente (01–04 y 27) no tienen tags, porque no
se provocan: se reconocen.

**Levantar el estado roto sin tocar tu trabajo.** En tu clon del curso, un *worktree* desacoplado
te da una carpeta aparte con el estado del tag, y tu rama principal ni se entera:

```bash
git worktree add --detach ../inc-05 inc/05/image-never-loaded-roto
# despliegas desde ../inc-05, diagnosticas, y al terminar:
git worktree remove ../inc-05
```

Si prefieres no usar *worktrees*, `git switch --detach inc/05/image-never-loaded-roto` hace lo mismo
en la carpeta del clon, y `git switch -` te devuelve a donde estabas.

**Leer la corrección.** El `git diff` entre los dos tags **es** la corrección, aislada del ruido de
la fase. Ábrelo solo cuando ya lo hayas resuelto, o cuando hayas agotado las tres pistas:

```bash
git diff inc/05/image-never-loaded-roto inc/05/image-never-loaded-fix
```

**La otra forma de llegar.** Si ya avanzaste y no quieres salir de tu laboratorio, el cuaderno ofrece
una tarea que aplica el cambio mínimo sobre lo que tienes corriendo y otra que lo revierte, y para
quien quiera provocarlo sin herramientas, el cambio descrito en una línea. Las tres formas están en
el [cuaderno de incidentes](cuaderno-incidentes.md#-cómo-se-trabaja-un-incidente).

**En tu propio repositorio**, si provocas un incidente para practicarlo, el commit lleva el prefijo
de la fase y el ID: `f08 inc05: …`. No crees tags `inc/` en tu repositorio: esos nombres son del
cuaderno.

---

## 📦 Los apéndices que dejan archivos

Los apéndices no llevan tag, salvo los tres que dejan archivos versionados en `src/lab/`:

| Apéndice | Tag | Qué deja |
|---|---|---|
| `a01` | `apendice-a01-laboratorio` | el Taskfile, los archivos de kind y los scripts |
| `a03` | `apendice-a03-contratos` | los contratos, la suite de conformidad y Swagger UI |
| `a16` | `apendice-a16-patrimonio` | Contingencia, el portal y la Braqui |

Se crean igual que los de fase, anotados y con lo que dejan en el mensaje.

---

## 🧾 Qué no entra al repositorio

Un `.gitignore` corto, con lo de siempre y tres cosas propias de este laboratorio:

- **Los entornos de Python** (`.venv/`) de los scripts: se recrean solos con la tarea que los usa, y
  el `requirements.txt` sí se versiona.
- **Las claves privadas** de la CA de laboratorio y de los certificados que firmas con ella. El
  certificado público de la CA puede ir; la clave, nunca, aunque sea de juguete: el hábito es lo que
  se entrena.
- **Los crudos de las mediciones** que pesen más que su resumen. El resumen va a `BENCHMARKS.md`, y el
  crudo se regenera con la tarea de medición.

> ⚠️ **Los secretos, nunca**, tampoco "de laboratorio": ningún `Secret` con valores reales, ningún
> token de un registry. La única excepción es deliberada y tiene dueño: el patrimonio de La Vecina
> trae sus mañas tal como las dejó la historia, y [su apéndice](a16-el-patrimonio.md#-las-mañas-a-propósito)
> dice cuáles son. Si un secreto tuyo ya
> entró al historial, borrarlo en un commit nuevo no lo saca: sigue ahí, en el commit anterior.
