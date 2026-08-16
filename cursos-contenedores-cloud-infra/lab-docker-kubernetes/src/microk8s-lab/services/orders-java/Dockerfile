# Multi-stage: compilamos el jar con Maven, luego lo corremos en un JRE.

# --- Etapa 1: build con Maven ---
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
# Copiamos primero el pom para cachear la descarga de dependencias.
COPY pom.xml ./
RUN mvn -q dependency:go-offline
COPY src ./src
RUN mvn -q clean package -DskipTests

# --- Etapa 2: runtime sólo con JRE ---
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /src/target/orders-java-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
