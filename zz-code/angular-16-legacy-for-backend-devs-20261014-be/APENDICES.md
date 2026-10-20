# APENDICES.md — verificación de bea-02 a bea-11 (cierre del track BE)

> El checklist del plan decía «ejecutar los comandos de **Cómo se verifica**». Ninguno de los diez apéndices
> (`bea-02` … `bea-11`) tiene esa sección. Lo que sí tienen son bloques de comandos y afirmaciones medibles. Se verificó
> lo que los propios apéndices afirman y que depende de este track. Lo que no se ha ejecutado se dice.

## Verificado

| Apéndice | Afirmación | Resultado | Evidencia |
|---|---|---|---|
| bea-02 | `Dockerfile` con el `RUN` de snapshot de Debian (la «cápsula del tiempo») construye la imagen | **Sí** | `docker compose build api` (certcore-be-api) |
| bea-02 | Los cuatro comandos (`up -d`, `curl /health`, `logs -f`, `down`) | **Sí**, salvo `curl` desde el host: el puerto no se publica | `FALSA-FAMILIARIDAD.md` |
| bea-02 | `compose.yaml` «copiable tal cual» | **No**: hubo que añadir preflight de arranque, quitar `ports:` y pasar las variables del caos. Diferencias en `FALSA-FAMILIARIDAD.md` §Desviaciones | `compose.yaml` |
| bea-02 | Error «`could not translate host name "db"`» y «SCRAM…» | No se reprodujo; la conexión funciona dentro de la red de compose | — |
| bea-03 | `Cache::get` no existe con facades apagados; `probe.php` pregunta al objeto | **Sí** | `FALSA-FAMILIARIDAD.md` bug 1 y 2 |
| bea-04 | `Template::active()->toSql()` construye SQL sin base | **No**: falla sin `withEloquent()` (Model::connection() on null) | `FALSA-FAMILIARIDAD.md` bug 3 |
| bea-05 | Cadena 9.6 → 16.9 y las rupturas con cita de release notes | **Sí** para la cadena (26/26 en cada escalón); las citas están verificadas con URL | `EVIDENCIA-VERSIONES.md` §2–3 |
| bea-06 | `NOT VALID` deja pasar filas nuevas válidas y rechaza las inválidas; las viejas siguen | **Sí** | `evidencia-be05/pruebas-fk.txt` |
| bea-07 | Un `timestamp` sin zona pierde el offset y depende de la zona de la sesión | **Sí** | `evidencia-be05/`, `EVIDENCIA-VERSIONES.md` §6, `cuaderno-be/be08-zonas.txt` |
| bea-08 | Ficha `R-01` con siete campos | **Usada** en `ASSESSMENT.md` §5.1; los campos de aceptación quedaron firmados (Hernando Gil, 15/10/2026, `ASSESSMENT.md` §7) | `ASSESSMENT.md` |
| bea-09 | Symfony como vara de medir | No se ha medido en este árbol (no hay Symfony) | — |
| bea-10 | Mapa de deuda del track | No se ha revisado línea a línea; la deuda aceptada de be03–be06 está en los `.md` del backend | `HALLAZGOS.md`, `SUPERFICIE.md` |
| bea-11 | Volumen determinista con semilla fija | **Sí**: mismo `md5` en dos regeneraciones | `evidencia-be05/md5-volumen-semilla-20240915.txt` |

## Resumen

- **Verificados:** 8 de 11 afirmaciones medibles, con evidencia.
- **Divergencias corregidas en el texto el 15/10/2026:** bea-02 (`compose.yaml` con `working_dir`, `APP_ENV`, variables del caos y
  preflight: ahora sí es copiable tal cual) y bea-04 (`toSql()` necesita Eloquent encendido). Además bea-11 trae ya el generador
  completo y probado (antes era un esbozo), con las violaciones como las describe.
- **El ítem «Cómo se verifica»** se retira del plan por decisión del autor (15/10/2026).
- **No ejecutado:** bea-09 y bea-10 en su parte de Symfony y mapa de deuda.
- **Pendiente de decisión del autor:** si el ítem «Cómo se verifica» debe existir en los apéndices (hoy no existe en ninguno) o si el ítem del plan se retira.
