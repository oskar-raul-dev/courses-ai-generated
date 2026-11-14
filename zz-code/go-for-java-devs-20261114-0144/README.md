# 🧪 go-for-java-devs-20261114-0144 · cómo correr estas pruebas

> **Curso:** go-for-java-devs · **Tandas:** S0–S11 (cerradas el 14/11/2026) · **Creado:** 2026-11-14
> **Propósito:** ejecutar las salidas de las fases por tandas y, en S10, escribir y medir el gemelo
> Spring Boot de ClearingHouse. El plan con el estado y la tabla de cada tanda está en
> `plan-de-ejecucion-final.md` (copia del desechable del curso, borrado el 14/11/2026).

## 1. 🎯 Qué se prueba y para qué

Cada tanda reconstruye el repositorio del lector a partir de los bloques de las fases y corre los
comandos de cada fase, en orden, para comparar su salida con la del texto.

| Script | Fase | Qué comprueba |
|---|---|---|
| `scripts/s1-f00.sh` | F00 | Toolchains, `go mod`, `build-info`, `build-all.sh` (B-01), `golangci-lint` y el `epoch-test` original |
| `scripts/s1-f00b.sh` | F00 | El código del envoltorio `golang.org/dl`, la versión de Go que exige cada `golangci-lint` v2 y `strings.Cut` con `go 1.13` |
| `scripts/s1-f00c.sh` | F00 | La receta de Apple Silicon, emulada: `GOARCH=amd64 go install` con `GOBIN` y sin él |
| `scripts/s1-f00d.sh` | F00 | El `epoch-test` rehecho con `strings.Cut` |
| `scripts/s1-f00e.sh` | F00 | `golangci-lint@v2.12.2` y `make` en la raíz con el `Makefile` original (falla) |
| `scripts/s1-f00f.sh` | F00 | `make fmt vet lint test`, `cover` y `clean` con el `Makefile` que recorre módulos |
| `scripts/s1-compose.sh` | F00 | El `compose.yaml` del curso, en el host, hasta `healthy`, y el perfil `rs` |
| `scripts/s1-f01.sh` | F01 | Los tres labs, OpsReport, los fragmentos con salida en comentario, los mensajes de go1.13 y el experimento de retención (B-02 y B-03 en una pasada) |
| `scripts/s1-regresion.sh` | F00–F01 | Lo que quedó en el curso, re-extraído: `gofmt`, `go1.13 vet/build`, OpsReport y `make fmt vet lint test` |


### Herramientas (S2 en adelante)

| Archivo | Qué hace |
|---|---|
| `reconstruir.sh NN` | Rehace `lector/` desde cero con las fases 00..NN, aplica `completar.py` y deja en `scripts/fusionados.txt` los archivos a los que `prep.sh` les pasa `goimports` |
| `extraer.py` | Además de lo de S1: fusiona parches (un bloque con ruta y sin `package` reemplaza las declaraciones homónimas), deduce el `package` de un archivo nuevo, salta el `//go:build` inicial y solo escribe rutas del repositorio (`labs/`, `services/`…) |
| `completar.py` | Las piezas que las fases omiten a propósito, una regla por caso; `stubs/<tanda>/` guarda las que son archivos enteros |
| `gofmt-curso.py [--fragmentos] [--aplicar]` | `gofmt` sobre los bloques Go del curso (a los fragmentos solo les cambia espacios) |
| `imports-curso.py [--aplicar]` | Añade a los bloques completos del curso los imports que faltan: los de la biblioteca estándar (según `goimports`) y los externos conocidos |
| `salidas-de.py FASE.md` | Lista lo que una fase da como salida |
| `nota-fechada.py FASE.md "texto"` | La nota de la regla 5 del plan, antes de `## 💻 6.` |
| `versiones-compatibles.sh` | La última versión de cada dependencia que compila con go1.25.1 |
| `ref1.py B-NN texto.md` | Inserta "Resultados de REF-1" en una entrada de `BENCHMARKS.md`; los textos están en `ref1-textos/` |
| `scripts/prep.sh`, `scripts/modulos.tsv` | Se incluye al principio de cada guion: instala `goimports`, `jq` y `make`, y crea los `go.mod` que falten |
| `scripts/compila.sh TOOLCHAIN dir…` | Todos los errores de compilación de cada módulo (`-gcflags=-e`) |
| `ch-go/` | ClearingHouse en Go, versión de referencia del duelo (no se publica). `serve`, `seed` y `close` |
| `b07/` | Los programas de B-07 (goroutines frente a hilos de la JVM) |

### Infraestructura (S6 en adelante)

Red `gfjd-net`; contenedores `gfjd-pg` (`postgres:16-alpine`), `gfjd-mongo` (`mongo:7`) y
`gfjd-valkey` (`valkey/valkey:8-alpine`); volúmenes `gfjd-gopath`, `gfjd-sdk` y `gfjd-m2`. Todo
con la etiqueta `curso=go-for-java-devs` y sin puertos publicados. `correr.sh` monta además
`ch-go/` en `/ch` y el gemelo del curso en `/spring`, y se une a la red con `NET=gfjd-net`.

### Guiones por tanda

