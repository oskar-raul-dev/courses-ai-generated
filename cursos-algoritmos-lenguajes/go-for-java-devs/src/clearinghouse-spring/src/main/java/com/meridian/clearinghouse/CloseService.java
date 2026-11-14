package com.meridian.clearinghouse;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.sql.DataSource;
import org.springframework.batch.core.job.Job;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.job.parameters.JobParametersBuilder;
import org.springframework.batch.core.launch.JobOperator;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.Step;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.infrastructure.item.Chunk;
import org.springframework.batch.infrastructure.item.ItemWriter;
import org.springframework.batch.infrastructure.item.database.JdbcCursorItemReader;
import org.springframework.batch.infrastructure.item.database.builder.JdbcCursorItemReaderBuilder;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;

/**
 * El cierre por lotes, con Spring Batch: un step orientado a fragmentos. Spring Batch da
 * hecho lo que en Go se escribe (el bucle, la transacción por fragmento, el registro
 * de ejecuciones); el punto de control de negocio vive en la tabla batches, compartida.
 */
@Service
public class CloseService {

    /** La fila que lee el cierre. */
    public record MovementRow(String id, String storeId, String type, long amountMinor, String currency) {
    }

    private static final String DAY_FILTER =
            "(m.occurred_at AT TIME ZONE s.time_zone)::date = CAST(:day AS date) AND m.status = 'received'";

    private final JdbcTemplate jdbc;
    private final DataSource dataSource;
    private final JobRepository jobRepository;
    private final JobOperator jobOperator;
    private final PlatformTransactionManager tx;

    CloseService(JdbcTemplate jdbc, DataSource dataSource, JobRepository jobRepository,
                 JobOperator jobOperator, PlatformTransactionManager tx) {
        this.jdbc = jdbc;
        this.dataSource = dataSource;
        this.jobRepository = jobRepository;
        this.jobOperator = jobOperator;
        this.tx = tx;
    }

