# Fases 3 y 4 — Migración a Helm y umbrella chart

En la Fase 2 tenías todos los servicios en YAML plano. Ahora los parametrizas con
Helm y los agrupas en un umbrella chart con overrides por ambiente. Este es el
corazón de lo que querías reproducir.

---

## Fase 3 — Entender el templating

Antes de instalar nada, **renderiza** el chart sin aplicarlo. `helm template`
evalúa los `{{ }}` y te muestra el YAML final que se aplicaría. Es tu mejor amigo
para aprender:

```powershell
# Renderiza el umbrella con los valores base
helm template lab charts/platform -f charts/platform/values.yaml
```

Compara la salida con los archivos de `docs/manifests/fase-1/`. Verás que es el
mismo tipo de objeto, pero con los valores ya sustituidos. Ese es el "aha" de Helm.

### Validar antes de instalar

```powershell
# Chequea sintaxis y buenas prácticas del chart
helm lint charts/platform

# Renderiza con un ambiente concreto para ver los overrides en acción
helm template lab charts/platform `
  -f charts/platform/values.yaml `
  -f charts/platform/values-local.yaml
```

Fíjate cómo `replicas` cambia según el `-f` que apliques al final.

---

## Fase 4 — Instalar el umbrella con overrides

### El patrón base + override

La idea que tenías es exactamente así: un `values.yaml` base y un `values-<env>.yaml`
que sobreescribe **sólo lo que cambia**. El orden de los `-f` importa: **el último
gana**.

```powershell
# Ambiente LOCAL (tu máquina)
helm install lab charts/platform `
  -f charts/platform/values.yaml `
  -f charts/platform/values-local.yaml
```

```powershell
# El mismo chart, ambiente E2E (más réplicas, tags fijos)
helm install lab-e2e charts/platform `
  -f charts/platform/values.yaml `
  -f charts/platform/values-e2e.yaml
```

### Verificar el release

```powershell
helm list                          # releases instalados
kubectl get pods                   # todos los servicios arriba
helm get values lab                # qué valores quedaron efectivos
```

### Actualizar tras un cambio

Cuando cambies un values o un template:

```powershell
helm upgrade lab charts/platform `
  -f charts/platform/values.yaml `
  -f charts/platform/values-local.yaml
```

### Desinstalar

```powershell
helm uninstall lab
```

---

## Antes de instalar: cargar TODAS las imágenes a kind

El umbrella despliega los 4 servicios, así que las 4 imágenes deben estar en el
cluster. Constrúyelas y cárgalas (esto lo automatiza el `Makefile`, pero hazlo a
mano una vez para entenderlo):

```powershell
# Construir
podman build -t localhost/catalog-node:dev services/catalog-node
podman build -t localhost/payments-go:dev  services/payments-go
podman build -t localhost/orders-java:dev  services/orders-java
podman build -t localhost/web-legacy:dev   services/web-legacy

# Cargar a kind
kind load docker-image localhost/catalog-node:dev --name lab
kind load docker-image localhost/payments-go:dev  --name lab
kind load docker-image localhost/orders-java:dev  --name lab
kind load docker-image localhost/web-legacy:dev   --name lab
```

---

## Ejercicios de aprendizaje

1. **Activar/desactivar un servicio sin borrar código.** Pon `web-legacy.enabled: false`
   en `values-local.yaml`, haz `helm upgrade`, y observa que su pod desaparece.
   Esto usa el `condition:` del `Chart.yaml` del umbrella.

2. **Crear tu propio ambiente.** Copia `values-qa.yaml` a `values-staging.yaml`,
   cambia réplicas y tags, e instálalo. Acabas de añadir un ambiente sin tocar
   ningún template.

3. **Ver el diff antes de aplicar.** Instala el plugin `helm-diff` y corre
   `helm diff upgrade` para ver qué cambiaría antes de aplicarlo — práctica común
   en equipos reales.

---

## Checklist para pasar a la Fase 5

- [ ] `helm template` renderiza sin errores
- [ ] `helm lint` pasa
- [ ] El umbrella instala los 4 servicios
- [ ] Entiendes cómo `-f values-<env>.yaml` sobreescribe la base
- [ ] Probaste activar/desactivar un servicio con `enabled`

Siguiente: `docs/fase-5-ingress.md` — exponer web-legacy al navegador.
