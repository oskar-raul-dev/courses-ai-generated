# Fase 5 — Ingress: acceso desde el navegador

Hasta ahora usabas `port-forward` para llegar a los servicios. Eso es para debug.
Un Ingress da acceso HTTP real por host/ruta, como en producción.

## 5.1 — Instalar el Ingress Controller (NGINX)

El cluster kind ya tiene los puertos 80/443 mapeados a tu host (ver kind/cluster.yaml,
hostPort 8080/8443). Instala el controller:

```powershell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Espera a que esté listo
kubectl wait --namespace ingress-nginx `
  --for=condition=ready pod `
  --selector=app.kubernetes.io/component=controller `
  --timeout=120s
```

## 5.2 — Crear el Ingress para web-legacy

Añade este template al subchart web-legacy (charts/platform/charts/web-legacy/templates/ingress.yaml):

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-legacy
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: lab.localhost
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-legacy
                port:
                  number: 8080
```

## 5.3 — Acceder

Con el puerto 80 del cluster mapeado a 8080 de tu host:

```
http://lab.localhost:8080
```

(En Windows, lab.localhost resuelve a 127.0.0.1 automáticamente.)

## Checklist
- [ ] El Ingress Controller está Running
- [ ] Ves la página de web-legacy en el navegador
- [ ] Entiendes host-based routing

Siguiente: docs/fase-6-observabilidad.md
