# lab-docker-kubernetes-20261020-1691

- **Curso:** lab-docker-kubernetes
- **Tanda:** C1
- **Creado:** 2026-10-20
- **Propósito:** pasada en macOS: A2 (B-00 de Docker) y A3 de F00 a F07
- **Estado:** vigente
- **Cómo regenerar lo que limpiar.py borra:** en `mi-lab/src/lab/`, `task build:all` reconstruye las
  cinco imágenes (y con ellas `node_modules`, `vendor` y `dist` dentro de cada etapa de build);
  `task cluster:up -- minimo|lab` y `task images:load -- <perfil>` rehacen el cluster.

## Qué hay

- `b00/lab/` — copia de `src/lab/` del curso, usada solo para medir B-00 (A2), para no ensuciar el
  árbol publicado con builds, `.venv` ni datos de medición.
- `mi-lab/` — el repositorio de la pasada, hecho **como lector**: la copia inicial de §4.7 y, de ahí
  en adelante, lo que cada fase manda escribir o generar. Con sus commits `fNN:` y sus tags
  `fase-NN-<slug>` de F00 a F07.
- `mi-lab.bundle` — el repositorio de la pasada como bundle (`git bundle create … --all`), con sus 8
  commits y sus 8 tags `fase-NN-<slug>`: es lo que entra a git, porque `mi-lab/` es un repositorio
  anidado y agregarlo tal cual guardaría solo un puntero. Se abre con
  `git clone mi-lab.bundle mi-lab`.
- `logs/` — los crudos de B-00 (tres perfiles, más la corrida abortada), B-04 y B-07.
- `salidas/` — el inventario de Docker previo a la tanda.
- `hallazgos-candidatos.md` — el borrador con el que se trabajó; lo definitivo está en
  `prompts/verificacion-de-laboratorio/hallazgos.md` del curso, desde H271.

## Qué sirvió

Al curso, de esta tanda:

- **`a01`** — la columna de Docker de la tabla `legacy` de B-00, corregida con las cifras del
  20/10/2026 y su nota (H272); la fila `legacy` de la tabla de plataformas (`709–743`); la
  reconfirmación en la cabecera de B-00; la aclaración de la versión de NestJS (H281); y la redacción
  de `compose:up`/`compose:down` en § El Taskfile (H277).
- **`src/lab/Taskfile.yml`** — `compose:up` y `compose:down` sin nombrar servicios, y fuera la
  variable `COMPOSE_SERVICES` (H277).
- **`src/lab/scripts/engine/engine.py`** — `engine:status` dice `(por defecto, sin .engine.env)`
  cuando el archivo no existe (H276).
- **`a03`** — el `CMD` en forma JSON en el marco común de G0 (H279), el andamio ESM de Nest en el
  prompt de `replenish` (H280) y la comprobación de versiones en el de `storefront` (H281).
- **F00 §4.7 y la convención de git** — de dónde sale `compose/compose.yaml` y qué perfil deja cada
  apéndice (H278).
- **F02 §4.3 y §4.6** — la salida de `task compose:up` al día, la nota de `--build-context` y de los
  tags de `STEP_TAGS`, y la tabla de tareas con su párrafo de entrada reescrito (H277).
- **F04 §5.3** — el matiz de que el `.dockerignore` solo mueve la caché cuando el Dockerfile copia
  directorios, con las dos mediciones (H283).
- **`hallazgos.md`** — la sección de C1, de H271 en adelante, y H155 actualizado a resuelto en su
  parte principal.
