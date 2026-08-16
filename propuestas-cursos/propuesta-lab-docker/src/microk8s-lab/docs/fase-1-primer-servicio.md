# Fase 1 — Tu primer servicio en YAML plano

Objetivo: construir la imagen de `catalog-node`, cargarla al cluster kind, y
desplegarla con un `Deployment` + `Service` escritos a mano. Sin Helm todavía —
primero entiende los objetos crudos.

---

## 1.1 — Construir la imagen con Podman

```powershell
cd services/catalog-node
podman build -t localhost/catalog-node:dev .
```

Verifica que existe:

```powershell
podman images | Select-String catalog-node
```

---

## 1.2 — Cargar la imagen al cluster kind

kind corre los nodos como contenedores. Tu imagen recién construida vive en Podman,
pero los nodos de kind **no la ven** automáticamente. Hay que cargarla:

```powershell
kind load docker-image localhost/catalog-node:dev --name lab
```

> Este paso es el equivalente en tu juguete a "subir la imagen al registry" del
> proyecto real. Aquí saltamos el registry y cargamos directo al cluster.

---

## 1.3 — Desplegar

```powershell
# Desde la raíz del repo
kubectl apply -f docs/manifests/fase-1/catalog-node.yaml
```

Observa cómo nacen los pods:

```powershell
kubectl get pods -w
# Ctrl+C cuando ambos estén Running
```

---

## 1.4 — Verificar que funciona

El Service es `ClusterIP` (interno), así que para probarlo desde tu máquina usamos
`port-forward`, que abre un túnel temporal:

```powershell
kubectl port-forward svc/catalog-node 3000:3000
```

En otra terminal:

```powershell
curl http://localhost:3000/products
curl http://localhost:3000/healthz
```

---

## 1.5 — Experimentos para aprender

Prueba estas cosas y observa qué pasa. Aquí es donde se aprende de verdad:

```powershell
# Mata un pod a mano y mira cómo K8s lo recrea solo
kubectl get pods
kubectl delete pod <nombre-de-un-pod-catalog>
kubectl get pods -w

# Escala a 4 réplicas sin editar el YAML
kubectl scale deployment catalog-node --replicas=4
kubectl get pods

# Vuelve a 2
kubectl scale deployment catalog-node --replicas=2

# Mira en qué nodo cayó cada pod (reparto entre workers)
kubectl get pods -o wide
```

Preguntas para responderte a ti mismo:
- ¿Por qué el Service sigue funcionando aunque mates un pod?
- ¿Los pods se reparten entre los 2 workers o caen en el mismo?
- ¿Qué pasa si pones una imagen que no existe?

---

## Checklist para pasar a la Fase 2

- [ ] La imagen se construye y se carga a kind
- [ ] Los pods llegan a Running y pasan el readinessProbe
- [ ] `curl /products` devuelve el JSON del catálogo
- [ ] Entiendes qué hace el Deployment vs el Service

Siguiente: `docs/fase-2-todos-los-servicios.md` — añadimos los demás servicios y
los hacemos hablar entre sí por DNS interno.
