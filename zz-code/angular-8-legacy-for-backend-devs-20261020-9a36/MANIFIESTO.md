# angular-8-legacy-for-backend-devs-20261020-9a36

- **Curso:** angular-8-legacy-for-backend-devs
- **Tanda:** T0–T4 del plan Apple Silicon (`prompts/_desechable-plan-apple-silicon.md`)
- **Creado:** 2026-10-20
- **Propósito:** Plan Apple Silicon de LabCore: devcontainer de A13 §6 en arm64 y amd64, fallas del A13 actual, Dart Sass frente a node-sass
- **Estado:** archivado (20/10/2026): lo útil ya está en el curso; se conserva como registro de cómo se probó
- **Cómo regenerar lo que limpiar.py borra:** `salidas/` y los `dist/` se rehacen con los comandos de README §4; los `node_modules` viven en volúmenes de Docker, no en disco.

## Qué hay

- `devc/clinical-lab/.devcontainer/`: el devcontainer candidato de A13 §6 (el que se publica byte a byte).
- `devc/clinical-lab-sass`, `devc/clinical-lab-dart`: el proyecto con el Sass de A02, con y sin `node-sass`.
- `a13-actual/`, `a13-parche-apt/`, `variantes/sin-python2/`: el A13 publicado y sus variantes, para citar fallas.
- `t0-*.sh`, `t1-*.sh`, `t2-*`, `t0-css-compara.py`, `extraer-bloques.py`, `a13-s6-borrador.md`: las pruebas y el armado de A13 (README §4).

## Qué sirvió

- `devc/clinical-lab/.devcontainer/` → A13 §6, byte a byte (SHA-256 en `salidas/t0/devcontainer-sha256.txt`).
- Los hallazgos H-T0-1 a H-T0-12, H-T1-1 y H-T2-1/2 → A13 §3–§9, «Cuándo usar qué», ejercicios 3 y 6; la 🧭 de A14 §3.
- H-T0-8 a H-T0-11 (Dart Sass) → D4 del plan (default: `node-sass` se queda) y A12 §3 opción C, A02 §1.1.
