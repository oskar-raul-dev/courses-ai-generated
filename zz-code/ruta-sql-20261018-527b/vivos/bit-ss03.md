### M-66 · ss03 · Lo que le cuesta a cada sede el plan que eligió la otra
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (la base `ss03`: 343.123 protocolos, 3.659.431 resultados)
**Hipótesis:** en nivel 170, con el plan del central en la caché (`Hash Match` con `Index Scan` de `ResultadoItem`, estructura publicada en ss03), la sede V lee al menos tres veces las lecturas lógicas que lee con su plan (`Index Seek`); con el plan de V, el central lee más que con el suyo. En Postgres, el plan heredado le costaba a V 8,1 veces ([M-21](#m-21--f13--el-plan-genérico-de-la-consulta-por-sede)). · **Resuélvela:** `uv run --extra sqlserver python ss03-query-store-y-parameter-sniffing/02_sniffing.py --private` desde `src/`

### M-67 · ss03 · La optimización PSP sobre la consulta por sede
**Tipo:** apuesta sin resolver · **Motor:** SQL Server 2025 CU9 (Enterprise Developer, emulado) · **Perfil:** M (la base `ss03`)
**Hipótesis:** PSP no arma variantes para `dbo.resultados_por_sede` (el central tiene cuatro veces los protocolos de un centro), y el evento `parameter_sensitive_plan_optimization_skipped_reason` da un motivo de sesgo insuficiente. · **Resuélvela:** `06_psp.sql`, desde `src/ss03-query-store-y-parameter-sniffing/`

### M-68 · ss03 · `plan_cache_mode` fijado para el rol del reporte
**Tipo:** publicada · **Motor:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` · **Perfil:** M, el modelo · **Fecha:** 18/10/2026
**Hipótesis:** con `ALTER ROLE … SET plan_cache_mode = force_custom_plan`, la sesión que empieza el día con el central no le pasa su plan a la sede V: la sexta ejecución, para V, usa su plan propio, sin tocar la consulta.
**Resultado:** cinco ejecuciones para el central y una para V como `ss03_reporte`: 0 planes genéricos y 6 personalizados; V con *nested loop* sobre `result_lab_order_id_idx`, 10.866 bloques (9.257 en caché y 1.609 leídos), contra los 87.945 del genérico heredado en [M-21](#m-21--f13--el-plan-genérico-de-la-consulta-por-sede). El rol necesitó `BYPASSRLS`: sin él, la política de la Fase 23 sobre `alameda.result` no le deja ver ninguna fila. · **Apuesta:** ganada
**Reproducir:** la solución del ejercicio 19 de ss03, con `staging.order_site` de `src/13-el-optimizador-en-tres-motores/01_generic_plans.sql`
