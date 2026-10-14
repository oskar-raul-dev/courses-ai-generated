// ContarEnPostgres.java · JDBC mínimo: el driver en el classpath, la consulta y su resultado.
import java.sql.DriverManager;

void main() throws Exception {
    var url = "jdbc:postgresql://postgres:5432/alameda";
    try (var conn = DriverManager.getConnection(url, "postgres", "lab");
         var st = conn.createStatement();
         var rs = st.executeQuery("SELECT count(*) FROM legacy.\"Pacientes\" WHERE \"Nombre\" LIKE '%Ñ%'")) {
        rs.next();
        IO.println("autocommit por defecto: " + conn.getAutoCommit());
        IO.println("filas con Ñ en legacy.\"Pacientes\": " + rs.getLong(1));
    }
}
