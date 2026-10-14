# angular-8-legacy-for-backend-devs-20261007-defa

- **Curso:** angular-8-legacy-for-backend-devs
- **Tanda:** T1–T5
- **Creado:** 2026-10-07
- **Propósito:** Giro a Ottawa: script de fechas, DatePipe con IANA, selector de rangos, incidentes 07/19, Java 8 y mongo:4.0 de bea-08/bea-06/bea-12
- **Estado:** archivado (2026-10-07, al cerrar el plan de edición)
- **Cómo regenerar lo que limpiar.py borra:** `bash comandos-t1.sh install` (sondas de Node), el `npm install` del esqueleto (README §4) y el `mvn dependency:copy-dependencies` de `sondas/java8/springdata`

## Qué hay

- `extraer/`: `bloque.py` (saca un bloque de código del markdown tal como está) y los scripts que arman las entradas de cada tanda.
- `fechas/`: inventario, tabla de equivalencias (fuente de verdad de D7/D12), `aplicar.py` y el chequeo de cierre de T1.
- `sondas/angular8/`: pruebas en Node 14 con `@angular/common` 8, TypeScript 3.5, Jasmine, `@ngrx/store` 8 y `json-server`.
- `sondas/java8/`: Java 8 (zonas, fragmentos de `bea-08`) y Spring Data Commons 2.1 (`LocalDate`).
- `sondas/mongo/`: `mongo:4.0` para `bea-06`, `bea-08` y el generador de `bea-12`.
- `esqueleto/`: proyecto Angular 8.2.14 `clinical-lab` armado con bloques del curso, para `ng build --prod` y la imagen de la Fase 13.
- `incidente19.sh`: los `docker run` del cuaderno y el render en Chrome headless.
- `ediciones/`: los scripts con que se editó el curso en T1–T3 (y los fragmentos largos que insertan).
- `verificar-curso.py`, `verificar-secciones.py`: los verificadores de T5 (el curso no tiene uno propio).
- `corrida-final.sh`: T1–T4 de cero contra el markdown final.
- `salidas/`: lo que imprimió cada prueba el 2026-10-07; `salidas/final/`, la corrida final.

## Qué sirvió

Nada se copió al curso desde aquí: las pruebas decidieron D11–D16 y las correcciones de T1–T3, que están en el markdown. `extraer/bloque.py` (acepta vallas sangradas) y `verificar-secciones.py` son candidatos a `zz-instrucciones/herramientas/`: sirven para cualquier curso sin `src/`.
