# Variantes y extensiones

## Cambiar Tomcat por TomEE o WildFly

El web-legacy usa `tomcat:9-jre8`. Para un servidor de aplicaciones JEE completo
(con EJB, JPA, JMS, etc.) cambia la imagen base del Dockerfile:

### TomEE (Tomcat + JEE)
```dockerfile
FROM tomee:8-jre8-plus
RUN rm -rf /usr/local/tomee/webapps/*
COPY src/main/webapp/ /usr/local/tomee/webapps/ROOT/
```

### WildFly
```dockerfile
FROM quay.io/wildfly/wildfly:26.1.3.Final-jdk8
# WildFly despliega .war desde standalone/deployments
COPY target/app.war /opt/jboss/wildfly/standalone/deployments/
```

Para WildFly necesitarás empaquetar un .war real con Maven (war plugin) en lugar
de copiar el JSP directo. Es un buen ejercicio para acercarte al "2017 JEE stack".

## Añadir una base de datos

Usa un subchart de Bitnami en lugar de escribir el tuyo:

```yaml
# En Chart.yaml del umbrella
dependencies:
  - name: postgresql
    version: "15.x.x"
    repository: "https://charts.bitnami.com/bitnami"
    condition: postgresql.enabled
```

## Añadir un nuevo microservicio

1. Crea services/<nuevo>/ con su Dockerfile
2. Copia un subchart existente como plantilla en charts/platform/charts/<nuevo>/
3. Añádelo a las dependencies del Chart.yaml del umbrella
4. Añade su bloque en values.yaml

El patrón está diseñado para esto: cada servicio es una pieza intercambiable.

## Red y políticas

- NetworkPolicies para restringir qué servicio habla con cuál
- Service mesh (Linkerd es el más simple) para mTLS y observabilidad de red
- Ingress con TLS usando cert-manager
