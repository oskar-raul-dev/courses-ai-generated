# Diseño de dominios y stack — Juguete de inventario de supermercados

Documento de diseño detallado por microservicio, con el stack tecnológico decidido y
las ideas de proyecto sobre Podman y Docker Desktop. Complementa al brief de alto
nivel; aquí se concreta QUÉ hace cada servicio y con QUÉ se construye.

---

## 1. Stack tecnológico decidido

| Servicio | Rol | Tecnología | Framework/Router |
|---|---|---|---|
| **web-inventory** | Frontend | Java 17 + MicroProfile | Open Liberty |
| **catalog** | Backend | Go | net/http (stdlib) o chi |
| **inventory** | Backend (central) | Spring Boot 3 + Java 17 | Spring MVC |
| **replenish** | Backend | Node | Fastify |
| **reports** | Backend (opcional anillo 1) | Node | Express |

### Notas sobre las decisiones

**Go — net/http o chi (no framework pesado):** en Go moderno lo idiomático es la
librería estándar. Desde Go 1.22 el routing de `net/http` cubre casi todo lo que antes
requería un router externo. Si se quiere routing más cómodo (parámetros de URL,
middleware componible), **chi** es el añadido mínimo: ~1.000 líneas, cero dependencias
externas, 100% compatible con `net/http`. **Nada de Gin/Echo/Fiber** — son frameworks
completos, sobreingeniería para este juguete.

**Node — Express Y Fastify (aprendizaje del contraste):** `replenish` usa **Fastify**
(más moderno, validación de schemas de fábrica, mejor rendimiento) y, si se añade el
servicio opcional `reports`, ese usa **Express** (el clásico minimalista). Así el
juguete expone ambos y se aprende la diferencia en vivo.

**Spring Boot 3 + Java 17, con migración a Java 25 como ejercicio futuro:** se empieza
en Java 17 (LTS) y se deja planificada una migración a Java 25 (LTS) como anillo de
aprendizaje — enfrentar una migración LTS-a-LTS es una habilidad real. La compilación
nativa con GraalVM también queda como anillo futuro de optimización (no MVP).

---

## 2. Dominio detallado por microservicio

### 2.1 — catalog (Go)

**Responsabilidad:** el maestro de productos de la cadena. Es la fuente de verdad de
QUÉ productos existen, no CUÁNTOS hay (eso es inventory).

**Entidades:**
- `Product`: id, sku, nombre, categoría, marca, unidad de medida, precio de lista,
  código de barras.
- `Category`: id, nombre, categoría padre (jerarquía: Bebidas > Gaseosas).

**Endpoints REST:**
```
GET  /products              lista productos (con filtro por categoría)
GET  /products/{id}         detalle de un producto
GET  /categories            árbol de categorías
GET  /healthz               health check para K8s
```

**Base de datos:** `catalog-db` (Postgres). Tablas: products, categories.

**Por qué Go:** lectura intensiva, alta concurrencia, lógica simple. Go brilla y es el
servicio más fácil para arrancar.

---

### 2.2 — inventory (Spring Boot 3) — SERVICIO CENTRAL

**Responsabilidad:** el corazón del dominio. Sabe CUÁNTAS unidades de cada producto
hay en cada sucursal, y registra cada MOVIMIENTO de stock. Es el orquestador de las
sagas en fases futuras.

**Entidades:**
- `Store`: id, nombre, dirección, región.
- `StockLevel`: store_id, product_id, cantidad_actual, umbral_minimo.
- `StockMovement`: id, store_id, product_id, tipo (VENTA, REABASTECIMIENTO, MERMA,
  TRANSFERENCIA), cantidad, timestamp, referencia. **Esta tabla es la fuente de datos
  temporales para el juguete de ciencia de datos.**

**Endpoints REST:**
```
GET  /stores                          lista sucursales
GET  /stores/{id}/stock               stock de una sucursal
POST /stores/{id}/sales               registrar venta (descuenta stock)  ← FLUJO CENTRAL
POST /stores/{id}/movements           registrar movimiento genérico
GET  /stores/{id}/movements           historial de movimientos (datos temporales)
GET  /healthz
```

**El flujo central — registrar una venta:**
1. Recibe: sucursal, producto, cantidad.
2. Valida que el producto existe (llama a `catalog`).
3. Descuenta el stock y registra un `StockMovement` tipo VENTA.
4. Si el stock quedó bajo el umbral, notifica a `replenish` para generar una orden.

**Base de datos:** `inventory-db` (Postgres). Tablas: stores, stock_levels, stock_movements.

**Por qué Spring Boot:** es donde vive la lógica de negocio más rica; mejor tooling
para transacciones, validación y (a futuro) orquestación de sagas.

---

### 2.3 — replenish (Node + Fastify)

