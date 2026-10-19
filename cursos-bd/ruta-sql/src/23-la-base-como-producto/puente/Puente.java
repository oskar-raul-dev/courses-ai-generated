// 💀☕ Boss del puente · PUNTO DE PARTIDA. Java 25, un solo archivo, sin frameworks. Tiene fallas que no se dicen.
//
// El laboratorio publica resultados como mensajes ORU (imitan HL7 v2: MSH, OBR y OBX; la versión del resultado va
// en el último campo de OBX, que es una simplificación declarada) en la cola `sih.oru` de Apache Artemis. El SIH los
// aplica en su tabla. Las fallas que el arnés inyecta: caídas del productor entre confirmar y enviar, caídas del
// consumidor entre aplicar y confirmar la entrega, correcciones que llegan fuera de orden y mensajes veneno.
//
//   java -cp "lib/*" Puente.java purgar
//   java -cp "lib/*" Puente.java producir <n> <tasaCaida>
//   java -cp "lib/*" Puente.java consumir <hilos> <tasaCaida>
//   java -cp "lib/*" Puente.java medir <n> <hilos>

import jakarta.jms.*;
import org.apache.activemq.artemis.jms.client.ActiveMQConnectionFactory;

import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicInteger;

public class Puente {
    static final String BROKER = env("BROKER_URL", "tcp://artemis:61616");
    static final String DB = env("DB_URL", "jdbc:postgresql://postgres:5432/alameda");
    static final String PASS = env("LAB_PASSWORD", "lab");
    static final String COLA = "sih.oru";

    static String env(String k, String d) { String v = System.getenv(k); return v == null ? d : v; }
    static java.sql.Connection db() throws SQLException { return DriverManager.getConnection(DB, "postgres", PASS); }
    static ConnectionFactory cf() { return new ActiveMQConnectionFactory(BROKER, "lab", PASS); }

    // ---- El mensaje ORU, simplificado ----------------------------------------------------------------------------
    static String oru(long resultId, int version, String analyte, String value) {
        String id = "R" + resultId + "-v" + version;
        return "MSH|^~\\&|ALAMEDA|LAB|SIH|HOSP|20251226||ORU^R01|" + id + "|P|2.5\r"
             + "OBR|1||" + resultId + "\r"
             + "OBX|1|NM|" + analyte + "||" + value + "||||||F|" + version;
    }

    record Oru(String messageId, long resultId, int version, String analyte, String value) {}

    static Oru parse(String body) {
        String[] seg = body.split("\r");
        if (seg.length < 3 || !seg[0].startsWith("MSH")) throw new IllegalArgumentException("no es un ORU: falta MSH");
        String[] msh = seg[0].split("\\|", -1), obr = seg[1].split("\\|", -1), obx = seg[2].split("\\|", -1);
        return new Oru(msh[9], Long.parseLong(obr[3]), Integer.parseInt(obx[12]), obx[3], obx[5]);
    }

    // ---- Productor: confirma el cambio y después publica el mensaje ---------------------------------------------
    static void cambio(java.sql.Connection c, long rid, int version, String analyte, String value) throws SQLException {
        try (var ps = c.prepareStatement("INSERT INTO staging.lab_oru (result_id, version, analyte, value) VALUES (?, ?, ?, ?)")) {
            ps.setLong(1, rid); ps.setInt(2, version); ps.setString(3, analyte); ps.setString(4, value); ps.executeUpdate();
        }
    }

    static void producir(int n, double caida, long seed) throws Exception {
        Random rnd = new Random(seed);
        int perdidos = 0;
        try (var c = db(); var conn = cf().createConnection()) {
            c.setAutoCommit(false);
            Session s = conn.createSession(false, Session.AUTO_ACKNOWLEDGE);
            MessageProducer p = s.createProducer(s.createQueue(COLA));
            p.setDeliveryMode(DeliveryMode.PERSISTENT);
            for (long i = 1; i <= n + 50; i++) {
                long rid = i <= n ? i : i - n;                 // los últimos 50 son correcciones (versión 2)
                int version = i <= n ? 1 : 2;
                String valor = version == 1 ? String.valueOf(70 + rnd.nextInt(80)) : "999";
                cambio(c, rid, version, "GLU", valor);
                c.commit();
                if (rnd.nextDouble() < caida) { perdidos++; continue; }   // el proceso cae entre el commit y el envío
                p.send(s.createTextMessage(oru(rid, version, "GLU", valor)));
            }
            for (int i = 1; i <= 3; i++) p.send(s.createTextMessage("ESTO NO ES HL7 " + i));
        }
        reenviarTarde(50);
        System.out.printf("producidos: %d cambios, 50 correcciones, 3 veneno · caídas entre commit y envío: %d%n", n, perdidos);
    }

