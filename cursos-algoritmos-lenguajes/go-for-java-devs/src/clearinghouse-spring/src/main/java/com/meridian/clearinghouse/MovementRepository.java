package com.meridian.clearinghouse;

import java.util.List;
import org.springframework.data.domain.Limit;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MovementRepository extends JpaRepository<Movement, String> {

    /** Paginación por cursor (keyset): estable y sin el coste de OFFSET (Fase 09). */
    List<Movement> findByStoreIdAndIdGreaterThanOrderByIdAsc(String storeId, String cursor, Limit limit);
}
