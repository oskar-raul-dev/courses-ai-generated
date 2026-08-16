# =============================================================
# switch-container.ps1
# Alterna entre Docker Desktop y Podman Desktop en Windows 11
# Compatible con Windows PowerShell 5.1 y PowerShell 7+
#
# Uso:
#   switch-container --switch-docker     apaga Podman, levanta Docker
#   switch-container --switch-podman     apaga Docker, levanta Podman
#   switch-container --shutdown-all      apaga ambos, limpia variables
#   switch-container --status            muestra el estado de cada runtime
#   switch-container --help              muestra esta ayuda
# =============================================================

# ==============================================================
# POR QUE NO USAMOS param() CON [switch]
# --------------------------------------------------------------
# Windows PowerShell 5.1 interpreta cualquier "--algo" como un
# intento de parametro NOMBRADO (-algo), y como los nombres de
# parametro no pueden llevar guiones, falla con:
#   "A parameter cannot be found that matches parameter name..."
#
# La solucion portable (funciona igual en 5.1 y en 7) es NO
# declarar param() y leer los argumentos crudos desde la variable
# automatica $args, que captura TODO lo que se pasa sin intentar
# mapearlo a parametros con nombre.
# ==============================================================

# Tomamos el primer argumento crudo, o cadena vacia si no hay ninguno.
$rawArg = if ($args.Count -gt 0) { [string]$args[0] } else { "" }

# Normalizamos: quitamos los guiones iniciales (-- o -) para quedarnos
# solo con el nombre de la accion. El regex ^-+ elimina uno o mas
# guiones al inicio de la cadena.
$accion = $rawArg -replace '^-+', ''


# ==============================================================
# CONSTANTES DE CONFIGURACION
# --------------------------------------------------------------
# Named Pipes en Windows (npipe://): canales IPC que expone el
# kernel para comunicacion local entre procesos, sin red.
# Docker y Podman los usan como "socket" local, equivalente al
# unix socket (/var/run/docker.sock) que usarian en Linux.
#   Formato: npipe:////./pipe/nombre
#   \\.\pipe\ es la ruta del kernel; los // son escape de \\
# ==============================================================
$DOCKER_PIPE         = "npipe:////./pipe/dockerDesktopLinuxEngine"
$PODMAN_PIPE         = "npipe:////./pipe/podman-machine-default"
$DOCKER_EXE          = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
$PODMAN_MACHINE_NAME = "podman-machine-default"


# ==============================================================
# FUNCION: Show-Help
# Write-Host escribe directo a consola (no al pipeline): su salida
# no puede capturarse con > ni consumirse desde otra funcion.
# ==============================================================
function Show-Help {
    Write-Host ""
    Write-Host "  switch-container -- gestiona Docker Desktop y Podman en Windows 11" -ForegroundColor White
    Write-Host ""
    Write-Host "  USO:" -ForegroundColor Yellow
    Write-Host "    switch-container [opcion]" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  OPCIONES:" -ForegroundColor Yellow
    Write-Host "    --switch-docker     Apaga Podman machine y levanta Docker Desktop" -ForegroundColor Gray
    Write-Host "    --switch-podman     Apaga Docker Desktop y levanta Podman machine" -ForegroundColor Gray
    Write-Host "    --shutdown-all      Apaga ambos y limpia DOCKER_HOST / CONTAINER_HOST" -ForegroundColor Gray
    Write-Host "    --status            Muestra el estado de cada runtime" -ForegroundColor Gray
    Write-Host "    --help              Muestra esta ayuda" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  EJEMPLOS:" -ForegroundColor Yellow
    Write-Host "    switch-container --switch-docker" -ForegroundColor Cyan
    Write-Host "    switch-container --switch-podman" -ForegroundColor Cyan
    Write-Host "    switch-container --shutdown-all" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  VARIABLES DE ENTORNO gestionadas:" -ForegroundColor Yellow
    Write-Host "    DOCKER_HOST                 apunta al socket del runtime activo" -ForegroundColor Gray
    Write-Host "    CONTAINER_HOST              se limpia siempre (rompe el CLI de Podman en Windows)" -ForegroundColor Gray
    Write-Host "    KIND_EXPERIMENTAL_PROVIDER  se pone en 'podman' al usar Podman;" -ForegroundColor Gray
    Write-Host "                                se limpia al usar Docker (kind usa Docker por defecto)" -ForegroundColor Gray
    Write-Host ""
}


