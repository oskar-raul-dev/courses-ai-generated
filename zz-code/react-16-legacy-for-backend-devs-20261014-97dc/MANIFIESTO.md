# react-16-legacy-for-backend-devs-20261014-97dc

- **Curso:** react-16-legacy-for-backend-devs
- **Tanda:** T0 (la raíz)
- **Creado:** 2026-10-14
- **Propósito:** pruebas de §5.1 de T0: `package.json` y `go.mod` de referencia, tags de la convención, diagrama de estados del alcance
- **Estado:** archivado (T12, 20/10/2026)
- **Cómo regenerar lo que limpiar.py borra:** `npm install --package-lock-only --ignore-scripts` en `node:14.21.3` (el lockfile de `trabajo/paquete`); `bash trabajo/tags/prueba-tags.sh <dir>` (el repo de prueba); `docker pull ghcr.io/mermaid-js/mermaid-cli/mermaid-cli:11.4.2` (la imagen)

## Qué hay

- `README.md`: cómo correr las pruebas y qué se espera ver.
- `trabajo/paquete/`: `package.json` candidato (`esclusa-app`) y su lockfile, más `comparar-con-doc.py`.
- `trabajo/gomod/`: `go.mod` candidato (`github.com/interoceanic-games/esclusa-api`) y su `go.sum`.
- `trabajo/tags/prueba-tags.sh`: prueba de la convención de tags en un repo vacío.
- `trabajo/mermaid/`: el bloque `stateDiagram-v2` extraído del alcance y su render.
- `salidas/`: registros de las pruebas, inventarios de Docker al inicio y al final, y el aviso sobre el inventario inicial de P7 (ver el README, §8).

## Qué sirvió

- El `package.json` y el `go.mod` probados se copiaron a `00-decisiones-y-versiones.md` §3 y §7.2 (el comparador confirma que son iguales).
- El bloque Mermaid probado está en `00-alcance-del-proyecto.md` §5.
- Los tags probados son los de `00-convencion-de-git-y-tags.md`.
