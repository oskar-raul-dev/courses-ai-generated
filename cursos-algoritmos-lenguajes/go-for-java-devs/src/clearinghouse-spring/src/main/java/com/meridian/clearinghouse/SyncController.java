package com.meridian.clearinghouse;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/** POST /sync/batches: el agente de tienda empuja un lote; idempotente por (tienda, referencia). */
@RestController
public class SyncController {

    record MovementIn(
            @NotBlank String externalRef,
            @NotNull @Pattern(regexp = "sale|refund|void|withdrawal|deposit") String type,
            long amountMinor,
            @NotNull @Pattern(regexp = "[A-Z]{3}") String currency,
            @NotNull Instant occurredAt) {
    }

    record BatchIn(@NotBlank String storeId, @NotEmpty List<@Valid MovementIn> movements) {
    }

    private final JdbcTemplate jdbc;

    SyncController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @PostMapping("/sync/batches")
    @Transactional
    public Map<String, Integer> sync(@Valid @RequestBody BatchIn in) {
        Integer exists = jdbc.queryForObject("SELECT count(*) FROM stores WHERE id = ?", Integer.class, in.storeId());
        if (exists == null || exists == 0) {
            throw new ApiException(HttpStatus.NOT_FOUND, "not_found", "la tienda no existe: " + in.storeId());
        }
        Timestamp now = Timestamp.from(Instant.now().truncatedTo(java.time.temporal.ChronoUnit.MICROS));
        // INSERT ... ON CONFLICT DO NOTHING en lote: la idempotencia la garantiza el
        // índice único, como en Go. Con JPA sería save() + capturar la excepción, fila a fila.
        jdbc.batchUpdate("""
                INSERT INTO movements (id, store_id, external_ref, type, amount_minor, currency, occurred_at, received_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT (store_id, external_ref) DO NOTHING""",
                in.movements(), 500, (ps, m) -> {
                    ps.setString(1, in.storeId() + "-" + m.externalRef());
                    ps.setString(2, in.storeId());
                    ps.setString(3, m.externalRef());
                    ps.setString(4, m.type());
                    ps.setLong(5, m.amountMinor());
                    ps.setString(6, m.currency());
                    ps.setTimestamp(7, Timestamp.from(m.occurredAt()));
                    ps.setTimestamp(8, now);
                });
        // Con reWriteBatchedInserts el driver devuelve SUCCESS_NO_INFO en vez del número de
        // filas: las aceptadas se cuentan por su marca de recepción, que es la de esta petición.
        Integer accepted = jdbc.query(con -> {
            var ps = con.prepareStatement(
                    "SELECT count(*) FROM movements WHERE store_id = ? AND received_at = ? AND external_ref = ANY(?)");
            ps.setString(1, in.storeId());
            ps.setTimestamp(2, now);
            ps.setArray(3, con.createArrayOf("text", in.movements().stream().map(MovementIn::externalRef).toArray()));
            return ps;
        }, rs -> rs.next() ? rs.getInt(1) : 0);
        return Map.of("accepted", accepted, "duplicates", in.movements().size() - accepted);
    }
}
