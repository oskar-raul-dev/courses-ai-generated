FROM golang:1.25.1-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -o /out/clearinghouse .

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/clearinghouse /clearinghouse
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/clearinghouse"]
