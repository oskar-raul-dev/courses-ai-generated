package com.meridian.clearinghouse;

import java.util.Arrays;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * ClearingHouse, el gemelo Spring Boot. Con {@code --batch --day=AAAA-MM-DD} ejecuta el
 * cierre y termina (el modo del cierre de un millón de B-24); sin argumentos, sirve HTTP.
 */
@SpringBootApplication
public class ClearingHouseApplication {

    public static void main(String[] args) {
        SpringApplication app = new SpringApplication(ClearingHouseApplication.class);
        if (Arrays.asList(args).contains("--batch")) {
            app.setWebApplicationType(WebApplicationType.NONE);
            System.exit(SpringApplication.exit(app.run(args)));
        }
        app.run(args);
    }
}
