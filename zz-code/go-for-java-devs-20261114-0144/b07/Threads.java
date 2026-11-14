import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;

/** B-07, lado JVM: N tareas que duermen 10 ms, con hilos de plataforma o virtuales. */
public class Threads {
    public static void main(String[] args) throws Exception {
        String mode = args[0];
        int n = Integer.parseInt(args[1]);
        long t0 = System.nanoTime();
        if (mode.equals("virtual")) {
            try (var ex = Executors.newVirtualThreadPerTaskExecutor()) {
                for (int i = 0; i < n; i++) ex.submit(() -> { Thread.sleep(10); return null; });
            }
        } else {
            List<Thread> ts = new ArrayList<>(n);
            for (int i = 0; i < n; i++) {
                Thread t = new Thread(() -> { try { Thread.sleep(10); } catch (InterruptedException e) { } });
                t.start();
                ts.add(t);
            }
            for (Thread t : ts) t.join();
        }
        System.out.printf("%s n=%d tiempo=%d ms%n", mode, n, (System.nanoTime() - t0) / 1_000_000);
    }
}
