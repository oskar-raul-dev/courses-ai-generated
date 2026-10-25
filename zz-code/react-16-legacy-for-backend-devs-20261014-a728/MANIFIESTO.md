# react-16-legacy-for-backend-devs-20261014-a728

- **Curso:** react-16-legacy-for-backend-devs
- **Tanda:** —
- **Creado:** 2026-10-14
- **Propósito:** {{qué se va a probar}}
- **Estado:** extraído (T12, 20/10/2026)
- **Cómo regenerar lo que limpiar.py borra:** {{p. ej. `npm ci`, `mvn -q package`, `python3 -m venv .venv && .venv/bin/pip install -r requirements.txt`}}

## Qué hay

- `esclusa-app.bundle` — **lo que se versiona** del repo de prueba: todas las ramas y tags en un archivo (git no versiona un repo dentro de otro), hecho el 24/10/2026. Se restaura con `git clone esclusa-app.bundle esclusa-app && cd esclusa-app && for b in $(git branch -r | grep -v HEAD | sed 's|origin/||'); do git branch -q "$b" "origin/$b" 2>/dev/null; done`.
{{Una línea por subdirectorio o archivo que importe.}}

## Qué sirvió

{{Lo que se extrajo al curso, a su laboratorio o a zz-instrucciones/herramientas/, con su destino.}}
