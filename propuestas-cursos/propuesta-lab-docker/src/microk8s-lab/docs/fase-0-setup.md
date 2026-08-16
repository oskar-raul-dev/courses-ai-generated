# Fase 0 — Setup del entorno

Objetivo: tener un cluster **kind** multi-nodo corriendo sobre **Podman**, con
`kubectl` y `helm` listos. Al terminar esta fase tendrás un Kubernetes vacío
donde desplegar en las siguientes fases.

---

## 0.1 — Confirmar que Podman está listo

```powershell
# Podman machine debe estar corriendo
podman machine list
# Debe mostrar "Currently running"

podman info | Select-String "cgroupVersion"
# Idealmente cgroupVersion: v2
```

Si tu Podman machine no está arriba, arráncala (o usa tu script):

```powershell
switch-container --switch-podman
```

---

## 0.2 — Instalar kind

**Recomendado: desde Podman Desktop GUI.** Settings → Resources → en el mosaico
"Kind" haz clic en Create/Install. La GUI configura el provider de Podman por ti.

**Alternativa por CLI (winget):**

```powershell
winget install -e --id Kubernetes.kind
```

Verifica:

```powershell
kind --version
```

---

## 0.3 — LA VARIABLE CRÍTICA: KIND_EXPERIMENTAL_PROVIDER

kind asume Docker por defecto. Para que use Podman **debes** definir esta variable
de entorno, o kind intentará hablar con Docker y fallará.

```powershell
# Sesión actual
$env:KIND_EXPERIMENTAL_PROVIDER = "podman"

# Persistente (para todas las terminales futuras)
[System.Environment]::SetEnvironmentVariable("KIND_EXPERIMENTAL_PROVIDER", "podman", "User")
```

> Si usas el script `switch-container`, considera añadir esta línea a
> `Switch-ToPodman` para que se configure sola al cambiar a Podman.

---

## 0.4 — Instalar Helm

```powershell
winget install -e --id Helm.Helm
helm version
```

---

## 0.5 — Crear el cluster

```powershell
# Desde la raíz del repo
kind create cluster --config kind/cluster.yaml --name lab
```

Esto tarda un par de minutos la primera vez (descarga la imagen del nodo).

### Si hace timeout (problema conocido con Podman rootless)

kind monitorea el arranque leyendo los logs de podman. En rootless, el relay de
logs en espacio de usuario a veces no conecta a tiempo y kind hace timeout aunque
el nodo esté bien. Workaround — cambia el log driver de Podman:

```powershell
# Entra a la máquina de Podman
podman machine ssh

# Dentro de la VM:
mkdir -p ~/.config/containers
echo '[containers]' >> ~/.config/containers/containers.conf
echo 'log_driver = "k8s-file"' >> ~/.config/containers/containers.conf
exit
```

Luego borra e intenta de nuevo:

```powershell
kind delete cluster --name lab
kind create cluster --config kind/cluster.yaml --name lab
```

---

## 0.6 — Verificar

```powershell
# kind configura kubectl automáticamente al contexto del cluster
kubectl cluster-info --context kind-lab

# Deberías ver 3 nodos: 1 control-plane + 2 workers
kubectl get nodes
```

Salida esperada (aprox.):

```
NAME                 STATUS   ROLES           AGE   VERSION
lab-control-plane    Ready    control-plane   2m    v1.3x.x
lab-worker           Ready    <none>          90s   v1.3x.x
lab-worker2          Ready    <none>          90s   v1.3x.x
```

---

## 0.7 — Comandos que usarás todo el tiempo

```powershell
kubectl get pods -A               # todos los pods de todos los namespaces
kubectl get all -n <namespace>    # todo en un namespace
kubectl describe pod <nombre>     # detalle / eventos de un pod
kubectl logs <pod> -f             # seguir logs
kubectl exec -it <pod> -- sh      # entrar a un contenedor
kubectl config get-contexts       # ver contextos (útil con varios clusters)
```

---

## Checklist para pasar a la Fase 1

- [ ] `podman machine list` muestra la máquina corriendo
- [ ] `KIND_EXPERIMENTAL_PROVIDER=podman` está definida y persistente
- [ ] `kind get clusters` lista `lab`
- [ ] `kubectl get nodes` muestra 3 nodos Ready
- [ ] `helm version` responde

Cuando todo esté marcado, sigue con `docs/fase-1-primer-servicio.md`.