    /** Registra el cierre del día (409 si ya existe) y devuelve su fila. */
    public Map<String, Object> start(String day) {
        try {
            LocalDate.parse(day);
        } catch (RuntimeException e) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "validation_failed", "día inválido: " + day);
        }
        Long total = jdbc.queryForObject("SELECT count(*) FROM movements m JOIN stores s ON s.id = m.store_id WHERE "
                + DAY_FILTER.replace(":day", "?"), Long.class, day);
        Timestamp now = Timestamp.from(Instant.now());
        try {
            jdbc.update("""
                    INSERT INTO batches (id, period_day, status, total_expected, started_at, updated_at)
                    VALUES (?, CAST(? AS date), 'running', ?, ?, ?)""", "b-" + day, day, total, now, now);
        } catch (DuplicateKeyException e) {
            throw new ApiException(HttpStatus.CONFLICT, "conflict", "ya hay un cierre para ese día");
        }
        return run("b-" + day).orElseThrow();
    }

    /** Ejecuta el cierre ya registrado, de forma síncrona. */
    public void execute(String day, int chunkSize) throws Exception {
        String batchId = "b-" + day;
        try {
            jobOperator.start(job(day, batchId, chunkSize), new JobParametersBuilder()
                    .addString("day", day).addLong("chunkSize", (long) chunkSize)
                    // Un día reabierto se vuelve a cerrar: cada ejecución es una instancia nueva.
                    .addLong("run", System.currentTimeMillis()).toJobParameters());
            jdbc.update("UPDATE batches SET status='completed', finished_at=now(), updated_at=now() WHERE id=? AND status='running'", batchId);
        } catch (Exception e) {
            jdbc.update("UPDATE batches SET status='failed', last_error=?, updated_at=now() WHERE id=?", e.toString(), batchId);
            throw e;
        }
    }

    public java.util.Optional<Map<String, Object>> run(String id) {
        List<Map<String, Object>> rows = jdbc.query("""
                SELECT id, to_char(period_day, 'YYYY-MM-DD') AS day, status, total_expected, processed, chunks_done
                FROM batches WHERE id = ?""", (rs, n) -> {
            Map<String, Object> m = new java.util.LinkedHashMap<>();
            m.put("id", rs.getString("id"));
            m.put("day", rs.getString("day"));
            m.put("status", rs.getString("status"));
            m.put("total_expected", rs.getLong("total_expected"));
            m.put("processed", rs.getLong("processed"));
            m.put("chunks_done", rs.getInt("chunks_done"));
            return m;
        }, id);
        return rows.stream().findFirst();
    }

    private Job job(String day, String batchId, int chunkSize) throws Exception {
        String checkpoint = jdbc.queryForObject("SELECT checkpoint FROM batches WHERE id = ?", String.class, batchId);
        Step step = new StepBuilder("close-" + day, jobRepository)
                .<MovementRow, MovementRow>chunk(chunkSize, tx)
                .reader(reader(day, checkpoint, chunkSize))
                .writer(writer(batchId))
                .build();
        return new JobBuilder("close-" + day, jobRepository).start(step).build();
    }

    /**
     * Un cursor sobre el día entero, desde el punto de control. El primer intento fue
     * JdbcPagingItemReader (una consulta por página), y en la medición de la Fase 16 cada
     * página tardaba 780 ms: el cursor recorre el día con una sola consulta.
     */
    private JdbcCursorItemReader<MovementRow> reader(String day, String checkpoint, int chunkSize) throws Exception {
        JdbcCursorItemReader<MovementRow> r = new JdbcCursorItemReaderBuilder<MovementRow>()
                .name("movements-" + day)
                .dataSource(dataSource)
                .sql("SELECT m.id, m.store_id, m.type, m.amount_minor, m.currency "
                        + "FROM movements m JOIN stores s ON s.id = m.store_id "
                        + "WHERE " + DAY_FILTER.replace(":day", "?") + " AND m.id > ? ORDER BY m.id")
                .preparedStatementSetter(ps -> {
                    ps.setString(1, day);
                    ps.setString(2, checkpoint);
                })
                .fetchSize(chunkSize)
                .rowMapper((rs, n) -> new MovementRow(rs.getString("id"), rs.getString("store_id"),
                        rs.getString("type"), rs.getLong("amount_minor"), rs.getString("currency")))
                .saveState(false)
                .build();
        return r;
    }

    /** Asientos, estados y punto de control: todo en la transacción del fragmento. */
    private ItemWriter<MovementRow> writer(String batchId) {
        return (Chunk<? extends MovementRow> chunk) -> {
            Timestamp now = Timestamp.from(Instant.now());
            List<Object[]> entries = new ArrayList<>();
            List<String> matched = new ArrayList<>();
            List<String> unmatched = new ArrayList<>();
            for (MovementRow m : chunk) {
                Ledger.Pair p = Ledger.of(m.storeId(), m.type(), m.amountMinor());
                if (p == null) {
                    unmatched.add(m.id());
                    continue;
                }
                matched.add(m.id());
                entries.add(new Object[]{batchId, m.id(), p.debit(), p.signed(), m.currency(), now});
                entries.add(new Object[]{batchId, m.id(), p.credit(), -p.signed(), m.currency(), now});
            }
            jdbc.batchUpdate("""
                    INSERT INTO ledger_entries (batch_id, movement_id, account, amount_minor, currency, created_at)
                    VALUES (?, ?, ?, ?, ?, ?) ON CONFLICT (movement_id, account) DO NOTHING""", entries);
            updateStatus("matched", matched);
            updateStatus("unmatched", unmatched);
            String last = chunk.getItems().get(chunk.size() - 1).id();
            jdbc.update("""
                    UPDATE batches SET checkpoint = ?, processed = processed + ?, chunks_done = chunks_done + 1,
                    updated_at = now() WHERE id = ?""", last, chunk.size(), batchId);
        };
    }

    private void updateStatus(String status, List<String> ids) {
        if (!ids.isEmpty()) {
            jdbc.update(con -> {
                var ps = con.prepareStatement("UPDATE movements SET status = ? WHERE id = ANY(?)");
                ps.setString(1, status);
                ps.setArray(2, con.createArrayOf("text", ids.toArray()));
                return ps;
            });
        }
    }
}
