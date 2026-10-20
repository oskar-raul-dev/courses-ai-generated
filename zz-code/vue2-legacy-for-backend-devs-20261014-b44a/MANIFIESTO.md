# vue2-legacy-for-backend-devs-20261014-b44a

- **Curso:** vue2-legacy-for-backend-devs
- **Tanda:** P1, R1–R4, V0–V7, K1–K6 y C (cierre, 2026-10-18)
- **Creado:** 2026-10-14
- **Propósito:** la edición completa del paquete Tiquetera: lineamientos (R), validación por ejecución (V), revisión de código (K) y cierre (C)
- **Estado:** archivado (2026-10-18). Lo útil ya pasó al paquete: los scripts que el alumno corre están publicados en sus fases y el verificador vive en `prompts/`; esto queda como registro de cómo se probó cada cifra
- **Cómo regenerar lo que limpiar.py borra:** nada en esta sesión se instala en el host; los diagramas se regeneran con `zz-instrucciones/herramientas/exportar-diagramas.py --motor docker`.

## Qué hay

- `README.md`: cómo correr, resultados y hallazgos de V0.
- `repo/tiquetera-legacy/`: el repo del alumno (tronco, estado final de F11; sin `.git`; `node_modules` y `dist` regenerables).
- `rutas/`, `backend/`, `incidentes/`, `k/` y los directorios de K: las rutas, el backend del Curso 02, los incidentes de los dos cuadernos y las herramientas de la revisión de código (ver el README, §11 a §19).
- `salidas/`: inventario de Docker, registro de npm, corridas del verificador, diagramas exportados e instantáneas por fase en `salidas/fases/`.

## Qué sirvió

- `salidas/diagramas/` y `salidas/diagramas-01-readme/`: los 22 diagramas Mermaid del paquete, generados por `exportar-diagramas.py`. Se usan como referencia visual; el curso guarda el Mermaid en el Markdown, no las imágenes.