# ==============================================================
# FUNCION: Show-Error
# Imprime el error en rojo, muestra el help y termina con exit 1.
# exit 1 senala fallo a cualquier proceso padre (CI/CD, otro script).
# ==============================================================
function Show-Error {
    param([string]$msg)
    Write-Host ""
    Write-Host "  ERROR: $msg" -ForegroundColor Red
    Write-Host ""
    Show-Help
    exit 1
}


# ==============================================================
# FUNCION: Write-Header
# Helper visual puro: separadores entre secciones.
# ==============================================================
function Write-Header {
    param([string]$msg)
    Write-Host ""
    Write-Host "-----------------------------------------" -ForegroundColor DarkGray
    Write-Host "  $msg" -ForegroundColor White
    Write-Host "-----------------------------------------" -ForegroundColor DarkGray
}


# ==============================================================
# FUNCION: Stop-DockerDesktop
# Get-Process busca el proceso por nombre. -ErrorAction
# SilentlyContinue evita excepcion si no existe (retorna $null).
# Stop-Process -Force equivale a SIGKILL: terminacion inmediata.
# El busy-wait espera que el proceso desaparezca antes de seguir,
# para que el named pipe quede libre.
# ==============================================================
function Stop-DockerDesktop {
    $proc = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "  Deteniendo Docker Desktop..." -ForegroundColor Yellow
        $proc | Stop-Process -Force
        $waited = 0
        while ((Get-Process "Docker Desktop" -ErrorAction SilentlyContinue) -and $waited -lt 15) {
            Start-Sleep -Seconds 1
            $waited++
        }
        Write-Host "  Docker Desktop detenido." -ForegroundColor Green
    } else {
        Write-Host "  Docker Desktop ya estaba apagado." -ForegroundColor Cyan
    }
}


# ==============================================================
# FUNCION: Stop-PodmanMachine
# --format usa plantillas Go: {{.LastUp}} extrae ese campo del
# objeto machine. Cuando corre vale "Currently running".
# 2>$null descarta stderr; | Out-Null descarta stdout.
# ==============================================================
function Stop-PodmanMachine {
    $status = podman machine list --format "{{.LastUp}}" 2>$null
    if ($status -match "Currently running") {
        Write-Host "  Deteniendo Podman machine..." -ForegroundColor Yellow
        podman machine stop $PODMAN_MACHINE_NAME | Out-Null
        Write-Host "  Podman machine detenida." -ForegroundColor Green
    } else {
        Write-Host "  Podman machine ya estaba apagada." -ForegroundColor Cyan
    }
}


# ==============================================================
# FUNCION: Set-EnvPersistent
# Las variables de entorno viven en DOS lugares en Windows:
#   1. Sesion actual (memoria del proceso): Set-Item Env:\NAME
#      -> efecto inmediato, muere al cerrar la terminal.
#   2. Registry de usuario (HKCU:\Environment):
#      SetEnvironmentVariable(..., "User")
#      -> persiste para terminales NUEVAS.
# Hacemos ambas: sin (1) la terminal actual no ve el cambio;
# sin (2) las terminales futuras no lo heredan.
# ==============================================================
function Set-EnvPersistent {
    param([string]$Name, [string]$Value)
    Set-Item -Path "Env:\$Name" -Value $Value
    [System.Environment]::SetEnvironmentVariable($Name, $Value, "User")
}


# ==============================================================
# FUNCION: Remove-EnvPersistent
# Inverso de Set-EnvPersistent. $null en scope "User" borra la
# clave del registry (no la deja vacia, la elimina).
# ==============================================================
function Remove-EnvPersistent {
    param([string]$Name)
    Remove-Item -Path "Env:\$Name" -ErrorAction SilentlyContinue
    [System.Environment]::SetEnvironmentVariable($Name, $null, "User")
}