**Responsabilidad:** gestiona las órdenes de reabastecimiento. Cuando inventory avisa
que un producto bajó del umbral, crea y trackea una orden de reposición.

**Entidades:**
- `ReplenishmentOrder`: id, store_id, product_id, cantidad_solicitada, estado
  (PENDIENTE, EN_TRANSITO, RECIBIDA, CANCELADA), fecha_creacion, fecha_recepcion.

**Endpoints REST:**
```
POST /replenishments            crear orden (lo llama inventory)
GET  /replenishments            listar órdenes (filtro por estado/sucursal)
PATCH /replenishments/{id}      cambiar estado (ej: marcar como recibida)
GET  /healthz
```

**El ciclo de vida de una orden** (material para la saga futura):
`PENDIENTE → EN_TRANSITO → RECIBIDA`. Cuando una orden se marca RECIBIDA, debería
notificar a inventory para sumar el stock (esto cierra el ciclo y es un buen caso de
coreografía por eventos en el anillo de sagas).

**Base de datos:** `replenish-db` (Postgres). Tabla: replenishment_orders.

**Por qué Node/Fastify:** I/O-bound (llamadas entre servicios), encaja con el modelo
async. Fastify da validación de entrada de fábrica.

---

### 2.4 — web-inventory (MicroProfile / Open Liberty)

**Responsabilidad:** el frontend que un operador de la cadena usaría. Renderiza el
estado del inventario consumiendo los tres backends. Server-side rendering (no SPA).

**Vistas:**
- Dashboard: resumen de stock por sucursal, alertas de productos bajo umbral.
- Detalle de sucursal: stock completo, con acción de registrar venta.
- Órdenes de reabastecimiento: listado y estado.

**Consume:**
- `catalog` para nombres/categorías de productos.
- `inventory` para niveles de stock y registrar ventas.
- `replenish` para el estado de las órdenes.

**Por qué MicroProfile/Open Liberty:** trae health checks, métricas Prometheus y
OpenAPI de fábrica — justo lo que sirve para la capa de observabilidad. Representa el
JEE moderno (no legacy) que se quería.

---

## 3. Mapa de relaciones entre servicios

```
web-inventory ──REST──> catalog     (¿qué productos hay?)
web-inventory ──REST──> inventory   (¿cuánto stock? registrar venta)
web-inventory ──REST──> replenish   (¿estado de órdenes?)

inventory ──REST──> catalog         (validar producto al vender)
inventory ──REST──> replenish       (crear orden si stock bajo umbral)
replenish ──REST──> inventory       (avisar recepción → sumar stock)
```

Ese último enlace bidireccional (replenish avisa a inventory) es el que en el anillo
de sagas se convierte en comunicación por eventos (coreografía) en lugar de REST directo.

---

## 4. Aperturas planificadas (anillos futuros)

| Anillo | Qué añade | Concepto |
|---|---|---|
| 1 | Servicio `reports` (Express) + endpoint de export | Contraste Express/Fastify; datos para análisis |
| 2 | gRPC entre inventory ↔ catalog | Protobuf, HTTP/2 en K8s |
| 3 | Saga orquestada del reabastecimiento | Compensaciones, transacción distribuida |
| 4 | Saga coreografiada (eventos vía Redis/NATS) | Desacoplamiento por eventos |
| 5 | Migración Spring Boot a Java 25 | Migración LTS-a-LTS |
| 6 | Compilación nativa GraalVM de inventory + medición | Optimización cloud-native, antes/después |
| 7 | NetworkPolicies / service mesh | Seguridad y observabilidad de red |
| 8 | Semilla de datos + Jupyter | Puente a ciencia de datos |
| TLS-1 | TLS básico self-signed en el Ingress | Certificados, Secrets TLS, CA propia |
| TLS-2 | cert-manager con CA propia | Emisión/renovación automática de certs |
| TLS-3 | mTLS entre servicios (a mano → Linkerd) | Zero-trust, handshake mutuo |
| Lab-TLS | Laboratorio de incidentes de certificados | Diagnóstico de fallos TLS en producción |

> **Certificados y TLS:** el detalle de estos anillos está en el documento aparte
> `certificados-tls.md`, y el laboratorio de incidentes (provocar fallos de cert a
> propósito para diagnosticarlos) en `lab-incidentes-certificados.md`. Se recomienda
> abordar TLS DESPUÉS de que el MVP funcione sin cifrado: añadir TLS sobre algo que ya
> funciona enseña mejor que arrancar con TLS desde cero. Nota de conexión con el setup
> dual: el error `x509: certificate signed by unknown authority` aparece tanto entre
> servicios (mTLS) como al hacer pull de un registry con cert self-signed, y se
> configura distinto en Podman vs Docker — otro punto para la bitácora comparativa.

### Anillos de certificados y TLS

