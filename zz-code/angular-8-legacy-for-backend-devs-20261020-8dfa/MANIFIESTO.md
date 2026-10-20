# angular-8-legacy-for-backend-devs-20261020-8dfa

- **Curso:** angular-8-legacy-for-backend-devs
- **Tanda:** kind-rosetta (anexo al plan Apple Silicon)
- **Creado:** 2026-10-20
- **Propósito:** pendiente de A13 (kind con Rosetta) y el H-host de `npm ci` en el Mac, preparado
- **Estado:** archivado (20/10/2026): H-host corrido por el autor
- **Cómo regenerar lo que limpiar.py borra:** `host-labcore/node_modules` con `./host-npm-ci.sh` (en el Mac).

## Qué hay

- `kind-rosetta.sh`, `kind-node-x64.sh`, `img/`, `img-node/`: la prueba de kind.
- `corregir-curso.py`: las correcciones de F14, A09, A12, A13 y las tablas forenses.
- `host-npm-ci.sh`, `host-labcore/`: el H-host para el autor.

## Qué sirvió

- H-K-1/2/3 → la ⚠️ de F14 §5.1 reescrita (el pod amd64 corre traducido; el `exec format error` es arm64 → cluster amd64),
  A09 §7, la fila de A12 §6, A13 §3/§7/§9 (el pendiente de kind se quitó), forense-fase-14 y forense-master.
- H-H-1 → la ⚠️ de `fsevents` y el 📝 de la espera en F0 §5.1, y el párrafo de `fsevents` en A12 §2, con el mensaje exacto.
