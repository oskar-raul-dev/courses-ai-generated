# Multi-stage build: compilamos en una imagen con el toolchain de Go
# y copiamos sólo el binario a una imagen mínima. Resultado: imagen
# final de pocos MB, sin compilador ni código fuente.

# --- Etapa 1: build ---
FROM golang:1.22-alpine AS build
WORKDIR /src
COPY go.mod ./
COPY main.go ./
# CGO_ENABLED=0 produce un binario estático que corre en imágenes
# sin libc (como scratch o alpine).
RUN CGO_ENABLED=0 go build -o /payments .

# --- Etapa 2: runtime ---
FROM alpine:3.20
# Copiamos SOLO el binario de la etapa anterior.
COPY --from=build /payments /payments
EXPOSE 8090
ENTRYPOINT ["/payments"]
