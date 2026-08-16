# Fase 2 — Todos los servicios y comunicación interna

Objetivo: desplegar los 4 servicios en YAML plano y hacer que se **hablen entre sí**
por el DNS interno de Kubernetes. Aquí entiendes cómo `orders-java` encuentra a
`catalog-node` sin IPs hardcodeadas.

## 2.1 — El DNS interno de Kubernetes

Cada Service crea un nombre DNS resoluble DENTRO del cluster:

```
<nombre-del-service>.<namespace>.svc.cluster.local
```

En el mismo namespace basta el nombre corto. Por eso `orders-java` llama a
`http://catalog-node:3000` y funciona: `catalog-node` es el nombre del Service.

## 2.2 — Construir y cargar todas las imágenes

```powershell
podman build -t localhost/catalog-node:dev services/catalog-node
podman build -t localhost/payments-go:dev  services/payments-go
podman build -t localhost/orders-java:dev  services/orders-java
podman build -t localhost/web-legacy:dev   services/web-legacy

kind load docker-image localhost/catalog-node:dev --name lab
kind load docker-image localhost/payments-go:dev  --name lab
kind load docker-image localhost/orders-java:dev  --name lab
kind load docker-image localhost/web-legacy:dev   --name lab
```

## 2.3 — Probar la cadena completa

Con todo desplegado, prueba el flujo orders -> catalog + payments:

```powershell
kubectl port-forward svc/orders-java 8080:8080
```

En otra terminal:

```powershell
curl -X POST http://localhost:8080/orders `
  -H "Content-Type: application/json" `
  -d '{"productId":"p1"}'
```

Deberías ver una respuesta que combina datos del catálogo Y del pago: eso prueba
que orders-java llamó a los otros dos servicios por DNS interno.

## 2.4 — Experimentos

```powershell
# Rompe la cadena: escala catalog-node a 0 y repite el curl anterior.
kubectl scale deployment catalog-node --replicas=0
# El pedido ahora falla. Observa el error. Luego restaura:
kubectl scale deployment catalog-node --replicas=2
```

Pregunta clave: ¿el error fue inmediato o hubo reintentos/timeout? Esto te lleva
directo a por qué existen los patrones de resiliencia (Fase 8).

## Checklist
- [ ] Los 4 servicios en Running
- [ ] El curl a /orders devuelve datos combinados
- [ ] Entiendes el DNS interno service-a-service

Siguiente: docs/fase-3-4-helm.md
