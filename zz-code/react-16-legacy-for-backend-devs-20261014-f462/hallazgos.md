# Hallazgos de la verificación previa (P7) — 14/10/2026

Máquina: macOS, arm64 (Apple Silicon), Docker 29.8.0. Todo corrió en contenedores con
`--label curso=react16`, sin puertos publicados al host, sin nada instalado en el host.
Salidas en `salidas/`; código de prueba en `trabajo/`.

## H1 · Imágenes congeladas y arm64

Las cinco imágenes del curso publican `linux/arm64` nativo: no hace falta emulación.
`node:14.21.3`, `golang:1.19.13`, `postgres:13`, `cypress/included:10.11.0`,
`grafana/k6:1.5.0`. Fuente: `salidas/manifiestos-plataformas.txt`. Cypress 10.11.0
responde `cypress --version` dentro de su imagen (`salidas/cypress-version.txt`).
**Consecuencia:** el smoke de F10 sí puede correr en `cypress/included:10.11.0`, sin
instalar nada en el host; queda para decidir en T6, no es una «no verificación».

## H2 · k6 fijado en `grafana/k6:1.5.0` (fecha 14/10/2026)

Versiones consultadas, todas con manifiesto: 1.0.0, 0.57.0, 1.1.0 a 1.5.0
(`salidas/k6-versiones-consultadas.txt`). Se fija **1.5.0**, arm64 incluido. `latest`
queda descartado (DR-04). **Decisión para T0:** entrada `Dnn` nueva en
`00-decisiones-y-versiones.md`.

## H3 · El giro ingenuo, medido

Escenario: 50 VUs, 1.500 claves de giro, cada una enviada **dos veces** (el reintento de
un cliente que perdió la respuesta). Stock inicial de `esclusa-de-oro`: 1.000. Ingenuo =
leer stock, decidir y escribir sin transacción ni clave única (`servidor.js`, modo
`ingenuo`).

| Medida | Ingenuo | Transaccional |
|---|---|---|
| Premios registrados (`spin_log`) | 1.014 | 1.000 |
| Claves con dos premios (dobles) | **495** | 0 |
| Stock restante | −14 | 0 |
| Stock excedido | **14** | 0 |
| p95 de la petición (k6) | 89,21 ms | 54,11 ms |

Fuente: `salidas/sql-giro-*.txt`, `salidas/k6-giro-*.txt`. Las cifras cambian de una
corrida a otra; **F03, be00 y be05 publican las de su corrida, no estas** (plan §5.1).

Nota de arnés, corregida y conservada: en el primer intento el esquema llevaba
`UNIQUE (key)` también en el modo ingenuo. El segundo intento de cada clave fallaba con
23505 después de descontar el stock, y el ingenuo salía protegido por accidente. La
salida mala está en `salidas/intento-1-indice-unico-en-ingenuo/`. La restricción ahora
solo se crea en el modo transaccional (`correr-giro.sh`).

Nota de lectura: k6 cuenta como fallo los 409 de las peticiones posteriores al
agotamiento (3.000 − 1.014 = 1.986 y 3.000 − 1.000 = 2.000). No son errores de servidor.

## H4 · La trampa de `math/rand` está confirmada

Mismo programa (8 sorteos con `rand.Intn(10000)`, sin semilla), dos corridas por versión
(`salidas/math-rand-1.19-vs-1.20.txt`):

- **Go 1.19.13:** `[8081 7887 1847 4059 2081 1318 4425 2540]` en las dos corridas. Se
  repite entre arranques.
- **Go 1.20.14:** dos secuencias distintas.

Confirma be-17 y la nota de DR-02. Y, como dice la propuesta, `oddsAudit` no lo ve
(H5).

## H5 · `oddsAudit`: la banda y el chi-cuadrado, con su tasa de falsas alarmas

Prototipo en `trabajo/odds/odds.js`, PRNG sembrado, 20.000 giros por corrida, 300
corridas por escenario, pesos configurados `[3000,2000,1500,1500,1000,800,150,50]` (el
último segmento, 0,5 %). La rueda que se acomoda reparte 2 % en ese segmento
(`salidas/odds-audit-prototipo.txt`).

- **Rueda honesta:** alarma (banda ±3σ o chi-cuadrado) en **6 %** de las corridas. El
  chi-cuadrado con α = 0,05 alarma por diseño en ~5 %; la banda aporta el resto.
- **Rueda que se acomoda:** alarma en **100 %** de las corridas.
- Valor crítico χ² con 7 grados de libertad y α = 0,05: **14,067**.

**Consecuencia para A14 y F08:** la tasa de falsas alarmas del chi-cuadrado es la del
nivel de significancia, no cero. El apéndice tiene que decirlo, y `oddsAudit` debe
reportar las dos señales por separado. (Pendiente: separar la tasa de la banda sola;
no se midió en esta corrida.)

## H6 · El prorrateo de 20,99 USD entre 500 giros es exacto en centavos enteros

