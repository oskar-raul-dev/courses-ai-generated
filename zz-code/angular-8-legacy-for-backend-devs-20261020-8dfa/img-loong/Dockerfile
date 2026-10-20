# Simula "nadie traduce": un ejecutable que el kernel no reconoce (ni ELF de una arquitectura registrada ni
# shebang). execve() devuelve ENOEXEC, el mismo error que una imagen arm64 en un nodo amd64 sin emulación.
FROM alpine:3.20
RUN printf 'no soy un binario de esta maquina\n' > /app && chmod +x /app
CMD ["/app"]
