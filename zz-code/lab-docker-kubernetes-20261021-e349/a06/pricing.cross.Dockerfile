# ── Etapa de build: el compilador de Go, que no viaja a la imagen final ──
# golang:1.27.1-alpine
FROM --platform=$BUILDPLATFORM golang@sha256:8a5910f31396cd4d89662f56c68b3ae31d374308270a1c3bd96672ee5ed43414 AS build
ARG TARGETOS TARGETARCH
WORKDIR /src
# Primero el módulo: esta capa se reutiliza mientras go.mod y go.sum no cambien.
COPY go.mod go.sum ./
RUN go mod download
# Todo el código del paquete; las pruebas (_test.go) no entran al binario.
COPY *.go ./
# G10: el código generado del contrato gRPC (task proto), que se versiona.
COPY pricingv1/ pricingv1/
# Binario estático (sin cgo: el driver de SQLite es Go puro), sin rutas locales ni símbolos de depuración.
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -ldflags="-s -w" -o /out/pricing .
# La carpeta de DATA_DIR, creada aquí con su dueño: distroless no tiene shell para hacerlo después,
# y un volumen montado sobre una carpeta que no existe nace de root (Fase 03).
RUN mkdir -p /out/data && chown 65532:65532 /out/data

# ── Etapa final: solo el binario ──
# gcr.io/distroless/static-debian13:nonroot — sin shell ni gestor de paquetes; usuario 65532.
FROM gcr.io/distroless/static-debian13@sha256:e2e927ec666bae08560abb3c55d0659eceabb657f56b6782ab500a9fc7f555e3
COPY --from=build /out/pricing /pricing
COPY --from=build --chown=65532:65532 /out/data /var/lib/pricing
EXPOSE 8080
CMD ["/pricing"]
