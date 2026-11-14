#!/usr/bin/env bash
# native-image del gemelo (GraalVM CE para Java 21), con Maven descargado en el contenedor.
cd "$(dirname "$0")/.."
SP=$(cd ../../cursos-algoritmos-lenguajes/go-for-java-devs/src/clearinghouse-spring && pwd)
rm -rf salidas/native && mkdir -p salidas/native && cp -r "$SP/pom.xml" "$SP/src" salidas/native/
time docker run --rm --label curso=go-for-java-devs --memory=7g -v gfjd-m2:/root/.m2 -v "$PWD/salidas/native":/app -w /app \
  --entrypoint bash ghcr.io/graalvm/native-image-community:25i5-25.0.5.0.3-ol9-20261103 -c '
    curl -sL https://archive.apache.org/dist/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz | tar xz -C /opt
    /opt/apache-maven-3.9.11/bin/mvn -q -B -Pnative native:compile -DskipTests 2>&1 | tail -25
    ls -l target/clearinghouse 2>/dev/null; native-image --version | head -1'
