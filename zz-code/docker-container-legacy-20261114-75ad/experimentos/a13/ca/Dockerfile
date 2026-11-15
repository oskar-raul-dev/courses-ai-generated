FROM legacy-node-toolchain:phase15
# el certificado raíz de tu empresa, junto al Dockerfile
COPY empresa-root-ca.crt /usr/local/share/ca-certificates/empresa-root-ca.crt

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# 1) el almacén del sistema: apt, curl, wget, git
# 2) y el de Node, que es aparte y no hereda del anterior
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