`scripts/s2-*.sh` a `scripts/s9-*.sh` siguen el patrón de S1: uno por fase o por medición, cada
uno con su log en `corridas/`. Los del duelo corren en el host porque lanzan contenedores:
`s10-go.sh` y `s10-contract.sh` (la suite de contrato), `s10-duelo-cierre.sh` (el cierre de un
millón y el md5 del libro mayor; `SOLO_SPRING=1` repite solo Spring), `s10-duelo-http.sh`
(arranque, memoria, latencia, CPU por petición y pico), `s9-b07.sh` y `s9-b20-b21.sh`.

## 2. 🛠️ Prerrequisitos

- Docker (probado con Engine 29.9.3 arm64 y Compose 5.7.0) y Python 3 para `extraer.py`.
- Imagen `golang:1.25.1-bookworm`. Dentro, `go1.13` se instala con el envoltorio `golang.org/dl` en
  el volumen `gfjd-sdk`, y el caché de módulos vive en el volumen `gfjd-gopath`. Los dos llevan la
  etiqueta `curso=go-for-java-devs`.
- Para `s1-compose.sh`: `postgres:16-alpine`, `mongo:7` y `valkey/valkey:8-alpine`, que se bajan
  solas.
- Red, porque `go install`, `go get` y `curl` van a `proxy.golang.org` y `dl.google.com`.

## 3. 🧭 Reglas antes de correr

```bash
mkdir -p salidas
{ docker ps -a --format '{{.Names}}\t{{.Image}}'; echo ---; docker volume ls -q; echo ---; \
  docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}'; } > salidas/inventario-docker-inicial.log
docker volume create --label curso=go-for-java-devs gfjd-gopath
docker volume create --label curso=go-for-java-devs gfjd-sdk
```

Todo corre con `docker run --rm --label curso=go-for-java-devs`. El compose de prueba no publica
puertos (`scripts/compose.prueba.yaml` los quita con `!reset`) y usa el proyecto `gfjd`.

## 4. ▶️ Cómo se corre

Desde este directorio:

```bash
C=../../cursos-algoritmos-lenguajes/go-for-java-devs
python3 extraer.py $C/00-instalacion-ambiente-y-tooling.md $C/01-sintaxis-y-valores.md
rm -f lector/main.go      # el main.go suelto del epoch-test de la F00 no va en la raíz
scripts/correr.sh scripts/s1-f00.sh corridas/s1-f00.log
scripts/correr.sh scripts/s1-f01.sh corridas/s1-f01.log
scripts/s1-compose.sh     # en el host; escribe corridas/s1-compose.log
scripts/correr.sh scripts/s1-regresion.sh corridas/s1-regresion.log
```

- `extraer.py FASE.md…` escribe en `lector/` cada bloque cuya primera línea es una ruta, y guarda cada
  versión en `salidas/versiones/`. Con `--listar`, solo lista.
- `scripts/correr.sh SCRIPT LOG` monta `lector/` como `~/dev/meridian` y `scripts/` como `/scripts`, y
  escribe la salida en pantalla y en `LOG`.
- El `Makefile` de `lector/` se tomó de la F00 a mano (`extraer.py` no reconoce `# Makefile`, porque el
  bloque es `makefile`); desde S1 es el corregido que ahora está en el curso.

## 5. 📏 Cómo se mide

No es un banco de pruebas, salvo dos cifras sueltas. El tiempo de `build-all.sh` (14,5 s de reloj con
la caché vacía) y la pasada de los benchmarks de `text-toolkit` (`-count=1`) se tomaron en el
contenedor `linux/arm64` de la máquina del autor. Solo sirven para confirmar que los comandos
funcionan. Las cifras publicables de B-01 a B-03 son tarea de S9.

## 6. 🧮 Los intermedios que amasan la salida

Ninguno: las salidas se comparan a ojo contra el bloque de la fase, y la tabla de S1 en el plan
registra cada caso. Lo único derivado es `ls -l | awk '{print $5, $9}'` para los tamaños de
`-s -w`.

## 7. ✅ Qué se espera ver

Las salidas de referencia son las de `corridas/` del 14/11/2026. `s1-regresion.log` tiene que terminar
en `exit 0` después de `make fmt vet lint test`.

## 8. 📂 Salidas

- `corridas/` (versionado): un log por script.
- `salidas/` (ignorado): el inventario inicial de Docker y `versiones/` de `extraer.py`. Borrado el
  14/11/2026, al cerrar; `extraer.py` y §3 lo vuelven a crear.
- `lector/` (versionado, salvo `bin/`): el repositorio del lector, tal como queda al cierre de cada
  tanda.

Se copió al curso: el `Makefile`, el `.golangci.yml`, la receta de Apple Silicon, el `epoch-test`
rehecho y las salidas corregidas (tabla de S1).

## 9. 🧹 Limpieza

```bash
docker compose -p gfjd -f lector/compose.yaml -f scripts/compose.prueba.yaml --profile rs down -v
docker volume rm gfjd-gopath gfjd-sdk          # solo al cerrar todas las tandas
```

Se limpia solo por la etiqueta o el proyecto `gfjd`. **Hecho el 14/11/2026**: contenedores, red,
volúmenes e imágenes `gfjd-*` borrados. Las imágenes base (`golang`, `postgres`, `mongo`, `valkey`,
Maven, Temurin y GraalVM) se quedan; para repetir, se vuelven a crear con los comandos de §3.

## 10. 🙈 Qué se dejó fuera

Los binarios (`bin/`, ignorados por git), el SDK de go1.13 y el caché de módulos (volúmenes). La
instalación en macOS no se probó: el contenedor es Linux.