2.099 centavos entre 500 giros: base 4, con +1 centavo en 99 giros; suma 2.099
(`salidas/odds-audit-prototipo.txt`). Cada giro vale 4,198 centavos de media. Sin
floats no hay centavo perdido; el incidente 18 necesita el float (propuesta §7).

## H7 · CRA 4 hoy: el comando del plan no funciona tal cual

- `npx create-react-app@4.0.3 esclusa-app --use-npm` con `--yes` delante: npm 6 intenta
  instalar `esclusa-app` como paquete (`salidas/cra4-intento1-npx-yes-error.log`).
- Sin `--yes`: CRA 4.0.3 **aborta con código 1** porque existe una versión más nueva en
  el registro (5.1.0). El mensaje habla de «instalación global», pero es el chequeo de
  versión (`salidas/cra4-intento2-npx-error-instalacion-global.log`).
- `npm init react-app esclusa-app`: instala **el template actual** (React 19, react-scripts
  5.0.1), no CRA 4. Es descartado (`salidas/cra4-intento3-npm-init-log.txt`).
- Andamiaje manual con `react-scripts@4.0.3`: el `init.js` no resuelve el template
  `cra-template` desde su carpeta. **Sin resolver** (`salidas/cra4-init-rs4.log`).
- **Lo que sí se verificó:** `react@16.14.0`, `react-dom@16.14.0`, `react-scripts@4.0.3`
  se resuelven juntos con npm 6.14.18 en `node:14.21.3`; `jest` queda en 26.6.0. Solo hay
  avisos de deprecación, sin conflictos de pares (`salidas/resolucion-react16-cra4.log`).

**Decisión para T1, antes de escribir F00:** cómo se genera el proyecto de F00 sin el
comando de `npx`. Opciones: un `package.json` de referencia con esas versiones y
`create-react-app` solo como guía, o resolver el template. El plan §5 F00 supone CRA 4
«como dice P7»: ese supuesto queda parcialmente falso y se corrige en la guía (P8).

## H8 · Pipeline de be09 (D23): el método de validación queda fijado

Sin repositorio ni runner, se valida con **`rhysd/actionlint:1.7.9`** (imagen fija,
sin instalar nada) y con los comandos del workflow dentro de `golang:1.19.13` y
`postgres:13`. actionlint detecta un error de sintaxis, una clave `with` en un `run` y
una expresión a un paso inexistente (`salidas/actionlint-roto.txt`). Un workflow válido
sale con un aviso: `actions/checkout@v3` es demasiado viejo para GitHub Actions
(`salidas/actionlint-ok.txt`). **Para be09:** usar `actions/checkout@v4` o superior, y
la verificación dice qué versión se usó.

## H9 · cgo y migraciones compilan en arm64

`mattn/go-sqlite3` v1.14.16, `lib/pq` v1.10.7 y `golang-migrate` v4.15.2 (D19 y D20)
compilan con `CGO_ENABLED=1` en `golang:1.19.13`, arm64. SQLite en tiempo de ejecución:
3.39.4 (`salidas/cgo-migrate-golang1.19.txt`). Cumple la cota de D18 (≥ 3.35). **No
verificado:** la ejecución de las migraciones contra Postgres; eso es de be02 (T7).

## H10 · Mock de Google Play: pago en efectivo pendiente

json-server 0.16.3 con una ruta Express de 4.17.1 devuelve `pending` mientras dura la
demora y `confirmed` después (`salidas/google-play-efectivo-pendiente.txt`, demora de
3 s). Modelo suficiente para F07.

## H11 · Inventario de Docker: no tocamos lo ajeno

La máquina tiene 5 contenedores y 21 volúmenes que **no son del curso** (otros proyectos:
lab de Alameda, condor, fgapp, mdm-lab, bd-lab). No se tocaron. El inventario inicial
está en `salidas/inventario-inicial-*.txt`. Lo que se creó (red, Postgres de prueba,
contenedores de la app) se borra al cerrar, con sus volúmenes. Ver `README.md`.

## Pendientes que no cierran P7

- Tasa de falsas alarmas de la banda sola (H5).
- Andamiaje de CRA 4 (H7).
- Pipeline de be09 sin ejecutar en un runner real (H8).

## H12 · Cambios de contenedores ajenos durante la sesión (no atribuidos)

Entre el inventario inicial y el final cambiaron recursos que **no son del curso**:
`condor-lab-busqueda-1` y su volumen `condor-lab_busqueda-data` ya no están; aparecen
`condor-lab-newsql-1` (volumen `condor-lab_newsql-data`), `ev-kafka-1..3` con sus
volúmenes y `clinical-lab-amd64-app-1`. Ningún comando de esta sesión toca esos
nombres: todos los recursos creados llevan `curso=react16` o `react16-p7-*` / `r16p7-*`,
y se borraron (`salidas/inventario-final-*.txt`). El cambio viene de otra actividad en
la máquina. Lo registro para que el autor lo confirme; no se actuó sobre ellos.
