# go-for-java-devs-20261114-0144

- **Curso:** go-for-java-devs
- **Tanda:** S0–S1
- **Creado:** 2026-11-14
- **Propósito:** ejecutar las salidas de las fases por tandas (S0 plan, S1 F00–F01) y el gemelo Spring Boot de ClearingHouse
- **Estado:** vigente
- **Cómo regenerar lo que limpiar.py borra:** `salidas/versiones/` sale de volver a correr `extraer.py`; el inventario de Docker no se regenera (es del 14/11/2026)

## Qué hay

- `README.md`: cómo se corre cada tanda (diez secciones).
- `extraer.py`: reconstruye el repositorio del lector desde los bloques de las fases.
- `scripts/`: `correr.sh` (el contenedor) y un script por fase y tanda.
- `corridas/`: los logs literales de cada script, versionados.
- `lector/`: el repositorio del lector al cierre de la última tanda.

## Qué sirvió

- S1 (14/11/2026): el `Makefile` que recorre módulos, el `.golangci.yml` corregido, la receta de go1.13 en Apple Silicon, el `epoch-test` con `strings.Cut` y las salidas corregidas de F00 y F01. El detalle, en la tabla de S1 del plan del curso.
