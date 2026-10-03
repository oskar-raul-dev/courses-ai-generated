# 🪞 Instintos

> **Curso:** Ruta NoSQL Lite · documento vivo
> **Qué es:** cada punto del curso donde **el instinto relacional falla**, con la medición que lo
> demuestra. Es el documento que mejor resume la ruta entera, y el que más sentido tiene leer solo.
> **Formato de cada entrada** (`prompts/formato-bitacora-de-medicion.md` §7): el instinto en tu voz ·
> por qué es razonable · dónde se rompe · la medición que lo prueba, con enlace a la
> [bitácora](bitacora-de-medicion.md) · y **la pregunta del instrumento** que lo habría anticipado.

---

> 🧭 **Un instinto que falla no es un instinto malo.** Cada uno de estos funciona en relacional, y
> por eso es razonable llevarlo a otra familia. Lo que este documento registra es el punto exacto
> donde deja de funcionar, con el número delante.

---

## Índice

| # | Familia | El instinto | Fase |
|---|---|---|---|
| 1 | documental | *"Normalizo, que para eso aprendí"* | [03](03-documental-levantar-y-modelar.md) |
| 2 | clave-valor | *"Le pongo un índice secundario"* | [05](05-clave-valor-levantar-y-modelar.md) |
| 3 | vectorial | *"Esto es buscar con `LIKE`, pero mejor"* | [15](15-vectorial-levantar-y-modelar.md) |

---

## 🍃 1 · "Normalizo, que para eso aprendí"

- **El instinto, en tu voz:** una colección por entidad, referencias por `_id`, y los cruces cuando
  haga falta.
- **Por qué es razonable:** la normalización evita la redundancia, y la redundancia es lo que se
  desincroniza. En Postgres funciona porque el `JOIN` se resuelve en el servidor, en un viaje.
- **Dónde se rompe:** en Mongo, la ficha normalizada y armada desde la aplicación cuesta **25 viajes**
  donde la embebida cuesta **1**; `$lookup` baja a un viaje pero, sin índice en el campo ajeno, recorre
  **1 000 000** de documentos por ficha. El cruce no es gratis: se decide al modelar.
- **La medición:** [M-02](bitacora-de-medicion.md#m-02--la-ficha-completa-de-una-aeronave-de-cuatro-maneras) y
  [M-03](bitacora-de-medicion.md#m-03--lo-que-lookup-examina-por-dentro).
- **La pregunta que lo habría anticipado:** la 3, **¿cuál es la unidad de lectura?**
- **Y el matiz de la Fase 04:** en Postgres, la misma ficha en una consulta también cuesta un viaje
  (50 filas examinadas). El instinto no falla por normalizar; falla por creer que en documental se
  consulta como en SQL.

## 🔑 2 · "Le pongo un índice secundario"

- **El instinto, en tu voz:** las sesiones se buscan por identificador, pero la pantalla de
  supervisión necesita las de un técnico: un índice sobre `technicianId` y listo.
- **Por qué es razonable:** en Postgres es una línea, y desde ese momento cada escritura lo mantiene
  sola, en la misma transacción que la fila.
- **Dónde se rompe:** Valkey no tiene índices secundarios. Sin la clave, las sesiones de un técnico
  cuestan un `SCAN` de **100 000 claves en 202 viajes**; con un set escrito a mano, **2 viajes**. Pero
  el set es otra estructura que mantiene tu código, y el TTL no pasa por tu código: tras vencer 1000
  sesiones, el set sigue con **1000 miembros y ninguno existe**.
- **La medición:** [M-07](bitacora-de-medicion.md#m-07--sesiones-el-índice-escrito-a-mano-y-lo-que-deja-atrás-el-ttl).
- **La pregunta que lo habría anticipado:** la 2, **¿conoces tus consultas de antemano, y son
  estables?** En clave-valor, cada consulta nueva es otra estructura que mantener a mano.

## 🧬 3 · "Esto es buscar con `LIKE`, pero mejor"

- **El instinto, en tu voz:** un `LIKE` que entiende sinónimos y faltas de ortografía: recibe un texto
  y devuelve los reportes que tratan de eso.
- **Por qué es razonable:** los dos reciben un texto y devuelven reportes, y el vector encuentra
  *"golpeteo al extender"* cuando buscas *"ruido metálico"*, cosa que `LIKE` no hace.
- **Dónde se rompe:** el vector no devuelve un conjunto, devuelve un orden, y siempre devuelve k. Arriba
  es impecable —**100 de 100** del tipo de avería correcto—, pero pedidos tantos como hay de ese tipo,
  acierta **728 de 1258**; una receta de arepas devuelve **10** reportes; y una matrícula buscada por
  parecido encuentra **4 de 186**.
- **La medición:** [M-11](bitacora-de-medicion.md#m-11--like-contra-vectores-y-la-búsqueda-exacta-hecha-por-parecido).
- **La pregunta que lo habría anticipado:** la 5, **¿exactitud o parecido?** Es la primera familia del
  curso que devuelve las parecidas, y se evalúa contra una verdad de referencia, no contra un error.
