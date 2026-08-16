# Certificados y TLS en el juguete — de self-signed a mTLS

Documento dedicado al aprendizaje de certificados en Kubernetes, una de las causas
más comunes y subestimadas de incidentes en producción. Cubre el recorrido completo:
TLS básico → cert-manager → mTLS entre servicios → laboratorio de incidentes.

Diseñado como capas: cada una añade profundidad. No hacer todo de golpe.

---

## Por qué esto importa (y por qué en un juguete)

Los certificados fallan de formas silenciosas y en el peor momento: expiran de
madrugada, una CA no coincide entre dos servicios, un nombre (SAN) mal configurado
rompe un handshake que "funcionaba ayer". En producción cuestan incidentes caros. En
un juguete, provocar y diagnosticar esos fallos es aprendizaje puro y barato.

El objetivo de este documento no es solo "poner HTTPS", sino **entender qué pasa por
debajo** para poder diagnosticar cuando algo se rompe.

---

## Conceptos base (glosario mínimo)

- **TLS**: el protocolo que cifra la comunicación (HTTPS es HTTP sobre TLS).
- **Certificado**: documento que prueba la identidad de un servidor (o cliente),
  firmado por una autoridad.
- **CA (Certificate Authority)**: quien firma y avala certificados. En internet son
  entidades públicas (Let's Encrypt); en un lab, una CA propia (self-signed).
- **Self-signed**: certificado firmado por su propia CA privada, no por una pública.
  Perfecto para aprender; el navegador se queja porque no conoce esa CA.
- **SAN (Subject Alternative Name)**: los nombres de host para los que el cert es
  válido. Un SAN incorrecto es una de las causas #1 de fallos.
- **Secret de tipo TLS**: cómo Kubernetes guarda un cert + su clave privada.
- **mTLS (mutual TLS)**: ambos extremos se verifican mutuamente, no solo el cliente
  al servidor. Base del modelo "zero trust".

---

## Capa 1 — TLS básico en el Ingress (self-signed)

El certificado que tu frontend presenta al navegador. El punto de entrada más visible.

### 1.1 — Generar una CA propia y un certificado

Con OpenSSL (o mkcert, más simple). Ejemplo conceptual con OpenSSL:

```bash
# 1. Crear una CA propia (la "autoridad" de tu lab)
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
  -keyout ca.key -out ca.crt -subj "/CN=lab-ca"

# 2. Generar clave + CSR para el host del frontend
openssl req -newkey rsa:2048 -nodes \
  -keyout web.key -out web.csr -subj "/CN=inv.localhost"

# 3. Firmar el cert con la CA, incluyendo el SAN (crítico)
openssl x509 -req -in web.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out web.crt -days 365 -sha256 \
  -extfile <(echo "subjectAltName=DNS:inv.localhost")
```

> **Alternativa recomendada para lab: mkcert.** Instala una CA local en tu sistema y
> genera certs válidos sin los pasos de OpenSSL. Mucho menos fricción:
> `mkcert inv.localhost`

### 1.2 — Montar el cert como Secret

```bash
kubectl create secret tls web-tls \
  --cert=web.crt --key=web.key
```

### 1.3 — Configurar el Ingress para usarlo

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-inventory
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - inv.localhost
      secretName: web-tls        # ← el Secret del paso anterior
  rules:
    - host: inv.localhost
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-inventory
                port:
                  number: 8080
```

### 1.4 — Confiar en la CA

El navegador se quejará porque no conoce tu CA. Para que confíe, importa `ca.crt` al
almacén de confianza del sistema (o usa mkcert que lo hace solo). Este paso enseña por
qué las CA públicas existen: sin una raíz de confianza compartida, nadie confía en nadie.

---

## Capa 2 — cert-manager (automatización)

Generar certs a mano no escala. **cert-manager** es el estándar de facto en Kubernetes:
emite, renueva y rota certificados automáticamente. Aprenderlo es directamente empleable.

### 2.1 — Instalar cert-manager

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set crds.enabled=true
```

### 2.2 — Un Issuer con CA propia (para el lab)

En producción el Issuer apunta a Let's Encrypt. En el lab, usa una CA propia:

```yaml
# La CA propia como Secret
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: lab-ca-issuer
spec:
  ca:
    secretName: lab-ca-keypair    # tu ca.crt + ca.key como Secret
```

### 2.3 — Pedir un certificado declarativamente

Ahora en lugar de generar certs a mano, los declaras y cert-manager los crea:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: web-inventory-cert
spec:
  secretName: web-tls              # cert-manager crea/renueva este Secret
  duration: 2160h                  # 90 días
  renewBefore: 360h                # renueva 15 días antes de expirar
  dnsNames:
    - inv.localhost
  issuerRef:
    name: lab-ca-issuer
    kind: ClusterIssuer
```

**El aprendizaje clave:** cert-manager renueva solo antes de expirar. En producción,
esto es lo que evita el incidente clásico del "cert que expiró el domingo". Ver cómo
lo hace, y qué pasa cuando `renewBefore` está mal configurado, es oro.

---

## Capa 3 — mTLS entre servicios

Hasta aquí, TLS protege la ENTRADA (navegador → frontend). mTLS protege la
comunicación INTERNA (servicio → servicio), y además ambos extremos se autentican.

### 3.1 — El problema que resuelve

Por defecto, dentro del cluster los servicios se hablan en texto plano (HTTP). Si un
atacante entra al cluster, ve todo. Con mTLS:
- El tráfico entre servicios va cifrado.
- Cada servicio prueba su identidad al otro (no basta con estar en la red).

### 3.2 — Dos caminos

**Camino A — a mano (para entender):** cada servicio tiene su propio cert de cliente,
firmado por la CA común. Configuras el cliente HTTP de cada servicio para presentar su
cert y verificar el del otro. Laborioso pero didáctico: ves exactamente qué es un
handshake mTLS.

**Camino B — service mesh (para producción):** un mesh como **Linkerd** hace mTLS
automático entre todos los pods, sin tocar el código de los servicios. Inyecta un
proxy sidecar que cifra todo. Recomendado tras entender el camino A.

```bash
# Instalar Linkerd (el mesh más simple)
linkerd install --crds | kubectl apply -f -
linkerd install | kubectl apply -f -
# Inyectar el mesh en tus servicios
kubectl get deploy -o yaml | linkerd inject - | kubectl apply -f -
```

Con Linkerd, mTLS entre inventory ↔ catalog ↔ replenish queda activo sin cambiar una
línea de sus códigos. El aprendizaje: cómo el mesh abstrae lo que en el camino A
hiciste a mano.

---

## Conexión con tu setup Podman/Docker: TLS en registries

Hay un ángulo que conecta certificados con tu setup dual. Cuando Docker o Podman bajan
imágenes de un registry con cert self-signed, fallan con el clásico:

```
x509: certificate signed by unknown authority
```

Es el MISMO tipo de error que verás entre servicios con mTLS mal configurado.
Practicarlo con un registry local:

1. Levanta un registry local con un cert self-signed.
2. Intenta `podman pull` / `docker pull` → falla con x509.
3. Configura la confianza en la CA (distinto en Podman vs Docker — otro contraste de
   tu bitácora dual).
4. El pull funciona.

Esto une tres temas del proyecto: certificados, el contraste Podman/Docker, y el
diagnóstico de incidentes.

---

## Anexo — dónde encaja en los anillos del juguete

| Anillo | Tema de certificados |
|---|---|
| 5-TLS | Capa 1: TLS básico self-signed en el Ingress |
| 6-TLS | Capa 2: cert-manager con CA propia |
| 7-TLS | Capa 3: mTLS (a mano, luego Linkerd) |
| Lab | Laboratorio de incidentes (documento aparte) |

Se recomienda hacer estas capas DESPUÉS de que el MVP funcione sin TLS. Añadir TLS
sobre algo que ya funciona enseña mejor que arrancar con TLS desde cero.

---

*Documento de aprendizaje de TLS/certificados. El laboratorio de incidentes (provocar
fallos a propósito) está en el documento aparte "lab-incidentes-certificados".*
