# lab-docker-kubernetes-20261024-ecee

- **Curso:** lab-docker-kubernetes
- **Tanda:** C3 del plan de cierre (el perfil de Podman, y el tramo con los dos motores)
- **Creado:** 2026-10-24
- **Propósito:** la pasada como lector con Podman (F00, F03, F05, F07, B-00, B-05, B-07, B-12) y la convivencia con Docker Desktop
- **Estado:** cerrado el 24/10/2026; hallazgos H379–H394 en `prompts/verificacion-de-laboratorio/hallazgos.md`
- **Cómo regenerar lo que no se versiona** (`.gitignore`):
  - `mi-lab/`: `git clone` del bundle de `../lab-docker-kubernetes-20261021-e349/` (HEAD `915d47a`).
  - `f03/`, `f05/`, `f07/`: `git -C mi-lab worktree add ../f0N <tag fase-0N-…>`; en `f05` y `f07`, aplicar `salidas/worktree-f0N-step-tags.diff`.
  - `b00/lab/`: `rsync -a` del `src/lab/` publicado del curso.

## Qué hay

- `logs/` y `salidas/` (no versionados, por el `.gitignore` del repositorio): una corrida por archivo, inventarios y el diff de `STEP_TAGS`.
- `resultados/`: los JSON del arnés (B-00, B-05, B-07 de kind y minikube, B-12); k3d no deja JSON porque no arranca.
- `hallazgos-candidatos.md`: los borradores de H379–H394.

## Qué sirvió

Correcciones en F00 §4.6, F05 §5.5, §8 y §9, F07 §8, F12, `a01`, `a02` (dos entradas), `a03` (prompt de G3),
`BENCHMARKS.md` (B-05, B-07, B-12) y `src/lab/` (`Taskfile.yml` y `services/pricing/main_test.go`).
