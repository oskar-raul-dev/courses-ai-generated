# Fase 8 — Sagas: orquestación y coreografía

El objetivo final. Una saga gestiona una transacción distribuida entre varios
servicios que no comparten base de datos, con compensaciones si algo falla.

## Los dos estilos

### Orquestación (un director)
Un servicio central (orders-java) dirige cada paso:

```
orders-java:
  1. reservar stock (catalog-node)   -> si falla, aborta
  2. cobrar (payments-go)            -> si falla, libera stock (compensación)
  3. confirmar pedido                -> si falla, reembolsa + libera stock
```

Ventaja: la lógica está en un lugar, fácil de seguir.
Desventaja: acoplamiento al orquestador.

### Coreografía (sin director, por eventos)
Cada servicio reacciona a eventos y publica los suyos, vía Redis pub/sub:

```
orders-java  --publica--> "order.created"
catalog-node --escucha--> reserva stock --publica--> "stock.reserved"
payments-go  --escucha--> cobra          --publica--> "payment.approved"
orders-java  --escucha--> confirma pedido
```

Si payments-go publica "payment.failed", catalog-node lo escucha y ejecuta su
compensación (libera stock). Nadie dirige: cada uno reacciona.

Ventaja: desacoplamiento total.
Desventaja: el flujo global es más difícil de razonar y depurar.

## Implementación en el juguete

1. Añade Redis al umbrella (subchart o dependencia bitnami/redis).
2. Orquestación: amplía el POST /orders de orders-java con los 3 pasos y sus
   compensaciones (try/catch que deshace lo hecho).
3. Coreografía: cada servicio se suscribe a canales Redis y reacciona.
4. Introduce fallos a propósito en payments-go (rechaza 1 de cada 3 pagos) para
   ver las compensaciones dispararse.

## Por qué esto cierra el aprendizaje

Sagas tocan TODO lo anterior: varios servicios (fase 2), desplegados con Helm
(fase 4), comunicándose (fase 7), y observados cuando algo falla (fase 6). Es la
síntesis del juguete y lo más cercano a los problemas reales de sistemas distribuidos.

## Checklist
- [ ] Redis desplegado en el cluster
- [ ] Saga orquestada funcionando con compensaciones
- [ ] Saga coreografiada funcionando con eventos
- [ ] Provocas un fallo y ves la compensación en los logs
