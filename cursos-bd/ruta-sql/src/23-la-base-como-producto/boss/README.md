# 💀 Boss del Bloque V — Las 9:40

El encargo de **Verónica Colombo** está en la
[Fase 23](../../../23-la-base-como-producto.md#-16-boss-del-bloque-v--las-940): la exportación nocturna y la notificación de
doce horas pasadas a flujo, y el portal servido por la API con seguridad por fila.

## Qué hay

| Archivo | Qué es | ¿Se edita? |
|---|---|---|
| `01_setup.sql` | el punto de partida: las tablas del flujo y la vista del portal, con fallas; el arnés lo corre antes de cada evaluación, así que tiene que ser repetible | **sí** |
| `flujo.py` | exportar, entregar, registrar un resultado y cerrar el día, con fallas que no se dicen | **sí** |
| `arnes.py` | evalúa cinco criterios (C1 a C5) sobre el directorio que le pases | no |

## Cómo se corre

Desde `src/`:

```bash
uv run lab up base api
cd lab && docker compose exec -T postgres psql -U postgres -d alameda < ../23-la-base-como-producto/01_setup.sql && cd ..
uv run python 23-la-base-como-producto/boss/arnes.py              # el punto de partida
uv run python 23-la-base-como-producto/boss/arnes.py mi-boss-v/   # tu copia del directorio, con tus dos archivos
```

Los cinco criterios: la exportación no pierde la fila que confirma tarde, un mensaje repetido no se aplica dos
veces, la notificación sale dentro de las doce horas, la API no le muestra a un paciente informes de otro, y una
corrección vieja no pisa a la nueva. **La solución no se publica**.
