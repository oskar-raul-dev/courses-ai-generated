# Guía completa: Docker Desktop + Podman + kind en Windows 11

Guía para montar un entorno de contenedores dual en Windows 11 donde **Docker Desktop**
y **Podman** conviven, se usan de a uno a la vez, y ambos sirven como motor para
**kind** (Kubernetes local). Incluye validación de prerrequisitos, instalación paso a
paso, switch manual (GUI y consola) y un script de PowerShell 5.1 que lo automatiza.

---

## Tabla de contenido

1. [Prerrequisitos y validación de WSL 2](#1-prerrequisitos-y-validación-de-wsl-2)
2. [Instalación de Docker Desktop](#2-instalación-de-docker-desktop)
3. [Instalación de Podman](#3-instalación-de-podman)
4. [Instalación de kubectl y kind](#4-instalación-de-kubectl-y-kind)
5. [Dejar el ambiente listo](#5-dejar-el-ambiente-listo)
6. [Switch manual Docker ↔ Podman](#6-switch-manual-docker--podman)
7. [Script de automatización (PowerShell 5.1)](#7-script-de-automatización-powershell-51)
8. [Flujo de trabajo diario](#8-flujo-de-trabajo-diario)
9. [Solución de problemas](#9-solución-de-problemas)

---

## 1. Prerrequisitos y validación de WSL 2

Docker Desktop y Podman usan **WSL 2** (Windows Subsystem for Linux) como base. Antes
de instalar nada, valida que lo tienes.

### 1.1 — Validar WSL 2

Abre **PowerShell** y ejecuta:

```powershell
wsl --version
wsl --list --verbose
```

Deberías ver algo así:

```
WSL version: 2.x.x
...
  NAME              STATE           VERSION
* Ubuntu            Stopped         2
```

Lo importante: la columna **VERSION** debe decir **2**. Si dice 1, actualiza esa
distro:

```powershell
wsl --set-default-version 2
wsl --set-version <nombre-distro> 2
```

### 1.2 — Si WSL no está instalado

```powershell
# Instala WSL 2 con Ubuntu por defecto (requiere reinicio)
wsl --install
```

Reinicia y vuelve a validar con los comandos de 1.1.

### 1.3 — Virtualización

WSL 2 necesita virtualización activada en la BIOS/UEFI. Verifica en el Administrador
de tareas → pestaña **Rendimiento** → **CPU**: debe decir "Virtualización: Habilitada".
Si está deshabilitada, actívala en la BIOS (suele llamarse VT-x/AMD-V o SVM).

### 1.4 — Errores comunes de WSL 2 y cómo resolverlos

Si al instalar WSL, crear la máquina de Podman, o arrancar un cluster ves errores como
estos, aún no tienes bien montada la base de virtualización. Son de los fallos más
frecuentes al empezar:

```
There is no distribution with the supplied name.
Error code: Wsl/Service/WSL_E_DISTRO_NOT_FOUND

The operation could not be started because a required feature is not installed.
Error code: Wsl/InstallDistro/Service/RegisterDistro/CreateVm/HCS/HCS_E_SERVICE_NOT_AVAILABLE
```

Recórrelos en este orden — el primero que falle suele ser la causa:

**1. Activar las características de Windows necesarias.**
Las dos características que respaldan la VM de WSL 2 son **Microsoft-Windows-Subsystem-Linux**
y **VirtualMachinePlatform**. Abre PowerShell **como administrador** y ejecuta:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Luego **reinicia el PC**. Un activado parcial o fallido de estas dos es la causa más común
de `HCS_E_SERVICE_NOT_AVAILABLE`.

**Verificar el estado real de las características.** Antes de dar por hecho que están
activas, compruébalo — el estado importa mucho:

```powershell
Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform |
  Select-Object FeatureName, State
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux |
  Select-Object FeatureName, State
```

Interpretación del campo `State`:

| Estado | Qué significa | Qué hacer |
|---|---|---|
| `Enabled` | Activada y lista | Reiniciar si acabas de activarla |
| `EnablePending` | Activada, falta reinicio | Reiniciar |
| `Disabled` | Desactivada, archivos presentes | El `dism enable-feature` la activa rápido |
| `DisabledWithPayloadRemoved` | Desactivada Y **sin archivos** | Requiere descargar el payload (ver más abajo) |

> **Caso especial — `DisabledWithPayloadRemoved`:** este estado significa que los archivos
> de la característica fueron eliminados del sistema. El `dism enable-feature` no solo la
> activa: tiene que **descargar** los componentes desde Windows Update primero. Por eso el
> comando puede parecer "clavado" en un porcentaje bajo (ej. 14.6%) durante varios minutos
> — en realidad está descargando, no colgado. Ver el apartado sobre Windows Update abajo.

**2. Activar la virtualización en BIOS/UEFI.**
Reinicia entrando a la BIOS/UEFI (normalmente Supr, F2 o F10 al arrancar) y activa
**Intel VT-x/VT-d** o **AMD-V/SVM**. Puedes comprobarlo primero desde Windows:
Administrador de tareas → Rendimiento → CPU → "Virtualización" debe decir "Habilitada".
Si dice "Deshabilitada", la VM de WSL 2 no puede arrancar y produce exactamente este error.

**3. Verificar el servicio Hyper-V Host Compute Service.**
Abre Servicios (`services.msc`) y asegúrate de que **"Hyper-V Host Compute Service"**
(vmcompute) esté en **Automático** y **En ejecución**. Si está detenido, clic derecho →
Iniciar. Si no arranca, revisa el Visor de eventos en Registros de Windows → Sistema,
buscando errores de vmcompute a la hora del fallo.

**4. Revisar software de virtualización en conflicto.**
Versiones antiguas de VMware Workstation o VirtualBox pueden acaparar el hipervisor en
exclusiva y bloquear a Hyper-V/WSL 2. Actualiza VMware/VirtualBox a una versión reciente
(ya soportan convivir con Hyper-V), o desinstálalos/desactívalos temporalmente para probar.

**5. Actualizar WSL y el kernel, y reintentar.**
```powershell
wsl --update
wsl --status                       # confirma que la plataforma VM está sana
wsl --install -d Ubuntu            # reintenta instalar la distro
```

Si sigue fallando, confirma que el arranque del hipervisor está en automático:

```powershell
bcdedit /enum | Select-String "hypervisorlaunchtype"
# Si no dice "Auto", ejecútalo como administrador y reinicia:
bcdedit /set hypervisorlaunchtype auto
```

**6. Si el DISM se queda "clavado" en un porcentaje bajo.**
No siempre está colgado — a menudo está descargando el payload (caso
`DisabledWithPayloadRemoved`) o esperando a que Windows Update libere el componente que
comparten. Para distinguir "lento" de "colgado":

```powershell
# El trabajo real lo hace TiWorker, no dism. Vigila su CPU:
Get-Process dism, TiWorker, TrustedInstaller -ErrorAction SilentlyContinue |
  Select-Object Name, CPU, StartTime
```

Si el valor de **CPU de TiWorker sube** entre una consulta y la siguiente, está trabajando
— espera. Si está completamente fijo durante 10+ minutos, ahí sí puede estar atascado.

**La causa #1 de que DISM se cuelgue: Windows Update en curso.** DISM y Windows Update
comparten el componente **TrustedInstaller**, así que se bloquean entre sí. Si hay una
actualización descargándose o instalándose (revisa Configuración → Windows Update),
**deja que termine primero**, reinicia si lo pide, y recién entonces reintenta el DISM.
Con TrustedInstaller libre, el `enable-feature` completa sin quedarse clavado.

Una vez que `Get-WindowsOptionalFeature` reporte `State : Enabled`, **reinicia** y solo
entonces reintenta `podman machine init`.

> **En resumen:** los errores `WSL_E_DISTRO_NOT_FOUND` y `HCS_E_SERVICE_NOT_AVAILABLE`
> casi siempre significan que falta activar una característica de Windows (paso 1) o la
> virtualización en BIOS (paso 2). Verifica el `State` de las características con
> `Get-WindowsOptionalFeature`: si dice `DisabledWithPayloadRemoved`, hace falta descargar
> el payload desde Windows Update, y si Update está ocupado, el DISM se cuelga hasta que
> Update termina. Empieza siempre por comprobar el estado real antes de dar por hecho que
> algo está activo.

---

## 2. Instalación de Docker Desktop

### 2.1 — Descargar e instalar

Descarga desde el sitio oficial: https://www.docker.com/products/docker-desktop/

Ejecuta el instalador y **asegúrate de que la opción "Use WSL 2 instead of Hyper-V"
esté marcada** durante la instalación.

Alternativa por winget:

```powershell
winget install -e --id Docker.DockerDesktop
```

### 2.2 — Validar Docker Desktop

Tras instalar y arrancar Docker Desktop, valida en PowerShell:

```powershell
docker version
docker context list
docker run --rm hello-world
```

`docker version` debe mostrar **Client** y **Server**. `docker context list` debe
mostrar `desktop-linux` como contexto activo (marcado con `*`). El `hello-world`
descarga y corre un contenedor de prueba: si ves el mensaje de bienvenida, Docker
funciona.

---

## 3. Instalación de Podman

Podman se instala en **dos piezas separadas**: la CLI (el motor) y Podman Desktop
(la interfaz gráfica). Se instalan por separado a propósito.

### 3.1 — Instalar Podman CLI

```powershell
winget install -e --id RedHat.Podman
```

> Nota: el instalador de Podman CLI **no requiere apagar Docker Desktop**. Solo copia
> binarios y registra el PATH.

Cierra y reabre PowerShell para que el PATH se actualice, luego valida:

```powershell
podman --version
```

### 3.2 — Instalar Podman Desktop (GUI)

El ID en winget lleva **guión** entre Podman y Desktop:

```powershell
winget install -e --id RedHat.Podman-Desktop
```

> Alternativa: descarga el instalador desde https://podman-desktop.io/downloads

### 3.3 — Inicializar la máquina de Podman

Podman en Windows necesita una VM ligera propia (distinta a la de Docker), llamada
"machine". La creas una sola vez:

```powershell
podman machine init --cpus 2 --memory 2048 --disk-size 20
podman machine start
```

Valida:

```powershell
podman machine list
podman version
```

`podman machine list` debe mostrar la máquina con estado **"Currently running"**.

> **Aviso normal:** al arrancar, Podman puede decir *"Another process was listening on
> the default Docker API pipe address"*. Es esperado si Docker está corriendo — cada
> motor usa su propio named pipe. No es un error.

---

## 4. Instalación de kubectl y kind

Para levantar Kubernetes local usamos **kind** (Kubernetes IN Docker), que crea un
cluster dentro de contenedores. Funciona tanto con Docker como con Podman.

### 4.1 — kubectl (cliente de Kubernetes)

kubectl es la herramienta de línea de comandos para hablar con el cluster: desplegar,
inspeccionar recursos, ver logs. Puede que ya lo tengas (Podman Desktop lo incluye).
Verifica:

```powershell
kubectl version --client
```

Si no lo tienes:

```powershell
winget install -e --id Kubernetes.kubectl
```

> **Nota de compatibilidad:** kubectl debe estar dentro de una versión menor de
> diferencia respecto al cluster. Por ejemplo, un cliente v1.36 habla con control
> planes v1.35, v1.36 y v1.37. Con kind esto rara vez es problema, pero si ves avisos
> de "version skew", esta es la causa.

### 4.2 — kind

**Importante:** kind es **un solo binario**, no hay "kind para Docker" y "kind para
Podman" por separado. Instalas kind una vez, y le indicas qué motor usar con una
variable de entorno.

```powershell
winget install -e --id Kubernetes.kind
kind --version
```

### 4.3 — La variable clave: KIND_EXPERIMENTAL_PROVIDER

- Con **Docker** activo, kind lo usa por defecto (no necesita variable).
- Con **Podman** activo, kind necesita saber que use Podman:

```powershell
$env:KIND_EXPERIMENTAL_PROVIDER = "podman"
```

El script de la sección 7 gestiona esta variable automáticamente al hacer switch.

### 4.4 — Helm (gestor de paquetes de Kubernetes)

Helm es el gestor de paquetes de Kubernetes: empaqueta manifiestos en "charts"
versionables. En el proyecto que vas a construir, todo el despliegue va vía Helm
(umbrella chart) y la observabilidad se instala con Helm, así que **es recomendado,
no opcional**.

```powershell
winget install -e --id Helm.Helm
helm version
```

> **Nota de versión:** Helm 4 ya es la versión estable. Helm 3 sigue en modo soporte
> (correcciones de seguridad hasta noviembre 2026). Para aprender, cualquiera de las
> dos sirve; winget te instalará la actual. No necesitas una versión de Helm específica
> según tu versión de Kubernetes.

---

## 5. Dejar el ambiente listo

### 5.1 — Permitir ejecución de scripts

Para poder correr el script de switch (sección 7), habilita la ejecución de scripts
locales. Abre PowerShell **como administrador** una sola vez:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### 5.2 — Carpeta de scripts en el PATH

```powershell
# Crear carpeta para tus scripts
New-Item -ItemType Directory -Force -Path "C:\Scripts"

# Añadirla al PATH del usuario (una sola vez)
$current = [System.Environment]::GetEnvironmentVariable("PATH", "User")
[System.Environment]::SetEnvironmentVariable("PATH", "$current;C:\Scripts", "User")
```

Cierra y reabre la terminal para que el PATH tome efecto.

### 5.3 — Verificación final del ambiente

```powershell
wsl --list --verbose        # WSL 2 OK
docker version              # Docker OK
podman --version            # Podman OK
podman machine list         # Machine creada
kubectl version --client    # kubectl OK
kind --version              # kind OK
helm version                # Helm OK
```

---

## 6. Switch manual Docker ↔ Podman

La idea: tener **solo un motor activo a la vez**. Cuando trabajas con uno, apagas el
otro para liberar recursos y evitar conflictos de pipe.

### 6.1 — Vía GUI

**Cambiar a Podman (apagar Docker):**
1. Clic derecho en el ícono de Docker Desktop (bandeja del sistema) → **Quit Docker Desktop**
2. Abre Podman Desktop → verifica que la machine esté corriendo (Settings → Resources)
3. Si no está: botón de play en el mosaico de Podman Machine

**Cambiar a Docker (apagar Podman):**
1. En Podman Desktop → Settings → Resources → botón stop en Podman Machine
   (o `podman machine stop` en consola)
2. Abre Docker Desktop y espera a que el ícono deje de animarse

### 6.2 — Vía consola

**Cambiar a Podman:**

```powershell
# 1. Apagar Docker Desktop
Get-Process "Docker Desktop" -ErrorAction SilentlyContinue | Stop-Process -Force

# 2. Arrancar Podman machine
podman machine start

# 3. Configurar variables.
#    IMPORTANTE: NO setees CONTAINER_HOST — el CLI de Podman encuentra su machine
#    solo, y un CONTAINER_HOST=npipe:// lo rompe ("not a supported schema").
#    De hecho conviene limpiarlo por si quedó de antes.
Remove-Item Env:\CONTAINER_HOST -ErrorAction SilentlyContinue
[System.Environment]::SetEnvironmentVariable("CONTAINER_HOST", $null, "User")

#    DOCKER_HOST sí, pero solo para herramientas Docker-compat (Compose, etc.):
$env:DOCKER_HOST = "npipe:////./pipe/podman-machine-default"
$env:KIND_EXPERIMENTAL_PROVIDER = "podman"
```

**Cambiar a Docker:**

```powershell
# 1. Apagar Podman machine
podman machine stop

# 2. Arrancar Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# 3. Apuntar la variable al pipe de Docker y limpiar las de Podman/kind
$env:DOCKER_HOST = "npipe:////./pipe/dockerDesktopLinuxEngine"
Remove-Item Env:\CONTAINER_HOST -ErrorAction SilentlyContinue
Remove-Item Env:\KIND_EXPERIMENTAL_PROVIDER -ErrorAction SilentlyContinue
docker context use desktop-linux
```

> **Qué son estas variables:** `DOCKER_HOST` le dice a las herramientas compatibles con
> la API de Docker (Compose, Testcontainers, VS Code Dev Containers) a qué "socket"
> (named pipe) conectarse. `KIND_EXPERIMENTAL_PROVIDER` le dice a kind qué motor usar.
> **Sobre `CONTAINER_HOST`:** NO la setees a un `npipe://` — el CLI de Podman en Windows
> no la entiende y falla con "not a supported schema". El propio `podman` encuentra su
> machine automáticamente sin ninguna variable; por eso en el switch a Podman la
> limpiamos en lugar de setearla.

---

## 7. Script de automatización (PowerShell 5.1)

En lugar de hacer los pasos manuales de la sección 6, este script lo automatiza.
Compatible con **Windows PowerShell 5.1** (el que trae Windows por defecto) y con
PowerShell 7+.

### 7.1 — Instalación del script

1. Guarda el archivo `switch-container.ps1` (código abajo) en `C:\Scripts\`
2. Asegúrate de haber hecho los pasos 5.1 y 5.2 (ExecutionPolicy y PATH)

### 7.2 — Uso

```powershell
switch-container --switch-docker     # Apaga Podman, levanta Docker
switch-container --switch-podman     # Apaga Docker, levanta Podman
switch-container --shutdown-all      # Apaga ambos y limpia variables
switch-container --status            # Muestra qué está encendido
switch-container --help              # Ayuda
```

El script gestiona automáticamente `DOCKER_HOST`, `CONTAINER_HOST` y
`KIND_EXPERIMENTAL_PROVIDER` en cada cambio, de forma persistente (registro de
usuario + sesión actual).

### 7.3 — Nota importante sobre las rutas

El script tiene valores fijos que debes verificar coinciden con tu instalación:

```powershell
$DOCKER_PIPE         = "npipe:////./pipe/dockerDesktopLinuxEngine"
$PODMAN_PIPE         = "npipe:////./pipe/podman-machine-default"
$DOCKER_EXE          = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
$PODMAN_MACHINE_NAME = "podman-machine-default"
```

Si tu Docker está instalado en otra ruta, o tu machine tiene otro nombre, ajústalos.
Para verificar el pipe real de Podman:

```powershell
podman machine inspect --format "{{.ConnectionInfo.PodmanSocket.Path}}"
```

### 7.4 — El script

El archivo completo `switch-container.ps1` se entrega por separado junto a esta guía.
Cópialo a `C:\Scripts\switch-container.ps1`.

---

## 8. Flujo de trabajo diario

### Validar que ambos motores sirven (prueba de fuego)

Después de instalar todo, esta es la batería de comandos para confirmar que cada motor
funciona de punta a punta, incluido levantar un cluster de Kubernetes.

**Validar Podman:**

```powershell
.\switch-container.ps1 --switch-podman

# El CLI de Podman conecta (Client Y Server) — no solo --version
podman version

# La machine está corriendo
podman machine list

# Prueba real: correr un contenedor
podman run --rm hello-world

# Confirmar que CONTAINER_HOST NO quedó seteado (si tuviera un npipe://, rompe Podman)
$env:CONTAINER_HOST                 # debe salir vacío

# Confirmar que la variable de kind se puso
$env:KIND_EXPERIMENTAL_PROVIDER     # debe decir: podman

# Levantar un cluster sobre Podman
kind create cluster --name lab-podman
kubectl get nodes                   # el nodo debe llegar a Ready
```

**Validar Docker:**

```powershell
.\switch-container.ps1 --switch-docker

# Cliente Y servidor de Docker responden
docker version

# Prueba real: correr un contenedor
docker run --rm hello-world

# La variable de kind se limpió (Docker es el default de kind)
$env:KIND_EXPERIMENTAL_PROVIDER     # debe salir vacío

# Levantar un cluster sobre Docker
kind create cluster --name lab-docker
kubectl get nodes                   # el nodo debe llegar a Ready
```

**Ver el estado en cualquier momento:**

```powershell
.\switch-container.ps1 --status
```

### Sobre el ciclo de vida de los clusters kind (importante)

Un matiz que causa confusión: **el cluster de kind NO se reactiva automáticamente al
hacer switch de motor.** El cluster vive como contenedores dentro del motor donde lo
creaste. Cuando el script apaga ese motor, sus contenedores se detienen; al reactivarlo,
Docker suele reiniciarlos solo, pero Podman generalmente no.

Por eso, en la práctica hay dos filosofías, y para aprendizaje conviene la primera:

**Opción A — clusters desechables (recomendada):** crea el cluster cuando vas a trabajar
y bórralo al terminar. Recrear tarda ~30 segundos.

```powershell
.\switch-container.ps1 --switch-podman
kind create cluster --name lab
# ...trabajas...
kind delete cluster --name lab
.\switch-container.ps1 --shutdown-all
```

**Opción B — clusters persistentes por motor:** mantienes uno creado en cada motor, pero
debes gestionar a mano el arranque de sus contenedores al cambiar de motor, y a veces no
reviven bien. Más fricción.

> **Puede ser necesario borrar el cluster (`kind delete cluster --name lab`) si:**
> - Al crear ves `node(s) already exist for a cluster with the name "lab"` — ya existía
>   uno con ese nombre (créalo de nuevo tras borrarlo).
> - `kubectl` da `Unable to connect... connection refused` — el cluster quedó a medias o
>   sus contenedores no están corriendo; borra y recrea.
> - Cambiaste de motor y el cluster de antes quedó en un estado inconsistente.
>
> Antes de un `create`, un `kind get clusters` te dice qué existe realmente.

### ¿Se pierde la infra al borrar el cluster?

Sí: `kind delete cluster` elimina TODO lo que había dentro (pods, deployments, datos de
bases de datos, etc.). **Pero en Kubernetes bien hecho eso casi no importa**, porque tu
infra está definida en archivos (manifiestos YAML, charts de Helm) que viven en tu
repositorio, no en el cluster. Reconstruir es cuestión de minutos:

```powershell
kind create cluster --name lab
helm install plataforma ./charts/platform    # toda la infra vuelve
```

Lo único que NO se regenera desde archivos son los **datos con estado** (lo que había en
una base de datos). Para un juguete de aprendizaje se regeneran con un script de seed;
si quieres que sobrevivan al borrado, kind puede montar carpetas de tu disco en el nodo
(`extraMounts` + PersistentVolume tipo hostPath), aunque eso añade complejidad.

### kind NO es para producción

kind significa **Kubernetes IN Docker**: corre todo el cluster (nodos incluidos) como
contenedores dentro de un solo motor, sobre una sola máquina. Eso lo hace ideal para lo
**desechable** — pruebas, CI/CD, aprendizaje — y no apto para producción:

- Un solo host es un único punto de fallo; los "nodos" comparten la misma máquina y kernel.
- No hay alta disponibilidad real (la resiliencia de Kubernetes viene de repartir cargas
  entre nodos independientes, cosa que kind simula pero no provee de verdad).
- El propio proyecto se define para probar Kubernetes y apps localmente, no para tráfico real.

En producción se usan clusters gestionados en la nube (EKS, GKE, AKS) o distribuciones
on-premise (OpenShift, Rancher, k3s), donde el cluster es **permanente y cuidado**, con
nodos en máquinas separadas. La ventaja: **tu infra en YAML/Helm es la misma** en kind y
en producción — cambias el destino, no la definición. Por eso bajar el cluster kind aquí
no es problema: es, por diseño, un entorno desechable de pruebas.

### Construir y cargar una imagen a kind

```powershell
podman build -t localhost/miapp:dev .           # o docker build
kind load docker-image localhost/miapp:dev --name lab
```

---

## 9. Solución de problemas

### Errores de WSL al crear la machine de Podman o el cluster

Si al ejecutar `podman machine init/start` o `kind create cluster` ves errores como
`WSL_E_DISTRO_NOT_FOUND` o `HCS_E_SERVICE_NOT_AVAILABLE`, el problema no es de Podman
ni de kind: es la base de WSL 2 / virtualización que no está bien montada. Ve a la
sección **1.4 — Errores comunes de WSL 2** de esta guía y recorre los pasos en orden
(activar características de Windows, virtualización en BIOS, servicio vmcompute).

### La machine de Podman existe para Podman pero no para WSL

Síntoma: `podman machine init` dice `VM already exists`, pero `podman machine start`
falla con `WSL_E_DISTRO_NOT_FOUND`, y `wsl --list --verbose` **no** muestra
`podman-machine-default`. Esto es un desajuste: Podman tiene registrada una machine
cuya distro WSL nunca se creó (típicamente porque un `init` anterior se interrumpió a
medias por el problema de virtualización).

Solución — borrar el registro fantasma y recrear:

```powershell
# 1. Borrar la machine rota (puede mostrar un error de WSL al final: es inofensivo,
#    solo significa que la distro ya no existía en WSL)
podman machine rm --force podman-machine-default

# 2. Recrear desde cero (con la virtualización ya arreglada)
podman machine init --cpus 2 --memory 2048 --disk-size 20
podman machine start

# 3. Confirmar: ahora WSL SÍ debe listar podman-machine-default
wsl --list --verbose
```

### Error de DNS al descargar la imagen de la machine (quay.io)

Si `podman machine init` falla con algo como `lookup cdn01.quay.io: no such host`, no
es un problema de Podman ni de WSL: es DNS/red. Podman no pudo resolver el CDN desde
donde baja la imagen de la VM. Reintenta (suele ser transitorio); si persiste, limpia
la caché DNS (`Clear-DnsClientCache`) y verifica que no haya una VPN o firewall
corporativo bloqueando `quay.io`.

### `podman version` falla con "npipe is not a supported schema"

Síntoma: `podman --version` (dos guiones) funciona, pero `podman version` (un espacio)
falla con:

```
Error: unable to create connection. "npipe" is not a supported schema
```

Causa: hay una variable **`CONTAINER_HOST`** apuntando a un `npipe:////./pipe/...`. El
CLI nativo de Podman en Windows NO entiende `npipe://` en `CONTAINER_HOST` (ese esquema
es válido para `DOCKER_HOST`, que leen las herramientas Docker-compat, pero no para el
propio Podman). Esto suele venir de una versión antigua del script de switch que seteaba
`CONTAINER_HOST` por error.

Solución — limpiar la variable en sesión y registro:

```powershell
Remove-Item Env:\CONTAINER_HOST -ErrorAction SilentlyContinue
[System.Environment]::SetEnvironmentVariable("CONTAINER_HOST", $null, "User")
podman version    # ahora debe mostrar Client y Server
```

> **Nota importante:** el CLI de Podman encuentra su machine automáticamente; **no
> necesita** que le setees `CONTAINER_HOST` ni `DOCKER_HOST`. La versión actual del
> script `switch-container.ps1` ya NO setea `CONTAINER_HOST` — solo setea `DOCKER_HOST`
> (para herramientas Docker-compat como Compose) y lo hace de forma que no rompe Podman.

### kind con Podman hace timeout al crear el cluster

Problema conocido con Podman rootless: kind lee los logs para saber si el cluster
arrancó, pero el relay de logs en modo usuario a veces no conecta a tiempo. Solución
— cambia el log driver de Podman:

```powershell
podman machine ssh
# Dentro de la VM:
mkdir -p ~/.config/containers
echo '[containers]' >> ~/.config/containers/containers.conf
echo 'log_driver = "k8s-file"' >> ~/.config/containers/containers.conf
exit

# Recrea el cluster
kind delete cluster --name lab
kind create cluster --name lab
```

### El comando docker/podman no encuentra el motor

Verifica a qué apunta la variable:

```powershell
switch-container --status
```

Si `DOCKER_HOST` apunta al motor equivocado, vuelve a hacer el switch correcto.

### Podman Desktop muestra 20 CPUs / 33 GB pero configuré menos

Es un bug visual de la GUI: muestra los recursos del host, no los asignados a la
machine. Verifica los reales con:

```powershell
podman machine list
```

### Docker y Podman parecen pelear por el mismo pipe

Es el comportamiento que este setup resuelve: no los tengas ambos encendidos. Usa
`switch-container --shutdown-all` y luego enciende solo el que necesites.

### El cluster de kind no revive tras reiniciar el PC

Tras un reinicio, el contenedor del nodo puede quedar detenido. Enciende el motor
correspondiente y, si no revive solo, reinícialo. En casos raros es más simple borrar
y recrear el cluster (`kind delete cluster` + `kind create cluster`).

---

## Resumen de comandos esenciales

| Acción | Comando |
|---|---|
| Validar WSL | `wsl --list --verbose` |
| Validar Docker | `docker version` |
| Validar Podman | `podman machine list` |
| Crear machine Podman | `podman machine init` + `podman machine start` |
| Instalar kubectl | `winget install -e --id Kubernetes.kubectl` |
| Instalar kind | `winget install -e --id Kubernetes.kind` |
| Instalar Helm | `winget install -e --id Helm.Helm` |
| Crear cluster | `kind create cluster --name lab` |
| Cambiar a Docker | `switch-container --switch-docker` |
| Cambiar a Podman | `switch-container --switch-podman` |
| Apagar todo | `switch-container --shutdown-all` |
| Ver estado | `switch-container --status` |
| Cargar imagen a kind | `kind load docker-image <img> --name lab` |

---

*Guía para Windows 11. El script `switch-container.ps1` se entrega como archivo
aparte junto a esta guía.
