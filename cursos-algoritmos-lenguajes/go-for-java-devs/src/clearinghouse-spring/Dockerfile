# El gemelo en contenedor. BASE elige la imagen final, para comparar en B-21:
#   docker build -t meridian/clearinghouse-spring:jvm .
#   docker build --build-arg BASE=eclipse-temurin:21-jre-alpine -t meridian/clearinghouse-spring:alpine .
ARG BASE=eclipse-temurin:21-jre

FROM maven:3.9.11-eclipse-temurin-21 AS build
WORKDIR /src
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -q -B dependency:go-offline
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -q -B package -DskipTests \
 && java -Djarmode=tools -jar target/clearinghouse.jar extract --layers --launcher --destination /out

FROM ${BASE}
WORKDIR /app
# Las capas de Spring Boot: dependencias primero, el código propio al final.
COPY --from=build /out/dependencies/ ./
COPY --from=build /out/spring-boot-loader/ ./
COPY --from=build /out/snapshot-dependencies/ ./
COPY --from=build /out/application/ ./
USER 1000:1000
EXPOSE 8081
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
