// bea-08 §5: what Spring Data 2.1's own LocalDate <-> Date converters do across JVM zones.
import java.time.LocalDate;
import java.util.Date;
import java.util.TimeZone;
import org.springframework.data.convert.Jsr310Converters;

public class LocalDateProbe {
    public static void main(String[] args) {
        String writer = args[0], reader = args[1];
        TimeZone.setDefault(TimeZone.getTimeZone(writer));
        Date stored = Jsr310Converters.LocalDateToDateConverter.INSTANCE.convert(LocalDate.parse("1984-03-12"));
        TimeZone.setDefault(TimeZone.getTimeZone(reader));
        LocalDate read = Jsr310Converters.DateToLocalDateConverter.INSTANCE.convert(stored);
        System.out.println("escrito en " + writer + " -> BSON " + stored.toInstant() + " -> leido en " + reader + " = " + read);
    }
}
