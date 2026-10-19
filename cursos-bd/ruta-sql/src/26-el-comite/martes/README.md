# 🏆 "Un martes" — el boss global

El encargo cierra en la [Fase 26](../../../26-el-comite.md#55-un-martes-el-boss-global): **la facturación de un martes
corre entera sobre la base nueva, mientras la vieja sigue viva al lado**. Es la presentación semanal a cada obra
social, con el precio del convenio vigente el día de la práctica, la cantidad, el coseguro, el tope por afiliado y
las prácticas que se facturan juntas.

## Qué hay

| Archivo | Qué es | ¿Se edita? |
|---|---|---|
| `00_base.sql` | lo que pone el curso: los supuestos que la caja no trae (el aumento del 1 de octubre, los topes, la composición de paneles), las tablas de la presentación y el rol `facturacion`, que no ve legacy | no |
| `01_setup.sql` | tu migración: lo que la base nueva todavía no tiene y la facturación necesita. El punto de partida no agrega nada | **sí** |
| `flujo.py` | `presentar(conn, desde)`: el punto de partida es la planilla de los martes pasada a SQL tal como estaba | **sí** |
| `arnes.py` | juega el martes 6 de octubre de 2026 con la semana del 28/09 al 04/10 y evalúa cinco criterios (C1 a C5) | no |

## Cómo se corre

Con el modelo entero de la Fase 25 (las anchas migradas, la cantidad de lo facturado y el CDC), desde `src/`:

```bash
uv run python 26-el-comite/martes/arnes.py              # el punto de partida: 0 de 5
uv run python 26-el-comite/martes/arnes.py mi-martes/   # tu copia del directorio
```

El arnés corre `00_base.sql`, vuelve a preparar el CDC de la Fase 25, corre tu `01_setup.sql` y llama a tu
`flujo.py`: a la mañana, recepción todavía escribe en legacy; al mediodía se emite la presentación; a la tarde
llegan dos prácticas más. Al final imprime la reconciliación con la planilla de Matías, por obra social.

**La solución no se publica**: pasa los cinco criterios, y lo que la fase sí cuenta es qué tuvo que agregarle a la
base nueva.
