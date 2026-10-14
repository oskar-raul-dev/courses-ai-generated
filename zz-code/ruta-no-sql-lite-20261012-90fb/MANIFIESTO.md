# ruta-no-sql-lite-20261012-90fb

- **Curso:** ruta-no-sql-lite
- **Tanda:** T6
- **Creado:** 2026-10-12
- **Propósito:** comprobaciones de reconstrucción del capstone (F23), las costuras de F24, la factura de F25 y la solución privada del boss V
- **Estado:** archivado (12/10/2026, cierre de T8; guarda la solución privada de su boss)
- **Cómo regenerar lo que limpiar.py borra:** nada: no hay dependencias propias; el código usa las de `cursos-bd/ruta-no-sql-lite/src/`

## Qué hay

- `f23-proyeccion-por-cierre.sql` y `f23-proyeccion-por-apertura.sql`: la proyección del inventario con los dos órdenes.
- `salidas/f23-*`: los logs de las cuatro comprobaciones de F23 y el diagrama dibujado con `mmdc`.
- `salidas/f24-*`: los logs de las costuras (con y sin caída), la carrera, la reconstrucción y la vuelta, y el diagrama de secuencia.
- `salidas/f25-*`: la factura (y la corrida que falló con `-j 4`), el árbol dibujado y los logs del boss V.
- `boss-v/`: la solución privada del boss V (`reconcile.ts`, `seam.ts`, `solucion-privada.md`); `node_modules` es un enlace.
- `salidas/*-antes.txt`: el inventario de Docker antes de empezar.

## Qué sirvió

- Los cuatro guiones pasaron a `src/23-poliglota-el-diseno/`; sus cifras, a M-72–M-75 de la bitácora y a la sección 6.4
  de F23; la forma de comparar, a `a04` (la huella de un derivado).
- Los guiones de F24 pasaron a `src/24-poliglota-la-costura/`; sus cifras, a M-76–M-80 y a la sección 6 de F24; la
  forma de medir la ventana, a `a04`; los errores, a E-80–E-83 de `a09`.
- `factura.ts` pasó a `src/25-poliglota-la-factura/`; sus cifras, a M-81 y a la sección 6 de F25. La solución del boss V
  se queda aquí, privada.
