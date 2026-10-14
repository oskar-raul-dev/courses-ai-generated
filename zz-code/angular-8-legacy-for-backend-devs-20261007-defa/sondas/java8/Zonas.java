// T3 probe for bea-08: America/Toronto rules on Java 8, as the appendix states them.
import java.time.*;
import java.time.zone.*;
import java.util.TimeZone;

public class Zonas {
    public static void main(String[] args) {
        ZoneId ott = ZoneId.of("America/Toronto");
        System.out.println("java " + System.getProperty("java.version") + " | default zone " + TimeZone.getDefault().getID());
        System.out.println("tzdb " + ZoneRulesProvider.getVersions("America/Toronto").lastKey());
        // Offsets in winter and summer
        System.out.println("2022-01-03T13:15Z en Ottawa: " + Instant.parse("2022-01-03T13:15:00Z").atZone(ott));
        System.out.println("2021-07-15T13:15Z en Ottawa: " + Instant.parse("2021-07-15T13:15:00Z").atZone(ott));
        // Transitions 2006-2007 and 2019-2022
        ZoneRules r = ott.getRules();
        for (int y : new int[] {2006, 2007, 2019, 2020, 2021, 2022}) {
            ZoneOffsetTransition t = r.nextTransition(LocalDate.of(y, 1, 1).atStartOfDay(ott).toInstant());
            ZoneOffsetTransition u = r.nextTransition(t.getInstant());
            System.out.println(y + ": " + t.getDateTimeBefore() + " -> " + t.getDateTimeAfter() + " | " + u.getDateTimeBefore() + " -> " + u.getDateTimeAfter());
        }
        // The hour that does not exist and the hour that happens twice
        System.out.println("gap  2021-03-14T02:30 -> " + ZonedDateTime.of(LocalDateTime.parse("2021-03-14T02:30"), ott));
        ZonedDateTime early = ZonedDateTime.of(LocalDateTime.parse("2021-11-07T01:30"), ott);
        System.out.println("overlap 2021-11-07T01:30 -> " + early + " y " + early.withLaterOffsetAtOverlap());
        // The Era 1 constant written in summer
        OffsetDateTime era1 = OffsetDateTime.parse("2021-07-15T09:00:00-05:00");
        System.out.println("'2021-07-15T09:00:00-05:00' en Ottawa es " + era1.atZoneSameInstant(ott).toLocalTime() + " " + era1.atZoneSameInstant(ott).getOffset());
        // The java.util.Date of bea-08 §5
        long ms = 1757516645123L;
        System.out.println("1757516645123L = " + Instant.ofEpochMilli(ms) + " | toString: " + new java.util.Date(ms));
        System.out.println("2026-09-10T15:04:05.123Z = " + Instant.parse("2026-09-10T15:04:05.123Z").toEpochMilli() + "L | toString: " + new java.util.Date(Instant.parse("2026-09-10T15:04:05.123Z").toEpochMilli()));
    }
}
