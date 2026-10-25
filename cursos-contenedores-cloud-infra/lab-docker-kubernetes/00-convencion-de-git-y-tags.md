# 🏷️ Convención de git y tags
## Laboratorio de contenedores y Kubernetes local

Documento de consulta. Todas las fases lo enlazan desde su bloque 🏷️ de cierre y ninguna lo vuelve a
explicar. No enseña git: fija cómo lo usa este curso, que tiene una particularidad que conviene
entender antes de la primera fase: **tu repositorio es el único que escribes**, y el `src/lab/` del
curso es la referencia contra la que te comparas, sin historia ni tags que tengas que seguir.

> **Cuándo se lee:** antes de la [Fase 00](00-el-ambiente.md), y cada vez que el bloque 🏷️ de cierre
> de una fase te mande aquí.
> 📝 **Fecha de verificación:** 03/10/2026, en macOS arm64, sobre un repositorio de prueba. Los
> comandos son de git y no cambian entre plataformas.

> 🔑 **La frase para memorizar:** un tag es un puntero a un commit. No ocupa espacio, no agrega
> overhead y se borra con `git tag -d`. La pregunta no es "¿vale la pena etiquetar esto?", es "¿por
> qué no?".

**Salto rápido:** [Tu repositorio y la referencia](#️-tu-repositorio-y-la-referencia) · [Commits](#️-commits) · [Tags de fase](#-tags-de-fase) · [Incidentes](#-los-incidentes-en-git) · [Apéndices](#-los-apéndices-que-dejan-archivos) · [Qué no entra](#-qué-no-entra-al-repositorio) · [Comandos](#-los-comandos-que-hacen-que-esto-sirva) · [Checklist](#-checklist-de-cierre-de-fase)

---

## 🗂️ Tu repositorio y la referencia

El curso construye **un solo proyecto**, `src/lab/`, que crece fase a fase: el Taskfile, los
archivos de kind, los contratos, los cinco servicios, los manifiestos, el chart, el patrimonio de
La Vecina. Tú lo construyes en **tu propio repositorio**, generando el código con los prompts del
curso y escribiendo a mano los manifiestos que las fases te piden escribir a mano.

```text
tu repositorio (mi-lab/)                 la carpeta del curso (solo lectura)
├── src/lab/ … lo que construyes         ├── las fases, los apéndices, el cuaderno
├── tus commits  fNN: …                  └── src/lab/ … la versión del autor, en su estado final
└── tus tags     fase-NN-<slug>
```

**Por qué no trabajar dentro del curso.** Si escribieras en la carpeta del curso, tus commits y los
cambios del autor se mezclarían en cada actualización, y perderías la referencia limpia contra la que
te comparas. El curso lo descargas o lo clonas una vez, aparte, y no escribes en él.

El `src/lab/` del curso está en su **estado final**: lo que quedó al cerrar la Fase 27. No trae una
copia por fase ni tags del autor: cada fase dice qué enciende, y en el chart cada interruptor
(`global.*.enabled` en `values.yaml`) lleva un comentario con la fase desde la que está encendido, así
que sabes qué parte de la referencia todavía no te toca. Los incidentes tampoco
necesitan tags: `task inc:break -- <ID>` los provoca sobre tu laboratorio y `task inc:fix -- <ID>`
los repara (los detalles, [abajo](#-los-incidentes-en-git)).

> 🧭 **Tu repositorio es tu bitácora; el `src/lab/` del curso es la regla contra la que te mides.**
> Ninguno de los dos sustituye al otro.

No hace falta remoto para el tuyo. Si lo tienes, recuerda que **los tags no viajan solos**:
`git push --tags`.

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

> ⚠️ **Volver a un tag te deja en `detached HEAD`.** Es normal: `git checkout fase-08-el-primer-despliegue`
> te pone a mirar ese estado sin estar en ninguna rama. Si vas a escribir desde ahí, crea una rama
> primero (`git switch -c wip/fase-08-intento-2`), con prefijo: una rama y un tag que se llaman igual
> vuelven ambiguo cualquier `git checkout`.

**Compararte con el autor.** Contra el `src/lab/` del curso, carpeta por carpeta, mirando solo lo que
la fase tocó. Para ver en qué se parece y en qué no tu `src/lab/` al suyo:

```bash
git diff --no-index --stat <curso>/src/lab/deploy <mi-lab>/src/lab/deploy
```

Que no coincidan no significa que el tuyo esté mal: el código generado varía de una corrida a otra,
la referencia ya trae lo de las fases que vienen, y lo que manda es que la suite de conformidad pase. Lo que sí debe coincidir son los nombres del
contrato: servicios, puertos, rutas, labels y tareas.

---

## 🩺 Los incidentes en git

Cada incidente de plataforma y de certificados (05–26) se provoca y se repara con una tarea, sobre
el laboratorio que tienes corriendo:

```bash
task inc:break -- 05     # aplica el cambio mínimo que produce el síntoma
task inc:fix -- 05       # lo revierte
```

Va al cluster `minimo` salvo que digas otro (`PROFILE=lab`, y `CLUSTER=` si en ese cluster corren los
valores de otro perfil). Los incidentes de ambiente (01–04 y 27) no se provocan: se reconocen.

**Leer la corrección.** El cambio mínimo de cada incidente está escrito dos veces: en una línea, en
su entrada del cuaderno, y en código, en `src/lab/scripts/incidents/inc.py`, que es lo que corren las
dos tareas. Ábrelos solo cuando ya lo hayas resuelto, o cuando hayas agotado las tres pistas.

**La otra forma de llegar.** Si prefieres provocarlo sin herramientas, la entrada del cuaderno
describe el cambio en una o dos líneas. Las dos formas están en el
[cuaderno de incidentes](cuaderno-incidentes.md#-cómo-se-trabaja-un-incidente).

**En tu propio repositorio**, si provocas un incidente para practicarlo, el commit lleva el prefijo
de la fase y el ID: `f08 inc05: …`. Con eso basta para encontrarlo después
(`git log --oneline --grep inc05`); no hace falta un tag por incidente.

---

## 📦 Los apéndices que dejan archivos

Los apéndices no llevan tag, salvo los tres que dejan archivos versionados en `src/lab/`:

| Apéndice | Tag | Qué deja |
|---|---|---|
| `a01` | `apendice-a01-laboratorio` | el Taskfile, los archivos de kind y los scripts |
| `a03` | `apendice-a03-contratos` | los contratos, la suite de conformidad y Swagger UI (los perfiles `conformance` y `docs` de `compose.yaml`) |
| `a16` | `apendice-a16-patrimonio` | Contingencia, el portal y la Braqui, y el perfil `legacy` de `compose.yaml` |

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

---

## 📈 Los comandos que hacen que esto sirva

```bash
git tag -l 'fase-*' -n1                                  # ¿dónde estoy?
git for-each-ref --sort=creatordate \
  --format='%(creatordate:short)  %(refname:short)' 'refs/tags/fase-*'   # cuándo cerré cada fase
git diff fase-07-el-cluster-local..fase-08-el-primer-despliegue --stat   # qué costó una fase
git checkout fase-07-el-cluster-local -- src/lab/deploy  # recuperar una carpeta de una fase anterior
git log --oneline --grep inc05                           # dónde practicaste un incidente
```

---

## ✅ Checklist de cierre de fase

- [ ] El checklist de validación de la fase, en verde y verificado a mano.
- [ ] La suite de conformidad del paso pasando contra el cluster.
- [ ] `git status` limpio: todo lo de la fase está commiteado.
- [ ] `git tag -a fase-NN-<slug> -m "…"` creado, con el checklist en el mensaje.
- [ ] Si la fase deja un apéndice con archivos (`a01`, `a03`, `a16`), su `apendice-…` también.

> **La señal de que quedó bien:** "vuelvo después de tres semanas, corro `git tag -l 'fase-*'`, y sé
> exactamente dónde me quedé y qué sigue — sin releer una sola línea del curso".
