# microk8s-lab — Juguete de aprendizaje tipo "personal server"

Un entorno de aprendizaje que reproduce el patrón de un cluster **kind** multi-nodo,
con varios servicios políglotas desplegados mediante un **umbrella Helm chart** con
overrides por ambiente, más una capa de **observabilidad open source**.

Diseñado para crecer: empieza con "levantar pods" y termina en sagas, gRPC y
configuración de red avanzada.

---

## Qué reproduce este juguete

| Concepto del entorno real | Cómo lo reproducimos aquí |
|---|---|
| Cluster kind multi-nodo | `kind` con 1 control-plane + 2 workers |
| Apps subidas como imágenes | Imágenes construidas localmente y cargadas con `kind load` |
| Despliegue con Helm charts | Umbrella chart `charts/platform` con subcharts por servicio |
| Values base + overrides por ambiente | `values.yaml` + `values-<env>.yaml` |
| Servicios de plataforma (Grafana, Datadog…) | Stack open source: Prometheus + Grafana + Loki + Tempo |
| Apps políglotas que se relacionan | Front JEE (Tomcat) + microservicios Java, Node, Go |

---

## Arquitectura de servicios

```
                          ┌─────────────────────────────┐
                          │        Ingress (NGINX)       │
                          └──────────────┬──────────────┘
                                         │
                    ┌────────────────────┼────────────────────┐
                    │                                          │
           ┌────────▼─────────┐                     ┌──────────▼─────────┐
           │   web-legacy     │   (navegador)       │   Grafana          │
           │   JEE / Tomcat   │                     │   (observabilidad) │
           │   (JSP + Servlet)│                     └────────────────────┘
           └────────┬─────────┘
                    │ HTTP/REST
        ┌───────────┼───────────────┬──────────────────┐
        │                           │                  │
 ┌──────▼───────┐          ┌────────▼───────┐  ┌────────▼────────┐
 │ orders-java  │          │ catalog-node   │  │ payments-go     │
 │ Spring Boot  │◄────────►│ Express        │  │ Go (net/http)   │
 │ (REST+gRPC)  │  gRPC    │ (REST)         │  │ (REST + gRPC)   │
 └──────┬───────┘          └────────┬───────┘  └────────┬────────┘
        │                           │                   │
        │      ┌────────────────────┴───────────────────┘
        │      │
 ┌──────▼──────▼──┐        ┌──────────────────┐
 │   PostgreSQL   │        │      Redis       │
 │  (estado)      │        │  (cache / bus)   │
 └────────────────┘        └──────────────────┘
```

### Los servicios y por qué cada uno

- **web-legacy** (JEE sobre Tomcat 9 / Java 8): el frontend "antiguo" que consume
  los microservicios vía REST. Representa el monolito heredado que casi todo equipo
  arrastra. Puedes cambiarlo por TomEE o WildFly más adelante (ver `docs/variantes.md`).
- **orders-java** (Spring Boot 3): microservicio moderno que orquesta pedidos.
  Expone REST y gRPC. Es el **orquestador de la saga** en la fase avanzada.
- **catalog-node** (Node + Express): catálogo de productos. Simple a propósito,
  para contrastar con Java.
- **payments-go** (Go): procesador de pagos. Ligero y rápido, ideal para mostrar
  un tercer lenguaje y para la **coreografía** de eventos vía Redis.
- **PostgreSQL** y **Redis**: estado y bus de eventos / cache.

---

## Fases de aprendizaje

El proyecto está pensado para construirse **por fases**. Cada una añade una capa de
complejidad y un concepto nuevo de Kubernetes/Helm. No intentes hacer todo de golpe.

| Fase | Qué construyes | Concepto que aprendes |
|---|---|---|
| **0** | Cluster kind + herramientas | kind, kubectl, contextos |
| **1** | Un solo servicio (catalog-node) en YAML plano | Pod, Deployment, Service |
| **2** | Todos los servicios en YAML plano | Namespaces, labels, DNS interno |
| **3** | Migración a Helm: un chart por servicio | Templates, values, releases |
| **4** | Umbrella chart + values por ambiente | Subcharts, overrides, `-f` |
| **5** | Ingress para acceso desde navegador | Ingress, host routing |
| **6** | Observabilidad (Prometheus/Grafana/Loki) | ServiceMonitor, dashboards |
| **7** | Comunicación gRPC entre servicios | Protobuf, gRPC en K8s |
| **8** | Saga: orquestación y coreografía | Patrones distribuidos, Redis pub/sub |

Cada fase tiene su propio documento en `docs/`.

---

## Estructura del repositorio

```
microk8s-lab/
├── README.md                      ← este archivo
├── Makefile                       ← comandos de alto nivel (up, down, build, deploy)
├── kind/
│   └── cluster.yaml               ← definición del cluster multi-nodo
├── services/                      ← código fuente de cada servicio
│   ├── web-legacy/                ← JEE / Tomcat
│   ├── orders-java/               ← Spring Boot
│   ├── catalog-node/              ← Express
│   └── payments-go/               ← Go
├── charts/
│   └── platform/                  ← umbrella chart
│       ├── Chart.yaml
│       ├── values.yaml            ← valores base
│       ├── values-local.yaml      ← override: máquina personal
│       ├── values-e2e.yaml        ← override: pruebas e2e
│       ├── values-qa.yaml         ← override: QA
│       └── charts/                ← subcharts por servicio
│           ├── web-legacy/
│           ├── orders-java/
│           ├── catalog-node/
│           └── payments-go/
├── platform/                      ← servicios de plataforma (observabilidad)
│   └── observability/
│       └── README.md              ← cómo instalar el stack kube-prometheus + Loki
└── docs/                          ← guía por fases
    ├── fase-0-setup.md
    ├── fase-1-primer-servicio.md
    ├── ...
    └── variantes.md               ← TomEE, WildFly, alternativas
```

---

## Prerrequisitos

Ya tienes Podman + Podman Desktop. Necesitas además:

- **kind** (instalado vía Podman Desktop GUI, ver `docs/fase-0-setup.md`)
- **kubectl** (ya lo tienes: v1.36.1)
- **helm** (lo instalamos en la fase 0)
- La variable `KIND_EXPERIMENTAL_PROVIDER=podman` (crítica, ver fase 0)

---

## Empezar

```bash
# Lee la fase 0 y sigue el recorrido
cat docs/fase-0-setup.md
```

No corras el `Makefile` completo el primer día. El objetivo es **entender cada capa**,
no tener el stack arriba lo más rápido posible.
