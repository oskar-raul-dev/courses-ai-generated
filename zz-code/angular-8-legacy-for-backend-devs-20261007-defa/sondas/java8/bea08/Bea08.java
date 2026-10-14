import java.time.*;
import java.util.TimeZone;

public class Bea08 {
  static void block0() {
    // Lo correcto, y lo que usa el track a partir de be04:
    Instant now = Instant.now();                         // un instante, UTC, sin zona
    LocalDate birthDate = LocalDate.parse("1984-03-12"); // una fecha de calendario
    ZonedDateTime inOttawa = now.atZone(ZoneId.of("America/Toronto"));   // para pintar
    
    // Lo de 2019, que sigue vivo en medio código:
    java.util.Date date = new java.util.Date();
  }
  static void block1() {
    java.util.Date d = new java.util.Date(1789052645123L);   // 2026-09-10T15:04:05.123Z
    System.out.println(d);
    // Imprime la hora en la zona POR DEFECTO DE LA JVM. En el contenedor, UTC:
    // "Thu Sep 10 15:04:05 UTC 2026". En el portátil de un desarrollador en
    // Ottawa, "Thu Sep 10 11:04:05 EDT 2026": cuatro horas menos en septiembre,
    // cinco en enero.
    // El MISMO objeto, dos salidas distintas, y ninguna es "la fecha guardada".
  }
  static void block2() {
    // Compruébalo en tu propia pila. Es el ejercicio 4.
    System.out.println(TimeZone.getDefault().getID());
    System.out.println(ZoneId.systemDefault());
  }
  static void block3() {
    OffsetDateTime era1 = OffsetDateTime.parse("2021-07-15T09:00:00-05:00");
    System.out.println("  era1.atZoneSameInstant(ZoneId.of(\"America/Toronto\")) -> " + era1.atZoneSameInstant(ZoneId.of("America/Toronto")));
    // 2021-07-15T10:00-04:00[America/Toronto]
  }
  static void block4() {
    ZoneId ottawa = ZoneId.of("America/Toronto");
    System.out.println("  ZonedDateTime.of(LocalDateTime.parse(\"2021-03-14T02:30\"),  -> " + ZonedDateTime.of(LocalDateTime.parse("2021-03-14T02:30"), ottawa));
    // 2021-03-14T03:30-04:00 — las 02:30 de ese domingo no existen: java.time las corre una hora
    ZonedDateTime early = ZonedDateTime.of(LocalDateTime.parse("2021-11-07T01:30"), ottawa);
    // 2021-11-07T01:30-04:00 — y esta existe dos veces:
    System.out.println("  early.withLaterOffsetAtOverlap() -> " + early.withLaterOffsetAtOverlap());
    // 2021-11-07T01:30-05:00
  }
  public static void main(String[] a) {
    System.out.println("JVM zone " + TimeZone.getDefault().getID());
    System.out.println("-- bloque 0"); block0();
    System.out.println("-- bloque 1"); block1();
    System.out.println("-- bloque 2"); block2();
    System.out.println("-- bloque 3"); block3();
    System.out.println("-- bloque 4"); block4();
  }
}
