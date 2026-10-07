# ruta-no-sql-lite-20261006-8b0f

- **Curso:** ruta-no-sql-lite
- **Tanda:** revisión contra `zz-instrucciones/` (06/10/2026), fuera de las tandas de escritura
- **Creado:** 2026-10-06
- **Propósito:** comprobar que fundir `src/lab/.gitignore` en `src/.gitignore` no cambia nada, dibujar con `mmdc` los diagramas pasados a Mermaid, y dejar registro de los reemplazos que alinearon lo publicado (anclas, enlaces, citas a `prompts/`).
- **Estado:** archivado
- **Cómo regenerar lo que limpiar.py borra:** `salidas/` se rehace con `comandos-revision.sh` (los pasos 2 y 6; los demás ya no encuentran nada que corregir).

## Qué hay

- `comandos-revision.sh` — los comandos de la sesión, en orden, tal como corrieron.
- `sin-citas-a-prompts.py` — los reemplazos literales que quitaron las citas a `prompts/` de lo publicado.
- `diagramas/` — los dos `.mmd`: las relaciones entre entidades de `a05` y el ejemplo de la guía §3.
- `salidas/` — las listas de `git ls-files` antes y después, la salida del verificador antes de corregir y los PNG de los diagramas (ignorado por git).

## Qué sirvió

- Los dos diagramas, al curso (`a05`) y a su guía (§3).
- El resultado del `.gitignore` (listas idénticas), a la guía §18.5 y a la bitácora del plan.
