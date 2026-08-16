# Laboratorio de incidentes de certificados (opcional)

Sección opcional y avanzada. La idea: **provocar fallos de certificados a propósito**
para aprender a diagnosticarlos, en un entorno seguro donde romper cosas no cuesta nada.

Cada incidente sigue el mismo formato: qué provocar, qué error esperar, cómo
diagnosticarlo, cómo arreglarlo. Es la forma más rápida de que estos fallos dejen de
darte miedo en producción.

Requisito: haber hecho al menos la Capa 1 (TLS básico) del documento de certificados.

---

## Cómo usar este laboratorio

Para cada incidente:
1. **Provoca** el fallo siguiendo los pasos.
2. **Observa** el error real (no leas la solución todavía).
3. **Diagnostica** con las herramientas que se indican.
4. **Arregla** y confirma que se resolvió.
5. **Anota** en tu bitácora qué síntoma correspondía a qué causa.

El valor está en el paso 2-3: reconocer el síntoma. En producción, el 80% del tiempo
de un incidente de cert se va en *identificar* que es un problema de cert y *cuál*.

---

## Incidente 1 — Certificado expirado

El clásico. El cert que funcionaba ayer y hoy no.

**Provocar:**
Genera un cert con validez de 1 día (o ya expirado con fechas en el pasado):

```bash
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout exp.key -out exp.crt -days 1 \
  -subj "/CN=inv.localhost" \
  -addext "subjectAltName=DNS:inv.localhost"
# Para uno YA expirado, usa faketime o ajusta -days a negativo con truco de fecha
```

Móntalo y espera (o simula) la expiración.

**Error esperado (navegador/cliente):**
```
certificate has expired  /  NET::ERR_CERT_DATE_INVALID
```

**Diagnosticar:**
```bash
# Ver las fechas de validez del cert
openssl x509 -in exp.crt -noout -dates
# notBefore / notAfter → si notAfter ya pasó, ahí está

# Desde dentro del cluster, contra un servicio
openssl s_client -connect inv.localhost:443 -servername inv.localhost 2>/dev/null | \
  openssl x509 -noout -dates
```

**Arreglar:** regenerar el cert con validez vigente. Con cert-manager, esto NO pasa
porque renueva solo — que es justamente la lección de por qué cert-manager existe.

---

## Incidente 2 — CA desconocida (x509: unknown authority)

El error más común entre servicios y con registries.

**Provocar:**
Firma el cert de un servicio con una CA, pero configura el cliente para confiar en
OTRA CA distinta (o en ninguna).

**Error esperado:**
```
x509: certificate signed by unknown authority
```

**Diagnosticar:**
```bash
# Ver quién firmó el cert que presenta el servidor
openssl s_client -connect <host>:443 -servername <host> 2>/dev/null | \
  openssl x509 -noout -issuer

# Comparar con la CA que el cliente tiene configurada como confiable.
# Si el issuer no coincide con ninguna CA confiable → este error.
```

**Arreglar:** montar la CA correcta en el trust store del cliente. En Kubernetes,
esto suele ser un ConfigMap/Secret con el `ca.crt` montado en el pod cliente. Con un
service mesh, el mesh gestiona la CA común automáticamente.

> **Conexión Podman/Docker:** este es el MISMO error al hacer pull de un registry con
> cert self-signed. La solución es análoga: confiar en la CA del registry. Buen punto
> para comparar cómo se configura la confianza en Podman vs Docker.

---

## Incidente 3 — SAN incorrecto (nombre no coincide)

Sutil y frustrante: el cert es válido, la CA es confiable, pero el NOMBRE no cuadra.

**Provocar:**
Genera un cert con SAN para `inv.localhost` pero accede al servicio por otro nombre
(ej. `inventory.localhost` o por IP).

**Error esperado:**
```
certificate is valid for inv.localhost, not inventory.localhost
Hostname mismatch  /  NET::ERR_CERT_COMMON_NAME_INVALID
```

