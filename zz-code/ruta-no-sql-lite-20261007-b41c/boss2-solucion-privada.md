# Boss II "El tablero que nadie puede reconstruir" — solución privada (no se publica)

> Guía §16, excepción 6: la solución del boss se guarda fuera del repositorio publicado.
> Generada el 07/10/2026 con `boss/setup.ts`, `tablero_duckdb.py`, `tableros.ts` y `boss2_solucion.ts`
> (logs en `salidas/boss-*.log` y `salidas/boss2-solucion.log`).

## Las tres cifras (Twin Otter con grabador, siete aeronaves)

| Tablero | Costo | Horas | USD/h |
|---|---|---|---|
| DuckDB (año 2026, UTC, sin tope de ventana) | 7 862 753,12 | 9853,5 | 797,96 |
| Timescale (ene–sep 2026, mes colombiano) | 7 862 753,12 | 8686,6 | 905,16 |
| OpenSearch (partes a precio de catálogo, horas de Timescale) | 9 200 840,98 | 8686,6 | 1059,20 |

## De dónde sale cada diferencia

1. **DuckDB − Timescale (horas, +1166,9 h):** `year(ts) = 2026` cuenta las lecturas posteriores al
   30/09/2026 de `HK-5178` (4902,0 h en el año contra 3733,5 en la ventana UTC); el resto, el corte UTC
   contra Colombia (HK-4251 1291,5 contra 1290,0; HK-4985 731,5 contra 731,1; HK-5178 3733,5 contra 3737,0).
2. **OpenSearch − Timescale (costo, +1 338 087,86):** 88 órdenes duplicadas por el lote reenviado sin `_id`
   (+1 296 526,60) y las llantas, actuadores y bombas a precio actualizado +12 % en el buscador
   (+41 561,26). 478 documentos para 390 órdenes.
3. **Las tres comparten un error que ninguna ve:** `HK-5178` entró a la flota el 01/03/2026 y el generador
   le asignó la misma cuota de lecturas que a las demás: 3737 h en siete meses (17,6 h por día). Defecto
   declarado en `a05`; F07 ejercicio 22 lo deja como pista.

## La cifra defendible

Mes colombiano, costos almacenados en la orden, sin duplicados, y `HK-5178` fuera por registros físicamente
imposibles: costo 7 665 638,79 (7 862 753,12 − 197 114,33) / horas 4949,6 (8686,6 − 3737,0) =
**1548,73 USD por hora volada**. Con `HK-5178` dentro (si alguien defiende sus horas): 905,16.

## Criterio de aceptación privado

El informe encuentra las tres causas con su cifra, pone `HK-5178` en duda con un argumento físico (horas por
día) y no promedia las tres cifras.
