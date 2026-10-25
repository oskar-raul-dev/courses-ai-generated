# 🗑️ Plan de cierre del curso publicado (desechable)
## Laboratorio de contenedores y Kubernetes local

> **Qué es:** la hoja de ruta de las tandas C0–C4 que cierran los accionables de D45 sobre el curso
> ya publicado. Desechable: no se cita desde el curso ni desde los documentos estables de `prompts/`,
> y se borra cuando C4 cierre (con permiso del autor). Lo que deba sobrevivir pasa antes a
> `pendientes-a-futuro.md`, a la propuesta de fases §12 o a `hallazgos.md`.
> **Abierto:** 19/10/2026. **Estado:** C0 (19/10), C1 (21/10), C2 (24/10) y C2-bis (24/10) cerradas, esperando la
> revisión del autor. Orden acordado el 24/10: primero O1 y O2 de C4 con el laboratorio arriba, después bajarlo, C3
> (Podman 6.1.3 ya instalado, Docker Desktop cerrado) y el resto de C4.

---

## 🧭 Reglas de todas las tandas

1. **Una tanda a la vez, y se para al cerrarla** para que el autor la revise. Cada tanda empieza con
   su paso 1: las preguntas que cambian lo que se hace, juntas y con la opción recomendada primero.
2. **Git lo maneja el autor.** Ni commits ni `git add`; para borrar o mover, `rm` y `mv`. Al cerrar
   cada tanda se dan los `git add` y el mensaje de una línea.
3. **Docker Desktop lo está usando el autor.** C0 no lo toca. C1 y C2 lo usan solo cuando el autor lo
   deja libre; C3 lo necesita cerrado. Nunca se borran contenedores, imágenes ni volúmenes ajenos al
   curso.
4. **Código y pruebas en `zz-code/`**, un directorio por tanda (`python3 zz-code/nuevo.py
   lab-docker-kubernetes`), con su README de corrida. Hallazgos desde **H271** en
   `verificacion-de-laboratorio/hallazgos.md`, con su log en `logs/`.
5. **Al cerrar cada tanda:** `verificar-corpus.py` en 0/0 en los dos modos, y la bitácora de abajo al
   día.

---

## 0️⃣ C0 · Sin máquina: los tags, el repositorio padre y la versión del nodo

### El problema

El curso le promete al lector un **repositorio padre** que no existe: "el repositorio del curso",
clonado aparte, con los tags `fase-NN-<slug>` del autor para compararse y los pares
`inc/<ID>/<slug>-roto|-fix` de los 22 incidentes de plataforma (05–26) para levantarlos y leer su
corrección como un `diff`. El repositorio de cursos tiene **0 tags**, y `src/lab/` está en su estado
final, sin historia fase a fase. La nota 📝 que agregó D45 en la convención de git y en el README es
un parche: C0 la reemplaza por el texto definitivo.

Lo que **sí** existe y alcanza: `task inc:break|fix -- <ID>` (`src/lab/scripts/incidents/inc.py`)
provoca y repara los 22 incidentes sin tags, y cada fase ya dice qué enciende y desde cuándo, así que
`src/lab/` final sirve de referencia. Los tags `fase-NN-<slug>` **del lector**, en su propio
repositorio, no cambian: esos sí existen, porque los crea él.

### Lo que hace C0

