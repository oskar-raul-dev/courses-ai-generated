# Fase 6 — Observabilidad open source

Reemplazamos el "Datadog" del entorno real por un stack 100% gratis y open source:
Prometheus (métricas) + Grafana (dashboards) + Loki (logs) + Tempo (trazas).

Ver platform/observability/README.md para el detalle de instalación con Helm.

## Resumen del stack

| Herramienta | Rol | Equivalente comercial |
|---|---|---|
| Prometheus | Recolecta métricas | Datadog metrics |
| Grafana | Dashboards y visualización | Datadog dashboards |
| Loki | Agregación de logs | Datadog logs |
| Tempo | Trazas distribuidas | Datadog APM |

## Instalación rápida (kube-prometheus-stack)

```powershell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Stack de métricas + Grafana en un namespace aparte
helm install obs prometheus-community/kube-prometheus-stack `
  --namespace observability --create-namespace
```

## Ver Grafana

```powershell
kubectl port-forward -n observability svc/obs-grafana 3000:80
# Usuario: admin  Password: kubectl get secret ... (ver README)
```

## Instrumentar tus servicios

Para que Prometheus recoja métricas de tus apps necesitas:
1. Exponer un endpoint /metrics en cada servicio
2. Un ServiceMonitor que le diga a Prometheus dónde buscar

Esto es material de una iteración futura: primero ten el stack corriendo y explora
los dashboards que kube-prometheus-stack trae de fábrica (ya muestran CPU/memoria
de tus pods sin instrumentar nada).

## Checklist
- [ ] Grafana accesible
- [ ] Ves métricas de tus pods en los dashboards por defecto
- [ ] Entiendes el rol de cada herramienta del stack
