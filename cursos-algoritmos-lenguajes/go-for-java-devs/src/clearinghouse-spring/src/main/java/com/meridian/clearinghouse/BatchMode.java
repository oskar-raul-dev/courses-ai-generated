package com.meridian.clearinghouse;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/** {@code --batch --day=AAAA-MM-DD [--chunk-size=N]}: el cierre como proceso que termina. */
@Component
class BatchMode implements ApplicationRunner {

    private final CloseService close;

    BatchMode(CloseService close) {
        this.close = close;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        if (!args.containsOption("batch")) {
            return;
        }
        String day = args.getOptionValues("day").getFirst();
        int chunk = args.containsOption("chunk-size") ? Integer.parseInt(args.getOptionValues("chunk-size").getFirst()) : 5000;
        long t0 = System.nanoTime();
        close.start(day);
        close.execute(day, chunk);
        System.out.printf("cierre %s completado en %d ms%n", day, (System.nanoTime() - t0) / 1_000_000);
    }
}
