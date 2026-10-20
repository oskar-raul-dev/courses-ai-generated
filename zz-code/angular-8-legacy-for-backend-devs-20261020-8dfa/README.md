# 🧪 angular-8-legacy-for-backend-devs-20261020-8dfa · cómo correr estas pruebas

> **Curso:** angular-8-legacy-for-backend-devs · **Tanda:** kind-rosetta (anexo al plan Apple Silicon, cerrado) · **Creado:** 2026-10-20
> **Propósito:** el pendiente de A13: ¿un pod de kind con una imagen amd64 corre traducido por Rosetta o muere con
> `exec format error` como decía la ⚠️ de F14 §5.1? Y el H-host de `npm ci` en el Mac con Node x64, preparado para el autor.

## 1. 🎯 Qué se prueba y para qué

| Prueba | Script | Alimenta | Hallazgo |
|---|---|---|---|
| Pods amd64 y arm64 en kind sobre la VM arm64 de Docker Desktop | `kind-rosetta.sh` | F14 §5.1, A09 §7, A12 §6, A13 §3/§7/§9, forense F14 y master | H-K-1, H-K-2 |
| Node 14.21.3 amd64 en un pod | `kind-node-x64.sh` | F14 §5.1 | H-K-3 |
| Correcciones del curso | `corregir-curso.py` | los de arriba | — |
| `npm ci` de LabCore en el Mac, Node x64 (**H-host, lo corrió el autor**) | `host-npm-ci.sh` | F0 §5.1, A12 §2 (`fsevents`) | H-H-1 |

### Hallazgos (20/10/2026)

- **H-K-1 · El pod amd64 corre** (`salidas/kind-rosetta.log`): kind v0.33.0, `kindest/node:v1.27.3` (la de F14), Docker
  Desktop 4.92.0 (`docker-desktop / aarch64`). Imágenes de una sola arquitectura (`--provenance=false`): `a8-kind-amd64:1`
  `ARCH=amd64` y `a8-kind-arm64:1`. Tras `kind load`, los dos pods `Running`; logs `ARCH=x86_64` y `ARCH=aarch64`. Desde el
  nodo, el proceso amd64 es `/run/rosetta/rosetta /bin/sleep sleep 3600`. La ⚠️ de F14 §5.1 era falsa en este runtime.
- **H-K-2 · binfmt en la VM** (mismo log, visto desde el nodo, que comparte el kernel de la VM): `rosetta` (`/run/rosetta/rosetta`)
  y `rosetta-wrapper` habilitados, **y también** `x86_64` → `/usr/bin/qemu-x86_64` y otros QEMU. Aun sin Rosetta, Docker
  Desktop traduciría con QEMU. El `exec format error` no se reproduce en este Mac; queda para el caso imagen arm64 → nodo amd64.
- **H-K-3 · Node x64 en el pod** (`salidas/kind-node-x64.log`): `ARCH=x64 v14.21.3`; el proceso es
  `/run/rosetta/rosetta /usr/local/bin/node node --no-opt -r /proc/.reset -e …`. **Observación sin conclusión:** el
  `rosetta-wrapper` de Docker Desktop le agrega `--no-opt` a `node` (V8 sin optimizar), lo que podría explicar parte de la
  lentitud amd64 de A13 §4 (`ng build` 15 s frente a 1 min 13 s). No se midió aparte ni se publicó.
- **H-H-1 · `npm ci` en el Mac** (20/10/2026, 09:39, lo corrió el autor; `salidas/host-npm-ci.log`, `host-npm-ci-completo.log`,
  `host-build.log`): macOS 26.7.1, `uname -m` arm64, Node v14.21.3 `arch=x64` (Mach-O x86_64), npm 6.14.18, Python 3.13.4, sin
  `python2`. `EXIT_NPM_CI=0`, 243 s, `added 1612 packages`. `node-sass`: `Downloading binary … darwin-x64-83_binding.node` /
  `Binary is fine`. `fsevents` 1.2.13 ×4 (`@angular/compiler-cli`, `karma`, `watchpack-chokidar2`, `webpack-dev-server`) falla con
  el `node-gyp` **5.1.1 de npm** (no el 3.8.0 de la raíz): `ValueError: invalid mode: 'rU' while trying to load binding.gyp`.
  `ng build --extract-css` 26 s, `styles.css` 257.619 bytes (el mismo tamaño que `node-sass` en los contenedores de …9a36).
  **Espera observada, causa sin probar:** de 09:39:30 a ~09:43 npm estuvo al 0 % de CPU; a las 09:43:11 su hijo era
  `git clone --depth=1 -q -b 1.3.8 https://github.com/eligrey/FileSaver.js.git` y a las 09:43:26 `node scripts/build.js`
  (`node-sass`). Lo más probable es el `git://` colgado de la trampa 3 de A14 §3 antes de caer a `https://`; el log de npm no
  lo registra. F0 §5.1 lo publica como espera, sin afirmar la causa.
