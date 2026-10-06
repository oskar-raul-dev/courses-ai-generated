# react-16-legacy-for-backend-devs-20261005-cbd3

- **Curso:** react-16-legacy-for-backend-devs
- **Tanda:** — (revisión del `prompts/` contra `zz-instrucciones/`, sin plan de producción)
- **Creado:** 2026-10-05
- **Propósito:** barrido del verificador base sobre el curso y prueba de los diagramas Mermaid de
  la guía §17.1 y del `prompts/README.md`.
- **Estado:** extraído
- **Cómo regenerar lo que limpiar.py borra:** desde la raíz del curso,
  `python3 prompts/verificar-corpus.py [--publicacion]`, y `mmdc -i <archivo>.mmd -o <archivo>.svg`.

## Qué hay

- `salidas/courses-ia.txt` y `salidas/publicacion.txt` — el verificador base con los perfiles del
  repositorio, antes de la subclase del curso.
- `salidas/curso.txt` y `salidas/curso-pub.txt` — la subclase del curso: 3 `ANCLA-FE0F` + 1
  `DIAGRAMA`, y 56 `CITA-PROMPTS` con `--publicacion`.
- `salidas/estados-numero.*` y `salidas/autoridad.*` — los dos Mermaid, dibujados con `mmdc`.
- `salidas/f05-estados.*` — el `stateDiagram-v2` que reemplazó al ASCII de F05 §4.

## Qué sirvió

La subclase quedó en `prompts/verificar-corpus.py` del curso; los hallazgos y su corrección, en la
guía §17.3 y §17.4. No hay código que conservar. La revalidación por ejecución abrirá su propio
directorio (ver `prompts/_desechable-plan-de-validacion.md` del curso).
