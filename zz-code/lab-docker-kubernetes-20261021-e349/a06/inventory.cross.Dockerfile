# ── Etapa de build: el JDK, que no viaja a la imagen final ──
# eclipse-temurin:25-jdk
FROM --platform=$BUILDPLATFORM eclipse-temurin@sha256:8c0a84ea11c8f6ed52600fc19f1040121f2a162998e9f50a5faebbbad9172dcc AS build
WORKDIR /src
# Primero el wrapper y el pom: la capa de dependencias se reutiliza mientras el pom no cambie.
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw -q -B dependency:go-offline
COPY src/ src/
# G10: el contrato gRPC, del contexto de build aparte (task build pasa --build-context proto=contracts/proto).
COPY --from=proto pricing/ proto/pricing/
RUN ./mvnw -q -B package -DskipTests
# Spring Boot parte su jar único en capas, de lo que menos cambia a lo que más.
RUN java -Djarmode=tools -jar target/inventory-0.0.1-SNAPSHOT.jar extract --layers --destination /out

# ── G13 (Fase 26): el outbox-relay, un binario estático de Go que viaja en la misma imagen ──
# golang:1.27.1-alpine, la de pricing
FROM --platform=$BUILDPLATFORM golang@sha256:8a5910f31396cd4d89662f56c68b3ae31d374308270a1c3bd96672ee5ed43414 AS relay
ARG TARGETOS TARGETARCH
WORKDIR /src
COPY relay/go.mod relay/go.sum ./
RUN go mod download
COPY relay/*.go ./
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -ldflags="-s -w" -o /out/outbox-relay .

# ── Etapa final: el JRE y la aplicación por capas ──
# eclipse-temurin:25-jre
FROM eclipse-temurin@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
# La imagen de Temurin no trae un usuario sin privilegios: uno propio, con uid fijo.
RUN useradd --system --uid 10001 --no-create-home inventory
WORKDIR /app
# De lo que menos cambia a lo que más: las dependencias casi nunca, la aplicación en cada commit.
COPY --from=build /out/dependencies/ ./
COPY --from=build /out/spring-boot-loader/ ./
COPY --from=build /out/snapshot-dependencies/ ./
COPY --from=build /out/application/ ./
# G13: el publicador del outbox. El sidecar es esta misma imagen con otro comando: /app/outbox-relay.
COPY --from=relay /out/outbox-relay /app/outbox-relay
# La carpeta de DATA_DIR con su dueño: un volumen montado sobre una carpeta que no existe nace
# de root, y el proceso muere con Permission denied (Fase 03).
RUN mkdir -p /var/lib/inventory && chown inventory /var/lib/inventory
# G10: el agente de OpenTelemetry para Java 2.32.0, con su suma. --chmod: sin él queda en 0600, ilegible para 10001.
ADD --checksum=sha256:f787eb6c7f3d18e69a431e108a15278d25ee37f83d68b678f621e063f3988f82 --chmod=644 \
    https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.32.0/opentelemetry-javaagent.jar \
    /opt/opentelemetry-javaagent.jar
USER inventory
EXPOSE 8080
# En forma JSON: el proceso 1 es la JVM, y la señal de apagado le llega a ella (Fase 03).
# `java -jar inventory-0.0.1-SNAPSHOT.jar migrate` aplica el esquema y termina (Fase 12).
# --enable-native-access: sin él, la carga de sqlite-jdbc avisa en texto (G7). -javaagent: las trazas (G10); se
# apaga con OTEL_JAVAAGENT_ENABLED=false.
CMD ["java", "-javaagent:/opt/opentelemetry-javaagent.jar", "--enable-native-access=ALL-UNNAMED", "-jar", "inventory-0.0.1-SNAPSHOT.jar"]
