# 💀 Boss del Bloque II — El portal de 2018

El encargo de **Verónica Colombo**, gerenta de datos de Horizonte, está en la
[Fase 14](../../../14-la-base-no-estaba-lenta.md#-boss-del-bloque-ii--el-portal-de-2018): enlaces que nadie pueda
calcular, los de 2018 vencidos sin dejar de responder, y una página del médico derivante que no lea la tabla entera.

## Qué hay

| Archivo | Qué es |
|---|---|
| `01_portal_2018.sql` | el punto de partida: arma `staging.portal_2018` como quedó en 2018 y mide lo que hay que arreglar, sin arreglarlo |

Este boss no trae arnés: cada criterio es un número de bloques que se mide con `EXPLAIN (ANALYZE, BUFFERS)`.

## Cómo se corre

Con la caja M cargada en Postgres, desde `src/lab/`:

```bash
docker compose exec -T postgres psql -U postgres -d alameda < ../14-la-base-no-estaba-lenta/boss/01_portal_2018.sql
```

## Lo que se entrega

En una transacción: un enlace por informe que no se pueda calcular, los enlaces de 2018 registrados como vencidos,
la página del médico paginada sin leer lo que no muestra, y las mediciones. Los criterios (5 bloques para abrir un
informe, 25 por página, 10 para el total, ningún informe alcanzado por el diccionario de la Fase 10), en la fase.
**La solución no se publica**.
