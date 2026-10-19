# 💀 Boss del Bloque III — Una tarde de julio

El encargo de **Matías Ledesma**, el de sistemas, está en la
[Fase 18](../../../18-bloqueos-deadlocks-y-ddl.md#-boss-del-bloque-iii--una-tarde-de-julio): tres cajas, cuatro técnicos
y el formulario de hemogramas abierto a la hora del almuerzo, a la vez, y una tarde que salga bien.

## Qué hay

| Archivo | Qué es | ¿Se edita? |
|---|---|---|
| `01_july.sql` | el estado de partida en `staging`: la numeración de 2015, la planilla de pendientes y los hemogramas del día | si el arreglo lo pide (una restricción, un índice) |
| `tills.py` | el código de la tarde: emitir, tomar una muestra, cargar su hemograma y el formulario del almuerzo | **sí: es el archivo que se arregla**, sin cambiar las firmas |
| `afternoon.py` | corre la tarde con hilos de verdad y la mide contra los cinco criterios | no |

## Cómo se corre

Desde `src/`, con la caja M en Postgres y el organismo fiscal de la Fase 16:

```bash
cd lab && docker compose exec -T postgres psql -U postgres -d alameda < ../16-el-folio-sin-huecos/01_setup.sql && cd ..
cd lab && docker compose exec -T postgres psql -U postgres -d alameda < ../18-bloqueos-deadlocks-y-ddl/boss/01_july.sql && cd ..
uv run python 18-bloqueos-deadlocks-y-ddl/boss/afternoon.py
```

`01_july.sql` se vuelve a correr antes de cada tarde. El punto de partida termina con rechazos del organismo,
muestras tomadas dos veces, una espera de diez segundos y la corrección del formulario perdida en silencio.

## Lo que se entrega

El diagnóstico de cada síntoma con su comando, el arreglo mínimo y `afternoon.py` con los cinco criterios en verde
en dos corridas seguidas. **La solución no se publica**.