Tema propio por su importancia: los certificados son de las causas más comunes de
incidentes en producción. Ver documento aparte `certificados-tls-lab.md` para el
detalle. Resumen de los anillos:

| Anillo | Qué añade | Concepto |
|---|---|---|
| C1 | TLS en Ingress con cert self-signed | Secret TLS, terminación TLS en el borde |
| C2 | cert-manager con CA propia (emisión/renovación automática) | Automatización del ciclo de vida del cert |
| C3 | mTLS entre servicios (manual o vía Linkerd) | Verificación mutua, zero-trust interno |
| C4 | Registry local con TLS (ángulo Podman/Docker) | Confianza en CA, error x509 típico |
| C5 (opcional) | Laboratorio de incidentes de certificados | Diagnóstico de fallos reales provocados |

---

## 5. Ideas de proyecto sobre Podman y Docker Desktop

Esta es la parte que conecta el juguete con tu setup dual. El objetivo: usar el MISMO
proyecto en ambos motores para aprender sus diferencias en la práctica.

### 5.1 — El experimento base: mismo cluster, dos motores

Levanta el juguete completo en kind-sobre-Docker y en kind-sobre-Podman, y documenta
las diferencias que encuentres. Este es el aprendizaje central.

```powershell
# Sobre Docker
switch-container --switch-docker
kind create cluster --name inv-docker
# build + load + deploy del juguete

# Sobre Podman
switch-container --switch-podman
kind create cluster --name inv-podman
# build + load + deploy del mismo juguete
```

**Qué observar y anotar:**
- ¿El build de imágenes tarda distinto en cada motor?
- ¿El `kind load` se comporta igual?
- ¿Los pods con puertos privilegiados (Ingress 80/443) dan problemas en Podman rootless?
- ¿La creación del cluster necesita el fix del log driver en Podman?
- ¿Diferencias en consumo de recursos del host?

### 5.2 — Ideas concretas de experimentos

**Experimento A — Rootless en la práctica.**
Despliega el juguete en Podman rootless e intenta exponer un servicio en el puerto 80.
Observa la fricción, aplica la solución (rootful o mapeo de puertos altos), y entiende
por qué Docker no tenía ese problema. Documenta el contraste.

**Experimento B — Portabilidad de imágenes.**
Construye una imagen con Docker, guárdala (`docker save`), y córrela en Podman
(`podman load`). Comprueba que el formato OCI hace las imágenes 100% portables entre
motores. Es la base de por qué el switch funciona.

**Experimento C — Comparar tiempos de arranque del cluster.**
Cronometra `kind create cluster` en Docker vs Podman. Anota la diferencia y razona por
qué (VM de Podman vs integración WSL de Docker).

**Experimento D — Pods como ciudadanos de primera clase (Podman).**
Usa `podman generate kube` sobre uno de tus servicios corriendo localmente en Podman,
y compara el YAML generado con el manifiesto que tú escribiste. Aprende cómo Podman
tiende un puente natural hacia Kubernetes que Docker no tiene.

**Experimento E — Observabilidad del propio motor.**
Compara cómo ves los contenedores en Docker Desktop (GUI) vs Podman Desktop (GUI) vs
las herramientas de Kubernetes (Headlamp, k9s). Entiende las tres capas: motor de
contenedores, orquestador, y GUI de cada uno.

### 5.3 — Matriz de comparación a completar

Lleva una tabla como esta mientras experimentas — es tu bitácora de aprendizaje:

| Aspecto | Docker Desktop | Podman | Notas |
|---|---|---|---|
| Crear cluster kind | | | |
| Build de imágenes | | | |
| kind load | | | |
| Puerto 80 (Ingress) | | | |
| Consumo RAM host | | | |
| Experiencia GUI | | | |
| Generar YAML K8s | N/A | `generate kube` | |

---

## 6. Resumen ejecutivo

- **Dominio:** inventario de supermercados; entidad central `StockMovement` con
  timestamps, semilla para ciencia de datos.
- **4 servicios MVP:** catalog (Go/stdlib), inventory (Spring Boot 3, central),
  replenish (Node/Fastify), web-inventory (MicroProfile/Open Liberty).
- **Flujo central:** registrar venta → validar producto → descontar stock → disparar
  reabastecimiento si aplica.
- **Database-per-service** estricto (un Postgres por backend).
- **Aperturas:** reports (Express), gRPC, sagas, migración Java 25, GraalVM nativo,
  redes, ciencia de datos — todo como anillos opcionales.
- **Podman/Docker:** usar el mismo juguete en ambos motores como experimento central
  de aprendizaje de infra, con bitácora de diferencias.

---

*Documento de diseño de dominios. La implementación (código, charts, manifiestos) se
desarrolla en el proyecto de construcción con Claude Code.*
