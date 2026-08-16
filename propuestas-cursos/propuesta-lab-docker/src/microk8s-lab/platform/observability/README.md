# Stack de observabilidad open source

Alternativa gratuita a Datadog para el juguete.

## Componentes

- **kube-prometheus-stack**: Prometheus + Grafana + Alertmanager + exporters
- **Loki**: logs (opcional, añadir después)
- **Tempo**: trazas distribuidas (opcional, para la fase gRPC/sagas)

## Instalación

```powershell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install obs prometheus-community/kube-prometheus-stack `
  --namespace observability --create-namespace
```

## Acceso a Grafana

```powershell
# Obtener la password de admin
kubectl get secret -n observability obs-grafana `
  -o jsonpath="{.data.admin-password}" | `
  ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

# Port-forward
kubectl port-forward -n observability svc/obs-grafana 3000:80
# http://localhost:3000  (usuario: admin)
```

## Añadir Loki para logs

```powershell
helm install loki grafana/loki-stack `
  --namespace observability
```

Luego en Grafana añades Loki como datasource (http://loki:3100) y ya puedes
consultar logs de tus pods con LogQL.

## Qué explorar primero

kube-prometheus-stack trae dashboards de fábrica. Sin instrumentar nada, ve a
Grafana > Dashboards y busca "Kubernetes / Compute Resources / Namespace (Pods)".
Ahí ves CPU y memoria de tus 4 servicios en tiempo real.
