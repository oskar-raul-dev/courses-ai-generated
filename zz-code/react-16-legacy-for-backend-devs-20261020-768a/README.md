# 🧪 react-16-legacy-for-backend-devs-20261020-768a · cómo correr estas pruebas

> **Curso:** react-16-legacy-for-backend-devs · **Tanda:** T12 · **Creado:** 2026-10-20
> **Propósito:** regresión completa de §5.1 desde un clon limpio del repo de prueba, tras R19 y measure.js
> Las reglas, en `zz-code/README.md` § "El README de cada directorio".

## 1. 🎯 Qué se prueba y para qué

| Prueba | Script | Para qué |
|---|---|---|
| `npm ci` y la suite de Jest (o el build, si el tag no tiene pruebas) en los diez tags de cierre; `go test -race -p 1` desde be04 | `trabajo/regresion.sh` | plan §5.1, T12 |
| F03 §5.4 otra vez: seis corridas de `traffic` + `measure` | `trabajo/f03-medir.sh` | el `measure.js` con el filtro de claves `spin-N` |
| Incidentes 11, 14 y 21 (front) y be-09, be-15, be-17 y be-18 (BE), en rama (rojo) y en fase (verde) | `trabajo/incidentes.sh fe`, `be`, `be15` | que sigan reproduciendo su síntoma |
| k6 de be05 (una corrida por fila de su tabla) y de be08 (las tres filas) | `trabajo/k6-be05.sh`, `trabajo/k6-todo.sh` (solo su parte de be08 vale; ver §5) | comparar en forma y rango con lo publicado |
| La smoke de F10 y la spec de R19 (`/spin-log`, y `/bitacora` da 404) | `trabajo/e2e.sh` | R19 en el navegador |

## 2. 🛠️ Prerrequisitos

Docker con `node:14.21.3`, `golang:1.19.13`, `postgres:13`, `grafana/k6:1.5.0` y `cypress/included:10.11.0`. Nada en el host salvo git y python3.

## 3. 🧭 Reglas antes de correr

Inventario en `salidas/{contenedores,volumenes,redes}-antes.txt`. Todo lleva `--label curso=react16` y el prefijo `r16t12-`. Ningún puerto publicado: Cypress corre en el espacio de red del contenedor de la consola.

## 4. ▶️ Cómo se corre

Desde este directorio, en este orden (los tres primeros crean `r16t12-pg` y `r16t12-net`; no corren a la par porque comparten la base):

```bash
bash trabajo/regresion.sh                      # o SOLO_GO=1 bash trabajo/regresion.sh <tag> …
bash trabajo/f03-medir.sh
bash trabajo/incidentes.sh fe; bash trabajo/incidentes.sh be; bash trabajo/incidentes.sh be15
bash trabajo/k6-be05.sh
bash trabajo/k6-todo.sh                        # solo sus tres corridas de be08 (ver §5)
bash trabajo/e2e.sh
```

## 5. 📏 Cómo se mide

Portátil arm64, todo en contenedores de la misma red. Tres errores del arnés, corregidos y repetidos (los intentos quedaron en `salidas/` con sufijo):

- `go test ./...` contra Postgres sin `-p 1`: los paquetes migran la misma base a la vez y se pisan (`regresion-todo-intento1-sin-p1.log`). El curso ya dice `-p 1` (be06).
- Copiar solo `server/` al contenedor: las pruebas de contrato siembran desde `../mock/db.json`.
- El k6 de be05 con `giro.js` y `medicion.sql` de master: el arnés de carga cambió desde be07, y con la rueda de be05 da 300 giros (`be05-k6-*-intento1-arnes-de-master.txt`). `be05-k6.sh` ahora los toma de `fase-be05`. Las dos primeras corridas de `k6-todo.sh` además no esperaron el arranque (ahora espera hasta 400 s).

## 6. 🧮 Los intermedios que amasan la salida

`measure.js` imprime el JSON por corrida; `medicion.sql` e `invariantes.sql` cuentan en SQL; `conteo21.js` cuenta por segmento y calcula el χ². Ningún promedio: el curso publica rangos.

## 7. ✅ Qué se espera ver (20/10/2026)

- Regresión: build en verde en F02–F08; Jest 25/25 desde F11; `go test` en verde en be04, be05, be07 y be09; regla del track BE vacía.
- F03: 1.009, 1.021, 1.044, 1.048, 1.001 y 1.000 premios (claves dobles 500–524).
- Incidentes: 11 `Expected 1 / Received 2`; 14 las consultas siguen tras el logout; 21 χ² 808,35 y avatar común 505; be-09 1.500 entregadas; be-17 misma secuencia en dos arranques; be-18 200 en vez de 409; be-15 `LastInsertId is not supported by this driver`. Todas verdes en su fase.
- k6 be05: 2019 a 50/s 1.000 y 500 dobles; las dos estrategias 1.000 + 500 sustitutos en todas las filas; 2019 con 50 jugadores 1.031/515; con 200, 1.070/515 (debajo del rango publicado de 1.077–1.088).
- k6 be08: `pico` en verde (p95 8,52 ms); 200 jugadores, 99 (p95 699,59 ms) e invariantes en 0; `incidente/be-09`, k6 en 0 e invariantes en 3 (1.500 Esclusas).
- Cypress: 2/2.

## 8. 📂 Salidas

Todo en `salidas/`, con el nombre del script. Ya no está en disco (comprobado el 25/10/2026); las cifras de §7 son
el registro y se rehacen corriendo §4. Al curso pasaron F03 §5.4 y la nota de be05 §8.

## 9. 🧹 Limpieza

Hecha el 20/10/2026: `docker rm -f -v` de `r16t12-pg` (y de los `r16t7-*` de `…6436`), `docker volume rm r16t12-gomod r16t12-npm r16t7-gomod`, `docker network rm r16t12-net r16t7-net`, y las imágenes construidas `r16t10-*` y `r16t11-*`. Las imágenes descargadas quedan. Nunca `prune`.

## 10. 🚫 Qué se dejó fuera

`etapas/*/node_modules` (lo regenera `regresion.sh`).
