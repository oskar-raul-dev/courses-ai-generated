# 💀 Boss del Bloque I — La señora que es tres pacientes

El encargo de **Norma Castellani**, directora técnica, está en la
[Fase 08](../../../08-los-dos-extremos-del-mismo-error.md#-boss-del-bloque-i--la-señora-que-es-tres-pacientes): una paciente
crónica repartida entre una libreta cívica, un DNI y el protocolo de su nieto recién nacido, y una historia de
glucemia que solo empieza en 2008.

## Qué hay

| Archivo | Qué es |
|---|---|
| `01_what_norma_sees.sql` | el punto de partida: lo que ve Norma hoy, con el modelo del Bloque I (tres pacientes, la glucemia desde 2008) |

Este boss no trae arnés: los criterios se comprueban contra `truth.planted_case` (`boss-1-lady` y
`boss-1-grandson`), que el generador plantó en la caja.

## Cómo se corre

Con el modelo del Bloque I cargado, desde `src/`:

```bash
uv run lab load --profile m --model
cd lab && docker compose exec -T postgres psql -U postgres -d alameda < ../08-los-dos-extremos-del-mismo-error/boss/01_what_norma_sees.sql
```

## Lo que se entrega

Un script, en una transacción, con la persona reconstruida y su fusión deshacible, el protocolo de la abuela
reasignado desde la ficha del nieto, la historia unificada de 1999 a 2026 y su medición con `lab measure`. Los
criterios de aceptación, completos, en la fase. **La solución no se publica**: es un encargo, no un ejercicio.
