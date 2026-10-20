Dos archivos en `.devcontainer/`, en la raíz del repositorio:

```dockerfile
@@DOCKERFILE@@```

```jsonc
@@DEVCONTAINER@@```

Y el detalle que hace que se pueda usar de verdad:

```bash
# Dentro del contenedor, ng serve tiene que escuchar en todas las interfaces.
# Con el default (localhost) el servidor solo se ve DESDE DENTRO, y desde el
# navegador del Mac no carga nada: es el "no me abre en el 4200" clásico.
npx ng serve --host 0.0.0.0 --poll 2000
```

**Detalles con intención.**

- **Debian 11 y `archive.debian.org`.** La imagen viene con las fuentes de `deb.debian.org`, y desde que Debian 11 salió de soporte el `apt-get install` falla así:

  ```text
  E: Failed to fetch http://deb.debian.org/debian-security/pool/updates/main/p/perl/perl-base_5.32.1-4%2bdeb11u5_arm64.deb  404  Not Found
  ```

  El archivo histórico tiene los paquetes y no se va a mover. Sin actualizaciones de seguridad, sí: es una imagen de desarrollo para un stack de 2019, no algo que se expone. Es la trampa 1 de **A14 §3**.
- **`ca-certificates` y la reescritura de git.** `jspdf` 1.5.3 trae `file-saver` desde GitHub, y npm 6 lo pide por SSH. Sin la reescritura, el `npm ci` muere así:

  ```text
  npm ERR! /usr/bin/git ls-remote -h -t ssh://git@github.com/eligrey/FileSaver.js.git
  npm ERR! error: cannot run ssh: No such file or directory
  ```

  Y por HTTPS, sin `ca-certificates`, git no puede verificar el certificado de GitHub. Son las trampas 2 y 3 de **A14 §3**, con su explicación completa.
- **`python2` además de `python3`.** En arm64, `node-sass` 4.14.1 compila con un `node-gyp` 3.8.0 que busca `python2`, después `python`, y no acepta Python 3. Sin `python2`, el `npm ci` falla en `node-sass@4.14.1 postinstall` con `Can't find Python executable "python", you can set the PYTHON env variable.` Con él, compila y deja `vendor/linux-arm64-83/binding.node`. En amd64 sobra, porque el binario se descarga, pero no estorba. Si tu equipo pasa a Dart Sass (**A12 §3**), esa línea se puede ir.
- **`chromium` y `CHROME_BIN`** son el navegador de `ng test`. Dentro del contenedor, Chromium corre como `node` y necesita el lanzador sin sandbox de **A14 §7.1** en `karma.conf.js`: `npx ng test --watch=false --browsers=ChromeHeadlessNoSandbox`.
- **La carpeta `/workspace/node_modules` creada en la imagen**, con dueño `node`, es lo que hace que el volumen nazca con ese dueño y que el `postCreateCommand` sea un `npm ci` a secas (§5).
- **`--host 0.0.0.0`** es obligatorio dentro de un contenedor. Sin él, `ng serve` anuncia `listening on localhost:4200` y desde el Mac el puerto publicado no responde. El mock de la **Fase 4** no lo necesita: Express escucha en todas las interfaces por defecto.
- **`--poll`** hace que el detector de cambios pregunte por los archivos en vez de esperar a que el sistema le avise. En Colima hace falta: los avisos de cambio no cruzan a la VM por defecto (§3). En Docker Desktop sobra —en la prueba del curso, `ng serve` recompiló al tocar un archivo desde el Mac con y sin `--poll`—, pero no estorba. Cuesta algo de CPU y evita la pregunta *"¿por qué tengo que reiniciar `ng serve` cada vez?"*.
- **El formato `devcontainer.json` es de VS Code**, aunque otras herramientas lo lean. Con la extensión *Dev Containers*, "Reopen in Container" construye la imagen, crea el volumen y corre `npm ci`. Si tu editor no lo soporta, la receta a mano de abajo hace lo mismo.
- **Este contenedor es la "ruta corta"** del ejercicio 🔥 de la **Fase 0** que propone armar el ambiente en Debian slim a mano. Si quieres la lección completa, hazlo a mano primero; si quieres trabajar, esto es lo que hay.

> 📝 **Cómo se probó.** Los dos archivos de arriba, tal cual, sobre la base del proyecto de **A14 §6** (el manifiesto y el lockfile de **A03 §8.1**), con Docker Desktop 4.92.0 en un Mac con chip M, en arm64 y en amd64: `npm ci`, `ng build`, `ng test` (3 de 3) y `ng serve` respondiendo 200 en el Mac. Lo que no se probó es VS Code abriéndolos: se probó la receta a mano de abajo, que hace lo mismo con esos dos archivos.

### Sin VS Code: la receta a mano

```bash
# Desde la raíz del repositorio, una sola vez.
docker build -t clinical-lab-dev .devcontainer
docker volume create lab-node-modules

# Cada día: un shell dentro del contenedor, con los puertos publicados
# solo en tu Mac (127.0.0.1), no en la red de la oficina.
docker run -it --rm --name clinical-lab-dev \
  -v "$PWD":/workspace \
  -v lab-node-modules:/workspace/node_modules \
  -p 127.0.0.1:4200:4200 -p 127.0.0.1:3000:3000 \
  clinical-lab-dev bash
```

Ya dentro, `npm ci` la primera vez, y después lo de cada fase. Cada servicio va en su terminal, y `docker exec -it clinical-lab-dev bash` abre otra: `npm run mock` en una y `npx ng serve --host 0.0.0.0 --poll 2000` en la otra.