    // La red desordena: el v1 de los resultados corregidos vuelve a llegar, después del v2.
    static void reenviarTarde(int k) throws Exception {
        try (var conn = cf().createConnection()) {
            Session s = conn.createSession(false, Session.AUTO_ACKNOWLEDGE);
            MessageProducer p = s.createProducer(s.createQueue(COLA));
            for (long i = 1; i <= k; i++) p.send(s.createTextMessage(oru(i, 1, "GLU", "100")));
        }
    }

    // ---- Consumidor ----------------------------------------------------------------------------------------------
    static void aplicar(java.sql.Connection c, Oru o) throws SQLException {
        try (var ps = c.prepareStatement("INSERT INTO staging.sih_resultado (result_id, version, analyte, value) VALUES (?, ?, ?, ?)")) {
            ps.setLong(1, o.resultId()); ps.setInt(2, o.version()); ps.setString(3, o.analyte()); ps.setString(4, o.value());
            ps.executeUpdate();
        }
    }

    static void descartar(java.sql.Connection c, String body, String motivo, int entregas) throws SQLException {
        try (var ps = c.prepareStatement("INSERT INTO staging.sih_descartes (payload, reason, attempts) VALUES (?, ?, ?)")) {
            ps.setString(1, body); ps.setString(2, motivo); ps.setInt(3, entregas); ps.executeUpdate();
        }
    }

    static void trabajador(jakarta.jms.Connection conn, double caida, long seed, AtomicInteger aplicados) throws Exception {
        Random rnd = new Random(seed);
        Session s = conn.createSession(true, Session.SESSION_TRANSACTED);   // la entrega se confirma con commit
        MessageConsumer mc = s.createConsumer(s.createQueue(COLA));
        try (var c = db()) {
            c.setAutoCommit(true);
            while (true) {
                Message m = mc.receive(3000);
                if (m == null) break;
                String body = ((TextMessage) m).getText();
                int entregas = m.getIntProperty("JMSXDeliveryCount");
                Oru o;
                try { o = parse(body); }
                catch (RuntimeException e) { s.rollback(); continue; }   // que lo reintente
                aplicar(c, o);
                if (rnd.nextDouble() < caida) { s.rollback(); continue; }     // cae después de aplicar: el broker reentrega
                s.commit();
                aplicados.incrementAndGet();
            }
        } finally { s.close(); }
    }

    static double consumir(int hilos, double caida, long seed) throws Exception {
        AtomicInteger aplicados = new AtomicInteger();
        long t0 = System.nanoTime();
        try (var conn = cf().createConnection()) {
            conn.start();
            ExecutorService ex = Executors.newFixedThreadPool(hilos);
            List<Future<Object>> fs = new ArrayList<>();
            for (int h = 0; h < hilos; h++) { final long sd = seed + h; fs.add(ex.submit(() -> { trabajador(conn, caida, sd, aplicados); return null; })); }
            for (var f : fs) f.get();
            ex.shutdown();
        }
        double seg = (System.nanoTime() - t0) / 1e9 - 3.0;   // se descuenta la espera final de 3 s sin mensajes
        System.out.printf("consumidos con confirmación: %d · %.2f s (sin la espera final de 3 s)%n", aplicados.get(), seg);
        return seg;
    }

    static void purgar() throws Exception {
        int n = 0;
        try (var conn = cf().createConnection()) {
            conn.start();
            Session s = conn.createSession(false, Session.AUTO_ACKNOWLEDGE);
            for (String q : new String[]{COLA, "DLQ"}) {
                MessageConsumer mc = s.createConsumer(s.createQueue(q));
                while (mc.receive(500) != null) n++;
                mc.close();
            }
        }
        System.out.println("purgados: " + n);
    }

    // La medición de "¿hacía falta un broker?": n mensajes, sin caídas, publicados de golpe y consumidos con `hilos`.
    static void medir(int n, int hilos) throws Exception {
        try (var c = db(); var conn = cf().createConnection()) {
            Session s = conn.createSession(false, Session.AUTO_ACKNOWLEDGE);
            MessageProducer p = s.createProducer(s.createQueue(COLA));
            p.setDeliveryMode(DeliveryMode.PERSISTENT);
            long t0 = System.nanoTime();
            for (long i = 1; i <= n; i++) p.send(s.createTextMessage(oru(i, 1, "GLU", "100")));
            System.out.printf("publicados: %d en %.2f s%n", n, (System.nanoTime() - t0) / 1e9);
        }
        consumir(hilos, 0.0, 1996);
    }

    public static void main(String[] a) throws Exception {
        switch (a[0]) {
            case "purgar" -> purgar();
            case "producir" -> producir(Integer.parseInt(a[1]), Double.parseDouble(a[2]), 1996);
            case "consumir" -> consumir(Integer.parseInt(a[1]), Double.parseDouble(a[2]), 1996);
            case "medir" -> medir(Integer.parseInt(a[1]), Integer.parseInt(a[2]));
            default -> throw new IllegalArgumentException("modo desconocido: " + a[0]);
        }
    }
}
