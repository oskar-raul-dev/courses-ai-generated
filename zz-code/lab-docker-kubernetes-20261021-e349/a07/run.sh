#!/bin/sh
# a07: los cuatro constructores, cada uno en un contenedor nuevo (build en frío), cronometrados. Las imágenes quedan con
# tag a07-*; los tar, en a07/out.
cd "$(dirname "$0")/.."; Z=$(pwd); S=$Z/mi-lab/src/lab/services; O=$Z/a07/out
BUILDAH=quay.io/buildah/stable@sha256:07e637ad7a1df37f44afea8287935b350224ac193d63e5cc96debb50a366853c
KANIKO=registry.gitlab.com/gitlab-ci-utils/container-images/kaniko@sha256:7795cec509a50a71378cc2c365f55c555ee3a05834d8eb1cd2552df5e66d44d8
GO=golang@sha256:8a5910f31396cd4d89662f56c68b3ae31d374308270a1c3bd96672ee5ed43414
JDK=eclipse-temurin@sha256:8c0a84ea11c8f6ed52600fc19f1040121f2a162998e9f50a5faebbbad9172dcc
JRE=eclipse-temurin@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
DISTROLESS=gcr.io/distroless/static-debian13@sha256:e2e927ec666bae08560abb3c55d0659eceabb657f56b6782ab500a9fc7f555e3
now() { python3 -c 'import time;print(time.time())'; }
dt() { python3 -c "import time;print(round(time.time()-$1,1))"; }
docker pull -q $BUILDAH > /dev/null; docker pull -q $KANIKO > /dev/null; docker pull -q $JDK > /dev/null
for i in 1 2; do
  s=$(now); docker run --rm --privileged -v "$S/pricing:/src:ro" -v "$O:/kout" $BUILDAH sh -c \
    "buildah --storage-driver vfs bud -t lab/pricing:a07-buildah /src && buildah --storage-driver vfs push lab/pricing:a07-buildah docker-archive:/kout/buildah.tar:lab/pricing:a07-buildah" > logs/a07-buildah-$i.log 2>&1 \
    && echo "buildah $i: $(dt $s) s" || echo "buildah $i: FALLÓ"
  s=$(now); docker run --rm --entrypoint /kaniko/executor -v "$S/pricing:/workspace:ro" -v "$O:/kout" $KANIKO \
    --context dir:///workspace --dockerfile /workspace/Dockerfile --no-push --tar-path /kout/kaniko.tar --destination lab/pricing:a07-kaniko > logs/a07-kaniko-$i.log 2>&1 \
    && echo "kaniko $i: $(dt $s) s" || echo "kaniko $i: FALLÓ"
  docker run --rm -v "$S/pricing:/src:ro" -v "$O:/kout" -w /src -e KO_DOCKER_REPO=lab/pricing-ko -e KO_DEFAULTBASEIMAGE=$DISTROLESS $GO sh -c \
    'a=$(date +%s.%N); go install github.com/google/ko@v0.19.1 && b=$(date +%s.%N) && ko build --push=false --tarball=/kout/ko.tar --platform=linux/arm64 --bare . && c=$(date +%s.%N) && echo "ko '$i': instalar ko $(echo $b $a | awk "{printf \"%.1f\", \$1-\$2}") s · ko build $(echo $c $b | awk "{printf \"%.1f\", \$1-\$2}") s · total $(echo $c $a | awk "{printf \"%.1f\", \$1-\$2}") s"' > logs/a07-ko-$i.log 2>&1
  grep '^ko ' logs/a07-ko-$i.log || echo "ko $i: FALLÓ"
done
rm -rf /tmp/a07-jib && cp -R "$S/inventory" /tmp/a07-jib && rm -rf /tmp/a07-jib/target && mkdir -p /tmp/a07-jib/proto && cp -R "$Z/mi-lab/src/lab/contracts/proto/pricing" /tmp/a07-jib/proto/
s=$(now); docker run --rm -v /tmp/a07-jib:/src -w /src $JDK sh -c \
  "./mvnw -B -q -DskipTests compile com.google.cloud.tools:jib-maven-plugin:3.5.2:buildTar -Djib.from.image=$JRE -Djib.from.platforms=linux/arm64 -Djib.to.image=lab/inventory:a07-jib -Djib.container.user=10001" > logs/a07-jib.log 2>&1 \
  && echo "jib: $(dt $s) s" || echo "jib: FALLÓ"
for t in buildah kaniko ko; do docker load -i $O/$t.tar 2>&1 | tail -1; done
docker load -i /tmp/a07-jib/target/jib-image.tar 2>&1 | tail -1
