package com.meridian.clearinghouse;

import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class RunController {

    record RunIn(String day, Integer chunkSize) {
    }

    private final CloseService close;
    private final ExecutorService runner = Executors.newVirtualThreadPerTaskExecutor();

    RunController(CloseService close) {
        this.close = close;
    }

    @PostMapping("/runs")
    public ResponseEntity<Map<String, Object>> start(@RequestBody RunIn in) {
        if (in.day() == null || in.day().isBlank()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "validation_failed", "day es obligatorio (AAAA-MM-DD)");
        }
        int chunk = in.chunkSize() == null || in.chunkSize() <= 0 ? 5000 : in.chunkSize();
        Map<String, Object> run = close.start(in.day());
        runner.submit(() -> {
            close.execute(in.day(), chunk);
            return null;
        });
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(run);
    }

    @GetMapping("/runs/{id}")
    public Map<String, Object> get(@PathVariable String id) {
        return close.run(id).orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "not_found", "el cierre no existe"));
    }
}