# ==============================================================
# FUNCION: Switch-ToDocker
# 1. Para Podman (libera el named pipe).
# 2. Lanza Docker Desktop (Start-Process es asincrono).
# 3. Polling sobre "docker version" hasta que responde (max 30s);
#    sin esto hay race condition ("connection refused").
# 4. DOCKER_HOST -> pipe de Docker (lo leen Compose, BuildKit, etc).
# 5. Limpia CONTAINER_HOST.
# 6. Fuerza contexto "desktop-linux".
# ==============================================================
function Switch-ToDocker {
    Write-Header "Cambiando a Docker Desktop"
    Stop-PodmanMachine

    Write-Host "  Iniciando Docker Desktop..." -ForegroundColor Yellow
    Start-Process $DOCKER_EXE

    Write-Host "  Esperando que Docker levante el socket..." -ForegroundColor Yellow
    $waited = 0
    while ($waited -lt 30) {
        try {
            $null = docker version 2>$null
            break
        } catch { }
        Start-Sleep -Seconds 2
        $waited += 2
    }

    Set-EnvPersistent "DOCKER_HOST" $DOCKER_PIPE
    Remove-EnvPersistent "CONTAINER_HOST"
    # kind usa Docker por defecto: quitamos la variable de provider para
    # que vuelva a su comportamiento nativo (no apuntar a Podman).
    Remove-EnvPersistent "KIND_EXPERIMENTAL_PROVIDER"
    docker context use desktop-linux 2>$null | Out-Null

    Write-Host ""
    Write-Host "  ACTIVO: Docker Desktop" -ForegroundColor Blue
    Write-Host "     DOCKER_HOST                = $env:DOCKER_HOST" -ForegroundColor Gray
    Write-Host "     CONTAINER_HOST             = (no definido)" -ForegroundColor Gray
    Write-Host "     KIND_EXPERIMENTAL_PROVIDER = (no definido, kind usa Docker)" -ForegroundColor Gray
    try {
        $cv = docker version --format "{{.Client.Version}}" 2>$null
        $sv = docker version --format "{{.Server.Version}}" 2>$null
        Write-Host "     Cliente: $cv  |  Servidor: $sv" -ForegroundColor Gray
    } catch { }
    Write-Host ""
}


# ==============================================================
# FUNCION: Switch-ToPodman
# 1. Mata Docker Desktop y espera que muera.
# 2. "podman machine start" es SINCRONO: bloquea hasta que la VM
#    esta lista, no necesita polling.
# 3. Setea SOLO DOCKER_HOST al pipe de Podman (para herramientas Docker-compat).
#    NO setea CONTAINER_HOST: el CLI nativo de Podman encuentra su machine solo,
#    y un CONTAINER_HOST=npipe:// rompe podman con "not a supported schema".
# ==============================================================
function Switch-ToPodman {
    Write-Header "Cambiando a Podman Desktop"
    Stop-DockerDesktop

    Write-Host "  Iniciando Podman machine..." -ForegroundColor Yellow
    podman machine start $PODMAN_MACHINE_NAME

    # IMPORTANTE: el CLI nativo de Podman encuentra su machine solo, NO se le
    # debe setear CONTAINER_HOST a un npipe:// (rompe podman con el error
    # "npipe is not a supported schema"). Por eso NO seteamos CONTAINER_HOST,
    # y de hecho lo limpiamos por si quedo de una version anterior del script.
    Remove-EnvPersistent "CONTAINER_HOST"

    # DOCKER_HOST se setea al pipe de Podman SOLO para herramientas que hablan
    # la API de Docker (Compose, Testcontainers, VS Code Dev Containers).
    # El podman CLI no lo necesita, pero no le molesta que exista.
    Set-EnvPersistent "DOCKER_HOST" $PODMAN_PIPE

    # kind asume Docker por defecto. Esta variable le dice que use Podman.
    # Sin ella, "kind create cluster" intentaria hablar con Docker y fallaria.
    Set-EnvPersistent "KIND_EXPERIMENTAL_PROVIDER" "podman"

    Write-Host ""
    Write-Host "  ACTIVO: Podman Desktop" -ForegroundColor Magenta
    Write-Host "     DOCKER_HOST                = $env:DOCKER_HOST" -ForegroundColor Gray
    Write-Host "     CONTAINER_HOST             = (no definido, el CLI de Podman no lo usa)" -ForegroundColor Gray
    Write-Host "     KIND_EXPERIMENTAL_PROVIDER = $env:KIND_EXPERIMENTAL_PROVIDER" -ForegroundColor Gray
    try {
        $pv = podman version --format "{{.Client.Version}}" 2>$null
        Write-Host "     Cliente: $pv" -ForegroundColor Gray
    } catch { }
    Write-Host ""
    Write-Host "  Tip: abre Podman Desktop manualmente desde el menu de inicio." -ForegroundColor DarkYellow
    Write-Host ""
}


