import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Runs SQL against an .accdb with UCanAccess: no Access, no Office, no Windows.
 *
 *   demo  <file.accdb>          what the front desk sees, the parser in SQL, the parser in code
 *   query <file.accdb> "<sql>"  any SQL you want
 *
 * UCanAccess loads the file into an in-memory HSQLDB, so the SQL dialect is Access-like but
 * not Access: InStr() returns 0 in UCanAccess 5.1.3, and LOCATE()/SUBSTRING() work instead.
 */
public class QueryAccdb {

    public static void main(String[] args) throws Exception {
        if (args.length < 2) {
            System.err.println("usage: demo <accdb> | query <accdb> \"<sql>\"");
            System.exit(2);
        }
        try (Connection conn = DriverManager.getConnection("jdbc:ucanaccess://" + args[1] + ";memory=true")) {
            switch (args[0]) {
                case "demo" -> demo(conn);
                case "query" -> printTable(query(conn, args[2]), 50);
                default -> throw new IllegalArgumentException("unknown command: " + args[0]);
            }
        }
    }

    static void demo(Connection conn) throws SQLException {
        section("1. Lo que ve la recepción: pacientes sin DNI cargado");
        printTable(query(conn, """
                SELECT id, nombre, dni, fecha_nac
                FROM pacientes
                WHERE dni IS NULL
                ORDER BY id"""), 8);

        section("2. El parser en SQL puro: solo sabe buscar 'DNI ' y cortar 8 caracteres");
        printTable(query(conn, """
                SELECT id, nombre,
                       CASE WHEN LOCATE('DNI ', nombre) > 0
                            THEN SUBSTRING(nombre, LOCATE('DNI ', nombre) + 4, 8)
                       END AS dni_con_sql
                FROM pacientes
                WHERE dni IS NULL
                ORDER BY id"""), 8);

        section("3. El parser de Rubén aplicado a lo que devuelve el SQL");
        List<String[]> rows = query(conn, """
                SELECT id, nombre
                FROM pacientes
                WHERE dni IS NULL
                ORDER BY id""");
        List<String[]> parsed = new ArrayList<>();
        parsed.add(new String[]{"id", "nombre", "dni_con_parser"});
        for (String[] r : rows.subList(1, rows.size())) {
            parsed.add(new String[]{r[0], r[1], RubenParser.extractDni(r[1])});
        }
        printTable(parsed, 8);

        section("4. Lo que el parser no ve: aciertos que no son un DNI de esa persona");
        List<String[]> wrong = new ArrayList<>();
        wrong.add(new String[]{"id", "nombre", "dni_con_parser", "problema"});
        for (String[] r : parsed.subList(1, parsed.size())) {
            String problem = r[2].isEmpty() ? "no encontró nada"
                    : r[1].contains("PASAP") ? "es un pasaporte"
                    : r[1].startsWith("RN ") ? "es el DNI de la madre"
                    : null;
            if (problem != null) wrong.add(new String[]{r[0], r[1], r[2], problem});
        }
        printTable(wrong, 20);
    }

    static void section(String title) {
        System.out.println("\n== " + title + "\n");
    }

    /** Runs a query and returns the header followed by every row, as strings. */
    static List<String[]> query(Connection conn, String sql) throws SQLException {
        try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            ResultSetMetaData md = rs.getMetaData();
            int n = md.getColumnCount();
            List<String[]> rows = new ArrayList<>();
            String[] header = new String[n];
            for (int i = 0; i < n; i++) header[i] = md.getColumnLabel(i + 1).toLowerCase();
            rows.add(header);
            while (rs.next()) {
                String[] r = new String[n];
                for (int i = 0; i < n; i++) {
                    Object v = rs.getObject(i + 1);
                    r[i] = v == null ? "NULL" : v.toString();
                }
                rows.add(r);
            }
            return rows;
        }
    }

    /** Prints header + rows as an aligned text table, up to maxRows data rows. */
    static void printTable(List<String[]> rows, int maxRows) {
        int total = rows.size() - 1;
        List<String[]> shown = rows.subList(0, Math.min(rows.size(), maxRows + 1));
        int n = rows.get(0).length;
        int[] w = new int[n];
        for (String[] r : shown) for (int i = 0; i < n; i++) w[i] = Math.min(60, Math.max(w[i], r[i].length()));
        for (int k = 0; k < shown.size(); k++) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < n; i++) {
                String cell = shown.get(k)[i];
                if (cell.length() > 60) cell = cell.substring(0, 57) + "...";
                sb.append(String.format("%-" + w[i] + "s", cell)).append(i < n - 1 ? " | " : "");
            }
            System.out.println(sb);
            if (k == 0) System.out.println("-".repeat(sb.length()));
        }
        System.out.printf("(%d filas%s)%n", total, total > maxRows ? ", mostrando " + maxRows : "");
    }

    /** DNI extraction from ModParser.bas (1998 version), same token walk as parse_patients.py. */
    static class RubenParser {

        static String extractDni(String raw) {
            if (raw == null) return "";
            String[] tokens = raw.trim().split(" ");
            for (int i = 0; i < tokens.length; i++) {
                String t = tokens[i];
                if (t.equals("DNI") && i < tokens.length - 1) {
                    return tokens[i + 1].replace(".", "");
                }
                if (isNumber(t) && t.replace(".", "").length() >= 7) {
                    return t.replace(".", "");
                }
            }
            return "";
        }

        static boolean isNumber(String t) {
            if (t.isEmpty()) return false;
            for (char c : t.toCharArray()) if (!Character.isDigit(c) && c != '.') return false;
            return true;
        }
    }
}
