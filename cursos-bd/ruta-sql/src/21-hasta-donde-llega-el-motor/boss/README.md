# 💀 Boss del Bloque IV — El informe en la app

El encargo de **Florencia Marchetti** está en la
[Fase 21](../../../21-hasta-donde-llega-el-motor.md#-16-boss-del-bloque-iv--el-informe-en-la-app): servir el informe como
documento sin perder la fuente relacional, buscar al paciente aunque la recepción lo haya escrito mal, y corregir
un resultado con su auditoría en la misma transacción.

## Qué hay

| Archivo | Qué es | ¿Se edita? |
|---|---|---|
| `informe.py` | el punto de partida: `buscar_paciente`, `leer_informe` y `corregir`, con tres fallas que no se dicen | **sí** |
| `arnes.py` | evalúa cinco criterios sobre el `informe.py` que le pases; sale con 0 solo si pasan los cinco | no |

## Cómo se corre

Desde `src/`, con el laboratorio arriba. **Antes, reconstruye las tablas de la Fase 20**, porque el arnés escribe
en `staging`:

```bash
cd lab && for f in 01_muestra 03_jsonb; do docker compose exec -T postgres psql -U postgres -d alameda < ../20-la-propuesta-de-florencia/$f.sql; done && cd ..
uv run python 21-hasta-donde-llega-el-motor/boss/arnes.py                 # el punto de partida
uv run python 21-hasta-donde-llega-el-motor/boss/arnes.py mi/informe.py   # tu versión
```

El punto de partida no pasa los cinco. **La solución no se publica**.
