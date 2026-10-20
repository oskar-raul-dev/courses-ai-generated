# CUADERNO-BE.md — reproducción de los doce incidentes (cierre del track BE)

> Cierre. Cada incidente de `cuaderno-incidentes-be.md` se reprodujo con su receta de
> `prompts/preparaciones-de-incidentes-be.md`, y donde la receta o el texto no cuadraban con lo medido se corrigieron los
> dos. Fecha: 15/10/2026, laboratorio `certcore-be` (PHP 7.4.33, Lumen 5.8.13, PostgreSQL 16.9 salvo donde se indica).
>
> **Cómo se aplican las ramas.** `zz-code/` no es un repositorio. Donde la receta pide una rama, el cambio se aplicó a
> mano y se deshizo después, verificando con `cmp` que los archivos quedaban como estaban. Los guiones de `sql/` se
> extrajeron de las recetas a `sql/`.
>
> **Canon decidido por el autor el 15/10/2026:** desde be03 el camino nuevo sirve las rutas del frontend y el viejo sigue
> vivo en `/legacy/templates` y `POST /legacy/findings`. Varios incidentes se reescribieron para ese canon.

---

## Resumen

| Incidente | Estado | Lo que se ve | Correcciones que hizo falta | Evidencia |
|---|---|---|---|---|
| be-01 · Caché que no se limpia | ✅ Reproducido | Tras publicar la v3, el panel (`/legacy/templates`) sigue mostrando la v2, también tras reiniciar el contenedor. Almacén `FileStore` | La rama sale de **be03** (en be01 no hay base ni ruta vieja); la receta parte de la versión canónica del controlador y pide `use Cache;` | `be01-cache.txt` |
| be-02 · Ejemplo copiado | ✅ Reproducido | `Exited (255)` con `aliasMiddleware()`; arreglado eso, `Exited (255)` con `A facade root has not been set.` | El segundo mensaje no era `Class 'Log' not found`; el preflight de `compose.yaml` ahora arranca los proveedores | `be02-error.txt` |
| be-03 · Dos listados, dos órdenes | ✅ Reproducido | `/legacy/templates` pasa de `elevator, boiler` a `boiler, elevator` tras un `UPDATE` que no cambia nada; `/templates` no se mueve | Ticket y pistas para `/legacy` frente a `/templates`; la receta del montón pasa de be-04 a be-03 y toca las filas de ascensores (tocando la caldera no cambia nada, medido) | `be03-orden.txt` |
| be-04 · Calderas primero | ✅ Reproducido | `/templates` da `boiler-annual-v1` primero; el mock daba los ascensores primero | Causa reescrita: el `ORDER BY` de be03 es alfabético. Sin preparación | `be04-orden.txt` |
| be-05 · «El id ya existe» | ✅ Reproducido | Cuatro `POST /inspections` dan `409`; el log dice `Key (id)=(500…503) already exists`; crear un cliente funciona | `setval(…, min(id), false)` en vez de `1` (con `1` no chocaba nada, medido); el 409 se registra en el log | `be05-error.txt` |
| be-06 · Informe roto sin despliegue | ✅ Reproducido | Con `postgres:11`: `vencidos: 2 · reglas: 2`. Con `16.9`: `column c.consrc does not exist`. El parche (`pg_get_constraintdef`) funciona en 16.9 y en 9.6 | El informe y su comando no existían en ninguna lección: van en la receta. Tag `11` en vez de `11.22`; se esperan 2 vencidos, no 3 | `be06-informe.txt` |
| be-07 · Respaldo inservible | ✅ Reproducido | 9.6 (con `wal_level=replica`): bien. 11 y 13: sólo falla `pg_switch_xlog()`. 16.9: fallan `pg_start/stop_backup` y aun así dice «respaldo completado» (6,6 MB) | El guion se ejecuta dentro del contenedor `db`; en 9.6 hace falta `wal_level=replica` | `be07-respaldo.txt` |
| be-08 · Vigente o vencido | ✅ Reproducido (navegador) | Pantalla y PDF: «Por vencer». Informe de vencidos en UTC (con el parche de be-06): `vencidos: 3` con el guion, `2` sin él. Sesión UTC `t`, Bogotá `f`; la vista dice `expiring` | La semilla no traía ese certificado: la receta lo crea. La receta fija ya no depende de la hora (sólo reproducía de 19:30 a 00:30 de Bogotá). Ticket y solución reescritos al canon «pantalla y PDF frente a informe» (decisión del autor): la solución tenía la aritmética de zonas al revés. Prueba de regresión medida: falla sin parche, pasa con él | `be08-zonas.txt`, `be08-ExpiredReportTimezoneTest.php` |
| be-09 · La 3117 sin ítems | ✅ Reproducido (navegador) | La 3117 (15/04/2023, v3, aprobada) sale con sus 3 respuestas, pero `GET /templates?…&version=3` da `[]`. En el navegador redirige a `/inspections/3117/findings` y la pantalla queda en blanco; el único rastro es la consola: `ApiError: No existe la plantilla elevator-annual en su versión 3.` | El generador ahora siembra las 88 en abril–mayo de 2023, v3, aprobadas, con ids desde 10000 (el 3117 queda libre) | `be09-3117.txt` |
| be-10 · Archivar se cae | ✅ Reproducido | `--year=2023` falla por la FK (`elevator-annual`, 3) y archiva 0; `--year=2024` archiva 170. Con el parche: 266 archivadas, 88 informadas | El proceso **mueve** la fila (`DELETE` + `INSERT`); un `UPDATE` de sólo el estado no fallaba (PostgreSQL no revisa la FK si la clave no cambia) | `be10.txt` |
| be-11 · 500 o 422 | ✅ Reproducido | `POST /legacy/findings` → 500; `POST /findings` → 422. Con el parche: los dos 422 | Rutas al canon; el frontend no crea hallazgos; regla duplicada en el parche de la solución | `be11.txt` |
| be-12 · El assessment adversarial | ✅ Analizado | El informe de la consultora, desmontado afirmación por afirmación | — | `ASSESSMENT.md` §9 |

**12 de 12 reproducidos.** Ningún incidente queda «no reproducible». La parte de navegador de be-08 y be-09 se vio con
Playwright el 15/10/2026.

---

## Comprobaciones de la receta (§7 de las preparaciones)

1. **El síntoma aparece como lo describe el ticket.** Sí en los doce, con las correcciones de la tabla.
2. **El sistema sigue arrancando.** Sí, salvo be-02, que consiste en que no arranca.
3. **`smoke.sh` sigue en 26/26.** Comprobado al final, con todas las ramas revertidas, la siembra limpia y el volumen de be05 dentro. No se corrió después de cada preparación por separado.

## Lo que queda abierto

- **Tiempos.** Los ejercicios piden cronometrar (be-02, be-06): no aplica a una reproducción automatizada.
