// Un UPDATE y una excepción antes de la segunda escritura: ¿quedó el UPDATE? Con `manual`, sin autocommit.
import java.sql.DriverManager;

void main(String[] args) throws Exception {
    boolean manual = args.length > 0 && args[0].equals("manual");
    var url = "jdbc:postgresql://postgres:5432/alameda";
    try (var conn = DriverManager.getConnection(url, "postgres", "lab"); var st = conn.createStatement()) {
        st.execute("CREATE TABLE IF NOT EXISTS alameda.payer_check (payer_code varchar(10) PRIMARY KEY, name varchar(100))");
        st.execute("DELETE FROM alameda.payer_check");
        st.execute("INSERT INTO alameda.payer_check VALUES ('PAMI', 'PAMI')");
        if (manual) {
            conn.setAutoCommit(false);
        }
        try {
            st.executeUpdate("UPDATE alameda.payer_check SET name = 'INSTITUTO NACIONAL' WHERE payer_code = 'PAMI'");
            throw new IllegalStateException("se cayó antes de la segunda escritura");
        } catch (IllegalStateException e) {
            if (manual) {
                conn.rollback();
            }
            IO.println("autocommit=" + conn.getAutoCommit() + " · excepción: " + e.getMessage());
        }
        try (var rs = st.executeQuery("SELECT name FROM alameda.payer_check")) {
            rs.next();
            IO.println("name = " + rs.getString(1));
        }
    }
}