- **C0.1 · Quitar el repositorio padre.** El curso pasa a tener **un repositorio, el tuyo**, y una
  referencia de lectura: `src/lab/` del curso. Se reescriben la §4.7 de `00-el-ambiente.md` ("Tu
  repositorio y el del curso"), el bloque "Dos repositorios" del README y las secciones de la
  convención de git que lo suponen (el diagrama de dos columnas, "Por qué dos y no uno", "Compararte
  con el autor", "Los incidentes en git", el `diff` de la línea 196).
- **C0.2 · Arreglar los tags de incidente.** Los pares `inc/…` dejan de ser la forma canónica. En el
  cuaderno, de las "tres formas de llegar al sistema roto" queda la tarea como canónica y la forma a
  mano; la corrección se lee en la entrada del incidente y en `inc.py`, no en un `git diff`. Las 22
  entradas del cuaderno que nombran su par de tags lo cambian por su `task inc:break -- <ID>`. En las
  fases, los cierres que listan "Y los pares de los incidentes…" (F08, F09, F10, F11, F12, F15, F16,
  F19, F20) se quedan con los tags del lector y los commits.
- **C0.3 · Quitar la nota de D45** en la convención de git y en el README, que ya no hace falta.
- **C0.4 · Lo que lo menciona en `prompts/`.** El contrato del cluster, el formato del cuaderno, la
  guía, los prompts de fase y la propuesta de fases (la fila de D45 y la decisión nueva, abajo) se
  alinean, para que una sesión futura no vuelva a escribir el repositorio padre.
- **C0.5 · A5, la versión del nodo de kind.** Leer las notas de versión de Envoy Gateway y de kind.
  Si ninguna versión soporta Kubernetes 1.37, se anota con la fecha y D32 sigue; si alguna lo soporta,
  se anota y C1 empieza con D32 reabierta (eso **no** cambia el curso en C0).

### El inventario (líneas al abrir C0, 19/10/2026)

Salen de buscar `inc/NN/`, `<ID>/<slug>`, "repositorio del curso", "clon del curso", "el del curso",
"del autor" y "Desde el tag". Las de "del autor" se revisan una por una: muchas son *"no verificado
por el autor"* y se quedan.

| Documento | Líneas |
|---|---|
| `00-convencion-de-git-y-tags.md` | 7, 30–34, 37, 43, 46, 49, 98, 113–140, 196 |
| `00-el-ambiente.md` | 230, 412–430 |
| `README.md` | 102–104 |
| `cuaderno-incidentes.md` | 48–49 y 22 entradas (388 … 1726) |
| F08 · F09 · F10 · F11 · F12 | 415, 887–888 · 733–734 · 846 · 739–740 · 945 |
| F15 · F16 · F19 · F20 | 938–939 · 807 · 199, 980–982 · 718 |
| A revisar ("del autor") | F07:247, F21:287 y 342, `a01`:442, 620 y 769, `a14`:111, `BENCHMARKS.md`:71 |
| `prompts/` | contrato 319; formato del cuaderno 142–162; guía 577 y 666; prompts de fase 64 y 562; propuesta 918 y 1082; `pendientes-a-futuro.md` 13, 101 y 113 |

### Las preguntas del paso 1 de C0

1. **¿Se retira el repositorio padre para siempre, o solo hasta que existan los tags?** Recomendado:
   **para siempre**. Un solo repositorio es más simple para el lector, `inc.py` ya da el estado roto
   exacto, y mantener 28 tags más 44 de incidente sincronizados con cada edición del curso es una
   deuda permanente. Con esto, **A1 se retira** de los accionables y O5 queda en crear el repositorio
   público, sin tags.
2. **¿El `diff` de la corrección se conserva de otra forma?** Recomendado: **no**: la entrada del
   cuaderno ya describe el cambio mínimo y `inc.py` lo tiene en código. Alternativa: que `task
   inc:diff -- <ID>` muestre el cambio (toca el Taskfile e `inc.py`, y pide probarlo en C1).
3. **¿La decisión va como D46?** Recomendado: **sí**, en la propuesta de fases §12, con D45 apuntando
   a ella.

### Cómo se cierra C0

`verificar-corpus.py` en 0/0 en los dos modos; `grep` sin resultados para `inc/[0-9]{2}/`,
"repositorio del curso", "clon del curso" y "el del curso" fuera de `prompts/` (salvo lo que se decida
dejar, anotado aquí); la tabla de accionables de `pendientes-a-futuro.md` sin A1 si así se decide; y
A5 anotado con su fecha.

---

## 🐳 C1–C4 · Las tandas con máquina

El detalle está en `pendientes-a-futuro.md` § Accionables, y C0 puede cambiarlo (sin A1, C1 y C2 ya
no producen tags de referencia: la pasada se hace igual, en un repositorio propio, como lector).

| Tanda | Qué | Docker Desktop | Lo pone el autor |
|---|---|---|---|
| **C1** | A2 (B-00 de Docker) y A3 de F00 a F07 | libre y **dedicado** | dejarlo libre |
| **C2** | A3 de F08 a F27 y los apéndices 🔥 | libre | dejarlo libre |
| **C3** | A4, el perfil de Podman, y B-00 de Podman | **cerrado**, y al final abierto con Podman | instalar Podman, cerrar Docker Desktop, decidir O3 |
| **C4** | O1, O2, O5 | — | todo |

---

## 🧭 Recomendaciones por defecto

Si el autor contesta "default" al paso 1 de una tanda, valen estas. Cada una se registra en la
bitácora con la palabra **por defecto**, y las que cambian el curso, también en la propuesta de
fases §12.

| Tanda | Pregunta | Por defecto | Por qué |
|---|---|---|---|
| C0 | ¿El repositorio padre se retira para siempre o hasta que existan los tags? | **Para siempre**; A1 sale de los accionables y O5 queda en crear el repositorio público sin tags | `inc.py` ya da el estado roto exacto, y 72 tags al día con cada edición son una deuda permanente |
| C0 | ¿Se conserva el `diff` de la corrección con un `task inc:diff`? | **No** | la entrada del cuaderno y `inc.py` ya dicen el cambio mínimo; una tarea nueva pide probarla en C1 |
| C0 | ¿La decisión va como D46? | **Sí**, en la propuesta §12, y D45 apunta a ella | el registro de decisiones es la fuente de verdad |
| C0 | ¿Qué pasa con las líneas de "del autor" que no hablan del repositorio padre? | **Se quedan** (*"no verificado por el autor"*, mediciones del autor) | no prometen nada que no exista |
| C0 | Si A5 encuentra una versión de Envoy Gateway que soporte Kubernetes 1.37 | **Se anota y no se cambia nada en C0**; C1 empieza con D32 reabierta | cambiar el nodo pide reverificar el camino base, y eso es máquina |
| C1 | ¿B-00 con cuántas repeticiones y qué perfiles? | **La misma forma que la publicada en `a01`**: perfiles `minimo`, `lab` y `legacy`, 3 corridas por celda con el cluster creado desde cero y la VM en 4 GiB. En C1, la columna de Docker; la de Podman, en C3 | la regla 3 de la pasada: una cifra se compara contra su variación, y solo con las mismas condiciones |
| C1 | Si B-00 sale fuera de la variación publicada | **Se corrige la cifra** en `BENCHMARKS.md`, `a01`, contrato §5 y F17 §5.5, con la máquina declarada | H155 decía que la medición tenía el Kubernetes de Docker Desktop encendido |
| C1 | ¿Dónde vive el repositorio de la pasada? | **`zz-code/<id>/mi-lab/`**, nuevo, con la copia inicial que pide `00-el-ambiente` §4.7 | la regla 1 de la pasada: como lector, sin copiar de `src/lab/` |
| C1–C2 | Si un comando del curso da una salida distinta pero equivalente | **Se deja la publicada** y se anota como hallazgo sin corrección | la regla 3: el número no se pisa dentro de la variación |
| C1–C2 | Si un comando del curso falla | **Se corrige el documento** (y `src/lab/` si hace falta), con su hallazgo | es justo lo que la pasada busca |
| C2 | ¿Los apéndices 🔥 entran todos? | **Todos los que no pidan cuenta de nube ni de pago**; los que la pidan quedan anotados como no ejecutados | el curso no despliega en una nube de pago |
| C2 | Al terminar, ¿se baja el laboratorio? | **No**, se deja arriba para O1 (la CA en el navegador) y el autor decide cuándo bajarlo | O1 necesita la puerta en 8443 |
| C3 | ¿Qué versión de Podman? | **La que fija `a01`**; si el instalador oficial ya no la ofrece, la estable del día, anotada como hallazgo | D17: la estable donde no hay LTS |
| C3 | ¿La máquina de Podman se queda al terminar? (O3) | **Se detiene, no se borra**, y el autor decide | borrarla es irreversible y es su máquina |
| C4 | ¿La CA se quita antes o después de bajar el laboratorio? | **Después de O1 y antes de bajarlo**, con el paso 4 de `a01` | así O1 y O2 se prueban sobre el mismo estado |

---

## ✅ Checklist de seguimiento

Se marca al cerrar cada punto, con la fecha en la bitácora. Una tanda está cerrada cuando todas sus
casillas lo están y el autor la revisó.

### C0 · Sin máquina

- [x] Paso 1 contestado (o "default") y registrado en la bitácora
- [x] D46 escrita en la propuesta de fases §12; D45 apunta a ella
- [x] C0.1 · `00-el-ambiente.md` §4.7 reescrita: un repositorio, el tuyo
- [x] C0.1 · `README.md`, bloque "Dos repositorios"
- [x] C0.1 · `00-convencion-de-git-y-tags.md`: diagrama, "Por qué dos y no uno", "Compararte con el
      autor", "Los incidentes en git" y el `diff` de la línea 196
- [x] C0.2 · `cuaderno-incidentes.md`: "Tres formas de llegar" y las 22 entradas
- [x] C0.2 · Cierres de F08, F09, F10, F11, F12, F15, F16, F19 y F20 sin pares `inc/`
- [x] C0.2 · Revisadas una por una las líneas de "del autor" (F07, F21, `a01`, `a14`, `BENCHMARKS.md`)
- [x] C0.3 · Nota 📝 de D45 retirada de la convención de git y del README
- [x] C0.4 · `prompts/` alineado: contrato, formato del cuaderno, guía, prompts de fase, propuesta
- [x] C0.4 · `pendientes-a-futuro.md`: A1 retirada (si así se decidió) y O5 ajustada
- [x] C0.5 · A5 consultada y anotada con su fecha
- [x] `grep` de cierre sin resultados fuera de `prompts/`
- [x] `verificar-corpus.py` en 0/0, en los dos modos
- [x] `git add` y mensaje entregados al autor (commit 194ddc1)
- [ ] Revisión del autor

### C1 · Docker Desktop libre y dedicado

- [x] El autor deja Docker Desktop libre y sin otras cargas (contenedor ajeno detenido, VM en 4 GiB
      declarados en `settings-store.json`)
- [x] Paso 1 contestado y registrado
- [x] Directorio de `zz-code/` creado con `nuevo.py` y su README (las diez secciones)
- [x] A2 · B-00 de Docker medido (`minimo`, `lab`, `legacy`; 3 corridas por celda; VM de 4 GiB), con su log
- [x] A2 · Cifras corregidas o confirmadas: `minimo` y `lab` dentro de la variación (se dejan, con la
      reconfirmación en la cabecera); `legacy` corregido en `a01` con las dos fechas. H155 cerrado en su
      parte principal; su sexta entrega (F17 §5.5) queda para C2
- [x] A3 · F00 + `a01` (lo de Docker; las tres líneas de Podman son A4)
- [x] A3 · F01–F02 + `a16`, el patrimonio y los cinco servicios de G0 generados con los prompts de `a03`
- [x] A3 · F03–F05 con Docker (B-05 y la mitad de Podman de la F05 quedan para C3)
- [x] A3 · F06–F07, los dos clusters de kind, B-04 y B-07, y el bloque opcional del Kubernetes de
      Docker Desktop encendido, medido y **borrado de verdad**
- [x] Tags `fase-00` a `fase-07` en el repositorio de la pasada
- [x] Hallazgos **H271–H288** escritos, con sus correcciones pasadas al curso
- [x] `task cluster:down` y `task legacy:down`; inventario de la máquina comparado con el de apertura
- [x] `verificar-corpus.py` en 0/0, en los dos modos
- [x] `git add` y mensaje entregados al autor (commits 194ddc1 y 74ee313)
- [ ] Revisión del autor

### C2 · Docker Desktop libre

- [x] Paso 1 contestado y registrado (**por defecto**)
- [x] A3 · F08–F16, incidentes 05–17, B-12 y B-16 — **hechas el 22/10/2026** (F16: G5, rollout, HPA, B-16 dos veces e incidentes 16–17); quedan la F10 §8 y la F14 §5.5 en el cluster `lab`, que sigue arriba
- [x] A3 · F17–F18, la observabilidad pieza por pieza — **22/10/2026**; la sexta entrega de B-00 remedida (H326)
- [x] A3 · F19 por terminal: `security verify-cert` y `curl` contra 8443 — **22/10/2026** (H332), con los incidentes 18–24
- [x] A3 · F20–F21, incidentes 18–26 y k9s — **23/10/2026** (H335, H338)
- [x] A3 · F22–F26, caos, B-23, la saga, la coreografía, el outbox y NATS — **23–24/10/2026** (H348, H354, H356); sin hacer: la F24 §4 (Contingencia en compose)
- [x] A3 · F27, el proyecto final con su rúbrica — **24/10/2026**: `notify` cumple los siete criterios y el de salida (H358, H359)
- [x] A3 · Apéndices 🔥 (`a06`–`a15`), cada uno instalado y retirado — **24/10/2026** (H360–H370); `a08` en parte: la nativa no entra en 3,8 GiB
- [x] Tags `fase-08` a `fase-27` en el repositorio de la pasada, más `proyecto-1…7` y `apendices`
- [x] `diff` del `src/lab/` de la pasada contra el del curso: 227 entradas, agrupadas en H371 (ninguna funcional fuera de lo generado)
- [x] Marcas *"no verificado por el autor"* quitadas solo donde se corrió: **ninguna** (todas hablan de Windows, Linux, Podman, el incidente 27 o un ejercicio no hecho)
- [x] Laboratorio arriba para O1 (G13, NATS, observabilidad y caos apagados)
- [x] `verificar-corpus.py` en 0/0 en los dos modos; `git add` y mensaje entregados
- [ ] Revisión del autor

### C2-bis · Lo que C2 dejó pendiente, con el cluster `lab` arriba

- [x] Paso 1 contestado (**por defecto**): la nativa de `a08` y las apuestas de la F15 §7 siguen no ejecutadas
- [x] Cluster `lab` y `lab-registry` arrancados de nuevo; 27 pods listos, G13 de `inventory` 15/15
- [x] F10 §8, el proxy en un worker (H372)
- [x] F16 ejercicio 22, el PDB con una y dos réplicas; enunciado corregido (H373)
- [x] F24 §4.1–§4.3, Contingencia en compose (H374), y el patrimonio abajo otra vez
- [x] `verificar-corpus.py` en 0/0 en los dos modos; `git add` y mensaje entregados
- [ ] Revisión del autor

### C3 · Docker Desktop cerrado

- [x] El autor instala Podman con el instalador oficial y cierra Docker Desktop (Podman 6.1.3 y Podman Desktop 1.29.3, los de `a01`)
- [x] Paso 1 contestado y registrado
- [x] A4 · `podman machine init` con 4 GiB, según `a01` — **24/10/2026**: libkrun, 3.885 MiB útiles; adentro corre Podman 6.1.4 (H379)
- [x] A4 · El cambio de motor de F00 y F05 (`task engine:*`): con Podman solo y con los dos (H391)
- [x] A4 · B-05 en la VM de Podman (H382: reproduce salvo la VM recién arrancada, nota con las dos fechas). B-04 no se corre: solo publica Docker
- [x] A2 · B-00 de Podman, con las mismas condiciones que en C1 — `minimo` y `legacy` reproducen; `lab` corregida (H385, H386)
- [x] A4 · Los dos clusters de kind con Podman y `task images:load` — F05 §4 y §5.1–§5.3 literales, §5.5 corregida (H380, H381); `lab` con 5 imágenes en los 3 nodos
- [x] A4 · F03, las notas 🦭 (H383)
- [x] A4 · F07 §6 y §8, B-07 con kind, k3d y minikube (H384: minikube corregido a 459 MiB)
- [x] A4 · B-12 con Podman y `task test:pricing DB=postgres` (H387–H389: tarea, F12, `main_test.go` y prompt de G3 corregidos)
- [x] El autor vuelve a abrir Docker Desktop (la máquina de Podman ya está detenida); pidió contraseña (H390)
- [x] Dos motores · F00 §4.6: el aviso del socket al arrancar la máquina y el de `engine:use` (H391)
- [x] Dos motores · F05 §9: el choque del puerto 8080, y el contexto del primer cluster que kind borra (H392)
- [x] Dos motores · F03 §5.5: `docker save` → `podman load` → `pricing` contesta en 18080 (H393)
- [x] Dos motores · el cambio de `main_test.go` probado con Docker (Ryuk activo, sin contenedores sobrantes; H394)
- [x] Recursos del curso borrados en los dos motores, por nombre (ninguna imagen base); Docker igual que al abrir
- [x] Hallazgos H379–H394 trasladados a `verificacion-de-laboratorio/hallazgos.md` (sección C3, con el estado de la máquina)
- [x] Marcas de Podman quitadas donde se corrió (F12, `a01` Ryuk, B-12); las que quedan son de Windows o Linux
- [x] Máquina de Podman detenida, con 21 imágenes base adentro (5,9 GB)
- [x] O3 decidida por el autor: **conserva la máquina** y vacía él mismo imágenes y contenedores — hecho: 0 imágenes, contenedores y volúmenes; máquina detenida
- [x] Por defecto: H382 (la celda de B-05 se queda) y H288 (el arnés borra la red `b07`; probado)
- [x] `verificar-corpus.py` en 0/0 en los dos modos; `git add` y mensaje entregados (commit 843cd70)
- [ ] Revisión del autor

### C4 · El autor

- [x] O1 · La CA en el navegador, sin advertencias, con la puerta en 8443 (H376)
- [x] O2 · CA quitada con el paso 4 de `a01`, y probada la variante del llavero del sistema (H377)
- [x] Laboratorio bajado (`task cluster:down`, `task legacy:down`): cluster `lab`, `lab-registry` (H378) y las 61 etiquetas `lab/*`; quedan los volúmenes del patrimonio y las bases bajadas, a decisión del autor
- [ ] O5 · Repositorio público creado sin `prompts/`
- [x] Lo que deba sobrevivir, pasado a `pendientes-a-futuro.md`: O4 (Windows y Linux), O5 y A5 (Envoy Gateway 1.10, prevista el 29/10/2026) siguen ahí; A2, A3, A4, O1, O2 y O3 tachadas
- [ ] Este plan borrado, con permiso del autor

---

## 📓 Bitácora

| Fecha | Tanda | Qué pasó |
|---|---|---|
| 19/10/2026 | — | Plan abierto. C0 lista para su paso 1. |
| 19/10/2026 | — | Recomendaciones por defecto y checklist de seguimiento agregados. |
| 19/10/2026 | C0 | Paso 1: "default" (las tres preguntas **por defecto**). D46 registrada. Directorio `zz-code/lab-docker-kubernetes-20261019-9abb/` (script del cuaderno: 22 entradas, 0 `inc/NN/` restantes). |
| 19/10/2026 | C0 | C0.1–C0.4 hechas: convención de git (sección "Tu repositorio y la referencia" e incidentes con `task inc:break\|fix`), `00-el-ambiente` §4.7, README, `0-ESTRUCTURA`, cuaderno ("Dos formas de llegar"), cierres de nueve fases, contrato §8, formato del cuaderno §6–§7, propuesta, A1 retirada. También el docstring de `src/lab/scripts/incidents/inc.py`. Las siete líneas de "del autor" se quedan (máquina y mediciones del autor). Corregido al escribir: el chart no apaga lo que no llegó; sus interruptores están encendidos y el comentario dice desde qué fase. |
| 19/10/2026 | C0 | Cierre: `grep` limpio fuera de `prompts/` (quedan "el `src/lab/` del curso" en `00-el-ambiente` y una fila de B-04, legítimas) y verificador 0/0 en los dos modos. Falta la revisión del autor. |
| 19/10/2026 | C0 | C0.5: ninguna versión publicada de Envoy Gateway soporta Kubernetes 1.37 (solo `latest`; la 1.10, prevista el 29/10/2026). D32 sigue. |
| 20/10/2026 | C1 | Paso 1: el autor libera Docker Desktop y baja la VM a 4 GiB; alcance, C1 completa. Directorio `zz-code/lab-docker-kubernetes-20261020-1691/`, con `b00/lab/` (copia para medir) y `mi-lab/` (el repositorio de la pasada, como lector). |
| 20/10/2026 | C1 | A2: B-00 de Docker en los tres perfiles. La primera corrida de `minimo` murió porque Docker Desktop se reinició encima (el autor aplicando los 4 GiB) y dejó el cluster huérfano (H275); relanzada. `minimo` y `lab` reproducen dentro del 1 % (H271); `legacy` fuera, **corregido por decisión del autor** con las dos fechas (H272). H155 cerrado en su parte principal (H273). |
| 20/10/2026 | C1 | A3, F00–F04. Los cinco servicios de G0 generados con los prompts de `a03`: suite G0 en 5/0 a la primera. Correcciones al curso: `engine.py` (H276), `compose:up`/`compose:down` sin nombrar servicios (**H277**, que rompía la F02 y la F03), la procedencia del `compose.yaml` (H278), el `CMD` en forma JSON en `a03` (**H279**, que desarmaba la rotura de la F03), el andamio ESM de Nest (H280) y dos versiones de `a01` (H281). B-04: los tamaños reproducen al 0,1 MB (270,8 contra 270,7 MB), los builds en frío no comparan (H283). El matiz del `.dockerignore` (H284). |
| 21/10/2026 | C1 | A3, F05–F07. B-07: versiones exactas y tiempos clavados, pero la memoria de kind bajó a 502 MiB y **una conclusión de la F07 §8 se cayó**; corregida la tabla y el párrafo por decisión del autor (H285), con `BENCHMARKS.md` e `INSTINTOS.md` al día y la apuesta de la §7 anotada sin reescribir. El Kubernetes de Docker Desktop, encendido y apagado con permiso: `disabled` no lo apaga ni tras reiniciar Docker Desktop entero (H286). Nota de método sobre la línea base de la VM (H287) y la red que deja minikube (H288). |
| 21/10/2026 | C1 | Cierre: clusters y compose abajo, inventario de la máquina igual al de apertura (salvo lo del curso que se deja a propósito, anotado en `hallazgos.md`), Kubernetes de Docker Desktop devuelto a `false` y borrado, y verificador en 0/0 en los dos modos. Falta la revisión del autor. |
| 21/10/2026 | C2 | Paso 1: **por defecto** (los apéndices 🔥 que no pidan cuenta de pago; el laboratorio se deja arriba para O1). Directorio `zz-code/lab-docker-kubernetes-20261021-e349/`, con el `mi-lab/` de C1 traído como repositorio de la pasada (8 commits y 8 tags al abrir). |
| 21/10/2026 | C2 | A3, F08–F12. El hallazgo de fondo es sistémico: **`src/lab/` se publicó en su estado final**, y las fases anteriores a un cambio no corren con él. Cuatro caras, todas corregidas y reverificadas: `STEP_TAGS` (**H289**), `task deploy` antes del chart (**H292**), `deploy/incidents/` fuera de la copia inicial (**H293**) y el `Secret` de la F11 que el patrimonio de la F10 necesita (**H295**). Lo demás reprodujo: G1 en los cinco servicios a la primera, G2 y G3 también, el hash del ReplicaSet, la regla de iptables, las dos páginas de Chrome carácter por carácter, el `SQLSTATE 42P01` y el base64 del `Secret` rotado. B-12 remedido: los absolutos bajan a la mitad y **la proporción da 2,3x, idéntica** (H300, las dos fechas en `BENCHMARKS.md`). También H290, H291, H294, H296–H299 y H301. |
| 21/10/2026 | C2 | A3, F13–F15. **F13**: el chart paraguas escrito desde la fase (lab-common, cinco subcharts, tres perfiles, migraciones y seed como hooks) y `task chart:compare` dando **las 117 diferencias en las 14 clases publicadas, número por número**. Correcciones: las labels que las fases no mostraban y la mudanza necesita para borrar por selector (**H302**, en F09–F12), el `Deployment` de la F12 al pasar a Postgres (H303), el namespace de observabilidad que `task deploy` aplica antes de que exista (**H304**), el ambiente de QA que el `delete` de la §5.7 se lleva (H305) y la bandera de la F14 que ya trae el Taskfile (H306). **F14**: sin un solo fallo del documento —el esquema de valores, el rollback, los tres perfiles, la segunda cadena y la superposición de rutas, todo literal— salvo dos scripts del autor que no están en el repositorio (H309) y la memoria de la segunda cadena, medida con el patrimonio encima (H308, la cifra publicada se deja). **F15**: G4 en los cuatro backends a la primera, las sondas y los recursos medidos con `crictl stats` (los mismos `requests`/`limits` del curso, y los 576 MiB de la cuota idénticos), el límite de CPU 42 veces más lento, y los incidentes 12–15 con su síntoma publicado. Correcciones: los tres valores distintos de la cuota (H311) y Contingencia, que ya nace `Burstable` (H312). |
| 22/10/2026 | C2 | A3, F16. G5 a la primera en los cinco servicios (suite en el cluster), la carrera de la F12 cerrada (5 de 5), la página vendiendo, el rollout con `preStop` en 0 peticiones perdidas, el HPA a los 31 s. Cluster `lab` (3 nodos) arriba, sistema desplegado sin HPA. Correcciones al curso: B-16 remedido dos veces (el empeoramiento de `catalog` con tres réplicas **no se repitió**, **H320**), §4/§9 (el `OOMKilled` con 64 MiB no reapareció, el efecto sí), `bench/b16/rate.js` en §8.1 (**H315**), dónde viven las piezas (H316), `inc:break -- 17` que no rompía nada sobre un metrics-server parchado (**H319**, también en `src/lab/` publicado). Error propio: `php-fpm` sin `resources` en mi chart de la F15, tapado por el `LimitRange` (**H314**, corrige la explicación del H311). El commit y el tag `fase-16-…` de la pasada los frenó el clasificador: los hace el autor. |
| 22/10/2026 | C2 | A3, F17–F19. **F17**: G6 a la primera; los doce blancos; el tablero a 3/s reproduce (p95 de `pricing` 4,75 ms idéntico); APCu 0 contra 200; la autopsia gana con ×184 (publicado ×228). **La sexta entrega de B-00, remedida sin el Kubernetes de Docker Desktop: Grafana 269 (260–312) y 347 a los 20 min, fuera de la variación publicada**; corregida con las dos fechas en F17 §8 y `a01`, con la columna de la VM nueva; **H155 cerrado entero** (H326). Hallazgo de fondo: tras pasar a `minimo`, `task obs:on\|off` redespliega con `lab` (**H325**, corregido en F17 y F18). **F18**: G7 a la primera; costo y autopsia reproducen (5.879 líneas en 10 min contra 5.853; 4.850 flujos y 22–23 % perdido). **F19**: la renovación con 2.364 peticiones y 0 fallos; G8 a la primera; la trampa del kubelet reproducida; `security verify-cert` y `curl` sin `--cacert` por el llavero (H332). **H334**: el incidente 24 no rompía tras la §5.7 y su `fix` dejaba el `deploy` colgado; `registry:untrust` y `registry:forget` corregidos, ciclo probado. También H321–H324, H327–H331, H333. |
| 23/10/2026 | C2 | A3, F20–F24. **F20**: endurecimiento y políticas reproducen (la tabla de alcance idéntica); H335 (`bootstrap/cache` de `catalog` con la raíz de solo lectura). **F21**: k9s verificado por fin, con una terminal emulada (H338). **F22**: G9 y el generador a la primera; los números de la cascada, los reintentos y el circuito reproducen. **F23**: G10 en los cuatro a la primera; B-23 remedido (lo determinista igual, `service+age` y la réplica nueva varían: segunda fecha en `BENCHMARKS.md`, H346); Tempo caído tumba a `catalog`, idéntico. **F24**: G11 a la primera, y **H348**: una cancelación que vence su plazo pero se hace dejaba la saga en `COMPENSATING` para siempre; corregido en la pasada, en el `LoanSaga` publicado, en el prompt de G11 y en la F24. **A las ~13:55 alguien detuvo todos los contenedores** (también el ajeno `gfapp-dev-db-1`; la VM no se reinició, H350): la sesión paró y preguntó. Hallazgos candidatos hasta H350. |
| 23/10/2026 (noche) | C2 | A3, F25, con el motor libre (el autor detuvo `ev-lab`). Al volver, el release quedó en `pending-upgrade` por el deploy cortado (H351, `a02`) y `kubectl wait` sale antes de tiempo (H352). `LOAN-000058` terminó `COMPENSATED`: H348, 4/4. **F25**: G12 en los dos; Valkey 28/30 con `kill 1` y 39 órdenes con 9 repetidas en el rollout, NATS 30/30 en los dos y 10 pendientes 60 s en cero en 0,1 s, como el curso. **H354**: el id de `replenish` de la pasada chocaba con dos réplicas y el rechazo tumbaba el proceso (prompt de G12). **H356**: la suite de G12 fallaba siempre la primera vez (Hurl con una sola coincidencia), corregida y probada en una droguería virgen. H353 y H355: el back-off y la readiness explican las cifras de perdidos. Hallazgos candidatos hasta H356. |
| 24/10/2026 | C2 | A3, F26, F27 y los apéndices; cierre. **F26**: las tres roturas de G12 reproducen (la de inventory en las tres corridas, H357); G13 a la primera, cero con G13, las dos defensas a mano idénticas y la apuesta 4 con cero huérfanas. **F27**: `notify` en Go, los siete criterios y el de salida; H358 (`obs:on` con el perfil) y H359 (el `consumer rm` que faltaba). **Apéndices**: H360–H370; H361 (el digest de Buildah ya no existe en quay; las otras 30 imágenes de `a01` sí), H366 (la `Application` de `a11` sin `CreateNamespace`), H368 (`DROP … WITH (FORCE)` y el contexto que `kind delete` borra); `a08` sin la nativa. Diff de `src/lab/` en H371. Hallazgos H289–H371 trasladados a `verificacion-de-laboratorio/hallazgos.md` (sección C2, con el estado de la máquina). `verificar-corpus.py` 0/0 en los dos modos. El laboratorio queda arriba para O1. |
| 24/10/2026 | C2-bis | Paso 1 **por defecto**. Cluster `lab` arrancado de nuevo (sigue en `restart=no`); los pendientes de C2 que se podían correr sin ampliar la VM: **F10 §8** reproduce (H372), **F16 ejercicio 22** reproduce con una y dos réplicas pero el `drain` a secas no corre (enunciado corregido, H373), **F24 §4** reproduce entera con solo Contingencia en compose (H374), y H375 (contexto de `conformance`, sin corrección). `inventory` quedó con `kubectl scale`: el próximo `task deploy` va con `FORCE=true`. El laboratorio sigue arriba para O1. |
| 24/10/2026 | C4 | **O1 hecha por el autor** (H376): `storefront.localhost:8443` en Chrome sin aviso de certificado; el catálogo bloqueado por contenido mixto, como anuncia la F19 §3. Sigue O2. |
| 24/10/2026 | C4 | **O2 hecha** (H377): la CA fuera del llavero `login` (la sesión) y la variante del sistema instalada, comprobada y quitada (el autor, con `sudo`; un pegado cortado dejó el certificado sin confianza, como avisa `a01`, y se repitió el borrado). Nota de lo verificado de `a01` al día. |
| 24/10/2026 | C4 | Laboratorio bajado: `kind delete cluster --name lab`, `registry:down` (dejaba el volumen huérfano: **H378**, `rm -fv` en la tarea y en `a01`) y las imágenes `lab/*` por nombre. F19 sin las marcas de navegador y desinstalación. Quedan, a decisión del autor: los volúmenes `lab_*` del patrimonio, las bases bajadas por el curso y la caché de build (67 GB). Siguiente: C3. |
| 24/10/2026 | C4 | Por pedido del autor: borrados los volúmenes del patrimonio (`lab_braqui-estado`, `lab_contingencia-data`, `lab_traslados`) y las redes `kind` y `lab_default`. **Ninguna imagen base**: pueden usarlas otros cursos. La caché de build sigue a decisión del autor. |
| 24/10/2026 | C3 | Paso 1 (todas las recomendadas): B-00 de Podman igual que C1 (`minimo`, `lab`, `legacy`; 3 corridas, cluster desde cero, VM de 4 GiB); la pasada en worktrees de `mi-lab` en los tags `fase-05` y `fase-07`; la F07 con kind, k3d y minikube; B-12 con Podman al final. Docker Desktop cerrado, Podman sin máquina. Directorio `zz-code/lab-docker-kubernetes-20261024-ecee/`. |
| 24/10/2026 | C3 | Lo de Podman solo, hecho: máquina (H379), F03 (H383), F05 (H380, H381), B-05 (H382), F07 y B-07 (H384), B-00 (H385, H386: `lab` corregida), cluster `lab` con `images:load`, B-12 y Testcontainers (H387–H389: cuatro correcciones a `test:pricing` y `main_test.go`). Máquina detenida; sigue el tramo con los dos motores, con Docker Desktop abierto por el autor. |
| 24/10/2026 (noche) | C3 | Tramo con los dos motores, con Docker Desktop abierto por el autor (pidió contraseña para recuperar el socket: **H390**, `a02` y F00). F00 §4.6 y `engine:*` literales (H391); F05 §9 literal, y kind borra el contexto del cluster de Docker al fallar el de Podman (**H392**, F05 §9 y `a02`); F03 §5.5 reproduce (H393); `main_test.go` con Docker, sin sobrantes, y la línea del fallo en la F12 (H394). Limpieza: Docker igual que al abrir; Podman sin nada del curso salvo las imágenes base, máquina detenida. H379–H394 en `hallazgos.md`; A4 tachada. Queda O3. |
| 24/10/2026 (noche) | C3 | O3: el autor **conserva la máquina de Podman** y borra él sus imágenes y contenedores. Por defecto: H382 sin tocar la celda; H288 cerrado con una línea en `measure.py` (borra la red `b07` tras el último `minikube delete`), probado con Docker (la red queda solo tras tres nodos). Docker igual que al abrir. |
| 25/10/2026 | C3 | El autor vació la máquina de Podman (`rm -a -f`, `rmi -a -f`: 21 imágenes base fuera; `system df` en cero) y la detuvo. C3 sin pendientes salvo la revisión del autor. |
