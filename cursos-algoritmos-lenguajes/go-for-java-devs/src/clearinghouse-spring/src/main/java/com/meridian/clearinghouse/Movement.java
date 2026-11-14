package com.meridian.clearinghouse;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

/** Un movimiento de caja. Spring Data JPA donde encaja: lectura y listado. */
@Entity
@Table(name = "movements")
public class Movement {

    @Id
    private String id;
    @Column(name = "store_id")
    private String storeId;
    @Column(name = "external_ref")
    private String externalRef;
    private String type;
    @Column(name = "amount_minor")
    private long amountMinor;
    private String currency;
    @Column(name = "occurred_at")
    private Instant occurredAt;
    private String status;

    protected Movement() {
    }

    public String getId() { return id; }
    public String getStoreId() { return storeId; }
    public String getExternalRef() { return externalRef; }
    public String getType() { return type; }
    public long getAmountMinor() { return amountMinor; }
    public String getCurrency() { return currency; }
    public Instant getOccurredAt() { return occurredAt; }
    public String getStatus() { return status; }
}
