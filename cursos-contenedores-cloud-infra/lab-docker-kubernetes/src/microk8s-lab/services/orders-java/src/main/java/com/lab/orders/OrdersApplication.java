package com.lab.orders;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestClient;
import org.springframework.beans.factory.annotation.Value;

import java.time.Instant;
import java.util.Map;

/**
 * orders-java — microservicio orquestador de pedidos (Spring Boot 3).
 *
 * Es el servicio "moderno" que consume a los demás:
 *   - consulta catalog-node por REST para validar el producto
 *   - llama a payments-go por REST para cobrar
 *
 * En la Fase 8 (sagas) este servicio se convierte en el ORQUESTADOR:
 * coordina los pasos y ejecuta compensaciones si algo falla.
 */
@SpringBootApplication
@RestController
public class OrdersApplication {

    // Las URLs de los otros servicios se inyectan por variables de
    // entorno. En Kubernetes serán los nombres DNS internos, p.ej.
    // http://catalog-node:3000 y http://payments-go:8090
    @Value("${CATALOG_URL:http://localhost:3000}")
    private String catalogUrl;

    @Value("${PAYMENTS_URL:http://localhost:8090}")
    private String paymentsUrl;

    private final RestClient http = RestClient.create();

    public static void main(String[] args) {
        SpringApplication.run(OrdersApplication.class, args);
    }

    // Healthcheck para las probes de K8s.
    @GetMapping("/healthz")
    public Map<String, String> health() {
        return Map.of("status", "ok");
    }

    /**
     * Crear un pedido. Flujo orquestado:
     *   1. Validar el producto contra catalog-node
     *   2. Cobrar contra payments-go
     *   3. Devolver el resultado
     */
    @PostMapping("/orders")
    public Map<String, Object> createOrder(@RequestBody Map<String, Object> body) {
        String productId = (String) body.get("productId");

        // Paso 1: validar producto en el catálogo
        Map<?, ?> product = http.get()
                .uri(catalogUrl + "/products/" + productId)
                .retrieve()
                .body(Map.class);

        double price = ((Number) product.get("price")).doubleValue();

        // Paso 2: cobrar
        Map<?, ?> payment = http.post()
                .uri(paymentsUrl + "/pay")
                .body(Map.of("orderId", "o-" + System.currentTimeMillis(), "amount", price))
                .retrieve()
                .body(Map.class);

        // Paso 3: responder
        return Map.of(
                "product", product,
                "payment", payment,
                "createdAt", Instant.now().toString()
        );
    }
}
