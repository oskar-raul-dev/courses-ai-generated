package com.meridian.clearinghouse;

import java.util.List;
import java.util.Map;
import org.springframework.data.domain.Limit;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MovementController {

    private final MovementRepository movements;

    MovementController(MovementRepository movements) {
        this.movements = movements;
    }

    @GetMapping("/movements/{id}")
    public Movement get(@PathVariable String id) {
        return movements.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "not_found", "el movimiento no existe"));
    }

    @GetMapping("/movements")
    public Map<String, Object> list(@RequestParam String store,
                                    @RequestParam(defaultValue = "50") int limit,
                                    @RequestParam(defaultValue = "") String cursor) {
        if (limit < 1 || limit > 500) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "validation_failed", "limit debe estar entre 1 y 500");
        }
        List<Movement> items = movements.findByStoreIdAndIdGreaterThanOrderByIdAsc(store, cursor, Limit.of(limit));
        String next = items.size() == limit ? items.get(items.size() - 1).getId() : "";
        return Map.of("items", items, "next_cursor", next);
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "ok");
    }
}
