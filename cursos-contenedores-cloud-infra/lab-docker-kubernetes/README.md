# 🧰 Propuesta: laboratorio de contenedores y Kubernetes local

Propuesta de un **laboratorio de infraestructura cloud-native** construido alrededor
de un juguete de microservicios. La premisa que lo define: el código de negocio es
andamiaje — se genera rápido y deliberadamente simple — porque lo que se aprende es
**todo lo que rodea a los servicios**, no los servicios.

> ⚠️ Borrador. Ver el [README del directorio de propuestas](../README.md) para
> entender qué implica ese estado.

## 🎯 Alcance

### El entorno base

Un host Windows 11 donde **Docker Desktop y Podman conviven** y se alternan con un
script, ambos sirviendo como motor para un cluster **kind** multi-nodo. Encima:
empaquetado OCI sin registry externo, despliegue con un umbrella chart de Helm,
observabilidad open source (métricas, dashboards, logs y trazas) y clientes de
cluster tanto web como de terminal. Incluye la guía de instalación y validación de
prerrequisitos paso a paso.

### El juguete

Inventario de una cadena de supermercados, repartido en varios microservicios
políglotas con sus propias bases de datos. El dominio se eligió porque genera datos
con volumen y estructura temporal, lo que deja la puerta abierta a extenderlo más
adelante.

### Lo que realmente se practica

- **Kubernetes local de punta a punta:** topología del cluster, exposición vía
  Ingress con dominio local, carga de imágenes sin registry.
- **Helm en serio:** umbrella chart, subcharts por servicio, valores por ambiente
  (local, e2e, QA).
- **Observabilidad:** scraping de métricas, dashboards, búsqueda de logs y trazas
  distribuidas.
- **Certificados y TLS por capas:** self-signed → gestor de certificados → mTLS
  entre servicios, tratado como una de las causas de incidente más subestimadas.
- **Laboratorio de incidentes:** provocar fallos de certificados a propósito y
  practicar el diagnóstico en un entorno donde romper no cuesta nada. Cada incidente
  sigue el mismo formato: qué provocar, qué error esperar, cómo diagnosticarlo, cómo
  arreglarlo.
- **Patrones distribuidos:** gRPC, sagas y eventos, como capas opcionales.
- **El contraste Docker vs. Podman:** mismo cluster, dos motores, experimentos
  comparativos.

### Cómo se construye

Dos reglas de método marcan el alcance de cada etapa: **infra primero, dominio
después** — se avanza en oleadas horizontales que tocan todos los servicios con poca
profundidad, en lugar de terminar uno antes de empezar el siguiente — y **anillos
concéntricos**, donde el Anillo 0 funciona end-to-end antes de sumar cualquier
complejidad, y las capas avanzadas quedan diseñadas pero quietas hasta que toque.

## 👥 Público objetivo

Desarrolladores con experiencia que quieren manos sobre infraestructura sin depender
de un cloud de pago ni de un cluster corporativo. Se asume soltura con contenedores
a nivel de uso, línea de comandos y al menos un lenguaje de backend.

## 🚫 Fuera de alcance

- Docker desde cero como tema.
- Clusters gestionados en la nube, multi-región o hardening para producción real.
- Profundidad de negocio en el dominio de inventario: el modelo se mantiene mínimo a
  propósito.
- Frontend más allá de lo necesario para ver el sistema funcionando.

## 📁 Contenido del directorio

Documentos numerados de diseño (brief, dominios y stack, certificados, laboratorio
de incidentes, guía del entorno Windows, refinamiento del Anillo 0) más un plan
maestro que los consolida y ordena sin reemplazarlos. En `src/` hay andamiaje
inicial de código e infraestructura, y el script de alternancia entre motores de
contenedores.