# ==============================================================
# FUNCION: Stop-All
# Apaga ambos runtimes y limpia las variables en sesion y registry.
# Sin variables definidas, los clientes fallan de forma explicita
# en lugar de conectarse a un pipe inexistente.
# ==============================================================
function Stop-All {
    Write-Header "Apagando todo"
    Stop-DockerDesktop
    Stop-PodmanMachine
    Remove-EnvPersistent "DOCKER_HOST"
    Remove-EnvPersistent "CONTAINER_HOST"
    Remove-EnvPersistent "KIND_EXPERIMENTAL_PROVIDER"

    Write-Host ""
    Write-Host "  Todo apagado. No hay runtime activo." -ForegroundColor Red
    Write-Host "     DOCKER_HOST                = (no definido)" -ForegroundColor Gray
    Write-Host "     CONTAINER_HOST             = (no definido)" -ForegroundColor Gray
    Write-Host "     KIND_EXPERIMENTAL_PROVIDER = (no definido)" -ForegroundColor Gray
    Write-Host ""
}



# ==============================================================
# FUNCION: Show-Status
# --------------------------------------------------------------
# Consulta el estado de cada runtime sin modificar nada:
#   Docker  -> presencia del proceso "Docker Desktop"
#   Podman  -> campo LastUp de "podman machine list"
# Tambien muestra a que socket apunta DOCKER_HOST actualmente,
# util para saber cual recibira tus comandos "docker"/"podman".
# ==============================================================
function Show-Status {
    Write-Header "Estado de los runtimes"

    # --- Docker ---
    $dockerProc = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if ($dockerProc) {
        Write-Host "  Docker Desktop : ENCENDIDO" -ForegroundColor Green
    } else {
        Write-Host "  Docker Desktop : apagado" -ForegroundColor DarkGray
    }

    # --- Podman ---
    $podmanStatus = podman machine list --format "{{.LastUp}}" 2>$null
    if ($podmanStatus -match "Currently running") {
        Write-Host "  Podman machine : ENCENDIDO" -ForegroundColor Green
    } else {
        Write-Host "  Podman machine : apagado" -ForegroundColor DarkGray
    }

    # --- A quien apuntan las variables ahora mismo ---
    Write-Host ""
    $currentHost = [System.Environment]::GetEnvironmentVariable("DOCKER_HOST", "User")
    if ([string]::IsNullOrEmpty($currentHost)) {
        Write-Host "  DOCKER_HOST                = (no definido)" -ForegroundColor Gray
    } else {
        Write-Host "  DOCKER_HOST                = $currentHost" -ForegroundColor Gray
    }
    $currentKind = [System.Environment]::GetEnvironmentVariable("KIND_EXPERIMENTAL_PROVIDER", "User")
    if ([string]::IsNullOrEmpty($currentKind)) {
        Write-Host "  KIND_EXPERIMENTAL_PROVIDER = (no definido, kind usa Docker)" -ForegroundColor Gray
    } else {
        Write-Host "  KIND_EXPERIMENTAL_PROVIDER = $currentKind" -ForegroundColor Gray
    }
    Write-Host ""
}


# ==============================================================
# DISPATCH
# --------------------------------------------------------------
# $accion ya viene sin guiones (normalizado arriba). Un switch
# simple sobre string funciona identico en PS 5.1 y 7.
# El caso "" (cadena vacia) captura la ausencia de argumento.
# default captura cualquier flag no reconocido.
# ==============================================================
switch ($accion) {
    "switch-docker" { Switch-ToDocker; exit 0 }
    "switch-podman" { Switch-ToPodman; exit 0 }
    "shutdown-all"  { Stop-All;        exit 0 }
    "status"        { Show-Status;     exit 0 }
    "help"          { Show-Help;       exit 0 }
    ""              { Show-Error "Debes indicar una opcion. Usa --help para ver las opciones disponibles." }
    default         { Show-Error "Opcion no reconocida: '$rawArg'. Usa --help para ver las opciones validas." }
}