**Diagnosticar:**
```bash
# Ver los SAN del cert
openssl x509 -in web.crt -noout -text | grep -A1 "Subject Alternative Name"

# ¿El nombre por el que accedes está en esa lista? Si no, ahí está el problema.
```

**Arreglar:** regenerar el cert incluyendo todos los nombres necesarios en el SAN.
Lección clave: el CN (Common Name) ya no basta; los clientes modernos SOLO miran el
SAN. Un SAN incompleto es causa #1 de "pero si el cert es válido, ¿por qué falla?".

---

## Incidente 4 — Secret mal montado o clave/cert desparejados

El cert y la clave privada no corresponden entre sí, o el Secret tiene mal las llaves.

**Provocar:**
Crea un Secret TLS mezclando el `.crt` de un cert con el `.key` de otro.

**Error esperado (en el Ingress controller o el pod):**
```
tls: private key does not match public key
```

**Diagnosticar:**
```bash
# El módulo de la clave y el del cert deben coincidir
openssl x509 -in web.crt -noout -modulus | openssl md5
openssl rsa  -in web.key -noout -modulus | openssl md5
# Si los dos hashes no son iguales → cert y clave no son pareja
```

**Arreglar:** recrear el Secret con el par correcto de cert + clave.

---

## Incidente 5 — cert-manager no emite el certificado

Configuraste cert-manager pero el cert nunca aparece o queda en estado no-listo.

**Provocar:**
Un `Certificate` que referencia un Issuer inexistente o mal configurado.

**Diagnosticar:**
```bash
# Estado del Certificate
kubectl describe certificate web-inventory-cert
# Mira la sección Events y Conditions: dice por qué no está Ready

# Los objetos intermedios de cert-manager
kubectl get certificaterequest,order,challenge
kubectl logs -n cert-manager deploy/cert-manager
```

**Arreglar:** según lo que digan los eventos — Issuer mal referenciado, CA secret
ausente, DNS name inválido. La lección: cert-manager es declarativo, y `describe` +
sus objetos intermedios (CertificateRequest, Order) te dicen exactamente dónde se
atascó la cadena.

---

## Incidente 6 — mTLS: un servicio sin cert de cliente

Con mTLS activo, un servicio intenta hablar con otro sin presentar su cert de cliente.

**Error esperado:**
```
remote error: tls: certificate required
```

**Diagnosticar:**
```bash
# Verificar si el servicio cliente tiene su cert montado
kubectl exec <pod-cliente> -- ls /path/al/cert
# Con Linkerd, verificar que el pod está "meshed"
linkerd viz stat deploy
```

**Arreglar:** montar el cert de cliente en el servicio (camino manual) o asegurar que
el pod esté inyectado en el mesh (camino Linkerd).

---

## Tabla resumen — síntoma → causa

Tu chuleta de diagnóstico. El objetivo es que con solo ver el error, saltes a la causa:

| Síntoma / error | Causa probable | Primer comando |
|---|---|---|
| `certificate has expired` | Cert vencido | `openssl x509 -noout -dates` |
| `x509: unknown authority` | CA no confiable/incorrecta | `openssl ... -noout -issuer` |
| `certificate is valid for X, not Y` | SAN incompleto | `openssl x509 -text \| grep -A1 SAN` |
| `private key does not match` | Cert y clave desparejados | comparar `-modulus \| md5` |
| Certificate no llega a Ready | cert-manager mal configurado | `kubectl describe certificate` |
| `tls: certificate required` | Cliente sin cert (mTLS) | verificar cert montado / mesh |

---

## Cierre

Cuando puedas mirar cualquiera de estos errores y saber en 30 segundos qué comando
correr, habrás convertido el tema que "genera incidentes en producción" en algo
rutinario. Ese es todo el objetivo del laboratorio.

---

*Laboratorio opcional. Complementa al documento "certificados-tls". Hacer después de
tener al menos TLS básico funcionando.*
