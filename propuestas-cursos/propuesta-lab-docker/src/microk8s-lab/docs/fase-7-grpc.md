# Fase 7 — Comunicación gRPC entre servicios

Hasta ahora los servicios se hablan por REST/HTTP. gRPC añade contratos fuertes
(Protobuf), streaming y mejor rendimiento. Es común entre microservicios internos.

## 7.1 — Definir el contrato (.proto)

Crea services/proto/orders.proto:

```protobuf
syntax = "proto3";
package lab;

service PaymentService {
  rpc ProcessPayment(PaymentRequest) returns (PaymentReply);
}

message PaymentRequest {
  string order_id = 1;
  double amount = 2;
}

message PaymentReply {
  string order_id = 1;
  string status = 2;
}
```

## 7.2 — Generar el código

Cada lenguaje genera sus stubs desde el mismo .proto:
- Go: protoc-gen-go + protoc-gen-go-grpc
- Java: protobuf-maven-plugin
- Node: @grpc/grpc-js + @grpc/proto-loader

El punto de aprendizaje: UN contrato, varios lenguajes. El .proto es la fuente
de verdad compartida.

## 7.3 — gRPC en Kubernetes

gRPC corre sobre HTTP/2. En K8s hay dos consideraciones:
1. El Service ClusterIP funciona igual (gRPC es TCP)
2. Para balanceo real de gRPC (que multiplexa conexiones) a veces se necesita
   un proxy con conocimiento de L7 como Linkerd o un headless Service.

Para el juguete, empieza con comunicación gRPC directa payments <-> orders por
ClusterIP. El balanceo avanzado es material de otra iteración.

## Checklist
- [ ] Un .proto compartido genera stubs en 2+ lenguajes
- [ ] orders-java llama a payments-go por gRPC
- [ ] Entiendes por qué gRPC necesita HTTP/2
