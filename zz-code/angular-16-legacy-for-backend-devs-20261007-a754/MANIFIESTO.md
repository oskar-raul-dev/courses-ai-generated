# angular-16-legacy-for-backend-devs-20261007-a754

- **Curso:** angular-16-legacy-for-backend-devs
- **Tanda:** T2-T5
- **Creado:** 2026-10-07
- **Propósito:** Edición Plomada: extractor de bloques del markdown, tsc de business-day.ts, línea base de tiempo y pruebas de los incidentes 21 y 22, php -l del track BE
- **Estado:** vigente
- **Cómo regenerar lo que limpiar.py borra:** `bash correr-t2.sh` (instala `node_modules/` en el contenedor con `npm install` y regenera `salidas/`).

## Qué hay

- `editar-t2.py` — los reemplazos de texto de T2 sobre el curso (exactos, de una aparición).
- `extraer.py` — reconstruye `src/app/core/{models,domain,time,pdf}` desde los bloques del markdown.
- `correr-t2.sh`, `tsconfig*.json`, `package.json` — `tsc` 5.1.6 en `node:18.18.2-alpine` y la línea base.
- `pruebas/linea-base.ts` → `linea-base-t2.json` — lo que el código de F07+F10 responde hoy; T3 compara contra esto.

## Qué sirvió

Nada extraído todavía. El `tsc` de T2 encontró el import faltante de F10 §5.8 (corregido a mano en el curso) y el desfase de F11 con la API de F10 (tanda T2b del plan).