- **No se probó:** Colima (no está instalado; ahí `qemu-x86_64` está desactivado con Rosetta, según H-H-3 de Vue, así que
  sin Rosetta podría fallar); la imagen real de la Fase 13.

## 2. 🛠️ Prerrequisitos

kind v0.33.0 (`/opt/homebrew/bin/kind`) y kubectl en el Mac; Docker Desktop 4.92.0 con Rosetta. La red `kind` y la imagen
`kindest/node:<none>` (a1ed56…) ya existían y no se tocaron. `alpine:3.20` ya estaba. `host-labcore/`: copia de
`../angular-8-legacy-for-backend-devs-20261020-9a36/devc/clinical-lab-sass` sin `node_modules`, `dist` ni `.devcontainer`.

## 3. 🧭 Reglas antes de correr

Cluster con nombre propio (`a8-rosetta`) y **kubeconfig en `salidas/kubeconfig`**: no se toca `~/.kube/config` ni el contexto
activo. Imágenes con `--label curso=angular-8-legacy --label tanda=kind-rosetta`. Sin puertos. Nunca `prune`.

## 4. ▶️ Cómo se corre

```bash
./kind-rosetta.sh > salidas/kind-rosetta.log 2>&1        # imágenes, cluster, binfmt, pods
./kind-node-x64.sh > salidas/kind-node-x64.log 2>&1      # Node amd64 en el mismo cluster
python3 -I corregir-curso.py ../../cursos-legacy/angular-8-legacy-for-backend-devs   # una sola vez
./host-npm-ci.sh                                          # EN EL MAC, lo corre el autor (§10)
```

## 5. 📏 Cómo se mide

No se mide tiempo: el resultado es el estado de los pods, sus logs y el proceso visto desde el nodo. `kind create` tardó 45 s
con la imagen ya bajada a medias.

## 6. 🧮 Los intermedios que amasan la salida

`kubectl get pods`, `kubectl logs`, `ls /proc/sys/fs/binfmt_misc` y `ps -eo args` dentro del nodo; están en los scripts.

## 7. ✅ Qué se espera ver

Lo de §1.

## 8. 📂 Salidas

`salidas/kind-rosetta.log`, `salidas/kind-node-x64.log`, `salidas/limpieza.log`; las del H-host, cuando se corra:
`salidas/host-npm-ci.log`, `host-npm-ci-completo.log`, `host-build.log`.

## 9. 🧹 Limpieza

Hecha el 20/10/2026 (`salidas/limpieza.log`): `kind delete cluster --name a8-rosetta`; `docker rmi` de `a8-kind-amd64:1`,
`a8-kind-arm64:1`, `a8-kind-node-amd64:1` y `kindest/node:v1.27.3` (bajada por esta prueba); `salidas/kubeconfig` borrado.
La red `kind`, `kindest/node:<none>` y `alpine:3.20` eran de antes y quedan. Queda la caché de build (base
`node:14.21.3-bullseye-slim` amd64 sin tag). Del H-host: `rm -rf host-labcore/node_modules host-labcore/dist`.

## 10. 🚫 Qué se dejó fuera

El H-host se corrió en el Mac del autor (H-H-1); su `node_modules` y `dist` se borran con el comando de §9.

**Limpieza final (20/10/2026, cierre del curso):** regenerables borrados con `limpiar.py` y a mano; se conservan `salidas/` (evidencia citada en este README).
