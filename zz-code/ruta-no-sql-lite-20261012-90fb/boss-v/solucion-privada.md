# 💀 Boss V — "Las dos verdades" · solución privada

> **No se publica** (D-05, confirmada por Oskar el 12/10/2026). Verificada el 12/10/2026 contra `camilo-10k`
> (`datasetSha256` `59cf902287e9…`) y la base `expediente` (`workOrder-10k`).

## Cómo se corre

```bash
# desde cursos-bd/ruta-no-sql-lite/src, con base y documental arriba
node 25-poliglota-la-factura/boss/setup.ts
# desde este directorio (node_modules es un enlace a los del curso)
node reconcile.ts --src ../../../cursos-bd/ruta-no-sql-lite/src   # salidas/f25-boss-v-reconcile.log
node seam.ts                                                       # salidas/f25-boss-v-seam.log
```

## 1 · Las discrepancias y su costura

**1794 de 7407 piezas** difieren. Se clasifican **sin `answers.json` de `camilo-10k`**, con la historia de movimientos
de SIGMA, el campo `history` de Camilo y el cuaderno de Yamile (el `answers.json` de `workOrder-10k`, como en la Fase
23). Contra `answers.json`, al final: **1794 de 1794 bien clasificadas**, 0 de más.

| Clase | Piezas | De dónde sale | Quién tiene razón |
|---|---|---|---|
| sin orden: intercambio, la que salió | 622 | SIGMA cambió el estado sin orden (F23) | SIGMA en el estado; nadie tiene el hecho |
| sin orden: regreso del taller | 537 | ídem | ídem |
| sin orden: sustituto de un intercambio | 213 | ídem; solo se separa del regreso con el cuaderno de Yamile | ídem |
| sin orden: se fue con su aeronave | 21 | la salida de la aeronave no es una orden | SIGMA |
| sin orden: el actuador de marzo | 1 | de almacén al taller, sin orden | SIGMA |
| costura: escritura perdida | 100 | doble escritura que falló (F24, 6.1) | SIGMA |
| costura: orden invertido | 100 | dos escrituras concurrentes al revés (F24, 6.1); el mismo estado que la perdida: lo separa `history` | SIGMA |
| costura: contador de un solo lado | 100 | las horas se suman en SIGMA y no llegan | SIGMA |
| derivado: corrección a mano | 100 | el almacén corregido solo en Camilo (F23, ⚰️) | **no se sabe**: puede ser Camilo |

**Lo que Camilo puede defender:** en las 1394 naturales, su sistema es **fiel a las órdenes** —es exactamente la
proyección de los movimientos— y SIGMA es el que cambió sin un hecho. SIGMA tiene el estado correcto (es lo que dice
el generador), pero no puede explicarlo. Ninguno de los dos tiene la verdad entera. Y las 100 correcciones a mano
pueden ser de Camilo con razón: el informe no las da por malas, pide el documento.

## 2 · La fuente de verdad, dato por dato

- **Estado y ubicación de la pieza:** SIGMA, **y como proyección** de hechos: el regreso del taller, el intercambio y
  el envío desde almacén pasan a ser filas (F23, 6.4). Sin eso, SIGMA sigue siendo una segunda verdad interna.
- **Horas y ciclos:** SIGMA, como suma de las estadías (`part_stint`, F13), no como contador que se actualiza.
- **Historia de la pieza:** los movimientos de SIGMA más los eventos nuevos; la `history` de Camilo se rearma desde ahí.

## 3 · Veredicto

**El sistema de Camilo se retira como fuente y se queda como índice reconstruible**, con una condición: que los tres
eventos sin registro se vuelvan filas en SIGMA. Mientras no lo sean, rearmar Camilo desde SIGMA copia el estado sin
su porqué. El rearmado mide 0,1 s para 7407 componentes, 0 distintos de SIGMA (`reconcile.ts`, punto 4).
**Condición de cambio:** si las 100 correcciones a mano resultan respaldadas por documentos del aliado, Camilo tiene
datos que SIGMA no, y antes de retirarlo hay que llevarlos a SIGMA por una bandeja de entrada (F24, 6.6).

## 4 · La costura

SIGMA es de un proveedor: no se le agrega código. **Outbox por trigger** (no pide `wal_level=logical`): un `AFTER
UPDATE` en `part` deja la fila en la misma transacción; un relevo lleva el estado actual a MongoDB.
Medido (`seam.ts`, 2000 cambios a 200/s, hacia una copia de la colección): **2000 de 2000, p50 18 ms, p99 108 ms,
máx. 125 ms**, con hasta 20 ms del sondeo del observador. CDC sería la alternativa con la factura de la Fase 24.

## 5 · La factura, lado a lado

| | Retirar Camilo | Quedarse como índice |
|---|---|---|
| motores | 4 (el diseño de F23) | 5 |
| RAM en reposo (a02) | 210 MiB | 452 MiB |
| respaldos | 1 (Postgres) | 1: Mongo se rearma desde SIGMA, no se respalda |
| licencias | TSL | TSL y SSPL |
| costura | ninguna nueva | el outbox por trigger y su relevo |
| personas | el equipo de Postgres y alguien de CouchDB | más alguien que sepa Mongo (hoy, solo Camilo) |
| lo que se gana | — | la pantalla de Camilo, sin reescribirla |

**Recomendación:** retirar, después de llevar las correcciones respaldadas a SIGMA. Quedarse como índice es defendible
si la pantalla del taller de componentes no se puede reescribir este año; en ese caso, Mongo deja de respaldarse y se
rearma, y la factura sube en una persona, no en un respaldo.
