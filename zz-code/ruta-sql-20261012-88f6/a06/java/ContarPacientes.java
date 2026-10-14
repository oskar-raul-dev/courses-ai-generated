// Un solo archivo, sin proyecto: `java ContarPacientes.java`. Lee Pacientes.csv de la caja con dos
// juegos de caracteres y cuenta en Postgres las filas con Ñ, para comparar.
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

void main(String[] args) throws Exception {
    var csv = Path.of(args[0]);
    for (Charset charset : new Charset[] {StandardCharsets.UTF_8, StandardCharsets.ISO_8859_1}) {
        try {
            var lines = Files.readAllLines(csv, charset);
            long withEnye = lines.stream().filter(l -> l.contains("Ñ")).count();
            IO.println(charset + ": " + (lines.size() - 1) + " filas, " + withEnye + " con Ñ");
        } catch (java.nio.charset.MalformedInputException e) {
            IO.println(charset + ": " + e);     // la Ñ de Latin-1 (0xD1) no es UTF-8 válido
        }
    }
}
