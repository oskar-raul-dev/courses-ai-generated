FROM golang:1.19.13 AS b
WORKDIR /s
COPY main.go .
RUN go mod init tz && CGO_ENABLED=0 go build -o /tz .
FROM gcr.io/distroless/static-debian12:nonroot@sha256:afa5c872c891853ca7fcf1f12c3edb23f7eeef36189728842dd51042ff57f7ab AS distroless
COPY --from=b /tz /tz
ENTRYPOINT ["/tz"]
FROM scratch AS vacia
COPY --from=b /tz /tz
ENTRYPOINT ["/tz"]
